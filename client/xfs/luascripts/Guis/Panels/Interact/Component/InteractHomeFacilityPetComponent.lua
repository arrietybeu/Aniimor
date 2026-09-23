-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Interact\\Component\\InteractHomeFacilityPetComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local InteractHomeFacilityPetComponent = Class.LightClass("InteractHomeFacilityPetComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

function InteractHomeFacilityPetComponent:findObjects()
	self.listPet = self.view.interactionNewUWidget.transform:GetComponent("ObjectReference"):GetRefValue("listPetNewUList")
end

function InteractHomeFacilityPetComponent:initView()
	function self.listPet.luaRenderItem(button, index, data)
		self:renderInteractionPetList(button, index, data)

		if data.btnHierarchyName then
			button.gameObject.name = data.btnHierarchyName
		end
	end

	self:show()
end

function InteractHomeFacilityPetComponent:renderInteractionPetList(button, index, data)
	local dispatchState

	if data.isMoving then
		dispatchState = UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching
	end

	LuaUIUtils.renderHomePetHead(button, data, dispatchState, {
		closeAbility = true
	})

	button.draggable = false
	button.interactable = false
end

function InteractHomeFacilityPetComponent:refreshPetList()
	if not pg.game.interaction.curChooseEntId then
		self.listPet:SetActive(false)

		self.petList = {}

		return
	end

	self.curHomeFacilityEntity = pg.getEntity(pg.game.interaction.curChooseEntId)
	self.petList = {}

	if not self.curHomeFacilityEntity then
		self.listPet:SetActive(false)

		return
	end

	if not pg.me or not pg.me.space or not pg.me.space.facilityAllocationInfo then
		self.listPet:SetActive(false)

		return
	end

	local ornamentId = self.curHomeFacilityEntity.ornamentId
	local relatedPets = pg.me.space.facilityAllocationInfo[ornamentId]

	if relatedPets then
		for k, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]
			local petRawInfo = pg.me.space.pets[petId]

			if petRawInfo then
				local petInfo = LuaUIUtils.generateHomePetInfoByPetInfo(petRawInfo)

				petInfo.isMoving = Const.HOMELAND_FACILITY_OP_TYPE.MOVING == allocation.opId or Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT == allocation.opId
				petInfo.btnHierarchyName = "UI_Node_Interaction_Pet_" .. k

				if allocation.opId > 0 then
					table.insert(self.petList, petInfo)
				end
			end
		end

		self.listPet:SetList(self.petList)
	else
		self.petList = {}
	end

	self.listPet.ScrollType = CS.XGUI.EScrollType.Vertical

	if not pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self.listPet.EnableDrag = false
	end

	self.listPet:SetActive(#self.petList > 0 and true or false)
end

function InteractHomeFacilityPetComponent:onFacilityAllocateChanged()
	self:refreshPetList()
end

return InteractHomeFacilityPetComponent
