-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioFuncOrnamentUIComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotoOrnamentData = require("Data.photo_ornament_data")
local ItemData = require("Data.item_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local StudioFuncOrnamentUIComponent = Class.LightClass("StudioFuncOrnamentUIComponent", UIComponent)

function StudioFuncOrnamentUIComponent:onCtor(info)
	self.avatarScene = self.ctrl:getAvatarScene()
	self.previewOrnamentId = nil
	self.focusedOrnamentId = nil
	self.focusedOrnamentIndex = nil
end

function StudioFuncOrnamentUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.limitUBaseText = objectReference:GetRefValue("limitUBaseText")
end

function StudioFuncOrnamentUIComponent:initView()
	self.ornamentLimit = AppearanceVariableData.STUDIO_ORNAMENT_NUM or 0
	self.ornaments = {}
	self.allOrnaments = {}

	for ornamentId, configData in pairs(PhotoOrnamentData) do
		local itemConfig = ItemData[ornamentId]
		local icon = configData.icon

		if itemConfig and not string.isNilOrEmpty(itemConfig.icon) then
			icon = itemConfig.icon
		end

		self.allOrnaments[#self.allOrnaments + 1] = {
			id = ornamentId,
			name = configData.name,
			icon = icon
		}
	end

	function self.listUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.icon or ""

		local isUnlocked = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Ornament, data.id)
		local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Ornament, nil, data.id)

		pg.global.setRedDot(itemPath, button, PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.Ornament, data.id), RedDotConst.RedDotStyle.NEW)
		button:TryChangePage("Lock", isUnlocked and 0 or 1)

		button.skipInListSwitch = not isUnlocked
		button.isSelected = self.selectedOrnamentId == data.id

		function button.luaNavFocused()
			self:onFocusOrnament(data)
		end

		function button.luaClick()
			self:onClickOrnament(button, data)
		end
	end
end

function StudioFuncOrnamentUIComponent:refreshUI()
	self.ornaments = {}

	for _, data in ipairs(self.allOrnaments) do
		if PhotographyAssetRedDotUtils.isAssetVisible(PhotographyAssetRedDotUtils.AssetType.Ornament, data.id) then
			self.ornaments[#self.ornaments + 1] = data
		end
	end

	PhotographyAssetRedDotUtils.sortUnlockedFirst(self.ornaments, PhotographyAssetRedDotUtils.AssetType.Ornament)
	self.listUList:SetList(self.ornaments)
	self:refreshLimitText()
end

function StudioFuncOrnamentUIComponent:refreshAssetUnlockState()
	self:refreshUI()
end

function StudioFuncOrnamentUIComponent:getPlacedOrnamentCount()
	if not self.avatarScene then
		return 0
	end

	local count = #self.avatarScene:getStudioOrnaments()

	if self.previewOrnamentId and self.avatarScene:getStudioOrnament(self.previewOrnamentId) then
		count = count - 1
	end

	return math.max(0, count)
end

function StudioFuncOrnamentUIComponent:refreshLimitText()
	local text = string.format(pg.getGameString("PHOTO_STUDIO_ORNAMENT_LIMIT"), self:getPlacedOrnamentCount(), self.ornamentLimit)

	ClientTextUtils.setText(self.limitUBaseText, text)
end

function StudioFuncOrnamentUIComponent:getOrnamentIndex(ornamentId)
	for index, data in ipairs(self.ornaments) do
		if data.id == ornamentId then
			return index
		end
	end

	return nil
end

function StudioFuncOrnamentUIComponent:clearPreviewOrnament()
	local ornamentId = self.previewOrnamentId

	if not ornamentId or not self.avatarScene then
		return false
	end

	self.previewOrnamentId = nil

	local selected = self.ctrl:getSelectedStudioOrnament()

	if selected and selected.studioOrnamentId == ornamentId then
		self.ctrl:selectStudioEntity(nil)
	end

	local removed = self.avatarScene:removeStudioOrnament(ornamentId)

	if removed then
		self.ctrl:refreshPlaceHotspots()
	end

	self:refreshLimitText()

	return removed
end

function StudioFuncOrnamentUIComponent:previewOrnament(data)
	self.focusedOrnamentId = data.id
	self.focusedOrnamentIndex = self:getOrnamentIndex(data.id)

	if self.previewOrnamentId and self.previewOrnamentId ~= data.id then
		self:clearPreviewOrnament()
	end

	local entity, created = self.avatarScene:spawnStudioOrnament(data.id, nil, nil, pg.me.uid)

	if not entity then
		return
	end

	if created then
		self.previewOrnamentId = data.id

		self.ctrl:placeStudioEntityAtScreenCenter(entity.studioOrnamentEntityId)
	end

	self.ctrl:refreshPlaceHotspots()
	self.ctrl:selectStudioEntity(entity)
	self:refreshLimitText()
	self.ctrl:refreshOrnamentConsoleBarState()
end

function StudioFuncOrnamentUIComponent:markOrnamentViewed(ornamentId)
	PhotographyAssetRedDotUtils.markAssetViewed(PhotographyAssetRedDotUtils.AssetType.Ornament, ornamentId)
	self.listUList:RefreshList()
	self.ctrl:onPhotoAssetViewed(PhotographyAssetRedDotUtils.AssetType.Ornament)
end

function StudioFuncOrnamentUIComponent:onFocusOrnament(data)
	if not pg.game.input:isUsingGamepad() or not self.avatarScene or self.ctrl:isOrnamentEditing() or self.isHandlingNavFocus then
		return
	end

	local isUnlocked = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Ornament, data.id)

	self.isHandlingNavFocus = true

	self:previewOrnament(data)

	if isUnlocked then
		self:markOrnamentViewed(data.id)
	end

	self.isHandlingNavFocus = false
