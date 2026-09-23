-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmog\\Component\\PetTransmogMainInfoComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogModel = require("Guis.Panels.PetTransmog.PetTransmogModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local SLOT_TYPE_MAX = Const.PetTransmogSlotType.Max
local PURPLE_QUALITY = ItemConst.ITEM_QUALITY.PURPLE
local GOLDEN_QUALITY = ItemConst.ITEM_QUALITY.GOLD
local ROLL_ANIM_DURATION = 0.5
local COST_COLOR_NORMAL = "#3D3D50"
local COST_COLOR_NOT_ENOUGH = "#F67574"
local PetTransmogMainInfoComponent = Class.LightClass("PetTransmogMainInfoComponent", UIComponent)

function PetTransmogMainInfoComponent:onCtor(extInfo)
	self.isRollRequesting = false
	self.isRolling = false
	self.isRollFlowLocked = false
	self.lastTransmogProgress = nil
	self.lastTransmogValue = nil
	self.lastUnlockedSet = nil
	self.lastCostSign = nil
	self.rollAnimSeq = 0
	self.rollFlowSeq = 0
	self.lastHoleQuality = nil
	self.holeQualityChanged = nil
	self.lastFlashSlotId = nil
	self.isRefreshingUseSpecialItemFlag = false
end

function PetTransmogMainInfoComponent:initView()
	if self.view.txtBtnCheck then
		local specialItemId = PetTransmogUtils.getTransmogSpecialItemId()
		local itemIcon = LuaUIUtils.getItemShowText(specialItemId)
		local itemName = LuaUIUtils.getNameByItemId(specialItemId) or ""

		ClientTextUtils.setText(self.view.txtBtnCheck, pg.getGameString("PETTRANSMOGRIFY_SPECIAL_ONLY") .. itemIcon .. itemName)
	end

	if self.view.btnGoon then
		function self.view.btnGoon.luaClick()
			self:onBtnRoll()
		end
	end

	if self.view.btnSavePlan then
		function self.view.btnSavePlan.luaClick()
			self:onBtnSavePlan()
		end
	end

	if self.view.btnComfirmPlanMain then
		function self.view.btnComfirmPlanMain.luaClick()
			self:onBtnComfilmMainPlan()
		end
	end

	if self.view.btnCheck then
		function self.view.btnCheck.luaSelectChanged(selected)
			self:onUseSpecialItemSelected(selected)
		end
	end

	if self.view.holeList then
		function self.view.holeList.luaRenderItem(button, index, data)
			self:onRenderHoleItem(button, data)
		end
	end

	if self.view.stars then
		for i = 1, SLOT_TYPE_MAX do
			local star = self.view.stars[i]

			if star then
				local starRef = star:GetComponent("ObjectReference")
				local btnLockUButton = starRef:GetRefValue("btnLockUButton")

				function star.luaClick()
					self:onStarInfoClick(i, star)
				end

				if btnLockUButton then
					function btnLockUButton.luaClick()
						self:onStarClick(i)
						self.ctrl:refreshPetRoundConsoleBar()
					end
				end
			end
		end
	end
end

function PetTransmogMainInfoComponent:refreshUseSpecialItemFlag()
	local flag = PetTransmogUtils.getUseSpecialItemFlag(self.model:getPetId())
	local isInvalid = self.model:getLockedHoleCount() > 0 or not PetTransmogUtils.canUseTransmogSpecialItem(self.model:getPetId())

	if flag and isInvalid then
		self.model:setUseSpecialItemFlag(false)
		self:refreshUseSpecialItemButton(false)
		pg.game.petTransmog:requestSetUseItemFlag(self.model:getPetId(), false)

		return
	end

	self.model:setUseSpecialItemFlag(flag)
	self:refreshUseSpecialItemButton(flag)
end

function PetTransmogMainInfoComponent:onUseSpecialItemSelected(selected)
	if self.isRefreshingUseSpecialItemFlag then
		return
	end

	selected = selected == true

	if not selected then
		self:setUseSpecialItemFlag(false)

		return
	end

	local petId = self.model:getPetId()

	if self.model:getLockedHoleCount() > 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("PETTRANSMOGRIFY_SPECIAL_LOCKED"))
		self:refreshUseSpecialItemButton(false)

		return
	end

	if not PetTransmogUtils.canUseTransmogSpecialItem(petId) then
		pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_SPECIAL_SLOT_LIMIT"), PetTransmogUtils.getSpecialSlotSuitId()))
		self:refreshUseSpecialItemButton(false)

		return
	end

	local desc = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_SPECIAL_CONFIRM"), PetTransmogUtils.getSpecialSlotSuitId())
	local hideTs = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.PetTransmogUseSpecialItemTipTs, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if hideTs + 604800 > Time.secondCache then
		self:setUseSpecialItemFlag(true)

		return
	end

	local hideSevenDays = false

	pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_ITEM_TIP_TITLE"), desc, function()
		if hideSevenDays then
			pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.PetTransmogUseSpecialItemTipTs, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
			pg.global.prefsCacheUtils:save()
		end

		self:setUseSpecialItemFlag(true)
	end, nil, function()
		self:refreshUseSpecialItemButton(false)
	end, nil, nil, {
		hint = true,
		hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 7),
		hintCb = function(isSelected)
			hideSevenDays = isSelected
		end
	})
