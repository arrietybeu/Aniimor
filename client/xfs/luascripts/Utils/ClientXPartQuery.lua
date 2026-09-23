-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientXPartQuery.lua

local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")
local EventConst = require("Const.EventConst")
local LuaCSConst = require("Common.Const.LuaCSConst")
local UIConst = require("Const.UIConst")
local json = require("json")
local base64 = require("base64")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local ClientUtils = require("Utils.ClientUtils")
local ClientXPartQuery = {}

function ClientXPartQuery.initSystem()
	pg.global.ClientXPartQuery = ClientXPartQuery

	pg.global.resMgr:XPartSetEventCallback(ClientXPartQuery.eventCallbackFromXPart)

	ClientXPartQuery._editorTest = false
	ClientXPartQuery._listAllPackGroup = ClientXPartQuery._initAllPackGroup()
	ClientXPartQuery._listAllPackItem = ClientXPartQuery._initAllPackItem()
	ClientXPartQuery._hashPackItem = {}
	ClientXPartQuery._listPackItemArray = {}

	for idx, val in ipairs(ClientXPartQuery._listAllPackItem) do
		local data = val

		for i2, v2 in ipairs(data) do
			ClientXPartQuery._hashPackItem["id_" .. tostring(v2.id)] = v2

			table.insert(ClientXPartQuery._listPackItemArray, v2)
		end
	end

	local testID = 25
	local testPack = ClientXPartQuery.findPackByID(testID)

	if testPack == nil then
		print("@fjs ClientXPartQuery: not find, testID=", testID)
	end

	local savedPartID = ClientXPartQuery.getSavedPartID()
	local testPrint = false

	if testPrint then
		print(string.format("ClientXPartQuery: _listAllPackGroup[%s]", table.val_to_str(ClientXPartQuery._listAllPackGroup)))
		print(string.format("ClientXPartQuery: _listAllPackItem[%s]", table.val_to_str(ClientXPartQuery._listAllPackItem)))

		local allPackGroup = ClientXPartQuery.getAllPackGroup()

		for idx, val in ipairs(allPackGroup) do
			local packGroup = val
			local packItemListArr = ClientXPartQuery.getPackItemList(packGroup.id)
			local packItemListStr = "nil"

			if packItemListArr ~= nil then
				packItemListStr = table.val_to_str(packItemListArr)
			end

			print(string.format("ClientXPartQuery: group[%d], packItemList[%s]", packGroup.id, packItemListStr))
		end
	end

	ClientXPartQuery._localMaxPartID = 0
	ClientXPartQuery._localMaxPartID = ClientXPartQuery.getLocalMaxPartID()

	print("@fjs ClientXPartQuery._localMaxPartID=", ClientXPartQuery._localMaxPartID)

	ClientXPartQuery._currentDownList = {}
	ClientXPartQuery._timerCheckNetworkID = nil
	ClientXPartQuery._loginDownloadRunning = false
	ClientXPartQuery._serverSceneIDCache = {}
end

function ClientXPartQuery.removeCheckNetworkTimer()
	if ClientXPartQuery._timerCheckNetworkID ~= nil then
		TimerManager.removeTimer(ClientXPartQuery._timerCheckNetworkID)

		ClientXPartQuery._timerCheckNetworkID = nil
	end
end

function ClientXPartQuery.startCheckNetworkTimer()
	ClientXPartQuery.removeCheckNetworkTimer()

	ClientXPartQuery._timerCheckNetworkID = TimerManager.addRepeatTimer(3, function()
		local netstate = ClientXPartQuery.getNetworkType()

		if netstate == 2 then
			ClientXPartQuery.removeCheckNetworkTimer()
			print("ClientXPartQuery.startCheckNetworkTimer: wifi mode start download, netstate=", netstate)

			local ClientXPartUtil = require("Utils.ClientXPartUtil")

			ClientXPartUtil.startDownAllPartID()
		end
	end)
end

function ClientXPartQuery.findPackByID(id)
	if id == nil then
		return nil
	end

	local packItem = ClientXPartQuery._hashPackItem["id_" .. tostring(id)]

	return packItem
end

function ClientXPartQuery.findPackTitleByDetail(detail)
	local title = ""

	if detail == nil then
		return title
	end

	local packHeadItem = ClientXPartQuery.findPackByID(detail.FullID or 0)

	if packHeadItem == nil then
		return title
	end

	title = packHeadItem.title or ""

	return title
end

