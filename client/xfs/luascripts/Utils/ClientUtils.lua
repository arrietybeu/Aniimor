-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local GlobalData = require("Core.Client.GlobalData")
local EntityFactory = require("Core.Common.EntityFactory")
local sceneData = require("Data.scene_data")
local mapOverlapScene = require("Data.map_overlap_scene")
local SysNoticeData = require("Data.sys_notice_data")
local LimitData = require("Data.limit_data")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local logger = LoggerManager.getLogger("ClientUtils")
local unpackValues = table.unpack or unpack
local ControllerData = CS.FunPlus.WorldX.ControllerData

local function clientCacheVerifyLog(...)
	local values = {
		n = select("#", ...),
		...
	}

	values.n = values.n + 1
	values[values.n] = "stack"
	values.n = values.n + 1
	values[values.n] = debug.traceback()
end

local CommonRepo = require("Core.Common.CommonRepo")
local Const = require("Common.Const.Const")
local QuestConst = require("Common.Const.QuestConst")
local AbilityConst = require("Common.Const.AbilityConst")
local PetResearchData = require("Data.pet_research_content_data")
local PetData = require("Data.pet_data")
local PuppetData = require("Data.puppet_data")
local PetBasePrototypeToPrototype = require("Data.pet_base_prototype_to_prototype_map")
local ECSConst = require("Const.ECSConst")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local LxGeometry = require("Common.Ability.LxGeometry")
local EntityManager = require("Core.Common.EntityManager")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local VoxelConst = require("Common.Const.VoxelConst")
local ClientRepo = require("Core.Client.ClientRepo")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local ClientConst = require("Const.ClientConst")
local PSServerConst = require("Const.PSServerConst")
local HotkeyConst = require("Const.HotkeyConst")
local DialogueConst = require("Const.DialogueConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Entity = require("Core.Common.Entity")
local effectData = require("Data.effect_data")
local RigidbodyData = require("Data.rigidbody_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local UIConst = require("Const.UIConst")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local ClientSwitch = require("Common.ClientSwitch")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local Bitset = require("Common.Bitset")
local RandomMapBatchUtils = require("Common.Utils.RandomMapBatchUtils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local ConflictTypes = require("Common.ConflictTypes")
local PhotoIdentifyData = require("Data.photo_identify_data")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local AvatarHairResIdToConfig = require("Data.avatar_hair_resId_to_config")
local CurrencyConsumeData = require("Data.currency_consume_data")
local ItemData = require("Data.item_data")
local InteractData = require("Data.interact_data")
local CommonSwitch = require("Common.CommonSwitch")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local BossMechanismTipData = require("Data.boss_mechanism_tip_data")
local Lume = require("Core.Common.lume")
local TimerManager = require("Core.Timer.TimerManager")
local HomeCampData = require("Data.home_camp_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local SceneSeamlessData = require("Data.scene_seamless_data")
local AttributeConst = require("Common.Const.AttributeConst")
local json = require("json")
local TopLogoConst = require("Const.TopLogoConst")
local NpcHideShowConfigData = require("Data.npc_hide_show_config_data")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local csXCloudPipeController = CS.FunPlus.WorldX.SDK.XCloudPipeController
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local mapFogManager = CS.FunPlus.WorldX.GameApp.UIMap.MapFogManager
local EventConst = require("Const.EventConst")
local unpack = unpack
local ClientUtils = {}
local pg = pg
local Vector3 = Vector3
local invokeCooldowns = {}

local function entityDestroy(ent, immediate)
	if ent.destroyed or ent._isDestroyingEntity then
		return
	end

	local preDestroyFunc = ent.preDestroy

	ent._isDestroyingEntity = true

	if ent.isFadeOut and not immediate then
		TimerManager.addTimer(3, function()
			if not ent or ent.destroyed then
				return
			end

			ent:destroy()
		end)

		if preDestroyFunc then
			preDestroyFunc(ent)
		end
	else
		if preDestroyFunc then
			preDestroyFunc(ent)
		end

		ent:destroy()
	end
end

local function clearAIObjectPools()
	local loaded = package.loaded
	local agentMeta = loaded["Common.AI.Behaviac.Agent.AgentMeta"]

	if agentMeta and agentMeta.clearInstance then
		agentMeta.clearInstance()
	end

	local baseAgent = loaded["Common.AI.Behaviac.Agent.BaseAgent"]

	if baseAgent and baseAgent.clearAllTreeTickPool then
		baseAgent.clearAllTreeTickPool()
	end

	local ctUtils = loaded["Common.AI.ConditionTrigger.CTUtils"]

	if ctUtils and ctUtils.ClearFlowPool then
		ctUtils.ClearFlowPool()
	end

	local planPool = loaded["Common.AI.BehaviacAgent.Unit.Plan.PlanPool"]

	if planPool and planPool.clear then
		planPool.clear()
	end
end

function ClientUtils.safeDestroy(ent, immediate)
	local exceptionError
	local st, err = xpcall(entityDestroy, debug.traceback, ent, immediate)

	if not st then
		exceptionError = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s safeDestroy failed, %s", ent:repr(), exceptionError)
		end
	end

	if exceptionError ~= nil and ent ~= nil then
		if ent.isMainPlayer then
			for entityId, _ in pairs(ent.entities) do
				local localEnt = EntityManager.getEntity(entityId)

				if localEnt then
					ClientUtils.safeDestroy(localEnt)
				end
			end

			pg.game:onPlayerDestroy(ent)
		end

		if not ent.destroyed then
			Entity.destroy(ent)
		end
	end
end

function ClientUtils.entityInitCall(ent, entityContent)
	ent:preInit(entityContent)
	ent:init(entityContent)
	ent:postInit(entityContent)
	ent:start()
end

local function _entityInitCall(ent, entityContent)
	ClientUtils.entityInitCall(ent, entityContent)

	if ent.enterSpace ~= nil and ent.space == nil then
		ent:enterSpace(pg.space)
	end

	ClientUtils.onClientEntityCreated(ent)
end

function ClientUtils.createClientEntity(entityType, entityId, entityContent)
	local ent = EntityFactory.createEntity(entityType, entityId)
	local exceptionError
	local st, err = xpcall(_entityInitCall, debug.traceback, ent, entityContent)

	if not st then
		exceptionError = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s %s createEntityLocally init failed, %s %s", entityId, entityType, exceptionError)
		end
	end

	if exceptionError ~= nil and ent ~= nil then
		ClientUtils.safeDestroy(ent)

		ent = nil
	end

	return ent
end

function ClientUtils.replaceClientEntity(clientEntity, entityId, entityContent)
	clientEntity.replaceNeedRebindEModel = true

	if clientEntity.id ~= entityId then
		EntityManager.removeEntity(clientEntity.id)

		clientEntity.id = entityId

		EntityManager.addEntity(entityId, clientEntity)
	end

	local exceptionError
	local st, err = xpcall(function()
		ClientUtils.entityInitCall(clientEntity, entityContent)

		if clientEntity.enterSpace ~= nil then
			clientEntity:enterSpace(pg.space)
		end

		if clientEntity.setInScene ~= nil then
			clientEntity:setInScene(true)
		end
	end, debug.traceback)

	if not st then
		exceptionError = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s createEntityLocally init failed, %s", entityId, exceptionError)
		end
	end

	if exceptionError ~= nil and clientEntity ~= nil then
		ClientUtils.safeDestroy(clientEntity)

		clientEntity = nil
	end

	return clientEntity
end

function ClientUtils.onClientEntityCreated(ent)
	if Utils.isBotPlayer(ent) then
		ent:serverMsg("RPC_CS_BotPlayerCreated")
	end

	pg.game:onEntityCreated(ent)
end

function ClientUtils.getSceneName(sceneId)
	if not sceneId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("getSceneName error !!! scene Id is nil ", debug.traceback())
		end

		return
	end

	local sceneInfo = sceneData[sceneId]

	if not sceneInfo then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(" getSceneName error !!! SceneId not configed", sceneId)
		end

		return
	end

	local sceneName = sceneInfo.file

	if not sceneName then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("getSceneName error !!! SceneFile is nil", sceneId)
		end

		return
	end

	return sceneName
end

function ClientUtils.isStreamScene(sceneId)
	if not sceneId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("getSceneName error !!! scene Id is nil ", debug.traceback())
		end

		return
	end

	local sceneInfo = sceneData[sceneId]

	if not sceneInfo then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(" getSceneName error !!! SceneId not configed", sceneId)
		end

		return
	end

	return ToBool(sceneInfo.isStream)
end

function ClientUtils.getSceneFarPlane(sceneId)
	local CameraConst = require("GameApp.Camera.CameraConst")

	if not sceneId then
		return CameraConst.DEFAULT_FAR_PLANE
	end

	local sceneInfo = sceneData[sceneId]

	if not sceneInfo or not sceneInfo.cameraFarPlane then
		return CameraConst.DEFAULT_FAR_PLANE
	end

	return math.min(sceneInfo.cameraFarPlane, CameraConst.DEFAULT_FAR_PLANE)
end

function ClientUtils.tryWithLogError(func)
	local ok, errors = xpcall(func, debug.traceback)

	if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(errors)
	end

	return ok, errors
end

function ClientUtils.openPictureOnEditor()
	local netHandler = ClientRepo.netHandler

	if netHandler ~= nil then
		netHandler:pauseHeartbeatTimeout()
	end

	local success, errorMessage = xpcall(function()
		pg.global.mobileCameraMgr:OpenPictureOnEditor()
	end, debug.traceback)

	if netHandler ~= nil then
		netHandler:resumeHeartbeatTimeout()
	end

	if not success then
		error(errorMessage)
	end
end

function ClientUtils.tryWithLogErrorEx(func, ...)
	local ok, errors = xpcall(func, debug.traceback, ...)

	if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(errors)
	end

	return ok, errors
end

function ClientUtils.showBubbleMessage(noticeId, ...)
	if noticeId == NoticeDef.ERROR_IN_COOLDOWN then
		pg.global.showBubbleMessageRaw(pg.getGameString("OPERATE_TOO_MANY"))

		return
	end

	local msgData = SysNoticeData[noticeId]
	local paramList = {
		...
	}
	local newParamList = {}

	for i, param in ipairs(paramList) do
		newParamList[#newParamList + 1] = pg.getLocalizationText(param)
	end

	if msgData then
		local desc = msgData.text

		desc = pg.getLocalizationText(msgData.text, unpack(newParamList))

		ClientUtils.showBubbleMessageRaw(desc, msgData.stay, msgData.tipStyle, nil, nil, nil, nil, msgData.delete)
	else
		local noticeStr = string.format("notice:%s", NoticeDef.getRepr(noticeId, paramList))

		if pg.game.setting:getShowDebugId() then
			ClientUtils.showBubbleMessageRaw(noticeStr, 3, nil)
		end

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("receive notice, but no config: %s", noticeStr)
		end

		return
	end
end

function ClientUtils.showBubbleMessageRaw(message, duration, tipStyle, outLineDesc, bigIcon, normalIcon, label, delete)
	pg.global.ui.tips:showTextTip(message, duration, tipStyle, outLineDesc, bigIcon, normalIcon, label, nil, delete)
end

function ClientUtils.showRewardLimitToast(limitId)
	local limitConfig = LimitData[limitId]

	if not limitConfig then
		return
	end

	local limitTypeTextId = Utils.getRewardLimitTypeTextId(limitConfig.type)

	if not limitTypeTextId then
		return
	end

	local limitTypeText = pg.getLocalizationText(limitTypeTextId)

	if not limitConfig.toast then
		ClientUtils.showBubbleMessageById(NoticeDef.ITEM_REWARD_LIMITED, limitTypeText)

		return
	end

	local toastText = pg.getLocalizationText(limitConfig.toast, limitTypeText)

	ClientUtils.showBubbleMessageRaw(toastText)
end

function ClientUtils.showBubbleMessageById(noticeId, ...)
	pg.global.ui.tips:showTextTipById(noticeId, ...)
end

function ClientUtils.getInteractActCooldown(interactConfigId)
	if not ToBool(interactConfigId) then
		return 0
	end

	local cfg = InteractData[interactConfigId]
	local cd = cfg and cfg.actCooldown or 0

	if cd == nil then
		return 0
	end

	return cd
end

function ClientUtils.hideBubbleMessageById(noticeId)
	pg.global.ui.tips:hideTextTipById(noticeId)
end

function ClientUtils.showDialog(dialogId, ...)
	pg.game.communication:startNpcDialog(dialogId, ...)
end

function ClientUtils.closeDialog()
	pg.game.communication:finishNpcDialog()
end

function ClientUtils.escape()
	local player = pg.me

	if player then
		player:serverMsg("RPC_CS_ResetPosition")
	end
end

function ClientUtils.getSysNoticeStr(noticeId, ...)
	local msgData = SysNoticeData[noticeId]

	if msgData then
		local desc = msgData.text
		local paramList = {
			...
		}
		local newParamList = {}

		for i, param in ipairs(paramList) do
			newParamList[#newParamList + 1] = pg.getLocalizationText(param)
		end

		desc = pg.getLocalizationText(msgData.text, unpack(newParamList))

		return desc
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("getSysNoticeStr failed: no such message key: " .. noticeId)
	end
end

function ClientUtils.showUI(uid, params, uiCloseCb)
	local info = params and params ~= "" and params or {}

	if params and params ~= "" and type(params) == "string" then
		info = string.split(params, ",")

		if uid == UIConst.UI_ID_SHOP_MAIN then
			local tags = {}

			for _, tag in ipairs(params) do
				table.insert(tags, tonumber(tag))
			end

			info = {
				shopTags = tags
			}
		end
	end

	pg.global.ui:open(uid, info, nil, uiCloseCb)
end

function ClientUtils.closeUI(uid)
	pg.global.ui:close(uid)
end

function ClientUtils.setVolumeEffectState(active, volumeId)
	if active then
		pg.game.camera:addVolumeEffect(volumeId)
	else
		pg.game.camera:delVolumeEffect(volumeId)
	end
end

function ClientUtils.setHudUIEffectState(active, param)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HUD_V2) and pg.global.ui.hudV2 then
		pg.global.ui.hudV2:setHudUIEffectState(active, param)
	end
end

function ClientUtils.showStaminaAddFx()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HUD_V2) and pg.global.ui.hudV2 then
		pg.global.ui.hudV2:showStaminaAddFx()
	end

	if pg.global.ui.topLogo and pg.global.ui.topLogo.m_getPlayerHubComponent then
		local hub = pg.global.ui.topLogo:m_getPlayerHubComponent()

		if hub then
			hub:showEnduranceAddFx()
		end
	end
end

function ClientUtils.showBattleUICountDown(time, useGameTime, type_, textKey, loopTime)
	local param = {
		useGameTime = useGameTime,
		type = type_,
		textKey = textKey,
		loopTime = loopTime
	}

	if pg.space and pg.space:isRogueEnv() then
		param.saveStartTime = Time.secondCache
		param.saveDuration = time

		local paramStr = json.encode(param)

		pg.global.prefsCacheUtils:setString(ClientConst.PrefKey.RogueBattleCountDown, paramStr)
	end

	pg.global.ui.tips:showTimeViolentCountDown(time, nil, param)
end

function ClientUtils.hideBattleUICountDown()
	pg.global.ui.tips:hideTimeViolentCountDown()

	if pg.space and pg.space:isRogueEnv() then
		pg.global.prefsCacheUtils:deleteKey(ClientConst.PrefKey.RogueBattleCountDown)
	end
end

function ClientUtils.showBossMechanismTip(tipId, duration, hasCountDown)
	local tipData = BossMechanismTipData[tipId]

	if not tipData then
		return
	end

	if duration == nil or duration <= 0 then
		duration = tipData.stay
	end

	local needCountDown = hasCountDown or ToBool(tipData.countDown)

	if needCountDown then
		local countDownBeginTime = tipData.beginTime or 0
		local countDownDuration = tipData.stayTime or 0

		pg.global.ui.tips:showA2Tips({
			id = "BossMechanismProgress",
			uniqueId = tipId,
			text = tipData.text,
			countDownBeginTime = countDownBeginTime,
			countDownDuration = countDownDuration,
			duration = duration
		})
	else
		pg.global.ui.tips:showA2Tips({
			id = "BossMechanismTips",
			uniqueId = tipId,
			text = tipData.text,
			duration = duration
		})
	end
end

function ClientUtils.hideBossMechanismTip(tipId, hasCountDown)
	local tipData = BossMechanismTipData[tipId]

	if not tipData then
		return
	end

	local needCountDown = hasCountDown or ToBool(tipData.countDown)

	if needCountDown then
		pg.global.ui.tips:hideA2Tips("BossMechanismProgress", tipId)
	else
		pg.global.ui.tips:hideA2Tips("BossMechanismTips", tipId)
	end
end

function ClientUtils.showUICountDown(time, useGameTime)
	pg.global.ui.tips:showCountDown(time, nil, {
		useGameTime = useGameTime
	})
end

function ClientUtils.hideUICountDown()
	pg.global.ui.tips:hideCountDown()
end

function ClientUtils.showUICountDownWithId(time, id, useGameTime)
	pg.global.ui.tips:showCountDown(time, id, {
		useGameTime = useGameTime
	})
end

function ClientUtils.hideUICountDownWithId(id)
	pg.global.ui.tips:hideCountDown(id)
end

function ClientUtils.showConfirm(titleId, descId, okCb, hideCancel, cancelCb, titleArgs, descArgs, showNextBtn, nextBtnCb, extraInfo)
	local descData = SysNoticeData[descId]

	if descData then
		local desc = descData.text

		if descData.text and titleArgs then
			desc = string.format(descData.text, table.unpack(titleArgs))
		end

		local titleData = SysNoticeData[titleId]
		local title

		if titleData then
			title = titleData.text

			if titleData.text and descArgs then
				title = string.format(titleData.text, table.unpack(descArgs))
			end
		else
			title = pg.getGameString("RELEASE_WARN")
		end

		ClientUtils.showConfirmRaw(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("showConfirm failed: no such message key: " .. descId)
	end
end

function ClientUtils.showConfirmRaw(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
	pg.global.ui.commonConfirm:open({
		title = title,
		desc = desc,
		okCb = okCb,
		hideCancel = hideCancel,
		cancelCb = cancelCb,
		showNextBtn = showNextBtn,
		nextBtnCb = nextBtnCb,
		extraInfo = extraInfo
	})
end

function ClientUtils.showConfirmByConfig(config)
	if config == nil then
		logger:error("showConfirmByConfig failed: config is nil")

		return
	end

	config.UseConfig = true

	pg.global.ui.commonConfirm:open(config)
end

function ClientUtils.showConfirmRawTicking(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo, tickFunc, tickInterval)
	pg.global.ui.commonConfirm:open({
		title = title,
		desc = desc,
		okCb = okCb,
		hideCancel = hideCancel,
		cancelCb = cancelCb,
		showNextBtn = showNextBtn,
		nextBtnCb = nextBtnCb,
		extraInfo = extraInfo,
		tickFunc = tickFunc,
		tickInterval = tickInterval
	})
end

function ClientUtils.showCommonTipUse(title, tipTop, data, confirmCb, cancelCb, muteCheckEnough, type, extra)
	pg.global.ui.commonUseConfirm:open({
		title = title,
		tipTop = tipTop,
		data = data,
		confirmCb = confirmCb,
		cancelCb = cancelCb,
		muteCheckEnough = muteCheckEnough,
		type = type,
		extra = extra
	})
end

function ClientUtils.refreshCodeAndData()
	ClientUtils.reloadRecentFiles()
end

function ClientUtils.reloadFile(filePath, reloadType)
	local ReloadFilter = require("Common.ReloadFilter")
	local currentPath = LUA_ROOT_PATH
	local relativePath = filePath
	local prefix = string.format("%s/", currentPath)

	if string.sub(relativePath, 1, string.len(prefix)) == prefix then
		relativePath = string.sub(relativePath, string.len(prefix) + 1)
	end

	if string.sub(relativePath, -4) ~= ".lua" then
		relativePath = relativePath .. ".lua"
	end

	for _, rule in pairs(ReloadFilter.ignoreModules) do
		if string.find(relativePath, rule) then
			logger:warn("reloadFile: %s matches ignore rule '%s', skipping", relativePath, rule)

			return
		end
	end

	logger:info("reloadFile: %s", relativePath)
	CommonRepo.reloadScheduler:startReload(reloadType or "single", {
		relativePath
	}, ReloadFilter.impFiles, ReloadFilter.deleteKeyModels, false)
end

function ClientUtils.reloadRecentFiles()
	CommonRepo.reloadScheduler:reloadRecentFiles()
end

function ClientUtils.getItemCountById(itemId, includeLocked)
	if pg.me == nil then
		return 0
	end

	if ClientUtils.isInDouYinOfflineScene() then
		local ClientOfflineCaptureComponent = require("Entities.SpaceEntities.PlayerComponent.ClientOfflineCaptureComponent")

		return ClientOfflineCaptureComponent.getOfflineBallCount(itemId)
	end

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) and ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_BALL then
		return pg.me.catchRogueInfo:getValidBallCount(pg.me, itemId)
	else
		return pg.me:getItemCountById(itemId, includeLocked)
	end
end

function ClientUtils.getHomelandItemCountById(itemId)
	if not pg.me.space or not pg.me.space:isHomeland() then
		return 0
	end

	return pg.me.space.itemMap[itemId] or 0
end

function ClientUtils.checkItemEnough(itemId, itemCount)
	if pg.me == nil then
		return false
	end

	return itemCount <= pg.me:getItemCountById(itemId, true)
end

function ClientUtils.checkIsNewPok(templateId)
	if not PetResearchData[templateId] then
		return false
	end

	local player = pg.me
	local playerHandBookMap = player.petHandbookMap
	local playerData = playerHandBookMap[templateId]

	if playerData then
		return not playerData:isCatched()
	end

	return true
end

function ClientUtils.checkIsNewKnowPuppet(entity)
	if not entity or not Utils.isPuppet(entity) then
		return false
	end

	local player = pg.me

	if not player then
		return false
	end

	local playerHandBookMap = player.petHandbookMap or {}
	local configData = entity:getConfigData() or {}
	local petHandbookInfo = playerHandBookMap[configData.petPrototypeId]

	if petHandbookInfo then
		return not petHandbookInfo:isCatched() and not petHandbookInfo:isKnown()
	end

	return true
end

function ClientUtils.checkIsCatched(entity)
	if not entity or not Utils.isPuppet(entity) then
		return false
	end

	local player = pg.me

	if not player then
		return false
	end

	local playerHandBookMap = player.petHandbookMap or {}
	local configData = entity:getConfigData() or {}
	local petHandbookInfo = playerHandBookMap[configData.petPrototypeId]

	if petHandbookInfo then
		return petHandbookInfo:isCatched()
	end

	return false
end

function ClientUtils.checkPhotoTraitIsUnlock(photoId)
	local event = PhotoIdentifyData[photoId].event

	if event == "petTraitStateSet" then
		local eventArg = PhotoIdentifyData[photoId].eventArg
		local petPrototypeId = eventArg[1]
		local traitId = eventArg[2]

		return ClientUtils.checkPetTraitExist(petPrototypeId, traitId) and ClientUtils.checkPetTraitIsUnlock(petPrototypeId, traitId)
	end

	return false
end

function ClientUtils.checkPhotoPetIsUnlock(photoId)
	local event = PhotoIdentifyData[photoId].event

	if event == "petTraitStateSet" then
		local matchEntities = PhotoIdentifyData[photoId].matchEntities

		if matchEntities and matchEntities[1] then
			local matchInfo = matchEntities[1]
			local basePetId = matchInfo[1]
			local petPrototypeIds = PetBasePrototypeToPrototype[basePetId] or {}

			for _, petPrototypeId in ipairs(petPrototypeIds) do
				local petHandbookInfo = pg.me.petHandbookMap[petPrototypeId]

				if petHandbookInfo and petHandbookInfo:isCatched() then
					return true
				end
			end
		end

		return false
	end

	return true
end

function ClientUtils.isInGuide()
	if pg and pg.game and pg.game.guide then
		return pg.game.guide:isInGuide()
	end

	return false
end

function ClientUtils.canHotSwitchPlatform()
	local me = pg.me

	if not me then
		return true
	end

	if me.ABILITY_ST and me:ABILITY_ST() or me.SKILL_AIM_ST and me:SKILL_AIM_ST() or me.isInCatchMode and me:isInCatchMode() or me.isThrowItem and me:isThrowItem() or me.isInMagnesisMode and me:isInMagnesisMode() or me.isInBossCatch and me:isInBossCatch() or me.CLIMB_ST and me:CLIMB_ST() or me.GLIDE_ST and me:GLIDE_ST() or me.SWIM_ST and me:SWIM_ST() or me.FLY_ST and me:FLY_ST() or me.EXPLORE_SWITCH_ST and me:EXPLORE_SWITCH_ST() or me.SCENT_TRACKING_ST and me:SCENT_TRACKING_ST() then
		return false
	end

	local pawn = pg.pawn
	local eModel = pawn and pawn.eModel

	if eModel and eModel.CharacterControllerIsFloating then
		return false
	end

	return true
end

function ClientUtils.checkPetTraitExist(petProtoTypeId, traitId)
	local petHandbookInfo = pg.me.petHandbookMap[petProtoTypeId]

	if petHandbookInfo then
		local traitInfo = petHandbookInfo:getTraitResearchInfoWithDefault(traitId)

		return traitInfo ~= nil
	end

	return false
end

function ClientUtils.checkPetTraitIsUnlock(petProtoTypeId, traitId)
	local petHandbookInfo = pg.me.petHandbookMap[petProtoTypeId]

	if petHandbookInfo then
		local traitState = petHandbookInfo:getTraitResearchInfoWithDefault(traitId).status

		return traitState == Const.PET_RESEARCH.STATUS_DONE
	end

	return false
end

function ClientUtils.checkPetIsFollowPet(petId)
	local petPrepareInfoList = pg.me.petPrepareList

	for idx, pId in pairs(petPrepareInfoList) do
		if pId == petId then
			return true, idx
		end
	end

	return false, nil
end

function ClientUtils.checkCreateUser(presetKey)
	if not ClientSwitch.OpenCreateUserProcess then
		ClientRepo.loginAgent:loginImp()

		return
	end

	ClientUtils.openAvatarProcess(false, presetKey)
end

function ClientUtils.doPreloadCreateRoleCutScene()
	do return end

	print("@fjs ClientUtils.doPreloadCreateRoleCutScene")

	local cutsceneItem = pg.game.cutscene:getCurCutScene()
	local cutsceneName = "CREATE_PLAYER"

	if cutsceneItem and cutsceneItem.name == cutsceneName then
		return
	end

	local AddressDataConst = require("Const.AddressDataConst")

	cutsceneItem = pg.game.cutscene:createCutscene(cutsceneName, AddressDataConst.CREATE_USER_ADDITION_RES, Vector3.zero, nil, {})

	cutsceneItem:preloadAsync(function()
		cutsceneItem.cutscene.prefabRoot.gameObject:SetActiveEx(false)

		local DefaultSceneConst = require("Common.Const.DefaultSceneConst")

		pg.global.scene:loadAdditiveScene(DefaultSceneConst.CREATE_PLAYER_ADDITIVE_SCENE_ID)
	end)
end

function ClientUtils.openAvatarProcess(bPreload, presetKey, readyCallback)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN) then
		pg.global.ui.login:switchLoginState(false)

		pg.global.ui.login.downHaveShowConfirm = true
	end

	local luaCSConst = require("Common.Const.LuaCSConst")
	local clientXPartUtil = require("Utils.ClientXPartUtil")
	local arg = {
		ToScene = 0,
		KeyFrom = luaCSConst.XPartConst.KeyLogin2Role
	}

	local function cbFunc()
		if readyCallback then
			clientXPartUtil._setWaitMode(-1)
			readyCallback()

			return
		end

		ClientUtils._callOpenAvatarProcess(bPreload, presetKey)
	end

	clientXPartUtil.hookAvatarOpenAvatarProcess(arg, cbFunc)
end

function ClientUtils._callOpenAvatarProcess(bPreload, presetKey)
	local clientXPartUtil = require("Utils.ClientXPartUtil")

	clientXPartUtil._setWaitMode(-1)
	pg.global.ui.avatarLoading:close()
	pg.global.eventEmitter:emit(EventConst.GAMEFLOW_CHANGE, "null", "EnterRole", {})
	clientXPartUtil.startDownPartNovice(1, 1)
	csSDKManager.PatchFlowSDKLog(20010, "LoginCreateRole", "", "")

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	if not AvatarUtils.hasCustomDataInDisk() then
		local createRoleTimeline = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_CREATE_ROLE_TIMELINE)

		if createRoleTimeline and createRoleTimeline:checkUIOpen() then
			createRoleTimeline:showPreparedTimeline(presetKey)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_CREATE_ROLE_TIMELINE, {
			forcePresetKey = presetKey
		}, function()
			createRoleTimeline = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_CREATE_ROLE_TIMELINE)

			if createRoleTimeline then
				createRoleTimeline:showPreparedTimeline(presetKey)
			end
		end)
	else
		pg.global.ui:open(UIConst.UI_ID_AVATAR_MAIN, {
			forcePresetKey = presetKey
		})
	end
end

function ClientUtils.afterOpenUIAvatarMain()
	return
end

function ClientUtils.createUserResult(result, errorCode)
	return
end

function ClientUtils.initEmmyDebug()
	package.cpath = package.cpath .. ";C:/Users/Administrator/AppData/Roaming/JetBrains/IdeaIC2022.1/plugins/EmmyLua/debugger/emmy/windows/x64/?.dll"

	local dbg = require("emmy_core")

	dbg.tcpConnect("localhost", 9966)
end

function ClientUtils.showNetworkReconnectTip(retryCb)
	pg.global.ui.loadProgress:hide()
	ClientUtils.showConfirmRaw(pg.getGameString("NET_RECONNECT_TITLE"), pg.getGameString("NET_RECONNECT_TIP_SIMPLE"), retryCb, false, function()
		ClientUtils.backToHome()
	end, false, nil, {
		okBtnDesc = pg.getGameString("NET_RECONNECT_RETRY"),
		cancelBtnDesc = pg.getGameString("BACK_HOME")
	})
end

function ClientUtils.showNetworkReconnectTip1(okCb)
	pg.global.ui.loadProgress:hide()
	ClientUtils.showConfirmRaw(pg.getGameString("NET_RECONNECT_TITLE"), pg.getGameString("NET_RECONNECT_TIP1"), okCb, false, function()
		ClientUtils.backToHome()
	end, false, nil, {
		okBtnDesc = pg.getGameString("NET_RECONNECT"),
		cancelBtnDesc = pg.getGameString("BACK_HOME")
	})
end

ClientUtils.ConsoleDisconnectNoticeKeyByFamily = {
	playstation = "PS_LIVE_UNAVAILABLE",
	xbox = "XBOX_LIVE_UNAVAILABLE"
}

function ClientUtils.showConsoleDisconnectTip(family, retryCb, cancelCb)
	local noticeKey = type(family) == "string" and ClientUtils.ConsoleDisconnectNoticeKeyByFamily[family]
	local extraDesc = noticeKey and PlatformNoticeUtils.getText(noticeKey)

	if string.isNilOrEmpty(extraDesc) then
		extraDesc = pg.getGameString("NET_RECONNECT_TIP2")
	end

	ClientUtils.showConfirmRaw(pg.getGameString("NET_RECONNECT_TITLE"), extraDesc, retryCb, false, cancelCb, false, nil, {
		okBtnDesc = pg.getGameString("NET_RECONNECT_RETRY"),
		cancelBtnDesc = pg.getGameString("BACK_HOME")
	})
end

function ClientUtils.showNetworkReconnectTip2(okCb)
	pg.global.ui.loadProgress:hide()
	ClientUtils.showConfirmRaw(pg.getGameString("NET_RECONNECT_TITLE"), pg.getGameString("NET_RECONNECT_TIP2"), okCb, false, function()
		ClientUtils.backToHome()
	end, false, nil, {
		okBtnDesc = pg.getGameString("NET_RECONNECT_RETRY"),
		cancelBtnDesc = pg.getGameString("BACK_HOME")
	})
end

function ClientUtils.showNetworkDisconnect(disconnectCode)
	logger:info("游戏网络断开：结束 PremiumFeatureSession。")

	local PlatformPremiumFeatureService = require("SDK.Platform.PlatformPremiumFeatureService")

	PlatformPremiumFeatureService:endSession(nil, 0)

	local msg = pg.getGameString("DISCONNECT_TIPS")

	if disconnectCode ~= nil then
		msg = msg .. "[" .. tostring(disconnectCode) .. "]"
	end

	local backToHomeTriggered = false

	local function backToHomeOnce()
		if backToHomeTriggered then
			return
		end

		backToHomeTriggered = true

		ClientUtils.backToHome(true)
	end

	pg.global.ui.loadProgress:hide()
	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), msg, backToHomeOnce, true, nil, false, nil, {
		onSupersededCb = function()
			TimerManager.addNextFrameCb(backToHomeOnce)
		end
	})

	if disconnectCode ~= ClientConst.NETWORK_DISCONNECT_CODE.NoReconnect and disconnectCode ~= ClientConst.NETWORK_DISCONNECT_CODE.MsNoReconnect then
		ClientUtils.checkNetwork()
	end
