-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFurnitureComposeDetail\\HomelandFurnitureComposeDetailCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandFurnitureComposeDetailCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local HomeObjectData = require("Data.home_object_data")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeBlueprintUtils = require("Common.Homeland.HomeBlueprintUtils")
local NoticeDef = require("Common.NoticeDef")
local HomelandFurnitureComposeDetailCtrl = Class.LightClass("HomelandFurnitureComposeDetailCtrl", UICtrl)
local HOME_OBJECT_TYPE_PRODUCE = 1
local HOME_OBJECT_TYPE_DECORATION = 2

HomelandFurnitureComposeDetailCtrl.messages = {
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountChanged",
		true
	}
}

function HomelandFurnitureComposeDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isPhotoOpening = false
	self.detailData = info.detailData
	self.designIndex = info.designIndex
	self.composeIndex = info.composeIndex
	self.photoContext = info.photoContext
	self.carGroup = info.carGroup
	self.coverImageKey = self.detailData.coverImageKeys and self.detailData.coverImageKeys[1]
	self.capturedCoverImageKey = nil
	self.isModify = false
	self.composeItemCountMap = nil
	self.titleName = self.detailData.name or ""
	self.description = self.detailData.description or ""
	self.isUploading = false
	self.isDeleting = false
	self.deleteCode = nil

	if self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE and self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION then
		self.description = pg.getGameString("HOMELAND_COMPOSE_DEFAULT_DESCRIPTION")
		self.titleName = pg.getGameString("HOMELAND_COMPOSE_BASE_COMBINATION")
	end

	self.view.btnPhotoUButton:TryChangePage("NoPic", string.isNilOrEmpty(self.coverImageKey) and 1 or 0)
	self.view.switchUWidget:SetActive((self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE or self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN) and not string.isNilOrEmpty(self.coverImageKey))
	ClientTextUtils.setText(self.view.txtComposeNameUSDFText, self.titleName)
	self:refreshComposeDetailInfo()
	self:loadCoverImage()
end

function HomelandFurnitureComposeDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btn3thUButton.luaClick()
		self:onDeleteBtnClick()
	end

	function self.view.btnCopyIDUButton.luaClick()
		local copyText

		if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN then
			copyText = self.detailData and self.detailData.code
		elseif self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
			copyText = self.detailData and self.detailData.ownerName
		end

		if string.isNilOrEmpty(copyText) then
			return
		end

		UIUtils.ClipboardWriter(copyText)
		pg.global.ui.tips:showTextTip(pg.getGameString("GM_TIPS_COPY_SUCCESS"))
	end

	function self.view.btn2ndUButton.luaClick()
		self:onDeleteBtnClick()
	end

	function self.view.btn1stUButton.luaClick()
		self:onSaveBtnClick()
	end

	function self.view.btnEditComposeNameUButton.luaClick()
		if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN or self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
			self:onEditNameBtnClick()
		end
	end

	function self.view.btnDescUButton.luaClick()
		if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN or self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
			self:onEditDescBtnClick()
		end
	end

	function self.view.btnPhotoUButton.luaClick()
		self:onPhotoBtnClick()
	end

	function self.view.listDetailsUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtSizeUSDFText = objectReference:GetRefValue("txtSizeUSDFText")
		local txtNumSizeUSDFText = objectReference:GetRefValue("txtNumSizeUSDFText")
		local iconSizeUImage = objectReference:GetRefValue("iconSizeUImage")

		ClientTextUtils.setText(txtSizeUSDFText, data.name)
		ClientTextUtils.setText(txtNumSizeUSDFText, data.info)

		iconSizeUImage.url = data.icon
	end

	function self.view.listFurnitureUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		local listUList = objectReference:GetRefValue("listUList")
		local titleUButton = objectReference:GetRefValue("titleUButton")
		local haveCountTable = {}
		local allNum = 0

		for _, info in ipairs(data.ornamentIdList) do
			local composeNum = info.count or 0
			local ownNum = pg.me:getItemCountById(info.homeId) or 0

			allNum = allNum + math.min(ownNum, composeNum)
			haveCountTable[info.homeId] = ownNum
		end

		local titleText = data.title .. ": "

		if self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
			titleText = titleText .. data.count
		else
			titleText = titleText .. allNum .. "/" .. data.count
		end

		ClientTextUtils.setText(txtTitleUSDFText, titleText)

		local active = true

		listUList:SetActive(active)
		button:TryChangePage("expand", 1)

		function titleUButton.luaClick()
			active = not active

			listUList:SetActive(active)
			button:TryChangePage("expand", active and 1 or 0)
		end

		function listUList.luaRenderItem(_button, _index, _data)
			local _objectReference = _button:GetComponent("ObjectReference")
			local itemUButton = _objectReference:GetRefValue("itemUButton")
			local txtNameUSDFText = _objectReference:GetRefValue("txtNameUSDFText")
			local txtNumUSDFText = _objectReference:GetRefValue("txtNumUSDFText")
			local homeId = _data.homeId
			local itemData = ItemData[homeId] or {}
			local iconObjectReference = itemUButton:GetComponent("ObjectReference")
			local itemIconUImage = iconObjectReference and iconObjectReference:GetRefValue("itemIconUImage")

			if itemIconUImage then
				itemIconUImage.url = itemData.icon
			end

			itemUButton:TryChangePage("Quality", itemData.quality or 0)
			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(itemData.itemName or ""))

			local composeNum = _data.count or 0

			if self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
				ClientTextUtils.setText(txtNumUSDFText, tostring(composeNum))
			else
				local ownNum = haveCountTable[_data.homeId] or 0
				local ownNumText = LuaUIUtils.formatShortItemNum(ownNum)

				if ownNum < composeNum then
					ownNumText = string.format("<style=%s>%s</style>", UIConst.ITEM_STATE_COLOR[UIConst.ITEM_STATE.LACK], ownNumText)
				end

				local composeNumText = LuaUIUtils.formatShortItemNum(composeNum)

				ClientTextUtils.setText(txtNumUSDFText, string.format("<nobr>%s/%s</nobr>", ownNumText, composeNumText))
			end

			if self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
				_button.luaClick = nil
			else
				function _button.luaClick()
					pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE, {
						curItemId = homeId,
						carGroup = self.carGroup
					})
				end
			end

			function itemUButton.luaClick()
				LuaUIUtils.popupPropTip({
					id = homeId,
					itemId = homeId,
					targetRect = itemUButton
				})
			end
		end

		listUList:SetList(data.ornamentIdList)
	end

	if pg.global.navMgr then
		self:addNavFocusListener(function()
			if self.view then
				self:refreshConsoleBarState()
			end
		end, "HomelandFurnitureComposeDetail")
	end
