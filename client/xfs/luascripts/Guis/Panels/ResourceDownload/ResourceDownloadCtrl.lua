-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ResourceDownload\\ResourceDownloadCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ResourceDownloadCtrl = Class.LightClass("ResourceDownloadCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local SceneUtils = require("Common.Utils.SceneUtils")
local LuaCSConst = require("Common.Const.LuaCSConst")
local ItemSourceData = require("Data.item_source_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ArkSceneId = 501
local ArkShopMarkId = 76952704

ResourceDownloadCtrl.OFFICIAL_WEB_URL_CN = "www.yimoo.com"
ResourceDownloadCtrl.OFFICIAL_WEB_URL_OVERSEA = "www.aniimo.com"
ResourceDownloadCtrl.ARK_DOWNLOAD_PART_ID = LuaCSConst.XPartConst.PCIDArk
ResourceDownloadCtrl.WORLD_DOWNLOAD_PART_ID = LuaCSConst.XPartConst.PCIDWorld
ResourceDownloadCtrl.ARK_SHOP_SOURCE_ID = 103031
ResourceDownloadCtrl.GoButtonAction = {
	Close = 1,
	None = 0,
	ArkShopping = 2
}

function ResourceDownloadCtrl:onCreate(info)
	self.downloadDetails = {}
	self.downloadSummary = {}
	self.downloadRateCache = {}
	self.resourcePackSize = info and info.packSize or 0
	self.curDownloadedSize = info and info.curSize or 0
	self.stageDownloadPartId = info and info.stageDownloadPartId
	self.goButtonAction = self.GoButtonAction.None

	UICtrl.onCreate(self, info)

	self.tickTimer = self:startTimer(function()
		self:onTick()
	end, 1, true)
	self.resourceDownloadStarting = true

	self:refreshDownloadProgress()
end

function ResourceDownloadCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnViewUButton.luaClick()
		self:openTutorialStudio()
	end

	function self.view.btnGoUButton.luaClick()
		self:onGoButtonClick()
	end

	self.view.progressUProgress.normalizedValue = 0

	self:refreshDownloadProgress()
end

function ResourceDownloadCtrl:openTutorialStudio()
	pg.global.sdkManager:openUrl("ResourceDownload", "ResourceDownload.URL", self:getOfficialWebUrl())
end

function ResourceDownloadCtrl:getOfficialWebUrl()
	if ClientConfigAppCountry == "cn" then
		return self.OFFICIAL_WEB_URL_CN
	end

	return self.OFFICIAL_WEB_URL_OVERSEA
end

function ResourceDownloadCtrl:openMapTrackingArkShop()
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(ArkSceneId)
	local markPoint = sceneMarkPointData and sceneMarkPointData[ArkShopMarkId]

	if markPoint and markPoint.markType then
		pg.game.map:openMapAndLocateMark(ArkSceneId, markPoint.markType, ArkShopMarkId)

		return
	end
end

function ResourceDownloadCtrl:openArkShopping()
	local sourceData = ItemSourceData[self.ARK_SHOP_SOURCE_ID]

	if sourceData then
		LuaUIUtils.clueSeek(sourceData)
	end
end

function ResourceDownloadCtrl:onGoButtonClick()
	if self.goButtonAction == self.GoButtonAction.Close then
		self:close()
	elseif self.goButtonAction == self.GoButtonAction.ArkShopping then
		self:openArkShopping()
	end
end

function ResourceDownloadCtrl:onDestroy()
	self:killTimer(self.tickTimer)

	self.tickTimer = nil
	self.downloadDetails = nil
	self.downloadSummary = nil
	self.downloadRateCache = nil
end

function ResourceDownloadCtrl:onTick()
	self:refreshDownloadProgress()
end

function ResourceDownloadCtrl:refreshDownloadProgress()
	local summary = self:getDownloadSummary()
	local stageDownloadComplete = self.stageDownloadPartId and self:isDownloadPartComplete(self.stageDownloadPartId)
	local isDownloadComplete = summary.isComplete or stageDownloadComplete

	self.view.progressUProgress:SetActive(not isDownloadComplete)
	self.view.txtProgressUSDFText:SetActive(not isDownloadComplete)

	self.view.progressUProgress.normalizedValue = summary.progress or 0

	local progressText = self:getDownloadSizeText(summary)

	ClientTextUtils.setText(self.view.txtProgressUSDFText, progressText)
	ClientTextUtils.setText(self.view.txtDetailsUSDFText, string.format(pg.getGameString("PACKAGE_DOWNLOAD_DESC"), self:getTimeLeftText(summary), progressText))

	if self.resourceDownloadStarting == true and summary.rateByte > 0 then
		self.resourceDownloadStarting = false

		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("PACKAGE_DOWNLOAD_TITLE"))
	end

	self:refreshGoButton(summary)

	if isDownloadComplete then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("RESOURCE_DOWNLOADED_SUCCESS_TITLE"))
		ClientTextUtils.setText(self.view.txtDetailsUSDFText, pg.getGameString("RESOURCE_DOWNLOADED_SUCCESS_DESC"))
		self:killTimer(self.tickTimer)

		self.tickTimer = nil
	end
end

