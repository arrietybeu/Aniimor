-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetOverview\\PetOverviewView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetOverviewView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetOverviewView = Class.LightClass("PetOverviewView", UIView)

function PetOverviewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootView = self.transform:GetComponent("UComponent")
	self.btnShareUButton = objectReference:GetRefValue("btnShareUButton")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.btnSwitchNameUSDFText = objectReference:GetRefValue("btnSwitchNameUSDFText")
	self.numInfoUList = objectReference:GetRefValue("numInfoUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
end

function PetOverviewView:registerObjects()
	return
end

function PetOverviewView:initView()
	return
end

return PetOverviewView
