-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMultiSelect\\HomelandMultiSelectCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandMultiSelectCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ItemData = require("Data.item_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandEditorTopListComponent = require("Guis.Panels.HomelandEditor.Component.HomelandEditorTopListComponent")
local HomelandViewCtrlComponent = require("Guis.Panels.HomelandEditor.Component.HomelandViewCtrlComponent")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local GlobalData = require("Core.Client.GlobalData")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local HomelandMultiSelectCtrl = Class.LightClass("HomelandMultiSelectCtrl", UICtrl)

HomelandMultiSelectCtrl.messages = {
	[MessageName.HOMELAND_EDITOR_SETTING_REFRESH] = {
		"refreshTopList",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}
HomelandMultiSelectCtrl.SelectType = {
	Select = 0,
	DeSelect = 1
}
HomelandMultiSelectCtrl.PRE_MULTI_SELECT_MAX_COUNT_RATIO = 2

function HomelandMultiSelectCtrl:ctor()
	HomelandMultiSelectCtrl.super.ctor(self)

	self.preMultiSelectEntities = {}
	self.preMultiSelectList = {}
	self.tempSelectEntitiesCache = {}
	self.tempPreMultiSelectEntitiesCache = {}
	self.tempPreMultiSelectList = {}
	self.tempCalcBoundEntities = {}
	self.selectEntitiesCache = {}
	self.isMobileMultiSelectMode = false
	self.isGamepadRBHold = false
end

function HomelandMultiSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view.widget.enableNavRegion = true
	self.view.widget.navRegionForceCursorOn = true
	self.editor = info.editor or pg.game.home.editor
	self.carGroup = info.carGroup
	self.areaId = info.areaId
	self.displayMode = self.editor.displayHideMode
	self.cameraHeight = self.editor.cameraHeightLimit
	self.photoHiddenFurniture = {}
	self.photoOutlinedFurniture = {}
	self.isBlueprintPhotoSceneActive = false

	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self.view.operateMobileUContainer:LoadDefaultUrlManually(function(obj)
			local objectReference = obj:GetComponent("ObjectReference")

			self.moveJoyStick = objectReference:GetRefValue("joyStickUJoyStick")

			local cameraCtrlUWidget = objectReference:GetRefValue("cameraCtrlUWidget")

			LuaUIUtils.setUIVisible(cameraCtrlUWidget, false)
		end)
	end

	self.viewCtrlComponent = HomelandViewCtrlComponent(self, self.view.viewCtrl, {
		joyStick = self.moveJoyStick
	})
	self.viewCtrlComponent.selectType = ClientConst.HomeSelectType.Ornament

	self.viewCtrlComponent:setGamepadShowHint(true)
	self.viewCtrlComponent:setKeyHintInfo("HudHomelandMultiSelect", "HudHomelandEdit")

	function self.viewCtrlComponent.onSelectEnt(ent)
		self:onSelectEnt(ent)
	end

	function self.viewCtrlComponent.onStartDrag(screenPos, button)
		return self:checkAndHandleStartDrag(screenPos, button)
	end

	function self.viewCtrlComponent.onEndDrag(screenPos, button)
		return self:checkAndHandleEndDrag(screenPos, button)
	end

	function self.viewCtrlComponent.onDrag(screenPos, button)
		return self:checkAndHandleDrag(screenPos, button)
	end

	local globalEditComponentConfig = {
		mode = Const.HOMELAND_EDITOR_MODE.PLACEMENT,
		editor = self.editor,
		getIsMultiSelectFunc = function()
			return true
		end,
		onMultiSelectFunc = function(switch)
			self:closePanel()
		end
	}

	self.globalEditingComponent = HomelandEditorTopListComponent(self, self.view.globalEditingUWidget, globalEditComponentConfig)

	self.editor:setEnableEdit(self.uid, true)
	self.viewCtrlComponent:initCameraHeight()
	ClientTextUtils.setText(self.view.txtDisplayUSDFText, pg.getGameString("HOME_BUILD_WALL_DISPLAY_DESC"))
	ClientTextUtils.setText(self.view.txtMetreUSDFText, pg.getGameString("HOME_BUILD_CAMERA_HEIGHT_DESC"))
	self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
	self.view.btnDisplayUButton:SetActive(not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD)

	function self.editor.onMultiSelectChangedCallback()
		self:onSelectListChange()
	end

	self.selectEntitiesData = {}
	self.selectType = HomelandMultiSelectCtrl.SelectType.Select

	self.view.widget:TryChangePage("MultiSelectType", self.selectType)
	self:setSelectBoxVisible(false)
	ClientTextUtils.setText(self.view.titleText, pg.getGameString("MULTIEDIT"))
	ClientTextUtils.setText(self.view.boxSelectToggleText, pg.getGameString("OPEN_RANGE_SELECT"))
	self:setMobileMultiSelectMode(false)
	self:refreshErrorState()
	self:initPreSelectState(info)
	pg.global.showBubbleMessage(NoticeDef.HOMELAND_MULTI_SELECT_ENTER)
end

function HomelandMultiSelectCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:closePanel()
	end

	function self.view.btnDisplayUButton.luaClick()
		self.displayMode = (self.displayMode + 1) % 3

		self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
		self.editor:setDisplayHideMode(self.displayMode)
		self.editor:refreshHeightHide()

		if self.displayMode == 0 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_FULL_DISPLAY"))
		elseif self.displayMode == 1 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_SEMI_HIDDEN"))
		elseif self.displayMode == 2 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_FULL_HIDDEN"))
		end
	end

	self:initSelectPanel()

	local nameText

	self.view.btnSaveUButton:SetActive(true)

	function self.view.btnSaveUButton.luaClick()
		self:openCreateComposeDetail()
	end

	nameText = self.view.btnSaveUButton:GetComponent("ObjectReference"):GetRefValue("nameText")

	ClientTextUtils.setText(nameText, pg.getGameString("HOMELAND_COMPOSE_SAVE_COMBINATION"))

	function self.view.btnEditUButton.luaClick()
		self:onEditBtnClick()
	end

	nameText = self.view.btnEditUButton:GetComponent("ObjectReference"):GetRefValue("nameText")

	ClientTextUtils.setText(nameText, pg.getGameString("START_EDIT"))

	function self.view.btnRecycleUButton.luaClick()
		self:onWithdrawBtnClick()
	end

	nameText = self.view.btnRecycleUButton:GetComponent("ObjectReference"):GetRefValue("nameText")

	ClientTextUtils.setText(nameText, pg.getGameString("WITHDRAW"))

	function self.view.btnAddUButton.luaClick()
		self.selectType = HomelandMultiSelectCtrl.SelectType.Select
	end

	nameText = self.view.btnAddUButton:GetComponent("ObjectReference"):GetRefValue("nameText")

	ClientTextUtils.setText(nameText, pg.getGameString("ADD_SELECT"))

	function self.view.btnRemoveUButton.luaClick()
		self.selectType = HomelandMultiSelectCtrl.SelectType.DeSelect
	end

	nameText = self.view.btnRemoveUButton:GetComponent("ObjectReference"):GetRefValue("nameText")

	ClientTextUtils.setText(nameText, pg.getGameString("REMOVE_SELECT"))

	function self.view.boxSelectToggleUButton.luaSelectChanged(isSelected)
		self:setMobileMultiSelectMode(isSelected)
	end

	self:bindHotKeyPerform("Hud/HomelandRecycle", function()
		self:onWithdrawBtnClick()
	end, self.view.btnRecycleUButton.gameObject, "Hud/HomelandRecycle")
	self:bindHotKeyPerform("Hud/HomelandConfirm", function()
		self:onEditBtnClick()
	end, self.view.btnEditUButton.gameObject, "Hud/HomelandConfirm")

	local recycleBind = self.view.btnRecycleUButton:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")

	recycleBind:SetHotKeyPaths("Hud/HomelandRecycle")

	local editBind = self.view.btnEditUButton:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")

	editBind:SetHotKeyPaths("Hud/HomelandConfirm")
	self:initConsoleKeyBind()
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function HomelandMultiSelectCtrl:onVisibleChange(visible)
	if visible then
		self:refreshDisplayMode()
		self.viewCtrlComponent:refreshCameraHeight()
	end
end

function HomelandMultiSelectCtrl:refreshDisplayMode()
	self.displayMode = self.editor.displayHideMode

	self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
end

function HomelandMultiSelectCtrl:openCreateComposeDetail()
	if not self.view or not self.editor then
		return false
	end

	self:refreshRangeInfo()

	local ornamentIdList, homeIdList = self:getSelectedOrnamentIdList()

	if #ornamentIdList < 2 then
		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_COMPOSE_CREATE_MIN_FURNITURE_COUNT"))

		return false
	end

	if self.isOverMaxCount or self.isOverMaxBound then
		return false
	end

	local loadValue = 0
	local comfortValue = 0

	for _, homeId in ipairs(homeIdList) do
		loadValue = loadValue + ClientHomelandUtils.getLoadValueById(homeId)
		comfortValue = comfortValue + ClientHomelandUtils.getComfortValueById(homeId)
	end

	local minX, maxX, minZ, maxZ, minY, maxY = self.editor:calcEntitiesBounds(self.tempCalcBoundEntities)
	local rangeX, rangeY, rangeZ = 0, 0, 0
	local photoContext

	if minX then
		rangeX = math.ceil(maxX - minX)
		rangeY = math.ceil(maxY - minY)
		rangeZ = math.ceil(maxZ - minZ)

		local centerLocal = Vector3.New((minX + maxX) * 0.5, (minY + maxY) * 0.5, (minZ + maxZ) * 0.5)
		local centerWorld = self.editor:getWorldPosition(centerLocal)
		local groupFront = self.editor:getWorldRotation(self.editor:getDefaultRotation()) * Vector3.forward

		groupFront.y = 0

		if Vector3.SqrMagnitude(groupFront) <= 0.01 then
			groupFront = Vector3.forward
		else
			groupFront:SetNormalize()
		end

		photoContext = {
			cameraTargetInfo = {
				center = {
					x = centerWorld.x,
					y = centerWorld.y,
					z = centerWorld.z
				},
				size = {
					x = maxX - minX,
					y = maxY - minY,
					z = maxZ - minZ
				},
				front = {
					x = groupFront.x,
					z = groupFront.z
				}
			},
			setSceneActive = function(active)
				self:setBlueprintPhotoSceneActive(active, ornamentIdList)
			end
		}
	end

	pg.global.ui.homelandFurnitureComposeDetail:open({
		designIndex = UIConst.HOME_DESIGN_MODE.CREATE,
		composeIndex = UIConst.HOME_COMPOSE_MODE.COMBINATION,
		photoContext = photoContext,
		detailData = {
			ornamentIdList = ornamentIdList,
			homeIdList = homeIdList,
			rangeSize = {
				rangeX,
				rangeY,
				rangeZ
			},
			loadValue = loadValue,
			comfortValue = comfortValue
		}
	})

	return true
end

function HomelandMultiSelectCtrl:initConsoleKeyBind()
	local gamepadMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "gamepadMoveViewBinding")

	gamepadMoveBinding.isVirtual = true
	gamepadMoveBinding.actionPath = "Raw/GamepadDPad"

	function gamepadMoveBinding.luaTrigger(inputInfo)
		if not self.editor then
			return
		end

		local deltaVec2 = inputInfo.valueVec2

		self.editor:handleMove(deltaVec2[1], deltaVec2[2])
	end

	local gamepadDeselectModifierBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "gamepadDeselectModifierBinding")

	gamepadDeselectModifierBinding.isVirtual = true
	gamepadDeselectModifierBinding.actionPath = "Raw/GamepadRightShoulder"

	function gamepadDeselectModifierBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.isGamepadRBHold = true
		elseif inputInfo.phase == "Canceled" then
			self.isGamepadRBHold = false
		end
	end
