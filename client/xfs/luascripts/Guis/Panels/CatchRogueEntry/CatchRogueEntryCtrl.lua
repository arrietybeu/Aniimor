-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRogueEntry\\CatchRogueEntryCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueEntryCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local EventCatchRogueData = require("Data.event_catch_rogue_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local LimitData = require("Data.limit_data")
local NoticeDef = require("Common.NoticeDef")
local PetData = require("Data.pet_data")
local CatchRogueEntryCtrl = Class.LightClass("CatchRogueEntryCtrl", UICtrl)

CatchRogueEntryCtrl.messages = {
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItems",
		true
	},
	[MessageName.UI_ON_SHOW] = {
		"onUIShow",
		true
	}
}

function CatchRogueEntryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CatchRogueEntryCtrl:addListener()
	function self.view.listElementUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.element)
	end

	function self.view.catchPetBtnInfo.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_PET_PREVIEW, {
			templateIds = CatchRoguePhaseData[self.gameId].catchpetType,
			title = pg.getGameString("CATCH_ROGUE_SHOW_PET")
		})
	end

	function self.view.rewardBtnInfo.luaRenderTooltip(button, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local txt = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txt, pg.getGameString("CATCH_ROGUE_HELP_REWARD"))
	end

	function self.view.catchPetUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderCatchRogueCommonPet(button, index, data)
	end

	function self.view.rewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.view.btnComfirmUButton.luaClick()
		self.view.rootComponent:TryChangePage("State", "Game")
	end

	function self.view.specialItemUList.luaRenderItem(button, index, data)
		self:renderSpecialCatchBall(button, index, data)
	end

	function self.view.shopBtn.luaClick()
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = {
				36
			}
		})
	end

	function self.view.commonItemUList.luaRenderItem(button, index, data)
		self:renderCommonCatchBall(button, index, data)
	end

	function self.view.commonItemBtnInfoUButton.luaClick()
		local itemInfo, curCnt, totalCnt = self.model:getAllCatchRogueCommonBall(self.gameId, self.tempCommonBallInfo)

		pg.global.ui:open(UIConst.UI_ID_COMMON_PANELLEFT_ITEM_SEL, {
			title = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_BALL"),
			fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
			itemList = itemInfo,
			maxCnt = totalCnt,
			curCnt = curCnt,
			refreshCb = function(ballInfo)
				self.tempCommonBallInfo = ballInfo

				self:refreshUI()
			end,
			leftBtnTxt = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_CLEAR"),
			rightBtnTxt = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_ONE_CLICK")
		})
	end

	function self.view.listPreparePetUList.luaRenderItem(button, index, data)
		self:renderPet(button, index, data)
	end

	function self.view.btnSearchUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_PET_PREVIEW, {
			templateIds = CatchRoguePhaseData[self.gameId].catchpetType,
			title = pg.getGameString("CATCH_ROGUE_SHOW_PET")
		})
	end

	function self.view.preparePetBtnInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_SELECT_PET, {
			fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
			levelId = self.gameId,
			inputPetList = self.tempPetInfo
		})
	end

	function self.view.btnAbandonUButton.luaClick()
		pg.me:settleCatchRogueGame(true, nil, function(noticeId, noticeArgs)
			if noticeId ~= NoticeDef.SUCCESS then
				pg.global.showBubbleMessageById(noticeId, noticeArgs)
			end

			self:refreshAll()
		end)
	end

	function self.view.btnStartUButton.luaClick()
		if self.resumeGame then
			local lackBallInfo = self.model:getLackCommonCatchRogueBallInfo()

			if #lackBallInfo > 0 then
				pg.global.showCommonTipUse(pg.getGameString("CATCH_ROGUE_LEAVE_BALL_CONFIRM"), pg.getGameString("CATCH_ROGUE_LEAVE_TIP"), lackBallInfo, function()
					self:startCatchRogue()
				end, nil)
			else
				self:startCatchRogue()
			end
		else
			self:startCatchRogue()
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end
end

function CatchRogueEntryCtrl:onDestroy()
	if not self.resumeGame and pg.me:canPrepareGame() then
		local petIds = {}

		for index, petId in ipairs(self.tempPetInfo or EMPTY_TABLE) do
			table.insert(petIds, petId)
		end

		if #petIds > 0 then
			pg.me:modifyCatchRoguePets(petIds)
		end
	end

	self.tempCommonBallInfo = {}
	self.tempPetInfo = {}

	pg.global.ui:close(UIConst.UI_ID_COMMON_PANELLEFT_ITEM_SEL)
	UICtrl.onDestroy(self)
end

function CatchRogueEntryCtrl:checkCanOpen(showNotice, data)
	local gameId = self.model:getCurCatchRogueInfo()

	if not gameId then
		return false
	end

	return UICtrl.checkCanOpen(self, showNotice, data)
