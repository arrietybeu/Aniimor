-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareView\\MarkShareViewCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local SysNoticeData = require("Data.sys_notice_data")
local GuideCourseData = require("Data.guide_course_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local AbilityParamData = require("Data.ability_param_data")
local Utils = require("Common.Utils.Utils")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local SkillTagData = require("Data.skill_tag_data")
local PetConfigData = require("Data.pet_config_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local ElementPropData = require("Data.element_prop_data")
local PlayerSkillReverseData = require("Data.player_skill_reverse_data")
local PlayerSkillData = require("Data.player_skill_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local MarkShareViewCtrl = Class.LightClass("MarkShareViewCtrl", UICtrl)

MarkShareViewCtrl.messages = {
	[MessageName.ON_INFO_STAMP_BE_LIKED] = {
		"onInfoStampBeLiked",
		true
	},
	[MessageName.ON_PLAYER_HURT] = {
		"onPlayerHurt",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function MarkShareViewCtrl:applyMarkShareImage(requestKey, imageWidget, containerWidget, onVisible)
	local _h = MarkShareViewCtrl._platformHooks

	if _h and _h.applyMarkShareImage then
		return _h.applyMarkShareImage(self, requestKey, imageWidget, containerWidget, onVisible)
	end

	if type(onVisible) == "function" then
		onVisible(true)
	end

	return true
end

function MarkShareViewCtrl:applyMarkShareText(requestKey, rawText, onResolved)
	local _h = MarkShareViewCtrl._platformHooks

	if _h and _h.applyMarkShareText then
		return _h.applyMarkShareText(self, requestKey, rawText, onResolved)
	end

	local normalizedText = rawText or ""

	if type(onResolved) == "function" then
		onResolved(normalizedText)
	end

	return normalizedText
end

function MarkShareViewCtrl:applyMarkShareName(requestKey, rawText, onResolved)
	local _h = MarkShareViewCtrl._platformHooks

	if _h and _h.applyMarkShareName then
		return _h.applyMarkShareName(self, requestKey, rawText, onResolved)
	end

	local normalizedText = rawText or ""

	if type(onResolved) == "function" then
		onResolved(normalizedText)
	end

	return normalizedText
end

function MarkShareViewCtrl:onCreate(info)
	self.openToken = {}
	self.avatarCleanupStarted = false
	self.closing = false
	self.markShareSystem = pg.game.markShare
	self.infoStampInfoTrans = info.infoStampInfoTrans
	self.state = nil

	UICtrl.onCreate(self, info)

	self.infoStampId = info.infoStampId

	pg.game.markShare:recordInfoStampTrans(info.infoStampInfoTrans)

	self.curPage = nil

	self:Init()
end

function MarkShareViewCtrl:onOpen(info)
	self.openToken = {}
	self.avatarCleanupStarted = false
	self.closing = false
end

function MarkShareViewCtrl:onShow()
	return
end

function MarkShareViewCtrl:onHide()
	return
end

function MarkShareViewCtrl:destroy()
	if self.avatarCleanupStarted then
		return
	end

	self.avatarCleanupStarted = true

	local markShare = self.markShareSystem
	local openToken = self.openToken

	if not pg.game or pg.game.markShare ~= markShare then
		return
	end

	pg.game.input.lockCameraZoom = false
	self.curEnt = nil

	if not self.infoStampInfoTrans then
		self:restoreAfterAvatarCleanup(openToken, markShare)

		return
	end

	pg.game.interaction.pause = false

	if markShare.bubbleHelper then
		markShare.bubbleHelper:enableBubble(false)
	end

	if self.state == -1 or not markShare.avatarHelper then
		markShare:clearAvatarEntity()
		self:restoreAfterAvatarCleanup(openToken, markShare)
	else
		markShare:clearAvatarEntity(function()
			self:restoreAfterAvatarCleanup(openToken, markShare)
		end)
	end
end

function MarkShareViewCtrl:restoreAfterAvatarCleanup(openToken, markShare)
	if self.openToken ~= openToken or not pg.game or pg.game.markShare ~= markShare then
		return
	end

	if markShare.infoStampInfoTrans and markShare.infoStampInfoTrans ~= self.infoStampInfoTrans then
		return
	end

	self:enableUI(true)
	markShare:dealInfoStampVisible(true)
end

function MarkShareViewCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.keyBoardContent = self.view.keyEscHotKeyContent
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnClose1UButton.luaClick()
		self:closePanel()
	end

	function self.view.btnClose2UButton.luaClick()
		self:closePanel()
	end

	function self.view.btnClose3UButton.luaClick()
		self:closePanel()
	end

	self.view.presetLikeBtn.enabledIntervalClick = true
	self.view.presetLikeBtn.intervalClickDuration = 3
	self.view.otherPlayerLikeBtn.enabledIntervalClick = true
	self.view.otherPlayerLikeBtn.intervalClickDuration = 3

	self.view.likeKeyHotKeyContent:SetHotKeyPaths("Hud/LikeInfoStamp")
	self.view.backKeyHotKeyContent:SetHotKeyPaths("Common/Cancel")
	self.view.otherLikedBtnHotKeyContent:SetHotKeyPaths("Hud/LikeInfoStamp")
	self.view.otherBackBtnHotKeyContent:SetHotKeyPaths("Common/Cancel")
end

function MarkShareViewCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function MarkShareViewCtrl:Init()
	local infoStampData = pg.game.markShare.aroundMarkInfoStampGroup[self.infoStampId]
	local isSys = infoStampData.type == Const.MediaMarkerType.SystemText

	if pg.game.markShare.infoStampInfoTrans then
		pg.game.interaction.pause = true

		if pg.game.markShare:inMyOwnKey(self.infoStampId) then
			local parsedInfo = pg.game.markShare:parseInfoStamp(false, self.infoStampId)

			self:renderMainPlayerPanel(parsedInfo)
			ClientTextUtils.setText(self.view.txtIDUSDFText, pg.me.uid)
		elseif infoStampData.type == Const.MediaMarkerType.SystemText then
			local parsedInfo = pg.game.markShare:parseInfoStamp(true, self.infoStampId)

			self:renderPresetOrOtherPlayerPanel(parsedInfo, true)
			ClientTextUtils.setText(self.view.txtIDUSDFText, "")
		else
			local parsedInfo = pg.game.markShare:parseInfoStamp(false, self.infoStampId)

			self:renderPresetOrOtherPlayerPanel(parsedInfo, false)
			ClientTextUtils.setText(self.view.txtIDUSDFText, self.model:getOtherPlayerUId(self.infoStampId))
		end
	else
		local parsedInfo = pg.game.markShare:parseInfoStamp(false, self.infoStampId)

		self:renderMainPlayerPanel(parsedInfo)
		ClientTextUtils.setText(self.view.txtIDUSDFText, pg.me.uid)
	end

	self:_renderExpireInfo(infoStampData, isSys)
	self:enableUI(false)
	pg.game.markShare:dealInfoStampVisible(false)

	local _h = MarkShareViewCtrl._platformHooks

	if _h and _h.initCloseButtons then
		_h.initCloseButtons(self)
	end
end

function MarkShareViewCtrl:_renderExpireInfo(data, isSys)
	if isSys or data.isPermanent == 1 then
		self.view.root:TryChangePage("Time", 0)

		return
	end

	local maxDayCount = SysConfigData.MARKSHARE_ENCOURAGE_DURING_MAX or 10
	local expireTs = (data.createTs or 0) + maxDayCount * Const.SECONDS_ONE_DAY
	local remainSeconds = expireTs - Time.secondCache

	if remainSeconds <= 0 then
		self.view.root:TryChangePage("Time", 2)
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("MARK_SHARE_EXPIRED"))

		return
	end

	self.view.root:TryChangePage("Time", 1)

	local remainDays = math.ceil(remainSeconds / Const.SECONDS_ONE_DAY)

	ClientTextUtils.setText(self.view.txtNameUSDFText, string.format(pg.getGameString("MARK_SHARE_EXPIRE_DAYS"), remainDays))
end

function MarkShareViewCtrl:enableUI(enable)
	local hudV2 = pg.global.ui.hudV2

	if enable then
		if hudV2 then
			hudV2:hideByInfoStamp(false)
		end

		pg.global.ui:show(UIConst.UI_ID_INTERACT)
	else
		if hudV2 then
			hudV2:hideByInfoStamp(true)
		end

		pg.global.ui:hide(UIConst.UI_ID_INTERACT)
	end
end

function MarkShareViewCtrl:loadAvatar(avatarType, optionId, rot)
	pg.game.markShare:createAvatarReplication(avatarType, optionId, function(ent)
		self.curEnt = ent

		local pos = pg.game.markShare.infoStampInfoTrans.position

		self.curEnt.eModel:SetTransformPosition(pos.x, pos.y, pos.z)
		EModelUtils.setAgentRotation(self.curEnt, rot, true)

		self.state = self.model:getContentAnimationData(self.infoStampId)

		pg.game.markShare.avatarHelper:animationTool(self.curEnt, self.state, true)
		pg.game.markShare.bubbleHelper:setPos(Vector3(self.curEnt.eModel:GetTransformPosition()) + self.curEnt.eModel.transform.up * SysConfigData.INFO_STAMP_BUBBLE_HEIGHT, true)
		pg.game.markShare.bubbleHelper:changeType(false)

		if self.hideEnt then
			self.curEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, false)
		end
	end, function()
		return
	end)
end

function MarkShareViewCtrl:getMarkShareReportText(parsedInfo)
	local reportText = tostring(parsedInfo.txtClips or "")

	if not string.isNilOrEmpty(parsedInfo.txtCustom) then
		reportText = string.format("%s\n%s", reportText, parsedInfo.txtCustom)
	end

	return reportText
end

function MarkShareViewCtrl:getMarkShareReportImageUrl(imgKey, fallbackImgUrl, callback)
	if string.isNilOrEmpty(imgKey) then
		callback(tostring(fallbackImgUrl or ""))

		return
	end

	ServiceUtils.callService("KvService", "getPictureUrl", {
		imgKey
	}, function(retStatus, response)
		local imgUrl = tostring(fallbackImgUrl or "")

		if retStatus and retStatus.status and response and type(response.value) == "string" then
			local rawUrl = string.sub(response.value, 9)

			if not string.isNilOrEmpty(rawUrl) then
				imgUrl = "https://" .. rawUrl
			end
		end

		callback(imgUrl)
	end, {
		hint = imgKey
	})
end

function MarkShareViewCtrl:submitMarkShareReport(reportInfo, imageContext, accusationCtrl)
	if imageContext and imageContext.isSubmitting then
		return
	end

	if imageContext then
		imageContext.isSubmitting = true
	end

	local imgKey = tostring(imageContext and imageContext.imgKey or "")
	local fallbackImgUrl = tostring(imageContext and imageContext.imgUrl or "")

	reportInfo.imgKey = imgKey

	self:getMarkShareReportImageUrl(imgKey, fallbackImgUrl, function(imgUrl)
		if imageContext then
			imageContext.isSubmitting = false
		end

		reportInfo.imgUrl = tostring(imgUrl or "")

		pg.me:reportChat(reportInfo)
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))

		if accusationCtrl then
			accusationCtrl:dismiss()
		end
	end)
end

function MarkShareViewCtrl:openMarkShareReport(parsedInfo)
	local markerInfo = pg.game.markShare.aroundMarkInfoStampGroup[self.infoStampId]

	if not markerInfo then
		return
	end

	local targetUid = tostring(markerInfo.uid or "")

	if string.isNilOrEmpty(targetUid) then
		return
	end

	local markerContent = markerInfo.content or {}
	local photoTemplate = markerContent.photoTemplate or {}
	local imgKey = tostring(photoTemplate.imgKey or "")
	local imgUrl = tostring(markerContent.imgUrl or "")
	local playerName = tostring(parsedInfo.playerName or "")

	pg.global.ui:open(UIConst.UI_ID_ACCUSATION, {
		playerName = playerName,
		playerId = targetUid,
		reportText = self:getMarkShareReportText(parsedInfo),
		reportImageContext = {
			imgKey = imgKey,
			imgUrl = imgUrl
		},
		reportSubmitHandler = function(reportInfo, imageContext, accusationCtrl)
			self:submitMarkShareReport(reportInfo, imageContext, accusationCtrl)
		end,
		reportInfo = {
			detailType = "media_marker",
			uid = targetUid,
			name = playerName,
			character = playerName,
			msgId = tostring(self.infoStampId),
			markerId = tostring(self.infoStampId),
			imgKey = imgKey,
			imgUrl = imgUrl
		}
	})
end

function MarkShareViewCtrl:renderPresetOrOtherPlayerPanel(parsedInfo, isSys)
	self.view.root:TryChangePage("View", isSys and 2 or 1)
	self:_setText_txtTitle1USDFText(isSys, parsedInfo.playerName)

	self.curPage = isSys and 2 or 1

	if isSys then
		self:loadAvatar(pg.game.markShare.AVATAR_TYPE.Preset, self.model:getPresetNpcId(self.infoStampId), parsedInfo.rot)
	else
		self:loadAvatar(pg.game.markShare.AVATAR_TYPE.OtherPlayer, self.model:getOtherPlayerUId(self.infoStampId), parsedInfo.rot)
	end

	if not parsedInfo.bubbleType then
		pg.game.markShare.bubbleHelper:enableBubble(false)
	else
		pg.game.markShare.bubbleHelper:changeImageUrl(parsedInfo.bubbleType)
		pg.game.markShare.bubbleHelper:changeViewText(parsedInfo.txtCustom or "")
		pg.game.markShare.bubbleHelper:enableBubble(true, false)
	end

	if isSys then
		ClientTextUtils.setText(self.view.presetLikeNum, parsedInfo.likes)

		if pg.game.markShare:isInfoStampBeLikedOrDislikedByMe(self.infoStampId) then
			self.view.root:TryChangePage("Liked", 1)

			self.view.btnLikedKeyBindingPro2.isVirtual = true
		else
			self.view.root:TryChangePage("Liked", 0)

			self.view.btnLikedKeyBindingPro2.isVirtual = false

			function self.view.presetLikeBtn.luaClick()
				local pos2 = self.model:getPresetMarkPos2(self.infoStampId)

				if not pos2 then
					return
				end

				pg.me:likeSysMediaMarker(self.infoStampId, pos2)
			end
		end

		self:dealSysPanel(parsedInfo)
	else
		ClientTextUtils.setText(self.view.otherPlayerLikeNum, parsedInfo.likes)

		function self.view.btnReportUButton.luaClick()
			self:openMarkShareReport(parsedInfo)
		end

		ClientTextUtils.setText(self.view.textReportUSDFText, pg.getGameString("ACCUSATION_BTN"))

		if pg.game.markShare:isInfoStampBeLikedOrDislikedByMe(self.infoStampId) then
			self.view.root:TryChangePage("Liked", 1)

			self.view.btnLikedKeyBindingPro1.isVirtual = true
		else
			self.view.root:TryChangePage("Liked", 0)

			self.view.btnLikedKeyBindingPro1.isVirtual = false

			function self.view.otherPlayerLikeBtn.luaClick()
				pg.me:likeMediaMarker(self.infoStampId, pg.game.markShare.aroundMarkInfoStampGroup[self.infoStampId].posIndex)
			end
		end

		self:dealNonSysPanel(parsedInfo)
	end
end

function MarkShareViewCtrl:renderMainPlayerPanel(parsedInfo)
	self.view.root:TryChangePage("View", 0)
	ClientTextUtils.setText(self.view.txtTitleUSDFText, parsedInfo.playerName)

	self.curPage = 0

	if pg.game.markShare.infoStampInfoTrans then
		self:loadAvatar(pg.game.markShare.AVATAR_TYPE.Self, nil, parsedInfo.rot)

		if not parsedInfo.bubbleType then
			pg.game.markShare.bubbleHelper:enableBubble(false)
		else
			pg.game.markShare.bubbleHelper:changeImageUrl(parsedInfo.bubbleType)
			pg.game.markShare.bubbleHelper:changeViewText(parsedInfo.txtCustom or "")
			pg.game.markShare.bubbleHelper:enableBubble(true, false)
		end
	end

	ClientTextUtils.setText(self.view.selfLikeNum, parsedInfo.likes)

	function self.view.btnPositionUButton.luaClick()
		if pg.game.map:checkValidScene(pg.game.map:convertSceneId(pg.me.space.sceneId)) == true then
			pg.game.map:openMapAndLocateMark(pg.game.markShare:getSelfMarkSceneId(self.infoStampId), Const.MAP_MARK_SHARE, self.infoStampId, nil, 1)
			self:closePanel()
		else
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[2126].text))
		end
	end

	function self.view.btnDeleteUButton.luaClick()
		if parsedInfo.photoTemplate and parsedInfo.photoTemplate.imgKey then
			ClientUtils.deletePicture(parsedInfo.photoTemplate.imgKey)
		end

		pg.me:removeMediaMarker(self.infoStampId)
		self:closePanel()
	end

	self:dealNonSysPanel(parsedInfo)
