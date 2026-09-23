-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ArkScreenInfoMap.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local AdvertisingContentData = require("Data.advertising_content_data")
local AdvertisingScreenData = require("Data.advertising_screen_data")
local ArkScreenInfoMap = class.LiteClass("ArkScreenInfoMap", CustomDict)

function ArkScreenInfoMap:addNormalScreenInfo(curSeconds, curTime, screenId, detailConfigData)
	self[screenId] = self[screenId] or {}

	if self[screenId].sourceScreenId > 0 or self[screenId].sourceContentScreenId > 0 then
		return false
	end

	self[screenId].screenId = screenId
	self[screenId].contentBeginTime = curTime

	if detailConfigData.playMod == 1 then
		self[screenId].contentIndex = self[screenId].contentIndex + 1

		if self[screenId].contentIndex > lume.tableLength(detailConfigData.groupId) then
			self[screenId].contentIndex = 1
		end

		self[screenId].contentId = detailConfigData.groupId[self[screenId].contentIndex]
	else
		self[screenId].contentId = lume.weightRandomChoiceOne(detailConfigData.groupId, detailConfigData.weight)
	end

	return true
end

function ArkScreenInfoMap:updateNormalScreenInfo(curSeconds, curTime, screenId, detailConfigData)
	if not self[screenId] then
		return self:addNormalScreenInfo(curSeconds, curTime, screenId, detailConfigData)
	end

	if self[screenId].sourceScreenId > 0 or self[screenId].sourceContentScreenId > 0 then
		return false
	end

	self[screenId].contentBeginTime = curTime

	if detailConfigData.playMod == 1 then
		self[screenId].contentIndex = self[screenId].contentIndex + 1

		if self[screenId].contentIndex > lume.tableLength(detailConfigData.groupId) then
			self[screenId].contentIndex = 1
		end

		self[screenId].contentId = detailConfigData.groupId[self[screenId].contentIndex]
	else
		self[screenId].contentId = lume.weightRandomChoiceOne(detailConfigData.groupId, detailConfigData.weight)
	end

	return true
end

function ArkScreenInfoMap:setNormalScreenInfoByScreenLinked(sourceScreenId, curScreenId)
	local sourceScreenInfo = self[sourceScreenId]

	if not sourceScreenInfo then
		return
	end

	self[curScreenId] = self[curScreenId] or {}
	self[curScreenId].screenId = curScreenId
	self[curScreenId].contentBeginTime = sourceScreenInfo.contentBeginTime
	self[curScreenId].contentId = sourceScreenInfo.contentId
	self[curScreenId].sourceScreenId = sourceScreenId
end

function ArkScreenInfoMap:setNormalScreenInfoByContentLinked(sourceContentId, curScreenId, curContentId)
	local sourceScreenInfo = self[sourceContentId]

	if not sourceScreenInfo then
		return
	end

	self[curScreenId] = self[curScreenId] or {}
	self[curScreenId].screenId = curScreenId
	self[curScreenId].contentBeginTime = sourceScreenInfo.contentBeginTime
	self[curScreenId].contentId = curContentId
	self[curScreenId].sourceContentScreenId = sourceContentId
end

function ArkScreenInfoMap:resetScreenInfo(screenId)
	if not self[screenId] then
		return
	end

	self[screenId].contentBeginTime = 0
	self[screenId].contentId = 0
	self[screenId].sourceScreenId = 0
	self[screenId].sourceContentScreenId = 0
	self[screenId].isInSpecial = false
end

function ArkScreenInfoMap:isBeScreenLinked(screenId)
	if not self[screenId] then
		return false
	end

	return self[screenId].sourceScreenId > 0
end

function ArkScreenInfoMap:isCurContentScreenLinked(screenId, areaType)
	if not self[screenId] then
		return false
	end

	if self[screenId].contentId <= 0 then
		return false
	end

	local screenData = self:_getAdvertisingScreenConfigData(screenId, areaType)

	if not screenData or not screenData.linkedScreen then
		return false
	end

	return lume.tableLength(screenData.linkedScreen) > 0 and AdvertisingContentData[self[screenId].contentId].restype == Const.ARK_SCREEN_CONTENT_TYPE.VEDIO_ALL
