-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\OctopusGashapon\\OctopusGashaponCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local OctopusGashaponCtrl = Class.LightClass("OctopusGashaponCtrl", UICtrl)
local ballExplodeTime = 0.24
local wonBuffId = 9162304
local BallColor = {
	ORANGE = 1,
	GOLD = 4,
	BLUE = 3,
	PINK = 2
}
local AttackState = {
	QUICK = 2,
	NORMAL = 1
}
local WinState = {
	WON = 2,
	NORMAL = 1
}
local BallAnimState = {
	Add = 2,
	NoneSlot = 1,
	Normal = 0,
	Explode = 3
}
local BallAnimColor = {
	ORANGE = 1,
	GOLD = 0,
	BLUE = 3,
	PINK = 2
}
local BallColorTOBallAnimColor = {
	[BallColor.ORANGE] = BallAnimColor.ORANGE,
	[BallColor.PINK] = BallAnimColor.PINK,
	[BallColor.BLUE] = BallAnimColor.BLUE,
	[BallColor.GOLD] = BallAnimColor.GOLD
}
local WinAnimColor = {
	ORANGE = 1,
	GOLD = 0,
	BLUE = 3,
	PINK = 2
}
local BallColorToWInAnimColor = {
	[BallColor.ORANGE] = WinAnimColor.ORANGE,
	[BallColor.PINK] = WinAnimColor.PINK,
	[BallColor.BLUE] = WinAnimColor.BLUE,
	[BallColor.GOLD] = WinAnimColor.GOLD
}

OctopusGashaponCtrl.messages = {
	[MessageName.DYNAMIC_LIST_REFRESH] = {
		"onRefreshBall",
		true
	},
	[MessageName.OCTOPUS_STATE_CHANGE] = {
		"onRefreshState",
		true
	},
	[MessageName.OCTOPUS_UI_INIT] = {
		"initUI",
		true
	}
}

function OctopusGashaponCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.view.enduranceFollowParentUIFollowTrans:SetUseCameraScaleLogic(true)
	self.view.enduranceFollowParentUIFollowTrans:SetCameraScaleOffsetParams(1, -300)
	self.view.enduranceFollowParentUIFollowTrans:AttachToEntity(pg.pawn.eModel)

	self.buffListId = "BubbleList"
	self.oldBallList = {}
	self.newBallList = {}
	self.attackState = AttackState.NORMAL
	self.winState = WinState.NORMAL
	self.winReceive = 0

	self:initUI()
end

function OctopusGashaponCtrl:initUI()
	self.BallMap = {
		self.view.ball_1,
		self.view.ball_2,
		self.view.ball_3,
		self.view.ball_4,
		self.view.ball_5
	}

	local curBallList = {}
	local curPetEntity = pg.me:getCurPetEntity()

	if curPetEntity and curPetEntity.dynamicListMap then
		curBallList = curPetEntity.dynamicListMap[self.buffListId] or {}
	end

	self.newBallList = curBallList

	for index, ballItem in pairs(self.BallMap) do
		local ball = curBallList[index]

		if not ball then
			self:changeBallState(ballItem, BallAnimState.NoneSlot)
		else
			self:changeBallColor(ballItem, BallColorTOBallAnimColor[ball])
			self:changeBallState(ballItem, BallAnimState.Normal)
		end
	end

	self:tickUpState()

	local wonColor = curPetEntity.wonColor
	local buff = curPetEntity.actorBuff:findOneBuffByTemplateId(wonBuffId)

	if buff and wonColor then
		local duration = buff.buffData.duration
		local remainingTime = buff:getRemainingTime()

		if duration and remainingTime > 0 and remainingTime - duration > 0 then
			self.winState = WinState.WON
			self.winReceive = 1

			if wonColor then
				local mapColor = {
					WinAnimColor.ORANGE,
					WinAnimColor.PINK,
					WinAnimColor.BLUE,
					WinAnimColor.GOLD
				}
				local color = mapColor[wonColor]

				self.view.rootAim:TryChangePage("Color", color)
				self.view.rootAim:TryChangePage("IsWin", true)
			end
		end
	else
		self:changeWinState(false, nil)
	end
end

function OctopusGashaponCtrl:onRefreshBall(info)
	if info.listId ~= self.buffListId or not self._visible or info.ent ~= pg.me then
		return
	end

	local curBallList = info.data

	if not curBallList then
		return
	end

	self.oldBallList = self.newBallList
	self.newBallList = curBallList

	self:showReal()
end

function OctopusGashaponCtrl:onRefreshState(info)
	local eventName = info.eventName
	local state = info.state

	if eventName == "QuickAttack" then
		if state then
			self.attackState = AttackState.QUICK
		else
			self.attackState = AttackState.NORMAL

			self:tickUpState()
		end
	elseif eventName == "Won" then
		if state then
			self.winState = WinState.WON
		else
			self.winState = WinState.NORMAL
			self.winReceive = 0

			self:changeWinState(false, nil)
		end
	end
