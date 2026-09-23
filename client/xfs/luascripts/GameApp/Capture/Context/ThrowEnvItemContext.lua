-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\ThrowEnvItemContext.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local NoBallContext = require("GameApp.Capture.Context.NoBallContext")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local AddressDataConst = require("Const.AddressDataConst")
local PlayableEventConst = require("Const.PlayableEventConst")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local InputFsm = require("GameApp.Input.InputFsm")
local Const = require("Common.Const.Const")
local commands = CaptureFsm.commands
local states = CaptureFsm.states
local ThrowEnvItemContext = Class.LightClass("ThrowEnvItemContext", NoBallContext)

function ThrowEnvItemContext:ctor(player, envItem)
	self.player = player
	self.eventEmitter = self.player.eventEmitter
	self.envItem = envItem
	self.castItemId = Utils.getBindingCastObjectId(envItem:getConfigData().bindingId)
	self.ballData = castItemData[self.castItemId]
end

function ThrowEnvItemContext:enter(fromContext)
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.THROWHOLD)

	self.player.eModel.ThrowAnimType = self.ballData.animType
	self.player.eModel.AlwaysLookForward = true

	self:enableCatchMode(true, true)
	self:hold()

	if fromContext and fromContext.fsm then
		self.fsm = fromContext.fsm
	else
		self.fsm = InputFsm.new(CaptureFsm)
	end

	self.state = self.fsm.state

	if fromContext then
		self:process()
	end
end

function ThrowEnvItemContext:hold()
	self.player:addEModelComponent(CommonConst.COMPONENT_CATCH)
	self.player.eModel:LoadPointer(CommonConst.COMPONENT_CATCH, AddressDataConst.PARABOLA_POINTER, {
		envRadius = self.envItem.bodySize,
		throwEnvId = self.envItem.id,
		boneName = self.ballData.bone,
		speed = self.ballData.maxV,
		offset = Vector3(unpack(self.ballData.offset))
	})
	self.envItem:onPlayerHold(self.player, self.castItemId)
	self.player:serverMsg("RPC_CS_PlayerHoldEnv", self.envItem.id)
end

function ThrowEnvItemContext:throwEnd(breaked)
	self.player:switchContext()
end

function ThrowEnvItemContext:exit()
	self.fsm:addCommand(commands.EnterExit)

	if self.state == states.T then
		return false
	end

	self:process()

	return true
end

function ThrowEnvItemContext:throw()
	self.fsm:addCommand(commands.Throw)

	if self.state == states.T then
		return
	end

	self:process()
end

function ThrowEnvItemContext:switch()
	self.fsm:addCommand(commands.SwitchItem)

	if self.state == states.T then
		return
	end

	self:process()
end

function ThrowEnvItemContext:process()
	self.state = self.fsm:read()

	if self.state == states.T then
		self:doThrow()
	elseif self.state == states.E then
		self:exitCatchMode()
	elseif self.state == states.S then
		self:doSwitch()
	end
end

function ThrowEnvItemContext:doThrow()
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.THROWRELEASE)
	self:fireBall()
end

function ThrowEnvItemContext:doSwitch()
	return
end

function ThrowEnvItemContext:exitCatchMode()
	self.player:switchContext()
end

function ThrowEnvItemContext:fireBall()
	if not self.envItem then
		return
	end

	self.envItem:onPlayerFire(self.player, self.ballData)

	self.envItem = nil

	self.player.eModel:UnloadPointer(CommonConst.COMPONENT_CATCH)
end

function ThrowEnvItemContext:destroy()
	if self.envItem then
		self.envItem:onPlayerDrop(self.player, self.ballData)
		self.player:serverMsg("RPC_CS_PlayerUnHoldEnv", self.envItem.id)

		self.envItem = nil
	end

	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)

	self.player.eModel.AlwaysLookForward = false

	self.player.eModel:UnloadPointer(CommonConst.COMPONENT_CATCH)

	self.player = nil
	self.eventEmitter = nil
	self.envItem = nil
	self.castItemId = nil
	self.ballData = nil
end

return ThrowEnvItemContext
