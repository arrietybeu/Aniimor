-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeWait\\PetExchangeWaitCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeWaitCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetExchangeWaitCtrl = Class.LightClass("PetExchangeWaitCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetCharacterData = require("Data.pet_character_data")
local UIConst = require("Const.UIConst")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PetExchangeWaitScene = require("GameApp.Scenes.UIScenes.PetExchangeWaitScene")
local PetLevelData = require("Data.pet_level_data")
local PetData = require("Data.pet_data")
local PetTalentData = require("Data.pet_talent_data")
local Time = require("Core.Common.Time")
local Lume = require("Core.Common.lume")
local PetInfo = require("CustomTypes.PetInfo")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local SysConfigData = require("Data.sys_config_data")
local PetFriendTradeUtils = require("Common.Utils.PetFriendTradeUtils")
local PetFriendTradeTextUtils = require("Utils.PetFriendTradeTextUtils")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local AudioConst = require("Const.AudioConst")
local Const = require("Common.Const.Const")
local PetConfigData = require("Data.pet_config_data")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local PetExchangeCountdownCtrl = require("Guis.Panels.PetExchangeCountdown.PetExchangeCountdownCtrl")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")

PetExchangeWaitCtrl.messages = {
	[MessageName.PET_EXCHANGE_SYNC_INFO] = {
		"refreshPetExchangeInfo",
		true
	},
	[MessageName.PET_EXCHANGE_SYNC_RESULT] = {
		"onExchangeResult",
		true
	}
}

local STAR_PART_STATE = {
	UNLIGHT = 0,
	LIGHT = 1
}
local RumblePhase = {
	SILENCE = 3,
	SWITCH = 2,
	WAIT = 1,
	OFF = 0,
	RESULT_VARIANT = 5,
	RESULT_NORMAL = 4
}
local BTN_CONFIRM_BIND_NAME = "BtnConfirmDynamic"
local PET_MANAGEMENT_ATTRIBUTE_EXTRA_INFO = {
	usePetManagementDisplayValue = true
}
local CONFIRM_PAGE_ACTION_PATH = {
	[0] = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth,
	HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest,
	[3] = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth
}

function PetExchangeWaitCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.showCurrencyId = SysConfigData.EXCHANGE_COST_ITEM_ID
	self.showCurrencyId2 = SysConfigData.PET_EXCHANGE_GOLDEN[1]
	self.normalAni1 = "VX_Pb_PetExchange_Switch_NoChange"
	self.normalAni2 = "VX_Pb_PetExchange_Switch_Mesh_NoChange"
	self.changeAni1 = "VX_Pb_PetExchange_Switch_Change"
	self.changeAni2 = "VX_Pb_PetExchange_Switch_Mesh_Change"
	self.petPropertyUWidget = {}
	self.showPetDetail = true
	self.isConfirm = false
	self.curExchangeState = 0
	self.exchangeSuccess = false

	self:showPetModel()
	self:initUI()
	self:showPetDetails()
end

function PetExchangeWaitCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()

		if self.exchangeSuccess then
			pg.me:chooseExchangePet(pg.me:getExchangeSocialInfo().choosedPetInfo[pg.me.id].id)
		else
			self.isConfirm = false

			pg.me:cancelConfirmExchangePetState()
		end
	end

	self:bindHotKeyPerform("Common/Cancel", self.view.btnBackUButton.luaClick, self.view.btnBackUButton.gameObject)

	function self.view.btnDetailsUButton.luaClick()
		self.showPetDetail = not self.showPetDetail

		self:showPetDetails()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.exchangeSuccess then
			self:close()

			return
		end

		if not self.isConfirm and not self:checkExchangeLimitBeforeConfirm() then
			return
		end

		pg.me:confirmExchange(not self.isConfirm)
		self:refreshConfirm()
	end

	self:bindHotKeyPerform("Raw/GamepadStart", function()
		if self.view and self.view.btnRulesUButton and not IsNil(self.view.btnRulesUButton) then
			self.view.btnRulesUButton:OnClickSimulate()
		end
	end)

	self.view.btnRulesUButton.enabledTooltip = false

	function self.view.btnRulesUButton.luaClick()
		if Const.COMMON_POPUP_TIP_ID.PET_EXCHANGE_INFO then
			pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.PET_EXCHANGE_INFO)
		end
	end

	self:refreshBtnConfirmHotKey(0)
end

