-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSelectPet\\TowerSelectPetCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSelectPetCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerSelectPetCtrl = Class.LightClass("TowerSelectPetCtrl", UICtrl)
local PetManagementUtils = require("Utils.PetManagementUtils")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local BossRushUtils = require("Utils.BossRushUtils")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")

TowerSelectPetCtrl.messages = {
	[MessageName.PET_LEVEL_CHANGED] = {
		"onPetLevelChanged",
		true
	},
	[MessageName.PET_ADD_EXP] = {
		"onPetLevelChanged",
		true
	}
}

function TowerSelectPetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if not info or not info.levelId then
		return
	end

	self.fromType = info.fromType

	if self.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
		self.levelId = info.levelId
		self.battlePetIds = info.inputPetList
		self.maxCount = Const.PET_PREPARE_NUM_LIMIT
	elseif self.fromType == UIConst.ROGUE_FROM_TYPE.BOSS_RUSH then
		self.levelId = info.levelId
		self.battlePetIds = BossRushUtils.getPlayerSelectPetIds(pg.me.id, self.levelId)
		self.maxCount = Const.PET_PREPARE_NUM_LIMIT

		self.view.roomTitleTowerUWidget:SetActive(false)
		self.view.roomTitleBossUContainer:SetActive(true)
	else
		self.levelId = info.levelId
		self.battlePetIds = pg.me:getCurSelectPets(self.levelId)
		self.maxCount = RogueTalentUtils.func(pg.me, "rogueExtraSlot") and 5 or 4

		pg.global.ui.towerLevelDetail:hide()
	end

	self.curSelectIndex = nil
	self.curSelectPetData = nil
	self.petId2Index = {}
	self.battleListItem = setmetatable({}, {
		__mode = "k"
	})

	self:initUI()
end

function TowerSelectPetCtrl:onVisibleChange(visible)
	TowerSelectPetCtrl.super.onVisibleChange(self, visible)

	if visible then
		PetManagementUtils.setSelectedPet(self.curSelectIndex)
	end
end

function TowerSelectPetCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnLevelupUButton.luaClick()
		local petData = self.curSelectPetData or self.firstPetData

		if petData then
			PetManagementUtils.onPetLvUpClick(petData.id, petData.iconName, petData.label, Utils.canLevelBreakthrough(petData.id))
		end
	end

	function self.view.btnCultivateUButton.luaClick()
		local petData = self.curSelectPetData or self.firstPetData

		if petData then
			PetManagementUtils.onEvolveClick(petData.id, petData.templateId, {
				toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.TALENT],
				selectPetList = self.battlePetIds
			})
		end
	end

	function self.view.btnSkillsUButton.luaClick()
		local petData = self.curSelectPetData or self.firstPetData

		if petData then
			PetManagementUtils.onEvolveClick(petData.id, petData.templateId, {
				toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL],
				selectPetList = self.battlePetIds
			})
		end
	end

	function self.view.btnDressUButton.luaClick()
		local petData = self.curSelectPetData or self.firstPetData

		if petData then
			LuaUIUtils.openPetAppearancePanel(petData.id, function()
				return
			end)
		end
	end
end

function TowerSelectPetCtrl:resetBtnState(data)
	local petInfo = pg.me:getPetInfo(data.id)

	self:refreshCanBreakThrough(petInfo.needBreakthrough)
end

function TowerSelectPetCtrl:refreshCanBreakThrough(needBreakthrough)
	self.view.btnLevelupUButton:TryChangePage("CanBreakthrough", 0)
end

function TowerSelectPetCtrl:checkLevel(data)
	if not data or not data.level then
		return false
	end

	if data.level <= pg.me.level then
		return true
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("ROGUE_SELECT_PET_LEVEL_LIMIT"))

	return false
end

