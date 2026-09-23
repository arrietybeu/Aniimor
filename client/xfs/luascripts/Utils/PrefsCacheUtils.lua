-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PrefsCacheUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CSPrefsUtil = CS.FunPlus.WorldX.Utils.PrefsUtil
local ClientConst = require("Const.ClientConst")
local logger = LoggerManager.getLogger("PrefsCacheUtils")
local VT_INT = 1
local VT_BOOL = 2
local VT_FLOAT = 3
local VT_STRING = 4
local WARNING_CACHE_SIZE = 5000
local Class = require("Core.Framework.Class")
local PrefsCacheUtils = Class.OldLightClass("PrefsCacheUtils", nil, true)
local GlobalData = require("Core.Client.GlobalData")

function PrefsCacheUtils:ctor()
	self.cacheTable = {}
	self.currentSize = 0
	self.canShowWarn = true
	self.prefsFunc = {
		[VT_INT] = {
			setFunc = "SetInt",
			immediatelySetFunc = "SetIntImmediately",
			getFunc = "GetInt"
		},
		[VT_BOOL] = {
			setFunc = "SetBool",
			immediatelySetFunc = "SetBoolImmediately",
			getFunc = "GetBool"
		},
		[VT_FLOAT] = {
			setFunc = "SetFloat",
			immediatelySetFunc = "SetFloatImmediately",
			getFunc = "GetFloat"
		},
		[VT_STRING] = {
			setFunc = "SetString",
			immediatelySetFunc = "SetStringImmediately",
			getFunc = "GetString"
		}
	}

	if UNITY_EDITOR then
		self:innerGetDebugEnterInfo()
	end
end

function PrefsCacheUtils:incCurrentSize()
	self.currentSize = self.currentSize + 1

	if self.canShowWarn and self.currentSize > WARNING_CACHE_SIZE then
		self.canShowWarn = false

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@liupeifu, PrefsCacheManager缓存的潜在总条目数已超过" .. WARNING_CACHE_SIZE .. ", 如果写入太多条目可能会引起异常")
		end
	end
end

function PrefsCacheUtils:tryGetUserName()
	local name = ""

	if GlobalData.Avatar then
		name = GlobalData.Avatar.username
	end

	if string.isNilOrEmpty(name) and pg.me then
		name = tostring(pg.me.uid)
	end

	return name
end

function PrefsCacheUtils:innerGet(key, defaultValue, valueType, flag)
	if flag == ClientConst.CACHE_TYPE_FLAG.USER then
		key = string.format("%s%s", self:tryGetUserName(), key)
	end

	local value = self.cacheTable[key]

	if value ~= nil then
		return value
	else
		self:incCurrentSize()
	end

	local funcName = self.prefsFunc[valueType].getFunc

	value = CSPrefsUtil[funcName](key, defaultValue)
	self.cacheTable[key] = value

	return value
end

function PrefsCacheUtils:innerSet(key, newValue, valueType, flag, immediately)
	if flag == ClientConst.CACHE_TYPE_FLAG.USER then
		key = string.format("%s%s", self:tryGetUserName(), key)
	end

	local oldValue = self.cacheTable[key]

	if oldValue == newValue then
		return
	elseif oldValue == nil then
		self:incCurrentSize()
	end

	local funcInfo = self.prefsFunc[valueType]
	local funcName = immediately and funcInfo.immediatelySetFunc or funcInfo.setFunc

	CSPrefsUtil[funcName](key, newValue)

	self.cacheTable[key] = newValue
end

function PrefsCacheUtils:deleteAll()
	CSPrefsUtil.DeleteAll()

	self.cacheTable = {}
end

function PrefsCacheUtils:getInt(key, defaultValue, flag)
	return self:innerGet(key, defaultValue, VT_INT, flag)
end

function PrefsCacheUtils:getBool(key, defaultValue, flag)
	return self:innerGet(key, defaultValue, VT_BOOL, flag)
end

function PrefsCacheUtils:getFloat(key, defaultValue, flag)
	return self:innerGet(key, defaultValue, VT_FLOAT, flag)
end

function PrefsCacheUtils:getString(key, defaultValue, flag)
	return self:innerGet(key, defaultValue, VT_STRING, flag)
end

function PrefsCacheUtils:setInt(key, newValue, flag)
	self:innerSet(key, newValue, VT_INT, flag)
end

function PrefsCacheUtils:setIntImmediately(key, newValue, flag)
	self:innerSet(key, newValue, VT_INT, flag, true)
end

function PrefsCacheUtils:setBool(key, newValue, flag)
	self:innerSet(key, newValue, VT_BOOL, flag)
end

function PrefsCacheUtils:setBoolImmediately(key, newValue, flag)
	self:innerSet(key, newValue, VT_BOOL, flag, true)
end

function PrefsCacheUtils:setFloat(key, newValue, flag)
	self:innerSet(key, newValue, VT_FLOAT, flag)
end

function PrefsCacheUtils:setFloatImmediately(key, newValue, flag)
	self:innerSet(key, newValue, VT_FLOAT, flag, true)
end

function PrefsCacheUtils:setString(key, newValue, flag)
	self:innerSet(key, newValue, VT_STRING, flag)
end

function PrefsCacheUtils:setStringImmediately(key, newValue, flag)
	self:innerSet(key, newValue, VT_STRING, flag, true)
end

function PrefsCacheUtils:save()
	CSPrefsUtil.Save()
end

function PrefsCacheUtils:deleteKey(key, flag)
	if flag == ClientConst.CACHE_TYPE_FLAG.USER then
		key = string.format("%s%s", self:tryGetUserName(), key)
	end

	self.cacheTable[key] = nil

	CSPrefsUtil.DeleteKey(key)
end

function PrefsCacheUtils:innerGetDebugEnterInfo()
	local SCENEID_KEY = "DebugEnterSceneId"
	local POS_KEY = "DebugEnterScenePos3"
	local sceneId = self:getInt(SCENEID_KEY, -1)

	if sceneId ~= -1 then
		GlobalData.DebugEnterSceneId = sceneId

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug(SCENEID_KEY, GlobalData.DebugEnterSceneId)
		end
	end

	local enterPos = self:getString(POS_KEY, "")

	if enterPos ~= "" then
		local DebugEnterScenePos3 = {}

		for number in string.gmatch(enterPos, "([-]?[%d%.]+)") do
			table.insert(DebugEnterScenePos3, tonumber(number))
		end

		GlobalData.DebugEnterScenePos3 = DebugEnterScenePos3

		local toolData = require("Editor.editor_utils")

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug(POS_KEY, toolData.dump(GlobalData.DebugEnterScenePos3))
		end
	end

	self:deleteKey(SCENEID_KEY)
	self:deleteKey(POS_KEY)
end

return PrefsCacheUtils
