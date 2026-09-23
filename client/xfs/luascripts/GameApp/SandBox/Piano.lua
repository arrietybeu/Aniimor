-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Piano.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Piano = Class.LightClass("Piano", LevelItem)
local piano_music_data = require("Data.piano_music_data")
local piano_timbre_data = require("Data.piano_timbre_data")
local piano_selection_data = require("Data.piano_selection_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("MusicPianoStair", "Sandbox", LoggerConst.ERROR)
local MaxPianoKeys = 32

function Piano:ctor(sandbox, spawnInfo, syncInfo)
	Piano.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Piano:onSandboxReady()
	Piano.super.onSandboxReady(self)

	self.pianoStairSB = self.shell.gameObject:GetComponent("PianoStairSB")

	self:RPC_SC_TracksChange(1)
end

function Piano:intract()
	self:serverMsg("RPC_CS_Intract")
end

function Piano:RPC_SC_TracksChange(curTracks)
	logger:log2Tag("Piano", "RPC_SC_TracksChange", curTracks)

	local musicId = piano_selection_data[curTracks].pianoMusicId
	local timbreId = piano_selection_data[curTracks].pianoTimbreId
	local musicData = {}

	for key = 1, MaxPianoKeys do
		local noteId = piano_music_data[musicId]["pmKey" .. key]
		local soundName = piano_timbre_data[timbreId][noteId].pianoNoteRes

		musicData[key] = soundName
	end

	if self.pianoStairSB then
		self.pianoStairSB:RefreshSound(musicData)
	end
end

function Piano:destroy()
	Piano.super.destroy(self)
end

return Piano
