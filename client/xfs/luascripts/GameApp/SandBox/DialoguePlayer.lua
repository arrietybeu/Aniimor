-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\DialoguePlayer.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local DialoguePlayer = Class.LightClass("DialoguePlayer", LevelItem)
local SandboxStateDef = require("Common.Const.SandboxStateDef")

function DialoguePlayer:ctor(sandbox, spawnInfo, syncInfo)
	DialoguePlayer.super.ctor(self, sandbox, spawnInfo, syncInfo)

	syncInfo.ret = syncInfo.ret or 0
end

function DialoguePlayer:onInit()
	self:onLevelItemValueChange("state", SandboxStateDef.DialoguePlayer.IDLE, self.syncInfo.state)
end

function DialoguePlayer:onLevelItemValueChange(key, oldValue, value)
	if key == "state" then
		if oldValue == value then
			return
		end

		if value == SandboxStateDef.DialoguePlayer.PLAYING then
			self:play()
		else
			self:stop()
		end
	end
end

function DialoguePlayer:play()
	local majorConfig = self:getMajorConfig()

	if not majorConfig or not majorConfig.dialogueGraphId then
		self.logger:error("DialoguePlayer:play() - majorConfig or dialogueGraphId is nil")

		return
	end

	local dialogueSystem = pg.game.dialogue

	if not dialogueSystem:isDialogueGraphIdValid(majorConfig.dialogueGraphId) then
		return
	end

	local extraData = {}

	function extraData.customCallback(ret)
		local comp = self.shell.gameObject:GetComponent("DialoguePlayer")

		comp:OnCustomCallback(ret)
	end

	self.playTimes = (self.playTimes or 0) + 1

	local playTimes = self.playTimes

	pg.game.dialogue:playDialogueGraph(majorConfig.dialogueGraphId, function(ret, id)
		if self.playTimes ~= playTimes then
			return
		end

		self:serverMsg("RPC_CS_Finished", ret)
	end, majorConfig.graphParam, majorConfig.graphContextParam, extraData)
end

function DialoguePlayer:stop()
	local majorConfig = self:getMajorConfig()

	if not majorConfig or not majorConfig.dialogueGraphId then
		self.logger:error("DialoguePlayer:play() - majorConfig or dialogueGraphId is nil")

		return
	end

	self.playTimes = (self.playTimes or 0) + 1

	pg.game.dialogue:stopDialogueGraph(majorConfig.dialogueGraphId)
end

function DialoguePlayer:replayOnReconnect()
	return
end

function DialoguePlayer:destroy()
	self:stop()
	DialoguePlayer.super.destroy(self)
end

return DialoguePlayer