end

function MarkShareViewCtrl:dealSysPanel(parsedInfo)
	function self.view.listContentUList.luaOnPointerEnter()
		pg.game.input.lockCameraZoom = true
	end

	function self.view.listContentUList.luaOnPointerExit()
		pg.game.input.lockCameraZoom = false
	end

	function self.view.listContentUList.luaRenderItem(button, index, data)
		button.gameObject:SetActiveEx(true)

		if data.tIndex == 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")

			self:applyMarkShareText(txtContentUSDFText, data.txtClips, function(displayText)
				if UIUtils.IsNull(txtContentUSDFText) then
					return
				end

				ClientTextUtils.setText(txtContentUSDFText, displayText)
			end)
			button:TryChangePage("Type", 2)
		elseif data.tIndex == 1 then
			local objectReference = button:GetComponent("ObjectReference")
			local btnPlayUButton = objectReference:GetRefValue("btnPlayUButton")
			local imageUImage = objectReference:GetRefValue("imageUImage")
			local buttonUButton = objectReference:GetRefValue("buttonUButton")

			if data.movie then
				button:TryChangePage("isImage", 0)

				function btnPlayUButton.luaClick()
					pg.global.ui:open(UIConst.UI_ID_SIMPLE_VIEW, {
						isImage = false,
						videoUrl = data.movie
					})
				end
			elseif data.picture then
				button:TryChangePage("isImage", 1)
				self:applyMarkShareImage(button, imageUImage, button, function(isVisible)
					button.gameObject:SetActiveEx(isVisible)

					if isVisible then
						imageUImage.url = data.picture

						function buttonUButton.luaClick()
							pg.global.ui:open(UIConst.UI_ID_SIMPLE_VIEW, {
								isImage = true,
								imageUrl = data.picture
							})
						end
					else
						imageUImage.url = ""
						buttonUButton.luaClick = nil
					end
				end)
			end
		elseif data.tIndex == 2 then
			local objectReference = button:GetComponent("ObjectReference")
			local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
			local btnPlayUButton = objectReference:GetRefValue("btnPlayUButton")
			local root = objectReference:GetRefValue("root")

			root:TryChangePage("State", 0)

			local duration = pg.game.audio.mgrInst.soundFactory:GetDuration(data.voice)

			countDownUCountDown:Reset(duration, duration)

			function btnPlayUButton.luaClick()
				local _, page = root:TryGetCurrentPage("State")

				if page == 0 then
					pg.game.audio:playEvent(data.voice)
					root:TryChangePage("State", 1)
					countDownUCountDown:Play(duration)
				else
					pg.game.audio:stopEvent(data.voice)
					root:TryChangePage("State", 0)
					countDownUCountDown:Reset(duration, duration)
				end
			end

			function countDownUCountDown.luaFinished()
				pg.game.audio:stopEvent(data.voice)
				root:TryChangePage("State", 0)
				countDownUCountDown:Reset(duration, duration)
			end
		elseif data.tIndex == 3 then
			local objectReference = button:GetComponent("ObjectReference")
			local btnReceiveUButton = objectReference:GetRefValue("btnReceiveUButton")
			local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

			LuaUIUtils.renderRewardItem(rewardItemUButton, {
				id = data.reward[1],
				num = data.reward[2]
			})

			local propData = LuaUIUtils.getItemClientInfoById(data.reward[1])

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(propData.name))
			ClientTextUtils.setText(txtNumUSDFText, string.format("x%s", data.reward[2]))
		elseif data.tIndex == 4 then
			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local btnUseUButton = objectReference:GetRefValue("btnUseUButton")
			local pData = PetData[data.pet[1]] or {}
			local iconName = pData.iconName
			local name = pData.name

			iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON), function()
				return
			end)
			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name))
		elseif data.tIndex == 5 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
			local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
			local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
			local title = pg.getLocalizationText(GuideCourseData[data.course].title)
			local typeName = pg.getLocalizationText(GuideCourseData[data.course].typeName)

			if data.courseName then
				title = data.courseName
			end

			if data.courseDesc then
				typeName = data.courseDesc
			end

			ClientTextUtils.setText(txtNameUSDFText, title)
			ClientTextUtils.setText(txtDetailsUSDFText, typeName)
			keyHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.InfoStampGoCourse)

			function btnGoUButton.luaClick()
				local courseConfig = GuideCourseData[data.course]

				if courseConfig == nil then
					return
				end

				local isCourseUnlock = pg.me.unlockCourseIds ~= nil and pg.me.unlockCourseIds[data.course] == true

				if not isCourseUnlock then
					pg.me:unlockCourse(data.course)
				end

				pg.global.ui:open(UIConst.UI_ID_QUEST_COURSE, {
					fromMarkShare = true,
					courseId = data.course,
					forceUnlockCourseId = not isCourseUnlock and data.course or nil
				})
				self:closePanel()
			end

			local goBind = KeyBindingPro.GetOrAddKeyBindingByName(button.gameObject, "goBind")

			goBind.isVirtual = true
			goBind.priority = -1
			goBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.InfoStampGoCourse

			function goBind.luaTrigger(inputInfo)
				if inputInfo.phase == "Performed" then
					btnGoUButton:OnClickSimulate()
				end
			end
		elseif data.tIndex == 6 then
			local objectReference = button:GetComponent("ObjectReference")
			local listUList = objectReference:GetRefValue("listUList")

			function listUList.luaRenderItem(b, i, d)
				self:renderPanelTipList(b, d)
			end

			listUList:SetList(Utils.deepCopyTable(data.clueList))
		end
	end

	self.view.listContentUList:SetList(parsedInfo.extraInfos)
