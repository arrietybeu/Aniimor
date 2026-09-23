-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CrossPlatformComponent.lua

local Class = require("Core.Framework.Class")
local ActivityConst = require("Common.Const.ActivityConst")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CrossPlatformComponent = Class.LightClass("CrossPlatformComponent", EventContainerComponent)

function CrossPlatformComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.taskUList = self.objectReference:GetRefValue("taskUList")
end

function CrossPlatformComponent:addListener()
	function self.taskUList.luaRenderItem(button, index, data)
		self:renderTaskButton(button, index, data)
	end
end

function CrossPlatformComponent:refreshPage()
	if not self:checkContentLoaded() then
		return
	end

	self:setEventTitle(nil)
	self.taskUList:SetList(self.model:getCrossPlatformTaskList())
end

function CrossPlatformComponent:renderTaskButton(btn, index, data)
	if not btn or not data then
		return
	end

	local objectReference = btn:GetComponent("ObjectReference")
	local taskDesUSDFText = objectReference:GetRefValue("taskDesUSDFText")
	local rewardItemUList = objectReference:GetRefValue("rewardItemUList")

	ClientTextUtils.setText(taskDesUSDFText, pg.getLocalizationText(data.taskDes))

	local canReceive = data.taskState == ActivityConst.TaskState.Finihed_CanRecv
	local hasReceived = data.taskState == ActivityConst.TaskState.Received or data.taskState == ActivityConst.TaskState.Received_SendMail
	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, hasReceived, canReceive)

	function rewardItemUList.luaRenderItem(rewardButton, rewardIndex, rewardData)
		LuaUIUtils.renderRewards(rewardButton, rewardIndex, rewardData)

		function rewardButton.luaClick()
			self:_showItemInfo(rewardData, rewardButton)
		end

		local treePath = string.format(RedDotConst.RedDotPath.EVENT_CROSS_PLATFORM_REWARD_ITEM, self.eventId, data.taskId, rewardIndex + 1)

		pg.global.setRedDot(treePath, rewardButton, canReceive, RedDotConst.RedDotStyle.REWARD)
	end

	rewardItemUList:SetList(rewards)
	btn:TryChangePage("State", hasReceived and 1 or 0)

	function btn.luaClick()
		if canReceive then
			pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
		end
	end
end

function CrossPlatformComponent:_showItemInfo(reward, button)
	if not reward or not button then
		return
	end

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

function CrossPlatformComponent:isCurrentTaskCanReceive()
	if not self.taskUList then
		return false
	end

	local navManager = pg.global.navMgr or CS.XGUI.Navigation.NavManager.Instance
	local focusedItem = navManager and navManager.CurrentFocusedUContent

	if not focusedItem or IsNil(focusedItem) then
		return false
	end

	local taskData = self.taskUList:GetData(focusedItem)

	return taskData ~= nil and taskData.taskState == ActivityConst.TaskState.Finihed_CanRecv
end

function CrossPlatformComponent:onBeforeExitPage()
	EventContainerComponent.onBeforeExitPage(self)
	self.ctrl:setCommonTitle(false)
end

function CrossPlatformComponent:onDestroy()
	EventContainerComponent.onDestroy(self)
end

return CrossPlatformComponent
