-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerStageInfo\\TowerStageInfoCtrl.lua

local MessageName = require("Const.MessageName")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TimerManager = require("Core.Timer.TimerManager")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RoguelikeData = require("Data.roguelike_data")
local BuffConfigData = require("Data.buff_config_data")
local LevelConditionData = require("Data.level_condition_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TowerStageInfoCtrl = Class.LightClass("TowerStageInfoCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local AbilityConst = require("Common.Const.AbilityConst")
local DungeonConst = require("Common.Const.DungeonConst")
local UIConst = require("Const.UIConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local RogueUtils = require("Utils.RogueUtils")
local Const = require("Common.Const.Const")

TowerStageInfoCtrl.messages = {
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurAbilityChanged",
		true
	}
}

function TowerStageInfoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.aniRecord = {}

	self:initUI()
end

function TowerStageInfoCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self:bindCommonCloseHotKey(function()
		self:close()
	end)

	function self.view.btnJumpUButton.luaClick()
		if self.showInfoPetId then
			pg.global.ui:open(UIConst.UI_ID_PET_PROPERTY, {
				curPetId = self.showInfoPetId
			})
		end
	end

	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function TowerStageInfoCtrl:onPetCurAbilityChanged()
	if self.roguePets == nil then
		return
	end

	self.model:refreshPetInfo(self.roguePets)
	self.view.listPetUList:SetList(self.roguePets)
end

function TowerStageInfoCtrl:getTeamFreePos()
	if self:isFullTeam() then
		return -1
	end

	for idx, id in ipairs(self.battlePetIds) do
		if id == "" or id == -1 then
			return idx
		end
	end

	return #self.battlePetIds + 1
end

function TowerStageInfoCtrl:changeBattleState(id, idx)
	local pos = idx

	if pos == -1 then
		if self:isFullTeam() then
			return -1
		end

		pos = self:getTeamFreePos()
		self.battlePetIds[pos] = id
	else
		self.battlePetIds[pos] = ""
	end
end

function TowerStageInfoCtrl:initUI()
	self.roguePets = self.model:getAllPets()
	self.isInBattle = pg.me.curRogueLayerState == DungeonConst.STATUS.PLAYING

	self.view.battleListPanelUComponent:TryChangePage("Status", self.isInBattle and 1 or 0)

	function self.view.selectedPetList.luaRenderItem(button, index, data)
		button.gameObject.name = tostring(index + 1)

		self:registerBtnDragEvent(button, data)
		LuaUIUtils.renderPetHeadRound(button, data, index + 1)

		button.interactable = false
		button.draggable = false
	end

	self.battlePetIds = RogueUtils.getBattlePetIds()

	self:sortPets()

	self.showInfoPetId = self.roguePets[1] and self.roguePets[1].id or nil

	function self.view.listPetUList.luaRenderItem(button, index, data)
		if not data.isEmpty and not data.isLock then
			self:registerBtnDragEvent(button, data)
		end

		self:renderPetInfo(button, index, data)

		button.draggable = false

		local notNeedNav = data.isEmpty or data.isLock

		button.navForceNonInteractable = notNeedNav
	end

	function self.view.listPetUList.luaFinishRender(list)
		self.view.listPetUList:SetEnableCustomInterval(false)
	end

	function self.view.listPetUList.luaClick(button, data, navItem)
		if data.isEmpty or data.isLock then
			return
		end

		self.showInfoPetId = data.id

		self:refreshPetProperty(data.id)
	end

	function self.view.enemyUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRogueEnemyInfo(button, index, data)
	end

	function self.view.propUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local valueUBaseText = objectReference:GetRefValue("valueUBaseText")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.icon

		ClientTextUtils.setText(valueUBaseText, data.value)

		function button.luaRenderTooltip(_, tipItem)
			PetManagementUtils.customRefreshBuffInfoTooltip(tipItem, PetManagementDataHelper.BuffInfoToolTipType.Buff, {
				buffName = pg.getLocalizationText(data.name),
				buffDesc = pg.getLocalizationText(data.desc),
				buffIcon = data.icon
			})
		end
	end

	self:setInfo()

	if self.showInfoPetId then
		self:refreshPetProperty(self.showInfoPetId)
	end

	self.view.listPetUList:SelectItem(0)
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("ROGUE_LIST_GOINTOBATTLE"))
	ClientTextUtils.setText(self.view.textRecordUSDFText, pg.getGameString("ROGUE_LIST_RECOMMEND"))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("ROGUE_LIST_TEAM_INFORMATION"))
	ClientTextUtils.setText(self.view.enemyUSDFText, pg.getGameString("ROGUE_LIST_ENEMY_INFORMATION"))
	ClientTextUtils.setText(self.view.taskUSDFText, pg.getGameString("ROGUE_LIST_MISSION_OBJECTIVES"))

	if self.view.buffUWidget then
		ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("ROGUE_MONSTER_EFFECT_TITLE"))

		local buffList = RogueUtils.getMonsterEffect()

		if buffList == nil or #buffList <= 0 then
			LuaUIUtils.setUIViewVisible(self.view.buffUWidget, false)
			self:scheduleRefreshDetailScrollConsoleBarState()
		else
			LuaUIUtils.setUIViewVisible(self.view.buffUWidget, true)

			function self.view.buffUList.luaFinishRender()
				self:scheduleRefreshDetailScrollConsoleBarState()
			end

			RogueUtils.renderMonsterEffect(self.view.buffUList, buffList)
		end
	end
