-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareEdit\\MarkShareEditCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapBlockConfigData = require("Data.map_block_config_data")
local json = require("json")
local SysConfigData = require("Data.sys_config_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ClientUtils = require("Utils.ClientUtils")
local SysNoticeData = require("Data.sys_notice_data")
local Utils = require("Common.Utils.Utils")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local PlayerForbidConst = require("Common.Const.PlayerForbidConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local MarkShareEditCtrl = Class.LightClass("MarkShareEditCtrl", UICtrl)
local fingerGestures = fingerGestures

MarkShareEditCtrl.messages = {
	[MessageName.ON_ADD_INFO_STAMP_SUCCESS] = {
		"onAddInfoStampSuccess",
		true
	},
	[MessageName.ON_DELETE_INFO_STAMP_SUCCESS] = {
		"onDeleteInfoStampSuccess",
		true
	},
	[MessageName.ON_REQUEST_SELF_MARK_INFO] = {
		"onRequestSelfMarkInfo",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}
MarkShareEditCtrl.MAIN_PAGE_TYPE = {
	addNewMark = 1,
	history = 0,
	editingAnimation = 7,
	editingBubble = 6,
	editingConj = 5,
	editingSentenceWord = 4,
	editingSentence = 3,
	chooseTemplate = 2
}
MarkShareEditCtrl.REPLACE_ICON_ID = "<sprite=\"Message\" index=2 anim=\"2,3,2\">"
MarkShareEditCtrl.REPLACE_SINGLE_ICON_ID = "<sprite=\"Message\" index=0 anim=\"0,1,2\">"

function MarkShareEditCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isDirty = nil
	self.textContentRecord = nil
	self.requestIds = {}
	self.curTextContentGroupConfirm = {}
	self.bubbleType = nil
	self.animation = self.model:getDefaultAnimation()
	self.photoTemplate = info and info.photoTemplate
	self.photoSprite = info and info.photoSprite
	self.needResetCamera = self.photoTemplate and true or false

	self:refreshTitle()
	self:refreshAnimationAvatarIcon()
	self:refreshBubbleIcon()

	self.txtCustom = ""

	if pg.game.markShare.bubbleHelper:getInputField() then
		ClientTextUtils.setText(pg.game.markShare.bubbleHelper:getInputField(), "")

		self.txtCustom = pg.game.markShare.bubbleHelper:getInputField().text
	end

	self.bubbleTypeCurChoose = self.bubbleType
	self.animationCurChoose = self.animation

	self:switchCamera(true)
	self:initGesture()
	self:Init(info)

	self.cdTs = Time.realSecondCache
end

function MarkShareEditCtrl:onOpen(info)
	return
end

function MarkShareEditCtrl:onShow()
	if NotNil(self.view.txtEdit) then
		ClientTextUtils.setText(self.view.txtEdit, pg.getGameString("CONSOLE_BAR_EDIT"))
	end
end

function MarkShareEditCtrl:onHide()
	return
end

function MarkShareEditCtrl:onVisibleChange(visible)
	UICtrl.onVisibleChange(visible)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.MarkShare, visible)
end

function MarkShareEditCtrl:onDestroy()
	if self.needResetCamera then
		LuaUIUtils.closeWristWatchCamera()
	elseif self.markShareCameraMode and pg.game.camera.fixedWithTargetCameraMode == self.markShareCameraMode then
		pg.game.camera:cancelBlendToFixedWithTarget(0.5)
	end

	self.markShareCameraMode = nil

	UICtrl.onDestroy(self)
end

function MarkShareEditCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_MARK_SHARE_BUBBLE] = true

	return whiteList
end

function MarkShareEditCtrl:Init(info)
	self:refreshBubble()
	self:switchNewOrHistoryPage(MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
	self:loadAvatar()

	self.turnAvatarSpeed = {}
	self.timer = self:startTimer(function()
		self:startTick()
	end, 0, true)
end

function MarkShareEditCtrl:startTick()
	if not self.turnAvatarSpeed.x then
		return
	end

	self:onSwipeModel(self.turnAvatarSpeed)
end

function MarkShareEditCtrl:refreshAnimationAvatarIcon()
	self.view.animationAvatarIcon.url = self.model:getIconByAnimationIndex(self.animation)
end

function MarkShareEditCtrl:refreshBubbleIcon()
	self.view.bubbleTypeIcon.url = self.model:getIconByBubbleTypeIndex(self.bubbleType)
end

function MarkShareEditCtrl:refreshTitle()
	local key = self.photoTemplate and "PHOTO_MARK_PROMPT" or "MARK_PROMPT"

	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString(key))
end

function MarkShareEditCtrl:loadAvatar()
	pg.game.markShare:createAvatarReplication(pg.game.markShare.AVATAR_TYPE.Self, nil, function(ent)
		self.curEnt = ent

		local targetPos = self:getPlayerForwardPos()

		self.curEnt.eModel:SetTransformPosition(targetPos.x, targetPos.y, targetPos.z)
		pg.game.markShare.avatarHelper:animationTool(self.curEnt, self.animation, nil, true)
		self.view.root:TryChangePage("showAvatar", self.animation == -1 and 1 or 0)
		pg.game.markShare.bubbleHelper:setPos(Vector3(self.curEnt.eModel:GetTransformPosition()) + self.curEnt.eModel.transform.up * SysConfigData.INFO_STAMP_BUBBLE_HEIGHT)
		pg.game.markShare.bubbleHelper:changeType(true)
	end, function()
		return
	end)
end

function MarkShareEditCtrl:getPlayerForwardPos()
	local pos = SysConfigData.INFO_STAMP_AVATAR_POSITION
	local wx, wy, wz = pg.me.eModel:PositionAgentTransformByLocalOffsetEx(pos[1], pos[2], pos[3])

	return Vector3.New(wx, wy, wz)
end

function MarkShareEditCtrl:switchNewOrHistoryPage(type, manual)
	if type == MarkShareEditCtrl.MAIN_PAGE_TYPE.history then
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.history)
		self.view.btnNewUButton:TryChangePage("Selected", 0)
		self.view.btnHistoryUButton:TryChangePage("Selected", 1)
		self:initHistoryData()

		if manual and self.curEnt then
			pg.game.markShare.avatarHelper:playEffect(self.curEnt, false, function()
				self.curEnt.eModel:SetModelVisible(false)
			end)
			self:switchCamera(false)
		end

		if self.bubbleType then
			pg.game.markShare.bubbleHelper:enableBubble(false)

			self.bubbleTypeCurChoose = nil
		end
	elseif type == MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark then
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
		self.view.btnNewUButton:TryChangePage("Selected", 1)
		self.view.btnHistoryUButton:TryChangePage("Selected", 0)
		self:initNewMarkEditingData()

		if manual and self.curEnt then
			self.curEnt.eModel:SetModelVisible(true)
			pg.game.markShare.avatarHelper:playEffect(self.curEnt, true)
			self:switchCamera(true)
		end

		if self.bubbleType then
			pg.game.markShare.bubbleHelper:enableBubble(true, true)
		end
	else
		return
	end
