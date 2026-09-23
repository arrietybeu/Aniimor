-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerResearchStarPreview\\PlayerResearchStarPreviewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerResearchStarPreviewView = Class.LightClass("PlayerResearchStarPreviewView", UIView)

function PlayerResearchStarPreviewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.viewRoot = self.transform:GetComponent("UComponent")
	self.propTextUSDFText = objectReference:GetRefValue("propTextUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function PlayerResearchStarPreviewView:registerObjects()
	return
end

function PlayerResearchStarPreviewView:initView()
	return
end

return PlayerResearchStarPreviewView
