-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpPetSet\\PvpPetSetCtrl.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local PvpPetSetCtrl = Class.LightClass("PvpPetSetCtrl", UICtrl)
local PvpPetDetailComponent = require("Guis.Panels.PvpPetSet.Component.PvpPetDetailComponent")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

PvpPetSetCtrl.messages = {
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurAbilityChanged",
		true
	}
}
PvpPetSetCtrl.CALLBACK_TYPE = {
	SKILL_UPDATE = 2,
	FEATURE_UPDATE = 1,
	STRENGTHEN_POINT_UPDATE = 3
}

function PvpPetSetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setContextInfo(info)
	self.view.rogueSelectPetUButton:SetActive(info.isRogue and not pg.me.space:isRogueEnv() or false)

	self.pvpPetDetailComponent = PvpPetDetailComponent.new(self)

	function self.view.pvpUList.luaRenderItem(button, index, data)
		self:instantiateCurPetItem(button, index, data)
	end

	function self.view.boxPetList.luaRenderItem(button, index, data)
		self:instantiatePetItem(button, data)
	end

	self.model:initRecorder()
end

function PvpPetSetCtrl:addListener()
	function self.view.closeBtn.luaClick()
		if self.context.isRogue then
			self:close()
		else
			self.model:sendSaveTeamInfoMsg()
			self:exitSetPanel()
		end
	end

	function self.view.rogueSelectPetUButton.luaClick()
		if self.context.rogueCb then
			self.context.rogueCb(self.selectMap)
			self:close()
		else
			self.model:sendSaveTeamInfoMsg()
			self:exitSetPanel()
		end
	end

	function self.view.switchSkillBtn.luaClick()
		self.view.btnEvolutionUButton.luaClick()
	end

	self:bindGamepadScrollUList(self.view.boxPetList, 150, true)
end

function PvpPetSetCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PvpPetSetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.context = info

	self.model:initPetList()

	self.selectItem = nil
	self.selectData = nil
	self.selectMap = {}
end

function PvpPetSetCtrl:onShow()
	self:refreshView()
	pg.game.pvp:setNormalVolume()
end

function PvpPetSetCtrl:refreshView()
	local pets = self.model:getPetList()
	local secPets = self.model:getSelectedPetList()
	local hasSelectPet = false

	for index, value in ipairs(secPets) do
		if not value.empty then
			hasSelectPet = true

			break
		end
	end

	self.view.rogueSelectPetUButton.interactable = hasSelectPet

	self.view.pvpUList:SetList(secPets)
	self.view.boxPetList:SetList(pets)

	local selectId = self.context.pId

	if selectId and selectId ~= 0 then
		for i, v in ipairs(pets) do
			if v.templateId == selectId then
				local _, btn = self.view.boxPetList:TryGetChildAt(i - 1)

				if btn then
					self:clickPetItem(btn, nil)
				end

				break
			end
		end
	else
		local _, btn = self.view.boxPetList:TryGetChildAt(0)

		if btn then
			self:clickPetItem(btn, nil)
		end
	end

	if not pets or #pets <= 0 then
		self.pvpPetDetailComponent:switchPetInfoTopPages(3)
	end
end

function PvpPetSetCtrl:instantiateCurPetItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local nameUText = objectReference:GetRefValue("nameUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")
	local numCPUText = objectReference:GetRefValue("numCPUText")
	local rayBoxRayBox = objectReference:GetRefValue("rayBoxRayBox")

	item.draggable = false

	item:TryChangePage("DragState", 0)
	item:TryChangePage("empty", data.empty and 1 or 0)

	self.selectMap[rayBoxRayBox] = {
		data = data,
		index = index + 1,
		button = item
	}

	item:TryChangePage("pet_number", index)

	function item.luaPress()
		self:clickPetItem(item, data)
	end

	function item.luaHover()
		if self.isDragging == true then
			item:TryChangePage("DragState", 4)
		end
	end

	function item.luaUnhover()
		if self.isDragging == true then
			item:TryChangePage("DragState", 0)
		end
	end

	btnDelUButton.gameObject:SetActiveEx(not data.empty and not pg.me.space:isRogueEnv())

	if data.empty then
		return
	end

	if data.configData.isBoss then
		item:TryChangePage("isFlash", 2)
	elseif data.configData.isShiny then
		item:TryChangePage("isFlash", 1)
	else
		item:TryChangePage("isFlash", 0)
	end

	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.configData.icon, LuaUIUtils.PET_ICON, data.configData.label, data.configData.gender), function()
		return
	end)

	if data.configData.gender == Const.GENDER_TYPE_MALE then
		item:TryChangePage("Gender", 0)
	elseif data.configData.gender == Const.GENDER_TYPE_FEMALE then
		item:TryChangePage("Gender", 1)
	else
		item:TryChangePage("Gender", 2)
	end

	ClientTextUtils.setText(nameUText, data.configData.name)

	local levelInfo = ClientTextUtils.concatByLanguage(pg.getGameString("LEVEL"), data.configData.level)

	if data.configData.cp then
		numCPUText:SetActiveFastest(true)

		numCPUText.text = ClientTextUtils.concatByLanguage(pg.getGameString("CP"), data.configData.cp or "0")
	else
		numCPUText:SetActiveFastest(false)
	end

	ClientTextUtils.setText(numLevelUText, levelInfo)

	function btnDelUButton.luaClick()
		self:onDeSelectItem(rayBoxRayBox, index + 1)
	end
