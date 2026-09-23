-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapMarkFilterComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MapMarkFilterComponent = Class.LightClass("MapMarkFilterComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")

function MapMarkFilterComponent:findObjects()
	self.objectReference = self.view.sortFloatUComponent.transform:GetComponent("ObjectReference")
	self.inputFieldUTMPInputField = self.objectReference:GetRefValue("inputFieldUTMPInputField")
	self.listNormalUList = self.objectReference:GetRefValue("listNormalUList")
	self.btnShowUButton = self.objectReference:GetRefValue("btnShowUButton")
	self.listSearchUList = self.objectReference:GetRefValue("listSearchUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnClose1UButton = self.objectReference:GetRefValue("btnClose1UButton")
	self.btnCleanUButton = self.objectReference:GetRefValue("btnCleanUButton")
	self.uIPbMapSortFilterAnimation = self.objectReference:GetRefValue("uIPbMapSortFilterAnimation")
	self.btnResetUButton = self.objectReference:GetRefValue("btnResetUButton")
	self.btnFilterUButton = self.view.btnFilterUButton
	self.simpleListTagUList = self.view.listTagUList

	local objectReference = self.btnShowUButton:GetComponent("ObjectReference")

	self.imgShowUImage = objectReference:GetRefValue("imgShowUImage")
end

function MapMarkFilterComponent:initView()
	function self.listNormalUList.luaRenderItem(button, index, data)
		self:renderNormalList(button, index, data)
	end

	function self.simpleListTagUList.luaRenderItem(button, index, data)
		self:renderSimpleTagList(button, index, data)
	end

	function self.listSearchUList.luaRenderItem(button, index, data)
		self:renderNormalList(button, index, data)
	end

	function self.btnResetUButton.luaClick()
		self:resetToDefault()
	end

	function self.btnFilterUButton.luaClick()
		self:openPanel()
	end

	function self.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.btnClose1UButton.luaClick()
		self:closePanel()
	end

	function self.btnShowUButton.luaClick()
		if pg.game.map.enableFinishedType[self.ctrl.sceneId] then
			pg.game.map.enableFinishedType[self.ctrl.sceneId] = false

			self.btnShowUButton:TryChangePage("Check", 0)

			self.imgShowUImage.url = AddressDataConst.MAP_SORT_SHOW_FINISHED_OFF

			self:doFilter()
		else
			pg.game.map.enableFinishedType[self.ctrl.sceneId] = true

			self.btnShowUButton:TryChangePage("Check", 1)

			self.imgShowUImage.url = AddressDataConst.MAP_SORT_SHOW_FINISHED_ON

			self:doFilter()
		end
	end

	function self.inputFieldUTMPInputField.luaOnSelect(text)
		if string.isNilOrEmpty(text) then
			self:openSearchPage(false, text)
		else
			self:openSearchPage(true, text)
		end
	end

	function self.inputFieldUTMPInputField.luaOnDeSelect(text)
		if string.isNilOrEmpty(text) then
			self:openSearchPage(false, text)
		else
			self:openSearchPage(true, text)
		end
	end

	function self.inputFieldUTMPInputField.luaValueChanged(text)
		if string.isNilOrEmpty(text) then
			self:openSearchPage(false, text)
		else
			self:openSearchPage(true, text)
		end
	end

	function self.btnCleanUButton.luaClick()
		self.inputFieldUTMPInputField.text = ""

		self:openSearchPage(false, "")
	end

	if pg.game.map:checkDisabledTypeContains(self.ctrl.sceneId) then
		self.view.sortFilterUComponent:TryChangePage("Custom", 1)
	else
		self.view.sortFilterUComponent:TryChangePage("Custom", 0)
	end
end

function MapMarkFilterComponent:openSearchPage(open, text)
	if open then
		self.view.sortFloatUComponent:TryChangePage("IsSearch", 1)

		self.searchedText = text

		self:refreshSearchList(self.searchedText)
	else
		self.view.sortFloatUComponent:TryChangePage("IsSearch", 0)

		self.searchedText = nil
	end
end

function MapMarkFilterComponent:openPanel()
	self.view.sortFilterUComponent.gameObject:SetActiveEx(false)
	self.view.chooseList.gameObject:SetActiveEx(false)
	self.ctrl:renderMultiIconSelectBox(false)
	self.view.locationInfo.gameObject:SetActiveEx(false)
	self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)

	self.panelOpened = true

	self.view.sortFloatUComponent.gameObject:SetActiveEx(true)
	self:refreshNormalList()
	self.btnShowUButton:TryChangePage("Check", pg.game.map.enableFinishedType[self.ctrl.sceneId] and 1 or 0)

	if pg.game.map.enableFinishedType[self.ctrl.sceneId] then
		self.imgShowUImage.url = AddressDataConst.MAP_SORT_SHOW_FINISHED_ON
	else
		self.imgShowUImage.url = AddressDataConst.MAP_SORT_SHOW_FINISHED_OFF
	end

	if string.isNilOrEmpty(self.inputFieldUTMPInputField.text) then
		self:openSearchPage(false, self.inputFieldUTMPInputField.text)
	else
		self:openSearchPage(true, self.inputFieldUTMPInputField.text)
	end
