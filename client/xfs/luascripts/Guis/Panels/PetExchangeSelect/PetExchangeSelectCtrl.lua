-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeSelect\\PetExchangeSelectCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeSelectCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetFriendTradeTextUtils = require("Utils.PetFriendTradeTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local UICtrl = require("Guis.UICtrl")
local PetExchangeVariantComponent = require("Guis.Panels.PetExchangeSelect.Component.PetExchangeVariantComponent")
local PetExchangeSelectCtrl = Class.LightClass("PetExchangeSelectCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local FriendshipLevelData = require("Data.friendship_level_data")
local EXCHANGE_PAGE_NORMAL = 0

PetExchangeSelectCtrl.messages = {
	[MessageName.PET_EXCHANGE_SYNC_INFO] = {
		"refreshPetExchangeInfo",
		true
	}
}

function PetExchangeSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	if info.uid then
		self.friendInfo = pg.game.chat:getPlayerInfo(info.uid)
	end

	self:initializeManagedBlur()

	self._isDestroying = false
	self.petManagementOwner = {}
	self.showCurrencyId = SysConfigData.EXCHANGE_COST_ITEM_ID
	self.selectedPetIndex = 10000
	self.selectedPetId = nil
	self.forbidSelectState = {}
	self.isVariant = info.isChange

	if self.isVariant == 1 then
		self:initVariantComponent()
	end

	self:initUI()
end

function PetExchangeSelectCtrl:initVariantComponent()
	self.variantComponent = PetExchangeVariantComponent.new(self)
end

function PetExchangeSelectCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self:bindCommonCloseHotKey(function()
		self:close()
	end)

	function self.view.btnConfirmUButton.luaClick()
		self:onBtnConfirm()
	end
end

function PetExchangeSelectCtrl:onBtnConfirm()
	if not self.selectedPetId then
		return
	end

	if pg.game.petManage:hasPetCultivation(self.selectedPetId) then
		pg.global.showConfirmMsgRaw(pg.getGameString("PET_EXCHANGE_INHERIT_WARN"), pg.getGameString("PET_EXCHANGE_INHERIT_DESC"), function()
			self:openPetInheritPanel(self.selectedPetId)
		end, false, function()
			self:confirmSelectedPet()
		end, true, nil, {
			okBtnDesc = pg.getGameString("GO_TO_INHERIT_PET"),
			cancelBtnDesc = pg.getGameString("EXCHANGE_PET_DIRECTLY"),
			nextBtnDesc = pg.getGameString("COMMON_CANCEL"),
			okBtnType = UIConst.MENU_EXIT_BTN_TYPE.Confirm,
			cancelType = UIConst.MENU_EXIT_BTN_TYPE.Confirm,
			nextBtnType = UIConst.MENU_EXIT_BTN_TYPE.Cancel,
			cancelBtnKey = Const.ExitButtonType.TEMPORARY_EXIT
		})
	else
		self:confirmSelectedPet()
	end
end

function PetExchangeSelectCtrl:confirmSelectedPet()
	if not self.selectedPetId then
		return
	end

	local selectedPetId = self.selectedPetId

	if self.variantComponent then
		self.variantComponent:confirmPet(selectedPetId)

		return
	end

	pg.me:confirmExchangePet(selectedPetId)
end

function PetExchangeSelectCtrl:refreshPetExchangeInfo()
	local exchangeInfo = pg.me:getExchangeSocialInfo()

	if not exchangeInfo then
		return
	end

	if exchangeInfo.players[pg.me.uid] and exchangeInfo.players[pg.me.uid].confirm and pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_SELECT) then
		pg.global.ui:open(UIConst.UI_ID_PET_EXCHANGE_WAIT, {
			selfSelectedPetId = self.selectedPetId
		})
	end
end

function PetExchangeSelectCtrl:openPetInheritPanel(petId)
	local canInherit, errType = pg.game.petManage:checkInheritSourcePetLegal(pg.me, petId)

	if not canInherit then
		local errNoticeId = pg.game.petManage:getErrNoticeId(errType)

		if errNoticeId then
			pg.global.showBubbleMessageById(errNoticeId)
		end

		return
	end

	pg.game.petManage:resetInheritDataModel()
	pg.game.petManage:setInheritSourcePetId(petId)
	pg.global.ui:open(UIConst.UI_ID_PET_INHERITANCE_MAIN, {
		petId = petId
	})
end

function PetExchangeSelectCtrl:close()
	UICtrl.close(self)

	if self.variantComponent then
		self.variantComponent:quitInteract()

		return
	end

	pg.me:cancelExchangePet()
end

function PetExchangeSelectCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function PetExchangeSelectCtrl:initUI()
	if not self.view or self._isDestroying then
		return
	end

	self.selectedPetItemUWidget = nil
	self.petItemButtons = {}

	local titleKey = self.variantComponent and "PET_VARIANT_SELECT_TITLE" or "PET_EXCHANGE_SELECT_TITLE"

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString(titleKey))
	self.view.btnRulesUButton:SetActive(not self.variantComponent)
	self.view.imgPetURawImage:SetActive(false)

	if self.variantComponent then
		self.variantComponent:refreshView()
	else
		self.view.btnSelectUButton:SetActive(false)
		self.view.btnCancelUButton:SetActive(false)
		self.view.root:TryChangePage("isChange", EXCHANGE_PAGE_NORMAL)
	end

	self:refreshPetSelectionState()

	if not self.friendInfo then
		return
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	self.view.btnRulesUButton.enabledTooltip = false

	function self.view.btnRulesUButton.luaClick()
		pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.PET_EXCHANGE_INFO)
	end

	ClientTextUtils.setText(self.view.friendShipLevelUBaseText, 1)

	local playerName = self:getFriendDisplayName()

	ClientTextUtils.setText(self.view.friendNameUBaseText, playerName)
	ClientTextUtils.setText(self.view.txtNameChangeUSDFText, playerName)
	ClientTextUtils.setText(self.view.nameCoverUSDFText, playerName)

	function PetManagementUtils.onNormalListRenderFinished()
		PetManagementUtils.setSelectedPet(self.selectedPetIndex)
		self:refreshPetSelectionState()
	end

	self.petManagementDelegateTable = {
		luaPress = function(button, index, data)
			if data.isEmpty or not data.id or not pg.me.pets[data.id] then
				return false
			end

			local forbidState = self.forbidSelectState[data.id]

			if forbidState ~= nil then
				if forbidState.showToast then
					pg.global.ui.tips:showTextTip(forbidState.tip)
				else
					self:showPetForbidTip(button, forbidState.tip)
				end

				return false
			end

			if not self.uiScene then
				return false
			end

			self.selectedPetId = data.id

			self:refreshPetSelectionState()
			self.uiScene:previewPet(data.id)

			if self.variantComponent then
				self.variantComponent:choosePet(data)
			else
				pg.me:chooseExchangePet(self.selectedPetId)
			end
		end,
		renderExtraLogic = function(button, index, data)
			if data.isEmpty then
				return
			end

			self.petItemButtons[index] = button

			local canSelect, tip, showToast = self:checkPetCanSelect(data)

			if not canSelect then
				button:TryChangePage("state", 1)
				self:setPetItemSelected(button, false)

				self.forbidSelectState[data.id] = {
					tip = tip,
					showToast = showToast
				}

				return
			end

			button:TryChangePage("state", 0)

			self.forbidSelectState[data.id] = nil

			local selectedPetId = self.selectedPetId or self.variantSelectedPetId
			local isSelectedPet = selectedPetId == data.id
			local shouldSelectDefault = not selectedPetId and index < self.selectedPetIndex

			if isSelectedPet or shouldSelectDefault then
				self.selectedPetIndex = index
				self.selectedPetId = data.id
			end

			self:setPetItemSelected(button, self.variantSelectedPetId == data.id)
		end,
		openPropertyPanelCb = function()
			self:restorePetManagementTemplate()
		end
	}

	PetManagementUtils.setListButtonDelegateTable(self.petManagementDelegateTable, self.petManagementOwner)
	PetManagementUtils.initTemplate(self.view.petInfoPanelTransform, self.view.petListTransform, {
		usePetManagementDisplayValue = true,
		uiScene = self.uiScene,
		owner = self.petManagementOwner,
		contextRestoreCb = function()
			self:restorePetManagementTemplate()
		end
	})

	if self.uiScene then
		self.uiScene:previewPet(PetManagementUtils.petId)
		self.uiScene:setRawImageProRef(self.view.imgPetURawImage)
		self.view.imgPetURawImage:SetActive(true)
	end

	local friendShipLevel = pg.game.chat:getFriendship(self.info.uid)

	if friendShipLevel and friendShipLevel > 0 then
		local friendshipIcon = FriendshipLevelData[friendShipLevel] and FriendshipLevelData[friendShipLevel].levelIcon or ""

		self.view.likabilityUImage.url = friendshipIcon
	end

	self:refreshUI()
