-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\Component\\LoginAccountComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local LoginAccountComponent = Class.LightClass("LoginAccountComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

function LoginAccountComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.nameUInputField = self.objectReference:GetRefValue("nameUInputField")
	self.randomUButton = self.objectReference:GetRefValue("randomUButton")
	self.cancelUButton = self.objectReference:GetRefValue("cancelUButton")
	self.confirmUButton = self.objectReference:GetRefValue("confirmUButton")
end

function LoginAccountComponent:initView()
	self:addListener()
end

function LoginAccountComponent:onShow()
	return
end

function LoginAccountComponent:tryActivateInputField()
	self.nameUInputField:Select()
end

function LoginAccountComponent:onHide()
	return
end

function LoginAccountComponent:addListener()
	function self.randomUButton.luaClick()
		return
	end

	function self.confirmUButton.luaClick()
		local text = string.trim(self.nameUInputField.text)

		ClientTextUtils.setText(self.view.inputField, text)
		self.view.rootUComponent:TryChangePage("Account", "Close")
		pg.global.sdkManager:login()
	end

	function self.cancelUButton.luaClick()
		self.view.rootUComponent:TryChangePage("Account", "Close")
	end

	function self.nameUInputField.luaEndEdit(text)
		self.nameUInputField:DeSelect()
	end
end

return LoginAccountComponent
