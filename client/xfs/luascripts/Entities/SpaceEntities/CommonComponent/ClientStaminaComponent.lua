-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientStaminaComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local StaminaComponent = require("Common.Components.StaminaComponent")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local StaminaConfigData = require("Common.Data.stamina_config_data")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local PetData = require("Data.pet_data")
local MessageName = require("Const.MessageName")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local NoticeDef = require("Common.NoticeDef")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local AttrFixType = CS.FunPlus.WorldX.Animations.AttrFixType
local ClientStaminaComponent = class.Component("ClientStaminaComponent", StaminaComponent)

function ClientStaminaComponent:ctor()
	self.staminaLocked = false
	self.lockedStamina = nil
	self.restoringLockedStamina = false
	self.staminaTickData = {
		enterCost = 0,
		freelanceMode = false,
		usualFlyCostSpace = false,
		isPvpSpace = false,
		isFastCarryEgg = false,
		isRobEggSpace = false,
		notifyNotEnough = false,
		startCost = false,
		recovery = false,
		followRatio = 1,
		vertRate = 0,
		horiRate = 0,
		recoverStaminaLeftTime = StaminaConfigData.StaminaRegenCoolDown,
		stateTag = TagMask.None,
		staminaTag = TagMask.None
	}
	self.staminaQueryData = {
		recovery = false,
		vertRate = 0,
		inCombat = false,
		enterWithoutCost = false,
		rate = 1,
		cost = 0,
		horiRate = 0
	}
	self.StateTagNames = {
		[TagMask.Glide] = "Glide",
		[TagMask.Climb] = "Climb",
		[TagMask.Swim] = "Swim",
		[TagMask.Fly] = "Fly",
		[TagMask.Sneak] = "Sneak",
		[TagMask.SpeedBurst] = "SpeedBurst",
		[TagMask.SkillRoll] = "SkillRoll"
	}
	self.StaminaTagNames = {
		[TagMask.Dash] = "Dash",
		[TagMask.Sprint] = "Sprint",
		[TagMask.Fall] = "Fall",
		[TagMask.Jump] = "Jump",
		[TagMask.Movement] = "Move"
	}
	self.StaminaTagPriority = {
		[TagMask.Dash] = 4,
		[TagMask.Sprint] = 3,
		[TagMask.Fall] = 2,
		[TagMask.Jump] = 1,
		[TagMask.Movement] = 0
	}
end

function ClientStaminaComponent:start()
	self.actorCombatAttribute:registerAttributeNotify(AttributeConst.stamina_cur, self.onStaminaCurChange)
end

function ClientStaminaComponent:onEnterSpace()
	local space = self.space

	self.staminaTickData.isRobEggSpace = Utils.isRobEggSceneId(space.sceneId)
	self.staminaTickData.usualFlyCostSpace = self:csRequireSpaceData("isFlyLowStaminaCost") ~= 1
	self.staminaTickData.isPvpSpace = space.isPvpEnv and space:isPvpEnv()
	self.staminaTickData.freelanceMode = Utils.isUnlockFreelanceMode(pg.me, Utils.getLeylineTreeIdBySceneId(space.sceneId))
end

function ClientStaminaComponent:onLeaveSpace()
	local space = self.space
end

function ClientStaminaComponent:setFastCarryEggStaminaState(isEnter)
	self.staminaTickData.isFastCarryEgg = isEnter == true
end

function ClientStaminaComponent:setStaminaLocked(locked)
	self.staminaLocked = locked == true

	if self.staminaLocked then
		self.lockedStamina = self:getStamina()

		self:clearStaminaTickData()
	else
		self.lockedStamina = nil
	end
end

function ClientStaminaComponent:clearStaminaTickData()
	local tickData = self.staminaTickData

	tickData.enterCost = 0
	tickData.horiRate = 0
	tickData.vertRate = 0
	tickData.recoverStaminaLeftTime = StaminaConfigData.StaminaRegenCoolDown
	tickData.stateTag = TagMask.None
	tickData.staminaTag = TagMask.None
	tickData.recovery = false
	tickData.startCost = false
end

function ClientStaminaComponent:restoreLockedStamina(curStamina)
	if not self.staminaLocked or self.lockedStamina == nil or self.restoringLockedStamina then
		return false
	end

	curStamina = curStamina or self:getStamina()

	local delta = self.lockedStamina - curStamina

	if math.abs(delta) <= 0.0001 then
		return false
	end

	self.restoringLockedStamina = true

	self.actorCombatAttribute:changeStamina(delta)

	self.restoringLockedStamina = false

	return true
end

