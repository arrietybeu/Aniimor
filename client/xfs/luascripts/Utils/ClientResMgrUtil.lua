-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientResMgrUtil.lua

local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")
local EventConst = require("Const.EventConst")
local LuaCSConst = require("Common.Const.LuaCSConst")
local ClientResMgrUtil = {}

function ClientResMgrUtil.initSystem()
	return
end

function ClientResMgrUtil.onEventGameFlowChange(sOldState, sNewState, tParam)
	local cid = 0
	local iid = LuaCSConst.XPartConst.PIIDDefault
	local state = sNewState

	if state == "EnterLogin" then
		cid = LuaCSConst.XPartConst.PCIDLogin
	elseif state == "EnterRole" then
		cid = LuaCSConst.XPartConst.PCIDRole
	elseif state == "EnterNovice" then
		cid = LuaCSConst.XPartConst.PCIDNovice
	elseif state == "EnterArk" then
		cid = LuaCSConst.XPartConst.PCIDArk
	elseif state == "EnterWater" then
		cid = LuaCSConst.XPartConst.PCIDWater
	elseif state == "EnterFire" then
		cid = LuaCSConst.XPartConst.PCIDFire
	else
		cid = state == "EnterWorld" and 0 or state == "EnterOther" and 0 or cid
	end

	if cid == 0 then
		return
	end

	pg.global.resMgr:XPartStartRecord(cid, iid)
end

function ClientResMgrUtil.getXMainSceneId(sceneId)
	if sceneId == 3002 then
		return sceneId
	end

	if sceneId < 1000000 then
		return sceneId
	end

	local mainSceneId = SceneUtils.getMainSceneId(sceneId)

	return mainSceneId
end

function ClientResMgrUtil.onMainPlayerEnterSpace(mainPlayer)
	local space = mainPlayer.space
	local spaceType = space.spaceType
	local sceneId = space.sceneId
	local worldSceneId = space.worldSceneId
	local mainSceneId = ClientResMgrUtil.getXMainSceneId(sceneId)

	worldSceneId = worldSceneId or mainSceneId

	print("@fjs TrackPlayer.EnterSpace: scene: ", spaceType, sceneId, worldSceneId, mainSceneId)

	local startRecord = 0
	local stopRecord = 0
	local cid = 0
	local iid = LuaCSConst.XPartConst.PIIDDefault
	local sid = mainSceneId

	if sid == LuaCSConst.XPartConst.SceneNovice then
		startRecord = 1
		cid = LuaCSConst.XPartConst.PCIDNovice
	elseif sid == LuaCSConst.XPartConst.SceneArk then
		startRecord = 1
		cid = LuaCSConst.XPartConst.PCIDArk
	elseif sid == LuaCSConst.XPartConst.ScenePVETGrass then
		startRecord = 1
		cid = LuaCSConst.XPartConst.PCIDArk
	elseif sid == LuaCSConst.XPartConst.SceneWater then
		startRecord = 1
		cid = LuaCSConst.XPartConst.PCIDWater
	elseif sid == LuaCSConst.XPartConst.SceneFire then
		startRecord = 1
		cid = LuaCSConst.XPartConst.PCIDFire
	elseif sid == LuaCSConst.XPartConst.SceneWorld then
		stopRecord = 1
		cid = 0
	else
		stopRecord = 1
		cid = 0
	end

	if startRecord == 1 and cid ~= 0 then
		pg.global.resMgr:XPartStartRecord(cid, iid)
	end

	if stopRecord == 1 then
		pg.global.resMgr:XPartStopRecord()
	end
end

function ClientResMgrUtil.onMainPlayerLeaveSpace(mainPlayer)
	return
end

function ClientResMgrUtil.Test(p1, p2)
	local url = "http://10.8.43.244:8070/app/xwin/WinBuildClient_685/game_mini/worldx_Data/StreamingAssets/cvs/res/lua/LuaScripts.xdf"

	url = "http://10.8.43.244:8070/app/xwin/WinBuildClient_685/game_mini/worldx_Data/StreamingAssets/cvs/res/lua/LuaScripts_nofiles.xdt"

	local fileSize = 187
	local fileHash = "f1a78e29212b3ed07b5f36ac6d92d907"

	url = "http://10.8.43.244:8070/app/xwin/WinBuildClient_685/game_mini/worldx_Data/StreamingAssets/cvs/res/lua/LuaScripts.xdt"

	local fileSize = 5482089
	local fileHash = "2d25ac48552f445ce4f1e0ccaaf7cdee"
	local limitKB = 1024
	local handle = ""

	print(string.format("ClientResMgrUtil.Test: url=[]%s]", url))

	handle = appFacade.httpManager:LuaXHttpCreate(limitKB, url, fileSize, fileHash, 0, 0)

	local tempPath = appFacade.httpManager:LuaXHttpTempPath(handle)

	print(string.format("LuaXHttpCreate: handle=%s, tempPath=%s,", handle, tempPath))

	if handle == "" then
		return
	end

	appFacade.httpManager:LuaXHttpStart(handle)

	ClientResMgrUtil._testTimerID = 0
	ClientResMgrUtil._testTimerID = TimerManager.addRepeatTimer(1, function()
		ClientResMgrUtil.TestTimer(handle, "")
	end)
end

function ClientResMgrUtil.TestTimer(p1, p2)
	local handle = p1
	local isStop = appFacade.httpManager:LuaXHttpIsStop(handle)

	if isStop == 0 then
		local curDownByte = appFacade.httpManager:LuaXHttpGetDownloadTotal64(handle)
		local curRateByte = appFacade.httpManager:LuaXHttpGetDownloadRate(handle)

		print(string.format("TestTimer: not isStop=%d, down=%d, rate=%d", isStop, curDownByte, curRateByte))

		return
	end

	if ClientResMgrUtil._testTimerID ~= 0 then
		TimerManager.removeTimer(ClientResMgrUtil._testTimerID)

		ClientResMgrUtil._testTimerID = 0
	end

	local errCode = appFacade.httpManager:LuaXHttpGetErrorCode(handle)
	local errMsg = appFacade.httpManager:LuaXHttpGetErrorMessage(handle)
	local tempPath = appFacade.httpManager:LuaXHttpTempPath(handle)
	local remove = ""

	print(string.format("TestTimer: yes isStop=%d, err=%d, msg=[%s], remove=[%s]", isStop, errCode, errMsg, remove))
	appFacade.httpManager:LuaXHttpRemove(handle)
end

return ClientResMgrUtil