function PetExchangeWaitCtrl:checkExchangeLimitBeforeConfirm()
	local exchangeInfo = pg.me:getExchangeSocialInfo()
	local limitContext = self:getExchangeSelfLimitContext(exchangeInfo)
	local canExchange, limitId, credentialTier, isCredentialLimit = PetFriendTradeUtils.checkExchangeLimit(pg.me.useLimitMap, limitContext.petInfo, limitContext.pedd, exchangeInfo.friendshipLevel, limitContext.isCredentialKnown)

	if canExchange then
		return true
	end

	local tip = pg.getGameString("NO_CHANGE_ATTEMPTS")

	if isCredentialLimit then
		tip = PetFriendTradeTextUtils.getExchangeLimitExceededText(limitId, credentialTier)
	end

	pg.global.ui.tips:showTextTip(tip)

	return false
end

function PetExchangeWaitCtrl:getExchangeSelfLimitContext(exchangeInfo)
	local selfPlayerInfo = exchangeInfo.players[pg.me.uid]
	local petInfo = selfPlayerInfo.petInfo
	local isCredentialKnown = selfPlayerInfo.confirm == true and petInfo.isCatchReporting == false

	return {
		petInfo = petInfo,
		pedd = Utils.getExchangePetConfig(petInfo),
		isCredentialKnown = isCredentialKnown
	}
end

function PetExchangeWaitCtrl:showPetDetails()
	self.view.petInfoLeftUComponent:TryChangePage("Details", self.showPetDetail and 1 or 0)
	self.view.petInfoRightUComponent:TryChangePage("Details", self.showPetDetail and 1 or 0)

	if self.exchangeSuccess then
		return
	end

	if self.showPetDetail then
		local exchangeInfo = pg.me:getExchangeSocialInfo()

		if not exchangeInfo then
			return
		end

		for uid, widget in pairs(self.petPropertyUWidget) do
			local playerInfo = exchangeInfo.players[uid]

			if playerInfo.confirm and playerInfo.petInfo then
				PetManagementUtils.renderPetAttribute(playerInfo.petInfo, widget, nil, nil, PET_MANAGEMENT_ATTRIBUTE_EXTRA_INFO)
			end
		end
	end
end

function PetExchangeWaitCtrl:refreshBtnConfirmHotKey(confirmPage)
	if not self.view or not self.view.btnConfirmUButton then
		return
	end

	local btn = self.view.btnConfirmUButton

	if IsNil(btn) then
		return
	end

	local btnGo = btn.gameObject
	local keyTrans = btn.transform:Find("LayoutBox/Key") or btn.transform:Find("Key")

	if keyTrans and not IsNil(keyTrans) then
		local hotKeyContent = keyTrans:GetComponent("HotKeyContent")

		if hotKeyContent and not IsNil(hotKeyContent) then
			self._btnConfirmKeyHotKeyContent = hotKeyContent
		end
	end

	local hotKeyContent = self._btnConfirmKeyHotKeyContent
	local actionPath = CONFIRM_PAGE_ACTION_PATH[confirmPage]

	if actionPath then
		self:bindHotKeyPerform(actionPath, function()
			if self.view and self.view.btnConfirmUButton and not IsNil(self.view.btnConfirmUButton) then
				self.view.btnConfirmUButton:OnClickSimulate()
			end
		end, btnGo, BTN_CONFIRM_BIND_NAME, hotKeyContent)
	else
		self:bindHotKeyPerform("", function()
			return
		end, btnGo, BTN_CONFIRM_BIND_NAME, hotKeyContent)
	end
end

function PetExchangeWaitCtrl:refreshConfirm()
	self.view.confirmUComponent:SetActive(self.curExchangeState > 0)

	if self.curExchangeState == 0 then
		return
	end

	local idNumDict = self:getExchangeCost()

	if self.view.iconPropUImage then
		self.view.iconPropUImage.url = LuaUIUtils.getIconByItemId(self.showCurrencyId)
	end

	local itemCount = ItemUtils.getItemCountById(pg.me, self.showCurrencyId)
	local needCount = ItemUtils.getItemCountFromNumInfo(idNumDict[self.showCurrencyId])
	local isCostEnough = ItemUtils.simpleCheckItemCountEnough(pg.me, idNumDict)

	LuaUIUtils.renderConsumeText(self.view.consumeUBaseText, itemCount, needCount, UIConst.ITEM_STATE.FULL)

	if idNumDict[self.showCurrencyId2] then
		local itemCount2 = ItemUtils.getItemCountById(pg.me, self.showCurrencyId2)
		local needCount2 = ItemUtils.getItemCountFromNumInfo(idNumDict[self.showCurrencyId2])

		LuaUIUtils.renderConsumeText(self.view.consumeExtraUBaseText, itemCount2, needCount2, UIConst.ITEM_STATE.FULL)
		self.view.consumeExtraUWidget:SetActive(true)
	else
		self.view.consumeExtraUWidget:SetActive(false)
	end

	local confirm = self.isConfirm and 1 or 0

	confirm = isCostEnough and confirm or 2
	confirm = (pg.me:getExchangeSocialInfo().isSettling or self.exchangeSuccess) and 3 or confirm

	self.view.confirmUComponent:TryChangePage("Confirm", confirm)
	self:refreshBtnConfirmHotKey(confirm)