function ClientStaminaComponent:updateStaminaTags(tagMasks)
	if self.staminaLocked then
		return
	end

	local stateTag = TagMask.None
	local staminaTag = TagMask.None

	for sTag, name in pairs(self.StateTagNames) do
		if tagMasks:Has(sTag) then
			stateTag = sTag
		end
	end

	local priority = -1

	for sTag, name in pairs(self.StaminaTagNames) do
		if tagMasks:Has(sTag) then
			local curtPriority = self.StaminaTagPriority[sTag]

			if priority < curtPriority then
				staminaTag = sTag
				priority = curtPriority
			end
		end
	end

	self:changeStaminaTickData(stateTag, staminaTag)
end

function ClientStaminaComponent:updateStaminaMoveDirectionRate(horiRate, vertRate)
	if self.staminaLocked then
		return
	end

	local tickData = self.staminaTickData

	tickData.horiRate = horiRate
	tickData.vertRate = vertRate
end

function ClientStaminaComponent:changeStaminaTickData(stateTag, staminaTag)
	local tickData = self.staminaTickData
	local inDiffState = tickData.stateTag ~= stateTag
	local inDiffStamina = tickData.staminaTag ~= staminaTag
	local stateData = self:getStaminaStateData(stateTag)
	local staminaData = self:getStaminaData(stateTag, staminaTag)
	local cost = 0
	local recovery = tickData.recovery
	local queryData = self:prepareStaminaQueryData(stateTag)

	self:staminaQueryEnterCost(stateData, queryData)

	local stateCost = queryData.cost

	self:staminaQueryEnterCost(staminaData, queryData)

	if inDiffState then
		cost = queryData.cost * queryData.rate
		recovery = queryData.recovery
	elseif inDiffStamina then
		cost = (queryData.cost - stateCost) * queryData.rate
		recovery = queryData.recovery
	end

	tickData.enterCost = cost
	tickData.recovery = recovery
	tickData.startCost = true
	tickData.stateTag = stateTag
	tickData.staminaTag = staminaTag
end

function ClientStaminaComponent:getStaminaData(stateTag, staminaTag)
	local tagStr = self.StaminaTagNames[staminaTag] or "Default"
	local data = self:getStaminaStateData(stateTag)

	if not data then
		return nil
	end

	return data[tagStr]
end

function ClientStaminaComponent:getStaminaStateData(stateTag)
	local tagStr1 = self.StateTagNames[stateTag] or "Default"
	local fromPlayer = pg.game.controller:isInControlMainPlayer()
	local data

	if fromPlayer then
		data = StaminaConfigData.StaminaCostConfigAvatar[tagStr1]
	else
		data = StaminaConfigData.StaminaCostConfig[tagStr1]
	end

	return data
end

function ClientStaminaComponent:prepareStaminaQueryData(stateTag)
	local data = self.staminaQueryData

	data.cost = 0
	data.rate = 1
	data.recovery = false
	data.enterWithoutCost = false
	data.horiRate = 0
	data.vertRate = 0
	data.inCombat = self:judgeStaminaInCombat(stateTag)

	return data
end

function ClientStaminaComponent:judgeStaminaInCombat(stateTag)
	if self:isInCombat() then
		return true
	end

	if stateTag == TagMask.Fly and self.staminaTickData.usualFlyCostSpace then
		return true
	end

	if self.staminaTickData.isRobEggSpace or self.staminaTickData.isFastCarryEgg then
		return true
	end

	return false
end

function ClientStaminaComponent:queryStaminaConfig(configData, costType, queryData)
	local canRecover = configData.CanRecover

	if canRecover == true then
		queryData.recovery = true
	end

	if canRecover == false then
		queryData.recovery = false
	end

	if configData.EnterWithoutCost then
		queryData.enterWithoutCost = true
	end

	local rate = configData.CostRateNotInCombat or 1

	if queryData.inCombat then
		rate = 1
	end

	local cost = 0
	local costData = configData[costType]

	if costData then
		if (queryData.horiRate > 0 or queryData.vertRate > 0) and costData.cost_v and costData.cost_h then
			cost = costData.cost_v * queryData.vertRate + costData.cost_h * queryData.horiRate
		else
			cost = costData.cost or 0
		end

		if not queryData.inCombat and costData.CostRateNotInCombat then
			rate = rate * costData.CostRateNotInCombat
		end

		local multiplier = costData.multiplier

		if multiplier then
			local fromPlayer = pg.game.controller:isInControlMainPlayer()

			if not fromPlayer then
				local petEnt = self:isControllingPet() and self:getCurPetEntity()
				local templateId = petEnt and petEnt.templateId or pg.game.controller.switchInfo.templateId

				if templateId then
					local petData = PetData[templateId]

					if petData then
						rate = rate * (petData[multiplier] or 1)
					end
				end
			end
		end
	end

	queryData.rate = queryData.rate * rate
	queryData.cost = queryData.cost + cost
