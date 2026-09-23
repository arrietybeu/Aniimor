-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\SignFourteenDayComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local SignFourteenDayComponent = Class.LightClass("SignFourteenDayComponent", UIComponent)

function SignFourteenDayComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.btnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.btnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.exNameText = objectReference:GetRefValue("exNameText")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.exTimeText = objectReference:GetRefValue("exTimeText")
end

function SignFourteenDayComponent:onCtor(info)
	self.eventId = info.eventId

	local signData = self.model:getSignData(self.eventId)

	self.curDay = signData and signData.totalSignNum or 1
end

function SignFourteenDayComponent:initView()
	self:addListener()
	self:refreshPage()
end

function SignFourteenDayComponent:addListener()
	function self.listUList.luaRenderItem(button, index, data)
		self:renderSignItem(button, index, data)
	end

	function self.btnLeftUButton.luaClick()
		self.curShowSignIndex = math.max(self.curShowSignIndex - 1, 1)

		self:refreshExShowSign()
	end

	function self.btnRightUButton.luaClick()
		self.curShowSignIndex = math.min(self.curShowSignIndex + 1, #self.exShowSign)

		self:refreshExShowSign()
	end

	function self.btnSearchUButton.luaClick()
		local curExShowSign = self.exShowSign[self.curShowSignIndex]

		if curExShowSign then
			local taskState = curExShowSign.taskState
			local rewards = LuaUIUtils.getRewardItemByDropId(curExShowSign.taskAward, taskState >= ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

			self.ctrl:showSignItemInfo(rewards[1], self.btnSearchUButton)
		end
	end
end

function SignFourteenDayComponent:refreshPage()
	self.exShowSign = {}

	local signCfgList = self.model:getSignList(self.eventId)

	self.listUList:SetList(signCfgList)

	if not self.curShowSignIndex then
		local showIndex = 1

		for i = 1, #self.exShowSign do
			if self.exShowSign[i].taskState < ActivityConst.TaskState.Received then
				showIndex = i

				break
			end
		end

		self.curShowSignIndex = showIndex
	end

	self:refreshExShowSign()
end

function SignFourteenDayComponent:refreshExShowSign()
	if next(self.exShowSign) then
		self.btnLeftUButton.gameObject:SetActiveEx(self.curShowSignIndex ~= 1)
		self.btnRightUButton.gameObject:SetActiveEx(self.curShowSignIndex ~= #self.exShowSign)

		local curExShowSign = self.exShowSign[self.curShowSignIndex]
		local taskState = curExShowSign.taskState
		local rewards = LuaUIUtils.getRewardItemByDropId(curExShowSign.taskAward, taskState >= ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

		if rewards[1].petId then
			ClientTextUtils.setText(self.exNameText, LuaUIUtils.getPetNameWithIdOrTmpId(rewards[1].petId))
		else
			local itemInfo = LuaUIUtils.getItemInfoById(rewards[1].id)

			ClientTextUtils.setText(self.exNameText, itemInfo.name)
		end

		local addTex

		if taskState >= ActivityConst.TaskState.Received then
			addTex = pg.getGameString("SIGNIN_AWARD_TIP_1")
		elseif taskState == ActivityConst.TaskState.Finihed_CanRecv then
			addTex = pg.getGameString("SIGNIN_AWARD_TIP_3")
		else
			addTex = pg.getFormatText(pg.getGameString("SIGNIN_AWARD_TIP_5"), curExShowSign.showIndex)
		end

		ClientTextUtils.setText(self.exTimeText, addTex)
	else
		self.btnLeftUButton.gameObject:SetActiveEx(false)
		self.btnRightUButton.gameObject:SetActiveEx(false)
	end
end

function SignFourteenDayComponent:renderSignItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtLockText = objectReference:GetRefValue("txtLockText")
	local txtDayText = objectReference:GetRefValue("txtDayText")
	local item1UButton = objectReference:GetRefValue("item1UButton")
	local item2UButton = objectReference:GetRefValue("item2UButton")

	ClientTextUtils.setText(txtDayText, string.format("%02d", data.showIndex))

	local taskState = data.taskState
	local btnState, getTex = self.model:getTaskInfo(ActivityConst.SignDayType.FourteenDay, taskState, self.curDay, data.showIndex)

	button:TryChangePage("Status", btnState)
	ClientTextUtils.setText(txtLockText, getTex)

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, taskState >= ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

	self:setRewardItem(item1UButton, taskState, data.taskId, rewards[1], data.eventIcon)
	item2UButton.gameObject:SetActiveEx(rewards[2])

	if rewards[2] then
		self:setRewardItem(item2UButton, taskState, data.taskId, rewards[2], data.eventIcon)
	end

	local canGet = taskState == ActivityConst.TaskState.Finihed_CanRecv

	function button.luaClick()
		if canGet then
			self:getSignReward(data.taskId)
		end
	end

	if data.eventIcon then
		self.exShowSign[#self.exShowSign + 1] = data
	end

	self.ctrl:setSignRodDot(index, button, canGet)
end

function SignFourteenDayComponent:setRewardItem(button, taskState, taskId, reward, eventIcon)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local itemUImage = objectReference:GetRefValue("itemUImage")

	ClientTextUtils.setText(textUBaseText, string.format("x%s", reward.num))

	itemUImage.url = reward.petId and eventIcon and eventIcon or LuaUIUtils.getIconByItemId(reward.id)

	function button.luaClick()
		if taskState == ActivityConst.TaskState.Finihed_CanRecv then
			self:getSignReward(taskId)
		else
			self.ctrl:showSignItemInfo(reward, button)
		end
	end
end

function SignFourteenDayComponent:getSignReward(taskId)
	pg.me:reqActReceiveTaskReward(taskId, self.eventId)
end

function SignFourteenDayComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return SignFourteenDayComponent
