-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetsEducationComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientPetsEducationComponent = class.Component("ClientPetsEducationComponent")

function ClientPetsEducationComponent:RPC_SC_OnUnequipCoreCarry(petId, oldInvId, oldItemGenId)
	self.logger:debug("RPC_SC_OnUnequipCoreCarry petId=%s, oldInvId=%d, oldItemGenId=%d", petId, oldInvId, oldItemGenId)
	facade:sendMsgToUI(MessageName.CARRY_UNLOAD, {
		petId = petId,
		invId = oldInvId,
		genID = oldItemGenId
	})
end

function ClientPetsEducationComponent:RPC_SC_OnEquipCoreCarry(petId, newInvId, newItemGenId)
	self.logger:debug("RPC_SC_OnEquipCoreCarry petId=%s, newInvId=%d, newItemGenId=%d", petId, newInvId, newItemGenId)
	facade:sendMsgToUI(MessageName.CARRY_EQUIP, {
		petId = petId
	})
end

function ClientPetsEducationComponent:RPC_SC_OnAssistCarryChange(petId)
	facade:sendMsgToUI(MessageName.CARRY_ASSIST_CHANGE, {
		petId = petId
	})
end

function ClientPetsEducationComponent:RPC_SC_OnUpgradeCoreCarry(invId, itemGenId, totalAddExp)
	local item = ItemUtils.getItem(self, invId, itemGenId)
	local corryCarryInfo = ItemUtils.getPropertyWithType(item)
	local newLevel, newExp = corryCarryInfo:getLevelAndExp()

	self.logger:debug("RPC_SC_OnUpgradeCoreCarry invId=%d, itemGenId=%d, totalAddExp=%d, newLevel=%d, newExp=%d, petId=%s", invId, itemGenId, totalAddExp, newLevel, newExp, corryCarryInfo.ownerPetId)
	facade:sendMsgToUI(MessageName.CARRY_UPGRADE)

	local parseCarryInfo = pg.game.petManage:parseCarryFullInfoWithId(invId, itemGenId)

	pg.game.petManage:setCoreCarryStrengthRecored(invId, itemGenId, parseCarryInfo)
end

function ClientPetsEducationComponent:clientAddAssistCarry(coreCarryInvId, coreCarryGenId, pos, assistCarryInvId, assistCarryGenId)
	self:serverMsg("RPC_CS_AddAssistCarry", coreCarryInvId, coreCarryGenId, pos, assistCarryInvId, assistCarryGenId)
end

function ClientPetsEducationComponent:RPC_CS_RemoveAssistCarry(coreCarryInvId, coreCarryGenId, pos)
	return
end

function ClientPetsEducationComponent:RPC_CS_ComposeAssistCarry(consumeList)
	return
end

return ClientPetsEducationComponent
