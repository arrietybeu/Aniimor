-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryItemUse\\InventoryItemUseCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local InventoryItemUseCtrl = Class.LightClass("InventoryItemUseCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ItemUseChecker = require("Guis.Panels.Inventory.Helper.ItemUseChecker")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

InventoryItemUseCtrl.messages = {}

local propList = {
	150001,
	150002,
	150003
}

function InventoryItemUseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function InventoryItemUseCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose1.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onBtnClosePanel()
		end
	end

	function self.view.btnClose1.luaClick()
		self:onBtnClosePanel()
	end

	function self.view.btnClose2.luaClick()
		self:onBtnClosePanel()
	end

	function self.view.btnCancal.luaClick()
		self:onBtnClosePanel()
	end

	function self.view.numSelector.luaValueChanged(addLv)
		self:refreshSelectInfo(addLv)
	end

	function self.view.petList.luaRenderItem(button, idx, data)
		self:onRenderPetItem(button, idx, data)
	end

	function self.view.propList.luaRenderItem(button, idx, data)
		self:onRenderPropItem(button, idx, data)
	end

	function self.view.btnConfirm.luaClick()
		self:usePetProp()
	end

	function self.view.btnRulesUButton.luaRenderTooltip(button, toolTip)
		local objectReference = toolTip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_MAX_UPGRADE_LEVEL_TIP"))
	end

	function self.view.btnPetUButton.luaRenderTooltip(_, toolTip)
		local add, curExp, maxExp = ItemUseChecker.parseConsumeInfo(self.selectPetId, self.itemMap, self.petExpAddRatio)
		local detailStr = string.format(pg.getGameString("PET_EXP_DESCRIPTION"), curExp, maxExp, add)

		PetManagementUtils.customRefreshBuffInfoTooltip(toolTip, PetManagementDataHelper.BuffInfoToolTipType.Buff, {
			buffName = pg.getGameString("CURRENT_PET_EXP"),
			buffDesc = detailStr
		})
	end

	function self.view.btnPetUButton.luaTooltipPopup(button, open)
		button:TryChangePage("Selected", open and 1 or 0)
	end
end

function InventoryItemUseCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function InventoryItemUseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.propId = info.itemId
	self.selectPetId = info.petId or 0
end

function InventoryItemUseCtrl:onShow()
	self:onRefreshView()
end

function InventoryItemUseCtrl:onRefreshView()
	self.oldAddLv = 0

	local dataList, index = self.model:getPetDataList(self.selectPetId)

	self.view.petList:SetList(dataList)

	self.itemMap, _, _, _, self.petExpAddRatio = ItemUseChecker.checkConsumeWithUpLv(dataList[index].id, propList, 1)

	local propData, _ = self.model:getExpPropDataList(self.propId)

	self.view.propList:SetList(propData)

	local res, tabBtn = self.view.petList:TryGetChildAt(index - 1)

	if res then
		tabBtn:OnClickSimulate()
	end
end

function InventoryItemUseCtrl:onRenderPetItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local petName = objectReference:GetRefValue("nameUText")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")
	local numCPUText = objectReference:GetRefValue("numCPUText")
	local elementsUList = objectReference:GetRefValue("elementsUList")
	local icon1UImage = objectReference:GetRefValue("icon1UImage")
	local icon2UImage = objectReference:GetRefValue("icon2UImage")
	local iconOrientationUImage = objectReference:GetRefValue("iconOrientationUImage")

	iconOrientationUImage.url = data.petTypeUrl
	button.name = index + 1
	button.draggable = false

	btnDelUButton.gameObject:SetActiveEx(false)

	function elementsUList.luaRenderItem(btn, idx, eleData)
		LuaUIUtils.setElementButtonNew(btn, eleData.element)
	end

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(petName, data.customName)
	else
		ClientTextUtils.setText(petName, pg.getLocalizationText(data.name))
	end

	if data.isShiny then
		button:TryChangePage("isFlash", 1)
	elseif data.isBoss then
		button:TryChangePage("isFlash", 2)
	else
		button:TryChangePage("isFlash", 0)
	end

	if data.gender == Const.GENDER_TYPE_MALE then
		button:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		button:TryChangePage("Gender", 1)
	else
		button:TryChangePage("Gender", 2)
	end

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label)

	elementsUList:SetList(data.elementNames)
	hpBarUHealthbar:TryChangePage("BarColor", 1)

	hpBarUHealthbar.hp = data.expRate
	hpBarUHealthbar.maxHp = 1

	if data.cp then
		numCPUText:SetActiveFastest(true)

		numCPUText.text = "CP:" .. data.cp
	else
		numCPUText:SetActiveFastest(false)
	end

	ClientTextUtils.setText(numLevelUText, data.level)
	button:TryChangePage("pet_number", index)

	function button.luaClick()
		self:onBtnClickPetItem(button)
	end
