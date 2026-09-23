-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\NpcDuel\\NpcDuelSystem.lua

local SystemBase = require("GameApp.Core.SystemBase")
local NpcDuelSharedUtils = require("Common.Utils.NpcDuelSharedUtils")
local Time = require("Core.Common.Time")
local DialogueConst = require("Const.DialogueConst")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local NpcDuelData = require("Data.npc_duel_data")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common.Utils.Utils")
local logger = require("Core.Log.LoggerManager").getLogger("NpcDuelSystem")
local UIConst = require("Const.UIConst")
local RealAvatarRobotData = require("Data.real_avatar_robot_data")
local NPC_DUEL_EXIT_DIALOGUE_CHECK_INTERVAL = 0.1
local NPC_DUEL_EXIT_DIALOGUE_WAIT_TIMEOUT = 30
local NPC_DUEL_START_FALLBACK_TIMEOUT = 45
local NpcDuelSystem = Class.LightClass("NpcDuelSystem", SystemBase)

function NpcDuelSystem:onCtor()
	self.exitDialogueTimer = nil
	self.exitDialogueWaitTime = 0
	self.exitDialogueInfo = nil
	self.lastResultSuccess = false
	self.curNpcDuelEntId = nil
	self.curNpcDuelNpcStaticId = nil
	self.curNpcDuelNpcTemplateId = nil
	self.dialogRecord = {}
	self.botPetDieCount = 0
	self.rematchFadeInTimer = nil
	self.rematchFallbackTimer = nil
	self.maskFadeInStage1Timer = nil
	self.maskFadeInStage1MaskObj = nil
	self.npcDuelAreaEffectInfo = nil
end

function NpcDuelSystem:getMessageBindMap()
	return {
		[MessageName.PET_CHANGE_REFRESH] = "onControlNewPet",
		[MessageName.NPC_DUEL_PET_DEATH] = "onPetDie",
		[MessageName.NPC_DUEL_BUFF_ADD] = "onBuffAdd",
		[MessageName.NPC_DUEL_START_ABILITY] = "onStartAbility",
		[MessageName.ON_PLAYER_LEAVE_SCENE] = "npcDuelCheckCloseExitMask",
		[MessageName.BREAK_POINT_CHANGE] = "onCurBotPetBPChange",
		[MessageName.HEALTH_POINT_CHANGE_ALTER] = "onCurBotPetHPChange"
	}
end

function NpcDuelSystem:onDestroy()
	self:npcDuelRemoveAreaEffect()
	self:stopWaitExitDialogueTimer()
	self:onRematchFadeOut()
	self:clearMaskFadeInStage1Timer()

	self.exitDialogueInfo = nil
end

function NpcDuelSystem:resetNpcDuelEndResult()
	self.lastResultSuccess = false
end

function NpcDuelSystem:setNpcDuelEndResult(result)
	self.lastResultSuccess = result == true
end

function NpcDuelSystem:cacheDuelNpc(entId)
	self.curNpcDuelEntId = entId

	local entity = entId and pg.getEntity(entId)

	if not entity then
		return
	end

	self.curNpcDuelNpcStaticId = entity.staticId
	self.curNpcDuelNpcTemplateId = entity.getTemplateId and entity:getTemplateId() or entity.templateId
end

function NpcDuelSystem:stopWaitExitDialogueTimer()
	if self.exitDialogueTimer ~= nil then
		self:killTimer(self.exitDialogueTimer)

		self.exitDialogueTimer = nil
	end
end

function NpcDuelSystem:getExitDialogue(npcDuelData, isSuccess)
	if not npcDuelData or not isSuccess then
		return nil
	end

	return npcDuelData.clearDialogue
end

function NpcDuelSystem:prepareExitDialogue(curNpcDuelId, curNpcDuelVariantId)
	self:stopWaitExitDialogueTimer()

	self.exitDialogueInfo = nil

	local npcDuelData = NpcDuelData[curNpcDuelId] and NpcDuelData[curNpcDuelId][curNpcDuelVariantId]
	local exitDialogue = self:getExitDialogue(npcDuelData, self.lastResultSuccess)

	if not exitDialogue then
		return
	end

	self.exitDialogueInfo = {
		dialogueId = exitDialogue,
		entId = self.curNpcDuelEntId,
		staticId = self.curNpcDuelNpcStaticId,
		templateId = self.curNpcDuelNpcTemplateId
	}
	self.exitDialogueWaitTime = 0
	self.exitDialogueTimer = self:startTimer(function()
		self:tryPlayExitDialogue()
	end, NPC_DUEL_EXIT_DIALOGUE_CHECK_INTERVAL, true)
