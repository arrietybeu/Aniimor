-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagement\\Component\\ExplorePetComponent.lua

local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local SysConfigData = require("Data.sys_config_data")
local UIComponent = require("Guis.Helper.UIComponent")
local ExplorePetComponent = Class.LightClass("ExplorePetComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

function ExplorePetComponent:findObjects()
	self.listCharUList = self.view.listCharUList
	self.maskButtonUButton = self.view.maskButtonForExploreUButton
	self.slotIdRecordTable = {}

	self:initSlotIdRecordTable()
end

function ExplorePetComponent:initView()
	self:addListener()
	self:refreshExploreList()
end

function ExplorePetComponent:addListener()
	return
end

function ExplorePetComponent:initSlotIdRecordTable()
	for i = 1, Const.MAX_FORMATION_COUNT do
		local petInfos = self.model:getExploreGroupInfoById(i)

		self.slotIdRecordTable[i] = {}

		for k, v in pairs(petInfos) do
			self.slotIdRecordTable[i][k] = v.empty and "empty" or v.id
		end
	end
end

function ExplorePetComponent:refreshExploreList()
	local selectGroupId = self.model:getSelectGroupId()
	local petInfos = self.model:getExploreGroupInfoById(selectGroupId)

	function self.listCharUList.luaRenderItem(button, index, data)
		self:setExplorePetListData(button, index, data)
	end

	function self.listCharUList.luaFinishRender(_)
		for k, v in pairs(petInfos) do
			self.slotIdRecordTable[selectGroupId][k] = v.empty and "empty" or v.id
		end
	end

	self.listCharUList:SetList(petInfos)
end

function ExplorePetComponent:setExplorePetListData(button, index, data)
	button:TryChangePage("select", 0)
	button:TryChangePage("button", 0)

	button.isSelected = false

	function button.luaPress()
		self:cardPressEvent(button, index, data)
	end

	button.name = "Explore_" .. index + 1

	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local nameUText = objectReference:GetRefValue("nameUText")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
	local resurrectionUWidget = objectReference:GetRefValue("resurrectionUWidget")
	local nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
	local nameShineUSDFText1 = objectReference:GetRefValue("nameShineUSDFText1")
	local favoriteUButton = objectReference:GetRefValue("favoriteUButton")
	local exploreUBaseText = objectReference:GetRefValue("exploreUBaseText")
	local exploreUBaseText2 = objectReference:GetRefValue("exploreUBaseText2")
	local flshIconUButton = objectReference:GetRefValue("flshIconUButton")
	local bossUButton = objectReference:GetRefValue("bossUButton")
	local umbralUContainer = objectReference:GetRefValue("umbralUContainer")

	if index == 0 then
		ClientTextUtils.setText(exploreUBaseText, pg.getGameString("CLIMB"))
		ClientTextUtils.setText(exploreUBaseText2, pg.getGameString("CLIMB"))
	elseif index == 1 then
		ClientTextUtils.setText(exploreUBaseText, pg.getGameString("GLIDE"))
		ClientTextUtils.setText(exploreUBaseText2, pg.getGameString("GLIDE"))
	elseif index == 2 then
		ClientTextUtils.setText(exploreUBaseText, pg.getGameString("SWIM"))
		ClientTextUtils.setText(exploreUBaseText2, pg.getGameString("SWIM"))
	end

	button:TryChangePage("PetChar", index + 1)
	button:TryChangePage("fakeSelect", 0)
	resurrectionUWidget.gameObject:SetActiveEx(false)

	function button.luaHover()
		self:onHover(button, data.empty == true)
	end

	function button.luaUnhover()
		self:onUnHover(button)
	end

	button:TryChangePage("DragState", 0)

	if data.empty == true then
		button:TryChangePage("empty", 1)

		petIdDisplay.gameObject.name = "Null"

		LuaUIUtils.clearPetHeadIcon(iconUImage)

		button.draggable = false

		return
	end

	if self.model.curSelectPetId == data.id then
		button:TryChangePage("select", 1)
		button:TryChangePage("button", 5)

		button.isSelected = true
	end

	button:TryChangePage("empty", 0)

	petIdDisplay.gameObject.name = data.id

	if self.slotIdRecordTable[self.model:getSelectGroupId()][index + 1] ~= data.id then
		button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	button.draggable = true

	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
		return
	end)

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(nameUText, data.customName)
		ClientTextUtils.setText(nameShineUSDFText, data.customName)
		ClientTextUtils.setText(nameShineUSDFText1, data.customName)
	else
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(nameShineUSDFText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(nameShineUSDFText1, pg.getLocalizationText(data.name))
	end

	hpBarUHealthbar.maxHp = 1
	hpBarUHealthbar.hp = data.hpRatio

	umbralUContainer:SetActive(data.isDark)

	if data.isDark then
		button:TryChangePage("isBoss", 0)
		umbralUContainer:LoadDefaultUrlManually()
	end

	if data.isShiny then
		button:TryChangePage("isFlash", 1)

		if data.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			button:TryChangePage("isFlash", 2)
		elseif data.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			button:TryChangePage("isFlash", 3)
		else
			button:TryChangePage("isFlash", 1)
		end

		LuaUIUtils.setPetTagLabelToolTip(flshIconUButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
		button:TryChangePage("isBoss", 0)
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

	PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)

	if data.isVariant then
		button:TryChangePage("isChange", 1)
	else
		button:TryChangePage("isChange", 0)
	end

	button:TryChangePage("IsBattle", 0)

	petIdDisplay.gameObject.name = data.id

	for i = 1, self.ctrl.MAX_FIGHT_PETS_COUNT do
		if data.id == self.model:getPetGroupPetsInModelByIndex(i) then
			button:TryChangePage("IsBattle", 1)

			break
		end
	end

	self:renderExploreSkillPoints(button, index, data)
	TimerManager.addTimer(0.1, function()
		local ent = pg.getEntity(data.id)

		if ent and ent.exploreRevivePer > 0 then
			self:onExplorePetRevivePercentChanged({
				[2] = ent.exploreRevivePer,
				[3] = {
					id = data.id
				}
			})
		end
	end)

	function button.luaBeginDrag()
		self:beginDrag(button, index, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endDrag(button, dropWidget, rayBox)
		self:clearDraggingInfo()
	end

	function btnDelUButton.luaClick()
		self.model:modifyExplorePrepareFormation(index + 1, "")
	end

	function favoriteUButton.luaClick()
		PetManagementUtils.setRenderFavoriteToolTips(favoriteUButton, data.id)
	end

	PetManagementUtils.refreshFavoriteBtn(favoriteUButton, data and data.favoriteType)
end

function ExplorePetComponent:cardPressEvent(button, index, data)
	if data.empty then
		self.ctrl.clickExploreSlotIndex = index

		self:refreshPetSelectedStatus(index)
		self:preStartFilter(button)
	else
		self.ctrl.clickExploreSlotIndex = index

		self:refreshPetSelectedStatus(index)
		self:preStartFilter(index + 1)
	end

	self:onHover(button, data.empty == true)
end

function ExplorePetComponent:getLockStatus(button)
	local temp = {}
	local _, page = button:TryGetCurrentPage("number")
	local _, page1 = button:TryGetCurrentPage("favState")
	local _, page2 = button:TryGetCurrentPage("PetChar")

	temp.isFavorite = page1 > 0
	temp.inBattle = page > 0
	temp.inExplore = page2 > 0

	return temp
end

function ExplorePetComponent:preStartFilter(button)
	local explore = type(button) == "number" and button or tonumber(string.split(button.name, "_")[2])
	local isClimb = explore == 1
	local isGlide = explore == 2
	local isSwim = explore == 3
	local isNone = explore == 4
	local allElements = self.model:getAllElementsInfo()
	local temp = {}

	for _, v in pairs(allElements) do
		temp[v.name] = v.name
	end

	self.model:setSelectSortId(8)
	self.model:setSortSwitchStatus(true)
	self.model:setFilter({
		isClimb = isClimb,
		isGlide = isGlide,
		isSwim = isSwim,
		isNone = isNone
	})
	self.ctrl.boxPets:startFilter(button)
end

function ExplorePetComponent:clearAllSelectFrames()
	local exploreButtons = self.listCharUList:GetAllButtons()

	for i = 0, exploreButtons.Length - 1 do
		exploreButtons[i]:TryChangePage("select", 0)
	end
end

function ExplorePetComponent:findSelectedFrameCursorIndex()
	local exploreButtons = self.listCharUList:GetAllButtons()

	for i = 1, exploreButtons.Length do
		local _, page = exploreButtons[i - 1]:TryGetCurrentPage("select")

		if page == 1 then
			local x = math.floor((i - 1) / 1) + 1
			local y = (i - 1) % 1 + 1

			return x, y
		end
	end

	return nil
end

function ExplorePetComponent:refreshPetSelectedStatus(index)
	local findIndex
	local buttons = self.listCharUList:GetAllButtons()

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
	self.ctrl.fightPets:selectItemIfExists(self.model.curSelectPetId)
end

function ExplorePetComponent:selectItemIfExists(petId)
	local buttons = self.listCharUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
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

function ExplorePetComponent:renderExploreSkillPoints(button, index, data)
	local objectReference1 = button:GetComponent("ObjectReference")
	local abilityListUList = objectReference1:GetRefValue("abilityListUList")
	local tempExploreLevelData = {}

	function abilityListUList.luaRenderItem(button1, _, data1)
		local objectReference2 = button1:GetComponent("ObjectReference")
		local levelUList = objectReference2:GetRefValue("levelUList")

		function levelUList.luaRenderItem(button2, _, data2)
			button2:TryChangePage("Have", data2.have)
		end

		button1:TryChangePage("PetChar", data1.type)
		button1:TryChangePage("quality", data1.quality - 1)
		button1:TryChangePage("Equip", data1.equip)

		button1.navForceNonInteractable = true

		levelUList:SetList(data1.pointNum)
	end

	local climbPointNum = {}
	local glidePointNum = {}
	local swimPointNum = {}

	for i = 1, 3 do
		climbPointNum[i] = i <= data.climbLevel and {
			have = 1
		} or {
			have = 0
		}
		glidePointNum[i] = i <= data.glideLevel and {
			have = 1
		} or {
			have = 0
		}
		swimPointNum[i] = i <= data.swimLevel and {
			have = 1
		} or {
			have = 0
		}
	end

	if index + 1 == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB and data.climbLevel ~= 0 then
		tempExploreLevelData[#tempExploreLevelData + 1] = {
			type = 1,
			equip = 1,
			quality = data.climbLevel,
			pointNum = climbPointNum
		}

		if data.glideLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 2,
				equip = 0,
				quality = data.glideLevel,
				pointNum = glidePointNum
			}
		end

		if data.swimLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 3,
				equip = 0,
				quality = data.swimLevel,
				pointNum = swimPointNum
			}
		end
	elseif index + 1 == AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE and data.glideLevel ~= 0 then
		tempExploreLevelData[#tempExploreLevelData + 1] = {
			type = 2,
			equip = 1,
			quality = data.glideLevel,
			pointNum = glidePointNum
		}

		if data.climbLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 1,
				equip = 0,
				quality = data.climbLevel,
				pointNum = climbPointNum
			}
		end

		if data.swimLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 3,
				equip = 0,
				quality = data.swimLevel,
				pointNum = swimPointNum
			}
		end
	elseif index + 1 == AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM and data.swimLevel ~= 0 then
		tempExploreLevelData[#tempExploreLevelData + 1] = {
			type = 3,
			equip = 1,
			quality = data.swimLevel,
			pointNum = swimPointNum
		}

		if data.climbLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 1,
				equip = 0,
				quality = data.climbLevel,
				pointNum = climbPointNum
			}
		end

		if data.glideLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 2,
				equip = 0,
				quality = data.glideLevel,
				pointNum = glidePointNum
			}
		end
	end

	abilityListUList:SetList(tempExploreLevelData)