end

function TowerStageInfoCtrl:refreshPetProperty(petId)
	for index, value in ipairs(self.roguePets) do
		if value.id == petId then
			self.view.rootUComponent:TryChangePage("Triangle", index - 1)

			break
		end
	end

	local data = LuaUIUtils.getRawPropertyData(petId)

	self.view.propUList:SetList(data)
end

function TowerStageInfoCtrl:setInfo()
	local dungeonId = pg.me.curRogueLayer
	local levelCfg = RoguelikeData[dungeonId]

	if levelCfg == nil then
		return
	end

	local text = pg.getGameString("TOWER_ROGUE_FLOOR_NAME")
	local finalText, _ = string.gsub(text, "{floor}", levelCfg.floor or "")

	ClientTextUtils.setText(self.view.levelNameUText, finalText)
	ClientTextUtils.setText(self.view.txtStageNameUText, pg.getLocalizationText(levelCfg.name))

	local recommendEles = levelCfg.recommendType or {}

	LuaUIUtils.renderPetElement(self.view.recommendEleList, recommendEles)

	self.battlePetIds = RogueUtils.getBattlePetIds()

	self.view.selectedPetList:SetList(self.model:getSelectedPets(self.battlePetIds))
	self.view.listPetUList:SetList(self.roguePets)

	local conditions = levelCfg.completionConditions or {}
	local data = {}

	for _, conditionId in ipairs(conditions) do
		local item = {}
		local conditionInfo = LevelConditionData[conditionId]

		item.label = pg.getLocalizationText(conditionInfo.displayDesc)

		table.insert(data, item)
	end

	self.view.conditionUList:SetList(data)
	self.view.conditionEmptyUWidget:SetActive(#data == 0)

	if levelCfg.buffId then
		local buffCfg = BuffConfigData[levelCfg.buffId]

		ClientTextUtils.setText(self.view.environmentEffectUText, buffCfg and pg.getLocalizationText(buffCfg.buffDesc) or "")
	end

	local enemyData = LuaUIUtils.getRogueEnemyList()

	self.view.enemyUList:SetList(enemyData)
	self.view.enemyEmptyUWidget:SetActive(#enemyData == 0)
	LuaUIUtils.setUIViewVisible(self.view.listPetUList, true)
end

function TowerStageInfoCtrl:renderPetInfo(button, index, data)
	if data.isLock then
		button:TryChangePage("State", 2)
	elseif data.isEmpty then
		button:TryChangePage("State", 1)
	else
		button:TryChangePage("State", 0)
	end

	if data.isEmpty or data.isLock then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local elementUList = objectReference:GetRefValue("elementUList")
	local orderUBaseText = objectReference:GetRefValue("orderUBaseText")
	local levelUBaseText = objectReference:GetRefValue("levelUBaseText")
	local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")
	local skill1UButton = objectReference:GetRefValue("skill1UButton")
	local skill2UButton = objectReference:GetRefValue("skill2UButton")
	local skill1iconUImage = objectReference:GetRefValue("skill1iconUImage")
	local skill2IconUImage = objectReference:GetRefValue("skill2IconUImage")
	local btnChangeSkillUButton = objectReference:GetRefValue("btnChangeSkillUButton")
	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local dragIconUImage = objectReference:GetRefValue("dragIconUImage")
	local orderUWidget = objectReference:GetRefValue("orderUWidget")
	local hpProgressUProgress = objectReference:GetRefValue("hpProgressUProgress")
	local addUButton = objectReference:GetRefValue("addUButton")
	local selectedIndex = self:getSelectedIndex(data.id)
	local isFullTeam = self:isFullTeam()

	function elementUList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	elementUList:SetList(data.elementNames)

	if not self.aniRecord[index] then
		self.aniRecord[index] = true

		button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	hpProgressUProgress.normalizedValue = data.hpRatio

	if data.hpRatio <= 0 then
		button:TryChangePage("Status", 2)
	elseif selectedIndex > 0 then
		button:TryChangePage("Status", 1)
	else
		button:TryChangePage("Status", 0)
	end

	if selectedIndex > 0 then
		button:TryChangePage("Add", 1)
		button:TryChangePage("AddStage", self.isInBattle and 1 or 0)
	else
		button:TryChangePage("Add", 0)
		button:TryChangePage("AddStage", (isFullTeam or self.isInBattle) and 1 or 0)
	end

	orderUWidget:SetActive(selectedIndex > 0)
	ClientTextUtils.setText(orderUBaseText, selectedIndex > 0 and "0" .. selectedIndex or "")
	ClientTextUtils.setText(levelUBaseText, data.level)
	ClientTextUtils.setText(petNameUBaseText, pg.getLocalizationText(data.name))

	local iconUrl = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)
	local iconUrl2 = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK, data.label)

	petIconUImage.url = iconUrl2
	dragIconUImage.url = iconUrl

	local qSkillInfo = PetManagementDataHelper.getPetSkillInfos(data.id, AbilityConst.WEAPON_SKILL_ABILITY)
	local eSkillInfo = PetManagementDataHelper.getPetSkillInfos(data.id, AbilityConst.WEAPON_SKILL_ABILITY2)
	local petInfo = pg.me:getPetInfo(data.id)

	skill1UButton:SetActive(qSkillInfo ~= nil)
	skill2UButton:SetActive(eSkillInfo ~= nil)

	if qSkillInfo then
		self:renderSkillTip(skill1UButton, qSkillInfo, petInfo)

		skill1iconUImage.url = LuaUIUtils.getSkillIcon(qSkillInfo.icon)
	end

	if eSkillInfo then
		self:renderSkillTip(skill2UButton, eSkillInfo, petInfo)

		skill2IconUImage.url = LuaUIUtils.getSkillIcon(eSkillInfo.icon)
	end

	function btnChangeSkillUButton.luaClick()
		PetManagementUtils.onEvolveClick(data.id, data.templateId, {
			toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL],
			selectPetList = self.battlePetIds
		})
	end

	function addUButton.luaClick()
		if self.isInBattle then
			return
		end

		local index = -1

		for i, petId in ipairs(self.battlePetIds) do
			if petId == data.id then
				index = i

				break
			end
		end

		if index ~= -1 then
			self:changeBattleState(data.id, index)
			self:refreshPetInfos()
		elseif not self:isFullTeam() then
			self:changeBattleState(data.id, -1)
			self:refreshPetInfos()
		else
			return
		end

		self:focusPetItem(button, data)
		self:refreshConsoleBarState()
	end
