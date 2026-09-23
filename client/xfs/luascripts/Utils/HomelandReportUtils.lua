-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HomelandReportUtils.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandReportUtils")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local HomelandReportUtils = {}

HomelandReportUtils.REPORT_SOURCE = "homeland"
HomelandReportUtils.CAPTURE_TIMEOUT = 5
HomelandReportUtils.SUBMIT_UI_HIDE_TIMEOUT = 30

function HomelandReportUtils.getOtherHomelandInfo(space)
	local player = pg.me

	space = space or player and player.space

	if not player or not space or not space.isHomeland or not space:isHomeland() then
		return nil
	end

	if not space.isSelfHomeland or space:isSelfHomeland(player) then
		return nil
	end

	local spaceId = tostring(space.id or "")
	local _, ownerUid = HomeLandUtils.parseHomelandKey(spaceId)

	if string.isNilOrEmpty(ownerUid) or ownerUid == "nil" then
		return nil
	end

	local ownerPlayer = space.homeLandOwnerPlayerId and pg.getEntity(space.homeLandOwnerPlayerId)

	if ownerPlayer and tostring(ownerPlayer.uid or "") ~= ownerUid then
		ownerPlayer = nil
	end

	local ownerName = ownerPlayer and ownerPlayer.playerName or ""

	if string.isNilOrEmpty(ownerName) then
		ownerName = LuaUIUtils.getPlayerDisplayName(ownerUid, nil, true)
	end

	if string.isNilOrEmpty(ownerName) then
		ownerName = ownerUid
	end

	local homeName = space.basicInfo and space.basicInfo.name or ""

	if string.isNilOrEmpty(homeName) then
		homeName = ownerName
	end

	return {
		spaceId = spaceId,
		ownerUid = ownerUid,
		ownerName = ownerName,
		homeName = homeName
	}
end

function HomelandReportUtils.isAvailable()
	return HomelandReportUtils.getOtherHomelandInfo() ~= nil
end

function HomelandReportUtils.destroyCapturedSprite(sprite)
	local cameraMgr = pg.global and pg.global.mobileCameraMgr

	if sprite and not IsNil(sprite) and cameraMgr then
		cameraMgr:DestroySpriteTexture(sprite)
	end
end

function HomelandReportUtils.restoreCaptureState(imageContext)
	if not imageContext or not imageContext.isCaptureStateHidden then
		return
	end

	imageContext.isCaptureStateHidden = false

	local ui = pg.global and pg.global.ui

	if ui then
		ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.HOMELAND_REPORT)
	end

	local input = pg.game and pg.game.input

	if input then
		input:setEnabledViewCtrl(true, UIConst.UI_HIDE_KEY.HOMELAND_REPORT)
	end
end

function HomelandReportUtils.clearCaptureTimer()
	if HomelandReportUtils._captureTimer then
		TimerManager.removeTimer(HomelandReportUtils._captureTimer)

		HomelandReportUtils._captureTimer = nil
	end
end

function HomelandReportUtils.isReportContextValid(imageContext)
	if not imageContext then
		return false
	end

	local currentInfo = HomelandReportUtils.getOtherHomelandInfo()

	return currentInfo and currentInfo.spaceId == imageContext.spaceId and currentInfo.ownerUid == imageContext.ownerUid
end

function HomelandReportUtils.finishCapture(imageContext, token)
	if token ~= HomelandReportUtils._activeCaptureToken or token ~= imageContext.submitToken then
		return false
	end

	HomelandReportUtils._activeCaptureToken = nil

	HomelandReportUtils.clearCaptureTimer()

	return true
end

function HomelandReportUtils.onCaptureTimeout(imageContext, ctrl, token)
	if token ~= HomelandReportUtils._activeCaptureToken or token ~= imageContext.submitToken then
		return
	end

	HomelandReportUtils._captureTimer = nil
	HomelandReportUtils._activeCaptureToken = nil
	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	HomelandReportUtils.restoreCaptureState(imageContext)
	HomelandReportUtils.setSubmitInteractable(ctrl, true)
	logger:warn("homeland report screenshot timed out")

	if ctrl and ctrl:checkUIOpen() then
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))
	end
end

function HomelandReportUtils.onPanelOpenFinished()
	HomelandReportUtils._isOpeningPanel = false
end

