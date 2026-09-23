-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChat\\PetChatCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local PetChatCtrl = Class.LightClass("PetChatCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetChatCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetChatCtrl:refreshContent(content)
	self.content = content

	self:showText()
end

function PetChatCtrl:showText()
	self.view.root.gameObject:SetActiveEx(true)
	self.view.rootAni:Play("VX_PetChat_In_New")

	if self.content ~= nil then
		ClientTextUtils.setText(self.view.content, self.content.DialogueTrans)
	end
end

function PetChatCtrl:closeText()
	if self.view == nil then
		return
	end

	UIUtils.PlayAnimation(self.view.rootAni, "VX_PetChat_Out_New", function()
		self.view.root.gameObject:SetActiveEx(false)
	end)
end

return PetChatCtrl
