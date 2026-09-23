-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientXPartUtil.lua

local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local LuaCSConst = require("Common.Const.LuaCSConst")
local UIConst = require("Const.UIConst")
local ClientXPartUtil = {}

function ClientXPartUtil._getResourceDownloadSystem()
	if pg and pg.game and pg.game.resourceDownload then
		return pg.game.resourceDownload
	end

	return nil
end

function ClientXPartUtil._notifyResourceDownload(funcName, ...)
	local resourceDownload = ClientXPartUtil._getResourceDownloadSystem()

	if resourceDownload and resourceDownload[funcName] then
		resourceDownload[funcName](resourceDownload, ...)
	end
end

function ClientXPartUtil.initSystem()
	pg.global.ClientXPartUtil = ClientXPartUtil

	local clientXPartQuery = require("Utils.ClientXPartQuery")

	clientXPartQuery.initSystem()

	ClientXPartUtil._oldWaitMode = -2
	ClientXPartUtil._limitKB = 4096
	ClientXPartUtil._waitContext = {}
	ClientXPartUtil._partMode = 0
	ClientXPartUtil._worldPartState = LuaCSConst.XPartConst.PercentFull

	local partMode = pg.global.resMgr:XPartGetPartMode()

	ClientXPartUtil._partMode = partMode

	if partMode ~= 0 then
		local worldPartState = pg.global.resMgr:XPartQueryStatus(LuaCSConst.XPartConst.PCIDWorld, 0)

		ClientXPartUtil._worldPartState = worldPartState
	end

	ClientXPartUtil._notifyResourceDownload("onXPartInit", ClientXPartUtil._partMode, ClientXPartUtil._worldPartState)
end

function ClientXPartUtil.needCheck()
	if EnableBotTest then
		return false
	end

	if ClientXPartUtil._partMode == 0 then
		return false
	end

	if ClientXPartUtil._worldPartState >= LuaCSConst.XPartConst.PercentFull then
		return false
	end

	return true
end

function ClientXPartUtil.getCurrentWaitPartID()
	local partID

	for key, val in pairs(ClientXPartUtil._waitContext) do
		local from = key
		local ctx = val

		if ctx ~= nil and ctx.arrPartID ~= nil then
			partID = ctx.arrPartID[1]

			if partID ~= nil then
				return partID
			end
		end
	end

	return partID
end

function ClientXPartUtil.getFirstWaitPartList()
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local ctxHash = ClientXPartUtil._waitContext

	if ctxHash == nil then
		return nil
	end

	local ctxItem

	for key, val in pairs(ctxHash) do
		if val ~= nil and ctxItem == nil then
			ctxItem = val
		end
	end

	return ctxItem
end

function ClientXPartUtil.getCurrentWaitPartList()
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local ctxItem = ClientXPartUtil.getFirstWaitPartList()

	if ctxItem == nil or ctxItem.arrPartID == nil then
		return nil
	end

	local arrPartID = ctxItem.arrPartID

	if #arrPartID <= 0 then
		return nil
	end

	local withFull = true
	local waitList = {}

	for idx, value in ipairs(arrPartID) do
		local clsid = value[1]
		local instid = value[2]
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		if withFull == true then
			table.insert(waitList, detail)
		elseif percent < LuaCSConst.XPartConst.PercentFull then
			table.insert(waitList, detail)
		end
	end

	return waitList
end

function ClientXPartUtil._destoryContext(from)
	local ctx = ClientXPartUtil._waitContext[from]

	if ctx == nil then
		return
	end

	if ctx.timerID ~= nil then
		local timerID = ctx.timerID

		ctx.timerID = nil

		TimerManager.removeTimer(timerID)
	end

	ClientXPartUtil._waitContext[from] = nil
end

function ClientXPartUtil._setWaitMode(mode)
	local oldMode = pg.global.resMgr:XPartWaitMode(mode)

	if oldMode ~= mode and mode ~= 0 then
		print(string.format("ClientXPartUtil._setWaitMode: old[%d] => new[%d], stk[%s]", oldMode, mode, debug.traceback()))
	end

	if oldMode ~= mode then
		ClientXPartUtil._notifyResourceDownload("onWaitModeChanged", mode)
	end

	return oldMode
