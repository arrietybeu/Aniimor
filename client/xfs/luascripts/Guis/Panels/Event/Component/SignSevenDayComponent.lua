-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\SignSevenDayComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local SignSevenDayComponent = Class.LightClass("SignSevenDayComponent", UIComponent)

function SignSevenDayComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.itemUButton = objectReference:GetRefValue("itemUButton")
end

function SignSevenDayComponent:onCtor(info)
	self.eventId = info.eventId

	local signData = self.model:getSignData(self.eventId)

	self.curDay = signData and signData.totalSignNum or 1
end

function SignSevenDayComponent:initView()
	self:addListener()
	self:refreshPage()
end

function SignSevenDayComponent:addListener()
	function self.listUList.luaRenderItem(button, index, data)
		self:renderSignItem(button, index, data)
	end

	function self.listUList.luaFinishRender()
		self:scheduleDefaultClaimableFocus()
	end
end

function SignSevenDayComponent:refreshPage(noListAnim)
	local signCfgList = self.model:getSignList(self.eventId) or {}
	local hasData = next(signCfgList) ~= nil

	if hasData then
		local noemalList = {}

		for i = 1, #signCfgList - 1 do
			table.insert(noemalList, signCfgList[i])
		end

		if noListAnim then
			self.listUList.itemData = noemalList

			self.listUList:RefreshList(true)
		else
			self.listUList:SetList(noemalList)
		end

		self:renderSignItem(self.itemUButton, #signCfgList - 1, signCfgList[#signCfgList])
	end

	self.listUList.gameObject:SetActiveEx(hasData)
	self.itemUButton.gameObject:SetActiveEx(hasData)
end

function SignSevenDayComponent:scheduleDefaultClaimableFocus()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self._defaultFocusFrameId then
		self:killFrameTimer(self._defaultFocusFrameId)
	end

	self._defaultFocusFrameId = self:startFrameTimer(function()
		self._defaultFocusFrameId = nil

		self:focusDefaultClaimableItem()
	end, 1)
end

function SignSevenDayComponent:focusDefaultClaimableItem()
	if not pg.game.input:isUsingGamepad() or not pg.global.navMgr then
		return false
	end

	local signCfgList = self.model:getSignList(self.eventId) or {}
	local signCount = #signCfgList

	for index, data in ipairs(signCfgList) do
		if data.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			local button

			if index == signCount then
				button = self.itemUButton
			else
				local success

				success, button = self.listUList:TryGetChildAt(index - 1)

				if not success then
					return false
				end
			end

			return button and pg.global.navMgr:FocusItem(button) or false
		end
	end

	return false
end

function SignSevenDayComponent:renderSignItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtLockText = objectReference:GetRefValue("txtLockText")
	local txtNumText = objectReference:GetRefValue("txtNumText")
	local txtGetText = objectReference:GetRefValue("txtGetText")

	button:TryChangePage("number", data.showIndex - 1)

	local taskState = data.taskState
	local btnState, getTex = self.model:getTaskInfo(ActivityConst.SignDayType.SevenDay, taskState, self.curDay, data.showIndex)

	button:TryChangePage("Status", btnState)
	ClientTextUtils.setText(txtLockText, getTex)

	if txtGetText then
		ClientTextUtils.setText(txtGetText, getTex)
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, taskState == ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

	ClientTextUtils.setText(txtNumText, string.format("x%s", rewards[1].num))

	iconUImage.url = data.eventIcon or LuaUIUtils.getIconByItemId(rewards[1].id)

	local canGet = taskState == ActivityConst.TaskState.Finihed_CanRecv

	function button.luaClick()
		if canGet then
			pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
		else
			self.ctrl:showSignItemInfo(rewards[1], button)
		end
	end

	self.ctrl:setSignRodDot(index, button, canGet)
end

function SignSevenDayComponent:onDestroy()
	if self._defaultFocusFrameId then
		self:killFrameTimer(self._defaultFocusFrameId)

		self._defaultFocusFrameId = nil
	end

	UIComponent.onDestroy(self)
end

return SignSevenDayComponent