function HomelandReportUtils.setSubmitInteractable(ctrl, interactable)
	local button = ctrl and ctrl.view and ctrl.view.btnConfirmUButton

	if button and not IsNil(button) then
		button.interactable = interactable
	end
end

function HomelandReportUtils.cancelSubmit(imageContext)
	if not imageContext then
		return
	end

	if imageContext.submitToken == HomelandReportUtils._activeCaptureToken then
		HomelandReportUtils._activeCaptureToken = nil

		HomelandReportUtils.clearCaptureTimer()
	end

	HomelandReportUtils.restoreCaptureState(imageContext)

	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	if imageContext.sprite then
		HomelandReportUtils.destroyCapturedSprite(imageContext.sprite)

		imageContext.sprite = nil
	end
end

function HomelandReportUtils.finishSubmitWithError(imageContext, ctrl, sprite, errorMessage)
	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	if imageContext.sprite == sprite then
		imageContext.sprite = nil
	end

	HomelandReportUtils.destroyCapturedSprite(sprite)
	HomelandReportUtils.restoreCaptureState(imageContext)
	HomelandReportUtils.setSubmitInteractable(ctrl, true)
	logger:error(errorMessage)

	if ctrl and ctrl:checkUIOpen() then
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))
	end
end

function HomelandReportUtils.onReportImageUploaded(reportInfo, imageContext, ctrl, submitToken, sprite, key, success, imgUrl)
	logger:info("dxk homeland report screenshot upload finished, key=%s, success=%s, imgUrl=%s", tostring(key), tostring(success), tostring(imgUrl))
	HomelandReportUtils.destroyCapturedSprite(sprite)

	if imageContext.sprite == sprite then
		imageContext.sprite = nil
	end

	if imageContext.submitToken ~= submitToken then
		return
	end

	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	if not ctrl or not ctrl:checkUIOpen() then
		HomelandReportUtils.restoreCaptureState(imageContext)

		return
	end

	if not success or string.isNilOrEmpty(imgUrl) then
		HomelandReportUtils.restoreCaptureState(imageContext)
		HomelandReportUtils.setSubmitInteractable(ctrl, true)
		logger:error("homeland report screenshot upload failed, key=%s", tostring(key))
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

		return
	end

	if not HomelandReportUtils.isReportContextValid(imageContext) then
		HomelandReportUtils.restoreCaptureState(imageContext)
		HomelandReportUtils.setSubmitInteractable(ctrl, true)
		logger:error("homeland report submit failed: report target changed after screenshot upload")
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))

		return
	end

	reportInfo.imgUrl = imgUrl

	pg.me:reportChat(reportInfo)
	ctrl:closeImmediately()
	HomelandReportUtils.restoreCaptureState(imageContext)
	pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))
end

function HomelandReportUtils.onReportScreenCaptured(reportInfo, imageContext, ctrl, submitToken, sprite)
	if not HomelandReportUtils.finishCapture(imageContext, submitToken) then
		HomelandReportUtils.destroyCapturedSprite(sprite)

		return
	end

	if not sprite or IsNil(sprite) then
		HomelandReportUtils.finishSubmitWithError(imageContext, ctrl, sprite, "homeland report screenshot failed")

		return
	end

	imageContext.sprite = sprite

	if not ctrl or not ctrl:checkUIOpen() or not HomelandReportUtils.isReportContextValid(imageContext) then
		HomelandReportUtils.finishSubmitWithError(imageContext, ctrl, sprite, "homeland report submit failed: report target changed during screenshot")

		return
	end

	if not pg.me or not pg.me.addPhotoImgSprite then
		HomelandReportUtils.finishSubmitWithError(imageContext, ctrl, sprite, "homeland report screenshot upload is unavailable")

		return
	end

	pg.me:addPhotoImgSprite(sprite, function(key, success, imgUrl)
		HomelandReportUtils.onReportImageUploaded(reportInfo, imageContext, ctrl, submitToken, sprite, key, success, imgUrl)
	end)
end

