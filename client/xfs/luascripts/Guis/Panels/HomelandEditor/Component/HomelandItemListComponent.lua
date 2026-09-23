-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditor\\Component\\HomelandItemListComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandItemListComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local HomeBlueprintConst = require("Common.Const.HomeBlueprintConst")
local HomeTypeData = require("Data.home_type_data")
local HomeSubTypeData = require("Data.home_sub_type_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RevertHomeObjectData = require("Data.revert_home_object_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local ClientUtils = require("Utils.ClientUtils")
local HomeObjectData = require("Data.home_object_data")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandItemListComponent = Class.LightClass("HomelandItemListComponent", UIComponent)
local HotKeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CallbackHandler = require("Core.Common.CallbackHandler")
local HomeEventTextData = require("Data.home_event_text_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local AudioConst = require("Const.AudioConst")
local RedDotConst = require("Const.RedDotConst")
local ItemOwnState = {
	SoldOut = 4,
	Locked = 3,
	NotHave = 2,
	CanBuy = 1,
	Normal = 0
}
local ComposePlaceState = {
	AreaNotMatch = 3,
	NotCollected = 2,
	Placeable = 1
}

HomelandItemListComponent.FavoriteTypeIndex = 99
HomelandItemListComponent.EmoTypeIndex = 100
HomelandItemListComponent.ItemTypeIndex = 101
HomelandItemListComponent.ComposeIndex = 102
HomelandItemListComponent.messages = {
	[MessageName.HOMELAND_BLUEPRINT_LIST_RESULT] = {
		"onBlueprintListResult",
		true
	},
	[MessageName.HOMELAND_BLUEPRINT_UPLOAD_RESULT] = {
		"onBlueprintListResult",
		true
	},
	[MessageName.HOMELAND_BLUEPRINT_DELETE_UPLOADED_RESULT] = {
		"onBlueprintDeleteResult",
		true
	}
}

local ComposeSubTypeSourceType = {
	[1021] = UIConst.HOME_DESIGN_MODE.MYDESIGN,
	[1022] = UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN,
	[1023] = UIConst.HOME_DESIGN_MODE.SHAREDESIGN
}

function HomelandItemListComponent:onCtor(info)
	self.isFurnitureStore = info and info.isFurnitureStore and info.isFurnitureStore or false
	self.dragView = info and info.dragView
	self.carGroup = info and info.carGroup
	self.isCarGroupMode = info and info.isCarGroupMode == true or not not self.carGroup
	self.curSelectItemId = info and info.itemId
	self.homeBlueprintCoverImageKeys = {}
	self.composePlaceStateMap = {}
	self.pendingComposeLocateInfo = nil
	self.composeListWaitingResponse = false
	self.isLocatingSelection = false
end

function HomelandItemListComponent:onDestroy()
	self:redDot_RecordSubTypeRead(self.curType, self.curSubType)

	self.homeBlueprintCoverImageKeys = nil
	self.composePlaceStateMap = nil
	self.pendingComposeLocateInfo = nil
	self.composeListWaitingResponse = nil
	self.isLocatingSelection = nil
	self.petDatas = nil
	self.curSelectItemId = nil

	if self.isFurnitureStore then
		pg.global.uiMgr:SetHomelandFurnitureStoreLuaTable(self.selectedItemLevel)
	else
		pg.global.uiMgr:SetHomelandEditorLuaTable(self.selectedItemLevel)
	end

	HomelandItemListComponent.super.onDestroy(self)
end

function HomelandItemListComponent:checkPetTabVisible()
	return not self.isFurnitureStore
end

function HomelandItemListComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.showBtn = self.objectReference:GetRefValue("showBtn")
	self.hideBtn = self.objectReference:GetRefValue("hideBtn")
	self.searchBtn = self.objectReference:GetRefValue("searchBtn")
	self.subTypeList = self.objectReference:GetRefValue("subTypeList")
	self.typeList = self.objectReference:GetRefValue("typeList")
	self.checkOwnBtn = self.objectReference:GetRefValue("checkOwnBtn")
	self.itemList = self.objectReference:GetRefValue("itemList")
	self.boxFilter = self.objectReference:GetRefValue("boxFilter")
	self.subTypeTitle = self.objectReference:GetRefValue("subTypeTitleUSDFText")
	self.btnShowHotKeyContent = self.objectReference:GetRefValue("btnShowHotKeyContent")
	self.foldListUList = self.objectReference:GetRefValue("foldListUList")
	self.foldListTitleUSDFText = self.objectReference:GetRefValue("foldListTitleUSDFText")
	self.nullUSDFText = self.objectReference:GetRefValue("nullUSDFText")
	self.itemFoldUPopupForm = self.objectReference:GetRefValue("itemFoldUPopupForm")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.panelUWidget = self.objectReference:GetRefValue("panelUWidget")
	self.subTabKeyL = self.objectReference:GetRefValue("subTabKeyL")
	self.subTabKeyR = self.objectReference:GetRefValue("subTabKeyR")
	self.tabKeyL = self.objectReference:GetRefValue("tabKeyL")
	self.tabKeyR = self.objectReference:GetRefValue("tabKeyR")
	self.selectAHotKeyContent = self.objectReference:GetRefValue("selectAHotKeyContent")
	self.btnTipsUSDFText = self.objectReference:GetRefValue("btnTipsUSDFText")
	self.listComposeUList = self.objectReference:GetRefValue("listComposeUList")
	self.btnImportUButton = self.objectReference:GetRefValue("btnImportUButton")
	self.txtImportUSDFText = self.objectReference:GetRefValue("txtImportUSDFText")
	self.txtExpendUSDFText = self.objectReference:GetRefValue("txtExpendUSDFText")
end

function HomelandItemListComponent:initView()
	self.searchText = nil
	self.homeListData = {}
	self.curType = nil
	self.curSubType = nil
	self.selectItemWhenTypeChange = false

	function self.typeList.luaRenderItem(item, index, data)
		item.clickSoundUrl = AudioConst.EVENT_HOME_ARCHITECTURE_TAB

		local nameUText = item:GetComponent("ObjectReference"):GetRefValue("nameUText")

		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		self:changeSelectedStatus(self.typeList, index)

		local typeId = data.typeId
		local redDotPath = string.format(RedDotConst.RedDotPath.HOMELAND_FURNITURE_TYPE_NEW, typeId)

		pg.global.setPreViewRedDot(redDotPath, item, function()
			return ClientHomelandUtils.getFurnitureTypeRedDotState(typeId, function(itemId, homeObjectInfo)
				return self:checkTypeValid(homeObjectInfo, itemId)
			end)
		end)
	end

	function self.typeList.luaSelectedChanged(uList, isSelected)
		if isSelected and not self.isLocatingSelection then
			self.pendingComposeLocateInfo = nil
		end

		local data = uList.selectedItem

		if data and isSelected then
			self:selectType(data.typeId)
		end

		if isSelected and self.selectItemWhenTypeChange then
			local list = self.itemList

			if self.curType == self.EmoTypeIndex then
				list = self.listPetUList
			elseif self.curType == self.ComposeIndex then
				list = self.listComposeUList
			end

			list:GoToIndex(0, true)

			local ret, btn = list:TryGetChildAt(0)

			if ret then
				btn:OnClickSimulate()
			else
				self.showFoldList = false

				self.uWidget:TryChangePage("FoldList", 0)
			end
		end
	end

	function self.subTypeList.luaRenderItem(item, index, data)
		item.clickSoundUrl = AudioConst.EVENT_HOME_ARCHITECTURE_TAB

		local objectRef = item.transform:GetComponent("ObjectReference")
		local nameUText = objectRef:GetRefValue("txtName")

		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))

		local icon = objectRef:GetRefValue("icon")

		icon.url = data.icon

		if not data.icon then
			item:TryChangePage("Status", 1)

			item.visibility = CS.XGUI.EVisibility.HitTestInvisible
		else
			item:TryChangePage("Status", 0)

			item.visibility = CS.XGUI.EVisibility.Visible
		end

		local typeId = self.curType
		local subTypeId = data.subTypeId
		local redDotPath = string.format(RedDotConst.RedDotPath.HOMELAND_FURNITURE_SUB_TYPE_NEW, typeId, subTypeId)

		pg.global.setPreViewRedDot(redDotPath, item, function()
			return ClientHomelandUtils.getFurnitureSubTypeRedDotState(typeId, subTypeId, function(itemId, homeObjectInfo)
				return self:checkTypeValid(homeObjectInfo, itemId)
			end)
		end)
	end

	function self.subTypeList.luaSelectedChanged(uList, isSelected)
		if isSelected and not self.isLocatingSelection then
			self.pendingComposeLocateInfo = nil
		end

		local data = uList.selectedItem
		local subTypeId

		if data then
			subTypeId = data.subTypeId
		end

		ClientTextUtils.setText(self.subTypeTitle, data and pg.getLocalizationText(data.name) or "")
		self:selectSubType(subTypeId)

		if isSelected and self.selectItemWhenTypeChange then
			local list = self.itemList

			if self.curType == self.EmoTypeIndex then
				list = self.listPetUList
			elseif self.curType == self.ComposeIndex then
				list = self.listComposeUList
			end

			list:GoToIndex(0, true)

			local ret, btn = list:TryGetChildAt(0)

			if ret then
				btn:OnClickSimulate()
			else
				self.showFoldList = false

				self.uWidget:TryChangePage("FoldList", 0)
			end
		end
	end

	function self.listComposeUList.luaRenderItem(item, index, data)
		item.clickSoundUrl = AudioConst.EVENT_HOME_ARCHITECTURE_CLICK
		item.draggable = false

		local objectReference = item.transform:GetComponent("ObjectReference")
		local bgUImage = objectReference:GetRefValue("bgUImage")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
		local nameText = data and data.name or ""

		if self:getComposeSourceTypeBySubType(self.curSubType) == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
			nameText = pg.getLocalizationText(nameText)
		end

		ClientTextUtils.setText(txtNameUSDFText, nameText or "")

		local imageKey = data.coverImageKeys and data.coverImageKeys[1]
		local imageUrl = self:getComposeSourceTypeBySubType(self.curSubType) == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN and data.image or nil

		self.homeBlueprintCoverImageKeys[item] = imageKey
		bgUImage.sprite = nil
		bgUImage.url = data.coverImageKey or data.icon or ""

		if not string.isNilOrEmpty(imageUrl) then
			self.homeBlueprintCoverImageKeys[item] = nil
			bgUImage.url = imageUrl
		elseif not string.isNilOrEmpty(imageKey) then
			pg.me:loadHomeBlueprintCoverImage(imageKey, function(sprite)
				local imageKeys = self.homeBlueprintCoverImageKeys

				if not imageKeys or imageKeys[item] ~= imageKey or not NotNil(bgUImage) then
					return
				end

				bgUImage.url = nil
				bgUImage.sprite = sprite
			end)
		end

		local stateInfo = self.composePlaceStateMap and self.composePlaceStateMap[data]

		if not stateInfo then
			local state, placeCount = self:getComposePlaceState(data)

			stateInfo = {
				state = state,
				placeCount = placeCount
			}
		end

		if stateInfo.state == ComposePlaceState.AreaNotMatch then
			item:TryChangePage("State", 1)
			ClientTextUtils.setText(txtStateUSDFText, pg.getGameString("HOMELAND_COMPOSE_AREA_NOT_MATCH"))
		elseif stateInfo.state == ComposePlaceState.NotCollected then
			item:TryChangePage("State", 1)
			ClientTextUtils.setText(txtStateUSDFText, pg.getGameString("HOMELAND_COMPOSE_NOT_COLLECTED"))
		else
			item:TryChangePage("State", 0)
			ClientTextUtils.setText(txtStateUSDFText, pg.getGameString("HOMELAND_COMPOSE_PLACEABLE_COUNT") .. stateInfo.placeCount)
		end

		function item.luaClick()
			self.pendingComposeLocateInfo = nil
			self.composeListSelectedIndex = index
			self.selectItemWhenTypeChange = true

			if self.ctrl and self.ctrl.refreshComposeDetailWindow then
				self.ctrl:refreshComposeDetailWindow(data)
			end
		end
	end

	function self.itemList.luaRenderItem(item, index, data)
		item.clickSoundUrl = AudioConst.EVENT_HOME_ARCHITECTURE_CLICK

		item:TryChangePage("Collapse", data.state ~= ItemOwnState.Locked and self.curType ~= self.FavoriteTypeIndex and data.placeId and self.itemGroups[data.placeId] and #self.itemGroups[data.placeId] > 1 and 1 or 0)

		function item.luaClick()
			self.pendingComposeLocateInfo = nil
			self.selectItemWhenTypeChange = true

			local _, foldListPage = self.uWidget:TryGetCurrentPage("FoldList")

			if not pg.game.input:isUsingGamepad() and self.curSelectItem and self.curSelectItem.itemId == data.itemId and foldListPage == 1 then
				self.uWidget:TryChangePage("FoldList", 0)

				return
			end

			self:selectItem(data, false)

			self.itemListSelectedIndex = index
			self.showFoldList = self.curType ~= self.FavoriteTypeIndex and data.placeId and self.itemGroups[data.placeId] and #self.itemGroups[data.placeId] > 1

			self.uWidget:TryChangePage("FoldList", self.showFoldList and 1 or 0)

			if not self.showFoldList and self.itemFoldUPopupForm then
				self.itemFoldUPopupForm:ClosePopUpForm()

				return
			end

			self.foldListUList:SetList(self.itemGroups[data.placeId])

			for idx, listItemData in pairs(self.foldListUList.itemData) do
				if self.curSelectItem.itemId == listItemData.itemId then
					self.foldListUList:RedirectToCenter(idx)
				end
			end

			self.itemFoldUPopupForm:SetModal(false)
			self.itemFoldUPopupForm:SetPadding(20)
			self.itemFoldUPopupForm:SetAutoVertical(true, false)
			self.itemFoldUPopupForm:OpenPopup(item.transform:GetComponent("RectTransform"), false)

			local HomeObjectPlaceData = require("Data.home_object_place_data")

			ClientTextUtils.setText(self.foldListTitleUSDFText, HomeObjectPlaceData[data.placeId][1].name)
		end

		if data.iconUrl == AddressDataConst.HOME_ITEM_STORED then
			data.iconUrl = AddressDataConst.HOME_ITEM_DARK_STORED
		end

		self:renderItemList(item, index, data, true)
	end

	function self.foldListUList.luaRenderItem(item, index, data)
		item.clickSoundUrl = AudioConst.EVENT_HOME_ARCHITECTURE_CLICK

		function item.luaClick()
			self.pendingComposeLocateInfo = nil

			self:selectItem(data, false)

			if data.state ~= ItemOwnState.Locked and data.state ~= ItemOwnState.SoldOut then
				local newData = Utils.deepCopyTable(data)
				local favPlaceIds = self:getFavPlaceIds()

				newData.isFavorite = favPlaceIds[HomeObjectData[newData.itemId].placeId] ~= nil
				self.selectedItemLevel[data.placeId] = newData.itemId

				self.itemList:SetElement(self.itemListSelectedIndex, newData)
			end
		end

		self:renderItemList(item, index, data, false)
	end

	function self.showBtn.luaClick()
		local canShowFoldList = self.curType ~= self.FavoriteTypeIndex and self.curType ~= self.EmoTypeIndex and self.curType ~= self.ComposeIndex and self.itemList.itemCount > 0

		self.uWidget:TryChangePage("FoldList", canShowFoldList and self.showFoldList and 1 or 0)
		self:setExpand(true)
	end

	function self.hideBtn.luaClick()
		self.uWidget:TryChangePage("FoldList", 0)
		self:setExpand(false)
	end

	function self.checkOwnBtn.luaSelectChanged(isSelect)
		self.isSelectOwn = isSelect

		self:updateHomeListData()
	end

	self.checkOwnBtn:SetActive(not self.isFurnitureStore)

	function self.searchBtn.luaClick()
		self:onSearchBtnClick()
	end

	function self.btnImportUButton.luaClick()
		pg.global.ui.tips:showCommonInput(pg.getGameString("HOMELAND_COMPOSE_IMPORT_COMBINATION"), function(inputText)
			local code = string.trim(inputText or "")

			if string.isNilOrEmpty(code) then
				return
			end

			pg.me:saveOtherHomeBlueprint(code)
		end, nil, {
			errorHide = true,
			inputTitle = "HOMELAND_COMPOSE_INPUT_COMBINATION_CODE",
			characterLimit = HomeBlueprintConst.DEFAULT_CONFIG.blueprintCodeLength or 8
		})
	end

	function self.listPetUList.luaRenderItem(button, idx, data)
		button.clickSoundUrl = AudioConst.EVENT_HOME_ARCHITECTURE_CLICK
		button.draggable = false

		LuaUIUtils.renderHomePetHead(button, data, nil, {
			hideWorkState = true,
			showEventState = true,
			showAppearanceTags = data.areaId == Const.HOMELAND_AREA_TYPE.BUILD
		})
		self:renderHomePetInfo(button, data)

		button.enabledTooltip = false
	end

	function self.listPetUList.luaSelectedChanged(uList, isSelected)
		if isSelected then
			local data = uList.selectedItem

			self:showPetDetail(data)
		end
	end

	local objectRef = self.boxFilter:GetComponent("ObjectReference")

	self.closeSearchBtn = objectRef:GetRefValue("closeBtn")

	function self.closeSearchBtn.luaClick()
		self:onCloseSearchBtnClick()
	end

	self.selectAHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonSouth")
	ClientTextUtils.setText(self.btnTipsUSDFText, pg.getGameString("GAMEPAD_CHOOSE"))
	ClientTextUtils.setText(self.txtImportUSDFText, pg.getGameString("HOMELAND_COMPOSE_IMPORT_COMBINATION"))
	ClientTextUtils.setText(self.txtExpendUSDFText, pg.getGameString("HOMELAND_EXPAND_LIST"))
	self:refreshSearchInfo()
	self:updateHomeListData()
	self:resetItemListExpand()
end

function HomelandItemListComponent:resetItemListExpand()
	if pg.game.input:isUsingGamepad() and not self.isFurnitureStore then
		self:setExpand(false)
	else
		self:setExpand(true)
	end
end

function HomelandItemListComponent:renderItemList(item, index, data, isItemList)
	item.enabledTooltip = false

	local objectRef = item.transform:GetComponent("ObjectReference")
	local nameUText = objectRef:GetRefValue("txtName")

	ClientTextUtils.setText(nameUText, data.name)

	local numText = objectRef:GetRefValue("txtNum")

	ClientTextUtils.setText(numText, data.numText or "")

	local icon = objectRef:GetRefValue("icon")
	local levelUWidget = objectRef:GetRefValue("levelUWidget")
	local levelText = objectRef:GetRefValue("levelText")
	local iconFavUWidget = objectRef:GetRefValue("iconFavUWidget")
	local iconCurrencyUImage = objectRef:GetRefValue("iconCurrencyUImage")
	local lockText = objectRef:GetRefValue("lockText")

	if data.iconUrl then
		iconCurrencyUImage:SetActive(true)

		iconCurrencyUImage.url = data.iconUrl
	else
		iconCurrencyUImage:SetActive(false)
	end

	if data.isFavorite then
		item:TryChangePage("IsFavorite", 1)
		iconFavUWidget:TryChangePage("enable", 1)
	else
		item:TryChangePage("IsFavorite", 0)
		iconFavUWidget:TryChangePage("enable", 0)
	end

	icon.url = data.icon

	if data.state == ItemOwnState.Normal or data.state == ItemOwnState.CanBuy then
		item:TryChangePage("state", 0)

		item.draggable = not self.isFurnitureStore
	elseif data.state == ItemOwnState.NotHave or data.state == ItemOwnState.SoldOut then
		item:TryChangePage("state", 1)

		item.draggable = not self.isFurnitureStore
	else
		item:TryChangePage("state", 2)

		item.draggable = false and not self.isFurnitureStore
	end

	item:TryChangePage("Quality", data.quality or 0)

	local isSameItem = false

	if data.itemId and self.curSelectItem then
		if self.curSelectItem.itemId == data.itemId then
			isSameItem = true
		elseif isItemList then
			local parentId = RevertHomeObjectData[data.itemId] and RevertHomeObjectData[data.itemId][1]
			local curParentId = RevertHomeObjectData[self.curSelectItem.itemId] and RevertHomeObjectData[self.curSelectItem.itemId][1]

			isSameItem = parentId and parentId == curParentId
		end
	end

	item.isSelected = isSameItem

	if data.state == ItemOwnState.Locked then
		local objectInfo = HomeObjectData[data.itemId or 0] or {}

		if data.drawingLocked and not data.conditionLocked then
			ClientTextUtils.setText(lockText, data.lockText)
		else
			ClientTextUtils.setText(lockText, pg.getLocalizationText(objectInfo.unlockDescShort) or "")
		end
	end

	item.name = data.itemId

	if data.levelText then
		levelUWidget:SetActive(true)
		ClientTextUtils.setText(levelText, data.levelText)
	else
		levelUWidget:SetActive(false)
	end

	if not self.isFurnitureStore then
		item.dragMode = 3

		function item.luaDrag(pos)
			self:onDragItem(item, pos, data)
		end

		function item.luaEndDrag()
			self:onDragEnd(item, data)
		end

		function item.luaEnterDropWidget(widget)
			if widget and widget == self.dragView then
				self:onDragIntoView(item, data)
			else
				self:onDragExitView(widget)
			end
		end

		function item.luaExitDropWidget(widget)
			if widget and widget == self.dragView then
				self:onDragExitView(item)
			end
		end
	end

	if isItemList then
		local redDotStyle = RedDotConst.RedDotStyle.NONE
		local typeId = self.curType or 0
		local subTypeId = self.curSubType or 0
		local redDotPath = string.format(RedDotConst.RedDotPath.HOMELAND_FURNITURE_ITEM_NEW, typeId, subTypeId, data.itemId or 0)

		if ClientHomelandUtils.isFurnitureRedDotType(self.curType) then
			local itemGroup = data.placeId and self.itemGroups[data.placeId]

			if itemGroup then
				redDotStyle = ClientHomelandUtils.getFurnitureItemListRedDotState(itemGroup)
			else
				redDotStyle = ClientHomelandUtils.getFurnitureItemRedDotState(data.itemId)
			end
		end

		pg.global.setRedDot(redDotPath, item, redDotStyle ~= RedDotConst.RedDotStyle.NONE, redDotStyle)
	end
end

function HomelandItemListComponent:onDragItem(item, pos, data)
	self.curDragItemPos = pos

	if item == self.curDragItem then
		self.ctrl:refreshPreviewPrefab()
	end
end

function HomelandItemListComponent:onDragEnd(item, data)
	if item == self.curDragItem and self.curDragItemId and not self.ctrl:placeNewOrnament(self.curDragItemId, true) then
		self.curDragItem = nil
		self.curDragItemId = nil

		self.ctrl:refreshPreviewPrefab()
	end
end

function HomelandItemListComponent:onVisibleChange(visible)
	if visible then
		self.typeList:RefreshList()
		self.subTypeList:RefreshList()
		self.itemList:RefreshList()
	else
		self:redDot_RecordSubTypeRead(self.curType, self.curSubType)

		self.curDragItem = nil
		self.curDragItemId = nil
	end
end

function HomelandItemListComponent:showPetDetail(data)
	self.ctrl:refreshPetDetailWindow(data)
end

function HomelandItemListComponent:onDragIntoView(item, data)
	if item.replicaWidget then
		LuaUIUtils.setUIViewVisible(item.replicaWidget, false)
	end

	self.curDragItem = item
	self.curDragItemId = data and data.itemId

	self.ctrl:refreshPreviewPrefab()
end

function HomelandItemListComponent:onDragExitView(item)
	if item.replicaWidget then
		LuaUIUtils.setUIViewVisible(item.replicaWidget, true)
	end

	if self.curDragItem == item then
		self.curDragItem = nil
		self.curDragItemId = nil

		self.ctrl:refreshPreviewPrefab()
	end
end

function HomelandItemListComponent:changeSelectedStatus(ulist, selectIndex)
	local res, child = ulist:TryGetChildAt(selectIndex)

	if res then
		if ulist.itemCount == 1 then
			child:TryChangePage("Status", 3)

			return
		end

		if selectIndex == 0 then
			child:TryChangePage("Status", 0)
		elseif selectIndex == ulist.itemCount - 1 then
			child:TryChangePage("Status", 2)
		else
			child:TryChangePage("Status", 1)
		end
	end
end

function HomelandItemListComponent:setExpand(isExpand)
	self.isExpand = isExpand

	if pg.game.input:isUsingGamepad() then
		local NavFocusState = CS.XGUI.Navigation.NavFocusState

		pg.global.navMgr:SetNavGroupForceNonInteractable("ListItem", not isExpand)
		pg.global.navMgr:SetNavGroupForceNonInteractable("ListItemFold", not isExpand)
		pg.global.navMgr:SetNavGroupForceNonInteractable("PetList", not isExpand)
		pg.global.navMgr:SetNavGroupItemFocusStateOverride("ListItem", true, isExpand and NavFocusState.Select or NavFocusState.Hover)
		pg.global.navMgr:SetNavGroupItemFocusStateOverride("ListItemFold", true, isExpand and NavFocusState.Select or NavFocusState.Hover)
		self.typeList:SetSwitchForceHidden(not isExpand)
		self.subTypeList:SetSwitchForceHidden(not isExpand)
	end

	if isExpand then
		self.uWidget:TryChangePage("ExpandState", 0)

		self.panelUWidget.visibility = CS.XGUI.EVisibility.SelfHitTestInvisible

		if self.curType == self.EmoTypeIndex then
			if self._cachedPetIndex and self._cachedPetIndex >= 0 and NotNil(self.listPetUList) and self._cachedPetIndex < self.listPetUList.itemCount then
				self.listPetUList:SelectItem(self._cachedPetIndex)
				self.uWidget:TryChangePage("FoldList", 0)

				if pg.game.input:isUsingGamepad() then
					local ret, btn = self.listPetUList:TryGetChildAt(self._cachedPetIndex)

					if ret and NotNil(btn) then
						CS.XGUI.Navigation.NavManager.Instance:FocusItem(btn)
					end
				end
			end
		elseif self.curType == self.ComposeIndex then
			if self._cachedComposeIndex and self._cachedComposeIndex >= 0 and NotNil(self.listComposeUList) and self._cachedComposeIndex < self.listComposeUList.itemCount then
				local ret, btn = self.listComposeUList:TryGetChildAt(self._cachedComposeIndex)

				if ret and NotNil(btn) then
					btn:OnClickSimulate()

					if pg.game.input:isUsingGamepad() then
						CS.XGUI.Navigation.NavManager.Instance:FocusItem(btn)
					end
				end
			end
		elseif self._cachedSelectItem and self._cachedSelectIndex and self._cachedSelectIndex >= 0 and NotNil(self.itemList) and self._cachedSelectIndex < self.itemList.itemCount then
			self:selectItem(self._cachedSelectItem, true)

			self.itemListSelectedIndex = self._cachedSelectIndex

			self.itemList:SelectItem(self._cachedSelectIndex)

			if pg.game.input:isUsingGamepad() then
				local ret, btn = self.itemList:TryGetChildAt(self._cachedSelectIndex)

				if ret and NotNil(btn) then
					CS.XGUI.Navigation.NavManager.Instance:FocusItem(btn)
				end
			end
		end

		self._cachedSelectItem = nil
		self._cachedSelectIndex = nil
		self._cachedPetIndex = nil
		self._cachedComposeIndex = nil
	else
		self.uWidget:TryChangePage("ExpandState", 1)

		self._cachedSelectItem = self.curSelectItem
		self._cachedSelectIndex = self.itemListSelectedIndex
		self._cachedPetIndex = self.listPetUList and self.listPetUList.selectedIndex or -1
		self._cachedComposeIndex = self.curType == self.ComposeIndex and self.ctrl.curComposeData and self.composeListSelectedIndex or nil
		self.panelUWidget.visibility = CS.XGUI.EVisibility.HitTestInvisible

		self.uWidget:TryChangePage("FoldList", 0)

		if NotNil(self.itemFoldUPopupForm) then
			self.itemFoldUPopupForm:ClosePopUpForm()
		end

		self:selectItem(nil, true)

		if self.ctrl and self.ctrl.closePetDetail then
			self.ctrl:closePetDetail()
		end

		if self.curType == self.ComposeIndex and self.ctrl and self.ctrl.closeComposeDetail then
			self.ctrl:closeComposeDetail()
		end
	end

	if self.ctrl and self.ctrl.viewCtrlComponent then
		self.ctrl.viewCtrlComponent:refreshKeyHints()
		self.ctrl.viewCtrlComponent:setGamepadShowHint(not self.isExpand)
		self.ctrl.viewCtrlComponent:setEnable(not self.isExpand or not pg.game.input:isUsingGamepad())
	end

	if self.ctrl and self.ctrl.view.consoleInUWidget then
		LuaUIUtils.setUIViewVisible(self.ctrl.view.consoleInUWidget, not self.isExpand)
	end

	if self.ctrl and self.ctrl.onExpandChange then
		self.ctrl:onExpandChange(isExpand)
	end
end

function HomelandItemListComponent:selectType(typeId, keepIndex)
	if self.curType ~= typeId then
		self:redDot_RecordSubTypeRead(self.curType, self.curSubType)

		self.curSubType = nil
	end

	self.curType = typeId

	if self.curType == self.EmoTypeIndex then
		if self.ctrl.closeItemDetail then
			self.ctrl:closeItemDetail()
		end

		if self.ctrl.closeComposeDetail then
			self.ctrl:closeComposeDetail()
		end

		self:selectItem(nil, true)
		self.checkOwnBtn:SetActive(false)
		self.searchBtn:SetActive(false)
		self.btnImportUButton:SetActive(false)
		self:refreshSubTypeList(typeId, keepIndex)
		self:refreshPetList()
	elseif self.curType == self.ComposeIndex then
		if self.ctrl.closeItemDetail then
			self.ctrl:closeItemDetail()
		end

		if self.ctrl.closePetDetail then
			self.ctrl:closePetDetail()
		end

		self:selectItem(nil, true)
		self.checkOwnBtn:SetActive(false)
		self.searchBtn:SetActive(false)
		self.btnImportUButton:SetActive(true)
		self:refreshSubTypeList(typeId, keepIndex)
	else
		if self.ctrl.closePetDetail then
			self.ctrl:closePetDetail()
		end

		if self.ctrl.closeComposeDetail then
			self.ctrl:closeComposeDetail()
		end

		self.checkOwnBtn:SetActive(not self.isFurnitureStore)
		self.searchBtn:SetActive(true)
		self.btnImportUButton:SetActive(false)
		self:refreshSubTypeList(typeId, keepIndex)
	end
end

function HomelandItemListComponent:refreshPetList()
	self.uWidget:TryChangePage("FoldList", 0)

	local petDatas = self:getHomePetList()

	if self.ctrl.petId and not self.ctrl:isPetInCurrentEditArea(self.ctrl.petId) then
		self.ctrl:closePetDetail()
	end

	if #petDatas > 0 then
		self.uWidget:TryChangePage("Item", 3)
	else
		self.uWidget:TryChangePage("Item", 2)
		ClientTextUtils.setText(self.nullUSDFText, pg.getGameString("HOME_NO_PET_DESC"))
	end

	self.petDatas = petDatas

	local typeName = pg.getLocalizationText(self.typeList.selectedItem.name)

	typeName = typeName .. " " .. #petDatas .. "/" .. pg.space.petBoxMap:getSlotCount()

	ClientTextUtils.setText(self.subTypeTitle, typeName)
	self.listPetUList:SetList(petDatas)
end

function HomelandItemListComponent:getHomePetList()
	local pets = pg.me and pg.me.pets or {}
	local allocation = pg.space.allocation
	local facility = pg.space.facility
	local ornament = pg.space.ornament
	local spacePets = pg.space.pets
	local homePets = {}
	local areaId = self.ctrl and self.ctrl.getEditAreaId and self.ctrl:getEditAreaId() or Const.HOMELAND_AREA_TYPE.PRODUCE

	for idx = 1, pg.space.petBoxMap:getSlotCount() do
		local petId = pg.space.petBoxMap:getPetId(areaId, idx)
		local pet = petId and pets[petId]

		if pet then
			local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

			petInfo.slotIdx = idx
			petInfo.areaId = areaId

			local allocationInfo = areaId == Const.HOMELAND_AREA_TYPE.PRODUCE and allocation[petId] or nil
			local homePetInfo = spacePets[petId]

			if allocationInfo then
				local ornamentId = allocationInfo.ornamentId
				local facilityInfo = facility[ornamentId]

				if facilityInfo and facilityInfo.facilityState == allocationInfo.opId then
					local ornamentInfo = ornament[ornamentId]
					local homeTemplateID = ornamentInfo.homeId
					local facilityType = Utils.getHomeFacilityType(homeTemplateID)

					petInfo.isWorking = true
					petInfo.facilityType = facilityType
					petInfo.opId = allocationInfo.opId
					petInfo.workload = allocationInfo.workload
					petInfo.facilityInfo = facilityInfo
					petInfo.fitPersonality = allocationInfo.fitTalent
				end
			end

			local eventInfo = homePetInfo and homePetInfo:getHomeEventInfo(pg.space)

			if eventInfo then
				local eventType = HomeEventTextData[eventInfo.textId] and HomeEventTextData[eventInfo.textId].eventType

				if eventType then
					local eventTypeData = HomeEventTypeData[eventType]

					if eventTypeData then
						petInfo.eventUrl = eventTypeData.statusIcon
						petInfo.isWorking = false
					end
				end
			end

			homePets[#homePets + 1] = petInfo
		end
	end

	return homePets
end

function HomelandItemListComponent:setSelectTypeSubType(typeId, subTypeId)
	for idx, typeInfo in ipairs(self.typeInfo) do
		if typeInfo.typeId == typeId then
			self.typeList:SelectItem(idx - 1)

			break
		end
	end

	if subTypeId then
		for idx, subTypeInfo in ipairs(self.subTypeInfo) do
			if subTypeInfo.subTypeId == subTypeId then
				self.subTypeList:SelectItem(idx - 1)

				break
			end
		end
	end
end

function HomelandItemListComponent:locateTypeSubType(typeId, subTypeId)
	local typeIndex
	local typeInfoList = self.typeInfo

	for index, typeInfo in ipairs(typeInfoList) do
		if typeInfo.typeId == typeId then
			typeIndex = index - 1

			break
		end
	end

	if typeIndex == nil then
		return false
	end

	local selectItemWhenTypeChange = self.selectItemWhenTypeChange
	local isLocatingSelection = self.isLocatingSelection

	self.selectItemWhenTypeChange = false
	self.isLocatingSelection = true

	self.typeList:SelectItem(typeIndex, false)
	self:selectType(typeId)

	local subTypeIndex
	local subTypeInfoList = self.subTypeInfo

	for index, subTypeInfo in ipairs(subTypeInfoList) do
		if subTypeInfo.subTypeId == subTypeId then
			subTypeIndex = index - 1

			break
		end
	end

	if subTypeIndex == nil then
		self.selectItemWhenTypeChange = selectItemWhenTypeChange
		self.isLocatingSelection = isLocatingSelection

		return false
	end

	self.subTypeList:SelectItem(subTypeIndex, false)
	self:selectSubType(subTypeId)

	self.selectItemWhenTypeChange = selectItemWhenTypeChange
	self.isLocatingSelection = isLocatingSelection

	self.typeList:RedirectToCenter(typeIndex, false, true)
	self.subTypeList:RedirectToCenter(subTypeIndex, false, true)

	return true
end

function HomelandItemListComponent:locateItem(itemId)
	local objectInfo = HomeObjectData[itemId]

	if not objectInfo then
		return false
	end

	local typeId = objectInfo.type
	local subTypeId = objectInfo.subType
	local itemIds = (self.homeListData[typeId] or EMPTY_TABLE)[subTypeId] or EMPTY_TABLE
	local itemExists = false

	for _, listItemId in ipairs(itemIds) do
		if listItemId == itemId then
			itemExists = true

			break
		end
	end

	if not itemExists then
		return false
	end

	local curSelectItemId = self.curSelectItemId

	self.curSelectItemId = itemId

	if not self:locateTypeSubType(typeId, subTypeId) then
		self.curSelectItemId = curSelectItemId

		return false
	end

	local itemIndex
	local itemData = self.itemList.itemData

	for index, itemInfo in pairs(itemData) do
		if itemInfo.itemId == itemId then
			itemIndex = index

			break
		end
	end

	if itemIndex == nil then
		self.curSelectItemId = curSelectItemId

		return false
	end

	local itemInfo = self.itemList:GetData(itemIndex)

	self:selectItem(itemInfo, true)

	self.itemListSelectedIndex = itemIndex

	self.itemList:SelectItem(itemIndex, false)
	self.itemList:RedirectToCenter(itemIndex, false, true)
	self.uWidget:TryChangePage("FoldList", 0)

	return true
end

function HomelandItemListComponent:clearPendingComposeLocate(clearSelectionRecord)
	local locateInfo = self.pendingComposeLocateInfo

	self.pendingComposeLocateInfo = nil

	local shouldClearSelectionRecord = clearSelectionRecord and locateInfo and self.ctrl and self.ctrl.clearLastComposeSelection

	if shouldClearSelectionRecord then
		self.ctrl:clearLastComposeSelection(locateInfo.sourceType, locateInfo.blueprintId)
	end
end

function HomelandItemListComponent:locatePendingCompose(clearWhenMissing)
	local locateInfo = self.pendingComposeLocateInfo

	if not locateInfo then
		return false
	end

	if self:getComposeSourceTypeBySubType(self.curSubType) ~= locateInfo.sourceType then
		if clearWhenMissing then
			self:clearPendingComposeLocate(true)
		end

		return false
	end

	local composeIndex, composeData
	local composeItemData = self.listComposeUList.itemData

	for index, data in pairs(composeItemData) do
		if tostring(data._id) == locateInfo.blueprintId then
			composeIndex = index
			composeData = data

			break
		end
	end

	if composeIndex == nil then
		if clearWhenMissing then
			self:clearPendingComposeLocate(true)
		end

		return false
	end

	self:clearPendingComposeLocate()

	self.composeListSelectedIndex = composeIndex

	self.listComposeUList:RedirectToCenter(composeIndex, false, true)
	self.ctrl:refreshComposeDetailWindow(composeData)

	return true
end

function HomelandItemListComponent:locateCompose(sourceType, blueprintId)
	self:clearPendingComposeLocate()

	local subTypeId

	for composeSubTypeId, composeSourceType in pairs(ComposeSubTypeSourceType) do
		if composeSourceType == sourceType then
			subTypeId = composeSubTypeId

			break
		end
	end

	if subTypeId == nil then
		if self.ctrl and self.ctrl.clearLastComposeSelection then
			self.ctrl:clearLastComposeSelection(sourceType, tostring(blueprintId))
		end

		return false
	end

	self.pendingComposeLocateInfo = {
		sourceType = sourceType,
		blueprintId = tostring(blueprintId)
	}

	if not self:locateTypeSubType(self.ComposeIndex, subTypeId) then
		self:clearPendingComposeLocate(true)

		return false
	end

	return self:locatePendingCompose(not self.composeListWaitingResponse)
end

function HomelandItemListComponent:checkTypeVisible(typeId, typeData)
	typeData = typeData or HomeTypeData[typeId]

	if not typeData then
		return false
	end

	if typeId ~= self.FavoriteTypeIndex then
		if self.isCarGroupMode then
			if not typeData.showInCar then
				return false
			end
		elseif typeData.hideInHomeland then
			return false
		end

		if typeData.hideInStore and self.isFurnitureStore then
			return false
		end

		if not self.isFurnitureStore and self.ctrl and self.ctrl.getEditAreaId and not HomeLandUtils.isTypeAreaAllowed(typeId, self.ctrl:getEditAreaId()) then
			return false
		end
	end

	if typeId == self.EmoTypeIndex and not pg.game.home:checkEnableHomePet() then
		return false
	end

	return true
end

function HomelandItemListComponent:refreshTypeList()
	local typeInfo = {}
	local selectIndex

	for typeId, info in pairs(HomeTypeData) do
		if self:checkTypeVisible(typeId, info) then
			table.insert(typeInfo, {
				typeId = typeId,
				name = info.name,
				sortId = info.sortId or 0
			})
		end
	end

	local function sortFunc(a, b)
		return a.sortId < b.sortId
	end

	table.sort(typeInfo, sortFunc)

	for index, info in ipairs(typeInfo) do
		if info.typeId == self.curType then
			selectIndex = index
		end
	end

	self.typeInfo = typeInfo

	self.typeList:SetList(typeInfo)

	if #typeInfo == 0 then
		self:selectType(nil)
	elseif selectIndex then
		self.typeList:SelectItem(selectIndex - 1, false)
		self:selectType(self.curType, true)
	else
		self.typeList:SelectItem(0)
	end
end

function HomelandItemListComponent:refreshSubTypeList(typeId, keepIndex)
	local subTypeInfo = {}

	if typeId then
		local subTypeList = self.homeListData[typeId]
		local useConfiguredSubTypes = string.isNilOrEmpty(self.searchText) and not self.isSelectOwn or typeId == self.FavoriteTypeIndex or typeId == self.EmoTypeIndex or typeId == self.ComposeIndex

		if (not subTypeList or next(subTypeList) == nil) and useConfiguredSubTypes then
			subTypeList = HomeSubTypeData[typeId] or {}
		end

		subTypeList = subTypeList or {}

		for subTypeId, _ in pairs(subTypeList) do
			local info = HomeSubTypeData[typeId][subTypeId]

			if info then
				table.insert(subTypeInfo, {
					subTypeId = subTypeId,
					name = info.name,
					icon = info.iconId,
					sortId = info.sortId or 0
				})
			end
		end

		local function sortFunc(a, b)
			return a.sortId < b.sortId
		end

		table.sort(subTypeInfo, sortFunc)
	end

	self.subTypeInfo = subTypeInfo

	self.subTypeList:SetList(subTypeInfo)

	if keepIndex then
		local selectIndex

		for index, info in ipairs(subTypeInfo) do
			if info.subTypeId == self.curSubType then
				selectIndex = index
			end
		end

		if selectIndex then
			self.subTypeList:SelectItem(selectIndex - 1, false)
			self:selectSubType(self.curSubType)
		else
			self.subTypeList:SelectItem(0)
		end
	else
		self.subTypeList:SelectItem(0)
	end
end

function HomelandItemListComponent:selectSubType(subTypeId)
	if self.curSubType ~= subTypeId then
		self:redDot_RecordSubTypeRead(self.curType, self.curSubType)
	end

	self.curSubType = subTypeId

	if self.curType == self.ComposeIndex then
		if self.ctrl.closeComposeDetail then
			self.ctrl:closeComposeDetail()
		end

		self:refreshComposeList()
	else
		self:refreshItemList()
	end
end

function HomelandItemListComponent:redDot_RecordSubTypeRead(typeId, subTypeId)
	if not ClientHomelandUtils.isFurnitureRedDotType(typeId) or not subTypeId then
		return
	end

	ClientHomelandUtils.readFurnitureSubTypeNewItems(typeId, subTypeId, function(itemId, homeObjectInfo)
		return self:checkTypeValid(homeObjectInfo, itemId)
	end)

	local redDotPath = string.format(RedDotConst.RedDotPath.HOMELAND_FURNITURE_SUB_TYPE_NEW, typeId, subTypeId)

	pg.global.refreshRedDotState(redDotPath)
end

function HomelandItemListComponent:getFavPlaceIds()
	local favoritePlaceIds = {}
	local favList = self:getFavList()

	for i, favId in pairs(favList) do
		if HomeObjectData[favId] and HomeObjectData[favId].placeId and not favoritePlaceIds[HomeObjectData[favId].placeId] then
			favoritePlaceIds[HomeObjectData[favId].placeId] = i
		end
	end

	return favoritePlaceIds
end

function HomelandItemListComponent:getFavList()
	if self.isCarGroupMode then
		return pg.me.favoriteCarOrnamentList
	end

	return pg.me.favoriteOrnamentList
end

function HomelandItemListComponent:getComposeSourceTypeBySubType(subTypeId)
	return ComposeSubTypeSourceType[subTypeId]
end

function HomelandItemListComponent:getComposePlaceCount(data)
	local ornaments = data and data.ornaments

	if type(ornaments) ~= "table" or #ornaments == 0 then
		return 0
	end

	local requireCounts = {}

	for _, ornamentInfo in ipairs(ornaments) do
		local homeId = ornamentInfo and ornamentInfo.homeId

		if homeId then
			requireCounts[homeId] = (requireCounts[homeId] or 0) + 1
		end
	end

	local placeCount

	for homeId, needCount in pairs(requireCounts) do
		if needCount > 0 then
			local ownCount = ClientUtils.getItemCountById(homeId) or 0

			if pg.me:isInSelfHomeland() then
				ownCount = ownCount + ClientUtils.getHomelandItemCountById(homeId)
			end

			local currentCount = math.floor(ownCount / needCount)

			placeCount = placeCount and math.min(placeCount, currentCount) or currentCount
		end
	end

	return placeCount or 0
end

function HomelandItemListComponent:isComposeAreaAllowed(data)
	local ornaments = data and data.ornaments

	if type(ornaments) ~= "table" or #ornaments == 0 then
		return false
	end

	for _, ornamentInfo in ipairs(ornaments) do
		local homeId = ornamentInfo and ornamentInfo.homeId
		local homeObjectInfo = homeId and HomeObjectData[homeId]

		if not homeObjectInfo or not self:checkTypeValid(homeObjectInfo, homeId) then
			return false
		end
	end

	return true
end

function HomelandItemListComponent:getComposePlaceState(data)
	if not self:isComposeAreaAllowed(data) then
		return ComposePlaceState.AreaNotMatch, 0
	end

	local placeCount = self:getComposePlaceCount(data)

	if placeCount <= 0 then
		return ComposePlaceState.NotCollected, 0
	end

	return ComposePlaceState.Placeable, placeCount
end

function HomelandItemListComponent:isComposeBefore(a, b, sourceType)
	local aStateInfo = self.composePlaceStateMap[a]
	local bStateInfo = self.composePlaceStateMap[b]
	local aState = aStateInfo and aStateInfo.state or ComposePlaceState.AreaNotMatch
	local bState = bStateInfo and bStateInfo.state or ComposePlaceState.AreaNotMatch

	if aState ~= bState then
		return aState < bState
	end

	local aId = a and a._id
	local bId = b and b._id
	local aIdNumber = tonumber(aId)
	local bIdNumber = tonumber(bId)

	if sourceType == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
		if aIdNumber and bIdNumber and aIdNumber ~= bIdNumber then
			return aIdNumber < bIdNumber
		end

		return tostring(aId or "") < tostring(bId or "")
	end

	local timeField = sourceType == UIConst.HOME_DESIGN_MODE.MYDESIGN and "createdTs" or "savedTs"
	local aTime = tonumber(a and a[timeField]) or 0
	local bTime = tonumber(b and b[timeField]) or 0

	if aTime ~= bTime then
		return bTime < aTime
	end

	if aIdNumber and bIdNumber and aIdNumber ~= bIdNumber then
		return aIdNumber < bIdNumber
	end

	return tostring(aId or "") < tostring(bId or "")
end

function HomelandItemListComponent:onBlueprintListResult(response)
	response = response or {}

	if not response.flag then
		local locateInfo = self.pendingComposeLocateInfo

		if locateInfo and response.sourceType == locateInfo.sourceType then
			self.composeListWaitingResponse = false

			self:clearPendingComposeLocate(true)
		end

		return
	end

	if self.curType ~= self.ComposeIndex then
		return
	end

	local sourceType = self:getComposeSourceTypeBySubType(self.curSubType)

	if response.sourceType == sourceType then
		self:refreshComposeList()
		self:locatePendingCompose(true)
	end
end

function HomelandItemListComponent:onBlueprintDeleteResult(response)
	self:onBlueprintListResult(response)

	response = response or {}

	if not response.flag or self.curType ~= self.ComposeIndex then
		return
	end

	local sourceType = self:getComposeSourceTypeBySubType(self.curSubType)

	if response.sourceType ~= sourceType then
		return
	end

	local curComposeData = self.ctrl and self.ctrl.curComposeData
	local deletedBlueprintId = response.blueprintId

	if curComposeData and deletedBlueprintId and tostring(curComposeData._id) == tostring(deletedBlueprintId) and self.ctrl.closeComposeDetail then
		self.ctrl:closeComposeDetail()
	end
end

function HomelandItemListComponent:refreshComposeList()
	self.uWidget:TryChangePage("Item", 4)
	self.uWidget:TryChangePage("FoldList", 0)

	local sourceType = self:getComposeSourceTypeBySubType(self.curSubType)
	local composeList = pg.me:getHomeBlueprintCachedList(sourceType, UIConst.HOME_COMPOSE_MODE.COMBINATION)

	self.composeListWaitingResponse = composeList == nil

	local sortedComposeList = {}

	self.composePlaceStateMap = {}

	for _, data in pairs(composeList or EMPTY_TABLE) do
		if type(data) == "table" then
			local state, placeCount = self:getComposePlaceState(data)

			self.composePlaceStateMap[data] = {
				state = state,
				placeCount = placeCount
			}

			table.insert(sortedComposeList, data)
		end
	end

	table.sort(sortedComposeList, function(a, b)
		return self:isComposeBefore(a, b, sourceType)
	end)
	self.listComposeUList:SetList(sortedComposeList)

	if (sourceType == UIConst.HOME_DESIGN_MODE.MYDESIGN or sourceType == UIConst.HOME_DESIGN_MODE.SHAREDESIGN) and self.subTypeList and self.subTypeList.selectedItem then
		local maxPage = 0

		if sourceType == UIConst.HOME_DESIGN_MODE.MYDESIGN then
			maxPage = HomelandConfigData.maxUploadBlueprintCount or 10
		elseif sourceType == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
			maxPage = HomelandConfigData.maxSavedOtherBlueprintCount or 10
		end

		local typeName = pg.getLocalizationText(self.subTypeList.selectedItem.name)

		ClientTextUtils.setText(self.subTypeTitle, typeName .. " " .. #sortedComposeList .. "/" .. maxPage)

		if #sortedComposeList == 0 then
			self.uWidget:TryChangePage("Item", 2)
		end
	end
end

function HomelandItemListComponent:refreshItemList()
	if self.curType == self.ComposeIndex then
		self:refreshComposeList()

		return
	end

	pg.me:buildOrnamentAreaSnapshot()

	self.selectedItemLevel = self.isFurnitureStore and pg.global.uiMgr._homelandFurnitureStoreItemListCache or pg.global.uiMgr._homelandEditorItemListCache

	if self.selectedItemLevel == nil then
		self.selectedItemLevel = {}
	end

	self.itemGroups = {}

	local itemsInfo = {}
	local itemIds = (self.homeListData[self.curType] or EMPTY_TABLE)[self.curSubType]
	local favList = self:getFavList()

	if itemIds == nil then
		if self.curType ~= self.FavoriteTypeIndex then
			itemIds = {}
		elseif string.isNilOrEmpty(self.searchText) then
			itemIds = self:getFavList()
		else
			itemIds = {}

			for _, itemId in pairs(favList) do
				local info = self:getItemInfo(itemId)

				if info and string.find(info.name, self.searchText) then
					itemIds[#itemIds + 1] = itemId
				end
			end
		end
	end

	if #itemIds == 0 then
		self.uWidget:TryChangePage("Item", 2)
		ClientTextUtils.setText(self.nullUSDFText, pg.getGameString("FURNITURE_LIST_NULL"))
	else
		self.uWidget:TryChangePage("Item", self.curType == self.FavoriteTypeIndex and 1 or 0)
	end

	local typeName = pg.getLocalizationText(self.typeList.selectedItem.name)

	if string.isNilOrEmpty(self.searchText) and self.curType == self.FavoriteTypeIndex then
		typeName = typeName .. " " .. #favList .. "/" .. HomelandConfigData.maxFavoriteOrnamentCount

		ClientTextUtils.setText(self.subTypeTitle, typeName)
	end

	for _, itemId in ipairs(itemIds) do
		local info = self:getItemInfo(itemId)

		if info then
			if info.placeId and self.curType and self.curType ~= self.FavoriteTypeIndex then
				if not self.itemGroups[info.placeId] then
					self.itemGroups[info.placeId] = {}
				end

				table.insert(self.itemGroups[info.placeId], info)
			else
				table.insert(itemsInfo, info)
			end
		end
	end

	local favoritePlaceIds = self:getFavPlaceIds()

	local function sortFunc(a, b)
		if a.isFavorite ~= b.isFavorite then
			return a.isFavorite == true
		end

		if a.state ~= b.state then
			return a.state < b.state
		end

		if a.isFavorite and b.isFavorite and a.placeId and b.placeId then
			return favoritePlaceIds[a.placeId] > favoritePlaceIds[b.placeId]
		end

		return a.sortId < b.sortId
	end

	for idx in pairs(self.itemGroups) do
		table.sort(self.itemGroups[idx], sortFunc)

		local groupSelectedItem, cachedItem, selectItem, bestNormalItem, bestCanBuyItem

		for _, info in pairs(self.itemGroups[idx]) do
			if info.placeId and self.curSelectItemId ~= nil and info.itemId and info.itemId == self.curSelectItemId then
				selectItem = Utils.deepCopyTable(info)
			end

			if info.placeId and self.selectedItemLevel[info.placeId] ~= nil and info.itemId and info.itemId == self.selectedItemLevel[info.placeId] then
				cachedItem = Utils.deepCopyTable(info)
			end

			if info.state == ItemOwnState.Normal and (bestNormalItem == nil or info.level and bestNormalItem.level and info.level > bestNormalItem.level) then
				bestNormalItem = Utils.deepCopyTable(info)
			end

			if info.state == ItemOwnState.CanBuy and (bestCanBuyItem == nil or info.level and bestCanBuyItem.level and info.level > bestCanBuyItem.level) then
				bestCanBuyItem = Utils.deepCopyTable(info)
			end
		end

		groupSelectedItem = selectItem or cachedItem or bestNormalItem or bestCanBuyItem

		if groupSelectedItem == nil then
			groupSelectedItem = Utils.deepCopyTable(self.itemGroups[idx][1])
		end

		groupSelectedItem.isFavorite = favoritePlaceIds[groupSelectedItem.placeId] ~= nil

		table.insert(itemsInfo, groupSelectedItem)
	end

	table.sort(itemsInfo, sortFunc)

	self.itemsInfo = itemsInfo

	self.itemList:SetList(itemsInfo)

	if #itemsInfo == 0 and not self.isFurnitureStore then
		self:selectItem(nil, false)
	end

	if self.itemList.selectedIndex < 0 then
		self.uWidget:TryChangePage("FoldList", 0)
	end

	pg.me:clearOrnamentAreaSnapshot()
end

function HomelandItemListComponent:refreshFoldList()
	local selectedItem = self.itemList:GetData(self.itemList.selectedIndex)
	local selectedItemGroup = selectedItem and selectedItem.placeId and self.itemGroups[selectedItem.placeId]

	if not selectedItemGroup then
		self.foldListUList:SetList(EMPTY_TABLE)
		self.uWidget:TryChangePage("FoldList", 0)

		return
	end

	self.foldListUList:SetList(selectedItemGroup)

	if not self.curSelectItem then
		return
	end

	local curSelectItemId = self.curSelectItem.itemId
	local foldListItemData = self.foldListUList.itemData

	for idx, listItemData in pairs(foldListItemData) do
		if curSelectItemId == listItemData.itemId then
			self.foldListUList:RedirectToCenter(idx)
		end
	end
end

function HomelandItemListComponent:refreshFavState(list, index, isFavorite)
	if index == -1 then
		return
	end

	local data = list:GetData(index)

	data.isFavorite = isFavorite

	list:SetElement(index, data)
end

function HomelandItemListComponent:refreshSearchInfo()
	if string.isNilOrEmpty(self.searchText) then
		self.boxFilter:SetActive(false)

		return
	end

	self.boxFilter:SetActive(true)

	local objectRef = self.boxFilter:GetComponent("ObjectReference")
	local searchText = objectRef:GetRefValue("searchText")

	ClientTextUtils.setText(searchText, self.searchText == nil and "" or pg.getFormatText(pg.getGameString(ClientTextUtils.getGameString("HOME_SEARCH_RESULT")), self.searchText, self.searchResultNum))
end

function HomelandItemListComponent:onCloseSearchBtnClick()
	self:setSearchInfo(nil)

	if self.resetSearchKeyProgressPress then
		self.resetSearchKeyProgressPress:ProgressToValue(0, nil, 0)
	end
end

function HomelandItemListComponent:setSearchInfo(searchText)
	self.searchText = searchText

	if searchText then
		pg.game.home.lastSearchText = searchText
	end

	self:refreshSearchInfo()
	self:updateHomeListData()
end

function HomelandItemListComponent:updateHomeListData()
	pg.me:buildOrnamentAreaSnapshot()
	table.clear(self.homeListData)

	self.searchResultNum = 0

	for type, typeInfo in pairs(RevertHomeObjectData) do
		if self:checkTypeVisible(type) then
			for subType, itemIds in pairs(typeInfo or EMPTY_TABLE) do
				for _, itemId in ipairs(itemIds or EMPTY_TABLE) do
					local info = self:getItemInfo(itemId)

					if info then
						local valid = true

						if not string.isNilOrEmpty(self.searchText) and not string.find(info.name, self.searchText) then
							valid = false
						end

						if self.isSelectOwn and info.state ~= ItemOwnState.Normal then
							valid = false
						end

						if not info.isReleased then
							valid = false
						end

						if valid then
							self.homeListData[type] = self.homeListData[type] or {}
							self.homeListData[type][subType] = self.homeListData[type][subType] or {}

							table.insert(self.homeListData[type][subType], itemId)

							self.searchResultNum = self.searchResultNum + 1
						end
					end
				end
			end
		end
	end

	self:refreshTypeList()
	self:refreshSearchInfo()
	pg.me:clearOrnamentAreaSnapshot()
end

function HomelandItemListComponent:checkNameValid(searchText)
	if string.isNilOrEmpty(searchText) then
		return true
	end

	for objectId, objectInfo in pairs(HomeObjectData) do
		if objectInfo.type and objectInfo.subType and self:checkTypeVisible(objectInfo.type) and self:checkTypeValid(objectInfo, objectId) and ClientHomelandUtils.getFurnitureReleaseState(objectId).isReleased then
			local name = pg.getLocalizationText(objectInfo.name)

			if string.find(name, searchText) then
				return true
			end
		end
	end

	return false
end

function HomelandItemListComponent:onSearchBtnClick()
	pg.global.ui.tips:showCommonInput(pg.getGameString("SEARCH_TITLE"), function(newName)
		if not self:checkNameValid(newName) then
			pg.global.showBubbleMessage(NoticeDef.HOME_PET_SEARCH_TEXT_INVALID)

			return true
		end

		self:setSearchInfo(newName)
	end, function()
		return
	end, {
		characterLimit = 14,
		text = pg.game.home.lastSearchText or ""
	})
end

function HomelandItemListComponent:checkTypeValid(homeObjectData, templateId)
	if not ClientHomelandUtils.isFurnitureAvailableInArea(templateId) then
		return false
	end

	if self.isCarGroupMode then
		return homeObjectData.canCarPlace
	end

	if not homeObjectData.canHomePlace then
		return false
	end

	if not self.isFurnitureStore and self.ctrl and self.ctrl.getEditAreaId then
		local areaId = self.ctrl:getEditAreaId()

		if not HomeLandUtils.isOrnamentAreaAllowed(templateId, areaId) then
			return false
		end
	end

	return true
end

function HomelandItemListComponent:getItemInfo(itemId)
	local itemData = ItemData[itemId] or {}
	local homeObjectData = HomeObjectData[itemId] or {}

	if not self:checkTypeValid(homeObjectData, itemId) then
		return nil
	end

	local itemCount = ClientUtils.getItemCountById(itemId)

	if pg.me:isInSelfHomeland() then
		itemCount = itemCount + ClientUtils.getHomelandItemCountById(itemId)
	end

	local releaseState = ClientHomelandUtils.getFurnitureReleaseState(itemId)
	local state = ItemOwnState.Normal
	local lockText = ""

	if itemCount <= 0 and not self.isFurnitureStore then
		state = ItemOwnState.NotHave

		local maxNum = self.ctrl:getOrnamentBuyMaxPlaceNum(itemId)
		local canBuyMore = maxNum > self.ctrl:getOrnamentPlaceIdCurPlaceNum(itemId)

		if canBuyMore and self.curType ~= self.ItemTypeIndex and not releaseState.isOffShelf then
			state = ItemOwnState.CanBuy
		end
	end

	local unlockState = ClientHomelandUtils.getFurnitureUnlockState(itemId, true)

	if unlockState.isLocked and (self.isFurnitureStore or itemCount <= 0) then
		state = ItemOwnState.Locked
		lockText = unlockState.lockText
	end

	local numCurrent = itemCount
	local curType, curLevel = Utils.getHomeOrnamentCurLevelInfo(itemId)
	local iconUrl, levelText, infoText

	if state == ItemOwnState.Locked then
		infoText = pg.getGameString("HOMELAND_ITEM_LOCKED")
	elseif releaseState.isOffShelf and (self.isFurnitureStore or itemCount <= 0) then
		state = ItemOwnState.SoldOut
		infoText = pg.getGameString("HOMELAND_ITEM_SOLD_OUT")
	elseif self.isFurnitureStore and self.ctrl:getOrnamentPlaceIdCurPlaceNum(itemId) >= self.ctrl:getOrnamentMaxPlaceNum(itemId) then
		state = ItemOwnState.SoldOut
		infoText = pg.getGameString("HOMELAND_ITEM_SOLD_OUT")
	elseif homeObjectData.getWay == 1 then
		local costItemId = homeObjectData.buyMoneyType
		local costItemNum = homeObjectData.buyMoneyNum

		if not self.isFurnitureStore and pg.space and pg.space.demoMode == true and Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_IDS[itemId] then
			costItemId = Const.HOMELAND_DEMO_SHELL_ITEM_ID
			costItemNum = Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_PRICE
		end

		if not costItemId or not costItemNum then
			return
		end

		infoText = LuaUIUtils.getItemCountConsumeShowColorRedOnlyText(costItemId, costItemNum, false)

		local hasNum = ClientUtils.getItemCountById(costItemId)

		infoText = hasNum < costItemNum and "<style=Debuff>" .. costItemNum .. "</style>" or tostring(costItemNum)

		local iconType = costItemId == Const.HOMELAND_DEMO_SHELL_ITEM_ID and LuaUIUtils.ITEM_ICON_TYPE.ICON_NORMAL or LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL

		iconUrl = LuaUIUtils.getIconByItemId(costItemId, iconType)
	elseif homeObjectData.getWay == 2 then
		local canRedeem = true

		if homeObjectData.buyItemId1 and homeObjectData.buyItemNum1 then
			local ownCount = ClientUtils.getItemCountById(homeObjectData.buyItemId1)

			if pg.me:isInSelfHomeland() then
				ownCount = ownCount + ClientUtils.getHomelandItemCountById(homeObjectData.buyItemId1)
			end

			if ownCount < homeObjectData.buyItemNum1 then
				canRedeem = false
			end
		end

		if homeObjectData.buyItemId2 and homeObjectData.buyItemNum2 then
			local ownCount = ClientUtils.getItemCountById(homeObjectData.buyItemId2)

			if pg.me:isInSelfHomeland() then
				ownCount = ownCount + ClientUtils.getHomelandItemCountById(homeObjectData.buyItemId2)
			end

			if ownCount < homeObjectData.buyItemNum2 then
				canRedeem = false
			end
		end

		if canRedeem then
			infoText = pg.getGameString("HOMELAND_ITEM_CONVERTIBLE")
		else
			infoText = "<style=Debuff>" .. pg.getGameString("APPEARANCE_PAY_FAIL") .. "</style>"
		end
	elseif homeObjectData.getWay == 3 then
		infoText = pg.getGameString("HOMELAND_ITEM_OBTAINABLE")

		for _, sourceId in ipairs(homeObjectData.buySource or EMPTY_TABLE) do
			local sourceData = ItemSourceData[sourceId]
			local sourceDesc = sourceData and sourceData.desc and pg.getLocalizationText(sourceData.desc)

			if not string.isNilOrEmpty(sourceDesc) then
				infoText = sourceDesc

				break
			end
		end
	end

	if curLevel then
		levelText = "Lv." .. curLevel
	end

	local isItemFavorite = false
	local favList = self:getFavList()

	if favList then
		for _, favItemId in pairs(favList) do
			if favItemId == itemId then
				isItemFavorite = true

				break
			end
		end
	end

	local numTextInfo

	if not self.isFurnitureStore then
		if itemCount > 0 or self.curType == self.ItemTypeIndex then
			numTextInfo = itemCount
			iconUrl = AddressDataConst.HOME_ITEM_STORED
		else
			local maxNum = self.ctrl:getOrnamentMaxPlaceNum(itemId)
			local placeItemCount = self.ctrl:getOrnamentCurPlaceNum(itemId)

			if maxNum <= placeItemCount then
				numTextInfo = itemCount
				iconUrl = AddressDataConst.HOME_ITEM_STORED
			end
		end
	end

	numTextInfo = numTextInfo or infoText

	local itemInfo = {
		itemId = itemId,
		name = pg.getLocalizationText(homeObjectData.name) or "",
		state = state,
		iconUrl = iconUrl,
		numText = numTextInfo,
		quality = itemData.quality,
		icon = itemData.icon,
		level = curLevel,
		levelText = levelText,
		sortId = homeObjectData.sortId or itemId,
		placeId = homeObjectData.placeId,
		isFavorite = isItemFavorite,
		lockText = lockText,
		conditionLocked = unlockState.conditionLocked,
		drawingLocked = unlockState.drawingLocked,
		isReleased = releaseState.isReleased,
		isOffShelf = releaseState.isOffShelf
	}

	return itemInfo
end

function HomelandItemListComponent:deselectItem()
	if self.curSelectItem then
		self.curSelectItem = nil

		self.itemList:RefreshList()
	end
end

function HomelandItemListComponent:cancelSelect()
	self.curSelectItem = nil

	self.itemList:RefreshList()
end

function HomelandItemListComponent:selectItem(itemInfo, shouldRefreshItemList, keepComposeRequest)
	if not self.ctrl then
		return
	end

	if shouldRefreshItemList == nil then
		shouldRefreshItemList = true
	end

	self.curSelectItem = itemInfo
	self.curSelectItemId = itemInfo and itemInfo.itemId or nil

	if shouldRefreshItemList then
		self.itemList:RefreshList()
		self.foldListUList:RefreshList()
	end

	self.ctrl:onSelectItem(itemInfo and itemInfo.itemId, keepComposeRequest)
end

function HomelandItemListComponent:expandFoldPopup(listIndex)
	if self.curType == self.FavoriteTypeIndex then
		return
	end

	local data = self.itemList:GetData(listIndex)

	if not data or not data.placeId then
		return
	end

	local group = self.itemGroups[data.placeId]

	if not group or #group <= 1 then
		return
	end

	local ret, item = self.itemList:TryGetChildAt(listIndex)

	if not ret or not NotNil(item) then
		return
	end

	self.itemListSelectedIndex = listIndex
	self.showFoldList = true

	self.uWidget:TryChangePage("FoldList", 1)
	self.foldListUList:SetList(group)

	for idx, listItemData in pairs(self.foldListUList.itemData) do
		if self.curSelectItem and self.curSelectItem.itemId == listItemData.itemId then
			self.foldListUList:RedirectToCenter(idx)
		end
	end

	self.itemFoldUPopupForm:SetModal(false)
	self.itemFoldUPopupForm:SetPadding(20)
	self.itemFoldUPopupForm:SetAutoVertical(true, false)
	self.itemFoldUPopupForm:OpenPopup(item.transform:GetComponent("RectTransform"), false)

	local HomeObjectPlaceData = require("Data.home_object_place_data")

	ClientTextUtils.setText(self.foldListTitleUSDFText, HomeObjectPlaceData[data.placeId][1].name)
end

function HomelandItemListComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		local UIConst = require("Const.UIConst")
	end

	self:setExpand(self.isExpand)
end

function HomelandItemListComponent:switchPreType()
	local currIndex = self.typeList.selectedIndex
	local preIndex = (currIndex - 1) % #self.typeInfo

	if preIndex ~= currIndex then
		self.typeList:SelectItem(preIndex)
	end
end

function HomelandItemListComponent:switchNextType()
	local currIndex = self.typeList.selectedIndex
	local nextIndex = (currIndex + 1) % #self.typeInfo

	if nextIndex ~= currIndex then
		self.typeList:SelectItem(nextIndex)
	end
end

function HomelandItemListComponent:switchPreSubType()
	local currIndex = self.subTypeList.selectedIndex
	local preIndex = (currIndex - 1) % #self.subTypeInfo

	if preIndex ~= currIndex then
		self.subTypeList:SelectItem(preIndex)
	end
end

function HomelandItemListComponent:switchNextSubType()
	local currIndex = self.subTypeList.selectedIndex
	local nextIndex = (currIndex + 1) % #self.subTypeInfo

	if nextIndex ~= currIndex then
		self.subTypeList:SelectItem(nextIndex)
	end
end

function HomelandItemListComponent:renderHomePetInfo(button, data)
	local objectReference = button:GetComponent("ObjectReference")
end

return HomelandItemListComponent