function ClientXPartQuery._initAllPackGroup()
	local data = {
		{
			name = 1419302567,
			order = "1"
		},
		{
			name = 1335248695,
			order = "2"
		},
		{
			name = 1210451004,
			order = "3"
		},
		{
			name = 1733741503,
			order = "4"
		},
		{
			name = 1151875584,
			order = "5"
		}
	}
	local testTitleCN = {
		{
			title = "基础",
			order = "1",
			name = 1419302567
		},
		{
			title = "场景",
			order = "2",
			name = 1335248695
		},
		{
			title = "玩法",
			order = "3",
			name = 1210451004
		},
		{
			title = "外观",
			order = "4",
			name = 1733741503
		},
		{
			title = "其它",
			order = "5",
			name = 1151875584
		}
	}
	local testTitleEN = {
		{
			title = "basic",
			order = "1",
			name = 1419302567
		},
		{
			title = "scene",
			order = "2",
			name = 1335248695
		},
		{
			title = "play",
			order = "3",
			name = 1210451004
		},
		{
			title = "skin",
			order = "4",
			name = 1733741503
		},
		{
			title = "other",
			order = "5",
			name = 1151875584
		}
	}
	local testTitle = testTitleEN

	if ClientConfigDefaultLang == "" or ClientConfigDefaultLang == "cn" or ClientConfigDefaultLang == "zh_CN" then
		testTitle = testTitleCN
	end

	local group = {}

	for idx, val in ipairs(data) do
		local id = idx
		local item = {}

		item.id = id
		item.name = val.name
		item.order = val.order
		item.title = "PackGroup"

		local testVal = testTitle[idx]

		if testVal ~= nil then
			item.title = testVal.title
		end

		group[id] = item
	end

	return group
end

function ClientXPartQuery._initAllPackItem()
	local testTitleRole = "创角捏脸"
	local testTitleNovice = "新手剧情"
	local testTitleArk = "ARK剧情"
	local testTitleWater = "水版块"
	local testTitleFire = "火版块"
	local testTitleWorld = "全量资源"
	local data1 = {
		{
			instid = 0,
			id = 23,
			clsid = 23,
			title = testTitleRole
		}
	}
	local data2 = {
		{
			instid = 0,
			id = 24,
			clsid = 24,
			title = testTitleNovice
		},
		{
			instid = 0,
			id = 25,
			clsid = 25,
			title = testTitleArk
		},
		{
			instid = 0,
			id = 26,
			clsid = 26,
			title = testTitleWater
		},
		{
			instid = 0,
			id = 27,
			clsid = 27,
			title = testTitleFire
		}
	}
	local data3 = {}
	local data4 = {}
	local data5 = {
		{
			instid = 0,
			id = 65,
			clsid = 65,
			title = testTitleWorld
		}
	}
	local dataAll = {
		data1,
		data2,
		data3,
		data4,
		data5
	}

	return dataAll
end

function ClientXPartQuery.getAllPackGroup()
	return ClientXPartQuery._listAllPackGroup
end

function ClientXPartQuery.getAllPackGroup()
	return ClientXPartQuery._listAllPackItem
end

function ClientXPartQuery.getPackItemList(groupid)
	local packGroup = ClientXPartQuery._listAllPackGroup[groupid]

	if packGroup == nil then
		return nil
	end

	local packItemList = ClientXPartQuery._listAllPackItem[packGroup.id]

	if packItemList == nil then
		return nil
	end

	local ret = {}

	for pidx, pval in ipairs(packItemList) do
		local packItemRaw = pval
		local packItemStatus = {}

		packItemStatus.id = packItemRaw.id
		packItemStatus.clsid = packItemRaw.clsid
		packItemStatus.instid = packItemRaw.instid
		packItemStatus.title = packItemRaw.title
		packItemStatus.detail = {}
		ret[pidx] = packItemStatus

		local clsid = packItemStatus.clsid
		local instid = packItemStatus.instid
		local detail = packItemStatus.detail

		pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)
	end

	return ret
end

function ClientXPartQuery.getSavedPartID()
	local tClass = {}
	local tInstance = {}
	local cnt = pg.global.resMgr:XPartGetSavedPartID(tClass, tInstance)
	local result = {}

	if cnt <= 0 then
		return result
	end

	for i = 1, cnt do
		result[i] = {
			tClass[i],
			tInstance[i]
		}
	end

	return result
end

function ClientXPartQuery.getAllPartID()
	return ClientXPartQuery._listPackItemArray
end

function ClientXPartQuery.queryPartID(partID)
	local detail

	if partID == nil then
		return detail
	end

	detail = {}

	local percent = pg.global.resMgr:XPartQueryDetail(partID[1], partID[2], detail)

	return detail
end