end

function PetExchangeSelectCtrl:refreshPetSelectionState()
	local hasSelectedPet = self.selectedPetId ~= nil
	local objectReference = self.view.petInfoPanelTransform:GetComponent("ObjectReference")
	local rightPanelUComponent = objectReference:GetRefValue("rightPanelUComponent")
	local pageIndex = hasSelectedPet and (PetManagementUtils.pageIndex or 0) or 3

	rightPanelUComponent:TryChangePage("tabInfo", pageIndex)

	local showSelectButton = self.variantComponent ~= nil and hasSelectedPet and not self.variantComponent.isSelfConfirmed

	self.view.btnSelectUButton:SetActive(showSelectButton)
	self.view.btnConfirmUButton:SetActive(hasSelectedPet)
end

function PetExchangeSelectCtrl:setPetItemSelected(button, selected)
	local objectReference = button:GetComponent("ObjectReference")
	local selectUWidget = objectReference:GetRefValue("selectUWidget")

	if selected and self.selectedPetItemUWidget ~= selectUWidget then
		self:clearPetItemSelected()

		self.selectedPetItemUWidget = selectUWidget
	end

	selectUWidget:SetActive(selected)
end

function PetExchangeSelectCtrl:clearPetItemSelected()
	if not self.selectedPetItemUWidget then
		return
	end

	self.selectedPetItemUWidget:SetActive(false)

	self.selectedPetItemUWidget = nil
