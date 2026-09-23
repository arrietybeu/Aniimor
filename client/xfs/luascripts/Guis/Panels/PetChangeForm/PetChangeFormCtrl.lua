-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeForm\\PetChangeFormCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetChangeFormCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FormChangeComponent = require("Guis.Panels.PetChangeForm.Component.FormChangeComponent")
local FormChangeSmallComponent = require("Guis.Panels.PetChangeForm.Component.FormChangeSmallComponent")
local PetFormDetailComponent = require("Guis.Panels.PetChangeForm.Component.PetFormDetailComponent")
local PetChangeFormCtrl = Class.LightClass("PetChangeFormCtrl", UICtrl)

PetChangeFormCtrl.messages = {}

function PetChangeFormCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._curFormChangeComponent = FormChangeComponent.new(self, self.view.popupObjectReference)
	self._petFormDetailComponent = PetFormDetailComponent.new(self, self.view.petDetailsObjectReference)
end

function PetChangeFormCtrl:addListener()
	return
end

function PetChangeFormCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetChangeFormCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._info = info

	self._curFormChangeComponent:setChangeFormTarget(info.targetTemplateId, info.itemId)
	self._curFormChangeComponent:setInfo(info.petInfo, info.itemId)
end

function PetChangeFormCtrl:onShow()
	return
end

function PetChangeFormCtrl:onHide()
	return
end

function PetChangeFormCtrl:refreshInfo()
	self._curFormChangeComponent:refreshInfo()
end

function PetChangeFormCtrl:tryChangePopupState(state)
	if state == 0 then
		self:refreshInfo()
	else
		self._petFormDetailComponent:openPetFormDetail(self._info.petInfo)
	end

	self.view.rootWidget:TryChangePage("Popup", state)
end

function PetChangeFormCtrl:setChangeFormTarget(templateId, itemId)
	self._curFormChangeComponent:setChangeFormTarget(templateId, itemId)
	self:refreshInfo()
	self.view.rootWidget:TryChangePage("Popup", 0)
end

return PetChangeFormCtrl