end

function MarkShareViewCtrl:renderPanelTipList(button, data)
	button:TryChangePage("InSence", 0)

	local objectReference = button:GetComponent("ObjectReference")
	local elementTransform = objectReference:GetRefValue("elementTransform")
	local iconTransform = objectReference:GetRefValue("iconTransform")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local skillPop = objectReference:GetRefValue("skillPop")
	local elementAndPetPop = objectReference:GetRefValue("elementAndPetPop")
	local itemPop = objectReference:GetRefValue("itemPop")
	local smallPop = objectReference:GetRefValue("smallPop")

	iconTransform.gameObject:SetActiveEx(true)
	elementTransform.gameObject:SetActiveEx(false)

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	if data[1] == 1 then
		button.PopupTool.popupTemplate = elementAndPetPop

		self:renderPanelTipElementAndPetPopup(button, data[2], data[1])
		iconTransform.gameObject:SetActiveEx(false)
		elementTransform.gameObject:SetActiveEx(true)
		LuaUIUtils.setElementButtonNew(elementUButton, data[2] or 0, false)
	else
		local defaultVal, iconName

		if data[1] == 2 then
			button.PopupTool.popupTemplate = elementAndPetPop

			self:renderPanelTipElementAndPetPopup(button, data[2], data[1])

			defaultVal = "10011"
			iconName = PetData[data[2]] and PetData[data[2]].iconName or defaultVal
			iconName = iconName or defaultVal
			iconUImage.url = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)
		elseif data[1] == 3 or data[1] == 4 then
			button.PopupTool.popupTemplate = skillPop

			self:renderPanelTipSkillPopup(button, data[2], data[1])

			defaultVal = "$UI_SkillIcon_Avatar_9000001.png"
			iconName = AbilityParamData[data[2]] and AbilityParamData[data[2]].icon or defaultVal
			iconName = iconName or defaultVal
			iconUImage.url = iconName
		elseif data[1] == 5 then
			button.PopupTool.popupTemplate = itemPop
			button.enabledTooltip = false

			self:renderPanelTipItemPopup(button, data[2])

			defaultVal = "$ui_item_1000.png"
			iconName = ItemData[data[2]] and ItemData[data[2]].icon or defaultVal
			iconName = iconName or defaultVal
			iconUImage.url = iconName
		elseif data[1] == 6 or data[1] == 7 or data[1] == 8 then
			button.PopupTool.popupTemplate = smallPop

			self:renderPanelTipSmallPopup(button, data[2], data[1])

			iconUImage.url = AddressDataConst[string.format("UI_MARK_SHARE_CLUE_%s_%s", data[1], data[2])]
		end
	end