function ClientXPartQuery.getDownHeadPack()
	local recvDetail
	local downStatusRecv = 5
	local debugText = ""

	for idx, val in ipairs(ClientXPartQuery._listPackItemArray) do
		local clsid = val.clsid
		local instid = val.instid
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		debugText = debugText .. string.format("[cls:%d,per:%d,sta:%d], ", clsid, percent, detail.DownStatus)

		if recvDetail ~= nil and percent < LuaCSConst.XPartConst.PercentFull and detail.DownStatus == downStatusRecv then
			recvDetail = detail
		end
	end

	print("@fjs getDownHeadPack: %s", debugText)

	return recvDetail
end

function ClientXPartQuery.getQueueHead(priority, detail)
	local percent = pg.global.resMgr:XPartQueryHead(priority, detail)

	return percent
end

function ClientXPartQuery.pauseQueueDownload(priority, detail)
	local percent = pg.global.resMgr:XPartTryPause(priority, detail)

	return percent
end

function ClientXPartQuery.resumeQueueDownload(priority, detail)
	local percent = pg.global.resMgr:XPartTryResume(priority, detail)

	return percent
end

function ClientXPartQuery.getDownQueueDetail()
	local ClientXPartUtil = require("Utils.ClientXPartUtil")
	local currentDetail = {}

	currentDetail.Percent = 0
	currentDetail.CurTotalByte = 0
	currentDetail.NumByte = 0
	currentDetail.LastCurByte = 0
	currentDetail.RateByte = 0

	local specialPartMode = ClientXPartQuery.isSpecialPartMode()
	local currentDownList

	if specialPartMode == true then
		currentDownList = ClientXPartUtil.getCurrentWaitPartList()
	else
		currentDownList = ClientXPartQuery._currentDownList
	end

	currentDetail.ItemTotal = #currentDownList
	currentDetail.ItemIndex = 0

	if currentDetail.ItemTotal <= 0 then
		return nil
	end

	local headDetail

	for index, item in ipairs(currentDownList) do
		local clsid = item.CID
		local instid = item.IID
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		if percent < LuaCSConst.XPartConst.PercentFull and headDetail == nil then
			headDetail = detail
		end
	end

	if headDetail == nil then
		local last = currentDetail.ItemTotal
		local item = currentDownList[last]
		local clsid = item.CID
		local instid = item.IID
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		headDetail = detail
	end

	currentDetail.Percent = headDetail.Percent
	currentDetail.CurTotalByte = headDetail.CurTotalByte
	currentDetail.NumByte = headDetail.NumByte
	currentDetail.LastCurByte = headDetail.LastCurByte
	currentDetail.RateByte = headDetail.RateByte

	for index, item in ipairs(currentDownList) do
		local clsid = item.CID
		local instid = item.IID
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		if percent < LuaCSConst.XPartConst.PercentFull and currentDetail.ItemIndex == 0 then
			currentDetail.ItemIndex = index
		end
	end

	return currentDetail
end

function ClientXPartQuery.getLocalMaxPartID()
	local localMaxPartID = LuaCSConst.XPartConst.PCIDInit
	local savedCID = ClientXPartQuery.setCurrentUserPartID(0, 0)

	if savedCID ~= 0 then
		localMaxPartID = savedCID
	end

	return localMaxPartID
end

function ClientXPartQuery.getDownMaxPartID()
	local allPartID = ClientXPartQuery.getAllPartID()
	local prevCID = LuaCSConst.XPartConst.PCIDInit
	local maxCID = LuaCSConst.XPartConst.PCIDInit

	for index, item in ipairs(allPartID) do
		local clsid = item.clsid
		local instid = item.instid
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)
		local percent = detail.Percent

		if percent >= LuaCSConst.XPartConst.PercentFull then
			maxCID = prevCID
			prevCID = clsid
		else
			maxCID = prevCID

			return maxCID
		end
	end

	return maxCID
end

function ClientXPartQuery.getIsDownMaxToLocal()
	local maxLocal = ClientXPartQuery._localMaxPartID
	local maxDown = ClientXPartQuery.getDownMaxPartID()

	maxLocal = ClientXPartQuery.getServerUserMaxPartID()

	if maxLocal <= maxDown then
		return true
	end

	return false
end

function ClientXPartQuery.uiLoginResetState(resumeVideo)
	if pg.global.ui == nil or pg.global.ui.login == nil then
		return
	end

	if pg.global.ui.login:checkUIOpen() then
		if resumeVideo == true then
			pg.global.ui.login:resumeVideo()
		end

		pg.global.ui.login:resetLoginState()
	end
end

function ClientXPartQuery.getNetworkType()
	local ntype = pg.global.resMgr:XPartQueryNetwork()

	return ntype
end

function ClientXPartQuery.setAllowCellNetwork(allowCell)
	local ntype = pg.global.resMgr:XPartAllowNetwork(allowCell)

	return ntype
end

function ClientXPartQuery.setSimulateNetworkType(stype)
	local ntype = pg.global.resMgr:XPartSimulateNetwork(stype)

	return ntype
