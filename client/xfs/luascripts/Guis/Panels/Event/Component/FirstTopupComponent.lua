-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\FirstTopupComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("FirstTopupComponent")
local Class = require("Core.Framework.Class")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local FirstTopupCardRenderer = require("Guis.Panels.Event.Component.FirstTopupCardRenderer")
local UIConst = require("Const.UIConst")
local CashShopConst = require("Const.CashShopConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local RedDotConst = require("Const.RedDotConst")
local Utils = require("Common.Utils.Utils")
local FirstTopupComponent = Class.LightClass("FirstTopupComponent", EventContainerComponent)

function FirstTopupComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	if self.transform.childCount == 0 then
		logger:warn("findObjects: no child found, content may not be loaded yet")

		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	if not objectReference then
		logger:warn("findObjects: ObjectReference not found")

		return
	end

	self.contentUComponent = objectReference:GetRefValue("contentUComponent")

	if self.contentUComponent then
		self.cardRenderer = FirstTopupCardRenderer(self.contentUComponent, {
			onGotoShop = function()
				self:_onGotoShop()
			end,
			onItemClick = function(reward, button)
				self:_showItemInfo(reward, button)
			end
		})
	end
end

function FirstTopupComponent:addListener()
	if not self.cardRenderer then
		logger:warn("addListener: cardRenderer not initialized")

		return
	end

	self.cardRenderer:bindListeners(function(cardIndex)
		self:_onCardClick(cardIndex)
	end, function(reward, button)
		self:_showItemInfo(reward, button)
	end)
end

function FirstTopupComponent:refreshPage()
	if not self:checkContentLoaded() or not self.cardRenderer then
		return
	end

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(nil, eventEndDayTime)

	local hasTopup = self.model:getIsFirstTopup()
	local isInEventPanel = true

	self.cardRenderer:setPageState(isInEventPanel, hasTopup)
	self.cardRenderer:refreshStaticTexts()

	self.rewardTasks = self.model:getFirstTopupRewardTask()

	if not self.rewardTasks or #self.rewardTasks < 3 then
		logger:warn("refreshPage: insufficient reward tasks, count=" .. (#self.rewardTasks or 0))

		return
	end

	local card1State = self.cardRenderer:refreshCard1(self.rewardTasks[1])
	local card2State = self.cardRenderer:refreshCard2Or3(self.rewardTasks[2], 2, card1State)

	self.cardRenderer:refreshCard2Or3(self.rewardTasks[3], 3, card2State)
	self.cardRenderer:refreshRewardRedDots(self.rewardTasks, function(index)
		return string.format(RedDotConst.RedDotPath.EVENT_FIRST_TOPUP_REWARD_ITEM, self.eventId, index)
	end)
end

function FirstTopupComponent:onEnterPage(eventId)
	EventContainerComponent.onEnterPage(self, eventId)

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("FirstTopupComponentFocusChange", function()
			if self.ctrl then
				self.ctrl:refreshConsoleBarState()
			end
		end)
	end
end

function FirstTopupComponent:focusOnReward()
	local navMgr = pg.global.navMgr
	local focused = navMgr and navMgr.CurrentFocusedUContent

	if not focused or IsNil(focused) then
		return false
	end

	local components = focused.gameObject:GetComponentsInChildren(typeof(CS.XGUI.UComponent), false)

	for i = 0, components.Length - 1 do
		if components[i].name == "UI_Com_RedTag_Reward" then
			return true
		end
	end

	return false
end

function FirstTopupComponent:_onCardClick(cardIndex)
	if not self.rewardTasks or not self.rewardTasks[cardIndex] then
		logger:warn("_onCardClick: invalid card index=" .. cardIndex)

		return
	end

	local taskData = self.rewardTasks[cardIndex]
	local taskState = taskData.taskState
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv

	if canReceive then
		pg.me:reqActReceiveTaskReward(taskData.taskId, self.eventId)
	end
end

function FirstTopupComponent:_onGotoShop()
	pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
		tabId = CashShopConst.CategoryType.RECHARGE
	})
end

function FirstTopupComponent:_showItemInfo(reward, button)
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

function FirstTopupComponent:onBeforeExitPage()
	EventContainerComponent.onBeforeExitPage(self)
	self.ctrl:setCommonTitle(false)

	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("FirstTopupComponentFocusChange")
	end
end

function FirstTopupComponent:onDestroy()
	EventContainerComponent.onDestroy(self)

	if self.cardRenderer then
		self.cardRenderer:dispose()

		self.cardRenderer = nil
	end

	self.contentUComponent = nil
	self.rewardTasks = nil
end

return FirstTopupComponent
