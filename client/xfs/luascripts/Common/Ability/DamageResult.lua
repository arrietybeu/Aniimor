-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\DamageResult.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local DamageResult = Class.LiteClass("DamageResult")

function DamageResult.build(combatCasterInfo, ability, damage, elementType, targetActorId, hitPos, hitDir, attackData, shieldAbsorbValue)
	local self = DamageResult.new()

	self.attackActorInfo = combatCasterInfo
	self.attackerAbilityId = ability and ability.abilityId or 0
	self.hurtType = AbilityConst.HURT_TYPE_HP_REDUCE
	self.attackResult = AbilityConst.ATTACK_RESULT_NORMAL
	self.srcType = AbilityConst.SRC_TYPE_NONE
	self.damageValue = damage
	self.shieldAbsorbValue = shieldAbsorbValue
	self.elementType = elementType
	self.targetActorId = targetActorId
	self.targetHitPos = hitPos
	self.targetHitDir = hitDir
	self.attackData = attackData
	self.hitIdx = 0
	self.damageShowEnum = Const.DAMAGE_SHOW_ENUM_NORMAL

	return self
end

function DamageResult:ctor()
	return
end

return DamageResult