end

function CatchRogueEntryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshAll()
end

function CatchRogueEntryCtrl:refreshAll()
	self.gameId = self.model:getCurCatchRogueInfo()
	self.resumeGame = pg.me:isPlayCatchRogue()

	if self.resumeGame then
		self:refreshTempData()
	else
		self.tempPetInfo = pg.me:getCatchRoguePreparePetList()
		self.tempCommonBallInfo = {}
	end

	self:initUI()
end

function CatchRogueEntryCtrl:setTempInfo(tempPetList, tempBallList)
	if tempPetList then
		self.tempPetInfo = tempPetList
	end

	if tempBallList then
		self.tempCommonBallInfo = tempBallList
	end
end

function CatchRogueEntryCtrl:refreshTempData()
	self.tempPetInfo = pg.me.catchRogueInfo:getValidPetList(pg.me)

	local tempBallList = pg.me.catchRogueInfo:getValidBallList(pg.me)

	self.tempCommonBallInfo = {}

	for index, itemId in ipairs(tempBallList) do
		if not table.contains(CatchRoguePhaseData[self.gameId].gameBallType, itemId) then
			local cnt = pg.me.catchRogueInfo:getValidBallCount(pg.me, itemId)

			table.insert(self.tempCommonBallInfo, {
				itemId = itemId,
				cnt = cnt
			})
		end
	end
end

function CatchRogueEntryCtrl:initUI()
	self.view.elementBigUButton:TryChangePage("type", CatchRoguePhaseData[self.gameId].gameType[1])
	self.view.rootComponent:TryChangePage("State", self.resumeGame and "Game" or "Main")

	self.view.catchPetBtnInfo.enabledTooltip = false

	for i = 1, 3 do
		local uContainer = self.view["pet" .. i .. "UContainer"]

		if not uContainer then
			return
		end

		if uContainer:CheckURLLoaded() then
			LuaUIUtils.renderCatchRogueCenterPet(i, uContainer.content, self.gameId)
		else
			uContainer:LoadDefaultUrlManually(function(content)
				LuaUIUtils.renderCatchRogueCenterPet(i, uContainer.content, self.gameId)
			end)
		end
	end

	ClientTextUtils.setText(self.view.textTitleUBaseText, pg.getLocalizationText(CatchRoguePhaseData[self.gameId].trainTitle))

	local elements = self.model:getCatchRogueElementList(self.gameId)

	self.view.listElementUList:SetList(elements)

	local commonPetList = self.model:getCatchRogueCommonPetList(self.gameId)

	self.view.catchPetUList:SetList(commonPetList)

	local catchRogueData = CatchRoguePhaseData[self.gameId]
	local rewards = LuaUIUtils.getRewardItemByDropId(catchRogueData.trainReward1)

	self.view.rewardUList:SetList(rewards)

	local btnStartTxt = self.view.btnStartUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnStartTxt, pg.getGameString("CATCH_ROGUE_ENTER"))

	local btnAbandonTxt = self.view.btnAbandonUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnAbandonTxt, pg.getGameString("CATCH_ROGUE_LEAVE"))
	self.view.btnAbandonUButton:SetActive(self.resumeGame == true)
	self.view.shopBtn:SetActive(self.resumeGame ~= true)
	self.view.commonItemBtnInfoUButton:SetActive(self.resumeGame ~= true)
	self.view.preparePetBtnInfoUButton:SetActive(self.resumeGame ~= true)

	if self.resumeGame then
		ClientTextUtils.setText(self.view.textTipsRemainUBaseText, string.format(pg.getGameString("CATCH_ROGUE_LEAVE_LEVEL"), pg.me.catchRogueInfo.floorId))
	else
		local remainCnt, totalCnt = self.model:getCatchRogueRemainInfo(self.gameId)

		ClientTextUtils.setText(self.view.textTipsRemainUBaseText, string.format(pg.getGameString("CATCH_ROGUE_CHALLENGE_QUANTITY"), remainCnt, totalCnt))
	end

	self.view.itemInfoSpecialUWidget:SetActive(pg.me:getCatchRogueBuyEnable() == true)

	if pg.me:getCatchRogueBuyEnable() == true then
		local specialItemList = self.model:getCatchRogueSpecialBall(self.gameId)

		self.view.specialItemUList:SetList(specialItemList)

		local totalCnt = 0

		for _, item in ipairs(specialItemList) do
			if item.num then
				totalCnt = totalCnt + item.num
			end
		end

		ClientTextUtils.setText(self.view.specialItemNumTxt, totalCnt)
	end

	local commonItemList, curBallCnt, totalBallCnt = self.model:getCurCatchRogueCommonBall(self.gameId, self.tempCommonBallInfo)

	self.view.commonItemUList:SetList(commonItemList)
	ClientTextUtils.setText(self.view.commonItemNumTxt, string.format("%s/%s", curBallCnt, totalBallCnt))

	local petList = self.model:getCatchRoguePetList(self.gameId, self.tempPetInfo)

	self.view.listPreparePetUList:SetList(petList)
