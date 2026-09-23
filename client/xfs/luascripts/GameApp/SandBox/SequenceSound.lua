-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SequenceSound.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local AudioConst = require("Const.AudioConst")
local SequenceSound = Class.LightClass("SequenceSound", LevelItem)

function SequenceSound:ctor(sandbox, spawnInfo, syncInfo)
	SequenceSound.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local defaultValue = self.spawnInfo.defaultValue or {}

	self.rowNum = defaultValue.rowNum or 0
end

function SequenceSound:destroy()
	pg.game.audio:unregisterAudioBgmEvent(self:getAudioEventKey())
	SequenceSound.super.destroy(self)
end

function SequenceSound:onSandboxReady()
	SequenceSound.super.onSandboxReady(self)

	self.sequenceSoundSB = self.shell.gameObject:GetComponent("SequenceSoundSB")

	self.sequenceSoundSB:SetStates(self.syncInfo.childStates)
	self.sequenceSoundSB:StartPlay()
	pg.game.audio:registerAudioBgmEvent(self:getAudioEventKey(), function(eventType, extraInfo)
		self:onBgmEvent(eventType, extraInfo)
	end)
end

function SequenceSound:getAudioEventKey()
	return "SequenceSound_" .. self.id
end

function SequenceSound:onValueChange(key, oldValue, value, isInit)
	SequenceSound.super.onValueChange(self, key, oldValue, value, isInit)

	if key == "childStates" and self.sequenceSoundSB then
		self.sequenceSoundSB:SetStates(self.syncInfo.childStates)
	end
end

function SequenceSound:onChildToggle(colIndex, rowIndex)
	local index = colIndex * self.rowNum + rowIndex

	self:serverMsg("RPC_CS_OnChildToggle", index)
end

function SequenceSound:onBgmEvent(eventType, extraInfo)
	if AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_MusicSyncBeat) and self.sequenceSoundSB then
		self.sequenceSoundSB:OnBgmSync()
	end
end

return SequenceSound
