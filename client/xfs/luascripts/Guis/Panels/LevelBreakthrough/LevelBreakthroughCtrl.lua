-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthrough\\LevelBreakthroughCtrl.lua

local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local LevelBreakthroughCtrl = Class.LightClass("LevelBreakthroughCtrl", UICtrl)

LevelBreakthroughCtrl.messages = {}

function LevelBreakthroughCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.replacedItemList = {}
end

function LevelBreakthroughCtrl:onShow()
	self.view.root:GetComponent("UComponent"):TryChangePage("Type", 1)

	if not self.info.petId then
		return
	end

	ClientTextUtils.setText(self.view.iTitle, pg.getGameString("LEVEL_BREAKTHROUGH"))

	self.petDetails = self.model:getPetDetails(self.info.petId)
	self.view.sliderNowUSlider.value = self.petDetails.expRate

	self.view.imgPetUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(self.petDetails.iconName, LuaUIUtils.PET_ICON, self.petDetails.label, self.petDetails.gender), function()
		return
	end)
	ClientTextUtils.setText(self.view.txtLvUSDFText, string.format("%s/%s", self.petDetails.level, self.petDetails.maxLevel))

	self.nextBreakLevel = self.model:getNextBreakthroughLevel(self.info.petId)

	ClientTextUtils.setText(self.view.breakThroughTip, string.format(pg.getGameString("LEVEL_BREAKTHROUGH_TIP"), self.nextBreakLevel))
	self:refreshItemList()

	function self.view.btnPetUButton.luaRenderTooltip(button, toolTip)
		local curExp = self.petDetails.curExp
		local maxExp = self.petDetails.maxExp
		local detailStr = string.format(pg.getGameString("PET_EXP_DESCRIPTION_1"), curExp, maxExp)

		PetManagementUtils.customRefreshBuffInfoTooltip(toolTip, PetManagementDataHelper.BuffInfoToolTipType.Buff, {
			buffName = pg.getGameString("CURRENT_PET_EXP"),
			buffDesc = detailStr
		})
	end
end

function LevelBreakthroughCtrl:destroy()
	return
end

function LevelBreakthroughCtrl:addListener()
	function self.view.btnConfirm.luaClick()
		self:onClickEnsure()
	end

	function self.view.btnCancel.luaClick()
		self:closePanel()
	end

	function self.view.btnExit.luaClick()
		self:closePanel()
	end

	function self.view.iPropList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end
end

function LevelBreakthroughCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_LEVEL_BREAKTHROUGH)
end

function LevelBreakthroughCtrl:refreshItemList()
	local items

	self.success = nil
	self.replacedInfo = {}
	items, self.success, self.replacedInfo = self.model:getRequiredItems(self.petDetails.templateId, self.info.petId)

	self.view.iPropList:SetList(items)

	if self.success then
		self.view.btnConfirm:TryChangePage("button", 0)

		self.view.btnConfirm.interactable = true

		self.view.txtWarning.gameObject:SetActiveEx(false)
	else
		self.view.btnConfirm:TryChangePage("button", 4)

		self.view.btnConfirm.interactable = false

		self.view.txtWarning.gameObject:SetActiveEx(true)
		ClientTextUtils.setText(self.view.txtWarning, pg.getGameString("HOMELAND_ITEM_NOT_ENOUGH"))
	end
end

function LevelBreakthroughCtrl:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	txtNumUText.disabledLocalization = true

	if data.isReplace then
		button:TryChangePage("Exchange", 1)
	else
		button:TryChangePage("Exchange", 0)
	end

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.ownNum,
				targetRect = button
			})
		end
	end

	function button.luaTooltipPopup(_, open)
		button.isSelected = open
	end

	button:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	local preferredState = data.isReplace and UIConst.ITEM_STATE.EXCHANGE or UIConst.ITEM_STATE.FULL

	LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum, data.requiredNum, preferredState)
end

function LevelBreakthroughCtrl:onClickEnsure()
	if self.success then
		if self.containsReplace then
			local iData = ItemData[self.replaceItemId]
			local leftItem = {
				id = self.replaceItemId,
				ownNum = ItemUtils.getItemCountById(pg.me, self.replaceItemId),
				quality = iData.quality,
				itemName = iData.itemName,
				iconName = LuaUIUtils.getIconByIconId(iData.icon),
				replaceNum = self.replacedNum
			}

			iData = ItemData[self.itemId]

			local rightItem = {
				id = self.itemId,
				ownNum = ItemUtils.getItemCountById(pg.me, self.itemId),
				quality = iData.quality,
				itemName = iData.itemName,
				iconName = LuaUIUtils.getIconByIconId(iData.icon),
				replaceNum = self.replacedNum
			}

			pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_TIP, {
				leftItem = leftItem,
				rightItem = rightItem,
				ensureCb = function()
					pg.me:serverMsg("RPC_CS_PetBreakthrough", self.info.petId, function(res)
						if res == 0 then
							facade:SendMessageCommand(MessageName.ON_PET_BREAKTHROUGH_SUCCESS, {
								petId = self.info.petId
							})
							pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_RESULT, {
								petId = self.info.petId,
								breakLevel = self.nextBreakLevel
							})
							self:closePanel()
						end
					end)
				end
			})
		else
			pg.me:serverMsg("RPC_CS_PetBreakthrough", self.info.petId, function(res)
				if res == 0 then
					facade:SendMessageCommand(MessageName.ON_PET_BREAKTHROUGH_SUCCESS, {
						petId = self.info.petId
					})
					pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_RESULT, {
						petId = self.info.petId,
						breakLevel = self.nextBreakLevel
					})
					self:closePanel()
				end
			end)
		end
	else
		pg.global.showBubbleMessageById(10217)
	end
end

function LevelBreakthroughCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

return LevelBreakthroughCtrl
