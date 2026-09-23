-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Component\\PropDetailComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local Mathf = require("Common.Math.Mathf")
local HoldItemData = require("Data.hold_item_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemUseCheckUtils = require("Common.Utils.ItemUseCheckUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local PetConfigData = require("Data.pet_config_data")
local ItemData = require("Data.item_data")
local ItemEffectData = require("Data.item_effect_data")
local ItemTTLUtils = require("Common.Utils.ItemTTLUtils")
local PetFormChangeData = require("Data.pet_form_change_data")
local LimitData = require("Data.limit_data")
local PetCharacterData = require("Data.pet_character_data")
local layer = require("Common.Const.PhysicsLayerConst")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PropDetailComponent = Class.LightClass("PropDetailComponent", UIComponent)

PropDetailComponent.ITEM_SOURCE_TRIGGER_TYPE = {
	MAP_MARK = 2,
	TIPS = 1
}
PropDetailComponent.ITEM_SOURCE_TRIGGER_FUNC = {
	[PropDetailComponent.ITEM_SOURCE_TRIGGER_TYPE.TIPS] = "showItemSourceTips",
	[PropDetailComponent.ITEM_SOURCE_TRIGGER_TYPE.MAP_MARK] = "markItemSourceInMap"
}

function PropDetailComponent:findObjects()
	self.container = self.view.propInfoUContainer
	self.lockerHotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.ctrl.view.gameObject, "Raw/GamepadLeftStickPress")
	self.lockerHotKeyBind.actionPath = "Raw/GamepadLeftStickPress"
	self.lockerHotKeyBind.isVirtual = true

	function self.lockerHotKeyBind.luaTrigger(inputInfo)
		return true
	end
end

function PropDetailComponent:onHide()
	UIComponent.onHide(self)
	self.view.layoutBoxUse:SetActive(false)
	self.view.btnUse1:SetActive(false)
end

function PropDetailComponent:initView()
	self.showLockButton = true

	LuaUIUtils.refreshItemInfoContainer(self.container, function(content)
		content:TryChangePage("isEmpty", 1)
	end)

	function self.view.btnUse1.luaClick()
		self:onClickUseBtn()
	end

	function self.view.btnUse2.luaClick()
		self:onClickUseBtn()
	end

	function self.view.btnCompound.luaClick()
		self:openItemCompositePopup()
	end

	function self.view.btnShowUButton.luaClick()
		self:tryShowItemInHand()
	end

	ClientTextUtils.setText(self.view.btnShowUButton.title, pg.getGameString("CARRY_ITEM_USE"))
end

function PropDetailComponent:showLockBtn(show)
	self.showLockButton = show

	if self.itemInfoParam then
		self.itemInfoParam.showLock = show and not self.fromSlot and not self.model:isInOperationState(self.model.STATE_DECOMPOSE)

		self:refreshItemInfo()
	end
end

function PropDetailComponent:refreshItemInfo()
	if not self.itemInfoParam then
		return
	end

	LuaUIUtils.renderItemInfo(self.container, self.itemInfoParam)
end

function PropDetailComponent:openItemCompositePopup()
	local isTTLExchange = ItemTTLUtils.getState(self.packSlot, Time.secondCache) == ItemTTLUtils.STATE_EXPIRED

	LuaUIUtils.openItemCompound(self.compoundList, isTTLExchange)
end

function PropDetailComponent:tryShowItemInHand()
	if not HoldItemData[self.propData.itemId] then
		return
	end

	pg.me:tryTakeOutItem(self.propData.invId, self.propData.index)
end

