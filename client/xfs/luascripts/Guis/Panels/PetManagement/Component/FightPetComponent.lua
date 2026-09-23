-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagement\\Component\\FightPetComponent.lua

local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local FightPetComponent = Class.LightClass("FightPetComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local NpcDuelData = require("Data.npc_duel_data")
local RiftLevelData = require("Data.rift_level_data")
local RiftBuffData = require("Data.rift_buff_data")

function FightPetComponent:findObjects()
	self.fightPetList = self.view.fightPetList
	self.listSupportUList = self.view.listSupportUList
	self.groupSelector = self.view.groupSelector
	self.fightBtn = self.view.fightBtn
	self.fightBtnCtrl = self.view.fightBtnCtrl
	self.pageUpBtnUButton = self.view.pageUpBtnUButton
	self.pageDownBtnUButton = self.view.pageDownBtnUButton
	self.maskButtonUButton = self.view.maskButtonForFightUButton
	self.slotIdRecordTable = {}
	self.muteEventFlag = {}

	self:initSlotIdRecordTable()
end

function FightPetComponent:initView()
	self:addListener()
end

function FightPetComponent:onDestroy()
	if self._pendingNavFocusFrameId then
		self:killFrameTimer(self._pendingNavFocusFrameId)

		self._pendingNavFocusFrameId = nil
	end

	self._pendingSelectPetId = nil
	self._pendingNavFocusPetId = nil

	UIComponent.onDestroy(self)
end

function FightPetComponent:addListener()
	function self.fightBtn.luaClick()
		self:onClickFight()
	end

	function self.pageUpBtnUButton.luaClick()
		local index = self.model:getSelectGroupId() - 1

		if index < 1 then
			index = Const.MAX_FORMATION_COUNT
		end

		self:switchGroupToIdx(index)
	end

	function self.pageDownBtnUButton.luaClick()
		local index = self.model:getSelectGroupId() + 1

		if index > Const.MAX_FORMATION_COUNT then
			index = 1
		end

		self:switchGroupToIdx(index)
	end
end

function FightPetComponent:_prepareInitialGamepadPetFocus(args)
	if not pg.game.input:isUsingGamepad() or not self.isNormalBattleMode then
		return
	end

	if args and (args.isRogue or args.isBossRush or args.isNpcDuelMode or args.isRift or args.onePlusThreeMode) then
		return
	end

	local petId = self.model.curSelectPetId

	if not petId or not pg.me:getPetInfo(petId) then
		return
	end

	self._pendingSelectPetId = petId
	self._pendingNavFocusPetId = petId
end

function FightPetComponent:onOpen(args)
	self.isPvp = args and args.isPvp or false

	if args and args.isRogue then
		self:exitBossRushMode()
		self:exitNpcDuelMode()
		self:exitRiftMode()
		self:initRogueMode(args.levelId)
	elseif args and args.isBossRush then
		self:exitRogueMode()
		self:exitNpcDuelMode()
		self:exitRiftMode()
		self:initBossRushMode(args.levelId)
	elseif args and args.isNpcDuelMode then
		self:exitBossRushMode()
		self:exitRogueMode()
		self:exitRiftMode()
		self:initNpcDuelMode(args.npcDuelId, args.npcDuelVariantId)
	elseif args and args.isRift then
		self:exitBossRushMode()
		self:exitNpcDuelMode()
		self:exitRogueMode()
		self:initRiftMode(args.levelId)
	else
		self:exitRogueMode()
		self:exitBossRushMode()
		self:exitNpcDuelMode()
		self:exitRiftMode()
	end

	if args and args.onePlusThreeMode then
		self.isNormalBattleMode = false
	else
		self.isNormalBattleMode = not pg.me.space or pg.me.space.battleMode == 0
	end

	self:_prepareInitialGamepadPetFocus(args)
	self.view.root:TryChangePage("SupportMode", self.isNormalBattleMode and 0 or 1)
	self:refreshFightList()
	self:refreshGroupSelector()

	if self.ctrl and self.ctrl.initNavBattleMode then
		self.ctrl:initNavBattleMode()
	end
end

function FightPetComponent:initSlotIdRecordTable()
	for i = 1, Const.MAX_FORMATION_COUNT do
		local petInfos = self.model:getGroupInfoById(i)
		local tCount = lume.count(petInfos)

		if tCount < self.ctrl.MAX_FIGHT_PETS_COUNT then
			for _ = 1, self.ctrl.MAX_FIGHT_PETS_COUNT - tCount do
				local t = {}

				t.empty = true
				petInfos[#petInfos + 1] = t
			end
		end

		self.slotIdRecordTable[i] = {}

		for k, v in pairs(petInfos) do
			self.slotIdRecordTable[i][k] = v.empty and "empty" or v.id
		end
	end
end

function FightPetComponent:refreshFightList()
	local selectGroupId = self.model:getSelectGroupId()
	local petInfos

	if self.isNormalBattleMode then
		petInfos = self.model:getGroupInfoById(selectGroupId)

		local tCount = lume.count(petInfos)

		if tCount < self.ctrl.MAX_FIGHT_PETS_COUNT then
			for _ = 1, self.ctrl.MAX_FIGHT_PETS_COUNT - tCount do
				local t = {}

				t.empty = true
				petInfos[#petInfos + 1] = t
			end
		end
	else
		petInfos = self.model:getSupportGroupInfoById(selectGroupId)
	end

	function self.fightPetList.luaRenderItem(button, index, data)
		self:setFightPetListData(button, index, data)
	end

	function self.listSupportUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			self:setFightPetListData(button, index, data)
		else
			self:setFightPetListSupportData(button, index, data)
		end
	end

	function self.fightPetList.luaFinishRender(_)
		for k, v in pairs(petInfos) do
			self.slotIdRecordTable[selectGroupId][k] = v.empty and "empty" or v.id
		end
	end

	function self.listSupportUList.luaFinishRender(_)
		for k, v in pairs(petInfos) do
			self.slotIdRecordTable[selectGroupId][k] = v.empty and "empty" or v.id
		end
	end

	if self.isNormalBattleMode then
		self.fightPetList:SetList(petInfos)
	else
		self.listSupportUList:SetList(petInfos)
	end

	if self._pendingSelectPetId then
		local idx = self:getListIndexByPetId(self._pendingSelectPetId)

		self._pendingSelectPetId = nil

		if idx then
			self:refreshPetSelectedStatus(idx)
		end
	end

	if self._pendingNavFocusPetId then
		local petId = self._pendingNavFocusPetId

		self._pendingNavFocusPetId = nil

		if not self.ctrl then
			return
		end

		if self._pendingNavFocusFrameId then
			self:killFrameTimer(self._pendingNavFocusFrameId)
		end

		self._pendingNavFocusFrameId = self.ctrl:startFrameTimer(function()
			self._pendingNavFocusFrameId = nil

			if not self.ctrl then
				return
			end

			if pg.global.navMgr and pg.global.navMgr.IsDragging then
				return
			end

			local idx = self:getListIndexByPetId(petId)

			if not idx then
				return
			end

			local list = self.isNormalBattleMode and self.fightPetList or self.listSupportUList

			if not list then
				return
			end

			local buttons = list:GetAllButtons()
			local btn = buttons[idx]

			if not IsNil(btn) and not btn.isNavFocused then
				btn:TryNavFocus()
			end
		end, 1)
	end

	self:refreshFightBtn(#petInfos)
	self:refreshNpcDuelRecommendLv(petInfos)
end

function FightPetComponent:setFightPetListData(button, index, data)
	button:TryChangePage("select", 0)
	button:TryChangePage("button", 0)

	button.isSelected = false

	button:TryChangePage("pet_number", index)

	function button.luaPress()
		self:cardPressEvent(button, index, data)
	end

	function button.luaHover()
		self:onHover(button, data.empty == true)
	end

	function button.luaUnhover()
		self:onUnHover(button)
	end

	function button.luaTryChangePage(name, pageIdx, lastPageIdx)
		if name == "button" then
			-- block empty
		end
	end

	button:TryChangePage("DragState", 0)

	if data.empty == true then
		button.name = "empty"

		button:TryChangePage("empty", 1)
		LuaUIUtils.tryClearPetHeadIconInUBUtton(button)

		button.draggable = false

		return
	end

	if self.model.curSelectPetId == data.id then
		button:TryChangePage("select", 1)
		button:TryChangePage("button", 5)

		button.isSelected = true
	end

	button.name = data.id

	if self.model and self.slotIdRecordTable[self.model:getSelectGroupId()][index + 1] ~= button.name then
		button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		self:muteEvent(data.id, button)
	end

	button:TryChangePage("empty", 0)

	button.draggable = not self.muteEventFlag[data.id]

	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local nameUText = objectReference:GetRefValue("nameUText")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")
	local numCPUText = objectReference:GetRefValue("numCPUText")
	local elementsUList = objectReference:GetRefValue("elementsUList")
	local iconOrientationUImage = objectReference:GetRefValue("iconOrientationUImage")
	local nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
	local nameShineUSDFText1 = objectReference:GetRefValue("nameShineUSDFText1")
	local deleteHotKeyContent = objectReference:GetRefValue("deleteHotKeyContent")
	local flshIconUButton = objectReference:GetRefValue("flshIconUButton")
	local favoriteUButton = objectReference:GetRefValue("favoriteUButton")
	local bossUButton = objectReference:GetRefValue("bossUButton")
	local praiseUWidget = objectReference:GetRefValue("praiseUWidget")
	local umbralUContainer = objectReference:GetRefValue("umbralUContainer")
	local crownUComponent = objectReference:GetRefValue("crownUComponent")
	local pet = pg.me:getPetInfo(data.id)

	if crownUComponent then
		local propLevels

		if pet and not pet:isCatchReporting() then
			propLevels = pg.game.petManage:getPetPropLevels(pet)
		end

		crownUComponent:TryChangePage("Crown", LuaUIUtils.getPetCrownState(propLevels))
	end

	function elementsUList.luaRenderItem(btn, idx, eleData)
		LuaUIUtils.setElementButtonNew(btn, eleData.element)
	end

	iconOrientationUImage.url = data.petTypeUrl

	button:TryChangePage("isChange", data.isVariant and 1 or 0)
	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
		return
	end)
	elementsUList:SetList(data.elementNames)

	if data.gender == Const.GENDER_TYPE_MALE then
		button:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		button:TryChangePage("Gender", 1)
	else
		button:TryChangePage("Gender", 2)
	end

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(nameUText, data.customName)
		ClientTextUtils.setText(nameShineUSDFText, data.customName)
		ClientTextUtils.setText(nameShineUSDFText1, data.customName)
	else
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(nameShineUSDFText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(nameShineUSDFText1, pg.getLocalizationText(data.name))
	end

	if praiseUWidget and self.npcDuelRecommendEles then
		praiseUWidget:SetActive(self:checkNpcDuelElementMatch(data.elementNames))
	else
		praiseUWidget:SetActive(false)
	end

	hpBarUHealthbar.maxHp = 1
	hpBarUHealthbar.hp = data.hpRatio

	umbralUContainer:SetActive(data.isDark)

	if data.isDark then
		button:TryChangePage("isBoss", 0)
		umbralUContainer:LoadDefaultUrlManually()
	end

	if data.isShiny then
		if data.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			button:TryChangePage("isFlash", 2)
			flshIconUButton:TryChangePage("Type", 1)
		elseif data.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			button:TryChangePage("isFlash", 3)
			flshIconUButton:TryChangePage("Type", 2)
		else
			button:TryChangePage("isFlash", 1)
			flshIconUButton:TryChangePage("Type", 0)
		end

		button:TryChangePage("isBoss", 0)
		LuaUIUtils.setPetTagLabelToolTip(flshIconUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
	elseif data.isMini then
		button:TryChangePage("isFlash", 0)
		button:TryChangePage("isBoss", 1)
		bossUButton:TryChangePage("Type", 1)
		LuaUIUtils.setPetTagLabelToolTip(bossUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
	elseif data.isBoss then
		button:TryChangePage("isFlash", 0)
		button:TryChangePage("isBoss", 1)
		bossUButton:TryChangePage("Type", 0)
		LuaUIUtils.setPetTagLabelToolTip(bossUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
	else
		button:TryChangePage("isFlash", 0)
		button:TryChangePage("isBoss", 0)
	end

	button:TryChangePage("Dead", data.hpRatio <= 0 and 1 or 0)

	if data.cp then
		numCPUText:SetActiveFastest(true)

		if pet:isCatchReporting() then
			ClientTextUtils.setText(numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), "???"))
		else
			ClientTextUtils.setText(numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), data.cp))
		end
	else
		numCPUText:SetActiveFastest(false)
	end

	ClientTextUtils.setText(numLevelUText, pet.level)

	function button.luaBeginDrag()
		self:beginDrag(button, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endDrag(button, dropWidget, rayBox)
		self:clearDraggingInfo()
	end

	function btnDelUButton.luaClick()
		self.model:modifyPrepareFormation(button.name)
	end

	function favoriteUButton.luaClick()
		PetManagementUtils.setRenderFavoriteToolTips(favoriteUButton, data.id)
	end

	PetManagementUtils.refreshFavoriteBtn(favoriteUButton, pet and pet.favoriteType)
end

function FightPetComponent:setFightPetListSupportData(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		LuaUIUtils.clearPetHeadIcon(iconUImage)

		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

		ClientTextUtils.setText(txtTitleUSDFText, data.title)

		local fairCompetitionUWidget = objectReference:GetRefValue("fairCompetitionUWidget")

		fairCompetitionUWidget:SetActive(self.isPvp)

		if self.isPvp then
			local averageTxtNameUSDFText = objectReference:GetRefValue("averageTxtNameUSDFText")

			ClientTextUtils.setText(averageTxtNameUSDFText, pg.getGameString("PET_PVP_AVARAGE_TIP2"))
		end
	else
		button:TryChangePage("select", 0)
		button:TryChangePage("button", 0)

		button.isSelected = false

		if index == 1 then
			button:TryChangePage("pet_number", 0)
		elseif index >= 3 then
			button:TryChangePage("pet_number", index - 2)
		end

		function button.luaPress()
			self:cardPressEvent(button, index, data)
		end

		function button.luaHover()
			self:onHover(button, data.empty == true)
		end

		function button.luaUnhover()
			self:onUnHover(button)
		end

		button:TryChangePage("DragState", 0)

		if data.empty == true then
			button.name = "empty"

			button:TryChangePage("empty", 1)
			LuaUIUtils.tryClearPetHeadIconInUBUtton(button)

			button.draggable = false

			return
		end

		if self.model.curSelectPetId == data.id then
			button:TryChangePage("select", 1)
			button:TryChangePage("button", 5)

			button.isSelected = true
		end

		button.name = data.id

		if self.model and self.slotIdRecordTable[self.model:getSelectGroupId()][index + 1] ~= button.name then
			button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			self:muteEvent(data.id, button)
		end

		button:TryChangePage("empty", 0)

		button.draggable = true

		local objectReference = button:GetComponent("ObjectReference")
		local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
		local deleteHotKeyContent = objectReference:GetRefValue("deleteHotKeyContent")

		PetManagementUtils.renderFightPetSupport(button, data)

		function button.luaBeginDrag()
			self:beginDrag(button, data)
		end

		function button.luaEndDrag(dropWidget, rayBox)
			self:endDrag(button, dropWidget, rayBox)
			self:clearDraggingInfo()
		end

		function btnDelUButton.luaClick()
			self.model:modifyPrepareFormation(button.name)
		end

		local umbralUContainer = objectReference:GetRefValue("umbralUContainer")
		local flshIconUButton = objectReference:GetRefValue("flshIconUButton")
		local bossUButton = objectReference:GetRefValue("bossUButton")

		umbralUContainer:SetActive(data.isDark)

		if data.isDark then
			button:TryChangePage("isBoss", 0)
			umbralUContainer:LoadDefaultUrlManually()
		end

		if data.isShiny then
			if data.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
				button:TryChangePage("isFlash", 2)
				flshIconUButton:TryChangePage("Type", 1)
			elseif data.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
				button:TryChangePage("isFlash", 3)
				flshIconUButton:TryChangePage("Type", 2)
			else
				button:TryChangePage("isFlash", 1)
				flshIconUButton:TryChangePage("Type", 0)
			end

			button:TryChangePage("isBoss", 0)
			LuaUIUtils.setPetTagLabelToolTip(flshIconUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
		elseif data.isMini then
			button:TryChangePage("isFlash", 0)
			button:TryChangePage("isBoss", 1)
			bossUButton:TryChangePage("Type", 1)
			LuaUIUtils.setPetTagLabelToolTip(bossUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
		elseif data.isBoss then
			button:TryChangePage("isFlash", 0)
			button:TryChangePage("isBoss", 1)
			bossUButton:TryChangePage("Type", 0)
			LuaUIUtils.setPetTagLabelToolTip(bossUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
		else
			button:TryChangePage("isFlash", 0)
			button:TryChangePage("isBoss", 0)
		end
	end
end

function FightPetComponent:muteEvent(id, button)
	if not id then
		return
	end

	self.muteEventFlag[id] = true
	self._inMuteEventTransition = true
	button.navForceInteractable = true
	button.draggable = false

	button:SetInteractableNoNavRefresh(false)

	self._inMuteEventTransition = false

	self.ctrl:startTimer(function()
		self.muteEventFlag[id] = nil
		self._inMuteEventTransition = true

		button:SetInteractableNoNavRefresh(true)

		button.navForceInteractable = false
		button.draggable = true
		self._inMuteEventTransition = false
	end, 1)
end

function FightPetComponent:cardPressEvent(button, index, data)
	if self._inMuteEventTransition or not self.ctrl then
		return
	end

	self:refreshPetSelectedStatus(index)
	self:onHover(button, data.empty == true)
end

function FightPetComponent:getLockStatus(button)
	local temp = {}
	local _, page = button:TryGetCurrentPage("number")
	local _, page1 = button:TryGetCurrentPage("favState")
	local _, page2 = button:TryGetCurrentPage("PetChar")

	temp.isFavorite = page1 > 0
	temp.inBattle = page > 0
	temp.inExplore = page2 > 0

	return temp
end

function FightPetComponent:clearAllSelectFrames()
	local fightButtons

	if self.isNormalBattleMode then
		fightButtons = self.fightPetList:GetAllButtons()
	else
		fightButtons = self.listSupportUList:GetAllButtons()
	end

	for i = 0, fightButtons.Length - 1 do
		if fightButtons[i].dataFromUList.tIndex == 1 or fightButtons[i].dataFromUList.tIndex == 2 then
			fightButtons[i]:TryChangePage("select", 0)
		end
	end
end

function FightPetComponent:selectMinLevelBattlePet()
	local fightButtons

	if self.isNormalBattleMode then
		fightButtons = self.fightPetList:GetAllButtons()
	else
		fightButtons = self.listSupportUList:GetAllButtons()
	end

	local minLevel = math.huge
	local selectIndex = 0

	for i = 0, fightButtons.Length - 1 do
		if fightButtons[i].dataFromUList.tIndex == 1 or fightButtons[i].dataFromUList.tIndex == 2 then
			fightButtons[i]:TryChangePage("select", 0)

			local data

			if self.isNormalBattleMode then
				data = self.fightPetList:GetData(i)
			else
				data = self.listSupportUList:GetData(i)
			end

			if data and data.level and minLevel > data.level then
				minLevel = data.level
				selectIndex = i
			end
		end
	end

	fightButtons[selectIndex].luaPress()
end

function FightPetComponent:refreshPetSelectedStatus(index)
	if not self.ctrl then
		return
	end

	local findIndex, buttons

	if self.isNormalBattleMode then
		buttons = self.fightPetList:GetAllButtons()
	else
		buttons = self.listSupportUList:GetAllButtons()
	end

	for i = 0, buttons.Length - 1 do
		if index then
			if i == index then
				buttons[i]:TryChangePage("select", 1)
				buttons[i]:TryChangePage("button", 5)

				buttons[i].isSelected = true
				findIndex = i
			else
				buttons[i]:TryChangePage("select", 0)
				buttons[i]:TryChangePage("button", 0)

				buttons[i].isSelected = false
			end
		else
			buttons[i]:TryChangePage("select", 0)
			buttons[i]:TryChangePage("button", 0)

			buttons[i].isSelected = false
		end
	end

	if not findIndex or not buttons[findIndex] then
		return
	end

	self.ctrl:showPetInfo(buttons[findIndex].dataFromUList)

	if buttons[findIndex].dataFromUList.id then
		self.model:setCurSelectPetId(buttons[findIndex].dataFromUList.id)
	else
		self.model:setCurSelectPetId()
	end

	self.ctrl.boxPets:selectItemIfExists(self.model.curSelectPetId)
	self.ctrl.explorePets:selectItemIfExists(self.model.curSelectPetId)
end

function FightPetComponent:selectItemIfExists(petId)
	local buttons

	if self.isNormalBattleMode then
		buttons = self.fightPetList:GetAllButtons()
	else
		buttons = self.listSupportUList:GetAllButtons()
	end

	for i = 0, buttons.Length - 1 do
		if self.isNormalBattleMode or buttons[i].dataFromUList.tIndex == 1 or buttons[i].dataFromUList.tIndex == 2 then
			if buttons[i].dataFromUList.id and buttons[i].dataFromUList.id == petId then
				buttons[i]:TryChangePage("select", 1)
				buttons[i]:TryChangePage("button", 5)

				buttons[i].isSelected = true
			else
				buttons[i]:TryChangePage("select", 0)
				buttons[i]:TryChangePage("button", 0)

				buttons[i].isSelected = false
			end
		end
	end
end

function FightPetComponent:hideFilterWhenSwitchBackToFightList()
	if not self.ctrl.inFilterMode then
		return
	end

	self.view.btnCleanFilterUButton.luaClick()
end

function FightPetComponent:beginDrag(button, data)
	self.ctrl:setIsDragging(true)

	button.replicaWidget.name = button.name
	self.ctrl.draggingReplicaWidget = button.replicaWidget
	self.ctrl.draggingReplicaWidgetType = self.ctrl.DRAGGING_REPLICA_WIDGET.FIGHT_GROUP_CARD

	local objectRef = button.replicaWidget:GetComponent("ObjectReference")
	local iconUrl = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	LuaUIUtils.reloadPetHeadIcon(objectRef:GetRefValue("iconUImage"), iconUrl)

	local nameContext = objectRef:GetRefValue("nameUText")

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(nameContext, data.customName)
	else
		ClientTextUtils.setText(nameContext, pg.getLocalizationText(data.name))
	end

	button:TryChangePage("DragState", 2)
	button.replicaWidget:TryChangePage("DragState", 1)

	if pg.global.navMgr then
		pg.global.navMgr:SetBKeyCancelTarget(button.gameObject.transform.position)
	end
end

function FightPetComponent:endDrag(button, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)

	if not dropWidget then
		self.model:modifyPrepareFormation(button.name)

		return
	end

	local dropName = dropWidget.gameObject.name

	if button.name == dropName or dropName == "empty" then
		self:resetDragState()

		return
	end

	local isFightPet = self.model:checkInCurrentFight(dropName)

	if isFightPet then
		self:markPendingSelectByDrop(button.name)
		self.model:switchPreparePet(button.name, dropName)
	else
		self.model:modifyPrepareFormation(button.name)
	end
end

function FightPetComponent:markPendingSelectByDrop(petId)
	if not petId then
		return
	end

	self._pendingSelectPetId = petId
	self._pendingNavFocusPetId = pg.game.input:isUsingGamepad() and petId or nil
end

function FightPetComponent:clearDraggingInfo()
	self.ctrl.draggingReplicaWidget = nil

	self.ctrl:setIsDragging(false)

	self.ctrl.draggingReplicaWidgetType = nil
end

function FightPetComponent:onHover(button, isEmpty)
	if not self.ctrl then
		return
	end

	local STATE = self.ctrl.CONSOLE_BAR_STATE

	self.ctrl:recordHoveredButton(self, button, isEmpty)
	self.ctrl:setConsoleBarState(STATE.IN_EMPTY_PET_BOX, isEmpty == true)
	self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, false)
	self.ctrl:setConsoleBarState(STATE.CAN_DROP, false)

	if not self.ctrl.isDragging then
		if isEmpty ~= true and button.draggable == true then
			self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, true)
		end

		return
	end

	if not IsNil(self.ctrl.draggingReplicaWidget) and self.ctrl.draggingReplicaWidget.name ~= button.name and (self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.PET_BOX_CARD or self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.FIGHT_GROUP_CARD) then
		self.ctrl.draggingReplicaWidget:TryChangePage("DragState", 3)
		button:TryChangePage("DragState", 4)
		self.ctrl:setConsoleBarState(STATE.CAN_DROP, true)
	end
end

function FightPetComponent:onUnHover(button)
	if not self.ctrl then
		return
	end

	local STATE = self.ctrl.CONSOLE_BAR_STATE

	self.ctrl:clearHoveredButton(self, button)
	self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, false)
	self.ctrl:setConsoleBarState(STATE.CAN_DROP, false)
	self.ctrl:setConsoleBarState(STATE.IN_EMPTY_PET_BOX, false)

	if self.ctrl.isDragging == true and not IsNil(self.ctrl.draggingReplicaWidget) and self.ctrl.draggingReplicaWidget.name ~= button.name and (self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.PET_BOX_CARD or self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.FIGHT_GROUP_CARD) then
		self.ctrl.draggingReplicaWidget:TryChangePage("DragState", 1)
		button:TryChangePage("DragState", 0)
	end
end

function FightPetComponent:resetDragState()
	local buttons

	if self.isNormalBattleMode then
		buttons = self.fightPetList:GetAllButtons()
	else
		buttons = self.listSupportUList:GetAllButtons()
	end

	for i = 0, buttons.Length - 1 do
		if buttons[i].dataFromUList.tIndex == 1 or buttons[i].dataFromUList.tIndex == 2 then
			buttons[i]:TryChangePage("DragState", 0)
		end
	end
end

function FightPetComponent:refreshGroupSelector()
	local groupNameContent = ""
	local groupInfos = self.model:getGroupInfos()
	local selectGroupId = self.model:getSelectGroupId()
	local groupId = pg.me.curPetFormationIndex
	local nameInfo = self.model:getGroupNameInfo(selectGroupId)

	if nameInfo.customName and nameInfo.customName ~= "" then
		groupNameContent = nameInfo.customName
	else
		groupNameContent = pg.getGameString("DEFAULT_GROUP_NAME") .. " " .. nameInfo.idx
	end

	local objectReference = self.groupSelector:GetComponent("ObjectReference")
	local groupName = objectReference:GetRefValue("groupName")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(groupName, groupNameContent)
	ClientTextUtils.setText(txtNameUText, groupNameContent)

	function self.groupSelector.luaRenderPopup(popup, list)
		popup:SetNavGroupBlockNavItemDrivenScroll(true)

		function list.luaRenderItem(button, index, data)
			button.name = index + 1

			local objRef = button:GetComponent("ObjectReference")
			local nameUText = objRef:GetRefValue("nameUText")
			local numCPUText = objRef:GetRefValue("numCPUText")
			local btnRenameUButton = objRef:GetRefValue("btnRenameUButton")
			local listUList = objRef:GetRefValue("listUList")
			local groupData = self.model:getGroupNameInfo(index + 1)

			if groupData.customName and groupData.customName ~= "" then
				ClientTextUtils.setText(nameUText, groupData.customName)
			else
				ClientTextUtils.setText(nameUText, pg.getGameString("DEFAULT_GROUP_NAME"), " ", groupData.idx)
			end

			local totalCp = 0

			for i = 1, #groupData.pets do
				totalCp = totalCp + groupData.pets[i].cp
			end

			ClientTextUtils.setText(numCPUText, "CP: ", totalCp)

			local tCount = lume.count(groupData.pets)

			if tCount < self.ctrl.MAX_FIGHT_PETS_COUNT then
				for _ = 1, self.ctrl.MAX_FIGHT_PETS_COUNT - tCount do
					local t = {}

					t.empty = true
					groupData.pets[#groupData.pets + 1] = t
				end
			end

			function listUList.luaRenderItem(button1, index1, data1)
				button1.draggable = false
				button1.navForceNonInteractable = true

				local objReference = button1:GetComponent("ObjectReference")
				local iconUImage = objReference:GetRefValue("icon")

				if data1.empty then
					button1:TryChangePage("state", 2)
					LuaUIUtils.renderPetHeadFlashBgAndFrame(objReference, false)
				else
					button1:TryChangePage("state", 0)

					local pet = pg.me:getPetInfo(data1.id)
					local shinyStyle = data1.shinyStyle or pet and pet.shinyStyle or 0

					LuaUIUtils.renderPetHeadFlashBgAndFrame(objReference, data1.isShiny, shinyStyle)
					iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data1.iconName, LuaUIUtils.PET_ICON, data1.label, data1.gender), function()
						return
					end)
				end
			end

			listUList:SetList(groupData.pets)

			function button.luaClick()
				self:switchGroupToIdx(index + 1)
			end

			function btnRenameUButton.luaClick()
				local NavManager = CS.XGUI.Navigation.NavManager.Instance
				local focusSnapshot = NavManager:SaveFocusStackSnapshot()
				local groupIdx = data.idx

				self.ctrl:showRename(self.model.RENAME_FOR_GROUP, groupIdx, function()
					self:_restoreGroupSelectorFocus(focusSnapshot, groupIdx)
				end, function()
					self:_restoreGroupSelectorFocus(focusSnapshot, groupIdx)
				end, function()
					self.ctrl:startFrameTimer(function()
						self.groupSelector:ClosePopup(true)
					end, 1)
				end)
			end
		end

		function list.luaFinishRender(subList)
			local btns = subList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i]:TryChangePage("select", i + 1 == selectGroupId and 1 or 0)
				btns[i]:TryChangePage("inUse", i + 1 == groupId and 1 or 0)

				local groupData = self.model:getGroupNameInfo(i + 1)

				btns[i]:TryChangePage("State", #groupData.pets <= 0 and 1 or 0)

				if i + 1 == selectGroupId then
					subList:SelectItem(i)
				end
			end

			local gotoIndex = selectGroupId - 2

			if gotoIndex < 0 then
				gotoIndex = 0
			end

			subList:GoToItem(btns[gotoIndex], true)

			if pg.game.input:isUsingGamepad() then
				if pg.global.navMgr.CurrentFocusedGroupName == "PetTeamPanel" then
					pg.global.navMgr:FocusItem(popup:GetNavGroupDefaultItem())
				else
					pg.global.navMgr:PushFocusItem(popup:GetNavGroupDefaultItem())
				end
			end

			popup:SetNavGroupBlockNavItemDrivenScroll(false)
		end

		list:SetList(groupInfos)
	end

	self.groupSelector:SetOptions(groupInfos)
end

function FightPetComponent:refreshSingleGroupSelectorItemName(index, newName)
	local popupInst = self.groupSelector:GetPopupInstance()
	local objectReference = popupInst:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")
	local _, btn = listUList:TryGetChildAt(index - 1)
	local objectReference1 = btn:GetComponent("ObjectReference")
	local nameUText = objectReference1:GetRefValue("nameUText")

	ClientTextUtils.setText(nameUText, newName)
end

function FightPetComponent:_getGroupSelectorRowButton(groupIdx)
	local popupInst = self.groupSelector:GetPopupInstance()

	if IsNil(popupInst) then
		return nil
	end

	local objectReference = popupInst:GetComponent("ObjectReference")

	if IsNil(objectReference) then
		return nil
	end

	local listUList = objectReference:GetRefValue("listUList")

	if IsNil(listUList) then
		return nil
	end

	local _, btn = listUList:TryGetChildAt(groupIdx - 1)

	return btn
end

function FightPetComponent:_restoreGroupSelectorFocus(snapshot, groupIdx)
	self.groupSelector:InteractPopup(true)
	self.ctrl:startFrameTimer(function()
		if not snapshot then
			return
		end

		local newRowButton = self:_getGroupSelectorRowButton(groupIdx)

		if not IsNil(newRowButton) then
			snapshot:SetTopEnteredGroupAndTarget(newRowButton)
			snapshot:SetTopSuppressSelectOnRestore(false)
		end

		CS.XGUI.Navigation.NavManager.Instance:RestoreFocusStackSnapshot(snapshot)
	end, 1)
end

function FightPetComponent:switchGroupToIdx(index)
	self.model:setSelectGroupId(index)
	self.ctrl:onPetFormationUpdate()
	self.groupSelector:ClosePopup()
end

function FightPetComponent:refreshFightBtn(petLen)
	if not petLen then
		local selectId = self.model:getSelectGroupId()
		local petInfos = self.model:getGroupInfoById(selectId)

		petLen = #petInfos
	end

	if petLen <= 0 then
		self.fightBtnCtrl.gameObject:SetActiveEx(false)

		return
	end

	self.fightBtnCtrl.gameObject:SetActiveEx(true)

	if self.ctrl:checkInCombat() then
		self.fightBtnCtrl:TryChangePage("fightBtn", 2)

		return
	end

	if self.model:checkSelectGroupIdIsFight() then
		self.fightBtnCtrl:TryChangePage("fightBtn", 1)
	else
		self.fightBtnCtrl:TryChangePage("fightBtn", 0)
	end
end

function FightPetComponent:onClickFight()
	self.model:syncFightGroup()
end

function FightPetComponent:refreshFightBtnByPetId(petId)
	local buttons

	if self.isNormalBattleMode then
		if not self.fightPetList then
			return
		end

		buttons = self.fightPetList:GetAllButtons()

		for i = 0, buttons.Length - 1 do
			if buttons[i].gameObject.name == petId then
				self.fightPetList:RefreshElement(i)

				break
			end
		end
	else
		if not self.listSupportUList then
			return
		end

		buttons = self.listSupportUList:GetAllButtons()

		for i = 0, buttons.Length - 1 do
			if buttons[i].gameObject.name == petId then
				self.listSupportUList:RefreshElement(i)

				break
			end
		end
	end
end

function FightPetComponent:getListIndexByPetId(petId)
	local buttons, lastIndex

	if self.isNormalBattleMode then
		if not self.fightPetList then
			return nil
		end

		buttons = self.fightPetList:GetAllButtons()
	else
		if not self.listSupportUList then
			return nil
		end

		buttons = self.listSupportUList:GetAllButtons()
	end

	lastIndex = buttons.Length - 1

	for i = 0, lastIndex do
		if buttons[i].name == petId then
			return i
		end
	end

	return nil
end

function FightPetComponent:initNpcDuelMode(npcDuelId, npcDuelVariantId)
	local npcDuelData = NpcDuelData[npcDuelId] and NpcDuelData[npcDuelId][npcDuelVariantId]

	if not npcDuelData then
		return
	end

	self.isNpcDuelMode = true
	self.npcDuelRecommendEles = npcDuelData.recommendedElements

	local npcDuel = pg.game and pg.game.npcDuel

	self.npcDuelRecommendLev = npcDuel and npcDuel:getNpcDuelLevelByDuelId(npcDuelId, npcDuelVariantId) or npcDuelData.recommendedLevel

	self.view.roomTowerTitleUContainer:LoadDefaultUrlManually()

	local objectReference = self.view.roomTowerTitleUContainer.content:GetComponent("ObjectReference")

	self.npcDuelTitleTowerUComponent = objectReference:GetRefValue("titleTowerUComponent")

	local textLv = objectReference:GetRefValue("textLvUBaseText")
	local elemUiList = objectReference:GetRefValue("listRoundUList")

	LuaUIUtils.renderPetElement(elemUiList, self.npcDuelRecommendEles)
	ClientTextUtils.setText(textLv, "lv." .. self.npcDuelRecommendLev)
end

function FightPetComponent:refreshNpcDuelRecommendLv(petInfos)
	if not self.npcDuelRecommendLev or not self.npcDuelTitleTowerUComponent then
		return
	end

	local totalLevel, petCount = 0, 0

	for _, pet in ipairs(petInfos) do
		if not pet.empty then
			petCount = petCount + 1
			totalLevel = totalLevel + pet.level
		end
	end

	local metRecommend = totalLevel / petCount >= self.npcDuelRecommendLev

	self.npcDuelTitleTowerUComponent:TryChangePage("TextState", metRecommend and 0 or 1)
end

function FightPetComponent:checkNpcDuelElementMatch(elementNames)
	if not elementNames or not self.npcDuelRecommendEles then
		return false
	end

	for _, info in ipairs(elementNames) do
		if table.contains(self.npcDuelRecommendEles, info.element) then
			return true
		end
	end

	return false
end

function FightPetComponent:exitNpcDuelMode()
	self.isNpcDuelMode = false
	self.npcDuelRecommendEles = nil
	self.npcDuelRecommendLev = nil
end

function FightPetComponent:initRogueMode(levelId)
	self.rogueBattleUList = self.view.listTowerUList

	self.view.roomTowerTitleUContainer:LoadDefaultUrlManually()

	local objectReference = self.view.roomTowerTitleUContainer.content:GetComponent("ObjectReference")

	self.titleTowerUComponent = objectReference:GetRefValue("titleTowerUComponent")

	local textRecommendUBaseText = objectReference:GetRefValue("textRecommendUBaseText")

	self.rogueTextLv = objectReference:GetRefValue("textLvUBaseText")
	self.rogueRoundList = objectReference:GetRefValue("listRoundUList")
	self.rogueLevelId = levelId
	self.rogueBattlePetIds = pg.me:getCurSelectPets(levelId)
	self.rogueMaxCount = RogueTalentUtils.func(pg.me, "rogueExtraSlot") and 5 or 4
	self.rogueBattleListItem = setmetatable({}, {
		__mode = "k"
	})
	self.rogueDraggingPetId = nil
	self.rogueDraggingIndex = nil
	self.isRogueMode = true

	self:setParentListType(3)
	self.view.topRightTabUList:SetActive(false)

	local difficultyCfg = RogueDifficultyData[levelId]

	if not difficultyCfg then
		return
	end

	self.rogueRecommendEles = difficultyCfg.recommendType or {}

	ClientTextUtils.setText(self.rogueTextLv, "lv." .. difficultyCfg.recommendLv)
	self.rogueTextLv:SetActive(true)
	self.rogueRoundList:SetActive(true)
	self.rogueBattleUList:SetActive(true)
	LuaUIUtils.renderPetElement(self.rogueRoundList, self.rogueRecommendEles)
	pg.global.ui.towerLevelDetail:hide()

	function self.rogueBattleUList.luaRenderItem(button, index, data)
		button.gameObject.name = tostring(data.index or index + 1)
		self.rogueBattleListItem[button] = true

		self:registerRogueBtnDragEvent(button, data)
		self:renderRogueBattlePet(button, index, data)
		button:TryChangePage("select", data.id == self.model.curSelectPetId and 1 or 0)
	end

	function self.rogueBattleUList.luaClick(button, data)
		if data.id then
			self:clickRogueBattleList(data.id)
		end
	end

	self:refreshRoguePetInfos()

	if self.rogueBattlePetIds[1] then
		self:clickRogueBattleList(self.rogueBattlePetIds[1])
	end
end

function FightPetComponent:clickRogueBattleList(id)
	local petInfo = self.model:setUpPetInfo(pg.me:getPetInfo(id))

	self.model:setCurSelectPetId(id)
	self.ctrl:showPetInfo(petInfo)
	self.ctrl.boxPets:selectItemIfExists(id)
	self.rogueBattleUList:RefreshList()
end

function FightPetComponent:exitRogueMode()
	if not self.isRogueMode then
		return
	end

	self.isRogueMode = false

	if self.rogueBattleUList then
		self.rogueBattleUList:SetActive(false)
	end

	if self.rogueTextLv then
		self.rogueTextLv:SetActive(false)
	end

	if self.rogueRoundList then
		self.rogueRoundList:SetActive(false)
	end
end

function FightPetComponent:saveRogueTeam()
	if not self.isRogueMode then
		return
	end

	pg.me:setRoguePets(self.rogueBattlePetIds)
	pg.me:setRogueLevelHistoryBattlePet(self.rogueLevelId, self.rogueBattlePetIds)
	pg.global.ui.towerLevelDetail:show()
	pg.global.ui.towerLevelDetail:refreshListPet(self.rogueBattlePetIds)
	self:exitRogueMode()
end

function FightPetComponent:refreshRoguePetInfos(skipBoxRefresh)
	self.rogueBattleUList:SetList(self:getRoguePetListData())

	if not skipBoxRefresh then
		self.ctrl.boxPets:refreshPetList()
	end

	self:refreshRogueRecommendLv()
end

function FightPetComponent:TryRefreshRoguePetElement(petId_)
	for index, petId in ipairs(self.rogueBattlePetIds) do
		if petId == petId_ then
			self.rogueBattleUList:RefreshElement(index - 1)
		end
	end

	self:refreshRogueRecommendLv()
end

function FightPetComponent:getRoguePetListData()
	local data = {
		{
			isEmpty = true,
			index = 1,
			tIndex = 0
		},
		{
			isEmpty = true,
			index = 2,
			tIndex = 0
		},
		{
			isEmpty = true,
			index = 3,
			tIndex = 0
		},
		{
			isEmpty = true,
			index = 4,
			tIndex = 0
		},
		{
			isEmpty = true,
			index = 5,
			tIndex = 0,
			isLock = not RogueTalentUtils.func(pg.me, "rogueExtraSlot")
		}
	}

	for index, petId in ipairs(self.rogueBattlePetIds) do
		local pet = pg.me.pets[petId]

		if pet and data[index] and not data[index].isLock then
			data[index] = {
				id = petId
			}
			data[index].tIndex = 0
			data[index].index = index
		end
	end

	return data
end

function FightPetComponent:refreshRogueRecommendLv()
	local totalLevel, petCount = 0, 0

	for _, petId in ipairs(self.rogueBattlePetIds) do
		local pet = pg.me.pets[petId]

		if pet then
			petCount = petCount + 1
			totalLevel = totalLevel + pet.level
		end
	end

	local difficultyCfg = RogueDifficultyData[self.rogueLevelId]

	if difficultyCfg and petCount > 0 then
		local metRecommend = totalLevel / petCount >= difficultyCfg.recommendLv

		self.titleTowerUComponent:TryChangePage("TextState", metRecommend and 0 or 1)
	else
		self.titleTowerUComponent:TryChangePage("TextState", 0)
	end
end

function FightPetComponent:renderRogueBattlePet(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local nameUText = objectReference:GetRefValue("nameUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")
	local numCPUText = objectReference:GetRefValue("numCPUText")
	local elementsUList = objectReference:GetRefValue("elementsUList")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local praiseUWidget = objectReference:GetRefValue("praiseUWidget")
	local iconOrientationUImage = objectReference:GetRefValue("iconOrientationUImage")
	local nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
	local nameShineUSDFText1 = objectReference:GetRefValue("nameShineUSDFText1")
	local bossUButton = objectReference:GetRefValue("bossUButton")
	local towerLockUBaseText = objectReference:GetRefValue("towerLockUBaseText")
	local number = data.index and data.index - 1 or index

	button:TryChangePage("pet_number", number)

	button.navForceNonInteractable = data.isLock or false

	if data.isLock then
		ClientTextUtils.setText(towerLockUBaseText, pg.getGameString("TOWER_PET_LOCK_TIP"))
	end

	if data.isLock then
		button:TryChangePage("empty", 2)
	elseif data.isEmpty then
		button:TryChangePage("empty", 1)
	else
		button:TryChangePage("empty", 0)
	end

	if data.isEmpty or data.isLock then
		if praiseUWidget then
			praiseUWidget:SetActive(false)
		end

		if btnDelUButton then
			btnDelUButton.gameObject:SetActiveEx(false)
		end

		LuaUIUtils.clearPetHeadIcon(iconUImage)

		button.draggable = false

		return
	end

	local pet = pg.me.pets[data.id]

	if not pet then
		LuaUIUtils.clearPetHeadIcon(iconUImage)

		return
	end

	local petData = LuaUIUtils.generatePetInfo(pet)

	button.draggable = true

	button:TryChangePage("DragState", 0)

	if petData.isShiny then
		if petData.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			button:TryChangePage("isFlash", 2)
		elseif petData.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			button:TryChangePage("isFlash", 3)
		else
			button:TryChangePage("isFlash", 1)
		end
	else
		button:TryChangePage("isFlash", 0)
	end

	button:TryChangePage("isChange", petData.isVariant and 1 or 0)

	local isShowBoss = petData.isBoss or petData.isMini

	button:TryChangePage("isBoss", isShowBoss and 1 or 0)

	if NotNil(bossUButton) and isShowBoss then
		bossUButton:TryChangePage("Type", petData.isMini and 1 or 0)
	end

	if iconOrientationUImage then
		iconOrientationUImage.url = petData.petTypeUrl
	end

	local petName = petData.customName and petData.customName ~= "" and petData.customName or pg.getLocalizationText(petData.name)

	if nameUText then
		ClientTextUtils.setText(nameUText, petName)
	end

	if nameShineUSDFText then
		ClientTextUtils.setText(nameShineUSDFText, petName)
	end

	if nameShineUSDFText1 then
		ClientTextUtils.setText(nameShineUSDFText1, petName)
	end

	if iconUImage then
		iconUImage.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petData.label, petData.gender)
	end

	if numLevelUText then
		ClientTextUtils.setText(numLevelUText, petData.level)
	end

	local pet = pg.me:getPetInfo(data.id)

	if numCPUText then
		if petData.cp and not pet:isCatchReporting() then
			numCPUText:SetActiveFastest(true)

			numCPUText.text = ClientTextUtils.concatByLanguage(pg.getGameString("CP"), petData.cp)
		else
			numCPUText:SetActiveFastest(false)
		end
	end

	if elementsUList then
		function elementsUList.luaRenderItem(btn, _, eleData)
			LuaUIUtils.setElementButtonNew(btn, eleData.element)
		end

		elementsUList:SetList(petData.elementNames)
	end

	if praiseUWidget then
		praiseUWidget:SetActive(self:checkRogueElementMatch(petData.elementNames))
	end

	if hpBarUHealthbar then
		hpBarUHealthbar.maxHp = 1
		hpBarUHealthbar.hp = 1
	end

	if btnDelUButton then
		btnDelUButton.gameObject:SetActiveEx(true)

		function btnDelUButton.luaClick()
			if self.isRogueMode then
				self:removeRogueBattlePet(data)
			elseif self.isBossRushMode then
				self:removeBossRushBattlePet(data)
			end
		end
	end
end

function FightPetComponent:removeRogueBattlePet(data)
	if data.isEmpty then
		return
	end

	for i, petId in ipairs(self.rogueBattlePetIds) do
		if petId == data.id then
			table.remove(self.rogueBattlePetIds, i)
			self:refreshRoguePetInfos()

			return
		end
	end
end

function FightPetComponent:removeBossRushBattlePet(data)
	if data.isEmpty then
		return
	end

	for i, petId in ipairs(self.bossRushBattlePetIds) do
		if petId == data.id then
			table.remove(self.bossRushBattlePetIds, i)
			self:refreshBossRushPetInfos()

			return
		end
	end
end

function FightPetComponent:checkRogueElementMatch(elementNames)
	if not elementNames or not self.rogueRecommendEles then
		return false
	end

	for _, info in ipairs(elementNames) do
		if table.contains(self.rogueRecommendEles, info.element) then
			return true
		end
	end

	return false
end

function FightPetComponent:checkRogueLevel(data)
	if not data or not data.level then
		return false
	end

	local maxControlLevel = pg.me:getMaxControlLevel()

	if maxControlLevel and maxControlLevel >= data.level then
		return true
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("ROGUE_SELECT_PET_LEVEL_LIMIT"))

	return false
end

function FightPetComponent:registerRogueBtnDragEvent(button, data)
	function button.luaBeginDrag()
		self:beginRogueDrag(button, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endRogueDrag(button, data, dropWidget, rayBox)
	end
end

function FightPetComponent:beginRogueDrag(button, data)
	self.rogueDraggingPetId = data.id
	self.rogueDraggingIndex = tonumber(button.gameObject.name)

	self.ctrl:setIsDragging(true)

	self.ctrl.draggingReplicaWidget = button.replicaWidget
	self.ctrl.draggingReplicaWidgetType = self.ctrl.DRAGGING_REPLICA_WIDGET.FIGHT_GROUP_CARD

	if button.replicaWidget then
		button.replicaWidget.name = button.gameObject.name

		local objectReference = button.replicaWidget:GetComponent("ObjectReference")
		local replicaIconUImage = objectReference:GetRefValue("iconUImage")
		local iconUrl
		local pet = pg.me.pets[data.id]

		if pet then
			local petData = LuaUIUtils.generatePetInfo(pet)

			iconUrl = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petData.label, petData.gender)

			LuaUIUtils.reloadPetHeadIcon(replicaIconUImage, iconUrl)
		else
			LuaUIUtils.clearPetHeadIcon(replicaIconUImage)
		end

		button.replicaWidget:TryChangePage("DragState", 1)
	end

	button:TryChangePage("DragState", 2)
end

function FightPetComponent:endRogueDrag(button, data, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)

	local sourceIndex = self.rogueDraggingIndex

	if sourceIndex then
		if dropWidget and self.rogueBattleListItem[dropWidget] then
			local targetIndex = tonumber(dropWidget.gameObject.name)

			if targetIndex and targetIndex ~= sourceIndex then
				local srcId = self.rogueBattlePetIds[sourceIndex]
				local tgtId = self.rogueBattlePetIds[targetIndex]

				if srcId and tgtId then
					self.rogueBattlePetIds[sourceIndex] = tgtId
					self.rogueBattlePetIds[targetIndex] = srcId

					self:refreshRoguePetInfos()
				elseif srcId then
					self.rogueBattlePetIds[targetIndex] = srcId
					self.rogueBattlePetIds[sourceIndex] = nil

					self:sortRoguePetIds()
					self:refreshRoguePetInfos()
				end
			end
		else
			table.remove(self.rogueBattlePetIds, sourceIndex)
			self:refreshRoguePetInfos()
		end
	end

	self.rogueDraggingPetId = nil
	self.rogueDraggingIndex = nil

	self.ctrl:setIsDragging(false)

	self.ctrl.draggingReplicaWidget = nil
	self.ctrl.draggingReplicaWidgetType = nil
end

function FightPetComponent:onBoxPetDropToRogueSlot(petId, dropWidget, petData)
	if not self.rogueBattleListItem[dropWidget] then
		return false
	end

	if petData and not self:checkRogueLevel(petData) then
		self:resetRogueBattleListDragState()

		return true
	end

	local targetIndex = tonumber(dropWidget.gameObject.name)

	if not targetIndex then
		self:resetRogueBattleListDragState()

		return true
	end

	local existIndex = -1

	for i, id in ipairs(self.rogueBattlePetIds) do
		if id == petId then
			existIndex = i

			break
		end
	end

	if self.rogueBattlePetIds[targetIndex] then
		if existIndex ~= -1 then
			self.rogueBattlePetIds[existIndex] = self.rogueBattlePetIds[targetIndex]
			self.rogueBattlePetIds[targetIndex] = petId
		else
			self.rogueBattlePetIds[targetIndex] = petId
		end
	else
		if existIndex ~= -1 then
			table.remove(self.rogueBattlePetIds, existIndex)
		end

		if #self.rogueBattlePetIds < self.rogueMaxCount then
			self.rogueBattlePetIds[targetIndex] = petId
		end

		self:sortRoguePetIds()
	end

	pg.game.audio:triggerEvent("ui_petmanagement_box_place")
	self:resetRogueBattleListDragState()
	self:refreshRoguePetInfos()

	return true
end

function FightPetComponent:sortRoguePetIds()
	local newIds = {}

	for i = 1, 5 do
		if self.rogueBattlePetIds[i] then
			table.insert(newIds, self.rogueBattlePetIds[i])
		end
	end

	self.rogueBattlePetIds = newIds
end

function FightPetComponent:resetRogueBattleListDragState()
	local buttons = self.rogueBattleUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		buttons[i]:TryChangePage("DragState", 0)
	end
end

function FightPetComponent:initBossRushMode(levelId)
	local BossRushUtils = require("Utils.BossRushUtils")
	local BossRushLevelData = require("Data.bossrush_guanka_data")

	self.bossRushBattleUList = self.view.listTowerUList
	self.bossRushLevelId = levelId
	self.isBossRushMode = true
	self.bossRushBattlePetIds = BossRushUtils.getPlayerSelectPetIds(pg.me.id, levelId)
	self.bossRushMaxCount = 4
	self.bossRushRecommendEles = {}
	self.bossRushBattleListItem = setmetatable({}, {
		__mode = "k"
	})
	self.bossRushDraggingPetId = nil
	self.bossRushDraggingIndex = nil

	local levelData = BossRushLevelData[levelId]

	if levelData then
		self.bossRushRecommendEles = levelData.elementRecmmend or {}
	end

	self:setParentListType(3)
	self.view.topRightTabUList:SetActive(false)

	self.bossRushBattleUList.rowSpacing = 64

	self.bossRushBattleUList:SetActive(true)

	if self.view.roomTitleBossUContainer then
		self.view.roomTitleBossUContainer:SetActive(true)
		BossRushUtils.initSelectPetTitleInfo(self.view.roomTitleBossUContainer, levelId)
	end

	function self.bossRushBattleUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 or data.tIndex == 2 then
			button.gameObject.name = tostring(data.index or index + 1)
			self.bossRushBattleListItem[button] = true

			self:registerBossRushBtnDragEvent(button, data)
			button:TryChangePage("select", data.id == self.model.curSelectPetId and 1 or 0)
		end

		if data.tIndex == 0 then
			self:renderRogueBattlePet(button, index, data)
		elseif data.tIndex == 2 then
			self:renderBossRushSupportPet(button, index, data)
		elseif data.tIndex == 1 then
			self:renderBossRushSplitTitle(button, index, data)
		end
	end

	function self.bossRushBattleUList.luaClick(button, data)
		if data.id then
			self:clickBossRushBattleList(data.id)
		end
	end

	self:refreshBossRushPetInfos()

	if self.bossRushBattlePetIds[1] then
		self:clickBossRushBattleList(self.bossRushBattlePetIds[1])
	end
end

function FightPetComponent:checkBossRushElementMatch(elementNames)
	if not elementNames or not self.bossRushRecommendEles then
		return false
	end

	for _, info in ipairs(elementNames) do
		if table.contains(self.bossRushRecommendEles, info.element) then
			return true
		end
	end

	return false
end

function FightPetComponent:exitBossRushMode()
	if not self.isBossRushMode then
		return
	end

	self.isBossRushMode = false
	self.bossRushBattleUList = nil
	self.bossRushLevelId = nil
end

function FightPetComponent:saveBossRushTeam()
	if not self.isBossRushMode then
		return
	end

	pg.me:bossRushSelectPet(self.bossRushLevelId, self.bossRushBattlePetIds)
	self:exitBossRushMode()
end

function FightPetComponent:refreshBossRushPetInfos(skipBoxRefresh)
	self.bossRushBattleUList:SetList(self:getBossRushPetListData())

	if not skipBoxRefresh then
		self.ctrl.boxPets:refreshPetList()
	end
end

function FightPetComponent:TryRefreshBossRushPetElement(petId_)
	for index, petId in ipairs(self.bossRushBattlePetIds) do
		if petId == petId_ then
			if index == 1 then
				self.bossRushBattleUList:RefreshElement(index)
			else
				self.bossRushBattleUList:RefreshElement(index + 1)
			end
		end
	end
end

function FightPetComponent:getBossRushPetListData()
	local data = {
		{
			isEmpty = true,
			index = 1,
			tIndex = 0
		},
		{
			isEmpty = true,
			index = 2,
			tIndex = 2
		},
		{
			isEmpty = true,
			index = 3,
			tIndex = 2
		},
		{
			isEmpty = true,
			index = 4,
			tIndex = 2
		}
	}

	for index, petId in ipairs(self.bossRushBattlePetIds) do
		local pet = pg.me.pets[petId]

		if pet and data[index] then
			data[index] = {
				id = petId
			}
			data[index].tIndex = index == 1 and 0 or 2
			data[index].index = index
		end
	end

	table.insert(data, 2, {
		tIndex = 1,
		title = pg.getGameString("SUPPORT_TEAM_TITLE_2")
	})
	table.insert(data, 1, {
		tIndex = 1,
		title = pg.getGameString("SUPPORT_TEAM_TITLE_1")
	})

	return data
end

function FightPetComponent:clickBossRushBattleList(id)
	local petInfo = self.model:setUpPetInfo(pg.me:getPetInfo(id))

	self.model:setCurSelectPetId(id)
	self.ctrl:showPetInfo(petInfo)
	self.ctrl.boxPets:selectItemIfExists(id)
	self.bossRushBattleUList:RefreshList()
end

function FightPetComponent:removeBossRushBattlePet(data)
	if data.isEmpty then
		return
	end

	for i, petId in ipairs(self.bossRushBattlePetIds) do
		if petId == data.id then
			table.remove(self.bossRushBattlePetIds, i)
			self:refreshBossRushPetInfos()

			return
		end
	end
end

function FightPetComponent:renderBossRushSupportPet(button, index, data)
	local number = data.index and data.index - 1 or index

	button:TryChangePage("pet_number", number)

	if data.isEmpty then
		button:TryChangePage("empty", 1)
		LuaUIUtils.tryClearPetHeadIconInUBUtton(button)

		button.draggable = false

		return
	end

	button:TryChangePage("empty", 0)

	local pet = pg.me.pets[data.id]

	if not pet then
		LuaUIUtils.tryClearPetHeadIconInUBUtton(button)

		return
	end

	local petData = LuaUIUtils.generatePetInfo(pet)

	PetManagementUtils.renderFightPetSupport(button, petData)

	button.draggable = true

	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")

	btnDelUButton.gameObject:SetActiveEx(true)

	function btnDelUButton.luaClick()
		self:removeBossRushBattlePet(data)
	end
end

function FightPetComponent:renderBossRushSplitTitle(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, data.title)
end

function FightPetComponent:registerBossRushBtnDragEvent(button, data)
	function button.luaBeginDrag()
		self:beginBossRushDrag(button, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endBossRushDrag(button, data, dropWidget, rayBox)
	end
end

function FightPetComponent:beginBossRushDrag(button, data)
	self.bossRushDraggingPetId = data.id
	self.bossRushDraggingIndex = tonumber(button.gameObject.name)

	self.ctrl:setIsDragging(true)

	self.ctrl.draggingReplicaWidget = button.replicaWidget
	self.ctrl.draggingReplicaWidgetType = self.ctrl.DRAGGING_REPLICA_WIDGET.FIGHT_GROUP_CARD

	if button.replicaWidget then
		button.replicaWidget.name = button.gameObject.name

		local objectReference = button.replicaWidget:GetComponent("ObjectReference")
		local replicaIconUImage = objectReference:GetRefValue("iconUImage")
		local iconUrl
		local pet = pg.me.pets[data.id]

		if pet then
			local petData = LuaUIUtils.generatePetInfo(pet)

			iconUrl = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petData.label, petData.gender)

			LuaUIUtils.reloadPetHeadIcon(replicaIconUImage, iconUrl)
		else
			LuaUIUtils.clearPetHeadIcon(replicaIconUImage)
		end

		button.replicaWidget:TryChangePage("DragState", 1)
	end

	button:TryChangePage("DragState", 2)
end

function FightPetComponent:endBossRushDrag(button, data, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)

	local sourceIndex = self.bossRushDraggingIndex

	if sourceIndex then
		if dropWidget and self.bossRushBattleListItem[dropWidget] then
			local targetIndex = tonumber(dropWidget.gameObject.name)

			if targetIndex and targetIndex ~= sourceIndex then
				local srcId = self.bossRushBattlePetIds[sourceIndex]
				local tgtId = self.bossRushBattlePetIds[targetIndex]

				if srcId and tgtId then
					self.bossRushBattlePetIds[sourceIndex] = tgtId
					self.bossRushBattlePetIds[targetIndex] = srcId

					self:refreshBossRushPetInfos()
				elseif srcId then
					self.bossRushBattlePetIds[targetIndex] = srcId
					self.bossRushBattlePetIds[sourceIndex] = nil

					self:sortBossRushPetIds()
					self:refreshBossRushPetInfos()
				end
			end
		else
			table.remove(self.bossRushBattlePetIds, sourceIndex)
			self:refreshBossRushPetInfos()
		end
	end

	self.bossRushDraggingPetId = nil
	self.bossRushDraggingIndex = nil

	self.ctrl:setIsDragging(false)

	self.ctrl.draggingReplicaWidget = nil
	self.ctrl.draggingReplicaWidgetType = nil
end

function FightPetComponent:onBoxPetDropToBossRushSlot(petId, dropWidget, petData)
	if not self.bossRushBattleListItem[dropWidget] then
		return false
	end

	local targetIndex = tonumber(dropWidget.gameObject.name)

	if not targetIndex then
		self:resetBossRushBattleListDragState()

		return true
	end

	local existIndex = -1

	for i, id in ipairs(self.bossRushBattlePetIds) do
		if id == petId then
			existIndex = i

			break
		end
	end

	if self.bossRushBattlePetIds[targetIndex] then
		if existIndex ~= -1 then
			self.bossRushBattlePetIds[existIndex] = self.bossRushBattlePetIds[targetIndex]
			self.bossRushBattlePetIds[targetIndex] = petId
		else
			self.bossRushBattlePetIds[targetIndex] = petId
		end
	else
		if existIndex ~= -1 then
			table.remove(self.bossRushBattlePetIds, existIndex)
		end

		if #self.bossRushBattlePetIds < self.bossRushMaxCount then
			self.bossRushBattlePetIds[targetIndex] = petId
		end

		self:sortBossRushPetIds()
	end

	pg.game.audio:triggerEvent("ui_petmanagement_box_place")
	self:resetBossRushBattleListDragState()
	self:refreshBossRushPetInfos()

	return true
end

function FightPetComponent:sortBossRushPetIds()
	local newIds = {}

	for i = 1, 4 do
		if self.bossRushBattlePetIds[i] then
			table.insert(newIds, self.bossRushBattlePetIds[i])
		end
	end

	self.bossRushBattlePetIds = newIds
end

function FightPetComponent:resetBossRushBattleListDragState()
	local buttons = self.bossRushBattleUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		buttons[i]:TryChangePage("DragState", 0)
	end
end

function FightPetComponent:initRiftMode(levelId)
	self.rogueBattleUList = self.view.listTowerUList

	if IsNil(self.view.roomTitleBossUContainer) then
		return
	end

	self.isRiftMode = true

	self.view.btnReleaseUButton:SetActive(false)
	self.view.topRightTabUList:SetActive(false)
	self.view.roomTitleBossUContainer.gameObject:SetActiveEx(true)

	if self.view.roomTitleBossUContainer:CheckURLLoaded() then
		self:feedRift(levelId)
	else
		self.view.roomTitleBossUContainer:LoadDefaultUrlManually(function()
			self:feedRift(levelId)
		end)
	end
end

function FightPetComponent:feedRift(levelId)
	local objectReference = self.view.roomTitleBossUContainer.content:GetComponent("ObjectReference")
	local listElementUList = objectReference:GetRefValue("listElementUList")
	local textMutationUSDFText = objectReference:GetRefValue("textMutationUSDFText")
	local listMutationUList = objectReference:GetRefValue("listMutationUList")

	ClientTextUtils.setText(textMutationUSDFText, pg.getGameString("Rift_Mutation_Short"))

	self.recommendElements = {}

	self.view.roomTitleBossUContainer.content:TryChangePage("Stage", 1)

	local riftCfg = RiftLevelData[levelId]

	if riftCfg == nil then
		return
	end

	self.recommendElements = riftCfg.recommendedElements or {}

	LuaUIUtils.renderPetElement(listElementUList, self.recommendElements)

	self.buffCfgs = self:getMutationBuffs(riftCfg)

	function listMutationUList.luaRenderItem(button, index, data)
		local objRef = button:GetComponent("ObjectReference")

		if IsNil(objRef) then
			return
		end

		local icon = objRef:GetRefValue("iconUImage")

		if icon then
			icon.url = data.config.buffIcon
		end

		LuaUIUtils.setSkillTipButton2(button, {
			skillIcon = data.config.buffIcon,
			skillName = data.config.buffName,
			skillDesc = data.config.desc
		})
	end

	listMutationUList:SetList(self.buffCfgs)
end

function FightPetComponent:exitRiftMode()
	if not self.isRiftMode then
		return
	end

	self.isRiftMode = false
	self.recommendElements = nil
	self.buffCfgs = nil
end

function FightPetComponent:getMutationBuffs(levelConfig)
	local ret = {}

	if not levelConfig then
		return ret
	end

	for _, key in ipairs({
		"envBuff01",
		"envBuff02"
	}) do
		local buffId = levelConfig[key]

		if buffId and buffId ~= 0 then
			local buffCfg = RiftBuffData[buffId]

			if buffCfg then
				ret[#ret + 1] = {
					buffId = buffId,
					config = buffCfg
				}
			end
		end
	end

	return ret
end

function FightPetComponent:setParentListType(page)
	self.view.root:TryChangePage("ListType", page)

	if self.ctrl and self.ctrl.currentPage then
		self.ctrl.currentPage = page
	end
end

return FightPetComponent
