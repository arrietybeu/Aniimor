-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\CatchProbGroup.lua

local Class = require("Core.Framework.Class")
local CatchProbGroup = Class.LightClass("CatchProbGroup")

function CatchProbGroup:ctor()
	self.mustGroup = {}
	self.minMaxGroup = {}
	self.base = 0
	self.baseCantCatch = false
end

function CatchProbGroup:setBase(base)
	self.baseCantCatch = base <= 0
	self.base = base
end

function CatchProbGroup:addMust(key, value)
	if not key then
		return
	end

	self.mustGroup[key] = value
end

function CatchProbGroup:addMinMax(key, value)
	if not key then
		return
	end

	self.minMaxGroup[key] = value
end

function CatchProbGroup:evaluate()
	local mustReason, isMust = self:getMustProb()
	local reason, minMaxProb = self:getMinMax()

	self.mustReason = mustReason

	if self.base * minMaxProb <= 0 then
		isMust = false
	end

	self.isMust = isMust

	if isMust then
		self.reason = mustReason
		self.prob = 1
	else
		self.minMaxProb = minMaxProb
		self.reason = reason
		self.prob = self.base * minMaxProb
	end
end

function CatchProbGroup:clear()
	table.clear(self.mustGroup)
	table.clear(self.minMaxGroup)

	self.base = 0
end

function CatchProbGroup:getMinMax()
	local min = math.huge
	local max = -math.huge
	local minKey, maxKey

	for k, v in pairs(self.minMaxGroup) do
		if v < min then
			min = v
			minKey = k
		end

		if max < v then
			max = v
			maxKey = k
		end
	end

	if min < 1 then
		return minKey, math.max(0, min)
	end

	return maxKey, math.max(0, max)
end

function CatchProbGroup:getMustProb()
	local has998 = false
	local key

	for k, v in pairs(self.mustGroup) do
		if v > 998 then
			has998 = true
			key = k
		end

		if v < 0 then
			return k, false
		end
	end

	return key, has998
end

return CatchProbGroup
