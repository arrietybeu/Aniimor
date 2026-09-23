-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Shop\\ShopSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local ShopSystem = Class.LightClass("ShopSystem", SystemBase)

function ShopSystem:onCreate()
	SystemBase.onCreate(self)

	self.interactShopPosterEvent = {}
end

function ShopSystem:setShopPosterInteractionEvent(func, id)
	if not self.interactShopPosterEvent then
		self.interactShopPosterEvent = {}
	end

	self.interactShopPosterEvent[id] = func
end

return ShopSystem
