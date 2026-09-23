-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\Component\\ItemCraftComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ItemCraftComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local ItemCraftComponent = Class.LightClass("ItemCraftComponent", UIComponent)

function ItemCraftComponent:enter(tabType)
	self.mainTabType = tabType

	if self.refUContainer:CheckURLLoaded() then
		self:onUILoaded()
	else
		self.refUContainer:LoadDefaultUrlManually(function()
			self:onUILoaded()
		end)
	end
end

function ItemCraftComponent:exit()
	return
end

function ItemCraftComponent:setFirstTabRed(button, index, data)
	return
end

function ItemCraftComponent:getRedStyle()
	return
end

ItemCraftComponent.pipeline = {
	base = 0,
	canOpen = 2,
	inCollection = 1
}

function ItemCraftComponent:ctor(ctrl, refUContainer, id)
	UIComponent.ctor(self, ctrl, refUContainer.transform)

	self.refUContainer = refUContainer
	self.cfgId = id
	self.refContainersLoaded = false
end

function ItemCraftComponent:onUILoaded()
	self.refContainersLoaded = true

	self:findObjects()
	self:addListener()
	self:refreshPage()
end

function ItemCraftComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local root = self.transform:GetChild(0)
	local objectReference = root:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
end

function ItemCraftComponent:addListener()
	function self.listUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			self:renderCraftItem(button, index, data)
		else
			self:renderCraftTitle(button, index, data)
		end
	end
end

function ItemCraftComponent:renderCraftItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnGo = objectReference:GetRefValue("btnGo")
	local txtBossCurrency = objectReference:GetRefValue("txtBossCurrency")
	local imgCostIten = objectReference:GetRefValue("imgCostIten")
	local listCostUList = objectReference:GetRefValue("listCostUList")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")
	local txtLock = objectReference:GetRefValue("txtLock")
	local btnLockInfo = objectReference:GetRefValue("btnLockInfo")
	local imgItemIcon = objectReference:GetRefValue("imgItemIcon")
	local txtItemName = objectReference:GetRefValue("txtItemName")
	local txtGoName = objectReference:GetRefValue("txtGoName")

	function listCostUList.luaRenderItem(button, idx, data)
		if data.tIndex == 0 then
			LuaUIUtils.setCompoundCard(button, data, false)
		end
	end

	function listRewardUList.luaRenderItem(button, idx, data)
		if data.tIndex == 0 then
			LuaUIUtils.setCompoundCard(button, data, true)
		end
	end

	btnLockInfo.enabledTooltip = true

	function btnLockInfo.luaRenderTooltip(button, toolTip)
		local objectReference = toolTip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.unlockDesc)
	end

	button:TryChangePage("ListState", data.unlock and "Normal" or "Lock")

	local craftInfo = self.model:getItemCraftInfo(data.craftId)

	if not craftInfo then
		listCostUList:SetList({})
		listRewardUList:SetList({})
		button:TryChangePage("Quality", "blue")

		return
	end

	button:TryChangePage("Quality", (craftInfo.quality or 0) >= 4 and "purple" or "blue")
	listCostUList:SetList(craftInfo.costList or {})
	listRewardUList:SetList(craftInfo.getList or {})
	ClientTextUtils.setText(txtBossCurrency, pg.getFormatText(pg.getGameString("SCHOOL_GUIDE_CRAFT_CONSUME_TIP"), craftInfo.currencyCost or 0))
	ClientTextUtils.setText(txtLock, pg.getGameString("SCHOOL_GUIDE_CRAFT_LOCK"))
	ClientTextUtils.setText(txtGoName, pg.getGameString("SCHOOL_GUIDE_HEAD_GOTO_BUTTON"))
	ClientTextUtils.setText(txtItemName, craftInfo.craftName or "")

	imgCostIten.url = craftInfo.currencyIcon
	imgItemIcon.url = craftInfo.craftIcon

	local costEnough = craftInfo.costEnough

	function btnGo.luaClick()
		if costEnough then
			pg.global.ui:open(UIConst.UI_ID_ITEM_COMPOSITE_POPUP_SINGLE, {
				compoundId = data.craftId,
				craftFunc = function()
					LuaUIUtils.sendCustomLog(Const.BILogName.SCHOOL_GUIDE_CRAFT, {
						item_get_id = data.craftId
					})
				end
			})
		else
			local curVitality = craftInfo.currencyId and ClientUtils.getItemCountById(craftInfo.currencyId) or 0
			local currencyNotEnough = craftInfo.currencyCost and craftInfo.currencyCost > 0 and curVitality < craftInfo.currencyCost
			local materialNotEnough = false

			if craftInfo.costList then
				for _, cost in ipairs(craftInfo.costList) do
					if ClientUtils.getItemCountById(cost.propId) < cost.countNeed then
						materialNotEnough = true

						break
					end
				end
			end

			if currencyNotEnough and not materialNotEnough then
				pg.global.ui.tips:showTextTip(pg.getGameString("SCHOOL_GUIDE_CRAFT_ENERGY_TIP"))
			else
				pg.global.ui.tips:showTextTip(pg.getGameString("SCHOOL_GUIDE_CRAFT_NOT_ENOUGH"))
			end
		end
	end
end

function ItemCraftComponent:renderCraftTitle(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	ClientTextUtils.setText(textUBaseText, data.title)
end

function ItemCraftComponent:refreshPage()
	local commonList = self.model:getItemCraftList()

	if commonList and #commonList > 0 then
		self.listUList:SetList(commonList)
	end
end

function ItemCraftComponent:refreshUI()
	if self.listUList then
		self.listUList:RefreshList()
	end
end

function ItemCraftComponent:onItemCountChanged()
	self:refreshUI()
end

function ItemCraftComponent:onRefreshCurrencyList()
	self:refreshUI()
end

function ItemCraftComponent:checkContentLoaded()
	return self.refContainersLoaded
end

return ItemCraftComponent