end

function ClientXPartQuery.setCurrentUserPartID(clsid, instid)
	local GlobalData = require("Core.Client.GlobalData")
	local user = GlobalData.UserName

	print(string.format("@fjs TrackUserPID: setCurrentUserPartID: user[%s], cid[%d], iid[%d]", user, clsid, instid))

	local ret = pg.global.resMgr:XPartSetUserPart(user, clsid, instid)

	return ret
end

function ClientXPartQuery.isSpecialPartMode()
	local partMode = pg.global.resMgr:XPartGetPartMode()

	if partMode >= LuaCSConst.XPartConst.PartModeBeg and partMode <= LuaCSConst.XPartConst.PartModeEnd then
		return true
	end

	return false
end

function ClientXPartQuery.tryRunSpecialPartMode()
	local runSpecialPartMode
	local partMode = pg.global.resMgr:XPartGetPartMode()

	if partMode == LuaCSConst.XPartConst.PartModeMin then
		return "PartModeMin"
	end

	if partMode >= LuaCSConst.XPartConst.PartModeBeg and partMode <= LuaCSConst.XPartConst.PartModeEnd then
		ClientXPartQuery.doRunSpecialPartMode(partMode)

		runSpecialPartMode = "partMode_" .. tostring(partMode)

		return runSpecialPartMode
	end

	return runSpecialPartMode
end

function ClientXPartQuery.doRunSpecialPartMode(partMode)
	local arrDownPartList = {}

	if partMode >= LuaCSConst.XPartConst.PartModeNovice then
		table.insert(arrDownPartList, {
			LuaCSConst.XPartConst.PCIDNovice,
			0
		})
	end

	if partMode >= LuaCSConst.XPartConst.PartModeArk then
		table.insert(arrDownPartList, {
			LuaCSConst.XPartConst.PCIDArk,
			0
		})
	end

	if partMode >= LuaCSConst.XPartConst.PartModeWater then
		table.insert(arrDownPartList, {
			LuaCSConst.XPartConst.PCIDWater,
			0
		})
	end

	if partMode >= LuaCSConst.XPartConst.PartModeFire then
		table.insert(arrDownPartList, {
			LuaCSConst.XPartConst.PCIDFire,
			0
		})
	end

	if partMode >= LuaCSConst.XPartConst.PartModeWorld then
		table.insert(arrDownPartList, {
			LuaCSConst.XPartConst.PCIDWorld,
			0
		})
	end

	local notCompletePartID = ClientXPartQuery.toDetailPartList(arrDownPartList, false)

	ClientXPartQuery.doDownPartList(false, notCompletePartID, 20480)
end

function ClientXPartQuery.toDetailPartList(arrDownPartList, withFull)
	local notCompletePartID = {}

	if arrDownPartList == nil then
		return notCompletePartID
	end

	for index, item in ipairs(arrDownPartList) do
		local clsid = item[1]
		local instid = item[2]
		local detail = {}
		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		if withFull == true then
			table.insert(notCompletePartID, detail)
		elseif percent < LuaCSConst.XPartConst.PercentFull then
			table.insert(notCompletePartID, detail)
		end
	end

	return notCompletePartID
end

function ClientXPartQuery.doDownPartList(dryRun, notCompletePartID, limitKB)
	local ClientXPartUtil = require("Utils.ClientXPartUtil")
	local len = 0
	local strList = "{}"

	if notCompletePartID ~= nil then
		len = #notCompletePartID
		strList = table.val_to_str(notCompletePartID)
	end

	print(string.format("@fjs doDownPartList: run len[%d], arr[%s], stk[%s]", len, strList, debug.traceback()))

	if dryRun == true then
		return
	end

	if len <= 0 then
		return
	end

	if limitKB <= 0 then
		limitKB = 81920
	end

	for index, item in ipairs(notCompletePartID) do
		local clsid = item.CID
		local instid = item.IID

		print(string.format("@fjs doDownPartList: item clsid:%d, instid:%d, limitKB:%d", clsid, instid, limitKB))

		local status = pg.global.resMgr:XPartTryDownload(clsid, instid, limitKB, 0)

		ClientXPartUtil._notifyResourceDownload("onPreDownloadPart", clsid, instid, status)
	end
end

function ClientXPartQuery.eventCallbackFromXPart(i1, i2, i3, s1, s2, s3)
	if s1 == "Download" and s2 == "PartDone" then
		local clsid = i1
		local instid = i2
		local timesec = i3

		ClientXPartQuery.callEventPartDownloadDone(clsid, instid, timesec)
	end

	if s1 == "Download" and s2 == "PartStart" then
		local clsid = i1
		local instid = i2
		local percent = i3

		ClientXPartQuery.callEventPartDownloadStart(clsid, instid, percent)
	end
