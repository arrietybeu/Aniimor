-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\MailNewComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local ItemUtils = require("Common.Utils.ItemUtils")
local DropUtils = require("Common.Utils.DropUtils")
local Utils = require("Common.Utils.Utils")
local ClientRepo = require("Core.Client.ClientRepo")
local logger = require("Core.Log.LoggerManager").getLogger("MailNewComponent")
local MailNewComponent = Class.LightClass("MailNewComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local RewardStateUtils = require("Common.Utils.RewardStateUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local MessageName = require("Const.MessageName")
local ItemData = require("Data.item_data")
local SettingSelectorTextData = require("Data.setting_selector_text_data")
local HotkeyConst = require("Const.HotkeyConst")
local SPECIAL_GIFT_MAIL_SOURCE_ID = 27

function MailNewComponent:onCtor()
	self.mailTitleTranslationOwner = {}
	self.mailContentTranslationOwner = {}
	self.mailTranslationSelected = false
	self.mailTranslationPendingCount = 0
	self.bannerFrame = nil
	self.bannerSprites = {}
	self.bannerLoadingUrls = {}
end

function MailNewComponent:onDestroy()
	self.bannerFrame = nil

	local bannerSprites = self.bannerSprites

	self.bannerSprites = nil
	self.bannerLoadingUrls = nil

	if self.bannerUImage and not IsNil(self.bannerUImage) then
		self.bannerUImage.sprite = nil
	end

	self:releaseMailBannerSprites(bannerSprites)
	self:stopMailTranslation()
end

function MailNewComponent:releaseMailBannerSprites(bannerSprites)
	for _, sprite in next, bannerSprites do
		pg.global.uiMgr:ReleaseTexture2D(sprite.texture)
	end
end

function MailNewComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.mailListUList = objectReference:GetRefValue("mailListUList")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.btnAllReadUButton = objectReference:GetRefValue("btnAllReadUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.rewardListUList = objectReference:GetRefValue("rewardListUList")
	self.btnDetailCloseUButton = objectReference:GetRefValue("btnDetailCloseUButton")
	self.textTimeUSDFText = objectReference:GetRefValue("textTimeUSDFText")
	self.detailAddresserNameUSDFText = objectReference:GetRefValue("detailAddresserNameUSDFText")
	self.detailScrollRect = objectReference:GetRefValue("detailScrollRect")
	self.btnDetailConfirmUButton = objectReference:GetRefValue("btnDetailConfirmUButton")
	self.mailDetailUComponent = objectReference:GetRefValue("mailDetailUComponent")
	self.detailTitleUSDFText = objectReference:GetRefValue("detailTitleUSDFText")
	self.noMessageUWidget = objectReference:GetRefValue("noMessageUWidget")
	self.txtMailEmptyUSDFText = objectReference:GetRefValue("txtMailEmptyUSDFText")
	self.btnDetailDeleteUButton = objectReference:GetRefValue("btnDetailDeleteUButton")
	self.infoUButton = objectReference:GetRefValue("infoUButton")
	self.btnOtherUButton = objectReference:GetRefValue("btnOtherUButton")
	self.translateUSDFText = objectReference:GetRefValue("translateUSDFText")
	self.otherPanelUWidget = objectReference:GetRefValue("otherPanelUWidget")
	self.translateUWidget = objectReference:GetRefValue("translateUWidget")
	self.bannerUImage = objectReference:GetRefValue("bannerUImage")
	objectReference = self.otherPanelUWidget:GetComponent("ObjectReference")
	self.otherBtnCloseUButton = objectReference:GetRefValue("otherBtnCloseUButton")
	self.listOtherUList = objectReference:GetRefValue("listOtherUList")
end

function MailNewComponent:initView()
	function self.btnDeleteUButton.luaClick()
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("MAIL_DELETE_ALL_MAIL"), function()
			pg.me:deleteReadedMail()
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end, nil)
	end

	local btnDeleteObjRef = self.btnDeleteUButton:GetComponent("ObjectReference")
	local btnDeleteText = btnDeleteObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnDeleteText, pg.getGameString("DELETE_READED_MAIL"))

	function self.btnAllReadUButton.luaClick()
		if pg.game.chat:checkHasRewardMail() == false then
			pg.global.ui.tips:showTextTip(pg.getGameString("MAIL_NO_REWARD_TO_RECEIVE"))

			return
		end

		pg.me:setAllMailGiftReceived()
		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
	end

	local btnReadObjRef = self.btnAllReadUButton:GetComponent("ObjectReference")
	local btnAllReadText = btnReadObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnAllReadText, pg.getGameString("OBTAIN_ALL"))

	function self.infoUButton.luaRenderTooltip(button, tooltip)
		local objectReference = tooltip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, string.format(pg.getGameString("CHAT_MAIL_PANEL_INFO")))
	end

	function self.btnDetailCloseUButton.luaClick()
		self:stopMailTranslation()
		self.uWidget:TryChangePage("ShowDetail", 0)
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnDetailCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.btnDetailCloseUButton.luaClick()
	end

	function self.btnDetailConfirmUButton.luaClick()
		local mailData = self.mailDatas[self.curSelectedMailIndex]

		if mailData == nil then
			return
		end

		if tonumber(mailData.SrcId) == Const.MAIL_ID.SHOPMALL_GIVE_MAIL then
			local info = self:buildGiftReceiveInfo(mailData)

			pg.global.ui:open(UIConst.UI_ID_SHOP_GIFT_RECEIVE, info)
		else
			pg.me:setMailGiftReceived({
				mailData.MailId
			})
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end
	end

	function self.btnDetailDeleteUButton.luaClick()
		pg.me:deleteMail({
			self.mailDatas[self.curSelectedMailIndex].MailId
		})
		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
	end

	local btnDetailDeleteObjRef = self.btnDetailDeleteUButton:GetComponent("ObjectReference")
	local btnDetailDeleteText = btnDetailDeleteObjRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnDetailDeleteText, pg.getGameString("DELETE"))
	ClientTextUtils.setText(self.txtMailEmptyUSDFText, pg.getGameString("CHAT_NO_MAIL"))

	self.mailDatas = {}

	self:initOtherList()
	self:initMailList()