end

function ExplorePetComponent:beginDrag(button, index, data)
	self.ctrl:setIsDragging(true)

	button.replicaWidget.name = button.name
	self.ctrl.draggingReplicaWidget = button.replicaWidget
	self.ctrl.draggingReplicaWidgetType = self.ctrl.DRAGGING_REPLICA_WIDGET.EXPLORE_GROUP_CARD

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
	self.ctrl:highLightExploreSlot(false, data.exploreSkillsLevel)
	self:renderExploreSkillPoints(button.replicaWidget, index, data)

	if pg.global.navMgr then
		pg.global.navMgr:SetBKeyCancelTarget(button.gameObject.transform.position)
	end
end

function ExplorePetComponent:endDrag(button, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)
	self.ctrl:highLightExploreSlot(true, nil)

	if not dropWidget then
		self.model:modifyExplorePrepareFormation(tonumber(string.split(button.name, "_")[2]), "")

		return
	end

	local dropName = dropWidget.gameObject.name

	if button.name == dropName then
		self:resetDragState()

		return
	end

	if string.find(dropName, "Explore_") then
		local index1 = tonumber(string.split(button.name, "_")[2])
		local index2 = tonumber(string.split(dropName, "_")[2])

		self:resetDragState()
		self.model:switchExplorePreparePet(index1, index2)
	else
		self.model:modifyExplorePrepareFormation(tonumber(string.split(button.name, "_")[2]), "")
	end
