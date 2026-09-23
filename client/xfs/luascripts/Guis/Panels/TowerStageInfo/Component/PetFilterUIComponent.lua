-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerStageInfo\\Component\\PetFilterUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PetFilterUIComponent = Class.LightClass("PetFilterUIComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetFilterUIComponent:findObjects()
	self.btnLeftUButton = self.view.btnLeftUButton
	self.btnRightUButton = self.view.btnRightUButton
	self.btnFilterUButton = self.view.btnFilterUButton
	self.btnFilter1UButton = self.view.btnFilter1UButton
	self.btnCleanFilterUButton = self.view.btnCleanFilterUButton
	self.selectorUSelector = self.view.selectorUSelector
	self.listPetUList = self.view.listPetUList
	self.pbFilterTransform = self.view.pbFilterTransform
	self.pbFilter1Transform = self.view.pbFilter1Transform
end

function PetFilterUIComponent:initView()
	self:addListener()

	self.boxId = pg.me.petBoxMap.curIndex

	self:refreshBoxSelector()
end

function PetFilterUIComponent:addListener()
	function self.btnLeftUButton.luaClick()
		self:switchBoxPages(true)
	end

	function self.btnRightUButton.luaClick()
		self:switchBoxPages(false)
	end

	function self.btnFilterUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
			doFilterCallback = function()
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_STAGE_INFO) then
					self:startFilter()
				end
			end
		})
	end

	function self.btnFilter1UButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
			doFilterCallback = function()
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_STAGE_INFO) then
					self:startFilter()
				end
			end
		})
	end

	function self.btnCleanFilterUButton.luaClick()
		self:endFilter()
	end
end

function PetFilterUIComponent:switchBoxToIdx(index)
	self.boxId = index

	self:refreshPetBox(self.boxId)
	self:refreshBoxSelector()
end

function PetFilterUIComponent:getIndexOfSelectedBoxIdInSequence()
	local petBoxMapSequence = pg.me.petBoxMap.sequence:getRawTable()
	local boxId = self.boxId or pg.me.petBoxMap.curIndex
	local indexOfSequence

	for i = 1, #petBoxMapSequence do
		if boxId == petBoxMapSequence[i] then
			indexOfSequence = i

			return petBoxMapSequence, indexOfSequence
		end
	end

	return petBoxMapSequence, indexOfSequence
end

function PetFilterUIComponent:switchBoxPages(isPre)
	if self.ctrl.inFilterMode then
		return
	end

	local sequence, indexOfSequence = self:getIndexOfSelectedBoxIdInSequence()

	if not indexOfSequence then
		return
	end

	local index = isPre and indexOfSequence - 1 or indexOfSequence + 1

	if index < 1 then
		index = #sequence
	end

	if index > #sequence then
		index = 1
	end

	self:switchBoxToIdx(sequence[index])
end

function PetFilterUIComponent:refreshBoxSelector()
	local petBoxMap = pg.me.petBoxMap
	local boxInfos = pg.global.ui.petManagement.model:getBoxInfos()
	local selectBoxId = self.boxId or pg.me.petBoxMap.curIndex
	local objRef = self.selectorUSelector:GetComponent("ObjectReference")
	local boxName = objRef:GetRefValue("boxName")
	local lockUButton = objRef:GetRefValue("lockUButton")
	local txtNameUText = objRef:GetRefValue("txtNameUText")
	local customName = petBoxMap[selectBoxId].customName
	local count = petBoxMap[selectBoxId].count
	local slotCount = petBoxMap[selectBoxId].slotCount
	local lockStatus = petBoxMap[selectBoxId]:isLocked()
	local countStr = string.format("(%d/%d)", count, slotCount)
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = string.format("%s %s", customName, countStr)
	else
		boxNameContent = string.format("%s %s %s", pg.getGameString("DEFAULT_PET_BOX_NAME"), selectBoxId, countStr)
	end

	ClientTextUtils.setText(boxName, boxNameContent)
	ClientTextUtils.setText(txtNameUText, boxNameContent)
	lockUButton:TryChangePage("Lock", lockStatus and 1 or 0)

	function self.selectorUSelector.luaRenderPopup(popup, list)
		self.boxSelectorTempList = list

		local objectReference1 = popup:GetComponent("ObjectReference")
		local boxNameUText = objectReference1:GetRefValue("boxNameUText")

		LuaUIUtils.setUIViewVisible(objectReference1:GetRefValue("btnEditUButton"), false)
		ClientTextUtils.setText(boxNameUText, boxNameContent)

		function list.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local numUText = objectReference:GetRefValue("numUText")
			local nameUText = objectReference:GetRefValue("nameUText")
			local lockUButton1 = objectReference:GetRefValue("lockUButton1")
			local btnEditUButton = objectReference:GetRefValue("btnEditUButton")

			lockUButton1:TryChangePage("Lock", petBoxMap[data.idx]:isLocked() and 1 or 0)
			ClientTextUtils.setText(numUText, data.countNum)

			if data.customName and data.customName ~= "" then
				ClientTextUtils.setText(nameUText, data.customName)
			else
				ClientTextUtils.setText(nameUText, pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.idx)
			end

			function button.luaClick()
				self:switchBoxToIdx(data.idx)
			end

			LuaUIUtils.setUIViewVisible(lockUButton1, false)
			LuaUIUtils.setUIViewVisible(btnEditUButton, false)
		end

		function list.luaFinishRender(subList)
			local btns = subList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i]:TryChangePage("select", btns[i].dataFromUList.idx == selectBoxId and 1 or 0)
			end
		end

		list:SetList(boxInfos)
	end

	self.selectorUSelector:SetOptions(boxInfos)

	if self.selectorUSelector.isPopup then
		self:refreshLockStatusWhenPopup()
	end
end

function PetFilterUIComponent:refreshLockStatusWhenPopup()
	if self.boxSelectorTempList == nil then
		return
	end

	local petBoxMap = pg.me.petBoxMap
	local btns = self.boxSelectorTempList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local objectReference = btns[i]:GetComponent("ObjectReference")
		local lockUButton1 = objectReference:GetRefValue("lockUButton1")

		lockUButton1:TryChangePage("Lock", petBoxMap[btns[i].dataFromUList.idx]:isLocked() and 1 or 0)
	end
end

function PetFilterUIComponent:getPetIdByBoxId(boxId)
	local petInfos = pg.global.ui.petManagement.model:getBoxInfoById(boxId)

	return petInfos
end

function PetFilterUIComponent:getFilteredPetsInfo()
	local petInfos = pg.global.ui.petManagement.model:getFilteredPetsInfo()

	return petInfos
end

function PetFilterUIComponent:filterEmpty(petInfos)
	local res = {}

	for _, petInfo in ipairs(petInfos) do
		if not petInfo.isEmpty then
			table.insert(res, petInfo)
		end
	end

	return res
end

function PetFilterUIComponent:refreshPetBox(boxId)
	self.listPetUList:SetList(self:getPetIdByBoxId(boxId))
end

function PetFilterUIComponent:startFilter()
	LuaUIUtils.setUIViewVisible(self.pbFilterTransform, false)
	LuaUIUtils.setUIViewVisible(self.pbFilter1Transform, true)
	self.listPetUList:SetList(self:getFilteredPetsInfo())
end

function PetFilterUIComponent:endFilter()
	LuaUIUtils.setUIViewVisible(self.pbFilterTransform, true)
	LuaUIUtils.setUIViewVisible(self.pbFilter1Transform, false)
	pg.global.ui.petManagement.model:setSelectSortId(0)
	self:refreshPetBox(self.boxId)
end

return PetFilterUIComponent
