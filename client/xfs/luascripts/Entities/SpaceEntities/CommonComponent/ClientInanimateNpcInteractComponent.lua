-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientInanimateNpcInteractComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local NpcFuncData = require("Data.npc_func_data")
local NpcFuncConfigData = require("Data.npc_func_config_data")
local InteractData = require("Data.interact_data")
local logger = LoggerManager.getLogger("ClientInanimateNpcInteractComponent")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local InteractionConst = require("Common.Const.InteractionConst")
local EventConst = require("Const.EventConst")
local ItemConst = require("Common.Const.ItemConst")
local RobEggConst = require("Common.Const.RobEggConst")
local ClientFKeyInteractBase = require("Entities.SpaceEntities.CommonComponent.ClientFKeyInteractBase")
local ClientInanimateNpcInteractComponent = Class.Component("ClientInanimateNpcInteractComponent", ClientFKeyInteractBase)
local INTERACT_EXECUTE = {
	[ItemConst.ROB_EGG_INTERACT_TYPE.SNATCH] = {
		check = "checkCanSnatchEgg"
	},
	[ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_TRANSFER] = {
		doInteract = "startTransferEgg",
		check = "TransferEgg"
	},
	[ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_EXIT] = {
		doInteract = "EggShipExit",
		check = "EggShipExit"
	},
	[ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_FORCE_EXIT] = {
		doInteract = "EggShipForceExit",
		check = "EggShipForceExit"
	},
	[ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_ENTER_CORE] = {
		check = "EggShipEnterCore"
	},
	[ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_ENTER_OUTSKIRT] = {
		check = "EggShipEnterOutSkirt"
	},
	[ItemConst.ROB_EGG_INTERACT_TYPE.LIMIT_TIME_CHALLENGE] = {
		doInteract = "startRobEggLimitTimeChallenge"
	}
}

function ClientInanimateNpcInteractComponent:start()
	self.playerInTrigger = false

	self:refreshInteractTrigger()
end

function ClientInanimateNpcInteractComponent:useReentryGuard()
	return true
end

function ClientInanimateNpcInteractComponent:getInteractPriority()
	return InteractionConst.EntInteractPriority.StaticNpc
end

function ClientInanimateNpcInteractComponent:checkShowInteract(interactId)
	local cData = INTERACT_EXECUTE[interactId]

	if cData == nil or cData.check == nil then
		return true
	end

	local func = self["check_" .. cData.check]

	if func then
		return func(self)
	end

	return true
end

function ClientInanimateNpcInteractComponent:setupRobEggInteractShowState(interact, interactId)
	if not self.isEggShip then
		return
	end

	if interactId ~= ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_TRANSFER then
		return
	end

	local isControllingEgg = pg.me and pg.me.isControllingEgg and pg.me:isControllingEgg()
	local pawnIsEgg = pg.pawn and pg.pawn.isRobSpaceEgg
	local hasTransferEgg = isControllingEgg or pawnIsEgg or pg.me and pg.me:grabEgg_checkHasCarryEgg() or false
	local textColor = hasTransferEgg and RobEggConst.EGG_SHIP_TRANSFER_HAS_EGG_TEXT_COLOR or RobEggConst.EGG_SHIP_TRANSFER_NO_EGG_TEXT_COLOR

	interact.textColor = textColor
end

function ClientInanimateNpcInteractComponent:leaveCurrentInteractUI()
	if not self.interactData then
		return
	end

	if #self.interactData > 1 then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self.interactData)
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.interactData[1])
	end

	self.interactData = nil
end

function ClientInanimateNpcInteractComponent:refreshInteractUI()
	if not self.playerInTrigger then
		return
	end

	if not self:checkCanInteract() then
		self:leaveCurrentInteractUI()

		return
	end

	self:leaveCurrentInteractUI()

	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds

	self.interactData = {}

	for _, interactId in ipairs(actionPrototypeIds) do
		if self:checkShowInteract(interactId) then
			local cData = InteractData[interactId]
			local interact = {
				globalId = self:getGlobalId(),
				interactionType = cData and cData.type or InteractionConst.INTERACTION_TYPE_NPC_INTERACTION,
				actionPrototypeId = interactId
			}

			self:setupRobEggInteractShowState(interact, interactId)
			table.insert(self.interactData, interact)
		end
	end

	if #self.interactData > 1 then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self.interactData)
	else
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self.interactData[1])
	end
end

function ClientInanimateNpcInteractComponent:onEnterInteractTrigger()
	if not self:checkCanInteract() then
		return
	end

	self.playerInTrigger = true

	self:refreshInteractUI()
