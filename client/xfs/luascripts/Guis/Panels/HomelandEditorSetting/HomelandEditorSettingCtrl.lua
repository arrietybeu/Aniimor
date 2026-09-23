-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditorSetting\\HomelandEditorSettingCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local HomelandEditorSettingCtrl = Class.LightClass("HomelandEditorSettingCtrl", UICtrl)

function HomelandEditorSettingCtrl:ctor()
	HomelandEditorSettingCtrl.super.ctor(self)

	self.view = self.view
end

function HomelandEditorSettingCtrl:onCreate(info)
	HomelandEditorSettingCtrl.super.onCreate(self, info)
	self:initSetting()
end

function HomelandEditorSettingCtrl:onDestroy()
	return
end

function HomelandEditorSettingCtrl:addListener()
	function self.view.ornamentFilterList.luaRenderItem(button, index, data)
		self:rendererOrnamentFilterItem(button, index, data)
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end
end

function HomelandEditorSettingCtrl:initSetting()
	self.settingListInfo = {}

	table.insert(self.settingListInfo, {
		filterType = ClientConst.OrnamentFilterType.Heat
	})
	table.insert(self.settingListInfo, {
		filterType = ClientConst.OrnamentFilterType.Cool
	})
	table.insert(self.settingListInfo, {
		filterType = ClientConst.OrnamentFilterType.Electric
	})
	table.insert(self.settingListInfo, {
		filterType = ClientConst.OrnamentFilterType.Light
	})

	self.settingInfo = {}

	for _, data in ipairs(self.settingListInfo) do
		self.settingInfo[data.filterType] = pg.game.home:getHomeEditorOrnamentFilter(data.filterType)
	end

	self.view.ornamentFilterList:SetList(self.settingListInfo)
end

function HomelandEditorSettingCtrl:rendererOrnamentFilterItem(item, index, data)
	item:TryChangePage("Type", data.filterType)

	item.isSelected = not pg.game.home:getHomeEditorOrnamentFilter(data.filterType)

	function item.luaClick()
		pg.game.home:setHomeEditorOrnamentFilter(data.filterType, not pg.game.home:getHomeEditorOrnamentFilter(data.filterType))

		item.isSelected = not pg.game.home:getHomeEditorOrnamentFilter(data.filterType)
	end
end

function HomelandEditorSettingCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_HOMELAND_EDITOR_TOPLOGO] = true

	return whiteList
end

return HomelandEditorSettingCtrl
