-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ResourceDownload\\Component\\DownloadProgressComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local DownloadProgressComponent = Class.LightClass("DownloadProgressComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")

DownloadProgressComponent.UPDATE_INTERVAL = 2
DownloadProgressComponent.TOOLTIP_AUTO_CLOSE_DELAY = 900
DownloadProgressComponent.BYTE_UNIT = 1024
DownloadProgressComponent.messages = {
	[MessageName.RESOURCE_DOWNLOAD_STATE_CHANGED] = {
		"onResourceDownloadStateChanged",
		true
	}
}

function DownloadProgressComponent:onCtor(info)
	self.downloadArg = info and info.downloadArg
	self.visibleTarget = info and info.visibleTarget
	self.visibleChanged = info and info.visibleChanged
	self.onDownloadComplete = info and info.onDownloadComplete
	self.clickFunc = info and info.clickFunc
	self.downloadDetails = {}
	self.downloadSummary = {
		progress = 0,
		totalSize = 0,
		curSize = 0,
		isComplete = false,
		isDownloading = false
	}
	self.downloadRateCache = {}
end

function DownloadProgressComponent:findObjects()
	if IsNil(self.transform) then
		return
	end

	local objectReference = self.transform:GetComponent("ObjectReference")

	self.downloadBtnUButton = self.transform:GetComponent("UButton")
	self.downloadProgress = objectReference:GetRefValue("progressUProgress")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function DownloadProgressComponent:registerObjects()
	if not self.downloadBtnUButton then
		return
	end

	if self.clickFunc then
		self.downloadBtnUButton.enabledTooltip = false
		self.downloadBtnUButton.luaRenderTooltip = nil
		self.downloadBtnUButton.luaTooltipPopup = nil

		function self.downloadBtnUButton.luaClick()
			self.clickFunc()
		end

		return
	end

	self.downloadBtnUButton.enabledTooltip = true

	function self.downloadBtnUButton.luaRenderTooltip(_, tooltip)
		self:renderDownloadTooltip(tooltip)
	end

	function self.downloadBtnUButton.luaTooltipPopup(_, flag)
		print("@fjs DownloadProgressComponent.luaTooltipPopup flag=", flag)

		if self.closeTooltipTimer then
			self:killTimer(self.closeTooltipTimer)

			self.closeTooltipTimer = nil
		end

		if flag then
			self.closeTooltipTimer = self:startTimer(function()
				self.closeTooltipTimer = nil

				if self.downloadBtnUButton and not IsNil(self.downloadBtnUButton) then
					self.downloadBtnUButton:CloseTooltip()
				end
			end, self.TOOLTIP_AUTO_CLOSE_DELAY)
		else
			self.tooltipBtn1UButton = nil
			self.tooltipBtn2UButton = nil

			if self.refreshTooltipTimer then
				self:killTimer(self.refreshTooltipTimer)

				self.refreshTooltipTimer = nil
			end
		end
	end
end

function DownloadProgressComponent:initView()
	self:setDownloadVisible(false)
	self:setDownloadProgress(0)
end

function DownloadProgressComponent:onShow()
	self:startRefresh()
end

function DownloadProgressComponent:onHide()
	self:stopRefresh()
end

function DownloadProgressComponent:onDestroy()
	self:stopRefresh()

	self.downloadDetails = nil
	self.downloadSummary = nil
	self.downloadRateCache = nil
end

function DownloadProgressComponent:startRefresh()
	if self.refreshTimer then
		return
	end

	self:refreshDownloadProgress()

	self.refreshTimer = self:startTimer(function()
		self:refreshDownloadProgress()
	end, self.UPDATE_INTERVAL, true)
end

function DownloadProgressComponent:stopRefresh()
	if self.refreshTimer then
		self:killTimer(self.refreshTimer)

		self.refreshTimer = nil
	end

	if self.refreshTooltipTimer then
		self:killTimer(self.refreshTooltipTimer)

		self.refreshTooltipTimer = nil
	end

	if self.closeTooltipTimer then
		self:killTimer(self.closeTooltipTimer)

		self.closeTooltipTimer = nil
	end

	self:setDownloadVisible(false)
end

function DownloadProgressComponent:refreshDownloadProgress()
	local summary = self:getDownloadSummary()

	self:tryNotifyDownloadComplete(summary)
	self:setDownloadVisible(summary.isDownloading)
	self:setDownloadProgress(summary.progress)
	self:setDownloadName()
end

function DownloadProgressComponent:tryNotifyDownloadComplete(summary)
	if not self.onDownloadComplete then
		return
	end

	if summary.isDownloading then
		self.wasDownloading = true

		return
	end

	if not self.wasDownloading or not summary.isComplete then
		return
	end

	self.wasDownloading = nil

	self.onDownloadComplete()
end

function DownloadProgressComponent:onResourceDownloadStateChanged()
	self:setDownloadName()
	self:refreshTooltipModeButtons()
end

function DownloadProgressComponent:refreshDownloadMode(combatStatus)
	if not pg or not pg.game or not pg.game.resourceDownload or not pg.game.resourceDownload:isXPartEnabled() then
		return
	end

	local inCombat = combatStatus == Const.COMBAT_STATUS_IN_COMBAT

	if combatStatus == nil and pg.me and pg.me.isInCombat then
		inCombat = pg.me:isInCombat()
	end

	pg.game.resourceDownload:setPartMode(not inCombat)
end

function DownloadProgressComponent:getDownloadDetails()
	if not pg.game.resourceDownload or not pg.game.resourceDownload:isXPartEnabled() then
		return nil
	end

	if not self.downloadArg then
		return pg.game.resourceDownload:getAllDownloadDetails(self.downloadDetails, true)
	end

	return pg.game.resourceDownload:getPartDownloadDetailsByArg(self.downloadArg, self.downloadDetails)