end

function ExplorePetComponent:clearDraggingInfo()
	self.ctrl.draggingReplicaWidget = nil

	self.ctrl:setIsDragging(false)

	self.ctrl.draggingReplicaWidgetType = nil
end

function ExplorePetComponent:onHover(button, isEmpty)
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

	if not IsNil(self.ctrl.draggingReplicaWidget) and self.ctrl.draggingReplicaWidget.name ~= button.name and (self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.PET_BOX_CARD or self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.EXPLORE_GROUP_CARD) and self:checkCurSlotExploreSkillSuitable()[tonumber(string.sub(button.name, 9))] then
		self.ctrl.draggingReplicaWidget:TryChangePage("DragState", 3)
		button:TryChangePage("DragState", 4)
		button:TryChangePage("fakeSelect", 1)
		self.ctrl:setConsoleBarState(STATE.CAN_DROP, true)
	end
end

function ExplorePetComponent:onUnHover(button)
	if not self.ctrl then
		return
	end

	local STATE = self.ctrl.CONSOLE_BAR_STATE

	self.ctrl:clearHoveredButton(self, button)
	self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, false)
	self.ctrl:setConsoleBarState(STATE.CAN_DROP, false)
	self.ctrl:setConsoleBarState(STATE.IN_EMPTY_PET_BOX, false)

	if self.ctrl.isDragging == true and not IsNil(self.ctrl.draggingReplicaWidget) and self.ctrl.draggingReplicaWidget.name ~= button.name and (self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.PET_BOX_CARD or self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.EXPLORE_GROUP_CARD) and self:checkCurSlotExploreSkillSuitable()[tonumber(string.sub(button.name, 9))] then
		self.ctrl.draggingReplicaWidget:TryChangePage("DragState", 1)
		button:TryChangePage("DragState", 0)
		button:TryChangePage("fakeSelect", 0)
	end