function PropDetailComponent:showPropDetails(propData, fromSlot)
	if propData == nil or propData.itemId == 0 then
		self.itemInfoParam = nil

		LuaUIUtils.refreshItemInfoContainer(self.container, function(content)
			content:TryChangePage("isEmpty", 1)
		end)

		return
	end

	local itemId = propData.itemId

	self.fromSlot = fromSlot
	self.packSlot = propData.packSlot
	self.propData = propData

	local isBall = self.propData.invIdx == ItemConst.INV_TYPE_BALL
	local ballBtnState = isBall and self:getCatchBallBtnState() or nil
	local showCarry = HoldItemData[itemId] ~= nil

	if propData.source then
		local detailSourceInfo = self.model:getDetailSourceInfo(propData.source)

		if ToBool(detailSourceInfo) then
			-- block empty
		end
	end

	local configData = ItemData[itemId] or {}
	local ttlState = ItemTTLUtils.getState(self.packSlot, Time.secondCache)
	local ttlUnavailable = ttlState == ItemTTLUtils.STATE_NOT_STARTED or ttlState == ItemTTLUtils.STATE_EXPIRED
	local ttlChangeItem = tonumber(configData.ttlChangeItem) or 0
	local hideUseButton = ItemTTLUtils.shouldHideUseButton(ttlState, ttlChangeItem)
	local hideCompoundButton = ItemTTLUtils.shouldHideCompoundButton(ttlState, ttlChangeItem)
	local effectData = ItemEffectData[itemId]
	local showBtnUse = false

	if effectData == nil then
		-- block empty
	else
		showBtnUse = effectData.sType == ItemConst.USEITEM_TYPE_VIEWABLE and true or effectData.canUseInBag or isBall

		local useTxt

		if isBall then
			useTxt = ballBtnState.text
		else
			useTxt = effectData.buttonTxt ~= nil and pg.getLocalizationText(effectData.buttonTxt) or pg.getGameString("USE")
		end

		ClientTextUtils.setText(self.view.btnUse1.title, useTxt)
		ClientTextUtils.setText(self.view.btnUse2.title, useTxt)

		local typePage = isBall and ballBtnState.typePage or 0

		self.view.btnUse1:TryChangePage("Type", typePage)
		self.view.btnUse2:TryChangePage("Type", typePage)
	end

	local showBtnCompound = false

	self.compoundList = self.model:tryGetCompoundList(itemId)

	if ttlState ~= ItemTTLUtils.STATE_EXPIRED and ttlChangeItem > 0 and self.compoundList then
		local availableCompoundList = {}

		for _, compoundId in ipairs(self.compoundList) do
			if compoundId ~= ttlChangeItem then
				availableCompoundList[#availableCompoundList + 1] = compoundId
			end
		end

		self.compoundList = #availableCompoundList > 0 and availableCompoundList or nil
	end

	if ttlState == ItemTTLUtils.STATE_EXPIRED and ttlChangeItem > 0 then
		self.compoundList = {
			ttlChangeItem
		}
		showBtnCompound = true
	elseif ttlState == ItemTTLUtils.STATE_NOT_STARTED then
		self.compoundList = nil
	elseif self.compoundList and effectData and effectData.sType ~= ItemConst.USEITEM_TYPE_EXCHANGE_ITEM then
		showBtnCompound = true
	end

	showBtnUse = showBtnUse and not hideUseButton
	showBtnCompound = showBtnCompound and not hideCompoundButton
	showCarry = showCarry and not ttlUnavailable

	if self.propData.invIdx == ItemConst.INV_TYPE_BALL and Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		showBtnUse = false
	end

	local showLayoutBox = showBtnUse and showBtnCompound or showCarry

	self.view.btnUse2:SetActive(showBtnUse)
	self.view.btnCompound:SetActive(showBtnCompound)
	ClientTextUtils.setText(self.view.btnCompound.title, ttlState == ItemTTLUtils.STATE_EXPIRED and pg.getGameString("CONVERT") or pg.getGameString("COMPOUND"))
	self.view.layoutBoxUse:SetActive(showLayoutBox)
	self.view.btnShowUButton:SetActive(showCarry)
	self.view.btnUse1:SetActive(not showLayoutBox and (showBtnUse or showBtnCompound))

	if not showLayoutBox then
		if showBtnUse then
			function self.view.btnUse1.luaClick()
				if self.propData.invIdx == ItemConst.INV_TYPE_BALL then
					self:onClickCatchBallEquipBtn()
				elseif effectData and effectData.sType == ItemConst.USEITEM_TYPE_VIEWABLE then
					self:onClickCheckBtn()
				else
					self:onClickUseBtn()
				end
			end
		elseif showBtnCompound then
			function self.view.btnUse1.luaClick()
				self:openItemCompositePopup()
			end

			ClientTextUtils.setText(self.view.btnUse1.title, ttlState == ItemTTLUtils.STATE_EXPIRED and pg.getGameString("CONVERT") or pg.getGameString("COMPOUND"))
		end
	end

	local isSocialItem = ItemUtils.isSocialItem(itemId)
	local isChangeFormItem = ItemUtils.isChangeFormItem(itemId)
	local visualInteractable = true

	if isSocialItem then
		visualInteractable = not pg.me:isInTeam() and (pg.me.space.sceneId == ClientConst.SCENE_MAIN_SINGLE_WORLD or Utils.isSpacePhase(pg.me.space.sceneId) == ClientConst.SCENE_MAIN_SINGLE_WORLD)
	elseif isChangeFormItem then
		local petInfos = PetManagementDataHelper.getGroupInfoById(PetManagementDataHelper.getSelectGroupId())
		local curPetInfo = petInfos[1]
		local curPetTemplateId = curPetInfo and curPetInfo.templateId or nil

		visualInteractable = Utils.petCanChangeForm(pg.me, curPetTemplateId) ~= false
	elseif isBall then
		visualInteractable = ballBtnState.visualInteractable
	end

	self.view.btnUse1.visualInteractable = visualInteractable
	self.view.btnUse2.visualInteractable = visualInteractable

	local isLock = false

	if not fromSlot and self.packSlot then
		isLock = self.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
	end

	self.itemInfoParam = {
		fromParamCount = true,
		skipFoldHotkey = true,
		itemId = itemId,
		itemCount = propData.count,
		invId = propData.invId,
		genID = propData.index,
		packSlot = self.packSlot,
		ttlState = ttlState,
		ttlStatusText = LuaUIUtils.getItemTTLStatusText(self.packSlot, Time.secondCache),
		expiredExchangeFunc = ttlState == ItemTTLUtils.STATE_EXPIRED and ttlChangeItem > 0 and function()
			self:openItemCompositePopup()
		end or nil,
		showLock = self.showLockButton and not fromSlot and not self.model:isInOperationState(self.model.STATE_DECOMPOSE),
		isLocked = isLock,
		btnLockFunc = function()
			self:onClickLockBtn()
		end
	}

	self:refreshItemInfo()
	self:show()
end

local function hitCallBack(isSelect)
	pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.LockCatchBallTips, isSelect and TimeUtils.getNextDayBegin(Time.getSecond()) or 0, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PropDetailComponent:getCatchBallBtnState()
	local isLock = self.packSlot and self.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
	local slotType = self.propData.catchBallSlotType or ItemUtils.getBallQuickSlotType(self.propData.itemId)
	local bindSlot = self.propData.bindCatchBallSlot
	local isEquipped = bindSlot and bindSlot > 0

	if isEquipped then
		return {
			typePage = 1,
			text = pg.getGameString("INVENTORY_CATCHBALL_UNLOAD"),
			visualInteractable = not isLock
		}
	end

	local isFull = self.model:getFirstEmptyBallSlot(slotType) == nil

	if isFull then
		return {
			visualInteractable = false,
			typePage = 0,
			text = pg.getGameString("INVENTORY_CATCHBALL_FULL")
		}
	end

	return {
		typePage = 0,
		text = pg.getGameString("INVENTORY_CATCHBALL_EQUIP"),
		visualInteractable = not isLock
	}
end

function PropDetailComponent:onClickCatchBallEquipBtn()
	if self.propData == nil then
		return
	end

	if self.packSlot and self.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED) then
		pg.global.showBubbleMessageRaw(pg.getGameString("INVENTORY_CATCHBALL_UNLOCK_FIRST"))

		return
	end

	local slotType = self.propData.catchBallSlotType or ItemUtils.getBallQuickSlotType(self.propData.itemId)
	local bindSlot = self.propData.bindCatchBallSlot

	if bindSlot and bindSlot > 0 then
		self.model:trySetupBallToQuickSlot(slotType, bindSlot, self.model.EMPTY_ITEM_ID)

		return
	end

	local emptySlot = self.model:getFirstEmptyBallSlot(slotType)

	if not emptySlot then
		pg.global.showBubbleMessageRaw(pg.getGameString("INVENTORY_CATCHBALL_SLOT_FULL"))

		return
	end

	self.model:trySetupBallToQuickSlot(slotType, emptySlot, self.propData.itemId, ItemConst.QUICK_SLOT_SET_MODE_INSERT_HEAD)
end

function PropDetailComponent:onClickLockBtn()
	if not self.packSlot then
		return
	end

	local isLock = self.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

	if not isLock and self.propData.isCaptureBind and self.propData.invIdx == ItemConst.INV_TYPE_BALL then
		local showTime = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.LockCatchBallTips, 0, ClientConst.CACHE_TYPE_FLAG.USER)
		local needShowTips = showTime < Time.getSecond()

		if needShowTips then
			pg.global.showConfirmMsgRaw(pg.getGameString("INVENTORY_CATCHBALL_LOCKTITLE"), pg.getGameString("INVENTORY_CATCHBALL_LOCKCONTENT"), function()
				self.model:trySwitchSelectPropLock()
				self.ctrl:onClickLockBtn(self.propData)
			end, nil, nil, nil, nil, {
				hint = true,
				hintCb = hitCallBack
			})
		else
			self.model:trySwitchSelectPropLock()
			self.ctrl:onClickLockBtn(self.propData)
		end
	else
		self.model:trySwitchSelectPropLock()
	end
end

function PropDetailComponent:onClickDropBtn()
	self.model:tryDropItem()
end

function PropDetailComponent:onClickUseBtn()
	if self.propData == nil then
		return
	end

	local itemId = self.propData.itemId
	local effectData = ItemEffectData[itemId]

	if not effectData then
		return
	end

	if not effectData.canUseInBag then
		return
	end

	if effectData.sType == ItemConst.USEITEM_TYPE_PET_EXP then
		if self.model:checkPetSlotHasPet() then
			pg.global.ui:open(UIConst.UI_ID_INVENTORY_ITEM_USE, {
				itemId = itemId
			})
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_NO_PET"), 2)
		end
	elseif effectData.sType == ItemConst.USEITEM_TYPE_DREAM_EGG and effectData.needItem then
		pg.global.ui.commonUseConfirm:open({
			title = pg.getGameString("USE_ITEM_DREAM_EGG"),
			tipTop = pg.getGameString("USE_ITEM_DREAM_EGG_COST_TIP"),
			data = effectData.needItem,
			confirmCb = function()
				self:useItemInner(itemId, effectData)
			end
		})
	elseif effectData.sType == ItemConst.USEITEM_TYPE_PET_CHARACTER_MODIFY then
		pg.global.showBubbleMessageRaw(pg.getGameString("DRAG_INFO"), 2)
	elseif effectData.sType == ItemConst.USEITEM_TYPE_PET_CHARACTER_RANDOM then
		pg.global.ui:open(UIConst.UI_ID_INVENTORY_PET_PROP_USE, {
			propData = self.propData,
			sType = effectData.sType
		})
	elseif ItemUtils.isSocialItem(itemId) then
		pg.game.social:useInviteItem(self.propData.invIdx, self.propData.index)
	elseif ItemUtils.isChangeFormItem(itemId) then
		local petInfos = PetManagementDataHelper.getGroupInfoById(PetManagementDataHelper.getSelectGroupId())
		local curPetInfo = petInfos[1]
		local curPetTemplateId = curPetInfo and curPetInfo.templateId or nil
		local canChange, targetTemplateId = ItemUtils.petCanChangeFormByItem(pg.me, curPetTemplateId, itemId)
		local useItemId = itemId

		if not canChange then
			local canChangeTargetId = Utils.petCanChangeForm(pg.me, curPetTemplateId)

			if canChangeTargetId == false then
				pg.global.showBubbleMessageById(NoticeDef.PET_FORM_CHANGE_ITEM_INVALID)

				return
			else
				useItemId = PetFormChangeData[canChangeTargetId] and PetFormChangeData[canChangeTargetId].needItem[1]
				targetTemplateId = canChangeTargetId

				pg.global.showBubbleMessageRaw(pg.getGameString("USE_FORM_ITEM_TIPS"))
			end
		end

		pg.global.ui:open(UIConst.UI_ID_PET_CHANGE_FORM, {
			withPetList = true,
			itemId = useItemId,
			petInfo = curPetInfo,
			targetTemplateId = targetTemplateId
		})
	elseif effectData.sType == ItemConst.USEITEM_TYPE_EXCHANGE_ITEM then
		pg.global.ui:open(UIConst.UI_ID_EXCHANGE_ITEM, {
			propData = self.propData
		})
	elseif effectData.sType == ItemConst.USEITEM_TYPE_PROPERTY_ENHANCE or effectData.sType == ItemConst.USEITEM_TYPE_RANDOM_TO_TALENT or effectData.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL or effectData.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL or effectData.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE then
		pg.global.ui:open(UIConst.UI_ID_INVENTORY_PET_PROP_USE, {
			propData = self.propData,
			sType = effectData.sType
		})
	elseif effectData.sType == ItemConst.USEITEM_TYPE_MULTI_CHOOSE_CHEST then
		pg.global.ui:open(UIConst.UI_ID_MULTI_CHOOSE_CHEST, {
			itemId = itemId
		})
	elseif effectData.sType == ItemConst.USEITEM_TYPE_SPAWN_ENVOBJ then
		local ret, hitInfo = pg.global.physicsMgr:GetSpawnEnvHit()

		if ret then
			self:useItem(itemId, self.propData.invIdx, self.propData.index, 1, {
				pos = hitInfo.point,
				normal = hitInfo.normal
			})
		else
			local me = pg.me
			local myPos = me:getPosition():Clone()

			self:useItem(itemId, self.propData.invIdx, self.propData.index, 1, {
				pos = myPos
			})
		end
	else
		self:useItemInner(itemId, effectData)
	end
end

function PropDetailComponent:tryUsePropertyItem(itemId)
	local petInfos = PetManagementDataHelper.getGroupInfoById(PetManagementDataHelper.getSelectGroupId())
	local curPetInfo = petInfos[1]
	local petInfo = pg.me:getPetInfo(curPetInfo.id)
	local res, state = ItemUseCheckUtils.check_propertyEnhance(petInfo, true, true)

	if state == NoticeDef.ERROR_CONFIG_NIL or state == NoticeDef.ERROR_CONFIG_HAS_ERROR or state == NoticeDef.ERROR_ALREADY_ENHANCED then
		pg.global.showBubbleMessage(state)

		return
	end

	local maxEnhance = PetConfigData.individualPropEnhanceMax
	local attrs = PetManagementDataHelper.getIndividualLevel(curPetInfo.id)
	local allExceed4, hasExceed4 = true, false
	local allMax, hasMax = true, false
	local recommends = {}
	local isHasRecommend = false

	for k, v in pairs(attrs) do
		if v.isRecommend then
			isHasRecommend = true
			recommends[#recommends + 1] = v
			v.id = k

			if maxEnhance <= v.baseLv then
				hasExceed4 = true
				v.state = 3
			else
				allExceed4 = false

				if v.indLv >= v.individualLevelMax then
					hasMax = true
					v.state = 2
				else
					allMax = false
					v.state = 1
				end
			end
		end
	end

	if allExceed4 then
		if isHasRecommend then
			pg.global.showBubbleMessageRaw(pg.getGameString("USE_PROPERTY_PROP_U_MAX_TIP"))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("NO_RECOMMENDED_PROP"))
		end

		return
	end

	local propName = LuaUIUtils.getNameByItemId(itemId)

	propName = string.format(pg.getGameString("USE_PROP_TITLE"), propName, curPetInfo.name)

	local content = ""

	table.sort(recommends, function(a, b)
		return a.state > b.state
	end)

	for i, v in ipairs(recommends) do
		if not string.isNilOrEmpty(content) then
			content = string.format("%s\n", content)
		end

		if v.state == 1 then
			content = content .. string.format(pg.getGameString("PROPERTY_ENHANCE_ENABLE_TIP"), v.name)
		elseif v.state == 2 then
			content = content .. string.format(pg.getGameString("PROPERTY_ENHANCE_MAX_ENABLE_TIP"), v.name, v.name)
		elseif v.state == 3 then
			content = content .. string.format(pg.getGameString("PROPERTY_ENHANCE_MAX_DISABLE_TIP"), v.name)
		end
	end

	pg.global.showConfirmMsgRaw(propName, content, function()
		self:useItemInner(itemId, {
			petId = curPetInfo.id
		})
	end)
end

function PropDetailComponent:useItemInner(itemId, effectData)
	local usedTimes = self.packSlot and self.packSlot:getUseTimes() or 0
	local res, code = self.model:checkItemUseAble({
		num = 1,
		id = itemId,
		usedTimes = usedTimes
	})

	if res == false then
		if code == NoticeDef.ERROR_LIMIT_EXCEED then
			LuaMsgUtils.showBubbleLimitExceed(itemId)
		end

		return
	end

	if effectData.needCheck then
		pg.global.showConfirmMsg(nil, NoticeDef.TELEPORT_CONFIRM, function()
			self:useItem(itemId, self.propData.invIdx, self.propData.index, 1)
		end, nil, nil)
	else
		self:useItem(itemId, self.propData.invIdx, self.propData.index, 1, effectData)
	end
end

function PropDetailComponent:usePetCharacterRandom(itemId, petId)
	local pet = pg.me:getPetInfo(petId)
	local characterList = Utils.getValidCharacterList(pet, true)

	if #characterList == 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("CHARACTER_ONLY_TIP"))

		return
	end

	local curCharacterId = pet.characterInfo.curCharacter

	if PetCharacterData[curCharacterId].rare == 1 then
		local curCharacterName = pg.getFormatText("<style=Q_5>{0}</style>", pg.getLocalizationText(PetCharacterData[curCharacterId].name))
		local targetCharacterName = pg.getFormatText("<style=Q_3>{0}</style>", pg.getLocalizationText(PetCharacterData[characterList[1]].name))

		pg.global.showConfirmMsgRaw(pg.getGameString("PET_CHARACTER_MODIFY_TITLE"), pg.getFormatText(pg.getGameString("PET_CHARACTER_MODIFY_RARE"), curCharacterName, targetCharacterName), function()
			self:useItemInner(itemId, {
				petId = petId
			})
		end, nil)
	else
		local curCharacterName = pg.getFormatText("<style=Q_3>{0}</style>", pg.getLocalizationText(PetCharacterData[curCharacterId].name))
		local targetCharacterName = pg.getFormatText("<style=Q_5>{0}</style>", pg.getLocalizationText(PetCharacterData[characterList[1]].name))

		pg.global.showConfirmMsgRaw(pg.getGameString("PET_CHARACTER_MODIFY_TITLE"), pg.getFormatText(pg.getGameString("PET_CHARACTER_MODIFY_COMMON"), curCharacterName, targetCharacterName), function()
			self:useItemInner(itemId, {
				petId = petId
			})
		end, nil)
	end
end

function PropDetailComponent:onClickCheckBtn()
	if self.propData == nil then
		return
	end

	local itemId = self.propData.itemId
	local effectData = ItemEffectData[itemId]

	if not effectData then
		return
	end

	if not effectData.sType == ItemConst.USEITEM_TYPE_VIEWABLE or effectData.bindViewType == nil or #effectData.bindViewType == 0 then
		return
	end

	LuaUIUtils.openItemViewer(effectData.bindViewType)
end

function PropDetailComponent:useItem(itemId, invId, genId, num, clientArgs)
	if Utils.itemId2CastItemId(itemId) then
		self.view.closeBtn.luaClick()
		pg.global.ui:close(UIConst.UI_ID_FUNC_MENU)

		local player = pg.me

		player:throwItemFromBag(itemId)

		return
	end

	LuaMsgUtils.useItem(itemId, invId, genId, num, clientArgs or {}, function()
		self:showPropDetails(self.propData, self.fromSlot)
	end)
end

function PropDetailComponent.showItemSourceTips(param)
	return
end

function PropDetailComponent.markItemSourceInMap(param)
	pg.global.showBubbleMessage(NoticeDef.FUNC_NOT_UNLOCK)
end

function PropDetailComponent:onClickCaptureBindBtn(isLogin)
	self.model:tryBindCaptureBall(isLogin)
end

function PropDetailComponent:refreshLockStatus()
	if self.packSlot then
		local isLock = self.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

		if self.itemInfoParam then
			self.itemInfoParam.isLocked = isLock

			self:refreshItemInfo()
		end
	end

	self:applyCatchBallBtnState()
end

function PropDetailComponent:applyCatchBallBtnState()
	if self.propData == nil or self.propData.invIdx ~= ItemConst.INV_TYPE_BALL then
		return
	end

	local state = self:getCatchBallBtnState()

	ClientTextUtils.setText(self.view.btnUse1.title, state.text)
	ClientTextUtils.setText(self.view.btnUse2.title, state.text)
	self.view.btnUse1:TryChangePage("Type", state.typePage)
	self.view.btnUse2:TryChangePage("Type", state.typePage)

	self.view.btnUse1.visualInteractable = state.visualInteractable
	self.view.btnUse2.visualInteractable = state.visualInteractable
end

return PropDetailComponent