end

function ClientXPartUtil._timerContext(from)
	local ctx = ClientXPartUtil._waitContext[from]

	if ctx == nil then
		return
	end

	local arrPartID = ctx.arrPartID
	local cbFunc = ctx.cbFunc
	local firstCID = 0
	local percent = 0
	local numNotRead = 0

	for idx, value in ipairs(arrPartID) do
		local clsid = value[1]
		local instid = value[2]
		local status = pg.global.resMgr:XPartQueryStatus(clsid, instid)

		if status < LuaCSConst.XPartConst.PercentFull then
			percent = status / 100
			numNotRead = numNotRead + 1
			firstCID = clsid
		end
	end

	ClientXPartUtil._notifyResourceDownload("onWaitProgress", from, arrPartID, numNotRead)

	if numNotRead > 0 then
		local tip = string.format("waitXPart: wait  fr[%s], num[%d], cid[%d], per[%.2f%%]", from, numNotRead, firstCID, percent)

		return
	end

	print("waitXPart: pass, fr=", from)

	if ClientXPartUtil._oldWaitMode ~= -2 then
		print("waitXPart: restore waitMode=", ClientXPartUtil._oldWaitMode)
		ClientXPartUtil._setWaitMode(ClientXPartUtil._oldWaitMode)

		ClientXPartUtil._oldWaitMode = -2
	end

	ClientXPartUtil._notifyResourceDownload("onWaitComplete", from, arrPartID)
	ClientXPartUtil._destoryContext(from)
	cbFunc()
end

function ClientXPartUtil._doWaitXPartCallback(from, arrPartID, arg, cbFunc)
	local ClientUtils = require("Utils.ClientUtils")
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local firstCID = 0
	local percent = 0
	local numNotRead = 0
	local isLoginToScene = from == LuaCSConst.XPartConst.KeyLogin2Scene
	local partMode = pg.global.resMgr:XPartGetPartMode()
	local isSpecialPartMode = ClientXPartQuery.isSpecialPartMode()

	for idx, value in ipairs(arrPartID) do
		local clsid = value[1]
		local instid = value[2]
		local status = pg.global.resMgr:XPartQueryStatus(clsid, instid)

		if status >= LuaCSConst.XPartConst.PercentFull then
			ClientXPartUtil._notifyResourceDownload("onWaitPartReady", from, clsid, instid, status)
		else
			firstCID = clsid
			percent = status / 100
			numNotRead = numNotRead + 1

			if isLoginToScene == false or isSpecialPartMode == true then
				local oldWaitMode = pg.global.resMgr:XPartWaitMode(0)

				if oldWaitMode ~= 1 then
					ClientXPartUtil._oldWaitMode = oldWaitMode

					ClientXPartUtil._setWaitMode(1)
				end

				pg.global.resMgr:XPartTryDownload(clsid, instid, ClientXPartUtil._limitKB, 0)
				ClientXPartUtil._notifyResourceDownload("onWaitPartDownload", from, clsid, instid, status)
			end
		end
	end

	if numNotRead <= 0 then
		print("waitXPartCallback: enter check pass, callback fr=", from)
		ClientXPartUtil._notifyResourceDownload("onWaitComplete", from, arrPartID)
		cbFunc()

		return
	end

	if isLoginToScene == true and isSpecialPartMode == false then
		local partNotReady = pg.getGameString("RESOURCE_NOT_DOWNLOADED")

		ClientUtils.showBubbleMessageRaw(partNotReady, 3)
		ClientXPartQuery.uiLoginResetState(false)
		ClientXPartQuery.tryGetUserLastScene()

		return
	end

	if isLoginToScene == true and isSpecialPartMode == true then
		ClientXPartQuery.uiLoginResetState(false)
	end

	local sceneID = 0

	if arg ~= nil and arg.ToScene ~= nil then
		sceneID = arg.ToScene
	end

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")
	local mainSceneId = clientResMgrUtil.getXMainSceneId(sceneID)

	if mainSceneId ~= nil and mainSceneId ~= 0 then
		from = string.format("%s_%d", from, mainSceneId)
	end

	if ClientXPartUtil._waitContext[from] ~= nil then
		return
	end

	local tip = string.format("waitXPart: start fr[%s], num[%d], cid[%d], per[%.2f%%]", from, numNotRead, firstCID, percent)

	print(tip)

	local ctx = {}

	ctx.from = from
	ctx.arrPartID = arrPartID
	ctx.arg = arg
	ctx.cbFunc = cbFunc
	ctx.numNotRead = numNotRead
	ctx.timerID = nil

	ClientXPartUtil._destoryContext(from)

	ClientXPartUtil._waitContext[from] = ctx

	ClientXPartUtil._notifyResourceDownload("onWaitStart", from, arrPartID)

	ctx.timerID = TimerManager.addRepeatTimer(2, function()
		ClientXPartUtil._timerContext(from)
	end)

	facade:SendMessageCommand(MessageName.RESOURCE_DOWNLOAD_STATE_BEGIN)
