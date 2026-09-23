-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetGiftTipsRecommend\\PetGiftTipsRecommendCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local HomeAbilityData = require("Data.home_ability_data")
local HomeAbilityLevelData = require("Data.home_ability_level_data")
local PetGiftTipsRecommendCtrl = Class.LightClass("PetGiftTipsRecommendCtrl", UICtrl)

function PetGiftTipsRecommendCtrl:onCreate(data)
	UICtrl.onCreate(self, data)
end

function PetGiftTipsRecommendCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data

	if self.iData.extra and self.iData.extra.openFun then
		self.iData.extra.openFun()
	end
end

function PetGiftTipsRecommendCtrl:checkCanOpen(showNotice, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function PetGiftTipsRecommendCtrl:addListener()
	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end
end

function PetGiftTipsRecommendCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetGiftTipsRecommendCtrl:onShow()
	if self.iData == nil then
		return
	end

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)
	self.view.rootCmp:OpenPopup(self.iData.targetRect)
	self:refreshGiftInfo()
	ClientTextUtils.setText(self.view.titleText, self.iData.title)
end

function PetGiftTipsRecommendCtrl:refreshGiftInfo()
	local data = self.iData
	local listUList = self.view.listUList

	function listUList.luaRenderItem(button, index, itemData)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailUSDFText")
		local iconRootUButton = objectReference:GetRefValue("iconRootUButton")

		iconRootUButton:TryChangePage("Quality", itemData.data.quality)

		iconUImage.url = itemData.data.icon

		if self.iData.type == UIConst.GIFT_TYPE.HOME then
			ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(itemData.data.homeDesc))
		else
			ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(itemData.data.desc))
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(itemData.data.name))
	end

	local tempData = {}

	for i = 1, #data.breedTalent do
		tempData[#tempData + 1] = {
			tIndex = 0,
			data = data.breedTalent[i]
		}
	end

	listUList:SetList(tempData)
end

function PetGiftTipsRecommendCtrl:onHide()
	return
end

return PetGiftTipsRecommendCtrl