end

function ClientUtils.checkNetwork()
	local playerGateIp, playerGatePort, msGateIp, msGatePort

	if ClientRepo.choiceSoulGate ~= nil and #ClientRepo.choiceSoulGate == 2 then
		playerGateIp = ClientRepo.choiceSoulGate[1]
		playerGatePort = ClientRepo.choiceSoulGate[2]
	end

	if ClientRepo.choiceMsGate ~= nil and #ClientRepo.choiceMsGate == 2 then
		msGateIp = ClientRepo.choiceMsGate[1]
		msGatePort = ClientRepo.choiceMsGate[2]
	end

	print("checkNetwork: ", playerGateIp, playerGatePort, msGateIp, msGatePort)

	local devid = ""
	local userid = ""
	local roleid = ""

	csSDKManager.XSDKSendTcpPing(devid, userid, roleid, playerGateIp, playerGatePort, function(codePlayer, msgPlayer)
		print("XSDKSendTcpPing: playerGate", codePlayer, msgPlayer)

		if codePlayer ~= 0 then
			local tip = "playerGatePingFail! \n" .. tostring(codePlayer) .. ":" .. msgPlayer

			ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), tip, function()
				return
			end, true)

			return
		end

		csSDKManager.XSDKSendTcpPing(devid, userid, roleid, msGateIp, msGatePort, function(codeMS, msgMS)
			print("XSDKSendTcpPing: msGate", codeMS, msgMS)

			if codeMS ~= 0 then
				local tip = "msGatePingFail! \n" .. tostring(codeMS) .. ":" .. msgMS

				ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), tip, function()
					return
				end, true)

				return
			end
		end)
	end)
