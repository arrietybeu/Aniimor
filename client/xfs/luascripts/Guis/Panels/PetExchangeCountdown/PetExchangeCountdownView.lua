-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeCountdown\\PetExchangeCountdownView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeCountdownView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetExchangeCountdownView = Class.LightClass("PetExchangeCountdownView", UIView)

function PetExchangeCountdownView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
end

function PetExchangeCountdownView:registerObjects()
	return
end

function PetExchangeCountdownView:initView()
	return
end

return PetExchangeCountdownView