end

function ClientXPartUtil.hookAvatarOpenAvatarProcess(arg, cbFunc)
	print(string.format("@fjs TrackXPart OpenAvatarProcess: arg[%s], stk[%s]", table.val_to_str(arg), debug.traceback()))

	if ClientXPartUtil.needCheck() == false then
		cbFunc()

		return
	end

	local from = arg.KeyFrom
	local arrPartID = {
		{
			LuaCSConst.XPartConst.PCIDRole,
			0
		}
	}

	ClientXPartUtil._doWaitXPartCallback(from, arrPartID, arg, cbFunc)
end

function ClientXPartUtil.hookLoginAgentLoginImp(arg, cbFunc)
	print(string.format("@fjs TrackXPart AgentLoginImp: arg[%s], stk[%s]", table.val_to_str(arg), debug.traceback()))

	if arg == nil or ClientXPartUtil.needCheck() == false then
		cbFunc()

		return
	end

	local arrPartID = ClientXPartUtil.getPartIDByArg(arg)

	if arrPartID == nil then
		cbFunc()

		return
	end

	local from = arg.KeyFrom

	ClientXPartUtil._doWaitXPartCallback(from, arrPartID, arg, cbFunc)
end

function ClientXPartUtil.hookMainPlayerTeleportToScene(arg, cbFunc)
	print(string.format("@fjs TrackXPart TeleportToScene: arg[%s], stk[%s]", table.val_to_str(arg), debug.traceback()))

	if arg == nil or ClientXPartUtil.needCheck() == false then
		cbFunc()

		return
	end

	local arrPartID = ClientXPartUtil.getPartIDByArg(arg)

	if arrPartID == nil then
		cbFunc()

		return
	end

	local from = arg.KeyFrom

	ClientXPartUtil.openResourceDownloadCtrl(arrPartID, arg)
	ClientXPartUtil._doWaitXPartCallback(from, arrPartID, arg, cbFunc)
end

function ClientXPartUtil.hookMainPlayerTeleportToPhase(arg, cbFunc)
	print(string.format("@fjs TrackXPart TeleportToPhase: arg[%s], stk[%s]", table.val_to_str(arg), debug.traceback()))

	if arg == nil or ClientXPartUtil.needCheck() == false then
		cbFunc()

		return
	end

	local arrPartID = ClientXPartUtil.getPartIDByArg(arg)

	if arrPartID == nil then
		cbFunc()

		return
	end

	local from = arg.KeyFrom

	ClientXPartUtil.openResourceDownloadCtrl(arrPartID, arg)
	ClientXPartUtil._doWaitXPartCallback(from, arrPartID, arg, cbFunc)
end

function ClientXPartUtil.isPartListReady(arrPartID)
	for _, value in ipairs(arrPartID) do
		local clsid = value[1]
		local instid = value[2] or 0
		local status = pg.global.resMgr:XPartQueryStatus(clsid, instid)

		if status < LuaCSConst.XPartConst.PercentFull then
			return false
		end
	end

	return true