end

function ClientUtils.showNetworkForbid()
	pg.global.ui.loadProgress:hide()
	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("DISCONNECT_SERVER_CLOSED_TIPS"), function()
		ClientUtils.backToHome()
	end, true)
end

function ClientUtils.showKicked()
	pg.global.ui.loadProgress:hide()
	pg.global.gmeManager:ExitRoom(function()
		if pg.game and pg.game.speech then
			pg.game.speech:onExitSpeechRoomResult()
		end
	end)
	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getLocalizationText(SysNoticeData[2217].text), function()
		ClientUtils.backToHome()
	end, true)
end

function ClientUtils.showErrorMsg(msg)
	pg.global.ui.loadProgress:hide()
	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), msg, function()
		ClientUtils.backToHome()
	end, true)
end

function ClientUtils.disconnectLoginNetworkOnly()
	if ClientRepo.loginAgent then
		ClientRepo.loginAgent._loginImpPending = nil

		if ClientRepo.loginAgent._stopBindGlobalMsGateTimer then
			ClientRepo.loginAgent:_stopBindGlobalMsGateTimer()
		end

		if ClientRepo.loginAgent._stopBindExtraGlobalMsGateTimer then
			ClientRepo.loginAgent:_stopBindExtraGlobalMsGateTimer()
		end
	end

	if ClientRepo.netHandler ~= nil then
		ClientRepo.netHandler:close()
		ClientRepo.netHandler:setClusterId(nil)
		ClientRepo.netHandler:setAddress(nil, nil)
		ClientRepo.netHandler:setConnectToken(nil)
	end

	if ClientRepo.msNetworkEventCallback then
		ClientRepo.msNetworkEventCallback:destroy()

		ClientRepo.msNetworkEventCallback = nil
	end

	if ClientRepo.globalMsProxy then
		ClientRepo.globalMsProxy:destroy()

		ClientRepo.globalMsProxy = nil
	end

	if ClientRepo.extraMsNetworkEventCallback then
		ClientRepo.extraMsNetworkEventCallback:destroy()

		ClientRepo.extraMsNetworkEventCallback = nil
	end

	if ClientRepo.extraGlobalMsProxy then
		ClientRepo.extraGlobalMsProxy:destroy()

		ClientRepo.extraGlobalMsProxy = nil
	end

	GlobalData.GlobalGateId = nil
	GlobalData.GlobalGateSessionId = nil
	GlobalData.LastBindMsUid = nil
	GlobalData.LastBindExtraMsUid = nil
	ClientRepo.notShowDisconnectStartTime = nil
end

function ClientUtils.destroyAll()
	if ClientRepo.netHandler ~= nil then
		ClientRepo.netHandler:close()
	end

	if ClientRepo.msNetworkEventCallback then
		ClientRepo.msNetworkEventCallback:destroy()

		ClientRepo.msNetworkEventCallback = nil
	end

	if ClientRepo.globalMsProxy then
		ClientRepo.globalMsProxy:destroy()

		ClientRepo.globalMsProxy = nil
	end

	if ClientRepo.extraMsNetworkEventCallback then
		ClientRepo.extraMsNetworkEventCallback:destroy()

		ClientRepo.extraMsNetworkEventCallback = nil
	end

	if ClientRepo.extraGlobalMsProxy then
		ClientRepo.extraGlobalMsProxy:destroy()

		ClientRepo.extraGlobalMsProxy = nil
	end

	xpcall(pg.global.ui.closeAllUIPanel, debug.traceback, pg.global.ui)
	ClientUtils.tryWithLogErrorEx(pg.global.ui.resetTeardownVisualState, pg.global.ui)
	ClientUtils.destroyAllExcludeNet()
end

function ClientUtils.destroyAllExcludeNet()
	pg.global.sdkManager:clear()
	xpcall(pg.game.onClear, debug.traceback, pg.game)

	if GlobalData.Player and GlobalData.Player.space then
		xpcall(GlobalData.Player.leaveSpace, debug.traceback, GlobalData.Player)
	end

	if GlobalData.Space then
		ClientUtils.safeDestroy(GlobalData.Space)

		GlobalData.Space = nil
		pg.space = nil
	end

	if GlobalData.Player then
		ClientUtils.safeDestroy(GlobalData.Player)

		GlobalData.Player = nil
	end

	clearAIObjectPools()
end

function ClientUtils.pullServerList(force)
	if _G_IsDebugMode and not ClientRepo.confJson.enableOnlineServerList then
		local dirConf, _ = ClientUtils.getDirConf()

		if dirConf ~= nil then
			ClientRepo.loginAgent:getServerInfosByConfig(dirConf)
		end

		return
	end

	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.reqServerList(force)
end

function ClientUtils.reviseForceConf(conf)
	if _G_IsDebugMode then
		if conf.forceServerGroup and conf.forceServerGroup ~= "" then
			ClientConfigServerGroup = conf.forceServerGroup
			conf.enableOnlineServerList = false

			print(string.format("================== forceServerGroup: %s==================", ClientConfigServerGroup))
		end

		if conf.forceServerName and conf.forceServerName ~= "" then
			ClientConfigServerName = conf.forceServerName

			print(string.format("================== forceServerName: %s==================", ClientConfigServerName))
		end

		if conf.forceMsGate and conf.forceMsGate ~= "" then
			ClientConfigMsGate = conf.forceMsGate

			print(string.format("================== forceMsGate: %s==================", ClientConfigMsGate))
		end
	end
end

function ClientUtils.getServerListGroup()
	local platform = pg and pg.global and pg.global.platform

	if ClientConfigLuaReview and ClientConfigLuaReview == true then
		return (not ClientConfigReviewServerGroup or ClientConfigReviewServerGroup == "") and ClientConfigServerGroup or ClientConfigReviewServerGroup
	end

	if ClientConst.OPEN_MIRROR_SERVER then
		return string.format("%s-MIRROR", ClientConfigServerGroup)
	end

	local isOverseasPS = platform and platform:isOverseasWithPS()

	if isOverseasPS and PSServerConst.isAutoSelectServerEnabled() then
		local countryCode = platform:getPSAccountCountryCode()
		local serverRegion = PSServerConst.getServerRegion(countryCode)

		logger:info(string.format("================== serverRegion: %s==================", tostring(serverRegion)))

		if serverRegion then
			return string.format("%s-%s", ClientConfigServerGroup, serverRegion)
		end
	end

	return ClientConfigServerGroup
end

function ClientUtils.getDirConf()
	local dirKey = ClientUtils.getServerListGroup()
	local dirConf

	if _G_IsDebugMode and not ClientRepo.confJson.enableOnlineServerList then
		dirConf = ClientRepo.confJson.serverGroupData[dirKey]
	elseif ClientRepo.ServerGroupDataOnline and ClientRepo.ServerGroupDataOnline.serverGroupData[dirKey] then
		dirConf = ClientRepo.ServerGroupDataOnline.serverGroupData[dirKey]
	end

	return dirConf, dirKey
end

function ClientUtils.getServerInfo()
	local dirConf, _ = ClientUtils.getDirConf()

	if dirConf == nil then
		return nil
	end

	local serverInfo

	for _, info in ipairs(dirConf.localDirData) do
		if info.ClusterId == GlobalData.ServerId and info.ClusterName == GlobalData.ServerName then
			serverInfo = info

			break
		end
	end

	return serverInfo
end

function ClientUtils.getServerStartTime()
	local serverInfo = ClientUtils.getServerInfo()

	if serverInfo == nil then
		return nil
	end

	return serverInfo.StartTime
end

local SERVER_START_TIME_PATTERN = "^(%d%d%d%d)(%d%d)(%d%d)%-(%d%d):(%d%d):(%d%d)$"

function ClientUtils.getServerStartTimestamp()
	local startTime = ClientUtils.getServerStartTime()

	if string.isNilOrEmpty(startTime) then
		return nil
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0
	local timestamp, err = TimeUtils.stringToTimestampByUtcOffset(startTime, areaOffset, SERVER_START_TIME_PATTERN)

	if timestamp == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ClientUtils.getServerStartTimestamp invalid StartTime=%s, err=%s", tostring(startTime), tostring(err))
	end

	return timestamp, err
end

function ClientUtils.isServerStartTimeReached()
	local startTimestamp, err = ClientUtils.getServerStartTimestamp()

	if startTimestamp == nil then
		return err == nil
	end

	local now = Time.secondCache or Time.getSecond()

	return startTimestamp <= now
end

function ClientUtils.connectMsGate()
	local dirConf, dirKey = ClientUtils.getDirConf()

	if dirConf == nil then
		CommonRepo.logger:error("ServerGroup is empty for dirKey=%s", dirKey)
		ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_LIST_EMPTY"), 3)

		return
	end

	if ClientRepo.msNetworkEventCallback ~= nil and ClientRepo.msNetworkEventCallback then
		ClientRepo.msNetworkEventCallback:destroy()

		ClientRepo.msNetworkEventCallback = nil
	end

	local msGateAddrList = dirConf.msGateAddrList

	for _, info in ipairs(dirConf.localDirData) do
		if info.msGateAddrList ~= nil and info.ClusterId == GlobalData.ServerId and info.ClusterName == GlobalData.ServerName then
			if info.msGateAddrList ~= nil then
				msGateAddrList = info.msGateAddrList
			end

			break
		end
	end

	if ClientConfigMsGate and ClientConfigMsGate ~= "" then
		msGateAddrList = {
			ClientConfigMsGate
		}
	end

	if msGateAddrList == nil or #msGateAddrList == 0 then
		CommonRepo.logger:error("connectMsGate failed: msGateAddrList is empty for dirKey=%s, serverId=%s", tostring(dirKey), tostring(GlobalData.ServerId))
		ClientUtils.showBubbleMessageRaw(pg.getGameString("LOGIN_MSGATE_CONNECT_FAILED"), 3)

		if pg.global.ui and pg.global.ui.login and pg.global.ui.login.resetLoginState then
			pg.global.ui.login:resetLoginState()
		end

		return
	end

	local function msReadyCb()
		ClientRepo.loginAgent:loginClick()
	end

	local EntityFactory = require("Core.Common.EntityFactory")
	local GlobalMsProxy4Client = require("Core.Client.GlobalMsProxy4Client")
	local globalMsProxy = GlobalMsProxy4Client(ClientRepo.confJson)

	ClientRepo.globalMsProxy = globalMsProxy

	local msNetworkEventCallback = EntityFactory.createEntity("MsNetworkEventCallback")

	ClientRepo.msNetworkEventCallback = msNetworkEventCallback

	msNetworkEventCallback:regCallbacksTo(globalMsProxy)
	msNetworkEventCallback:start(msGateAddrList, msReadyCb)

	if dirConf.extraMsGateProxyAddr ~= nil then
		local function extraMsReadyCb()
			CommonRepo.logger:info("-------------- connect extra MS success ---------")
		end

		local globalMsProxy = GlobalMsProxy4Client(ClientRepo.confJson)

		globalMsProxy:setExtraConnect()

		ClientRepo.extraGlobalMsProxy = globalMsProxy

		local extraMsNetworkEventCallback = EntityFactory.createEntity("MsNetworkEventCallback")

		extraMsNetworkEventCallback:regCallbacksTo(globalMsProxy)
		extraMsNetworkEventCallback:start(dirConf.extraMsGateAddrList, extraMsReadyCb)

		ClientRepo.extraMsNetworkEventCallback = extraMsNetworkEventCallback
	end
end