end

function PetTransmogMainInfoComponent:setUseSpecialItemFlag(flag)
	flag = flag == true

	self.model:setUseSpecialItemFlag(flag)
	self:refreshUseSpecialItemButton(flag)
	self:refreshCostInfo(true)

	if self.view.btnGoon then
		self.view.btnGoon:InvokeCallbackWithChildren(CS.XGUI.EInvokeTime.Custom1)
	end

	pg.game.petTransmog:requestSetUseItemFlag(self.model:getPetId(), flag)
end

function PetTransmogMainInfoComponent:refreshUseSpecialItemButton(flag)
	if not self.view.btnCheck then
		return
	end

	self.isRefreshingUseSpecialItemFlag = true

	self.view.btnCheck:SetSelected(flag == true)

	self.isRefreshingUseSpecialItemFlag = false
end

function PetTransmogMainInfoComponent:onHide()
	self.rollAnimSeq = (self.rollAnimSeq or 0) + 1
	self.rollFlowSeq = (self.rollFlowSeq or 0) + 1
	self.isRolling = false
	self.isRollRequesting = false
	self.isRollFlowLocked = false
end

function PetTransmogMainInfoComponent:onDestroy()
	self.rollAnimSeq = (self.rollAnimSeq or 0) + 1
	self.rollFlowSeq = (self.rollFlowSeq or 0) + 1
	self.isRolling = false
	self.isRollRequesting = false
	self.isRollFlowLocked = false
end

function PetTransmogMainInfoComponent:refreshMainInfo()
	self:refreshPetRound()
	self:refreshCurrency()
	self:refreshUseSpecialItemFlag()

	local petId = self.model:getPetId()
	local scheme = PetTransmogUtils.getCurrentDisplayScheme(petId)

	if self.view.tMPBeatUTextBeat then
		self.view.tMPBeatUTextBeat:SetText(scheme and scheme.transmogValue or 0)
	end

	self:refreshCostInfo()

	if self.view.holeList then
		self.view.holeList:SetList(self.ctrl:buildHoleData(scheme))
	end

	self:refreshBaptizeState(scheme, petId)
end

function PetTransmogMainInfoComponent:refreshCurrentSchemeInfo(scheme)
	if self.view.holeList then
		self.view.holeList:SetList(self.ctrl:buildHoleData(scheme))
	end

	self:refreshBaptizeState(scheme, self.model:getPetId())
end

function PetTransmogMainInfoComponent:refreshBaptizeState(scheme, petId)
	if not self.view.rootUComponent then
		return
	end

	local state = PetTransmogModel.BAPTIZE_STATE.IDLE
	local suitInfo = petId and PetTransmogUtils.getCurrentSuitInfo(petId)
	local suitQuality = suitInfo and suitInfo.quality or 0

	if suitQuality >= GOLDEN_QUALITY then
		state = PetTransmogModel.BAPTIZE_STATE.RESULT
	elseif suitQuality >= PURPLE_QUALITY then
		state = PetTransmogModel.BAPTIZE_STATE.PURPLE_RESULT
	end

	self.model:setBaptizeState(state)
	self.view.rootUComponent:TryChangePage("BaptizeState", state)