end

function ClientXPartUtil.getStageDownloadPartId(arrPartID)
	local sceneId = pg.me and pg.me.space and pg.me.space.sceneId

	if not sceneId then
		return
	end

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")
	local mainSceneId = clientResMgrUtil.getXMainSceneId(sceneId)
	local stagePartId

	if mainSceneId == LuaCSConst.XPartConst.SceneArk or mainSceneId == LuaCSConst.XPartConst.ScenePVETGrass then
		stagePartId = LuaCSConst.XPartConst.PCIDWorld
	end

	if not stagePartId then
		return
	end

	for _, partInfo in ipairs(arrPartID) do
		if partInfo[1] == stagePartId then
			return stagePartId
		end
	end
end

function ClientXPartUtil.openResourceDownloadCtrl(arrPartID, arg, forceOpen)
	if not pg.me or not pg.me.space or not pg.me.space.sceneId then
		return
	end

	if not pg or not pg.global or not pg.global.ui then
		return
	end

	if not forceOpen and ClientXPartUtil.isPartListReady(arrPartID) then
		return
	end

	if arg and arg._resourceDownloadCtrlOpened then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_RESOURCE_DOWNLOAD) then
		return
	end

	if arg then
		arg._resourceDownloadCtrlOpened = true
	end

	pg.global.ui:open(UIConst.UI_ID_RESOURCE_DOWNLOAD, {
		partList = arrPartID,
		from = arg and arg.KeyFrom,
		stageDownloadPartId = ClientXPartUtil.getStageDownloadPartId(arrPartID)
	})
end

function ClientXPartUtil.getPartIDByArg(arg)
	local arrPartID
	local from = arg.KeyFrom
	local sceneID = arg.ToScene

	if from == LuaCSConst.XPartConst.KeyLogin2Role then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDRole,
				0
			}
		}

		return arrPartID
	end

	if from == LuaCSConst.XPartConst.KeyRole2Novice then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDNovice,
				0
			}
		}

		return arrPartID
	end

	if from == LuaCSConst.XPartConst.KeyLogin2Scene then
		arrPartID = ClientXPartUtil.getPartIDByScene(arg, from, sceneID)

		return arrPartID
	end

	if from == LuaCSConst.XPartConst.KeyTeleToScene then
		arrPartID = ClientXPartUtil.getPartIDByScene(arg, from, sceneID)

		return arrPartID
	end

	if from == LuaCSConst.XPartConst.KeyTeleToPhase then
		arrPartID = ClientXPartUtil.getPartIDByScene(arg, from, sceneID)

		return arrPartID
	end

	return arrPartID
end

function ClientXPartUtil.getPartIDByScene(arg, from, sceneID)
	local arrPartID

	if sceneID == nil then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDWorld,
				0
			}
		}

		return arrPartID
	end

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")
	local mainSceneId = clientResMgrUtil.getXMainSceneId(sceneID)

	sceneID = mainSceneId

	if LuaCSConst.XPartConst.SceneFreeID[sceneID] then
		return nil
	end

	if sceneID == LuaCSConst.XPartConst.SceneNovice then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDNovice,
				0
			}
		}

		return arrPartID
	end

	if sceneID == LuaCSConst.XPartConst.SceneArk or sceneID == LuaCSConst.XPartConst.ScenePVETGrass then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDNovice,
				0
			},
			{
				LuaCSConst.XPartConst.PCIDArk,
				0
			}
		}

		return arrPartID
	end

	if sceneID == LuaCSConst.XPartConst.SceneWater then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDNovice,
				0
			},
			{
				LuaCSConst.XPartConst.PCIDArk,
				0
			},
			{
				LuaCSConst.XPartConst.PCIDWater,
				0
			}
		}

		return arrPartID
	end

	if sceneID == LuaCSConst.XPartConst.SceneFire then
		arrPartID = {
			{
				LuaCSConst.XPartConst.PCIDNovice,
				0
			},
			{
				LuaCSConst.XPartConst.PCIDArk,
				0
			},
			{
				LuaCSConst.XPartConst.PCIDWater,
				0
			},
			{
				LuaCSConst.XPartConst.PCIDFire,
				0
			}
		}

		return arrPartID
	end

	arrPartID = {
		{
			LuaCSConst.XPartConst.PCIDNovice,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDArk,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDWater,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDFire,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDWorld,
			0
		}
	}

	return arrPartID
