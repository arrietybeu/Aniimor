-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetUpSkill\\PetUpSkillCtrl.lua

local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local logger = require("Core.Log.LoggerManager").getLogger("PetUpSkillCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetUpSkillCtrl = Class.LightClass("PetUpSkillCtrl", UICtrl)
local PetConfigData = require("Data.pet_config_data")
local PetSkillInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetSkillInfoComponent")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ItemData = require("Data.item_data")
local ItemConst = require("Common.Const.ItemConst")

PetUpSkillCtrl.messages = {}

function PetUpSkillCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.skillInfoData = info.skillInfoData
	self.petInfo = info.petInfo

	ClientTextUtils.setText(self.view.infoTxtTipsUSDFText, pg.getGameString("PETSKILL_HELP_DETAILS"))
end

function PetUpSkillCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("PETSKILL_UPLV_TITLE"))

	self.view.btnInfoUButton.enabledTooltip = false

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = PetConfigData.PETSKILL_UPLV_HELPID or 1,
			keepVisibleUIs = {
				[UIConst.UI_ID_PET_MANAGEMENT_UPSKILL] = true
			}
		})
	end
end

function PetUpSkillCtrl:refreshCurrencyList()
	local glazeConsume = self.skillInfoData and self.skillInfoData.glazeConsume

	if not glazeConsume then
		return
	end

	local itemList = {}

	for itemId in pairs(glazeConsume) do
		itemList[#itemList + 1] = itemId
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, itemList)
end

function PetUpSkillCtrl:onDestroy()
	if self.currencyTickTimer then
		self:killTimer(self.currencyTickTimer)

		self.currencyTickTimer = nil
	end

	UICtrl.onDestroy(self)
end

function PetUpSkillCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.skillInfoData = info.skillInfoData
	self.petInfo = info.petInfo

	LuaUIUtils.renderSkillHeadComp(self.view.petSkillUButton, self.skillInfoData, self.petInfo, false, nil, nil, true)

	self.beforeSkillInfo = PetSkillInfoComponent.new(self.view, self, self.view.skillBeforeUComponent)

	self.beforeSkillInfo:renderPetSkillInfo(self.skillInfoData, self.petInfo, {
		showRealGlazeType = true,
		pos = UIConst.GlazeSkillPos.Before
	})

	self.enhancedSkillInfoData = self:buildEnhancedSkillInfo()
	self.afterSkillInfo = PetSkillInfoComponent.new(self.view, self, self.view.skillAfterUComponent)

	self.afterSkillInfo:renderPetSkillInfo(self.enhancedSkillInfoData or self.skillInfoData, self.petInfo, {
		showRealGlazeType = true,
		pos = UIConst.GlazeSkillPos.After,
		compareSkillInfoData = self.skillInfoData
	})

	function self.view.btnConsumeUButton.luaClick()
		self:onClickConsumeBtn()
	end

	function self.view.btnNoneCostUButton.luaClick()
		pg.global.showBubbleMessageById(NoticeDef.PETSKILL_CANT_UPLV_BY_COST)
	end

	ClientTextUtils.setText(self.view.btnConsumeTxt, pg.getGameString("PETSKILL_BTN_UPLV"))

	local glazeConsume = self.skillInfoData.glazeConsume
	local canAfford = true

	if glazeConsume then
		for itemId, consumeNum in pairs(glazeConsume) do
			self.view.iconConsumeUImage.url = LuaUIUtils.getIconByItemId(itemId)

			local hasNum = ClientUtils.getItemCountById(itemId)

			if hasNum < consumeNum then
				canAfford = false
			end

			local numText = consumeNum

			if not canAfford then
				local lackStyle = UIConst.ITEM_STATE_COLOR[UIConst.ITEM_STATE.LACK]

				numText = string.format("<style=%s>%s</style>", lackStyle, consumeNum)
			end

			ClientTextUtils.setText(self.view.txtNumUSDFText, tostring(numText))

			break
		end
	end

	self.view.btnConsumeUButton:SetActive(true)
	self.view.btnConsumeUButton:TryChangePage("button", canAfford and 0 or 4)
	self.view.btnNoneCostUButton:SetActive(not canAfford)
	self:refreshCurrencyList()

	self.currencyTickTimer = self:startTimer(function()
		self:refreshTopCurrencyList()
	end, 1, true)
