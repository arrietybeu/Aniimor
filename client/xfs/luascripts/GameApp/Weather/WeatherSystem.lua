-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Weather\\WeatherSystem.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("DialogueItemCmd")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local SceneData = require("Data.scene_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local SystemBase = require("GameApp.Core.SystemBase")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local WeatherData = require("Data.weather_data")
local TimerManager = require("Core.Timer.TimerManager")
local SandboxConst = require("Common.Const.SandboxConst")
local WeatherSystem = Class.LightClass("WeatherSystem", SystemBase)

function WeatherSystem:onCtor()
	SystemBase.onCtor(self)

	self.sunWeatherId = 1
	self.todTimes = {}
	self.clientWeatherOverride = nil
	self.lastServerWeatherId = nil
end

function WeatherSystem:onInit()
	SystemBase.onInit(self)
	self:onClear()
end

function WeatherSystem:onClear()
	return
end

function WeatherSystem:onSceneLoaded(sceneId, sceneName)
	self:refreshWeather(sceneId)
	self:refreshTideState()
end

function WeatherSystem:refreshWeather(sceneId)
	if self.initTimer then
		TimerManager.removeTimer(self.initTimer)
	end

	self.initTimer = TimerManager.addTimer(0.5, function()
		local blockId = pg.game.map:getCurBlockAreaId()

		if not pg.me then
			return
		end

		local curWeatherId = pg.me:getWeatherByAreaId(blockId)

		if curWeatherId > 0 then
			if self.clientWeatherOverride == nil then
				appFacade.pipelineManager:TrySetWeatherProfile(WeatherData[curWeatherId].weatherPrefab)
			end

			for meteorId, state in pairs(pg.me.meteorDict) do
				if state == 1 then
					pg.me:CreateImpactObj(meteorId)
				end
			end

			local meteorologyId = pg.me:getAreaMeteorology(blockId)

			if meteorologyId > 0 then
				appFacade.pipelineManager:TrySetAuroraState(true)
				pg.me:recordMeteorologyTime()
				pg.me:startMeteorologyTimer()
			else
				appFacade.pipelineManager:TrySetAuroraState(false)
			end

			facade:SendMessageCommand(MessageName.WEATHER_REFRESH, {
				blockAreaId = blockId
			})

			if self.blockTimer then
				TimerManager.removeTimer(self.blockTimer)
			end

			self.blockTimer = TimerManager.addRepeatTimer(1, function()
				local curBlockId = pg.game.map:getCurBlockAreaId()

				if self.lastBlockId and self.lastBlockId ~= curBlockId and pg.me then
					local lastWeatherId = pg.me:getWeatherByAreaId(self.lastBlockId)
					local curWeatherId = pg.me:getWeatherByAreaId(curBlockId)
					local lastMeteorologyId = pg.me:getAreaMeteorology(self.lastBlockId)
					local curMeteorologyId = pg.me:getAreaMeteorology(curBlockId)

					if lastWeatherId > 0 and curWeatherId > 0 and lastWeatherId ~= curWeatherId or lastMeteorologyId ~= curMeteorologyId then
						if self.clientWeatherOverride == nil then
							appFacade.pipelineManager:TrySetWeatherProfile(WeatherData[curWeatherId].weatherPrefab)
						end

						facade:SendMessageCommand(MessageName.WEATHER_REFRESH, {
							blockAreaId = curBlockId
						})

						local eventData = {
							weatherId = curWeatherId
						}

						facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.CURRENT_AREA_WEATHER_REFRESH, eventData)
					end
				end

				self.lastBlockId = curBlockId
			end)
		else
			appFacade.pipelineManager:TrySetWeatherProfile(WeatherData[self.sunWeatherId].weatherPrefab)

			if Utils.isSpaceCatchRogueDungeon(Utils.getSpaceType(sceneId)) then
				appFacade.pipelineManager:TrySetAuroraState(true)
			else
				appFacade.pipelineManager:TrySetAuroraState(false)
			end
		end
	end)
end

