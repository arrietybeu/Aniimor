-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\AccessControl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AccessControl")
local AccessControl = {}
local raw_next = next
local rawDataMap = setmetatable({}, {
	__mode = "k"
})

AccessControl.RawDataMap = rawDataMap

local function pairsIterator(t, k)
	local v

	k, v = next(t, k)

	if v ~= nil then
		return k, v
	end
end

local function ipairsIterator(t, i)
	i = i + 1

	local v = t[i]

	if v ~= nil then
		return i, v
	end
end

local shared_mt = {
	__index = function(proxy, k)
		if k == "_AccessControl_" then
			return true
		end

		if k == "_DEBUG_" and _G_IsDebugMode then
			return rawDataMap[proxy]
		end

		local raw = rawDataMap[proxy]

		return raw[k]
	end,
	__newindex = function(proxy, k, v)
		local tab = rawDataMap[proxy]

		if not pg.isReloading and not pg.isRuningScript then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("Cannot modify a read only table.", debug.traceback())
			end

			return
		end

		rawset(tab, k, v)
	end,
	__pairs = function(proxy)
		local tab = rawDataMap[proxy]

		return pairsIterator, tab, nil
	end,
	__ipairs = function(proxy)
		local tab = rawDataMap[proxy]

		return ipairsIterator, tab, 0
	end,
	__len = function(proxy)
		local tab = rawDataMap[proxy]

		return #tab
	end
}

function AccessControl.readOnly(tab)
	if type(tab) ~= "table" then
		return tab
	end

	if rawDataMap[tab] then
		return tab
	end

	for k, v in raw_next, tab do
		if type(v) == "table" then
			tab[k] = AccessControl.readOnly(v)
		end
	end

	local proxy = {}

	rawDataMap[proxy] = tab

	setmetatable(proxy, shared_mt)

	return proxy
end

function AccessControl:getRawTable(tab)
	if tab._AccessControl_ ~= true then
		return tab
	end

	local raw = rawDataMap[tab]

	if not raw then
		return tab
	end

	local rawTable = {}

	for k, v in raw_next, raw do
		if type(v) == "table" then
			rawTable[k] = self:getRawTable(v)
		else
			rawTable[k] = v
		end
	end

	return rawTable
end

return AccessControl
