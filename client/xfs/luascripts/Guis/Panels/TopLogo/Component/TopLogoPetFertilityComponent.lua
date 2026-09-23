-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPetFertilityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local TopLogoConst = require("Const.TopLogoConst")
local EventConst = require("Const.EventConst")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local TopLogoPetFertilityComponent = Class.LightClass("TopLogoPetFertilityComponent", TopLogoItemComponent)

function TopLogoPetFertilityComponent:ctor(refUContainer, topLogoItem)
	self.tempPos = Vector3.New(0, 0, 0)
	self._hatchSlotStatus = nil
	self.petFertilityVisible = nil

	TopLogoPetFertilityComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoPetFertilityComponent:onCtor()
	self._isPetFertility = self.entity.className ~= "ClientStaticNpc"
	self.m_pendingFertilityRefresh = false

	TopLogoPetFertilityComponent.super.onCtor(self)
end

function TopLogoPetFertilityComponent:shouldBeActive()
	if self.m_pendingFertilityRefresh then
		return true
	end

	if not self.entity then
		return false
	end

	return self.entity.templateId == ClientConst.HATCH_BOX_ID
end

function TopLogoPetFertilityComponent:resetRender()
	self.petFertilityVisible = nil
	self._hatchSlotStatus = nil
	self.objectReference = nil
	self.rootComponent = nil
	self.hatchingCountDown = nil

	TopLogoPetFertilityComponent.super.resetRender(self)
end

function TopLogoPetFertilityComponent:onDestroy()
	self.m_pendingFertilityRefresh = false

	TopLogoPetFertilityComponent.super.onDestroy(self)

	self.m_loadedPetFertilityCallBack = nil
end

function TopLogoPetFertilityComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.hatchingCountDown = self.objectReference:GetRefValue("hatchingCountDown")
end

function TopLogoPetFertilityComponent:addEntityListener()
	function self.onPetFertilityMsg()
		self.m_pendingFertilityRefresh = true

		self:notifyActiveStateChanged(self:shouldBeActive())

		if not self.topLogoItem:isTopLogoPrefabReady() then
			return
		end

		self.m_pendingFertilityRefresh = false

		self:refreshVisible()
		self:refreshTopLogoInfo()
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PETFERTILITY, self.onPetFertilityMsg)
	end
end

function TopLogoPetFertilityComponent:innerGetVisible()
	if not self.entity then
		return false
	end

	if not TopLogoPetFertilityComponent.super.innerGetVisible(self) then
		return false
	end

	return true
end

function TopLogoPetFertilityComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingFertilityRefresh then
		self.m_pendingFertilityRefresh = false
	end

	self:refreshPetFertility()
end

function TopLogoPetFertilityComponent:refreshPetFertility()
	if self:checkContainerLoaded() then
		self:m_refreshTplPetFertility()
	else
		if not self.m_loadedPetFertilityCallBack then
			function self.m_loadedPetFertilityCallBack(isSuccess)
				if isSuccess then
					self:m_refreshTplPetFertility()
				end
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedPetFertilityCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end
end

function TopLogoPetFertilityComponent:m_getTopLogoShowHatchSlotIndex()
	for hatchSlotIndex, info in pairs(pg.me.hatchSlotMap or EMPTY_TABLE) do
		if info.status == Const.PET_BALL.HATCH_STATUS_SUCC then
			return hatchSlotIndex
		end
	end

	return Utils.getHatchBoxShowSlotIndex()
end

function TopLogoPetFertilityComponent:m_refreshTplPetFertility()
	local visible = self:checkFinalVisible()

	if self.petFertilityVisible ~= visible then
		self.petFertilityVisible = visible

		LuaUIUtils.setUIVisible(self.rootComponent, visible)
	end

	local hatchSlotIndex = self:m_getTopLogoShowHatchSlotIndex()
	local hatchSlotStatus, totalTime

	if not hatchSlotIndex then
		hatchSlotStatus = Const.PET_BALL.HATCH_STATUS_INIT
	else
		local status = pg.me.hatchSlotMap[hatchSlotIndex].status

		hatchSlotStatus = status
	end

	self._hatchSlotStatus = hatchSlotStatus

	if hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_START then
		local slotData = Utils.getHatchSlotEggInfoByIndex(hatchSlotIndex)

		totalTime = Utils.getHatchTime(slotData.id)
	end

	local targetState

	if hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_INIT then
		targetState = 0

		self.hatchingCountDown:Stop()
	elseif hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_START then
		targetState = 1

		local ts = pg.me.hatchSlotMap[hatchSlotIndex].endTs

		LuaUIUtils.setCountDownTime(self.hatchingCountDown, ts, UIConst.TimeType.Short)
	elseif hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_SUCC then
		targetState = 2

		self.hatchingCountDown:Stop()
	end

	self.rootComponent:TryChangePage("State", targetState)
end

function TopLogoPetFertilityComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoPetFertilityComponent.super.onLanguageChanged(self)
end

function TopLogoPetFertilityComponent:getInitMaxDistance()
	if self.entity.templateId == ClientConst.HATCH_BOX_ID and self._isPetFertility then
		return SysConfigData.PET_FERTILITY_TOPLOGO_DISTANCE
	end

	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoPetFertilityComponent
