-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonSelectUse\\Component\\LevelBreakthroughComponent.lua

local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local LevelBreakthroughComponent = Class.LightClass("LevelBreakthroughComponent", UIComponent)
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

function LevelBreakthroughComponent:findObjects()
	return
end

function LevelBreakthroughComponent:overrideAddListener()
	function self.view.btnConfirm.luaClick()
		self:onClickEnsure()
	end

	function self.view.btnCancel.luaClick()
		self.ctrl:closePanel()
	end

	function self.view.btnExit.luaClick()
		self.ctrl:closePanel()
	end

	function self.view.iPropList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end
end

function LevelBreakthroughComponent:overrideOnShow()
	if not self.ctrl.iData.petId then
		return
	end

	self.replacedItemList = {}

	ClientTextUtils.setText(self.view.iTitle, pg.getGameString("LEVEL_BREAKTHROUGH"))

	self.petDetails = self.model:getPetDetails(self.ctrl.iData.petId)
	self.view.sliderNowUSlider.value = self.petDetails.expRate

	self.view.imgPetUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(self.petDetails.iconName, LuaUIUtils.PET_ICON, self.petDetails.label, self.petDetails.gender), function()
		return
	end)
	ClientTextUtils.setText(self.view.txtLvUSDFText, string.format("%s/%s", self.petDetails.level, self.petDetails.maxLevel))

	self.nextBreakLevel = self.model:getNextBreakthroughLevel(self.ctrl.iData.petId)

	ClientTextUtils.setText(self.view.breakThroughTipOld, self.petDetails.maxLevel)
	ClientTextUtils.setText(self.view.breakThroughTip, self.nextBreakLevel)
	self:refreshItemList()

	function self.view.btnPetUButton.luaRenderTooltip(button, toolTip)
		local curExp = self.petDetails.curExp
		local maxExp = self.petDetails.maxExp
		local detailStr = string.format(pg.getGameString("PET_EXP_DESCRIPTION_1"), curExp, maxExp)
		local PetManagementUtils = require("Utils.PetManagementUtils")
		local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

		PetManagementUtils.customRefreshBuffInfoTooltip(toolTip, PetManagementDataHelper.BuffInfoToolTipType.Buff, {
			buffName = pg.getGameString("CURRENT_PET_EXP"),
			buffDesc = detailStr
		})
	end
end

function LevelBreakthroughComponent:initView()
	return
end

function LevelBreakthroughComponent:refreshItemList()
	local items

	self.success = nil
	self.replacedInfo = {}
	items, self.success, self.replacedInfo = self.model:getRequiredItems(self.petDetails.templateId, self.ctrl.iData.petId)

	self.view.iPropList:SetList(items)

	if self.success then
		self.view.btnConfirm:TryChangePage("button", 0)

		self.view.btnConfirm.interactable = true

		if next(self.replacedInfo) then
			self.view.txtWarning.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(self.view.txtWarning, string.format("<color=#ACB0BF>%s</color>", pg.getGameString("USE_REPLACED_ITEM")))
		else
			self.view.txtWarning.gameObject:SetActiveEx(false)
		end
	else
		self.view.btnConfirm:TryChangePage("button", 4)

		self.view.btnConfirm.interactable = false

		self.view.txtWarning.gameObject:SetActiveEx(true)
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("HOMELAND_ITEM_NOT_ENOUGH"))
	end
end

function LevelBreakthroughComponent:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	txtNumUText.disabledLocalization = true

	local beReplaced = false

	for _, v in pairs(self.replacedInfo) do
		if v.oriItemId == data.id then
			beReplaced = true

			break
		end
	end

	button:TryChangePage("Added", 0)

	if beReplaced then
		button:TryChangePage("Exchange", 1)
	else
		button:TryChangePage("Exchange", 0)
	end

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

		local btnList = self.view.iPropList:GetAllButtons()

		for i = 0, btnList.Length - 1 do
			local v = btnList[i]

			v.isSelected = v == button and select
		end
	end

	function button.luaTooltipPopup(_, open)
		button.isSelected = open
	end

	button:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	if beReplaced then
		LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum, data.requiredNum, 2)
	else
		LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum, data.requiredNum, 1)
	end

	button:SetSelected(false)
end

function LevelBreakthroughComponent:onClickEnsure()
	if self.success then
		if next(self.replacedInfo) then
			local leftItems = {}
			local rightItems = {}

			for index, v in pairs(self.replacedInfo) do
				local iData = ItemData[v.newItemId]
				local leftItem = {
					id = v.newItemId,
					ownNum = ItemUtils.getItemCountById(pg.me, v.newItemId),
					quality = iData.quality,
					itemName = iData.itemName,
					iconName = LuaUIUtils.getIconByIconId(iData.icon),
					replaceNum = v.newNum
				}

				leftItems[index] = leftItem
				iData = ItemData[v.oriItemId]

				local rightItem = {
					id = v.oriItemId,
					ownNum = ItemUtils.getItemCountById(pg.me, v.oriItemId),
					quality = iData.quality,
					itemName = iData.itemName,
					iconName = LuaUIUtils.getIconByIconId(iData.icon),
					replaceNum = v.oriNum
				}

				rightItems[index] = rightItem
			end

			pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_TIP, {
				leftItem = leftItems,
				rightItem = rightItems,
				ensureCb = function()
					pg.me:serverMsg("RPC_CS_PetBreakthrough", self.ctrl.iData.petId, function(res)
						if res == 0 then
							pg.game.audio:playEvent("SFX_UI_PetRaise_Breakthrough")
							facade:SendMessageCommand(MessageName.ON_PET_BREAKTHROUGH_SUCCESS, {
								petId = self.ctrl.iData.petId
							})
							pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_RESULT, {
								petId = self.ctrl.iData.petId,
								breakLevel = self.nextBreakLevel
							})
						end
					end)
				end
			})
		else
			pg.me:serverMsg("RPC_CS_PetBreakthrough", self.ctrl.iData.petId, function(res)
				if res == 0 then
					pg.game.audio:playEvent("SFX_UI_PetRaise_Breakthrough")
					facade:SendMessageCommand(MessageName.ON_PET_BREAKTHROUGH_SUCCESS, {
						petId = self.ctrl.iData.petId
					})
					pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_RESULT, {
						petId = self.ctrl.iData.petId,
						breakLevel = self.nextBreakLevel
					})
				end
			end)
		end
	else
		pg.global.showBubbleMessageById(10217)
	end
end

function LevelBreakthroughComponent:destroy()
	return
end

return LevelBreakthroughComponent