end

function MarkShareEditCtrl:initHistoryData()
	local data = {}

	for k, v in pairs(pg.me.mediaMarker) do
		data[#data + 1] = {
			createTs = v.createTs,
			key = k,
			isPermanent = v.isPermanent
		}
	end

	table.sort(data, function(a, b)
		return a.createTs < b.createTs
	end)
	ClientTextUtils.setText(self.view.historyCount, Lume.count(data))

	self.view.historyList.poolMode = 0

	function self.view.historyList.luaFinishRender(_)
		local t = {}
		local max = #data < 10 and #data or 10

		for i = 1, max do
			t[#t + 1] = data[i].key
			self.requestIds[data[i].key] = true
		end

		if next(t) then
			pg.me:batchFindMediaMarker(t)
		end
	end

	function self.view.historyList.luaRenderItem(button, index, data1)
		local objectReference = button:GetComponent("ObjectReference")
		local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")
		local txtNumLikeUSDFText = objectReference:GetRefValue("txtNumLikeUSDFText")
		local txtPositionUSDFText = objectReference:GetRefValue("txtPositionUSDFText")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtContentUSDFText, "")
		ClientTextUtils.setText(txtNumLikeUSDFText, 0)
		ClientTextUtils.setText(txtPositionUSDFText, "")
		self:_renderExpireInfo(button, txtNameUSDFText, data1)

		button.name = data1.key

		function button.luaClick()
			pg.game.markShare:openInfoStampSimple(data1.key)
		end
	end

	self.view.historyList:SetList(data)
	self.view.root:TryChangePage("MarkEmpty", Lume.count(data) > 0 and 1 or 0)
end

function MarkShareEditCtrl:_renderExpireInfo(button, txtName, data)
	if data.isPermanent == 1 then
		button:TryChangePage("Time", 0)

		return
	end

	local maxDayCount = SysConfigData.MARKSHARE_ENCOURAGE_DURING_MAX or 10
	local expireTs = (data.createTs or 0) + maxDayCount * Const.SECONDS_ONE_DAY
	local remainSeconds = expireTs - Time.secondCache

	if remainSeconds <= 0 then
		button:TryChangePage("Time", 2)
		ClientTextUtils.setText(txtName, pg.getGameString("MARK_SHARE_EXPIRED"))

		return
	end

	button:TryChangePage("Time", 1)

	local remainDays = math.ceil(remainSeconds / Const.SECONDS_ONE_DAY)

	ClientTextUtils.setText(txtName, string.format(pg.getGameString("MARK_SHARE_EXPIRE_DAYS"), remainDays))
end

function MarkShareEditCtrl:onHistoryListScroll(Vec2)
	local markShareEdit = pg.global.ui.markShareEdit

	markShareEdit:renderHistoryButtons()
end

function MarkShareEditCtrl:renderHistoryButtons()
	if self.view.historyList.itemCount <= 0 then
		return
	end

	local btns = self.view.historyList:GetAllButtons()
	local result, min, max = self.view.historyList:TryGetVisualRange()

	if result then
		for i = min, max do
			if not self.requestIds[btns[i].name] then
				pg.me:batchFindMediaMarker({
					btns[i].name
				})

				self.requestIds[btns[i].name] = true
			end
		end
	end
end

function MarkShareEditCtrl:checkAllDefault()
	return #self.curTextContentGroupConfirm <= 0 and not self.bubbleType and self.animation == self.model:getDefaultAnimation()
end

function MarkShareEditCtrl:checkTextClipsEmpty()
	return #self.curTextContentGroupConfirm <= 0
end