end

function MapMarkFilterComponent:closePanel()
	if not self.view then
		return
	end

	self.view.sortFilterUComponent.gameObject:SetActiveEx(true)
	self.view.sortFilterUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	UIUtils.PlayAnimation(self.uIPbMapSortFilterAnimation, "VX_Pb_Map_SortFilter_Out", function()
		pg.game.map:saveEnabledMarkTypes(self.ctrl.sceneId)
		self.view.sortFloatUComponent.gameObject:SetActiveEx(false)
	end)

	self.panelOpened = false

	if pg.game.map:checkDisabledTypeContains(self.ctrl.sceneId) then
		self.view.sortFilterUComponent:TryChangePage("Custom", 1)
	else
		self.view.sortFilterUComponent:TryChangePage("Custom", 0)
	end
end

function MapMarkFilterComponent:refreshNormalList()
	local data = self.model:getSortNormalListData(self.ctrl.sceneId)

	self.listNormalUList:SetList(data)
end

function MapMarkFilterComponent:refreshSimpleTagList()
	local data = self.model:getSortTagListData(self.ctrl.sceneId)

	self.simpleListTagUList:SetList(data)
end

function MapMarkFilterComponent:refreshSearchList(text)
	if not text then
		return
	end

	local data = self.model:getSearchListData(text, self.ctrl.sceneId)

	self.listSearchUList:SetList(data)
end

function MapMarkFilterComponent:renderSimpleTagList(button, index, data)
	if not self.ctrl then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	button:TryChangePage("select", not pg.game.map.totalDisabledType[self.ctrl.sceneId][data.index] and 1 or 0)
	ClientTextUtils.setText(txtNameUSDFText, data.name)

	function button.luaClick()
		local isDisabled = pg.game.map.totalDisabledType[self.ctrl.sceneId][data.index] ~= nil

		pg.game.map.totalDisabledType[self.ctrl.sceneId][data.index] = not isDisabled and data.index or nil

		self:refreshSimpleTagList()
		self:doTotalFilter()
		pg.game.map:saveTotalEnabledMarkTypes(self.ctrl.sceneId)
	end
end