end

function TowerStageInfoCtrl:focusPetItem(button, data)
	local itemData = self.roguePets

	for index, item in ipairs(itemData) do
		if item.id == data.id then
			self.showInfoPetId = data.id

			if self.showInfoPetId then
				self:refreshPetProperty(self.showInfoPetId)
				self.view.listPetUList:SelectItem(index - 1)
			end

			break
		end
	end
end

function TowerStageInfoCtrl:renderSkillTip(button, data, petInfo)
	button.enabledTooltip = true

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	LuaUIUtils.setRenderSKillTooTip(button, data, nil, petInfo)
end

function TowerStageInfoCtrl:registerBtnDragEvent(button, data)
	function button.luaBeginDrag()
		self:beginDrag(button, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endDrag(button, data, dropWidget, rayBox)
	end
end

function TowerStageInfoCtrl:beginDrag(button, data)
	self.isDragging = true
	button.replicaWidget.name = button.name
	self.draggingPetId = data.id
	self.draggingIndex = tonumber(button.name)

	button:TryChangePage("DragState", 2)
	button.replicaWidget:TryChangePage("DragState", 1)
end

function TowerStageInfoCtrl:endDrag(button, data, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)

	if self.draggingPetId and dropWidget and tonumber(dropWidget.gameObject.name) then
		local targetSelectIndex = tonumber(dropWidget.gameObject.name)

		if self.draggingIndex then
			if self.battlePetIds[targetSelectIndex] then
				self.battlePetIds[self.draggingIndex] = self.battlePetIds[targetSelectIndex]
				self.battlePetIds[targetSelectIndex] = data.id
			end
		else
			local existIndex = -1

			for index, petId in ipairs(self.battlePetIds) do
				if petId == data.id then
					existIndex = index

					break
				end
			end

			if self.battlePetIds[targetSelectIndex] then
				if existIndex then
					self.battlePetIds[existIndex] = self.battlePetIds[targetSelectIndex]
				end

				self.battlePetIds[targetSelectIndex] = data.id
			elseif existIndex == -1 then
				table.insert(self.battlePetIds, data.id)
			end
		end

		self:refreshPetInfos()
	elseif self.draggingIndex then
		table.remove(self.battlePetIds, self.draggingIndex)
		self:refreshPetInfos()
	end

	self.isDragging = false
	self.draggingPetId = nil
	self.draggingIndex = nil
end

function TowerStageInfoCtrl:onNavFocusChange()
	if not LuaUIUtils.isUIViewVisible(self.view.rootUComponent) then
		return
	end

	local data = self:getFocusPetData()

	if data == nil then
		return
	end

	if data and not data.isEmpty then
		self:refreshConsoleBarState(false)
	else
		self:refreshConsoleBarState(true)
	end
end

function TowerStageInfoCtrl:refreshConsoleBarState(allHide)
	if allHide then
		pg.global.navMgr:SetConsoleBarState("TowerStageInfo_On", false)
		pg.global.navMgr:SetConsoleBarState("TowerStageInfo_Off", false)
		pg.global.navMgr:SetConsoleBarState("TowerStageInfo_Skill", false)

		return
	end

	local index = self:getSelectedIndex(self.showInfoPetId)
	local inTeam = index > 0

	pg.global.navMgr:SetConsoleBarState("TowerStageInfo_On", not inTeam and not self.isInBattle and self.showInfoPetId ~= nil)
	pg.global.navMgr:SetConsoleBarState("TowerStageInfo_Off", inTeam and not self.isInBattle and self.showInfoPetId ~= nil)
	pg.global.navMgr:SetConsoleBarState("TowerStageInfo_Skill", self.showInfoPetId ~= nil and not self.isInBattle and self.showInfoPetId ~= nil)
	pg.global.navMgr:SetConsoleBarState("TowerStageInfo_SkillBattle", self.showInfoPetId ~= nil and self.isInBattle and self.showInfoPetId ~= nil)
end

function TowerStageInfoCtrl:refreshDetailScrollConsoleBarState()
	local viewHeight = self.view.detailViewRectTransform.rect.height
	local contentHeight = self.view.detailContentRectTransform.rect.height

	pg.global.navMgr:SetConsoleBarState("TowerStageInfo_Scroll", viewHeight < contentHeight)
end

function TowerStageInfoCtrl:scheduleRefreshDetailScrollConsoleBarState()
	if self.detailScrollRefreshFrameId then
		TimerManager.delFrameCb(self.detailScrollRefreshFrameId)
	end

	self.detailScrollRefreshFrameId = self:startFrameTimer(function()
		self.detailScrollRefreshFrameId = nil

		if self.view then
			self:refreshDetailScrollConsoleBarState()
		end
	end, 1)
end

function TowerStageInfoCtrl:refreshPetInfos()
	self.view.selectedPetList:SetList(self.model:getSelectedPets(self.battlePetIds))
	self.view.listPetUList:RefreshList()
end

function TowerStageInfoCtrl:getFocusPetData()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local currentFocusedUContent = navMgr.CurrentFocusedUContent
	local currentFocusedGroupName = navMgr.CurrentFocusedGroupName

	if currentFocusedGroupName == "List" and currentFocusedUContent then
		local idx = self.view.listPetUList:GetChildIndex(currentFocusedUContent)

		if idx and idx >= 0 then
			local data = self.roguePets[idx + 1]

			return data
		end
	end
end

function TowerStageInfoCtrl:getSelectedIndex(petId)
	for index, battlePetId in ipairs(self.battlePetIds) do
		if petId == battlePetId then
			return index
		end
	end

	return 0
end

function TowerStageInfoCtrl:isFullTeam()
	local count = 0

	for _, v in ipairs(self.battlePetIds) do
		if v ~= "" and v ~= -1 then
			count = count + 1
		end
	end

	return count >= Const.PET_PREPARE_NUM_LIMIT
end

function TowerStageInfoCtrl:sortPets()
	table.sort(self.roguePets, RogueUtils.comparePetSortInfo)
end

function TowerStageInfoCtrl:onDestroy()
	if self.detailScrollRefreshFrameId then
		TimerManager.delFrameCb(self.detailScrollRefreshFrameId)

		self.detailScrollRefreshFrameId = nil
	end

	if not self.isInBattle then
		for i = #self.battlePetIds, 1, -1 do
			if self.battlePetIds[i] == "" or self.battlePetIds[i] == -1 then
				table.remove(self.battlePetIds, i)
			end
		end

		pg.me.space:modifyBattleFormation(self.battlePetIds)
	end

	UICtrl.onDestroy(self)
end

function TowerStageInfoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerStageInfoCtrl:onShow()
	return
end

function TowerStageInfoCtrl:onHide()
	return
end

return TowerStageInfoCtrl