end

function ClientXPartUtil._getPreDownloadList()
	local arrPartID = {
		{
			LuaCSConst.XPartConst.PCIDRole,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDNovice,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDArk,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDWater,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDFire,
			0
		},
		{
			LuaCSConst.XPartConst.PCIDWorld,
			0
		}
	}

	return arrPartID
end

function ClientXPartUtil.startDownloadAllPart()
	local partMode = pg.global.resMgr:XPartGetPartMode()

	if partMode == 0 then
		ClientXPartUtil._notifyResourceDownload("onPreDownloadSkip", partMode)

		return
	end

	local arrPartID = ClientXPartUtil._getPreDownloadList()

	ClientXPartUtil._notifyResourceDownload("onPreDownloadStart", arrPartID)

	for index, item in ipairs(arrPartID) do
		local clsid = item[1]
		local instid = item[2]

		print(string.format("ClientXPartUtil.start: clsid:%d, instid:%d, limitKB:%d", clsid, instid, ClientXPartUtil._limitKB))

		local status = pg.global.resMgr:XPartTryDownload(clsid, instid, ClientXPartUtil._limitKB, 0)

		ClientXPartUtil._notifyResourceDownload("onPreDownloadPart", clsid, instid, status)
	end
end

function ClientXPartUtil.startDownPart(clsid, instid, head, nolimit)
	if clsid == 0 or clsid == nil then
		return
	end

	print(string.format("ClientXPartUtil.startDownPart: clsid:%d, instid:%d, head:%d, nolimit:%d", clsid, instid, head, nolimit))

	if head == 1 and nolimit == 1 then
		ClientXPartUtil._setWaitMode(1)
	end

	pg.global.resMgr:XPartTryDownload(clsid, instid, ClientXPartUtil._limitKB, 0)

	if head == 1 then
		pg.global.resMgr:XPartHeadDownload(clsid, instid)
	end
end

function ClientXPartUtil.startDownPartRole(head, nolimit)
	ClientXPartUtil.startDownPart(LuaCSConst.XPartConst.PCIDRole, 0, head, nolimit)
end

function ClientXPartUtil.startDownPartNovice(head, nolimit)
	ClientXPartUtil.startDownPart(LuaCSConst.XPartConst.PCIDNovice, 0, head, nolimit)
end

function ClientXPartUtil.startDownPartArk(head, nolimit)
	ClientXPartUtil.startDownPart(LuaCSConst.XPartConst.PCIDArk, 0, head, nolimit)
end

function ClientXPartUtil.startDownPartWater(head, nolimit)
	ClientXPartUtil.startDownPart(LuaCSConst.XPartConst.PCIDWater, 0, head, nolimit)
end

function ClientXPartUtil.startDownPartFire(head, nolimit)
	ClientXPartUtil.startDownPart(LuaCSConst.XPartConst.PCIDFire, 0, head, nolimit)
end

function ClientXPartUtil.startDownPartWorld(head, nolimit)
	ClientXPartUtil.startDownPart(LuaCSConst.XPartConst.PCIDWorld, 0, head, nolimit)
end

function ClientXPartUtil.printAllPart()
	local arrID = {
		{
			21,
			0
		},
		{
			22,
			0
		},
		{
			23,
			0
		},
		{
			24,
			0
		},
		{
			25,
			0
		},
		{
			26,
			0
		},
		{
			27,
			0
		},
		{
			56,
			0
		},
		{
			65,
			0
		}
	}

	print("XPart.printAllPart: start")

	for idx, value in ipairs(arrID) do
		local clsid = value[1]
		local instid = value[2]
		local tResult = {}

		pg.global.resMgr:XPartQueryDetail(clsid, instid, tResult)
		print(string.format("XPart.printAllPart: idx:%d, cid:%d, iid:%d, part:[%s]", idx, clsid, instid, table.val_to_str(tResult)))
	end

	print("XPart.printAllPart: comp")
