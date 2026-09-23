-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogEventVenture\\RogEventVentureCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RogueUtils = require("Utils.RogueUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local ItemConst = require("Common.Const.ItemConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local RogueConst = require("Const.RogueConst")
local RogEventVentureCtrl = Class.LightClass("RogEventVentureCtrl", UICtrl)

function RogEventVentureCtrl:onOpen(info)
	if not RogueUtils.isInRogueSpace() then
		self:closeDirect()

		return
	end

	function self.view.btnClose.luaClick()
		self:close()
	end

	function self.view.btnStop.luaClick()
		self:tryStop()
	end

	function self.view.btnStart.luaClick()
		self:setBtnInteract(false)
		pg.me:serverMsg("RPC_CS_ReqRogueStartRoll", self.diceMachineType, function(ret, rollPoint)
			RogueUtils.log("RPC_CS_ReqRogueStartRoll callback, rollPoint: %s", rollPoint)

			if ret then
				local endAniName = string.format("End%d", rollPoint)
				local time1 = AnimationUtils.getPlayableClipLength(self.npcEnt, PlayableConst.Start)
				local time2 = AnimationUtils.getPlayableClipLength(self.npcEnt, PlayableConst.Loop)
				local time3 = AnimationUtils.getPlayableClipLength(self.npcEnt, PlayableConst[endAniName])

				if self.npcEnt and self.npcEnt.playRawAnimation then
					self.npcEnt:playRawAnimation("Start", 0.05)
					TimerManager.addTimer(time1, function()
						self.npcEnt:playRawAnimation("Loop", 0.05)
					end)
					TimerManager.addTimer(time1 + time2, function()
						self.npcEnt:playRawAnimation(endAniName, 0.05)
					end)
				end

				pg.game.audio:playEvent("SFX_UI_Rouge_RollDice")

				self.stepStartTimer = TimerManager.addTimer(time1 + time2 + time3, function()
					self:onGetStep(rollPoint)
				end)
			end
		end)
	end

	self.moneyEnoughFlag = false
	self.btnInteractFlag = false

	self:refreshBtnShow()
	self:processOpenParam(info)
end

function RogEventVentureCtrl:closeDirect()
	self.hasInit = false

	UICtrl.close(self)
end

function RogEventVentureCtrl:close()
	if self.hasInit then
		self:onClickClose()
	else
		self:closeDirect()
	end
end

function RogEventVentureCtrl:processOpenParam(info)
	self.diceMachineType = info[1] and Const.RogueDiceMachineType.Buff or Const.RogueDiceMachineType.Npc
	self.npcEnt = pg.getEntity((info.dialogueContext or EMPTY_TABLE).globalId or 0)

	local diceSchemeId = self.model:tryGetDiceSchemeId(self.diceMachineType)

	if not diceSchemeId then
		pg.me:serverMsg("RPC_CS_ReqRogueOpenDice", self.diceMachineType, function(ret)
			if ret then
				self:onGetReqRogueOpenDice()
			else
				RogueUtils.logError("RPC_CS_ReqRogueOpenDice  invalid")
				self:closeDirect()
			end
		end)
	else
		self:onGetReqRogueOpenDice()
	end
end

function RogEventVentureCtrl:onGetReqRogueOpenDice()
	local diceSchemeId, diceRandomCount, totalRollPoint, currentRewardIndex, currentPointIndex, pointState, rewardState, rewardCount = self.model:initVentureData(self.diceMachineType)

	RogueUtils.log("RPC_CS_ReqRogueOpenDice callback, diceSchemeId: %s, diceRandomCount: %s, totalRollPoint: %s", diceSchemeId, diceRandomCount, totalRollPoint)

	if not diceSchemeId then
		RogueUtils.logError("onGetReqRogueOpenDice  投资数据初始化失败")
		self:closeDirect()

		return
	end

	self.diceSchemeId = diceSchemeId
	self.diceRandomCount = diceRandomCount
	self.totalRollPoint = totalRollPoint
	self.currentRewardIndex = currentRewardIndex
	self.currentPointIndex = currentPointIndex
	self.pointState = pointState
	self.rewardState = rewardState
	self.rewardCount = rewardCount
	self.remainPointNum = 0
	self.isForward = true

	self:setBtnInteract(true)
	self:refreshStructShow()
	self:refreshPointShow()
	self:refreshMoneyShow()
	self:refreshSurpriseShow()
	self:checkSendReward()
	self:foucsCurrent()
	LuaUIUtils.setUIViewVisible(self.view.txtNumber, false)
	UIUtils.PlayAnimation(self.view.rootAnim, "VX_Ani_Pb_Tower_Venture_Capita_In", function()
		LuaUIUtils.setUIViewVisible(self.view.txtNumber, true)
		self:refreshPointShow()
	end)

	self.hasInit = true
end

function RogEventVentureCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.stepStartTimer then
		TimerManager.removeTimer(self.stepStartTimer)

		self.stepStartTimer = nil
	end

	if self.stepUpdateTimer then
		TimerManager.removeTimer(self.stepUpdateTimer)

		self.stepUpdateTimer = nil
	end

	if self.npcEnt then
		AnimationUtils.playAnimation(self.npcEnt, PlayableConst.Idle)
	end
end

function RogEventVentureCtrl:onClickClose()
	if not self.btnInteractFlag then
		return
	end

	local isDiceFinish = self.model:isDiceFinish(self.diceMachineType)

	if isDiceFinish then
		self:closeDirect()
	else
		self:tryStop()
	end
end

function RogEventVentureCtrl:tryStop()
	pg.global.showConfirmMsgRaw(pg.getGameString("ROGUE_DIEC_CONFIRM_TITLE"), pg.getGameString("ROGUE_DIEC_CONFIRM"), function()
		pg.me:serverMsg("RPC_CS_ReqRogueEndRoll", self.diceMachineType, function(ret)
			if ret then
				self:refreshBtnShow()
				self:checkSendReward(true)
			end
		end)
	end)
end

function RogEventVentureCtrl:refreshStructShow()
	function self.view.listReward.luaRenderItem(button, idx, data)
		local objectReference = button:GetComponent("ObjectReference")
		local listItem = objectReference:GetRefValue("listItem")

		function listItem.luaRenderItem(_button, _index, _data)
			if _data.tIndex == 0 then
				LuaUIUtils.renderRewards(_button, _index, _data)
			end
		end

		local rewards = LuaUIUtils.getRewardItemByDropId(data.dropId)

		for i = 1, #rewards do
			if RogueUtils.useRogueQuality(rewards[i].id) then
				rewards[i].type = 2
			end
		end

		for i = #rewards + 1, 4 do
			rewards[i] = {
				tIndex = 1
			}
		end

		listItem:SetList(rewards)
		button:TryChangePage("Line", data.isTop and 0 or data.isDown and 2 or 1)
	end

	self.view.listReward:SetList(self.model:getRewardRenderData(self.diceSchemeId))

	local res, button = self.view.listReward:TryGetChildAt(self.rewardCount - 1)

	if res then
		local objectReference = button:GetComponent("ObjectReference")
		local zeroPointTransform = objectReference:GetRefValue("zeroPointTransform")
		local pos = self.view.txtNumber.transform.position

		pos.y = zeroPointTransform.position.y
		self.view.txtNumber.transform.position = pos
	end
end

function RogEventVentureCtrl:refreshPointShow()
	ClientTextUtils.setText(self.view.txtNumber, 0)

	local isStop = self.remainPointNum <= 0

	for index = 1, self.rewardCount do
		local viewIndex = self.rewardCount - index
		local res, button = self.view.listReward:TryGetChildAt(viewIndex)

		if res then
			local objectReference = button:GetComponent("ObjectReference")
			local listPoint = objectReference:GetRefValue("listPoint")
			local rewardIsCurrent = index == self.currentRewardIndex
			local rewardIsPast = self.rewardState[index]

			button:TryChangePage("Status", isStop and rewardIsCurrent and 1 or rewardIsPast and 2 or 0)

			local pointStateLine = self.pointState[index]

			function listPoint.luaRenderItem(_button, _index, _data)
				local logicIndex = #pointStateLine - _index
				local pointIsCurrent = rewardIsCurrent and logicIndex == self.currentPointIndex
				local pointIsPast = pointStateLine[logicIndex].state

				if pointIsCurrent then
					if isStop then
						_button:TryChangePage("Status", 1)
					else
						_button:TryChangePage("Status", 3)
					end
				elseif pointIsPast then
					_button:TryChangePage("Status", 2)
				else
					_button:TryChangePage("Status", 0)
				end

				if pointIsCurrent then
					local pos = self.view.txtNumber.transform.position

					pos.y = _button.transform.position.y
					self.view.txtNumber.transform.position = pos

					local isLast = index == self.rewardCount and logicIndex == #pointStateLine

					LuaUIUtils.setUIViewVisible(self.view.txtNumber, not isLast)
					ClientTextUtils.setText(self.view.txtNumber, self.totalRollPoint)
				end
			end

			listPoint:SetList(pointStateLine)
		end
	end
end

function RogEventVentureCtrl:refreshMoneyShow()
	local ownNum = ClientUtils.getItemCountById(ItemConst.ITEM_SPECIAL_ROGUE_COIN)
	local needNum = self.model:getCost(self.diceSchemeId, self.diceRandomCount)

	RogueUtils.setMoneyText(self.view.txtMoney, needNum, ownNum)
	self:setMoneyEnough(needNum <= ownNum)
end

function RogEventVentureCtrl:refreshBtnShow()
	local isDiceFinish = self.model:isDiceFinish(self.diceMachineType)

	self.view.btnStop.interactable = not isDiceFinish and self.btnInteractFlag
	self.view.btnStart.interactable = not isDiceFinish and self.btnInteractFlag and self.moneyEnoughFlag

	self.view.btnStop:SetActive(not isDiceFinish)
	self.view.btnClose:SetActive(isDiceFinish)
end

function RogEventVentureCtrl:refreshSurpriseShow()
	if self:checkSurprise() then
		self:playSurprise()
	end
end

function RogEventVentureCtrl:setMoneyEnough(flag)
	self.moneyEnoughFlag = flag

	self:refreshBtnShow()
end

function RogEventVentureCtrl:setBtnInteract(flag)
	self.btnInteractFlag = flag

	self:refreshBtnShow()
end

function RogEventVentureCtrl:onGetStep(stepNum)
	self.diceRandomCount = self.diceRandomCount + 1
	self.isForward = true
	self.remainPointNum = stepNum
	self.normalStepCounter = RogueConst.VentureNormalStepTime
	self.lastStepCounter = RogueConst.VentureLastStepTime
	self.stepUpdateTimer = TimerManager.addRepeatTimer(0.1, function()
		local go = false

		if self.remainPointNum > 1 then
			self.normalStepCounter = self.normalStepCounter - 1

			if self.normalStepCounter <= 0 then
				self.normalStepCounter = RogueConst.VentureNormalStepTime
				go = true
			end
		else
			self.lastStepCounter = self.lastStepCounter - 1

			if self.lastStepCounter <= 0 then
				self.lastStepCounter = RogueConst.VentureLastStepTime
				go = true
			end
		end

		if go then
			self:stepOne()
			self:refreshPointShow()

			if self.remainPointNum <= 0 then
				TimerManager.removeTimer(self.stepUpdateTimer)
				self:stepEnd()
				self:refreshMoneyShow()
				self:setBtnInteract(true)
			end
		end
	end)
end

function RogEventVentureCtrl:stepOne()
	if self.currentRewardIndex == self.rewardCount then
		self.isForward = false
	end

	if self.currentRewardIndex == 1 and self.currentPointIndex == 1 and not self.isForward then
		self.isForward = true
	end

	if self.isForward then
		self:stepOneForward()
	else
		self:stepOneBackward()
	end

	pg.game.audio:playEvent("SFX_UI_Rouge_MovePoint")
end

function RogEventVentureCtrl:stepOneForward()
	local goNextReward = self.currentRewardIndex == 0 or #self.pointState[self.currentRewardIndex] == self.currentPointIndex

	if goNextReward then
		self.currentRewardIndex = self.currentRewardIndex + 1
		self.currentPointIndex = 1
	else
		self.currentPointIndex = self.currentPointIndex + 1
	end

	self.totalRollPoint = self.totalRollPoint + 1
	self.remainPointNum = self.remainPointNum - 1
end

function RogEventVentureCtrl:stepOneBackward()
	local goPrevious = self.currentPointIndex == 1

	if goPrevious then
		self.currentRewardIndex = self.currentRewardIndex - 1
		self.currentPointIndex = #self.pointState[self.currentRewardIndex]
	else
		self.currentPointIndex = self.currentPointIndex - 1
	end

	self.totalRollPoint = self.totalRollPoint - 1
	self.remainPointNum = self.remainPointNum - 1
end

function RogEventVentureCtrl:stepEnd()
	local rewardIsNew = not self.rewardState[self.currentRewardIndex]

	if rewardIsNew then
		self.rewardState[self.currentRewardIndex] = true

		local viewIndex = self.rewardCount - self.currentRewardIndex
		local res, button = self.view.listReward:TryGetChildAt(viewIndex)

		if res then
			local objectReference = button:GetComponent("ObjectReference")
			local widgetItemAnim = objectReference:GetRefValue("widgetItemAnim")

			if self.currentRewardIndex == self.rewardCount then
				pg.game.audio:playEvent("SFX_UI_Rouge_ArriveEnd")
				UIUtils.PlayAnimation(widgetItemAnim, "VX_Ani_Node_RewardNormal_Refresh02", function()
					if self:checkSurprise() then
						self:playSurprise(function()
							self:checkSendReward(true)
						end)
					else
						self:checkSendReward(true)
					end
				end)
			else
				UIUtils.PlayAnimation(widgetItemAnim, "VX_Ani_Node_RewardNormal_Refresh")
			end
		end

		pg.game.audio:playEvent("SFX_UI_Rouge_LightUpRewards")
	end

	local pointIsNew = not self.pointState[self.currentRewardIndex][self.currentPointIndex].state

	if pointIsNew then
		self.pointState[self.currentRewardIndex][self.currentPointIndex].state = true
	end

	pg.game.audio:playEvent("SFX_UI_Rouge_FallPoint")
end

function RogEventVentureCtrl:checkSendReward(force)
	local isDiceFinish = self.model:isDiceFinish(self.diceMachineType)
	local isRewardFinish = self.model:isRewardFinish(self.diceMachineType)
	local needSend = force or isDiceFinish and not isRewardFinish

	if needSend then
		pg.me:serverMsg("RPC_CS_ReqRogueDiceSendReward", self.diceMachineType, function()
			self:closeDirect()
		end)
	end
end

function RogEventVentureCtrl:checkSurprise()
	local allGet = true

	for i = 1, self.rewardCount do
		if not self.rewardState[i] then
			allGet = false
		end
	end

	return allGet
end

function RogEventVentureCtrl:playSurprise(cb)
	self.view.rootComponent:TryChangePage("Status", 1)
	UIUtils.PlayAnimation(self.view.animSurprise, "VX_Ani_Pb_Tower_Venture_Capita_Reward", function()
		if cb then
			cb()
		end
	end)
end

function RogEventVentureCtrl:foucsCurrent()
	local firstIdx = self.currentRewardIndex > 0 and self.currentRewardIndex or 1
	local res, button = self.view.listReward:TryGetChildAt(self.rewardCount - firstIdx)

	if res then
		local objectReference = button:GetComponent("ObjectReference")
		local listItem = objectReference:GetRefValue("listItem")
		local res, defaultItem = listItem:TryGetChildAt(0)

		if res then
			pg.global.navMgr:FocusItem(defaultItem, CS.XGUI.Navigation.FocusEntryMode.Restore)
		end
	end
end

return RogEventVentureCtrl
