-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\Common\\SliderBubbleComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SliderBubbleComponent = Class.LightClass("SliderBubbleComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

SliderBubbleComponent.TYPE = {
	NORMAL = 0,
	NONE = 2,
	COLOR = 1
}

function SliderBubbleComponent:onCtor(info)
	self.type = info and info.type or self.TYPE.NORMAL
end

function SliderBubbleComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.valueUBaseText = self.objectReference:GetRefValue("valueUBaseText")
	self.nameUBaseText = self.objectReference:GetRefValue("nameUBaseText")
	self.rUBaseText = self.objectReference:GetRefValue("rUBaseText")
	self.gUBaseText = self.objectReference:GetRefValue("gUBaseText")
	self.bUBaseText = self.objectReference:GetRefValue("bUBaseText")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

function SliderBubbleComponent:initView()
	self.rootUComponent:TryChangePage("type", self.type)
	self.rootUComponent:SetActiveFastest(false)
end

function SliderBubbleComponent:initHide()
	self.rootUComponent:SetActiveFastest(false)
end

function SliderBubbleComponent:show()
	if self.state ~= "show" then
		self.rootUComponent:SetActiveFastest(true)
		self.rootUComponent:TryChangePage("state", "show")
	end
end

function SliderBubbleComponent:hide()
	if self.state ~= "hide" then
		self.rootUComponent:TryChangePage("state", "hide")
	end
end

function SliderBubbleComponent:setNormalValue(value, name)
	ClientTextUtils.setText(self.valueUBaseText, value)
	ClientTextUtils.setText(self.nameUBaseText, pg.getLocalizationText(name))
end

function SliderBubbleComponent:setColorValue(r, g, b)
	ClientTextUtils.setText(self.rUBaseText, r <= 1 and math.floor(r * 255 + 0.5) or r)
	ClientTextUtils.setText(self.gUBaseText, g <= 1 and math.floor(g * 255 + 0.5) or g)
	ClientTextUtils.setText(self.bUBaseText, b <= 1 and math.floor(b * 255 + 0.5) or b)
end

function SliderBubbleComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return SliderBubbleComponent