end

function OctopusGashaponCtrl:showReal()
	if self.winState == WinState.WON and self.winReceive == 0 then
		if #self.newBallList == 0 then
			self.winReceive = 1

			self:tickUpState()

			for index, ballItem in pairs(self.BallMap) do
				if index <= #self.oldBallList then
					self:changeBallState(ballItem, BallAnimState.Explode)
				else
					self:changeBallState(ballItem, BallAnimState.NoneSlot)
				end
			end

			local count = {}
			local fullColor

			for _, ballIdx in pairs(self.oldBallList) do
				if not count[ballIdx] then
					count[ballIdx] = 0
				end

				count[ballIdx] = count[ballIdx] + 1

				if count[ballIdx] >= 4 then
					fullColor = ballIdx

					break
				end
			end

			self:startTimer(function()
				if fullColor then
					self:changeWinState(true, BallColorToWInAnimColor[fullColor])
				else
					self:changeWinState(true, BallColorToWInAnimColor[WinAnimColor.GOLD])
				end
			end, 0.5)
		end
	elseif #self.newBallList == #self.oldBallList + 1 then
		if self.attackState ~= AttackState.QUICK then
			self:tickSingleState()
		else
			self:tickDownState()
		end

		local curSlot = self.BallMap[#self.newBallList]

		if curSlot then
			self:changeBallColor(curSlot, BallColorTOBallAnimColor[self.newBallList[#self.newBallList]])
			self:changeBallState(curSlot, BallAnimState.Normal)
		end
	elseif #self.newBallList < #self.oldBallList then
		local deletedList = self:getDeletedIndex(self.oldBallList, self.newBallList)

		for _, idx in pairs(deletedList) do
			local deleteItem = self.BallMap[idx]

			self:changeBallState(deleteItem, BallAnimState.Explode)
		end

		local startId = deletedList[1]

		self:startTimer(function()
			for index, idx in pairs(self.newBallList) do
				if index >= startId then
					self:changeBallColor(self.BallMap[index], BallColorTOBallAnimColor[idx])
					self:changeBallState(self.BallMap[index], BallAnimState.Add)
				end
			end

			for idx, slot in pairs(self.BallMap) do
				if idx > #self.newBallList then
					self:changeBallState(slot, BallAnimState.NoneSlot)
				end
			end
		end, ballExplodeTime)
	elseif #self.newBallList == #self.oldBallList and #self.newBallList == 5 then
		if self.attackState ~= AttackState.QUICK then
			self:tickSingleState()
		else
			self:tickDownState()
		end

		for idx, slot in pairs(self.BallMap) do
			self:changeBallColor(slot, BallColorTOBallAnimColor[self.newBallList[idx]])
		end

		self:changeBallColor(self.view.ball_fake, BallColorTOBallAnimColor[self.oldBallList[1]])
		self:changeBallState(self.view.ball_fake, BallAnimState.Normal)
		self:startTimer(function()
			self:fullBallTrigger()
		end, 0.033)
	end
end

function OctopusGashaponCtrl:getDeletedIndex(a, b)
	local lenA = #a
	local lenB = #b
	local kept = {}
	local i = 1
	local j = 1

	while i <= lenA and j <= lenB do
		if a[i] == b[j] then
			kept[i] = true
			j = j + 1
		end

		i = i + 1
	end

	local deleted = {}

	for idx = 1, lenA do
		if not kept[idx] then
			table.insert(deleted, idx)
		end
	end

	return deleted
end

function OctopusGashaponCtrl:tickUpState()
	self:tickChangeState(0)
end

function OctopusGashaponCtrl:tickDownState()
	self:tickChangeState(1)
end

function OctopusGashaponCtrl:tickSingleState()
	self:tickChangeState(2)
end

function OctopusGashaponCtrl:tickChangeState(state)
	local curStack = self.view.rootAim:TryGetCurrentPage("Stick")

	if curStack == state then
		return
	end

	self.view.rootAim:TryChangePage("Stick", state)
end

function OctopusGashaponCtrl:fullBallTrigger()
	if self.attackState == AttackState.QUICK then
		self.view.rootAim:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	else
		self.view.rootAim:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function OctopusGashaponCtrl:changeWinState(isWin, color)
	local winState = 0

	if isWin then
		winState = 1
	end

	if color then
		self.view.rootAim:TryChangePage("Color", color)
	end

	self.view.rootAim:TryChangePage("IsWin", winState)
end

function OctopusGashaponCtrl:changeBallState(item, state)
	local curStage = item:TryGetCurrentPage("Stage")

	if curStage == state then
		return
	end

	item:TryChangePage("Stage", state)
end

function OctopusGashaponCtrl:changeBallColor(item, state)
	local curStage = item:TryGetCurrentPage("Stage")

	if curStage == state then
		return
	end

	item:TryChangePage("Color", state)
end

function OctopusGashaponCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return OctopusGashaponCtrl