function MarkShareEditCtrl:refreshConsumeList()
	local ret = {}

	if self.animation ~= self.model:getDefaultAnimation() then
		for _, v in pairs(self.model:getConsumeCostData(2)) do
			if ret[v.id] then
				ret[v.id] = ret[v.id] + v.num
			else
				ret[v.id] = v.num
			end
		end
	end

	if self.bubbleType then
		for _, v in pairs(self.model:getConsumeCostData(3)) do
			if ret[v.id] then
				ret[v.id] = ret[v.id] + v.num
			else
				ret[v.id] = v.num
			end
		end
	end

	if #self.curTextContentGroupConfirm > 0 then
		for _, v in pairs(self.model:getConsumeCostData(1)) do
			if ret[v.id] then
				ret[v.id] = ret[v.id] + v.num
			else
				ret[v.id] = v.num
			end
		end
	end

	local newT = {}

	for k, v in pairs(ret) do
		newT[#newT + 1] = {
			id = k,
			num = v
		}
	end

	self.view.consumeUList:SetList(newT)
end

function MarkShareEditCtrl:initNewMarkEditingData()
	if self.isDirty and self.textContentRecord then
		self.curTextContentGroupConfirm = Utils.deepCopyTable(self.textContentRecord)
	end

	self.view.root:TryChangePage("Edit", #self.curTextContentGroupConfirm > 0 and 1 or 0)
	self.view.root:TryChangePage("hideLeftBtns", #self.curTextContentGroupConfirm <= 0 and 1 or 0)

	if #self.curTextContentGroupConfirm > 0 then
		self:refreshHoldingWordDisplay()

		function self.view.consumeUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local icon = objectReference:GetRefValue("icon")
			local txtNum = objectReference:GetRefValue("txtNum")
			local remainNum = ClientUtils.getItemCountById(data.id) or 0

			if remainNum < data.num then
				ClientTextUtils.setText(txtNum, string.format("<color=red>%s</color>/%s", remainNum, data.num))
			else
				ClientTextUtils.setText(txtNum, string.format("%s/%s", remainNum, data.num))
			end

			icon.url = LuaUIUtils.getIconByItemId(data.id)
		end

		self:refreshConsumeList()

		function self.view.editingWordBtn.luaClick()
			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate)
			self:refreshEditingPage()
		end

		self.view.btnSendUButton:TryChangePage("disable", 0)
	else
		function self.view.createNewMarkBtn.luaClick()
			if not UIUtils.IsRayCastHit(self:getPlayerForwardPos(), 0.3) then
				pg.global.showBubbleMessageRaw(pg.getGameString("INFO_STAMP_POS_INVALID"))

				return
			end

			self.view.root.renderOpacity = 0
			self.view.root.renderOpacity = 1

			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate)
			self:refreshEditingPage()
		end

		self.view.btnSendUButton:TryChangePage("disable", 1)
	end

	self.view.activeDeleModeBtn:TryChangePage("disable", self:checkAllDefault() and 1 or 0)

	function self.view.activeDeleModeBtn.luaClick()
		if self:checkAllDefault() then
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[10902].text))

			return
		end

		self:deleteMainInfoStamp()
		self:deleteBubble()
		self:revertAnimation()
		self:refreshConsumeList()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
		self:initNewMarkEditingData()
	end

	function self.view.btnSendUButton.luaClick()
		if self.cdTs + 1 > Time.realSecondCache then
			pg.global.showBubbleMessageRaw(pg.getGameString("OPERATE_TOO_MANY"))

			return
		end

		if #self.curTextContentGroupConfirm <= 0 then
			pg.global.showBubbleMessageRaw(pg.getGameString("INFO_STAMP_INVALID"))

			return
		end

		if Lume.count(pg.me.mediaMarker) >= SysConfigData.INFO_STAMP_MAX_LIMIT then
			pg.global.showBubbleMessageRaw(pg.getGameString("REACH_MAX_INFO_STAMP_LIMIT"))

			return
		end

		self.cdTs = Time.realSecondCache

		self:addMark()
	end

	function self.view.btnBubbleUButton.luaClick()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.editingBubble)
		self:refreshEditingBubblePage()
	end

	function self.view.btnActionUButton.luaClick()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.editingAnimation)
		self:refreshEditingAnimationPage()
	end

	function self.view.uselessBtn.luaClick()
		self:closePanel()
	end
end