end

function HomelandMultiSelectCtrl:onDestroy()
	self:setBlueprintPhotoSceneActive(false)
	self:clearPreMultiSelect()
	facade:sendMsgToUI(MessageName.HOMELAND_EDITOR_SETTING_REFRESH, {
		mode = Const.HOMELAND_EDITOR_MODE.MULTIPLE
	})

	self.editor.onMultiSelectChangedCallback = nil
	self.selectBoxVisible = nil
	self.editorErrorType = nil
	self.viewCtrlComponent = nil
	self.isOverMaxCount = false
	self.isOverMaxBound = false
	self.globalEditingComponent = nil

	table.clear(self.selectEntitiesCache)
	table.clear(self.preMultiSelectEntities)
	table.clear(self.preMultiSelectList)
	table.clear(self.selectEntitiesData)
	table.clear(self.tempCalcBoundEntities)
	table.clear(self.tempSelectEntitiesCache)
	table.clear(self.tempPreMultiSelectEntitiesCache)
	table.clear(self.tempPreMultiSelectList)
	self.editor:clearMultiSelectEntities()
	self.editor:setEnableEdit(self.uid, false)
	UICtrl.onDestroy(self)
end

function HomelandMultiSelectCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshSelectList()
end

function HomelandMultiSelectCtrl:checkVirtualMouseHoverSnapEnabled()
	return true