end

function MarkShareViewCtrl:renderPanelTipSkillPopup(button, key, idx)
	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtName = objectReference:GetRefValue("txtName")
		local listTagUList = objectReference:GetRefValue("listTagUList")
		local elementUButton = objectReference:GetRefValue("elementUButton")
		local damageTypeUButton = objectReference:GetRefValue("damageTypeUButton")
		local cost = objectReference:GetRefValue("cost")
		local cd = objectReference:GetRefValue("cd")
		local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")
		local txtShortDetailsUSDFText = objectReference:GetRefValue("txtShortDetailsUSDFText")
		local txtLongDetailsUSDFText = objectReference:GetRefValue("txtLongDetailsUSDFText")
		local videoPlayerUVideoPlayerAVPro = objectReference:GetRefValue("videoPlayerUVideoPlayerAVPro")

		cmp:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(key)))
		ClientTextUtils.setText(txtName, pg.getLocalizationText(AbilityParamData[key].name))

		iconSkillUImage.url = LuaUIUtils.getSkillIcon(AbilityParamData[key].icon)

		local skillDesc = LuaUIUtils.getSkillDesc(AbilityParamData[key])

		if string.isNilOrEmpty(skillDesc) then
			local index = PlayerSkillReverseData[key]

			if index then
				skillDesc = PlayerSkillData[index] and pg.getLocalizationText(PlayerSkillData[index][1].desc) or nil
			end
		end

		if string.isNilOrEmpty(skillDesc) then
			skillDesc = " "
		end

		local index = PlayerSkillReverseData[key]

		if index and PlayerSkillData[index] then
			local video
			local configData = pg.me:getConfigData()
			local gender = pg.me.gender or configData.gender

			if gender == 1 then
				video = PlayerSkillData[index][1].videoM
			else
				video = PlayerSkillData[index][1].videoF
			end

			if string.isNilOrEmpty(video) then
				video = PlayerSkillData[index][1].video
			end

			if not string.isNilOrEmpty(video) then
				cmp:TryChangePage("video", 1)

				videoPlayerUVideoPlayerAVPro.resID = video
			end
		end

		ClientTextUtils.setText(txtLongDetailsUSDFText.content, skillDesc)
		ClientTextUtils.setText(txtShortDetailsUSDFText, skillDesc)

		if idx == 3 then
			cmp:TryChangePage("SkillType", 1)
		else
			cmp:TryChangePage("SkillType", 0)
			LuaUIUtils.setElementButtonNew(elementUButton, AbilityParamData[key].elementType)
			ClientTextUtils.setText(cost, AbilityParamData[key].epCost)
			ClientTextUtils.setText(cd, AbilityParamData[key].power)
			damageTypeUButton:TryChangePage("Type", AbilityParamData[key].attackType)

			function listTagUList.luaRenderItem(b, _, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local txtNameUText = objectReference1:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
			end

			local tagList = {}

			if AbilityParamData[key].tags then
				for _, tagId in pairs(AbilityParamData[key].tags) do
					tagList[#tagList + 1] = {
						tagName = SkillTagData[tagId].tagName
					}
				end
			end

			listTagUList:SetList(tagList)
		end
	end
end

function MarkShareViewCtrl:renderPanelTipElementAndPetPopup(button, key, idx)
	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconPetUImage = objectReference:GetRefValue("iconPetUImage")
		local listTagUList = objectReference:GetRefValue("listTagUList")
		local txtOrientationUSDFText = objectReference:GetRefValue("txtOrientationUSDFText")
		local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")
		local elementUButton = objectReference:GetRefValue("elementUButton")

		if idx == 1 then
			cmp:TryChangePage("Type", 1)
			LuaUIUtils.setElementButtonNew(elementUButton, key)

			local nameCh = ElementPropData[key] and ElementPropData[key].name_ch

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(nameCh))

			if not ElementPropData[key] then
				ClientTextUtils.setText(txtContentUSDFText, "EMPTY")
			elseif ElementPropData[key].desc then
				ClientTextUtils.setText(txtContentUSDFText, pg.getLocalizationText(ElementPropData[key].desc))
			else
				ClientTextUtils.setText(txtContentUSDFText, "EMPTY")
			end
		else
			cmp:TryChangePage("Type", 0)

			local petType = PetData[key].functionId

			ClientTextUtils.setText(txtOrientationUSDFText, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(PetData[key].name))
			ClientTextUtils.setText(txtContentUSDFText, PetResearchContentData[key] ~= nil and pg.getLocalizationText(PetResearchContentData[key].desc) or "EMPTY")

			iconPetUImage.url = LuaUIUtils.getPetIcon(PetData[key].iconName, LuaUIUtils.PET_ICON)

			local _, elementNames = LuaUIUtils.getElementInfo(PetData[key].elementType)

			function listTagUList.luaRenderItem(button1, _, data1)
				LuaUIUtils.setElementButtonNew(button1, data1.element)
			end

			listTagUList:SetList(elementNames)
		end
	end
