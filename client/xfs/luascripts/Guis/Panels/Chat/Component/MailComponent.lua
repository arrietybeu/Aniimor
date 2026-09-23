-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\MailComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local ItemUtils = require("Common.Utils.ItemUtils")
local DropUtils = require("Common.Utils.DropUtils")
local ClientRepo = require("Core.Client.ClientRepo")
local MailComponent = Class.LightClass("MailComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")

function MailComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.mailListUList = self.objectReference:GetRefValue("mailListUList")
	self.mailCountUText = self.objectReference:GetRefValue("mailCountUText")
	self.mailCountLimitUText = self.objectReference:GetRefValue("mailCountLimitUText")
	self.btnDelAllMailUButton = self.objectReference:GetRefValue("btnDelAllMailUButton")
	self.btnReciveAllMailUButton = self.objectReference:GetRefValue("btnReciveAllMailUButton")
	self.mailTitleUText = self.objectReference:GetRefValue("mailTitleUText")
	self.mailTimeUText = self.objectReference:GetRefValue("mailTimeUText")
	self.mailSenderUText = self.objectReference:GetRefValue("mailSenderUText")
	self.mailContentUComponent = self.objectReference:GetRefValue("mailContentUComponent")
	self.mailRewardItemListUList = self.objectReference:GetRefValue("mailRewardItemListUList")
	self.btnDeleteMailUButton = self.objectReference:GetRefValue("btnDeleteMailUButton")
	self.btnReceiveMailUButton = self.objectReference:GetRefValue("btnReceiveMailUButton")
	self.textContentUScrollRect = self.objectReference:GetRefValue("textContentUScrollRect")
end

function MailComponent:initView()
	function self.btnDelAllMailUButton.luaClick()
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("MAIL_DELETE_ALL_MAIL"), function()
			pg.me:deleteReadedMail()
		end, nil)
	end

	function self.btnReciveAllMailUButton.luaClick()
		pg.me:setAllMailGiftReceived()
	end

	function self.btnDeleteMailUButton.luaClick()
		local mailData = self.mailDatas[self.curSelectedMailIndex]

		if mailData ~= nil then
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("MAIL_DELETE_CURRENT_MAIL"), function()
				pg.me:deleteMail({
					mailData.MailId
				})
			end, nil)
		end
	end

	function self.btnReceiveMailUButton.luaClick()
		local mailData = self.mailDatas[self.curSelectedMailIndex]

		if mailData ~= nil then
			pg.me:setMailGiftReceived({
				mailData.MailId
			})
		end
	end

	ClientTextUtils.setText(self.mailCountLimitUText, "/", Const.MAIL.MAIL_CAPACITY)

	self.mailDatas = {}

	self:initMailList()
end

function MailComponent:initMailList()
	function self.mailRewardItemListUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewards(button, index, data)
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
			giftStatus = data.Params.giftReceived and 2 or 1
		end

		button:TryChangePage("Gift", giftStatus)

		local isSelected = self.curSelectedMailIndex == index + 1

		if isSelected then
			if giftStatus == 0 or giftStatus == 2 then
				button:TryChangePage("Readed", 3)
			else
				button:TryChangePage("Readed", 2)
			end
		elseif giftStatus == 0 and data.Params.haveRead or giftStatus == 2 then
			button:TryChangePage("Readed", 4)
		elseif giftStatus == 1 then
			button:TryChangePage("Readed", 0)
		elseif not data.Params.haveRead then
			button:TryChangePage("Readed", 1)
		end

		ClientTextUtils.setText(nameUBaseText, data.Title)
		ClientTextUtils.setText(senderUBaseText, data.SrcName)
		ClientTextUtils.setText(timeUBaseText, LuaUIUtils.getCountDownString(data.RemoveTime - Time.secondCache, UIConst.TimeType.Short, true))

		local items = self:getMailGiftItems(data)
		local showReward = #items > 0

		if showReward then
			LuaUIUtils.renderRewards(rewardItemUButton, 0, items[1])
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
	end

	function self.mailListUList.luaClick(button, data)
		self.curSelectedMailIndex = self.mailListUList:GetChildIndex(button) + 1

		self:refreshMailContent()
		self.mailListUList:RefreshList()
	end

	self.curSelectedMailIndex = 1

	self:refreshMailList()
	self:refreshMailContent()

	local _, button = self.mailListUList:TryGetChildAt(0)

	if button then
		button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

local function mailSort(a, b)
	return a.CreatedTime > b.CreatedTime
end

function MailComponent:refreshMailList(indexDiff)
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

	if self.curSelectedMailIndex > #data then
		self.curSelectedMailIndex = 1
	end

	self.transform:GetComponent("UComponent"):TryChangePage("Empty", #data > 0 and 0 or 1)
	ClientTextUtils.setText(self.mailCountUText, tostring(#data))

	self.mailDatas = data

	self.mailListUList:SetList(data)

	if #data >= self.curSelectedMailIndex and data[self.curSelectedMailIndex] ~= nil then
		self.mailListUList:SelectItem(self.curSelectedMailIndex - 1, false)
	end

	self.btnReciveAllMailUButton.interactable = pg.game.chat:checkHasRewardMail()
end

local function calcMailGifts(gifts)
	local idNumDict, petCreateInfo = {}, {}

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

	return idNumDict, petCreateInfo
end

function MailComponent:refreshMailContent(playAni)
	local mailData = self.mailDatas[self.curSelectedMailIndex]

	if mailData == nil then
		return
	end

	local mailType = 0

	if pg.game.chat:checkMailHasGift(mailData) then
		mailType = mailData.Params.giftReceived and 2 or 1
	end

	self.mailContentUComponent:TryChangePage("MailType", mailType)
	ClientTextUtils.setText(self.mailTitleUText, mailData.Title)
	ClientTextUtils.setText(self.mailSenderUText, mailData.SrcName)
	ClientTextUtils.setText(self.mailTimeUText, ClientTextUtils.concatByLanguage(pg.getGameString("MAIL_VALID_TIME"), LuaUIUtils.getCountDownString(mailData.RemoveTime - Time.secondCache, UIConst.TimeType.Short, true)))

	if pg.game.chat.mailContent[mailData.MailId] == nil and type(pg.game.chat.requestMailContent) == "function" then
		pg.game.chat:requestMailContent(mailData.MailId, {
			highPriority = true
		})
	end

	local content = string.gsub(pg.game.chat.mailContent[mailData.MailId] or "", "\\n", "\n")
	local contentText = self.textContentUScrollRect.content:GetComponent("UBaseText")

	ClientTextUtils.setText(contentText, content)

	function contentText.luaOnHyperlinkClick(action, content, contentRect)
		LuaUIUtils.clickHyperText(action, content, contentRect)
	end

	self.mailRewardItemListUList:SetList(self:getMailGiftItems(mailData))

	if playAni then
		self.transform:GetComponent("Animation"):Play()
	end

	if not mailData.Params.haveRead then
		mailData.Params.haveRead = true

		pg.me:setMailHaveRead(mailData.MailId)
	end
end

function MailComponent:getMailGiftItems(mailData)
	if mailData.Params.giftInfo then
		local gifts = mailData.Params.giftInfo
		local items = {}

		if type(gifts) == "string" then
			gifts = ClientRepo.protoCodec:decode(gifts)
		end

		local idNumDict, petCreateInfo = calcMailGifts(gifts)

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
					type = 1,
					num = 1,
					petId = info.templateId,
					level = info.level,
					label = info.label,
					hasGet = mailData.Params.giftReceived
				})
			end
		end

		return items
	end

	return {}
end

return MailComponent