end

function PetExchangeWaitCtrl:getExchangeCost()
	local hasShinyStar = false
	local targetUid, targetPetInfo

	for uid, playerInfo in pairs(pg.me:getExchangeSocialInfo().players) do
		local petInfo = self:generatePetDetailData(pg.game.chat:getPlayerInfo(uid), playerInfo.petInfo)

		if petInfo and petInfo.quality and petInfo.quality >= 3 then
			hasShinyStar = true
		end

		if uid ~= pg.me.uid then
			targetUid = uid
			targetPetInfo = playerInfo.petInfo
		end
	end

	if not string.isNilOrEmpty(targetUid) and targetPetInfo then
		return Utils.getExchangePetCost(targetPetInfo, pg.game.chat:getFriendship(targetUid), nil, hasShinyStar)
	end

	return {}
end

function PetExchangeWaitCtrl:showPetModel()
	if not self.uiScene then
		return
	end

	for uid, playerInfo in pairs(pg.me:getExchangeSocialInfo().players) do
		local petInfo = playerInfo.petInfo

		if uid == pg.me.uid then
			self.uiScene:setLeftModel(petInfo.templateId, self.view.imgPetLeftURawImage, petInfo.label, {
				petId = petInfo.id,
				shinyStyle = petInfo.shinyStyle,
				shinyEffectReplace = petInfo.shinyEffectReplace
			})
		elseif petInfo then
			self.uiScene:setRightModel(petInfo.templateId, not playerInfo.confirm, self.view.imgPetRightURawImage, petInfo.label, {
				scheme = petInfo.selectTransmogScheme,
				shinyStyle = petInfo.shinyStyle,
				shinyEffectReplace = petInfo.shinyEffectReplace
			})
		end
	end
end

function PetExchangeWaitCtrl:initUI()
	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	ClientTextUtils.setText(self.view.txtTimesUSDFText, pg.getGameString("PET_EXCHANGE_TIME_LEFT"))
	self:refreshUI()
end

function PetExchangeWaitCtrl:refreshUI()
	self:refreshCurrency()
	self:refreshPetExchangeInfo()
end

function PetExchangeWaitCtrl:refreshPetExchangeInfo()
	local exchangeInfo = pg.me:getExchangeSocialInfo()

	if not exchangeInfo then
		return
	end

	self:refreshExchangeDefaultLimitRemainCount()

	local state = 0

	for uid, exchangeInfo in pairs(exchangeInfo.players) do
		local petInfo = exchangeInfo.petInfo

		self:normalizeExchangePetInfoForDisplay(petInfo)

		if uid == pg.me.uid then
			self.isConfirm = exchangeInfo.clicked == true

			if petInfo then
				self:initBottomBaseInfo(self.view.leftBottomUWidget, self:generateBaseData(pg.me, petInfo), nil, pg.me, petInfo)

				function self.view.listTagLUList.luaRenderItem(button, idx, data)
					LuaUIUtils.renderPetTagList(button, data)
					LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(petInfo.templateId, petInfo.label, petInfo.bodySizeType, petInfo.shinyStyle))
				end

				local tagDatas = LuaUIUtils.getPetTagList(petInfo)

				self.view.listTagLUList:SetList(tagDatas)
				self:initPetDetailInfo(self.view.petInfoLeftUComponent, self:generatePetDetailData(pg.me, petInfo))
			end
		else
			self.view.rightBottomUWidget:SetActive(exchangeInfo.confirm == true)

			local friendInfo = pg.game.chat:getPlayerInfo(uid)

			if friendInfo then
				if exchangeInfo.confirm then
					function self.view.listTagRUList.luaRenderItem(button, idx, data)
						LuaUIUtils.renderPetTagList(button, data)
						LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(petInfo.templateId, petInfo.label, petInfo.bodySizeType, petInfo.shinyStyle))
					end

					local tagDatas = LuaUIUtils.getPetTagList(petInfo)

					self.view.listTagRUList:SetList(tagDatas)
					self:initBottomBaseInfo(self.view.rightBottomUWidget, self:generateBaseData(friendInfo, petInfo), nil, friendInfo, petInfo)
					self:initPetDetailInfo(self.view.petInfoRightUComponent, self:generatePetDetailData(friendInfo, petInfo))

					state = 2
				else
					self:setFriendPlayerInfo(friendInfo)
				end

				if exchangeInfo.clicked then
					state = 1
				end
			end
		end
	end

	self:showPetModel()

	self.curExchangeState = state

	self.view.rootUComponent:TryChangePage("State", state)

	if not self.exchangeSuccess and self._rumblePhase ~= RumblePhase.SWITCH and self._rumblePhase ~= RumblePhase.SILENCE and self._rumblePhase ~= RumblePhase.RESULT_NORMAL and self._rumblePhase ~= RumblePhase.RESULT_VARIANT then
		self:setRumblePhase(RumblePhase.WAIT)
	end

	self:refreshConfirm()
	PetExchangeCountdownCtrl.tryOpen(exchangeInfo)
