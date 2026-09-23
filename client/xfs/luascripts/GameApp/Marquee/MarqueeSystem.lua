-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Marquee\\MarqueeSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local Lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("MarqueeSystem")
local ToBool = ToBool
local MARQUEE_DEFAULT_SPEED = 3

local function normalizeMarqueeSpeed(speed)
	if type(speed) == "number" then
		return speed
	end

	if type(speed) == "string" and speed ~= "" then
		local num = tonumber(speed)

		if num ~= nil then
			return num
		end
	end

	return MARQUEE_DEFAULT_SPEED
end

local MarqueeSystem = Class.LightClass("MarqueeSystem", SystemBase)

function MarqueeSystem:getMessageBindMap()
	return {
		[MessageName.ON_LOADING_PANEL_SHOW] = "onLoadingProgressShow"
	}
end

function MarqueeSystem:onCtor()
	self.marqueeInfo = {}
end

function MarqueeSystem:onTick()
	local loadProgress = pg.global.ui and pg.global.ui.loadProgress

	if loadProgress and loadProgress:checkUIShow() then
		pg.global.ui.tips:clearMarquee()

		return
	end

	self:tryTriggerMarquee()
end

function MarqueeSystem:onClear()
	pg.global.ui.tips:clearMarquee()
	Lume.clear(self.marqueeInfo)
end

function MarqueeSystem:onDestroy()
	self.marqueeInfo = nil
end

function MarqueeSystem:onLoadingProgressShow()
	pg.global.ui.tips:clearMarquee()
end

function MarqueeSystem:updateMarqueeInfo(info)
	if not ToBool(info) then
		self:onClear()

		return
	end

	for id, data in pairs(info) do
		if self.marqueeInfo[id] == nil then
			self.marqueeInfo[id] = data
		else
			local curData = self.marqueeInfo[id]

			if curData.channel ~= data.channel or curData.count ~= data.count or curData.internal ~= data.internal or curData.startTime ~= data.startTime or curData.endTime ~= data.endTime or curData.text ~= data.text or curData.speed ~= data.speed then
				self.marqueeInfo[id] = data
			end
		end
	end

	for id, data in pairs(self.marqueeInfo) do
		if info[id] == nil then
			self.marqueeInfo[id] = nil

			pg.global.ui.tips:clearMarqueeById(id)
		end
	end

	self:tryTriggerMarquee()
end

function MarqueeSystem:tryTriggerMarquee()
	if not ToBool(self.marqueeInfo) then
		return false
	end

	local curTime = Time.secondCache

	for id, data in pairs(self.marqueeInfo) do
		if not data.isObsolete then
			local nextTriggerTime = data.nextTriggerTime

			if nextTriggerTime then
				self:tryTriggerNextMarquee(id, data, curTime, nextTriggerTime)
			else
				self:calculateNextTriggerInfo(data, curTime)
				self:tryTriggerNextMarquee(id, data, curTime, data.nextTriggerTime)
			end
		else
			self.marqueeInfo[id] = nil
		end
	end
end

function MarqueeSystem:tryTriggerNextMarquee(id, data, curTime, nextTriggerTime)
	if data.isObsolete then
		return
	end

	if nextTriggerTime <= curTime then
		local needTips, needWorldChannel, needSystemChannel = self:checkMarqueeChannel(data.channel)

		if needTips then
			pg.global.ui.tips:addMarqueeText(data.text, id, normalizeMarqueeSpeed(data.speed))
		end

		if needWorldChannel then
			pg.game.chat:recvWorldMarqueeNotice(pg.getLocalizationText(data.text))
		end

		if needSystemChannel then
			pg.game.chat:recvSystemNotice(pg.getLocalizationText(data.text), 5)
		end

		self:calculateNextTriggerInfo(data, curTime)
	end
end

function MarqueeSystem:checkMarqueeChannel(channel)
	local needTips = false
	local needWorldChannel = false
	local needSystemChannel = false
	local typeChannel = type(channel)

	if typeChannel == "table" then
		for _, info in pairs(channel) do
			if info == 1 then
				needTips = true
			elseif info == 2 then
				needWorldChannel = true
			elseif info == 3 then
				needSystemChannel = true
			elseif info == 0 then
				needTips = true
				needWorldChannel = true
				needSystemChannel = true
			end
		end
	elseif typeChannel == "string" then
		for i = 1, #channel do
			local char = channel:sub(i, i)

			if char == "1" then
				needTips = true
			elseif char == "2" then
				needWorldChannel = true
			elseif char == "3" then
				needSystemChannel = true
			elseif char == "0" then
				needTips = true
				needWorldChannel = true
				needSystemChannel = true
			end
		end
	elseif typeChannel == "number" then
		if channel == 1 then
			needTips = true
		elseif channel == 2 then
			needWorldChannel = true
		elseif channel == 3 then
			needSystemChannel = true
		elseif channel == 0 then
			needTips = true
			needWorldChannel = true
			needSystemChannel = true
		end
	end

	return needTips, needWorldChannel, needSystemChannel
end

function MarqueeSystem:calculateNextTriggerInfo(data, curTime)
	if data.endTime and curTime > data.endTime then
		data.isObsolete = true

		return
	end

	if data.count == nil then
		data.isObsolete = true

		return
	end

	local count = tonumber(data.count)

	if count < 1 then
		data.isObsolete = true

		return
	end

	local interval = data.internal and tonumber(data.internal) or 0

	if not data.nextTriggerTime and interval >= curTime - data.startTime then
		data.nextTriggerTime = data.startTime

		return
	end

	if curTime > data.startTime + (count - 1) * interval then
		data.isObsolete = true

		return
	end

	if not data.nextTriggerTime then
		data.nextTriggerTime = data.startTime

		for i = 2, count do
			if data.nextTriggerTime >= curTime - interval then
				break
			end

			data.nextTriggerTime = data.nextTriggerTime + interval
		end
	else
		data.nextTriggerTime = data.nextTriggerTime + interval
	end
end

return MarqueeSystem
