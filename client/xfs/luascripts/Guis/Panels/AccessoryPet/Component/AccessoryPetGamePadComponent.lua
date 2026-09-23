-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPet\\Component\\AccessoryPetGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetAccessoryGamePadComponent = Class.LightClass("PetAccessoryGamePadComponent", UIComponent)

function PetAccessoryGamePadComponent:findObjects()
	return
end

function PetAccessoryGamePadComponent:initView()
	return
end

function PetAccessoryGamePadComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PetAccessoryGamePadComponent
