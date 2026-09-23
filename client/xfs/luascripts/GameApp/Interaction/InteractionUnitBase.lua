-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractionUnitBase.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local InteractData = require("Data.interact_data")
local Mathf = require("Common.Math.Mathf")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local ClientUtils = require("Utils.ClientUtils")
local DialogueConst = require("Const.DialogueConst")
local SandboxConst = require("Common.Const.SandboxConst")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local DialogueUtils = require("Utils.DialogueUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local Time = require("Core.Common.Time")
local ItemConst = require("Common.Const.ItemConst")
local RobEggConst = require("Common.Const.RobEggConst")
local logger = LoggerManager.getLogger("InteractionUnitBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetPrototypeData = require("Data.pet_prototype_data")
local TextHelperBase = require("GameApp.Interaction.TextHelper.TextHelperBase")
local PetFamilyData = require("Data.pet_family_data")
local ToBool = ToBool
local InteractionUnitBase = Class.LightClass("InteractionUnitBase")
local InteractionConst = require("Common.Const.InteractionConst")

function InteractionUnitBase:ctor(info, interactId)
	self.info = info
	self.globalId = info.globalId
	self.triggerSrcType = info.triggerSrcType
	self.dist = info.dist
	self.overrideInteractDis = info.overrideInteractDis
	self.needItem = info.needItem
	self.showDetail = info.showDetail
	self.targetName = info.name or ""
	self.actionPrototypeId = info.actionPrototypeId or InteractionConst.DEFAULT_INTERACTION_PROTOTYPE_ID
	self.interactData = InteractData[self.actionPrototypeId] and lume.clone(InteractData[self.actionPrototypeId]) or {}
	self.interactData.styleId = self.actionPrototypeId
	self.interactData.index = 1
	self.interactData.actionName = info.actionName or self.interactData.actionName
	self.interactData.textColor = info.textColor
	self.interactionType = info.interactionType or self.interactData.type
	self.interactId = interactId
	self.targetPos = info.targetPos
	self.handlePetEthnicGroup = info.handlePetEthnicGroup or ToBool(self.interactData.handlePetEthnicGroup)
	self.overrideNpcTemplateId = info.overrideNpcTemplateId
	self.useTurnAnim = false
	self.stateCheckExclude = {}

	if self.interactData.stateCheckExclude then
		for _, state in ipairs(self.interactData.stateCheckExclude) do
			self.stateCheckExclude[state] = true
		end
	end

	self.info.dialogueSrc = DialogueConst.SrcType.Interaction
end

function InteractionUnitBase:canInteractive()
	local ent = self:getEntity()

	if not ent then
		return false
	end

	local visible = ent.visible

	if visible == false then
		return false
	end

	if ent.checkCanInteract and not ent:checkCanInteract(self) then
		return false
	end

	if not self:checkInteractAngle() then
		return false
	end

	if not self:checkInteractForwardAngleRange() then
		return false
	end

	if not self:checkAirBlock() then
		return false
	end

	if not self:checkInteractBlock() then
		return false
	end

	if not self.interactData.showWhenCantAct and not self:checkConditionId() then
		return false
	end

	if pg.me:isControllingEgg() and SysConfigData.EggModeInteractWhiteList and not table.contains(SysConfigData.EggModeInteractWhiteList, self.actionPrototypeId) then
		return false
	end

	if self.interactData.actWhenArrive == 1 then
		if not pg.pawn:checkAutoInteract(nil, true, self.stateCheckExclude) then
			return false
		end
	else
		if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
			return false
		end

		if not pg.pawn:checkInteract(nil, true, self.stateCheckExclude) then
			return false
		end

		if pg.pawn ~= pg.me and not pg.me:checkInteract(nil, true, self.stateCheckExclude) then
			return false
		end
	end

	if pg.me.space and Utils.isSpaceSingleWorld(pg.me.space.spaceType) and pg.me:isInTeam() and pg.me.inLeaderWorld then
		if Utils.isChest(ent) then
			if not ent:belongsToPlayer(pg.me) then
				return false
			end
		elseif self:checkCaseCanInteract(ent) then
			-- block empty
		else
			return false
		end
	end

	if not self:checkDistanceValid(ent) then
		return false
	end

	if self.interactData.checkPrototypeId and pg.pawn.basePetPrototypeId ~= self.interactData.checkPrototypeId then
		return false
	end

	return true
end

function InteractionUnitBase:checkCaseCanInteract(ent)
	if Utils.isVehicle(ent) then
		return true
	elseif Utils.isCollectItem(ent) then
		return true
	elseif Utils.isEnvObj(ent) then
		return true
	end

	return false
end

function InteractionUnitBase:checkDistanceValid(ent)
	local interactDis = self:getConfigDis()

	if interactDis > 0 then
		local triggerId = ent.triggerId

		if triggerId and ent.eModel then
			return ent.eModel:CheckTriggerDistanceValid(triggerId)
		else
			return false
		end
	end

	return true
end

function InteractionUnitBase:findPointAtDistance(posA, posB, distAB, distLimit)
	local t = (distAB - distLimit) / distAB

	if t < 0 then
		t = 0
	end

	local x = posA.x + (posB.x - posA.x) * t
	local y = posA.y + (posB.y - posA.y) * t
	local z = posA.z + (posB.z - posA.z) * t

	return {
		x,
		y,
		z
	}
end

function InteractionUnitBase:getEntity()
	local ent = pg.getEntityByGlobalId(self.globalId)

	return ent
end

function InteractionUnitBase:checkConditionId()
	local player = pg.me
	local conditionIds = self.interactData.conditionId or {}

	for _, conditionId in pairs(conditionIds) do
		if not player.triggerMap:isCompleteOrMeetCondition(conditionId) then
			return false
		end
	end

	return true
end

function InteractionUnitBase:doInteract(param)
	if self.interactData.showWhenCantAct and not self:checkConditionId() then
		if self.interactData.conNotice then
			ClientUtils.showBubbleMessage(self.interactData.conNotice)
		end

		return
	end

	local space = pg.space

	if space and space.checkPermission and not space:checkPermission(SandboxConst.Permission.OwnerInScene, true) then
		return
	end

	self:tryInteractive(param)
end

function InteractionUnitBase:tryInteractive(param)
	if not self.interactData then
		return false
	end

	local preCheckFunc = self.info.preCheckFunc

	if preCheckFunc and not preCheckFunc() then
		return false
	end

	local targetPos = self:getInteractPos()
	local targetEnt = self:getEntity()
	local pawn = pg.pawn
	local canChangeLocation = true
	local needAutoPathFind = targetPos ~= nil
	local needFaceToTarget = ToBool(self.interactData.faceToTarget)
	local skipChangeLocation = true

	if needAutoPathFind or targetEnt and needFaceToTarget then
		canChangeLocation = pg.pawn:checkCanChangeLocationBeforeInteract(self.interactData.isLocationConflictByCancel)
		skipChangeLocation = not canChangeLocation
	end

	if not canChangeLocation and self.interactData.demandLocationChange then
		return false
	end

	if skipChangeLocation then
		self:tryTargetFaceToPawn(targetEnt)

		if not self:checkHandlePetEthnicGroup(param) then
			return
		end

		self:interactive(param)

		return true
	end

	local function internalInteractiveFunc()
		self:tryFaceToTarget(needFaceToTarget, targetEnt)
		self:tryTargetFaceToPawn(targetEnt)

		if not self:checkHandlePetEthnicGroup(param) then
			return
		end

		self:interactive(param)
	end

	local AbilityConst = require("Common.Const.AbilityConst")
	local ClientDebugUtils = require("Utils.ClientDebugUtils")

	ClientDebugUtils.drawDebugHitBoxMesh(targetPos, Quaternion(0, 0, 0, 1), AbilityConst.LX_GEOMETRY_TYPE_SPHERE, {
		0.5
	})

	if needAutoPathFind and pawn:pawnAutoPathFinding(targetPos, internalInteractiveFunc, AutoPathFindUtils.PathFindType.Voxel) then
		return true
	end

	internalInteractiveFunc()

	return true
end

function InteractionUnitBase:getInteractPos()
	local targetPos
	local ent = self:getEntity()

	if not ent then
		return
	end

	local pawn = pg.pawn

	if not pawn then
		return
	end

	local iconDist = self:getInteractIconDist()
	local forceDist = self.interactData.interactiveForceDist
	local faceToInteractions = self.interactData.faceToInteractions

	if forceDist then
		if ent.getInteractPos then
			return ent:getInteractPos(forceDist, pawn)
		end

		Vector3.enableCreateFromCache()

		local entPos = ent:getPosition()
		local dir = Vector3.one

		if faceToInteractions then
			dir = ent:getForward()
		else
			local playerPos = pawn:getPosition()
			local xzPosOffset = playerPos - entPos

			xzPosOffset.y = 0

			if xzPosOffset:Magnitude() < 0.0001 then
				dir = ent:getForward()
			else
				dir = Vector3.Normalize(xzPosOffset)
			end
		end

		targetPos = entPos + dir * forceDist

		Vector3.disableCreateFromCache(targetPos)

		return targetPos
	end

	if iconDist then
		local entPos = ent:getPosition()
		local dist = Utils.distance(pawn:getPosition(), entPos)
		local distLimit = self.dist or self:getConfigDis()

		if distLimit < dist then
			targetPos = self:findPointAtDistance(pawn:getPosition(), entPos, dist, distLimit - 0.1)
		end
	end

	return targetPos
end

function InteractionUnitBase:tryFaceToTarget(needFaceToTarget, targetEnt)
	if not needFaceToTarget or not targetEnt then
		return
	end

	pg.pawn:faceToTarget(targetEnt, nil, self.useTurnAnim)
end

function InteractionUnitBase:tryTargetFaceToPawn(targetEnt)
	if not targetEnt then
		return
	end

	local needTargetFaceToPawn = ToBool(self.interactData.targetTurnToPlayer)

	if needTargetFaceToPawn and targetEnt.faceToTarget then
		targetEnt:faceToTarget(pg.pawn, nil, self.useTurnAnim)
	end
end

function InteractionUnitBase:interactive(param)
	return
end

function InteractionUnitBase:getIcon()
	if self.info and self.info.iconId then
		return self.info.iconId
	end

	local ent = self:getEntity()

	if ent and Utils.isChest(ent) then
		return ent:getConfigData().icon or AddressDataConst.UI_INTERACT_COMMON_ICON
	end

	if ent and Utils.isCollectItem(ent) then
		return ent:getConfigData().icon or AddressDataConst.UI_INTERACT_COMMON_ICON
	end

	return self.interactData.iconId
end

function InteractionUnitBase:checkIsMultiChoice()
	local btnStyles = self:getInteractBtnStyle()

	return #btnStyles > 1
end

function InteractionUnitBase:getText()
	local entity = pg.getEntityByGlobalId(self.globalId)

	if entity and pg.space and pg.space:isGrabEgg() then
		if Utils.isResourceBox(entity) then
			return self:getCustomName()
		elseif Utils.isRobEggSpaceEgg(entity) then
			return self:getCombineName()
		elseif Utils.isCollectItem(entity) then
			return self:getTargetName()
		end
	end

	if not string.isNilOrEmpty(self.targetName) then
		return self:getTargetName()
	end

	local interactData = self.interactData

	if interactData.actionName then
		local text = pg.getLocalizationText(interactData.actionName)
		local ent = self:getEntity()

		if ent then
			local name

			if ent.getName then
				name = ent:getName()
			else
				local configData = ent:getConfigData()

				name = configData.name
			end

			text = string.gsub(text, UIConst.INTERACT_TEXT_REPLACE_PATTERN, pg.getLocalizationText(name))

			if self.info and self.info.formatTextArgs then
				text = pg.getFormatText(text, unpack(self.info.formatTextArgs))
			end

			text = TextHelperBase.getSpecificText(ent, interactData, text)
		end

		return text
	elseif self.targetName then
		return pg.getLocalizationText(self.targetName)
	end

	return ""
end

function InteractionUnitBase:getTip()
	return self.interactData.actionTips
end

function InteractionUnitBase:getConfigDis()
	if self.overrideInteractDis then
		return self.overrideInteractDis
	end

	local ent = self:getEntity()

	if ent then
		local cfgData = ent:getConfigData()

		if cfgData.interactiveDist then
			return cfgData.interactiveDist
		end
	end

	return self.interactData.interactiveDist or 0
end

function InteractionUnitBase:checkInteractAngle()
	local ent = self:getEntity()

	if ent then
		local cfgData = ent:getConfigData()

		if cfgData and cfgData.checkAngle then
			if self:getInteractAngle() > cfgData.checkAngle then
				return false
			end

			return true
		end
	end

	if self.interactData and self.interactData.checkAngle and self:getInteractAngle() > self.interactData.checkAngle then
		return false
	end

	return true
end

function InteractionUnitBase:checkInteractForwardAngleRange()
	local ent = self:getEntity()

	if ent then
		local cfgData = ent:getConfigData()

		if cfgData and cfgData.checkForwardAngleRange then
			return self:checkIsInForwardAngleRange(cfgData.checkForwardAngleRange)
		end
	end

	if self.interactData and self.interactData.checkForwardAngleRange then
		return self:checkIsInForwardAngleRange(self.interactData.checkForwardAngleRange)
	end

	return true
end

function InteractionUnitBase:checkIsInForwardAngleRange(angle)
	local ent = self:getEntity()

	if not ent then
		return false
	end

	local pawn = pg.pawn

	if not pawn then
		return false
	end

	angle = math.max(0, math.min(360, angle))

	if angle <= 0 then
		return false
	end

	if angle >= 360 then
		return true
	end

	local entPos = ent:getPosition()
	local pawnPos = pawn:getPosition()

	Vector3.enableCreateFromCache()

	local ent2PawnDir = pawnPos - entPos

	ent2PawnDir.y = 0

	if ent2PawnDir:Magnitude() < 1e-06 then
		Vector3.disableCreateFromCache()

		return true
	end

	ent2PawnDir:SetNormalize()

	local entForward = ent:getForward()

	entForward.y = 0

	if entForward:Magnitude() < 1e-06 then
		Vector3.disableCreateFromCache()

		return true
	end

	entForward:SetNormalize()

	local dotProduct = Vector3.Dot(entForward, ent2PawnDir)

	dotProduct = math.max(-1, math.min(1, dotProduct))

	local angleRad = math.acos(dotProduct)
	local angleDeg = math.deg(angleRad)
	local halfAngle = angle / 2
	local result = angleDeg <= halfAngle

	Vector3.disableCreateFromCache()

	return result
end

function InteractionUnitBase:checkAirBlock()
	if self.interactData and self.interactData.airBlock == 1 then
		local pawn = pg.pawn

		if pawn:FALL_ST() then
			return false
		end
	end

	return true
end

function InteractionUnitBase:checkInteractBlock()
	if self.interactData and self.interactData.checkBlock == 1 then
		local ent = self:getEntity()
		local pawn = pg.pawn

		if ent and AutoPathFindUtils.checkEntityBlock(pawn, ent) then
			return false
		end
	end

	return true
end

function InteractionUnitBase:getInteractAngle()
	local ent = self:getEntity()

	if not ent then
		return 0
	end

	local pawn = pg.pawn
	local pawnYaw = pawn:getRotation():GetEulerAnglesY()

	Vector3.enableCreateFromCache()

	local pawn2Ent = ent:getPosition() - pawn:getPosition()

	if pawn2Ent:Magnitude() < 1e-06 then
		Vector3.disableCreateFromCache()

		return 0
	end

	Vector3.disableCreateFromCache(pawn2Ent)

	local pawn2EntYaw = Quaternion.LookRotation(pawn2Ent, Vector3.up):GetEulerAnglesY()
	local yawDiff = Mathf.DeltaAngle(pawn2EntYaw, pawnYaw)

	return math.abs(yawDiff)
end

function InteractionUnitBase:getSquareDist()
	local ent = self:getEntity()

	if not ent then
		return math.maxFloat
	end

	local pawn = pg.pawn

	return Utils.squareDistNoYAxis(pawn:getPosition(), ent:getPosition())
end

function InteractionUnitBase:getInteractBtnStyle()
	if self.interactData.actWhenArrive == 1 then
		return {}
	end

	if self.actionPrototypeId == ItemConst.ROB_EGG_INTERACT_TYPE.EGG_SHIP_TRANSFER then
		local isControllingEgg = pg.me and pg.me.isControllingEgg and pg.me:isControllingEgg()
		local pawnIsEgg = pg.pawn and pg.pawn.isRobSpaceEgg
		local hasTransferEgg = isControllingEgg or pawnIsEgg or pg.me and pg.me:grabEgg_checkHasCarryEgg() or false

		self.interactData.textColor = hasTransferEgg and RobEggConst.EGG_SHIP_TRANSFER_HAS_EGG_TEXT_COLOR or RobEggConst.EGG_SHIP_TRANSFER_NO_EGG_TEXT_COLOR
	end

	return {
		self.interactData
	}
end

function InteractionUnitBase:getActionName()
	return pg.getLocalizationText(self.interactData.actionName)
end

function InteractionUnitBase:getCustomName()
	return self:getActionName()
end

function InteractionUnitBase:getTargetName()
	return pg.getLocalizationText(self.targetName)
end

function InteractionUnitBase:getCombineName()
	local actionName = pg.getLocalizationText(self.interactData.actionName)
	local targetName = pg.getLocalizationText(self.targetName)

	if not string.isNilOrEmpty(actionName) and string.find(actionName, "{0}", 1, true) then
		return pg.getFormatText(actionName, targetName)
	end

	local combineName

	if not string.isNilOrEmpty(actionName) then
		combineName = actionName
	end

	if not string.isNilOrEmpty(targetName) then
		combineName = ClientTextUtils.concatByLanguage(combineName, targetName)
	end

	return combineName
end

function InteractionUnitBase:getInteractIconDist()
	return self.interactData.interactiveIconDist
end

function InteractionUnitBase:getInteractTargetPos()
	if self.targetPos then
		return self.targetPos
	end

	local ent = self:getEntity()

	if ent then
		return ent:getPosition()
	end
end

function InteractionUnitBase:checkChanged()
	return false
end

function InteractionUnitBase:onEnterTrigger()
	if self.interactData.actWhenArrive == 1 and self:canInteractive(true) then
		self.lastAutoInteractTime = Time.realSecondCache

		self:doInteract()
	end
end

function InteractionUnitBase:tryAutoInteract()
	if self.interactData.actWhenArrive == 1 then
		if self.lastAutoInteractTime and Time.realSecondCache - self.lastAutoInteractTime < 1 then
			return
		end

		if self:canInteractive(true) then
			self.lastAutoInteractTime = Time.realSecondCache

			self:doInteract()
		end
	end
end

function InteractionUnitBase:checkIsAutoInteract()
	if self.interactData.actWhenArrive == 1 then
		return true
	end
end

function InteractionUnitBase:onLeaveTrigger()
	return
end

function InteractionUnitBase:setSortId(sortId)
	self.sortId = sortId
end

function InteractionUnitBase:getSortId()
	return self.sortId
end

function InteractionUnitBase:needCheckPetEthnicGroup(param)
	return self.handlePetEthnicGroup
end

function InteractionUnitBase:checkHandlePetEthnicGroup(param)
	if not self:needCheckPetEthnicGroup(param) then
		return true
	end

	local interactEntity = self:getEntity()
	local npcTemplateId = interactEntity and interactEntity.templateId or 0
	local npcData = PuppetData[npcTemplateId]

	if npcData and npcData.npcType == DialogueConst.NpcType.Pet then
		pg.me:_cancel_EXPLORE_DELAY_CANCEL_SWITCH_ST()

		if pg.me:isControllingExploreEnt() then
			return false
		end

		local ret, dialogType, id, specialEthnicId = DialogueUtils.checkPetsSameEthnicDialogue(pg.pawn, interactEntity)

		if not ret then
			if dialogType == 1 then
				pg.game.dialogue:playDialogueGraph(id, nil, nil, {
					src = DialogueConst.SrcType.Interaction
				})
			else
				local ethnicGroup = specialEthnicId

				if ethnicGroup == nil then
					ethnicGroup = interactEntity ~= nil and interactEntity:getConfigData() ~= nil and interactEntity:getConfigData().ethnicGroup or nil
				end

				local petsInfo = ClientUtils.findCanLinkedPetsInBag(nil, nil, ethnicGroup)

				ClientUtils.sortCanLinkedPetsInBag(petsInfo)

				local petName, extraText
				local extraInfo = {}

				if petsInfo ~= nil and #petsInfo > 0 then
					local petInfo = petsInfo[1]

					petName = petInfo.customName

					local prototypeData = PetPrototypeData[petInfo.petPrototypeId]

					if string.isNilOrEmpty(petName) then
						petName = prototypeData and pg.getLocalizationText(prototypeData.name) or nil
					end

					extraInfo.extraText = petName and pg.getFormatText(pg.getGameString("PET_UNKNOWDIALOGUE_TEXT1"), petName) or nil
					extraInfo.branch = {}
					extraInfo.branch[1] = {
						optionText = pg.getFormatText(pg.getGameString("PET_UNKNOWDIALOGUE_TEXT2"), petName),
						btnIcon = LuaUIUtils.getPetIcon(prototypeData.iconName, LuaUIUtils.PET_ICON)
					}
					extraInfo.branch[2] = {
						optionText = pg.getGameString("PET_UNKNOWDIALOGUE_TEXT3"),
						btnIcon = AddressDataConst.UI_EXIT_INTERACT_ICON
					}

					function extraInfo.callback(branchIndex)
						if branchIndex == 1 then
							ClientUtils.quickLinkByPetId(petInfo.id, function(ret)
								if ret then
									self:tryInteractive(param)
								end
							end)
						end
					end
				else
					local prototypeData = Utils.getPetPrototypeData(interactEntity)
					local familyData = PetFamilyData[prototypeData.ethnicGroup]

					petName = prototypeData and pg.getLocalizationText(familyData.name) or nil
					extraInfo.extraText = petName and pg.getFormatText(pg.getGameString("PET_UNKNOWDIALOGUE_TEXT"), petName) or nil
				end

				extraInfo.src = DialogueConst.SrcType.Interaction
				extraInfo.overrideNameTemplateId = self.overrideNpcTemplateId

				pg.game.communication:startNpcDialog(id, interactEntity.id, extraInfo)
			end

			return false
		end
	end

	return true
end

return InteractionUnitBase