end

function NpcDuelSystem:canPlayExitDialogue()
	if not self.exitDialogueInfo then
		return false
	end

	if not pg.me or not pg.me.space then
		return false
	end

	if pg.me.space:isNpcDuel() then
		return false
	end

	if not pg.global.scene:isSceneValid() then
		return false
	end

	return true
end

function NpcDuelSystem:getExitDialogueNpcEntity(dialogueInfo)
	if not dialogueInfo or not pg.me or not pg.me.space then
		return nil
	end

	if dialogueInfo.staticId and dialogueInfo.staticId ~= 0 then
		local entity = pg.me.space:getEntityByStaticId(dialogueInfo.staticId)

		if entity then
			return entity
		end
	end

	if dialogueInfo.templateId then
		local closestEntity
		local closestDistance = 10
		local pawnPos = pg.pawn and pg.pawn:getPosition()
		local entities = pg.getEntitiesByTemplateId(dialogueInfo.templateId)

		for _, entity in pairs(entities) do
			if entity and entity.visible and (not entity.space or entity.space == pg.me.space) then
				if not pawnPos then
					return entity
				end

				local distance = Vector3.Distance(entity:getPosition(), pawnPos)

				if distance < closestDistance then
					closestDistance = distance
					closestEntity = entity
				end
			end
		end

		if closestEntity then
			return closestEntity
		end
	end

	return dialogueInfo.entId and pg.getEntity(dialogueInfo.entId) or nil
end

function NpcDuelSystem:clearExitDialogue()
	self.exitDialogueInfo = nil
	self.lastResultSuccess = false

	self:stopWaitExitDialogueTimer()
end

function NpcDuelSystem:tryPlayExitDialogue()
	if not self.exitDialogueInfo then
		return
	end

	self.exitDialogueWaitTime = (self.exitDialogueWaitTime or 0) + NPC_DUEL_EXIT_DIALOGUE_CHECK_INTERVAL

	if self.exitDialogueWaitTime > NPC_DUEL_EXIT_DIALOGUE_WAIT_TIMEOUT then
		self:clearExitDialogue()

		return
	end

	if not self:canPlayExitDialogue() then
		return
	end

	local dialogueInfo = self.exitDialogueInfo
	local npcEntity = self:getExitDialogueNpcEntity(dialogueInfo)

	if (dialogueInfo.staticId or dialogueInfo.templateId) and not npcEntity then
		return
	end

	self:clearExitDialogue()

	local entId = npcEntity and npcEntity.id or nil

	ClientUtils.showDialog(dialogueInfo.dialogueId, entId)
end

function NpcDuelSystem:onSceneLoaded(sceneId, sceneName)
	self:npcDuelRemoveAreaEffect()
	self:tryPlayExitDialogue()
end

function NpcDuelSystem:npcDuelCreateAreaEffect(centerPosition, scale)
	self:npcDuelRemoveAreaEffect()

	if not centerPosition then
		return
	end

	local effectInfo = {}

	self.npcDuelAreaEffectInfo = effectInfo

	local loadFinished = false
	local taskId = pg.global.resMgr:GetInstanceFromCacheByLua("$Eff_BossArea_Common_30X30_Collider.prefab", function(obj)
		loadFinished = true
		effectInfo.taskId = nil

		if IsNil(obj) then
			if self.npcDuelAreaEffectInfo == effectInfo then
				self.npcDuelAreaEffectInfo = nil
			end

			return
		end

		if self.npcDuelAreaEffectInfo ~= effectInfo or effectInfo.removing then
			pg.global.resMgr:RemoveInstanceToCache(obj, true)

			if self.npcDuelAreaEffectInfo == effectInfo then
				self.npcDuelAreaEffectInfo = nil
			end

			return
		end

		effectInfo.obj = obj
		obj.transform.position = centerPosition

		local rawScale = obj.transform.localScale

		obj.transform.localScale = Vector3(rawScale.x * scale, rawScale.y, rawScale.z * scale)
	end)

	if not loadFinished then
		effectInfo.taskId = taskId
	end
