-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotMultipleUpgradeComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PlotMultipleUpgradeComponent")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotMultipleUpgradeComponent = Class.LightClass("PlotMultipleUpgradeComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeObjectData = require("Data.home_object_data")
local HomeFacilityData = require("Data.homeland_facility_data")
local UPGRADE_COST_SLOT_MAX = 4

function PlotMultipleUpgradeComponent:findObjects()
	return
end

function PlotMultipleUpgradeComponent:initView()
	self.upgradeInfoList = {}
	self.upgradeAllCount = 0
	self.upgradeCoinNum = 0
	self.upgradeMaxCoinNum = 0
	self.maxLevel = false
	self.itemId = HomelandConfigData.homeCurrencyId or 1010

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
	end)
end

function PlotMultipleUpgradeComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnSwitchMaxUButton = objectReference:GetRefValue("btnSwitchMaxUButton")
	self.txtCloseUSDFText = objectReference:GetRefValue("txtCloseUSDFText")
	self.txtOpenUSDFText = objectReference:GetRefValue("txtOpenUSDFText")
	self.txtMaxUSDFText = objectReference:GetRefValue("txtMaxUSDFText")
	self.listPlotUList = objectReference:GetRefValue("listPlotUList")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.btnUpgradeUButton = objectReference:GetRefValue("btnUpgradeUButton")
	self.txtUpgradeUSDFText = objectReference:GetRefValue("txtUpgradeUSDFText")
	self.costUWidget = objectReference:GetRefValue("costUWidget")
	self.txtAllNumUSDFText = objectReference:GetRefValue("txtAllNumUSDFText")
	self.listCostUList = objectReference:GetRefValue("listCostUList")
end

