-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\TradeMarket\\TradeMarketSubPageComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local TradeMarketSubPageComponent = Class.LightClass("TradeMarketSubPageComponent", UIComponent)

function TradeMarketSubPageComponent:ctor(ctrl, trans, extInfo)
	self._entered = false
	self.refUContainer = trans

	UIComponent.ctor(self, ctrl, trans, extInfo)
end

function TradeMarketSubPageComponent:enterPage()
	self._entered = true

	self.refUContainer:SetActive(true)

	if not self._contentLoaded then
		if self.refUContainer:CheckURLLoaded() then
			self:_onContentLoaded()
		else
			self.refUContainer:LoadDefaultUrlManually(function()
				self:_onContentLoaded()
			end)
		end
	else
		self:refreshPage()
	end
end

function TradeMarketSubPageComponent:exitPage()
	self._entered = false

	self.refUContainer:SetActive(false)
end

function TradeMarketSubPageComponent:_onContentLoaded()
	self._contentLoaded = true

	self:_findObjectRef()
	self:_addObjectListener()
	self:refreshPage()
end

function TradeMarketSubPageComponent:_findObjectRef()
	return
end

function TradeMarketSubPageComponent:_addObjectListener()
	return
end

function TradeMarketSubPageComponent:refreshPage()
	return
end

function TradeMarketSubPageComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return TradeMarketSubPageComponent