end

function PetExchangeWaitCtrl:refreshExchangeDefaultLimitRemainCount()
	local limitId = PetFriendTradeUtils.getExchangeDefaultLimitId()
	local remainCount = pg.me.useLimitMap:getRemainCount(limitId)

	ClientTextUtils.setText(self.view.costTimesUBaseText, remainCount)
end

function PetExchangeWaitCtrl:getExchangeLimitId(exchangeInfo)
	local limitContext = self:getExchangeSelfLimitContext(exchangeInfo)

	return PetFriendTradeUtils.getExchangeLimitId(pg.me.useLimitMap, limitContext.petInfo, limitContext.pedd, exchangeInfo.friendshipLevel, limitContext.isCredentialKnown)
end

function PetExchangeWaitCtrl:onExchangeResult(param)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_SELECT) then
		pg.global.ui:close(UIConst.UI_ID_PET_EXCHANGE_SELECT)
	end

	if param.isSuccess then
		self.exchangeSuccess = param.isSuccess

		self:showExchangeAni()
	else
		self:close()
	end
end

function PetExchangeWaitCtrl:showExchangeAni()
	if self.uiScene then
		pg.game.audio:playEvent(AudioConst.EVENT_PET_EXCHANGE_SUCCESS)
		self.view.switchAniAnimation.gameObject:SetActiveEx(true)
		self.view.centerUWidget:SetActive(false)
		self.view.bottomUWidget:SetActive(false)
		self.view.topPanelUWidget:SetActive(false)
		self.uiScene:showPetDownEffect()

		local hasVariant = self:checkHasVariant()

		self:setRumblePhase(RumblePhase.SWITCH)

		local resultPhase = hasVariant and RumblePhase.RESULT_VARIANT or RumblePhase.RESULT_NORMAL

		self._rumbleSilenceTimerId = self:startTimer(function()
			self._rumbleSilenceTimerId = nil

			self:setRumblePhase(RumblePhase.SILENCE)
		end, 4.5)
		self._rumbleResultTimerId = self:startTimer(function()
			self._rumbleResultTimerId = nil

			self:setRumblePhase(resultPhase)
		end, 7)

		if hasVariant then
			self.view.switchAniAnimation:Play(self.changeAni1)
			self.view.vXMeshAnimation:Play(self.changeAni2)
		else
			self.view.switchAniAnimation:Play(self.normalAni1)
			self.view.vXMeshAnimation:Play(self.normalAni2)
		end

		self:startTimer(function()
			self.uiScene:exchangePet()
			self.uiScene:showPetUpEffect()
		end, 4.5)
		self.view.rootUComponent:TryChangePage("State", 3)
		self:startTimer(function()
			self:refreshInfoAfterExchange()
		end, 7)
	end
end

function PetExchangeWaitCtrl:refreshInfoAfterExchange()
	self.view.switchAniAnimation.gameObject:SetActiveEx(false)
	self.view.centerUWidget:SetActive(true)
	self.view.bottomUWidget:SetActive(true)
	self.view.topPanelUWidget:SetActive(true)

	self.showPetDetail = true

	self.view.petInfoLeftUComponent:TryChangePage("Details", self.showPetDetail and 1 or 0)
	self.view.petInfoRightUComponent:TryChangePage("Details", self.showPetDetail and 1 or 0)
	self.view.confirmUComponent:SetActive(true)

	local players = pg.me.tempSocialInfo.players

	for uid, exchangeInfo in pairs(players) do
		local addPetInfo = exchangeInfo.addPetInfo
		local petInfoDict, individualPropUpMap, individualLevelUpMap, isVariant = self:getVariantInfo(addPetInfo)

		logger:debug("ExchangePet dump result, variantInfo=%s, individualPropUpMap=%s", inspect(individualLevelUpMap), inspect(individualPropUpMap))

		if uid == pg.me.uid then
			self:initBottomBaseInfo(self.view.leftBottomUWidget, self:generateBaseData(pg.me, petInfoDict), isVariant, pg.me, petInfoDict)
			self:initPetDetailInfo(self.view.petInfoLeftUComponent, self:generatePetDetailData(pg.me, petInfoDict), individualPropUpMap, individualLevelUpMap)
		else
			local friendInfo = pg.game.chat:getPlayerInfo(uid)

			if friendInfo then
				self:initBottomBaseInfo(self.view.rightBottomUWidget, self:generateBaseData(friendInfo, petInfoDict), isVariant, friendInfo, petInfoDict)
				self:initPetDetailInfo(self.view.petInfoRightUComponent, self:generatePetDetailData(friendInfo, petInfoDict), individualPropUpMap, individualLevelUpMap)
			end
		end
	end

	pg.me.tempSocialInfo = nil
