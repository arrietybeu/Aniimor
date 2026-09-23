-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientWeatherComponent.lua

local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MeteorData = require("Data.meteor_data")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local WeatherData = require("Data.weather_data")
local AudioConst = require("Const.AudioConst")
local UIConst = require("Const.UIConst")
local WeatherUtils = require("GameApp.Weather.WeatherUtils")
local MapBlockConfigData = require("Data.map_block_config_data")
local Utils = require("Common.Utils.Utils")
local SandboxConst = require("Common.Const.SandboxConst")
local SceneData = require("Data.scene_data")
local TriggerConst = require("Common.Const.TriggerConst")
local EventConst = require("Common.Const.EventConst")
local LeylineFlowerConst = require("Common.Const.LeylineFlowerConst")
local ClientWeatherComponent = class.Component("ClientWeatherComponent")

function ClientWeatherComponent:ctor()
	self.weatherChanged = {}
	self.meteorObjs = {}
	self.blockNewPet = {}
	self.impactObjs = {}
	self.meteorologyTime = {}
end

function ClientWeatherComponent:start()
	self:RecordWeatherInfo()
	self:startMeteorologyTimer()
	clientLevelUtils.notifyEcsWeather()
end

function ClientWeatherComponent:RecordWeatherInfo()
	self.lastWeatherInfo = {}

	for areaId, weatherInfoList in pairs(self.weatherInfoForecast) do
		if weatherInfoList ~= nil and #weatherInfoList > 0 then
			table.insert(self.lastWeatherInfo, areaId, weatherInfoList[1].weatherId)
		end
	end
end

function ClientWeatherComponent:destroy()
	for _, obj in pairs(self.impactObjs) do
		pg.global.resMgr:RemoveInstanceToCache(obj)
	end

	if self.meteorologyTimer ~= nil then
		TimerManager.removeTimer(self.meteorologyTimer)
	end

	pg.me.impactObjs = {}
end

function ClientWeatherComponent:onMeteorDict_valueChanged(oldValue, newValue, newKey)
	if newValue == 1 then
		self:refreshMeteor(newKey)
	end
end

function ClientWeatherComponent:refreshMeteor(meteorId)
	local curMeteorId = meteorId
	local meteorData = MeteorData[curMeteorId]

	pg.global.resMgr:GetInstanceFromCacheByLua(meteorData.meteorPrefabResID, function(meteorObj, userData)
		meteorObj.transform:SetParent(pg.global.effectMgr.worldEffectRoot)

		meteorObj.transform.position = meteorData.meteorWorldTransform
		meteorObj.transform.localRotation = Quaternion.Euler(meteorData.meteorRotation[1], meteorData.meteorRotation[2], meteorData.meteorRotation[3])
		self.meteorObjs[curMeteorId] = meteorObj

		TimerManager.addTimer(meteorData.DelayCreationTime, function()
			pg.global.resMgr:RemoveInstanceToCache(self.meteorObjs[curMeteorId])
			table.remove(self.meteorObjs, curMeteorId)
			self:CreateImpactObj(curMeteorId)
		end)
	end)
end

function ClientWeatherComponent:CreateImpactObj(meteorId)
	if self.impactObjs[meteorId] == nil then
		local meteorData = MeteorData[meteorId]

		pg.global.resMgr:GetInstanceFromCacheByLua(meteorData.impactPrefabResID, function(impactObj, userData)
			impactObj.transform:SetParent(pg.global.effectMgr.worldEffectRoot)

			impactObj.transform.position = meteorData.meteorWorldTransform

			local meteorController = impactObj:GetComponent("MeteorController")

			meteorController.meteorId = meteorId
			self.impactObjs[meteorId] = impactObj
		end)
	end
end

function ClientWeatherComponent:on_meteorDict_entry_added(k, v)
	if v == 1 then
		self:refreshMeteor(k)
	end
end

