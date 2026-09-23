-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Challenge\\ChallengeSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ChallengeSystem")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local ChallengeSystem = Class.LightClass("ChallengeSystem", SystemBase)

function ChallengeSystem:onCtor()
	self.challengeInfo = {}
	self.curChallengeItem = nil
end

function ChallengeSystem:onTick()
	local changed = false

	for challengeKey, challengeItem in pairs(self.challengeInfo) do
		if challengeItem.removeTime and challengeItem.removeTime < Time.realSecondCache then
			self.challengeInfo[challengeKey] = nil
			changed = true
		end
	end

	if changed then
		self:updateCurChallenge()
	end
end

function ChallengeSystem:getCurChallengeInfo()
	if self.curChallengeItem then
		return self.curChallengeItem.challengeInfo
	end

	return nil
end

function ChallengeSystem:addChallenge(challengeKey, challengeInfo)
	for existChallengeKey, challengeItem in pairs(self.challengeInfo) do
		if challengeItem.removeTime then
			self.challengeInfo[existChallengeKey] = nil
		end
	end

	self.challengeInfo[challengeKey] = {
		challengeInfo = challengeInfo,
		addTime = Time.realSecondCache
	}

	self:updateCurChallenge()
end

function ChallengeSystem:updateCurChallenge()
	local curChallengeItem

	for challengeKey, challengeItem in pairs(self.challengeInfo) do
		if curChallengeItem == nil then
			curChallengeItem = challengeItem
		elseif self:comparePriority(curChallengeItem, challengeItem) < 0 then
			curChallengeItem = challengeItem
		end
	end

	self.curChallengeItem = curChallengeItem

	facade:sendMsgToUI(MessageName.CHALLENGE_UPDATE)
end

function ChallengeSystem:comparePriority(challengeA, challengeB)
	return challengeA.addTime - challengeB.addTime
end

function ChallengeSystem:removeChallenge(challengeKey, keepTime)
	keepTime = keepTime or 0

	local challengeItem = self.challengeInfo[challengeKey]

	if challengeItem then
		if keepTime <= 0 then
			self.challengeInfo[challengeKey] = nil

			if challengeItem == self.curChallengeItem then
				self:updateCurChallenge()
			end
		elseif challengeItem ~= self.curChallengeItem then
			self.challengeInfo[challengeKey] = nil
		else
			challengeItem.removeTime = Time.realSecondCache + keepTime
		end
	end
end

function ChallengeSystem:clearWaitRemoveChallenges()
	local changed = false

	for challengeKey, challengeItem in pairs(self.challengeInfo) do
		if challengeItem.removeTime then
			self.challengeInfo[challengeKey] = nil
			changed = true
		end
	end

	if changed then
		self:updateCurChallenge()
	end
end

function ChallengeSystem:testAddChallenge()
	self:addChallenge("Test", {
		title = "Test",
		resetFunc = function()
			print("dxk on click")
		end
	})
end

function ChallengeSystem:testRemoveChallenge()
	self:removeChallenge("Test", 5)
end

return ChallengeSystem