function WeatherSystem:setClientWeather(weatherId)
	local cfg = WeatherData[weatherId]

	if cfg == nil then
		return
	end

	if self.clientWeatherOverride == nil then
		local blockId = pg.game.map and pg.game.map:getCurBlockAreaId() or 0
		local serverId = pg.me and pg.me:getWeatherByAreaId(blockId) or nil

		if serverId ~= nil and serverId > 0 then
			self.lastServerWeatherId = serverId
		end
	end

	self.clientWeatherOverride = weatherId

	appFacade.pipelineManager:TrySetWeatherProfile(cfg.weatherPrefab)
end

function WeatherSystem:resetClientWeather()
	if self.clientWeatherOverride == nil then
		return
	end

	self.clientWeatherOverride = nil

	local blockId = pg.game.map and pg.game.map:getCurBlockAreaId() or 0
	local serverId = pg.me and pg.me:getWeatherByAreaId(blockId) or nil
	local restoreId = self.sunWeatherId

	if serverId ~= nil and serverId > 0 then
		restoreId = serverId
	end

	local cfg = WeatherData[restoreId]

	if cfg ~= nil then
		appFacade.pipelineManager:TrySetWeatherProfile(cfg.weatherPrefab)
	end

	self.lastServerWeatherId = nil
end

function WeatherSystem:onSceneUnloaded(sceneId, sceneName)
	if self.blockTimer then
		TimerManager.removeTimer(self.blockTimer)
	end

	if self.initTimer then
		TimerManager.removeTimer(self.initTimer)
	end
end

function WeatherSystem:setTodTime(key, enable, hour, min, timePeriod)
	self.todTimes[key] = {
		key = key,
		enable = enable,
		hour = hour,
		min = min,
		timePeriod = timePeriod,
		priority = Const.TOD_TIME_KEY_PRIORITY[key] or -1
	}

	local curTodTime = self:getCurTodTime()

	if curTodTime and pg.me and pg.me.space then
		local st, err = xpcall(function()
			self:changeTodTime(curTodTime.hour, curTodTime.min, curTodTime.timePeriod)
		end, debug.traceback)

		if not st and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s onRenderTimePeriodChange failed, %s", self:repr(), err)
		end
	end
end

function WeatherSystem:changeTodTime(hour, min, timePeriod)
	local sceneData = SceneData[pg.space.sceneId]

	if sceneData then
		local sceneName = sceneData.file
		local sceneType = ClientConst.TodScene[sceneName] or ClientConst.TodSceneSceneId[pg.space.sceneId]

		if sceneType == nil then
			timePeriod = -1
		end

		if sceneType == ClientConst.SetTime then
			appFacade.pipelineManager:OnChangeTime(hour, min, timePeriod, true)
		else
			appFacade.pipelineManager:OnChangeTime(hour, min, timePeriod, false)
		end
	end
end

function WeatherSystem:getCurTodTime()
	local res

	for _, todTime in pairs(self.todTimes) do
		if todTime.enable and (res == nil or todTime.priority > res.priority) then
			res = todTime
		end
	end

	return res
end

function WeatherSystem:backToHome()
	appFacade.pipelineManager:TrySetWeatherProfile(WeatherData[1].weatherPrefab)
end

function WeatherSystem:refreshTideState()
	local player = pg.me

	if player and player:isInTeam() then
		for id, info in pairs(player:getCurTeamInfo().membersInfo) do
			if info.entityId ~= player.id then
				local other = pg.getEntity(info.entityId)

				if Utils.isMainPlayer(other) then
					player = other

					break
				end
			end
		end
	end

	if not player then
		return
	end

	local tideState = Utils.getTideStateId(player)

	if not pg.space or pg.space.sceneId ~= 3003 then
		return
	end

	if tideState == Const.TIDE_STATES.HIGH_TIDE then
		CS.FunPlus.WorldX.GameApp.Sandbox.SandboxUtils.SetOceanHeight(true, 3)
	else
		CS.FunPlus.WorldX.GameApp.Sandbox.SandboxUtils.SetOceanHeight(false, 3)
	end
end

return WeatherSystem