end

function PetTransmogMainInfoComponent:refreshCurrency()
	if not self.view.currencyList then
		return
	end

	local itemList = {}
	local needId = PetTransmogUtils.getTransmogItemId()
	local pointsId = PetTransmogUtils.getTransmogPointsId()
	local specialId = PetTransmogUtils.getTransmogSpecialItemId()

	if needId and needId > 0 then
		itemList[#itemList + 1] = needId
	end

	if PetTransmogUtils.isTransmogShopOpen() and pointsId and pointsId > 0 then
		itemList[#itemList + 1] = pointsId
	end

	if specialId and specialId > 0 then
		itemList[#itemList + 1] = specialId
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.currencyList, nil, itemList)
end

function PetTransmogMainInfoComponent:refreshCostInfo(skipCostAnimation)
	if not self.view.txtCashUSDFText then
		return
	end

	local lockCount = self.model:getLockedHoleCount()
	local cost = PetTransmogUtils.getLockCost(lockCount)
	local materialStatus = PetTransmogUtils.getRollMaterialStatus(self.model:getPetId(), cost, self.model:getUseSpecialItemFlag())
	local parts = {}

	if materialStatus.specialUseCount > 0 then
		parts[#parts + 1] = LuaUIUtils.getItemShowText(materialStatus.specialItemId) .. materialStatus.specialUseCount
	end

	if materialStatus.needUseCount > 0 then
		parts[#parts + 1] = LuaUIUtils.getItemShowText(materialStatus.needItemId) .. materialStatus.needUseCount
	end

	local specialNotEnough = materialStatus.useSpecial and materialStatus.specialOwned < materialStatus.specialUseCount

	ClientTextUtils.setText(self.view.txtCashUSDFText, table.concat(parts, " "))

	local costItemId = materialStatus.useSpecial and materialStatus.specialItemId or materialStatus.needItemId
	local costCount = materialStatus.useSpecial and materialStatus.specialUseCount or materialStatus.needUseCount
	local ownedCount = materialStatus.useSpecial and materialStatus.specialOwned or materialStatus.needOwned

	if self.view.imgCostItem then
		self.view.imgCostItem.url = LuaUIUtils.getIconByItemId(costItemId)
	end

	if self.view.txtCostNum then
		self.view.txtCostNum.colorCode = ownedCount < costCount and COST_COLOR_NOT_ENOUGH or COST_COLOR_NORMAL

		ClientTextUtils.setText(self.view.txtCostNum, costCount)
	end

	local costSign = string.format("%s:%d|%s:%d", tostring(materialStatus.specialItemId), materialStatus.specialUseCount, tostring(materialStatus.needItemId), materialStatus.needUseCount)

	if not skipCostAnimation and self.lastCostSign ~= nil and self.lastCostSign ~= costSign and self.view.rootUComponent then
		self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	self.lastCostSign = costSign
end

function PetTransmogMainInfoComponent:refreshPetRound()
	if self.isRolling then
		return
	end

	local petId = self.model:getPetId()
	local scheme = PetTransmogUtils.getCurrentDisplayScheme(petId)
	local progress = PetTransmogUtils.getTransmogProgress(petId)
	local petName = LuaUIUtils.getPetName(petId)

	if petName then
		if self.view.txtpetName then
			ClientTextUtils.setText(self.view.txtpetName, pg.getLocalizationText(petName))
		end

		if self.view.textPlanInfoName then
			ClientTextUtils.setText(self.view.textPlanInfoName, pg.getLocalizationText(petName))
		end
	end

	if self.view.slider then
		self.view.slider.maxValue = 1
		self.view.slider.value = PetTransmogUtils.getTransmogSliderFill(progress)
	end

	self:layoutStars(scheme, petId)

	self.lastTransmogProgress = progress
	self.lastTransmogValue = scheme and scheme.transmogValue or 0
	self.lastUnlockedSet = self.ctrl:buildUnlockedSet(petId)
	self.lastFlashSlotId = scheme and scheme.holeIds and scheme.holeIds[Const.PetTransmogSlotType.Flash]

	if self.view.txtnumAdd then
		self.view.txtnumAdd:SetActive(false)
	end
end

function PetTransmogMainInfoComponent:layoutStars(scheme, petId, changedSet)
	if not self.view.stars then
		return
	end

	local unlockedList = PetTransmogUtils.getUnlockedHoles(petId)
	local canLock = (unlockedList and #unlockedList or 0) >= 2

	for i = 1, SLOT_TYPE_MAX do
		local star = self.view.stars[i]

		if star then
			local starRef = star:GetComponent("ObjectReference")
			local startBtn = starRef:GetRefValue("starUButton")
			local unlocked = PetTransmogUtils.isHoleDisplayUnlocked(petId, i)

			star:TryChangePage("Emtpy", unlocked and 0 or 1)
			star:TryChangePage("Lock", self:calcStarLockPage(petId, i, canLock))
			star:TryChangePage("Quality", PetTransmogUtils.getHoleQuality(scheme, i))
			ClientTextUtils.setText(starRef:GetRefValue("txtPartName"), PetTransmogUtils.getHoleName(petId, i))
			ClientTextUtils.setText(starRef:GetRefValue("txtQuilty"), PetTransmogUtils.getSlotName(petId, scheme, i))

			if changedSet and changedSet[i] then
				startBtn:InvokeCallback(CS.XGUI.EInvokeTime.User2)
			end
		end
	end
end

function PetTransmogMainInfoComponent:calcStarLockPage(petId, holeIndex, canLock)
	local realUnlocked = PetTransmogUtils.isHoleUnlocked(petId, holeIndex)

	if not realUnlocked or not canLock or holeIndex == Const.PetTransmogSlotType.Flash then
		return 2
	end

	return self.model:isHoleLocked(holeIndex) and 1 or 0
end

function PetTransmogMainInfoComponent:refreshStarsLock()
	if not self.view.stars then
		return
	end

	local petId = self.model:getPetId()
	local unlockedList = PetTransmogUtils.getUnlockedHoles(petId)
	local canLock = (unlockedList and #unlockedList or 0) >= 2

	for i = 1, SLOT_TYPE_MAX do
		local star = self.view.stars[i]

		if star then
			star:TryChangePage("Lock", self:calcStarLockPage(petId, i, canLock))
		end
	end
end

function PetTransmogMainInfoComponent:onRenderHoleItem(button, data)
	if not data then
		return
	end

	button:TryChangePage("Emtpy", data.isEmpty and 1 or 0)
	button:TryChangePage("Quality", data.quality or 0)

	if self.holeQualityChanged and data.index and self.holeQualityChanged[data.index] then
		self.holeQualityChanged[data.index] = nil

		button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	self.lastHoleQuality = self.lastHoleQuality or {}

	if data.index then
		self.lastHoleQuality[data.index] = data.quality or 0
	end
end

function PetTransmogMainInfoComponent:onBtnRoll()
	if self.isRollFlowLocked or self.isRolling or self.isRollRequesting then
		return
	end

	local petId = self.model:getPetId()

	if not petId then
		return
	end

	if not self:_checkRollItemEnough() then
		return
	end

	self.isRollFlowLocked = true

	local suitInfo = PetTransmogUtils.getCurrentSuitInfo(petId)

	if suitInfo and suitInfo.quality >= GOLDEN_QUALITY then
		local desc = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_CONFIRM_SUIT_REFRESH"), suitInfo.name)

		pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_TIP"), desc, function()
			self:doRoll(petId)
		end, nil, function()
			self.isRollFlowLocked = false
		end)

		return
	end

	local goldenNames = self:collectUnlockedGoldenNames()

	if #goldenNames == 0 then
		self:doRoll(petId)

		return
	end

	local hideTs = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.PetTransmogRollGoldenTipTs, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if hideTs + 86400 > Time.secondCache then
		self:doRoll(petId)

		return
	end

	local desc = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_CONFIRM_REFRESH"), table.concat(goldenNames, "、"))
	local hideToday = false

	pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_TIP"), desc, function()
		if hideToday then
			pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.PetTransmogRollGoldenTipTs, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
			pg.global.prefsCacheUtils:save()
		end

		self:doRoll(petId)
	end, nil, function()
		self.isRollFlowLocked = false
	end, nil, nil, {
		hint = true,
		hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
		hintCb = function(isSelected)
			hideToday = isSelected
		end
	})
end

function PetTransmogMainInfoComponent:_checkRollItemEnough()
	local petId = self.model:getPetId()
	local lockCount = self.model:getLockedHoleCount()
	local needCount = PetTransmogUtils.getLockCost(lockCount)
	local materialStatus = PetTransmogUtils.getRollMaterialStatus(petId, needCount, self.model:getUseSpecialItemFlag())
	local displayItemId = materialStatus.displayItemId

	if not displayItemId or displayItemId <= 0 or needCount <= 0 then
		return true
	end

	if needCount <= materialStatus.totalOwned then
		return true
	end

	if materialStatus.useSpecial then
		pg.global.ui.tips:showTextTip(pg.getGameString("PETTRANSMOGRIFY_SPECIAL_NOT_ENOUGH"))

		return false
	end

	pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_ITEM_GET, {
		defaultBuyCount = materialStatus.lackCount
	})

	return false
end

function PetTransmogMainInfoComponent:doRoll(petId)
	if self.isRolling or self.isRollRequesting then
		return
	end

	self.isRollFlowLocked = true
	self.isRollRequesting = true

	pg.game.petTransmog:requestRoll(petId, self.model:getLockedHoleList())
end

function PetTransmogMainInfoComponent:buildHoleQualityChangedSet(scheme)
	local lastQuality = self.lastHoleQuality or {}
	local changed = {}

	for i = 1, SLOT_TYPE_MAX do
		local newQuality = PetTransmogUtils.getHoleQuality(scheme, i)

		if (lastQuality[i] or 0) ~= newQuality then
			changed[i] = true
		end
	end

	return changed
end

function PetTransmogMainInfoComponent:collectUnlockedGoldenNames()
	local petId = self.model:getPetId()
	local scheme = PetTransmogUtils.getCurrentScheme(petId)
	local holeIds = scheme and scheme.holeIds

	if not holeIds then
		return {}
	end

	local names = {}

	for i = 1, Const.PetTransmogSlotType.Hair do
		if not self.model:isHoleLocked(i) then
			local cfg = PetTransmogUtils.getSlotConfig(holeIds[i])

			if cfg and (cfg.quality or 0) >= GOLDEN_QUALITY then
				names[#names + 1] = pg.getLocalizationText(cfg.typename)
			end
		end
	end

	return names
end

function PetTransmogMainInfoComponent:onTransmogRolled()
	local petId = self.model:getPetId()

	if not petId then
		self.isRollRequesting = false
		self.isRollFlowLocked = false

		return
	end

	self.isRollRequesting = false
	self.isRolling = true
	self.isRollFlowLocked = true
	self.rollFlowSeq = (self.rollFlowSeq or 0) + 1

	local flowSeq = self.rollFlowSeq
	local previewReady = false
	local tweenReady = false

	local function tryFinishRollFlow()
		if flowSeq ~= self.rollFlowSeq then
			return
		end

		if not previewReady or not tweenReady then
			return
		end

		self.isRolling = false
		self.isRollFlowLocked = false
	end

	local rawScheme = PetTransmogUtils.getCurrentScheme(petId)
	local scheme = PetTransmogUtils.getCurrentDisplayScheme(petId)
	local progress = PetTransmogUtils.getTransmogProgress(petId)

	self:refreshUseSpecialItemFlag()
	self.ctrl:previewTransmogScheme(rawScheme, function()
		previewReady = true

		tryFinishRollFlow()
	end)

	self.holeQualityChanged = self:buildHoleQualityChangedSet(scheme)

	self:refreshCurrentSchemeInfo(scheme)

	local newValue = scheme and scheme.transmogValue or 0
	local delta = newValue - (self.lastTransmogValue or 0)

	if self.view.txtnumAdd then
		local prefix = delta > 0 and "+" or ""

		ClientTextUtils.setText(self.view.txtnumAdd, prefix .. delta)
		self.view.txtnumAdd:SetActive(delta ~= 0)
	end

	if delta ~= 0 then
		self:playValueChange(self.lastTransmogValue, newValue)
	end

	self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)

	local suitInfo = PetTransmogUtils.getCurrentSuitInfo(petId)
	local rollSound = suitInfo and suitInfo.quality >= GOLDEN_QUALITY and "SFX_PETTRANSMOGRIFY_GOLDEN_SUIT" or "SFX_PETTRANSMOGRIFY_CHANGE"

	pg.game.audio:playEvent(rollSound)

	local fromProgress = self.lastTransmogProgress or progress
	local maxV = PetTransmogUtils.getMaxTransmogValue(petId)
	local atMax = maxV and maxV > 0 and maxV <= progress

	if fromProgress ~= progress and not atMax then
		local singleExp = PetTransmogUtils.getTransmogSingleExp()
		local isCrit = singleExp and singleExp > 0 and singleExp < progress - fromProgress
		local invokeTime = isCrit and CS.XGUI.EInvokeTime.User3 or CS.XGUI.EInvokeTime.User2

		self.view.rootUComponent:InvokeCallback(invokeTime)
	end

	local fromFill = PetTransmogUtils.getTransmogSliderFill(fromProgress)
	local toFill = PetTransmogUtils.getTransmogSliderFill(progress)

	self:tweenSlider(fromFill, toFill, ROLL_ANIM_DURATION, function()
		self.lastTransmogProgress = progress
		self.lastTransmogValue = newValue

		self:refreshCostInfo()

		local newSet = self.ctrl:buildUnlockedSet(petId)
		local oldSet = self.lastUnlockedSet or {}
		local newlyList = {}

		for holeIdx in pairs(newSet) do
			if not oldSet[holeIdx] and holeIdx ~= Const.PetTransmogSlotType.Color then
				newlyList[#newlyList + 1] = holeIdx
			end
		end

		table.sort(newlyList)

		self.lastUnlockedSet = newSet

		local flashIdx = Const.PetTransmogSlotType.Flash
		local newFlashSlotId = scheme and scheme.holeIds and scheme.holeIds[flashIdx]
		local changedSet = {}

		for i = 1, SLOT_TYPE_MAX do
			if PetTransmogUtils.isHoleUnlocked(petId, i) and not self.model:isHoleLocked(i) then
				if i == flashIdx then
					changedSet[i] = newFlashSlotId ~= self.lastFlashSlotId
				else
					changedSet[i] = true
				end
			end
		end

		self.lastFlashSlotId = newFlashSlotId

		self:layoutStars(scheme, petId, changedSet)

		if #newlyList > 0 then
			pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_STAR_UPGRADE, {
				petId = petId,
				newlyUnlocked = newlyList
			})
		end

		tweenReady = true

		tryFinishRollFlow()
	end)
end

function PetTransmogMainInfoComponent:playValueChange(oldV, newV)
	local beat = self.view.tMPBeatUTextBeat

	if not beat then
		return
	end

	beat:SetText(oldV or 0)
	beat:SetEndNumber(newV or 0)
	beat:StartBeat()
end

function PetTransmogMainInfoComponent:onRollFinished(msg)
	self.isRollRequesting = false

	if not msg or msg.retStatus ~= 0 then
		self.isRolling = false
		self.isRollFlowLocked = false
	end
end

function PetTransmogMainInfoComponent:tweenSlider(fromValue, toValue, durationSec, onComplete)
	self.rollAnimSeq = (self.rollAnimSeq or 0) + 1

	local mySeq = self.rollAnimSeq

	if not self.view.slider or fromValue == toValue then
		if self.view.slider then
			self.view.slider.value = toValue
		end

		if onComplete then
			onComplete()
		end

		return
	end

	self.view.slider.value = fromValue

	self.view.slider:ProgressToValue(toValue, function()
		if mySeq ~= self.rollAnimSeq then
			return
		end

		if onComplete then
			onComplete()
		end
	end, durationSec)
end

function PetTransmogMainInfoComponent:onStarClick(holeIndex)
	if self.isRollFlowLocked or self.isRolling or self.isRollRequesting then
		return
	end

	if not holeIndex then
		return
	end

	local star = self.view.stars and self.view.stars[holeIndex]

	if not star then
		return
	end

	local petId = self.model:getPetId()

	if not PetTransmogUtils.isHoleUnlocked(petId, holeIndex) then
		return
	end

	if holeIndex == Const.PetTransmogSlotType.Flash then
		return
	end

	local unlockedList = PetTransmogUtils.getUnlockedHoles(petId)

	if (unlockedList and #unlockedList or 0) < 2 then
		return
	end

	local willLock = not self.model:isHoleLocked(holeIndex)

	if willLock then
		local lockableCount = PetTransmogUtils.getLockableHoleCount(petId)

		if self.model:getLockedHoleCount() >= lockableCount - 1 then
			pg.global.ui.tips:showTextTip(pg.getGameString("PETTRANSMOGRIFY_ALL_LOCK"))

			return
		end

		local maxLock = PetTransmogUtils.getMaxLockNum()

		if maxLock > 0 and maxLock <= self.model:getLockedHoleCount() then
			local tipDecs = pg.getGameString("PETTRANSMOGRIFY_CANTLOCK")

			pg.global.ui.tips:showTextTip(tipDecs)

			return
		end
	end

	if willLock and self.model:getUseSpecialItemFlag() then
		pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_ITEM_TIP_TITLE"), pg.getGameString("PETTRANSMOGRIFY_SPECIAL_CANCEL_FOR_LOCK"), function()
			self:setUseSpecialItemFlag(false)
			self:applyHoleLock(holeIndex, true)
		end)

		return
	end

	self:applyHoleLock(holeIndex, willLock)
end

function PetTransmogMainInfoComponent:applyHoleLock(holeIndex, willLock)
	local petId = self.model:getPetId()
	local star = self.view.stars and self.view.stars[holeIndex]

	if not petId or not star then
		return
	end

	self.model:setHoleLocked(holeIndex, willLock)
	star:TryChangePage("Lock", willLock and 1 or 0)
	self:refreshCostInfo()
	self:refreshCurrency()

	local partName = PetTransmogUtils.getHoleName(petId, holeIndex)
	local tipKey = willLock and "PETTRANSMOGRIFY_LOCKED_NOTICE" or "PETTRANSMOGRIFY_UNLOCK"

	pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString(tipKey), partName))
	pg.game.petTransmog:requestLockSchemeHole(petId, self.model:getLockedHoleList())
end

function PetTransmogMainInfoComponent:onStarInfoClick(holeIndex, star)
	local petId = self.model:getPetId()

	if not petId or not star then
		return
	end

	local targetRect = star:GetComponent("RectTransform")

	pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_BAPTIZE_TIP, {
		petId = petId,
		holeIndex = holeIndex,
		targetRect = targetRect
	})