end

function MailNewComponent:initOtherList()
	self.translateUWidget:SetActive(false)

	function self.btnOtherUButton.luaClick()
		self:setOtherPanelVisible(not self.otherPanelVisible)
	end

	function self.otherBtnCloseUButton.luaClick()
		self:setOtherPanelVisible(false)
	end

	function self.listOtherUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			self:renderSwitchSettingItem(button, data)
		elseif data.tIndex == 4 then
			self:renderMailTranslationSettingItem(button, data)
		end
	end

	local otherFuncList = self.model:getExtensionFunctionListByType("Mail")

	self.listOtherUList:SetList(otherFuncList)
	self:setOtherPanelVisible(false)
end

function MailNewComponent:renderSwitchSettingItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	local button1UButton = objectReference:GetRefValue("button1UButton")
	local button2UButton = objectReference:GetRefValue("button2UButton")
	local btnName1USDFText = objectReference:GetRefValue("btnName1USDFText")
	local btnName2USDFText = objectReference:GetRefValue("btnName2USDFText")

	ClientTextUtils.setText(textTitleUSDFText, pg.getLocalizationText(data.label))

	local option1TextData = SettingSelectorTextData[data.widgetTxt[1]]
	local option2TextData = SettingSelectorTextData[data.widgetTxt[2]]

	ClientTextUtils.setText(btnName1USDFText, pg.getLocalizationText(option1TextData.name))
	ClientTextUtils.setText(btnName2USDFText, pg.getLocalizationText(option2TextData.name))

	local isSelected = self[data.checkFunc](self, data.settingType)

	button1UButton.isSelected = not isSelected
	button2UButton.isSelected = isSelected

	function button1UButton.luaClick()
		self[data.func](self, false, data.settingType)

		button1UButton.isSelected = true
		button2UButton.isSelected = false
	end

	function button2UButton.luaClick()
		self[data.func](self, true, data.settingType)

		button1UButton.isSelected = false
		button2UButton.isSelected = true
	end