function HomelandReportUtils.submitReport(reportInfo, imageContext, ctrl)
	if not imageContext or imageContext.isSubmitting then
		return
	end

	if not HomelandReportUtils.isReportContextValid(imageContext) then
		logger:error("homeland report submit failed: report target is invalid")
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))

		return
	end

	if tonumber(reportInfo.reportType) == Const.ACCUSATION_TYPE.PLAYER_HOME_NAME then
		pg.me:reportChat(reportInfo)
		ctrl:closeImmediately()
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))

		return
	end

	local cameraMgr = pg.global and pg.global.mobileCameraMgr

	if not cameraMgr or not pg.global.ui or not pg.game or not pg.game.input then
		logger:error("homeland report screenshot failed: capture service is unavailable")
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

		return
	end

	local submitToken = {}

	imageContext.submitToken = submitToken
	imageContext.isSubmitting = true
	imageContext.isCaptureStateHidden = true

	HomelandReportUtils.setSubmitInteractable(ctrl, false)

	HomelandReportUtils._activeCaptureToken = submitToken

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.HOMELAND_REPORT, {}, HomelandReportUtils.SUBMIT_UI_HIDE_TIMEOUT)
	pg.game.input:setEnabledViewCtrl(false, UIConst.UI_HIDE_KEY.HOMELAND_REPORT)

	HomelandReportUtils._captureTimer = TimerManager.addTimer(HomelandReportUtils.CAPTURE_TIMEOUT, function()
		HomelandReportUtils.onCaptureTimeout(imageContext, ctrl, submitToken)
	end)

	cameraMgr:CaptureScreenDelaySaveCopy(function(sprite)
		HomelandReportUtils.onReportScreenCaptured(reportInfo, imageContext, ctrl, submitToken, sprite)
	end)
end

function HomelandReportUtils.openReportPanel(targetInfo)
	local imageContext = {
		spaceId = targetInfo.spaceId,
		ownerUid = targetInfo.ownerUid
	}

	HomelandReportUtils._isOpeningPanel = true

	pg.global.ui:open(UIConst.UI_ID_ACCUSATION, {
		playerId = targetInfo.ownerUid,
		playerName = targetInfo.homeName,
		playerDisplayName = targetInfo.homeName,
		reportInfo = {
			uid = targetInfo.ownerUid,
			name = targetInfo.homeName,
			character = targetInfo.homeName,
			homeName = targetInfo.homeName,
			detailType = HomelandReportUtils.REPORT_SOURCE
		},
		reportSource = HomelandReportUtils.REPORT_SOURCE,
		reportImageContext = imageContext,
		reportSubmitHandler = HomelandReportUtils.submitReport,
		reportCancelHandler = HomelandReportUtils.cancelSubmit
	}, function()
		HomelandReportUtils.onPanelOpenFinished()
	end, function()
		HomelandReportUtils.onPanelOpenFinished()
	end)
end

function HomelandReportUtils.open()
	if HomelandReportUtils._isOpeningPanel then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_ACCUSATION) then
		return
	end

	local targetInfo = HomelandReportUtils.getOtherHomelandInfo()

	if not targetInfo then
		return
	end

	HomelandReportUtils.openReportPanel(targetInfo)
end

HomelandReportUtils.HOME_CAMP_REPORT_SOURCE = "homeCamp"

function HomelandReportUtils.showNoHomeCampReportablePlayerNotice()
	pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_REPORT_NO_PLAYER)
end

function HomelandReportUtils.getCurrentHomeCampContext()
	local player = pg.me
	local space = player and player.space

	if not player or not space or not space.isHomeCamp or not space:isHomeCamp() then
		return nil
	end

	return {
		spaceId = tostring(space.id or ""),
		spaceKey = tostring(space.spaceKey or ""),
		campStaticId = tostring(player.curCampStaticId or ""),
		campLineUid = tostring(player.curCampLineUid or "")
	}
end

function HomelandReportUtils.isHomeCampReportAvailable()
	return HomelandReportUtils.getCurrentHomeCampContext() ~= nil
end

