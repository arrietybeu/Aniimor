-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientXPartGMHook.lua

local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")
local EventConst = require("Const.EventConst")
local LuaCSConst = require("Common.Const.LuaCSConst")
local UIConst = require("Const.UIConst")
local ClientXPartGMHook = {}

function ClientXPartGMHook.getCurrentSceneID()
	local sceneID = 0
	local mainSceneId = 0

	if pg.me == nil or pg.me.space == nil then
		return mainSceneId
	end

	sceneID = pg.me.space.sceneId

	if sceneID == nil or sceneID == 0 then
		return mainSceneId
	end

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")

	mainSceneId = clientResMgrUtil.getXMainSceneId(sceneID)

	if mainSceneId == nil or mainSceneId == 0 then
		return 0
	end
end

function ClientXPartGMHook.hookGMExecCmdList(selectData, cbFuncGM)
	local tReturn = {
		TeleFunc = "",
		ToScene = 0,
		NeedTele = false
	}
	local needHook = ClientXPartGMHook._needHookExecCmdList(selectData, cbFuncGM, tReturn)

	if needHook == false then
		return false
	end

	if tReturn.NeedTele == false then
		return false
	end

	print(string.format("@fjs TrackHookGM hookGMExecCmdList, needHook[%s], tReturn[%s]", tostring(needHook), table.val_to_str(tReturn)))

	local function cbFuncXPart()
		cbFuncGM(selectData)
	end

	local luaCSConst = require("Common.Const.LuaCSConst")
	local clientXPartUtil = require("Utils.ClientXPartUtil")
	local sceneID = tReturn.ToScene

	if sceneID == nil then
		sceneID = 0
	end

	local arg = {
		KeyFrom = luaCSConst.XPartConst.KeyTeleToScene,
		ToScene = sceneID
	}

	clientXPartUtil.hookMainPlayerTeleportToScene(arg, cbFuncXPart)

	return true
end

function ClientXPartGMHook._needHookExecCmdList(selectData, cbFuncGM, tReturn)
	local GmToolUtils = require("Utils.GmToolUtils")
	local data = require(GmToolUtils.CMDListPrefix .. selectData.value)

	for _, cmd in ipairs(data.steps) do
		local ret = ClientXPartGMHook._getCmdListSceneID(selectData, cmd, tReturn)

		if ret == true then
			return true
		end
	end

	return false
end

function ClientXPartGMHook._getCmdListSceneID(selectData, cmd, tReturn)
	local mid = cmd.mid
	local param = cmd.params
	local eventName = ""
	local eventParam = ""
	local sceneID = 0
	local mainSceneId = 0

	if param ~= nil then
		eventName = param.eventName
		eventParam = param.eventParam
	end

	if mid == "doEventByData" and eventName == "teleportScenePosition" then
		sceneID = ClientXPartGMHook._getIntFromV3Str(eventParam)
	end

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")

	mainSceneId = clientResMgrUtil.getXMainSceneId(sceneID)

	if mainSceneId == nil or mainSceneId == 0 then
		return false
	end

	local curSceneID = ClientXPartGMHook.getCurrentSceneID()

	tReturn.ToScene = mainSceneId
	tReturn.TeleFunc = eventName

	if mainSceneId ~= curSceneID then
		tReturn.NeedTele = true
	end

	if tReturn.NeedTele == true then
		return true
	end

	return false
end

function ClientXPartGMHook._getIntFromV3Str(v3str)
	local val = 0
	local v3 = ClientXPartGMHook._getVector3(v3str)

	if v3 == nil then
		return val
	end

	val = v3[1]

	return val
end

function ClientXPartGMHook._getVector3(v3str)
	local func = load(string.format("return %s", v3str))
	local v3ret = func()

	return v3ret
end

return ClientXPartGMHook