end

function ClientXPartQuery.callEventPartDownloadStart(clsid, instid, percent)
	print(string.format("ClientXPartQuery.PartStart: cid:%d, iid:%d", clsid, instid))
	ClientXPartQuery.sendLogXPart("PartStart", clsid, instid, 0)
end

function ClientXPartQuery.callEventPartDownloadDone(clsid, instid, timesec)
	print(string.format("ClientXPartQuery.PartDone: cid:%d, iid:%d", clsid, instid))

	local ClientXPartUtil = require("Utils.ClientXPartUtil")

	ClientXPartUtil._notifyResourceDownload("onPartDownloaded", clsid, instid)
	ClientXPartQuery.sendLogXPart("PartDone", clsid, instid, timesec)
end

function ClientXPartQuery.sendLogXPart(name, clsid, instid, timesec)
	local pkg_name = ClientXPartQuery.partID2Name(clsid, instid)
	local duration = timesec
	local type = 0

	if name == "PartStart" then
		type = 1
	end

	if name == "PartDone" then
		type = 2
	end

	local isWaitMode = pg.global.resMgr:XPartWaitMode(0)
	local update_status = 1

	if isWaitMode == 1 then
		update_status = 1
	end

	if isWaitMode == -1 then
		update_status = 2
	end

	local is_new = pg.global.resMgr:XPartCallEntry("GetIsDeviceNew", "", 0, 0, 0)
	local is_first_pass = pg.global.sdkManager.isAccountNew

	if is_new == nil then
		is_new = 0
	end

	if is_first_pass == nil then
		is_first_pass = 0
	end

	local GlobalData = require("Core.Client.GlobalData")
	local evname = "download_flow"
	local evdata = {
		pkg_name = pkg_name,
		duration = duration,
		type = type,
		update_status = update_status,
		is_new = is_new,
		is_first_pass = is_first_pass
	}

	print(string.format("sendLogXPart: evname[%s], evdata[%s]", evname, table.val_to_str(evdata)))
	GlobalData.BILogger:customeLog(evname, evdata)
end

function ClientXPartQuery.partID2Name(clsid, instid)
	if clsid == LuaCSConst.XPartConst.PCIDInit then
		return "init"
	end

	if clsid == LuaCSConst.XPartConst.PCIDLogin then
		return "login"
	end

	if clsid == LuaCSConst.XPartConst.PCIDRole then
		return "role"
	end

	if clsid == LuaCSConst.XPartConst.PCIDNovice then
		return "novice"
	end

	if clsid == LuaCSConst.XPartConst.PCIDArk then
		return "ark"
	end

	if clsid == LuaCSConst.XPartConst.PCIDWater then
		return "water"
	end

	if clsid == LuaCSConst.XPartConst.PCIDFire then
		return "fire"
	end

	if clsid == LuaCSConst.XPartConst.PCIDWorld then
		return "world"
	end

	return "none"
end

function ClientXPartQuery.queryLastSceneResp(reply)
	print(string.format("@fjs ClientXPartQuery.queryLastSceneResp: reply[%s]", table.val_to_str(reply)))
end

function ClientXPartQuery.queryLastSceneServer()
	print("@fjs ClientXPartQuery.queryLastSceneServer")

	local httpTimeoutMS = 15000
	local httpSSL = false
	local httpHost = "10.8.53.98"
	local httpPort = "19041"
	local httpMethod = "POST"
	local httpPath = "/queryLastScene"
	local httpHead = {
		["Content-Type"] = "application/json"
	}
	local httpData = {
		accountId = "",
		ticket = ""
	}
	local userName = "f2080601-8053098"
	local useSDK = false

	if useSDK == true then
		httpData.accountId = pg.global.sdkManager.accountId
		httpData.ticket = pg.global.sdkManager.ticket
	else
		local ticket = ClientXPartQuery.genAccTicket(userName, 0)

		httpData.accountId = userName
		httpData.ticket = ticket
	end

	local httpBody = json.encode(httpData)
	local httpCallback = ClientXPartQuery.queryLastSceneResp
	local httpProxy = HttpClientProxy()
	local httpReq = HttpRequest(httpHost, httpPort, httpMethod, httpPath, httpHead, httpBody, httpSSL)

	httpProxy:httpRequest(httpReq, httpTimeoutMS, httpCallback, false)
end