function PlotMultipleUpgradeComponent:addListener()
	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getGameString("HOMELAND_PLOT_BATCH_UPGRADE"))
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("HOMELAND_PLOT_BATCH_LEVEL_TIPS"))
	ClientTextUtils.setText(self.txtCloseUSDFText, pg.getGameString("OFF"))
	ClientTextUtils.setText(self.txtOpenUSDFText, pg.getGameString("ON"))
	ClientTextUtils.setText(self.txtMaxUSDFText, pg.getGameString("HOMELAND_PLOT_LEVELUP_MAX"))
	ClientTextUtils.setText(self.txtUpgradeUSDFText, pg.getGameString("UPGRADE"))
	ClientTextUtils.setText(self.txtAllNumUSDFText, pg.getGameString("HOMELAND_LEVEL_UPGRADE_COST"))

	function self.btnCloseUButton.luaClick()
		self.ctrl:exitOrnamentGridMultipleMode()
	end

	function self.btnUpgradeUButton.luaClick()
		if self.upgradeAllCount <= 0 then
			return
		end

		local number = self.maxLevel and self.upgradeMaxCoinNum or self.upgradeCoinNum
		local hasCount = pg.me:getItemCountById(self.itemId)

		if hasCount < number then
			pg.global.showBubbleMessage(NoticeDef.HOMELAND_ORNAMENT_UPGRADE_LACK)

			return
		end

		for curType, typeTable in pairs(self.upgradeInfoList) do
			for curLevel, levelInfo in pairs(typeTable.upList) do
				local upgradeInfo = self.maxLevel and levelInfo.maxUpgradeInfo or levelInfo.upgradeInfo
				local count = levelInfo.count

				for id, num in pairs(upgradeInfo.upgradeItemCost or EMPTY_TABLE) do
					local hasNum = ItemUtils.getItemCountById(pg.me, id) + ClientUtils.getHomelandItemCountById(id)

					if hasNum < num * count then
						pg.global.showBubbleMessage(NoticeDef.HOME_CAR_UPGRADE_ITEM_LACK_INHOME)

						return
					end
				end
			end
		end

		for curType, typeTable in pairs(self.upgradeInfoList) do
			for curLevel, levelInfo in pairs(typeTable.upList) do
				local upgradeHomeTemplateId

				if self.maxLevel then
					upgradeHomeTemplateId = levelInfo.maxUpgradeInfo.homeTemplateId
				else
					upgradeHomeTemplateId = levelInfo.upgradeInfo.homeTemplateId
				end

				if upgradeHomeTemplateId then
					for ornamentId, _ in pairs(levelInfo.ornamentTable) do
						pg.me.space:upgradeOrnament(ornamentId, upgradeHomeTemplateId, true, "manage_page")
					end
				end
			end
		end

		self.ctrl:exitOrnamentGridMultipleMode()
	end

	local function performToggle()
		local now = Time.getTickSecond()

		if self._lastMaxToggleTime and now - self._lastMaxToggleTime < 0.1 then
			return
		end

		self._lastMaxToggleTime = now
		self.maxLevel = not self.maxLevel

		local num = self.maxLevel and 1 or 0

		self.btnSwitchMaxUButton:TryChangePage("MaxLevel", num)
		self.listPlotUList:RefreshList()
		self:refreshAllCoinNum()
	end

	self.btnSwitchMaxUButton.luaClick = performToggle

	if self.ctrl and self.ctrl.bindHotKeyPerform then
		self.ctrl:bindHotKeyPerform("Raw/GamepadButtonWest", function()
			if not self.btnSwitchMaxUButton or IsNil(self.btnSwitchMaxUButton.gameObject) then
				return
			end

			if not self.btnSwitchMaxUButton.gameObject.activeInHierarchy then
				return
			end

			if self.btnSwitchMaxUButton.interactable == false then
				return
			end

			performToggle()
		end, self.btnSwitchMaxUButton.gameObject)
	end

	function self.listPlotUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameTextPlus = objectReference:GetRefValue("txtNameTextPlus")
		local txtNumTotalUSDFText = objectReference:GetRefValue("txtNumTotalUSDFText")
		local listUList = objectReference:GetRefValue("listUList")

		ClientTextUtils.setText(txtNameTextPlus, data.name)
		ClientTextUtils.setText(txtNumTotalUSDFText, "x" .. data.allCount)

		function listUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtLvBeforeUSDFText = objectReference:GetRefValue("txtLvBeforeUSDFText")
			local txtLvAfterUSDFText = objectReference:GetRefValue("txtLvAfterUSDFText")
			local txtCountUSDFText = objectReference:GetRefValue("txtCountUSDFText")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
			local listItemCostUList = objectReference:GetRefValue("listItemCostUList")
			local txtCostUSDFText = objectReference:GetRefValue("txtCostUSDFText")

			ClientTextUtils.setText(txtLvBeforeUSDFText, "Lv." .. data.level)
			ClientTextUtils.setText(txtCountUSDFText, "x" .. data.count)
			ClientTextUtils.setText(txtCostUSDFText, pg.getGameString("HOMELAND_LEVEL_UPGRADE_COST"))

			iconUImage.url = LuaUIUtils.getIconByItemId(self.itemId)

			local upgradeInfo

			if self.maxLevel then
				upgradeInfo = data.maxUpgradeInfo
			else
				upgradeInfo = data.upgradeInfo
			end

			local nextType, nextLevel = Utils.getHomeOrnamentCurLevelInfo(upgradeInfo.homeTemplateId)

			ClientTextUtils.setText(txtLvAfterUSDFText, "Lv." .. nextLevel)

			local itemCount = 0

			for id, num in pairs(upgradeInfo.upgradeCost or EMPTY_TABLE) do
				if id == self.itemId then
					itemCount = num
				end
			end

			ClientTextUtils.setText(txtNumUSDFText, itemCount)

			local costData = {}

			for id, num in pairs(upgradeInfo.upgradeItemCost or EMPTY_TABLE) do
				local costInfo = {
					showNum = true,
					tIndex = 0,
					id = id,
					num = ItemUtils.getItemCountById(pg.me, id) + ClientUtils.getHomelandItemCountById(id),
					costNum = num
				}

				table.insert(costData, costInfo)
			end

			table.sort(costData, function(a, b)
				return a.id < b.id
			end)

			local hasRealCost = #costData > 0

			if hasRealCost then
				while #costData < UPGRADE_COST_SLOT_MAX do
					table.insert(costData, {
						tIndex = 1
					})
				end
			end

			listItemCostUList:SetActive(hasRealCost)

			function listItemCostUList.luaRenderItem(button, index, data)
				if data.tIndex == 1 then
					return
				end

				LuaUIUtils.renderCostItem(button, data)
			end

			listItemCostUList:SetList(costData)
		end

		local list = {}

		for curLevel, levelInfo in pairs(data.upList) do
			table.insert(list, levelInfo)
		end

		table.sort(list, function(a, b)
			return a.level < b.level
		end)
		listUList:SetList(list)
	end
