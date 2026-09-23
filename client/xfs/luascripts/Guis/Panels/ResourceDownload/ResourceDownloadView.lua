-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ResourceDownload\\ResourceDownloadView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ResourceDownloadView = Class.LightClass("ResourceDownloadView", UIView)

function ResourceDownloadView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnViewUButton = self.objectReference:GetRefValue("btnViewUButton")
	self.btnGoUButton = self.objectReference:GetRefValue("btnGoUButton")

	local btnGoObjectReference = self.btnGoUButton.transform:GetComponent("ObjectReference")

	self.txtGoUText = btnGoObjectReference and btnGoObjectReference:GetRefValue("txtNameUText")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.txtProgressUSDFText = self.objectReference:GetRefValue("txtProgressUSDFText")
	self.txtDetailsUSDFText = self.objectReference:GetRefValue("txtDetailsUSDFText")
end

return ResourceDownloadView