end

function StudioFuncOrnamentUIComponent:isPreviewOrnament(entity)
	return entity ~= nil and entity.studioOrnamentId == self.previewOrnamentId
end

function StudioFuncOrnamentUIComponent:hasPreviewOrnament()
	return self.previewOrnamentId ~= nil and self.avatarScene ~= nil and self.avatarScene:getStudioOrnament(self.previewOrnamentId) ~= nil
end

function StudioFuncOrnamentUIComponent:selectPreviewOrnament()
	local entity = self.previewOrnamentId and self.avatarScene and self.avatarScene:getStudioOrnament(self.previewOrnamentId)

	if not entity then
		return false
	end

	self.ctrl:selectStudioEntity(entity)

	return true
end

function StudioFuncOrnamentUIComponent:commitPreviewOrnament()
	local entity = self.ctrl:getSelectedStudioOrnament()

	if not self:isPreviewOrnament(entity) then
		return false
	end

	if self:getPlacedOrnamentCount() >= self.ornamentLimit then
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_ORNAMENT_QUOTA_FULL"))
		self:refreshLimitText()

		return false
	end

	self.previewOrnamentId = nil

	self.ctrl:refreshPlaceHotspots()
	self.ctrl:selectStudioEntity(entity)
	self.ctrl:recordHistoryStep("ornament_add")
	self:refreshLimitText()
	self.ctrl:refreshOrnamentConsoleBarState()

	return true
end

function StudioFuncOrnamentUIComponent:onClickOrnament(button, data)
	if not PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Ornament, data.id) then
		PhotographyStudioUtils.showLockedAssetTip(data.id, button)

		return
	end

	if not self.avatarScene then
		return
	end

	self.focusedOrnamentId = data.id
	self.focusedOrnamentIndex = self:getOrnamentIndex(data.id)

	if pg.game.input:isUsingGamepad() then
		if self.previewOrnamentId ~= data.id and not self:isFocusedOrnamentPlaced() then
			self:previewOrnament(data)
		end

		if self.previewOrnamentId == data.id then
			if self:commitPreviewOrnament() then
				self:editFocusedOrnament()
			end
		else
			self:editFocusedOrnament()
		end
	else
		self:previewOrnament(data)
	end

	self:markOrnamentViewed(data.id)
end

function StudioFuncOrnamentUIComponent:setListNavigationLocked(locked)
	if IsNil(self.listUList) then
		return
	end

	if locked and pg.global.navMgr:IsFocusInNavGroupOf(self.listUList) then
		pg.global.navMgr:ClearFocus()
	end

	self.listUList.navGroupForceNonInteractable = locked
end

function StudioFuncOrnamentUIComponent:restoreFocusedItem(skipFocusPreview)
	self:setListNavigationLocked(false)

	local index = self.focusedOrnamentIndex

	if not index then
		return
	end

	if self.pendingFocusTimer then
		self:killTimer(self.pendingFocusTimer)

		self.pendingFocusTimer = nil
	end

	local timerId

	timerId = self:startTimer(function()
		if self.pendingFocusTimer ~= timerId then
			return
		end

		self.pendingFocusTimer = nil

		local success, button = self.listUList:TryGetChildAt(index - 1)

		if success and NotNil(button) then
			if skipFocusPreview then
				self.isHandlingNavFocus = true
			end

			pg.global.navMgr:FocusItem(button)

			if skipFocusPreview then
				self.isHandlingNavFocus = false
			end
		end
	end, 0)
	self.pendingFocusTimer = timerId
end

function StudioFuncOrnamentUIComponent:onOrnamentEditExited(restoreFocus)
	self:setListNavigationLocked(false)

	if restoreFocus then
		self:restoreFocusedItem()
	end
end

function StudioFuncOrnamentUIComponent:isFocusedOrnamentPlaced()
	return self.focusedOrnamentId ~= nil and self.focusedOrnamentId ~= self.previewOrnamentId and self.avatarScene and self.avatarScene:getStudioOrnament(self.focusedOrnamentId) ~= nil
end

function StudioFuncOrnamentUIComponent:isOrnamentItemFocused()
	return pg.game.input:isUsingGamepad() and NotNil(self.listUList) and pg.global.navMgr:IsFocusInNavGroupOf(self.listUList)
end

