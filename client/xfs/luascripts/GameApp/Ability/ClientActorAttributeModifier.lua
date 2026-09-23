-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ClientActorAttributeModifier.lua

local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local ActorAttributeModifier = require("Common.Ability.Attribute.ActorAttributeModifier")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientActorAttributeModifier = Class.LiteClass("ClientActorAttributeModifier", ActorAttributeModifier)

ClientActorAttributeModifier.ClientPreModifyAttributes = {
	[AttributeConst.reduce_cur_tp_rate] = true,
	[AttributeConst.tp_cur] = true,
	[AttributeConst.tp_max_v] = true,
	[AttributeConst.tp_temp_cur] = true,
	[AttributeConst.tp_temp_max] = true,
	[AttributeConst.stamina_cur] = true,
	[AttributeConst.add_cur_stamina_v] = true,
	[AttributeConst.add_cur_stamina_max_p] = true,
	[AttributeConst.water_cur] = true
}

function ClientActorAttributeModifier:modifyAttrib(actorCombatAttribute, attributeId, value, customData)
	local entity = actorCombatAttribute.actorInterface:getEntity()

	if not Utils.isVirtualEntity(entity) then
		if entity.authority ~= Const.AUTHORITY_MASTER then
			return false
		end

		if not ClientActorAttributeModifier.ClientPreModifyAttributes[attributeId] then
			return false
		end
	end

	ActorAttributeModifier.modifyAttrib(self, actorCombatAttribute, attributeId, value, customData)
end

function ClientActorAttributeModifier.processAddCurStaminaV(actorCombatAttribute, attributeId, value, customData)
	actorCombatAttribute:changeStamina(value)
end

function ClientActorAttributeModifier.processAddCurStaminaMaxP(actorCombatAttribute, attributeId, value, customData)
	local currentMax = actorCombatAttribute:getMaxStamina()
	local addStamina = value * currentMax

	actorCombatAttribute:changeStamina(addStamina)
end

return ClientActorAttributeModifier
