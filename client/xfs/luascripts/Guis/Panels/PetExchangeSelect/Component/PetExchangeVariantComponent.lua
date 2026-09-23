-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeSelect\\Component\\PetExchangeVariantComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetInfoCardDisplayUtils = require("Guis.Utils.PetInfoCardDisplayUtils")
local PetInfoTipPresenter = require("Guis.Utils.PetInfoTipPresenter")
local UIComponent = require("Guis.Helper.UIComponent")
local PetExchangeVariantComponent = Class.LightClass("PetExchangeVariantComponent", UIComponent)
local EXCHANGE_PAGE_VARIANT = 1
local SELECT_PAGE_NORMAL = 0
local SELECT_PAGE_SELECTED = 1
local STATE_PAGE_NOT_SELECTED = 0
local STATE_PAGE_SELECTED = 1
local PET_DETAIL_HYPERLINK_ACTION = "pet_detail"
local PET_DETAIL_HYPERLINK_FORMAT = "<link=\"pet_detail\"><u>{0}</u></link>"
local PET_INFO_TIP_SCENE_POSITION_Y = 500

PetExchangeVariantComponent.messages = {
	[MessageName.PET_VARIANT_INTERACT_SYNC_INFO] = {
		"refreshVariantState",
		true
	}
}

function PetExchangeVariantComponent:onCtor()
	local sceneKey = self.ctrl.module .. ".variantPetInfoTip"

	self.petInfoTipPresenter = PetInfoTipPresenter.new(sceneKey, nil, {
		uiSceneId = sceneKey,
		positionY = PET_INFO_TIP_SCENE_POSITION_Y
	})
end

function PetExchangeVariantComponent:findObjects()
	local objectReference = self.view.ischangeUComponent:GetComponent("ObjectReference")
	local playerHeadObjectReference = objectReference:GetRefValue("playerHeadObjectReference")

	self.playerHeadUWidget = playerHeadObjectReference and playerHeadObjectReference.transform
	self.textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	self.textPlayerNameUSDFText = objectReference:GetRefValue("textPlayerNameUSDFText")
	self.nameCoverUSDFText = objectReference:GetRefValue("nameCoverUSDFText")
	self.iconUImage = self.view.petHeadObjectReference:GetRefValue("iconUImage")
end

function PetExchangeVariantComponent:initView()
	self:addListener()
	self:refreshText()
	self:refreshPlayerInfo()
end

function PetExchangeVariantComponent:addListener()
	function self.view.btnSelectUButton.luaClick()
		self:confirmPet(self.ctrl.selectedPetId)
	end

	function self.view.btnCancelUButton.luaClick()
		self:cancelConfirmPet()
	end
end

function PetExchangeVariantComponent:refreshText()
	local btnSelectObjectReference = self.view.btnSelectUButton:GetComponent("ObjectReference")
	local btnCancelObjectReference = self.view.btnCancelUButton:GetComponent("ObjectReference")
	local selectTextUText = btnSelectObjectReference:GetRefValue("txtNameUText")
	local cancelTextUText = btnCancelObjectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(selectTextUText, pg.getGameString("PET_EXCHANGE_CONFIRM_SELECT"))
	ClientTextUtils.setText(cancelTextUText, pg.getGameString("PET_EXCHANGE_CANCEL_SELECT"))
	ClientTextUtils.setText(self.view.textWaitCancelUSDFText, pg.getGameString("PET_EXCHANGE_WAIT_FRIEND_SELECT"))
	ClientTextUtils.setText(self.view.textSelectUSDFText, pg.getGameString("PET_EXCHANGE_SELECTED"))
end

function PetExchangeVariantComponent:refreshPlayerInfo()
	local playerInfo = self.ctrl.friendInfo

	if not playerInfo then
		return
	end

	local playerName = self.ctrl:getFriendDisplayName()

	ClientTextUtils.setText(self.textLvUSDFText, playerInfo.level or 1)
	ClientTextUtils.setText(self.textPlayerNameUSDFText, playerName)

	local mustName = pg.getGameString("PET_EXCHANGE_OBJECT")

	ClientTextUtils.setText(self.nameCoverUSDFText, mustName)
	self:refreshPlayerHead(playerInfo)
