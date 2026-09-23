-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoginSelectServer\\LoginSelectServerView.lua

local logger = require("Core.Log.LoggerManager").getLogger("LoginSelectServerView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LoginSelectServerView = Class.LightClass("LoginSelectServerView", UIView)

function LoginSelectServerView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	self.listServerUList = objectReference:GetRefValue("listServerUList")
	self.btnSureUButton = objectReference:GetRefValue("btnSureUButton")

	local btnOC = self.btnSureUButton:GetComponent("ObjectReference")

	self.uIBtn1stConfirmUButton = btnOC:GetRefValue("uIBtn1stConfirmUButton")
	self.txtNameUText = btnOC:GetRefValue("txtNameUText")
	self.lockUImage = btnOC:GetRefValue("lockUImage")
	self.keyHotKeyContent = btnOC:GetRefValue("keyHotKeyContent")
end

function LoginSelectServerView:registerObjects()
	return
end

function LoginSelectServerView:initView()
	return
end

return LoginSelectServerView
