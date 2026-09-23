-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmog\\PetTransmogModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogModel = Class.LightClass("PetTransmogModel", UIModel)

PetTransmogModel.SCHEME_SOURCE = {
	CUSTOM = 1,
	PREVIEW = 2
}
PetTransmogModel.PLAN_TAB = {
	CUSTOM = 1,
	PREVIEW = 2
}
PetTransmogModel.UI_STATE = {
	HIDDEN = 2,
	PLAN = 1,
	NORMAL = 0,
	Scheme = 3
}
PetTransmogModel.BAPTIZE_STATE = {
	RESULT = 1,
	IDLE = 0,
	PURPLE_RESULT = 2
}

function PetTransmogModel:ctor()
	self.petId = nil
	self.currentTab = PetTransmogModel.PLAN_TAB.CUSTOM
	self.selectedSchemeSource = nil
	self.selectedSchemeIndex = nil
	self.uiState = PetTransmogModel.UI_STATE.NORMAL
	self.baptizeState = PetTransmogModel.BAPTIZE_STATE.IDLE
	self.lockedHoles = {}
	self.useSpecialItemFlag = false
end

function PetTransmogModel:isHoleLocked(holeIndex)
	return self.lockedHoles[holeIndex] == true
end

function PetTransmogModel:setHoleLocked(holeIndex, locked)
	if not holeIndex then
		return
	end

	self.lockedHoles[holeIndex] = locked and true or nil
end

function PetTransmogModel:getLockedHoleList()
	local list = {}

	for holeIndex in pairs(self.lockedHoles) do
		list[#list + 1] = holeIndex
	end

	table.sort(list)

	return list
end

function PetTransmogModel:getLockedHoleCount()
	local count = 0

	for _ in pairs(self.lockedHoles) do
		count = count + 1
	end

	return count
end

function PetTransmogModel:setUseSpecialItemFlag(flag)
	self.useSpecialItemFlag = flag == true
end

function PetTransmogModel:getUseSpecialItemFlag()
	return self.useSpecialItemFlag
end

function PetTransmogModel:clearLockedHoles()
	self.lockedHoles = {}
end

function PetTransmogModel:setLockedHolesFromSet(lockedSet)
	self.lockedHoles = {}

	if lockedSet then
		for holeIndex, locked in pairs(lockedSet) do
			if locked then
				self.lockedHoles[holeIndex] = true
			end
		end
	end
end

function PetTransmogModel:setUIState(s)
	self.uiState = s
end

function PetTransmogModel:getUIState()
	return self.uiState
end

function PetTransmogModel:setBaptizeState(s)
	self.baptizeState = s
end

function PetTransmogModel:getBaptizeState()
	return self.baptizeState
end

function PetTransmogModel:setPetId(petId)
	self.petId = petId
end

function PetTransmogModel:getPetId()
	return self.petId
end

function PetTransmogModel:setCurrentTab(tab)
	self.currentTab = tab
end

function PetTransmogModel:getCurrentTab()
	return self.currentTab
end

function PetTransmogModel:setSelected(source, index)
	self.selectedSchemeSource = source
	self.selectedSchemeIndex = index
end

function PetTransmogModel:getSelectedSource()
	return self.selectedSchemeSource
end

function PetTransmogModel:getSelectedIndex()
	return self.selectedSchemeIndex
end

function PetTransmogModel:getSelectedScheme()
	local list

	if self.selectedSchemeSource == PetTransmogModel.SCHEME_SOURCE.CUSTOM then
		list = self:getCustomSchemes()
	elseif self.selectedSchemeSource == PetTransmogModel.SCHEME_SOURCE.PREVIEW then
		list = self:getPreviewSchemes()
	end

	return list and list[self.selectedSchemeIndex] or nil
end

function PetTransmogModel:getCustomSchemes()
	return PetTransmogUtils.getCustomSchemes(self.petId)
end

function PetTransmogModel:getPreviewSchemes()
	return PetTransmogUtils.getPreviewSchemes(self.petId)
end

return PetTransmogModel