function ClientXPartQuery.genAccTicket(acc, timesec)
	local placeHoder = "0000000000000000000000000000000000000000000000000000000000000000"
	local timeSecond = timesec

	if timeSecond == 0 then
		timeSecond = os.time()
	end

	local ticketObj = {}

	ticketObj.account_id = acc
	ticketObj.time = timeSecond

	local ticketText = json.encode(ticketObj)
	local ticketFull = string.format("%s%s", placeHoder, ticketText)
	local ticketBase64 = base64.encode(ticketFull)

	print("@fjs genAccTicket: acc[%s], times[%s], ticket[%s], base64[%s]", acc, tostring(timesec), ticketFull, ticketBase64)

	return ticketBase64
end

function ClientXPartQuery.servGetUserNameNeedServerID(serverID)
	local ClientSwitch = require("Common.ClientSwitch")

	if ClientConfigUserNameNoServerID ~= "true" and not SDKLoginConfig.isEnabled() and not ClientSwitch.EnableUserNameDebugLogin and serverID ~= 100 then
		return true
	end

	return false
end

function ClientXPartQuery.servGetSelectServerID()
	local serverid
	local loginCtrl = pg.global.ui.login

	if loginCtrl ~= nil and loginCtrl.loginServerComponent ~= nil then
		serverid = loginCtrl.loginServerComponent.selectServerId
	end

	if serverid == nil then
		serverid = -255
	end

	return serverid
end

function ClientXPartQuery.servGetSelectServerName()
	local name
	local loginCtrl = pg.global.ui.login

	if loginCtrl ~= nil and loginCtrl.loginServerComponent ~= nil then
		name = loginCtrl.loginServerComponent.selectServerName
	end

	if name == nil then
		name = ""
	end

	return name
end

function ClientXPartQuery.servGetUserName(withServerID)
	local isSdkEnable = SDKLoginConfig.isEnabled()
	local userName

	if isSdkEnable then
		if pg.global.sdkManager.isLogin == true then
			userName = pg.global.sdkManager.accountId
		end
	else
		local loginCtrl = pg.global.ui.login

		if loginCtrl then
			userName = loginCtrl.view.inputField.text
		end
	end

	if userName == nil then
		userName = ""
	end

	local userNameWithSuffix = userName

	if userName ~= "" and withServerID == true then
		userNameWithSuffix = ClientXPartQuery.servGetUserNameWithSuffix(userName)
	end

	return userNameWithSuffix
end

function ClientXPartQuery.servGetUserNameWithSuffix(userName)
	local userNameWithSuffix = userName

	if userName ~= "" then
		local serverID = ClientXPartQuery.servGetSelectServerID()

		if serverID == nil then
			serverID = -255
		end

		local needServerIDSuffix = ClientXPartQuery.servGetUserNameNeedServerID(serverID)

		if needServerIDSuffix == true then
			userNameWithSuffix = userName .. "-" .. tostring(serverID)
		end
	end

	return userNameWithSuffix
end

function ClientXPartQuery.servGetUserTicket(userNameWithSuffix)
	local isSdkEnable = SDKLoginConfig.isEnabled()
	local userTicket

	if isSdkEnable then
		if pg.global.sdkManager.isLogin == true then
			userTicket = pg.global.sdkManager.ticket
		end
	else
		if userNameWithSuffix == nil or userNameWithSuffix == "" then
			userNameWithSuffix = ClientXPartQuery.servGetUserName(true)
		end

		userTicket = ClientXPartQuery.genAccTicket(userNameWithSuffix, 0)
	end

	return userTicket
end

function ClientXPartQuery.servGetExternalAddrItem(servID, servName)
	local ClientUtils = require("Utils.ClientUtils")
	local result = {
		dirKey = "",
		dataIndex = 0
	}
	local dirConf, dirKey = ClientUtils.getDirConf()

	if dirConf == nil then
		return result
	end

	result.dirKey = dirKey
	result.dirConf = dirConf
	result.dirExtAddrList = dirConf.externalAddrList

	if dirConf.externalAddrList ~= nil and #dirConf.externalAddrList > 0 then
		result.findExtAddrItem = dirConf.externalAddrList[1]
	end

	result.dataIndex = 0

	for idx, info in ipairs(dirConf.localDirData) do
		if info.externalAddrList ~= nil and info.ClusterId == servID and info.ClusterName == servName then
			if info.externalAddrList ~= nil then
				result.dataIndex = idx
			end

			break
		end
	end

	if result.dataIndex ~= 0 then
		local info = dirConf.localDirData[result.dataIndex]

		result.dataItem = info
		result.dataExtAddrList = info.externalAddrList
	end

	if result.dataExtAddrList ~= nil and #result.dataExtAddrList > 0 then
		result.findExtAddrItem = result.dataExtAddrList[1]
	end

	return result
end

function ClientXPartQuery.toServerSceneUserKey(userName, serverid, serverName)
	local userKey = userName .. "_" .. tostring(serverid)

	return userKey
end

