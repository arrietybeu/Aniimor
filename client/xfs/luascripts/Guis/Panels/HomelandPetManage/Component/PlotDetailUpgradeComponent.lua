-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\PlotDetailUpgradeComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PlotDetailUpgradeComponent")
local Class = require("Core.Framework.Class")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PlotDetailUpgradeComponent = Class.LightClass("PlotDetailUpgradeComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local ClientUtils = require("Utils.ClientUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomeObjectData = require("Data.home_object_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local ItemData = require("Data.item_data")
local HomelandUpgradeData = require("Data.home_upgrade_data")
local HomeFacilityData = require("Data.homeland_facility_data")

function PlotDetailUpgradeComponent:findObjects()
	return
end

function PlotDetailUpgradeComponent:initView()
	self.ornamentInfo = nil
	self.maxLevel = false
	self.upgradeInfo = nil
	self.itemId = HomelandConfigData.homeCurrencyId or 1010

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPlotDetailUpgrade(self.ornamentInfo)
	end)
end

function PlotDetailUpgradeComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.btnSwitchMaxUButton = objectReference:GetRefValue("btnSwitchMaxUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtOpenNowUSDFText = objectReference:GetRefValue("txtOpenNowUSDFText")
	self.txtLvBeforeUSDFText = objectReference:GetRefValue("txtLvBeforeUSDFText")
	self.txtCloseNowUSDFText = objectReference:GetRefValue("txtCloseNowUSDFText")
	self.txtLvAfterUSDFText = objectReference:GetRefValue("txtLvAfterUSDFText")
	self.listLevelUList = objectReference:GetRefValue("listLevelUList")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.btnUpgradeUButton = objectReference:GetRefValue("btnUpgradeUButton")
	self.textUpgradeUSDFText = objectReference:GetRefValue("textUpgradeUSDFText")
	self.txtMaxLVUSDFText = objectReference:GetRefValue("txtMaxLVUSDFText")
	self.textCostItemUSDFText = objectReference:GetRefValue("textCostItemUSDFText")
	self.listCostUList = objectReference:GetRefValue("listCostUList")
	self.costUWidget = objectReference:GetRefValue("costUWidget")
end

function PlotDetailUpgradeComponent:addListener()
	ClientTextUtils.setText(self.txtCloseNowUSDFText, pg.getGameString("OFF"))
	ClientTextUtils.setText(self.txtOpenNowUSDFText, pg.getGameString("ON"))
	ClientTextUtils.setText(self.textUpgradeUSDFText, pg.getGameString("UPGRADE"))
	ClientTextUtils.setText(self.txtMaxLVUSDFText, pg.getGameString("FULL_LEVEL_TIP"))
	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getGameString("HOMELAND_PLOT_LEVELUP_MAX"))
	ClientTextUtils.setText(self.textCostItemUSDFText, pg.getGameString("HOMELAND_LEVEL_UPGRADE_COST"))

	function self.listLevelUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local txtValueUSDFText = objectReference:GetRefValue("txtValueUSDFText")
			local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, data.name)
			ClientTextUtils.setText(txtValueUSDFText, data.tDesc)
			ClientTextUtils.setText(txtAddUSDFText, "+" .. data.nDesc - data.tDesc)
		elseif data.tIndex == 1 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local listItemUList = objectReference:GetRefValue("listItemUList")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_LEVEL_UNLOCKING_FORMULA"))

			function listItemUList.luaRenderItem(_button, _index, _data)
				LuaUIUtils.renderRewardItem(_button, _data)

				local objectReference = _button:GetComponent("ObjectReference")
				local imgMaskLockUWidget = objectReference:GetRefValue("imgMaskLockUWidget")

				if imgMaskLockUWidget then
					imgMaskLockUWidget:SetActive(_data.conditionLocked or _data.drawingLocked or false)
				end

				function _button.luaClick()
					local formulaData = HomelandFormulaData[_data.formulaId]
					local formulaInfo = ClientHomelandUtils.getHomeFormulaData(_data.formulaId)
					local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						autoHor = true,
						padding = 100,
						id = _data.id,
						itemCount = ClientUtils.getHomelandItemCountById(_data.itemId),
						targetRect = listItemUList,
						formulaInfo = formulaInfo,
						conditionLockText = _data.conditionLocked and formulaData.unlockDesc,
						lockText = _data.drawingLocked and not _data.conditionLocked and ClientHomelandUtils.getDrawingUnlockText(false, false) or nil,
						sourceItemId = _data.drawingLocked and not _data.conditionLocked and formulaData.unlockByItemId or nil,
						sourceTitle = _data.drawingLocked and not _data.conditionLocked and ClientHomelandUtils.getDrawingSourceTitle(false) or nil,
						price = Utils.getHomeItemPrice(defaultOutputItem)
					})
				end
			end

			listItemUList:SetList(data.formulaList)
		end
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
		self:refreshPlotDetailUpgrade(self.ornamentInfo)
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

	function self.btnUpgradeUButton.luaClick()
		if not self.ornamentInfo or not self.upgradeInfo then
			return
		end

		local itemCount = self:getUpgradeItemCount(self.upgradeInfo)
		local hasCount = pg.me:getItemCountById(self.itemId)

		if hasCount < itemCount then
			pg.global.showBubbleMessage(NoticeDef.HOMELAND_ORNAMENT_UPGRADE_LACK)

			return
		end

		pg.me.space:upgradeOrnament(self.ornamentInfo.ornamentId, self.upgradeInfo.homeTemplateId, false, "manage_page")
	end
