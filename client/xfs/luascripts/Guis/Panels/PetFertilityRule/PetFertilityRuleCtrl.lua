-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityRule\\PetFertilityRuleCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetFertilityRuleCtrl = Class.LightClass("PetFertilityRuleCtrl", UICtrl)

PetFertilityRuleCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetFertilityRuleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:Init()
	self:initGesture()
end

function PetFertilityRuleCtrl:onShow()
	return
end

function PetFertilityRuleCtrl:onHide()
	return
end

function PetFertilityRuleCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetFertilityRuleCtrl:Init()
	self.curPage = 0
	self.rulesData = self.model:getRulesData()

	if #self.rulesData <= 0 then
		self:closePanel()

		return
	end

	self.rulesCount = #self.rulesData

	self:adjustBtnState()

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderImgItem(button, index, data)
	end

	self.view.listUList:SetList(self.rulesData)
end

function PetFertilityRuleCtrl:destroy()
	self:destroyGesture()
end

function PetFertilityRuleCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnLeftUButton.luaClick()
		self:loadPage(true)
	end

	function self.view.btnRightUButton.luaClick()
		self:loadPage(false)
	end
end

function PetFertilityRuleCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_FERTILITY_RULE)
end

function PetFertilityRuleCtrl:initGesture()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnSwipeEnd(gesture)
		self:loadPage(gesture.swipeVector[1] > 0)
	end
end

function PetFertilityRuleCtrl:destroyGesture()
	fingerGestures.luaOnSwipeEnd = nil

	fingerGestures.DeActive()
end

function PetFertilityRuleCtrl:renderImgItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	local picGroup = scrollRectUScrollRect.content.transform:Find("LayoutPic"):GetComponent("ULayoutBox")
	local pic1 = picGroup.transform:Find("Pic1/ImgPic1"):GetComponent("UImage")
	local pic2 = picGroup.transform:Find("Pic2/ImgPic2"):GetComponent("UImage")
	local textContentList = scrollRectUScrollRect.content.transform:Find("List"):GetComponent("UList")

	if #data.pictures <= 0 then
		picGroup.gameObject:SetActiveEx(false)
	elseif #data.pictures == 1 then
		picGroup.gameObject:SetActiveEx(true)
		pic1.gameObject:SetActiveEx(true)
		pic2.gameObject:SetActiveEx(false)

		pic1.url = data.pictures[1]
	else
		picGroup.gameObject:SetActiveEx(true)
		pic1.gameObject:SetActiveEx(true)
		pic2.gameObject:SetActiveEx(true)

		pic1.url = data.pictures[1]
		pic2.url = data.pictures[2]
	end

	local temp = {}

	temp[1] = {
		tIndex = 0,
		title = data.title
	}
	temp[2] = {
		tIndex = 1,
		desc = data.desc
	}

	function textContentList.luaRenderItem(b, i, d)
		if d.tIndex == 0 then
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtDetailsUSDFText = objectReference1:GetRefValue("txtDetailsUSDFText")

			ClientTextUtils.setText(txtDetailsUSDFText, d.title)
		else
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtDetailsUSDFText = objectReference1:GetRefValue("txtDetailsUSDFText")

			ClientTextUtils.setText(txtDetailsUSDFText, d.desc)
		end
	end

	textContentList:SetList(temp)
end

function PetFertilityRuleCtrl:loadPage(isPrev)
	if isPrev then
		if self.curPage <= 0 then
			return
		else
			self:goToPageByIndex(self.curPage - 1)
		end
	elseif self.curPage >= self.rulesCount - 1 then
		return
	else
		self:goToPageByIndex(self.curPage + 1)
	end
end

function PetFertilityRuleCtrl:goToPageByIndex(index)
	self.curPage = index

	self.view.listUList:GoToIndex(index)
	self:adjustBtnState()
end

function PetFertilityRuleCtrl:adjustBtnState()
	self.view.root:TryChangePage("showPre", self.curPage > 0 and 1 or 0)
	self.view.root:TryChangePage("showNxt", self.curPage < self.rulesCount - 1 and 1 or 0)
end

return PetFertilityRuleCtrl