end

function PetExchangeWaitCtrl:checkHasVariant()
	for uid, playerInfo in pairs(pg.me:getExchangeSocialInfo().players) do
		local addPetInfo = playerInfo.addPetInfo
		local petInfoDict, individualPropUpMap, individualLevelUpMap, isVariant = self:getVariantInfo(addPetInfo)

		if isVariant then
			return true
		end
	end

	return false
end

function PetExchangeWaitCtrl:getVariantInfo(petInfo)
	self:normalizeExchangePetInfoForDisplay(petInfo)

	local petInfoDict, clientShowPetInfo, variantInfoLevelUpMap, propListBeforeVariant = unpack(petInfo, 1, 4)

	self:normalizeExchangePetInfoForDisplay(petInfoDict)

	local attributeMap = petInfoDict and PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfoDict) or {}
	local propListAfterVariant = petInfoDict and Utils.genBasePropertyDisplayDict(petInfoDict.basePropertyList, attributeMap)
	local individualPropUpMap = self:generateIndividualPropUpMap(propListBeforeVariant, propListAfterVariant)

	return petInfoDict, individualPropUpMap, variantInfoLevelUpMap.individualLevelUpMap, variantInfoLevelUpMap.isVariant
end

function PetExchangeWaitCtrl:normalizeExchangePetInfoForDisplay(petInfo)
	if not Utils.isTable(petInfo) then
		return
	end

	self:normalizeNumberKeyTable(petInfo)
	self:normalizeNumberKeyTable(petInfo.basePropertyList)
end

function PetExchangeWaitCtrl:normalizeNumberKeyTable(data)
	if not Utils.isTable(data) then
		return
	end

	local convertList = {}

	for key, value in pairs(data) do
		if Utils.isTable(value) then
			self:normalizeNumberKeyTable(value)
		end

		local numberKey = type(key) == "string" and tonumber(key) or nil

		if numberKey then
			convertList[#convertList + 1] = {
				oldKey = key,
				newKey = numberKey,
				value = value
			}
		end
	end

	for _, info in ipairs(convertList) do
		if data[info.newKey] == nil then
			data[info.newKey] = info.value
		end

		data[info.oldKey] = nil
	end
end

function PetExchangeWaitCtrl:generateIndividualPropUpMap(propListBeforeVariant, propListAfterVariant)
	if not propListBeforeVariant or not propListAfterVariant then
		return nil
	end

	local res = {}

	for index, info in ipairs(propListAfterVariant) do
		if propListBeforeVariant[index] and info.displayValue ~= propListBeforeVariant[index].displayValue then
			res[index] = info.displayValue - propListBeforeVariant[index].displayValue
		end
	end

	return res
end

function PetExchangeWaitCtrl:setFriendPlayerInfo(playerInfo)
	local objectReference = self.view.rightBottomUWidget:GetComponent("ObjectReference")
	local avatarUImage = objectReference:GetRefValue("avatarUImage")
	local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
	local headIcon = playerInfo.headIcon or 1

	avatarUImage.url = PlayerHeadIconData[headIcon].res

	local playerName = LuaUIUtils.getPlayerDisplayName(playerInfo.uid, playerInfo.playerName, true)
	local _h = PetExchangeWaitCtrl._platformHooks

	playerName = _h and _h.applyFriendPlayerNameMask and _h.applyFriendPlayerNameMask(self, playerInfo, playerName) or playerName

	ClientTextUtils.setText(playerNameUBaseText, playerName)
end

function PetExchangeWaitCtrl:generateBaseData(playerInfo, petInfo)
	local headIcon = playerInfo.headIcon or 1
	local pData = PetData[petInfo.templateId] or {}
	local petConfigName = ""

	if pData then
		petConfigName = pg.getLocalizationText(pData.name)
	end

	local petName = petInfo.customName

	if petName == nil or petName == "" then
		petName = petConfigName
	end

	local resolvedPlayerName = playerInfo.playerName

	if playerInfo.uid and tostring(playerInfo.uid) ~= tostring(pg.me.uid) then
		resolvedPlayerName = LuaUIUtils.getPlayerDisplayName(playerInfo.uid, playerInfo.playerName, true)
	end

	local data = {
		avatarIcon = PlayerHeadIconData[headIcon].res,
		playerName = resolvedPlayerName,
		petName = petName,
		petCustomName = petInfo.customName,
		petConfigName = petConfigName,
		petCp = Utils.getCpValue(petInfo) or 0,
		petLevel = petInfo.level,
		petExp = petInfo.exp or 0,
		templateId = petInfo.templateId,
		resonanceInfo = petInfo.resonanceInfo
	}

	return data