function ClientUtils.updateServerList()
	if pg.global.scene and pg.global.scene.curScene and pg.global.scene.curScene.sceneId ~= ClientConst.SCENE_LOGIN_ID then
		return
	end

	if not ClientRepo.confJson.enableOnlineServerList then
		return
	end

	local dirConf, dirKey = ClientUtils.getDirConf()

	ClientRepo.loginAgent:getServerInfosByConfig(dirConf)

	if (ClientRepo.msNetworkEventCallback == nil or ClientRepo.msNetworkEventCallback.msGateList == nil or #ClientRepo.msNetworkEventCallback.msGateList == 0) and ClientRepo.msNetworkEventCallback then
		ClientRepo.msNetworkEventCallback:destroy()

		ClientRepo.msNetworkEventCallback = nil
	end
end

local clientCacheBackToHomeCommitInProgress

local function continueBackToHome(keepSdkLogin)
	if keepSdkLogin then
		ClientUtils.innerBackToHome()
	elseif ClientConfigCloudEnable ~= "true" then
		if SDKLoginConfig.isEnabled() then
			pg.global.sdkManager:logout()
			pg.global.sdkManager:clear()
		else
			ClientUtils.innerBackToHome()
		end
	else
		if ClientConfigSDKFromMobile == "true" then
			pg.global.sdkManager:clear()
			csSDKManager.Logout()
		end

		ClientUtils.innerBackToHome()
	end

	ClientUtils.sendGMERoomExit()
	ClientUtils.sendCloudHostQuit()

	pg.global.firstEnterGame = nil

	mapFogManager:Clear()
	pg.game.chat:backToHome()
	pg.game.weather:backToHome()
	pg.global.ui.hudV2:backToHome()
	pg.global.ui.tips:backToHome()
	pg.global.ui.announcement:backToHome()
	pg.game.avatar:backToHome()
end

function ClientUtils.backToHome(keepSdkLogin)
	if clientCacheBackToHomeCommitInProgress then
		return
	end

	local player = GlobalData.Player
	local ClientCache = require("Entities.SpaceEntities.ClientCache")

	if player == nil or not ClientCache.isAttached(player) then
		continueBackToHome(keepSdkLogin)

		return
	end

	clientCacheBackToHomeCommitInProgress = true

	local success, startedOrError = pcall(ClientCache.flushForAccountSwitch, player)

	if not success and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(startedOrError)
	end

	clientCacheBackToHomeCommitInProgress = nil

	continueBackToHome(keepSdkLogin)
end

local innerBackToHomeInProgress

local function finishInnerBackToHome()
	if not innerBackToHomeInProgress then
		return
	end

	innerBackToHomeInProgress = nil

	ClientUtils.destroyAll()

	local clearSuccess, clearError = pcall(require("Entities.SpaceEntities.ClientCache").clearDetached)

	if not clearSuccess and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(clearError)
	end

	pg.game:onBackToLogin()
	pg.global.scene:loadScene(ClientConst.SCENE_LOGIN_ID)
	TimerManager.addTimer(3, function()
		if ClientUtils.isPublicClient() == false then
			pg.global.resMgr:ClearCache()
			ClientUtils.gc()
		end
	end)
end

function ClientUtils.innerBackToHome()
	if innerBackToHomeInProgress then
		return
	end

	innerBackToHomeInProgress = true

	local player = GlobalData.Player
	local success, err = pcall(function()
		local ClientCache = require("Entities.SpaceEntities.ClientCache")

		if player ~= nil then
			ClientCache.detach(player)
		end
	end)

	if not success and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(err)
	end

	finishInnerBackToHome()
end

function ClientUtils.sendCloudHostQuit()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	csXCloudPipeController.SendCloudHostCodeFromLua(5001, "AppQuit")
end

function ClientUtils.sendGMERoomExit()
	if ClientSwitch.EnableGMESDK and pg.global.gmeManager then
		pg.global.gmeManager:UnInit()
	end
end

function ClientUtils.getCurrentPetInfo()
	local parmonInfo = CS.FunPlus.WorldX.Level.CustomTypes.ParmonInfo()
	local curPet = pg.me:getCurPetEntity()

	if curPet then
		parmonInfo.id = curPet.id
		parmonInfo.actorId = curPet.actorId
		parmonInfo.templateId = curPet.templateId
		parmonInfo.weight = curPet.weight or 0
		parmonInfo.position = curPet:getPosition()
		parmonInfo.rotation = curPet:getRotation()
	end

	return parmonInfo
end

function ClientUtils.getCurrentPlayerInfo()
	local playerInfo = CS.FunPlus.WorldX.Level.CustomTypes.PlayerInfo()
	local me = pg.me

	if me then
		playerInfo.id = me.id
		playerInfo.actorId = me.actorId
		playerInfo.position = me:getPosition()
		playerInfo.rotation = me:getRotation()
		playerInfo.templateId = me.templateId
		playerInfo.isControllingPet = pg.game.controller:isInControlEnt()

		local curPet = pg.me:getCurPetEntity()

		if curPet then
			playerInfo.petTemplateId = curPet.templateId
			playerInfo.basePetTemplateId = Utils.getRefIdByPetPrototypeId(curPet.petPrototypeId)
		end
	end

	return playerInfo
end

function ClientUtils.getEntityInfoById(entId)
	local ent = pg.getEntity(entId)

	if ent then
		local entInfo

		if ent.actorType == Const.ACTOR_TYPE_PUPPET then
			entInfo = CS.FunPlus.WorldX.Level.CustomTypes.PuppetInfo()
			entInfo.weight = ent.weight or 0
		elseif ent.actorType == Const.ACTOR_TYPE_PET then
			entInfo = CS.FunPlus.WorldX.Level.CustomTypes.ParmonInfo()
			entInfo.weight = ent.weight or 0
		elseif ent.actorType == Const.ACTOR_TYPE_PLAYER then
			entInfo = CS.FunPlus.WorldX.Level.CustomTypes.PlayerInfo()
		else
			entInfo = CS.FunPlus.WorldX.Level.CustomTypes.EntityInfo()
		end

		if entInfo then
			entInfo.id = ent.id
			entInfo.actorId = ent.actorId
			entInfo.templateId = ent.templateId
			entInfo.actorType = ent.actorType
			entInfo.position = ent:getPosition()
			entInfo.rotation = ent:getRotation()
		end

		return entInfo
	end

	return nil
end

function ClientUtils.doPlayerDeformToPet(petId)
	local petInfo = PetData[petId]

	pg.me:deformTo(petInfo, {
		isPet = true,
		templateId = petId
	})
end

function ClientUtils.playerCancelDeform()
	pg.me:deformTo(nil)
end

function ClientUtils.doEntityDeformToPet(ent, petId)
	local petInfo = PetData[petId]

	ent:deformTo(petInfo, {
		isPet = true,
		templateId = petId
	})
end

function ClientUtils.entityCancelDeform(ent)
	ent:deformTo(nil)
end

function ClientUtils.entityPlayAnim(entId, animId)
	if string.isNilOrEmpty(entId) or string.isNilOrEmpty(animId) then
		return
	end

	local ent = pg.getEntity(entId)

	if ent and ent.playTrivialAnimation then
		ent:playTrivialAnimation(animId)
	end
end

function ClientUtils.entityPlayPlayable(entId, animId, allowRepeat, timelineTag)
	if string.isNilOrEmpty(entId) or string.isNilOrEmpty(animId) then
		return
	end

	local ent = pg.getEntity(entId)

	if ent and ent.playAnimation then
		ent:playAnimation(animId, allowRepeat, timelineTag)
	end
end

function ClientUtils.cameraBlendTo(position, rotation, fov, blendTime, callback, cancelCallback, extraParam)
	pg.game.camera:cameraBlendToFixed(position, rotation, fov, blendTime, callback, cancelCallback, extraParam)
end

function ClientUtils.cameraResetBlend(blendTime, resetPlayerDir, extraParam)
	if pg.game == nil or pg.game.camera == nil then
		return
	end

	pg.game.camera:cancelBlendToFixed(blendTime, resetPlayerDir, extraParam)
end

function ClientUtils.stopCameraAnim()
	if pg.game == nil or pg.game.camera == nil then
		return
	end

	pg.game.camera:stopCameraAnim()
end

function ClientUtils.callServerGraphDebug(graphId)
	if UNITY_EDITOR then
		pg.me:serverSpaceMsg("RPC_CS_SetGraphDebug", {
			graphId,
			true
		})
	end
end

function ClientUtils.callServerGraphNodePort(graphId, nodeId, portName)
	if UNITY_EDITOR then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("RPC_CS_CallGraphNodePort", graphId, nodeId, portName)
		end

		pg.me:serverSpaceMsg("RPC_CS_CallGraphNodePort", {
			graphId,
			nodeId,
			portName
		})
	end
end

function ClientUtils.callServerReloadSandbox(sandboxId)
	pg.me.space:callServerReloadSandbox(tonumber(sandboxId))
end

function ClientUtils.ReSetSkill_Q(skillid)
	pg.me:serverMsg("RPC_CS_DoPlayerGmCmd", "changeAbility", {
		abilityType = 1,
		level = 1,
		abilityId = skillid
	})
end

function ClientUtils.ReSetSkill_E(skillid)
	pg.me:serverMsg("RPC_CS_DoPlayerGmCmd", "changeAbility", {
		abilityType = 2,
		level = 1,
		abilityId = skillid
	})
end

function ClientUtils.AddBuff(id)
	pg.me:serverMsg("RPC_CS_DoPlayerGmCmd", "addBuff", {
		buffLv = "1",
		tgtId = 0,
		srcId = "1",
		duration = 10,
		buffId = id
	})
end

function ClientUtils.getSkillEnergyByType(data)
	local abilityType = data.abilityType
	local pawn = data.pawn or pg.pawn

	if abilityType == AbilityConst.ULTIMATE_ABILITY then
		return pawn.actorCombatAttribute:getSp()
	else
		return pawn.actorCombatAttribute:getEp()
	end
end

function ClientUtils.teleportPos(pos)
	local player = pg.me

	if player and pos and pos:Magnitude() > 0 then
		if FREE_WALK then
			player:forceSetPos(pos, true)
		else
			player:doGmCmd("gotoByPos", pos.x, pos.y, pos.z)
		end
	end
end

function ClientUtils.getProfileRuntimePos(pos, sceneId)
	local x, y, z = pos.x, pos.y, pos.z
	local sceneConfig = mapOverlapScene[sceneId] and sceneData[sceneId]
	local wholemapOffset = sceneConfig and sceneConfig.wholemapOffset

	if wholemapOffset and #wholemapOffset == 3 then
		x = x - wholemapOffset[1]
		z = z - wholemapOffset[3]
	end

	return Vector3(x, y, z)
end

function ClientUtils.teleportScene(sceneId)
	local player = pg.me

	if player then
		player:doGmCmd("teleportToScene", sceneId, 0)
	end
end

function ClientUtils.playerExitMagnesis()
	local player = pg.me

	if player then
		player:magnesisCancel()
	end
end

function ClientUtils.getEntityIdByGlobalId(envId)
	if string.isNilOrEmpty(envId) then
		return
	end

	local envEnt = pg.getEntityByGlobalId(envId)

	if envEnt then
		return envEnt.id
	end

	return nil
end

function ClientUtils.endProfile()
	pg.me.eModel.GmMoveSpeed = -1

	pg.game.input:enableControlInput(true)
	pg.game.input:enableHudInput(true)
	pg.pawn.eModel:SetActiveEx(true)
	CS.FunPlus.WorldX.Utils.GmToolUtils.CloseOBCamera()
end

function ClientUtils.getCurrentPlayerId()
	local me = pg.me

	if me then
		return me.id
	end

	return nil
end

function ClientUtils.getCurrentPlayerTemplateId()
	if pg.me == nil then
		return 0
	end

	return pg.me.templateId
end

function ClientUtils.getCurrentPetId()
	local curPet = pg.me:getCurPetEntity()

	if curPet then
		return curPet.id
	end

	return nil
end

function ClientUtils.getCurrentPetTemplateId()
	if pg.me == nil then
		return 0
	end

	local curPet = pg.me:getCurPetEntity()

	if curPet == nil then
		return 0
	end

	return curPet.petInfo.templateId
end

function ClientUtils.getEntityIdByStaticId(staticId)
	local entId = pg.me and pg.me.space and pg.me.space:getEntityIdByStaticId(staticId)

	if entId == nil then
		entId = ""
	end

	return entId
end

function ClientUtils.getRandomMapEntityIdByOriginStaticIdForCS(staticId)
	local space = pg.me and pg.me.space

	if space == nil or not ToBool(staticId) then
		return ""
	end

	local entId = space.staticId2Id[staticId]

	if entId then
		return entId
	end

	local newIds = RandomMapBatchUtils.queryNewIdsByOrigin(space.id, staticId)
	local hitEntId

	if newIds then
		for i = 1, #newIds do
			entId = space.staticId2Id[newIds[i]]

			if entId then
				if hitEntId and hitEntId ~= entId then
					logger:error("getRandomMapEntityIdByOriginStaticIdForCS ambiguous staticId=%s", tostring(staticId))

					return ""
				end

				hitEntId = entId
			end
		end
	end

	return hitEntId or ""
end

function ClientUtils.createSoulEggEvolutionEntity(info, pos, rot, presentationOptions)
	local ClientSoulEggEvolutionEntity = require("Entities.SpaceEntities.ClientSoulEggEvolutionEntity")
	local soulEggEvolutionEntity = ClientSoulEggEvolutionEntity.new()

	ClientUtils.entityInitCall(soulEggEvolutionEntity, {})
	soulEggEvolutionEntity.eModel:SetTransformParent(nil, false)
	EModelUtils.setAgentPositionAndRotation(soulEggEvolutionEntity, pos, rot)

	soulEggEvolutionEntity.eModel.modelModelView.instPriority = ClientConst.InstantiatePriority.Urgent

	soulEggEvolutionEntity:setSoulEggAvatar(info, presentationOptions)

	return soulEggEvolutionEntity
end

function ClientUtils.createFertilityCubeEntity(info, resId, pos, rot, presentationOptions)
	local ClientFertilityCubeEntity = require("Entities.SpaceEntities.ClientFertilityCubeEntity")
	local fertilityCubeEntity = ClientFertilityCubeEntity.new()

	ClientUtils.entityInitCall(fertilityCubeEntity, {})
	fertilityCubeEntity.eModel:SetTransformParent(nil, false)
	EModelUtils.setAgentPositionAndRotation(fertilityCubeEntity, pos, rot)

	fertilityCubeEntity.eModel.modelModelView.instPriority = presentationOptions and presentationOptions.instantiatePriority or ClientConst.InstantiatePriority.Urgent

	fertilityCubeEntity:setCubeModel(info, resId, presentationOptions)

	return fertilityCubeEntity
end

function ClientUtils.createEvolutionEntity(entityInfo, pos, rot, presentationOptions)
	local ClientEvolutionEntity = require("Entities.SpaceEntities.ClientEvolutionEntity")
	local evolutionEntity = ClientEvolutionEntity.new()

	ClientUtils.entityInitCall(evolutionEntity, {
		isIgnoreEffectLod = true
	})
	evolutionEntity.eModel:SetTransformParent(nil, false)
	EModelUtils.setAgentPositionAndRotation(evolutionEntity, pos, rot)

	evolutionEntity.eModel.modelModelView.instPriority = ClientConst.InstantiatePriority.Urgent

	evolutionEntity:setEvolutionAvatar(entityInfo, presentationOptions)

	return evolutionEntity
end

function ClientUtils.createPetBallEntity(petId)
	local pets = pg.me.pets
	local pet = pets[petId]

	if pet == nil then
		return
	end

	local ClientPet = require("Entities.SpaceEntities.ClientPet")
	local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
	local mePos = pg.me:getPosition()
	local find, positionX, positionY, positionZ = VoxelUtils.findVoxelRandomPos(pg.me, mePos, 2, 10)
	local rotation = Quaternion.Euler(0, 0, 0)
	local position = Vector3.New(positionX, positionY, positionZ)
	local entityContent = {
		position = position,
		rotation = rotation,
		virtualTemplateClassName = ClientPet.typeName,
		virtualTemplateActorType = Const.ACTOR_TYPE_PET,
		virtualModelLayer = ClientConst.LayerDefine.LAYER_UI_SCENE,
		virtualTemplateId = pet.templateId,
		bornPosition = position,
		curModelScale = pet.modelScale,
		baseAttr = pet.baseAttr,
		abilityMap = pet.curAbilityMap,
		label = pet.label,
		individuationIds = pet.individuationIds
	}

	return ClientUtils.createClientEntity("ClientPetBallEntity", VirtualEntUtils.getNewVirtualEntityId(), entityContent)
end

function ClientUtils.enableLevelInput(mapName, enable, graphName)
	pg.game.input:enableLevelBlockInput(mapName, enable, graphName)
end

function ClientUtils.setTeammateViewEnable(enable)
	pg.me.disableTeammateView = not enable
end

function ClientUtils.setBlockInput(key, isBlock)
	pg.game.input:setBlockInput(key, isBlock)
end

function ClientUtils.setModuleEnableByLevel(reasonKey, moduleName, enable)
	reasonKey = reasonKey or "Default"

	local levelReasonKey = "Level_" .. reasonKey

	pg.game:setModuleEnable(levelReasonKey, moduleName, enable)
end

function ClientUtils.exitCatchMode()
	pg.me:forceExitCaptureMode()
end

function ClientUtils.isPuppet(entity)
	return Utils.isPuppet(entity)
end

function ClientUtils.isPet(entity)
	return Utils.isPet(entity)
end

function ClientUtils.isEnvObj(entity)
	return Utils.isEnvObj(entity)
end

function ClientUtils.isInPetPrepareList(entity)
	if not entity or not entity.master then
		return false
	end

	if entity.master.petPrepareList then
		for _, id in ipairs(entity.master.petPrepareList) do
			if entity.id == id then
				return true
			end
		end
	end

	return false
end

function ClientUtils.getPetMasterPrepareList(entity)
	if not entity or not entity.master then
		return {}
	end

	return entity.master.petPrepareList or {}
end

function ClientUtils.updateMaxPreparedPetLevel(masterEnt)
	if not masterEnt then
		return
	end

	if not masterEnt.petPrepareList then
		masterEnt.maxPreparedPetLevel = 0

		return
	end

	local maxLevel = 0
	local pets = masterEnt:getPets()

	if pets then
		for _, id in ipairs(masterEnt.petPrepareList) do
			if pets[id] then
				maxLevel = math.max(maxLevel, pets[id].level)
			end
		end
	end

	masterEnt.maxPreparedPetLevel = maxLevel
end

function ClientUtils.showChest(spawnerId)
	pg.me:serverMsg("RPC_CS_SpawnerProductionShowOne", spawnerId)
end

function ClientUtils.checkPerceivedValue(staticId, perceivedValue)
	local entity = pg.me.space:getEntityByStaticId(staticId)

	if entity then
		return perceivedValue <= entity:getPerceivedValue()
	end

	return false
end

function ClientUtils.checkCondition(conditionId)
	if pg.me == nil then
		return false
	end

	return pg.me.triggerMap:isCompleteOrMeetCondition(conditionId)
end

local harmonyPCHiddenSettingFuncTypes

if UNITY_OPENHARMONY then
	harmonyPCHiddenSettingFuncTypes = {
		vSync = true,
		setResolution = true,
		setScreenMode = true,
		frameGeneration = true
	}
end

function ClientUtils.getRealPlatformId()
	local RealPlatform = ClientConst.RealPlatform
	local platform = pg.global and pg.global.platform

	if platform ~= nil then
		if platform:isConsole() then
			return RealPlatform.Console
		end

		if platform:isMobile() then
			return RealPlatform.Mobile
		end

		if platform:isPC() then
			return RealPlatform.PC
		end
	end

	if IS_MOBILE or ClientConfigInputPlatform == "Mobile" then
		return RealPlatform.Mobile
	end

	return RealPlatform.PC
end

function ClientUtils.checkIsOpenToCurPlatform(tipInfo)
	if tipInfo.realPlatform ~= nil then
		local curRealPlatform = ClientUtils.getRealPlatformId()
		local matched = false

		if type(tipInfo.realPlatform) == "table" or type(tipInfo.realPlatform) == "userdata" then
			for _, openPlatform in ipairs(tipInfo.realPlatform) do
				if openPlatform == curRealPlatform then
					matched = true

					break
				end
			end
		else
			matched = tipInfo.realPlatform == curRealPlatform
		end

		if not matched then
			return false
		end
	end

	if UNITY_OPENHARMONY and ClientConfigInputPlatform == "Standalone" and tipInfo.funcType and harmonyPCHiddenSettingFuncTypes[tipInfo.funcType] then
		return false
	end

	if tipInfo.platform == nil then
		return true
	end

	local isConsoleFamily = pg.global.platform and pg.global.platform:isConsoleFamily() or false

	for _, funcType in ipairs(ClientConst.FuncInConsoleOnly) do
		if tipInfo.funcType == funcType then
			return isConsoleFamily
		end
	end

	local curPlatform = pg.global.ui.uiMgr:CheckPlatform()

	for _, openPlatform in ipairs(tipInfo.platform) do
		if openPlatform == curPlatform then
			return true
		end
	end

	if isConsoleFamily then
		local UIConst = require("Const.UIConst")

		for _, openPlatform in ipairs(tipInfo.platform) do
			if openPlatform == UIConst.PLATFORM.Console then
				return true
			end
		end
	end

	return false
end

function ClientUtils.getAdaptionPlatform()
	return CS.XGUI.UIConfig.instance:GetAdaptionPlatform()
end

function ClientUtils.forceExitGhostEyeState()
	local player = pg.me

	if player then
		player:forceExitGhostEyeState()
	end
end

local buffTag2CheckCmdMap

function ClientUtils.getBuffTag2CheckCmdEvent(buffTagId)
	if not buffTag2CheckCmdMap then
		buffTag2CheckCmdMap = {
			[AbilityConst.BUFF_TAG_CHARM] = ConflictTypes.CT_CHARM,
			[AbilityConst.BUFF_TAG_FROZEN] = ConflictTypes.CT_FROZEN,
			[AbilityConst.BUFF_TAG_STUN] = ConflictTypes.CT_STUN,
			[AbilityConst.BUFF_TAG_SLEEP] = ConflictTypes.CT_SLEEP,
			[AbilityConst.BUFF_TAG_SILENT] = ConflictTypes.CT_SILENT,
			[AbilityConst.BUFF_TAG_PALSY] = ConflictTypes.CT_PALSY
		}
	end

	return buffTag2CheckCmdMap[buffTagId]
end

function ClientUtils.handleModelImpulseEvent(entity, shapeKind, centerOffsetXYZ, rotationOffset, shapeArgs, physicsImpulse)
	local rot = entity:getRotation():Clone()
	local center = entity:getPosition():Clone()
	local offsetXYZ = Vector3.New(unpack(centerOffsetXYZ))
	local offsetRotation = Vector3.New(unpack(rotationOffset))

	physicsImpulse = AbilitySettingGlobalConstData.physicsImpulse[physicsImpulse] or 0
	center = CombatActionTool.translatePoint(center, rot, offsetXYZ)

	if offsetRotation.x ~= 0 then
		rot = rot * Quaternion.AngleAxis(offsetRotation.x, Vector3.left)
	end

	if offsetRotation.y ~= 0 then
		rot = rot * Quaternion.AngleAxis(offsetRotation.y, Vector3.up)
	end

	if offsetRotation.z ~= 0 then
		rot = rot * Quaternion.AngleAxis(offsetRotation.z, Vector3.forward)
	end

	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[shapeKind]

	if entity.RPC_SC_DrawAbilityGizmo then
		entity:RPC_SC_DrawAbilityGizmo(shapeKind, center:getRawTable(), rot:getRawTable(), shapeArgs)
	end

	pg.global.physicsMgr:SetChemHitInfo(entity.actorId, 0, ECSConst.ELEMENT_TYPE_NONE, physicsImpulse, 0, 0, 0, 0)

	if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
		pg.global.physicsMgr:TraverseElementCircle3D(center, rot, shapeArgs)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
		pg.global.physicsMgr:TraverseElementSector3D(center, rot, shapeArgs)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
		pg.global.physicsMgr:TraverseElementTrapezoid3D(center, rot, shapeArgs)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
		pg.global.physicsMgr:TraverseElementAnnularSector3D(center, rot, shapeArgs)
	end

	pg.global.physicsMgr:ClearChemHitInfo()
end

function ClientUtils.createShadow(mainEnt, shadowOffset)
	if mainEnt.virtualShadowEntity then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("----------one entity is allowed to have one shadow")
		end

		return
	end

	local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
	local ent = ClientUtils.createClientEntity("ClientShadowVirtualEntity", VirtualEntUtils.getNewVirtualEntityId(), {
		mainEnt = mainEnt
	})

	mainEnt.virtualShadowEntity = ent

	ent:setActive(ClientConst.MODEL_VISIBLE_KEY.SHADOW, mainEnt.active)
	ent:OpenShadow(mainEnt, shadowOffset)
	mainEnt:setEntityCacheVal("shadowEntityId", ent.id)

	return ent
end

function ClientUtils.createFollowingPhantom(actionData, petTemplateId, masterActorId)
	local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
	local ent = ClientUtils.createClientEntity("ClientFollowingPhantomVirtualEntity", VirtualEntUtils.getNewVirtualEntityId(), {
		actionData = actionData,
		petTemplateId = petTemplateId,
		masterActorId = masterActorId
	})

	return ent
end

function ClientUtils.destroyFollowingPhantom(ent)
	ClientUtils.safeDestroy(ent)
end

function ClientUtils.destoryShadow(mainEnt)
	local shadowEnt = mainEnt.virtualShadowEntity or nil

	if not shadowEnt then
		return
	end

	shadowEnt:CloseShadow()
	mainEnt:setEntityCacheVal("shadowEntityId", nil)
	ClientUtils.safeDestroy(shadowEnt)

	mainEnt.virtualShadowEntity = nil
end

function ClientUtils.getValidSwapPosition(ent, targetPosition)
	local actorInfo = Utils.getEntityConfigData(ent)
	local rigidbodyId = actorInfo.rigidbody
	local radius = 0.1
	local height = 1
	local center = Vector3(0, 0.5, 0)

	if rigidbodyId then
		local rigidbodyData = RigidbodyData[rigidbodyId]

		radius = rigidbodyData.radius
		height = rigidbodyData.height

		if rigidbodyData.center == nil then
			center = Vector3(0, rigidbodyData.height * 0.5, 0)
		else
			center:Copy(rigidbodyData.center)
		end
	end

	targetPosition = CS.FunPlus.WorldX.Navigate.NavigateUtils.GetValidSwapPosition(targetPosition, center, radius, height)

	return targetPosition
end

function ClientUtils.createVirtualGrabEggEntity(templateId, pos, modelScale, rootTransform, patternType, patternColorType)
	local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
	local ent = ClientUtils.createClientEntity("ClientGrabEggSettlementVirtualEntity", VirtualEntUtils.getNewVirtualEntityId(), {
		templateId = templateId,
		position = pos,
		modelScale = modelScale,
		rootTransform = rootTransform,
		patternColorType = patternColorType,
		patternType = patternType
	})

	return ent
end

function ClientUtils.createVirtualChest(mainChestEnt, pos)
	local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
	local ent = ClientUtils.createClientEntity("ClientChestVirtualEntity", VirtualEntUtils.getNewVirtualEntityId(), {
		position = pos,
		mainChest = mainChestEnt
	})

	return ent
end

function ClientUtils.copyVirtualEntityFrom(srcEntId, transform, syncLoad)
	local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
	local srcEnt = pg.getEntityByActorId(srcEntId)
	local ent = ClientVirtualEntityUtils.copySimpleVirtualPlayerFrom({
		copyEntity = srcEnt,
		syncLoad = syncLoad
	})

	ent:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)
	ent.eModel:SetTransformParent(transform)
	ent.eModel:SetTransformLocalPosition()
	ent.eModel:SetTransformLocalRotation(0, 0, 0, 1)

	return ent.eModel
