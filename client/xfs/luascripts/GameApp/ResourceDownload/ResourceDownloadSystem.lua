-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\ResourceDownload\\ResourceDownloadSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local LuaCSConst = require("Common.Const.LuaCSConst")
local ClientXPartUtil = require("Utils.ClientXPartUtil")
local MessageName = require("Const.MessageName")
local PackDownloadItem = require("Data.pack_download_item")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ResourceDownloadSystem = Class.LightClass("ResourceDownloadSystem", SystemBase)

ResourceDownloadSystem.READY_STATUS_DONE = 2
ResourceDownloadSystem.DOWN_STATUS = {
	PART = 4,
	WAIT = 3,
	DONE = 2,
	HALT = 7,
	PEND = 6,
	RECV = 5
}
ResourceDownloadSystem.BYTE_UNIT = 1024
ResourceDownloadSystem.MIN_VALID_DOWNLOAD_RATE = 4
ResourceDownloadSystem.SMOOTH_RATE_TIME = 5

function ResourceDownloadSystem:onInit()
	self.fullSpeedDownload = false
	self.packDownloadPartListCache = {}
	self.packDownloadDetailsCache = {}
	self.packDownloadStateCache = {}

	self:onXPartInit(ClientXPartUtil._partMode or 0, ClientXPartUtil._worldPartState or LuaCSConst.XPartConst.PercentFull)
end

function ResourceDownloadSystem:sendDownloadStateChanged()
	facade:SendMessageCommand(MessageName.RESOURCE_DOWNLOAD_STATE_CHANGED)
end

function ResourceDownloadSystem:onXPartInit(partMode, worldPartState)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onPreDownloadSkip(partMode)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onPreDownloadStart(partList)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onPreDownloadPart(clsid, instid, status)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onWaitPartReady(from, clsid, instid, status)
	return
end

function ResourceDownloadSystem:onWaitPartDownload(from, clsid, instid, status)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onWaitStart(from, partList)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onWaitProgress(from, partList, numNotReady)
	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onWaitComplete(from, partList)
	if ClientXPartUtil._waitContext and ClientXPartUtil._waitContext[from] then
		-- block empty
	end

	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onWaitModeChanged(mode)
	local fullSpeedDownload = mode == 1

	if self.fullSpeedDownload == fullSpeedDownload then
		return
	end

	self.fullSpeedDownload = fullSpeedDownload

	self:sendDownloadStateChanged()
end

function ResourceDownloadSystem:onPartDownloaded(clsid, instid)
	print(string.format("ResourceDownloadSystem:onPartDownloaded: cid:%d, iid:%d", clsid, instid))

	if clsid == LuaCSConst.XPartConst.PCIDWorld then
		ClientXPartUtil.openResourceDownloadCtrl({
			{
				clsid,
				instid
			}
		}, nil, true)
	end
end

function ResourceDownloadSystem:getPartMode()
	if not pg or not pg.global or not pg.global.resMgr then
		return 0
	end

	return pg.global.resMgr:XPartGetPartMode()
end

function ResourceDownloadSystem:setPartMode(fullSpeed)
	ClientXPartUtil._setWaitMode(fullSpeed and 1 or -1)
end

function ResourceDownloadSystem:isFullSpeedDownload()
	return self.fullSpeedDownload == true
end

function ResourceDownloadSystem:isXPartEnabled()
	return self:getPartMode() ~= 0
end

function ResourceDownloadSystem:isPartDetailComplete(detail)
	if not detail then
		return true
	end

	if (detail.Percent or 0) >= LuaCSConst.XPartConst.PercentFull then
		return true
	end

	if detail.ReadyStatus == ResourceDownloadSystem.READY_STATUS_DONE then
		return true
	end

	return detail.DownStatus == ResourceDownloadSystem.DOWN_STATUS.DONE
end

function ResourceDownloadSystem:isPartDetailReceiving(detail)
	return detail ~= nil and not self:isPartDetailComplete(detail) and detail.DownStatus == ResourceDownloadSystem.DOWN_STATUS.RECV
end

