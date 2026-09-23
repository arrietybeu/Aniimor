-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetPreset\\Component\\AccessoryPetPresetGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AccessoryPetPresetGamePadComponent = Class.LightClass("AccessoryPetPresetGamePadComponent", UIComponent)

function AccessoryPetPresetGamePadComponent:findObjects()
	return
end

function AccessoryPetPresetGamePadComponent:initView()
	return
end

function AccessoryPetPresetGamePadComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return AccessoryPetPresetGamePadComponent
