-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\PetInputProcessor.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Const.Const")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local PetInputProcessor = Class.LightClass("PetInputProcessor", BaseInputProcessor)

local function isInGrabEggSpace()
	return pg.space and pg.space.isGrabEgg and pg.space:isGrabEgg()
end

function PetInputProcessor:onInit()
	BaseInputProcessor.onInit(self)

	self.actionMapKey = HotkeyConst.INPUT_MAP_ACTION_KEY.Pet
end

function PetInputProcessor:handleChangeModeAction(inputInfo)
	return
end

function PetInputProcessor:handleSwitchTeamNegativeAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if isInGrabEggSpace() then
			return
		end

		local player = pg.me

		if player then
			player:serverMsg("RPC_CS_SelectPrepareFormation", math.max(1, player.curPetFormationIndex - 1))
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PetInputProcessor:handleSwitchTeamPositiveAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if isInGrabEggSpace() then
			return
		end

		local player = pg.me

		if player then
			player:serverMsg("RPC_CS_SelectPrepareFormation", math.min(Const.MAX_FORMATION_COUNT, player.curPetFormationIndex + 1))
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

return PetInputProcessor