end

function HomelandFurnitureComposeDetailCtrl:refreshConsoleBarState()
	local currentFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local currentFocusedUContent = pg.global.navMgr.CurrentFocusedUContent
	local isInRightPanal = currentFocusedGroupName == "ScaleRight"
	local isInLeftPanal = currentFocusedGroupName == "ListFurniture"
	local isListItem = currentFocusedGroupName == "ListFurniture" and currentFocusedUContent and currentFocusedUContent.gameObject.name == "UI_Node_Home_NewCompose_Cell(Clone)"
	local isCreate = self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("FurnitureComposeDetail_List", isInRightPanal)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("FurnitureComposeDetail_Item", isListItem and not isCreate)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("FurnitureComposeDetail_Choose", isInLeftPanal)
end

function HomelandFurnitureComposeDetailCtrl:refreshSaveButton()
	if not self.view then
		return
	end

	local active = self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE

	active = active or self.isModify

	self.view.btn1stUButton:SetActive(active)
end

function HomelandFurnitureComposeDetailCtrl:close()
	if self.isModify then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOMELAND_COMPOSE_UNSAVED_EXIT_CONFIRM"), function()
			if not self.view then
				return
			end

			self.isModify = false

			UICtrl.close(self)
		end)

		return
	end

	UICtrl.close(self)
end