end

function PlotDetailUpgradeComponent:refreshUpgradeListInfo()
	local facilityId = Utils.getHomeObjectFacilityId(self.ornamentInfo.homeId)
	local facilityData = HomeFacilityData[facilityId]
	local upgradeInfo

	if self.maxLevel then
		upgradeInfo = self.model:getMaxAllowedUpgradeInfo(self.ornamentInfo.homeId)
	else
		upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(self.ornamentInfo.homeId)
	end

	local haveCost = 0

	if upgradeInfo and upgradeInfo.homeTemplateId then
		local curType, curLevel = Utils.getHomeOrnamentCurLevelInfo(self.ornamentInfo.homeId)
		local nextFacilityData = HomeFacilityData[upgradeInfo.homeTemplateId]

		if facilityData and nextFacilityData then
			local nextType, nextLevel = Utils.getHomeOrnamentCurLevelInfo(upgradeInfo.homeTemplateId)

			ClientTextUtils.setText(self.txtLvBeforeUSDFText, "Lv." .. curLevel)
			ClientTextUtils.setText(self.txtLvAfterUSDFText, "Lv." .. nextLevel)

			local curHomeData = HomeObjectData[self.ornamentInfo.homeId]
			local nextHomeData = HomeObjectData[upgradeInfo.homeTemplateId]
			local attributeData = {}

			if curHomeData and nextHomeData and curHomeData.maxPetCount ~= nextHomeData.maxPetCount then
				table.insert(attributeData, {
					tIndex = 0,
					name = pg.getGameString("HOMELAND_UPGRADE_DES"),
					tDesc = curHomeData.maxPetCount,
					nDesc = nextHomeData.maxPetCount
				})
			end

			if facilityData.outputLimit ~= nextFacilityData.outputLimit then
				table.insert(attributeData, {
					tIndex = 0,
					name = pg.getGameString("HOME_BUILDING_UPGRADE_DES_2"),
					tDesc = facilityData.outputLimit,
					nDesc = nextFacilityData.outputLimit
				})
			end

			local formulaList = HomeLandUtils.getLevelFormulaList(self.ornamentInfo.homeId, facilityId, upgradeInfo)

			if #formulaList > 0 then
				table.insert(attributeData, {
					tIndex = 1,
					formulaList = formulaList
				})
			end

			self.listLevelUList:SetList(attributeData)

			local costData = {}

			for id, num in pairs(upgradeInfo.upgradeItemCost or EMPTY_TABLE) do
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

			haveCost = #costData > 0 and 1 or 0

			function self.listCostUList.luaRenderItem(button, index, data)
				LuaUIUtils.renderCostItem(button, data)
			end

			self.listCostUList:SetList(costData)

			self.iconUImage.url = LuaUIUtils.getIconByItemId(self.itemId)

			local itemCount = self:getUpgradeItemCount(upgradeInfo)
			local canUpgrade = true
			local hasCount = pg.me:getItemCountById(self.itemId)

			if hasCount < itemCount then
				itemCount = pg.getFormatText("<style=Debuff>{0}</style>", itemCount)
				canUpgrade = false
			end

			if canUpgrade then
				for _, item in ipairs(costData) do
					if item.num < item.costNum then
						canUpgrade = false

						break
					end
				end
			end

			self.btnUpgradeUButton.interactable = canUpgrade

			ClientTextUtils.setText(self.txtNumUSDFText, itemCount)

			self.upgradeInfo = upgradeInfo
		end
	end

	self.uWidget.content:TryChangePage("HaveCost", haveCost)
end

function PlotDetailUpgradeComponent:getUpgradeItemCount(upgradeInfo)
	local itemCount = 0

	for id, num in pairs(upgradeInfo.upgradeCost or EMPTY_TABLE) do
		if id == self.itemId then
			itemCount = num
		end
	end

	return itemCount
end

function PlotDetailUpgradeComponent:refreshPlotDetailUpgrade(ornamentInfo)
	if not ornamentInfo then
		return
	end

	self.ornamentInfo = ornamentInfo

	if not self.uWidget:CheckURLLoaded() then
		return
	end

	self.upgradeInfo = nil

	if self:checkCanPerformLevelUp(self.ornamentInfo.homeId) then
		self.uWidget.content:TryChangePage("Max", 0)
		self.listLevelUList:SetActive(true)
		self:refreshUpgradeListInfo()
	else
		self.uWidget.content:TryChangePage("Max", 1)
		self.uWidget.content:TryChangePage("HaveCost", 0)
		self.listLevelUList:SetActive(false)
	end
end

function PlotDetailUpgradeComponent:checkCanPerformLevelUp(homeId)
	local upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(homeId)

	if upgradeInfo and pg.me.space:isSelfHomeland(pg.me) then
		local homeObjectData = HomeObjectData[upgradeInfo.homeTemplateId] or {}

		return pg.me.triggerMap:isCompleteOrMeetCondition(homeObjectData.unlockCondition)
	else
		return false
	end
end

function PlotDetailUpgradeComponent:onDestroy()
	self.ornamentInfo = nil
	self.upgradeInfo = nil

	UIComponent.onDestroy(self)
end

function PlotDetailUpgradeComponent:onEnterPage()
	return
end

return PlotDetailUpgradeComponent