end

function ClientStaminaComponent:checkStaminaCost(stateTag, staminaTag)
	if self.gmMode == Const.NO_COST_MODE then
		return true
	end

	local queryData = self:prepareStaminaQueryData(stateTag)

	self:staminaQueryEnterCost(self:getStaminaStateData(stateTag), queryData)
	self:staminaQueryEnterCost(self:getStaminaData(stateTag, staminaTag), queryData)

	local cost = queryData.cost

	if queryData.inCombat and staminaTag == TagMask.Dash and self.space and Utils.isRobEggSceneId(self.space.sceneId) then
		cost = AbilitySettingGlobalConstData.SouDaCheInCombatDashCost or 30
	end

	local ret = cost <= self:getStamina()

	if not ret and not self.staminaTickData.notifyNotEnough then
		self.staminaTickData.notifyNotEnough = true
	end

	if cost > 0 then
		facade:sendMsgToUI(MessageName.CHECK_ENDURANCE_ENOUGH, {
			isEnough = ret
		})
	end

	return ret
end

function ClientStaminaComponent:checkEndofStamina()
	if self.gmMode == Const.NO_COST_MODE then
		return false
	end

	return self:getStamina() < 0.1
end

function ClientStaminaComponent:staminaQueryEnterCost(configData, queryData)
	if not configData then
		return
	end

	self:queryStaminaConfig(configData, StaminaConfigData.StaminaCostType.COST_ON_ENTER, queryData)

	if queryData.enterWithoutCost then
		queryData.enterWithoutCost = false
		queryData.rate = 0
	end
end

function ClientStaminaComponent:staminaQueryTickCost(costType, stateTag, staminaTag, queryData)
	if self:needClearTickCost(stateTag, queryData) then
		return
	end

	local stateData = self:getStaminaStateData(stateTag)

	if stateData then
		self:queryStaminaConfig(stateData, costType, queryData)

		local staminaData = self:getStaminaData(stateTag, staminaTag)

		if staminaData then
			self:queryStaminaConfig(staminaData, costType, queryData)
		end
	end
end

function ClientStaminaComponent:needClearTickCost(stateTag, queryData)
	if self.characterState == CharacterStateConst.SPEEDBURSTFALL then
		queryData.rate = 0

		return true
	end

	if stateTag == TagMask.Glide then
		local controledPawn = pg.pawn

		if controledPawn and controledPawn.inConstraintWind then
			queryData.rate = 0

			return true
		end
	elseif stateTag == TagMask.Fly then
		local master = self.getMasterEntity and self:getMasterEntity().inConstraintWind or self

		if master and master.inConstraintWind then
			queryData.rate = 0

			return true
		end
	end

	return false
end

function ClientStaminaComponent:onStaminaExhausted()
	self.staminaTickData.startCost = false

	local controledPawn = pg.pawn
	local characterState = controledPawn.characterState

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) then
		self:checkFlyingSkillAndCast(controledPawn)
	elseif CharacterStateConst.isChildOfState(characterState, CharacterStateConst.MAGNESIS) then
		controledPawn:setMagnesisModeEnable(false)
	end

	self:exitFastCarryEggState()
end

function ClientStaminaComponent:checkFlyingSkillAndCast(controledPawn)
	if Utils.isPet(controledPawn) and controledPawn.flyEndSkill then
		local castResult = controledPawn:clientCastAbilityNoTarget(controledPawn.flyEndSkill)

		return castResult
	end

	return false
end

