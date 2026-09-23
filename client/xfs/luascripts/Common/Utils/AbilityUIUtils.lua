-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AbilityUIUtils.lua

local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AvatarData = require("Data.avatar_data")
local pg = pg
local ToBool = ToBool
local AbilityUIUtils = {}

function AbilityUIUtils.handleNormalAttackActionPerformed(uiComp)
	local player = pg.me

	if player == nil then
		return
	end

	if not pg.game.input.lockCursor and not pg.game.input:isUsingGamepad() and not pg.global.ui:runPlatformByMobile() then
		return
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.NormalAttack) then
		return
	end

	if pg.game.controller:isInControlMainPlayer() and player:checkPetUseGoSkill() then
		AbilityUIUtils.useGoSkill()

		return
	end

	if player:isControllingPet() and pg.pawn:BURROW_ST() and not pg.pawn:SKILL_ST() then
		pg.pawn:stopBurrow()

		return
	end

	if Utils.isSupportPet(pg.pawn) then
		player:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

		return
	end

	local abilityId = AbilityUtils:getNormalAttackAbilityId()

	if ToBool(abilityId) then
		if pg.game.controller:isInControlMainPlayer() and player.isUsePetSkillMode then
			AbilityUIUtils.useGoSkill()

			return
		end

		pg.game.controller:useSkill(abilityId, AbilityConst.WEAPON_NORMAL_ATK_ABILITY)
	end

	AbilityUIUtils.cancelNormalAttackLongPressCallback(uiComp)

	uiComp.normalAttackLongPressTimer = uiComp:startTimer(function()
		AbilityUIUtils.onNormalAttackLongPress()
	end, 0)
end

function AbilityUIUtils.handleNormalAttackActionCanceled(uiComp)
	if pg.pawn and pg.pawn.combatTimelineRef.cnt > 0 then
		pg.pawn:stopChargeByAbilityId(pg.pawn.combatTimelineRef.abilityId)
	end

	AbilityUIUtils.cancelNormalAttackLongPressCallback(uiComp)

	pg.game.controller.nextSkillAction.holdSkillId = 0
end

function AbilityUIUtils.cancelNormalAttackLongPressCallback(uiComp)
	if uiComp.normalAttackLongPressTimer then
		uiComp:killTimer(uiComp.normalAttackLongPressTimer)
	end

	uiComp.normalAttackLongPressTimer = nil
end

function AbilityUIUtils.onNormalAttackLongPress()
	if not pg.game.input.lockCursor and not pg.game.input:isUsingGamepad() then
		return
	end

	if next(pg.game.controller.autoCastController.autoCastInfo) then
		return
	end

	local abilityId = AbilityUtils:getNormalAttackAbilityId()

	if ToBool(abilityId) then
		pg.game.controller.nextSkillAction.holdSkillId = abilityId
	end
end

function AbilityUIUtils.useGoSkill()
	local player = pg.me

	if not player then
		return
	end

	local avatarData = AvatarData[player.templateId]

	if avatarData then
		local skillId = avatarData.GoAbilityId

		pg.game.controller:useSkill(skillId)
	end
end

return AbilityUIUtils
