-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Timeline\\TimelineSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local Time = require("Core.Common.Time")
local TimelineSystem = Class.LightClass("TimelineSystem", SystemBase)

function TimelineSystem:onCtor()
	self.timelineList = {}
	self.lastTickTime = Time.realSecondCache
end

function TimelineSystem:addTimeline(luaTimeline)
	if luaTimeline:tick(0.001) and not table.contains(self.timelineList, luaTimeline) then
		self.timelineList[#self.timelineList + 1] = luaTimeline
	end
end

function TimelineSystem:onTick()
	local now = Time.realSecondCache
	local deltaTime = now - self.lastTickTime
	local timelineItem

	for index = #self.timelineList, 1, -1 do
		timelineItem = self.timelineList[index]

		if timelineItem == nil or timelineItem:tick(deltaTime) == false then
			table.remove(self.timelineList, index)
		end
	end

	self.lastTickTime = now
end

return TimelineSystem
