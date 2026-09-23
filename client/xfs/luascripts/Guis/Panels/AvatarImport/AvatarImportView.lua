-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarImport\\AvatarImportView.lua

local logger = require("Core.Log.LoggerManager").getLogger("AvatarImportView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarImportView = Class.LightClass("AvatarImportView", UIView)

function AvatarImportView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.backUButton = objectReference:GetRefValue("backUButton")
	self.scanUButton = objectReference:GetRefValue("scanUButton")
	self.idUTMPInputField = objectReference:GetRefValue("idUTMPInputField")
	self.confirmUButton = objectReference:GetRefValue("confirmUButton")
	self.maskRayBoxTrans = objectReference:GetRefValue("maskRayBoxTrans")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function AvatarImportView:registerObjects()
	return
end

function AvatarImportView:initView()
	if UNITY_PS5 then
		self.scanUButton.gameObject:SetActiveEx(false)
	end
end

return AvatarImportView
