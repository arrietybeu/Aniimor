-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossEpComp.lua

local Class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local EP_ATTRIBUTE_IDS = {
	AttributeConst.ep_cur,
	AttributeConst.ep_max_cur,
	AttributeConst.ep_temp_cur,
	AttributeConst.ep_temp_max
}
local BossEpComp = Class.LightClass("BossEpComp")

function BossEpComp:ctor(owner)
	self.owner = owner
	self.epBalls = nil
	self.specialTempEpBalls = nil
	self.finalEpBalls = {}
	self.dirtyEpIndex = {}
	self.lastNormalBallCount = nil
	self.lastTempBallCount = nil
	self.m_notifyTarget = nil
	self.m_notifyInfoList = nil
	self.oneBallEpValue = SysConfigData.EP_VALUE_PER_BALL or 1
end

function BossEpComp:onBind(objectReference)
	self.epListUList = objectReference:GetRefValue("epListUList")

	if self.epListUList then
		function self.epListUList.luaRenderItem(button, index, data)
			button:TryChangePage("state", data.state)

			button:GetChild("Progress"):GetComponent("UImage").fillAmount = data.progress
		end
	end
end

function BossEpComp:refresh(pawn)
	local owner = self.owner

	if not owner.m_isCreated or not pg.space:isNpcDuel() or not pawn then
		if self.epListUList then
			self.epListUList.gameObject:SetActiveEx(false)
		end

		return
	end

	if not pawn.actorCombatAttribute then
		return
	end

	self.epBalls = self.epBalls or {}
	self.specialTempEpBalls = self.specialTempEpBalls or {}

	local curEp = pawn.actorCombatAttribute:getEp()
	local maxEp = pawn.actorCombatAttribute:getMaxEp()
	local curTempEp = pawn.actorCombatAttribute:getTempEp()
	local maxTempEp = pawn.actorCombatAttribute:getMaxTempEp()

	curEp = curEp - curTempEp
	maxEp = maxEp - maxTempEp

	table.clear(self.finalEpBalls)
	table.clear(self.dirtyEpIndex)

	local normalCount = self:refreshBallData(self.epBalls, curEp, maxEp, self.finalEpBalls, self.dirtyEpIndex, 0)

	self:refreshBallData(self.specialTempEpBalls, curTempEp, maxTempEp, self.finalEpBalls, self.dirtyEpIndex, normalCount)

	local tempCount = #self.finalEpBalls - normalCount

	if self.epListUList then
		if normalCount ~= self.lastNormalBallCount or tempCount ~= self.lastTempBallCount then
			self.epListUList:SetList(self.finalEpBalls)

			self.lastNormalBallCount = normalCount
			self.lastTempBallCount = tempCount
		else
			for i = 1, #self.dirtyEpIndex do
				self.epListUList:RefreshElement(self.dirtyEpIndex[i])
			end
		end

		self.epListUList.gameObject:SetActiveEx(true)
	end
end

function BossEpComp:bindNotify(target)
	if self.m_notifyTarget == target and self.m_notifyInfoList then
		return
	end

	self:unbindNotify()

	if not target or not pg.space:isNpcDuel() then
		return
	end

	local actorCombatAttribute = target.actorCombatAttribute

	if not actorCombatAttribute then
		return
	end

	self.m_notifyTarget = target
	self.m_notifyInfoList = {}

	self:registerNotify(actorCombatAttribute, target)

	if actorCombatAttribute and actorCombatAttribute.masterActorCombatAttribute then
		self:registerNotify(actorCombatAttribute.masterActorCombatAttribute, target)
	end
end

function BossEpComp:registerNotify(actorCombatAttribute, target)
	if not actorCombatAttribute then
		return
	end

	for _, notifyInfo in ipairs(self.m_notifyInfoList) do
		if notifyInfo.actorCombatAttribute == actorCombatAttribute then
			return
		end
	end

	local notifyIds = {}

	local function refreshFunc()
		if self.m_notifyTarget == target and self.owner.curTarget == target then
			self:refresh(target)
		end
	end

	for _, attributeId in ipairs(EP_ATTRIBUTE_IDS) do
		notifyIds[#notifyIds + 1] = {
			attributeId = attributeId,
			notifyId = actorCombatAttribute:registerAttributeNotify(attributeId, refreshFunc)
		}
	end

	self.m_notifyInfoList[#self.m_notifyInfoList + 1] = {
		actorCombatAttribute = actorCombatAttribute,
		notifyIds = notifyIds
	}
end

function BossEpComp:unbindNotify()
	if not self.m_notifyInfoList then
		self.m_notifyTarget = nil

		return
	end

	for _, notifyInfo in ipairs(self.m_notifyInfoList) do
		local actorCombatAttribute = notifyInfo.actorCombatAttribute

		if actorCombatAttribute then
			for _, notifyData in ipairs(notifyInfo.notifyIds) do
				actorCombatAttribute:unregisterAttributeNotify(notifyData.attributeId, notifyData.notifyId)
			end
		end
	end

	self.m_notifyInfoList = nil
	self.m_notifyTarget = nil
end

function BossEpComp:refreshBallData(epBallList, curEp, maxEp, resultList, dirtyIndex, indexOffset)
	local ballCount = 1
	local maxBallCount = math.ceil(maxEp / self.oneBallEpValue)

	while ballCount <= maxBallCount do
		if epBallList[ballCount] == nil then
			epBallList[ballCount] = {
				state = 0,
				tIndex = 0
			}
		end

		local ball = epBallList[ballCount]
		local newState = curEp >= ballCount * self.oneBallEpValue and 0 or 1
		local newProgress = math.clamp(curEp / self.oneBallEpValue + 1 - ballCount, 0, 1)

		if ball.state ~= newState or ball.progress ~= newProgress then
			dirtyIndex[#dirtyIndex + 1] = indexOffset + ballCount - 1
		end

		ball.state = newState
		ball.progress = newProgress

		table.insert(resultList, ball)

		ballCount = ballCount + 1
	end

	while maxBallCount < #epBallList do
		table.remove(epBallList, #epBallList)
	end

	return maxBallCount
end

function BossEpComp:destroy()
	self:reset()

	self.epBalls = nil
	self.specialTempEpBalls = nil
	self.finalEpBalls = nil
	self.dirtyEpIndex = nil
end

function BossEpComp:reset()
	self:unbindNotify()

	self.lastNormalBallCount = nil
	self.lastTempBallCount = nil

	if self.epListUList then
		self.epListUList.gameObject:SetActiveEx(false)
	end
end

return BossEpComp
