-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchReward\\Component\\RewardItemListComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RewardItemListComponent = Class.LightClass("RewardItemListComponent", UIComponent)

function RewardItemListComponent:ctor(ctrl, data)
	self.ctrl = ctrl
	self.model = ctrl.model
	self.view = ctrl.view
	self.rewardCardObjects = self.view:findRewardCardObjects(data.root)
	self.uiIndex = data.uiIndex
	self.level = self.uiIndex + 1
	self.petTemplateId = data.petTemplateId

	self:addListener()
	self:init(data.itemList)
end

function RewardItemListComponent:init(itemList)
	self.rewardCardObjects.listProp:SetList(itemList)
end

function RewardItemListComponent:addListener()
	function self.rewardCardObjects.listProp.luaRenderItem(button, index, data)
		self:onRefreshItem(button, index, data)
	end

	function self.rewardCardObjects.listProp.luaClick(button, data)
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			scale = 0.8,
			enableBtn = 0,
			autoVer = true,
			id = data.itemId,
			num = data.count,
			targetRect = button
		})
	end

	function self.rewardCardObjects.btnClaim.luaClick()
		self.ctrl:claimReward(self.level)
	end
end

function RewardItemListComponent:onRefreshItem(button, index, data)
	local itemObjects = self.view:findRewardItemObjects(button)

	itemObjects.root:TryChangePage("Quality", data.quality)

	itemObjects.imgItem.url = data.iconURL

	ClientTextUtils.setText(itemObjects.txtNum, data.count)
end

return RewardItemListComponent
