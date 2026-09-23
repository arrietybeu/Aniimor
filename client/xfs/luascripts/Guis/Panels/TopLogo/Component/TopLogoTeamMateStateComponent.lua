-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoTeamMateStateComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local TopLogoTeamMateStateComponent = Class.LightClass("TopLogoTeamMateStateComponent", TopLogoItemComponent)

function TopLogoTeamMateStateComponent.resolveStateFromEntity(entity)
	if entity == nil then
		return nil
	end

	if entity.FALLEN_AID_ST and entity:FALLEN_AID_ST() then
		return UIConst.TOPLOGO_TEAM_MATE_STATE.AID
	end

	if entity.life == Const.LIFE_FALLEN then
		return UIConst.TOPLOGO_TEAM_MATE_STATE.FALLEN
	end

	return nil
end

function TopLogoTeamMateStateComponent:ctor(refUContainer, topLogoItem)
	TopLogoTeamMateStateComponent.super.ctor(self, refUContainer, topLogoItem)

	self.stateType = nil
	self.isCalling = false
end

function TopLogoTeamMateStateComponent:onDestroy()
	self.m_loadedTMStateCbFunc = nil

	TopLogoTeamMateStateComponent.super.onDestroy(self)
end

function TopLogoTeamMateStateComponent:resetRender()
	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	self.content = nil
	self.sliderUSlider = nil

	TopLogoTeamMateStateComponent.super.resetRender(self)
end

function TopLogoTeamMateStateComponent:findObjects()
	self.content = self.refUContainer.content:GetComponent("UComponent")

	local objRef = self.content:GetComponent("ObjectReference")

	self.sliderUSlider = objRef:GetRefValue("sliderUSlider")
end

function TopLogoTeamMateStateComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoTeamMateStateComponent.super.onLanguageChanged(self)
end

function TopLogoTeamMateStateComponent:addEntityListener()
	if self.entity then
		-- block empty
	end
end

function TopLogoTeamMateStateComponent:initUI()
	self:refreshVisible()

	if self:innerGetVisible() then
		self:refreshTopLogoInfo()
	end

	if not self.timerId and self:innerGetVisible() then
		self:onTopLogoCompVisibleChanged(true)
	end
end

function TopLogoTeamMateStateComponent:onTopLogoCompVisibleChanged(visible)
	if not self:checkContainerLoaded() then
		return
	end

	if visible then
		self:refreshTopLogoInfo()

		if self.entity then
			self.timerId = self:startTimer(function()
				if not self.entity then
					return
				end

				if self.stateType == UIConst.TOPLOGO_TEAM_MATE_STATE.AID then
					if self.fallenAidDuration == nil then
						self.fallenAidDuration = self.entity.fallenAidEndTime - self.entity:getGameTime()
					end

					local aidProgress = 1 - (self.entity.fallenAidEndTime - self.entity:getGameTime()) / self.fallenAidDuration

					aidProgress = math.clamp(aidProgress, 0, 1)
					self.sliderUSlider.value = aidProgress
				else
					local curHp = self.entity.curHp
					local maxHp = self.entity.maxHp

					self.sliderUSlider.value = curHp / maxHp
					self.fallenAidDuration = nil
				end
			end, 0.1, true)
		end
	else
		if self.timerId then
			self:killTimer(self.timerId)

			self.timerId = nil
		end

		if self.entity:FALLEN_AID_ST() then
			pg.me:serverMsgNoGC("RPC_CS_StopFallenAid", self.entity.actorId)
		end
	end
end

function TopLogoTeamMateStateComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoTeamMateStateComponent:innerGetVisible()
	return self:shouldBeActive()
end

function TopLogoTeamMateStateComponent:shouldBeActive()
	return self.stateType ~= nil
end

function TopLogoTeamMateStateComponent:m_updateStateType(stateType)
	local oldStateType = self.stateType

	if oldStateType ~= stateType and (oldStateType == UIConst.TOPLOGO_TEAM_MATE_STATE.AID or stateType == UIConst.TOPLOGO_TEAM_MATE_STATE.AID) then
		self.fallenAidDuration = nil
	end

	self.stateType = stateType
end

function TopLogoTeamMateStateComponent:restoreStateFromEntity()
	self:m_updateStateType(TopLogoTeamMateStateComponent.resolveStateFromEntity(self.entity))

	self.isCalling = self.entity ~= nil and self.entity.callHelpTimer ~= nil
end

function TopLogoTeamMateStateComponent:refreshStateFromEntity()
	self:restoreStateFromEntity()
	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())

	if not self:shouldBeActive() then
		return
	end

	if self:checkContainerLoaded() then
		self:refreshTopLogoInfo()

		return
	end

	if not self.m_loadedTMStateCbFunc then
		function self.m_loadedTMStateCbFunc(isSuccess)
			if isSuccess then
				self:refreshVisible()
				self:refreshTopLogoInfo()
			end
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedTMStateCbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoTeamMateStateComponent:setStateType(stateType)
	self:m_updateStateType(stateType)
	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())

	if not self:shouldBeActive() then
		return
	end

	if self:checkContainerLoaded() then
		self:refreshTopLogoInfo()

		return
	end

	if not self.m_loadedTMStateCbFunc then
		function self.m_loadedTMStateCbFunc(isSuccess)
			if isSuccess then
				self:refreshVisible()
				self:refreshTopLogoInfo()
			end
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedTMStateCbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoTeamMateStateComponent:refreshVisible(skipRefresh)
	TopLogoItemComponent.refreshVisible(self, skipRefresh)
end

function TopLogoTeamMateStateComponent:setIsCalling(value)
	local isCalling = value == true

	if isCalling and self.stateType == nil then
		self:m_updateStateType(TopLogoTeamMateStateComponent.resolveStateFromEntity(self.entity))
	end

	self.isCalling = isCalling

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())

	if not self:shouldBeActive() then
		return
	end

	if self:checkContainerLoaded() then
		self:refreshTopLogoInfo()

		return
	end

	if not isCalling then
		return
	end

	if not self.m_loadedTMStateCbFunc then
		function self.m_loadedTMStateCbFunc(isSuccess)
			if isSuccess then
				self:refreshVisible()
				self:refreshTopLogoInfo()
			end
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedTMStateCbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoTeamMateStateComponent:refreshTopLogoInfo(callFromUpdate)
	if self.content and self:innerGetVisible() then
		self.content:TryChangePage("Type", self.stateType)
		self.content:TryChangePage("State", self.isCalling and 1 or 0)
	end
end

return TopLogoTeamMateStateComponent