end

function MarkShareViewCtrl:renderPanelTipItemPopup(button, key)
	function button.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = key,
			targetRect = button,
			extra = {
				openFun = function()
					button:TryChangePage("Selected", 1)
				end,
				closeFun = function()
					button:TryChangePage("Selected", 0)
				end
			}
		})
	end
end

function MarkShareViewCtrl:renderPanelTipSmallPopup(button, key, idx)
	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(string.format("MARK_SHARE_CLUE_%s_%s", idx, key)))
	end
end

function MarkShareViewCtrl:dealNonSysPanel(parsedInfo)
	local _h = MarkShareViewCtrl._platformHooks

	if _h and _h.initOnlineID then
		_h.initOnlineID(self, parsedInfo)
	end

	self:applyMarkShareText("ugcMarkShareConcatText", parsedInfo.txtClips, function(displayText)
		if self.view and not UIUtils.IsNull(self.view.concatText) then
			ClientTextUtils.setText(self.view.concatText, displayText)
		end
	end)
	self:renderPhotoTemplate(parsedInfo)
end

function MarkShareViewCtrl:renderPhotoTemplate(parsedInfo)
	local photoTemplate = parsedInfo.photoTemplate
	local havePhoto = photoTemplate ~= nil

	self.view.templateUWidget:SetActive(havePhoto)

	if havePhoto then
		local objectReference = self.view.templateUWidget:GetComponent("ObjectReference")
		local btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")
		local btnUseUButton = objectReference:GetRefValue("btnUseUButton")
		local photoUImage = objectReference:GetRefValue("photoUImage")

		function btnDetailUButton.luaClick()
			pg.global.ui.albumPhoto:open({
				photoInfo = {
					onlyShow = true,
					sprite = photoUImage.sprite,
					timeStamp = photoTemplate.time
				}
			})
		end

		function btnUseUButton.luaClick()
			local photo = pg.global.ui.photo

			photo:open({
				photoMode = photo.ModeType.NORMAL_MODE,
				preset = photoTemplate.preset
			}, function()
				pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_TEMPLATE_USED"))

				if self.curEnt then
					self.curEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, false)
				else
					self.hideEnt = true
				end
			end, function()
				if self.curEnt then
					self.curEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, true)
				end
			end)
		end

		local isUGCImageVisible = true

		pg.global.ui.photo.model:queryPresetImg(photoTemplate.imgKey, function(sprite, id)
			if isUGCImageVisible then
				photoUImage.sprite = sprite
			end
		end)
		self:applyMarkShareImage("ugcMarkSharePhotoTemplate", photoUImage, self.view.templateUWidget, function(isVisible)
			isUGCImageVisible = isVisible == true

			self.view.templateUWidget:SetActive(havePhoto and isVisible)

			if not isVisible then
				photoUImage.sprite = nil
			end
		end)
	end