end

function PetExchangeSelectCtrl:syncVariantSelectedPet(petId)
	self.variantSelectedPetId = petId

	self:refreshVariantPetItemSelected()

	if not petId or self.selectedPetId then
		return
	end

	self.selectedPetId = petId

	self:refreshVariantSelectedPetInBox()
end

function PetExchangeSelectCtrl:refreshVariantPetItemSelected()
	self:clearPetItemSelected()

	local hasTemplateContext = PetManagementUtils.hasTemplateContext(self.petManagementOwner)

	if not self.variantSelectedPetId or not hasTemplateContext then
		return
	end

	for index, data in ipairs(PetManagementUtils.petInfos) do
		if data.id == self.variantSelectedPetId then
			local button = self.petItemButtons[index - 1]

			if button then
				self:setPetItemSelected(button, true)
			end

			return
		end
	end
end

function PetExchangeSelectCtrl:refreshVariantSelectedPetInBox()
	if not PetManagementUtils.hasTemplateContext(self.petManagementOwner) then
		return
	end

	self.selectedPetIndex = 10000

	for index, data in ipairs(PetManagementUtils.petInfos) do
		if data.id == self.selectedPetId then
			self.selectedPetIndex = index - 1

			PetManagementUtils.setSelectedPet(self.selectedPetIndex)

			return
		end
	end

	PetManagementUtils.setSelectedPet(-1)
end

function PetExchangeSelectCtrl:checkPetCanSelect(data)
	if self.variantComponent then
		return self.variantComponent:checkPetCanSelect(data)
	end

	local petInfo = pg.me:getPetInfo(data.id)
	local friendshipLevel = pg.game.chat:getFriendship(self.info.uid)
	local pedd = Utils.getExchangePetConfig(petInfo)
	local canSelect, reason = Utils.checkExchangeRemovePet(pg.me, petInfo, friendshipLevel, pedd)

	if not canSelect then
		local tip, showToast = self:getExchangePetForbidTip(petInfo, pedd, friendshipLevel, reason)

		return false, tip, showToast
	end

	return true
end

