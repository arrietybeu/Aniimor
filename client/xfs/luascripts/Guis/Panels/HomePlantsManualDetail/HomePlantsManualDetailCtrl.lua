-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsManualDetail\\HomePlantsManualDetailCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsManualDetailCtrl")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local HomePlantsManualDetailCtrl = Class.LightClass("HomePlantsManualDetailCtrl", UICtrl)

HomePlantsManualDetailCtrl.messages = {
	[MessageName.ON_HOME_PLANT_SINGLE_REWARD_CHANGED] = {
		"onSingleRewardChanged",
		true
	}
}

function HomePlantsManualDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomePlantsManualDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local uINodePokedexDetailsUWidget = objectReference:GetRefValue("uINodePokedexDetailsUWidget")

		ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(data.name))

		local itemData = ItemData[data.itemId]

		if itemData then
			self:setImage(iconUImage, itemData.icon)
		end

		if self:_plantIsGet(data.itemId) then
			uINodePokedexDetailsUWidget:TryChangePage("State", 1)
		else
			uINodePokedexDetailsUWidget:TryChangePage("State", 0)
		end
	end

	function self.view.listUList.luaClick(button, data)
		if self:_plantIsGet(data.itemId) == false then
			return
		end

		pg.global.ui.commonItemTip:open({
			num = 1,
			showConfirmBtn = true,
			id = data.itemId,
			targetRect = button,
			btnDataList = {
				{
					name = pg.getGameString("HOME_PLANT_SEND_BTN_NAME"),
					confirmFunc = function(confirmData)
						self:onClickGiftBtn(confirmData)
					end
				}
			}
		})
	end

	function self.view.btnClaimUButton.luaClick()
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("发送消息:家园变异植物 全收集领奖 %d", self.formulaId)
		end

		pg.me:reqGetPlantReward(self.formulaId)
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomePlantsManualDetail", function()
			self:refreshConsoleBarState()
		end)
	end
end

function HomePlantsManualDetailCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
		local isGetForNavItem = false

		if self.plantData then
			local navItem = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedUContent

			if navItem then
				local navItemIndex = self.view.listUList:GetChildIndex(navItem)

				if navItemIndex and navItemIndex >= 0 then
					local data = self.plantData[navItemIndex + 1]

					if data and data.itemId then
						isGetForNavItem = self:_plantIsGet(data.itemId)
					end
				end
			end
		end

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isGetForNavItem", isGetForNavItem)
	end
end

function HomePlantsManualDetailCtrl:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomePlantsManualDetail")
	end

	UICtrl.onDestroy(self)
end

function HomePlantsManualDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.plantId = info.id
	self.formulaId = info.formulaId
	self.numMax = info.numMax
	self.rewardId = info.rewardId
	self.icon = info.icon

	if self.plantId == nil then
		self.plantId, self.formulaId, self.numMax, self.rewardId, self.icon = self.model.getPlantInfo(info.plantIndex or 1)
	end

	self.plantData = self.model:getAllPlantsByFormulaId(self.formulaId, self.numMax)

	self.view.listUList:SetList(self.plantData)
	self:setImage(self.view.iconUImage, self.icon)
	self:refreshBtnAndRewardState()

	local curHasNum = LuaUIUtils.HomePlantManual_getCurPlantsNumByFormulaId(self.formulaId)

	ClientTextUtils.setText(self.view.txtUSDFText, string.format("<color=#96d0ff><size=84>%d</color></size>/%d", curHasNum, self.numMax))

	if curHasNum == self.numMax then
		self.view.btnPokedexUWidget:TryChangePage("State", 1)
	else
		self.view.btnPokedexUWidget:TryChangePage("State", 0)
	end

	self.view.autoHarvestUWidget:SetActive(false)
end

function HomePlantsManualDetailCtrl:onShow()
	return
end

function HomePlantsManualDetailCtrl:onHide()
	return
end

function HomePlantsManualDetailCtrl:refreshBtnAndRewardState()
	if pg.me.singlePlantReward[self.formulaId] == true then
		self.view.btnClaimUButton:SetActive(false)
		self.view.btnReadyUWidget:SetActive(true)
		LuaUIUtils.setRewardListByDropId(self.view.rewardList, self.rewardId, nil, true, false)
	else
		self.view.btnClaimUButton:SetActive(true)
		self.view.btnReadyUWidget:SetActive(false)

		local canGetReward = self:_isGetAllPlants()

		self.view.btnClaimUButton:TryChangePage("button", 4)

		self.view.btnClaimUButton.visualInteractable = canGetReward

		if canGetReward == true then
			LuaUIUtils.setRewardListByDropId(self.view.rewardList, self.rewardId, nil, false, true)
		else
			LuaUIUtils.setRewardListByDropId(self.view.rewardList, self.rewardId, nil, false, false)
		end
	end
end

function HomePlantsManualDetailCtrl:setImage(img, url)
	if url == nil or url == "" then
		return
	end

	if not img then
		return
	end

	if string.startsWith(url, "http") then
		img:SetTextureByUrl(url)
	else
		img.url = url
	end
end

function HomePlantsManualDetailCtrl:_plantIsGet(itemId)
	local map = pg.me.plantBook[self.formulaId]

	if map then
		return map[itemId] or false
	end

	return false
end

function HomePlantsManualDetailCtrl:_isGetAllPlants()
	return LuaUIUtils.HomePlantManual_getCurPlantsNumByFormulaId(self.formulaId) == self.numMax
end

function HomePlantsManualDetailCtrl:onClickGiftBtn(itemData)
	for itemId, cnt in pairs(itemData) do
		if self._getItemCount(itemId) > 0 then
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			end

			pg.global.ui.homePlantsSend:open({
				itemNum = 1,
				itemId = itemId
			})
		else
			pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)
		end

		return
	end
end

function HomePlantsManualDetailCtrl._getItemCount(itemId)
	local bagNum = ClientUtils.getItemCountById(itemId)
	local invNum = ClientUtils.getHomelandItemCountById(itemId)

	return bagNum + invNum
end

function HomePlantsManualDetailCtrl:onSingleRewardChanged()
	self:refreshBtnAndRewardState()
end

return HomePlantsManualDetailCtrl
