-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\Component\\ClothFabricComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientConst = require("Const.ClientConst")
local ClothFabricComponent = Class.LightClass("ClothFabricComponent", UIComponent)
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")

function ClothFabricComponent:findObjects()
	return
end

function ClothFabricComponent:initView()
	function self.view.patternList.luaRenderItem(button, _, data)
		self:onRenderPatternItem(button, data)
	end
end

function ClothFabricComponent:selectDefaultFabricTab()
	self:openFabric()
end

function ClothFabricComponent:openFabric()
	local maskDataList = self.model:getMaskDataList(2)

	self.view.patternList:SetList(maskDataList)

	self.selectMatTexIndex = nil

	local index = self.model:getMatAreaTexIdx(self.ctrl.selectAreaIdx)
	local res, subBtn = self.view.patternList:TryGetChildAt(index - 1)

	if not res then
		return
	end

	subBtn:OnClickSimulate()
end

function ClothFabricComponent:onRenderPatternItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconPattern = objectReference:GetRefValue("iconPattern")

	button:TryChangePage("State", 1)

	iconPattern.url = data.res

	function button.luaClick()
		self:onBtnClickPatternItem(button)
	end

	if data.res then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_CLOTHES_STAIN_PATTERN_ITEM, data.res)

		pg.global.setRedDot(treePath, button, data.showRedDot or false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
	end
end

function ClothFabricComponent:onBtnClickPatternItem(button)
	local btnList = self.view.patternList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("GamePadFocus", v == button and 1 or 0)
	end

	local data = button.dataFromUList
	local oldIndex = self.selectMatTexIndex

	self.selectMatTexIndex = data.index

	if oldIndex == nil then
		return
	end

	self.model:setMatAreaTexIdx(self.ctrl.selectAreaIdx, data.index)

	local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_CLOTHES_STAIN_PATTERN_ITEM, data.res)

	pg.me:setRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, false)

	data.showRedDot = false

	local index = self.view.patternList:GetChildIndex(button)

	self.view.patternList:RefreshElement(index)
end

function ClothFabricComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ClothFabricComponent