function ResourceDownloadSystem:isPartDetailDownloadActive(detail)
	if not detail or self:isPartDetailComplete(detail) then
		return false
	end

	local downStatus = detail.DownStatus

	return downStatus == ResourceDownloadSystem.DOWN_STATUS.RECV or downStatus == ResourceDownloadSystem.DOWN_STATUS.PEND or downStatus == ResourceDownloadSystem.DOWN_STATUS.HALT
end

function ResourceDownloadSystem:fillPartDetailState(detail)
	if not detail then
		return nil
	end

	local percent = tonumber(detail.Percent) or 0

	detail.percentRatio = percent / LuaCSConst.XPartConst.PercentFull
	detail.isComplete = self:isPartDetailComplete(detail)
	detail.isReceiving = self:isPartDetailReceiving(detail)

	local curSize = tonumber(detail.CurTotalByte or detail.CurByte) or 0

	detail.isPaused = not detail.isComplete and not detail.isReceiving and (detail.DownStatus == ResourceDownloadSystem.DOWN_STATUS.PEND or detail.DownStatus == ResourceDownloadSystem.DOWN_STATUS.HALT or curSize > 0)
	detail.isWaiting = not detail.isComplete and not detail.isReceiving and not detail.isPaused
	detail.isDownloadActive = self:isPartDetailDownloadActive(detail)
	detail.needDownload = not detail.isComplete

	return detail
end

function ResourceDownloadSystem:getPartDownloadDetail(clsid, instid, outDetail)
	if not clsid or not pg or not pg.global or not pg.global.resMgr then
		return nil
	end

	local detail = outDetail or {}

	pg.global.resMgr:XPartQueryDetail(clsid, instid or 0, detail)

	return self:fillPartDetailState(detail)
end

function ResourceDownloadSystem:getPartDownloadDetails(partList, outDetails)
	if not partList then
		return nil
	end

	local details = outDetails or {}

	for index, partInfo in ipairs(partList) do
		local detail = details[index] or {}

		details[index] = self:getPartDownloadDetail(partInfo[1], partInfo[2], detail)
	end

	for index = #partList + 1, #details do
		details[index] = nil
	end

	return details
end

function ResourceDownloadSystem:isPartDownloading(clsid, instid, outDetail)
	local detail = self:getPartDownloadDetail(clsid, instid, outDetail)

	return detail ~= nil and detail.isDownloadActive == true, detail
end

function ResourceDownloadSystem:isPartReceiving(clsid, instid, outDetail)
	local detail = self:getPartDownloadDetail(clsid, instid, outDetail)

	return detail ~= nil and detail.isReceiving == true, detail
end

function ResourceDownloadSystem:getPartIDsByArg(arg)
	if not arg then
		return nil
	end

	return ClientXPartUtil.getPartIDByArg(arg)
end

function ResourceDownloadSystem:getPartIDsByScene(sceneId)
	if not sceneId then
		return nil
	end

	local arg = {
		KeyFrom = LuaCSConst.XPartConst.KeyTeleToScene,
		ToScene = sceneId
	}

	return ClientXPartUtil.getPartIDByScene(arg, arg.KeyFrom, sceneId)
end

function ResourceDownloadSystem:getPartDownloadDetailsByArg(arg, outDetails)
	return self:getPartDownloadDetails(self:getPartIDsByArg(arg), outDetails)
end

function ResourceDownloadSystem:appendUniquePartInfo(partList, clsid, instid, addedMap)
	if not clsid then
		return
	end

	instid = instid or 0

	local key = tostring(clsid) .. "_" .. tostring(instid)

	if addedMap[key] then
		return
	end

	addedMap[key] = true
	partList[#partList + 1] = {
		clsid,
		instid
	}
end

function ResourceDownloadSystem:appendUniquePartList(targetPartList, sourcePartList, addedMap)
	if not sourcePartList then
		return
	end

	for _, partInfo in ipairs(sourcePartList) do
		self:appendUniquePartInfo(targetPartList, partInfo and partInfo[1], partInfo and partInfo[2], addedMap)
	end
end