end

function MailNewComponent:renderMailTranslationSettingItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnOpenUButton = objectReference:GetRefValue("btnOpenUButton")
	local buttonObjectReference = btnOpenUButton:GetComponent("ObjectReference")
	local uIBtn1stConfirmUButton = buttonObjectReference:GetRefValue("uIBtn1stConfirmUButton")
	local txtNameUText = buttonObjectReference:GetRefValue("txtNameUText")
	local keyHotKeyContent = buttonObjectReference:GetRefValue("keyHotKeyContent")

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.label))

	local textKey = self.mailTranslationSelected and "AI_TRANSLATED" or "AI_TRANSLATE"

	ClientTextUtils.setText(txtNameUText, pg.getGameString(textKey))

	local actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadConfirm

	keyHotKeyContent:SetHotKeyPaths(actionPath)
	uIBtn1stConfirmUButton:SetGamepadAction(actionPath, keyHotKeyContent.gameObject)
	uIBtn1stConfirmUButton:SetHotkeyActiveOnlyInCurrentItem(true)

	function uIBtn1stConfirmUButton.luaClick()
		self[data.func](self)
	end
end

function MailNewComponent:setOtherPanelVisible(visible)
	self.otherPanelVisible = visible
	self.btnOtherUButton.isSelected = visible

	self.otherPanelUWidget:SetActive(visible)

	if visible then
		self.listOtherUList:RefreshList()
	end
end

function MailNewComponent:toggleMailTranslation()
	self.mailTranslationSelected = not self.mailTranslationSelected

	self.listOtherUList:RefreshList()

	if not self.mailTranslationSelected then
		self:stopMailTranslation()
	end

	local _, showDetailPage = self.uWidget:TryGetCurrentPage("ShowDetail")

	if showDetailPage == 1 then
		self:refreshMailContent()
	end
end

function MailNewComponent:stopMailTranslation()
	if pg.game and pg.game.chat then
		pg.game.chat:cancelTextTranslationOwner(self.mailTitleTranslationOwner)
		pg.game.chat:cancelTextTranslationOwner(self.mailContentTranslationOwner)
	end

	self.mailTranslationPendingCount = 0

	self.translateUWidget:SetActive(false)
end

