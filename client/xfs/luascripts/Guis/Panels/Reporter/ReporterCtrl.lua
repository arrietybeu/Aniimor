-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Reporter\\ReporterCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ReporterCtrl = Class.LightClass("ReporterCtrl", UICtrl)
local PetReportUIComponent = require("Guis.Panels.Reporter.Component.PetReportUIComponent")
local PetSubmitUIComponent = require("Guis.Panels.Reporter.Component.PetSubmitUIComponent")
local PropSubmitUIComponent = require("Guis.Panels.Reporter.Component.PropSubmitUIComponent")
local UIConst = require("Const.UIConst")

ReporterCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function ReporterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.propSubmitComponent = PropSubmitUIComponent.new(self, self.view.pbPropSubmit)
end

function ReporterCtrl:addListener()
	return
end

function ReporterCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function ReporterCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info.ids == 1 then
		self:dismiss()
	elseif info.ids == 2 then
		self:switchPropSubmit(info.data, info.callback)
	elseif info.ids == 3 then
		self:switchPetSubmit(info.data, info.callback)
	elseif info.ids == 4 then
		self:switchOwnPetSubmit(info.data, info.callback)
	end
end

function ReporterCtrl:setPageIndex(index)
	self.view.component:TryChangePage("State", index)

	local show = index == self.model.NONE

	if show then
		self:dismiss()
	end
end

function ReporterCtrl:switchPropSubmit(eventParam, cb)
	self.propSubmitComponent:switchReportState(true, eventParam, cb)
end

function ReporterCtrl:switchPetSubmit(eventParam, cb)
	return
end

function ReporterCtrl:switchOwnPetSubmit(eventParam, cb)
	return
end

function ReporterCtrl:checkOpen(info)
	pg.global.ui:open(UIConst.UI_ID_REPORT, info)
end

function ReporterCtrl:onShow()
	pg.global.ui.topLogo:setTopLogoVisible(UIConst.TOPLOGO_VISIBLE_KEY.PET_REPORT, false)
end

function ReporterCtrl:onHide()
	pg.global.ui.topLogo:setTopLogoVisible(UIConst.TOPLOGO_VISIBLE_KEY.PET_REPORT, true)
end

return ReporterCtrl
