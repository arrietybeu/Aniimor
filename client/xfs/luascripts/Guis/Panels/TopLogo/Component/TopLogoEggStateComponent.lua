-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoEggStateComponent.lua

local UIConst = require("Const.UIConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local TopLogoConst = require("Const.TopLogoConst")
local Class = require("Core.Framework.Class")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local logger = LoggerManager.getLogger("TopLogoEggStateComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local TopLogoEggStateComponent = Class.LightClass("TopLogoEggStateComponent", TopLogoItemComponent)

function TopLogoEggStateComponent:ctor(refUContainer, topLogoItem)
	TopLogoEggStateComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoEggStateComponent:onDestroy()
	TopLogoEggStateComponent.super.onDestroy(self)

	self.m_loadedEggStateCallBack = nil
end

function TopLogoEggStateComponent:resetRender()
	self.eggName = nil
	self.subName = nil
	self.countDown = nil
	self.state = nil
	self.ownerUid = nil

	TopLogoEggStateComponent.super.resetRender(self)
end

function TopLogoEggStateComponent:findObjects()
	local objectReference = self.refUContainer.content:GetComponent("ObjectReference")

	self.eggName = objectReference:GetRefValue("eggName")
	self.subName = objectReference:GetRefValue("subName")
	self.countDown = objectReference:GetRefValue("countDown")
	self.countDown.positiveTiming = true

	function self.countDown.onGetBaseText(d, h, m, s, ms)
		local remain = math.max(0, self.countDown.totalSecond - self.countDown.currentSecond)
		local rm = math.floor(remain / 60)
		local rs = math.floor(remain % 60)

		return string.format("%02d:%02d", rm, rs)
	end
end

function TopLogoEggStateComponent:refreshEggName()
	if self.entity then
		local configData = self.entity:getConfigData()

		ClientTextUtils.setText(self.eggName, pg.getLocalizationText(configData.name))
	end
end

function TopLogoEggStateComponent:initUI()
	self:refreshEggName()
end

function TopLogoEggStateComponent:refreshTopLogoInfo(callFromUpdate)
	if self:checkFinalVisible() then
		if self:checkContainerLoaded() then
			self:m_refreshTplEggStateInfo()
		else
			if not self.m_loadedEggStateCallBack then
				function self.m_loadedEggStateCallBack(isSuccess)
					if isSuccess then
						self:m_refreshTplEggStateInfo()
					end
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedEggStateCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	end
end

function TopLogoEggStateComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoEggStateComponent.super.onLanguageChanged(self)
	self:refreshEggName()

	self.state = nil
	self.ownerUid = nil

	self:m_refreshTplEggStateInfo()
end

function TopLogoEggStateComponent:m_refreshTplEggStateInfo()
	if self.entity then
		local transferPoint = self.entity.space.transportInfo[self.entity.staticId]
		local state = transferPoint.state
		local ownerUid = transferPoint.ownerUid

		if self:checkStateChange(state, ownerUid) then
			self.state = state
			self.ownerUid = ownerUid

			if state == Const.ROB_EGG_TRANSPORT_STATE.NORMAL then
				self.refUContainer.content:TryChangePage("Active", 0)
				self.refUContainer.content:TryChangePage("Type", 0)
				ClientTextUtils.setText(self.subName, pg.getGameString("GRAB_EGG_TRANSFER_NOT_ACTIVATED"))
			else
				self.refUContainer.content:TryChangePage("Active", 1)
				ClientTextUtils.setText(self.subName, pg.getLocalizationText(transferPoint.ownerName))

				local startTime = transferPoint.startTime or 0
				local finishTime = transferPoint.finishTime or 0
				local totalTime = finishTime - startTime
				local remaining = finishTime - Time.secondCache

				if remaining > 0 and totalTime > 0 then
					local elapsed = math.max(0, totalTime - remaining)

					self.countDown:Play(elapsed, totalTime)
				end

				local player = pg.me

				if player:grabEgg_isSelfTeamTransport(self.entity.staticId) then
					self.refUContainer.content:TryChangePage("Type", 0)
				else
					self.refUContainer.content:TryChangePage("Type", 1)
				end
			end
		end
	end
end

function TopLogoEggStateComponent:checkStateChange(state, ownerUid)
	if state ~= self.state then
		return true
	end

	if ownerUid ~= self.ownerUid then
		return true
	end

	return false
end

function TopLogoEggStateComponent:getInitMaxDistance()
	return UIConst.TopLogoEnterRange
end

return TopLogoEggStateComponent