function MailNewComponent:initMailList()
	function self.rewardListUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderMailRewards(button, index, data)
	end

	function self.mailListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local senderUBaseText = objectReference:GetRefValue("senderUBaseText")
		local timeUBaseText = objectReference:GetRefValue("timeUBaseText")
		local hasGift = pg.game.chat:checkMailHasGift(data)
		local giftStatus = 0

		if hasGift then
			giftStatus = data.Params.giftReceived and 1 or 0
		else
			giftStatus = 1
		end

		local readStatus = giftStatus == 1 and data.Params.haveRead and 1 or 0

		button:TryChangePage("MailAndReward", giftStatus)
		button:TryChangePage("MailState", readStatus)
		ClientTextUtils.setText(nameUBaseText, data.Title)
		ClientTextUtils.setText(timeUBaseText, LuaUIUtils.getCountDownString(data.RemoveTime - Time.secondCache, UIConst.TimeType.Short, true))

		local isGiftMail = tonumber(data.SrcId) == Const.MAIL_ID.SHOPMALL_GIVE_MAIL

		if isGiftMail then
			local giverName = self:getGiftMailGiverName(data)

			ClientTextUtils.setText(senderUBaseText, giverName)
		else
			ClientTextUtils.setText(senderUBaseText, data.SrcName)
		end

		self:trySetGiftMailGiverDisplayName(tonumber(data.SrcId), data, senderUBaseText)

		local items = self:getMailGiftItems(data)

		if isGiftMail then
			self:convertGiftMailItems(data, items)
		end

		local showReward = #items > 0

		if showReward then
			LuaUIUtils.renderMailRewards(rewardItemUButton, 0, items[1])
		end

		local treePath = string.format(RedDotConst.RedDotPath.FUNC_MENU_MAIL_LIST_ITEM, data.id)
		local isRewardMail = pg.game.chat:checkIsRewardMail(data.id)
		local isNewMail = pg.game.chat:checkIsNewMail(data.id)

		if isRewardMail then
			pg.global.setRedDot(treePath, button, isRewardMail, RedDotConst.RedDotStyle.REWARD)
		elseif isNewMail then
			pg.global.setRedDot(treePath, button, isNewMail, RedDotConst.RedDotStyle.NEW)
		else
			pg.global.setRedDot(treePath, button, false, RedDotConst.RedDotStyle.NONE)
		end

		function button.luaClick()
			if button.isSelected then
				local _, showDetailPage = self.uWidget:TryGetCurrentPage("ShowDetail")

				if showDetailPage == 1 then
					return
				end

				self:selectMail(index + 1)
			end
		end
	end

	function self.mailListUList.luaSelectedChanged(list)
		self:selectMail(list.selectedIndex + 1)
	end

	self.curSelectedMailIndex = 1

	local _h = MailNewComponent._platformHooks

	if _h and _h.initMailList then
		_h.initMailList(self)
	end
end

function MailNewComponent:selectMail(index)
	self.curSelectedMailIndex = index

	self:refreshMailContent()
	self.mailListUList:RefreshList()
	self.uWidget:TryChangePage("ShowDetail", 1)
end

local function mailSort(a, b)
	return a.CreatedTime > b.CreatedTime
end

