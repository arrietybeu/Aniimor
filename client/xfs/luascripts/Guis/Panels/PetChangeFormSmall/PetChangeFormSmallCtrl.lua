-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeFormSmall\\PetChangeFormSmallCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetChangeFormCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FormChangeComponent = require("Guis.Panels.PetChangeForm.Component.FormChangeComponent")
local FormChangeSmallComponent = require("Guis.Panels.PetChangeForm.Component.FormChangeSmallComponent")
local PetFormDetailComponent = require("Guis.Panels.PetChangeForm.Component.PetFormDetailComponent")
local PetChangeFormSmallCtrl = Class.LightClass("PetChangeFormSmallCtrl", UICtrl)

PetChangeFormSmallCtrl.messages = {}

function PetChangeFormSmallCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._curFormChangeComponent = FormChangeSmallComponent.new(self, self.view.popupObjectReference)
	self._petFormDetailComponent = PetFormDetailComponent.new(self, self.view.petDetailsObjectReference)
end

function PetChangeFormSmallCtrl:addListener()
	return
end

function PetChangeFormSmallCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetChangeFormSmallCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._info = info

	self._curFormChangeComponent:setChangeFormTarget(info.targetTemplateId, info.itemId)
	self._curFormChangeComponent:setInfo(info.petInfo, info.itemId)
end

function PetChangeFormSmallCtrl:onShow()
	return
end

function PetChangeFormSmallCtrl:onHide()
	return
end

function PetChangeFormSmallCtrl:refreshInfo()
	self._curFormChangeComponent:refreshInfo()
end

function PetChangeFormSmallCtrl:tryChangePopupState(state)
	if state == 0 then
		self:refreshInfo()
	else
		self._petFormDetailComponent:openPetFormDetail(self._info.petInfo)
	end

	self.view.rootWidget:TryChangePage("Popup", state)
end

function PetChangeFormSmallCtrl:setChangeFormTarget(templateId, itemId)
	self._curFormChangeComponent:setChangeFormTarget(templateId, itemId)
	self:refreshInfo()
	self.view.rootWidget:TryChangePage("Popup", 0)
end

return PetChangeFormSmallCtrl
