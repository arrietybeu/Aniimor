-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilitySelectPet\\HomelandFacilitySelectPetCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local Const = require("Common.Const.Const")
local HomeObjectData = require("Data.home_object_data")
local HomelandFacilitySelectPetCtrl = Class.LightClass("HomelandFacilitySelectPetCtrl", UICtrl)

function HomelandFacilitySelectPetCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function HomelandFacilitySelectPetCtrl:onCreate(info)
	HomelandFacilitySelectPetCtrl.super.onCreate(self, info)

	self.view = self.view
end

function HomelandFacilitySelectPetCtrl:onOpen(info)
	HomelandFacilitySelectPetCtrl.super.onOpen(self, info)

	self.ornamentId = info.ornamentId
	self.homeTemplateId = info.homeTemplateId
	self.petListVisible = false

	self:initUI()
end

function HomelandFacilitySelectPetCtrl:getFacilityInfo()
	return pg.me.space.facility[self.ornamentId]
end

function HomelandFacilitySelectPetCtrl:onDestroy()
	self.selectedPetId = nil

	PetManagementUtils.destroyTemplate()
	UICtrl.onDestroy(self)
end

function HomelandFacilitySelectPetCtrl:addListener()
	function self.view.okBtn.luaClick()
		self:onOkBtnClick()
	end

	function self.view.backBtn.luaClick()
		self:close()
	end

	function self.view.allocateList.luaRenderItem(button, index, data)
		self:renderAllocateItem(button, index, data)
	end
end

function HomelandFacilitySelectPetCtrl:initUI()
	PetManagementUtils.setListButtonDelegateTable({
		luaPress = function(button, index, data)
			self:selectPet(data.id)
		end,
		renderExtraLogic = function(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local addonUComponent = objectReference:GetRefValue("addonUComponent")

			addonUComponent:SetActive(false)
		end
	})
	PetManagementUtils.initTemplate(self.view.petInfoPanelTransform, self.view.petListTransform, {
		isFromHome = true,
		ignoreDisableMainCamera = true,
		hideUIScene = true
	})
	self:refreshFacilityInfo()
	self:selectPet(nil)
end

function HomelandFacilitySelectPetCtrl:refreshFacilityInfo()
	self.requireType, self.requireAbility, self.requireLevel = self:getRequireAbilityType()

	self:updatePetListVisible()
end

function HomelandFacilitySelectPetCtrl:updatePetListVisible()
	local petListVisible = false
	local facilityInfo = self:getFacilityInfo()

	if facilityInfo and (facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV) then
		petListVisible = true
	end

	self.petListVisible = petListVisible

	self.view.listPet:SetActive(petListVisible)
end

function HomelandFacilitySelectPetCtrl:refreshPetList()
	self:updatePetListVisible()

	if not self.petListVisible then
		return
	end

	local relatedPets = pg.space.facilityAllocationInfo[self.ornamentId]

	table.clear(self.petList)

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]

			if not Const.HOMELAND_IGNORE_WORK_TYPE[allocation.opId] then
				table.insert(self.petList, {
					isEmpty = false,
					petId = petId,
					opId = allocation.opId
				})
			end
		end
	end

	local homeEntInfo = HomeObjectData[self.homeTemplateId] or {}
	local maxPetCount = homeEntInfo.maxPetCount or 0
	local curCount = #self.petList

	for i = curCount + 1, maxPetCount do
		table.insert(self.petList, {
			isEmpty = true
		})
	end

	self.view.listPet:SetList(self.petList)
end

function HomelandFacilitySelectPetCtrl:selectPet(petId)
	self.selectedPetId = petId
end

function HomelandFacilitySelectPetCtrl:onOkBtnClick()
	pg.me.space:allocateHomePetWork(self.selectedPetId, self.ornamentId, Const.HOMELAND_FACILITY_OP_TYPE.MOVING)
end

function HomelandFacilitySelectPetCtrl:cancelPetWork(petId)
	pg.me.space:deallocateHomePetWork(petId, self.ornamentId)
end

function HomelandFacilitySelectPetCtrl:getRequireAbilityType()
	local facilityInfo = self:getFacilityInfo()
	local opId = facilityInfo.facilityState
	local requireType, abilityId, abilityLevel = Utils.getOperationRequireOpType(opId)

	return requireType, abilityId, abilityLevel
end

function HomelandFacilitySelectPetCtrl:renderAbilityIcon(iconItem, requireType, abilityId, abilityLevel)
	if requireType == Const.HOME_OPER_REQUIRE_TYPE.None or not abilityLevel or abilityLevel <= 0 then
		iconItem:SetActive(false)

		return true
	end

	iconItem:SetActive(true)

	if requireType == Const.HOME_OPER_REQUIRE_TYPE.Ability then
		-- block empty
	end
end

function HomelandFacilitySelectPetCtrl:renderAllocateItem(button, index, data)
	if data.isEmpty then
		button:TryChangePage("empty", 1)

		return
	end

	button:TryChangePage("empty", 0)

	local petInfo = pg.me:getPetInfo(data.petId)

	LuaUIUtils.renderPetSlotBarItem(button, petInfo)

	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local homeChar = objectReference:GetRefValue("homeChar")
	local panelWorkload = objectReference:GetRefValue("panelWorkload")

	function btnDelUButton.luaClick()
		self:cancelPetWork(data.petId)
	end
end

return HomelandFacilitySelectPetCtrl