function ResourceDownloadSystem:getPackDownloadCacheKey(packData, packId)
	return packId or packData and packData.packId or packData
end

function ResourceDownloadSystem:getPackDownloadPartList(packData, packId)
	if not packData then
		return nil
	end

	local cacheKey = self:getPackDownloadCacheKey(packData, packId)

	self.packDownloadPartListCache = self.packDownloadPartListCache or {}

	if cacheKey and self.packDownloadPartListCache[cacheKey] then
		return self.packDownloadPartListCache[cacheKey]
	end

	local partList = {}
	local addedMap = {}

	self:appendUniquePartList(partList, packData.partList, addedMap)

	if #partList <= 0 then
		return nil
	end

	if cacheKey then
		self.packDownloadPartListCache[cacheKey] = partList
	end

	return partList
end

function ResourceDownloadSystem:getPackDownloadSummary(packData, outSummary, packId)
	local summary = outSummary or {}

	summary.curSize = 0
	summary.totalSize = 0
	summary.progress = 0
	summary.isValid = false
	summary.isComplete = false
	summary.isDownloading = false
	summary.isPaused = false
	summary.isWaiting = false
	summary.needDownload = true

	if not self:isXPartEnabled() then
		summary.isValid = true
		summary.isComplete = true
		summary.needDownload = false
		summary.progress = 1

		return summary
	end

	local partList = self:getPackDownloadPartList(packData, packId)

	if not partList then
		return summary
	end

	summary.isValid = true
	summary.isComplete = true
	summary.needDownload = false

	local progressSum = 0
	local progressCount = 0
	local cacheKey = self:getPackDownloadCacheKey(packData, packId)

	self.packDownloadDetailsCache = self.packDownloadDetailsCache or {}

	local details = self:getPartDownloadDetails(partList, cacheKey and self.packDownloadDetailsCache[cacheKey] or {})

	if cacheKey then
		self.packDownloadDetailsCache[cacheKey] = details
	end

	for _, detail in ipairs(details) do
		if detail then
			local curSize = tonumber(detail.CurTotalByte or detail.CurByte) or 0
			local totalSize = tonumber(detail.NumByte) or 0

			summary.curSize = summary.curSize + curSize
			summary.totalSize = summary.totalSize + totalSize
			progressSum = progressSum + (tonumber(detail.percentRatio) or 0)
			progressCount = progressCount + 1
			summary.isComplete = summary.isComplete and detail.isComplete == true
			summary.needDownload = summary.needDownload or detail.needDownload == true
			summary.isDownloading = summary.isDownloading or detail.isReceiving == true
			summary.isPaused = summary.isPaused or detail.isPaused == true
			summary.isWaiting = summary.isWaiting or detail.isWaiting == true
		end
	end

	if summary.totalSize > 0 then
		summary.progress = summary.curSize / summary.totalSize
	elseif progressCount > 0 then
		summary.progress = progressSum / progressCount
	end

	if summary.progress < 0 then
		summary.progress = 0
	elseif summary.progress > 1 then
		summary.progress = 1
	end

	return summary
end

function ResourceDownloadSystem:getPackDownloadState(packData, outState, packId)
	local cacheKey = self:getPackDownloadCacheKey(packData, packId)

	self.packDownloadStateCache = self.packDownloadStateCache or {}

	local state = outState or cacheKey and self.packDownloadStateCache[cacheKey] or {}

	if cacheKey and not outState then
		self.packDownloadStateCache[cacheKey] = state
	end

	local summary = self:getPackDownloadSummary(packData, state, packId)

	state.stateName = "NotDownloaded"

	if summary.isComplete then
		state.stateName = "Downloaded"
	elseif summary.isDownloading then
		state.stateName = "Downloading"
	elseif summary.isPaused or summary.progress > 0 then
		state.stateName = "Pause"
	elseif summary.isWaiting then
		state.stateName = "Wait"
	end

	return state
end