function MarkShareEditCtrl:refreshHoldingWordDisplay()
	local result = pg.game.markShare:getTemplateTxt({
		txtClips = self.curTextContentGroupConfirm
	})

	ClientTextUtils.setText(self.view.holdingTxtContent, string.format(result, MarkShareEditCtrl.REPLACE_ICON_ID))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, string.format("%s %s/%s", pg.getGameString("ALREADY_WRITTEN"), #self.curTextContentGroupConfirm, 3))
end

function MarkShareEditCtrl:refreshWordDisplay()
	local result = pg.game.markShare:getTemplateTxt({
		txtClips = self.curTextContentGroupConfirm
	})
	local _, page = self.view.root:TryGetCurrentPage("Type")

	if page == MarkShareEditCtrl.MAIN_PAGE_TYPE.editingSentenceWord then
		ClientTextUtils.setText(self.view.editingTxtContent, string.format(result, MarkShareEditCtrl.REPLACE_ICON_ID))
	elseif #self.curTextContentGroupConfirm >= 3 then
		ClientTextUtils.setText(self.view.editingTxtContent, string.format(result, MarkShareEditCtrl.REPLACE_ICON_ID))
	else
		ClientTextUtils.setText(self.view.editingTxtContent, string.format("%s%s", string.format(result, MarkShareEditCtrl.REPLACE_ICON_ID), MarkShareEditCtrl.REPLACE_SINGLE_ICON_ID))
	end

	if #self.curTextContentGroupConfirm <= 0 then
		self.view.editingTxtContentButton:TryChangePage("Type", 0)
	else
		self.view.editingTxtContentButton:TryChangePage("Type", 1)
	end

	if #self.curTextContentGroupConfirm >= 3 then
		ClientTextUtils.setText(self.view.txtTipsUSDFText, string.format("%s<color=red>%s/%s</color>", pg.getGameString("ALREADY_WRITTEN"), #self.curTextContentGroupConfirm, 3))
	else
		ClientTextUtils.setText(self.view.txtTipsUSDFText, string.format("%s%s/%s", pg.getGameString("ALREADY_WRITTEN"), #self.curTextContentGroupConfirm, 3))
	end

	local showPhoto = self.photoTemplate and page == MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate and true or false

	self.view.templateUWidget:SetActive(showPhoto)
end

function MarkShareEditCtrl:refreshEditingPage()
	if not self.isDirty then
		self.textContentRecord = Utils.deepCopyTable(self.curTextContentGroupConfirm)
	end

	function self.view.listMainUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.name)

		function button.luaClick()
			if #self.curTextContentGroupConfirm >= 3 then
				pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[10903].text))

				return
			end

			if index == 0 then
				self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.editingSentence)
				self:refreshEditingSentencePage()
			else
				self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.editingConj)
				self:refreshEditingConjPage()
			end
		end
	end

	local data = {}

	if #self.curTextContentGroupConfirm < 3 then
		data[1] = {
			name = pg.getGameString("SENTENCE")
		}
		data[2] = {
			name = pg.getGameString("CONJ")
		}
	end

	self.view.listMainUList.poolMode = 0

	self.view.listMainUList:SetList(data)
	self:refreshWordDisplay()

	function self.view.btnBackUButton.luaClick()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
		self:initNewMarkEditingData()
	end

	self.view.btnClearTextUButton:TryChangePage("disable", self:checkTextClipsEmpty() and 1 or 0)

	function self.view.btnClearTextUButton.luaClick()
		if self:checkTextClipsEmpty() then
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[10902].text))

			return
		end

		self.curTextContentGroupConfirm = {}
		self.isDirty = true

		self:refreshEditingPage()
	end

	function self.view.btnConfiemUButton.luaClick()
		self.isDirty = nil

		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
		self:initNewMarkEditingData()
	end

	if self.photoTemplate then
		local objectReference = self.view.templateUWidget:GetComponent("ObjectReference")
		local photoUImage = objectReference:GetRefValue("photoUImage")
		local btnAuthorizeUButton = objectReference:GetRefValue("btnAuthorizeUButton")
		local btnDeletePhotoUButton = objectReference:GetRefValue("btnDeletePhotoUButton")
		local btnShowPicUButton = objectReference:GetRefValue("btnShowPicUButton")

		photoUImage.sprite = self.photoSprite

		if self.photoTemplate.authorize == nil then
			self.photoTemplate.authorize = true
		end

		btnAuthorizeUButton.isSelected = true

		function btnAuthorizeUButton.luaClick()
			self.photoTemplate.authorize = not self.photoTemplate.authorize
		end

		function btnDeletePhotoUButton.luaClick()
			self.view.templateUWidget:SetActive(false)

			self.photoTemplate = nil
		end

		function btnShowPicUButton.luaClick()
			pg.global.ui.albumPhoto:open({
				photoInfo = {
					onlyShow = true,
					sprite = photoUImage.sprite,
					timeStamp = self.photoTemplate.time
				}
			})
		end
	end
end

function MarkShareEditCtrl:refreshEditingSentencePage()
	function self.view.listTemplateUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		button.name = data.key

		ClientTextUtils.setText(txtNameUSDFText, string.format(data.name, "***"))

		function button.luaClick()
			self.curTextContentGroupConfirm[#self.curTextContentGroupConfirm + 1] = {
				data.key,
				[2] = 0
			}

			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.editingSentenceWord)
			self:refreshEditingWordPage()
		end
	end

	self:refreshWordDisplay()
	self.view.editingTxtContentButton:TryChangePage("Type", 1)
	self.view.listTemplateUList:SetList(self.model:getSentenceData())

	function self.view.btnSubBackUButton.luaClick()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate)
		self:refreshEditingPage()
	end
end