function HomelandFurnitureComposeDetailCtrl:refreshComposeDetailInfo()
	self.view.widget:TryChangePage("Type", self.composeIndex - 1)

	local titleName = ""

	if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN then
		titleName = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_MY_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_MY_PLAN")
	elseif self.designIndex == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
		titleName = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_SYSTEM_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_SYSTEM_PLAN")
	elseif self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
		titleName = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_SHARE_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_SHARE_PLAN")
	elseif self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
		titleName = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_CREATE_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_CREATE_PLAN")
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, titleName)
	ClientTextUtils.setText(self.view.txtGoUSDFText, pg.getGameString("HOMELAND_COMPOSE_GO_PHOTO"))

	local canOperation = self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE or self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN

	self.view.txtGoUSDFText:SetActive(canOperation)

	self.view.btnPhotoUButton.interactable = canOperation

	local descriptionText = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_COMBINATION_DESC") or pg.getGameString("HOMELAND_COMPOSE_PLAN_DESC")

	ClientTextUtils.setText(self.view.txtTitleDescUSDFText, descriptionText)
	ClientTextUtils.setText(self.view.txtDescUSDFText, self.description)

	local saveText = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_SAVE_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_SAVE_PLAN")

	ClientTextUtils.setText(self.view.txtSaveUSDFText, saveText)

	local codeText = self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_COMBINATION_CODE") or pg.getGameString("HOMELAND_COMPOSE_PLAN_CODE")

	if self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
		codeText = pg.getGameString("HOMELAND_COMPOSE_DESIGNER")
	end

	ClientTextUtils.setText(self.view.txtTitleUSDFText, codeText .. ": ")

	if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN then
		ClientTextUtils.setText(self.view.txtIDUSDFText, self.detailData.code or "")
	elseif self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
		ClientTextUtils.setText(self.view.txtIDUSDFText, self.detailData.ownerName or "")
	end

	self.view.btnDescUButton.interactable = canOperation

	self.view.btnCopyIDUButton:SetActive(self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN or self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN)
	self:refreshSaveButton()

	local needDelete = self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN or self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN

	self.view.btn2ndUButton:SetActive(needDelete and self.composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION)
	self.view.btn3thUButton:SetActive(needDelete and self.composeIndex == UIConst.HOME_COMPOSE_MODE.PLAN)
	self.view.iconUWidget:SetActive(canOperation)
	self.view.iconEditUImage:SetActive(canOperation)
	ClientTextUtils.setText(self.view.txtPreviewUSDFText, pg.getGameString("DELETE"))

	local detailsList = {}
	local rangeSize = self.detailData.rangeSize

	if not rangeSize or #rangeSize == 0 then
		rangeSize = {
			0,
			0,
			0
		}
	end

	table.insert(detailsList, {
		icon = "$UI_Img_Home_FurnitureComposee_Size.png",
		name = pg.getGameString("HOMELAND_COMPOSE_SIZE"),
		info = rangeSize[1] .. "×" .. rangeSize[2] .. "×" .. rangeSize[3]
	})
	table.insert(detailsList, {
		icon = "$UI_Img_Home_FurnitureComposee_Live.png",
		name = pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE"),
		info = self.detailData.comfortValue or 0
	})
	table.insert(detailsList, {
		icon = "$UI_Img_Home_FurnitureComposee_Load.png",
		name = pg.getGameString("HOMELAND_COMPOSE_LOAD_VALUE"),
		info = self.detailData.loadValue or 0
	})
	self.view.listDetailsUList:SetList(detailsList)

	local detailList = self:getDetailList()

	self.view.listFurnitureUList:SetList(detailList)
	pg.global.navMgr:SetNavGroupForceNonInteractable("ScaleRight", not canOperation)
end

function HomelandFurnitureComposeDetailCtrl:getComposeItemCountMap()
	if self.composeItemCountMap then
		return self.composeItemCountMap
	end

	local countMap = {}

	for _, homeId in ipairs(self.detailData.homeIdList or EMPTY_TABLE) do
		if homeId then
			countMap[homeId] = (countMap[homeId] or 0) + 1
		end
	end

	self.composeItemCountMap = countMap

	return countMap
end

function HomelandFurnitureComposeDetailCtrl:onItemCountChanged(data)
	if self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE then
		return
	end

	local itemId = data and data.itemId

	if not itemId then
		return
	end

	local countMap = self:getComposeItemCountMap()

	if not countMap[itemId] then
		return
	end

	self.view.listFurnitureUList:RefreshList()
end

function HomelandFurnitureComposeDetailCtrl:getDetailList()
	local list = {}
	local produceList = {}
	local decorationList = {}
	local countMap = self:getComposeItemCountMap()
	local homeIds = {}

	for homeId, _ in pairs(countMap) do
		table.insert(homeIds, homeId)
	end

	table.sort(homeIds)

	local produceCount = 0
	local decorationCount = 0

	for _, homeId in ipairs(homeIds) do
		local objectData = HomeObjectData[homeId]
		local itemData = {
			homeId = homeId,
			count = countMap[homeId]
		}

		if objectData and objectData.type == HOME_OBJECT_TYPE_PRODUCE then
			table.insert(produceList, itemData)

			produceCount = produceCount + countMap[homeId]
		else
			table.insert(decorationList, itemData)

			decorationCount = decorationCount + countMap[homeId]
		end
	end

	if #produceList > 0 then
		table.insert(list, {
			title = pg.getGameString("HOMELAND_COMPOSE_FACILITY_LIST"),
			ornamentIdList = produceList,
			count = produceCount
		})
	end

	if #decorationList > 0 then
		table.insert(list, {
			title = pg.getGameString("HOMELAND_COMPOSE_FURNITURE_LIST"),
			ornamentIdList = decorationList,
			count = decorationCount
		})
	end

	return list