end

function HomelandMultiSelectCtrl:onShow()
	return
end

function HomelandMultiSelectCtrl:onHide()
	return
end

function HomelandMultiSelectCtrl:initSelectPanel()
	local objectReference = self.view.selectedPanelUComponent:GetComponent("ObjectReference")

	self.listItemUList = objectReference:GetRefValue("listItemUList")

	local btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	local btnHideUButton = objectReference:GetRefValue("btnHideUButton")
	local btnShowUButton = objectReference:GetRefValue("btnShowUButton")

	self.selectedText = objectReference:GetRefValue("selectedText")

	function btnHideUButton.luaClick()
		self.view.selectedPanelUComponent:TryChangePage("ExpandState", 1)
	end

	function btnShowUButton.luaClick()
		self.view.selectedPanelUComponent:TryChangePage("ExpandState", 0)
	end

	function self.listItemUList.luaRenderItem(button, index, data)
		self:rendererSelectItem(button, index, data)
	end

	function btnDeleteUButton.luaClick()
		self:onDeleteAllBtnClick()
	end
end

function HomelandMultiSelectCtrl:onSelectListChange()
	self:refreshSelectList()
end

function HomelandMultiSelectCtrl:refreshSelectList()
	local multiSelectEntities = self.editor.multiSelectEntities
	local multiSelectList = self.editor.multiSelectList

	table.clear(self.selectEntitiesData)

	for i, entId in ipairs(multiSelectList) do
		local ent = multiSelectEntities[entId]

		if ent then
			table.insert(self.selectEntitiesData, {
				entId = entId,
				homeTemplateId = ent.homeTemplateId
			})
		end
	end

	lume.reverseInPlace(self.selectEntitiesData)
	self.listItemUList:SetList(self.selectEntitiesData)

	local itemNum = #self.selectEntitiesData
	local maxMultiSelectNum = HomelandConfigData.maxMultiSelectNum or 100
	local numText = ""

	if maxMultiSelectNum < itemNum then
		numText = pg.getFormatText("<style=Debuff>{0}</style>/{1}", itemNum, maxMultiSelectNum)

		self:setOverMaxCountState(true)
	else
		numText = pg.getFormatText("{0}/{1}", itemNum, maxMultiSelectNum)

		self:setOverMaxCountState(false)
	end

	ClientTextUtils.setText(self.selectedText, pg.getFormatText(pg.getGameString("MULTI_SELECT_NUM"), numText))
	LuaUIUtils.setUIVisible(self.view.selectedPanelUComponent, itemNum > 0)
	self:refreshRangeInfo()

	self.view.btnEditUButton.interactable = itemNum > 0 and not self.isOverMaxCount and not self.isOverMaxBound
	self.view.btnSaveUButton.interactable = itemNum > 0 and not self.isOverMaxCount and not self.isOverMaxBound
	self.view.btnRecycleUButton.interactable = itemNum > 0
