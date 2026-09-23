-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\UseLimitMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local LimitData = require("Data.limit_data")
local UseLimitMap = class.LiteClass("UseLimitMap", CustomDict)

function UseLimitMap:getInfo(key)
	if self[key] == nil and pg.component == "game" then
		self[key] = {
			count = 0,
			lastClearTs = Time.secondCache
		}

		if self.nextRefreshTs == 0 then
			self.nextRefreshTs = Time.secondCache
		end
	end

	return self[key]
end

function UseLimitMap:testLimit(templateId, testCount)
	testCount = testCount or 1

	local ldd = LimitData[templateId]

	if ldd == nil then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	local curCount = self[templateId] and self[templateId].count or 0

	if curCount + testCount > ldd.countLimit then
		return false, NoticeDef.ERROR_LIMIT_EXCEED
	end

	return true
end

function UseLimitMap:getLastRemainCount(templateId)
	local info = self[templateId]

	return info and info.lastRemainCount or 0
end

function UseLimitMap:getRealUsedCount(templateId)
	local info = self[templateId]

	return info and info.count or 0
end

function UseLimitMap:getUsedCount(templateId)
	local info = self[templateId]

	return info and info.count + info.lastRemainUseCount or 0
end

function UseLimitMap:getTotalCount(templateId)
	local ldd = LimitData[templateId]

	return ldd and ldd.countLimit or 0
end

function UseLimitMap:getRemainCount(templateId)
	return self:getTotalCount(templateId) - self:getUsedCount(templateId) + self:getLastRemainCount(templateId)
end

function UseLimitMap:getRealRemainCount(templateId)
	if templateId ~= 36 then
		return 0
	end

	return self:getTotalCount(templateId) - self:getRealUsedCount(templateId)
end

return UseLimitMap