function MarkShareEditCtrl:refreshEditingWordPage()
	function self.view.listWordUList.luaFinishRender(_)
		self.view.listWordUList:GoToIndex(0)
	end

	self.view.listWordUList.poolMode = 0

	function self.view.listWordUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.name)

		button.name = data.key

		function button.luaClick()
			self.curTextContentGroupConfirm[#self.curTextContentGroupConfirm][2] = data.key
			self.isDirty = true

			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate)
			self:refreshEditingPage()
		end

		function self.view.btnSubBackUButton.luaClick()
			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.editingSentence)

			self.curTextContentGroupConfirm[#self.curTextContentGroupConfirm] = nil

			self:refreshEditingSentencePage()
		end
	end

	self:refreshWordDisplay()

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtTabUSDFText = objectReference:GetRefValue("txtTabUSDFText")

		iconUImage.url = data.icon

		ClientTextUtils.setText(txtTabUSDFText, data.tpName)

		function button.luaClick()
			local btns = self.view.listTabUList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i]:TryChangePage("State", 0)
			end

			btns[index]:TryChangePage("State", 1)

			if data.key == 10 then
				self.view.listWordUList.layoutTool.colCount = 1
			else
				self.view.listWordUList.layoutTool.colCount = 2
			end

			self.view.listWordUList:SetList(self.model:getWordsData(data.key))
		end

		ClientTextUtils.setText(self.view.fillerWordTitle, pg.getGameString("DROP_DOWN_OPEN"), data.tpName)
	end

	function self.view.listTabUList.luaFinishRender(_)
		self.view.listTabUList:GoToIndex(0)

		local btns = self.view.listTabUList:GetAllButtons()

		btns[0]:OnClickSimulate()
	end

	self.view.listTabUList:SetList(self.model:getWordTabData())
end

function MarkShareEditCtrl:refreshEditingConjPage()
	function self.view.listConjUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.name)

		button.name = data.key

		function button.luaClick()
			self.curTextContentGroupConfirm[#self.curTextContentGroupConfirm + 1] = {
				data.key
			}
			self.isDirty = true

			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate)
			self:refreshEditingPage()
		end

		function self.view.btnSubBackUButton.luaClick()
			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.chooseTemplate)
			self:refreshEditingPage()
		end
	end

	self.view.listConjUList:SetList(self.model:getConjData())
	self:refreshWordDisplay()
	self.view.editingTxtContentButton:TryChangePage("Type", 1)
end

function MarkShareEditCtrl:refreshEditingBubblePage()
	pg.game.markShare.bubbleHelper:allowInputField(true)

	local recordTxt = self.txtCustom

	function self.view.listBubbleUList.luaFinishRender(_)
		local btns = self.view.listBubbleUList:GetAllButtons()

		if not self.bubbleType then
			btns[0]:OnClickSimulate()
		else
			btns[self.bubbleType - 1]:OnClickSimulate()
		end
	end

	function self.view.listBubbleUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local imgBubbleUImage = objectReference:GetRefValue("imgBubbleUImage")

		imgBubbleUImage.url = data.icon
		button.name = data.key

		button:TryChangePage("State", 0)

		function button.luaClick()
			if self.bubbleTypeCurChoose and data.key ~= self.bubbleTypeCurChoose then
				pg.game.markShare.bubbleHelper:playSwitchAni()
			end

			self.bubbleTypeCurChoose = data.key

			self:refreshBubble(self.bubbleTypeCurChoose)

			local btns = self.view.listBubbleUList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i]:TryChangePage("State", 0)
			end

			btns[index]:TryChangePage("State", 1)
		end
	end

	self.view.listBubbleUList:SetList(self.model:getBubbleData())

	function self.view.btnBackUButton.luaClick()
		self.bubbleTypeCurChoose = nil

		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
		self:initNewMarkEditingData()

		self.txtCustom = recordTxt

		ClientTextUtils.setText(pg.game.markShare.bubbleHelper:getInputField(), recordTxt)

		if self.bubbleType and self.bubbleType ~= self.bubbleTypeCurChoose then
			pg.game.markShare.bubbleHelper:playSwitchAni()
		end

		self:refreshBubble()
		pg.game.markShare.bubbleHelper:allowInputField(false)
	end

	function self.view.btnConfiemUButton.luaClick()
		if self.txtCustom == "" or string.isNilOrEmpty(self.txtCustom) then
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[10901].text))

			return
		end

		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)

		self.bubbleType = self.bubbleTypeCurChoose

		self:initNewMarkEditingData()
		self:refreshBubble()
		self:refreshBubbleIcon()
		pg.game.markShare.bubbleHelper:allowInputField(false)
	end

	if self.txtCustom == "" or string.isNilOrEmpty(self.txtCustom) then
		self.view.btnConfiemUButton:TryChangePage("disable", 1)
	else
		self.view.btnConfiemUButton:TryChangePage("disable", 0)
	end

	self.view.btnClearAlterUButton:TryChangePage("disable", 0)

	function self.view.btnClearAlterUButton.luaClick()
		if not self.bubbleType then
			self.view.btnBackUButton:OnClickSimulate()
		else
			self:deleteBubble()
			self:refreshConsumeList()
			self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
			self:initNewMarkEditingData()
		end
	end

	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("CHOOSE_YOUR_BUBBLE"))
end