end

function HomelandMultiSelectCtrl:setOverMaxCountState(isOverMaxCount)
	if self.isOverMaxCount ~= isOverMaxCount then
		self.isOverMaxCount = isOverMaxCount

		self:refreshErrorState()
	end
end

function HomelandMultiSelectCtrl:setOverMaxBoundState(isOverMaxBound)
	if self.isOverMaxBound ~= isOverMaxBound then
		self.isOverMaxBound = isOverMaxBound

		self:refreshErrorState()
	end
end

function HomelandMultiSelectCtrl:refreshErrorState()
	if self.isOverMaxCount then
		self:refreshErrorInfo(Const.HomeEditorMultiSelectErrorType.OverCount)
	elseif self.isOverMaxBound then
		self:refreshErrorInfo(Const.HomeEditorMultiSelectErrorType.OverBounds)
	else
		self:refreshErrorInfo(Const.HomeEditorMultiSelectErrorType.None)
	end
end

function HomelandMultiSelectCtrl:refreshRangeInfo()
	table.clear(self.tempCalcBoundEntities)

	local multiSelectEntities = self.editor.multiSelectEntities
	local removeEntities, extraAddEntities

	if self.isInMultiSelecting then
		if self:checkIsSelectMode() then
			extraAddEntities = self.preMultiSelectEntities
		else
			removeEntities = self.preMultiSelectEntities
		end
	end

	for entId, ent in pairs(multiSelectEntities) do
		if not removeEntities or not removeEntities[entId] then
			table.insert(self.tempCalcBoundEntities, ent)
		end
	end

	if extraAddEntities then
		for entId, ent in pairs(extraAddEntities) do
			if not multiSelectEntities[entId] then
				table.insert(self.tempCalcBoundEntities, ent)
			end
		end
	end

	if #self.tempCalcBoundEntities == 0 then
		self:setOverMaxBoundState(false)
		ClientTextUtils.setText(self.view.areaRangeText, "")

		return
	end

	local minX, maxX, minZ, maxZ, minY, maxY = self.editor:calcEntitiesBounds(self.tempCalcBoundEntities)

	if not minX then
		self:setOverMaxBoundState(false)
		ClientTextUtils.setText(self.view.areaRangeText, "")

		return
	end

	local maxXZBound = HomelandConfigData.maxMultiSelectSize or 10
	local maxHeightBound = HomelandConfigData.maxMultiSelectHeight or 15
	local rangeX = math.ceil(maxX - minX)
	local rangeY = math.ceil(maxY - minY)
	local rangeZ = math.ceil(maxZ - minZ)
	local rangeXText = ""
	local boundValid = true

	if maxXZBound < rangeX then
		rangeXText = pg.getFormatText("<style=Debuff>{0}</style>", rangeX)
		boundValid = false
	else
		rangeXText = pg.getFormatText("{0}", rangeX)
	end

	local rangeZText = ""

	if maxXZBound < rangeZ then
		rangeZText = pg.getFormatText("<style=Debuff>{0}</style>", rangeZ)
		boundValid = false
	else
		rangeZText = pg.getFormatText("{0}", rangeZ)
	end

	local rangeYText = ""

	if maxHeightBound < rangeY then
		rangeYText = pg.getFormatText("<style=Debuff>{0}</style>", rangeY)
		boundValid = false
	else
		rangeYText = pg.getFormatText("{0}", rangeY)
	end

	local rangeText = pg.getFormatText("{0}x{1}x{2}", rangeXText, rangeYText, rangeZText)

	ClientTextUtils.setText(self.view.areaRangeText, pg.getFormatText(pg.getGameString("CURRENT_RANG"), rangeText))
	self:setOverMaxBoundState(not boundValid)
end

function HomelandMultiSelectCtrl:rendererSelectItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtName")
	local txtNum = objectReference:GetRefValue("txtNum")
	local icon = objectReference:GetRefValue("icon")
	local lockText = objectReference:GetRefValue("lockText")
	local levelUWidget = objectReference:GetRefValue("levelUWidget")
	local levelText = objectReference:GetRefValue("levelText")
	local iconFavUWidget = objectReference:GetRefValue("iconFavUWidget")
	local removeBtn = objectReference:GetRefValue("removeBtn")

	txtNum:SetActive(false)
	txtName:SetActive(false)
	removeBtn:SetActive(true)
	levelUWidget:SetActive(false)

	local itemData = ItemData[data.homeTemplateId] or {}

	icon.url = itemData.icon

	button:TryChangePage("Quality", itemData.quality or 0)

	function removeBtn.luaClick()
		self:onSelectItemDeleteBtnClick(data)
	end