end

function ExplorePetComponent:resetDragState()
	local buttons = self.listCharUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		buttons[i]:TryChangePage("DragState", 0)
		buttons[i]:TryChangePage("fakeSelect", 0)
	end
end

function ExplorePetComponent:checkCurSlotExploreSkillSuitable()
	local isExplore = string.find(self.ctrl.draggingReplicaWidget.name, "Explore_") ~= nil
	local petData

	if isExplore then
		local childIndex = tonumber(string.sub(self.ctrl.draggingReplicaWidget.name, 9))
		local _, btn = self.listCharUList:TryGetChildAt(childIndex - 1)

		if btn then
			petData = btn.dataFromUList
		end
	else
		local childIndex = tonumber(self.ctrl.draggingReplicaWidget.name)

		if self.ctrl.inFilterMode then
			local _, btn = self.ctrl.boxPets.boxPetFilterList:TryGetChildAt(childIndex - 1)

			if btn then
				petData = btn.dataFromUList
			end
		else
			local btn = self.ctrl.boxPets.boxPetNewListContainers[childIndex - 1].content:GetComponent("UButton")

			if btn then
				petData = btn.dataFromUList
			end
		end
	end

	local temp = {}

	if petData then
		local exploreSkills = petData.exploreSkillsLevel

		if exploreSkills.canClimb then
			temp[1] = true
		end

		if exploreSkills.canGlide then
			temp[2] = true
		end

		if exploreSkills.canSwim then
			temp[3] = true
		end
	end

	return temp
