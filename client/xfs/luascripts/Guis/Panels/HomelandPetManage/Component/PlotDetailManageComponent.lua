-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotDetailManageComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlotDetailManageComponent")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotDetailManageComponent = Class.LightClass("PlotDetailManageComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local ClientUtils = require("Utils.ClientUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local HomeObjectData = require("Data.home_object_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local PetTalentData = require("Data.pet_talent_data")
local PetData = require("Data.pet_data")
local HomeAbilityData = require("Data.home_ability_data")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

PlotDetailManageComponent.PetWorkMode = {
	Rest = 1,
	Work = 2
}

function PlotDetailManageComponent:findObjects()
	return
end

function PlotDetailManageComponent:initView()
	self.ornamentInfo = nil
	self.petList = {}
	self.isMaxWork = true

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPlotDetailManage(self.ornamentInfo)
	end)
end

function PlotDetailManageComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.listRecommendUList = objectReference:GetRefValue("listRecommendUList")
	self.listCharacterUList = objectReference:GetRefValue("listCharacterUList")
	self.listPetRecommendUList = objectReference:GetRefValue("listPetRecommendUList")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.elementGradeUButton = objectReference:GetRefValue("elementGradeUButton")
	self.layoutBoxUWidget = objectReference:GetRefValue("layoutBoxUWidget")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.bgImagePro = objectReference:GetRefValue("bgImagePro")
	self.txtGradeUSDFText = objectReference:GetRefValue("txtGradeUSDFText")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
end

function PlotDetailManageComponent:addListener()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("RECOMMEND"))
	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("HOMELAND_NO_PETS"))

	function self.listCharacterUList.luaRenderItem(button, _, itemData)
		local talentTemplateId = itemData.templateId

		LuaUIUtils.renderTalentItem(button, talentTemplateId)

		local objectReference = button:GetComponent("ObjectReference")
		local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

		rayBoxUWidget.gameObject:SetActiveEx(true)

		function button.luaClick()
			local talentData = {}
			local name = PetTalentData[talentTemplateId].talentName
			local icon = PetTalentData[talentTemplateId].talentIcon
			local quality = PetTalentData[talentTemplateId].rarity
			local id = talentTemplateId
			local group = PetTalentData[talentTemplateId].group
			local homeDesc = PetTalentData[talentTemplateId].homeDesc
			local breedTalent = {}

			breedTalent[#breedTalent + 1] = {
				name = name,
				icon = icon,
				quality = quality,
				id = id,
				group = group,
				homeDesc = homeDesc
			}
			talentData.targetRect = self.layoutBoxUWidget
			talentData.autoHor = true
			talentData.type = UIConst.GIFT_TYPE.HOME
			talentData.breedTalent = breedTalent
			talentData.title = pg.getGameString("HOME_PERSONALITY_RECOMMEND")

			pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS_RECOMMEND, talentData)
		end
	end

	function self.listPetRecommendUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			button.name = self.model.NULLPET_TAG .. self.model.HOME_SPLIT .. tostring(index + 1)
			button.interactable = false

			return
		end

		self:refreshPetListView(button, data)

		button.name = self.model.WORKPET_TAG .. self.model.HOME_SPLIT .. tostring(index + 1)
	end

	function self.listPetUList.luaRenderItem(button, index, data)
		local petList = {}

		if data.mode == self.PetWorkMode.Rest then
			petList = self.restPetList
		elseif data.mode == self.PetWorkMode.Work then
			petList = self.workPetList
		end

		local objectReference = button:GetComponent("ObjectReference")
		local textTextPlus = objectReference:GetRefValue("textTextPlus")
		local listPetInfoUList = objectReference:GetRefValue("listPetInfoUList")
		local iconJobUImage = objectReference:GetRefValue("iconJobUImage")

		iconJobUImage.url = data.icon

		ClientTextUtils.setText(textTextPlus, data.text)

		function listPetInfoUList.luaRenderItem(button, index, data)
			self:refreshPetListView(button, data)
		end

		listPetInfoUList:SetList(petList)
	end
