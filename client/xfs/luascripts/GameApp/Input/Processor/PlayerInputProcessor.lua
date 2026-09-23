-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\PlayerInputProcessor.lua

local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local CommonAbilityHelper = require("GameApp.Ability.CommonAbilityHelper")
local PlayerInputProcessor = Class.LightClass("PlayerInputProcessor", BaseInputProcessor)
local IsLongPressActiveForKey = CS.XGUI.Navigation.GamepadHotkey.IsLongPressActiveForKey
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Time = require("Core.Common.Time")

function PlayerInputProcessor:onInit()
	BaseInputProcessor.onInit(self)

	self.actionMapKey = HotkeyConst.INPUT_MAP_ACTION_KEY.Player
end

function PlayerInputProcessor:onBlockByUI(isBlock)
	if isBlock then
		pg.global.inputMgr:SetMoveAxis(0, 0, 0)
	end
end

function PlayerInputProcessor:handleJumpAction(inputInfo)
	if pg.game.input:isUsingGamepad() and pg.game.interaction.canClimbHere then
		return true
	end

	local characterState = pg.pawn and pg.pawn.characterState
	local isFly = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING)

	if inputInfo.phase == "Performed" then
		if isFly then
			pg.pawn:beginStraightUp()

			return
		end

		if pg.game.controller ~= nil then
			pg.game.controller:onHandleJump(true)
		end
	elseif inputInfo.phase == "Canceled" then
		if isFly then
			pg.pawn:endStraightUp()
		end

		if pg.game.controller ~= nil then
			pg.game.controller:onHandleJump(false)
		end
	end
end

function PlayerInputProcessor:handleClimbJumpAction(inputInfo)
	if pg.game.controller ~= nil then
		if not pg.game.controller:checkInClimbState() then
			return true
		end

		if inputInfo.phase == "Performed" then
			pg.game.controller:onHandleClimbJump(true)
		end

		return false
	end

	return true
end

function PlayerInputProcessor:handleClimbJump2Action(inputInfo)
	if pg.game.controller ~= nil then
		if not pg.game.controller:checkInClimbState() then
			return true
		end

		if inputInfo.phase == "Performed" then
			pg.game.controller:onHandleClimbJump(false)
		end

		return false
	end

	return true
end

function PlayerInputProcessor:handleFastClimbAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.game.controller ~= nil then
			pg.game.controller:onHandleFastClimb(true)
		end
	elseif inputInfo.phase == "Canceled" and pg.game.controller ~= nil then
		pg.game.controller:onHandleFastClimb(false)
	end
end

function PlayerInputProcessor:handleStartSprintAction(inputInfo)
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Dash) then
		return
	end

	local actionPath = inputInfo.actionMapName .. "/" .. inputInfo.actionName

	if inputInfo.phase == "Performed" then
		if IsLongPressActiveForKey(actionPath) then
			self._dashPressStartTime = Time.realtimeSinceStartup

			return
		end

		self._dashPressStartTime = nil

		if pg.game.controller ~= nil then
			pg.game.controller:onHandleDash(true)
		end
	elseif inputInfo.phase == "Canceled" then
		if self._dashPressStartTime ~= nil then
			local pressDuration = Time.realtimeSinceStartup - self._dashPressStartTime

			self._dashPressStartTime = nil

			if pressDuration <= HotkeyConst.SHORT_PRESS_MAX_DURATION and pg.game.controller ~= nil then
				pg.game.controller:onHandleDash(true)
				pg.game.controller:onHandleDash(false)
			end

			return
		end

		if pg.game.controller ~= nil then
			pg.game.controller:onHandleDash(false)
		end
	end
end

function PlayerInputProcessor:handleChangeMeleeWeaponAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.game.controller ~= nil then
			pg.game.controller:onHandleChangeMeleeWeapon(true)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PlayerInputProcessor:handleCrouchAction(inputInfo)
	return true
end

function PlayerInputProcessor:handleStartFlyAction(inputInfo)
	if inputInfo.phase == "Performed" then
		local me = pg.me

		if me ~= nil then
			me:startFly()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PlayerInputProcessor:handleCommandPetUseQSkillOnEnvObjAction(inputInfo)
	if inputInfo.phase == "Performed" then
		local me = pg.me

		if me ~= nil then
			me:commandPetUseQSkillOnEnvObj()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PlayerInputProcessor:handleSwitchPetCommandModeAction(inputInfo)
	if inputInfo.phase == "Performed" then
		local me = pg.me

		if me ~= nil then
			me:switchPetCommandMode()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

return PlayerInputProcessor