end

function NpcDuelSystem:npcDuelRemoveAreaEffect()
	local effectInfo = self.npcDuelAreaEffectInfo

	if not effectInfo then
		return
	end

	effectInfo.removing = true

	if effectInfo.taskId then
		pg.global.resMgr:TryCancelGOLoadAsyncTask(effectInfo.taskId)

		effectInfo.taskId = nil
	end

	if NotNil(effectInfo.obj) then
		pg.global.resMgr:RemoveInstanceToCache(effectInfo.obj, true)

		effectInfo.obj = nil
	end

	self.npcDuelAreaEffectInfo = nil
end

function NpcDuelSystem:clearMaskFadeInStage1Timer()
	if self.maskFadeInStage1Timer then
		self:killTimer(self.maskFadeInStage1Timer)

		self.maskFadeInStage1Timer = nil
	end

	if not IsNil(self.maskFadeInStage1MaskObj) then
		pg.global.uiMgr:DestroyItem(self.maskFadeInStage1MaskObj.gameObject)

		self.maskFadeInStage1MaskObj = nil
	end

	self.banNpcInteraction = false
end

function NpcDuelSystem:npcDuelMaskFadeInStage1()
	self:clearMaskFadeInStage1Timer()

	self.maskFadeInStage1MaskObj = pg.global.uiMgr:SyncInstantiateItem("$VX_Node_BattleRoom_Black_Mask.prefab", pg.global.uiMgr.infosLayer)
	self.banNpcInteraction = true
	self.maskFadeInStage1Timer = self:startTimer(function()
		self.maskFadeInStage1Timer = nil
		self.banNpcInteraction = false

		if not IsNil(self.maskFadeInStage1MaskObj) then
			pg.global.uiMgr:DestroyItem(self.maskFadeInStage1MaskObj.gameObject)

			self.maskFadeInStage1MaskObj = nil
		end
	end, 4)

	function self.maskFadeInStage2Func()
		if not IsNil(self.maskFadeInStage1MaskObj) then
			self.banNpcInteraction = false

			local uwidget = self.maskFadeInStage1MaskObj:GetComponent("UWidget")

			uwidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end
end

function NpcDuelSystem:isBanNpcInteraction()
	return ToBool(self.banNpcInteraction)
end

function NpcDuelSystem:npcDuelExitMask()
	if not IsNil(self.exitMaskObj) then
		return
	end

	self.exitMaskObj = pg.global.uiMgr:SyncInstantiateItem("$VX_Node_BattleRoom_Black_Mask.prefab", pg.global.uiMgr.infosLayer)

	TimerManager.addTimer(3, function()
		self:npcDuelCheckCloseExitMask()
	end)
end

function NpcDuelSystem:npcDuelCheckCloseExitMask()
	if not IsNil(self.exitMaskObj) then
		pg.global.uiMgr:DestroyItem(self.exitMaskObj.gameObject)

		self.exitMaskObj = nil
	end
end

function NpcDuelSystem:setInRematch(inRematch)
	self.isInRematching = inRematch
end

function NpcDuelSystem:isInRematch()
	return ToBool(self.isInRematching)
end

function NpcDuelSystem:npcDuelMaskFadeInStage2()
	if self.maskFadeInStage2Func then
		self.maskFadeInStage2Func()
	end

	self.maskFadeInStage2Func = nil
end

function NpcDuelSystem:npcDuelMaskFadeOut()
	local maskObj = pg.global.uiMgr:SyncInstantiateItem("$VX_Node_BattleRoom_Black_Mask_2.prefab", pg.global.uiMgr.infosLayer)

	TimerManager.addTimer(2, function()
		pg.global.uiMgr:DestroyItem(maskObj.gameObject)
	end)
end

local dialogEnum = {
	DUEL_TIME = 7,
	BOT_PET_ABILITY = 6,
	PLAYER_PET_BUFF = 5,
	BOT_PET_BUFF = 4,
	PLAYER_PET_DIE = 3,
	BOT_PET_DIE = 2,
	BOT_PET_IN = 1,
	N_BOT_PET_DIE = 9,
	ATTRI_CHANGE = 8
}

function NpcDuelSystem:onControlNewPet(info)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	if info and info.ent and Utils.isBotPlayer(info.ent) then
		self:npcDuelPlayDialogInDuel(info.ent, dialogEnum.BOT_PET_IN, info.newPetId)
	end