function ResourceDownloadSystem:getCurrentDownloadingPackId()
	local waitPackId, pausePackId

	for packId, packData in pairs(PackDownloadItem) do
		if packData.showInList then
			local state = self:getPackDownloadState(packData, nil, packId)

			if state.stateName == "Downloading" then
				return packId
			elseif state.stateName == "Wait" and not waitPackId then
				waitPackId = packId
			elseif state.stateName == "Pause" then
				pausePackId = pausePackId or packId
			end
		end
	end

	return waitPackId or pausePackId
end

function ResourceDownloadSystem:requestDownloadPack(packData)
	local state = self:getPackDownloadState(packData)

	if not state.isValid or state.isComplete then
		return state
	end

	self:startSettingPackDownload(packData)

	return self:getPackDownloadState(packData, state)
end

function ResourceDownloadSystem:startDownloadAllPackDownloadItems()
	if not self:isXPartEnabled() then
		self:sendDownloadStateChanged()

		return nil, 0
	end

	local partList = {}
	local addedMap = {}

	for packId, packData in pairs(PackDownloadItem) do
		self:appendUniquePartList(partList, self:getPackDownloadPartList(packData, packId), addedMap)
	end

	local downloadCount = 0

	for _, partInfo in ipairs(partList) do
		local clsid = partInfo and partInfo[1]
		local instid = partInfo and (partInfo[2] or 0)

		if clsid then
			local _, started = self:startDownloadPartToHead(clsid, instid)

			if started then
				downloadCount = downloadCount + 1
			end
		end
	end

	self:sendDownloadStateChanged()

	return partList, downloadCount
end

function ResourceDownloadSystem:startSettingPackDownload(packData)
	if not packData or not packData.packId then
		return nil
	end

	local partList = self:getPackDownloadPartList(packData)

	if not partList then
		return nil
	end

	local downloadCount = 0

	for _, partInfo in ipairs(partList) do
		local clsid = partInfo and partInfo[1]
		local instid = partInfo and (partInfo[2] or 0)

		if clsid then
			local _, started = self:startDownloadPartToHead(clsid, instid)

			if started then
				downloadCount = downloadCount + 1
			end
		end
	end

	self:sendDownloadStateChanged()

	return partList, downloadCount
end

function ResourceDownloadSystem:startDownloadPartToHead(clsid, instid)
	if not clsid or not pg or not pg.global or not pg.global.resMgr then
		return nil, false
	end

	instid = instid or 0

	local status = pg.global.resMgr:XPartQueryStatus(clsid, instid)

	if status >= LuaCSConst.XPartConst.PercentFull then
		return status, false
	end

	status = pg.global.resMgr:XPartTryDownload(clsid, instid, ClientXPartUtil._limitKB, 0)

	pg.global.resMgr:XPartHeadDownload(clsid, instid)

	return status, true
end

function ResourceDownloadSystem:requestCleanPackList(packList)
	if not packList then
		return false
	end

	for _, packInfo in ipairs(packList) do
		self:requestCleanPack(packInfo)
	end

	return false
end

function ResourceDownloadSystem:requestCleanPack(packInfo)
	return false
end

function ResourceDownloadSystem:smoothDownloadRate(rateByte, curSize, totalSize, cache)
	rateByte = tonumber(rateByte) or 0
	curSize = tonumber(curSize) or 0
	totalSize = tonumber(totalSize) or 0

	if rateByte <= self.MIN_VALID_DOWNLOAD_RATE or totalSize <= curSize then
		cache.rateByte = nil

		return rateByte
	end

	local now = Time.realSecondCache

	if cache.rateByte == nil or cache.totalSize ~= totalSize or curSize < (cache.curSize or 0) or cache.time == nil then
		cache.rateByte = rateByte
	else
		local alpha = 1 - math.exp(-math.max(now - cache.time, 0) / self.SMOOTH_RATE_TIME)

		cache.rateByte = cache.rateByte + (rateByte - cache.rateByte) * alpha
	end

	cache.time = now
	cache.curSize = curSize
	cache.totalSize = totalSize

	return cache.rateByte
end