end

function PlotDetailManageComponent:_bindPetItemGamepadHotkeys(button)
	if not button or not button.gameObject then
		return
	end

	local yBind = KeyBindingPro.GetOrAddKeyBindingByName(button.gameObject, "PlotDetailManage_PetItemY")

	yBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth
	yBind.isVirtual = true

	function yBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onGamepadNorthPressed()
		end

		return true
	end

	local xBind = KeyBindingPro.GetOrAddKeyBindingByName(button.gameObject, "PlotDetailManage_PetItemX")

	xBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	xBind.isVirtual = true

	function xBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onGamepadWestPressed()
		end

		return true
	end
end

function PlotDetailManageComponent:refreshPetListView(button, data)
	button.dataFromUList = data

	self:_bindPetItemGamepadHotkeys(button)

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnCancelWorkingUContainer = objectReference:GetRefValue("btnCancelWorkingUContainer")
	local iconFavUContainer = objectReference:GetRefValue("iconFavUContainer")
	local petExchangeUButton = objectReference:GetRefValue("petExchangeUButton")
	local iconWorkStateUImage = objectReference:GetRefValue("iconWorkStateUImage")
	local panelHomeworkUButton = objectReference:GetRefValue("panelHomeworkUButton")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local abilityUWidget = objectReference:GetRefValue("abilityUWidget")
	local listAbilityUList = objectReference:GetRefValue("listAbilityUList")
	local petCharUButton = objectReference:GetRefValue("petCharUButton")
	local petCharacterUWidget = objectReference:GetRefValue("petCharacterUWidget")
	local petIdRectTransform = objectReference:GetRefValue("petIdRectTransform")

	abilityUWidget:SetActive(false)

	local petInfo = pg.space.pets[data.petId]
	local renderInfo = {
		petId = petInfo.templateId,
		label = petInfo.label
	}

	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(PetData[renderInfo.petId].iconName, LuaUIUtils.PET_ICON, renderInfo.label), function()
		if iconUImage.sprite == nil then
			iconUImage.url = LuaUIUtils.getPetIcon(PetData[renderInfo.petId].iconName, LuaUIUtils.PET_ICON, 0)
		end
	end)

	button.draggable = not data.currentWork
	button.visualInteractable = not data.currentWork
	button.enabledTooltip = false

	local requireAbilityId, requireAbilityLevel = self:getRequireAbilityInfo()
	local petData = PetData[petInfo.templateId]
	local petAbilityLevel = petData.homeAbility[requireAbilityId]
	local facilityType = Utils.getHomeFacilityType(self.ornamentInfo.homeId)
	local facilityInfo = pg.space.facility[self.ornamentInfo.ornamentId]

	LuaUIUtils.renderHomeAbility(petCharUButton, requireAbilityId, petAbilityLevel)

	if requireAbilityLevel <= petAbilityLevel then
		petCharUButton:TryChangePage("Condition", 1)
	else
		petCharUButton:TryChangePage("Condition", 0)
	end

	local workRate = Utils.calcWorkRate(facilityType, data.opId, data.workload, facilityInfo.formulaId)

	if workRate then
		button:TryChangePage("Reason", 1)
		panelHomeworkUButton:TryChangePage("WorkRatio", workRate >= 1 and 1 or 2)
		ClientTextUtils.setText(numUSDFText, string.format("%s%%", math.floor(workRate * 100)))
	else
		ClientTextUtils.setText(numUSDFText, "0%")
		panelHomeworkUButton:TryChangePage("WorkRatio", 0)
	end

	if data.fitPersonality and data.fitPersonality ~= 0 then
		petCharacterUWidget:SetActive(true)
		LuaUIUtils.renderTalentItem(petExchangeUButton, data.fitPersonality)
	else
		petCharacterUWidget:SetActive(false)
	end

	iconWorkStateUImage:SetActive(data.isWork)
	btnCancelWorkingUContainer:SetActive(data.currentWork)

	function btnCancelWorkingUContainer.content.luaClick()
		pg.me.space:deallocateHomePetWork(data.petId, nil, true)
	end

	function button.luaClick()
		if data.currentWork or self.isMaxWork then
			return
		end

		self:setWorkNewPet(data)
	end

	function button.luaEndDrag(dropWidget, pointerWidget)
		if data.currentWork then
			return
		end

		self:dragWorkOrRestPetEnd(data, dropWidget)
	end