function ClientWeatherComponent:on_weatherInfoForecast_endTime_changed(oldVal, newVal, blockAreaId, index)
	self:refreshWeather(blockAreaId)
end

function ClientWeatherComponent:on_weatherInfoForecast_weatherId_changed(oldVal, newVal, blockAreaId, index)
	self:refreshWeather(blockAreaId)
end

function ClientWeatherComponent:on_weatherInfoForecast_entry_added(index, data, blockAreaId)
	return
end

function ClientWeatherComponent:on_weatherInfoForecast_delete(index, data, blockAreaId)
	self:refreshWeather(blockAreaId)
end

function ClientWeatherComponent:refreshWeather(blockAreaId)
	local lastWeatherId = self.lastWeatherInfo[blockAreaId]
	local curWeatherId = self:getWeather()

	if curWeatherId > 0 then
		if curWeatherId ~= lastWeatherId and self:isSpaceOwner() then
			table.insert(self.weatherChanged, blockAreaId)

			local curBlockAreaId = pg.game.map:getCurBlockAreaId()

			if curBlockAreaId == blockAreaId then
				local weatherData = WeatherData[curWeatherId]

				appFacade.pipelineManager:TrySetWeatherProfile(weatherData.weatherPrefab)
				clientLevelUtils.notifyEcsWeather()
				facade:SendMessageCommand(MessageName.WEATHER_REFRESH, {
					blockAreaId = blockAreaId
				})

				local eventData = {
					weatherId = curWeatherId
				}

				facade:sendLuaEvent(self.id .. SandboxConst.COMMON_EVENT.CURRENT_AREA_WEATHER_REFRESH, eventData)

				local pets = MapBlockConfigData[blockAreaId][WeatherUtils:getWeatherStateName(curWeatherId)]

				if pets ~= nil then
					table.insert(self.blockNewPet, curBlockAreaId)
				end
			else
				facade:SendMessageCommand(MessageName.WEATHER_REFRESH, {
					blockAreaId = blockAreaId
				})
			end
		end

		self.lastWeatherInfo[blockAreaId] = curWeatherId
	end
end

function ClientWeatherComponent:blockAreaHasNewPet(blockAreaId)
	return self.blockNewPet[blockAreaId] or false
end

function ClientWeatherComponent:clearChangedWeather()
	self.weatherChanged = {}
end

function ClientWeatherComponent:on_meteorologyInfoMap_entry_deleted(k, v)
	self:setMeteorologyEnable(false, k)
end

function ClientWeatherComponent:on_meteorologyInfoMap_entry_added(k, v)
	self:setMeteorologyEnable(true, k)

	if v and v.meteorologyId == LeylineFlowerConst.DEFAULT_RAINBOW_METEOROLOGY_ID then
		local curBlockAreaId = pg.game and pg.game.map and pg.game.map:getCurBlockAreaId()

		if curBlockAreaId == k and pg.global and pg.global.eventEmitter then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_METEOROLOGY_EXPERIENCED, {
				count = 1
			})
		end
	end
end

function ClientWeatherComponent:RPC_SC_MeteorologyChanged(blockId)
	facade:SendMessageCommand(MessageName.METEOROLOGY_REFRESH, {
		smallAreaId = blockId
	})
end

function ClientWeatherComponent:on_meteorologyInfoMap_changed(oldv, newv, key)
	if key then
		self:setMeteorologyEnable(true, key)
	end
end

function ClientWeatherComponent:setMeteorologyEnable(enable, blockAreaId)
	local space = pg.space
	local curBlockAreaId = pg.game.map:getCurBlockAreaId()

	if curBlockAreaId == blockAreaId then
		appFacade.pipelineManager:TrySetAuroraState(enable)
		facade:SendMessageCommand(MessageName.WEATHER_REFRESH, {
			blockAreaId = blockAreaId
		})

		if enable then
			self:recordMeteorologyTime()
			self:startMeteorologyTimer()
		end
	else
		facade:SendMessageCommand(MessageName.WEATHER_REFRESH, {
			blockAreaId = blockAreaId
		})
	end
