-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Crawl\\Component\\CrawlAimComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("CrawlAimComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CrawlAimComponent = Class.LightClass("CrawlAimComponent", UIComponent)

function CrawlAimComponent:findObjects()
	return
end

function CrawlAimComponent:initView()
	return
end

function CrawlAimComponent:onMagnesisModeChange(enable)
	if not pg.game.controller:isInControlMainPlayer() then
		return
	end

	if enable then
		self:onMagnesisAimChange(0)
	end

	LuaUIUtils.setUIViewVisible(self.uWidget, enable)
end

function CrawlAimComponent:onMagnesisAimChange(isAim)
	if not pg.game.controller:isInControlMainPlayer() then
		return
	end

	self.uWidget:TryChangePage("State", isAim)
end

function CrawlAimComponent:onMagnesisBehaviorChange(isThrow)
	if not pg.game.controller:isInControlMainPlayer() then
		return
	end

	if isThrow then
		LuaUIUtils.setUIViewVisible(self.uWidget, false)
	end
end

function CrawlAimComponent:onFreeAimModeChange(enable)
	LuaUIUtils.setUIViewVisible(self.uWidget, enable)
end

function CrawlAimComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return CrawlAimComponent