end

function PetExchangeVariantComponent:refreshPlayerHead(playerInfo)
	LuaUIUtils.renderPlayerAvatarImages(self.playerHeadUWidget, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})
end

function PetExchangeVariantComponent:refreshView()
	self:refreshMode()
	self.view.ischangeUComponent:TryChangePage("SELECT", SELECT_PAGE_NORMAL)

	self.iconUImage.url = ""

	self:refreshVariantState()
end

function PetExchangeVariantComponent:refreshMode()
	self.view.root:TryChangePage("isChange", EXCHANGE_PAGE_VARIANT)
end

function PetExchangeVariantComponent:refreshVariantState()
	local socialInfo = pg.me:getPetVariantInteractSocialInfo()

	if not socialInfo or not socialInfo.players then
		self.isSelfConfirmed = false
		self.confirmedPetInfo = nil

		self.view.textWaitCancelUSDFText:SetActive(true)
		self.view.ischangeUComponent:TryChangePage("State", STATE_PAGE_NOT_SELECTED)
		self.ctrl:syncVariantSelectedPet(nil)
		self:refreshSelectedPet(nil)
		self.ctrl:refreshPetSelectionState()

		return
	end

	local players = socialInfo.players
	local selfInfo = self:getVariantInfo(players, pg.me.uid)
	local friendInfo = self:getVariantInfo(players, self.ctrl.info.uid)
	local isSelfConfirmed = selfInfo ~= nil and selfInfo.confirm == true
	local isFriendConfirmed = friendInfo ~= nil and friendInfo.confirm == true
	local friendState = isFriendConfirmed and STATE_PAGE_SELECTED or STATE_PAGE_NOT_SELECTED

	self.view.btnCancelUButton:SetActive(isSelfConfirmed)
	self.view.textWaitCancelUSDFText:SetActive(not isFriendConfirmed)
	self.view.root:TryChangePage("Select", isSelfConfirmed and 1 or 0)
	self.view.ischangeUComponent:TryChangePage("State", friendState)

	local serverPetInfo = selfInfo and selfInfo.petInfo

	self.isSelfConfirmed = isSelfConfirmed
	self.confirmedPetInfo = isSelfConfirmed and serverPetInfo or nil
	self.browsingPetInfo = self.browsingPetInfo or serverPetInfo

	self.ctrl:syncVariantSelectedPet(self.confirmedPetInfo and self.confirmedPetInfo.id)
	self:refreshSelectedPet(self.confirmedPetInfo or self.browsingPetInfo)
	self.ctrl:refreshPetSelectionState()
end

function PetExchangeVariantComponent:getVariantInfo(players, uid)
	return players[uid] or players[tostring(uid)] or players[tonumber(uid)]
end

function PetExchangeVariantComponent:refreshSelectedPet(petInfo)
	local petConfig = petInfo and PetData[petInfo.templateId]
	local iconName = petInfo and (petInfo.iconName or petConfig and petConfig.iconName)

	if not iconName then
		self.view.ischangeUComponent:TryChangePage("SELECT", SELECT_PAGE_NORMAL)

		self.iconUImage.url = ""

		return
	end

	self.view.ischangeUComponent:TryChangePage("SELECT", SELECT_PAGE_SELECTED)

	self.iconUImage.url = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
end

function PetExchangeVariantComponent:checkPetCanSelect(data)
	if data.isVariant == true then
		return false, pg.getGameString("PET_VARIANT_INTERACT_PET_FORBID")
	end

	if data.inBattle or data.inExplore then
		return false, pg.getGameString("EPRR_PET_IN_TEAM")
	end

	if data.isPutInHomeland then
		return false, pg.getGameString("EPAR_PET_IN_HOME")
	end

	if pg.me:isPetActivityDispatching(data) then
		return false, pg.getGameString("DISPATCH_TASK_FORBIDDEN")
	end

	return true
end

function PetExchangeVariantComponent:choosePet(data)
	self.browsingPetInfo = data

	if not self.isSelfConfirmed then
		self:refreshSelectedPet(data)
	end
end

