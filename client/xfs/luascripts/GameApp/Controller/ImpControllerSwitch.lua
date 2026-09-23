-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\ImpControllerSwitch.lua

local ControllerSystem = require("GameApp.Controller.ControllerSystem")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local AbilityConst = require("Common.Const.AbilityConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local InputCommand = require("GameApp.Input.InputCommand")

function ControllerSystem:getFlyLevel(globalId)
	local pet = pg.getEntity(globalId)

	if not pet or not pet.templateId then
		return 0
	end

	local data = pet:getConfigData()

	if not data then
		return 0
	end

	return data.canFly or 0
end

function ControllerSystem:autoSwitchEntity(globalId, abilityIndex, state)
	if pg.game.cutscene:isInCutsceneState() then
		return false
	end

	self:tryCancelDelayCancel()

	if globalId == self.pawn.id then
		return false
	end

	self:forceSaveControllerState(false, state)

	local valid = false

	if globalId == self.me:getGlobalId() then
		valid = pg.me:switchToExplorePlayer()
	elseif pg.me.inExploreState and pg.me.lastControlState == Const.CONTROL_STATE_CONTROL and pg.me.lastCombatPetId == globalId then
		valid = pg.me:cancelSwitchToExploreEnt()
	else
		valid = pg.me:switchToExplorePet(abilityIndex, globalId)
	end

	if valid then
		self.pawn:playEffect("Eff_Common_Parmon_Switch")
		self.pawn:playSoundEvent("ui_sfx_change_parmon")
	end

	return true
end

function ControllerSystem:restoreAutoSwitch(state)
	if not pg.me or not pg.me:isControllingExploreEnt() then
		return false
	end

	if pg.pawn ~= pg.me then
		self:delayCancelExploreSwitch()

		return false
	else
		pg.me:cancelSwitchToExploreEnt()

		return false
	end
end

function ControllerSystem:tryCancelDelayCancel()
	if self:isInDelayExit() then
		self:cancelDelayCancel()
		facade:sendMsgToUI(MessageName.EXIT_EXIT_DELAY_EXPLORE_STATE)
	end
end

function ControllerSystem:cancelDelayCancel()
	if self.delayCancelTimerId then
		self:killTimer(self.delayCancelTimerId)

		self.delayCancelTimerId = nil
	end

	self.delayExitMark = false
end

function ControllerSystem:delayCancelExploreSwitch()
	if self:isInDelayExit() then
		return
	end

	self.delayExitMark = false

	local cancelExploreSwitchDelay = SysConfigData.cancelExploreSwitchDelay or 2

	self.delayCancelTimerId = self:startTimer(CallbackHandler(self, "realCancelExploreSwitch"), cancelExploreSwitchDelay)

	facade:sendMsgToUI(MessageName.ENTER_EXIT_DELAY_EXPLORE_STATE)
end

function ControllerSystem:isInDelayExit()
	return self.delayExitMark or self.delayCancelTimerId or false and true
end

function ControllerSystem:checkAndCancelExploreSwitch()
	if self.delayExitMark then
		self:realCancelExploreSwitch()
	end
end

function ControllerSystem:realCancelExploreSwitch(force, forceShowMsg)
	local showMsg = not self.delayExitMark or forceShowMsg

	if not showMsg then
		if not self.lastShowCancelExploreMsg or Time.realSecondCache > self.lastShowCancelExploreMsg + 4 then
			self.lastShowCancelExploreMsg = Time.realSecondCache
			showMsg = true
		end
	else
		self.lastShowCancelExploreMsg = Time.realSecondCache
	end

	self:cancelDelayCancel()

	if not pg.me or not pg.me:isControllingExploreEnt() then
		return
	end

	if pg.pawn ~= pg.me then
		if not force and not pg.me:checkCanCancelSwitchToExploreEnt(showMsg) then
			self.delayExitMark = true

			return
		end

		self:forceSaveControllerState(false)
		pg.me:cancelSwitchToExploreEnt()
		self.pawn:playEffect("Eff_Common_Parmon_Switch")
		self.pawn:playSoundEvent("ui_sfx_change_parmon")
	else
		pg.me:cancelSwitchToExploreEnt()
	end

	facade:sendMsgToUI(MessageName.EXIT_EXIT_DELAY_EXPLORE_STATE)
end

function ControllerSystem:isInAutoSwitch()
	if not pg.me then
		return false
	end

	return pg.me:isControllingExploreEnt()
end

function ControllerSystem:saveControllerState(filterState, state)
	if self.switchInfo.enabled then
		return
	end

	self:forceSaveControllerState(filterState, state)
end

function ControllerSystem:forceSaveControllerState(filterState, state, abilityStateDuration, abilityVelocity)
	self.switchInfo.enabled = true

	local velocity, rotation

	if self.pawn then
		state = state or self.pawn.characterState
		velocity = self.pawn.eModel and self.pawn.eModel.LastTargetVelocity or nil
	end

	self.switchInfo.filterState = filterState
	self.switchInfo.pendingCharacterState = state
	self.switchInfo.pendingVelocity = velocity
	self.switchInfo.pendingAbilityStateDuration = abilityStateDuration
	self.switchInfo.pendingAbilityVelocity = abilityVelocity
end

function ControllerSystem:resetControllerState()
	self.switchInfo.enabled = false
end

function ControllerSystem:onSwitchAbilityHint(show, abilityIndex, switchGlobalId)
	if show then
		self.switchAbilityHintInfo.switchGlobalId = switchGlobalId
		self.switchAbilityHintInfo.abilityIndex = abilityIndex
		self.switchAbilityHintInfo.show = true
	else
		self.switchAbilityHintInfo.switchGlobalId = nil
		self.switchAbilityHintInfo.abilityIndex = nil
		self.switchAbilityHintInfo.show = nil
	end

	pg.game.interaction:tryShowInteractView()
	facade:SendMessageCommand(MessageName.CONTROLLER_SWITCH_UPDATE, self.switchAbilityHintInfo)
end

function ControllerSystem:getExplorePet(abilityId)
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink) then
		return
	end

	if not self.me then
		return
	end

	local explorePetId = self.me:getSpecificAbilityPetId(abilityId)
	local abilityName = AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[abilityId]

	if explorePetId then
		local petEntity = pg.getEntity(explorePetId)

		if petEntity and not petEntity:isDead() and petEntity:getConfigData()[abilityName] then
			return explorePetId
		end
	end