end

function DownloadProgressComponent:getDownloadSummary()
	local summary = self.downloadSummary

	summary.detail = nil
	summary.curSize = 0
	summary.totalSize = 0
	summary.progress = 0
	summary.isDownloading = false
	summary.isComplete = false

	local details = self:getDownloadDetails()

	if not details then
		return summary
	end

	local progressSum = 0
	local progressCount = 0

	summary.isComplete = true

	for _, detail in ipairs(details) do
		if detail then
			local curSize = tonumber(detail.CurTotalByte or detail.CurByte) or 0
			local totalSize = tonumber(detail.NumByte) or 0

			if detail.DownStatus == 5 then
				summary.detail = detail
			end

			summary.curSize = summary.curSize + curSize
			summary.totalSize = summary.totalSize + totalSize
			progressSum = progressSum + (tonumber(detail.percentRatio) or 0)
			progressCount = progressCount + 1
			summary.isDownloading = summary.isDownloading or detail.isDownloadActive == true
			summary.isComplete = summary.isComplete and detail.isComplete == true
		end
	end

	summary.isComplete = progressCount > 0 and summary.isComplete

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

function DownloadProgressComponent:setDownloadVisible(visible)
	visible = visible == true

	local changed = self.downloadVisible ~= visible

	self.downloadVisible = visible

	if self.visibleTarget then
		self.visibleTarget:SetActive(visible)
	elseif self.downloadBtnUButton then
		self.downloadBtnUButton:SetActive(visible)
	end

	if changed and self.visibleChanged then
		self.visibleChanged(visible)
	end
end

function DownloadProgressComponent:setDownloadProgress(progress)
	if not self.downloadProgress then
		return
	end

	self.downloadProgress.normalizedValue = progress or 0
end

function DownloadProgressComponent:setDownloadName()
	if not self.txtNameUSDFText then
		return
	end

	if not pg then
		return
	end

	self.txtNameUSDFText:SetActive(true)

	local resourceDownload = pg and pg.game and pg.game.resourceDownload
	local fullSpeed = resourceDownload and resourceDownload:isFullSpeedDownload()
	local textKey = fullSpeed and "RESOURCE_DOWNLOAD_FULL_SPEED" or "RESOURCE_DOWNLOAD_LIMIT_SPEED"

	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString(textKey))
end

function DownloadProgressComponent:renderDownloadTooltip(tooltip)
	if IsNil(tooltip) then
		return
	end

	local objectReference = tooltip:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtTitle = objectReference:GetRefValue("txtTitle")
	local btn1UButton = objectReference:GetRefValue("btn1UButton")
	local btn2UButton = objectReference:GetRefValue("btn2UButton")
	local txtDetail = objectReference:GetRefValue("txtDetail")
	local btn1Name = btn1UButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	local btn2Name = btn2UButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	self.tooltipBtn1UButton = btn1UButton
	self.tooltipBtn2UButton = btn2UButton

	function btn1UButton.luaClick()
		pg.game.resourceDownload:setPartMode(true)
		self:refreshTooltipModeButtons()
	end

	function btn2UButton.luaClick()
		pg.game.resourceDownload:setPartMode(false)
		self:refreshTooltipModeButtons()
	end

	self:refreshTooltipModeButtons()

	local summary = self:getDownloadSummary()

	if self.refreshTooltipTimer then
		self:killTimer(self.refreshTooltipTimer)

		self.refreshTooltipTimer = nil
	end

	local infoTip = self:getTipInfoFromSummary2(summary)

	ClientTextUtils.setText(txtDetail, infoTip)
	ClientTextUtils.setText(txtTitle, pg.getGameString("PACKEG_DOWNLOAD_TITLE"))
	ClientTextUtils.setText(btn1Name, pg.getGameString("DOWNLOAD_SPEED_FIRST"))
	ClientTextUtils.setText(btn2Name, pg.getGameString("DOWNLOAD_EXPERIENCE_FIRST"))

	self.refreshTooltipTimer = self:startTimer(function()
		summary = self:getDownloadSummary()

		local infoTip = self:getTipInfoFromSummary2(summary)

		ClientTextUtils.setText(txtDetail, infoTip)
	end, self.UPDATE_INTERVAL, true)
end

function DownloadProgressComponent:refreshTooltipModeButtons()
	if not self.tooltipBtn1UButton then
		return
	end

	local fullSpeed = pg.game.resourceDownload:isFullSpeedDownload()

	self.tooltipBtn1UButton.isSelected = fullSpeed
	self.tooltipBtn2UButton.isSelected = not fullSpeed
end

function DownloadProgressComponent:getTipInfoFromSummary2(summary)
	local detail = summary.detail
	local resourceDownload = pg and pg.game and pg.game.resourceDownload
	local curRateByte = detail and detail.RateByte or 0
	local curSizeByte = detail and detail.CurTotalByte or 0
	local totalSizeByte = detail and detail.NumByte or 0
	local smoothRateByte = resourceDownload:smoothDownloadRate(curRateByte, curSizeByte, totalSizeByte, self.downloadRateCache)
	local timeLeft = resourceDownload:formatDownloadTime(smoothRateByte, curSizeByte, totalSizeByte, true)

	return pg.getFormatText(pg.getGameString("DOWNLOAD_PROGRESS_TOOLTIP_DETAIL"), self:formatBytes(curSizeByte) .. "/" .. self:formatBytes(totalSizeByte), self:formatBytes(curRateByte) .. "/s", timeLeft)
end

function DownloadProgressComponent:formatBytes(bytes)
	return pg.game.resourceDownload:formatDownloadBytes(bytes)
end

return DownloadProgressComponent