end

function NpcDuelSystem:onPetDie(info)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	if info and info.entId then
		local ent = pg.getEntity(info.entId)

		if not ent then
			return
		end

		if Utils.isBotPlayer(ent) then
			self:npcDuelPlayDialogInDuel(ent, dialogEnum.BOT_PET_DIE, info.petId)

			self.botPetDieCount = self.botPetDieCount + 1

			self:npcDuelPlayDialogInDuel(ent, dialogEnum.N_BOT_PET_DIE, self.botPetDieCount)
		elseif Utils.isMainPlayer(ent) then
			self:npcDuelPlayDialogInDuel(ent, dialogEnum.PLAYER_PET_DIE, info.petId)
		end
	end
end

function NpcDuelSystem:onBuffAdd(info)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	if info and info.ent then
		if Utils.isBotPet(info.ent) then
			self:npcDuelPlayDialogInDuel(info.ent, dialogEnum.BOT_PET_BUFF, info.buffId)
		elseif Utils.isPlayerPet(info.ent) then
			self:npcDuelPlayDialogInDuel(info.ent, dialogEnum.PLAYER_PET_BUFF, info.buffId)
		end
	end
end

function NpcDuelSystem:onStartAbility(info)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	if info and info.ent and Utils.isBotPet(info.ent) then
		self:npcDuelPlayDialogInDuel(info.ent, dialogEnum.BOT_PET_ABILITY, info.abilityId)
	end
end

function NpcDuelSystem:onDeulPassSecond(time)
	self:npcDuelPlayDialogInDuel(nil, dialogEnum.DUEL_TIME, time)
end

local attrType = {
	bp = 2,
	hp = 1
}

function NpcDuelSystem:onCurBotPetBPChange(info)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	if info and info.entity then
		local curPetEntity = pg.space:getCurNpcDuelBotPetEntity()

		if Utils.isBotPet(info.entity) and curPetEntity and curPetEntity.actorId == info.entity.actorId then
			local percent = 100 - curPetEntity.actorCombatAttribute:getBreakPercent()

			self:npcDuelPlayDialogInDuel(info.entity, dialogEnum.ATTRI_CHANGE, attrType.bp, percent)
		end
	end
end

function NpcDuelSystem:onCurBotPetHPChange(info)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	if info and info.entity then
		local curPetEntity = pg.space:getCurNpcDuelBotPetEntity()

		if Utils.isBotPet(info.entity) and curPetEntity and curPetEntity.actorId == info.entity.actorId then
			local percent = curPetEntity.actorCombatAttribute:getHpPercent()

			self:npcDuelPlayDialogInDuel(info.entity, dialogEnum.ATTRI_CHANGE, attrType.hp, percent)
		end
	end
end

function NpcDuelSystem:npcDuelPlayDialogInDuel(ent, dialogType, arg1, arg2)
	if not pg.space or not pg.space:isNpcDuel() then
		return
	end

	local dialogueId, dialogCd, dialogTimesLimit = self:getDialogConfig(ent, dialogType, arg1, arg2)

	if dialogueId and self:checkDialogCanPlay(dialogueId, dialogCd, dialogTimesLimit) then
		self:recordDialog(dialogueId)
		ClientUtils.showDialog(dialogueId, pg.me.id, {
			chatType = DialogueConst.ChatType.TELECALL
		})
	end
end