end

function PlotDetailManageComponent:onGamepadNorthPressed()
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance
	local navItem = navMgr and navMgr.CurrentFocusedUContent

	if not navItem then
		return
	end

	local data = navItem.dataFromUList

	if not data or data.tIndex == 1 or not data.petId then
		return
	end

	if data.currentWork then
		pg.me.space:deallocateHomePetWork(data.petId, nil, true)
	elseif self.isMaxWork then
		local evictSlot = self:_findFirstWorkSlot()

		if evictSlot and evictSlot.petId then
			self:setWorkNewPet(data, function()
				pg.me.space:deallocateHomePetWork(evictSlot.petId, nil, true)
			end)
		end
	else
		self:setWorkNewPet(data)
	end
end

function PlotDetailManageComponent:onGamepadWestPressed()
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	self:trySetDefaultFocus()
end

function PlotDetailManageComponent:_findFirstWorkSlot()
	if not self.petList then
		return nil
	end

	for _, slot in ipairs(self.petList) do
		if slot.tIndex == 0 and slot.petId then
			return slot
		end
	end

	return nil
end

function PlotDetailManageComponent:trySetDefaultFocus()
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	if not self.listPetRecommendUList then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	if self.petList then
		for idx, slot in ipairs(self.petList) do
			if slot.tIndex == 0 and slot.petId then
				local ok, btn = self.listPetRecommendUList:TryGetChildAt(idx - 1)

				if ok and btn then
					navMgr:FocusItem(btn)

					return
				end
			end
		end
	end
end

function PlotDetailManageComponent:setWorkNewPet(data, func)
	if data.isWork then
		ClientUtils.showConfirmRaw(pg.getGameString("HOMELAND_PLOT_WORKPET_CONFIRM_TITLE"), pg.getGameString("HOMELAND_PLOT_WORKPET_CONFIRM_DESC"), function()
			if func then
				func()
			end

			pg.space:allocateHomePetWork(data.petId, self.ornamentInfo.ornamentId, Const.HOMELAND_FACILITY_OP_TYPE.MOVING, true)
		end)
	else
		if func then
			func()
		end

		pg.space:allocateHomePetWork(data.petId, self.ornamentInfo.ornamentId, Const.HOMELAND_FACILITY_OP_TYPE.MOVING, true)
	end
end

function PlotDetailManageComponent:dragWorkOrRestPetEnd(petInfo, dropWidget)
	local petId = petInfo.petId

	if not petId or not dropWidget then
		return
	end

	local targetName = dropWidget.gameObject.name
	local info = string.split(targetName, self.model.HOME_SPLIT) or {}

	if info[1] == self.model.WORKPET_TAG then
		local index = tonumber(info[2])
		local workPetData = self.petList[index]

		if workPetData then
			self:setWorkNewPet(petInfo, function()
				if workPetData.tIndex == 0 and workPetData.petId then
					pg.me.space:deallocateHomePetWork(workPetData.petId, nil, true)
				end
			end)
		end
	elseif info[1] == self.model.NULLPET_TAG then
		local index = tonumber(info[2])
		local workPetData = self.petList[index]

		if workPetData and workPetData.tIndex == 1 then
			self:setWorkNewPet(petInfo)
		end
	end
