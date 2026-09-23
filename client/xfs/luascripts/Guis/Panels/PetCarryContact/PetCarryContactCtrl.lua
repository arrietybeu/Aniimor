-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryContact\\PetCarryContactCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryContactCtrl")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local ItemConst = require("Common.Const.ItemConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetSkillInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetSkillInfoComponent")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetCarryContactCtrl = Class.LightClass("PetCarryContactCtrl", UICtrl)
local CORE_CARRY_CERTIFY_BUTTON = "CARRY_CERT_BTN"
local CORE_CARRY_CERTIFY_DESC = "CARRY_CERT_PANEL_DESC"
local CORE_CARRY_CERTIFY_CONFIRM = "CARRY_CERT_CONFIRM"

PetCarryContactCtrl.messages = {}

function PetCarryContactCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetCarryContactCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	self.view.btnInfoUButton.enabledTooltip = false

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = 219
		})
	end

	function self.view.btnConsumeUButton.luaClick()
		self:onClickConsumeBtn()
	end

	function self.view.btnNoneCostUButton.luaClick()
		pg.global.showBubbleMessageById(NoticeDef.ITEM_COUNT_LACK)
	end
end

function PetCarryContactCtrl:onDestroy()
	if self.currencyTickTimer then
		self:killTimer(self.currencyTickTimer)

		self.currencyTickTimer = nil
	end

	self.isCoreCarryCertifyPanelClosed = true

	if self.pendingCoreCarryCertifyAnimation then
		self:playCoreCarryCertifySuccessAnimation()
	end

	UICtrl.onDestroy(self)
end

function PetCarryContactCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.petId = info and info.petId
	self.isCoreCarryCertifyPanelClosed = nil
	self.isCoreCarryCertifyAnimationTriggered = nil
	self.pendingCoreCarryCertifyAnimation = nil

	local success, noticeId, context = pg.game.petManage:checkCoreCarryCertify(self.petId, nil, true)

	if not success then
		pg.global.showBubbleMessageById(noticeId)
		self:closePanel()

		return
	end

	self.context = context
	self.petInfo = context.petInfo
	self.coreCarryInfo = context.coreCarryInfo
	self.coreCarryDisplayInfo = pg.game.petManage:parseCarryFullInfo(context.coreCarryItem)
	self.beforeSkillInfo, self.afterSkillInfo = PetManagementDataHelper.getCoreCarryCertifySkillPairByBaseFormPet(context.targetBaseFormPet)

	self:refreshView()
	self:refreshCurrencyList()

	if self.currencyTickTimer then
		self:killTimer(self.currencyTickTimer)
	end

	self.currencyTickTimer = self:startTimer(function()
		self:refreshTopCurrencyList()
	end, 1, true)

	ClientTextUtils.setText(self.view.txtExclusiveUSDFText, pg.getGameString("CARRY_CERT_ENHANCE"))
end

function PetCarryContactCtrl:onShow()
	return
end

function PetCarryContactCtrl:onHide()
	return
end

function PetCarryContactCtrl:playCoreCarryCertifySuccessAnimation(petId)
	petId = petId or self.petId

	if self.isCoreCarryCertifyAnimationTriggered or not petId then
		return
	end

	self.isCoreCarryCertifyAnimationTriggered = true

	facade:sendMsgToUI(MessageName.CARRY_CERTIFY_ANIMATION, {
		petId = petId
	})
end

function PetCarryContactCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_MANAGEMENT_CARRYCONTACT)
end

function PetCarryContactCtrl:refreshView()
	local displayInfo = self.coreCarryDisplayInfo or {}
	local targetBaseFormPet = self.context.targetBaseFormPet
	local targetPetName = LuaUIUtils.getPetNameWithIdOrTmpId(targetBaseFormPet)

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString(CORE_CARRY_CERTIFY_BUTTON))
	ClientTextUtils.setText(self.view.infoTxtTipsUSDFText, string.format(pg.getGameString(CORE_CARRY_CERTIFY_DESC), targetPetName))
	ClientTextUtils.setText(self.view.txtPetNameUSDFText, LuaUIUtils.getPetNameByPetInfo(self.petInfo))
	ClientTextUtils.setText(self.view.txtCarryNameUSDFText, displayInfo.l10nName or LuaUIUtils.getNameByItemId(self.coreCarryInfo.itemId))
	ClientTextUtils.setText(self.view.btnConsumeTxt, pg.getGameString(CORE_CARRY_CERTIFY_CONFIRM))

	self.view.leftPetIconUImage.url = LuaUIUtils.getPetIconByTemplateId(self.petInfo.templateId, LuaUIUtils.PET_ICON, self.petInfo.label)
	self.view.iconCarryUImage.url = displayInfo.bigIcon or LuaUIUtils.getIconByItemId(self.coreCarryInfo.itemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_BIG)

	self.view.carryUComponent:TryChangePage("Quality", displayInfo.quality or 0)

	self.beforeSkillComponent = PetSkillInfoComponent.new(self.view, self, self.view.skillBeforeUComponent)

	self.beforeSkillComponent:renderPetSkillInfo(self.beforeSkillInfo, self.petInfo, {
		showRealGlazeType = true,
		pos = UIConst.GlazeSkillPos.Before
	})

	self.afterSkillComponent = PetSkillInfoComponent.new(self.view, self, self.view.skillAfterUComponent)

	self.afterSkillComponent:renderPetSkillInfo(self.afterSkillInfo or self.beforeSkillInfo, self.petInfo, {
		showRealGlazeType = true,
		pos = UIConst.GlazeSkillPos.After,
		compareSkillInfoData = self.beforeSkillInfo
	})
	self:refreshCostState()