end

function PetExchangeWaitCtrl:generatePetDetailData(playerInfo, petInfo)
	local pageIndex, ratingStr = PetInfo.getPropRatingResult(petInfo)
	local breedTalent = {}
	local talentList = petInfo.talentList

	for i = 1, #talentList do
		local talentTemplateId = talentList[i].templateId

		if talentTemplateId and PetTalentData[talentTemplateId] then
			local cfg = PetTalentData[talentTemplateId]

			table.insert(breedTalent, {
				name = cfg.talentName,
				icon = cfg.talentIcon,
				quality = cfg.rarity,
				id = talentTemplateId,
				desc = cfg.dec,
				homeDesc = cfg.homeDesc,
				group = cfg.group
			})
		end
	end

	table.sort(breedTalent, function(a, b)
		return a.id < b.id
	end)

	local PetDetail = {
		quality = pageIndex,
		qualityName = pg.getGameString(ratingStr),
		petBaseInfo = {
			{
				key = pg.getGameString("PET_HEIGHT"),
				value = string.format("%.2f%s", petInfo.height, pg.getGameString("METER"))
			},
			{
				key = pg.getGameString("PET_WEIGHT"),
				value = string.format("%.2f%s", petInfo.weight, pg.getGameString("KILOGRAMS"))
			},
			{
				key = pg.getGameString("PET_CAPTURE_TIME"),
				value = pg.getFormatText(pg.getGameString("BEEN_WITH"), math.round((Time.secondCache * 1000 - petInfo.time) / 1000 / 3600 / 24))
			}
		},
		featureId = petInfo.characterInfo.curCharacter,
		breedTalent = breedTalent,
		petInfo = petInfo,
		playerUid = playerInfo.uid
	}

	return PetDetail
end

function PetExchangeWaitCtrl:initBottomBaseInfo(widget, info, hasExchange, playerInfo, petInfo)
	local objectReference = widget:GetComponent("ObjectReference")
	local avatarUImage = objectReference:GetRefValue("avatarUImage")
	local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
	local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")
	local elementUList = objectReference:GetRefValue("elementUList")
	local numCPUBaseText = objectReference:GetRefValue("numCPUBaseText")
	local expUSlider = objectReference:GetRefValue("expUSlider")
	local levelUBaseText = objectReference:GetRefValue("levelUBaseText")
	local petNameUComponent = objectReference:GetRefValue("petNameUComponent")
	local txtNameChangeUBaseText = objectReference:GetRefValue("txtNameChangeUBaseText")
	local nameCoverUBaseText = objectReference:GetRefValue("nameCoverUBaseText")
	local abilityUList = objectReference:GetRefValue("abilityUList")
	local typeUImage = objectReference:GetRefValue("typeUImage")
	local typeUBaseText = objectReference:GetRefValue("typeUBaseText")
	local petTypeUImage = objectReference:GetRefValue("petTypeUImage")
	local petTypeNameUSDFText = objectReference:GetRefValue("petTypeNameUSDFText")
	local starUContainer = objectReference:GetRefValue("starUContainer")

	petNameUComponent:SetActive(true)

	function elementUList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element, true, info.templateId)
	end

	avatarUImage.url = info.avatarIcon

	petNameUComponent:TryChangePage("isChange", hasExchange and 1 or 0)

	local playerName = info.playerName

	ClientTextUtils.setText(petNameUBaseText, info.petName)
	ClientTextUtils.setText(txtNameChangeUBaseText, info.petName)
	ClientTextUtils.setText(nameCoverUBaseText, info.petName)

	local _h = PetExchangeWaitCtrl._platformHooks

	if _h and _h.applyBottomBaseInfoMask then
		local maskResult = _h.applyBottomBaseInfoMask(self, {
			widget = widget,
			objectReference = objectReference,
			info = info,
			playerInfo = playerInfo,
			petInfo = petInfo
		})

		if Utils.isTable(maskResult) then
			playerName = maskResult.playerName or playerName

			if maskResult.petName then
				ClientTextUtils.setText(petNameUBaseText, maskResult.petName)
				ClientTextUtils.setText(txtNameChangeUBaseText, maskResult.petName)
				ClientTextUtils.setText(nameCoverUBaseText, maskResult.petName)
			end
		end
	end

	ClientTextUtils.setText(playerNameUBaseText, playerName)
	ClientTextUtils.setText(numCPUBaseText, info.petCp)
	ClientTextUtils.setText(levelUBaseText, info.petLevel)

	local maxExp = PetLevelData[info.petLevel + 1] ~= nil and PetLevelData[info.petLevel + 1].needExp or 0

	expUSlider.value = maxExp == 0 and 1 or info.petExp / maxExp

	local pData = PetData[info.templateId]
	local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

	elementUList:SetList(elementNames)
	LuaUIUtils.renderPetCharList(abilityUList, info.templateId)
	LuaUIUtils.setPetFunction(typeUImage, typeUBaseText, info.templateId)

	if petTypeUImage and petTypeNameUSDFText then
		local petType = PetData[info.templateId].functionId

		petTypeUImage.url = PetConfigData.petFunctionIcon[petType]

		ClientTextUtils.setText(petTypeNameUSDFText, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	end

	if starUContainer then
		local resonanceInfo = info.resonanceInfo
		local stage = resonanceInfo.resonanceStage or 0
		local level = resonanceInfo.resonanceLevel or 0

		if not stage or not level or stage < 0 or level < 0 then
			return
		end

		local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage)

		starUContainer:SetUrlWithCallback(curStageStarUrl, function(content)
			local maxStage, maxLv = PetManagementUtils.getResonanceMaxStageLv()

			if maxStage <= stage and maxLv <= level then
				return
			end

			local objRef = content:GetComponent("ObjectReference")
			local star1UComponent = LuaUIUtils.safeGetRefValue(objRef, "star1UComponent")
			local star2UComponent = LuaUIUtils.safeGetRefValue(objRef, "star2UComponent")
			local star3UComponent = LuaUIUtils.safeGetRefValue(objRef, "star3UComponent")
			local star4UComponent = LuaUIUtils.safeGetRefValue(objRef, "star4UComponent")
			local star5UComponent = LuaUIUtils.safeGetRefValue(objRef, "star5UComponent")
			local star6UComponent = LuaUIUtils.safeGetRefValue(objRef, "star6UComponent")
			local starUComps = {
				star1UComponent,
				star2UComponent,
				star3UComponent,
				star4UComponent,
				star5UComponent,
				star6UComponent
			}

			content:TryChangePage("State", 1)

			for checkStarLv, starUComp in ipairs(starUComps) do
				if starUComp then
					local isGreatherCur = level > 0 and checkStarLv <= level

					starUComp:TryChangePage("Fill", isGreatherCur and STAR_PART_STATE.LIGHT or STAR_PART_STATE.UNLIGHT)
				end
			end
		end)
	end
