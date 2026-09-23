-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceWeatherComponent.lua

local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MeteorData = require("Data.meteor_data")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local WeatherData = require("Data.weather_data")
local AudioConst = require("Const.AudioConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local TriggerConst = require("Common.Const.TriggerConst")
local ClientSpaceWeatherComponent = class.Component("ClientSpaceWeatherComponent")

function ClientSpaceWeatherComponent:ctor()
	self._weatherChangeCallbacks = {}
end

function ClientSpaceWeatherComponent:start()
	return
end

function ClientSpaceWeatherComponent:on_spaceWeatherInfoMap_entry_added(blockAreaId, v)
	self:refreshSpaceWeather(blockAreaId)
	self:_notifyWeatherChange(nil, v, blockAreaId)
end

function ClientSpaceWeatherComponent:on_spaceWeatherInfoMap_changed(oldValue, newValue, blockAreaId)
	self:refreshSpaceWeather(blockAreaId)

	local curBlockAreaId = pg.game.map:getCurBlockAreaId()

	if curBlockAreaId == blockAreaId then
		pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_IN_TIME_WEATHER_BLOCK)
	end

	self:_notifyWeatherChange(oldValue, newValue, blockAreaId)
end

function ClientSpaceWeatherComponent:on_spaceWeatherInfoMap_weatherId_changed(oldValue, newValue, blockAreaId)
	self:_notifyWeatherChange(oldValue, newValue, blockAreaId)
end

function ClientSpaceWeatherComponent:_notifyWeatherChange(oldValue, newValue, blockAreaId)
	if not self._weatherChangeCallbacks then
		return
	end

	for callback, _ in pairs(self._weatherChangeCallbacks) do
		callback(oldValue, newValue, blockAreaId)
	end
end

function ClientSpaceWeatherComponent:refreshSpaceWeather(blockAreaId)
	if not pg.me:isSpaceOwner() then
		pg.me:refreshWeather(blockAreaId)
	end
end

function ClientSpaceWeatherComponent:on_meteorologyInfoMap_entry_deleted(k, v)
	self:refreshSpaceMeteorology(false, k)
end

function ClientSpaceWeatherComponent:on_meteorologyInfoMap_entry_added(k, v)
	self:refreshSpaceMeteorology(true, k)
end

function ClientSpaceWeatherComponent:on_meteorologyInfoMap_changed(oldv, newv, key)
	if key then
		self:refreshSpaceMeteorology(true, key)
	end
end

function ClientSpaceWeatherComponent:refreshSpaceMeteorology(enable, blockAreaId)
	if not pg.me:isSpaceOwner() then
		pg.me:setMeteorologyEnable(enable, blockAreaId)
	end
end

function ClientSpaceWeatherComponent:getWeather()
	local blockId = pg.game.map:getCurBlockAreaId()

	return self:getWeatherByAreaId(blockId)
end

function ClientSpaceWeatherComponent:getWeatherByAreaId(areaId)
	if not self.spaceWeatherInfoMap then
		return -1
	end

	local weatherInfo = self.spaceWeatherInfoMap[areaId]

	if not weatherInfo then
		return -1
	end

	return weatherInfo.weatherId
end

function ClientSpaceWeatherComponent:getMeteorology()
	local blockId = pg.game.map:getCurBlockAreaId()

	return self:getAreaMeteorology(blockId)
end

function ClientSpaceWeatherComponent:getAreaMeteorology(blockId)
	if not self.meteorologyInfoMap then
		return -1
	end

	if not self.meteorologyInfoMap[blockId] then
		return -1
	end

	if self.meteorologyInfoMap[blockId].endTime < Time.secondCache then
		return -1
	end

	return self.meteorologyInfoMap[blockId].meteorologyId
end

function ClientSpaceWeatherComponent:getAreaMeteorologyEndTime(blockId)
	if not self.meteorologyInfoMap then
		return -1
	end

	if not self.meteorologyInfoMap[blockId] then
		return -1
	end

	return self.meteorologyInfoMap[blockId].endTime
end

function ClientSpaceWeatherComponent:addWeatherChangeCallback(callback)
	if not self._weatherChangeCallbacks then
		self._weatherChangeCallbacks = {}
	end

	self._weatherChangeCallbacks[callback] = true
end

function ClientSpaceWeatherComponent:removeWeatherChangeCallback(callback)
	if self._weatherChangeCallbacks then
		self._weatherChangeCallbacks[callback] = nil
	end
end

return ClientSpaceWeatherComponent