end

function PlotDetailManageComponent:refreshPlotDetailManage(ornamentInfo)
	if not ornamentInfo then
		return
	end

	local lastOrnamentId = self.ornamentInfo and self.ornamentInfo.ornamentId

	self.ornamentInfo = ornamentInfo

	if not self.uWidget:CheckURLLoaded() then
		return
	end

	local facilityInfo = pg.me.space.facility[ornamentInfo.ornamentId]

	if not self.model:canHomeObjectPlacePet(ornamentInfo.homeId, facilityInfo) then
		return
	end

	self:refreshAccessAndAbility()
	self:refreshPetWorkList()
	self:refreshHomelandPetList()

	local petListBoxInfo = self:getPetListBoxInfo()

	self.emptyUWidget:SetActive(false)
	self.listPetUList:SetActive(false)

	if #petListBoxInfo > 0 then
		self.listPetUList:SetActive(true)
		self.listPetUList:SetList(petListBoxInfo)
	else
		self.emptyUWidget:SetActive(true)
	end

	if lastOrnamentId ~= ornamentInfo.ornamentId then
		if self.focusTimer then
			TimerManager.removeTimer(self.focusTimer)

			self.focusTimer = nil
		end

		self.focusTimer = TimerManager.addNextFrameCb(function()
			self.focusTimer = nil

			self:trySetDefaultFocus()
		end)
	end
end

function PlotDetailManageComponent:getPetListBoxInfo()
	local res = {}

	if self.restPetList and #self.restPetList > 0 then
		table.insert(res, {
			icon = "$UI_Home_ToplogoState_Sleep.png",
			text = pg.getGameString("HOMELAND_PLOT_REST"),
			mode = self.PetWorkMode.Rest
		})
	end

	if self.workPetList and #self.workPetList > 0 then
		table.insert(res, {
			icon = "$UI_Home_TopLogoState_Hammer.png",
			text = pg.getGameString("HOME_FACILITY_WORKING"),
			mode = self.PetWorkMode.Work
		})
	end

	return res
end

function PlotDetailManageComponent:refreshHomelandPetList()
	if not self.ornamentInfo then
		return
	end

	local workPetList = {}
	local restPetList = {}

	for petId, pet in pairs(pg.space.pets) do
		if pet and HomeLandUtils.isHomePetInProduceArea(pg.space, petId) then
			local pdd = PetData[pet.templateId] or {}
			local requireAbilityId, requireAbilityLevel = self:getRequireAbilityInfo()
			local petAbilityLv = pdd.homeAbility[requireAbilityId] or 0

			if petAbilityLv > 0 then
				local facilityInfo = pg.space.facility[self.ornamentInfo.ornamentId]
				local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)
				local petByMe = pg.me.pets[petId]
				local workload = Utils.calcHomePetTimeWorkload(petByMe, facilityInfo.facilityState, facilityId, pg.space:checkHomePetHasFood())
				local fitPersonality = Utils.getHomePetFitPersonality(petByMe, facilityId)
				local petInfo = {
					petId = petId,
					opId = facilityInfo.facilityState,
					workload = workload,
					fitPersonality = fitPersonality
				}
				local petStateValid = Utils.checkHomePetStateValid(pet, pg.space)
				local allocationInfo = pg.space.allocation[petId]
				local operInfo = HomelandOperateData[facilityInfo.facilityState]

				if not petStateValid then
					-- block empty
				elseif allocationInfo and not Const.HOMELAND_IGNORE_WORK_TYPE[allocationInfo.opId] then
					petInfo.isWork = true

					if allocationInfo.ornamentId ~= self.ornamentInfo.ornamentId and Utils.checkHomePetCanDoOperId(pet.templateId, facilityInfo.facilityState) then
						table.insert(workPetList, petInfo)
					end
				else
					petInfo.isWork = false

					if Utils.checkHomePetCanDoOperId(pet.templateId, facilityInfo.facilityState) then
						table.insert(restPetList, petInfo)
					end
				end
			end
		end
	end

	self.workPetList = workPetList
	self.restPetList = restPetList
