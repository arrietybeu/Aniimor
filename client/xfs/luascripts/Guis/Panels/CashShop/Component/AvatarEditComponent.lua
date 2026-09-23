-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\AvatarEditComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Utils = require("Common.Utils.Utils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceData = require("Data.appearance_data")
local AppearanceJewelryInfo = require("CustomTypes.AppearanceJewelryInfo")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local AvatarEditComponent = Class.LightClass("AvatarEditComponent", UIComponent)
local avatarMgr = pg.global.avatarMgr

function AvatarEditComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.editRootUComponent = self.objectReference:GetRefValue("editRootUComponent")
	self.operationUList = self.objectReference:GetRefValue("operationUList")
	self.btnUndoUButton = self.objectReference:GetRefValue("btnUndoUButton")
	self.btnRedoUButton = self.objectReference:GetRefValue("btnRedoUButton")
	self.btnEditResetUButton = self.objectReference:GetRefValue("btnEditResetUButton")
end

function AvatarEditComponent:initView()
	self.avatarComponent = self.ctrl and self.ctrl.avatarComponent
	self.editing = false
	self.reactionKey = nil
	self.slotId = nil
	self.accessoryId = nil
	self.lastEditOpName = nil
	self.curOperations = {}
	self.selectedAccessoryId = nil
	self.selectedSlotId = nil

	if self.editRootUComponent then
		self.editRootUComponent:TryChangePage("state", 0)
	end

	if self.operationUList then
		self.operationUList:SetList({})
	end
end

function AvatarEditComponent:_ensureBindings()
	if self._bindingsReady then
		return
	end

	self._bindingsReady = true

	self:addListener()
end

function AvatarEditComponent:setSelectedAccessory(accessoryId, slotId)
	self.selectedAccessoryId = accessoryId
	self.selectedSlotId = slotId
end

function AvatarEditComponent:addListener()
	if self.operationUList then
		function self.operationUList.luaRenderItem(button, index, data)
			AvatarUtils.renderOperationCollection(button, data, function(contentButton, contentIndex, contentData)
				self:_renderSliderItem(contentButton, contentIndex, contentData)
			end)
		end
	end

	if self.btnUndoUButton then
		function self.btnUndoUButton.luaClick()
			self:undo()
			self:refreshOperationList()
		end
	end

	if self.btnRedoUButton then
		function self.btnRedoUButton.luaClick()
			self:redo()
			self:refreshOperationList()
		end
	end

	if self.btnEditResetUButton then
		function self.btnEditResetUButton.luaClick()
			self:resetToPreset()
			self:refreshOperationList()
		end
	end
end

function AvatarEditComponent:removeListener()
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

function AvatarEditComponent:deactivateBindings()
	self:removeListener()

	self._bindingsReady = nil
end

function AvatarEditComponent:showAdjustPanel(accessoryId, slotId)
	self:_ensureBindings()

	if self.ctrl and self.ctrl.view and self.ctrl.view.rootUComponent then
		self.ctrl.view.rootUComponent:TryChangePage("showAdjust", 1)
	end

	if self.editRootUComponent then
		self.editRootUComponent:TryChangePage("state", 1)
	end

	accessoryId = accessoryId or self.selectedAccessoryId
	slotId = slotId or self.selectedSlotId

	local ok = false

	if accessoryId then
		ok = self:beginEdit(accessoryId, slotId)

		if not ok then
			ok = self:beginEditWithPreview(slotId)
		end
	else
		ok = self:beginEditWithPreview(slotId)
	end

	if ok then
		self:refreshOperationList()
	elseif self.operationUList then
		self.operationUList:SetList({})
	end

	self:refreshButtonState()

	return ok
end

function AvatarEditComponent:hideAdjustPanel()
	if self.ctrl and self.ctrl.view and self.ctrl.view.rootUComponent then
		self.ctrl.view.rootUComponent:TryChangePage("showAdjust", 0)
	end
end

function AvatarEditComponent:clearOperationList()
	if self.operationUList then
		self.operationUList:SetList({})
	end
end

function AvatarEditComponent:resetEditContext()
	self:_clearEditState()
	self:clearOperationList()
end

function AvatarEditComponent:beginEditWithPreview(slotId)
	if not self.avatarComponent or not self.avatarComponent.avatarScene then
		return false
	end

	local entity = self.avatarComponent.avatarScene:getCurEntity()

	if not entity then
		return false
	end

	if slotId then
		local accessoryId = entity:getAppearanceConfigId(slotId, true)

		if accessoryId and accessoryId ~= 0 then
			return self:beginEdit(accessoryId, slotId)
		end

		return false
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId = entity:getAppearanceConfigId(partId, true)

		if accessoryId and accessoryId ~= 0 then
			return self:beginEdit(accessoryId, partId)
		end
	end

	return false
end

function AvatarEditComponent:beginEdit(accessoryId, slotId)
	if not self.avatarComponent then
		return false
	end

	local entity = self.avatarComponent.avatarScene and self.avatarComponent.avatarScene:getCurEntity()

	if not entity then
		return false
	end

	local data = AppearanceData[accessoryId]

	if not data then
		return false
	end

	self.slotId = slotId or data.partId

	if not self.slotId then
		return false
	end

	self.accessoryId = accessoryId
	self.reactionKey = ClientModelUtils.getAccessoryReactionKeyAndKindKey(accessoryId, entity.eModel.modelModelView.modelInfo:GetMakeUpPartAssetId())

	if not self.reactionKey then
		return false
	end

	local curPreviewId = entity:getAppearanceConfigId(self.slotId, true)

	if curPreviewId ~= accessoryId then
		self.avatarComponent:equipAccessory(accessoryId, self.slotId)
	end

	avatarMgr.avatarMakeup:SelectAttach(self.reactionKey)

	self.editing = true
	self.lastEditOpName = nil

	return true
end

function AvatarEditComponent:getEditableOperations()
	if not self.reactionKey then
		return {}
	end

	local reaction = self:_getReactionData(self.reactionKey)

	if not reaction then
		return {}
	end

	return Utils.deepCopyTable(reaction.operations or {})
end

function AvatarEditComponent:refreshOperationList()
	self:_ensureBindings()

	self.curOperations = self:getEditableOperations()

	if self.operationUList then
		self.operationUList:SetList(self.curOperations)
	end

	self:refreshButtonState()
end

function AvatarEditComponent:startEditOperation(opName)
	if not self.editing or not self.reactionKey or not opName then
		return
	end

	self.lastEditOpName = opName

	avatarMgr.avatarMakeup:StartEditAttach(self.reactionKey, opName)
end

function AvatarEditComponent:updateEditOperation(value)
	if not self.editing or not self.reactionKey then
		return
	end

	avatarMgr.avatarMakeup:EditAttach(self.reactionKey, value)
end

function AvatarEditComponent:endEditOperation()
	if not self.editing or not self.reactionKey then
		return
	end

	avatarMgr.avatarMakeup:FinishEditAttach(self.reactionKey)

	self.lastEditOpName = nil
end

function AvatarEditComponent:resetToPreset()
	if not self.editing or not self.reactionKey then
		return
	end

	avatarMgr.avatarMakeup:ResetAttachToPreset(self.reactionKey)
	avatarMgr.globalStack:Clear()
end

function AvatarEditComponent:cancelEdit()
	if not self.editing or not self.accessoryId or not self.reactionKey then
		return
	end

	local lastInfoStr = pg.me.jewelryLastInfos and pg.me.jewelryLastInfos[self.accessoryId]

	if lastInfoStr then
		self:refreshAttachByServer(self.accessoryId, self.reactionKey, lastInfoStr)
	else
		avatarMgr.avatarMakeup:ResetAttachToPreset(self.reactionKey)
	end

	avatarMgr.globalStack:Clear()
	self:_clearEditState()
end

function AvatarEditComponent:saveEdit(callback)
	if not self.editing or not self.slotId or not self.accessoryId or not self.reactionKey then
		if callback then
			callback(false)
		end

		return
	end

	if not pg.me.appearanceInfo or not pg.me.appearanceInfo[self.accessoryId] then
		if callback then
			callback(false)
		end

		return
	end

	local entity = self.avatarComponent.avatarScene:getCurEntity()

	if not entity then
		if callback then
			callback(false)
		end

		return
	end

	entity:syncToServer()

	local info = self:createJewelryInfo(self.accessoryId, self.reactionKey)

	if Utils.isEmptyTable(info) then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_SetJewelryInfo", self.slotId, self.accessoryId, info, function(res)
		if callback then
			callback(res == true)
		end
	end)