end

function PetExchangeWaitCtrl:initPetDetailInfo(widget, info, individualPropUpMap, individualLevelUpMap)
	local objectReference = widget:GetComponent("ObjectReference")
	local qualityUComponent = objectReference:GetRefValue("qualityUComponent")
	local qualityUBaseText = objectReference:GetRefValue("qualityUBaseText")
	local petInfoUList = objectReference:GetRefValue("petInfoUList")
	local propertyUWidget = objectReference:GetRefValue("propertyUWidget")
	local petFeatureUButton = objectReference:GetRefValue("petFeatureUButton")
	local petFeatureUBaseText = objectReference:GetRefValue("petFeatureUBaseText")
	local natureListUList = objectReference:GetRefValue("natureListUList")
	local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	local scrollRectContent = scrollRectUScrollRect.content
	local scrollRectObjectReference = scrollRectContent.transform:GetComponent("ObjectReference")
	local txtDetailsUSDFText = scrollRectObjectReference:GetRefValue("txtDetailsUSDFText")

	function petInfoUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtKeyUBaseText = objectReference:GetRefValue("txtKeyUBaseText")
		local txtValueUBaseText = objectReference:GetRefValue("txtValueUBaseText")

		ClientTextUtils.setText(txtKeyUBaseText, data.key)
		ClientTextUtils.setText(txtValueUBaseText, data.value)
	end

	function natureListUList.luaRenderItem(button, index, data)
		button.enabledTooltip = false
		button:GetChild("Icon"):GetComponent("UImage").url = data.icon

		button:TryChangePage("Quality", data.quality)

		function button.luaClick()
			local talentData = {}

			talentData.targetRect = natureListUList
			talentData.autoHor = true
			talentData.type = UIConst.GIFT_TYPE.BATTLE
			talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
			talentData.giftType = UIConst.GIFT_TYPE.HOME
			talentData.breedTalent = info.breedTalent

			pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
		end
	end

	qualityUComponent:TryChangePage("Quality", info.quality)
	ClientTextUtils.setText(qualityUBaseText, info.qualityName)
	petInfoUList:SetList(info.petBaseInfo)

	self.petPropertyUWidget[info.playerUid] = propertyUWidget

	self:startTimer(function()
		PetManagementUtils.renderPetAttribute(info.petInfo, propertyUWidget, individualPropUpMap, individualLevelUpMap, PET_MANAGEMENT_ATTRIBUTE_EXTRA_INFO)
	end, 0.1)

	local featureInfo = PetCharacterData[info.featureId]

	if featureInfo then
		local feature = Lume.clone(featureInfo)

		feature.featureId = info.featureId

		PetManagementUtils.renderPetFeature(petFeatureUButton, feature, info.petInfo)
		ClientTextUtils.setText(petFeatureUBaseText, pg.getLocalizationText(feature.name))

		local previousPetInfo = LuaUIUtils.customRichTextData.petInfo

		LuaUIUtils.customRichTextData.petInfo = info.petInfo

		ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(feature.desc))

		LuaUIUtils.customRichTextData.petInfo = previousPetInfo
	end

	natureListUList:SetList(info.breedTalent)

	local btnTalent

	if widget == self.view.petInfoLeftUComponent then
		btnTalent = self.view.btnTalentLeftUButton
	else
		btnTalent = self.view.btnTalentRightUButton
	end

	if btnTalent then
		function btnTalent.luaClick()
			local talentData = {
				autoHor = true,
				targetRect = natureListUList,
				type = UIConst.GIFT_TYPE.BATTLE,
				showType = UIConst.GIFT_SHOW_TYPE.GIFT,
				giftType = UIConst.GIFT_TYPE.HOME,
				breedTalent = info.breedTalent
			}

			pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
		end
	end