function NpcDuelSystem:getDialogConfig(ent, dialogType, arg1, arg2)
	local npcDuelData = NpcDuelData[pg.me.curNpcDuelId] and NpcDuelData[pg.me.curNpcDuelId][pg.me.curNpcDuelVariantId]

	if not npcDuelData then
		return
	end

	local config

	if dialogType == dialogEnum.BOT_PET_IN then
		local petIndex = self:getPetIndexByPetId(ent, arg1)

		config = self:getDialogConfigFromConfig(npcDuelData.npcPetAppearDialogue, petIndex)
	elseif dialogType == dialogEnum.BOT_PET_DIE then
		local petIndex = self:getPetIndexByPetId(ent, arg1)

		config = self:getDialogConfigFromConfig(npcDuelData.npcPetBeKilledDialogue, petIndex)
	elseif dialogType == dialogEnum.PLAYER_PET_DIE then
		local petIndex = self:getPetIndexByPetId(ent, arg1)

		config = self:getDialogConfigFromConfig(npcDuelData.playerPetBeKilledDialogue, petIndex)
	elseif dialogType == dialogEnum.BOT_PET_BUFF then
		config = self:getDialogConfigFromConfig(npcDuelData.npcPetGetBuffDialogue, arg1)
	elseif dialogType == dialogEnum.PLAYER_PET_BUFF then
		config = self:getDialogConfigFromConfig(npcDuelData.playerPetGetBuffDialogue, arg1)
	elseif dialogType == dialogEnum.BOT_PET_ABILITY then
		config = self:getDialogConfigFromConfig(npcDuelData.npcPetCastSkillDialogue, arg1)
	elseif dialogType == dialogEnum.DUEL_TIME then
		config = self:getDialogConfigFromConfig(npcDuelData.battleDurationDialogue, arg1)
	elseif dialogType == dialogEnum.ATTRI_CHANGE then
		config = self:getDialogConfigFromConfig_AttriChange(npcDuelData.npcPetCurAttrMeetCondDialogue, arg1, arg2)

		if config then
			return config[4], config[5], config[6]
		end
	elseif dialogType == dialogEnum.N_BOT_PET_DIE then
		config = self:getDialogConfigFromConfig(npcDuelData.npcPetBeKilledIndexDialogue, arg1)
	end

	if not config then
		return
	end

	return config[2], config[3], config[4]
end

function NpcDuelSystem:getDialogConfigFromConfig(list, key)
	if not list then
		return
	end

	local default, result

	for _, v in ipairs(list) do
		if v[1] == 0 then
			default = v
		end

		if v[1] == key then
			result = v
		end
	end

	return result or default
end

function NpcDuelSystem:getDialogConfigFromConfig_AttriChange(list, attrType, curAttrPer)
	if not list then
		return
	end

	local result

	for _, v in ipairs(list) do
		local op = v[2]
		local per = v[3]

		if v[1] == attrType then
			if op == 1 and per < curAttrPer then
				result = v

				break
			elseif op == 2 and curAttrPer <= per then
				result = v

				break
			end
		end
	end

	return result
end

function NpcDuelSystem:getPetIndexByPetId(ent, petId)
	if not ent or not petId or not ent.petPrepareList then
		return
	end

	for index, id in ipairs(ent.petPrepareList) do
		if id == petId then
			return index
		end
	end
end

function NpcDuelSystem:checkDialogCanPlay(dialogId, dialogCd, dialogTimesLimit)
	self.dialogRecord = self.dialogRecord or {}
	dialogCd = dialogCd or 0
	dialogTimesLimit = dialogTimesLimit or 1

	local dialogRecord = self.dialogRecord[dialogId]

	if not dialogRecord then
		return true
	end

	if dialogTimesLimit > 0 and dialogTimesLimit <= dialogRecord.playTimes then
		return false
	end

	if dialogCd > 0 and dialogCd > Time.realSecondCache - dialogRecord.lastPlayTime then
		return false
	end

	return true
end

function NpcDuelSystem:recordDialog(dialogId)
	self.dialogRecord = self.dialogRecord or {}

	local dialogRecord = self.dialogRecord[dialogId]

	if not dialogRecord then
		dialogRecord = {
			playTimes = 0
		}
		self.dialogRecord[dialogId] = dialogRecord
	end

	dialogRecord.lastPlayTime = Time.realSecondCache
	dialogRecord.playTimes = dialogRecord.playTimes + 1
end

function NpcDuelSystem:clearDialogRecored()
	self.dialogRecord = {}
	self.botPetDieCount = 0
end

function NpcDuelSystem:npcDuelStartFallback()
	self:clearNpcDuelStartFallbackTimer()
	logger:info("npcDuelStartFallback timer start")

	self.checkStartFallbackTimer = TimerManager.addTimer(NPC_DUEL_START_FALLBACK_TIMEOUT, function()
		if pg.space and pg.space:isNpcDuel() then
			local isSceneValid = pg.global and pg.global.scene and pg.global.scene:isSceneValid()
			local isBotReady = pg.space.isBotReady and pg.space:isBotReady()
			local isReady = pg.me and pg.me.space and pg.me.space:isNpcDuel() and isSceneValid and isBotReady

			if isReady then
				logger:info("NpcDuel超时检查时场景已就绪，跳过强制退出")
			else
				if pg.global and pg.global.ui then
					pg.global.ui:close(UIConst.UI_ID_NPC_DUEL_START)
				end

				if pg.me then
					pg.me:serverMsg("RPC_CS_NpcDuelExit")
				end

				logger:error("强制退出NpcDuel，进入对决未成功-已进入场景，错误代码=%s", tostring(pg.space.faultId))
			end
		else
			logger:error("进入NpcDuel超时-未进入场景")
		end

		self:clearNpcDuelStartFallbackTimer()
	end)