function PetExchangeVariantComponent:confirmPet(petId, callback)
	local variantPet, variantCount = self:getVariantPetAtLimit()

	if variantPet ~= nil then
		local variantPetName = LuaUIUtils.getPetNameByPetInfo(variantPet)
		local variantPetLink = pg.getFormatText(PET_DETAIL_HYPERLINK_FORMAT, variantPetName)
		local desc = pg.getFormatText(pg.getGameString("PET_VARIANT_INTERACT_LIMIT_CONFIRM"), variantCount, SysConfigData.VARIANT_LIMIT_1, variantPetLink)
		local variantPetInfo = PetManagementDataHelper.createPetInfoTipData(PetManagementDataHelper.setUpPetInfo(variantPet))

		local function onHyperLinkClick(action, _, contentRect, fallbackButton)
			if action ~= PET_DETAIL_HYPERLINK_ACTION then
				return
			end

			self:openVariantPetDetail(contentRect, fallbackButton, variantPetInfo)
		end

		local function onHyperLinkCleanup()
			self:clearVariantPetDetail()
		end

		local extraInfo = {
			hyperLinkClick = onHyperLinkClick,
			hyperLinkCleanup = onHyperLinkCleanup
		}

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), desc, function()
			pg.me:confirmVariantInteractPet(petId, callback)
		end, nil, nil, nil, nil, extraInfo)

		return
	end

	pg.me:confirmVariantInteractPet(petId, callback)
end

function PetExchangeVariantComponent:openVariantPetDetail(contentRect, fallbackButton, petInfo)
	self:clearVariantPetDetail()

	local triggerButton = self:findHyperlinkButton(contentRect, fallbackButton)

	self.variantPetDetailButton = triggerButton

	local function renderPetInfo(component, displayPetInfo)
		self:renderVariantPetInfoCard(component, displayPetInfo)
	end

	self.petInfoTipPresenter:bind(triggerButton, function()
		return petInfo
	end, {
		hierarchy = 1,
		popupDirection = CS.XGUI.EPopupDirection.AutoHorizontal,
		verticalAlignment = CS.XGUI.EVerticalAlignment.Bottom,
		renderPetInfo = renderPetInfo
	})
	triggerButton:OpenTooltipWithUrl("$UI_Pop_PetInfo_Tips.prefab")
end

function PetExchangeVariantComponent:renderVariantPetInfoCard(component, petInfo)
	self.petInfoCardDisplayState = self.petInfoCardDisplayState or {}

	local function ensurePetPreviewUIScene(callback)
		self.petInfoTipPresenter:ensurePetPreviewUIScene(callback)
	end

	PetInfoCardDisplayUtils.render(component, petInfo, {
		visibleTabList = PetInfoCardDisplayUtils.ALL_TAB_LIST,
		state = self.petInfoCardDisplayState,
		ensurePetPreviewUIScene = ensurePetPreviewUIScene
	})
end

function PetExchangeVariantComponent:clearVariantPetDetail()
	if self.petInfoTipPresenter then
		self.petInfoTipPresenter:unbind(self.variantPetDetailButton)
	end

	self.variantPetDetailButton = nil
end

function PetExchangeVariantComponent:findHyperlinkButton(contentRect, fallbackButton)
	local current = contentRect

	while current do
		local button = current:GetComponent("UButton")

		if button then
			return button
		end

		current = current.parent
	end

	return fallbackButton
end

function PetExchangeVariantComponent:getVariantPetAtLimit()
	local variantPets = PetManagementDataHelper.getVariantPetsByFriendUid(self.ctrl.info.uid)
	local variantCount = #variantPets

	if variantCount < SysConfigData.VARIANT_LIMIT_1 then
		return nil, variantCount
	end

	return variantPets[1], variantCount
end

function PetExchangeVariantComponent:cancelConfirmPet()
	pg.me:cancelConfirmVariantInteractPet()
end

function PetExchangeVariantComponent:quitInteract()
	pg.me:cancelVariantInteract(Const.EPQR_CLIENT_QUIT)
end

function PetExchangeVariantComponent:onDestroy()
	self:clearVariantPetDetail()
	self.petInfoTipPresenter:destroy()

	self.petInfoTipPresenter = nil
end

return PetExchangeVariantComponent