end

function ControllerSystem:checkManualSwitchExploreEnt()
	return self.validExploreSwitchPetEnt and self.validExploreSwitchPetEnt ~= pg.pawn
end

function ControllerSystem:manualSwitchExploreEnt()
	return
end

function ControllerSystem:updateSwitchGlobalId(abilityIndex, fallbackPlayer)
	self.validExploreSwitchPetEnt = nil
	self.csSwitchInfo.toSwitchGlobalId = nil

	if not self.enableSwitchController or self.pawn == nil or self.me == nil then
		self.switchInfo.forbidSwitch = true

		return false
	end

	local configData = self.pawn:getConfigData()
	local toSwitchGlobalId, explorePetEntity, explorePetId
	local forbidSwitch = false
	local abilityName = AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[abilityIndex]
	local mainPlayer = pg.me

	if mainPlayer.inSwitchAnim then
		forbidSwitch = true
	elseif mainPlayer.forceControl then
		forbidSwitch = true
	elseif pg.game.cutscene:isInCutsceneState() then
		forbidSwitch = true
	elseif not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink) then
		forbidSwitch = true
	else
		explorePetId = self.me:getSpecificAbilityPetId(abilityIndex)

		if explorePetId then
			local petEntity = pg.getEntity(explorePetId)

			if petEntity and not petEntity:isDead() and petEntity:getConfigData()[abilityName] then
				explorePetEntity = petEntity
				self.validExploreSwitchPetEnt = explorePetEntity
			end
		end
	end

	if forbidSwitch then
		if self:isInControlEnt() then
			if configData[abilityName] then
				toSwitchGlobalId = self.pawn:getGlobalId()
			end
		elseif fallbackPlayer then
			toSwitchGlobalId = self.me:getGlobalId()
		end
	else
		local keepSameEnt = false

		if self:isInControlEnt() and configData[abilityName] then
			toSwitchGlobalId = self.pawn:getGlobalId()
			keepSameEnt = true
		end

		if not keepSameEnt then
			if explorePetEntity then
				local curPetEnt = self.me:getCurPetEntity()
				local petVisible = explorePetEntity:checkExploreVisible()

				if petVisible and self.me:checkExploreControlPet(true) and (not curPetEnt or curPetEnt:checkExploreBeControlPet(true)) then
					toSwitchGlobalId = explorePetId
				elseif fallbackPlayer then
					toSwitchGlobalId = self.me:getGlobalId()
				end
			elseif mainPlayer:isControllingExploreEnt() and mainPlayer.lastControlState == Const.CONTROL_STATE_CONTROL then
				local petEntity = pg.getEntity(mainPlayer.lastCombatPetId)

				if petEntity and not petEntity:isDead() and petEntity:getConfigData()[abilityName] then
					toSwitchGlobalId = mainPlayer.lastCombatPetId
				elseif fallbackPlayer and self.me:checkExploreStopControlPet(true) then
					toSwitchGlobalId = self.me:getGlobalId()
				end
			elseif fallbackPlayer and (self:isInControlMainPlayer() or self.me:checkExploreStopControlPet(true)) then
				toSwitchGlobalId = self.me:getGlobalId()
			end
		end
	end

	self.switchInfo.forbidSwitch = forbidSwitch
	self.csSwitchInfo.toSwitchGlobalId = toSwitchGlobalId

	return true