end

function PetCarryContactCtrl:getCostItem()
	local costDict = self.context and self.context.costDict

	if not costDict then
		return nil, nil
	end

	for itemId, itemCount in pairs(costDict) do
		return itemId, itemCount
	end

	return nil, nil
end

function PetCarryContactCtrl:refreshCostState()
	local itemId, requiredCount = self:getCostItem()
	local ownCount = itemId and ItemUtils.getItemCountByIdCanUse(pg.me, itemId, false) or 0
	local canAfford = itemId ~= nil and requiredCount <= ownCount

	self.view.iconConsumeUImage.url = itemId and LuaUIUtils.getIconByItemId(itemId) or ""

	local numText = requiredCount or 0

	if not canAfford then
		local lackStyle = UIConst.ITEM_STATE_COLOR[UIConst.ITEM_STATE.LACK]

		numText = string.format("<style=%s>%s</style>", lackStyle, numText)
	end

	ClientTextUtils.setText(self.view.txtNumUSDFText, tostring(numText))
	self.view.btnConsumeUButton:SetActive(true)
	self.view.btnConsumeUButton:TryChangePage("button", canAfford and 0 or 4)
	self.view.btnNoneCostUButton:SetActive(not canAfford)
end

function PetCarryContactCtrl:refreshCurrencyList()
	local itemList = {}
	local costDict = self.context and self.context.costDict or {}

	for itemId in pairs(costDict) do
		itemList[#itemList + 1] = itemId
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, itemList)
end

function PetCarryContactCtrl:refreshTopCurrencyList()
	local itemCount = self.view.listCurrencyUList.itemCount

	for i = 1, itemCount do
		local res, button = self.view.listCurrencyUList:TryGetChildAt(i - 1)

		if res then
			self:refreshTopCurrencyItem(button)
		end
	end

	self:refreshCostState()
end

function PetCarryContactCtrl:refreshTopCurrencyItem(button)
	local buttonData = button and button.dataFromUList
	local itemId = buttonData and buttonData.itemId

	if not itemId then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local countUText = objectReference:GetRefValue("countUText")
	local itemCount = 0

	if itemId == ItemConst.ITEM_SPECIAL_EXP_ROGUE_TALENT then
		itemCount = pg.me.rogueTalentExp or 0
	elseif itemId >= ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND and itemId <= ItemConst.ITEM_SPECIAL_MONEY_CASH then
		itemCount = pg.me:getMoneyNum(itemId)
	else
		itemCount = pg.me:getItemCountById(itemId)
	end

	if ItemData[itemId] then
		ClientTextUtils.setText(countUText, itemCount)

		function button.luaRenderTooltip(_, tooltip)
			LuaUIUtils.refreshItemInfo(tooltip, {
				fromParamCount = true,
				id = itemId,
				itemCount = itemCount,
				targetRect = button
			}, button)
		end
	end
end

function PetCarryContactCtrl:onClickConsumeBtn()
	if self.isCertifying or not self.petId then
		return
	end

	self.isCertifying = true

	local success, noticeId = pg.game.petManage:sendRpcCertifyCoreCarry(self.petId, function(resultNoticeId)
		self:onCertifyCallback(resultNoticeId)
	end)

	if not success then
		self.isCertifying = nil

		pg.global.showBubbleMessageById(noticeId)
		self:refreshCostState()
	end
end

function PetCarryContactCtrl:onCertifyCallback(noticeId)
	if noticeId ~= NoticeDef.SUCCESS then
		self.isCertifying = nil

		pg.global.showBubbleMessageById(noticeId)
		self:refreshCostState()

		return
	end

	local petId = self.petId
	local targetBaseFormPet = self.context and self.context.targetBaseFormPet
	local petInfo = self.petInfo
	local afterSkillInfo = self.afterSkillInfo
	local retAbilityId = self.afterSkillInfo and AbilityUtils.getAbilityParamId(self.afterSkillInfo.abilityId) or nil

	pg.game.petManage:waitCoreCarryCertifySync(petId, targetBaseFormPet, function()
		self.isCertifying = nil

		facade:sendMsgToUI(MessageName.CARRY_CERTIFY, {
			petId = petId,
			retAbilityId = retAbilityId
		})

		local shouldOpenSkillSuccessPanel = afterSkillInfo and petInfo

		if shouldOpenSkillSuccessPanel then
			local isSkillSuccessPanelOpen = false

			pg.game.audio:playEvent("SFX_UI_Skillenhance_Success_Effect")
			pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_UPSKILL_SUC, {
				skillInfoData = afterSkillInfo,
				petInfo = petInfo
			}, function()
				isSkillSuccessPanelOpen = true

				self:closePanel()
			end, function()
				if isSkillSuccessPanelOpen or self.isCoreCarryCertifyPanelClosed then
					self:playCoreCarryCertifySuccessAnimation(petId)
				else
					self.pendingCoreCarryCertifyAnimation = true
				end
			end)
		else
			self.pendingCoreCarryCertifyAnimation = true

			self:closePanel()
			logger:warn("core carry certification success panel data is missing, petId=%s", tostring(petId))
		end
	end)
end

return PetCarryContactCtrl