function ResourceDownloadSystem:formatDownloadTime(rateByte, curSize, totalSize, noPrefix)
	local leftByte = 0

	if totalSize > 0 then
		leftByte = totalSize - curSize
	end

	if leftByte < 0 then
		leftByte = 0
	end

	if rateByte <= 0 then
		rateByte = 1
	end

	local sec = leftByte / rateByte
	local leftTime = rateByte <= self.MIN_VALID_DOWNLOAD_RATE and "?" or LuaUIUtils.getCountDownString(sec, UIConst.TimeType.Short, true)

	if noPrefix then
		return leftTime
	end

	return pg.getFormatText(pg.getGameString("LEFT_TIME_WITH_PREFIX"), leftTime)
end

function ResourceDownloadSystem:formatDownloadBytes(bytes)
	bytes = tonumber(bytes) or 0

	if bytes >= self.BYTE_UNIT * self.BYTE_UNIT * self.BYTE_UNIT then
		return string.format("%.2fGB", bytes / self.BYTE_UNIT / self.BYTE_UNIT / self.BYTE_UNIT)
	end

	if bytes >= self.BYTE_UNIT * self.BYTE_UNIT then
		return string.format("%.2fMB", bytes / self.BYTE_UNIT / self.BYTE_UNIT)
	end

	if bytes >= self.BYTE_UNIT then
		return string.format("%.2fKB", bytes / self.BYTE_UNIT)
	end

	return string.format("%dB", bytes)
end

function ResourceDownloadSystem:appendPartDownloadDetails(partList, outDetails, startIndex, addedMap, onlyDownloadActive)
	if not partList then
		return startIndex or 0
	end

	local detailIndex = startIndex or 0

	for _, partInfo in ipairs(partList) do
		local clsid = partInfo and partInfo[1]
		local instid = partInfo and (partInfo[2] or 0)
		local key = clsid and tostring(clsid) .. "_" .. tostring(instid)

		if clsid and (not addedMap or not addedMap[key]) then
			if addedMap then
				addedMap[key] = true
			end

			local detail = self:getPartDownloadDetail(clsid, instid, outDetails[detailIndex + 1] or {})

			if not onlyDownloadActive or detail and detail.isDownloadActive then
				detailIndex = detailIndex + 1
				outDetails[detailIndex] = detail
			end
		end
	end

	return detailIndex
end

function ResourceDownloadSystem:getAllDownloadDetails(outDetails, onlyCurrentDownload)
	local details = outDetails or {}
	local addedMap = {}
	local detailIndex = 0
	local xPartConst = LuaCSConst.XPartConst
	local partList = {
		{
			xPartConst.PCIDInit,
			0
		},
		{
			xPartConst.PCIDLogin,
			0
		},
		{
			xPartConst.PCIDRole,
			0
		},
		{
			xPartConst.PCIDNovice,
			0
		},
		{
			xPartConst.PCIDArk,
			0
		},
		{
			xPartConst.PCIDWater,
			0
		},
		{
			xPartConst.PCIDFire,
			0
		},
		{
			xPartConst.PCIDWorld,
			0
		}
	}

	detailIndex = self:appendPartDownloadDetails(partList, details, detailIndex, addedMap, onlyCurrentDownload)

	for index = detailIndex + 1, #details do
		details[index] = nil
	end

	if detailIndex <= 0 then
		return nil
	end

	return details
end

function ResourceDownloadSystem:getWaitContextDownloadDetails(from, outDetails)
	local waitContext = ClientXPartUtil._waitContext
	local ctx = waitContext and waitContext[from]

	if not ctx then
		return nil
	end

	return self:getPartDownloadDetails(ctx.arrPartID, outDetails)
end

function ResourceDownloadSystem:getAllWaitContextDownloadDetails(outContextDetails)
	local waitContext = ClientXPartUtil._waitContext

	if not waitContext then
		return nil
	end

	local contextDetails = outContextDetails or {}

	for from in pairs(contextDetails) do
		if not waitContext[from] then
			contextDetails[from] = nil
		end
	end

	for from, ctx in pairs(waitContext) do
		contextDetails[from] = self:getPartDownloadDetails(ctx.arrPartID, contextDetails[from] or {})
	end

	return contextDetails
end

return ResourceDownloadSystem