end

function CatchRogueEntryCtrl:refreshUI()
	if self.resumeGame then
		ClientTextUtils.setText(self.view.textTipsRemainUBaseText, string.format(pg.getGameString("CATCH_ROGUE_LEAVE_LEVEL"), pg.me.catchRogueInfo.floorId))
	else
		local remainCnt, totalCnt = self.model:getCatchRogueRemainInfo(self.gameId)

		ClientTextUtils.setText(self.view.textTipsRemainUBaseText, string.format(pg.getGameString("CATCH_ROGUE_CHALLENGE_QUANTITY"), remainCnt, totalCnt))
	end

	self.view.itemInfoSpecialUWidget:SetActive(pg.me:getCatchRogueBuyEnable() == true)

	if pg.me:getCatchRogueBuyEnable() == true then
		local specialItemList = self.model:getCatchRogueSpecialBall(self.gameId)

		self.view.specialItemUList:SetList(specialItemList)

		local totalCnt = 0

		for _, item in ipairs(specialItemList) do
			if item.num then
				totalCnt = totalCnt + item.num
			end
		end

		ClientTextUtils.setText(self.view.specialItemNumTxt, totalCnt)
	end

	local commonItemList, curBallCnt, totalBallCnt = self.model:getCurCatchRogueCommonBall(self.gameId, self.tempCommonBallInfo)

	self.view.commonItemUList:SetList(commonItemList)
	ClientTextUtils.setText(self.view.commonItemNumTxt, string.format("%s/%s", curBallCnt, totalBallCnt))

	local petList = self.model:getCatchRoguePetList(self.gameId, self.tempPetInfo)

	self.view.listPreparePetUList:SetList(petList)
end

function CatchRogueEntryCtrl:onShow()
	self:refreshUI()
end

function CatchRogueEntryCtrl:onHide()
	return
end