end

function PlotMultipleUpgradeComponent:changeUpgradeInfoList(ornamentId, isAdd)
	local ornamentInfo = pg.me.space.ornament[ornamentId]

	if not ornamentInfo then
		return
	end

	local homeTemplateId = ornamentInfo.homeId

	if isAdd then
		self:addUpgradeInfoList(homeTemplateId, ornamentId)
	else
		self:removeUpgradeInfoList(homeTemplateId, ornamentId)
	end

	self.uWidget.content:TryChangePage("Empty", self.upgradeAllCount > 0 and 1 or 0)

	if self.upgradeAllCount > 0 then
		local list = {}

		for curType, typeTable in pairs(self.upgradeInfoList) do
			table.insert(list, typeTable)
		end

		table.sort(list, function(a, b)
			return a.type < b.type
		end)
		self.listPlotUList:SetList(list)
	end

	self:refreshAllCoinNum()
end

function PlotMultipleUpgradeComponent:getUpgradeInfoList(ornamentIdList)
	self.upgradeInfoList = {}
	self.upgradeAllCount = 0
	self.upgradeCoinNum = 0
	self.upgradeMaxCoinNum = 0

	for ornamentId, _ in pairs(ornamentIdList) do
		local ornamentInfo = pg.me.space.ornament[ornamentId]

		if ornamentInfo then
			local homeTemplateId = ornamentInfo.homeId

			self:addUpgradeInfoList(homeTemplateId, ornamentId)
		end
	end

	return self.upgradeInfoList
end

function PlotMultipleUpgradeComponent:removeUpgradeInfoList(homeTemplateId, ornamentId)
	if not homeTemplateId then
		return
	end

	local curType, curLevel = Utils.getHomeOrnamentCurLevelInfo(homeTemplateId)

	curType = curType or homeTemplateId
	curLevel = curLevel or 1

	if self.upgradeInfoList[curType] == nil then
		return
	end

	local typeTable = self.upgradeInfoList[curType]

	if typeTable.upList[curLevel] == nil then
		return
	end

	for id, num in pairs(typeTable.upList[curLevel].upgradeInfo.upgradeCost or EMPTY_TABLE) do
		if id == self.itemId then
			self.upgradeCoinNum = self.upgradeCoinNum - num
		end
	end

	for id, num in pairs(typeTable.upList[curLevel].maxUpgradeInfo.upgradeCost or EMPTY_TABLE) do
		if id == self.itemId then
			self.upgradeMaxCoinNum = self.upgradeMaxCoinNum - num
		end
	end

	typeTable.upList[curLevel].ornamentTable[ornamentId] = nil
	typeTable.upList[curLevel].count = typeTable.upList[curLevel].count - 1

	if typeTable.upList[curLevel].count <= 0 then
		typeTable.upList[curLevel] = nil
	end

	typeTable.allCount = typeTable.allCount - 1

	if typeTable.allCount <= 0 then
		self.upgradeInfoList[curType] = nil
	end

	self.upgradeAllCount = self.upgradeAllCount - 1
end