end

function ControllerSystem:getClimbingInfo(showMissTip)
	local fallbackPlayer = false

	if pg.me:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		fallbackPlayer = pg.me.eModel.controllerData.canClimb
	end

	self:updateSwitchGlobalId(AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB, fallbackPlayer)

	if self.csSwitchInfo.toSwitchGlobalId then
		local entity = pg.getEntity(self.csSwitchInfo.toSwitchGlobalId)

		if entity then
			local configData = entity:getConfigData()

			self.csSwitchInfo.jumpOnWallHeight = configData.jumpOnWallHeight or 0.3

			if self:isInControlMainPlayer() then
				local height = self.pawn.eModel.height
				local climbAcrossHHeightMin = SysConfigData.jumpOnWallHeightRatio * height

				self.csSwitchInfo.minClimbHeight = climbAcrossHHeightMin + SysConfigData.jumpOnWallToTopHighHeightRange[2]
			else
				self.csSwitchInfo.minClimbHeight = configData.enterClimbMinHeight or 0.5
			end
		end
	end

	return self.csSwitchInfo
end

function ControllerSystem:getWaterfallInfo(showMissTip)
	self:updateSwitchGlobalId(AbilityConst.SPECIFIC_ABILITY_INDEX_WATERFALL, false)

	return self.csSwitchInfo
end

function ControllerSystem:getGlidingInfo(showMissTip)
	if not self:updateSwitchGlobalId(AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE, false) then
		return self.csSwitchInfo
	end

	if showMissTip == true and string.isNilOrEmpty(self.csSwitchInfo.toSwitchGlobalId) and not self.switchInfo.forbidSwitch then
		local explorePetId = self.me:getSpecificAbilityPetId(AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE)

		if not explorePetId and pg.me.eModel:IsCommandPerformed(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Jump) then
			self:showAbilityMissTip(AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE)
		end
	end

	return self.csSwitchInfo
end

function ControllerSystem:getSwimmingInfo(waterDepth)
	if self.me then
		local meConfigData = self.me:getTemplateData()
		local enterSwimHeight = (meConfigData.enterSwimDepthRatio or SysConfigData.defaultEnterSwimDepthRatio) * meConfigData.modelHeight

		if enterSwimHeight < waterDepth then
			local fallbackPlayer = true

			if pg.me:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
				fallbackPlayer = pg.me.eModel.controllerData.canSwim
			end

			self:updateSwitchGlobalId(AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM, fallbackPlayer)

			if pg.me.forceControl and self.csSwitchInfo.toSwitchGlobalId == nil then
				pg.pawn:beDrownOnForceControl()
			end
		else
			self.csSwitchInfo.toSwitchGlobalId = nil
		end
	else
		self.csSwitchInfo.toSwitchGlobalId = nil
	end

	return self.csSwitchInfo
end

function ControllerSystem:showAbilityMissTip(tipType)
	if not pg.me or pg.me.level < 5 then
		return
	end

	if self.switchInfo.forbidSwitch then
		return
	end

	if tipType == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB then
		local explorePetId = self.me:getSpecificAbilityPetId(AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB)

		if not explorePetId then
			self.lastClimbAbilityTipTime = self.lastClimbAbilityTipTime or 0

			if Time.realSecondCache - self.lastClimbAbilityTipTime > 1 then
				local canSwitchToExplorePet = self.me:checkExploreControlPet(true)

				if canSwitchToExplorePet then
					pg.global.showBubbleMessageById(NoticeDef.CLIMB_ABILITY_DISABLE)
				end

				self.lastClimbAbilityTipTime = Time.realSecondCache
			end
		end
	elseif tipType == AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE then
		local explorePetId = self.me:getSpecificAbilityPetId(AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE)

		if not explorePetId then
			self.lastGlidingAbilityTipTime = self.lastGlidingAbilityTipTime or 0

			if Time.realSecondCache - self.lastGlidingAbilityTipTime > 1 then
				local canSwitchToExplorePet = self.me:checkExploreControlPet(true)

				if canSwitchToExplorePet then
					pg.global.showBubbleMessageById(NoticeDef.GLIDING_ABILITY_DISABLE)
				end

				self.lastGlidingAbilityTipTime = Time.realSecondCache
			end
		end
	end
end

function ControllerSystem:_checkNeedShowAbilityMissTip(abilityId)
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink) then
		return false
	end

	if self.me:getSpecificAbilityPetId(abilityId) then
		return false
	end

	if self.me:checkExploreControlPet(true) then
		local curPetEnt = self.me:getCurPetEntity()

		if not curPetEnt or curPetEnt:checkExploreBeControlPet(true) then
			return true
		end
	end

	return false
end