function MailNewComponent:refreshMailList(indexDiff, initSelected)
	if indexDiff then
		self.curSelectedMailIndex = self.curSelectedMailIndex + indexDiff
	end

	local dataUnread = {}
	local dataUnReceive = {}
	local dataRead = {}

	for _, mail in ipairs(pg.game.chat.mailList) do
		if not mail.Params.haveRead then
			table.insert(dataUnread, mail)
		elseif pg.game.chat:checkMailHasGift(mail) and not mail.Params.giftReceived then
			table.insert(dataUnReceive, mail)
		else
			table.insert(dataRead, mail)
		end
	end

	table.sort(dataUnread, mailSort)
	table.sort(dataUnReceive, mailSort)
	table.sort(dataRead, mailSort)

	local data = dataUnread

	for _, value in ipairs(dataUnReceive) do
		table.insert(data, value)
	end

	for _, value in ipairs(dataRead) do
		table.insert(data, value)
	end

	if self.curSelectedMailIndex > #data or initSelected then
		self.curSelectedMailIndex = 1
	end

	self.transform:GetComponent("UComponent"):TryChangePage("Empty", #data > 0 and 0 or 1)
	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getFormatText(pg.getGameString("MAIL_TITLE"), #data, Const.MAIL.MAIL_CAPACITY))

	for index, mail in ipairs(data) do
		mail.selected = index == self.curSelectedMailIndex
	end

	self.mailDatas = data

	self.mailListUList:SetList(data)
	RewardStateUtils.applyClaimButton(self.btnAllReadUButton, pg.game.chat:checkHasRewardMail(), RedDotConst.RedDotPath.FUNC_MENU_MAIL, false, "claimAll")

	if #data > 0 then
		self.mailListUList:SelectItem(self.curSelectedMailIndex - 1)
	else
		self.uWidget:TryChangePage("ShowDetail", 0)
	end

	self.noMessageUWidget:SetActive(#data <= 0)
end

local function calcMailGifts(gifts)
	local idNumDict, petCreateInfo, customData = {}, {}, {}

	if gifts.items and type(gifts.items) == "table" then
		ItemUtils.mergeItemInfoResult(idNumDict, ItemUtils.formatIdNumBoundDict(gifts.items))
	end

	if gifts.pets then
		lume.append(petCreateInfo, gifts.pets)
	end

	if gifts.rewardIds then
		for i = 1, #gifts.rewardIds do
			local rewardId = gifts.rewardIds[i]
			local oneIdNumDict, onePetCreateInfo = DropUtils.genDropDisplayInfo(rewardId, true)

			ItemUtils.mergeItemInfoResult(idNumDict, oneIdNumDict)
			lume.append(petCreateInfo, onePetCreateInfo)
		end
	end

	if gifts.customData then
		customData = gifts.customData
	end

	return idNumDict, petCreateInfo, customData
end

function MailNewComponent:getMailGiftItems(mailData)
	if mailData.Params.giftInfo then
		local gifts = mailData.Params.giftInfo
		local items = {}

		if type(gifts) == "string" then
			gifts = ClientRepo.protoCodec:decode(gifts)
		end

		if Utils.isTable(gifts) == false then
			logger:error("Failed to parse mail gift info, mailId=%s, valueType=%s", tostring(mailData.MailId), type(gifts))

			return {}
		end

		local idNumDict, petCreateInfo, customData = calcMailGifts(gifts)

		if idNumDict then
			for itemId, numInfo in pairs(idNumDict) do
				local num = ItemUtils.getItemCountFromNumInfo(numInfo)

				table.insert(items, {
					tIndex = 0,
					type = 0,
					id = itemId,
					num = num,
					hasGet = mailData.Params.giftReceived
				})
			end
		end

		if petCreateInfo then
			for _, info in pairs(petCreateInfo) do
				table.insert(items, {
					tIndex = 0,
					num = 1,
					type = 1,
					petId = info.templateId,
					level = info.level,
					label = info.label,
					hasGet = mailData.Params.giftReceived
				})
			end
		end

		if customData then
			for _, data in ipairs(customData) do
				table.insert(items, {
					tIndex = 0,
					type = 0,
					id = data.itemId,
					num = data.count,
					hasGet = mailData.Params.giftReceived
				})
			end
		end

		return items
	end

	return {}
end

function MailNewComponent:refreshMailContent()
	local _h = MailNewComponent._platformHooks

	if _h and _h.refreshMailContent and _h.refreshMailContent(self) then
		return
	end

	local mailData = self.mailDatas[self.curSelectedMailIndex]

	self:refreshMailBanner(mailData)

	if mailData == nil then
		self:stopMailTranslation()
		self.uWidget:TryChangePage("ShowDetail", 0)
		RewardStateUtils.applyClaimButton(self.btnDetailConfirmUButton, false, RedDotConst.RedDotPath.FUNC_MENU_MAIL, false, "detailClaim")

		return
	end

	self.uWidget:TryChangePage("ShowDetail", 1)

	local isGiftMail = self:refreshMailActionState(mailData)

	self:refreshMailHeader(mailData, isGiftMail)
	self:refreshMailBody(mailData, isGiftMail)
	self:markMailRead(mailData)
end

function MailNewComponent:refreshMailBanner(mailData)
	local bannerFrame = mailData and mailData.Params[Const.MAIL.PARAMS.BANNER_FRAME]
	local hasBanner = not string.isNilOrEmpty(bannerFrame)

	self.mailDetailUComponent:TryChangePage("Image", hasBanner and 1 or 0)

	self.bannerFrame = bannerFrame
	self.bannerUImage.url = nil
	self.bannerUImage.sprite = nil

	if not hasBanner then
		return
	end

	local bannerSprite = self.bannerSprites[bannerFrame]

	if bannerSprite then
		self.bannerUImage.sprite = bannerSprite

		return
	end

	if self.bannerLoadingUrls[bannerFrame] then
		return
	end

	local bannerSprites = self.bannerSprites
	local bannerLoadingUrls = self.bannerLoadingUrls

	bannerLoadingUrls[bannerFrame] = true

	UIUtils.SetTextureByUrl(bannerFrame, function(sprite)
		if self.bannerSprites ~= bannerSprites or IsNil(self.bannerUImage) then
			if sprite then
				pg.global.uiMgr:ReleaseTexture2D(sprite.texture)
			end

			return
		end

		bannerLoadingUrls[bannerFrame] = nil

		if not sprite then
			return
		end

		bannerSprites[bannerFrame] = sprite

		if self.bannerFrame == bannerFrame then
			self.bannerUImage.sprite = sprite
		end
	end)
end

function MailNewComponent:refreshMailActionState(mailData)
	local isGiftMail = tonumber(mailData.SrcId) == Const.MAIL_ID.SHOPMALL_GIVE_MAIL
	local hasGift = pg.game.chat:checkMailHasGift(mailData)
	local canClaim = hasGift and not mailData.Params.giftReceived

	self.btnDetailDeleteUButton:SetActive(not hasGift or mailData.Params.giftReceived == nil or mailData.Params.giftReceived == true)
	self.btnDetailConfirmUButton:SetActive(canClaim)
	RewardStateUtils.applyClaimButton(self.btnDetailConfirmUButton, canClaim, RedDotConst.RedDotPath.FUNC_MENU_MAIL, false, "detailClaim")

	local btnDetailConfirmObjRef = self.btnDetailConfirmUButton:GetComponent("ObjectReference")
	local btnDetailConfirmText = btnDetailConfirmObjRef:GetRefValue("txtNameUText")

	if isGiftMail then
		ClientTextUtils.setText(btnDetailConfirmText, pg.getGameString("SHOP_GIFT_OPEN"))
	else
		ClientTextUtils.setText(btnDetailConfirmText, pg.getGameString("QUEST_DELEGATION_CLAIM"))
	end

	return isGiftMail
end

function MailNewComponent:refreshMailHeader(mailData, isGiftMail)
	ClientTextUtils.setText(self.detailTitleUSDFText, mailData.Title)

	if isGiftMail then
		local giverName = self:getGiftMailGiverName(mailData)

		ClientTextUtils.setText(self.detailAddresserNameUSDFText, giverName)
	else
		ClientTextUtils.setText(self.detailAddresserNameUSDFText, mailData.SrcName)
	end

	self:trySetGiftMailGiverDisplayName(tonumber(mailData.SrcId), mailData, self.detailAddresserNameUSDFText)
	ClientTextUtils.setText(self.textTimeUSDFText, pg.getLocalizationTimeYMD(mailData.CreatedTime, true))
end

function MailNewComponent:refreshMailBody(mailData, isGiftMail)
	local mailContent = pg.game.chat.mailContent[mailData.MailId]

	if mailContent == nil and type(pg.game.chat.requestMailContent) == "function" then
		pg.game.chat:requestMailContent(mailData.MailId, {
			highPriority = true
		})
	end

	local content = string.gsub(mailContent or "", "\\n", "\n")
	local contentText = self.detailScrollRect.content:GetComponent("UBaseText")

	contentText.enabledHyperlink = true

	function contentText.luaOnHyperlinkClick(action, content2, contentRect)
		LuaUIUtils.clickHyperText(action, content2, contentRect)
	end

	local items = self:getMailGiftItems(mailData)

	if isGiftMail then
		self:convertGiftMailItems(mailData, items)
	end

	self.mailDetailUComponent:TryChangePage("HaveOrNot", #items > 0 and 0 or 1)

	local displayContent = content
	local isSpecialGiftMail = tonumber(mailData.SrcId) == SPECIAL_GIFT_MAIL_SOURCE_ID

	if (isSpecialGiftMail or isGiftMail) and #items > 0 and ItemData[items[1].id] then
		local itemConfig = ItemData[items[1].id]
		local senderName = isGiftMail and self:getGiftMailGiverName(mailData) or mailData.SrcName
		local itemName = pg.getLocalizationText(itemConfig.itemName)

		displayContent = string.format(content, senderName, itemName)
	end

	ClientTextUtils.setText(contentText, displayContent)
	self:refreshMailTranslation(mailData, displayContent, mailContent ~= nil)
	self.rewardListUList:SetList(items)
end

function MailNewComponent:markMailRead(mailData)
	if not mailData.Params.haveRead then
		mailData.Params.haveRead = true

		pg.me:setMailHaveRead(mailData.MailId)
	end

	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function MailNewComponent:refreshMailTranslation(mailData, content, contentLoaded)
	if not self.mailTranslationSelected then
		return
	end

	local sourceLanguage = mailData.Params.mailLanguage

	if string.isNilOrEmpty(sourceLanguage) then
		local isCn = ClientConfigAppCountry == "cn"

		sourceLanguage = isCn and "zh_CN" or "en"
	end

	local mailId = mailData.MailId
	local targetLanguage = pg.game.setting:getLanguage()

	self:startMailTranslation()

	local titleCallback = CallbackHandler(self, "onMailTitleTranslated", mailId, targetLanguage)
	local titleStarted = pg.game.chat:translateText(mailData.Title, sourceLanguage, titleCallback, self.mailTitleTranslationOwner)

	if not titleStarted then
		self:stopMailTranslation()

		return
	end

	if not contentLoaded then
		return
	end

	local contentCallback = CallbackHandler(self, "onMailContentTranslated", mailId, targetLanguage)
	local contentStarted = pg.game.chat:translateText(content, sourceLanguage, contentCallback, self.mailContentTranslationOwner)

	if not contentStarted then
		self:stopMailTranslation()
	end
end

function MailNewComponent:startMailTranslation()
	self:stopMailTranslation()

	self.mailTranslationPendingCount = 2

	ClientTextUtils.setText(self.translateUSDFText, pg.getGameString("AI_TRANSLATING"))
	self.translateUWidget:SetActive(true)
end

function MailNewComponent:isCurrentMailTranslation(mailId, targetLanguage)
	local translationActive = self.ctrl ~= nil and self.mailTranslationSelected and self.mailTranslationPendingCount > 0

	if not translationActive then
		return false
	end

	local selectedMailData = self.mailDatas[self.curSelectedMailIndex]

	return selectedMailData ~= nil and selectedMailData.MailId == mailId and pg.game.setting:getLanguage() == targetLanguage
end

function MailNewComponent:completeMailTranslationPart()
	self.mailTranslationPendingCount = self.mailTranslationPendingCount - 1

	if self.mailTranslationPendingCount == 0 then
		ClientTextUtils.setText(self.translateUSDFText, pg.getGameString("AI_TRANSLATED"))
	end
end

function MailNewComponent:onMailTitleTranslated(mailId, targetLanguage, success, translatedTitle)
	if not self:isCurrentMailTranslation(mailId, targetLanguage) then
		return
	end

	if success ~= true then
		self:stopMailTranslation()

		return
	end

	ClientTextUtils.setText(self.detailTitleUSDFText, translatedTitle)
	self:completeMailTranslationPart()
end

function MailNewComponent:onMailContentTranslated(mailId, targetLanguage, success, translatedText)
	if not self:isCurrentMailTranslation(mailId, targetLanguage) then
		return
	end

	if success ~= true then
		self:stopMailTranslation()

		return
	end

	local contentText = self.detailScrollRect.content:GetComponent("UBaseText")

	ClientTextUtils.setText(contentText, translatedText)
	self:completeMailTranslationPart()
end

function MailNewComponent:buildGiftReceiveInfo(mailData)
	local info = {
		mail = mailData
	}

	if mailData.Params and mailData.Params.giftInfo then
		local gifts = mailData.Params.giftInfo

		if type(gifts) == "string" then
			gifts = ClientRepo.protoCodec:decode(gifts)
		end

		if gifts.customData then
			info.giverUid = gifts.customData.giverUid
			info.blessTxt = gifts.customData.blessTxt
			info.commodityId = gifts.customData.commodityId
			info.rechargeId = gifts.customData.rechargeId
		end

		if gifts.items then
			local giftItems = {}

			for itemId, num in pairs(gifts.items) do
				info.id = info.id or itemId
				info.num = info.num or num

				table.insert(giftItems, {
					id = itemId,
					num = num
				})
			end

			info.giftItems = giftItems
		end
	end

	return info
end

function MailNewComponent:getGiftMailRechargeId(mailData)
	if not mailData.Params or not mailData.Params.giftInfo then
		return nil
	end

	local gifts = mailData.Params.giftInfo

	if type(gifts) == "string" then
		gifts = ClientRepo.protoCodec:decode(gifts)
	end

	if gifts.customData then
		return gifts.customData.rechargeId
	end

	return nil
end

function MailNewComponent:convertGiftMailItems(mailData, items)
	if self:getGiftMailRechargeId(mailData) then
		return
	end

	for _, item in ipairs(items) do
		local replacedTable = ItemUtils.getReplacedItemCountTable(pg.me, {
			[item.id] = item.num
		})

		if replacedTable then
			local newId = next(replacedTable)

			if newId then
				item.id = newId
			end
		end
	end
end

function MailNewComponent:getGiftMailGiverName(mailData)
	if not mailData.Params or not mailData.Params.giftInfo then
		return mailData.SrcName or ""
	end

	local gifts = mailData.Params.giftInfo

	if type(gifts) == "string" then
		gifts = ClientRepo.protoCodec:decode(gifts)
	end

	if gifts.customData and gifts.customData.giverUid then
		local playerInfo = pg.game.chat:getPlayerInfo(tostring(gifts.customData.giverUid))

		if playerInfo and playerInfo.playerName then
			local playerName = playerInfo.playerName
			local _h = MailNewComponent._platformHooks

			if _h and _h.getGiftMailGiverName then
				playerName = _h.getGiftMailGiverName(self, mailData, playerName)
			end

			return playerName
		end
	end

	return mailData.SrcName and ClientTextUtils.getLocalizationText(mailData.SrcName) or ""
end

function MailNewComponent:trySetGiftMailGiverDisplayName(srcId, mailData, senderUBaseText)
	if srcId == Const.MAIL_ID.SHOPMALL_GIVE_MAIL or srcId == Const.MAIL_ID.FRIEND_GIFT then
		local _h = MailNewComponent._platformHooks

		if _h and _h.getGiftMailGiverDisplayName then
			local giverName = self:getGiftMailGiverName(mailData)
			local displayName = _h.getGiftMailGiverDisplayName(self, mailData, giverName)

			senderUBaseText.supportRichText = true

			ClientTextUtils.setText(senderUBaseText, displayName)
		end
	end
end

function MailNewComponent:setAutoDeleteReadMails(isNeed)
	return pg.global.prefsCacheUtils:setBool(pg.me.uid .. "AutoDeleteReadMails", isNeed)
end

function MailNewComponent:getAutoDeleteReadMails()
	return pg.global.prefsCacheUtils:getBool(pg.me.uid .. "AutoDeleteReadMails", false)
end

function MailNewComponent:tryDeleteReadMails()
	local autoDeleteReadMails = self:getAutoDeleteReadMails()

	if autoDeleteReadMails == false then
		return
	end

	local mailDatas = self.mailDatas
	local chatSystem = pg.game.chat
	local checkMailHasRead = pg.game.chat.checkMailHasRead
	local hasReadMail = false

	for index, mailData in ipairs(mailDatas) do
		hasReadMail = checkMailHasRead(chatSystem, mailData)

		if hasReadMail then
			break
		end
	end

	if hasReadMail == false then
		return
	end

	pg.me:deleteReadedMail()
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function MailNewComponent:onHide()
	self:tryDeleteReadMails()
end

function MailNewComponent:onClose()
	self:tryDeleteReadMails()
end

return MailNewComponent