end

function ClientInanimateNpcInteractComponent:onLeaveInteractTrigger()
	self.playerInTrigger = false

	self:leaveCurrentInteractUI()
end

function ClientInanimateNpcInteractComponent:checkCanInteract()
	if self.checkShowEntityInteract then
		return self:checkShowEntityInteract()
	end

	return true
end

function ClientInanimateNpcInteractComponent:interact(interactUnit)
	local interactId = interactUnit.actionPrototypeId
	local cData = INTERACT_EXECUTE[interactId]

	if self.checkCanActualInteract and not self:checkCanActualInteract(interactId) then
		return
	end

	if cData == nil or cData.doInteract == nil then
		pg.me:startInteract(Const.IACT_TP_NPC, self.id, interactUnit.actionPrototypeId, {}, nil)
	else
		local func = self["interact_" .. cData.doInteract]

		if func then
			func(self, interactUnit)
		end
	end
end

function ClientInanimateNpcInteractComponent:onInteractResult(fromEnt, actionPrototypeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("ClientInanimateNpcInteractComponent:onInteractResult")
	end

	if self.staticId and self.staticId ~= 0 and fromEnt.authority == Const.AUTHORITY_MASTER then
		local eventData = {
			fromEnt = fromEnt,
			actionPrototypeId = actionPrototypeId
		}

		facade:sendLuaEvent(self.staticId .. ClientConst.LuaEventPostFix.EntityInteract, eventData)
	end
end

function ClientInanimateNpcInteractComponent:getNpcActionPrototypeIds()
	local configData = self:getConfigData()

	return configData.actionPrototypeIds
end

function ClientInanimateNpcInteractComponent:checkNpcInteractState()
	return true
end

function ClientInanimateNpcInteractComponent:getInteractiveDist()
	local cData = self:getConfigData()

	return cData.interactiveDist or 2
end

function ClientInanimateNpcInteractComponent:check_TransferEgg()
	if self.isEggShip then
		return pg.me:grabEgg_checkCanTransferEgg(self.ownerUid, self.isEggShip)
	else
		return pg.me:grabEgg_checkCanTransferEgg(self.staticId, false)
	end
end

function ClientInanimateNpcInteractComponent:interact_startTransferEgg(interactUnit)
	if pg.me:grabEgg_checkHasCarryEgg() then
		pg.me:startInteract(Const.IACT_TP_NPC, self.id, interactUnit.actionPrototypeId, {}, nil)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_NO_AYN_EGG"), 2)
	end
end

function ClientInanimateNpcInteractComponent:interact_startRobEggLimitTimeChallenge(interactUnit)
	local targetId = self.id
	local actionPrototypeId = interactUnit.actionPrototypeId

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("SECONDARY_CONFIRMATION_FOR_LIMITED_TIME_CHALLENGE"), function()
		if pg.me then
			pg.me:startInteract(Const.IACT_TP_NPC, targetId, actionPrototypeId, {}, nil)
		end
	end)
end

function ClientInanimateNpcInteractComponent:check_checkCanSnatchEgg()
	return pg.me:grabEgg_checkCanSnatchEgg(self.staticId)
end

function ClientInanimateNpcInteractComponent:check_EggShipExit()
	if pg.me:isControllingEgg() then
		return false
	end

	return true
end

function ClientInanimateNpcInteractComponent:interact_EggShipExit()
	if not self.finishEggTask then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("GRAB_EGG_UNFINISHED_EXIT"), nil, true)
	else
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("GRAB_EGG_EXIT"), function()
			self:retreat(false)
		end)
	end
end

function ClientInanimateNpcInteractComponent:check_EggShipForceExit()
	return false
end

function ClientInanimateNpcInteractComponent:interact_EggShipForceExit()
	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("GRAB_EGG_EXIT_FORCE"), function()
		self:retreat(true)
	end)
end

function ClientInanimateNpcInteractComponent:check_EggShipEnterCore()
	if pg.space:isSingleMode() then
		return false
	end

	if pg.me:isControllingEgg() then
		return false
	end

	return pg.space:checkIsPVPStage() and not self.inPvp
end

function ClientInanimateNpcInteractComponent:check_EggShipEnterOutSkirt()
	if pg.space:isSingleMode() then
		return false
	end

	if pg.me:isControllingEgg() then
		return false
	end

	return pg.space:checkIsPVPStage() and self.inPvp
end

return ClientInanimateNpcInteractComponent