end

function InventoryItemUseCtrl:onBtnClickPetItem(button)
	local btnList = self.view.petList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("select", v == button and 1 or 0)
	end

	local data = button.dataFromUList

	self.selectPetId = data.id

	self:onRefreshUseNum()
end

function InventoryItemUseCtrl:onRenderPropItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	button.draggable = false
	iconUImage.url = data.icon

	button:TryChangePage("Quality", data.quality)

	local useNum = self.itemMap[data.id] or 0

	LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum, useNum, 1)
	button:SetSelected(false)
	button:TryChangePage("Added", useNum > 0 and 1 or 0)

	function button.luaClick()
		local select = false

		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.ownNum,
				targetRect = button
			})

			select = true
		end

		local btnList = self.view.propList:GetAllButtons()

		for i = 0, btnList.Length - 1 do
			local v = btnList[i]

			v.isSelected = v == button and select
		end
	end

	function button.luaTooltipPopup(item, open)
		item.isSelected = open
	end
end

function InventoryItemUseCtrl:onRefreshUseNum()
	if string.isNilOrEmpty(self.selectPetId) then
		return
	end

	local baseInfo = self.model:getPetBaseInfo(self.selectPetId)

	self.view.imgPet.url = baseInfo.icon

	local maxLv = ItemUseChecker.checkPetCanUpMaxLv(self.selectPetId)

	ClientTextUtils.setText(self.view.txtLevelMax, string.format(pg.getGameString("PET_MAX_LEVEL"), maxLv))

	local maxAddLv, state = ItemUseChecker.checkUsePropMaxLevel(self.selectPetId, propList)

	self.view.numSelector:SetMaxValueWithoutNotify(maxAddLv)
	self.view.numSelector:SetMinValueWithoutNotify(math.min(1, maxAddLv))

	local curLv = math.min(1, maxAddLv)

	self.view.numSelector.value = curLv

	self:refreshSelectInfo(curLv)

	if state == "canUpgrade" then
		ClientTextUtils.setText(self.view.txtWarning, "")
	elseif state == "notEnough" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("EXP_PROP_NOT_ENOUGH"))
	elseif state == "fullLv" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("FULL_LEVELED"))
	elseif state == "maxUpLv" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("INCREASE_TITLE_INC_MAX_LEVEL"))
	elseif state == "canBreak" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("NEED_LEVEL_BREAKTHROUGH"))
	end
end

function InventoryItemUseCtrl:refreshSelectInfo(addLv)
	local itemMap, curExp, beyondExp, maxExp, petExpAddRatio = ItemUseChecker.checkConsumeWithUpLv(self.selectPetId, propList, addLv)

	if beyondExp == nil then
		return
	end

	self.itemMap = itemMap
	self.petExpAddRatio = petExpAddRatio

	self.view.propList:RefreshList()

	if addLv > 0 then
		beyondExp = maxExp

		local changeLv = addLv - (self.oldAddLv or 0)

		if changeLv > 0 then
			ClientTextUtils.setText(self.view.txtLevelAdd, "+", tostring(changeLv))
			self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		elseif changeLv < 0 then
			ClientTextUtils.setText(self.view.txtLevelMinus, tostring(changeLv))
			self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User3)
		end
	end

	if addLv > 1 then
		curExp = 0
	end

	self.oldAddLv = addLv
	self.view.sliderNow.value = curExp / maxExp
	self.view.sliderAdd.value = beyondExp / maxExp

	local enable = addLv > 0

	for _, v in pairs(itemMap) do
		if v > 0 then
			enable = true

			break
		end
	end

	self.view.btnConfirm:TryChangePage("enable", enable and 1 or 0)

	self.view.btnConfirm.interactable = enable

	local baseInfo = self.model:getPetBaseInfo(self.selectPetId)

	ClientTextUtils.setText(self.view.txtLevelNow, string.format("Lv.%d", baseInfo.curLv + addLv))
end

function InventoryItemUseCtrl:usePetProp()
	LuaMsgUtils.useItemBatch(self.itemMap, {
		petId = self.selectPetId
	}, function()
		pg.game.audio:playEvent("SFX_UI_PetRaise_Upgrade")
		self:onRefreshView()
	end)
end

function InventoryItemUseCtrl:onBtnClosePanel()
	self:dismiss()
end

function InventoryItemUseCtrl:onHide()
	return
end

return InventoryItemUseCtrl
