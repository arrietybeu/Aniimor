-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Share\\ShareView.lua

local logger = require("Core.Log.LoggerManager").getLogger("ShareView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ShareView = Class.LightClass("ShareView", UIView)

function ShareView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.exitUButton = self.objectReference:GetRefValue("exitUButton")
	self.saveUButton = self.objectReference:GetRefValue("saveUButton")
	self.copyUButton = self.objectReference:GetRefValue("copyUButton")
	self.picUImage = self.objectReference:GetRefValue("picUImage")
	self.qrCodeRawImage = self.objectReference:GetRefValue("qrCodeRawImage")
	self.nameUBaseText = self.objectReference:GetRefValue("nameUBaseText")
	self.idUBaseText = self.objectReference:GetRefValue("idUBaseText")
end

function ShareView:registerObjects()
	return
end

function ShareView:initView()
	if UNITY_PS5 then
		self.saveUButton.gameObject:SetActiveEx(false)
	end
end

return ShareView