function CatchRogueEntryCtrl:renderSpecialCatchBall(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	button.draggable = false
	button.enabledTooltip = false

	if data.tIndex == 0 then
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
		local imgDisableUImage = objectReference:GetRefValue("imgDisableUImage")
		local exclusiveUContainer = objectReference:GetRefValue("exclusiveUContainer")

		itemIconUImage.url = data.icon

		ClientTextUtils.setText(txtNumUBaseText, data.num)
		exclusiveUContainer:SetActive(data.isSpecial)

		if data.isSpecial then
			exclusiveUContainer:LoadDefaultUrlManually()
		end
	elseif data.tIndex == 1 then
		-- block empty
	end
end

function CatchRogueEntryCtrl:renderCommonCatchBall(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	button.draggable = false
	button.enabledTooltip = false

	if data.tIndex == 0 then
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
		local imgDisableUImage = objectReference:GetRefValue("imgDisableUImage")
		local exclusiveUContainer = objectReference:GetRefValue("exclusiveUContainer")

		itemIconUImage.url = data.icon

		ClientTextUtils.setText(txtNumUBaseText, data.num)
		exclusiveUContainer:SetActive(data.isSpecial)

		if data.isSpecial then
			exclusiveUContainer:LoadDefaultUrlManually()
		end

		function button.luaClick()
			if not self.resumeGame then
				local itemInfo, curCnt, totalCnt = self.model:getAllCatchRogueCommonBall(self.gameId, self.tempCommonBallInfo)

				pg.global.ui:open(UIConst.UI_ID_COMMON_PANELLEFT_ITEM_SEL, {
					title = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_BALL"),
					fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
					itemList = itemInfo,
					maxCnt = totalCnt,
					curCnt = curCnt,
					refreshCb = function(ballInfo)
						self.tempCommonBallInfo = ballInfo

						self:refreshUI()
					end,
					leftBtnTxt = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_CLEAR"),
					rightBtnTxt = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_ONE_CLICK")
				})
			end
		end
	elseif data.tIndex == 1 then
		function button.luaClick()
			local itemInfo, curCnt, totalCnt = self.model:getAllCatchRogueCommonBall(self.gameId, self.tempCommonBallInfo)

			pg.global.ui:open(UIConst.UI_ID_COMMON_PANELLEFT_ITEM_SEL, {
				title = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_BALL"),
				fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
				itemList = itemInfo,
				maxCnt = totalCnt,
				curCnt = curCnt,
				refreshCb = function(ballInfo)
					self.tempCommonBallInfo = ballInfo

					self:refreshUI()
				end,
				leftBtnTxt = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_CLEAR"),
				rightBtnTxt = pg.getGameString("CATCH_ROGUE_CARRY_INTERFACE_ONE_CLICK")
			})
		end
	elseif data.tIndex == 2 then
		-- block empty
	end
end

function CatchRogueEntryCtrl:renderPet(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	button.draggable = false
	button.enabledTooltip = false

	if data.tIndex == 0 then
		local icon = objectReference:GetRefValue("iconUImage")
		local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
		local cData = PetData[data.templateId] or {}
		local petIcon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON)

		icon.url = petIcon

		function button.luaClick()
			if not self.resumeGame then
				pg.global.ui:open(UIConst.UI_ID_TOWER_SELECT_PET, {
					fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
					levelId = self.gameId,
					inputPetList = self.tempPetInfo
				})
			end
		end

		panelCPUContainer:LoadDefaultUrlManually(function(obj)
			local objectReference1 = obj.transform:GetComponent("ObjectReference")
			local numCPUText = objectReference1:GetRefValue("numCPUSDFText")
			local singleElement = objectReference1:GetRefValue("singleElement")
			local doubleElement1 = objectReference1:GetRefValue("doubleElement1")
			local doubleElement2 = objectReference1:GetRefValue("doubleElement2")
			local _, names = LuaUIUtils.getElementInfo(cData.elementType)
			local elementCount = #names

			if elementCount == 0 then
				panelCPUContainer.content:TryChangePage("DetailState", 0)
				LuaUIUtils.setUIViewVisible(singleElement, false)
			elseif elementCount == 1 then
				panelCPUContainer.content:TryChangePage("DetailState", 0)
				LuaUIUtils.setUIViewVisible(singleElement, true)
				LuaUIUtils.setElementButtonNew(singleElement, names[1].element)
			else
				panelCPUContainer.content:TryChangePage("DetailState", 1)
				LuaUIUtils.setElementButtonNew(doubleElement1, names[1].element)
				LuaUIUtils.setElementButtonNew(doubleElement2, names[2].element)
			end

			local level = 30
			local cp = data.petInfo:getCpValueWithLevel(level)

			ClientTextUtils.setText(numCPUText, "CP:" .. cp)
		end)
	elseif data.tIndex == 1 then
		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_TOWER_SELECT_PET, {
				fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
				levelId = self.gameId,
				inputPetList = self.tempPetInfo
			})
		end
	elseif data.tIndex == 2 then
		-- block empty
	end
end

function CatchRogueEntryCtrl:startCatchRogue()
	local petIds = {}
	local noticeId
	local remainCnt, totalCnt = self.model:getCatchRogueRemainInfo(self.gameId)

	if remainCnt <= 0 then
		noticeId = NoticeDef.CATCH_ROGUE_CNT_LIMIT

		pg.global.showBubbleMessageById(noticeId)

		return
	end

	for index, petId in ipairs(self.tempPetInfo or EMPTY_TABLE) do
		table.insert(petIds, petId)
	end

	if #petIds <= 0 then
		noticeId = NoticeDef.CATCH_ROGUE_PETS_EMPTY

		pg.global.showBubbleMessageById(noticeId)

		return
	end

	if not self.resumeGame then
		pg.me:modifyCatchRoguePets(petIds)
	end

	local ballIds = {}
	local ballCountMap = {}

	for index, info in ipairs(self.tempCommonBallInfo or EMPTY_TABLE) do
		local itemId = info.itemId
		local cnt = info.cnt

		table.insert(ballIds, itemId)

		ballCountMap[itemId] = cnt
	end

	if pg.me:getCatchRogueBuyEnable() == true then
		local specialItemList = self.model:getCatchRogueSpecialBall(self.gameId)

		for index, info in ipairs(specialItemList or EMPTY_TABLE) do
			if info.itemId then
				local itemId = info.itemId
				local cnt = info.num

				table.insert(ballIds, itemId)

				ballCountMap[itemId] = cnt
			end
		end
	end

	if #ballIds <= 0 then
		noticeId = NoticeDef.CATCH_ROGUE_BALL_EMPTY

		pg.global.showBubbleMessageById(noticeId)

		return
	end

	if not self.resumeGame then
		pg.me:modifyCatchRogueBallSort(ballIds)
		pg.me:modifyCatchRogueBallCount(ballCountMap)
	end

	pg.me:enterCatchRogueGame(function(noticeId, noticeArgs)
		if noticeId ~= NoticeDef.SUCCESS then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end
	end)
end

function CatchRogueEntryCtrl:onBuyItems(data)
	self:refreshUI()
end

function CatchRogueEntryCtrl:onUIShow(uid)
	if uid == UIConst.UI_ID_LOADING then
		self:dismiss()
	end
end

function CatchRogueEntryCtrl:onCatchRogueSettle()
	self:refreshAll()
end

return CatchRogueEntryCtrl