function MarkShareEditCtrl:refreshEditingAnimationPage()
	function self.view.listActionUList.luaFinishRender(_)
		local btns = self.view.listActionUList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			if tonumber(btns[i].name) == self.animation then
				btns[i]:TryChangePage("State", 1)
			end
		end
	end

	function self.view.listActionUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local imgActionUImage = objectReference:GetRefValue("imgActionUImage")

		imgActionUImage.url = data.icon
		button.name = data.key

		button:TryChangePage("State", 0)

		if data.key == -1 then
			button:TryChangePage("Empty", 1)
		else
			button:TryChangePage("Empty", 0)
		end

		function button.luaClick()
			self.animationCurChoose = data.key

			local btns = self.view.listActionUList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				if tonumber(btns[i].name) == data.key then
					btns[i]:TryChangePage("State", 1)
				else
					btns[i]:TryChangePage("State", 0)
				end
			end

			pg.game.markShare.avatarHelper:animationTool(self.curEnt, self.animationCurChoose)
			self.view.root:TryChangePage("showAvatar", self.animationCurChoose == -1 and 1 or 0)
			self.view.btnClearAlterUButton:TryChangePage("disable", self.animationCurChoose == self.model:getDefaultAnimation() and 1 or 0)
		end
	end

	self.view.listActionUList:SetList(self.model:getAnimationData())

	function self.view.btnBackUButton.luaClick()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)
		self:initNewMarkEditingData()

		if self.animation ~= self.animationCurChoose then
			pg.game.markShare.avatarHelper:animationTool(self.curEnt, self.animation)
			self.view.root:TryChangePage("showAvatar", self.animation == -1 and 1 or 0)
		end
	end

	function self.view.btnConfiemUButton.luaClick()
		self.view.root:TryChangePage("Type", MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark)

		self.animation = self.animationCurChoose

		self:initNewMarkEditingData()
		self:refreshAnimationAvatarIcon()
	end

	self.view.btnClearAlterUButton:TryChangePage("disable", self.animationCurChoose == self.model:getDefaultAnimation() and 1 or 0)

	function self.view.btnClearAlterUButton.luaClick()
		if self.animationCurChoose == self.model:getDefaultAnimation() then
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[10902].text))

			return
		end

		local btns = self.view.listActionUList:GetAllButtons()

		if btns.Length <= 0 then
			return
		end

		btns[0]:OnClickSimulate()
	end

	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("CHOOSE_YOUR_ANIMATION"))
end

function MarkShareEditCtrl:destroy()
	self.view.historyList:UnRegisterToScrollEvent(self.onHistoryListScroll)
	pg.game.markShare:clearAvatarEntity()
	self:destroyGesture()

	self.curEnt = nil
	self.turnAvatarSpeed = {}

	pg.game.markShare.bubbleHelper:enableBubble(false)

	self.bubbleTypeCurChoose = nil
end

function MarkShareEditCtrl:escFunc()
	local _, page = self.view.root:TryGetCurrentPage("Type")

	if page == 0 or page == 1 then
		self:closePanel()
	elseif page == 2 or page == 6 or page == 7 then
		self.view.btnBackUButton:OnClickSimulate()
	elseif page == 3 or page == 4 or page == 5 then
		self.view.btnSubBackUButton:OnClickSimulate()
	end
end

function MarkShareEditCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:escFunc()
		end
	end

	function self.view.mainBackBtn.luaClick()
		self:closePanel()
	end

	function self.view.btnNewUButton.luaClick()
		self:switchNewOrHistoryPage(MarkShareEditCtrl.MAIN_PAGE_TYPE.addNewMark, true)
	end

	function self.view.btnHistoryUButton.luaClick()
		self:switchNewOrHistoryPage(MarkShareEditCtrl.MAIN_PAGE_TYPE.history, true)
	end

	function self.view.root.luaTryChangePage(name, pageIdx)
		if name == "Type" and pageIdx ~= MarkShareEditCtrl.MAIN_PAGE_TYPE.editingBubble then
			self.view.btnConfiemUButton:TryChangePage("disable", 0)
		elseif name == "hideLeftBtns" then
			self.view.btnActionUButton.navForceNonInteractable = pageIdx == 1
		end
	end

	if pg.game.markShare.bubbleHelper:getInputField() then
		pg.game.markShare.bubbleHelper:getInputField().luaValueChanged = function(keyword)
			self.txtCustom = keyword

			local _, page = self.view.root:TryGetCurrentPage("Type")

			if page ~= MarkShareEditCtrl.MAIN_PAGE_TYPE.editingBubble then
				return
			end

			if keyword == "" or string.isNilOrEmpty(keyword) then
				self.view.btnConfiemUButton:TryChangePage("disable", 1)
			else
				self.view.btnConfiemUButton:TryChangePage("disable", 0)
			end

			pg.game.markShare.bubbleHelper:refreshLimit()
		end
	end

	self.view.historyList:RegisterToScrollEvent(self.onHistoryListScroll)

	local function refreshTurnAvatarSpeed()
		local isLeftPressed = self.turnAvatarLeftButtonPressed or self.turnAvatarLeftTriggerPressed
		local isRightPressed = self.turnAvatarRightButtonPressed or self.turnAvatarRightTriggerPressed

		self.turnAvatarSpeed.x = (isRightPressed and 20 or 0) + (isLeftPressed and -20 or 0)

		if self.turnAvatarSpeed.x == 0 then
			self.turnAvatarSpeed.x = nil
		end
	end

	function self.view.btnLeftUButton.luaPress()
		self.turnAvatarLeftButtonPressed = true

		refreshTurnAvatarSpeed()
	end

	function self.view.btnLeftUButton.luaRelease()
		self.turnAvatarLeftButtonPressed = false

		refreshTurnAvatarSpeed()
	end

	function self.view.btnRightUButton.luaPress()
		self.turnAvatarRightButtonPressed = true

		refreshTurnAvatarSpeed()
	end

	function self.view.btnRightUButton.luaRelease()
		self.turnAvatarRightButtonPressed = false

		refreshTurnAvatarSpeed()
	end

	self.view.leftKeyHotKeyContent:SetHotKeyPaths("Raw/GamepadLeftTrigger")
	self.view.rightKeyHotKeyContent:SetHotKeyPaths("Raw/GamepadRightTrigger")

	local ltBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnLeftUButton.gameObject, "markShareEditTurnLeft")

	ltBind.isVirtual = true
	ltBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftTrigger

	function ltBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.turnAvatarLeftTriggerPressed = true

			refreshTurnAvatarSpeed()
		elseif inputInfo.phase == "Canceled" then
			self.turnAvatarLeftTriggerPressed = false

			refreshTurnAvatarSpeed()
		end
	end

	local rtBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnRightUButton.gameObject, "markShareEditTurnRight")

	rtBind.isVirtual = true
	rtBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightTrigger

	function rtBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.turnAvatarRightTriggerPressed = true

			refreshTurnAvatarSpeed()
		elseif inputInfo.phase == "Canceled" then
			self.turnAvatarRightTriggerPressed = false

			refreshTurnAvatarSpeed()
		end
	end

	function self.view.gMButtonUButton.luaClick()
		self:gm()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(42)
	end