end

function HomelandFurnitureComposeDetailCtrl:onPhotoBtnClick()
	local isCreatePhoto = self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE
	local isMyDesignPhoto = self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN

	if self.isPhotoOpening or not isCreatePhoto and not isMyDesignPhoto or self.composeIndex ~= UIConst.HOME_COMPOSE_MODE.COMBINATION then
		return
	end

	local cameraTargetInfo

	if isCreatePhoto then
		local photoContext = self.photoContext

		cameraTargetInfo = photoContext and photoContext.cameraTargetInfo

		if not cameraTargetInfo or not cameraTargetInfo.center then
			return
		end
	end

	self.isPhotoOpening = true

	local photo = pg.global.ui.photo

	photo:open({
		photoMode = photo.ModeType.HOMELAND_MODE,
		photoCameraTargetInfo = cameraTargetInfo,
		usePhotoCallback = function(sprite, imageKey)
			if not self.view or string.isNilOrEmpty(imageKey) then
				if sprite then
					pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
				end

				return
			end

			local previousCapturedImageKey = self.capturedCoverImageKey

			if self:setCoverImageSprite(sprite, imageKey) then
				self.capturedCoverImageKey = imageKey

				if previousCapturedImageKey and previousCapturedImageKey ~= imageKey then
					pg.me:removeHomeBlueprintCoverImage(previousCapturedImageKey)
				end

				if isMyDesignPhoto then
					self.isModify = true

					self:refreshSaveButton()
				end
			else
				pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
			end
		end
	}, function()
		if self.view and isCreatePhoto then
			self:setPhotoSceneActive(true)
		end
	end, function()
		if not self.view then
			return
		end

		self.isPhotoOpening = false

		if isCreatePhoto then
			self:setPhotoSceneActive(false)
		end
	end)
end

function HomelandFurnitureComposeDetailCtrl:setPhotoSceneActive(active)
	if self.designIndex ~= UIConst.HOME_DESIGN_MODE.CREATE then
		return
	end

	local photoContext = self.photoContext

	if photoContext and photoContext.setSceneActive then
		photoContext.setSceneActive(active)
	end
end

function HomelandFurnitureComposeDetailCtrl:setCoverImageSprite(sprite, imageKey)
	imageKey = imageKey or self.coverImageKey

	if not sprite or string.isNilOrEmpty(imageKey) or not self.view then
		return false
	end

	if not pg.me:cacheHomeBlueprintCoverImage(imageKey, sprite) then
		return false
	end

	self.coverImageKey = imageKey
	self.view.imgPicUImage.url = nil
	self.view.imgPicUImage.sprite = sprite

	self.view.btnPhotoUButton:TryChangePage("NoPic", 0)
	self.view.switchUWidget:SetActive(self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE or self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN)

	return true
end

function HomelandFurnitureComposeDetailCtrl:loadCoverImage()
	local image = self.view.imgPicUImage
	local imageKey = self.coverImageKey
	local imageUrl = self.designIndex == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN and self.detailData.image or nil

	image.sprite = nil

	if not string.isNilOrEmpty(imageUrl) then
		image.url = imageUrl

		self.view.btnPhotoUButton:TryChangePage("NoPic", 0)

		return
	end

	if string.isNilOrEmpty(imageKey) then
		return
	end

	pg.me:loadHomeBlueprintCoverImage(imageKey, function(sprite, resultKey)
		if not self.view or self.coverImageKey ~= resultKey or resultKey ~= imageKey or not sprite or not NotNil(sprite) then
			return
		end

		local currentImage = self.view.imgPicUImage

		if not currentImage or not NotNil(currentImage) then
			return
		end

		currentImage.url = nil
		currentImage.sprite = sprite

		self.view.btnPhotoUButton:TryChangePage("NoPic", 0)
	end)
end