end

function NpcDuelSystem:clearNpcDuelStartFallbackTimer()
	logger:info("clearNpcDuelStartFallbackTimer")

	if self.checkStartFallbackTimer then
		TimerManager.removeTimer(self.checkStartFallbackTimer)

		self.checkStartFallbackTimer = nil
	end
end

function NpcDuelSystem:clearRematchFadeInTimer()
	if self.rematchFadeInTimer then
		self:killTimer(self.rematchFadeInTimer)

		self.rematchFadeInTimer = nil
	end
end

function NpcDuelSystem:clearRematchFallbackTimer()
	if self.rematchFallbackTimer then
		self:killTimer(self.rematchFallbackTimer)

		self.rematchFallbackTimer = nil
	end
end

function NpcDuelSystem:startRematchFallbackTimer()
	self:clearRematchFallbackTimer()

	local fallbackTime = 45

	self.rematchFallbackTimer = self:startTimer(function()
		self.rematchFallbackTimer = nil

		logger:warn("NpcDuelRematch 场景就绪超时，兜底关闭黑幕")
		self:onRematchFadeOut()
	end, fallbackTime, false)
end

function NpcDuelSystem:onRematchFadeIn(cb)
	local fadeTime = 0.5

	self:clearRematchFadeInTimer()

	local backScreenID = 177

	pg.global.ui:open(UIConst.UI_ID_BLACK_SCREEN, {
		autoCloseByConfig = false,
		notAutoCloseOnSceneLoaded = true,
		id = backScreenID,
		inTime = fadeTime,
		outTime = fadeTime
	})
	self:startRematchFallbackTimer()

	self.rematchFadeInTimer = self:startTimer(function()
		self.rematchFadeInTimer = nil

		if not pg.space or not pg.space:isNpcDuel() then
			self:onRematchFadeOut()

			return
		end

		if cb then
			cb()
		end
	end, fadeTime + 0.1, false)
end

function NpcDuelSystem:onRematchFadeOut()
	self:clearRematchFadeInTimer()
	self:clearRematchFallbackTimer()
	self:setInRematch(false)

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BLACK_SCREEN) and pg.global.ui.blackScreen then
		pg.global.ui.blackScreen:startCloseScreen()
	end
end

function NpcDuelSystem:getNpcDuelLevelByGlobalId(globalId)
	if not globalId then
		return 0
	end

	local entity = pg.getEntityByGlobalId(globalId)

	if not entity then
		return 0
	end

	local configData = entity:getConfigData()

	if not configData or not configData.npcDuelId then
		return 0
	end

	local variantId = pg.me and pg.me.npcDuelBasicInfo and pg.me.npcDuelBasicInfo.variantIdMap and pg.me.npcDuelBasicInfo.variantIdMap[configData.npcDuelId]

	variantId = variantId or 1

	return self:getNpcDuelLevelByDuelId(configData.npcDuelId, variantId)
end

function NpcDuelSystem:getNpcDuelLevelByDuelId(npcDuelId, variantId)
	local npcDuelData = NpcDuelData[npcDuelId] and NpcDuelData[npcDuelId][variantId]

	if not npcDuelData or not npcDuelData.npcBotPlayerId then
		return 0
	end

	local robotData = RealAvatarRobotData[npcDuelData.npcBotPlayerId]

	if not robotData or not robotData.level then
		return npcDuelData.recommendedLevel
	end

	local playerBotLv = robotData.level
	local detalLv = NpcDuelSharedUtils:calcNpcDuelLevelDeltaByDuelId(pg.me, npcDuelId, variantId, playerBotLv)
	local botLevel = NpcDuelSharedUtils:clampNpcDuelBotLevel(playerBotLv + detalLv)

	return botLevel
end

return NpcDuelSystem
