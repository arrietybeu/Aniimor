-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SoundGame.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local UIConst = require("Const.UIConst")
local SandboxConst = require("Common.Const.SandboxConst")
local SoundGame = Class.LightClass("SoundGame", LevelItem)
local SandboxStateDef = require("Common.Const.SandboxStateDef")

function SoundGame:ctor(sandbox, spawnInfo, syncInfo)
	SoundGame.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function SoundGame:onSandboxReady()
	SoundGame.super.onSandboxReady(self)
end

function SoundGame:play(csSoundGame)
	self.csSoundGame = csSoundGame

	local majorConfig = self:getMajorConfig()

	if not majorConfig or not majorConfig.resId then
		self.logger:error("SoundGame:play() - majorConfig or resId is nil")

		return
	end

	pg.global.ui:open(UIConst.UI_ID_GAME_COUNT_TIME, {
		callback = function()
			pg.global.ui:open(UIConst.UI_ID_SOUND_GAME, {
				soundGame = self
			}, function()
				pg.global.ui:close(UIConst.UI_ID_GAME_COUNT_TIME)
			end)

			self.cutScene = pg.game.cutscene:playCutscene(majorConfig.resId, majorConfig.resId, self:getPosition(), self:getRotation(), nil, nil, {
				createCallback = function(cmd)
					csSoundGame:StartGame(cmd.cutscene)
				end,
				endCallback = function(cmd)
					csSoundGame:EndGame()
					pg.global.ui:close(UIConst.UI_ID_SOUND_GAME)
				end
			})
		end
	})
end

function SoundGame:stop()
	if NotNil(self.csSoundGame) then
		self.csSoundGame:Interrupt()
	end

	if self.cutScene then
		self.cutScene:destroy()

		self.cutScene = nil
	end
end

function SoundGame:hit()
	if NotNil(self.csSoundGame) then
		local result = self.csSoundGame:Hit()

		if result then
			pg.global.ui.soundGame:perfect()
		else
			pg.global.ui.soundGame:miss()
		end
	end
end

function SoundGame:destroy()
	self:stop()

	self.csSoundGame = nil

	pg.global.ui:close(UIConst.UI_ID_SOUND_GAME)
	SoundGame.super.destroy(self)
end

return SoundGame