end

function ClientUtils.destoryVirtualChest(chestEnt)
	ClientUtils.safeDestroy(chestEnt)
end

function ClientUtils.closeBoxAndMenu()
	pg.global.ui.petManagement:dismiss()
	pg.global.ui.funcMenu:closeUI()
end

function ClientUtils.addEntityDynamicBubble(staticId, bubbleId, bubbleDistance, bubbleCd)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.addDynamicBubble then
			entity:addDynamicBubble(bubbleId, bubbleDistance, bubbleCd)
		end
	end
end

function ClientUtils.removeEntityDynamicBubble(staticId, bubbleId)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.removeDynamicBubble then
			entity:removeDynamicBubble(bubbleId)
		end
	end
end

function ClientUtils.addEntityCustomInteraction(staticId, interactId, interactConfigId, handlePetEthnicGroup, callback, sandBoxId, doOnce, overrideNpcTemplateId)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.addCustomInteraction then
			entity:addCustomInteraction(interactId, interactConfigId, handlePetEthnicGroup, callback, sandBoxId, doOnce, overrideNpcTemplateId)
		end
	end
end

function ClientUtils.removeEntityCustomInteraction(staticId, interactId)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.removeCustomInteraction then
			entity:removeCustomInteraction(interactId)
		end
	end
end

function ClientUtils.enableEntityCallFriend(staticId, interactId, enable, distance, callback, sandBoxId, doOnce)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.enableInteractCallFriend then
			entity:enableInteractCallFriend(interactId, enable, distance, callback, sandBoxId, doOnce)
		end
	end
end

function ClientUtils.enableListenBallHitEvent(staticId, interactId, enable, callback, sandBoxId, doOnce)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.enableListenBallHitEvent then
			entity:enableListenBallHitEvent(interactId, enable, callback, sandBoxId, doOnce)
		end
	end
end

function ClientUtils.enableShowVlogTopLogo(staticId, interactId, enable, callback, sandBoxId, doOnce, extraParams)
	if pg.me and pg.me.space then
		local entity = pg.me.space:getEntityByStaticId(staticId)

		if entity and entity.enableShowVlogTopLogo then
			if enable and extraParams then
				entity:enableShowVlogTopLogo(interactId, enable, callback, sandBoxId, doOnce, extraParams.uiShowDistance, extraParams.canInteractDistance, extraParams.showStyle)
			else
				entity:enableShowVlogTopLogo(interactId, enable, callback, sandBoxId, doOnce)
			end
		end
	end
end

function ClientUtils.getPortalPosInfo(sceneId, pointId)
	local mainSceneId = Utils.getPhaseMainSceneId(sceneId)
	local scenePortalData = SceneUtils.getScenePortalData(sceneId)

	if not scenePortalData and mainSceneId and mainSceneId ~= sceneId then
		scenePortalData = SceneUtils.getScenePortalData(mainSceneId)
		sceneId = mainSceneId
	end

	if not scenePortalData then
		return false, nil
	end

	local pointData = scenePortalData[pointId]

	if not pointData then
		return false, nil
	end

	local pos, yaw = Utils.getPosByMarkData(pointData)

	return true, pos
end

function ClientUtils.playTeleportDissolveEffectAndTeleport(teleportScene, transportId)
	if not ClientUtils.invokeWithCooldown("teleport") then
		return
	end

	if not pg.pawn or not pg.me or not pg.pawn.space then
		return
	end

	if not pg.pawn:checkTeleport() then
		return
	end

	transportId = transportId or 0

	local teleportSameScene = pg.pawn.space.sceneId == teleportScene

	if teleportSameScene and not ToBool(transportId) then
		return
	end

	pg.game.input:setAllInputMapEnabled(false, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)

	local reloadScene = not teleportSameScene

	if teleportSameScene then
		local ret, targetPos = ClientUtils.getPortalPosInfo(teleportScene, transportId)

		if ret then
			reloadScene = appFacade.streamManager:CheckNeedLoad(targetPos)
		end
	end

	if not reloadScene then
		pg.pawn:playTeleportDissolveEffect(nil, nil, function()
			pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, false)
			pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, false)
			AnimationUtils.playAnimationState(pg.pawn, CharacterStateConst.IDLE)
			pg.me:tryTeleportToScene(teleportScene, transportId)
		end)
	else
		AnimationUtils.playAnimationState(pg.pawn, CharacterStateConst.IDLE)
		pg.me:tryTeleportToScene(teleportScene, transportId)
	end

	pg.game.effect.recoverTeleportDissolveTimer = TimerManager.addTimer(3, function()
		pg.game.effect.recoverTeleportDissolveTimer = nil

		pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)

		if pg.me then
			pg.me.pendingTeleportAppear = nil

			pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)
			pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)

			local cbCurSpaceSceneId = pg.me.space and pg.me.space.sceneId
			local forbidTeleport = cbCurSpaceSceneId == teleportScene and not ToBool(transportId)

			if not forbidTeleport then
				pg.me:tryTeleportToScene(teleportScene, transportId or 0)
			end
		end

		if pg.pawn then
			pg.pawn:playTeleportAppearEffect(1.2)
		end
	end)
end

function ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(func)
	if not ClientUtils.invokeWithCooldown("teleportfunc") then
		return
	end

	if not func then
		return
	end

	if not pg.pawn then
		return
	end

	if not pg.pawn:checkTeleport() then
		return
	end

	local hasCallCallBack = false

	pg.game.input:setAllInputMapEnabled(false, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)
	pg.pawn:playTeleportDissolveEffect(nil, nil, function()
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, false)
		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, false)
		AnimationUtils.playAnimationState(pg.pawn, CharacterStateConst.IDLE)

		if hasCallCallBack then
			return
		end

		func()

		hasCallCallBack = true
	end)

	pg.game.effect.recoverTeleportDissolveTimer = TimerManager.addTimer(3, function()
		pg.game.effect.recoverTeleportDissolveTimer = nil

		pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)

		if pg.me then
			pg.me.pendingTeleportAppear = nil

			pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)
			pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)
		end

		if pg.pawn then
			pg.pawn:playTeleportAppearEffect(1.2)
		end

		if hasCallCallBack then
			return
		end

		func()

		hasCallCallBack = true
	end)
end

function ClientUtils.invokeWithCooldown(key)
	if invokeCooldowns[key] then
		return false
	end

	invokeCooldowns[key] = true

	TimerManager.addTimer(1, function()
		invokeCooldowns[key] = nil
	end)

	return true
end

function ClientUtils.canCatch(entity)
	return CatchProbContext.clientGet(entity).canCatch
end

function ClientUtils.getEffectConfigInfo(effectKey, ent)
	if effectKey == ControllerData.EffDelayDash and ent == pg.pawn and ent and ent.inGrass then
		return nil
	end

	local rawInfo = effectData[effectKey]

	rawInfo = rawInfo and rawInfo[1]

	if not rawInfo then
		return nil
	end

	local extraInfo = {}

	if ent then
		ClientEffectUtils.applyEffectCommonMountData(ent, rawInfo, extraInfo)
	end

	return pg.game.effect:createEffectConfigInfo(rawInfo, extraInfo)
end

function ClientUtils.setPlayerCameraFocusAndFov(param)
	if param.faceToTarget then
		pg.game.camera.playerCameraMode:FaceToTargetTransform(param.faceToTarget, param.heightDelta, param.maxLockTime, param.shoulder)
	end

	if param.fov ~= nil then
		pg.game.camera.playerCameraMode:blendToFov(param.fov, param.fovBlendTime, param.fovBlendFunc)
	end
end

function ClientUtils.getCustomVariableValue(id)
	if pg.me == nil or pg.me.triggerMap.customVariables == nil then
		return -1
	end

	if pg.me.triggerMap.customVariables[id] then
		return pg.me.triggerMap.customVariables[id]
	else
		return -1
	end
end

function ClientUtils.getNpcBehavStatusMap(staticId)
	if not staticId then
		return
	end

	if pg.me == nil or pg.me.triggerMap.npcBehaviorStatus == nil then
		return
	end

	return pg.me.triggerMap.npcBehaviorStatus[staticId]
