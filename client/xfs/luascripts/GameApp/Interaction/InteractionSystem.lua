-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractionSystem.lua

local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local InteractionConst = require("Common.Const.InteractionConst")
local InteractionQuickCatch = require("GameApp.Interaction.InteractUnit.InteractionQuickCatch")
local InteractionRootNodeUnit = require("GameApp.Interaction.InteractionRootNodeUnit")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local InteractData = require("Data.interact_data")
local LoggerManager = require("Core.Log.LoggerManager")
local lume = require("Core.Common.lume")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestEntityData = require("Data.Quest.quest_entity_data")
local UIConst = require("Const.UIConst")
local PetConfigData = require("Data.pet_config_data")
local NpcFuncConfigData = require("Data.npc_func_config_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local ClientSwitch = require("Common.ClientSwitch")
local InteractionSystem = Class.LightClass("InteractionSystem", SystemBase)

function InteractionSystem:getMessageBindMap()
	return {
		[MessageName.ENTER_TRIGGER] = "onEnterTrigger",
		[MessageName.LEAVE_TRIGGER] = "onLeaveTrigger",
		[MessageName.ENTER_TRIGGER_MULTI_INTERACT] = "onMultInteractEnterTrigger",
		[MessageName.LEAVE_TRIGGER_MULTI_INTERACT] = "onMultInteractLeaveTrigger",
		[MessageName.PLAYER_ONTELEPORT] = "onPlayerTeleport",
		[MessageName.QUEST_ON_STATE_CHANGE] = "onQuestStateChange",
		[MessageName.QUEST_ON_OBJECTIVE_FINISHED] = "onQuestObjectiveFinished",
		[MessageName.NPC_DUEL_STATE_CHANGED] = "onNpcDuelStateChanged",
		[MessageName.PET_CHANGE_REFRESH] = "onPetChange",
		[MessageName.MAIN_PET_LEAVE_SPACE] = "onMainPetLeaveSpace",
		[MessageName.BREAK_STATE_CHANGE] = "onBreakStateChange",
		[MessageName.ON_CONTROL_ENT] = "onControlEntChanged"
	}
end

function InteractionSystem:onCtor()
	self.pause = false
	self.isClassic = false
	self.interactIdIdx = 0
	self.currentUnitMap = {}
	self.curNoTargetType = nil
	self.curAutoInteractUnit = {}
	self.unitMap = {}
	self.currentInteractList = {}
	self.interactableUnitInRange = 0
	self.breakEntIdSet = {}
	self.quickCaptureRefreshDirty = false
	self.controlEntSensitiveFuncMenuCache = {}
	self.isControllingEgg = pg.me and pg.me:isControllingEgg() or false

	self:initQuickCaptureInteract()
end

function InteractionSystem:onDestroy()
	self:clear()
end

function InteractionSystem:clear()
	self:clearQuickCaptureRefresh()

	self.pause = false

	for index, unitList in pairs(self.currentUnitMap) do
		for _, unit in pairs(unitList) do
			unit:onLeaveTrigger()
		end
	end

	for _, rootNode in pairs(self.currentInteractList) do
		for _, unit in pairs(rootNode.interactUnits) do
			unit:onLeaveTrigger()
		end
	end

	self.currentUnitMap = {}
	self.currentInteractList = {}
	self.curAutoInteractUnit = {}
	self.curNoTargetType = nil
	self.unitMap = {}
	self.interactableUnitInRange = 0
	self.breakEntIdSet = {}

	self:initQuickCaptureInteract()
	facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
end

function InteractionSystem:onSpaceDestroy(space)
	if space == pg.space then
		self:clear()
	end
end

function InteractionSystem:onPlayerTeleport()
	return
end

function InteractionSystem:onSceneLoaded(sceneId, sceneName)
	if not pg.me or not pg.me.space then
		return
	end

	if pg.space:isHomeland() then
		self:setInteractClassicEnable(true)
	else
		self:setInteractClassicEnable(false)
	end
end

function InteractionSystem:onSceneUnloaded(sceneId, sceneName)
	self:setInteractClassicEnable(false)
end

function InteractionSystem:onQuestStateChange(data)
	self:refreshQuestRelatedEntities(data.questId)
end

function InteractionSystem:onQuestObjectiveFinished(data)
	self:refreshQuestRelatedEntities(data.questId)
end

function InteractionSystem:refreshQuestRelatedEntities(questId)
	local questEntData = QuestEntityData[questId]

	if questEntData == nil then
		return
	end

	if not pg.me or not pg.me.space then
		return
	end

	for i = 1, #questEntData do
		local data = questEntData[i]

		if data.staticId then
			local ent = pg.me.space:getEntityByStaticId(data.id)

			if ent and ent.refreshInteractTrigger then
				ent:refreshInteractTrigger()
			end
		else
			local entities = pg.getEntitiesByPetPrototypeId(data.id)

			if entities then
				for k, ent in pairs(entities) do
					if ent and ent.refreshInteractTrigger then
						ent:refreshInteractTrigger()
					end
				end
			end
		end
	end
end

function InteractionSystem:onNpcDuelStateChanged(data)
	local npcDuelId = data.npcDuelId

	if not npcDuelId or not pg.me or not pg.me.npcSpecialInteractsMap then
		return
	end

	for staticId, _ in pairs(pg.me.npcSpecialInteractsMap) do
		local ent = pg.me.space:getEntityByStaticId(staticId)

		if ent then
			local configData = ent:getConfigData()

			if configData and configData.npcDuelId == npcDuelId and ent.refreshInteractTrigger then
				ent:refreshInteractTrigger()
			end
		end
	end
end

function InteractionSystem:refreshInteractions()
	if not pg.pawn then
		return
	end

	if self.pause then
		return
	end

	if self.isClassic then
		self:trySyncInteractChange()
	else
		self:refreshInteractUnit()
	end

	self:updateAutoInteracts()
end

function InteractionSystem:onTick()
	self:refreshInteractions()
end

function InteractionSystem:setInteractClassicEnable(enabled)
	if self.isClassic ~= enabled then
		self.isClassic = enabled

		facade:sendMsgToUI(MessageName.UPDATE_INTERACT_MODE, {})
	end
end

function InteractionSystem:getNoTargetInteractUnit()
	for _, type in ipairs(InteractionConst.NO_TARGET_POS_LIST) do
		if self.unitMap[type] then
			local unitList = self.unitMap[type]
			local unit

			for index = #unitList, 1, -1 do
				unit = unitList[index]

				if unit:canInteractive() then
					return {
						type,
						{
							unit
						}
					}
				end
			end
		end
	end
end

function InteractionSystem:getCollectItemEntities()
	local map = self.unitMap[InteractionConst.INTERACTION_TYPE_ENT_FUNC]
	local entities = {}

	if map then
		for _, unit in pairs(map) do
			local entity = pg.getEntityByGlobalId(unit.globalId)

			if Utils.isCollectItem(entity) then
				entities[#entities + 1] = entity
			end
		end
	end

	return entities
end

function InteractionSystem:getInterActionType(info)
	if info.overrideType then
		return info.overrideType
	end

	local actionPrototypeId = info.actionPrototypeId
	local interactData = InteractData[actionPrototypeId]

	if actionPrototypeId and interactData and interactData.type then
		return interactData.type
	end

	local interactionType = info.interactionType

	if interactionType then
		return interactionType
	end

	return nil
end

function InteractionSystem:onEnterTrigger(info)
	local interactionType = self:getInterActionType(info)

	if not interactionType then
		return
	end

	local globalId = info.globalId

	if self.unitMap[interactionType] then
		local unitList = self.unitMap[interactionType]

		for index, unit in ipairs(unitList) do
			if info.actionPrototypeId == unit.actionPrototypeId and unit.globalId == globalId and unit.triggerSrcType == info.triggerSrcType then
				return
			end
		end
	end

	local unit = self:generateInteractionUnit(info)

	if unit then
		if not self.unitMap[interactionType] then
			self.unitMap[interactionType] = {}
		end

		self.unitMap[interactionType][#self.unitMap[interactionType] + 1] = unit

		unit:onEnterTrigger()
	end
end

function InteractionSystem:onMultInteractEnterTrigger(infos)
	for _, info in ipairs(infos) do
		self:onEnterTrigger(info)
	end
end

function InteractionSystem:onLeaveTrigger(info)
	local interactionType = self:getInterActionType(info)

	if not interactionType then
		return
	end

	local globalId = info.globalId
	local actionPrototypeId = info.actionPrototypeId

	if self.unitMap[interactionType] then
		local unitList = self.unitMap[interactionType]

		for index, unit in ipairs(unitList) do
			if unit.globalId == globalId and unit.triggerSrcType == info.triggerSrcType and (actionPrototypeId == nil or unit.actionPrototypeId == actionPrototypeId) then
				unit:onLeaveTrigger()
				table.remove(unitList, index)

				break
			end
		end
	end

	self:refreshInteractUnit()
end

function InteractionSystem:onLeaveTriggerWithType(interactionType)
	local unitList = self.unitMap[interactionType]

	if unitList == nil or #unitList == 0 then
		return
	end

	for _, unit in ipairs(unitList) do
		unit:onLeaveTrigger()
	end

	table.clearArray(unitList)
	self:refreshInteractUnit()
end

function InteractionSystem:onMultInteractLeaveTrigger(infos)
	for _, info in ipairs(infos) do
		self:onLeaveTrigger(info)
	end
end

function InteractionSystem:onControlEntChanged()
	if ClientSwitch.EnableInteractionControlEntOptimize then
		local isControllingEgg = pg.me and pg.me:isControllingEgg() or false
		local eggModeChanged = self.isControllingEgg ~= isControllingEgg

		self.isControllingEgg = isControllingEgg

		if eggModeChanged or self:hasControlEntSensitiveUnit() then
			self:refreshInteraction(true)
		end
	else
		self:refreshInteraction(true)
	end
end

function InteractionSystem:hasControlEntSensitiveUnit()
	for interactionType, unitList in pairs(self.unitMap) do
		if #unitList > 0 then
			local checkType = InteractionConst.ControlEntSensitiveUnitCheckType[interactionType]

			if checkType == InteractionConst.UNIT_CONTROL_ENT_SENSITIVE then
				return true
			elseif checkType == InteractionConst.UNIT_CONTROL_ENT_CONDITIONAL_SENSITIVE then
				for _, unit in ipairs(unitList) do
					if self:isControlEntSensitive(unit) then
						return true
					end
				end
			end
		end
	end

	return false
end

function InteractionSystem:isControlEntSensitive(unit)
	if not unit then
		return false
	end

	return unit.interactData and unit.interactData.checkPrototypeId ~= nil or self:isControlEntSensitiveFuncMenu(unit.funcMenuId)
end

function InteractionSystem:isControlEntCondition(conditionName)
	if not conditionName then
		return false
	end

	return conditionName == "PLAYER_IS_CONTROL_PET" or string.find(conditionName, "CONTROL_PET", 1, true) == 1
end

function InteractionSystem:isControlEntSensitiveFuncMenu(funcMenuId)
	if not funcMenuId then
		return false
	end

	local cached = self.controlEntSensitiveFuncMenuCache[funcMenuId]

	if cached ~= nil then
		return cached
	end

	local sensitive = false
	local npcFuncConfigData = NpcFuncConfigData[funcMenuId]
	local npcFuncList = npcFuncConfigData and npcFuncConfigData.npcFunc

	if not npcFuncList then
		self.controlEntSensitiveFuncMenuCache[funcMenuId] = false

		return false
	end

	for _, npcFunc in ipairs(npcFuncList) do
		local checkConditions = npcFunc[3]

		if checkConditions then
			for _, conditionId in ipairs(checkConditions) do
				local customTriggerInfo = CustomTriggerData[conditionId]
				local conditionInfo = customTriggerInfo and customTriggerInfo.condition

				if conditionInfo then
					for _, condition in ipairs(conditionInfo) do
						if self:isControlEntCondition(condition[1]) then
							sensitive = true

							break
						end
					end
				end

				if sensitive then
					break
				end
			end

			if sensitive then
				break
			end
		end
	end

	self.controlEntSensitiveFuncMenuCache[funcMenuId] = sensitive

	return sensitive
end

function InteractionSystem:generateInteractionUnit(info)
	local interactionType = self:getInterActionType(info)

	if not interactionType then
		return
	end

	local config = InteractionConst.INTERACTION_CONFIG[interactionType]

	if not config then
		return nil
	end

	local className = config.className
	local class = require("GameApp.Interaction.InteractUnit." .. className)
	local interactId = self:getInteractId()

	return class.new(info, interactId)
end

function InteractionSystem:getInteractId()
	local interactId = self.interactIdIdx

	self:calculateInteractId()

	return interactId
end

function InteractionSystem:calculateInteractId()
	self.interactIdIdx = self.interactIdIdx + 1

	if self.interactIdIdx > InteractionConst.INTERACT_ID_END then
		self.interactIdIdx = 0
	end
end

function InteractionSystem:doUnitInteractive(unit, info)
	if unit ~= nil and unit:canInteractive() then
		unit:doInteract(info)
	end
end

function InteractionSystem:onBreakStateChange(data)
	if not data or not data.ent then
		return
	end

	local ent = data.ent

	if not Utils.isPuppet(ent) then
		return
	end

	local entId = ent.id

	if data.isBreak then
		self.breakEntIdSet[entId] = true
	else
		self.breakEntIdSet[entId] = nil
	end

	self:requestQuickCaptureRefresh()
end

function InteractionSystem:requestQuickCaptureRefresh()
	self.quickCaptureRefreshDirty = true
end

function InteractionSystem:beforeAnimation()
	if not self.quickCaptureRefreshDirty then
		return
	end

	self.quickCaptureRefreshDirty = false

	self:tryRefreshQuickCaptureInteract()
end

function InteractionSystem:clearQuickCaptureRefresh()
	self.quickCaptureRefreshDirty = false
end

function InteractionSystem:tryRefreshQuickCaptureInteract()
	local targetEntId = self:tryGetQuickCaptureTarget()

	if targetEntId then
		self.quickCaptureUnit:setEnableInteractive(true)

		if targetEntId ~= self.quickCaptureEntId then
			self:tryShowInteractView()
			self.quickCaptureUnit:setTargetId(targetEntId)

			self.quickCaptureEntId = targetEntId

			facade:sendMsgToUI(MessageName.UPDATE_QUICK_CAPTURE_STATE, {
				visible = true
			})
		end
	else
		self.quickCaptureUnit:setEnableInteractive(false)

		if self.quickCaptureEntId then
			facade:sendMsgToUI(MessageName.UPDATE_QUICK_CAPTURE_STATE, {
				visible = false
			})
		end

		self.quickCaptureEntId = nil
	end
end

function InteractionSystem:tryGetQuickCaptureTarget()
	local player = pg.pawn

	if not player or not pg.me then
		return nil
	end

	if not player:checkQuickCatch(true) then
		return nil
	end

	local earliestTs = math.maxFloat
	local captureEntId

	for entId in pairs(self.breakEntIdSet) do
		local ent = pg.getEntity(entId)

		if not ent then
			self.breakEntIdSet[entId] = nil
		elseif self:checkQuickCapture(player, ent) and earliestTs > ent.breakRecoverTime then
			earliestTs = ent.breakRecoverTime
			captureEntId = ent.id
		end
	end

	return captureEntId
end

function InteractionSystem:checkQuickCapture(player, ent)
	if not ent then
		return false
	end

	if ent:isDead() then
		return false
	elseif not ent:inBreak() then
		return false
	end

	if ent.needDoGroupReward then
		return false
	end

	if pg.game.camera.ballDriveCameraMode:isActive() then
		return false
	end

	local timeNow = Time.realSecondCache

	if ent.lastQuickCaptureTime and timeNow - ent.lastQuickCaptureTime < 5 then
		return false
	end

	if Utils.distance(player:getPosition(), ent:getPosition()) >= self.quickCaptureUnit:getConfigDis() then
		return false
	end

	local ballItemId = self.quickCaptureUnit:getBallItemId()
	local hasBall = ballItemId ~= nil and ballItemId ~= 0

	if not hasBall then
		return not CatchProbContext.clientIsForbidCatchIgnoreBall(ent)
	end

	local probContext = CatchProbContext.clientGet(ent)

	if not probContext.canCatch and probContext.cantCatchReason ~= "lackEmptySlot" then
		return false
	end

	return true
end

function InteractionSystem:initQuickCaptureInteract()
	local interactId = self:getInteractId()
	local info = {
		actionPrototypeId = InteractionConst.STYLE_CONST.QUICK_CAPTURE,
		interactionType = InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE
	}

	self.unitMap[InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE] = {}
	self.quickCaptureUnit = InteractionQuickCatch.new(info, interactId)

	self:clearQuickCaptureTimer()

	if not EnableBotTest then
		self.quickCaptureTimer = TimerManager.addRepeatTimer(0.5, function()
			self:requestQuickCaptureRefresh()
		end)
	end
end

function InteractionSystem:clearQuickCaptureTimer()
	if self.quickCaptureTimer then
		TimerManager.removeTimer(self.quickCaptureTimer)

		self.quickCaptureTimer = nil
	end
end

function InteractionSystem:refreshInteraction(force)
	self:refreshInteractUnit(force)
	self:updateAutoInteracts()
end

function InteractionSystem:getCurrentUnitMapGlobalIdByInteractionConstId(interactionConstId)
	for _, rootNode in ipairs(self.currentInteractList) do
		for _, unit in pairs(rootNode.interactUnits) do
			if unit.interactionType == interactionConstId then
				return unit.globalId
			end
		end
	end
end

function InteractionSystem:updateAutoInteracts()
	if self.isClassic then
		for idx, units in pairs(self.currentUnitMap) do
			for _, unit in pairs(units) do
				if unit.tryAutoInteract then
					unit:tryAutoInteract()
				end
			end
		end
	else
		for idx, unit in pairs(self.curAutoInteractUnit) do
			if unit.tryAutoInteract then
				unit:tryAutoInteract()
			end
		end
	end
end

local firstLevelUnits = {}
local onlyFuncUnits = {}
local interactListCache = {}
local interactList = interactListCache

function InteractionSystem:refreshInteractUnit(force)
	table.clear(firstLevelUnits)
	table.clear(onlyFuncUnits)
	table.clear(interactList)

	local sortId = 0

	table.clear(self.curAutoInteractUnit)

	for _, type in ipairs(InteractionConst.NO_TARGET_POS_LIST) do
		if self.unitMap[type] then
			local unitList = self.unitMap[type]
			local unit

			for index = #unitList, 1, -1 do
				unit = unitList[index]

				self:tryInsertInteractUnit(firstLevelUnits, onlyFuncUnits, unit, sortId)

				sortId = sortId + 1
			end
		end
	end

	for _, interType in ipairs(InteractionConst.INTERACTION_PRIORITY_LIST) do
		if self.unitMap[interType] then
			local unitList = self.unitMap[interType]

			for index = #unitList, 1, -1 do
				local unit = unitList[index]

				if not unit:checkIsAutoInteract() then
					self:tryInsertInteractUnit(firstLevelUnits, onlyFuncUnits, unit, sortId)

					sortId = sortId + 1
				else
					self.curAutoInteractUnit[#self.curAutoInteractUnit + 1] = unit
				end
			end
		end
	end

	local interactChanged = false
	local changedStartIndex

	for _, rootNode in pairs(firstLevelUnits) do
		if not rootNode:checkIsEmpty() then
			self:sortQuestInter(rootNode)

			interactList[#interactList + 1] = rootNode
		end
	end

	for _, rootNode in ipairs(onlyFuncUnits) do
		interactList[#interactList + 1] = rootNode
	end

	self:filterMarkShareInteractions(interactList)

	interactList = self:rebuildCurrentInteractList(interactList)

	if force then
		interactListCache = self.currentInteractList
		self.currentInteractList = interactList
		interactList = interactListCache

		self:tryShowInteractView()
		facade:SendMessageCommand(MessageName.UPDATE_INTERACT_VIEW, {})

		return
	end

	if #interactList ~= #self.currentInteractList then
		interactChanged = true
	end

	local compareCount = math.min(#interactList, #self.currentInteractList)

	for index = 1, compareCount do
		local unitRoot1 = interactList[index]
		local unitRoot2 = self.currentInteractList[index]

		if not unitRoot1:compareOtherRootNode(unitRoot2) then
			interactChanged = true
			changedStartIndex = index

			break
		end
	end

	if interactChanged then
		changedStartIndex = changedStartIndex or compareCount + 1
	end

	if interactChanged then
		interactListCache = self.currentInteractList
		self.currentInteractList = interactList
		interactList = interactListCache

		self:tryShowInteractView()
		facade:SendMessageCommand(MessageName.UPDATE_INTERACT_VIEW, {
			changedStartIndex = changedStartIndex
		})
	end
end

function InteractionSystem:filterMarkShareInteractions(interactRoots)
	if self.isClassic then
		return
	end

	local hasOtherInteraction = false

	for _, rootNode in ipairs(interactRoots) do
		if not rootNode:isMarkShare() then
			hasOtherInteraction = true

			break
		end
	end

	if not hasOtherInteraction then
		return
	end

	local count = #interactRoots
	local writeIndex = 1

	for index = 1, count do
		local rootNode = interactRoots[index]

		if not rootNode:isMarkShare() then
			interactRoots[writeIndex] = rootNode
			writeIndex = writeIndex + 1
		end
	end

	for index = writeIndex, count do
		interactRoots[index] = nil
	end
end

local _prioritys = {}
local _oldIndexs = {}
local _newIndexs = {}
local _sortIds = {}

local function _sortFunc(a, b)
	local pa = _prioritys[a]
	local pb = _prioritys[b]
	local aOldIdx = _oldIndexs[a]
	local bOldIdx = _oldIndexs[b]

	if not aOldIdx and pa == InteractionConst.LEVEL_05 and bOldIdx then
		return false
	elseif aOldIdx and not bOldIdx and pb == InteractionConst.LEVEL_05 then
		return true
	end

	if pa < pb then
		return true
	elseif pa == pb then
		if pa ~= InteractionConst.LEVEL_05 then
			local aSortId = _sortIds[a]
			local bSortId = _sortIds[b]

			if aSortId ~= bSortId then
				return aSortId < bSortId
			end
		end

		if aOldIdx and bOldIdx then
			return aOldIdx < bOldIdx
		elseif aOldIdx then
			return true
		elseif bOldIdx then
			return false
		end

		return _newIndexs[a] < _newIndexs[b]
	else
		return false
	end
end

function InteractionSystem:rebuildCurrentInteractList(newInteractList)
	for i, a in ipairs(newInteractList) do
		_prioritys[a] = self:getEntPriority(a)
		_oldIndexs[a] = self:getEntInOldInteract(a)
		_newIndexs[a] = i
		_sortIds[a] = a:getSortId() or math.maxInt
	end

	table.sort(newInteractList, _sortFunc)
	table.clear(_prioritys)
	table.clear(_oldIndexs)
	table.clear(_newIndexs)
	table.clear(_sortIds)

	return newInteractList
end

function InteractionSystem:getEntPriority(interactUnit)
	local ent = interactUnit:getEnt()

	if not ent then
		if interactUnit:isMarkShare() then
			return InteractionConst.LEVEL_05
		end

		return InteractionConst.LEVEL_01
	elseif Utils.isChest(ent) or Utils.isGrabEggTransfer(ent) or Utils.isNpc(ent) then
		return InteractionConst.LEVEL_00
	elseif ent == pg.pawn then
		return InteractionConst.LEVEL_02
	elseif Utils.isPlayer(ent) or Utils.isPet(ent) then
		return InteractionConst.LEVEL_05
	end

	return InteractionConst.LEVEL_04
end

function InteractionSystem:getEntInOldInteract(interUnit)
	for idx, unit in ipairs(self.currentInteractList) do
		if interUnit.globalId and unit.globalId == interUnit.globalId then
			return idx
		end

		if not interUnit.globalId and not unit.globalId and unit.interactUnits[1] == interUnit.interactUnits[1] then
			return idx
		end
	end
end

function InteractionSystem:tryInsertInteractUnit(firstUnits, onlyFuncUnits, unit, sortId)
	local globalId = unit.globalId

	if not globalId then
		if unit:canInteractive() then
			local rootNodeUnit = InteractionRootNodeUnit.new()

			rootNodeUnit:addInteractUnit(unit)

			rootNodeUnit.onlyFunc = true
			onlyFuncUnits[#onlyFuncUnits + 1] = rootNodeUnit
		end

		return
	end

	if unit:canInteractive() then
		local rootNodeUnit = firstUnits[globalId]

		if not rootNodeUnit then
			rootNodeUnit = InteractionRootNodeUnit.new(globalId)
			firstUnits[globalId] = rootNodeUnit
		end

		unit:setSortId(sortId)
		rootNodeUnit:addInteractUnit(unit)
	end
end

function InteractionSystem:setCanClimbHereState(flag)
	self.canClimbHere = flag
end

function InteractionSystem:trySyncInteractChange()
	local interactChange = false
	local chooseEntId
	local UnitInfo = self:getNoDistInteractUnit()

	if UnitInfo then
		interactChange = self:trySetCurrentUnitMap(UnitInfo[1], UnitInfo[2])
	else
		local interInfo = self:getEntInteractUnit()

		interactChange = interInfo[1]
		self.currentUnitMap = interInfo[2]
		chooseEntId = interInfo[3]
	end

	self.curChooseEntId = chooseEntId

	if interactChange then
		self:tryShowInteractView()
		facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
		facade:sendMsgToSystem(MessageName.UPDATE_INTERACT_VIEW, {})
	end
end

function InteractionSystem:tryShowInteractView()
	if pg.global.ui.interact:checkUIClosing() then
		pg.global.ui.interact:open()
	end
end

function InteractionSystem:getNoDistInteractUnit()
	for _, type in ipairs(InteractionConst.NO_TARGET_POS_LIST) do
		if self.unitMap[type] then
			local unitList = self.unitMap[type]
			local unit

			for index = #unitList, 1, -1 do
				unit = unitList[index]

				if unit:canInteractive() then
					return {
						type,
						{
							unit
						}
					}
				end
			end
		end
	end
end

function InteractionSystem:trySetCurrentUnitMap(interType, interUnitList)
	local changed = false

	if interType ~= self.curNoTargetType then
		self.curNoTargetType = interType
		changed = true
	end

	local curList = self.currentUnitMap[interType]

	for idx, interUnit in ipairs(interUnitList) do
		if not curList or curList and curList[idx] ~= interUnit then
			changed = true

			break
		end

		if interUnit:checkChanged() then
			changed = true

			break
		end
	end

	if changed then
		self.currentUnitMap = {}
		self.currentUnitMap[interType] = interUnitList
	end

	return changed
end

function InteractionSystem:getEntInteractUnit()
	local interChanged = false
	local nearestAngle = math.maxFloat
	local maxPriority = 0
	local pawn = pg.pawn
	local interEntId
	local unitInfos = {}

	for _, interType in ipairs(InteractionConst.NO_TARGET_POS_LIST) do
		if self.currentUnitMap[interType] then
			interChanged = true
			self.currentUnitMap[interType] = nil
		end
	end

	self.interactableUnitInRange = 0

	for _, interType in ipairs(InteractionConst.INTERACTION_PRIORITY_LIST) do
		if self.unitMap[interType] then
			local unitList = self.unitMap[interType]
			local unit

			for index = #unitList, 1, -1 do
				unit = unitList[index]

				if unit:canInteractive() then
					local targetPos = unit:getInteractTargetPos()

					if targetPos then
						local angle = unit:getInteractAngle()
						local tempSquareDist = Utils.squareDistNoYAxis(pawn:getPosition(), targetPos)

						if interType ~= InteractionConst.INTERACTION_TYPE_MARK_SHARE and tempSquareDist <= SysConfigData.INFO_STAMP_FORBIDDEN_AREA_NEAR_NPC then
							self.interactableUnitInRange = self.interactableUnitInRange + 1
						end

						local ent = unit:getEntity()
						local curPriority = 0

						if ent and ent.getInteractPriority then
							curPriority = ent:getInteractPriority()
						end

						if maxPriority < curPriority or angle < nearestAngle then
							maxPriority = curPriority
							nearestAngle = angle

							if ent then
								interEntId = ent.id
							else
								interEntId = nil
							end
						end

						unitInfos[#unitInfos + 1] = {
							interType,
							unit
						}
					else
						table.remove(unitList, index)
					end
				end
			end
		end
	end

	local resultData = {}

	for index = #unitInfos, 1, -1 do
		local unitParam = unitInfos[index]
		local iType, unit = unpack(unitParam)
		local ent = unit:getEntity()

		if interEntId then
			if ent and ent.id == interEntId then
				if not resultData[iType] then
					resultData[iType] = {}
				end

				local len = #resultData[iType]

				resultData[iType][len + 1] = unit
			end
		elseif not ent then
			if not resultData[iType] then
				resultData[iType] = {}
			end

			local len = #resultData[iType]

			resultData[iType][len + 1] = unit
		end
	end

	for _, interType in ipairs(InteractionConst.INTERACTION_PRIORITY_LIST) do
		local curUnitCount = self.currentUnitMap[interType] and #self.currentUnitMap[interType] or 0
		local resultUnitCount = resultData[interType] and #resultData[interType] or 0

		if curUnitCount ~= resultUnitCount then
			interChanged = true

			break
		end

		if curUnitCount > 0 then
			for idx = 1, curUnitCount do
				if self.currentUnitMap[interType][idx] ~= resultData[interType][idx] then
					interChanged = true

					break
				end
			end
		end
	end

	return {
		interChanged,
		resultData,
		interEntId
	}
end

function InteractionSystem:checkHasInteractUnit()
	for idx, unit in pairs(self.currentUnitMap) do
		if unit then
			return true
		end
	end

	return false
end

function InteractionSystem:onPetChange(info)
	if info.isPet then
		local masterEntity = info.ent:getMasterEntity()

		if masterEntity ~= pg.me then
			return
		end
	elseif info.ent ~= pg.me then
		return
	end

	local curPet = pg.me:getCurPetEntity()

	if not curPet then
		return
	end

	if lume.find(PetConfigData.GotchaTemplateId, curPet.templateId) and pg.me.controlState == Const.CONTROL_STATE_CONTROL then
		if not pg.global.ui:checkUIOpen(UIConst.UI_OCTOPUS_GASHAPON) then
			pg.global.ui:open(UIConst.UI_OCTOPUS_GASHAPON)
		else
			pg.global.ui:close(UIConst.UI_OCTOPUS_GASHAPON)
			pg.global.ui:open(UIConst.UI_OCTOPUS_GASHAPON)
		end
	elseif pg.global.ui:checkUIOpen(UIConst.UI_OCTOPUS_GASHAPON) then
		pg.global.ui:close(UIConst.UI_OCTOPUS_GASHAPON)
	end
end

function InteractionSystem:onMainPetLeaveSpace(info)
	local ent = info and info.ent

	if not ent then
		return
	end

	if not lume.find(PetConfigData.GotchaTemplateId, ent.templateId) then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_OCTOPUS_GASHAPON) then
		pg.global.ui:close(UIConst.UI_OCTOPUS_GASHAPON)
	end
end

function InteractionSystem:sortQuestInter(interactUnit)
	if interactUnit == nil or not interactUnit.interactUnits or #interactUnit.interactUnits <= 1 then
		return
	end

	local function getQuestId(unit)
		if unit.questId and unit.questId ~= 0 then
			return unit.questId
		elseif unit.questCommitInfo and #unit.questCommitInfo > 0 then
			return unit.questCommitInfo[1].questId
		elseif unit.questDialogInfo and #unit.questDialogInfo > 0 then
			return unit.questDialogInfo[1].questId
		end

		return nil
	end

	local function isQuestRelated(unit)
		if table.contains(InteractionConst.QuestCorrelationType, unit.interactionType) then
			return true
		end

		return getQuestId(unit) ~= nil
	end

	local questUnits = {}
	local otherUnits = {}
	local pageTypeZeroUnits = {}

	for _, unit in ipairs(interactUnit.interactUnits) do
		if isQuestRelated(unit) then
			local questId = getQuestId(unit)

			if questId then
				unit.isHudShowQuest = QuestUtils.getPageType(questId) > 0

				if QuestUtils.getPageType(questId) == 0 then
					table.insert(pageTypeZeroUnits, unit)
				else
					table.insert(questUnits, unit)
				end
			else
				table.insert(otherUnits, unit)
			end
		else
			table.insert(otherUnits, unit)
		end
	end

	table.sort(pageTypeZeroUnits, function(a, b)
		local qIdA = getQuestId(a)
		local qIdB = getQuestId(b)
		local isClueA = qIdA and QuestUtils.isQuestOfClueQuestType(qIdA) or false
		local isClueB = qIdB and QuestUtils.isQuestOfClueQuestType(qIdB) or false

		if isClueA ~= isClueB then
			return isClueA
		end

		return (qIdA or 0) < (qIdB or 0)
	end)

	local questIdCache = {}

	for _, unit in ipairs(questUnits) do
		questIdCache[unit] = getQuestId(unit)
	end

	table.sort(questUnits, function(a, b)
		local qIdA = questIdCache[a]
		local qIdB = questIdCache[b]
		local tracingA = qIdA and QuestUtils.isCurQuestTracing(qIdA) or false
		local tracingB = qIdB and QuestUtils.isCurQuestTracing(qIdB) or false

		if tracingA ~= tracingB then
			return tracingA
		end

		if (a.isHudShowQuest or false) ~= (b.isHudShowQuest or false) then
			return a.isHudShowQuest or false
		end

		local pageTypeA = qIdA and QuestUtils.getPageType(qIdA) or 0
		local pageTypeB = qIdB and QuestUtils.getPageType(qIdB) or 0

		if pageTypeA ~= pageTypeB then
			return pageTypeA < pageTypeB
		end

		return (qIdA or 0) < (qIdB or 0)
	end)
	table.clear(interactUnit.interactUnits)

	for _, unit in ipairs(questUnits) do
		table.insert(interactUnit.interactUnits, unit)
	end

	for _, unit in ipairs(otherUnits) do
		table.insert(interactUnit.interactUnits, unit)
	end

	for _, unit in ipairs(pageTypeZeroUnits) do
		table.insert(interactUnit.interactUnits, unit)
	end
end

return InteractionSystem
