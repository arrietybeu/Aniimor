-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\PetAccessoryEditComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Utils = require("Common.Utils.Utils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local PetAccessoryEditComponent = Class.LightClass("PetAccessoryEditComponent", UIComponent)
local OPERATION_CONFIG = {
	operations = {
		{
			displayName = 55295756,
			subOps = {
				{
					opName = 1,
					displayName = 59381762,
					tIndex = 0
				},
				{
					opName = 2,
					displayName = 56026640,
					tIndex = 0
				},
				{
					opName = 3,
					displayName = 47151758,
					tIndex = 0
				}
			}
		},
		{
			displayName = 41352984,
			subOps = {
				{
					opName = 5,
					displayName = 57605298,
					tIndex = 0
				},
				{
					opName = 6,
					displayName = 35417729,
					tIndex = 0
				},
				{
					opName = 7,
					displayName = 41352984,
					tIndex = 0
				}
			}
		},
		{
			displayName = 65641329,
			subOps = {
				{
					opName = 8,
					displayName = 65641329,
					tIndex = 0
				}
			}
		}
	}
}

function PetAccessoryEditComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.editRootUComponent = self.objectReference:GetRefValue("editRootUComponent")
	self.operationUList = self.objectReference:GetRefValue("operationUList")
	self.btnUndoUButton = self.objectReference:GetRefValue("btnUndoUButton")
	self.btnRedoUButton = self.objectReference:GetRefValue("btnRedoUButton")
	self.btnEditResetUButton = self.objectReference:GetRefValue("btnEditResetUButton")
end

function PetAccessoryEditComponent:initView()
	self.avatarComponent = self.ctrl and self.ctrl.avatarComponent
	self.selectedPetAccessoryId = nil
	self.selectedGenId = nil
	self.selectedSlotIdx = 1
	self.editing = false
	self.sliderInfo = nil
	self.operationData = {}
	self.cacheOperationData = {}
	self.instanceId = nil

	if self.editRootUComponent then
		self.editRootUComponent:TryChangePage("state", 0)
	end
end

function PetAccessoryEditComponent:_ensureBindings()
	if self._bindingsReady then
		return
	end

	self._bindingsReady = true

	self:addListener()
end

function PetAccessoryEditComponent:addListener()
	if self.operationUList then
		function self.operationUList.luaRenderItem(button, _, data)
			AvatarUtils.renderOperationCollection(button, data, function(contentButton, _, contentData)
				self:_renderSliderItem(contentButton, contentData)
			end)
		end
	end

	if self.btnUndoUButton then
		function self.btnUndoUButton.luaClick()
			self:undo()
		end
	end

	if self.btnRedoUButton then
		function self.btnRedoUButton.luaClick()
			self:redo()
		end
	end

	if self.btnEditResetUButton then
		function self.btnEditResetUButton.luaClick()
			self:resetToPreset()
		end
	end
end

function PetAccessoryEditComponent:removeListener()
	if self.operationUList then
		self.operationUList.luaRenderItem = nil
	end

	if self.btnUndoUButton then
		self.btnUndoUButton.luaClick = nil
	end

	if self.btnRedoUButton then
		self.btnRedoUButton.luaClick = nil
	end

	if self.btnEditResetUButton then
		self.btnEditResetUButton.luaClick = nil
	end
end

function PetAccessoryEditComponent:deactivateBindings()
	self:removeListener()

	self._bindingsReady = nil
end

function PetAccessoryEditComponent:setSelectedPetAccessory(accessoryId, genId, slotIdx)
	self.selectedPetAccessoryId = accessoryId
	self.selectedGenId = genId
	self.selectedSlotIdx = slotIdx or 1
end

function PetAccessoryEditComponent:hasSelectedPetAccessory()
	return self.selectedPetAccessoryId ~= nil
end

function PetAccessoryEditComponent:showAdjustPanel(accessoryId, genId, slotIdx)
	self:_ensureBindings()

	if self.ctrl and self.ctrl.view and self.ctrl.view.rootUComponent then
		self.ctrl.view.rootUComponent:TryChangePage("showAdjust", 1)
	end

	if self.editRootUComponent then
		self.editRootUComponent:TryChangePage("state", 1)
	end

	accessoryId = accessoryId or self.selectedPetAccessoryId
	genId = genId or self.selectedGenId
	slotIdx = slotIdx or self.selectedSlotIdx

	if not accessoryId then
		self:clearOperationList()

		return false
	end

	local ok = self:beginEdit(accessoryId, genId, slotIdx)

	if ok and self.operationUList then
		self.operationUList:SetList(Utils.deepCopyTable(OPERATION_CONFIG.operations))
	elseif self.operationUList then
		self.operationUList:SetList({})
	end

	self:refreshButtonState()

	return ok
end

function PetAccessoryEditComponent:hideAdjustPanel()
	if self.ctrl and self.ctrl.view and self.ctrl.view.rootUComponent then
		self.ctrl.view.rootUComponent:TryChangePage("showAdjust", 0)
	end
end

function PetAccessoryEditComponent:clearOperationList()
	if self.operationUList then
		self.operationUList:SetList({})
	end
end

function PetAccessoryEditComponent:resetEditContext()
	self.editing = false
	self._undoStack = {}
	self._redoStack = {}

	self:clearOperationList()
end

function PetAccessoryEditComponent:beginEdit(accessoryId, genId, slotIdx)
	if not self.avatarComponent or not self.avatarComponent.avatarScene then
		return false
	end

	local entity = self.avatarComponent.avatarScene:getCurEntity()

	if not entity or not entity.eModel or not entity.eModel.modelView then
		return false
	end

	slotIdx = slotIdx or 1
	self.selectedSlotIdx = slotIdx
	self.selectedPetAccessoryId = accessoryId
	self.selectedGenId = genId
	self.instanceId = string.format("%d_%d", slotIdx, accessoryId)

	if self.avatarComponent.equipPetAccessory then
		self.avatarComponent:equipPetAccessory(accessoryId)
	end

	local petInfo = pg.me:getPetInfo(self.avatarComponent.curPetId or 0)
	local petHeight = petInfo and petInfo.height or 1
	local petScale = petInfo and petInfo.scale or 1
	local petSizeLevel = petInfo and petInfo.sizeLevel

	self.sliderInfo = AvatarUtils.generatePetJewelrySlider(petHeight, petScale, 1.5, petSizeLevel)
	self.editing = true
	self._undoStack = {}
	self._redoStack = {}

	local modelView = entity.eModel.modelView
	local expectedInstanceId = self.instanceId

	local function finishInit()
		if self.instanceId ~= expectedInstanceId then
			return
		end

		local attachInfo = self.avatarComponent:buildPetAttachInfo(accessoryId, slotIdx)
		local op = AvatarUtils.loadPetOperationFromAttach(modelView, self.instanceId, attachInfo, self.sliderInfo)

		self.operationData = {
			curOffset = Vector3.New(op.curOffset.x, op.curOffset.y, op.curOffset.z),
			curRotate = Vector3.New(op.curRotate.x, op.curRotate.y, op.curRotate.z),
			curScale = op.curScale,
			attachBone = op.attachBone,
			resId = op.resId
		}
		self.cacheOperationData = {
			curOffset = Vector3.New(self.operationData.curOffset.x, self.operationData.curOffset.y, self.operationData.curOffset.z),
			curRotate = Vector3.New(self.operationData.curRotate.x, self.operationData.curRotate.y, self.operationData.curRotate.z),
			curScale = self.operationData.curScale,
			attachBone = self.operationData.attachBone,
			resId = self.operationData.resId
		}

		if self.operationUList then
			self.operationUList:RefreshList()
		end
	end

	finishInit()

	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.addNextFrameCb(finishInit)

	return true
end

function PetAccessoryEditComponent:_renderSliderItem(button, data)
	local min, max, cur = self:_parseSliderInfoWithOpName(data)

	data.minValue = min
	data.maxValue = max

	AvatarUtils.renderSlider(button, data, cur, function(value)
		local newValue = AvatarUtils.parseSliderMapValue(data.oldMin, data.oldMax, data.newMin, data.newMax, value, true)

		self:_setAccessTransWithOpName(newValue, data.opName)
		self:_applyOperationToModel()
	end, function()
		self:_pushUndo()
		self:refreshButtonState()
	end)
end

function PetAccessoryEditComponent:_parseSliderInfoWithOpName(data)
	local opName = data.opName
	local info = self.sliderInfo
	local min, max, cur = 0, 0, 0

	if opName == 1 then
		cur = self.operationData.curOffset.x
		min = info.minOffset.x
		max = info.maxOffset.x
	elseif opName == 2 then
		cur = self.operationData.curOffset.y
		min = info.minOffset.y
		max = info.maxOffset.y
	elseif opName == 3 then
		cur = self.operationData.curOffset.z
		min = info.minOffset.z
		max = info.maxOffset.z
	elseif opName == 5 then
		cur = self.operationData.curRotate.x
		min = -info.mapRotLength
		max = info.mapRotLength
	elseif opName == 6 then
		cur = self.operationData.curRotate.y
		min = -info.mapRotLength
		max = info.mapRotLength
	elseif opName == 7 then
		cur = self.operationData.curRotate.z
		min = -info.mapRotLength
		max = info.mapRotLength
	elseif opName == 8 then
		cur = self.operationData.curScale
		min = info.minScale
		max = info.maxScale
	end

	data.oldMin = min
	data.oldMax = max
	data.newMin = -info.mapPosLength
	data.newMax = info.mapPosLength

	local newCur = AvatarUtils.parseSliderMapValue(min, max, data.newMin, data.newMax, cur)

	return data.newMin, data.newMax, newCur
end

function PetAccessoryEditComponent:_setAccessTransWithOpName(v, opName)
	if opName == 1 then
		self.operationData.curOffset:Set(v, self.operationData.curOffset.y, self.operationData.curOffset.z)
	elseif opName == 2 then
		self.operationData.curOffset:Set(self.operationData.curOffset.x, v, self.operationData.curOffset.z)
	elseif opName == 3 then
		self.operationData.curOffset:Set(self.operationData.curOffset.x, self.operationData.curOffset.y, v)
	elseif opName == 5 then
		self.operationData.curRotate:Set(v, self.operationData.curRotate.y, self.operationData.curRotate.z)
	elseif opName == 6 then
		self.operationData.curRotate:Set(self.operationData.curRotate.x, v, self.operationData.curRotate.z)
	elseif opName == 7 then
		self.operationData.curRotate:Set(self.operationData.curRotate.x, self.operationData.curRotate.y, v)
	elseif opName == 8 then
		self.operationData.curScale = v
	end
end

function PetAccessoryEditComponent:_applyOperationToModel()
	local entity = self.avatarComponent and self.avatarComponent.avatarScene and self.avatarComponent.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local modelView = entity.eModel.modelView

	AvatarUtils.syncPetAttachFromOperation(modelView, self.instanceId, self.operationData)
end

function PetAccessoryEditComponent:_cloneOperationData(src)
	return {
		curOffset = Vector3.New(src.curOffset.x, src.curOffset.y, src.curOffset.z),
		curRotate = Vector3.New(src.curRotate.x, src.curRotate.y, src.curRotate.z),
		curScale = src.curScale,
		attachBone = src.attachBone,
		resId = src.resId
	}
end

function PetAccessoryEditComponent:_pushUndo()
	self._undoStack[#self._undoStack + 1] = self:_cloneOperationData(self.operationData)
	self._redoStack = {}
end

function PetAccessoryEditComponent:undo()
	if not self._undoStack or #self._undoStack <= 0 then
		return
	end

	self._redoStack[#self._redoStack + 1] = self:_cloneOperationData(self.operationData)
	self.operationData = table.remove(self._undoStack)

	self:_applyOperationToModel()
	self:refreshOperationList()
end

function PetAccessoryEditComponent:redo()
	if not self._redoStack or #self._redoStack <= 0 then
		return
	end

	self._undoStack[#self._undoStack + 1] = self:_cloneOperationData(self.operationData)
	self.operationData = table.remove(self._redoStack)

	self:_applyOperationToModel()
	self:refreshOperationList()
end

function PetAccessoryEditComponent:resetToPreset()
	if not self.cacheOperationData or not self.editing then
		return
	end

	self.operationData = self:_cloneOperationData(self.cacheOperationData)

	self:_applyOperationToModel()
	self:refreshOperationList()
end

function PetAccessoryEditComponent:refreshOperationList()
	if self.operationUList then
		self.operationUList:SetList(Utils.deepCopyTable(OPERATION_CONFIG.operations))
	end

	self:refreshButtonState()
end

function PetAccessoryEditComponent:refreshButtonState()
	if self.btnUndoUButton then
		self.btnUndoUButton.interactable = self._undoStack and #self._undoStack > 0
	end

	if self.btnRedoUButton then
		self.btnRedoUButton.interactable = self._redoStack and #self._redoStack > 0
	end
end

function PetAccessoryEditComponent:saveEdit(callback, genId)
	if not self.avatarComponent or not self.avatarComponent.curPetId then
		if callback then
			callback(false)
		end

		return
	end

	if genId == nil or genId == 0 then
		genId = self.selectedGenId
	end

	if not genId or genId == 0 then
		if callback then
			callback(false)
		end

		return
	end

	local item = {
		configId = self.selectedPetAccessoryId,
		attachBone = self.operationData.attachBone,
		posX = self.operationData.curOffset.x,
		posY = self.operationData.curOffset.y,
		posZ = self.operationData.curOffset.z,
		rotX = self.operationData.curRotate.x,
		rotY = self.operationData.curRotate.y,
		rotZ = self.operationData.curRotate.z,
		scale = self.operationData.curScale
	}

	pg.me:serverMsg("RPC_CS_SetPetJewelryInfo", self.avatarComponent.curPetId, genId, item, function(res)
		if callback then
			callback(res == true)
		end
	end)
end

return PetAccessoryEditComponent
