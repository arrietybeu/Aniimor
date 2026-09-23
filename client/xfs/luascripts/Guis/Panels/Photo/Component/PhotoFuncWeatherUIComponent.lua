-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncWeatherUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncWeatherUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncWeatherUIComponent = Class.LightClass("PhotoFuncWeatherUIComponent", UIComponent)
local Const = require("Common.Const.Const")
local WeatherData = require("Data.weather_data")

PhotoFuncWeatherUIComponent.WeatherConfig = {
	{
		controlId = 0,
		id = 1
	},
	{
		controlId = 1,
		id = 2
	},
	{
		controlId = 2,
		id = 3
	},
	{
		controlId = 3,
		id = 4
	}
}
PhotoFuncWeatherUIComponent.TimeConfig = {
	{
		controlId = 4,
		id = Const.TimePeriod.Morning
	},
	{
		controlId = 5,
		id = Const.TimePeriod.Day
	},
	{
		controlId = 6,
		id = Const.TimePeriod.Dusk
	},
	{
		controlId = 7,
		id = Const.TimePeriod.Night
	}
}

function PhotoFuncWeatherUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function PhotoFuncWeatherUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listWeatherUList = self.objectReference:GetRefValue("listWeatherUList")
	self.listTimeUList = self.objectReference:GetRefValue("listTimeUList")
end

function PhotoFuncWeatherUIComponent:initView()
	local blockId = pg.game.map:getCurBlockAreaId()

	self.lastWeatherId = pg.me:getWeatherByAreaId(blockId)
	self.curWeatherId = self.lastWeatherId
	self.lastTimePeriod = pg.timePeriod
	self.curTimePeriod = self.lastTimePeriod

	function self.listWeatherUList.luaRenderItem(button, index, data)
		if not data.id then
			return
		end

		button:TryChangePage("Weather", data.controlId)
	end

	function self.listWeatherUList.luaClick(button, data)
		if not data.id then
			return
		end

		local weatherId

		if data.id == self.curWeatherId then
			weatherId = self.lastWeatherId
		else
			weatherId = data.id
		end

		self.curWeatherId = weatherId

		local weatherData = WeatherData[weatherId]

		if weatherData then
			appFacade.pipelineManager:TrySetWeatherProfile(weatherData.weatherPrefab)
		end

		self.preset = nil
	end

	function self.listTimeUList.luaRenderItem(button, index, data)
		if not data.id then
			return
		end

		button:TryChangePage("Weather", data.controlId)
	end

	function self.listTimeUList.luaClick(button, data)
		if not data.id then
			return
		end

		self.ctrl:hideLight()

		local timePeriod

		if data.id == self.curTimePeriod then
			timePeriod = self.lastWeatherId
		else
			timePeriod = data.id
		end

		self.curTimePeriod = timePeriod

		pg.space:setTimePeriodClient(timePeriod)
		self.ctrl:tryTriggerAllPetsAction()

		self.preset = nil
	end

	if self.preset then
		self:applyPreset(self.preset)
	end
end

function PhotoFuncWeatherUIComponent:onDestroy()
	UIComponent.onDestroy(self)

	if self.lastWeatherId ~= self.curWeatherId then
		local weatherData = WeatherData[self.lastWeatherId]

		if weatherData then
			appFacade.pipelineManager:TrySetWeatherProfile(weatherData.weatherPrefab)
		else
			appFacade.pipelineManager:TrySetWeatherProfile(WeatherData[1].weatherPrefab)
		end
	end

	if self.lastTimePeriod ~= self.curTimePeriod and pg.space then
		pg.space:setTimePeriodClient(self.lastTimePeriod)
	end
end

function PhotoFuncWeatherUIComponent:refreshUI()
	if not self.haveRefreshed then
		local dataList = {}

		for k, v in ipairs(self.WeatherConfig) do
			dataList[#dataList + 1] = v
		end

		self.listWeatherUList:SetList(dataList)
		self.listWeatherUList:DeselectAll()

		dataList = {}

		for k, v in ipairs(self.TimeConfig) do
			dataList[#dataList + 1] = v
		end

		self.listTimeUList:SetList(dataList)
		self.listTimeUList:DeselectAll()

		self.haveRefreshed = true
	end

	local weatherData = self.listWeatherUList.itemData

	for index, data in pairs(weatherData) do
		if data.id == self.curWeatherId then
			self.listWeatherUList:SelectItem(index)

			break
		end
	end

	local timeData = self.listTimeUList.itemData

	for index, data in pairs(timeData) do
		if data.id == self.curTimePeriod then
			self.listTimeUList:SelectItem(index)

			break
		end
	end
end

function PhotoFuncWeatherUIComponent:applyPreset(preset)
	local weatherId = preset.weatherId

	if weatherId then
		self.curWeatherId = weatherId

		local weatherData = WeatherData[weatherId]

		if weatherData then
			appFacade.pipelineManager:TrySetWeatherProfile(weatherData.weatherPrefab)
		end
	end

	local timeId = preset.timeId

	if timeId then
		self.curTimePeriod = timeId

		pg.space:setTimePeriodClient(timeId)
	end
end

function PhotoFuncWeatherUIComponent:saveToPreset(preset)
	preset.weatherId = self.curWeatherId
	preset.timeId = self.curTimePeriod
end

return PhotoFuncWeatherUIComponent