function HomelandReportUtils.getCurrentHomeCampCarEntries()
	local player = pg.me
	local space = player and player.space

	if not HomelandReportUtils.isHomeCampReportAvailable() then
		return nil
	end

	local carCreatedMap = space.campCarCreatedMap

	if not carCreatedMap then
		return nil
	end

	local entries = {}

	for rawUid, entId in pairs(carCreatedMap) do
		local carEnt = entId and pg.getEntity(entId)
		local isCurrentCar = carEnt and not carEnt.destroyed and carEnt.space == space
		local uid = tostring(isCurrentCar and carEnt.ownerUid or rawUid or "")

		if not string.isNilOrEmpty(uid) then
			local carIndex = isCurrentCar and tonumber(carEnt.carIndex) or nil

			entries[#entries + 1] = {
				slotIndex = carIndex,
				slotKey = tostring(carIndex or uid),
				uid = uid,
				homeName = HomeLandUtils.getCampAddOnOwnerNameFromCreatedMap(space, uid)
			}
		end
	end

	table.sort(entries, function(a, b)
		if a.slotIndex and b.slotIndex and a.slotIndex ~= b.slotIndex then
			return a.slotIndex < b.slotIndex
		end

		if a.slotIndex ~= b.slotIndex then
			return a.slotIndex ~= nil
		end

		if a.slotKey ~= b.slotKey then
			return a.slotKey < b.slotKey
		end

		return a.uid < b.uid
	end)

	return entries
end

function HomelandReportUtils.isHomeCampInfoReady()
	if not HomelandReportUtils.isHomeCampReportAvailable() then
		return false
	end

	local space = pg.me.space
	local carCreatedMap = space.campCarCreatedMap
	local campLineInfo = space.campLineInfo

	return carCreatedMap ~= nil and campLineInfo ~= nil and campLineInfo.lineUid ~= 0 and #carCreatedMap == campLineInfo.loginCount
end

function HomelandReportUtils.getHomeCarNamesByUid()
	local namesByUid = {}
	local carEntries = HomelandReportUtils.getCurrentHomeCampCarEntries()

	for _, entry in ipairs(carEntries or {}) do
		if not string.isNilOrEmpty(entry.homeName) then
			namesByUid[entry.uid] = entry.homeName
		end
	end

	return namesByUid
end

function HomelandReportUtils.getHomeCampReportablePlayerUids(includeSelf)
	local player = pg.me
	local carEntries = HomelandReportUtils.getCurrentHomeCampCarEntries()

	if not player or not carEntries then
		return {}
	end

	local selfUid = tostring(player.uid or "")
	local uids = {}
	local seen = {}

	for _, entry in ipairs(carEntries) do
		if (includeSelf or entry.uid ~= selfUid) and not seen[entry.uid] then
			seen[entry.uid] = true
			uids[#uids + 1] = entry.uid
		end
	end

	if includeSelf and not string.isNilOrEmpty(selfUid) and not seen[selfUid] then
		uids[#uids + 1] = selfUid
	end

	return uids
end

function HomelandReportUtils.isHomeCampReportContextValid(context, reportInfos)
	if not context then
		return false
	end

	local currentContext = HomelandReportUtils.getCurrentHomeCampContext()

	if not currentContext or currentContext.spaceId ~= context.spaceId or currentContext.spaceKey ~= context.spaceKey or currentContext.campStaticId ~= context.campStaticId or currentContext.campLineUid ~= context.campLineUid then
		return false
	end

	if not reportInfos then
		return true
	end

	local availableUids = {}

	for _, uid in ipairs(HomelandReportUtils.getHomeCampReportablePlayerUids()) do
		availableUids[uid] = true
	end

	for _, reportInfo in ipairs(reportInfos) do
		local uid = tostring(reportInfo.uid or "")

		if string.isNilOrEmpty(uid) or not availableUids[uid] then
			return false
		end
	end

	return #reportInfos > 0
end

function HomelandReportUtils.submitHomeCampReports(reportInfos, imgUrl)
	for _, reportInfo in ipairs(reportInfos) do
		reportInfo.imgUrl = imgUrl

		pg.me:reportChat(reportInfo)
	end
end

function HomelandReportUtils.restoreHomeCampCaptureState(imageContext)
	if not imageContext or not imageContext.isCaptureStateHidden then
		return
	end

	imageContext.isCaptureStateHidden = false

	local ui = pg.global and pg.global.ui

	if ui then
		ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.HOME_CAMP_REPORT)
	end

	local input = pg.game and pg.game.input

	if input then
		input:setEnabledViewCtrl(true, UIConst.UI_HIDE_KEY.HOME_CAMP_REPORT)
	end
end

function HomelandReportUtils.clearHomeCampCaptureTimer()
	if HomelandReportUtils._homeCampCaptureTimer then
		TimerManager.removeTimer(HomelandReportUtils._homeCampCaptureTimer)

		HomelandReportUtils._homeCampCaptureTimer = nil
	end
end

function HomelandReportUtils.finishHomeCampCapture(imageContext, token)
	if token ~= HomelandReportUtils._activeHomeCampCaptureToken or token ~= imageContext.submitToken then
		return false
	end

	HomelandReportUtils._activeHomeCampCaptureToken = nil

	HomelandReportUtils.clearHomeCampCaptureTimer()

	return true
end

function HomelandReportUtils.onHomeCampCaptureTimeout(imageContext, ctrl, token)
	if token ~= HomelandReportUtils._activeHomeCampCaptureToken or token ~= imageContext.submitToken then
		return
	end

	HomelandReportUtils._homeCampCaptureTimer = nil
	HomelandReportUtils._activeHomeCampCaptureToken = nil
	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	HomelandReportUtils.restoreHomeCampCaptureState(imageContext)
	HomelandReportUtils.setSubmitInteractable(ctrl, true)
	logger:warn("home camp report screenshot timed out")

	if ctrl and ctrl:checkUIOpen() then
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))
	end