end

function MarkShareViewCtrl:setLikedState()
	if self.curPage == 1 then
		self.view.root:TryChangePage("Liked", 1)

		self.view.btnLikedKeyBindingPro1.isVirtual = true
	elseif self.curPage == 2 then
		self.view.root:TryChangePage("Liked", 1)

		self.view.btnLikedKeyBindingPro2.isVirtual = true
	end
end

function MarkShareViewCtrl:onInfoStampBeLiked(info)
	if not info or info.markerId ~= self.infoStampId then
		return
	end

	self:setLikedState()

	if info.onlyChangeLikeState then
		return
	end

	self.view.particleUWidget.gameObject:SetActiveEx(true)
	self.view.particle1UWidget.gameObject:SetActiveEx(true)

	if self.curPage == 1 then
		ClientTextUtils.setText(self.view.otherPlayerLikeNum, info.likes)
	elseif self.curPage == 2 then
		ClientTextUtils.setText(self.view.presetLikeNum, info.likes)
	end

	local info1 = pg.game.markShare.poolHelper[info.markerId].info

	if not info1 then
		return
	end

	pg.game.markShare:refreshMarkColor(info.markerId)
end

function MarkShareViewCtrl:onPlayerHurt(info)
	self:closePanel()
end

function MarkShareViewCtrl:closePanel()
	if not self.view or self.closing or self.avatarCleanupStarted then
		return
	end

	self.closing = true

	local openToken = self.openToken
	local _h = MarkShareViewCtrl._platformHooks

	if _h and _h.clearOnlineID then
		_h.clearOnlineID(self)
	end

	UIUtils.PlayAnimation(self.view.panelAnimation, "VX_MarkShare_View_Out", function()
		if self.openToken ~= openToken or self.avatarCleanupStarted then
			return
		end

		pg.global.ui:close(UIConst.UI_ID_MARK_SHARE_VIEW)
	end)
end

function MarkShareViewCtrl:_setText_txtTitle1USDFText(isSys, playerName)
	if isSys then
		if self.view and self.view.txtTitle1USDFText then
			ClientTextUtils.setText(self.view.txtTitle1USDFText, playerName)
		end
	else
		self:applyMarkShareName("ugcMarkShareViewName", playerName or "", function(displayText)
			if self.view and not UIUtils.IsNull(self.view.txtTitle1USDFText) then
				ClientTextUtils.setText(self.view.txtTitle1USDFText, displayText)
			end

			if self.view and not UIUtils.IsNull(self.view.txtTitleUSDFText) then
				ClientTextUtils.setText(self.view.txtTitleUSDFText, displayText)
			end
		end)
	end
end

return MarkShareViewCtrl
