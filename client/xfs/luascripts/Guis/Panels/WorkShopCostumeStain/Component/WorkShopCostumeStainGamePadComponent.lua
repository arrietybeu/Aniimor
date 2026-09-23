-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\Component\\WorkShopCostumeStainGamePadComponent.lua

local Class = require("Core.Framework.Class")
local GamePadComponent = require("Guis.Helper.GamePadComponent")
local WorkShopCostumeStainGamePadComponent = Class.LightClass("WorkShopCostumeStainGamePadComponent", GamePadComponent)

function WorkShopCostumeStainGamePadComponent:findObjects()
	return
end

function WorkShopCostumeStainGamePadComponent:initView()
	return
end

function WorkShopCostumeStainGamePadComponent:onDestroy()
	GamePadComponent.onDestroy(self)
end

return WorkShopCostumeStainGamePadComponent
