-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandLevelUp\\HomelandLevelUpCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandLevelUpCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandLevelUpCtrl = Class.LightClass("HomelandLevelUpCtrl", UICtrl)
local HomeFacilityData = require("Data.homeland_facility_data")
local HomeUpgradeData = require("Data.home_upgrade_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local GameStringConfig = require("Data.gamestring_config_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local UIConst = require("Const.UIConst")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandFormulaData = require("Data.homeland_formula_data")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local ClientUtils = require("Utils.ClientUtils")

HomelandLevelUpCtrl.messages = {
	[MessageName.HOMELAND_LEVEL_UP_SUCC] = {
		"onLevelUpSucc",
		true
	}
}

function HomelandLevelUpCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	if info then
		function self.view.listCurrencyUList.luaRenderItem(button, index, data)
			LuaUIUtils.setTopCurrencyItem(button, data.itemId)
		end

		self.view.listCurrencyUList:SetList(self:getIconList())

		local facilityData = HomeFacilityData[info.facilityId]
		local upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(self.info.homeTemplateId)

		if upgradeInfo then
			local curType, curLevel = Utils.getHomeOrnamentCurLevelInfo(self.info.homeTemplateId)
			local nextFacilityData = HomeFacilityData[upgradeInfo.homeTemplateId]

			if facilityData and nextFacilityData then
				local nextLevel = curLevel + 1

				ClientTextUtils.setText(self.view.txtLvNowUBaseText, "Lv." .. curLevel)
				ClientTextUtils.setText(self.view.txtLvAfterUBaseText, "Lv." .. nextLevel)
				ClientTextUtils.setText(self.view.textCostUSDFText, pg.getGameString("HOMELAND_LEVEL_UPGRADE_COST"))

				local curHomeData = HomeObjectData[self.info.homeTemplateId]
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

				local formulaList = HomeLandUtils.getLevelFormulaList(self.info.homeTemplateId, self.info.facilityId, upgradeInfo)

				if #formulaList > 0 then
					table.insert(attributeData, {
						tIndex = 1,
						formulaList = formulaList
					})
				end

				function self.view.listNewUList.luaRenderItem(button, index, data)
					if data.tIndex == 0 then
						local itemObjectReference = button:GetComponent("ObjectReference")
						local txtName = itemObjectReference:GetRefValue("txtNameUSDFText")
						local txtNumNow = itemObjectReference:GetRefValue("txtNumNowUSDFText")
						local txtNumAfter = itemObjectReference:GetRefValue("txtNumAfterUSDFText")

						ClientTextUtils.setText(txtName, data.name)
						ClientTextUtils.setText(txtNumNow, data.tDesc)
						ClientTextUtils.setText(txtNumAfter, data.nDesc)
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
									padding = 20,
									id = _data.id,
									itemCount = ClientUtils.getHomelandItemCountById(_data.itemId),
									targetRect = self.view.listNewUList,
									formulaInfo = formulaInfo,
									conditionLockText = _data.conditionLocked and formulaData.unlockDesc,
									lockText = _data.drawingLocked and not _data.conditionLocked and ClientHomelandUtils.getDrawingUnlockText(false, false) or nil,
									sourceItemId = _data.drawingLocked and not _data.conditionLocked and formulaData.unlockByItemId or nil,
									sourceTitle = _data.drawingLocked and not _data.conditionLocked and ClientHomelandUtils.getDrawingSourceTitle(false) or nil,
									price = Utils.getHomeItemPrice(defaultOutputItem),
									extra = {
										closeFun = function()
											if not IsNil(listItemUList) then
												listItemUList:DeselectAll()
											end
										end
									}
								})
							end
						end

						listItemUList:SetList(data.formulaList)
					end
				end

				self.view.listNewUList:SetList(attributeData)

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

				self.view.costUWidget:SetActive(#costData > 0)

				function self.view.listRewardUList.luaRenderItem(button, index, data)
					LuaUIUtils.renderCostItem(button, data)
				end

				self.view.listRewardUList:SetList(costData)

				local coinId = HomelandConfigData.homeCurrencyId or 1010
				local coinNum = upgradeInfo.upgradeCost and upgradeInfo.upgradeCost[coinId] or 0

				self.view.layoutConsumeUWidget:SetActive(coinNum > 0)

				self.view.iconConsumeUImage.url = LuaUIUtils.getIconByItemId(coinId)

				local hasCount = pg.me:getItemCountById(coinId)
				local showCoinNum = coinNum

				if hasCount < coinNum then
					showCoinNum = pg.getFormatText("<style=Debuff>{0}</style>", coinNum)
				end

				ClientTextUtils.setText(self.view.txtNumUSDFText, showCoinNum)

				self.upgradeData = {
					oldLv = curLevel,
					newLv = nextLevel,
					carryAttrs = attributeData,
					title = pg.getGameString("HOME_FACILITY_UPGRADE")
				}
			end
		end
	end
end

function HomelandLevelUpCtrl:onLevelUpSucc()
	self:close()
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_LEVEL_UP_RESULT, self.upgradeData)
end

function HomelandLevelUpCtrl:getIconList()
	local icon = {}

	table.insert(icon, {
		itemId = HomelandConfigData.homeCurrencyId or 1010
	})

	return icon
end

function HomelandLevelUpCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseBGUButton.luaClick()
		self:close()
	end

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		local upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(self.info.homeTemplateId)

		if upgradeInfo then
			pg.me.space:upgradeOrnament(self.info.ornamentId, upgradeInfo.homeTemplateId, false, "homeland")
		end
	end
end

function HomelandLevelUpCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomelandLevelUpCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandLevelUpCtrl:onShow()
	return
end

function HomelandLevelUpCtrl:onHide()
	return
end

return HomelandLevelUpCtrl
