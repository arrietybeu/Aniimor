-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\FormulaTrackingUIComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local HomelandFacilityDataReverse = require("Data.homeland_facility_data_reverse")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandFormulaDataReverse = require("Data.homeland_formula_data_reverse")
local HomeObjectData = require("Data.home_object_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local PetData = require("Data.pet_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local MessageName = require("Const.MessageName")
local OrderLibData = require("Data.order_library_data")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local FormulaTrackingUIComponent = Class.LightClass("FormulaTrackingUIComponent", UIComponent)

FormulaTrackingUIComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemCountChanged",
		true
	},
	[MessageName.ON_HOME_ORDER_LIST_CHANGED] = {
		"onHomeOrderListChanged",
		true
	}
}

function FormulaTrackingUIComponent:onCtor(info)
	self.disableGamepadHotKey = info and info.disableGamepadHotKey == true
end

function FormulaTrackingUIComponent:initView()
	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPanel(self.formulaId)
	end)
end

function FormulaTrackingUIComponent:onDestroy()
	FormulaTrackingUIComponent.super.onDestroy(self)
end

function FormulaTrackingUIComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.iconPlotUImage = objectReference:GetRefValue("iconPlotUImage")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.formulaInfoUWidget = objectReference:GetRefValue("formulaInfoUWidget")
	self.petInfoUWidget = objectReference:GetRefValue("petInfoUWidget")
	self.listUList = objectReference:GetRefValue("listUList")
	self.list2UList = objectReference:GetRefValue("list2UList")
	self.txtTimeUSDFText = objectReference:GetRefValue("txtTimeUSDFText")
	self.iconTimeUImage = objectReference:GetRefValue("iconTimeUImage")
	self.petHeadUButton = objectReference:GetRefValue("petHeadUButton")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.iconWorkUImage = objectReference:GetRefValue("iconWorkUImage")
	self.txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
	self.listItemUList = objectReference:GetRefValue("listItemUList")
	self.arrowUWidget = objectReference:GetRefValue("arrowUWidget")
	self.orderULayoutBox = objectReference:GetRefValue("orderULayoutBox")
	self.txtOrderUSDFText = objectReference:GetRefValue("txtOrderUSDFText")
	self.keyCloseHotKeyContent = objectReference:GetRefValue("keyCloseHotKeyContent")

	self:initHotKeyBindings()
end

function FormulaTrackingUIComponent:initHotKeyBindings()
	if self.disableGamepadHotKey then
		if self.keyCloseHotKeyContent then
			self.keyCloseHotKeyContent.gameObject:SetActiveEx(false)
		end

		if self.gamepadCloseBinding then
			self.gamepadCloseBinding.actionPath = nil
		end

		if self.formulaTrackingLTBinding then
			self.formulaTrackingLTBinding.actionPath = nil
		end

		self.isFormulaTrackingLTHeld = false

		return
	end

	if pg.game.input:isUsingGamepad() then
		self:initGamepadHotKeys()
	else
		self:initKeyboardHotKeys()
	end
end

function FormulaTrackingUIComponent:initGamepadHotKeys()
	self.isFormulaTrackingLTHeld = false

	local closeKB = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCloseUButton.gameObject, "FormulaTrackingClose")

	closeKB.isVirtual = true
	closeKB.actionPath = "Raw/GamepadButtonWest"

	function closeKB.luaTrigger(inputInfo)
		if not self.isFormulaTrackingLTHeld then
			return true
		end

		if inputInfo.phase == "Performed" and self.btnCloseUButton.luaClick then
			self.btnCloseUButton.luaClick()
		end
	end

	self.gamepadCloseBinding = closeKB

	self.keyCloseHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonWest")
	self.keyCloseHotKeyContent.gameObject:SetActiveEx(false)

	local ltBind = KeyBindingPro.GetOrAddKeyBindingByName(self.uWidget.content.gameObject, "formulaTrackingLTBind")

	ltBind.isVirtual = true
	ltBind.actionPath = "Raw/GamepadLeftTrigger"

	function ltBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.isFormulaTrackingLTHeld = true

			self.keyCloseHotKeyContent.gameObject:SetActiveEx(true)
		elseif inputInfo.phase == "Canceled" then
			self.isFormulaTrackingLTHeld = false

			self.keyCloseHotKeyContent.gameObject:SetActiveEx(false)
		end

		return true
	end

	self.formulaTrackingLTBinding = ltBind
end

function FormulaTrackingUIComponent:initKeyboardHotKeys()
	self.isFormulaTrackingLTHeld = false

	if self.keyCloseHotKeyContent then
		self.keyCloseHotKeyContent.gameObject:SetActiveEx(false)
	end

	if self.gamepadCloseBinding then
		self.gamepadCloseBinding.actionPath = nil
	end

	if self.formulaTrackingLTBinding then
		self.formulaTrackingLTBinding.actionPath = nil
	end
end

function FormulaTrackingUIComponent:onInputDeviceChanged(deviceType)
	self:initHotKeyBindings()
