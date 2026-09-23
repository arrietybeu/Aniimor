-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientBeCarryComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local InteractionConst = require("Common.Const.InteractionConst")
local HoldEntPanelConfig = require("Data.hold_ent_panel_config_data")
local Utils = require("Common.Utils.Utils")
local SceneData = require("Data.scene_data")
local OpDef = require("Common.OpDef")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local Class = require("Core.Framework.Class")
local ConflictTypes = require("Common.ConflictTypes")
local HoldEntData = require("Data.hold_ent_data")
local HoldItemData = require("Data.hold_item_data")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")
local ClientBeCarryComponent = Class.Component("ClientBeCarryComponent")

function ClientBeCarryComponent:getCarryInteractionListData()
	if self.isCarryItem then
		return
	end

	local cfgData = self:getConfigData()
	local forceAllowHug = cfgData and cfgData.forceAllowHug

	if not forceAllowHug then
		if not SceneData[pg.space.sceneId].canHugPet then
			return
		end

		local masterEnt = self.getMasterEntity and self:getMasterEntity()

		if masterEnt == nil then
			if self.ownerUid ~= pg.me.uid then
				return
			end
		elseif masterEnt ~= pg.me then
			return
		end
	end

	local dist = self:getBeHoldDistance()

	return {
		actionPrototypeId = HoldEntPanelConfig.petHugInteractionId,
		interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
		globalId = self:getGlobalId(),
		interactFunc = function(interactUnit)
			self:beHold(interactUnit)
		end,
		overrideInteractDis = dist,
		canInteractiveFunc = function()
			if not self:checkCanBeCarry() then
				return false
			end

			return pg.me:checkStatus(ConflictTypes.CT_START_HUG_ENT, false, nil, true)
		end
	}
end

function ClientBeCarryComponent:checkCanBeCarry()
	if pg.space:isHomeland() then
		local petInfo = pg.space.pets[self.id]

		if petInfo and not Utils.checkHomePetStateValid(petInfo, pg.space) then
			return false
		end
	end

	return true
end

function ClientBeCarryComponent:getBeHoldDistance()
	if pg.space:isHomeland() then
		local combatPet = pg.me and pg.me.curCombatPetId

		if self.id ~= combatPet then
			return self.eModel and self.eModel.radius or 0.3
		end
	end

	local radius = self.eModel and self.eModel.radius or 0.3

	if radius <= 0 then
		radius = 0.3
	end

	local player = pg.me
	local space = pg.space
	local dist

	if space and space:isHomeland() then
		dist = radius + HoldEntPanelConfig.petHugHomeDistanceExtra
	else
		dist = radius + HoldEntPanelConfig.petHugDistanceExtra
	end

	local playerRadius = player and player.eModel and player.eModel.radius

	if playerRadius <= 0 then
		playerRadius = 0.3
	end

	dist = dist + playerRadius

	return dist
end

function ClientBeCarryComponent:beHold(interactUnit)
	local player = pg.me

	player:tryCarryEnt(self.id, OpDef.OP.CS_PC_PetTakeUp, Const.CARRY_REQ_FROM_INTERACTION, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS and pg.global and pg.global.eventEmitter then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_HUG_PET, {
				count = 1
			})
		end
	end)
end

function ClientBeCarryComponent:getHoldConfigDatas()
	local templateId = self.petInfo and self.petInfo.templateId or self.templateId
	local holdCfg

	if self.isCarryItem == true then
		holdCfg = HoldItemData[templateId]

		if Utils.tableIsEmptyOrNil(holdCfg) or Utils.tableIsEmptyOrNil(holdCfg.itemParameter) then
			holdCfg = HoldEntPanelConfig.petHugDefaultParameter
		else
			holdCfg = holdCfg.itemParameter
		end
	else
		holdCfg = HoldEntData[templateId]

		if Utils.tableIsEmptyOrNil(holdCfg) or Utils.tableIsEmptyOrNil(holdCfg.petParameter) then
			holdCfg = HoldEntPanelConfig.petHugDefaultParameter
		else
			holdCfg = holdCfg.petParameter
		end
	end

	local ikOffset = Vector3.New(holdCfg[8], holdCfg[9], holdCfg[10])
	local offset = Vector3.New(holdCfg[1], holdCfg[2], holdCfg[3])
	local euler = Vector3.New(holdCfg[4], holdCfg[5], holdCfg[6])
	local ani = holdCfg[7]
	local effectOn = holdCfg[11] == 1

	return ikOffset, offset, euler, ani, effectOn
end

function ClientBeCarryComponent:onMoveUserChanged(oldVal, newVal)
	if self.subject and self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_ENT_BE_CARRIED_STATE_CHANGE) then
		local isEnter = string.isNilOrEmpty(oldVal)

		if isEnter then
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ENT_BE_CARRIED_STATE_CHANGE, true)
		else
			local isExit = string.isNilOrEmpty(newVal)

			if isExit then
				self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ENT_BE_CARRIED_STATE_CHANGE, false)
			end
		end
	end

	if self.updateStateCache then
		self:updateStateCache("BE_HUG_ENT_ST")
	end
end

return ClientBeCarryComponent