function StudioFuncOrnamentUIComponent:editFocusedOrnament()
	if not self:isFocusedOrnamentPlaced() then
		return false
	end

	local entity = self.avatarScene:getStudioOrnament(self.focusedOrnamentId)

	if not entity then
		return false
	end

	self.ctrl:enterOrnamentEdit(entity)
	self:setListNavigationLocked(true)

	return true
end

function StudioFuncOrnamentUIComponent:deleteFocusedOrnament()
	if not self:isFocusedOrnamentPlaced() then
		return false
	end

	local ornamentId = self.focusedOrnamentId
	local ornamentIndex = self.focusedOrnamentIndex
	local wasEditing = self.ctrl:isOrnamentEditing()

	self.ctrl:exitOrnamentEdit(false)

	self.focusedOrnamentId = ornamentId
	self.focusedOrnamentIndex = ornamentIndex

	self.ctrl:selectStudioEntity(nil)

	if not self.avatarScene:removeStudioOrnament(ornamentId) then
		return false
	end

	self.ctrl:refreshPlaceHotspots()
	self.ctrl:recordHistoryStep("ornament_remove")
	self.listUList:RefreshList()
	self:refreshLimitText()

	if wasEditing then
		self:restoreFocusedItem(true)
	end

	self.ctrl:refreshOrnamentConsoleBarState()

	return true
end

function StudioFuncOrnamentUIComponent:onNavFocusChange()
	if not pg.game.input:isUsingGamepad() or self.ctrl:isOrnamentEditing() or self.isHandlingNavFocus then
		return
	end

	if pg.global.navMgr:IsFocusInNavGroupOf(self.listUList) then
		return
	end

	self.focusedOrnamentId = nil
	self.focusedOrnamentIndex = nil

	self:clearPreviewOrnament()

	local selected = self.ctrl:getSelectedStudioOrnament()

	if selected then
		self.ctrl:selectStudioEntity(nil)
	end
end

function StudioFuncOrnamentUIComponent:onStudioEntitySelected(entity)
	self.selectedOrnamentId = entity and entity.studioOrnamentId or nil

	if NotNil(self.listUList) then
		self.listUList:RefreshList()
	end

	self:refreshLimitText()
end

function StudioFuncOrnamentUIComponent:onBeginPhoto()
	local ornamentId = self.previewOrnamentId
	local entity = ornamentId and self.avatarScene and self.avatarScene:getStudioOrnament(ornamentId)

	if not entity then
		return
	end

	self.captureHiddenPreviewOrnamentId = ornamentId

	entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, false)
end

function StudioFuncOrnamentUIComponent:onEndPhoto()
	local ornamentId = self.captureHiddenPreviewOrnamentId

	self.captureHiddenPreviewOrnamentId = nil

	local entity = ornamentId and self.avatarScene and self.avatarScene:getStudioOrnament(ornamentId)

	if entity then
		entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, true)
	end
end

function StudioFuncOrnamentUIComponent:saveToPreset(preset)
	local ornaments = {}

	if self.avatarScene then
		for _, entity in ipairs(self.avatarScene:getStudioOrnaments()) do
			if entity.studioOrnamentId ~= self.previewOrnamentId then
				local entityId = entity.studioOrnamentEntityId
				local pos = self.avatarScene:getStudioEntityLocalPos(entityId)

				if pos then
					ornaments[#ornaments + 1] = {
						ornamentId = entity.studioOrnamentId,
						pos = pos,
						rotY = self.avatarScene:getStudioEntityLocalRotY(entityId) or 0
					}
				end
			end
		end
	end

	table.sort(ornaments, function(left, right)
		return left.ornamentId < right.ornamentId
	end)

	preset.ornaments = ornaments
end

function StudioFuncOrnamentUIComponent:applyPreset(preset)
	if not self.avatarScene then
		return
	end

	self:clearPreviewOrnament()
	self.avatarScene:syncStudioOrnaments(preset and preset.ornaments, self.ctrl:getStudioMasterUid())
	self.ctrl:refreshPlaceHotspots()
	self:refreshLimitText()
end

function StudioFuncOrnamentUIComponent:onDeselected()
	if self.pendingFocusTimer then
		self:killTimer(self.pendingFocusTimer)

		self.pendingFocusTimer = nil
	end

	self.ctrl:exitOrnamentEdit(false)
	self:setListNavigationLocked(false)

	self.focusedOrnamentId = nil
	self.focusedOrnamentIndex = nil

	self:clearPreviewOrnament()

	local selected = self.ctrl:getSelectedStudioOrnament()

	if selected then
		self.ctrl:selectStudioEntity(nil)
	end
end

function StudioFuncOrnamentUIComponent:onInputDeviceChanged()
	if not pg.game.input:isUsingGamepad() then
		self:onDeselected()
	end
end

function StudioFuncOrnamentUIComponent:onDestroy()
	if self.pendingFocusTimer then
		self:killTimer(self.pendingFocusTimer)

		self.pendingFocusTimer = nil
	end

	self:clearPreviewOrnament()
	UIComponent.onDestroy(self)
end

return StudioFuncOrnamentUIComponent