end

function FormulaTrackingUIComponent:addListener()
	function self.btnCloseUButton.luaClick(button, data)
		local _pinnedFormulaList = pg.me.pinnedFormulaList or {}
		local oldItemId = _pinnedFormulaList[1]

		pg.me:requestSetPinnedFormulas({}, function()
			if oldItemId ~= nil then
				local temp = pg.getGameString("HOME_TRACKING_FORMULA_TIPS")
				local oldConfigData = ItemData[oldItemId]

				if oldConfigData then
					pg.global.ui.tips:showTextTip(pg.getFormatText(temp, pg.getLocalizationText(oldConfigData.itemName)))
				end
			end
		end)
	end

	ClientTextUtils.setText(self.txtStateUSDFText, pg.getGameString("HOMELAND_TIPS_KEEP_WORK"))
end

function FormulaTrackingUIComponent:refreshPanel(formulaId)
	if self.formulaId ~= formulaId then
		self.currentOrderInsId = nil
	end

	self.formulaId = formulaId

	if not self.formulaId or not self.uWidget:CheckURLLoaded() then
		self.uWidget:SetActive(false)

		return
	end

	local formulaData = HomelandFormulaData[formulaId]

	if not formulaData then
		self.uWidget:SetActive(false)

		return
	end

	self.uWidget:SetActive(true)

	if not self.disableGamepadHotKey then
		self.isFormulaTrackingLTHeld = false

		if self.keyCloseHotKeyContent then
			self.keyCloseHotKeyContent.gameObject:SetActiveEx(false)
		end
	end

	local facilityIds = HomelandFacilityDataReverse[formulaId]

	for _, v in ipairs(facilityIds or EMPTY_TABLE) do
		local homeObjectCfg = HomeObjectData[v]

		if homeObjectCfg then
			self.iconPlotUImage.url = homeObjectCfg.plotIconId or ""

			local revertInfo = RevertHomeUpgradeData[v]
			local facilityLevel = revertInfo and revertInfo[2] or 1

			ClientTextUtils.setText(self.txtTitleUSDFText, "Lv." .. facilityLevel)

			break
		end
	end

	local resultInfo = {}
	local outputMap = HomeLandUtils.getFormulaOutputMap(formulaData)

	for outputItemId, outputItemNum in pairs(outputMap) do
		table.insert(resultInfo, {
			id = outputItemId,
			num = outputItemNum
		})
	end

	local workNum = tostring(formulaData.workload)
	local workIcon = AddressDataConst.HOME_TIPS_WORK_ICON

	if formulaData.time then
		workNum = LuaUIUtils.getCountDownString(formulaData.time, nil, true)
		workIcon = AddressDataConst.HOME_TIPS_TIME_ICON
	end

	if formulaData.pet then
		self.formulaInfoUWidget:SetActive(false)
		self.petInfoUWidget:SetActive(true)
		LuaUIUtils.renderPetItemSimple(self.petHeadUButton, {
			label = 0,
			petId = formulaData.pet
		})

		self.petHeadUButton.draggable = false

		local petCfg = PetData[formulaData.pet]
		local petName = petCfg and pg.getLocalizationText(petCfg.name) or ""

		self.petHeadUButton.enabledTooltip = true

		function self.petHeadUButton.luaRenderTooltip(btn, cmp)
			local ref = cmp:GetComponent("ObjectReference")
			local txtNameUSDFText = ref:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("HOME_PET_FAMILY_WORK_TIPS"), petName))
		end

		function self.listItemUList.luaRenderItem(button, idx, data)
			LuaUIUtils.renderRewardItem(button, data, nil, true)
		end

		self.listItemUList:SetList(resultInfo)

		self.iconWorkUImage.url = workIcon

		ClientTextUtils.setText(self.txtNumUSDFText, workNum)
		self:refreshOrderNeedList()
	else
		self.formulaInfoUWidget:SetActive(true)
		self.petInfoUWidget:SetActive(false)

		function self.listUList.luaRenderItem(button, idx, data)
			LuaUIUtils.renderRewardItem(button, data, nil, true)

			button.PopupTool.hierarchy = 2
		end

		self:refreshConsumableList()
		self:refreshOrderNeedList()

		self.iconTimeUImage.url = workIcon

		ClientTextUtils.setText(self.txtTimeUSDFText, workNum)
	end
end