end

function MarkShareEditCtrl:closePanel()
	self:destroy()
	UIUtils.PlayAnimation(self.view.contentAnimation, "VX_MarkShare_Panel_Out", function()
		pg.global.ui:close(UIConst.UI_ID_MARK_SHARE_EDIT)
	end)
end

function MarkShareEditCtrl:initGesture()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnSwipeStart(gesture)
		self.pickedUIElement = gesture.pickedUIElement
	end

	function fingerGestures.luaOnSwipeEnd(gesture)
		self.pickedUIElement = nil
	end

	function fingerGestures.luaOnSwipe(gesture)
		if self.pickedUIElement then
			return
		end

		self:onSwipeModel(gesture.deltaPosition)
	end
end

function MarkShareEditCtrl:destroyGesture()
	fingerGestures.DeActive()
end

function MarkShareEditCtrl:onSwipeModel(deltaPosition)
	if not self.curEnt then
		return
	end

	local speed = -deltaPosition.x * 0.2
	local rx, ry, rz, rw = self.curEnt.eModel:GetPositionAgentRotationEx()
	local newRot = Quaternion(rx, ry, rz, rw) * Quaternion.Euler(0, speed, 0)

	EModelUtils.setAgentRotation(self.curEnt, newRot, true)

	self.modelRot = newRot
end

function MarkShareEditCtrl:refreshBubble(tempBubbleType)
	if tempBubbleType then
		pg.game.markShare.bubbleHelper:enableBubble(true, true)
		pg.game.markShare.bubbleHelper:changeImageUrl(self.model:getBubbleRes(tempBubbleType))
	elseif self.bubbleType then
		pg.game.markShare.bubbleHelper:enableBubble(true, true)
		pg.game.markShare.bubbleHelper:changeImageUrl(self.model:getBubbleRes(self.bubbleType))
	else
		pg.game.markShare.bubbleHelper:enableBubble(false)

		self.bubbleTypeCurChoose = nil
	end
end

function MarkShareEditCtrl:addMark()
	if LuaUIUtils.checkFeatureForbid(PlayerForbidConst.PLAYER_SWITCH.PLAYER_MEDIA_MARK) then
		return
	end

	local function addMarkInner(imgUrl)
		local cost = Utils.getInfoStampCostTypeList(self.animation, self.bubbleType, self.curTextContentGroupConfirm)

		pg.me:addMediaMarker(Const.MediaMarkerType.NormalText, {
			txtCustom = "",
			pos = self:getPlayerForwardPos(),
			rot = self.modelRot,
			playerName = pg.me.playerName,
			txtClips = self.curTextContentGroupConfirm,
			animation = self.animation,
			bubbleType = self.bubbleType,
			costType = cost,
			photoTemplate = self.photoTemplate,
			imgUrl = imgUrl
		})
	end

	if self.photoTemplate and self.photoSprite then
		pg.me:addPhotoImgSprite(self.photoSprite, function(key, result, imgUrl)
			if result == true then
				self.photoTemplate.imgKey = key

				addMarkInner(imgUrl)
			end
		end)
	else
		addMarkInner()
	end
end

function MarkShareEditCtrl:onAddInfoStampSuccess(info)
	pg.global.showBubbleMessageRaw(pg.getGameString("ADD_INFO_STAMP_SUCCESS"))
	self:closePanel()

	if pg.global.ui.funcMenu then
		pg.global.ui.funcMenu:closePanel()
	end
end

function MarkShareEditCtrl:onDeleteInfoStampSuccess(info)
	self:initHistoryData()
end

function MarkShareEditCtrl:revertAnimation()
	self.animation = self.model:getDefaultAnimation()

	pg.game.markShare.avatarHelper:animationTool(self.curEnt, self.animation)
	self.view.root:TryChangePage("showAvatar", self.animation == -1 and 1 or 0)
	self:refreshAnimationAvatarIcon()
end

function MarkShareEditCtrl:deleteBubble()
	self.bubbleType = nil

	self:refreshBubbleIcon()

	self.txtCustom = ""

	ClientTextUtils.setText(pg.game.markShare.bubbleHelper:getInputField(), "")
	self:refreshBubble()
end

function MarkShareEditCtrl:deleteMainInfoStamp()
	self.curTextContentGroupConfirm = {}

	self:initNewMarkEditingData()
end

