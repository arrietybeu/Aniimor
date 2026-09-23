-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamDungeonComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TeamDungeonComponent = Class.LightClass("TeamDungeonComponent", UIComponent)

function TeamDungeonComponent:findObjects()
	self.btnModeSwitch = self.view.btnModeSwitch
	self.mapUWidget = self.view.mapUWidget
	self.mapName = self.view.mapName
	self.txtModeName = self.view.txtModeName
end

function TeamDungeonComponent:registerObjects()
	if self.btnModeSwitch then
		function self.btnModeSwitch.luaClick()
			self:onBtnModeSwitch()
		end
	end
end

function TeamDungeonComponent:refreshView(data)
	data = data or {}

	if self.txtModeName then
		ClientTextUtils.setText(self.txtModeName, data.modeName or "")
	end

	if self.mapUWidget and data.modeType ~= nil then
		self.mapUWidget:TryChangePage("mode", data.modeType)
	end

	if self.mapName then
		ClientTextUtils.setText(self.mapName, data.mapName or "")
	end

	if self.btnModeSwitch then
		LuaUIUtils.setUIVisible(self.btnModeSwitch, data.isLeader)
	end
end

function TeamDungeonComponent:onBtnModeSwitch()
	if self.ctrl and self.ctrl.onBtnModeSwitch then
		self.ctrl:onBtnModeSwitch()
	end
end

return TeamDungeonComponent