function MapMarkFilterComponent:renderNormalList(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

		ClientTextUtils.setText(txtTitleUSDFText, data.name)
	elseif data.tIndex == 1 then
		local objectReference = button:GetComponent("ObjectReference")
		local listItemUList = objectReference:GetRefValue("listItemUList")

		function listItemUList.luaRenderItem(button1, index1, data1)
			local objectReference1 = button1:GetComponent("ObjectReference")
			local iconUImage = objectReference1:GetRefValue("iconUImage")
			local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")
			local txtNumUSDFText = objectReference1:GetRefValue("txtNumUSDFText")
			local numLayout = txtNumUSDFText.transform.parent

			if data1.active == 0 then
				button1:TryChangePage("Type", 2)
				button1:TryChangePage("select", 0)

				function button1.luaClick()
					pg.global.showBubbleMessageRaw(pg.getGameString("UNKNOWN_MAP_FILTER_MARK"))
				end
			else
				button1:TryChangePage("Type", 0)

				iconUImage.url = data1.icon

				ClientTextUtils.setText(txtNameUSDFText, data1.name)
				txtNumUSDFText.gameObject:SetActiveEx(false)

				if numLayout and numLayout.name == "NumLayout" then
					numLayout.gameObject:SetActiveEx(false)
				end

				local x = UIConst.MAP_CONST.SIZE_DELTA[data1.markLevel][1] * 0.85
				local y = UIConst.MAP_CONST.SIZE_DELTA[data1.markLevel][2] * 0.85
				local z = UIConst.MAP_CONST.SIZE_DELTA[data1.markLevel][3] * 0.85

				iconUImage.transform.localScale = Vector3(x, y, z)

				local disabled = pg.game.map.disabledType[self.ctrl.sceneId][tostring(data1.configId)]

				button1:TryChangePage("select", not disabled and 1 or 0)

				function button1.luaClick()
					if pg.game.map.disabledType[self.ctrl.sceneId][tostring(data1.configId)] then
						pg.game.map.disabledType[self.ctrl.sceneId][tostring(data1.configId)] = nil
					else
						pg.game.map.disabledType[self.ctrl.sceneId][tostring(data1.configId)] = tostring(data1.configId)
					end

					self:refreshNormalList()
					self:refreshSearchList(self.searchedText)
					self:doFilter()
				end
			end
		end

		local listData = {}
		local containsUnknown = 0

		for _, configId in pairs(data.categories) do
			if pg.game.map.sceneMarkPointConfigCountData[self.ctrl.sceneId][configId] then
				if pg.game.map.sceneMarkPointConfigCountData[self.ctrl.sceneId][configId].active == 0 then
					containsUnknown = containsUnknown + 1
				else
					local t = {}

					t.name = pg.getLocalizationText(self.model:getNameByMarkType(configId))
					t.icon = self.model:getIconByMarkType(configId)
					t.active = pg.game.map.sceneMarkPointConfigCountData[self.ctrl.sceneId][configId].active
					t.total = pg.game.map.sceneMarkPointConfigCountData[self.ctrl.sceneId][configId].total
					t.configId = configId
					t.markLevel = DefaultMapMarkData[configId].markLevel or 1
					listData[#listData + 1] = t
				end
			end
		end

		if containsUnknown > 0 then
			local t = {}

			t.active = 0
			listData[#listData + 1] = t
		end

		listItemUList:SetList(listData)
	end
end

function MapMarkFilterComponent:doFilter()
	if self.ctrl.loadVisibleMarks then
		self.ctrl:loadVisibleMarks()
	end

	local showTag = false

	for _, v in pairs(self.ctrl.markCaches) do
		if NotNil(v.button) then
			showTag = not pg.game.map:isEnabledByFilter(self.ctrl.sceneId, v.markConfigId, v.markStatus, v.spawnerId, {
				finishStateAlwaysShow = v.finishStateAlwaysShow
			}) and 1 or 0

			pg.game.map:setSceneMarkQuestPointDataFiler(v, showTag == 0)
			v.button:TryChangePage("MapFilterHide", not pg.game.map:isEnabledByFilter(self.ctrl.sceneId, v.markConfigId, v.markStatus, v.spawnerId, {
				finishStateAlwaysShow = v.finishStateAlwaysShow
			}) and 1 or 0)
		end
	end

	self:refreshQuestTagOrMark()

	if self.ctrl.markBubbleComponent then
		for key, v in pairs(self.ctrl.markBubbleComponent.bubbleMarksObjCaches) do
			local tableData = self.ctrl.markCaches[key]

			if NotNil(v.button) and tableData then
				v.button:TryChangePage("MapFilterHide", not pg.game.map:isEnabledByFilter(self.ctrl.sceneId, tableData.markConfigId, tableData.markStatus, tableData.spawnerId, {
					finishStateAlwaysShow = tableData.finishStateAlwaysShow
				}) and 1 or 0)
			end
		end
	end

	local minimap = pg.global.ui.hudV2 and pg.global.ui.hudV2.LU and pg.global.ui.hudV2.LU.minimapV2

	if minimap then
		minimap:updateMapFilter(self.ctrl.sceneId)
	end
end

function MapMarkFilterComponent:doTotalFilter()
	if self.ctrl.loadVisibleMarks then
		self.ctrl:loadVisibleMarks()
	end

	for _, v in pairs(self.ctrl.markCaches) do
		if NotNil(v.button) then
			v.button.renderOpacity = pg.game.map:isEnabledByTotalFilter(self.ctrl.sceneId, v.markConfigId) and 1 or 0
		end
	end

	if self.ctrl.markBubbleComponent then
		for key, v in pairs(self.ctrl.markBubbleComponent.bubbleMarksObjCaches) do
			local tableData = self.ctrl.markCaches[key]

			if NotNil(v.button) and tableData then
				v.button.renderOpacity = pg.game.map:isEnabledByTotalFilter(self.ctrl.sceneId, tableData.markConfigId) and 1 or 0
			end
		end
	end

	local minimap = pg.global.ui.hudV2 and pg.global.ui.hudV2.LU and pg.global.ui.hudV2.LU.minimapV2

	if minimap then
		minimap:updateTotalFilter(self.ctrl.sceneId)
	end
end

function MapMarkFilterComponent:refreshQuestTagOrMark()
	for key, v in pairs(self.ctrl.markCaches) do
		if NotNil(v.button) and v.type == Const.MAP_CONST.TYPE.QUEST and v.questId then
			local id, isSpawnerId = pg.game.map:isContainMarkSpawnerId(v.questId, v.objId)

			if isSpawnerId then
				local showQuestTag = false
				local addQuestTag = pg.game.map:getContainMarkSpawnerId(id)

				if addQuestTag and addQuestTag.questId and addQuestTag.questId > 0 then
					showQuestTag = pg.game.map:isShowQuestTagMark(addQuestTag.questId, addQuestTag.objId)
				end

				local objectReference = v.button:GetComponent("ObjectReference")
				local btnRectTransform = objectReference:GetRefValue("btnRectTransform")
				local btnCC = btnRectTransform.childCount

				for i = 0, btnCC - 1 do
					local ObjectReference = btnRectTransform:GetChild(i).gameObject:GetComponent("ObjectReference")
					local questCmp = btnRectTransform:GetChild(i).gameObject:GetComponent("UComponent")
					local questNumberUComponent = ObjectReference:GetRefValue("questNumberUComponent")

					if questNumberUComponent then
						questNumberUComponent:SetActive(not showQuestTag)
						questCmp:SetActive(not showQuestTag)
					end

					local taskUComponent = ObjectReference:GetRefValue("taskUComponent")

					if taskUComponent then
						taskUComponent:SetActive(showQuestTag)
					end
				end

				if NotNil(v.recTrans) and v.markPos then
					local pos = v.markPos

					if showQuestTag then
						local relatePos = pg.game.map:getQuestTagRelateMarkPosition(v.questId, v.objId)

						if relatePos then
							pos = relatePos
						end
					end

					local mx, my = pg.game.map:convertPos(pos[1], pos[3], v.realSceneId, true)

					v.recTrans.anchoredPosition = Vector2(mx, my)
					v.anchoredPositionX = mx
					v.anchoredPositionY = my
					v.realAnchoredPositionX = mx
					v.realAnchoredPositionY = my
					v.mapX = mx
					v.mapY = my
				end
			end
		end
	end
end

function MapMarkFilterComponent:resetToDefault()
	pg.game.map:resetDefaultDisabledType(self.ctrl.sceneId)
	self:refreshNormalList()
	self:doFilter()
end

function MapMarkFilterComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return MapMarkFilterComponent
