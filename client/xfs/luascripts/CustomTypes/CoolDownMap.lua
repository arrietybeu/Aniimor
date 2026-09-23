-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CoolDownMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local CoolDownMap = class.LiteClass("CoolDownMap", CustomDict)

function CoolDownMap:testCoolDown(cdType, cdId)
	local cdInfo = self[cdType]

	if cdInfo == nil or cdInfo[cdId] == nil then
		return true
	end

	return Time.secondCache >= cdInfo[cdId]
end

function CoolDownMap:getCoolDownRemainTime(cdType, cdId)
	local cdInfo = self[cdType]

	if cdInfo == nil or cdInfo[cdId] == nil then
		return 0
	end

	return cdInfo[cdId] - Time.secondCache
end

function CoolDownMap:setCoolDown(cdType, cdId, cdTime)
	self[cdType] = self[cdType] or {}
	self[cdType][cdId] = Time.secondCache + cdTime
end

function CoolDownMap:clrCoolDown(cdType, cdId)
	local cdInfo = self[cdType]

	if cdInfo == nil then
		return
	end

	cdInfo[cdId] = nil
end

return CoolDownMap