end

function PetTransmogMainInfoComponent:onBtnComfilmMainPlan()
	local petId = self.model:getPetId()

	if not petId then
		return
	end

	local currValue = PetTransmogUtils.getCurrentTransmogValue(petId)
	local appliedValue = PetTransmogUtils.getAppliedTransmogValue(petId)
	local confirmTextKey = appliedValue <= currValue and "PETTRANSMOGRIFY_CONFIRM_CLEAR" or "PETTRANSMOGRIFY_CONFIRM_APPLY"

	local function confirm(action)
		pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_APPLY_SCHEME"), pg.getGameString(confirmTextKey), action)
	end

	self.ctrl:snapShot(function(imageKey)
		if PetTransmogUtils.isCustomFull(petId) then
			confirm(function()
				pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_REPLACE, {
					petId = petId,
					mode = PetTransmogUtils.REPLACE_MODE.APPLY_CURR,
					imageKey = imageKey
				})
			end)
		else
			confirm(function()
				pg.game.petTransmog:requestuseCurrTransmogScheme(petId, imageKey)
			end)
		end
	end)
end

function PetTransmogMainInfoComponent:onBtnSavePlan()
	self.ctrl:changeUIState(PetTransmogModel.UI_STATE.Scheme)

	local currScheme = PetTransmogUtils.getCurrentDisplayScheme(self.model:getPetId())

	self.ctrl.schemeListComponent:refreshPlanPartInfo(currScheme)

	if self.view.planPanelUComponent then
		self.view.planPanelUComponent:TryChangePage("BtnState", 3)
	end

	pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_SCHEME, {
		petId = self.model:getPetId()
	}, nil, function()
		self.ctrl:changeUIState(PetTransmogModel.UI_STATE.NORMAL)
	end)
end

return PetTransmogMainInfoComponent
