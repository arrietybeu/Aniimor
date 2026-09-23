-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetConfirm\\PetConfirmCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetConfirmCtrl = Class.LightClass("PetConfirmCtrl", UICtrl)

PetConfirmCtrl.messages = {}

function PetConfirmCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	ClientTextUtils.setText(self.view.titleUBaseText, info.title or "")
	ClientTextUtils.setText(self.view.detailsUBaseText, info.desc or "")

	if info.tip then
		ClientTextUtils.setText(self.view.txtTipsUBaseText, info.tip or "")
	end

	self.view.txtTipsUBaseText:SetActive(info.tip)
	self.uiScene:setExRawImageProRef(self.view.rawPetRawImagePro, 800, 800)
end

function PetConfirmCtrl:addListener()
	function self.view.cancelUButton.luaClick()
		if self.info.cancelCb then
			self.info.cancelCb()
		end

		self:close()
	end

	function self.view.confirmUButton.luaClick()
		if self.info.confirmCb then
			self.info.confirmCb()
		end

		self:close()
	end
end

function PetConfirmCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetConfirmCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetConfirmCtrl:onShow()
	return
end

function PetConfirmCtrl:onHide()
	return
end

return PetConfirmCtrl