function FormulaTrackingUIComponent:refreshConsumableList()
	local formulaData = HomelandFormulaData[self.formulaId]

	if not formulaData or formulaData.pet then
		return
	end

	local consumableInfo = {}

	for i = 1, 3 do
		local consumableId = formulaData["consumable" .. i]
		local consumableNum = formulaData["consumableNum" .. i]

		if consumableId and consumableNum then
			local itemCount = 0

			if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
				itemCount = itemCount + ClientUtils.getHomelandItemCountById(consumableId)
			end

			local haveNum = itemCount

			if consumableNum <= itemCount then
				haveNum = string.format("<color=#bdf561>%s</color>", itemCount)
			else
				haveNum = string.format("<color=#f67574>%s</color>", itemCount)
			end

			local numText = haveNum .. "/" .. consumableNum

			table.insert(consumableInfo, {
				id = consumableId,
				num = numText
			})
		end
	end

	self.listUList:SetList(consumableInfo or {})
	self.arrowUWidget:SetActive(#consumableInfo > 0)
end

function FormulaTrackingUIComponent:refreshOrderNeedList()
	if not self.list2UList then
		return
	end

	local formulaData = HomelandFormulaData[self.formulaId]

	if not formulaData then
		self.list2UList:SetList({})

		return
	end

	local rawShowList = {}

	if pg.me then
		for _, propertyName in ipairs({
			"homeSeasonOrderList",
			"showList"
		}) do
			local orderList = pg.me[propertyName]

			if orderList then
				local rawOrderList = orderList.getRawTable and orderList:getRawTable() or orderList

				for _, orderInfo in ipairs(rawOrderList) do
					table.insert(rawShowList, orderInfo)
				end
			end
		end
	end

	local outputItemIds = {}
	local outputMap = HomeLandUtils.getFormulaOutputMap(formulaData)

	for outputItemId, _ in pairs(outputMap) do
		table.insert(outputItemIds, outputItemId)
	end

	if #outputItemIds == 0 then
		self.list2UList:SetList({})

		return
	end

	local targetOrderInsId

	if rawShowList then
		for _, orderInfo in ipairs(rawShowList) do
			if orderInfo.orderStatus == HomeOrderConst.STATUS.Incomplete then
				local orderCfg = OrderLibData[orderInfo.orderId]

				if orderCfg then
					for i = 1, 3 do
						local needItemId = orderCfg["unlockItem" .. i]

						if needItemId and needItemId[1] then
							for _, outputItemId in ipairs(outputItemIds) do
								if needItemId[1] == outputItemId then
									targetOrderInsId = orderInfo.insId

									break
								end
							end

							if targetOrderInsId then
								break
							end
						end
					end

					if targetOrderInsId then
						break
					end
				end
			end
		end
	end

	self.currentOrderInsId = targetOrderInsId

	local orderNeedInfo = {}

	if targetOrderInsId then
		for _, orderInfo in ipairs(rawShowList) do
			if orderInfo.insId == targetOrderInsId then
				local orderCfg = OrderLibData[orderInfo.orderId]

				if orderCfg then
					for i = 1, 3 do
						local needItemId = orderCfg["unlockItem" .. i]

						if needItemId and needItemId[1] then
							local itemId = needItemId[1]
							local needNum = needItemId[2] or 1
							local itemCount = ClientUtils.getItemCountById(itemId, true)

							if pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
								itemCount = itemCount + ClientUtils.getHomelandItemCountById(itemId)
							end

							local haveNum = itemCount

							if needNum <= itemCount then
								haveNum = string.format("<color=#bdf561>%s</color>", itemCount)
							else
								haveNum = string.format("<color=#f67574>%s</color>", itemCount)
							end

							local numText = haveNum .. "/" .. needNum

							table.insert(orderNeedInfo, {
								id = itemId,
								num = numText
							})
						end
					end
				end

				break
			end
		end
	end

	self.orderULayoutBox:SetActive(false)

	if #orderNeedInfo > 0 then
		local str = orderNeedInfo[1].num

		ClientTextUtils.setText(self.txtOrderUSDFText, str)
		self.orderULayoutBox:SetActive(true)
	end

	if not formulaData.pet then
		function self.list2UList.luaRenderItem(button, idx, data)
			LuaUIUtils.renderRewardItem(button, data, nil, true)

			button.PopupTool.hierarchy = 2
		end

		local resultInfo = {}
		local outputMap = HomeLandUtils.getFormulaOutputMap(formulaData)

		for outputItemId, outputItemNum in pairs(outputMap) do
			table.insert(resultInfo, {
				id = outputItemId,
				num = outputItemNum
			})
		end

		self.list2UList:SetList(resultInfo)
	end
end

function FormulaTrackingUIComponent:onHomeOrderListChanged()
	if not self.formulaId or not self.uWidget:CheckURLLoaded() then
		return
	end

	local pinnedFormulaList = pg.me and pg.me.pinnedFormulaList or {}

	if not pinnedFormulaList[1] or pinnedFormulaList[1] ~= self.formulaId then
		return
	end

	self:refreshOrderNeedList()
end

function FormulaTrackingUIComponent:onItemCountChanged()
	if not self.formulaId or not self.uWidget:CheckURLLoaded() then
		return
	end

	local pinnedFormulaList = pg.me and pg.me.pinnedFormulaList or {}

	if not pinnedFormulaList[1] or pinnedFormulaList[1] ~= self.formulaId then
		return
	end

	self:refreshConsumableList()
	self:refreshOrderNeedList()
end

function FormulaTrackingUIComponent:findObjects()
	return
end

return FormulaTrackingUIComponent
