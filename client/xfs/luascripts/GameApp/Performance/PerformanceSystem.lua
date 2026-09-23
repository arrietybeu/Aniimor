-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Performance\\PerformanceSystem.lua

local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local PerformanceSystem = Class.LightClass("PerformanceSystem", SystemBase)
local ToBool = ToBool
local CONST_COUNT = 5

function PerformanceSystem:onCtor()
	self.fps = 0
	self.pingPlayer = 0
	self.pingService = 0
	self.count = 0
	self.totalTime = 0
end

function PerformanceSystem:onTick()
	local hud = pg.global.ui.hudV2

	if hud and hud:getStatisticsVisible() and hud.view then
		self.count = self.count + 1
		self.totalTime = self.totalTime + Time.unscaledDeltaTime

		if self.count >= CONST_COUNT then
			self.fps = self.count * pg.game.setting:getLuaTickFrameInterval() / self.totalTime
			self.pingPlayer, self.pingService = ClientUtils.getTTLs()
			self.pingPlayer = self.pingPlayer / 1000000
			self.pingService = self.pingService / 1000000
			self.count = 0
			self.totalTime = 0

			local frameMultiplier = 1
			local setting = pg.game.setting

			if setting then
				frameMultiplier = setting:getFrameGenerationMultiplier()
			end

			local fps = self.fps * frameMultiplier
			local ping = self.pingPlayer

			if hud.refreshStatisticsInfoEx then
				hud:refreshStatisticsInfoEx(string.format("Fps: %.1f\nPing: %.0f", fps, ping))
			end
		end
	end
end

return PerformanceSystem
