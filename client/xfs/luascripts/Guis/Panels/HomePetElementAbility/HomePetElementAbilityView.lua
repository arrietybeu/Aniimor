-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePetElementAbility\\HomePetElementAbilityView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomePetElementAbilityView = Class.LightClass("HomePetElementAbilityView", UIView)

function HomePetElementAbilityView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.listAbilityUList = objectReference:GetRefValue("listAbilityUList")
end

function HomePetElementAbilityView:registerObjects()
	return
end

function HomePetElementAbilityView:initView()
	return
end

return HomePetElementAbilityView