end

function AvatarEditComponent:getUndoRedoState()
	local globalStack = avatarMgr.globalStack

	return {
		canUndo = globalStack:CanBackward(),
		canRedo = globalStack:CanForward()
	}
end

function AvatarEditComponent:undo()
	avatarMgr:Undo()
	self:refreshButtonState()
end

function AvatarEditComponent:redo()
	avatarMgr:Redo()
	self:refreshButtonState()
end

function AvatarEditComponent:refreshButtonState()
	local state = self:getUndoRedoState()

	if self.btnUndoUButton then
		self.btnUndoUButton.interactable = state.canUndo
	end

	if self.btnRedoUButton then
		self.btnRedoUButton.interactable = state.canRedo
	end
end

function AvatarEditComponent:_renderSliderItem(button, _, contentData)
	if contentData.tIndex ~= 0 then
		AvatarUtils.renderSlider(button, contentData, 0)

		return
	end

	local value = avatarMgr.avatarMakeup:GetReactionDataValue(self.reactionKey, contentData.opName)

	AvatarUtils.renderSlider(button, contentData, value, function(v)
		self:updateEditOperation(v)
		self:refreshButtonState()
	end, function()
		self:endEditOperation()
		self:refreshButtonState()
	end, function()
		self:startEditOperation(contentData.opName)
	end)
