-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientChainAttackComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local CombatContext = require("Common.Ability.CombatContext")
local ClientChainAttackComponent = Class.Component("ClientChainAttackComponent")

function ClientChainAttackComponent:ctor()
	return
end

function ClientChainAttackComponent:onChainAttackInfoTotalDamageChanged(ov, nv)
	if self.isMainPlayer then
		facade:SendMessageCommand(MessageName.CHAIN_DAMAGE_CHANGE, nv)
	end
end

function ClientChainAttackComponent:onChainAttackInfoInExtremeChanged(ov, nv)
	if self.isMainPlayer then
		facade:SendMessageCommand(MessageName.CHAIN_IN_EXTREME_CHANGE, nv)
	end
end

function ClientChainAttackComponent:tryTriggerPlayerTeamChainAttack()
	if not self:isInTeam() then
		return false
	end

	local teamInfo = self:getCurTeamMemberInfo()

	if not ToBool(teamInfo) or table.getCount(teamInfo) < self.chainAttackInfo:getLeastPlayerTeamChainCnt() then
		return false
	end

	if self.chainAttackInfo:isInPlayerTeamChain() then
		return false
	end

	if self.space and (Utils.isRobEggSceneId(self.space.sceneId) or Utils.isBossRushSceneId(self.space.sceneId)) then
		return false
	end

	local lockEntity = pg.getEntityByActorId(self.lockedActorId)

	if not lockEntity or not Utils.isPuppet(lockEntity) then
		return false
	end

	self:serverMsg("RPC_CS_StartPlayerTeamChainAttack")
end

function ClientChainAttackComponent:respondPlayerTeamChainChance()
	self:serverMsgNoGC("RPC_CS_RespondPlayerTeamChainChance", self.chainAttackInfo.curResponderId)
end

function ClientChainAttackComponent:RPC_SC_ShowBurstDamage(finalDamage)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("dxk RPC_SC_ShowBurstDamage", finalDamage)
	end

	pg.global.ui.chainAttack:showFinalResult(finalDamage)
end

function ClientChainAttackComponent:RPC_SC_NotifyPlayerTeamChainChance(uid)
	if not self.isMainPlayer then
		return
	end

	if self.chainAttackInfo.lastLockedActorId ~= self.lockedActorId then
		return
	end

	if not self:checkCanRespondChainChance() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_CHAIN_ATTACK_RESPOND, nil, function()
		pg.global.ui.chainAttackRespond:showChainAttackRespondBtn(true, uid)
	end)
end

function ClientChainAttackComponent:RPC_SC_NotifyTriggerExtremeChain(petList)
	pg.global.ui:open(UIConst.UI_ID_CHAIN_ATTACK, nil, function()
		pg.global.ui.chainAttack:triggerExtremeChainV2(petList)
	end)
end

return ClientChainAttackComponent