end

function HomelandReportUtils.cancelHomeCampReportSubmit(imageContext)
	if not imageContext then
		return
	end

	if imageContext.submitToken == HomelandReportUtils._activeHomeCampCaptureToken then
		HomelandReportUtils._activeHomeCampCaptureToken = nil

		HomelandReportUtils.clearHomeCampCaptureTimer()
	end

	HomelandReportUtils.restoreHomeCampCaptureState(imageContext)

	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	if imageContext.sprite then
		HomelandReportUtils.destroyCapturedSprite(imageContext.sprite)

		imageContext.sprite = nil
	end
end

function HomelandReportUtils.finishHomeCampSubmitWithError(imageContext, ctrl, sprite, errorMessage)
	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	if imageContext.sprite == sprite then
		imageContext.sprite = nil
	end

	HomelandReportUtils.destroyCapturedSprite(sprite)
	HomelandReportUtils.restoreHomeCampCaptureState(imageContext)
	HomelandReportUtils.setSubmitInteractable(ctrl, true)
	logger:error(errorMessage)

	if ctrl and ctrl:checkUIOpen() then
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))
	end
end

function HomelandReportUtils.onHomeCampReportImageUploaded(reportInfos, imageContext, ctrl, submitToken, sprite, key, success, imgUrl)
	HomelandReportUtils.destroyCapturedSprite(sprite)

	if imageContext.sprite == sprite then
		imageContext.sprite = nil
	end

	if imageContext.submitToken ~= submitToken then
		return
	end

	imageContext.submitToken = nil
	imageContext.isSubmitting = false

	if not ctrl or not ctrl:checkUIOpen() then
		HomelandReportUtils.restoreHomeCampCaptureState(imageContext)

		return
	end

	if not success or string.isNilOrEmpty(imgUrl) then
		HomelandReportUtils.restoreHomeCampCaptureState(imageContext)
		HomelandReportUtils.setSubmitInteractable(ctrl, true)
		logger:error("home camp report screenshot upload failed, key=%s", tostring(key))
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

		return
	end

	if not HomelandReportUtils.isHomeCampReportContextValid(imageContext, reportInfos) then
		HomelandReportUtils.restoreHomeCampCaptureState(imageContext)
		HomelandReportUtils.setSubmitInteractable(ctrl, true)
		logger:error("home camp report submit failed: report target changed after screenshot upload")
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))

		return
	end

	HomelandReportUtils.submitHomeCampReports(reportInfos, imgUrl)
	ctrl:closeImmediately()
	HomelandReportUtils.restoreHomeCampCaptureState(imageContext)
	pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))
end

