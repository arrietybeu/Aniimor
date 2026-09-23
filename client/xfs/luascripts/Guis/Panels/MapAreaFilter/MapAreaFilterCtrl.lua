-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MapAreaFilter\\MapAreaFilterCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Bitset = require("Common.Bitset")
local ClientConst = require("Const.ClientConst")
local MapHelper = require("GameApp.Map.MapHelper")
local MapAreaFilterCtrl = Class.LightClass("MapAreaFilterCtrl", UICtrl)

function MapAreaFilterCtrl:addListener()
	function self.view.closeBtn.luaClick()
		self:dismiss()
	end

	function self.view.resetBtn.luaClick()
		self.selectedAreaIds = {}

		self:initCountry()

		self.isDirty = true
	end

	function self.view.confirmBtn.luaClick()
		if self.isDirty then
			pg.game.map:saveMapAreaSelectedSetting(self.selectedAreaIds)
		end

		self:dismiss()

		if self.callback then
			self.callback(self.selectedAreaIds, self.isDirty)
		end
	end

	function self.view.countryList.luaRenderItem(button, index, data)
		self:onRenderCountryItem(button, index, data)
	end

	function self.view.mapAreaList.luaRenderItem(button, index, data)
		self:onRenderMapAreaItem(button, index, data)
	end

	function self.view.smallMapAreaList.luaRenderItem(button, index, data)
		self:onRenderSmallMapAreaItem(button, index, data)
	end
end

function MapAreaFilterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:init(info)
end

function MapAreaFilterCtrl:onShow()
	UICtrl.onShow(self)
end

function MapAreaFilterCtrl:init(info)
	self.nationId = info[1]
	self.callback = info[2]
	self.selectedAreaIds = pg.game.map:getMapAreaSelectedSetting()

	self:initCountry()
end

function MapAreaFilterCtrl:initCountry()
	self.isDirty = false
	self.selecedFlags = {}
	self.countryAreaList = MapHelper.getNationAreaUnlockList(self.nationId)

	self.view.countryList:SetList(self.countryAreaList)
	self.view.countryCom:TryChangePage("Empty", table.getCount(self.countryAreaList) > 0 and 0 or 1)
end

function MapAreaFilterCtrl:onRenderCountryItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameTxt = objectReference:GetRefValue("nameTxt")
	local countyConfig = self.model:getNationConfig(data.countryId)

	ClientTextUtils.setTextWithId(nameTxt, countyConfig.name)

	function button.luaClick()
		self:onClickCountryBtn(button, data, false)

		self.isDirty = true
	end

	if (#self.countryAreaList == 1 or self.selectedAreaIds[data.countryId]) and index == 0 then
		button.isSelected = true

		self:onClickCountryBtn(button, data, true)
	end
end

function MapAreaFilterCtrl:onClickCountryBtn(button, data, defaultSelect)
	if not button.isSelected or defaultSelect then
		if self.selectedAreaIds[data.countryId] == nil then
			self.selectedAreaIds[data.countryId] = {}
		end

		self.curMapAreaIdList = data.mapAreaIdList

		self.view.mapAreaList:SetList(data.mapAreaIdList)
		self.view.mapAreaCom:TryChangePage("Empty", table.getCount(data.mapAreaIdList) > 0 and 0 or 1)
	else
		self.selectedAreaIds[data.countryId] = nil

		self.view.mapAreaList:SetList({})
		self.view.mapAreaCom:TryChangePage("Empty", 1)
		self.view.smallMapAreaList:SetList({})
		self.view.smallMapAreaCom:TryChangePage("Empty", 1)
	end
end

function MapAreaFilterCtrl:onRenderMapAreaItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameTxt = objectReference:GetRefValue("nameTxt")
	local mapAreaConfig = self.model:getMapAreaConfig(data.mapAreaId)

	ClientTextUtils.setTextWithId(nameTxt, mapAreaConfig.areaName)

	function button.luaClick()
		self:onClickMapAreaBtn(button, data, false)

		self.isDirty = true
	end

	if #self.curMapAreaIdList == 1 or self.selectedAreaIds[data.countryId][data.mapAreaId] then
		button.isSelected = true

		self:onClickMapAreaBtn(button, data, true)
	end
end

function MapAreaFilterCtrl:onClickMapAreaBtn(button, data, defaultSelect)
	if not button.isSelected or defaultSelect then
		if self.selectedAreaIds[data.countryId][data.mapAreaId] == nil then
			self.selectedAreaIds[data.countryId][data.mapAreaId] = {}
		end

		self.view.smallMapAreaList:SetList(data.smallAreaIdList)
		self.view.smallMapAreaCom:TryChangePage("Empty", table.getCount(data.smallAreaIdList) > 0 and 0 or 1)
	else
		self.selectedAreaIds[data.countryId][data.mapAreaId] = nil

		self.view.smallMapAreaList:SetList({})
		self.view.smallMapAreaCom:TryChangePage("Empty", 1)
	end
end

function MapAreaFilterCtrl:onRenderSmallMapAreaItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameTxt = objectReference:GetRefValue("nameTxt")
	local smallMapAreaConfig = self.model:getSmallMapAreaConfig(data.smallAreaId)

	ClientTextUtils.setTextWithId(nameTxt, smallMapAreaConfig.areaName)

	function button.luaClick()
		local selected

		if self.selectedAreaIds[data.countryId][data.mapAreaId][data.smallAreaId] then
			selected = false
			self.selectedAreaIds[data.countryId][data.mapAreaId][data.smallAreaId] = nil
		else
			selected = true
			self.selectedAreaIds[data.countryId][data.mapAreaId][data.smallAreaId] = true
		end

		button:TryChangePage("Type", selected and 1 or 0)

		self.isDirty = true
	end

	button.isSelected = self.selectedAreaIds[data.countryId] and self.selectedAreaIds[data.countryId][data.mapAreaId] and self.selectedAreaIds[data.countryId][data.mapAreaId][data.smallAreaId] == true

	button:TryChangePage("Type", button.isSelected and 1 or 0)
end

return MapAreaFilterCtrl