end

local RUMBLE_TICK_INTERVAL = 1
local PHASE_RUMBLE_PARAM = {
	[RumblePhase.WAIT] = {
		highFreq = 0.05,
		lowFreq = 0.15,
		tickInterval = 1.3,
		duration = 0.3
	},
	[RumblePhase.SWITCH] = {
		highFreq = 0.2,
		lowFreq = 0.3,
		rampMax = 1,
		rampStep = 0.1,
		tickInterval = 0.3,
		duration = 0.3
	},
	[RumblePhase.RESULT_NORMAL] = {
		highFreq = 0.9,
		lowFreq = 1,
		oneShot = true,
		duration = 0.3
	},
	[RumblePhase.RESULT_VARIANT] = {
		highFreq = 1,
		lowFreq = 1,
		oneShot = true,
		duration = 0.6
	}
}

function PetExchangeWaitCtrl:setRumblePhase(phase)
	if self._rumblePhase == phase then
		return
	end

	self._rumblePhase = phase

	local layer = ClientConst.RumbleLayer.PET_EXCHANGE_WAIT

	pg.game.input:stopRumble(layer)

	if self._rumbleTickTimerId then
		self:killTimer(self._rumbleTickTimerId)

		self._rumbleTickTimerId = nil
	end

	local param = PHASE_RUMBLE_PARAM[phase]

	if not param then
		return
	end

	local lowFreq, highFreq = param.lowFreq, param.highFreq
	local duration = param.duration
	local tickInterval = param.tickInterval or RUMBLE_TICK_INTERVAL
	local rampStep, rampMax = param.rampStep, param.rampMax or 1

	local function playPulse()
		pg.game.input:playRumbleByName(layer, "CommonTapLight")
		pg.game.input:playRumble(layer, lowFreq, highFreq, duration, false)
	end

	local function tick()
		playPulse()

		if rampStep then
			lowFreq = math.min(rampMax, lowFreq + rampStep)
			highFreq = math.min(rampMax, highFreq + rampStep)
		end
	end

	tick()

	if not param.oneShot then
		self._rumbleTickTimerId = self:startTimer(tick, tickInterval, true)
	end
end

function PetExchangeWaitCtrl:_clearAllRumble()
	if self._rumbleSilenceTimerId then
		self:killTimer(self._rumbleSilenceTimerId)

		self._rumbleSilenceTimerId = nil
	end

	if self._rumbleResultTimerId then
		self:killTimer(self._rumbleResultTimerId)

		self._rumbleResultTimerId = nil
	end

	self:setRumblePhase(RumblePhase.OFF)
end

function PetExchangeWaitCtrl:refreshCurrency()
	self.view.listCurrencyUList:SetList({
		{
			itemId = self.showCurrencyId
		}
	})
end

function PetExchangeWaitCtrl:onDestroy()
	pg.game.uiScene:switchOutScene(UISceneConst.PET_EXCHANGE_WAIT_SCENE)
	PetManagementUtils.clearPetAttributeTimer()
	self:_clearAllRumble()
	UICtrl.onDestroy(self)
end

function PetExchangeWaitCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetExchangeWaitCtrl:onShow()
	return
end

function PetExchangeWaitCtrl:onHide()
	self:_clearAllRumble()
end

return PetExchangeWaitCtrl