function PetExchangeSelectCtrl:getExchangePetForbidTip(petInfo, pedd, friendshipLevel, reason)
	local tip = ""

	if reason == Const.EPRR_PET_IN_TEAM then
		tip = pg.getGameString("EPRR_PET_IN_TEAM")
	elseif reason == Const.EPRR_FRIENDSHIP_LOW then
		tip = pg.getGameString("EPRR_FRIENDSHIP_LOW")
	elseif reason == Const.EPRR_EXCHANGE_CD then
		tip = pg.getGameString("EPRR_EXCHANGE_CD")

		local sourceUid = PetManagementDataHelper.getPetSource(petInfo.id)
		local playerName = ""

		if sourceUid and sourceUid ~= "" then
			local playerInfo = pg.game.chat:getPlayerInfo(sourceUid)

			if playerInfo then
				playerName = playerInfo.playerName or ""
			end
		end

		local platformHooks = PetExchangeSelectCtrl._platformHooks

		playerName = platformHooks and platformHooks.applyExchangeTipNameMask and platformHooks.applyExchangeTipNameMask(self, sourceUid, playerName) or playerName
		tip = string.gsub(tip, "{0}", playerName)
	elseif reason == Const.EPRR_LIMIT_EXCEED then
		return PetFriendTradeTextUtils.getExchangeLimitExceededTip(pg.me.useLimitMap, petInfo, pedd, friendshipLevel, not petInfo:isCatchReporting()), true
	elseif reason == Const.EPRR_PET_TYPE_FORBID then
		tip = pg.getGameString("EPAR_PET_TYPE_FORBID")
	elseif reason == Const.EPRR_PET_IN_HOME then
		tip = pg.getGameString("EPAR_PET_IN_HOME")
	elseif reason == Const.EPRR_PET_IN_DISPATCH then
		tip = pg.getGameString("DISPATCH_TASK_FORBIDDEN")
	end

	return tip, false
end

function PetExchangeSelectCtrl:showPetForbidTip(button, tip)
	local param = {
		autoHor = true,
		targetRect = button,
		desc = tip
	}

	pg.global.ui:open(UIConst.UI_ID_PET_EXCHANGE_TIP, param)
end

function PetExchangeSelectCtrl:getFriendDisplayName()
	local playerName = self.friendInfo.playerName
	local hooks = PetExchangeSelectCtrl._platformHooks

	playerName = hooks and hooks.applyPlayerNameMask and hooks.applyPlayerNameMask(self, playerName) or playerName

	return playerName
end

function PetExchangeSelectCtrl:restorePetManagementTemplate()
	if self._isDestroying or not self.view then
		return
	end

	if PetManagementUtils.hasTemplateContext and PetManagementUtils.hasTemplateContext(self.petManagementOwner) then
		return
	end

	if PetManagementUtils.hasOtherTemplateContext and PetManagementUtils.hasOtherTemplateContext(self.petManagementOwner) then
		return
	end

	if not PetManagementUtils.hasTemplateContext and PetManagementUtils.delegateTable == self.petManagementDelegateTable and PetManagementUtils.boxPetNewListContainers then
		return
	end

	self.selectedPetIndex = 10000

	if not self.variantComponent then
		self.selectedPetId = nil
	end

	self.forbidSelectState = {}

	self:initUI()
end

function PetExchangeSelectCtrl:refreshUI()
	self:refreshCurrency()
end

function PetExchangeSelectCtrl:onVisibleChange(visible)
	if self.uiScene then
		self.uiScene:setModelVisible(visible)
	end

	if visible and self.uiScene then
		self:restorePetManagementTemplate()
		self.uiScene:playPetIdle()
	end
end

function PetExchangeSelectCtrl:refreshCurrency()
	self.view.listCurrencyUList:SetList({
		{
			itemId = self.showCurrencyId
		}
	})
end

function PetExchangeSelectCtrl:onDestroy()
	self._isDestroying = true

	UICtrl.onDestroy(self)
	PetManagementUtils.destroyTemplate(self.petManagementOwner)
end

function PetExchangeSelectCtrl:onOpen(info)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_INFO_PLAYER_CARD) then
		pg.global.ui:close(UIConst.UI_ID_INFO_PLAYER_CARD)
	end

	UICtrl.onOpen(self, info)
end

function PetExchangeSelectCtrl:onShow()
	if self.uiScene then
		self:restorePetManagementTemplate()
	end
end

function PetExchangeSelectCtrl:onHide()
	return
end

function PetExchangeSelectCtrl:getManagedBlurEffect()
	return self.view and self.view.bgBlurUIBlurEffect
end

return PetExchangeSelectCtrl
