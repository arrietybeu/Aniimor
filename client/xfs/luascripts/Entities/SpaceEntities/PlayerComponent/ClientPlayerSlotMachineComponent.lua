-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerSlotMachineComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientPlayerSlotMachineComponent = class.Component("ClientPlayerSlotMachineComponent")

function ClientPlayerSlotMachineComponent:ctor()
	return
end

function ClientPlayerSlotMachineComponent:init(avtDict)
	return true
end

function ClientPlayerSlotMachineComponent:destroy()
	return
end

function ClientPlayerSlotMachineComponent:startSlotMachine(slotMachineId, cb)
	self:serverMsg("RPC_CS_StartSlotMachine", slotMachineId, cb)
end

function ClientPlayerSlotMachineComponent:requestSlotReward(slotMachineId)
	self:serverMsg("RPC_CS_SlotMachineReward", slotMachineId)
end

return ClientPlayerSlotMachineComponent
