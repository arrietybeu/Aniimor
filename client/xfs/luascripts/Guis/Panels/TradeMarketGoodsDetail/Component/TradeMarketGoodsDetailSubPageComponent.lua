-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\Component\\TradeMarketGoodsDetailSubPageComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeMarketGoodsDetailSubPageComponent = Class.LightClass("TradeMarketGoodsDetailSubPageComponent", UIComponent)

function TradeMarketGoodsDetailSubPageComponent:ctor(ctrl, uContainer, extInfo)
	self._entered = false
	self._contentLoaded = false
	self.refUContainer = uContainer

	UIComponent.ctor(self, ctrl, uContainer and uContainer.transform, extInfo)
end

function TradeMarketGoodsDetailSubPageComponent:findObjects()
	return
end

function TradeMarketGoodsDetailSubPageComponent:registerObjects()
	return
end

function TradeMarketGoodsDetailSubPageComponent:initView()
	self:setVisible(false)
end

function TradeMarketGoodsDetailSubPageComponent:onEnter()
	self._entered = true

	self:setVisible(true)

	if not self.refUContainer then
		return
	end

	if not self._contentLoaded then
		if self.refUContainer:CheckURLLoaded() then
			self:_onContentLoaded()
		else
			self.refUContainer:LoadDefaultUrlManually(function()
				self:_onContentLoaded()
			end)
		end
	else
		self:initPage()
	end
end

function TradeMarketGoodsDetailSubPageComponent:onExit()
	self._entered = false

	self:setVisible(false)
end

function TradeMarketGoodsDetailSubPageComponent:setVisible(visible)
	if self.refUContainer then
		self.refUContainer:SetActive(visible == true)
	end
end

function TradeMarketGoodsDetailSubPageComponent:_onContentLoaded()
	self._contentLoaded = true

	self:_findObjectRef()
	self:_addObjectListener()

	if self._entered then
		self:initPage()
	end
end

function TradeMarketGoodsDetailSubPageComponent:_getObjectReference()
	local content = self.refUContainer and self.refUContainer.content

	return content and content:GetComponent("ObjectReference") or nil
end

function TradeMarketGoodsDetailSubPageComponent:_findObjectRef()
	return
end

function TradeMarketGoodsDetailSubPageComponent:_addObjectListener()
	return
end

function TradeMarketGoodsDetailSubPageComponent:initPage()
	return
end

function TradeMarketGoodsDetailSubPageComponent:refreshPage()
	return
end

function TradeMarketGoodsDetailSubPageComponent:initFollowView()
	self.btnAttentionUButton:SetActive(true)

	self.progressAttentionUProgress.minValue = 0
	self.progressAttentionUProgress.maxValue = TradeMarketUtils.getFollowFullCount()

	function self.btnAttentionUButton.luaClick()
		self.ctrl:toggleFollowTradeItem()
	end

	self:refreshFollowState()
end

function TradeMarketGoodsDetailSubPageComponent:refreshFollowState()
	self.btnAttentionUButton.visualInteractable = not self.ctrl.isFollowRequesting
	self.progressAttentionUProgress.value = pg.me:isTradeItemFollow(self.ctrl.tradeItemKey) and TradeMarketUtils.getFollowFullCount() or 0
end

function TradeMarketGoodsDetailSubPageComponent:onDestroy()
	self._entered = false

	if self.btnAttentionUButton then
		self.btnAttentionUButton.luaClick = nil
	end

	self.refUContainer = nil

	UIComponent.onDestroy(self)
end

return TradeMarketGoodsDetailSubPageComponent