end

function ClientUtils.getNpcBehavStatus(staticId, key)
	if pg.me == nil or pg.me.triggerMap.npcBehaviorStatus == nil then
		return -1
	end

	local varTable = pg.me.triggerMap.npcBehaviorStatus[staticId]

	if varTable and varTable[key] then
		return varTable[key]
	else
		return -1
	end
end

function ClientUtils.getQuestData(questId)
	local QuestUtils = require("GameApp.Quest.QuestUtils")
	local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
	local questData = QuestUtils.getQuestData(questId)

	if questData == nil and pg.me ~= nil then
		local state = QuestCommonUtils.getQuestState(pg.me, questId)

		questData = {
			state = state
		}
	end

	return questData
end

local function _getQuestSelfGuidePos(QuestUtils, questId)
	if questId == nil or questId == 0 then
		return nil
	end

	local questData = QuestUtils.getQuestData(questId)

	if questData == nil then
		return nil
	end

	local targetInfo = QuestUtils.getQuestTargetInfo(questData, true)

	if targetInfo == nil or targetInfo.posInfo == nil then
		return nil
	end

	for i = 1, #targetInfo.posInfo do
		local info = targetInfo.posInfo[i]
		local entityStaticId = info.posConfig and info.posConfig.entity or info.npcStaticId
		local pos = info.pos

		if entityStaticId and pg.me and pg.me.space then
			local entity = pg.me.space:getEntityByStaticId(entityStaticId)

			if entity then
				pos = entity:getPosition()
			end
		end

		if pos ~= nil and pos[1] ~= nil and pos[2] ~= 9999 then
			return pos
		end
	end

	return nil
end

function ClientUtils.getQuestPosition(questId)
	local QuestUtils = require("GameApp.Quest.QuestUtils")
	local position = Vector3.New()
	local pos = _getQuestSelfGuidePos(QuestUtils, questId)

	if pos == nil then
		local parent = QuestUtils.getParentQuestId(questId)
		local subs = parent and parent ~= 0 and parent ~= questId and QuestUtils.getAllSubQuests(parent)

		if subs then
			for _, id in pairs(subs) do
				pos = _getQuestSelfGuidePos(QuestUtils, tonumber(id))

				if pos ~= nil then
					break
				end
			end
		end
	end

	if pos ~= nil and pos[1] ~= nil then
		position:Set(pos[1], pos[2], pos[3])
	end

	return position
end

function ClientUtils.uautoCheckUIShow(uid)
	if type(uid) ~= "number" then
		uid = tonumber(uid)
	end

	local res = pg.global.ui:checkUIShow(uid)

	return res
end

function ClientUtils.exitDungeon(showLoadingPanel)
	if showLoadingPanel and pg.global.scene then
		pg.global.scene:showExitLoadingGuard()
	end

	pg.me:serverMsg("RPC_CS_QuitSpace")
end

function ClientUtils.getCurrentDungeonPassRecord()
	local dungeonId
	local curSpace = pg.me.space

	if curSpace then
		dungeonId = curSpace:getCurDungeonId()
	end

	local passTime = 0

	if dungeonId then
		passTime = pg.me.passRecord[dungeonId] or 0
	end

	return passTime
end

function ClientUtils.getCurrentDungeonMainPlayerPassRecord()
	local curSpace = pg.me.space

	return curSpace.mainPlayerPassRecord or 0
end

function ClientUtils.getCurrentRobEggUnderGroundIsDGEnable()
	local me = pg.me

	if me == nil then
		return false
	end

	local space = me.space

	if space == nil then
		return false
	end

	return space.isDGEnable == true
end

function ClientUtils.setResPointActive(staticId, isActive)
	ResPointUtils.ActivatePointByScene(staticId, isActive)
end

function ClientUtils.setHideEntityByTotemPuzzle(isHide)
	if isHide then
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.TOTEM_PUZZLE, false)
		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TOTEM_PUZZLE, false)
	else
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.TOTEM_PUZZLE, true)
		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TOTEM_PUZZLE, true)
	end
end

function ClientUtils.setHideUIByTotemPuzzle(isHide)
	if isHide then
		local whiteList = {}

		whiteList[UIConst.UI_ID_QUEST_ARRIVAL_TIP] = true

		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.TOTEM_PUZZLE, whiteList)
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.TOTEM_PUZZLE)
	end
end

function ClientUtils.getPetBodySizeType(petEnt)
	if not Utils.isPet(petEnt) and not Utils.isPetNpc(petEnt) then
		return nil
	end

	local configData = petEnt:getConfigData()
	local petPrototypeId = configData and configData.petPrototypeId or 0
	local bodySizeType = PetPrototypeData[petPrototypeId] and PetPrototypeData[petPrototypeId].cameraDistModeId

	return bodySizeType
end

function ClientUtils.SetAllPlayerVisible(key, visible, includeMainPlayer, includeTeammate)
	if visible then
		Bitset.clrBit(ClientConst.PLAYER_VISIBLE_FLAG, key)
		Bitset.clrBit(ClientConst.PET_VISIBLE_FLAG, key)
	else
		Bitset.setBit(ClientConst.PLAYER_VISIBLE_FLAG, key)
		Bitset.setBit(ClientConst.PET_VISIBLE_FLAG, key)
	end

	if includeMainPlayer and pg.me then
		pg.me:setVisible(key, visible)
		pg.me:setCurPetVisible(key, visible)
	end

	if includeTeammate == nil then
		includeTeammate = true
	end

	local entities = pg.global.entityMgr.getAllEntities()
	local needRefresh

	for _, entity in pairs(entities) do
		if entity.refreshVisible then
			needRefresh = true

			if not includeTeammate and (pg.me:isUidTeamMember(entity.uid) or pg.me:isTeamPet(entity.id)) then
				needRefresh = false
			end

			if needRefresh then
				entity:refreshVisible()
			end
		end
	end
end

function ClientUtils.SetAllPuppetVisible(key, visible)
	if visible then
		Bitset.clrBit(ClientConst.PUPPET_VISIBLE_FLAG, key)
	else
		Bitset.setBit(ClientConst.PUPPET_VISIBLE_FLAG, key)
	end

	local entities = pg.global.entityMgr.getAllEntities()

	for _, entity in pairs(entities) do
		if entity.refreshVisible then
			entity:refreshVisible()
		end
	end
end

function ClientUtils.setInCutsceneState(reasonKey, inState)
	pg.game.cutscene:setInCutsceneState(reasonKey, inState)
end

function ClientUtils.setInTotemPuzzle(inTotemPuzzle)
	pg.me.inTotemPuzzle = inTotemPuzzle
end

function ClientUtils.tryInsertToTable(targetTable, value)
	if targetTable == nil or value == nil then
		return
	end

	table.insert(targetTable, value)
end

function ClientUtils.checkSingleStatusCondition(cond)
	local player = pg.me

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("checkSingleStatusCondition invalid player")
		end

		return false
	end

	if not cond then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("checkSingleStatusCondition invalid param:", cond)
		end

		return false
	end

	return TriggerUtils.checkSingleStatusCondition(player, cond)
end

function ClientUtils.checkEntityCanBeInteracted(entity, isBubble)
	if entity.isInCombat and entity:isInCombat() then
		if not isBubble then
			return false
		end

		local enableBubbleInCombat = entity:getConfigData().enableBubbleInCombat or entity.forceShowBubbleInCombat

		if not enableBubbleInCombat then
			return false
		end
	end

	if entity.agent and entity.agent.getBehaviorState then
		local curBehaviorState = entity.agent:getBehaviorState()
		local stateName = BehaviorPathMapData.EnumMap[curBehaviorState]

		if DialogueConst.FORBID_RANDOM_TEXT_AI_BT_TREE[stateName] then
			return false
		end
	end

	for _, tag in pairs(DialogueConst.FORBID_RANDOM_TEXT_ENTITY_TAG) do
		if Utils.hasEntityTag(entity, tag) then
			return false
		end
	end

	if not entity:checkStatus(ConflictTypes.INTERACT_ST, nil, nil, true) then
		return false
	end

	return true
end

function ClientUtils.checkTargetEntityDifferentEthnicGroupWithPawn(targetEntity)
	local npcTemplateId = targetEntity and targetEntity.templateId or 0
	local npcData = PuppetData[npcTemplateId]

	if npcData and npcData.npcType == Const.NPC_TYPE.Pet and (pg.me:isControllingMaster() or pg.me:isControllingPet() and not Utils.IsSameEthnicGroup(targetEntity, pg.me:getCurPetEntity())) then
		return true
	end

	return false
end

function ClientUtils.levelSetTipsVisible(reasonKey, visible)
	pg.global.ui.tips:setTipsVisibleByLevel(reasonKey, visible)
end

function ClientUtils.getSandboxPhase(sandboxId)
	if not pg.space then
		return 0
	end

	local ownerId = pg.space.ownerPlayerId
	local owner = pg.getEntity(ownerId)

	if not owner then
		return 0
	end

	return owner:getSandboxPhase(sandboxId)
end

function ClientUtils.setAudioState(stateGroup, stateId, reason, forceSet)
	pg.game.audio:trySetState(stateGroup, stateId, reason, forceSet)
end

function ClientUtils.tryClientSysTrigger(triggerType, triggerId, count, params)
	pg.me:tryClientTrigger(triggerType, triggerId, count, params)
end

function ClientUtils.onSoundEmitterEvent(eventName, eventType, param)
	pg.game.audio:onSoundEmitterEvent(eventName, eventType, param)
end

function ClientUtils.getTTLs()
	if ClientRepo.msNetworkEventCallback and ClientRepo.msNetworkEventCallback:isConnected() then
		local playerTTL = ClientRepo.networkEventCallback:getTTL() or 0
		local serviceTTL = ClientRepo.msNetworkEventCallback:getTTL() or 0

		return playerTTL, serviceTTL
	end

	return 0, 0
end

function ClientUtils.getPlayerTTLs()
	if ClientRepo.msNetworkEventCallback and ClientRepo.msNetworkEventCallback:isConnected() then
		local playerTTL = ClientRepo.networkEventCallback:getTTL() or 0

		return playerTTL
	end

	return 0
end

function ClientUtils.playCutscene(resId, pos, rot, callback)
	return pg.game.cutscene:playCutscene(resId, resId, pos, rot, nil, nil, {
		endCallback = callback
	})
end

function ClientUtils.playCutsceneForResCheck(resId, resPath)
	local function callback(cutsceneCmd)
		CS.FunPlus.WorldX.Utils.WorldXProfiler.RuntimeResChecks.RuntimeResCheckLauncher.OnCutSceneCreated(cutsceneCmd.cutscene, resPath)
	end

	return pg.game.cutscene:playCutscene(resId, resId, nil, nil, nil, nil, {
		createCallback = callback
	})
end

function ClientUtils.createCutscene(resId, pos, rot)
	return pg.game.cutscene:createCutscene(resId, resId, pos, rot)
end

function ClientUtils.checkExploreLevel(petInfo, player)
	local newPData = PetData[petInfo.templateId]
	local groupInfo = player.prepareFormationList[1]
	local petIds = groupInfo.exploreFormation

	petIds = petIds:getRawTable()

	local curClimbLevel = 0
	local curFlyLevel = 0
	local curSwimLevel = 0
	local newClimbLevel = newPData.canClimb or 0
	local newFlyLevel = newPData.canFly or 0
	local newSwimLevel = newPData.canSwim or 0

	if petIds[1] and petIds[1] ~= "" then
		local pet = player:getPetInfo(petIds[1])
		local pData = PetData[pet.templateId]

		curClimbLevel = pData.canClimb or 0
	end

	if petIds[2] and petIds[2] ~= "" then
		local pet = player:getPetInfo(petIds[2])
		local pData = PetData[pet.templateId]

		curFlyLevel = pData.canFly or 0
	end

	if petIds[3] and petIds[3] ~= "" then
		local pet = player:getPetInfo(petIds[3])
		local pData = PetData[pet.templateId]

		curSwimLevel = pData.canSwim or 0
	end

	return curClimbLevel < newClimbLevel, curFlyLevel < newFlyLevel, curSwimLevel < newSwimLevel
end

function ClientUtils.findCanLinkedPetsInBag(baseTemplateId, baseFormPetId, petFamilyId, formName, stage, label)
	if not pg.me.pets then
		return {}
	end

	local function parseParam(param)
		if param == nil then
			return {}
		elseif Utils.isTable(param) then
			return param
		else
			return {
				param
			}
		end
	end

	local function inSet(values, target)
		for _, v in pairs(values) do
			if v == target then
				return true
			end
		end

		return false
	end

	local controlLevel = pg.me.actorCombatAttribute._baseAttr[AttributeConst.max_control_level]

	local function extraCondition(petInfo)
		if petInfo.level > controlLevel or pg.me:isPetPutInHomeland(petInfo) or pg.me:isPetActivityDispatching(petInfo) then
			return false
		end

		return true
	end

	local baseTemplateIds = parseParam(baseTemplateId)
	local baseFormPetIds = parseParam(baseFormPetId)
	local petFamilyIds = parseParam(petFamilyId)
	local formNames = parseParam(formName)
	local stages = parseParam(stage)
	local labels = parseParam(label)
	local hasBaseTemplate = #baseTemplateIds ~= 0
	local hasBaseFormPet = #baseFormPetIds ~= 0
	local hasPetFamily = #petFamilyIds ~= 0

	local function findFunc(petInfos, res)
		for _, petInfo in pairs(petInfos) do
			if extraCondition(petInfo) then
				local templateId = petInfo.templateId

				if templateId and templateId ~= 0 then
					local petData = PetData[templateId]

					if petData then
						local match = false

						if hasBaseTemplate then
							match = inSet(baseTemplateIds, templateId)
						elseif hasBaseFormPet then
							local formPetId = petData.baseFormPet or templateId

							match = inSet(baseFormPetIds, formPetId)
						elseif hasPetFamily then
							match = inSet(petFamilyIds, petData.ethnicGroup)
						end

						if match and #formNames ~= 0 then
							local petFormName = Utils.getPetFormNameByTemplateId(templateId)

							match = inSet(formNames, petFormName)
						end

						if match and #stages ~= 0 then
							match = inSet(stages, petInfo.stage)
						end

						if match and #labels ~= 0 then
							match = inSet(labels, petInfo.label)
						end

						if match then
							res[#res + 1] = {
								id = petInfo.id,
								uuid = petInfo.uuid,
								templateId = petInfo.templateId,
								customName = petInfo.customName,
								petPrototypeId = petInfo.petPrototypeId
							}
						end
					end
				end
			end
		end
	end

	local result = {}
	local isControllingPet = pg.me:isControllingPet() or false

	if isControllingPet then
		local curPetEntId = pg.me:getCurPetEntity().id
		local petInfo = pg.me:getPetInfo(curPetEntId)

		findFunc({
			petInfo
		}, result)

		if #result > 0 then
			return {}
		end
	end

	result = {}

	local pets = {}
	local prepareList = pg.me.petPrepareList or {}

	for _, petId in pairs(prepareList) do
		local petInfo = pg.me:getPetInfo(petId)

		pets[#pets + 1] = petInfo
	end

	findFunc(pets, result)

	if #result == 0 then
		pets = pg.me.pets or {}

		findFunc(pets, result)
	end

	return result
end

function ClientUtils.sortCanLinkedPetsInBag(result)
	if not result then
		return
	end

	local function getPetCpForSort(petInfo)
		if petInfo and type(petInfo.getCpValueForRank) == "function" then
			return petInfo:getCpValueForRank(1)
		end

		if petInfo and type(petInfo.getCpValue) == "function" then
			return petInfo:getCpValue()
		end

		return petInfo and petInfo.cp or 0
	end

	local function getLabelRank(curLabel)
		if Utils.isLabelMagic(curLabel) then
			return 5
		elseif Utils.isLabelVariant(curLabel) then
			return 4
		elseif Utils.isLabelElite(curLabel) then
			return 3
		elseif Utils.isLabelBoss(curLabel) then
			return 2
		elseif Utils.isLabelShiny(curLabel) then
			return 1
		end

		return 0
	end

	local function getFormRank(templateId)
		local formName = Utils.getPetFormNameByTemplateId(templateId)

		if not formName then
			return 0
		end

		return Const.FormName2Id[formName] or 0
	end

	table.sort(result, function(a, b)
		local cpA, cpB = getPetCpForSort(a), getPetCpForSort(b)

		if cpA ~= cpB then
			return cpB < cpA
		end

		local labelA = getLabelRank(a and a.label or 0)
		local labelB = getLabelRank(b and b.label or 0)

		if labelA ~= labelB then
			return labelB < labelA
		end

		local formA = getFormRank(a and a.templateId)
		local formB = getFormRank(b and b.templateId)

		if formA ~= formB then
			return formB < formA
		end

		local levelA, levelB = a and a.level or 0, b and b.level or 0

		if levelA ~= levelB then
			return levelB < levelA
		end

		local stageA, stageB = a and a.stage or 0, b and b.stage or 0

		if stageA ~= stageB then
			return stageB < stageA
		end

		return tostring(a and a.id or "") > tostring(b and b.id or "")
	end)
end

function ClientUtils.quickLinkByPetId(petId, callback)
	local petPrepareList = pg.me.petPrepareList
	local inBattle = Lume.find(petPrepareList, petId)

	if not inBattle then
		inBattle = #petPrepareList + 1
		inBattle = math.clamp(inBattle, 1, 4)
	end

	pg.me:serverMsg("RPC_CS_QuickBattlePet", petId, inBattle, function(result)
		if callback then
			callback(result)
		end
	end)
end

function ClientUtils.checkLinkedCondition()
	if pg.game.social.interactGestureComponent:checkInteractGesturePlaying() or pg.me.invasionInputDisabled or not pg.me:checkPetControlUnlock() or not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink) or pg.me:isInCatchMode() then
		return false
	end

	return true