function ResourceDownloadCtrl:isDownloadPartComplete(partId)
	local resourceDownload = pg.game.resourceDownload
	local detail = resourceDownload and resourceDownload:getPartDownloadDetail(partId, 0)

	return detail and detail.isComplete == true
end

function ResourceDownloadCtrl:setGoButtonAction(action, text)
	self.goButtonAction = action

	self.view.btnGoUButton:SetActive(action == self.GoButtonAction.Close)
	self.view.btnCloseUButton:SetActive(action ~= self.GoButtonAction.Close)

	if text then
		ClientTextUtils.setText(self.view.txtGoUText, text)
	end
end

function ResourceDownloadCtrl:refreshGoButton(summary)
	if self.stageDownloadPartId == self.ARK_DOWNLOAD_PART_ID then
		if self:isDownloadPartComplete(self.ARK_DOWNLOAD_PART_ID) then
			self:setGoButtonAction(self.GoButtonAction.Close, pg.getGameString("QUEST_TRACK_PLAY_DIALOGUE"))
		else
			self:setGoButtonAction(self.GoButtonAction.None)
		end

		return
	end

	if self.stageDownloadPartId == self.WORLD_DOWNLOAD_PART_ID then
		if not self:isDownloadPartComplete(self.ARK_DOWNLOAD_PART_ID) then
			self:setGoButtonAction(self.GoButtonAction.None)
		elseif self:isDownloadPartComplete(self.WORLD_DOWNLOAD_PART_ID) then
			self:setGoButtonAction(self.GoButtonAction.Close, pg.getGameString("QUEST_TRACK_PLAY_DIALOGUE"))
		else
			self:setGoButtonAction(self.GoButtonAction.ArkShopping, pg.getGameString("GO_SHOPPING"))
		end

		return
	end

	if summary.isComplete then
		self:setGoButtonAction(self.GoButtonAction.Close, pg.getGameString("QUEST_TRACK_PLAY_DIALOGUE"))
	end
end

function ResourceDownloadCtrl:getDownloadSummary()
	local summary = self.downloadSummary

	summary.curSize = 0
	summary.totalSize = 0
	summary.progress = 0
	summary.isDownloading = false
	summary.isComplete = false
	summary.useMBUnit = false
	summary.rateByte = 0

	local details = self:getDownloadDetails()

	if details then
		self:fillDownloadSummary(summary, details)

		return summary
	end

	summary.curSize = self.curDownloadedSize
	summary.totalSize = self.resourcePackSize
	summary.useMBUnit = true

	if summary.totalSize > 0 then
		summary.progress = math.clamp(summary.curSize / summary.totalSize, 0, 1)
		summary.isComplete = summary.curSize >= summary.totalSize
	else
		summary.isComplete = true
	end

	return summary
end

function ResourceDownloadCtrl:getDownloadDetails()
	if not pg.game.resourceDownload or not pg.game.resourceDownload:isXPartEnabled() then
		return nil
	end

	return pg.game.resourceDownload:getAllDownloadDetails(self.downloadDetails, true)
end

function ResourceDownloadCtrl:fillDownloadSummary(summary, details)
	local progressSum = 0
	local progressCount = 0

	summary.isComplete = true

	for _, detail in ipairs(details) do
		if detail then
			local curSize = tonumber(detail.CurTotalByte or detail.CurByte) or 0
			local totalSize = tonumber(detail.NumByte) or 0

			if detail.DownStatus == 5 then
				summary.curSize = curSize
				summary.totalSize = totalSize
				summary.progress = math.clamp(tonumber(detail.percentRatio) or 0, 0, 1)
				summary.isDownloading = detail.isDownloadActive == true
				summary.isComplete = detail.isComplete == true
				summary.rateByte = tonumber(detail.RateByte) or 0

				return
			end

			summary.curSize = summary.curSize + curSize
			summary.totalSize = summary.totalSize + totalSize
			progressSum = progressSum + (tonumber(detail.percentRatio) or 0)
			progressCount = progressCount + 1
			summary.isDownloading = summary.isDownloading or detail.isDownloadActive == true
			summary.isComplete = summary.isComplete and detail.isComplete == true
		end
	end

	if summary.totalSize > 0 then
		summary.progress = math.clamp(summary.curSize / summary.totalSize, 0, 1)
	elseif progressCount > 0 then
		summary.progress = math.clamp(progressSum / progressCount, 0, 1)
	end

	summary.isComplete = progressCount > 0 and summary.isComplete
end

function ResourceDownloadCtrl:getDownloadSizeText(summary)
	if summary.useMBUnit then
		return summary.curSize .. "MB/" .. summary.totalSize .. "MB"
	end

	return pg.game.resourceDownload:formatDownloadBytes(summary.curSize) .. "/" .. pg.game.resourceDownload:formatDownloadBytes(summary.totalSize)
end

function ResourceDownloadCtrl:getTimeLeftText(summary)
	local resourceDownload = pg.game.resourceDownload
	local rateByte = resourceDownload:smoothDownloadRate(summary.rateByte, summary.curSize, summary.totalSize, self.downloadRateCache)

	return resourceDownload:formatDownloadTime(rateByte, summary.curSize, summary.totalSize, true)
end

return ResourceDownloadCtrl