end

function ClientXPartUtil.tryDownSavedPartID()
	local numNotReady = 0
	local downPartID = {}
	local needCheck = ClientXPartUtil.needCheck()

	if needCheck == false then
		return downPartID
	end

	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local savedPartID = ClientXPartQuery.getSavedPartID()
	local worldCID = LuaCSConst.XPartConst.PCIDWorld
	local worldPercent = -1

	for idx, val in ipairs(savedPartID) do
		local clsid = val[1]
		local instid = val[2]

		if clsid > 0 then
			local percent = pg.global.resMgr:XPartQueryStatus(clsid, instid)

			if percent < LuaCSConst.XPartConst.PercentFull then
				numNotReady = numNotReady + 1

				table.insert(downPartID, {
					clsid,
					instid,
					percent
				})

				if clsid == worldCID then
					worldPercent = percent
				end
			end
		end
	end

	if worldPercent >= 0 then
		ClientXPartUtil._setWaitMode(1)
		ClientXPartUtil.startDownPart(worldCID, 0, 0, 0)

		return {
			{
				worldCID,
				0,
				worldPercent
			}
		}
	end

	if numNotReady > 0 then
		ClientXPartUtil._setWaitMode(1)
	end

	for idx, val in ipairs(downPartID) do
		local clsid = val[1]
		local instid = val[2]

		ClientXPartUtil.startDownPart(clsid, instid, 0, 0)
	end

	return downPartID
end

function ClientXPartUtil.tryGetLeftPartID()
	local numNotReady = 0
	local leftPartID = {}
	local needCheck = ClientXPartUtil.needCheck()

	if needCheck == false then
		return leftPartID
	end

	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local savedPartID = ClientXPartQuery.getSavedPartID()
	local hashSavePartID = {}

	for idx, val in ipairs(savedPartID) do
		local clsid = val[1]
		local instid = val[2]
		local idkey = string.format("id_%d_%d", clsid, instid)

		hashSavePartID[idkey] = val
	end

	local arrPartID = ClientXPartUtil._getPreDownloadList()

	for idx, val in ipairs(arrPartID) do
		local clsid = val[1]
		local instid = val[2]
		local idkey = string.format("id_%d_%d", clsid, instid)
		local itemSaved = hashSavePartID[idkey]

		if itemSaved == nil then
			local itemLeft = {
				idkey = idkey,
				clsid = clsid,
				instid = instid
			}
			local detail = {}

			itemLeft.detail = detail

			pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

			local title = ClientXPartQuery.findPackTitleByDetail(detail)

			itemLeft.title = title

			table.insert(leftPartID, itemLeft)
		end
	end

	return leftPartID
end

function ClientXPartUtil.formatLeftPartID(leftPartID)
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local savedPartID = ClientXPartQuery.getSavedPartID()
	local allSavedByteSize = 0

	for idx, val in ipairs(savedPartID) do
		local clsid = val[1]
		local instid = val[2]
		local detail = {}

		pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		allSavedByteSize = allSavedByteSize + detail.NumByte

		print(string.format("@fjs formatLeftPartID: saved[%d], detail[%s]", clsid, table.val_to_str(detail)))
	end

	local worldCID = LuaCSConst.XPartConst.PCIDWorld
	local allWorldByteSize = 0
	local allLeftPartByteSize = 0

	for idx, val in ipairs(leftPartID) do
		local clsid = val.clsid
		local instid = val.instid
		local detail = val.detail

		if clsid == worldCID then
			allWorldByteSize = detail.NumByte
		else
			allLeftPartByteSize = allLeftPartByteSize + detail.NumByte
		end
	end

	local resourceDownload = pg and pg.game and pg.game.resourceDownload
	local totalLeftSize = allWorldByteSize - allSavedByteSize
	local allWorldByteSizeNoOther = totalLeftSize - allLeftPartByteSize

	print(string.format("@fjs formatLeftPartID: all[%s], saved[%s], left[%s]", tostring(allWorldByteSize), tostring(allSavedByteSize), tostring(totalLeftSize)))

	local textLeftSizeListTip = ""

	for idx, val in ipairs(leftPartID) do
		local clsid = val.clsid
		local instid = val.instid
		local detail = val.detail

		val.NumByte = val.detail.NumByte

		if clsid == worldCID then
			val.NumByte = allWorldByteSizeNoOther
		end

		local sizeTip = resourceDownload:formatDownloadBytes(val.NumByte)

		if textLeftSizeListTip == "" then
			textLeftSizeListTip = string.format("%s:%s", val.title, sizeTip)
		else
			textLeftSizeListTip = textLeftSizeListTip .. string.format(", %s:%s", val.title, sizeTip)
		end
	end

	local sizeAllTextPrefix = "大小"
	local sizeAllTextByte = resourceDownload:formatDownloadBytes(totalLeftSize)
	local sizeAllTipText = string.format("(%s%s)? \n %s", sizeAllTextPrefix, sizeAllTextByte, textLeftSizeListTip)

	return sizeAllTipText
