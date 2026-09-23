-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\SignBaseComponent.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("SignBaseComponent")
local UIComponent = require("Guis.Helper.UIComponent")
local ActivityConst = require("Common.Const.ActivityConst")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local GameEventData = require("Data.game_event_data")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local SignBaseComponent = Class.LightClass("SignBaseComponent", EventContainerComponent)
local SignSevenDayComponent = require("Guis.Panels.Event.Component.SignSevenDayComponent")
local SignFourteenDayComponent = require("Guis.Panels.Event.Component.SignFourteenDayComponent")
local SignLongDayComponent = require("Guis.Panels.Event.Component.SignLongDayComponent")

function SignBaseComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.sevenDayObjectReference = objectReference:GetRefValue("sevenDayObjectReference")
	self.fourteenDayObjectReference = objectReference:GetRefValue("fourteenDayObjectReference")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
end

function SignBaseComponent:refreshPage(noListAnim)
	local signCfg = self.model:getSignCfg(self.eventId)

	if not signCfg then
		return
	end

	local signEndTime = self.model:getSignEndTime(self.eventId)

	self:setEventTitle(self.eventTitleUContainer, signEndTime)

	local status = self.eventType == ActivityConst.EventType.LongTermSign and ActivityConst.SignDayType.LongSign or signCfg.signinDayType

	if status == ActivityConst.SignDayType.SevenDay then
		self.rootUComponent:TryChangePage("status", 0)

		if not self.showPage then
			self.showPage = SignSevenDayComponent.new(self, self.sevenDayObjectReference, {
				eventId = self.eventId
			})
		else
			self.showPage:refreshPage(noListAnim)
		end
	elseif status == ActivityConst.SignDayType.FourteenDay then
		self.rootUComponent:TryChangePage("status", 1)

		if not self.showPage then
			self.showPage = SignFourteenDayComponent.new(self, self.fourteenDayObjectReference, {
				eventId = self.eventId
			})
		else
			self.showPage:refreshPage()
		end
	elseif status == ActivityConst.SignDayType.LongSign then
		self.rootUComponent:TryChangePage("status", 2)

		if not self.showPage then
			self.showPage = SignLongDayComponent.new(self, self.transform, {
				eventId = self.eventId
			})
		else
			self.showPage:refreshPage()
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("Sign signinDayType error ", self.eventId)
	end

	self:refreshCommonNodeRedDot()
end

function SignBaseComponent:onTaskStageChanged(info)
	local eventData = GameEventData[self.eventId]
	local noListAnim = eventData and eventData.container == "newHandSigninUContainer"

	self:refreshPage(noListAnim)
end

function SignBaseComponent:onEnterPlayEvent()
	EventContainerComponent.onEnterPlayEvent(self)

	local eventData = GameEventData[self.eventId]

	if eventData and eventData.container == "newHandSigninUContainer" and self.rootUComponent then
		self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function SignBaseComponent:showSignItemInfo(reward, button)
	if reward.petId then
		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = reward.petId
		})
	else
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = reward.id,
			targetRect = button,
			originData = {
				hideCount = true
			}
		})
	end
end

function SignBaseComponent:setSignRodDot(index, button, isShow)
	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_REUNION_SIGN, self.eventId, index), button, isShow, RedDotConst.RedDotStyle.REWARD)
end

function SignBaseComponent:onDestroy()
	if self.showPage then
		self.showPage:destroy()

		self.showPage = nil
	end

	UIComponent.onDestroy(self)
end

return SignBaseComponent