function HomelandFurnitureComposeDetailCtrl:onSaveBtnClick()
	if self.isUploading then
		return
	end

	if self.composeIndex ~= UIConst.HOME_COMPOSE_MODE.COMBINATION then
		return
	end

	local isCreate = self.designIndex == UIConst.HOME_DESIGN_MODE.CREATE
	local isMyDesign = self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN

	if not isCreate and not isMyDesign then
		return
	end

	if isMyDesign and not self.isModify then
		return
	end

	if string.isNilOrEmpty(self.titleName) then
		pg.global.showBubbleMessageRaw(pg.getGameString("NAME_NOT_VALID"))

		return
	end

	local coverImageKeys = {}

	if not string.isNilOrEmpty(self.coverImageKey) then
		table.insert(coverImageKeys, self.coverImageKey)
	end

	if isMyDesign then
		local code = self.detailData and self.detailData.code

		if string.isNilOrEmpty(code) then
			return
		end

		self.isUploading = true

		pg.me:updateUploadedHomeBlueprint(code, self.titleName, self.description, coverImageKeys, function(isSucc)
			self.isUploading = false

			if isSucc and self.view then
				self.isModify = false

				self:close()
			end
		end)
	elseif isCreate then
		local ornamentIdList = self.detailData and self.detailData.ornamentIdList or {}

		if #ornamentIdList < 2 then
			pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_COMPOSE_CREATE_MIN_FURNITURE_COUNT"))

			return
		end

		if not isPlan and #ornamentIdList > HomeBlueprintUtils.getConfig("maxFurniturePerBlueprint") then
			pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_FURNITURE_COUNT_LIMIT)

			return
		end

		self.isUploading = true

		local rangeSize = self.detailData.rangeSize

		if not rangeSize or #rangeSize == 0 then
			rangeSize = {
				0,
				0,
				0
			}
		end

		pg.me:uploadHomeBlueprint(ornamentIdList, self.titleName, self.description, coverImageKeys, rangeSize, function(isSucc)
			self.isUploading = false

			if isSucc then
				self:close()
				pg.global.ui:close(UIConst.UI_ID_HOMELAND_MULTI_SELECT)
			end
		end)
	end
end

function HomelandFurnitureComposeDetailCtrl:onDeleteBtnClick()
	if self.isDeleting then
		return
	end

	if self.designIndex ~= UIConst.HOME_DESIGN_MODE.MYDESIGN and self.designIndex ~= UIConst.HOME_DESIGN_MODE.SHAREDESIGN or self.composeIndex ~= UIConst.HOME_COMPOSE_MODE.COMBINATION then
		return
	end

	local code = self.detailData and self.detailData.code or ""

	if string.isNilOrEmpty(code) then
		return
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOMELAND_COMPOSE_DELETE_CONFIRM"), function()
		self.isDeleting = true
		self.deleteCode = code

		local deleteFunc = self.designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN and pg.me.deleteSavedOtherHomeBlueprint or pg.me.deleteUploadedHomeBlueprint

		deleteFunc(pg.me, code, function(isSucc)
			self.isDeleting = false

			if isSucc and self.deleteCode == code then
				self.deleteCode = nil
				self.isModify = false

				self:close()
			end
		end)
	end)
end

function HomelandFurnitureComposeDetailCtrl:onEditNameBtnClick()
	pg.global.ui.tips:showCommonInput(pg.getGameString("HOMELAND_COMPOSE_EDIT_NAME_TITLE"), function(newName)
		if not self.view or newName == nil or newName == "" then
			return
		end

		self.titleName = newName

		ClientTextUtils.setText(self.view.txtComposeNameUSDFText, self.titleName)

		if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN then
			self.isModify = true

			self:refreshSaveButton()
		end
	end, nil, {
		errorHide = true,
		text = self.titleName,
		characterLimit = HomeBlueprintUtils.getConfig("maxBlueprintNameLength") or 20
	})
end

function HomelandFurnitureComposeDetailCtrl:onEditDescBtnClick()
	pg.global.ui:open(UIConst.UI_ID_COMMON_TEXT_INPUT, {
		needSensitiveWordsCheck = true,
		title = pg.getGameString("HOMELAND_COMPOSE_EDIT_DESC_TITLE"),
		initialInputText = self.description or "",
		maxLen = HomeBlueprintUtils.getConfig("maxBlueprintDescLength") or 100,
		confirmCb = function(inputText)
			if not self.view then
				return
			end

			self.description = inputText or ""

			ClientTextUtils.setText(self.view.txtDescUSDFText, self.description)

			if self.designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN then
				self.isModify = true

				self:refreshSaveButton()
			end
		end
	})
end

function HomelandFurnitureComposeDetailCtrl:onVisibleChange(visible)
	if visible then
		self:refreshConsoleBarState()
	end
end

function HomelandFurnitureComposeDetailCtrl:onDestroy()
	self:setPhotoSceneActive(false)

	self.photoContext = nil
	self.composeItemCountMap = nil

	UICtrl.onDestroy(self)
end

function HomelandFurnitureComposeDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandFurnitureComposeDetailCtrl:onShow()
	return
end

function HomelandFurnitureComposeDetailCtrl:onHide()
	return
end

return HomelandFurnitureComposeDetailCtrl