end

function HomelandMultiSelectCtrl:onSelectItemDeleteBtnClick(data)
	local ent = pg.getEntity(data.entId)
	local entities = self:collectOrnamentEditGroupEntities({
		ent
	})

	self.editor:removeMultiSelectEntities(entities)
end

function HomelandMultiSelectCtrl:onDeleteAllBtnClick()
	if pg.game.home.curLoginShowMultiSelectClearHint then
		local extraInfo = {
			hint = true,
			hintCb = function(isSelected)
				pg.game.home.curLoginShowMultiSelectClearHint = not isSelected
			end
		}

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("MULTISELECT_CLEAN_CONFIRM"), function()
			self.editor:clearMultiSelectEntities()
		end, nil, nil, nil, nil, extraInfo)
	else
		self.editor:clearMultiSelectEntities()
	end
end

function HomelandMultiSelectCtrl:onWithdrawBtnClick()
	if self.carGroup then
		self.editor:withdrawMultiSelectEntities()
	elseif not pg.game.home:tryShowRemoveFacilitiesConfirm(self.editor.multiSelectEntities, function()
		self.editor:withdrawMultiSelectEntities()
	end) then
		self.editor:withdrawMultiSelectEntities()
	end
end

function HomelandMultiSelectCtrl:onEditBtnClick()
	local multiSelectEntities = self.editor.multiSelectEntities

	if not next(multiSelectEntities) then
		return
	end

	if self.isOverMaxCount or self.isOverMaxBound then
		return
	end

	local entities = {}

	for _, entInfo in ipairs(self.selectEntitiesData) do
		local ent = multiSelectEntities[entInfo.entId]

		table.insert(entities, ent)
	end

	if #entities == 1 then
		pg.global.ui.homelandPlacement:open({
			isFromMultiSelect = true,
			editType = ClientConst.HomeEditType.UpdateOrnament,
			entity = entities[1],
			editor = self.editor,
			carGroup = self.carGroup,
			areaId = self.areaId
		})
	else
		pg.global.ui.homelandPlacement:open({
			isFromMultiSelect = true,
			editType = ClientConst.HomeEditType.UpdateOrnament,
			entities = entities,
			editor = self.editor,
			carGroup = self.carGroup,
			areaId = self.areaId
		})
	end

	GlobalData.BILogger:customeLog("home_build_mode", {
		is_continuous_buy = 0,
		is_continuous_place = 0,
		is_multiple_edit = 0,
		is_multiple_choice = 1,
		action_type = "edit_confirm"
	})
end

function HomelandMultiSelectCtrl:getOrnamentEnt(ornamentId)
	if self.carGroup then
		return self.carGroup:getHomeEntity(ornamentId)
	end

	return pg.game.home:getHomeEntity(ornamentId)
end

function HomelandMultiSelectCtrl:collectOrnamentEditGroupEntities(seedEntities, collectGroups)
	local homeSpace = pg.me and pg.me.space

	if self.carGroup then
		homeSpace = self.carGroup.campCarEnt
	end

	return ClientHomelandUtils.collectOrnamentEditGroupEntities(seedEntities, {
		editor = self.editor,
		areaId = self.areaId,
		homeSpace = homeSpace,
		getEntity = function(ornamentId)
			return self:getOrnamentEnt(ornamentId)
		end,
		collectGroups = collectGroups
	})
end

function HomelandMultiSelectCtrl:getSelectedOrnamentIdList()
	local ornamentIdList = {}
	local homeIdList = {}
	local multiSelectEntities = self.editor.multiSelectEntities

	for _, entId in ipairs(self.editor.multiSelectList) do
		local ent = multiSelectEntities[entId]

		if ent and ent.homeTemplateId and ent.ornamentId then
			table.insert(ornamentIdList, ent.ornamentId)
			table.insert(homeIdList, ent.homeTemplateId)
		end
	end

	return ornamentIdList, homeIdList
end