end

function ClientUtils.computeFuseSwitchState(excludeConditions)
	if pg.game.seamless:seam_sys_isSwitchSeamless() then
		return nil, nil
	end

	if not pg.me then
		return nil, nil
	end

	local player = pg.me

	if player.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				player = pg.getEntity(info.entityId)
			end
		end
	end

	if not player then
		return nil, nil
	end

	local visible = not player:checkArkSceneState()
	local canSwitch = visible

	excludeConditions = excludeConditions or {}

	local fuseSwitchConditions = {
		{
			key = "beCarried",
			check = function()
				return pg.me:EGG_BE_CARRIED_ST()
			end,
			apply = function()
				visible = false
				canSwitch = false
			end
		},
		{
			key = "controllingEgg",
			check = function()
				return pg.me:isControllingEgg()
			end,
			apply = function()
				visible = true
				canSwitch = true
			end
		},
		{
			key = "specialMoveState",
			check = function()
				return CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.CLIMBING) or CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.GLIDING) or CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.SWIMMING)
			end,
			apply = function()
				visible = false
				canSwitch = false
			end
		},
		{
			key = "emptyPrepareList",
			check = function()
				return player:isPrepareListEmpty() and not player:isControllingExplorePet() and not player:isControllingEgg()
			end,
			apply = function()
				visible = false
				canSwitch = false
			end
		},
		{
			key = "chargeQte",
			check = function()
				return pg.game.qte:isInChargeQte()
			end,
			apply = function()
				visible = false
				canSwitch = false
			end
		},
		{
			key = "petLinkModule",
			check = function()
				return not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink)
			end,
			apply = function()
				canSwitch = false
			end
		},
		{
			key = "pvpEnv",
			check = function()
				return player.space and player.space:isPvpEnv()
			end,
			apply = function()
				canSwitch = false
			end
		},
		{
			key = "catchMode",
			check = function()
				return pg.me:isInCatchMode()
			end,
			apply = function()
				visible = false
				canSwitch = false
			end
		}
	}

	for _, condition in ipairs(fuseSwitchConditions) do
		if not table.contains(excludeConditions, condition.key) and condition.check() then
			condition.apply()

			break
		end
	end

	return canSwitch, visible
end

function ClientUtils.getUserName()
	return GlobalData.UserName
end

function ClientUtils.setPetVisibleInLevel(visible, isAllPet)
	pg.game:setPetVisibleInLevel(visible, isAllPet)
end

function ClientUtils.showBlackScreen(blackScreenId, endCb, eventContext)
	pg.global.ui.blackScreen:open({
		id = blackScreenId,
		finishCb = endCb,
		context = eventContext
	})
end

function ClientUtils.showWhiteScreen(whiteScreenId, endCb, eventContext)
	pg.global.ui.whiteScreen:open({
		id = whiteScreenId,
		finishCb = endCb,
		context = eventContext
	})
end

function ClientUtils.sequenceExecute(tasks, finalCallback)
	local index = 1

	local function next()
		if index <= #tasks then
			local task = tasks[index]

			index = index + 1

			local ret, errors = ClientUtils.tryWithLogError(function()
				task(next)
			end)

			if not ret then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("sequenceExecute execute task failed!")
				end

				finalCallback()
			end
		elseif finalCallback then
			finalCallback()
		end
	end

	next()
end

function ClientUtils.updateCursorState()
	pg.game.input:refreshCursorState()
end

function ClientUtils.onRogueGroundReady()
	local space = pg.me and pg.me.space

	if space and space.onRogueGroundReady and (space:isRogueEnv() or space:isBossRushEnv()) then
		space:onRogueGroundReady()
	end
end

function ClientUtils.isMainPlayerTeamMember(entityId)
	local entity = pg.getEntity(entityId)

	if pg.me and entity then
		return pg.me:isUidTeamMember(entity.uid) or false
	end

	return false
end

function ClientUtils.isFullScreenUI()
	local panelId = pg.global.ui:getLastNormalFirstPanel()
	local state, _ = pg.global.ui:getFullScreenVisibleState()
	local isLoadingShow = pg.global.ui.loadProgress:checkUIVisible()
	local cutscene = pg.game.cutscene:getCurCutScene()
	local hasCutscene = cutscene and cutscene:isPlaying() or false
	local dialogueGraph = pg.game.dialogue:isPlayingDialogueGraph()
	local normalDialogue = pg.game.communication:isInNormalDialogue()

	return panelId or state or hasCutscene or dialogueGraph or isLoadingShow or normalDialogue
end

function ClientUtils.isFullScreenVisible()
	return pg.global.ui:isFullScreenVisible()
end

function ClientUtils.inAfkMode()
	return pg.game.camera.playerCameraMode.inAfk
end

function ClientUtils.enterAfkMode()
	pg.game.camera.playerCameraMode:enterAfkMode()
end

function ClientUtils.exitAfkMode()
	pg.game.camera.playerCameraMode:exitAfkMode()
end

function ClientUtils.enterAfkActionState()
	if pg.me then
		pg.me:setActionState(Const.PlayerActionState.AFK)
	end
end

function ClientUtils.exitAfkActionState()
	if pg.me then
		local curUIActionState = pg.game.social and pg.game.social:getCurUIActionState() or 0

		if curUIActionState ~= Const.PlayerActionState.FuncMenu and curUIActionState ~= Const.PlayerActionState.CommonPanel then
			pg.me:setActionState(Const.PlayerActionState.None)
		end
	end
end

function ClientUtils.stopDialogueCameraDof()
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue, false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_AniimoHuge, false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_AniimoSmall, false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_HumanVSAniimo, false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_HumanVSHuman, false)
end

function ClientUtils.setTopLogoComponentVisible(compNames, visible)
	local param = {
		visibleKey = UIConst.TOPLOGO_VISIBLE_KEY.DIALOGUE,
		visible = visible,
		targetCompNames = compNames
	}

	facade:sendMsgToUI(MessageName.UI_ON_SET_TOPLOGO_COMPONENT_VISIBLE, param)
end

function ClientUtils.calVectorAngle(x1, y1, z1, x2, y2, z2)
	local dot = x1 * x2 + y1 * y2 + z1 * z2
	local len1 = math.sqrt(x1 * x1 + y1 * y1 + z1 * z1)
	local len2 = math.sqrt(x2 * x2 + y2 * y2 + z2 * z2)

	if len1 == 0 or len2 == 0 then
		return 0
	end

	return math.acos(dot / (len1 * len2)) * 180 / math.pi
end

function ClientUtils.onUButtonConsumeTrigger(luaClick, consumeId)
	if consumeId == 0 then
		return
	end

	ClientUtils.checkConsumeProp(consumeId, function()
		if not IsNil(luaClick) then
			xpcall(luaClick, debug.traceback)
		end

		pg.me:serverMsg("RPC_CS_CurrencyConsumeEvent", consumeId)
	end, function()
		return
	end)
end

function ClientUtils.checkConsumeProp(consumeId, confirm, cancel)
	if pg.me == nil then
		cancel()

		return
	end

	local cData = CurrencyConsumeData[consumeId]

	if cData == nil then
		cancel()

		return
	end

	local consume = cData.eventParam

	if #consume == 0 then
		confirm()

		return
	end

	local enough = true
	local id, num

	for _, v in ipairs(consume) do
		id = v[1]
		num = math.abs(v[2] or 0)

		local ownNum = ClientUtils.getItemCountById(id, true)

		if ownNum < num then
			enough = false

			break
		end
	end

	local notEnoughDesc = cData.notEnough

	local function notEnoughCallback(_id, _num)
		local cd = ItemData[_id]
		local icon = cd.icon
		local name = pg.getLocalizationText(cd.itemName)
		local content = pg.getGameString(notEnoughDesc)

		content = pg.getFormatText(content, name, _num)

		pg.global.ui.tips:showTextTip(content, 3, 1, nil, nil, icon)
	end

	local type = cData.remindType

	if type == 1 then
		pg.global.ui.commonUseConfirm:open({
			muteCheckEnough = false,
			title = pg.getLocalizationText(cData.titleTxt),
			data = consume,
			confirmCb = confirm,
			cancelCb = cancel,
			notEnoughCallback = notEnoughCallback
		})
	elseif type == 2 then
		if not enough then
			notEnoughCallback(id, num)
		else
			confirm()
		end
	end
end

function ClientUtils.checkIsHideEntity(entity)
	if EnableBotTest then
		return false
	end

	if not entity or entity.isDestroyed then
		return false
	end

	local isHideEntity = false

	if entity.isHideNpc then
		isHideEntity = true
	end

	if not GlobalData.Player then
		return isHideEntity
	end

	local hideShowDic = GlobalData.Player and GlobalData.Player.hideShowEntityDict or {}
	local hideShowInfo = GlobalData.Player and GlobalData.Player.hideShowEntityInfo or {}
	local hideShowDicVar = entity.staticId and entity.staticId ~= 0 and hideShowDic and hideShowDic[entity.staticId]
	local hideShowInfoVar = entity.staticId and entity.staticId ~= 0 and hideShowInfo and hideShowInfo[entity.staticId]

	if hideShowInfoVar and Utils.isTable(hideShowInfoVar) then
		for _, v in pairs(hideShowInfoVar) do
			if v then
				if v == 1 then
					isHideEntity = false

					break
				else
					isHideEntity = true
				end
			end
		end
	elseif hideShowDicVar then
		isHideEntity = hideShowDicVar ~= 1
	end

	return isHideEntity
end

function ClientUtils.hasNpcHideShowTimeConfig(staticId)
	if staticId == nil or staticId == 0 then
		return false
	end

	return NpcHideShowConfigData[staticId] ~= nil
end

function ClientUtils.checkNpcVisibleByHideShowTime(staticId)
	if not ClientUtils.hasNpcHideShowTimeConfig(staticId) then
		return true
	end

	local config = NpcHideShowConfigData[staticId]
	local startTime = Utils.getConfigTimeOfAreaByData(nil, config.startDayTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(nil, config.endDayTimeRefId)

	return TimeUtils.isInRangeTimestamp(startTime, endTime)
end

function ClientUtils.getClientAuthority(entity)
	if Utils.isServerPuppet(entity) then
		return Const.AUTHORITY_AUTONOMOUS_PROXY
	end

	local master = entity.getMasterEntity and entity:getMasterEntity() or nil

	if master and Utils.isServerPuppet(master) then
		return Const.AUTHORITY_AUTONOMOUS_PROXY
	end

	if entity.isMainPlayer then
		return Const.AUTHORITY_MASTER
	end

	if Utils.isNpc(entity) and Utils.checkIsInTown(entity) then
		return Const.AUTHORITY_MASTER
	end

	if not GlobalData.Player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			entity.logger:error("other entity create before player,may cause a wrong authority")
		end

		return Const.AUTHORITY_SIMULATED_PROXY
	end

	if entity.authorityId == GlobalData.Player.id then
		return Const.AUTHORITY_MASTER
	else
		return Const.AUTHORITY_SIMULATED_PROXY
	end
end

function ClientUtils.getClientMainAuthority(entity)
	if Utils.isNpc(entity) and Utils.checkIsInTown(entity) then
		return true
	end

	local entityAuthority = entity.authority or ClientUtils.getClientAuthority(entity)

	return entityAuthority == Const.AUTHORITY_MASTER
end

function ClientUtils.isClientMainAuthority(authority)
	return authority == Const.AUTHORITY_MASTER
end

function ClientUtils.getEnablePosSync(entity)
	if not Utils.checkIsAuthorityMaster(entity) then
		return false
	end

	if entity.aoi then
		local entityCanMove = entity.entityCanMove

		if entityCanMove == nil then
			entityCanMove = false
		end

		local overrideState = entity.getPosSyncOverrideState and entity:getPosSyncOverrideState()

		if overrideState ~= nil then
			return overrideState
		end

		if Utils.isNpc(entity) then
			if Utils.checkIsInTown(entity) or Utils.isStaticNpc(entity) then
				return false
			else
				return entityCanMove
			end
		end

		return entityCanMove
	end

	return false
end

function ClientUtils.onHairCommandOperated(partId, resId)
	local configId = AvatarHairResIdToConfig[resId]

	pg.game.avatar:updateHairSelection(partId, configId, "onHairCommandOperated")
end

function ClientUtils.leaveSpace(ent)
	ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
		ent:serverMsg("RPC_CS_QuitSpace")
	end)
end

function ClientUtils.onVoxelSceneChanged()
	if pg.game and pg.game.voxel then
		pg.game.voxel:resetMutableRegionCache()
	end

	local space = pg.space

	if not space then
		return
	end

	local spaceId = space.id

	VoxelUtils.setSpanDataFilter(spaceId, VoxelConst.VoxelMaterialDef.Ocean_1)

	local tickFrameCount = VoxelConst.MUTABLE_REGION_TICK_FRAME_COUNT

	VoxelUtils.setVoxelTickFrameCount(spaceId, IS_MOBILE and tickFrameCount.MOBILE or tickFrameCount.DEFAULT)
	VoxelUtils.setVoxelTimeScale(spaceId, pg.game and pg.game.globalTimeScale or 1)
end

function ClientUtils.getClientCatchInfo(actorId)
	local itemId = pg.global.ui.hudV2:getCurSelectPropId()
	local targetEnt = pg.getEntityByActorId(actorId)

	if not targetEnt then
		return
	end

	return Utils.getDebugCatchInfo(pg.me, targetEnt, itemId)
end

function ClientUtils.getServerCatchInfo()
	if not pg.me then
		return {}
	end

	local serverCatchInfos = {}

	for i = 1, #pg.me.debugCatchInfos do
		local info = pg.me.debugCatchInfos[i]

		if info then
			local data = Utils.decodeFromStr(info)

			if data then
				local temp = string.split(data[1], "_")
				local timeStr = TimeUtils.timeStampToUtcString(temp and temp[1])
				local templateId = temp and temp[2]
				local catchResult = temp and temp[3]
				local catchInfo = {
					timeStamp = temp[1],
					timeStr = timeStr,
					templateId = templateId,
					catchResult = catchResult
				}

				table.merge(catchInfo, data[2])
				table.insert(serverCatchInfos, catchInfo)
			end
		end
	end

	return serverCatchInfos
end

function ClientUtils.gc()
	local oldMem = collectgarbage("count")

	collectgarbage("collect")

	local newMem = collectgarbage("count")

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("gc before %d, end %d", oldMem, newMem)
	end

	pg.global.resMgr:UnloadUnusedAssetDetail(3000, 100, 3, 1)
end

function ClientUtils.gcImmediately()
	local oldMem = collectgarbage("count")

	collectgarbage("collect")

	local newMem = collectgarbage("count")

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("gc before %d, end %d", oldMem, newMem)
	end

	pg.global.resMgr:UnloadUnusedAssetDetail(0, 0, 0, 1)
end

function ClientUtils.isPublicClient()
	local envType = ClientConfigEnvType

	if envType > 0 then
		return true
	end

	return false
end

