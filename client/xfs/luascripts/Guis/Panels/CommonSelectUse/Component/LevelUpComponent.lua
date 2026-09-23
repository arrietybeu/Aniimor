-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonSelectUse\\Component\\LevelUpComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemUseChecker = require("Guis.Panels.Inventory.Helper.ItemUseChecker")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local Utils = require("Common.Utils.Utils")
local LevelUpComponent = Class.LightClass("LevelUpComponent", UIComponent)
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

function LevelUpComponent:findObjects()
	return
end

function LevelUpComponent:overrideAddListener()
	function self.view.iPropList.luaRenderItem(item, _, data)
		self:instantiateItem(item, data)
	end

	function self.view.btnCancel.luaClick()
		self.ctrl:closePanel()
	end

	function self.view.btnExit.luaClick()
		self.ctrl:closePanel()
	end

	function self.view.btnConfirm.luaClick()
		self:onConfirm()
	end

	function self.view.selector.luaValueChanged(value)
		self:onAddLvChanged(value)
	end

	function self.view.btnRulesUButton.luaRenderTooltip(button, toolTip)
		local objectReference = toolTip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_MAX_UPGRADE_LEVEL_TIP"))
	end

	function self.view.btnPetUButton.luaRenderTooltip(button, toolTip)
		local add, curExp, maxExp = ItemUseChecker.parseConsumeInfo(self.ctrl.iData.petId, self.itemMap, self.petExpAddRatio)
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

function LevelUpComponent:overrideOnShow()
	local a, b, c, d, e = ItemUseChecker.checkConsumeWithUpLv(self.ctrl.iData.petId, self.ctrl.iData.selectList, 1)

	self.itemMap = a
	self.petExpAddRatio = e

	ClientTextUtils.setText(self.view.iTitle, pg.getLocalizationText(self.ctrl.iData.title))

	local dataList = self.model:parsePropData(self.ctrl.iData.selectList)

	self.view.iPropList:SetList(dataList)

	local maxLv = ItemUseChecker.checkPetCanUpMaxLv(self.ctrl.iData.petId)

	ClientTextUtils.setText(self.view.txtLevelMax, string.format(pg.getGameString("PET_MAX_LEVEL"), maxLv))

	local maxAddLv, state = ItemUseChecker.checkUsePropMaxLevel(self.ctrl.iData.petId, self.ctrl.iData.selectList)

	self.view.selector:SetMaxValueWithoutNotify(maxAddLv)
	self.view.selector:SetMinValueWithoutNotify(math.min(1, maxAddLv))

	self.oldAddLv = 0

	local curLv = math.min(1, maxAddLv)

	self.view.selector.value = curLv

	local recordAdd, recordCurExp, recordMaxExp = ItemUseChecker.parseConsumeInfo(self.ctrl.iData.petId, self.itemMap, self.petExpAddRatio)
	local recordExpRatio

	if state == "canUpgrade" then
		ClientTextUtils.setText(self.view.txtWarning, "")
	elseif state == "notEnough" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("EXP_PROP_NOT_ENOUGH"))

		recordExpRatio = LuaUIUtils.safeDiv(recordCurExp, recordMaxExp)
	elseif state == "fullLv" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("FULL_LEVELED"))
	elseif state == "maxUpLv" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("INCREASE_TITLE_INC_MAX_LEVEL"))
	elseif state == "canBreak" then
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("NEED_LEVEL_BREAKTHROUGH"))
	end

	self.view.imgPetUImage.url = LuaUIUtils.getPetIcon(self.ctrl.iData.iconName, LuaUIUtils.PET_ICON, self.ctrl.iData.label)

	self:onAddLvChanged(curLv, recordExpRatio)
end

function LevelUpComponent:initView()
	return
end

function LevelUpComponent:onAddLvChanged(addLv, recordExpRatio)
	local itemMap, curExp, beyondExp, maxExp, petExpAddRatio = ItemUseChecker.checkConsumeWithUpLv(self.ctrl.iData.petId, self.ctrl.iData.selectList, addLv)

	if beyondExp == nil then
		return
	end

	self.itemMap = itemMap
	self.petExpAddRatio = petExpAddRatio

	self.view.iPropList:RefreshList()

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

	if recordExpRatio then
		self.view.sliderNowUSlider.value = recordExpRatio == 0 and recordExpRatio or math.max(recordExpRatio, 0.005)
	else
		self.view.sliderNowUSlider.value = LuaUIUtils.safeDiv(curExp, maxExp)
	end

	self.view.sliderAddUSlider.value = LuaUIUtils.safeDiv(beyondExp, maxExp)

	local enable = addLv > 0

	for _, v in pairs(itemMap) do
		if v > 0 then
			enable = true

			break
		end
	end

	self.view.btnConfirm:TryChangePage("enable", enable and 1 or 0)

	self.view.btnConfirm.interactable = enable

	local petInfo = pg.me:getPetInfo(self.ctrl.iData.petId)
	local _, maxLevel = Utils.getPetExpMaxAdd(pg.me, self.ctrl.iData.petId)

	ClientTextUtils.setText(self.view.txtLevelNowUText, string.format("Lv.%s/%s", petInfo.level + addLv, maxLevel))
end

function LevelUpComponent:instantiateItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	txtNumUText.disabledLocalization = true

	function item.luaClick()
		local select = false

		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.ownNum,
				targetRect = item
			})

			select = true
		end

		local btnList = self.view.iPropList:GetAllButtons()

		for i = 0, btnList.Length - 1 do
			local v = btnList[i]

			v.isSelected = v == item and select
		end
	end

	function item.luaTooltipPopup(button, open)
		button.isSelected = open
	end

	item:TryChangePage("Exchange", 0)
	item:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	local useNum = self.itemMap[data.id] or 0

	LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum, useNum, 1)
	item:SetSelected(false)
	item:TryChangePage("Added", useNum > 0 and 1 or 0)
end

function LevelUpComponent:onConfirm()
	LuaMsgUtils.useItemBatch(self.itemMap, {
		petId = self.ctrl.iData.petId
	}, function()
		pg.game.audio:playEvent("SFX_UI_PetRaise_Upgrade")
		self:overrideOnShow()
	end)
end

function LevelUpComponent:destroy()
	return
end

return LevelUpComponent