function HomelandMultiSelectCtrl:setBlueprintPhotoSceneActive(active, selectedOrnamentIds)
	if active and not self.view then
		return
	end

	if active == self.isBlueprintPhotoSceneActive then
		return
	end

	if not active then
		for _, entity in ipairs(self.photoHiddenFurniture or EMPTY_TABLE) do
			if entity and not entity.destroyed and entity.setVisible then
				entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, true)
			end
		end

		for _, entity in ipairs(self.photoOutlinedFurniture or EMPTY_TABLE) do
			if entity and not entity.destroyed and entity.isInMultiSelect and entity.setEditorOutline then
				entity:setEditorOutline(ClientConst.EntityEditorOutlinePriority.MutiSelect, true, AddressDataConst.HOMELAND_OUTLINE_GREEN)
			end
		end

		local viewCtrlComponent = self.viewCtrlComponent

		if viewCtrlComponent and not viewCtrlComponent.isDestroyed and viewCtrlComponent.setEnable then
			viewCtrlComponent:setEnable(self.photoViewCtrlWasEnabled ~= false)
		end

		self.photoHiddenFurniture = {}
		self.photoOutlinedFurniture = {}
		self.photoViewCtrlWasEnabled = nil
		self.isBlueprintPhotoSceneActive = false

		return
	end

	local editor = self.editor

	if not editor or not editor.forEachHideableEntity then
		return
	end

	local viewCtrlComponent = self.viewCtrlComponent

	if viewCtrlComponent and not viewCtrlComponent.isDestroyed and viewCtrlComponent.setEnable then
		self.photoViewCtrlWasEnabled = viewCtrlComponent.enable

		viewCtrlComponent:setEnable(false)
	end

	local selectedOrnamentIdSet = {}

	for _, ornamentId in ipairs(selectedOrnamentIds or EMPTY_TABLE) do
		selectedOrnamentIdSet[ornamentId] = true
	end

	self.photoHiddenFurniture = {}
	self.photoOutlinedFurniture = {}

	editor:forEachHideableEntity(function(entity)
		if entity and entity.setVisible and not selectedOrnamentIdSet[entity.ornamentId] then
			entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, false)
			table.insert(self.photoHiddenFurniture, entity)
		end
	end)

	for _, entity in pairs(editor.multiSelectEntities or EMPTY_TABLE) do
		if entity and selectedOrnamentIdSet[entity.ornamentId] and entity.isInMultiSelect and entity.setEditorOutline then
			entity:setEditorOutline(ClientConst.EntityEditorOutlinePriority.MutiSelect, false)
			table.insert(self.photoOutlinedFurniture, entity)
		end
	end

	self.isBlueprintPhotoSceneActive = true
end

function HomelandMultiSelectCtrl:onSelectEnt(ent)
	if not ent then
		return
	end

	if not ent.canEntEdit or not ent:canEntEdit() then
		return
	end

	if self.areaId and ent.areaId ~= self.areaId then
		return
	end

	local selectEntities = self:collectOrnamentEditGroupEntities({
		ent
	})

	if not self.editor.multiSelectEntities[ent.id] then
		local addCount = 0

		for _, entity in ipairs(selectEntities) do
			if not self.editor.multiSelectEntities[entity.id] then
				addCount = addCount + 1
			end
		end

		if #self.editor.multiSelectList + addCount > self:getMultiSelectMaxCount() then
			return
		end

		self.editor:addMultiSelectEntities(selectEntities)
	else
		self.editor:removeMultiSelectEntities(selectEntities)
	end
end

function HomelandMultiSelectCtrl:setMobileMultiSelectMode(isSelected)
	self.view.boxSelectToggleUButton:SetSelected(isSelected)
	LuaUIUtils.setUIVisible(self.view.toggleTabUWidget, isSelected)

	if self.isMobileMultiSelectMode ~= isSelected then
		self.isMobileMultiSelectMode = isSelected

		if isSelected then
			pg.global.showBubbleMessage(NoticeDef.HOMELAND_MULTI_BOX_SELECT_BLOCK_CAMERA)
		end
	end
end

function HomelandMultiSelectCtrl:checkAndHandleStartDrag(screenPos, button)
	self:clearPreMultiSelect()

	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		if self.isMobileMultiSelectMode then
			self.startDragPos = screenPos
			self.isInMultiSelecting = true

			return true
		end
	elseif button ~= ClientConst.InputButtonType.Middle then
		if button == ClientConst.InputButtonType.Left then
			if pg.game.input:isUsingGamepad() and self.isGamepadRBHold then
				self.selectType = HomelandMultiSelectCtrl.SelectType.DeSelect
			else
				self.selectType = HomelandMultiSelectCtrl.SelectType.Select
			end
		else
			self.selectType = HomelandMultiSelectCtrl.SelectType.DeSelect
		end

		self.startDragPos = screenPos
		self.isInMultiSelecting = true

		return true
	end

	return false
end

function HomelandMultiSelectCtrl:checkAndHandleEndDrag(screenPos)
	if self.isInMultiSelecting then
		self:setSelectBoxVisible(false)
		self:endPreSelectEntities(self.startDragPos, self.curDragPos)

		return true
	end

	return false
end

function HomelandMultiSelectCtrl:checkAndHandleDrag(screenPos, button)
	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		if self.isInMultiSelecting then
			self:setSelectBoxVisible(true)

			self.curDragPos = screenPos

			LuaUIUtils.setSelectBoxRect(self.view.selectBoxRect, self.view.selectBoxRect.parent, self.startDragPos, self.curDragPos, self.view.selectBoxIconTrans, 0.15, 0.15)
			self:updatePreSelectEntities(self.startDragPos, self.curDragPos)

			return true
		end
	elseif button ~= ClientConst.InputButtonType.Middle and self.isInMultiSelecting then
		self:setSelectBoxVisible(true)

		self.curDragPos = screenPos

		LuaUIUtils.setSelectBoxRect(self.view.selectBoxRect, self.view.selectBoxRect.parent, self.startDragPos, self.curDragPos, self.view.selectBoxIconTrans, 0.15, 0.15)
		self:updatePreSelectEntities(self.startDragPos, self.curDragPos)

		return true
	end

	return false