function ClientXPartQuery.tryGetUserLastScene()
	local ClientXPartUtil = require("Utils.ClientXPartUtil")
	local needGetLastScene = ClientXPartUtil.needCheck()

	if ClientXPartQuery._editorTest == true then
		needGetLastScene = true
	end

	if needGetLastScene == false then
		return
	end

	local serverid = ClientXPartQuery.servGetSelectServerID()
	local serverName = ClientXPartQuery.servGetSelectServerName()
	local userName = ClientXPartQuery.servGetUserName(false)

	if serverid == nil or serverid < 0 then
		print("@fjs LastScene tryGetUserLastScene: serverid not valid, skip")

		return
	end

	if userName == nil or userName == "" then
		print("@fjs LastScene tryGetUserLastScene: userName not valid, skip")

		return
	end

	local userKey = ClientXPartQuery.toServerSceneUserKey(userName, serverid, serverName)
	local cacheContext = ClientXPartQuery._serverSceneIDCache[userKey]

	if cacheContext ~= nil and cacheContext.UserKey == userKey then
		if cacheContext.SceneID == -1 then
			return
		end

		if cacheContext.SceneID >= 0 then
			print(string.format("@fjs tryGetUserLastScene: cache valid, skip, SceneID[%d], userKey[%s]", cacheContext.SceneID, userKey))

			return
		end
	end

	local extAddrResult = ClientXPartQuery.servGetExternalAddrItem(serverid, serverName)

	if extAddrResult == nil or extAddrResult.findExtAddrItem == nil then
		print("@fjs LastScene tryGetUserLastScene: extAddr not valid, skip")
		ClientUtils.showBubbleMessageRaw("ServerNoExternalAddrList", 3)

		return
	end

	local ctx = {}

	ctx.UserKey = userKey
	ctx.ServerID = serverid
	ctx.ServerName = serverName
	ctx.UserName = userName
	ctx.UserNameWithSuffix = ClientXPartQuery.servGetUserNameWithSuffix(userName)
	ctx.UserTicket = ClientXPartQuery.servGetUserTicket(ctx.UserNameWithSuffix)
	ctx.ExtAddrResult = extAddrResult

	local extAddrItem = extAddrResult.findExtAddrItem

	ctx.HttpTimeout = 15000
	ctx.HttpSSL = extAddrItem.isSSL or false
	ctx.HttpHost = extAddrItem.httpIp or "0.0.0.0"
	ctx.HttpPort = extAddrItem.httpPort or 80
	ctx.HttpMethod = "POST"
	ctx.HttpPath = "/queryLastScene"
	ctx.HttpHead = {
		["Content-Type"] = "application/json"
	}
	ctx.HttpData = {
		accountId = "",
		ticket = ""
	}
	ctx.HttpData.accountId = ctx.UserNameWithSuffix
	ctx.HttpData.ticket = ctx.UserTicket
	ctx.HttpBody = json.encode(ctx.HttpData)

	function ctx.Callback(reply)
		TimerManager.addTimer(0.01, function()
			ClientXPartQuery.callbackGetUserLastScene(ctx, reply)
		end)
	end

	ctx.SceneID = -1
	ctx.HttpReply = nil
	ClientXPartQuery._serverSceneIDCache[ctx.UserKey] = ctx

	print(string.format("@fjs tryGetUserLastScene: start ctx[%s]", table.val_to_str(ctx)))

	local httpProxy = HttpClientProxy()
	local httpReq = HttpRequest(ctx.HttpHost, ctx.HttpPort, ctx.HttpMethod, ctx.HttpPath, ctx.HttpHead, ctx.HttpBody, ctx.HttpSSL)

	httpProxy:httpRequest(httpReq, ctx.HttpTimeout, ctx.Callback, false)
end

function ClientXPartQuery.callbackGetUserLastScene(ctx, reply)
	local jtextCtx = ctx and table.val_to_str(ctx) or "nil"
	local jtextReply = reply and table.val_to_str(reply) or "nil"

	print(string.format("@fjs callbackGetUserLastScene: end ctx[%s], reply[%s]", jtextCtx, jtextReply))

	if ctx ~= nil then
		ctx.SceneID = 0
		ctx.HttpReply = reply
		ClientXPartQuery._serverSceneIDCache[ctx.UserKey] = ctx
	end

	if reply == nil or reply == "" then
		return
	end

	if reply.err ~= 0 then
		ClientXPartQuery.tipError("GetLastScene: err=" .. tostring(reply.err))

		return
	end

	if reply.body == nil then
		ClientXPartQuery.tipError("GetLastScene: err=body nil")

		return
	end

	local body = json.decode(reply.body)
	local code = body.code
	local errorCode = body.errorCode

	if code == 404 and errorCode == "ACCOUNT_NOT_FOUND" then
		-- block empty
	end

	local sceneid = 0

	if body.code ~= 200 then
		if code == 404 and errorCode == "ACCOUNT_NOT_FOUND" then
			sceneid = 0
		else
			ClientXPartQuery.tipError(string.format("GetLastScene: error, code[%s], body[%s]", tostring(body.code), table.val_to_str(body)))

			return
		end
	else
		local data = body.data

		if data ~= nil and data.lastSceneId ~= nil then
			sceneid = data.lastSceneId
		end
	end

	ctx.SceneID = sceneid

	print(string.format("@fjs callbackGetUserLastScene: sceneid[%d]", sceneid))