end

function PetUpSkillCtrl:onShow()
	if not self.skillInfoData then
		return
	end
end

function PetUpSkillCtrl:onHide()
	return
end

function PetUpSkillCtrl:onClickConsumeBtn()
	if not self.skillInfoData or not self.petInfo then
		return
	end

	if not self.skillInfoData.canGlaze then
		if self.skillInfoData.alreadyGlazed then
			pg.global.showBubbleMessageById(NoticeDef.PETSKILL_ALREADY_UPLV)
		elseif not self.skillInfoData.alreadyLearnt then
			pg.global.showBubbleMessageById(NoticeDef.SKILL_NOT_LEARNED_CAN_NOT_EQUIP)
		end

		return
	end

	local glazeConsume = self.skillInfoData.glazeConsume

	if glazeConsume then
		for itemId, consumeNum in pairs(glazeConsume) do
			local hasNum = ClientUtils.getItemCountById(itemId)

			if hasNum < consumeNum then
				pg.global.showBubbleMessageRaw(pg.getGameString("PETSKILL_CANT_UPLV_BY_COST"))

				return
			end
		end
	end

	local petId = self.petInfo.id
	local paramId = self.skillInfoData.paramId or AbilityUtils.getAbilityParamId(self.skillInfoData.abilityId)

	pg.me:serverMsg("RPC_CS_UpgradePetSkill", petId, paramId, CallbackHandler(self, "onUpgradeSkillCallback"))
end

function PetUpSkillCtrl:buildEnhancedSkillInfo()
	local enhancedParamId = self.skillInfoData and self.skillInfoData.enhancedSkillId

	return LuaUIUtils.buildEnhancedSkillInfo(enhancedParamId, self.petInfo.templateId, self.petInfo.petPrototypeId)
end

function PetUpSkillCtrl:onUpgradeSkillCallback(result)
	if result == NoticeDef.SUCCESS and self.skillInfoData and self.petInfo then
		pg.game.audio:playEvent("SFX_UI_Skillenhance_Success_Effect")

		local pairedSkillInfoCache = LuaUIUtils.buildEnhancedSkillInfo(self.skillInfoData.enhancedSkillId, self.petInfo.templateId, self.petInfo.petPrototypeId)
		local retAbilityId = AbilityUtils.getAbilityParamId(pairedSkillInfoCache.abilityId)

		facade:SendMessageCommand(MessageName.PET_SKILL_GLAZE_SUCCESS, {
			petId = self.petInfo.id,
			retAbilityId = retAbilityId
		})
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_UPSKILL_SUC, {
			skillInfoData = pairedSkillInfoCache,
			petInfo = self.petInfo
		})
	else
		pg.global.showBubbleMessage(result)
	end
end

function PetUpSkillCtrl:refreshTopCurrencyList()
	local itemCount = self.view.listCurrencyUList.itemCount

	for i = 1, itemCount do
		local res, btn = self.view.listCurrencyUList:TryGetChildAt(i - 1)

		if res then
			self:refreshTopCurrencyItem(btn)
		end
	end
end

function PetUpSkillCtrl:refreshTopCurrencyItem(button)
	if not button then
		return
	end

	local btnData = button.dataFromUList

	if not btnData then
		return
	end

	local itemId = btnData.itemId
	local objectReference = button:GetComponent("ObjectReference")
	local countUText = objectReference:GetRefValue("countUText")
	local itemConfig = ItemData[itemId]
	local itemCount = 0

	if itemId == ItemConst.ITEM_SPECIAL_EXP_ROGUE_TALENT then
		itemCount = pg.me.rogueTalentExp or 0
	elseif itemId >= ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND and itemId <= ItemConst.ITEM_SPECIAL_MONEY_CASH then
		itemCount = pg.me:getMoneyNum(itemId)
	else
		itemCount = pg.me:getItemCountById(itemId)
	end

	if itemConfig then
		ClientTextUtils.setText(countUText, itemCount)

		function button.luaRenderTooltip(btn, cmp)
			LuaUIUtils.refreshItemInfo(cmp, {
				fromParamCount = true,
				id = itemId,
				itemCount = itemCount,
				targetRect = button
			}, button)
		end
	end
end

return PetUpSkillCtrl