end

function HomelandMultiSelectCtrl:addPreSelectRelatedOrnaments(tempSelectEntitiesCache)
	local seedEntities = {}

	for _, entity in pairs(tempSelectEntitiesCache) do
		table.insert(seedEntities, entity)
	end

	table.sort(seedEntities, function(a, b)
		return tostring(a.id) < tostring(b.id)
	end)

	local relatedEntities, _, entityGroups = self:collectOrnamentEditGroupEntities(seedEntities, true)

	for _, entity in ipairs(relatedEntities) do
		tempSelectEntitiesCache[entity.id] = entity
	end

	return entityGroups
end

function HomelandMultiSelectCtrl:updatePreSelectEntities(startScreenPos, endScreenPos)
	table.clear(self.tempSelectEntitiesCache)
	self.editor:tryBoxSelectEntities(startScreenPos, endScreenPos, ClientConst.HomeSelectType.Ornament, self.tempSelectEntitiesCache)

	local entityGroups = self:addPreSelectRelatedOrnaments(self.tempSelectEntitiesCache)

	table.clear(self.tempPreMultiSelectEntitiesCache)
	table.clear(self.tempPreMultiSelectList)

	local maxCount = self:getPreMultiSelectMaxCount()
	local preMultiSelectCount = 0

	for _, entityGroup in ipairs(entityGroups) do
		local validGroupCount = 0

		for _, ent in ipairs(entityGroup) do
			if self:checkCanPreMultiSelect(ent) then
				validGroupCount = validGroupCount + 1
			else
				self.tempSelectEntitiesCache[ent.id] = nil
			end
		end

		if maxCount >= preMultiSelectCount + validGroupCount then
			for _, ent in ipairs(entityGroup) do
				if self.tempSelectEntitiesCache[ent.id] then
					self.tempPreMultiSelectEntitiesCache[ent.id] = ent

					table.insert(self.tempPreMultiSelectList, ent)
				end
			end

			preMultiSelectCount = preMultiSelectCount + validGroupCount
		end
	end

	local changed = false

	for entId, ent in pairs(self.preMultiSelectEntities) do
		if not self.tempPreMultiSelectEntitiesCache[entId] and self:removePreMultiSelect(ent) then
			changed = true
		end
	end

	for _, ent in ipairs(self.tempPreMultiSelectList) do
		if self:addPreMultiSelect(ent) then
			changed = true
		end
	end

	if changed then
		self:refreshRangeInfo()
	end
end

function HomelandMultiSelectCtrl:endPreSelectEntities(startScreenPos, endScreenPos)
	self:updatePreSelectEntities(startScreenPos, endScreenPos)
	table.clear(self.selectEntitiesCache)

	for i, entId in ipairs(self.preMultiSelectList) do
		local ent = self.preMultiSelectEntities[entId]

		table.insert(self.selectEntitiesCache, ent)
	end

	if self:checkIsSelectMode() then
		self.editor:addMultiSelectEntities(self.selectEntitiesCache)
	else
		self.editor:removeMultiSelectEntities(self.selectEntitiesCache)
	end

	table.clear(self.selectEntitiesCache)
	self:clearPreMultiSelect()
	self:refreshRangeInfo()
end

function HomelandMultiSelectCtrl:setSelectBoxVisible(visible)
	if self.selectBoxVisible ~= visible then
		self.selectBoxVisible = visible

		LuaUIUtils.setUIVisible(self.view.selectBoxRect, visible)

		if visible then
			self.view.widget:TryChangePage("BoxSelection", 1)
			self.view.widget:TryChangePage("MutiSelectType", self:checkIsSelectMode() and 0 or 1)

			if self:checkIsSelectMode() then
				ClientTextUtils.setText(self.view.boxSelectTitle, pg.getGameString("MULTI_SELECTING_HINT"))
			else
				ClientTextUtils.setText(self.view.boxSelectTitle, pg.getGameString("MULTI_UNSELECTING_HINT"))
			end
		else
			self.view.widget:TryChangePage("BoxSelection", 0)
		end
	end
end

function HomelandMultiSelectCtrl:checkIsSelectMode()
	return self.selectType == HomelandMultiSelectCtrl.SelectType.Select
end

function HomelandMultiSelectCtrl:checkCanPreMultiSelect(entity)
	if not entity.setPreMultiSelectMode or not entity.canEntEdit or not entity:canEntEdit() then
		return false
	end

	if self.areaId and entity.areaId ~= self.areaId then
		return false
	end

	local isSelected = self.editor.multiSelectEntities[entity.id] ~= nil

	return self:checkIsSelectMode() ~= isSelected
end

function HomelandMultiSelectCtrl:getMultiSelectMaxCount()
	local maxMultiSelectNum = HomelandConfigData.maxMultiSelectNum or 100

	return math.floor(maxMultiSelectNum * HomelandMultiSelectCtrl.PRE_MULTI_SELECT_MAX_COUNT_RATIO)
end

function HomelandMultiSelectCtrl:getPreMultiSelectMaxCount()
	local maxCount = self:getMultiSelectMaxCount()

	if self:checkIsSelectMode() then
		maxCount = maxCount - #self.editor.multiSelectList
	end

	return math.max(maxCount, 0)