function ClientUtils.getEntityTopLogoFollowStrategy(entity)
	if not entity then
		return
	end

	local configData = entity:getConfigData()

	if configData.topLogoOffsetType and configData.topLogoOffsetType > 0 then
		return configData.topLogoOffsetType
	else
		local prefabResID = configData.prefabResID
		local modelInfoRef = configData.modelInfoRef

		if configData.appearanceResID or prefabResID and string.find(prefabResID, "Avatar") or modelInfoRef and string.find(modelInfoRef, "Avatar") then
			return ClientConst.TopLogoFollowStrategy.Head
		else
			return ClientConst.TopLogoFollowStrategy.FxRoot
		end
	end
end

function ClientUtils.getEntityTopLogoHeight(entity, mStrategy, entry)
	if not entity then
		return
	end

	local configData = entity:getConfigData()
	local scale = entity.curModelScale or 1
	local modelHeight = configData.modelHeight
	local strategy = entity.topLogoData.strategy

	if configData.topLogoOffsetNoScale then
		return configData.topLogoOffsetNoScale
	end

	if configData.topLogoOffset then
		return configData.topLogoOffset * scale
	end

	if strategy == ClientConst.TopLogoFollowStrategy.Head then
		local res = false
		local headRadius = 0

		if entity.eModel then
			res, headRadius = entity.eModel:TryGetHeadRadius(Const.COMPONENT_INDEX_MODEL)
		end

		if not res and entry == TopLogoConst.GET_TOPLOGO_HEIGHT_ENTRY.ON_SKELETON_LOADED and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@sxy actorId = %s templateId = %s, headRadius = %s, prefabResID = %s; topLogo预期挂接策略为头部，但无法获取到头部配置。", entity.actorId, entity.templateId, headRadius or 0, configData.prefabResID or "nil")
		end

		return headRadius * scale + 0.15
	else
		modelHeight = modelHeight or entity:getHeight()

		return modelHeight * scale + 0.2
	end
end

function ClientUtils.uploadPicture(key, sprite, callback, jpgQuality)
	local function getUrlCb(retStatus, response)
		if retStatus.status then
			local rawUrl = string.sub(response.value, 9)
			local imgUrl = "https://" .. rawUrl

			local function uploadCallback(success)
				if callback then
					callback(key, success, success and imgUrl or nil)
				end

				if not success and LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("uploadPicture UploadSpriteToUrl error: ", key)
				end
			end

			if jpgQuality then
				pg.global.mobileCameraMgr:UploadSpriteToUrl(sprite, imgUrl, uploadCallback, jpgQuality)
			else
				pg.global.mobileCameraMgr:UploadSpriteToUrl(sprite, imgUrl, uploadCallback)
			end
		else
			if callback then
				callback(key, false)
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("uploadPicture getPictureUrl error: ", key, inspect(retStatus))
			end
		end
	end

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	ServiceUtils.callService("KvService", "addPictureUrl", {
		key
	}, getUrlCb, {
		hint = key
	})
end

function ClientUtils.pullPicture(key, callback)
	local function getUrlCb(retStatus, response)
		if retStatus.status then
			local rawUrl = string.sub(response.value, 9)
			local imgUrl = "https://" .. rawUrl

			pg.global.mobileCameraMgr:DownloadSpriteFromUrl(imgUrl, function(sprite)
				if callback then
					callback(key, sprite)
				end

				if not sprite and LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("pullPicture DownloadSpriteFromUrl error: ", key)
				end
			end)
		else
			if callback then
				callback(key, nil)
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("pullPicture getPictureUrl error: ", key)
			end
		end
	end

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	ServiceUtils.callService("KvService", "getPictureUrl", {
		key
	}, getUrlCb, {
		hint = key
	})
end

function ClientUtils.loadSpriteFromPhotoUrl(photoUrl, callback)
	local isUrl = type(photoUrl) == "string" and (string.startsWith(photoUrl, "https://") or string.startsWith(photoUrl, "http://"))

	if not isUrl then
		if callback then
			callback(nil)
		end

		return
	end

	local pictureKey = string.match(photoUrl, "/picture/([^/?#]+)")

	if pictureKey then
		ClientUtils.pullPicture(pictureKey, function(_, sprite)
			if callback then
				callback(sprite)
			end
		end)

		return
	end

	pg.global.mobileCameraMgr:DownloadSpriteFromUrl(photoUrl, function(sprite)
		if callback then
			callback(sprite)
		end
	end)
end

function ClientUtils.deletePicture(key, callback)
	local function cb(retStatus, response)
		if retStatus.status then
			if callback then
				callback(key, nil)
			end
		else
			if callback then
				callback(key, 101)
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("deletePicture error: ", key)
			end
		end
	end

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	ServiceUtils.callService("KvService", "deletePicture", {
		key
	}, cb, {
		hint = key
	})
end

function ClientUtils.refreshPlayerAndPetsModel()
	if pg.me then
		pg.me:refreshAppearance()
		ClientEffectUtils.applyCommonMountEffects(pg.me)

		for index, petId in ipairs(pg.me.petPrepareList) do
			local petEntity = pg.getEntity(petId)

			if petEntity then
				petEntity:refreshAppearance()
				ClientEffectUtils.applyCommonMountEffects(petEntity)
			end
		end
	end
end

function ClientUtils.getPetEntryBuffUIoffset(petEnt)
	local configData = petEnt and petEnt:getConfigData()
	local petPrototypeId = configData and configData.petPrototypeId or 0
	local offsetX = PetPrototypeData[petPrototypeId] and PetPrototypeData[petPrototypeId].entryBuffUIOffsetX or 0
	local offsetY = PetPrototypeData[petPrototypeId] and PetPrototypeData[petPrototypeId].entryBuffUIOffsetY or 0

	return offsetX, offsetY
end

function ClientUtils.addEntityTag(actorId, tag)
	local ent = pg.getEntityByActorId(actorId)

	Utils.addEntityTag(ent, tag)
end

function ClientUtils.removeEntityTag(actorId, tag)
	local ent = pg.getEntityByActorId(actorId)

	Utils.removeEntityTag(ent, tag)
end

function ClientUtils.checkHomeCampUnlock(campId)
	local m = pg.me.homeBasicInfo and pg.me.homeBasicInfo.unlockedHomeCampIds

	return m and m[tostring(campId)] == true
end

function ClientUtils.addMarqueeText(textHashId, count)
	count = count or 1

	for i = 1, count do
		pg.global.ui.tips:addMarqueeText(textHashId)
	end
end

function ClientUtils.checkEnableRendererBatch()
	return ClientConst.EnableRendererBatch and ClientSwitch.EnableRendererBatch
end

function ClientUtils.setL10nUCountDownTextFunc(ucountDownComp)
	if not ucountDownComp then
		return
	end

	function ucountDownComp.onGetL10nFormatText(formatStr)
		return ClientUtils.getL10nUCountDownText(formatStr)
	end
end

function ClientUtils.getL10nUCountDownText(formatStr)
	if not formatStr then
		return ""
	end

	local unitMap = {
		毫秒 = "",
		秒 = "SECOND",
		分 = "MINUTE",
		时 = "HOUR",
		天 = "DAY"
	}
	local retStr = formatStr

	for chineseUnit, l10nKey in pairs(unitMap) do
		retStr = string.gsub(retStr, chineseUnit, l10nKey and l10nKey ~= "" and pg.getGameString(l10nKey) or "")
	end

	return retStr
end

local HomeLandUtils = require("Common.Utils.HomeLandUtils")

function ClientUtils.getHomeFacilityEntityIdForCS(facilityParam)
	local luaEnt = HomeLandUtils.getHomeFacilityEntity(pg.me, facilityParam)

	if not luaEnt or not luaEnt.id then
		return nil
	end

	return luaEnt.id
end

function ClientUtils.getHomeFacilityPointPoseForCS(facilityParam)
	local ok, pos, rot = HomeLandUtils.getHomeFacilityPointPose(pg.me, facilityParam)

	if not ok then
		return {
			ok = false
		}
	end

	return {
		ok = true,
		pos = pos,
		rot = rot
	}
end

function ClientUtils.addResource(resourceType, key, data, callback)
	local function getUrlCb(retStatus, response)
		if retStatus.status then
			local rawUrl = string.sub(response.value, 9)
			local idx = string.find(rawUrl, "/")
			local host = string.sub(rawUrl, 1, idx - 1)
			local path = string.sub(rawUrl, idx)

			local function pushDataCb(reply)
				if reply.err == 0 and string.find(reply.body, "<Error>") == nil then
					if callback then
						callback(key, true)
					end
				else
					if callback then
						callback(key, false)
					end

					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error("addResource httpRequest error: ", key, rawUrl, reply.err)
					end
				end
			end

			local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
			local HttpRequest = require("Core.Net.Http.HttpRequest")
			local proxy = HttpClientProxy()
			local json = require("json")

			data = json.encode(data)

			local request = HttpRequest(host, nil, HttpRequest.Method.PUT, path, nil, data, false)

			proxy:httpRequest(request, 5000, pushDataCb, false)
		else
			if callback then
				callback(key, false)
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("addResource getResourceUrl error: ", key)
			end
		end
	end

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	ServiceUtils.callService("KvService", "resourceUrl", {
		resourceType,
		key,
		"put"
	}, getUrlCb, {
		hint = key
	})
end

function ClientUtils.pullResource(resourceType, key, callback)
	local function getUrlCb(retStatus, response)
		if retStatus.status then
			local rawUrl = string.sub(response.value, 9)
			local idx = string.find(rawUrl, "/")
			local host = string.sub(rawUrl, 1, idx - 1)
			local path = string.sub(rawUrl, idx)

			local function pullDataCb(reply)
				local body = reply.body or ""
				local httpStatus = tonumber(reply.header and reply.header.HTTP_STATUS)
				local ossErrorCode = string.match(body, "<Code>([^<]+)</Code>")
				local isNotFound = reply.err == 0 and (ossErrorCode == "NoSuchKey" or httpStatus == 404 and ossErrorCode == nil)
				local isHttpSuccess = httpStatus == nil or httpStatus >= 200 and httpStatus < 300

				if isNotFound then
					if callback then
						callback(key, nil)
					end
				elseif reply.err == 0 and isHttpSuccess and string.find(body, "<Error>") == nil then
					if callback then
						local json = require("json")
						local data = json.decode(body)

						callback(key, data)
					end
				else
					if callback then
						callback(key, nil)
					end

					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error("pullResource httpRequest error: key=", key, " err=", reply.err, " httpStatus=", httpStatus or "", " ossCode=", ossErrorCode or "")
					end
				end
			end

			local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
			local HttpRequest = require("Core.Net.Http.HttpRequest")
			local proxy = HttpClientProxy()
			local request = HttpRequest(host, nil, HttpRequest.Method.GET, path, nil, nil, false)

			proxy:httpRequest(request, 5000, pullDataCb, false)
		else
			if callback then
				callback(key, nil)
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("pullResource getResourceUrl error: ", key)
			end
		end
	end

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	ServiceUtils.callService("KvService", "resourceUrl", {
		resourceType,
		key,
		"get"
	}, getUrlCb, {
		hint = key
	})
end

local SafeCallback = require("Core.Framework.SafeCallback")

local function requestBinaryResource(resourceType, key, action, data, callback, directUrl, onUrl, onUrlContext, urlOnly, callbackContext, callbackContext2)
	local isPull = action == "get"
	local failedResult = false

	if isPull then
		failedResult = nil
	end

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	local function finishUrlError(errorType)
		if callback then
			SafeCallback(callback, key, failedResult, errorType or "url_error", nil, callbackContext, callbackContext2)
		end
	end

	local function useUrl(url, urlSource)
		local hostStart, ssl

		if type(url) == "string" then
			if string.find(url, "https://", 1, true) == 1 then
				hostStart = 9
				ssl = true
			elseif string.find(url, "http://", 1, true) == 1 then
				hostStart = 8
				ssl = false
			end
		end

		local pathStart = hostStart and string.find(url, "/", hostStart, true)

		if not pathStart or pathStart == hostStart then
			finishUrlError("url_error")

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("binary resource invalid url: action=%s key=%s source=%s", action, key, tostring(urlSource))
			end

			return
		end

		if onUrl then
			SafeCallback(onUrl, onUrlContext, key, url, urlSource)
		end

		if urlOnly == true then
			if callback then
				SafeCallback(callback, key, url, nil, nil, callbackContext, callbackContext2)
			end

			return
		end

		local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
		local HttpRequest = require("Core.Net.Http.HttpRequest")
		local method = isPull and HttpRequest.Method.GET or HttpRequest.Method.PUT
		local request = HttpRequest(string.sub(url, hostStart, pathStart - 1), nil, method, string.sub(url, pathStart), nil, data, ssl)

		HttpClientProxy():httpRequest(request, 5000, function(reply)
			local replyHeader = reply and reply.header
			local replyBody = reply and reply.body
			local replyErr = reply and reply.err
			local httpStatus = tonumber(replyHeader and replyHeader.HTTP_STATUS)
			local success = reply ~= nil and replyErr == 0 and httpStatus ~= nil and httpStatus >= 200 and httpStatus < 300
			local isNotFound = not success and isPull and reply ~= nil and replyErr == 0 and httpStatus == 404
			local errorType = not success and (isNotFound and "not_found" or "http_error") or nil

			if callback then
				local result = success

				if isPull then
					result = success and replyBody or nil
				end

				SafeCallback(callback, key, result, errorType, httpStatus, callbackContext, callbackContext2)
			end

			if not success and not isNotFound and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("binary resource http error: action=%s key=%s err=%s status=%s", action, key, replyErr or "nil", httpStatus or "unknown")
			end
		end, false)
	end

	if type(directUrl) == "string" and directUrl ~= "" then
		useUrl(directUrl, "cache")

		return
	end

	local function getUrlCb(retStatus, response)
		if not retStatus or not retStatus.status then
			finishUrlError("url_error")

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("binary resource url error: action=%s key=%s error=%s", action, key, retStatus and retStatus.errmsg or "unknown")
			end

			return
		end

		useUrl(response and response.value, "service")
	end

	local serviceArgs = {
		resourceType,
		key,
		action
	}
	local serviceOptions = {
		timeout = 5,
		hint = key
	}

	ServiceUtils.callService("KvService", "resourceUrl", serviceArgs, getUrlCb, serviceOptions)
end

function ClientUtils.addBinaryResource(resourceType, key, data, callback, directUrl, onUrl, onUrlContext, callbackContext)
	if type(data) ~= "string" then
		if callback then
			SafeCallback(callback, key, false, "invalid_data", nil, callbackContext)
		end

		return
	end

	requestBinaryResource(resourceType, key, "put", data, callback, directUrl, onUrl, onUrlContext, false, callbackContext)
end

function ClientUtils.requestBinaryResourcePutUrl(resourceType, key, callback, callbackContext)
	requestBinaryResource(resourceType, key, "put", nil, callback, nil, nil, nil, true, callbackContext)
end

function ClientUtils.pullBinaryResource(resourceType, key, callback, callbackContext, callbackContext2)
	requestBinaryResource(resourceType, key, "get", nil, callback, nil, nil, nil, false, callbackContext, callbackContext2)
end

function ClientUtils.isInDouYinOfflineScene()
	return pg.me and pg.me.isClientEnt and pg.me.sceneId == Const.DOUYIN_OFFLINE_SCENE_ID
end

function ClientUtils.clearDirtyDataInPool(clearLevelOrTableCount, canClearCurrentFrameDataOrListCount, maxClearDirtyCallbackCount)
	Utils.clearDirtyDataInPool(clearLevelOrTableCount, canClearCurrentFrameDataOrListCount, maxClearDirtyCallbackCount)
end

function ClientUtils.checkModuleGrayEnabled(key)
	if type(key) ~= "string" or key == "" then
		return true
	end

	local probabilities = appFacade.luaManager:GetModuleGrayProbability(key)

	if not probabilities or probabilities.Count == 0 then
		return true
	end

	local probability = 0
	local platformIndex

	if UNITY_ANDROID then
		platformIndex = 0
	elseif UNITY_IOS then
		platformIndex = 1
	elseif UNITY_STANDALONE then
		platformIndex = 2
	end

	if not platformIndex then
		return false
	end

	if platformIndex < probabilities.Count then
		probability = tonumber(probabilities[platformIndex]) or 0
	end

	local maxValue = 100

	probability = math.max(0, math.min(maxValue, probability))

	logger:info("[ModuleGray] 配置模块: key=%s, 启用概率=%s", key, tostring(probability))

	if probability <= 0 then
		return false
	end

	if probability < maxValue then
		local random = math.random(0, maxValue)

		logger:info("[ModuleGray] 配置模块: key=%s, 随机值=%s", key, random)

		return random < probability
	end

	return true
end

return ClientUtils