end

function AvatarEditComponent:refreshAttachByServer(accessoryId, reactionKey, lastInfoStr)
	if not accessoryId or not reactionKey or not lastInfoStr then
		return
	end

	local jewelryInfo = AppearanceJewelryInfo.new()

	jewelryInfo:toTable(accessoryId, lastInfoStr)

	local overrideResId = ""

	if jewelryInfo.colorJewelryId and jewelryInfo.colorJewelryId ~= 0 then
		local colorData = ColorJewelryData[jewelryInfo.colorJewelryId]

		if colorData then
			overrideResId = colorData.res
		end
	end

	avatarMgr.avatarMakeup:RefreshAttachByServer(reactionKey, jewelryInfo, overrideResId)
end

function AvatarEditComponent:createJewelryInfo(accessoryId, reactionKey)
	local entity = self.avatarComponent and self.avatarComponent.avatarScene and self.avatarComponent.avatarScene:getCurEntity()

	if not entity then
		return {}
	end

	local attachModelInfo = entity.eModel.modelModelView.modelInfo:GetAttachModelInfo(reactionKey)

	if not attachModelInfo then
		return {}
	end

	return {
		configId = accessoryId,
		attachBone = attachModelInfo.attachHp,
		posX = attachModelInfo.localOffset.x,
		posY = attachModelInfo.localOffset.y,
		posZ = attachModelInfo.localOffset.z,
		rotX = attachModelInfo.localRotation.x,
		rotY = attachModelInfo.localRotation.y,
		rotZ = attachModelInfo.localRotation.z,
		scale = attachModelInfo.scale.x
	}
end

function AvatarEditComponent:_getReactionData(reactionKey)
	if not self.avatarComponent then
		return nil
	end

	local entity = self.avatarComponent.avatarScene and self.avatarComponent.avatarScene:getCurEntity()
	local presetKey = self.avatarComponent.curPresetKey
	local makeupKey = AvatarUtils.getPartAssetId(entity, "makeup", presetKey)

	if not makeupKey then
		return nil
	end

	local makeupData = require(string.format("Data.Avatar.accessory.accessory_%s_data", makeupKey))

	for _, kindData in pairs(makeupData or EMPTY_TABLE) do
		for _, reactionData in ipairs(kindData.reactionList or EMPTY_TABLE) do
			if reactionData.key == reactionKey then
				return reactionData
			end
		end
	end
end

function AvatarEditComponent:_clearEditState()
	self.editing = false
	self.reactionKey = nil
	self.slotId = nil
	self.accessoryId = nil
	self.lastEditOpName = nil
end

return AvatarEditComponent