end

function ArkScreenInfoMap:getCurContentLinkedScreens(screenId, areaType)
	if not self[screenId] then
		return {}
	end

	local screenData = self:_getAdvertisingScreenConfigData(screenId, areaType)

	if not screenData then
		return {}
	end

	return screenData.linkedScreen or {}
end

function ArkScreenInfoMap:isBeContentLinked(screenId)
	if not self[screenId] then
		return false
	end

	return self[screenId].sourceContentScreenId > 0
end

function ArkScreenInfoMap:isCurContentContentLinked(screenId)
	if not self[screenId] then
		return false
	end

	local contentData = AdvertisingContentData[self[screenId].contentId]

	if not contentData or not contentData.linkedContent then
		return false
	end

	return lume.tableLength(contentData.linkedContent) > 0
end

function ArkScreenInfoMap:getCurContentLinkedContent(screenId)
	if not self[screenId] then
		return {}
	end

	return AdvertisingContentData[self[screenId].contentId].linkedContent or {}
end

function ArkScreenInfoMap:getCurScreenContentDuration(screenId)
	if not self[screenId] then
		return 0
	end

	local duration = AdvertisingContentData[self[screenId].contentId].duration

	return duration
end

function ArkScreenInfoMap:addSpecialScreenInfo(curSeconds, curTime, screenId, detailConfigData)
	self[screenId] = self[screenId] or {}
	self[screenId].screenId = screenId
	self[screenId].contentBeginTime = curTime
	self[screenId].contentId = detailConfigData.contentId[1]
	self[screenId].isInSpecial = true

	return true
end

function ArkScreenInfoMap:updateSpecialScreenInfo(curSeconds, curTime, screenId, detailConfigData)
	if not self[screenId] then
		return self:addSpecialScreenInfo(curSeconds, curTime, screenId, detailConfigData)
	end

	self[screenId].contentBeginTime = curTime
	self[screenId].contentId = detailConfigData.contentId[1]
	self[screenId].isInSpecial = true

	return true
end

function ArkScreenInfoMap:isCurContentInSpecial(screenId)
	local screenInfo = self[screenId]

	if screenInfo and screenInfo.isInSpecial then
		return true
	end

	return false
end

function ArkScreenInfoMap:debugInfo(screenId)
	if not self[screenId] then
		return ""
	end

	local info = self[screenId]

	return string.format("beginTime=%s contentId=%s isInSpecial=%s sourceScreenId=%s sourceContentScreenId=%s", info.contentBeginTime, info.contentId, info.isInSpecial, info.sourceScreenId, info.sourceContentScreenId)
end

function ArkScreenInfoMap:getClientFullScreenInfo()
	local screenInfo = {}

	for screenId, info in pairs(self) do
		screenInfo[screenId] = {
			contentId = info.contentId,
			contentBeginTime = info.contentBeginTime
		}
	end

	return screenInfo
end

function ArkScreenInfoMap:getClientScreenInfo(screenId)
	local info = self[screenId]

	if info then
		return {
			[screenId] = {
				contentId = info.contentId,
				contentBeginTime = info.contentBeginTime
			}
		}
	end

	return {}
end

function ArkScreenInfoMap:_getAdvertisingScreenConfigData(screenId, areaType)
	local advertisingScreenData = AdvertisingScreenData[screenId]

	if not advertisingScreenData then
		return nil
	end

	return advertisingScreenData[areaType]
end

function ArkScreenInfoMap:showSceneInfo()
	local screenIds = lume.keys(AdvertisingScreenData)

	screenIds = lume.sort(screenIds)

	local str = ""

	for _, screenId in ipairs(screenIds) do
		local info = self[screenId]

		if info then
			str = str .. string.format("[%s,%s,%s]", screenId, info.contentId, info.contentBeginTime)
		end
	end

	return str
end

return ArkScreenInfoMap