end

function PvpPetSetCtrl:instantiatePetItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local iconHomeUImage = objectReference:GetRefValue("iconHomeUImage")
	local battleNumUContainer = objectReference:GetRefValue("battleNumUContainer")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")

	panelCPUContainer:LoadDefaultUrlManually()

	local objectReference1 = panelCPUContainer.content:GetComponent("ObjectReference")
	local numCPUText = objectReference1:GetRefValue("numCPUSDFText")
	local singleElement = objectReference1:GetRefValue("singleElement")
	local doubleElement1 = objectReference1:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference1:GetRefValue("doubleElement2")
	local panelCharListUContainer = objectReference:GetRefValue("panelCharListUContainer")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")
	local petQualityUContainer = objectReference:GetRefValue("petQualityUContainer")
	local petRareUContainer = objectReference:GetRefValue("petRareUContainer")
	local petRareNmlUContainer = objectReference:GetRefValue("petRareNmlUContainer")

	panelCPUContainer.renderOpacity = 1
	panelCharListUContainer.renderOpacity = 1
	txtBoxUImage.renderOpacity = 0

	petQualityUContainer:DestroyContent()
	petRareUContainer:DestroyContent()
	petRareNmlUContainer:DestroyContent()
	iconHomeUImage:SetActive(false)

	item.enabledTooltip = false

	item:TryChangePage("state", data.unlock and 0 or 1)
	item:TryChangePage("select", 0)

	function item.luaInitDrag()
		item.draggable = data.unlock
	end

	function item.luaPress()
		self:clickPetItem(item, data)
	end

	function item.luaBeginDrag()
		self.isDragging = true
		self.draggingPetId = data.templateId
	end

	function item.luaEndDrag(_, target)
		self.isDragging = false

		self:onSelectItem(target, data)
	end

	local shinyStyle = data.serverData and data.serverData.shinyStyle or 0

	LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, data.configData.isShiny, shinyStyle)
	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.configData.icon, LuaUIUtils.PET_ICON, data.configData.label, data.configData.gender), function()
		return
	end)
	ClientTextUtils.setText(numCPUText, data.configData.cp or "0")

	if #data.configData.elementNames <= 0 then
		panelCPUContainer.content.gameObject:SetActiveEx(false)
	elseif #data.configData.elementNames == 1 then
		panelCPUContainer.content.gameObject:SetActiveEx(true)
		panelCPUContainer.content:TryChangePage("DetailState", 0)
		LuaUIUtils.setElementButtonNew(singleElement, data.configData.elementNames[1].element)
	else
		panelCPUContainer.content.gameObject:SetActiveEx(true)
		panelCPUContainer.content:TryChangePage("DetailState", 1)
		LuaUIUtils.setElementButtonNew(doubleElement1, data.configData.elementNames[1].element)
		LuaUIUtils.setElementButtonNew(doubleElement2, data.configData.elementNames[2].element)
	end

	local tempExploreLevelAllData = {}

	for k, v in pairs(data.configData.exploreSkillsLevel) do
		local temp = {
			exploreName = k,
			exploreLevel = v
		}

		tempExploreLevelAllData[#tempExploreLevelAllData + 1] = temp
	end

	local battleNum = -1

	for _, v in pairs(self.selectMap) do
		if v.data.id == data.id then
			battleNum = v.index - 1

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
end

function PvpPetSetCtrl:clickPetItem(item, _)
	if self.selectItem then
		self.selectItem:TryChangePage("select", 0)
	end

	self.selectItem = item

	self.selectItem:TryChangePage("select", 1)

	if self.selectItem.dataFromUList ~= nil then
		self.pvpPetDetailComponent:refreshPetInfoDetail(self.selectItem.dataFromUList)
	end
end

function PvpPetSetCtrl:onSelectItem(target, newData)
	if self.selectMap[target] == nil then
		return
	end

	if not self.model:checkCanSelect(newData) then
		return
	end

	if self.selectMap[target].data.templateId == newData.templateId then
		local old = self.selectMap[target]

		self.model:selectPet(old.index, newData)
		self:refreshView()

		return
	end

	local existsBtn = self:checkIdExists(newData.templateId)

	if existsBtn then
		if self.selectMap[target].data.templateId == 0 then
			self:refreshAni(self.selectMap[target].button)
		else
			self:refreshAni(self.selectMap[target].button, existsBtn)
		end
	else
		self:refreshAni(self.selectMap[target].button)
	end

	local old = self.selectMap[target]

	self.model:selectPet(old.index, newData)
	self:refreshView()
end

function PvpPetSetCtrl:checkIdExists(id)
	for _, v in pairs(self.selectMap) do
		if v.data.templateId == id then
			return v.button
		end
	end

	return nil
end

function PvpPetSetCtrl:onDeSelectItem(_, index)
	self.model:deSelectPet(index)
	self:refreshView()

	if self.selectItem == nil then
		return
	end

	local _, curPage = self.selectItem:TryGetCurrentPage("pet_number")

	if curPage == index - 1 then
		self.pvpPetDetailComponent:refreshPetInfoDetail()
	end
end

function PvpPetSetCtrl:sendSavePetInfoMsg(templateId, callbackType)
	if templateId == nil or self.model.petsMap[templateId].serverData == nil then
		return
	end

	local me = pg.me
	local abilityPresetMap = {}

	for i = 1, #self.model.petsMap[templateId].serverData.abilityPresetMap do
		abilityPresetMap[i] = {}

		for j = 1, #self.model.petsMap[templateId].serverData.abilityPresetMap[i] do
			abilityPresetMap[i][j] = self.model.petsMap[templateId].serverData.abilityPresetMap[i][j]
		end
	end

	local curAbilityPreset = self.model.petsMap[templateId].serverData.curAbilityPreset
	local curCharacter = self.model.petsMap[templateId].serverData.curCharacter
	local valid = true
	local skill1, skill2

	for i = 1, #abilityPresetMap do
		skill1 = abilityPresetMap[i][AbilityConst.WEAPON_SKILL_ABILITY]
		skill2 = abilityPresetMap[i][AbilityConst.WEAPON_SKILL_ABILITY2]

		if skill1 == 0 and skill2 == 0 or skill1 ~= skill2 then
			valid = true
		else
			valid = false

			return
		end
	end

	local res = {
		templateId = templateId,
		abilityPresetMap = abilityPresetMap,
		curAbilityPreset = curAbilityPreset,
		curCharacter = curCharacter
	}

	if callbackType == self.CALLBACK_TYPE.FEATURE_UPDATE then
		me:setPetInfo(res, templateId, function(result)
			if result == NoticeDef.SUCCESS then
				self.pvpPetDetailComponent:refreshPetInfoDetail(self.model.petsMap[templateId])
			else
				me.logger:error("update feature error", result)
			end
		end)
	elseif callbackType == self.CALLBACK_TYPE.SKILL_UPDATE then
		me:setPetInfo(res, templateId, function(result)
			if result == NoticeDef.SUCCESS then
				local petTrainingNew = pg.global.ui.petTrainingNew

				if petTrainingNew ~= nil and petTrainingNew.view then
					petTrainingNew:onPetCurAbilityChanged({
						petId = templateId
					})
				end

				self.pvpPetDetailComponent:refreshPetInfoDetail(self.model.petsMap[templateId])
			else
				me.logger:error("update skill error", result)
			end
		end)
	elseif callbackType == self.CALLBACK_TYPE.STRENGTHEN_POINT_UPDATE then
		-- block empty
	end
end

function PvpPetSetCtrl:exitSetPanel()
	if self.context and self.context.cb then
		self.context.cb()
	end

	pg.global.ui:close(UIConst.UI_ID_PVP_PET_SET)
end

function PvpPetSetCtrl:onHide()
	pg.game.pvp:setNormalVolume()
end

function PvpPetSetCtrl:getRightPanelCurrentPage()
	local _, page = self.view.rightPanelUComponent:TryGetCurrentPage("tabInfo")

	return page
end

function PvpPetSetCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_TOWER_MAIN] = true

	return whiteList
end

function PvpPetSetCtrl:refreshAni(button, existsButton)
	return
end

function PvpPetSetCtrl:onPetCurAbilityChanged(info)
	local petId = info.petId

	if petId == self.selectItem.dataFromUList.id then
		self.pvpPetDetailComponent:refreshSkillList(pg.me:getPetInfo(petId))
	end
end

return PvpPetSetCtrl