function ClientStaminaComponent:costStamina(stateTag, staminaTag, cost)
	if true then return end --[[INFSTAM]]
	if cost <= 0 or self.gmMode == Const.NO_COST_MODE then
		return
	end

	if pg.pawn:AUTO_CAST_ST() then
		return
	end

	local costRatio = self.actorCombatAttribute:getStaminaCostRatio()

	if stateTag == TagMask.Climb then
		costRatio = self.actorCombatAttribute:getStaminaCostRatio(AttributeConst.stamina_cost_ratio_climb_v)
	elseif stateTag == TagMask.Glide then
		if pg.pawn.eModel.CanGlide then
			cost = 0
		else
			costRatio = self.actorCombatAttribute:getStaminaCostRatio(AttributeConst.stamina_cost_ratio_glide_v)
		end
	elseif stateTag == TagMask.Swim then
		-- block empty
	elseif staminaTag == TagMask.Dash then
		costRatio = pg.pawn.actorCombatAttribute:getStaminaCostRatio(AttributeConst.stamina_cost_ratio_dash_v)

		if self.space.isPvpEnv and self.space:isPvpEnv() then
			cost = cost * (AbilitySettingGlobalConstData.pvpDashStaminaCostRatio or 1)
		elseif Utils.isRobEggSceneId(self.space.sceneId) and self:isInCombat() then
			cost = AbilitySettingGlobalConstData.SouDaCheInCombatDashCost or 30
		end
	elseif staminaTag == TagMask.Sprint then
		costRatio = pg.pawn.actorCombatAttribute:getStaminaCostRatio(AttributeConst.stamina_cost_ratio_sprint_v)
	end

	cost = cost * costRatio * self.staminaTickData.followRatio

	self.actorCombatAttribute:changeStamina(-cost)
end

function ClientStaminaComponent:recoverStamina(value)
	if value > 0 then
		self.actorCombatAttribute:changeStamina(value)
	end
end

function ClientStaminaComponent:onStaminaCurChange(old, new)
	if self:restoreLockedStamina(new) then
		return
	end

	if new <= 0 then
		self:onStaminaExhausted()
	end

	facade:sendMsgToUI(MessageName.ENDURANCE_STATE_CHANGE)
end

function ClientStaminaComponent:checkFullStamina()
	local attr = self.actorCombatAttribute

	return attr:getRawAttribValue(AttributeConst.stamina_cur) >= attr:getRawAttribValue(AttributeConst.stamina_max_cur)
end

function ClientStaminaComponent:tick(deltaTime)
	if self.staminaLocked then
		self:restoreLockedStamina()

		return
	end

	local eModelTimeScale = self.eModel.timeScale or 1
	local scaledDeltaTime = deltaTime * self.timeScale * eModelTimeScale
	local tickData = self.staminaTickData
	local isFastCarryEggMoving = tickData.isFastCarryEgg and tickData.staminaTag == TagMask.Movement
	local staminaTag = isFastCarryEggMoving and TagMask.Sprint or tickData.staminaTag
	local cost = 0

	if tickData.enterCost > 0 then
		cost = cost + tickData.enterCost
		tickData.enterCost = 0
	end

	local queryData = self:prepareStaminaQueryData(tickData.stateTag)

	if (tickData.startCost or isFastCarryEggMoving) and (queryData.inCombat or not tickData.freelanceMode) then
		queryData.horiRate = tickData.horiRate
		queryData.vertRate = tickData.vertRate

		self:staminaQueryTickCost(StaminaConfigData.StaminaCostType.COST_BY_TIME, tickData.stateTag, staminaTag, queryData)

		local tickCost = queryData.cost * queryData.rate * scaledDeltaTime

		cost = cost + tickCost

		self:costStamina(tickData.stateTag, staminaTag, cost)
	end

	if cost == 0 and tickData.recovery and not self:checkFullStamina() then
		if tickData.recoverStaminaLeftTime > 0 then
			tickData.recoverStaminaLeftTime = tickData.recoverStaminaLeftTime - scaledDeltaTime
		else
			local regenV = self.actorCombatAttribute:getAttribValue(AttributeConst.stamina_regen_v)
			local regenP = self.actorCombatAttribute:getAttribValue(AttributeConst.stamina_regen_p)
			local pvpStaminaRecoverRatio = tickData.isPvpSpace and AbilitySettingGlobalConstData.pvpStaminaRecoverRatio or 1

			if tickData.isRobEggSpace then
				if self:isInCombat() then
					pvpStaminaRecoverRatio = AbilitySettingGlobalConstData.pvpStaminaRecoverRatio or 1
				else
					pvpStaminaRecoverRatio = SysConfigData.OutFightStaminRatio or 1
				end
			end

			self:recoverStamina(regenV * (1 + regenP) * scaledDeltaTime * pvpStaminaRecoverRatio)
		end
	else
		tickData.recoverStaminaLeftTime = StaminaConfigData.StaminaRegenCoolDown
	end

	if tickData.notifyNotEnough then
		pg.global.showBubbleMessageById(NoticeDef.STAMINA_NOT_ENOUGH)

		tickData.notifyNotEnough = false
	end
end

function ClientStaminaComponent:getOneDashCost()
	local queryData = self:prepareStaminaQueryData(TagMask.None)
	local data = self:getStaminaData(TagMask.None, TagMask.Dash)

	self:staminaQueryEnterCost(data, queryData)

	return queryData.cost
end

return ClientStaminaComponent
