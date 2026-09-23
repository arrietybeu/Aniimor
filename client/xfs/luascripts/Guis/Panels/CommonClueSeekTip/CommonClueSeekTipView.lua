-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonClueSeekTip\\CommonClueSeekTipView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonClueSeekTipView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonClueSeekTipView = Class.LightClass("CommonClueSeekTipView", UIView)

function CommonClueSeekTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUPopupForm = self.objectReference:GetRefValue("rootUPopupForm")
	self.btnDetailUButton = self.objectReference:GetRefValue("btnDetailUButton")
	self.textUBaseText = self.objectReference:GetRefValue("textUBaseText")
	self.iconUWidget = self.objectReference:GetRefValue("iconUWidget")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.nameUBaseText = self.objectReference:GetRefValue("nameUBaseText")
	self.titleUWidget = self.objectReference:GetRefValue("titleUWidget")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.collectiblesTagUContainer = self.objectReference:GetRefValue("collectiblesTagUContainer")
end

function CommonClueSeekTipView:registerObjects()
	return
end

function CommonClueSeekTipView:initView()
	return
end

return CommonClueSeekTipView