function TowerSelectPetCtrl:initUI()
	PetManagementUtils.setListButtonDelegateTable({
		selectedChanged = function(data, button)
			local objectReference = button:GetComponent("ObjectReference")
			local frameSelectUImage = objectReference:GetRefValue("frameSelectUImage")

			if frameSelectUImage then
				frameSelectUImage:SetActive(false)
			end
		end,
		luaPress = function(button, index, data)
			if not self.forbiddenRemove and not data.isEmpty then
				local existIndex = -1

				for i, petId in ipairs(self.battlePetIds) do
					if petId == data.id then
						existIndex = i

						break
					end
				end

				if existIndex ~= -1 then
					table.remove(self.battlePetIds, existIndex)
				elseif #self.battlePetIds < self.maxCount and self:checkLevel(data) then
					table.insert(self.battlePetIds, data.id)
				end
			end

			self.curSelectIndex = index
			self.curSelectPetData = data

			if data.id then
				self:refreshPetInfos()
				self:resetBtnState(data)
			end
		end,
		renderExtraLogic = function(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local praiseUWidget = objectReference:GetRefValue("praiseUWidget")
			local battleNumUContainer = objectReference:GetRefValue("battleNumUContainer")
			local iconEvolveUImage = objectReference:GetRefValue("iconEvolveUImage")

			if data.isEmpty then
				praiseUWidget:SetActive(false)

				return
			end

			if index == 0 then
				self.firstPetData = data

				self:resetBtnState(data)
			end

			if iconEvolveUImage then
				iconEvolveUImage.gameObject:SetActiveEx(false)
			end

			praiseUWidget:SetActive(self:checkElementMatch(data.elementNames, self.recommendEles))

			local battleNum = -1

			for number, petId in ipairs(self.battlePetIds) do
				if data.id == petId then
					battleNum = number - 1
					self.petId2Index[data.id] = index

					break
				end
			end

			if battleNum == -1 then
				if battleNumUContainer:CheckURLLoaded() then
					battleNumUContainer:DestroyContent()
				end
			elseif battleNumUContainer:CheckURLLoaded() then
				battleNumUContainer.content:TryChangePage("number", battleNum)
			else
				battleNumUContainer:LoadDefaultUrlManually(function(widget)
					widget:TryChangePage("number", battleNum)
				end)
			end
		end,
		luaBeginDrag = function(button, index, data)
			self:beginDrag(button, data, true)
		end,
		luaEndDrag = function(button, dropWidget, rayBox, data)
			self:endDrag(button, data, dropWidget, rayBox)
		end,
		luaHover = function(button, index, data)
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		end,
		luaUnhover = function(button, index, data)
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	})

	function PetManagementUtils.onPetInfoPageChange(index)
		self.view.btnLevelupUButton:SetActive(index == 0)
		self.view.btnCultivateUButton:SetActive(index == 0)
		self.view.btnSkillsUButton:SetActive(index == 1)
		self.view.btnDressUButton:SetActive(index == 2)
	end

	PetManagementUtils.initTemplate(self.view.rightPanelTransform, self.view.midPanelTransform, {
		hideBtnFavorite = true,
		noNeedTabIndex = true,
		uiScene = self.uiScene
	})

	function PetManagementUtils.onNormalListRenderFinished()
		if not self.forbiddenSelect then
			PetManagementUtils.setSelectedPet(0)
		end
	end

	PetManagementUtils.setSelectedPet(0)

	local recommendLevel, recommendEles

	self.view.catchRogueTipsTxt:SetActive(false)

	if self.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
		local data = CatchRoguePhaseData[self.levelId]

		recommendEles = data.recommendType or {}

		self.view.textLvUBaseText:SetActive(false)
		self.view.catchRogueTipsTxt:SetActive(true)
		ClientTextUtils.setText(self.view.catchRogueTipsTxt, pg.getGameString("CATCH_ROGUE_LEVEL"))
	elseif self.fromType == UIConst.ROGUE_FROM_TYPE.BOSS_RUSH then
		BossRushUtils.initSelectPetTitleInfo(self.view.roomTitleBossUContainer, self.levelId)

		local levelData = BossRushLevelData[self.levelId]

		recommendEles = levelData.elementRecmmend or {}
	else
		local difficultyCfg = RogueDifficultyData[self.levelId]

		if not difficultyCfg then
			return
		end

		recommendLevel = difficultyCfg.recommendLv
		recommendEles = difficultyCfg.recommendType or {}

		ClientTextUtils.setText(self.view.textLvUBaseText, "lv." .. recommendLevel)
	end

	self.recommendEles = recommendEles

	LuaUIUtils.renderPetElement(self.view.listRoundUList, recommendEles)

	function self.view.listBattleUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 or data.tIndex == 2 then
			local selected = self.curSelectPetData and data.id == self.curSelectPetData.id

			button:TryChangePage("select", selected and 1 or 0)

			button.gameObject.name = tostring(data.index or index + 1)
			self.battleListItem[button] = true

			self:registerBtnDragEvent(button, data)
		end

		if data.tIndex == 0 then
			self:renderBattlePet(button, index, data)
		elseif data.tIndex == 2 then
			self:renderSupportPet(button, index, data)
		elseif data.tIndex == 1 then
			self:renderSplitTitle(button, index, data)
		end
	end

	function self.view.listBattleUList.luaClick(button, data)
		if data.id then
			self.forbiddenRemove = true

			PetManagementUtils.selectPet(data.id)

			self.forbiddenRemove = false
			self.curSelectPetData = data

			self:resetBtnState(data)
		end
	end

	self:refreshPetInfos()
end

function TowerSelectPetCtrl:refreshPetInfos()
	self.view.listBattleUList:SetList(self:getPetListData())

	self.forbiddenSelect = true

	PetManagementUtils.refreshPetList()

	self.forbiddenSelect = false

	self:refreshRecommendLv()
end

function TowerSelectPetCtrl:onPetLevelChanged(info)
	TimerManager.addNextFrameCb(function()
		self:refreshPetInfos()

		if info.oldLevel < info.newLevel then
			pg.global.ui:open(UIConst.UI_ID_PET_LEVEL_UP, info)
		end
	end)
	self:startTimer(function()
		PetManagementUtils.setSelectedPet(self.curSelectIndex)
	end, 0.1)
end

function TowerSelectPetCtrl:getPetListData()
	local data = {}

	if self.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE or self.fromType == UIConst.ROGUE_FROM_TYPE.BOSS_RUSH then
		data = {
			{
				isEmpty = true,
				index = 1
			},
			{
				isEmpty = true,
				index = 2
			},
			{
				isEmpty = true,
				index = 3
			},
			{
				isEmpty = true,
				index = 4
			}
		}
	else
		data = {
			{
				isEmpty = true,
				index = 1
			},
			{
				isEmpty = true,
				index = 2
			},
			{
				isEmpty = true,
				index = 3
			},
			{
				isEmpty = true,
				index = 4
			},
			{
				index = 5,
				isEmpty = true,
				isLock = not RogueTalentUtils.func(pg.me, "rogueExtraSlot")
			}
		}
	end

	for index, petId in ipairs(self.battlePetIds) do
		local pet = pg.me.pets[petId]

		if pet and not data[index].isLock then
			data[index] = LuaUIUtils.generatePetInfo(pet)
			data[index].index = index
		end
	end

	if self.fromType == UIConst.ROGUE_FROM_TYPE.BOSS_RUSH then
		data[2].tIndex = 2
		data[3].tIndex = 2
		data[4].tIndex = 2

		table.insert(data, 2, {
			tIndex = 1,
			title = pg.getGameString("SUPPORT_TEAM_TITLE_2")
		})
		table.insert(data, 1, {
			tIndex = 1,
			title = pg.getGameString("SUPPORT_TEAM_TITLE_1")
		})

		self.view.listBattleUList.rowSpacing = 64
	end

	return data
end

function TowerSelectPetCtrl:refreshRecommendLv()
	if self.fromType == UIConst.ROGUE_FROM_TYPE.BOSS_RUSH then
		return
	end

	local totalLevel = 0
	local petCount = 0

	for index, petId in ipairs(self.battlePetIds) do
		local pet = pg.me.pets[petId]

		if pet then
			petCount = petCount + 1
			totalLevel = totalLevel + pet.level
		end
	end

	if petCount == 0 then
		self.view.rootUComponent:TryChangePage("Text", 0)
	elseif self.fromType ~= UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
		local difficultyCfg = RogueDifficultyData[self.levelId]

		self.view.rootUComponent:TryChangePage("Text", totalLevel / petCount >= difficultyCfg.recommendLv and 0 or 1)
	end
end

function TowerSelectPetCtrl:renderBattlePet(button, index, data)
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
	local number = data.index and data.index - 1 or index

	button:TryChangePage("pet_number", number)

	if data.isLock then
		button:TryChangePage("empty", 2)
	elseif data.isEmpty then
		button:TryChangePage("empty", 1)
	else
		button:TryChangePage("empty", 0)
	end

	if data.isEmpty or data.isLock then
		praiseUWidget:SetActive(false)

		return
	end

	button:TryChangePage("DragState", 0)
	button:TryChangePage("isFlash", data.isShiny and 1 or 0)
	button:TryChangePage("isChange", data.isVariant and 1 or 0)

	iconOrientationUImage.url = data.petTypeUrl

	local petName = ""

	if data.customName and data.customName ~= "" then
		petName = data.customName
	else
		petName = pg.getLocalizationText(data.name)
	end

	ClientTextUtils.setText(nameUText, petName)
	ClientTextUtils.setText(nameShineUSDFText, petName)
	ClientTextUtils.setText(nameShineUSDFText1, petName)

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	ClientTextUtils.setText(numLevelUText, data.level)

	local pet = pg.me:getPetInfo(data.id)

	if data.cp and not pet:isCatchReporting() then
		numCPUText:SetActiveFastest(true)

		numCPUText.text = ClientTextUtils.concatByLanguage(pg.getGameString("CP"), data.cp)
	else
		numCPUText:SetActiveFastest(false)
	end

	function elementsUList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	elementsUList:SetList(data.elementNames)
	praiseUWidget:SetActive(self:checkElementMatch(data.elementNames, self.recommendEles))

	hpBarUHealthbar.maxHp = 1
	hpBarUHealthbar.hp = 1

	btnDelUButton.gameObject:SetActiveEx(not data.empty)

	function btnDelUButton.luaClick()
		self:removeBattlePet(data)
	end
end

function TowerSelectPetCtrl:renderSupportPet(button, index, data)
	if data.empty then
		return
	end

	PetManagementUtils.renderFightPetSupport(button, data)

	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")

	btnDelUButton.gameObject:SetActiveEx(not data.empty)

	function btnDelUButton.luaClick()
		self:removeBattlePet(data)
	end
end

function TowerSelectPetCtrl:removeBattlePet(data)
	if data.isEmpty then
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
		table.remove(self.battlePetIds, index)
		self:refreshPetInfos()
	end
end

function TowerSelectPetCtrl:renderSplitTitle(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, data.title)
end

function TowerSelectPetCtrl:checkElementMatch(elementNames, recommendEles)
	for _, info in ipairs(elementNames) do
		if table.contains(recommendEles, info.element) then
			return true
		end
	end

	return false
end

function TowerSelectPetCtrl:registerBtnDragEvent(button, data)
	function button.luaBeginDrag()
		self:beginDrag(button, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endDrag(button, data, dropWidget, rayBox)
	end
end

function TowerSelectPetCtrl:beginDrag(button, data, isList)
	self.isDragging = true
	button.replicaWidget.name = button.name
	self.draggingPetId = data.id

	if not isList then
		self.draggingIndex = tonumber(button.name)
	end

	button:TryChangePage("DragState", 2)
	button.replicaWidget:TryChangePage("DragState", 1)
end

function TowerSelectPetCtrl:endDrag(button, data, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)

	if not self:checkLevel(data) then
		return
	end

	if self.draggingPetId and dropWidget and tonumber(dropWidget.gameObject.name) and self.battleListItem[dropWidget] then
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
				if existIndex ~= -1 then
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

function TowerSelectPetCtrl:onDestroy()
	if self.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
		pg.global.ui.catchRogueEntry:setTempInfo(self.battlePetIds)
		pg.global.ui.catchRogueEntry:refreshUI()
	elseif self.fromType == UIConst.ROGUE_FROM_TYPE.BOSS_RUSH then
		pg.me:bossRushSelectPet(self.levelId, self.battlePetIds)
	else
		pg.me:setRoguePets(self.battlePetIds)
		pg.me:setRogueLevelHistoryBattlePet(self.levelId, self.battlePetIds)
		pg.global.ui.towerLevelDetail:show()
		pg.global.ui.towerLevelDetail:refreshListPet(self.battlePetIds)
	end

	PetManagementUtils.destroyTemplate()
	UICtrl.onDestroy(self)
end

function TowerSelectPetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerSelectPetCtrl:onShow()
	return
end

function TowerSelectPetCtrl:onHide()
	return
end

return TowerSelectPetCtrl