function MarkShareEditCtrl:onRequestSelfMarkInfo(info)
	if not info.result then
		return
	end

	local markers = info.markers
	local btns = self.view.historyList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if markers[btns[i].name] then
			local objectReference = btns[i]:GetComponent("ObjectReference")
			local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")
			local txtNumLikeUSDFText = objectReference:GetRefValue("txtNumLikeUSDFText")
			local txtPositionUSDFText = objectReference:GetRefValue("txtPositionUSDFText")
			local content = json.decode(markers[btns[i].name].content)
			local sceneId = pg.me.mediaMarker[btns[i].name].sceneId
			local blockId = pg.game.map:inWhichBlock(sceneId, false, {
				x = content.pos[1],
				z = content.pos[3]
			})
			local blockData = blockId and MapBlockConfigData[blockId]
			local positionName = pg.me:getDungeonName(sceneId)

			if blockData and blockData.areaName then
				positionName = pg.getLocalizationText(blockData.areaName)
			end

			ClientTextUtils.setText(txtPositionUSDFText, positionName or "")
			ClientTextUtils.setText(txtContentUSDFText, pg.game.markShare:getTemplateTxt(content))
			ClientTextUtils.setText(txtNumLikeUSDFText, markers[btns[i].name].likes)
		end
	end
end

function MarkShareEditCtrl:switchCamera(closer)
	local cameraInfo = SysConfigData.INFO_STAMP_CAMERA_INFO
	local cameraMenuInfo = {
		{
			0.7,
			1.129603,
			-0.72
		},
		{
			0,
			-28.8,
			0
		},
		45,
		0.5
	}
	local cameraPos = pg.global.cameraMgr.vcManager:GetFuncMenuBackPos()
	local cameraRot = pg.global.cameraMgr.vcManager:GetFuncMenuBackRot()
	local fov = pg.global.cameraMgr.vcManager:GetFuncMenuBackFov()
	local pivotHeight = pg.me:getCameraHeightInfo()

	if closer then
		local adjustedCameraPos = {
			cameraInfo[1][1],
			cameraInfo[1][2] - pivotHeight,
			cameraInfo[1][3]
		}

		pg.game.camera:cameraBlendToFixedWithTargetByActorId(adjustedCameraPos, cameraInfo[2], cameraInfo[3], pg.me.actorId, cameraInfo[4], function()
			return
		end, {
			pivotOffset = Vector3(0, pivotHeight, 0)
		})
	else
		local adjustedCameraMenuPos = {
			cameraMenuInfo[1][1],
			cameraMenuInfo[1][2] - pivotHeight,
			cameraMenuInfo[1][3]
		}

		pg.game.camera:cameraBlendToFixedWithTargetByActorId(adjustedCameraMenuPos, cameraMenuInfo[2], cameraMenuInfo[3], pg.me.actorId, cameraMenuInfo[4], function()
			return
		end, {
			pivotOffset = Vector3(0, pivotHeight, 0)
		})
	end

	self.markShareCameraMode = pg.game.camera.fixedWithTargetCameraMode
end

function MarkShareEditCtrl:gm()
	local informationIdStr = self.view.inputFieldUTMPInputField.text

	if string.isNilOrEmpty(informationIdStr) then
		pg.global.showBubbleMessageRaw(pg.getGameString("INFO_STAMP_GM_TIP_ERROR"))

		return
	end

	local informationId = tonumber(informationIdStr)

	if not informationId then
		pg.global.showBubbleMessageRaw(pg.getGameString("INFO_STAMP_GM_TIP_ERROR"))

		return
	end

	local rot = "{0,0,0}"

	if self.curEnt then
		local _ex, _ey, _ez = self.curEnt.eModel:GetPositionAgentEulerEx()

		rot = string.format("{%s,%s,%s}", _ex, _ey, _ez)
	end

	local bubbleType = ""

	if self.bubbleType then
		bubbleType = tostring(self.bubbleType)
	end

	local txtClips = "{"

	for i = 1, #self.curTextContentGroupConfirm do
		local temp = ""

		if #self.curTextContentGroupConfirm[i] == 1 then
			temp = string.format("{%s}", self.curTextContentGroupConfirm[i][1])
		else
			temp = string.format("{%s,%s}", self.curTextContentGroupConfirm[i][1], self.curTextContentGroupConfirm[i][2])
		end

		txtClips = txtClips .. temp .. ","
	end

	txtClips = txtClips .. "}"

	local posValue = self:getPlayerForwardPos()
	local pos = string.format("坐标{%s,%s,%s}", posValue[1], posValue[2], posValue[3])
	local ret = CS.FunPlus.WorldX.Utils.GmToolUtils.CreateInformationPoint(pg.me.space.sceneId, informationId, Vector3(posValue[1], posValue[2], posValue[3]))
	local createInformationPointMsg = ""

	createInformationPointMsg = (ret == 0 or ret == -1) and "关卡异步留言信息点创建失败！" or "关卡异步留言信息点创建成功！ID: " .. ret

	UIUtils.CopyCsvDataToBuffer({
		pos,
		informationId,
		"CE_通用",
		"yuntao.xu",
		"1",
		"",
		"1",
		"400153",
		"0",
		rot,
		txtClips,
		bubbleType,
		self.txtCustom,
		tostring(self.animation)
	}, function()
		pg.global.showBubbleMessageRaw(string.format(pg.getGameString("INFO_STAMP_GM_TIP"), createInformationPointMsg))
	end)
end

return MarkShareEditCtrl