end

function ClientXPartQuery.tipError(msg)
	print("ClientXPartQuery.tipError: " .. msg)
	ClientUtils.showBubbleMessageRaw(msg, 3)
end

function ClientXPartQuery.getPartIDFromSceneID(sceneID)
	local saveCID = LuaCSConst.XPartConst.PCIDInit

	if sceneID == nil or sceneID <= 0 then
		return saveCID
	end

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")
	local mainSceneId = clientResMgrUtil.getXMainSceneId(sceneID)

	sceneID = mainSceneId

	if LuaCSConst.XPartConst.SceneFreeID[sceneID] then
		return saveCID
	end

	if sceneID == LuaCSConst.XPartConst.SceneNovice then
		saveCID = LuaCSConst.XPartConst.PCIDNovice
	elseif sceneID == LuaCSConst.XPartConst.SceneArk then
		saveCID = LuaCSConst.XPartConst.PCIDArk
	elseif sceneID == LuaCSConst.XPartConst.ScenePVETGrass then
		saveCID = LuaCSConst.XPartConst.PCIDArk
	elseif sceneID == LuaCSConst.XPartConst.SceneWater then
		saveCID = LuaCSConst.XPartConst.PCIDWater
	elseif sceneID == LuaCSConst.XPartConst.SceneFire then
		saveCID = LuaCSConst.XPartConst.PCIDFire
	elseif sceneID == LuaCSConst.XPartConst.SceneWorld then
		saveCID = LuaCSConst.XPartConst.PCIDWorld
	else
		saveCID = LuaCSConst.XPartConst.PCIDWorld
	end

	return saveCID
end

function ClientXPartQuery.getServerUserMaxPartID()
	local partid = LuaCSConst.XPartConst.PCIDInit
	local ClientXPartUtil = require("Utils.ClientXPartUtil")
	local needGetLastScene = ClientXPartUtil.needCheck()

	if ClientXPartQuery._editorTest == true then
		needGetLastScene = true
	end

	if needGetLastScene == false then
		return partid
	end

	local serverid = ClientXPartQuery.servGetSelectServerID()
	local serverName = ClientXPartQuery.servGetSelectServerName()
	local userName = ClientXPartQuery.servGetUserName(false)

	if serverid == nil or serverid < 0 then
		return partid
	end

	if userName == nil or userName == "" then
		return partid
	end

	local sceneid = 0
	local userKey = ClientXPartQuery.toServerSceneUserKey(userName, serverid, serverName)
	local cacheContext = ClientXPartQuery._serverSceneIDCache[userKey]

	if cacheContext ~= nil and cacheContext.UserKey == userKey then
		if cacheContext.SceneID == -1 then
			return partid
		end

		if cacheContext.SceneID ~= 0 then
			sceneid = cacheContext.SceneID
		end
	end

	if sceneid ~= 0 then
		partid = ClientXPartQuery.getPartIDFromSceneID(sceneid)
	end

	return partid
end

function ClientXPartQuery.haveGetServerUserSceneID()
	local partid = LuaCSConst.XPartConst.PCIDInit
	local ClientXPartUtil = require("Utils.ClientXPartUtil")
	local needGetLastScene = ClientXPartUtil.needCheck()

	if ClientXPartQuery._editorTest == true then
		needGetLastScene = true
	end

	if needGetLastScene == false then
		return false
	end

	local serverid = ClientXPartQuery.servGetSelectServerID()
	local serverName = ClientXPartQuery.servGetSelectServerName()
	local userName = ClientXPartQuery.servGetUserName(false)

	if serverid == nil or serverid < 0 then
		return false
	end

	if userName == nil or userName == "" then
		return false
	end

	local sceneid = 0
	local userKey = ClientXPartQuery.toServerSceneUserKey(userName, serverid, serverName)
	local cacheContext = ClientXPartQuery._serverSceneIDCache[userKey]

	if cacheContext == nil then
		return false
	end

	if cacheContext.SceneID < 0 then
		return false
	end

	return true
end

return ClientXPartQuery