end

function HomelandMultiSelectCtrl:addPreMultiSelect(entity)
	if not self.preMultiSelectEntities[entity.id] then
		if #self.preMultiSelectList >= self:getPreMultiSelectMaxCount() then
			return false
		end

		self.preMultiSelectEntities[entity.id] = entity

		table.insert(self.preMultiSelectList, entity.id)

		if entity.setPreMultiSelectMode then
			entity:setPreMultiSelectMode(self:checkIsSelectMode())
		end

		return true
	end

	return false
end

function HomelandMultiSelectCtrl:removePreMultiSelect(entity)
	if self.preMultiSelectEntities[entity.id] == entity then
		self.preMultiSelectEntities[entity.id] = nil

		lume.removeFromArr(self.preMultiSelectList, entity.id)

		if entity.setPreMultiSelectMode then
			entity:setPreMultiSelectMode(nil)
		end

		return true
	end

	return false
end

function HomelandMultiSelectCtrl:clearPreMultiSelect()
	self.isInMultiSelecting = false

	for entId, entity in pairs(self.preMultiSelectEntities) do
		if entity.setPreMultiSelectMode then
			entity:setPreMultiSelectMode(nil)
		end
	end

	table.clear(self.preMultiSelectList)
	table.clear(self.preMultiSelectEntities)
end

function HomelandMultiSelectCtrl:closePanel()
	pg.global.showBubbleMessage(NoticeDef.HOMELAND_MULTI_SELECT_QUIT)
	self:close()
end

function HomelandMultiSelectCtrl:refreshTopList(data)
	if self.globalEditingComponent and data and data.mode == Const.HOMELAND_EDITOR_MODE.PLACEMENT then
		self.globalEditingComponent:refreshTopList()
	end
end

function HomelandMultiSelectCtrl:refreshErrorInfo(editorErrorType)
	if not self.view.warningUContainer then
		return
	end

	if editorErrorType == Const.HomeEditorMultiSelectErrorType.None and not self.editorErrorType then
		return
	end

	if not self.view.warningUContainer:CheckURLLoaded() then
		self.view.warningUContainer:LoadDefaultUrlManually(function()
			self:refreshErrorInfo(editorErrorType)
		end)
	elseif editorErrorType ~= self.editorErrorType then
		self.editorErrorType = editorErrorType

		if editorErrorType == Const.HomeEditorMultiSelectErrorType.None then
			if not self.view.warningUContainer.content.gameObject.activeInHierarchy then
				self.view.warningUContainer:SetActive(false)
			else
				self.view.warningUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			end

			return
		end

		self.view.warningUContainer:SetActive(false)

		local errorText = self:getPlaceErrorText(editorErrorType)

		if errorText then
			self.view.warningUContainer:SetActive(true)
			self.view.warningUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)

			local objectReference = self.view.warningUContainer.content:GetComponent("ObjectReference")
			local txtWarningUSDFText = objectReference:GetRefValue("txtWarningUSDFText")

			ClientTextUtils.setText(txtWarningUSDFText, errorText)
		end
	end
end

function HomelandMultiSelectCtrl:getPlaceErrorText(errorType)
	if not errorType or errorType == Const.HomeEditorMultiSelectErrorType.None then
		return
	elseif errorType == Const.HomeEditorMultiSelectErrorType.OverBounds then
		return pg.getGameString("OVER_BOX_SELECT_RANGE")
	elseif errorType == Const.HomeEditorMultiSelectErrorType.OverCount then
		return pg.getGameString("OVER_BOX_SELECT_NUM")
	end

	return pg.getGameString("HOMELAND_EDITOR_ERRORNONE")
end

function HomelandMultiSelectCtrl:shopButtonClick()
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE, {
		carGroup = self.carGroup
	})
end

function HomelandMultiSelectCtrl:initPreSelectState(info)
	local preSelectEntities = {}

	for _, entity in ipairs(info.preSelectEntities or EMPTY_TABLE) do
		table.insert(preSelectEntities, entity)
	end

	if info.preSelectEntity then
		table.insert(preSelectEntities, info.preSelectEntity)
	end

	local relatedEntities = self:collectOrnamentEditGroupEntities(preSelectEntities)

	if #relatedEntities > 0 then
		self.editor:addMultiSelectEntities(relatedEntities)
	end
end

function HomelandMultiSelectCtrl:onChildEntityAdded(entity)
	return
end

function HomelandMultiSelectCtrl:onChildEntityRemove(entity)
	return
end

function HomelandMultiSelectCtrl:onChildEntityDestroy(entity)
	return
end

function HomelandMultiSelectCtrl:onInputDeviceChanged(deviceType)
	if self.viewCtrlComponent then
		self.viewCtrlComponent:refreshKeyHints()
	end

	self:refreshVirtualMouseHoverSnapEnabled()
end

function HomelandMultiSelectCtrl:onNavFocusChange()
	local inModal = pg.global.navMgr and pg.global.navMgr:IsInModalGroup() or false

	self.view.widget.navRegionForceCursorOn = not inModal

	pg.global.ui:refreshLockCursor()
end

return HomelandMultiSelectCtrl