function HomelandReportUtils.onHomeCampReportScreenCaptured(reportInfos, imageContext, ctrl, submitToken, sprite)
	if not HomelandReportUtils.finishHomeCampCapture(imageContext, submitToken) then
		HomelandReportUtils.destroyCapturedSprite(sprite)

		return
	end

	if not sprite or IsNil(sprite) then
		HomelandReportUtils.finishHomeCampSubmitWithError(imageContext, ctrl, sprite, "home camp report screenshot failed")

		return
	end

	imageContext.sprite = sprite

	if not ctrl or not ctrl:checkUIOpen() or not HomelandReportUtils.isHomeCampReportContextValid(imageContext, reportInfos) then
		HomelandReportUtils.finishHomeCampSubmitWithError(imageContext, ctrl, sprite, "home camp report submit failed: report target changed during screenshot")

		return
	end

	if not pg.me or not pg.me.addPhotoImgSprite then
		HomelandReportUtils.finishHomeCampSubmitWithError(imageContext, ctrl, sprite, "home camp report screenshot upload is unavailable")

		return
	end

	pg.me:addPhotoImgSprite(sprite, function(key, success, imgUrl)
		HomelandReportUtils.onHomeCampReportImageUploaded(reportInfos, imageContext, ctrl, submitToken, sprite, key, success, imgUrl)
	end)
end

function HomelandReportUtils.submitHomeCampReport(reportInfos, imageContext, ctrl)
	if not imageContext or imageContext.isSubmitting then
		return
	end

	if not HomelandReportUtils.isHomeCampReportContextValid(imageContext, reportInfos) then
		logger:error("home camp report submit failed: report target is invalid")
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))

		return
	end

	local reportType = reportInfos[1] and tonumber(reportInfos[1].reportType)

	if reportType == Const.ACCUSATION_TYPE.PLAYER_HOME_NAME then
		HomelandReportUtils.submitHomeCampReports(reportInfos)
		ctrl:closeImmediately()
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))

		return
	end

	local cameraMgr = pg.global and pg.global.mobileCameraMgr

	if not cameraMgr or not pg.global.ui or not pg.game or not pg.game.input then
		logger:error("home camp report screenshot failed: capture service is unavailable")
		pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

		return
	end

	local submitToken = {}

	imageContext.submitToken = submitToken
	imageContext.isSubmitting = true
	imageContext.isCaptureStateHidden = true

	HomelandReportUtils.setSubmitInteractable(ctrl, false)

	HomelandReportUtils._activeHomeCampCaptureToken = submitToken

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.HOME_CAMP_REPORT, {}, HomelandReportUtils.SUBMIT_UI_HIDE_TIMEOUT)
	pg.game.input:setEnabledViewCtrl(false, UIConst.UI_HIDE_KEY.HOME_CAMP_REPORT)

	HomelandReportUtils._homeCampCaptureTimer = TimerManager.addTimer(HomelandReportUtils.CAPTURE_TIMEOUT, function()
		HomelandReportUtils.onHomeCampCaptureTimeout(imageContext, ctrl, submitToken)
	end)

	cameraMgr:CaptureScreenDelaySaveCopy(function(sprite)
		HomelandReportUtils.onHomeCampReportScreenCaptured(reportInfos, imageContext, ctrl, submitToken, sprite)
	end)
end

function HomelandReportUtils.onHomeCampReportPanelOpenFinished()
	HomelandReportUtils._isOpeningHomeCampReportPanel = false
end

function HomelandReportUtils.openHomeCampReportPanel(context, isGmPreview)
	HomelandReportUtils._isOpeningHomeCampReportPanel = true

	pg.global.ui:open(UIConst.UI_ID_HOME_CAMP_REPORT, {
		reportImageContext = context,
		reportSubmitHandler = HomelandReportUtils.submitHomeCampReport,
		reportCancelHandler = HomelandReportUtils.cancelHomeCampReportSubmit,
		isGmPreview = isGmPreview == true
	}, function()
		HomelandReportUtils.onHomeCampReportPanelOpenFinished()
	end, function()
		HomelandReportUtils.onHomeCampReportPanelOpenFinished()
	end)
end

function HomelandReportUtils.openHomeCampReport(isGmPreview)
	if HomelandReportUtils._isOpeningHomeCampReportPanel or pg.global.ui:checkUIOpen(UIConst.UI_ID_HOME_CAMP_REPORT) then
		return
	end

	local context = HomelandReportUtils.getCurrentHomeCampContext()

	if not context then
		return
	end

	local playerUids = HomelandReportUtils.getHomeCampReportablePlayerUids(isGmPreview)

	if #playerUids == 0 then
		if HomelandReportUtils.isHomeCampInfoReady() then
			HomelandReportUtils.showNoHomeCampReportablePlayerNotice()
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))
		end

		return
	end

	HomelandReportUtils.openHomeCampReportPanel(context, isGmPreview)
end

return HomelandReportUtils