end

function PlotDetailManageComponent:refreshPetWorkList()
	if not self.ornamentInfo then
		return
	end

	local relatedPets = pg.space.facilityAllocationInfo[self.ornamentInfo.ornamentId]
	local facilityInfo = pg.space.facility[self.ornamentInfo.ornamentId]
	local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)

	table.clear(self.petList)

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.space.allocation[petId]

			if not Const.HOMELAND_IGNORE_WORK_TYPE[allocation.opId] then
				local petInfo = pg.space.pets[petId]
				local petByMe = pg.me.pets[petId]
				local workload = Utils.calcHomePetTimeWorkload(petByMe, facilityInfo.facilityState, facilityId, pg.space:checkHomePetHasFood())
				local fitPersonality = Utils.getHomePetFitPersonality(petByMe, facilityId)

				table.insert(self.petList, {
					isWork = true,
					tIndex = 0,
					currentWork = true,
					petId = petId,
					opId = allocation.opId,
					workload = allocation.workload,
					fitPersonality = allocation.fitTalent
				})
			end
		end
	end

	local homeEntInfo = HomeObjectData[self.ornamentInfo.homeId] or {}
	local maxPetCount = homeEntInfo.maxPetCount or 0
	local curCount = #self.petList

	self.isMaxWork = #self.petList == maxPetCount

	for i = curCount + 1, maxPetCount do
		table.insert(self.petList, {
			tIndex = 1
		})
	end

	self.listPetRecommendUList:SetList(self.petList)
end

function PlotDetailManageComponent:refreshAccessAndAbility()
	local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)
	local hasAccessRecommend = false

	if not facilityId then
		self.listCharacterUList:SetList({})
	else
		local facilityInfo = HomelandFacilityData[facilityId] or {}

		if facilityInfo.personalityDes then
			hasAccessRecommend = true

			local personalityList = {}

			table.insert(personalityList, {
				templateId = facilityInfo.personalityDes
			})
			self.listCharacterUList:SetList(personalityList)
		else
			self.listCharacterUList:SetList({})
		end
	end

	local hasAbilityRecommend = false
	local requireAbilityId, petAbilityLevel = self:getRequireAbilityInfo()

	if requireAbilityId and petAbilityLevel then
		local homeAbilityData = HomeAbilityData[requireAbilityId]

		if not homeAbilityData then
			self.elementGradeUButton:SetActive(false)
		else
			self.elementGradeUButton:SetActive(true)

			hasAbilityRecommend = true

			ClientTextUtils.setText(self.txtGradeUSDFText, "L" .. petAbilityLevel)

			self.iconUImage.url = homeAbilityData.icon

			self.bgImagePro:SetColorWithHtmlString(homeAbilityData.iconColor)
		end
	else
		self.elementGradeUButton:SetActive(false)
	end

	self.elementGradeUButton.interactable = false

	self.textUSDFText:SetActive(hasAbilityRecommend or hasAccessRecommend)
end

function PlotDetailManageComponent:getRequireAbilityInfo()
	if not self.ornamentInfo then
		return
	end

	local facilityInfo = pg.space.facility[self.ornamentInfo.ornamentId]

	if not facilityInfo then
		return nil
	end

	return Utils.getHomePetTimeWorkloadAbilityLevel(facilityInfo.facilityState)
end

function PlotDetailManageComponent:onDestroy()
	if self.focusTimer then
		TimerManager.removeTimer(self.focusTimer)

		self.focusTimer = nil
	end

	self.petList = {}
	self.isMaxWork = true

	UIComponent.onDestroy(self)
end

function PlotDetailManageComponent:onEnterPage()
	return
end

return PlotDetailManageComponent