function PlotMultipleUpgradeComponent:addUpgradeInfoList(homeTemplateId, ornamentId)
	if not homeTemplateId then
		return
	end

	local curType, curLevel = Utils.getHomeOrnamentCurLevelInfo(homeTemplateId)

	curType = curType or homeTemplateId
	curLevel = curLevel or 1

	if self.upgradeInfoList[curType] == nil then
		local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)
		local facilityData = HomeFacilityData[facilityId] or {}
		local homeObjectData = HomeObjectData[homeTemplateId] or {}
		local name = facilityData.typeName or homeObjectData.name

		self.upgradeInfoList[curType] = {}
		self.upgradeInfoList[curType].name = pg.getLocalizationText(name)
		self.upgradeInfoList[curType].type = curType
		self.upgradeInfoList[curType].upList = {}
		self.upgradeInfoList[curType].allCount = 0
	end

	local typeTable = self.upgradeInfoList[curType]

	if typeTable.upList[curLevel] == nil then
		typeTable.upList[curLevel] = {}
		typeTable.upList[curLevel].maxUpgradeInfo = self.model:getMaxAllowedUpgradeInfo(homeTemplateId)
		typeTable.upList[curLevel].upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(homeTemplateId)
		typeTable.upList[curLevel].ornamentTable = {}
		typeTable.upList[curLevel].level = curLevel
		typeTable.upList[curLevel].count = 0
	end

	typeTable.upList[curLevel].count = typeTable.upList[curLevel].count + 1
	typeTable.allCount = typeTable.allCount + 1
	self.upgradeAllCount = self.upgradeAllCount + 1
	typeTable.upList[curLevel].ornamentTable[ornamentId] = true

	for id, num in pairs(typeTable.upList[curLevel].upgradeInfo.upgradeCost or EMPTY_TABLE) do
		if id == self.itemId then
			self.upgradeCoinNum = self.upgradeCoinNum + num
		end
	end

	for id, num in pairs(typeTable.upList[curLevel].maxUpgradeInfo.upgradeCost or EMPTY_TABLE) do
		if id == self.itemId then
			self.upgradeMaxCoinNum = self.upgradeMaxCoinNum + num
		end
	end
end

function PlotMultipleUpgradeComponent:refreshAllCoinNum()
	local number = self.maxLevel and self.upgradeMaxCoinNum or self.upgradeCoinNum
	local hasCount = pg.me:getItemCountById(self.itemId)

	if hasCount < number then
		number = pg.getFormatText("<style=Debuff>{0}</style>", number)
	end

	ClientTextUtils.setText(self.txtNumUSDFText, number)
	self:refreshAllItemCost()
end

function PlotMultipleUpgradeComponent:refreshAllItemCost()
	local totalCostMap = {}

	for curType, typeTable in pairs(self.upgradeInfoList) do
		for curLevel, levelInfo in pairs(typeTable.upList) do
			local upgradeInfo = self.maxLevel and levelInfo.maxUpgradeInfo or levelInfo.upgradeInfo
			local count = levelInfo.count

			for id, num in pairs(upgradeInfo.upgradeItemCost or EMPTY_TABLE) do
				totalCostMap[id] = (totalCostMap[id] or 0) + num * count
			end
		end
	end

	local costData = {}

	for id, num in pairs(totalCostMap) do
		local costInfo = {
			showNum = true,
			id = id,
			num = ItemUtils.getItemCountById(pg.me, id) + ClientUtils.getHomelandItemCountById(id),
			costNum = num
		}

		table.insert(costData, costInfo)
	end

	table.sort(costData, function(a, b)
		return a.id < b.id
	end)

	local hasCost = #costData > 0

	self.uWidget.content:TryChangePage("HaveCost", hasCost and 1 or 0)

	if hasCost then
		function self.listCostUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderCostItem(button, data)
		end

		self.listCostUList:SetList(costData)
	end
end

function PlotMultipleUpgradeComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PlotMultipleUpgradeComponent:onEnterPage()
	self.upgradeInfoList = {}
	self.upgradeAllCount = 0
	self.upgradeCoinNum = 0
	self.upgradeMaxCoinNum = 0
	self.maxLevel = false

	self.uWidget.content:TryChangePage("Empty", 0)
	self.btnSwitchMaxUButton:TryChangePage("MaxLevel", 0)
end

return PlotMultipleUpgradeComponent