end

function ClientWeatherComponent:recordMeteorologyTime()
	self.meteorologyTime = {}

	for areaId, meteorologyInfo in pairs(self.meteorologyInfoMap) do
		local leftTime = meteorologyInfo.endTime - Time.secondCache

		self.meteorologyTime[areaId] = leftTime
	end
end

function ClientWeatherComponent:startMeteorologyTimer()
	if Utils.isEmptyTable(self.meteorologyTime) then
		return
	end

	if self.meteorologyTimer then
		TimerManager.removeTimer(self.meteorologyTimer)
	end

	self.meteorologyTimer = TimerManager.addRepeatTimer(1, function()
		for areaId, time in pairs(self.meteorologyTime) do
			local leftTime = time - 1

			if leftTime <= 0 then
				local curBlockAreaId = pg.game.map:getCurBlockAreaId()

				if curBlockAreaId == areaId then
					self:setMeteorologyEnable(false, curBlockAreaId)
				end

				self.meteorologyTime[areaId] = nil
			else
				self.meteorologyTime[areaId] = leftTime
			end
		end
	end)
end

function ClientWeatherComponent:onEnterMeteorArea(meteorId)
	local impactObj = self.impactObjs[meteorId]

	if impactObj then
		pg.global.resMgr:RemoveInstanceToCache(impactObj)
	end

	self.impactObjs[meteorId] = nil

	self:serverMsg("RPC_CS_ActionMeteorSandbox", meteorId)
end

function ClientWeatherComponent:getWeather()
	local blockId = pg.game.map:getCurBlockAreaId()

	return self:getWeatherByAreaId(blockId)
end

function ClientWeatherComponent:getWeatherByAreaId(areaId)
	local space = pg.space

	if space then
		if Utils.isSpacePhase(space.sceneId) then
			local phaseWeather = SceneData[space.sceneId].forceWeatherType

			if phaseWeather and phaseWeather > 0 then
				return phaseWeather
			end
		end

		if not self:isSpaceOwner() then
			local id = space:getWeatherByAreaId(areaId)

			if id ~= -1 then
				return id
			end
		end
	else
		return 0
	end

	if self.weatherInfoForecast == nil then
		return 0
	end

	local weatherInfo = self.weatherInfoForecast[areaId]

	if not weatherInfo or #weatherInfo == 0 then
		return 0
	end

	return weatherInfo[1].weatherId
end

function ClientWeatherComponent:getMeteorology()
	local blockId = pg.game.map:getCurBlockAreaId()

	return self:getAreaMeteorology(blockId)
end

function ClientWeatherComponent:getAreaMeteorology(blockId)
	local space = pg.space

	if space and not self:isSpaceOwner() then
		local id = space:getAreaMeteorology(blockId)

		if id ~= -1 then
			return id
		end
	end

	if not self.meteorologyInfoMap then
		return 0
	end

	if not self.meteorologyInfoMap[blockId] then
		return 0
	end

	if self.meteorologyInfoMap[blockId].endTime < Time.secondCache then
		return 0
	end

	return self.meteorologyInfoMap[blockId].meteorologyId
end

function ClientWeatherComponent:getAreaMeteorologyEndTime(blockId)
	local space = pg.space

	if space and not self:isSpaceOwner() then
		local endtime = space:getAreaMeteorologyEndTime(blockId)

		if endtime ~= -1 then
			return endtime
		end
	end

	if not self.meteorologyInfoMap then
		return 0
	end

	if not self.meteorologyInfoMap[blockId] then
		return 0
	end

	return self.meteorologyInfoMap[blockId].endTime
end

function ClientWeatherComponent:RPC_SC_ResetMeteor()
	for _, impactObj in pairs(self.impactObjs) do
		pg.global.resMgr:RemoveInstanceToCache(impactObj)
	end

	self.impactObjs = {}
end

return ClientWeatherComponent