end

function ExplorePetComponent:highLightExploreSlot(resetAll, exploreSkillsData)
	local _, page = self.view.root:TryGetCurrentPage("ListType")

	if page ~= 1 then
		return
	end

	local btns = self.listCharUList:GetAllButtons()

	if resetAll then
		for i = 0, btns.Length - 1 do
			btns[i]:TryChangePage("Disabled", 0)
		end
	else
		if not exploreSkillsData.canClimb then
			btns[0]:TryChangePage("Disabled", 1)
		end

		if not exploreSkillsData.canGlide then
			btns[1]:TryChangePage("Disabled", 1)
		end

		if not exploreSkillsData.canSwim then
			btns[2]:TryChangePage("Disabled", 1)
		end
	end
end

function ExplorePetComponent:onPetHpChanged(info)
	local exploreButtons = self.listCharUList:GetAllButtons()

	for i = 0, exploreButtons.Length - 1 do
		local objectReference = exploreButtons[i]:GetComponent("ObjectReference")
		local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
		local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
		local vxRecoverUParticle = objectReference:GetRefValue("vxRecoverUParticle")

		if info.entity.id == petIdDisplay.gameObject.name then
			hpBarUHealthbar.hp = info.entity.curHp / info.entity.maxHp

			if info.oldValue < info.newValue then
				vxRecoverUParticle:Play()
				exploreButtons[i]:InvokeCallback(CS.XGUI.EInvokeTime.User2)
			end
		end
	end
end

function ExplorePetComponent:onExplorePetRevivePercentChanged(petInfoMessageBody)
	local exploreButtons = self.listCharUList:GetAllButtons()

	for i = 0, exploreButtons.Length - 1 do
		local objectReference = exploreButtons[i]:GetComponent("ObjectReference")
		local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
		local resurrectionUWidget = objectReference:GetRefValue("resurrectionUWidget")
		local cDUCountDown = objectReference:GetRefValue("cDUCountDown")

		if petInfoMessageBody[3].id == petIdDisplay.gameObject.name then
			local pet = pg.getEntity(petInfoMessageBody[3].id)

			resurrectionUWidget.gameObject:SetActiveEx(not pet:isAlive())
			cDUCountDown:Reset(petInfoMessageBody[2], 1)

			local remainTime = pg.me:isInCombat() and (1 - petInfoMessageBody[2]) * SysConfigData.explorePetReviveTimeInCombat or (1 - petInfoMessageBody[2]) * SysConfigData.explorePetReviveTime

			cDUCountDown.formatText = math.ceil(remainTime)
		end
	end
end

function ExplorePetComponent:refreshExploreBtnByPetId(petId)
	if not self.listCharUList then
		return
	end

	local buttons = self.listCharUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local objectReference = buttons[i]:GetComponent("ObjectReference")
		local petIdDisplay = objectReference:GetRefValue("petIdDisplay")

		if petIdDisplay.gameObject.name == petId then
			self.listCharUList:RefreshElement(i)

			break
		end
	end
end

return ExplorePetComponent