end

function ClientXPartUtil.tryDownLeftPartID()
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local savedPartID = ClientXPartQuery.getSavedPartID()
	local leftPartID = ClientXPartUtil.tryGetLeftPartID()

	print("@fjs loginTryDownLeftPartID: left[%s]", table.val_to_str(leftPartID))
	ClientXPartUtil._setWaitMode(-1)

	local arrPartID = ClientXPartUtil._getPreDownloadList()

	ClientXPartUtil._notifyResourceDownload("onPreDownloadStart", arrPartID)

	for index, item in ipairs(leftPartID) do
		local clsid = item.clsid
		local instid = item.instid

		print(string.format("ClientXPartUtil.start: clsid:%d, instid:%d, limitKB:%d", clsid, instid, ClientXPartUtil._limitKB))

		local status = pg.global.resMgr:XPartTryDownload(clsid, instid, ClientXPartUtil._limitKB, 0)

		ClientXPartUtil._notifyResourceDownload("onPreDownloadPart", clsid, instid, status)
	end
end

function ClientXPartUtil.getNotCompletePartID()
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local allPartID = ClientXPartQuery.getAllPartID()
	local notCompletePartID = {}

	for index, item in ipairs(allPartID) do
		local clsid = item.clsid
		local instid = item.instid
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		if percent < LuaCSConst.XPartConst.PercentFull then
			table.insert(notCompletePartID, detail)
		end
	end

	return notCompletePartID
end

function ClientXPartUtil.tryDownAllPartID()
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local allPartID = ClientXPartQuery.getAllPartID()
	local notCompletePartID = ClientXPartUtil.getNotCompletePartID()

	ClientXPartQuery._currentDownList = notCompletePartID

	for index, item in ipairs(notCompletePartID) do
		local clsid = item.CID
		local instid = item.IID

		print(string.format("ClientXPartUtil.start: clsid:%d, instid:%d, limitKB:%d", clsid, instid, ClientXPartUtil._limitKB))

		local status = pg.global.resMgr:XPartTryDownload(clsid, instid, ClientXPartUtil._limitKB, 0)

		ClientXPartUtil._notifyResourceDownload("onPreDownloadPart", clsid, instid, status)
	end
end

function ClientXPartUtil.startDownAllPartID()
	local ClientXPartQuery = require("Utils.ClientXPartQuery")
	local resourceDownload = pg and pg.game and pg.game.resourceDownload

	if not resourceDownload:isXPartEnabled() then
		return
	end

	if ClientXPartQuery._loginDownloadRunning == true then
		return
	end

	ClientXPartQuery._loginDownloadRunning = true

	print(string.format("@fjs startDownAllPartID: ", debug.traceback()))
	ClientXPartUtil._setWaitMode(1)
	ClientXPartUtil.tryDownAllPartID()
	facade:SendMessageCommand(MessageName.RESOURCE_DOWNLOAD_STATE_BEGIN)
end

return ClientXPartUtil
