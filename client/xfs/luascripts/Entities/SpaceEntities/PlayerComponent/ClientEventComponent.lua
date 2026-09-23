-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientEventComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local TriggerConst = require("Common.Const.TriggerConst")
local SafeCallback = require("Core.Framework.SafeCallback")
local SafeCallbackWithReturn = require("Core.Framework.SafeCallbackWithReturn")
local StringEx = require("Core.Framework.String")
local lume = require("Core.Common.lume")
local CommonSwitch = require("Common.CommonSwitch")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local Bitset = require("Common.Bitset")
local Queue = require("Core.Framework.Queue")
local PlayableConst = require("Common.Const.PlayableConst")
local AudioConst = require("Const.AudioConst")
local DialogueConst = require("Const.DialogueConst")
local SysConfigData = require("Data.sys_config_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local EventEnumData = require("Data.event_enum_data")
local NoticeDef = require("Common.NoticeDef")
local ClientConst = require("Const.ClientConst")
local RoguelikeData = require("Data.roguelike_data")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local GlobalData = require("Core.Client.GlobalData")
local LeylineTreeData = require("Data.leylinetree_data")
local CTRPool = require("Common.AICt.CTRPool")
local ArkSlotMachineData = require("Data.ark_slotmachine_data")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LevelConditionData = require("Data.level_condition_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local RogueConst = require("Const.RogueConst")
local TimerManager = require("Core.Timer.TimerManager")
local RogueUtils = require("Utils.RogueUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local FunctionUnlockUIIdData = require("Data.function_unlock_ui")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local BossRushUtils = require("Utils.BossRushUtils")
local ShopClassifyData = require("Data.shop_classify_data")
local getBit = Bitset.getBit
local ClientSwitch = require("Common.ClientSwitch")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")
local EffectConst = require("Const.EffectConst")
local ItemSourceData = require("Data.item_source_data")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local BlackScreenData = require("Data.black_screen_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCampData = require("Data.home_camp_data")
local HomeSeasonCelebrationData = require("Data.home_season_celebration_data")
local HomelandConfigData = require("Data.homeland_config_data")
local AppearanceAction = require("Data.appearance_action_data")
local PlayerBadgeData = require("Data.player_badge_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local NavMeshServiceUtils = require("Common.Utils.NavMeshServiceUtils")
local DEFAULT_LEYLINE_TREE_ID = 200011
local ID_DIALOGUE_MOVE = "dialogueMove"
local ID_DIALOGUE_ROTATE = "dialogueRotate"
local ClientEventComponent = class.Component("ClientEventComponent")
local getBit = Bitset.getBit

function ClientEventComponent:start()
	self.eventCacheList = {}
	self.eventCacheMap = {}

	self.eventMap:startEventTimer()
end

function ClientEventComponent:destroy()
	self.eventCacheList = nil
	self.eventCacheMap = nil

	self.eventMap:removeEventTimer()
end

function ClientEventComponent:checkEvent(eventId, context)
	return self.eventMap:checkSysEvent(eventId, context)
end

function ClientEventComponent:checkEventByData(eventData, context)
	return self.eventMap:checkSysEventByData(eventData, context)
end

function ClientEventComponent:doEvent(eventId, context)
	self.eventMap:onSysEvent(eventId, context)
end

function ClientEventComponent:doEventByData(eventData, context)
	self.eventMap:onSysEventByData(eventData, context)
end

function ClientEventComponent:_checkClientEvent(eventName, param, context)
	local funName = "checkEvent_" .. eventName

	if self[funName] == nil then
		return true, NoticeDef.SUCCESS
	end

	return SafeCallbackWithReturn(self[funName], self, param or {}, context)
end

function ClientEventComponent:_doClientEvent(eventName, param, context)
	local funName = "event_" .. eventName
	local handler = self[funName]

	handler = handler or ClientEventComponent[funName]

	if not handler then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("_doClientEvent no function, funName=%s", funName, self:repr())
		end

		return
	end

	SafeCallback(handler, self, param or {}, context or {})
end

function ClientEventComponent:_doServerEvent(eventName, param, context)
	self:serverMsg("RPC_CS_doEventFromClient", eventName, param or {}, context or {})
end

function ClientEventComponent:finishRepeatEvent(context)
	return
end

function ClientEventComponent:RPC_SC_doEventFromServer(eventName, param, context)
	local endd = EventEnumData[eventName]

	if endd == nil or endd.eventFlag ~= "c" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_doEventFromServer config error", eventName, inspect(endd), self:repr())
		end

		return
	end

	if not pg.game.loading:isFinished() and Const.EVENT_ASYNC[eventName] then
		local eventId = context and context.eventId

		if eventId and self.eventCacheMap[eventId] then
			return
		end

		local cacheCount = #self.eventCacheList

		if cacheCount > Const.MAX_EVENT_CACHE_SIZE then
			self.logger:error("RPC_SC_doEventFromServer warning: Loading期间收到大量客户端事件，请排查异常配置！")
		end

		local info = {
			eventName = eventName,
			param = param,
			context = context
		}
		local curPriority = Const.EVENT_ASYNC[eventName]
		local insertPos = cacheCount + 1

		for i, existingEvent in ipairs(self.eventCacheList) do
			local targetPriority = Const.EVENT_ASYNC[existingEvent.eventName] or 999

			if curPriority < targetPriority then
				insertPos = i

				break
			end
		end

		self:addCacheEvent(info, insertPos)

		if pg.game.loading:isFinished() then
			self:doCacheEvents()
		end

		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_doEventFromServer", eventName, inspect(param), inspect(context), self:repr())
	end

	self:startDoClientEvent(eventName, param, context)
end

function ClientEventComponent:RPC_SC_BlackScreen(id, context)
	self:openBlackScreen(id, context)
end

function ClientEventComponent:doCacheEvents()
	if self.isProcessingEvents or self.eventCacheList == nil or #self.eventCacheList == 0 then
		return
	end

	self.isProcessingEvents = true

	self:processNextEvent()
end

function ClientEventComponent:processNextEvent()
	while #self.eventCacheList > 0 do
		local info = self:removeCacheEvent(1)

		if not info then
			break
		end

		local isAsync = Const.EVENT_ASYNC[info.eventName]
		local hasCalled = false

		local function onComplete()
			if self.eventCacheList == nil then
				return
			end

			if not hasCalled then
				hasCalled = true

				self:processNextEvent()
			end
		end

		local context = Utils.deepCopyTable(info.context) or {}

		context.callback = onComplete

		SafeCallback(self.startDoClientEvent, self, info.eventName, info.param, context)

		if isAsync then
			return
		elseif not hasCalled then
			hasCalled = true
		else
			return
		end
	end

	self.isProcessingEvents = false
end

function ClientEventComponent:startDoClientEvent(eventName, param, context)
	self.eventMap:registerSysEvent(eventName, param, context.eventDelay, context)
end

function ClientEventComponent:resetReTriggerEvents()
	if pg.game.isReTriggerEvent then
		if pg.global.ui:checkUIShow(UIConst.UI_ID_LOADING) then
			pg.global.ui:close(UIConst.UI_ID_LOADING)
		end

		if pg.global.ui:checkUIShow(UIConst.UI_ID_LOADING_SHOW) then
			pg.global.ui:close(UIConst.UI_ID_LOADING_SHOW)
		end
	end

	pg.game.isReTriggerEvent = nil

	self:removeCheckTeleportTimer()
end

function ClientEventComponent:notifyReTriggerEvents()
	if pg.game.isReTriggerEvent == true then
		pg.game.isReTriggerEvent = nil

		return
	end

	if pg.game.dialogue:isPlayingDialogueGraph() or pg.game.dialogue:isPreparingToPlayDialogueGraph() then
		return
	end

	local ret = self:reTriggerEvent(self.reTriggerCallback)

	self:reTriggerCallback(ret)
end

function ClientEventComponent:reTriggerCallback(ret)
	if not ret then
		pg.me:doCacheEvents()
	end
end

function ClientEventComponent:reTriggerEvent(callback)
	if not self:canReTriggerEvent() then
		pg.game.isReTriggerEvent = nil

		return false
	end

	local needConfirm = self:needConfirmReTriggerEvent()

	if not needConfirm then
		pg.game.isReTriggerEvent = true

		self:serverMsg("RPC_CS_StartReTriggerEvent", true)

		if callback then
			callback(self, true)
		end

		return true
	end

	local title = pg.getGameString("QUEST_EVENT_REPEAT_TITLE")

	pg.global.showConfirmMsgRaw(title, nil, function()
		pg.game.isReTriggerEvent = true

		self:serverMsg("RPC_CS_StartReTriggerEvent", true)

		if callback then
			callback(self, true)
		end
	end, false, function()
		pg.game.isReTriggerEvent = nil

		if callback then
			callback(self, false)
		end
	end, nil, nil)

	return true
end

function ClientEventComponent:canReTriggerEvent()
	if not self.reTriggerEvents or #self.reTriggerEvents == 0 then
		return false
	end

	if not self.eventCacheList or #self.eventCacheList == 0 then
		return true
	end

	for i = 1, #self.reTriggerEvents do
		local targetEvent = self.reTriggerEvents[i]

		if not self.eventCacheMap[targetEvent.eventId] then
			return true
		end
	end

	return false
end

function ClientEventComponent:needConfirmReTriggerEvent()
	if not ClientSwitch.EnableConfirmReTriggerEvent then
		return false
	end

	if not self.reTriggerEvents or #self.reTriggerEvents == 0 then
		return false
	end

	for i = 1, #self.reTriggerEvents do
		local targetEvent = self.reTriggerEvents[i]

		if targetEvent.reTriggerCount == 0 then
			return false
		end
	end

	return true
end

function ClientEventComponent:getReTriggerEvent(eventId)
	if self.reTriggerEvents == nil then
		return
	end

	for i = 1, #self.reTriggerEvents do
		local targetEvent = self.reTriggerEvents[i]

		if targetEvent.eventId == eventId then
			return targetEvent
		end
	end
end

function ClientEventComponent:addCacheEvent(eventInfo, posIndex)
	local eventId = eventInfo.context and eventInfo.context.eventId

	if eventId and self.eventCacheMap[eventId] then
		return
	end

	if posIndex then
		table.insert(self.eventCacheList, posIndex, eventInfo)
	else
		table.insert(self.eventCacheList, eventInfo)
	end

	if eventId then
		self.eventCacheMap[eventId] = true
	end
end

function ClientEventComponent:removeCacheEvent(posIndex)
	local info = table.remove(self.eventCacheList, posIndex)

	if info and info.context and info.context.eventId then
		self.eventCacheMap[info.context.eventId] = nil
	end

	return info
end

function ClientEventComponent:event_clientSetMarkStates(eventParam)
	if not eventParam then
		return
	end

	local markInfos, status, isCover = eventParam[1], eventParam[2], eventParam[3]

	if markInfos == nil or status == nil then
		return
	end

	self:doEventByData({
		"setMarkStates",
		{
			markInfos,
			status,
			isCover
		}
	})
end

function ClientEventComponent:event_shop(eventParam, eventContext)
	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	local shopClassCfg = ShopClassifyData[eventParam[1]]

	if not shopClassCfg then
		return
	end

	if shopClassCfg.type == 1 then
		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = eventParam,
			npcGlobalId = eventContext and eventContext.globalId,
			shopTag = eventParam[2]
		})
	else
		pg.global.ui:open(UIConst.UI_ID_SHOP_TRANS, {
			shopTags = eventParam,
			npcGlobalId = eventContext and eventContext.globalId,
			shopClassCfg = shopClassCfg,
			shopTag = eventParam[2]
		})
	end
end

function ClientEventComponent:event_openStreamForceBind(eventParam, eventContext)
	local sdkManager = pg.global.sdkManager

	if sdkManager:canSteamBindEmail() then
		sdkManager:forceBindEmail()

		return
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("BIND_EMAIL_SUCCESS"))
end

function ClientEventComponent:event_openUI(eventParam, eventContext)
	local uiName = eventParam[1]

	if not LuaUIUtils.checkUIFuncValid(uiName) then
		return
	end

	local uiParam = eventParam[2]
	local uiOpenCb = eventContext and eventContext.uiOpenCb or nil
	local openInfo = {}

	openInfo.uiContext = {}
	openInfo.uiContext.npcGlobalId = eventContext and eventContext.globalId

	if uiParam then
		if type(uiParam) == "table" then
			table.merge(openInfo, uiParam)
		else
			openInfo[1] = uiParam
		end
	end

	local checkRet = self:customCheckCanOpen(uiName, openInfo)

	if not checkRet then
		return
	end

	if (uiName == UIConst.UI_ID_CASH_SHOP or uiName == UIConst.UI_ID_BP_PERMIT) and pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
		PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

		return
	end

	if uiName == UIConst.UI_ID_APPEARANCE_V2 then
		LuaUIUtils.openPlayerAppearancePanel(nil, uiOpenCb)
	elseif uiName == UIConst.UI_ID_PLAYER_ENHANCEMENT then
		LuaUIUtils.openPlayerEnhance({
			defaultPlayerActive = false,
			defaultMode = uiParam,
			defaultTreeId = eventParam[3]
		}, uiOpenCb)
	elseif uiName == UIConst.UI_ID_ITEM_VIEWER then
		LuaUIUtils.openItemViewer(uiParam, uiOpenCb)
	elseif uiName == UIConst.UI_ID_PVP_MENU then
		LuaUIUtils.openPVPMenu(uiParam, uiOpenCb)
	elseif uiName == UIConst.UI_ID_PHOTO then
		pg.global.ui.hudV2:openPhotoPanel()
	elseif uiName == UIConst.UI_ID_TOWER_SETTLEMENT then
		if self:checkShowExchangeRewardWarning(RoguelikeData[pg.me.curRogueLayer]) then
			pg.global.showConfirmMsgRaw(pg.getGameString("ROGUE_NOT_EXCHANGE_REWARD_TITLE"), pg.getGameString("ROGUE_NOT_EXCHANGE_REWARD_TIP"), function()
				pg.global.ui:open(uiName, openInfo, uiOpenCb)
			end)
		else
			pg.global.ui:open(uiName, openInfo, uiOpenCb)
		end
	elseif uiName == UIConst.UI_ID_HOMELAND_CAR_LEVEL_UP then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_HOMELAND_CAR_COMP_LEVEL_UP) then
			pg.global.ui.homeCarLevelUp:open(openInfo, uiOpenCb, nil, {
				ignoreResetUICamera = true
			})
			pg.global.ui:close(UIConst.UI_ID_HOMELAND_CAR_COMP_LEVEL_UP)
		else
			pg.global.ui:open(uiName, openInfo, uiOpenCb)
		end
	elseif uiName == UIConst.UI_ID_FUNC_MENU_UNLOCK then
		local helpLockStatus = Utils.getHelpIsUnlock(pg.me, openInfo[1] or 0)

		if helpLockStatus and helpLockStatus < Const.HELP_UNLOCK_LEVEL.UNLOCK then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				self.logger:error("@event event_openUI helpUI is locked ! ! ! helpId:" .. openInfo[1])
			end

			return
		end

		pg.global.ui:open(uiName, openInfo, uiOpenCb)
	elseif uiName == UIConst.UI_ID_INTERACT_GESTURE then
		pg.global.ui:closeAllNormalPanel()

		if pg.global.ui.hudV2 and pg.global.ui.hudV2.LD then
			pg.global.ui.hudV2.LD:openEmoticonPanel()
		end
	elseif uiName == UIConst.UI_ID_SHOP_MAIN then
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
			return
		end

		local classifyId = openInfo.shopTags and openInfo.shopTags[1]
		local shopClassCfg = classifyId and ShopClassifyData[classifyId]

		if not shopClassCfg then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("@event event_openUI shop invalid classifyId:%s", tostring(classifyId))
			end

			return
		end

		openInfo.npcGlobalId = eventContext and eventContext.globalId

		if shopClassCfg.type == 1 then
			pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, openInfo, uiOpenCb)
		else
			openInfo.shopClassCfg = shopClassCfg

			pg.global.ui:open(UIConst.UI_ID_SHOP_TRANS, openInfo, uiOpenCb)
		end
	else
		pg.global.ui:open(uiName, openInfo, uiOpenCb)
	end
end

function ClientEventComponent:event_openUISuper(eventParam)
	local uiName = eventParam[1]
	local uiParam = eventParam[2]
	local uiContext = {}

	for _, params in ipairs(uiParam) do
		uiContext[params[1]] = params[2]
	end

	local checkRet = self:customCheckCanOpen(uiName, uiContext)

	if not checkRet then
		return
	end

	pg.global.ui:open(uiName, uiContext)
end

function ClientEventComponent:event_forceTracedQuest(eventParam)
	local questId = eventParam[1]
	local autoV = tonumber(eventParam[2]) or 0

	QuestUtils.questManualForce(questId, autoV)
end

function ClientEventComponent:event_openHomeBuildTab(eventParam)
	local type = eventParam[1]
	local subType = eventParam[2]

	if not pg.space or not Utils.isHomeland(pg.space.spaceType) then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HOMELAND_CAR_LEVEL_UP) then
		pg.global.ui:close(UIConst.UI_ID_HOMELAND_CAR_LEVEL_UP)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HOMELAND_MAIN_PAGE) then
		pg.global.ui:close(UIConst.UI_ID_HOMELAND_MAIN_PAGE)
	end

	pg.global.ui.homelandEditor:open({
		type = type,
		subType = subType
	})
end

function ClientEventComponent:event_startAIRemind(eventParam)
	local aiId = eventParam[1]

	self:tryRefreshAiIds(true, aiId, true)
end

function ClientEventComponent:event_finishAIRemind(eventParam)
	local aiId = eventParam[1]

	self:tryRefreshAiIds(false, aiId, true)
end

function ClientEventComponent:event_aiHelperTrackTarget(eventParam)
	local info = eventParam[2]

	info.func = eventParam[1]

	facade:sendMsgToUI(MessageName.UI_TRACK_SINGLE_ENT, info)
end

function ClientEventComponent:event_showPhoto(info)
	pg.global.ui.photoTip:open({
		resId = info[1],
		templateIds = info[2]
	})
end

function ClientEventComponent:event_lockingMapPoints(eventParam)
	local sceneId = eventParam[1]
	local pointId = eventParam[2]

	LuaUIUtils.locateMark(sceneId, pointId)
end

function ClientEventComponent:event_closeUI(eventParam)
	pg.global.ui:close(eventParam[1])
end

function ClientEventComponent:event_openActiveDungeon(eventParam, npcParam)
	local activeId = eventParam[1]

	if self.activityDatas then
		for _, info in pairs(self.activityDatas) do
			if activeId == info.activityId and info.activityType == Const.ActivityType.BOSS_DUNGEON then
				pg.global.ui.activeDungeon:open(info)

				pg.me.ActiveClientDatas.activeId = activeId
			end
		end
	end
end

function ClientEventComponent:event_playEffect(eventParam, npcParam)
	local effectId = eventParam[1]
	local entId = npcParam.globalId
	local npc = pg.getEntity(entId)

	if not npc then
		return
	end

	npc:playEffect(effectId)
end

function ClientEventComponent:event_playEffectOn(eventParam)
	local effectId = eventParam[1]
	local staticId = eventParam[2]
	local ent = staticId and self.space:getEntityByStaticId(staticId)

	if not ent then
		return
	end

	ent:playEffect(effectId)
end

function ClientEventComponent:event_playEffectOnRandom(eventParam)
	local effectKeyList = eventParam[1]

	if type(effectKeyList) ~= "table" or #effectKeyList <= 0 then
		return
	end

	local staticId = eventParam[2]
	local ent = staticId and self.space:getEntityByStaticId(staticId)

	if not ent then
		return
	end

	local effectKey = effectKeyList[math.random(1, #effectKeyList)]

	ent:playEffect(effectKey)
end

function ClientEventComponent:event_stopEffect(eventParam, npcParam)
	local effectId = eventParam[1]
	local entId = npcParam.globalId
	local npc = pg.getEntity(entId)

	if not npc then
		return
	end

	npc:stopEffect(effectId)
end

function ClientEventComponent:event_showRogueDungeonInfo(eventParam, npcParam)
	local entId = npcParam.globalId
	local npc = pg.getEntity(entId)

	if not npc then
		return
	end

	local levelInfo = RoguelikeData[pg.me.curRogueLayer] or {}

	if not levelInfo then
		return
	end

	local function handle()
		local infoRoot = npc.eModel.modelSkeletonView.skeletonRoot:Find("Canvas/TowerEnterPanel")
		local objectReference = infoRoot:GetComponent("ObjectReference")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")
		local targetUList = objectReference:GetRefValue("targetUList")
		local enemyUList = objectReference:GetRefValue("enemyUList")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")
		local text2UBaseText = objectReference:GetRefValue("text2UBaseText")
		local rootAnimation = objectReference:GetRefValue("rootAnimation")
		local listElementUList = objectReference:GetRefValue("listElementUList")
		local title3UWidget = objectReference:GetRefValue("title3UWidget")
		local text3USDFText = objectReference:GetRefValue("text3USDFText")
		local listBuffUList = objectReference:GetRefValue("listBuffUList")

		pg.game.audio:triggerEvent(AudioConst.EVENT_ROGUE_SHOW_DUNGEON_PANEL)

		local dist = Vector3.Distance(npc:getPosition(), pg.pawn:getPosition())
		local trapEventData = npc:tryGetTrapEventData()
		local showState = true

		if trapEventData and trapEventData.trapEvent then
			showState = dist <= trapEventData.trapEvent[1][1]
		end

		rootUComponent:SetActive(showState)

		if not showState then
			return
		end

		local infotBoardType = levelInfo.infotBoardType or 0

		rootUComponent:TryChangePage("Type", infotBoardType)
		ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(levelInfo.name))
		ClientTextUtils.setText(text2UBaseText, pg.getLocalizationText(levelInfo.name))

		local conditions = levelInfo.completionConditions or {}
		local data = {}

		for _, conditionId in ipairs(conditions) do
			local item = {}
			local conditionInfo = LevelConditionData[conditionId]

			item.label = pg.getLocalizationText(conditionInfo.displayDesc)

			table.insert(data, item)
		end

		targetUList:SetList(data)

		function enemyUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRogueEnemyInfo(button, index, data)
		end

		local recommendEles = levelInfo.recommendType or {}

		LuaUIUtils.renderPetElement(listElementUList, recommendEles)
		enemyUList:SetList(LuaUIUtils.getRogueEnemyList())
		rootAnimation:Play()

		if title3UWidget then
			ClientTextUtils.setText(text3USDFText, pg.getGameString("ROGUE_MONSTER_EFFECT_TITLE"))

			local buffList = RogueUtils.getMonsterEffect()

			if buffList == nil or #buffList == 0 then
				LuaUIUtils.setUIViewVisible(title3UWidget, false)
				LuaUIUtils.setUIViewVisible(listBuffUList, false)
			else
				LuaUIUtils.setUIViewVisible(title3UWidget, true)
				LuaUIUtils.setUIViewVisible(listBuffUList, true)
				RogueUtils.renderMonsterEffect(listBuffUList, buffList)
			end
		end
	end

	if npc:modelLoaded() then
		handle()
	else
		npc.eModel.modelModelView.luaOnModelRefreshFinshed = handle
	end
end

function ClientEventComponent:event_startRogueBattle()
	if not pg.me or not pg.me.space then
		return
	end

	if not pg.me.space:isRogueEnv() then
		return
	end

	pg.global.gameMgr:RefreshShadowInBounds(0, 0, 0, 1, 1, 1)
	pg.me.space:startBattle(RogueUtils.getBattlePetIds())
	facade:SendMessageCommand(MessageName.ROGUE_START_BATTLE)
end

function ClientEventComponent:event_goNextDungeonScene(eventParam, npcParam)
	local entId = npcParam.globalId
	local npc = pg.getEntity(entId)

	if not npc then
		return
	end

	local staticId = npc.staticId
	local levelInfo = RoguelikeData[pg.me.curRogueLayer]

	if not levelInfo then
		return
	end

	local referenceDungeonId = levelInfo.referenceDungeonId or {}
	local nextDungeonIds = referenceDungeonId[staticId]

	if not nextDungeonIds then
		return
	end

	local function startNextDungeon()
		pg.game.audio:triggerEvent(AudioConst.EVENT_ROGUE_GO_NEXT_DUNGEON)
		npc:playEffect(RogueConst.GoNextDungeonNpcEffect[npc.templateId])
		npc:setVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, false, false, false)
		TimerManager.addTimer(RogueConst.GoNextDungeonDelay, function()
			pg.me:startRandomRogue(staticId)
		end)
	end

	if self:checkShowExchangeRewardWarning(levelInfo) then
		pg.global.showConfirmMsgRaw(pg.getGameString("ROGUE_NOT_EXCHANGE_REWARD_TITLE"), pg.getGameString("ROGUE_NOT_EXCHANGE_REWARD_TIP"), function()
			startNextDungeon()
		end)
	else
		startNextDungeon()
	end
end

function ClientEventComponent:checkShowExchangeRewardWarning(levelInfo)
	if not levelInfo then
		return false
	end

	local totalExchangeCount = levelInfo.rogueStaminaExchangeCount
	local exchangeCount = pg.me.rogueExchangeMap[pg.me.curRogueLayer] or 0

	return totalExchangeCount and totalExchangeCount > 0 and exchangeCount == 0
end

function ClientEventComponent:event_showRogueExchangeReward(eventParam, npcParam)
	if not pg.me or not pg.me.space then
		return
	end

	if not pg.me.space:isRogueEnv() then
		return
	end

	local rewardType = eventParam and eventParam[1] or Const.RogueExchangeRewardType.CarryItem
	local levelInfo = RoguelikeData[pg.me.curRogueLayer]

	if not levelInfo or not levelInfo.rogueStaminaExchangeCount then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("event_showRogueExchangeReward config error")
		end

		return
	end

	local dropIndex = RogueTalentUtils.func(pg.me, "rogueStaminaDropId") or 1

	dropIndex = math.max(dropIndex, 1)

	local rewardSet = rewardType == Const.RogueExchangeRewardType.CarryItem and levelInfo.rogueStaminaRewardSet or levelInfo.rogueStaminaRewardSet2
	local title = rewardType == Const.RogueExchangeRewardType.CarryItem and pg.getGameString("EXCHANGE_REWARD_TITLE") or pg.getGameString("EXCHANGE_REWARD_TITLE2")
	local tipTop = rewardType == Const.RogueExchangeRewardType.CarryItem and pg.getGameString("EXCHANGE_REWARD_TIP") or pg.getGameString("EXCHANGE_REWARD_TIP2")

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, {
		type = 2,
		title = title,
		tipTop = string.gsub(tipTop, "{0}", levelInfo.rogueStaminaRewardCost),
		dropId = rewardSet and rewardSet[dropIndex],
		exchangeTotalCount = levelInfo.rogueStaminaExchangeCount,
		exchangeCount = pg.me.rogueExchangeMap[pg.me.curRogueLayer] or 0,
		exchangeCost = levelInfo.rogueStaminaRewardCost,
		confirmCb = function()
			local itemCount = ItemUtils.getItemCountById(pg.me, Const.CommonEnergyType_Stamina)

			if itemCount < levelInfo.rogueStaminaRewardCost then
				LuaUIUtils.openVitalityGot(Const.CommonEnergyType_Stamina)

				return
			end

			local totalCount = levelInfo.rogueStaminaExchangeCount
			local exchangeCount = pg.me.rogueExchangeMap[pg.me.curRogueLayer] or 0

			if totalCount <= exchangeCount then
				pg.global.ui.tips:showTextTip(pg.getGameString("EXCHANGE_REWARD_COUNT_LACK"))

				return
			end

			pg.me:reqRogueExchangeReward(rewardType)

			if exchangeCount + 1 == totalCount and RogueUtils.rogueExchangeNpcId then
				local ent = pg.getEntity(RogueUtils.rogueExchangeNpcId)

				if ent then
					ent:stopEffect(EffectConst.ROGUE_EXCHANGE_REWARD_NPC_EFF)
				end
			end
		end
	})
end

function ClientEventComponent:event_playRogueExchangeNpcEffect(eventParam, npcParam)
	local effectId = EffectConst.ROGUE_EXCHANGE_REWARD_NPC_EFF
	local entId = npcParam.globalId
	local npc = pg.getEntity(entId)

	if not npc then
		return
	end

	npc:playEffect(effectId)

	RogueUtils.rogueExchangeNpcId = entId
end

function ClientEventComponent:event_bossRushTeleport(eventParam, npcParam)
	local target = eventParam[1]
	local cycleData = BossRushCycleData[pg.me.curBossRushCycleId]
	local isBattleLevel = table.contains(Const.BossRushBattlePlace, target)

	if isBattleLevel then
		local levelId = cycleData[target]

		if pg.space.openLevelId ~= 0 and pg.space.openLevelId ~= levelId and pg.me:isInTeam() and not pg.me:isTeamLeader() then
			local bossName = BossRushUtils.getBossNameByLevelId(pg.space.openLevelId)
			local tip = string.gsub(pg.getGameString("BOSS_RUSH_OPEN_LEVEL_NOT_MATCH_LEADER"), "<bossName>", bossName)

			pg.global.ui.tips:showTextTip(tip)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_CHALLENGE, {
			levelId = levelId,
			levelIds = {
				cycleData.bossLeft,
				cycleData.bossMid,
				cycleData.bossRight
			},
			target = target
		})

		return
	end

	if cycleData[target] then
		pg.me:goBossRushDungeon(cycleData[target])
	elseif target == Const.BossRushTeleportTarget.Prepare then
		pg.me:goBossRushDungeon(SysConfigData.BossRushPrepareLevelId)
	end

	self.curBossRushPlace = target
end

function ClientEventComponent:event_challengeDungeonclient(eventParam, npcParam)
	local dungeonId = eventParam[1]

	if not dungeonId then
		local entityId = npcParam and npcParam.fromEntId or npcParam.globalId
		local fromEnt = pg.getEntity(entityId)

		if fromEnt then
			dungeonId = fromEnt:getConfigData().refDungeonSceneId
		end
	end

	if not dungeonId then
		return
	end

	local isInTeamRoom = pg.me.teamInfo.prepareInfos and lume.getMapLen(pg.me.teamInfo.prepareInfos) > 0

	pg.global.ui:open(UIConst.UI_ID_GAME_INSTANCE, {
		dungeonId = dungeonId
	})
end

function ClientEventComponent:event_reportReward(eventParam, npcParam)
	pg.global.ui.reporter:checkOpen({
		ids = 1,
		data = npcParam
	})
end

function ClientEventComponent:event_reportUpload()
	if not CommonSwitch.PET_REPORT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	local player = pg.me
	local reportMoney = player.catchReportMap:getTotalMoney()
	local allPoint = PetResearchUtils.getAllHasReportPointArea()

	if reportMoney > 0 or #allPoint > 0 then
		pg.global.ui.petReport:open({
			reportMoney = reportMoney,
			allReportPointArea = allPoint
		})
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("SUB_REPORT_NO_PET"))
	end
end

function ClientEventComponent:event_startParmonCompetition(eventParam)
	return
end

function ClientEventComponent:event_createStumpPuppet(eventParam)
	return
end

function ClientEventComponent:event_refreshOperationHint(eventParam)
	facade:sendMsgToUI(MessageName.REFRESH_OPERATION_HINT, {})
end

function ClientEventComponent:event_appearSceneHelpPanel(eventParam)
	pg.global.ui.help:open({
		specificScene = pg.space.sceneId
	})
end

function ClientEventComponent:event_dialogue(eventParam, extraParam)
	local dialogueId = eventParam[1]
	local delayAfterFullScreenPanel = eventParam[2]
	local entityStaticId = eventParam[3]
	local npcId = extraParam and extraParam.globalId
	local entity = entityStaticId and self.space:getEntityByStaticId(entityStaticId)
	local src = extraParam and extraParam.dialogueSrc

	if not src and extraParam and extraParam.source == Const.ESM_INTERACT then
		src = DialogueConst.SrcType.Interaction
	end

	pg.game.communication:startNpcDialog(dialogueId, entity and entity.id or npcId, {
		delayAfterFullScreenPanel = delayAfterFullScreenPanel,
		src = src
	})
end

function ClientEventComponent:event_closeDialogue()
	pg.game.communication:finishNpcDialog()
end

function ClientEventComponent:event_playSound(eventParam)
	local eventName = eventParam[1]

	pg.game.audio:triggerEvent(eventName)
end

function ClientEventComponent:event_stopPlaySound(eventParam)
	local eventName = eventParam[1]

	pg.game.audio:playEvent("stop_" .. eventName)
end

function ClientEventComponent:event_playVideo(eventParam)
	local eventName = eventParam[1]

	pg.global.ui.video:open({
		videoType = Const.VideoType.NormalVideo,
		videoClip = eventName
	})
end

function ClientEventComponent:event_goodbye(eventParam, extraParam)
	if extraParam ~= nil then
		local targetEntity = pg.getEntityByGlobalId(extraParam.globalId)

		if targetEntity ~= nil then
			targetEntity:onLeaveInteractTrigger()
		end
	end
end

function ClientEventComponent:event_openPicEx(eventParam)
	local imgUrls = eventParam[1][1]

	if #imgUrls <= 0 then
		return
	end

	local posterStaticId = tonumber(eventParam[2])

	pg.global.ui:open(UIConst.UI_ID_SHOP_POSTER, {
		imgUrls = imgUrls,
		posterStaticId = posterStaticId
	})

	if pg.game.shop.interactShopPosterEvent then
		pg.game.shop.interactShopPosterEvent[posterStaticId](false, posterStaticId)
	end
end

function ClientEventComponent:event_interactLeylineTree(eventParam)
	if not eventParam then
		pg.global.showBubbleMessageById(2205)

		return
	end

	local leylineTreeId = eventParam[1]

	if not leylineTreeId then
		pg.global.showBubbleMessageById(2205)

		return
	end

	if not pg.me.leylineTreeInfoMap[leylineTreeId] or pg.me.leylineTreeInfoMap[leylineTreeId].leylineTreeLevel < 0 then
		pg.global.showBubbleMessageById(2205)

		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_LEYLINE_TREE) then
		pg.global.ui:show(UIConst.UI_ID_LEYLINE_TREE)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_LEYLINE_TREE, {
		leylineTreeId = leylineTreeId
	})
end

function ClientEventComponent:event_activeLeylineTree(eventParam)
	if not eventParam then
		return
	end

	local leylineTreeId = eventParam[1]

	if not leylineTreeId then
		return
	end

	if pg.me.leylineTreeInfoMap[leylineTreeId] and pg.me.leylineTreeInfoMap[leylineTreeId].leylineTreeLevel >= 0 then
		return
	end

	pg.me:serverMsg("RPC_CS_UpgradeLeylineTree", leylineTreeId, 0)
end

function ClientEventComponent:event_interactNourish(eventParam)
	if not eventParam then
		return
	end

	local leylineTreeId = eventParam[1]

	if not leylineTreeId then
		return
	end

	if leylineTreeId == -1 then
		leylineTreeId = pg.game.leylineTree:getCurLeylineTreeId()

		if not leylineTreeId or leylineTreeId == 0 then
			leylineTreeId = DEFAULT_LEYLINE_TREE_ID
		end
	end

	local leylineTreeInfoMapData = pg.me.leylineTreeInfoMap[leylineTreeId]

	if not leylineTreeInfoMapData or leylineTreeInfoMapData.leylineTreeLevel < 0 then
		return
	end

	local leylineTreeLevel = leylineTreeInfoMapData.leylineTreeLevel

	if leylineTreeLevel < SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_MAP_NOURISH, {
		to = "Nourish",
		leylineTreeId = leylineTreeId
	})
end

function ClientEventComponent:event_interactWeather(eventParam)
	if not eventParam then
		return
	end

	local leylineTreeId = eventParam[1]

	if not leylineTreeId then
		return
	end

	if leylineTreeId == -1 then
		leylineTreeId = pg.game.leylineTree:getCurLeylineTreeId()

		if not leylineTreeId or leylineTreeId == 0 then
			leylineTreeId = DEFAULT_LEYLINE_TREE_ID
		end
	end

	local leylineTreeInfoMapData = pg.me.leylineTreeInfoMap[leylineTreeId]

	if not leylineTreeInfoMapData or leylineTreeInfoMapData.leylineTreeLevel < 0 then
		return
	end

	local leylineTreeLevel = leylineTreeInfoMapData.leylineTreeLevel

	if leylineTreeLevel < SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_LEVEL then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_MAP_NOURISH, {
		to = "Weather",
		leylineTreeId = leylineTreeId
	})
end

function ClientEventComponent:event_trapEvent(eventParam, extraParam)
	if extraParam ~= nil then
		local npcEntity = pg.getEntityByGlobalId(extraParam.globalId)

		if npcEntity and npcEntity.playAnimation then
			npcEntity:playAnimation(PlayableConst[eventParam[1]])
		end
	end
end

function ClientEventComponent:event_showEmojiBubble(eventParam, extraParam)
	if extraParam and extraParam.globalId then
		local name = eventParam[1]
		local duration = eventParam[2]
		local npcEntity = pg.getEntityByGlobalId(extraParam.globalId)

		npcEntity.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, name, duration)
	end
end

function ClientEventComponent:event_showMultiBubble(eventParam, extraParam)
	local bubbleId = eventParam[1]

	if bubbleId then
		pg.global.eventEmitter:emit(EventConst.NPC_INTERACT_BUBBLE_GROUP, bubbleId)
	end
end

function ClientEventComponent:event_setBGM(eventParam)
	local bgmName = eventParam[1]

	pg.game.audio:playBgm(bgmName, AudioConst.BgmPriority.ClientEvent)
end

function ClientEventComponent:event_resetBGM(eventParam)
	pg.game.audio:stopBgm(AudioConst.BgmPriority.ClientEvent)
end

function ClientEventComponent:event_setPlayerRoute(eventParam)
	local routeId = eventParam[1]
	local routeData = SceneUtils.getSceneRouteData(pg.me.space.sceneId, pg.me.space.id)[routeId]
	local posList = {}

	if routeData and routeData.wayPoints then
		for _, data in pairs(routeData.wayPoints) do
			table.insert(posList, data.position)
		end

		pg.me:pawnAutoPathFinding(posList[#posList], false, AutoPathFindUtils.PathFindType.ForceMove, posList)
	end
end

function ClientEventComponent:event_resetPlayerCamera(eventParam)
	pg.game.camera.playerCameraMode:resetCamera()
end

function ClientEventComponent:event_onPlayerPositionReset(eventParam)
	facade:SendMessageCommand(MessageName.ON_PLAYER_POSITION_RESET, {})
end

function ClientEventComponent:event_playCameraShake(eventParam)
	local shakeId = eventParam[1]

	if shakeId == nil or shakeId == 0 then
		return
	end

	local ent
	local staticId = eventParam[2]

	if staticId ~= nil then
		ent = pg.me.space:getEntityByStaticId(staticId)
	end

	pg.game.camera:playCameraShakeById(ent, shakeId)
end

function ClientEventComponent:event_toast(eventParam)
	pg.global.showBubbleMessageById(eventParam[1])
end

function ClientEventComponent:event_hideUI(eventParam)
	local isHide = eventParam[1] or 0
	local hideMaxTime = eventParam[2] or 0
	local excludePanelIds = eventParam[3] or {}
	local whiteList = {}

	for _, idInfo in ipairs(excludePanelIds) do
		if idInfo[1] then
			whiteList[idInfo[1]] = true
		end
	end

	if isHide == 1 then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.CLIENT_EVENT, whiteList, hideMaxTime)
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CLIENT_EVENT)
	end
end

function ClientEventComponent:event_dialogueMoveCamera(eventParam)
	local curCamera = pg.game.dialogue:getCurDialogueCamera()

	if curCamera == nil then
		return
	end

	local startPos, startRot, endPos, endRot

	if string.notNilOrEmpty(eventParam[1]) then
		local temp = string.split(eventParam[1], ",")

		startPos = Vector3(tonumber(temp[1]), tonumber(temp[2]), tonumber(temp[3]))
	end

	if string.notNilOrEmpty(eventParam[2]) then
		local temp = string.split(eventParam[2], ",")

		startRot = Vector3(tonumber(temp[1]), tonumber(temp[2]), tonumber(temp[3]))
	end

	if string.notNilOrEmpty(eventParam[3]) then
		local temp = string.split(eventParam[3], ",")

		endPos = Vector3(tonumber(temp[1]), tonumber(temp[2]), tonumber(temp[3]))
	end

	if string.notNilOrEmpty(eventParam[4]) then
		local temp = string.split(eventParam[4], ",")

		endRot = Vector3(tonumber(temp[1]), tonumber(temp[2]), tonumber(temp[3]))
	end

	local brain = curCamera.transform:GetComponent("CinemachineBrain")

	if brain ~= nil then
		brain.enabled = false
	end

	local duration = eventParam[5]

	if endPos ~= nil then
		if startPos ~= nil then
			curCamera.transform.position = startPos
		end

		DoTweenAnimMgr.Move(curCamera.transform, LuaUIUtils.TweenId(ID_DIALOGUE_MOVE), endPos, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			if brain ~= nil then
				brain.enabled = true
			end
		end)
	end

	if endRot ~= nil then
		if startRot ~= nil then
			curCamera.transform.eulerAngles = startRot
		end

		DoTweenAnimMgr.Rotate(curCamera.transform, LuaUIUtils.TweenId(ID_DIALOGUE_ROTATE), endRot, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			if brain ~= nil then
				brain.enabled = true
			end
		end)
	end
end

function ClientEventComponent:setDittoPuppetVisible(eventParam)
	local staticId = eventParam[1] or 0
	local visible = eventParam[2] == 1
	local puppet = self.space:getEntityByStaticId(staticId)

	if puppet then
		puppet:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, visible, visible)
	end
end

function ClientEventComponent:event_blackScreen(eventParam, context)
	self:openBlackScreen(eventParam[1], context)
end

function ClientEventComponent:openBlackScreen(id, context)
	local screenConfig = BlackScreenData[id]

	if screenConfig == nil then
		return
	end

	if screenConfig.type == 1 then
		pg.global.ui:open(UIConst.UI_ID_BLACK_SCREEN, {
			id = id,
			context = context
		})
	elseif screenConfig.type == 2 then
		pg.global.ui:open(UIConst.UI_ID_WHITE_SCREEN, {
			id = id,
			context = context
		})
	end
end

function ClientEventComponent:event_closeBlackScreen(eventParam)
	local screenConfig = BlackScreenData[eventParam[1]]

	if screenConfig == nil then
		return
	end

	if screenConfig.type == 1 then
		pg.global.ui:close(UIConst.UI_ID_BLACK_SCREEN)
	elseif screenConfig.type == 2 then
		pg.global.ui:close(UIConst.UI_ID_WHITE_SCREEN)
	end
end

function ClientEventComponent:event_teleportScenePositionByConfirm(eventParam, context)
	local sceneId = eventParam[1]
	local portalId = eventParam[2]
	local isBanEffect = eventParam[3]
	local showConfirm = eventParam[4] or 0
	local blackScreenId = eventParam[5] or 0

	if showConfirm == 1 then
		local msg = pg.getGameString("TELEPORT_CONFIRM")
		local markPointData = SceneUtils.getSceneMarkPointData(sceneId)
		local markPointName = markPointData ~= nil and markPointData[portalId] and markPointData[portalId].infoTitle or ""

		msg = string.gsub(msg, "{0}", pg.getLocalizationText(markPointName))

		pg.global.showConfirmMsgRaw(pg.getGameString("SUB_REPORT_TELEPORT"), msg, function()
			self:teleportScenePosition(sceneId, portalId, isBanEffect, blackScreenId)
		end)
	else
		self:teleportScenePosition(sceneId, portalId, isBanEffect, blackScreenId)
	end
end

function ClientEventComponent:teleportScenePosition(sceneId, portalId, isBanEffect, blackScreenId, loadingOpenCb, loadingCloseCb)
	local isBanEffect = isBanEffect and isBanEffect > 0

	pg.game.map.banTeleportEffectFlag = isBanEffect
	pg.game.forceBanPlayerReviveAnim = isBanEffect or nil

	if blackScreenId > 0 then
		pg.global.scene.blackScreenId = blackScreenId

		pg.global.ui:open(UIConst.UI_ID_LOADING_SHOW, {
			id = blackScreenId,
			isreload = pg.global.scene.curScene.sceneId == sceneId
		}, loadingOpenCb, loadingCloseCb)
	else
		pg.global.ui:open(UIConst.UI_ID_LOADING, nil, loadingOpenCb, loadingCloseCb)
	end

	self:addTimer(0.5, function()
		pg.me:tryTeleportToScene(sceneId, portalId, true)
	end)
end

function ClientEventComponent:event_teleportSelfHomeLandWithConfirm(eventParam)
	if pg.me and pg.me:isInSelfHomeland() then
		pg.global.showBubbleMessageById(NoticeDef.HOME_ALREADY_IN_HOMELAND)

		return
	end

	ClientUtils.showConfirmRaw(pg.getGameString("QUEST_TELEPORT_HOMELAND_TITLE"), pg.getGameString("QUEST_TELEPORT_HOMELAND_DESC"), function()
		if not pg.me.isHomelandUnlock then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_NOT_UNLOCKED"))

			return
		end

		pg.me:serverMsg("RPC_CS_ReqEnterSelfHomeland", function(res)
			if res then
				pg.global.ui:closeAllNormalPanel()
			end
		end)
	end)
end

function ClientEventComponent:event_teleportSelfHomeLand(eventParam)
	if pg.me and pg.me:isInSelfHomeland() then
		pg.global.showBubbleMessageById(NoticeDef.HOME_ALREADY_IN_HOMELAND)

		return
	end

	pg.me:serverMsg("RPC_CS_ReqEnterSelfHomeland", function(res)
		if res then
			pg.global.ui:closeAllNormalPanel()
		end
	end)
end

function ClientEventComponent:getAvailableTeleportList(greatTeleportData)
	local allList = {}
	local j = 1

	for i, data in pairs(greatTeleportData.portals) do
		allList[j] = data
		j = j + 1
	end

	return allList
end

function ClientEventComponent:event_clientGreatPortalTeleport(param, context)
	if not pg.space then
		return
	end

	local fromEntId = self.id

	if context ~= nil and context.fromEntId ~= nil and type(context.fromEntId) == "string" then
		fromEntId = context.fromEntId
	end

	local sceneId = param[1]
	local greatTeleportId = param[2]
	local teleportId = param[3]
	local ent = pg.getEntity(fromEntId)
	local GreatTeleportData = SceneUtils.getSceneData(sceneId, "scene_portal_group_data", pg.space.id)

	if GreatTeleportData == nil then
		return
	end

	local greatTeleportData = GreatTeleportData[greatTeleportId]
	local portalId = teleportId

	if teleportId == nil or teleportId == 0 then
		if greatTeleportData == nil then
			return
		end

		local teleportList = self:getAvailableTeleportList(greatTeleportData)

		portalId = lume.randomchoice(teleportList)
	end

	if fromEntId == self.id or fromEntId == nil or not ent then
		pg.me:CheckAndCallServerTeleport(sceneId, function()
			pg.me:serverMsg("RPC_CS_NotifyStartTeleport", sceneId, portalId)
		end)

		return
	end

	local pos = ent:getPosition()
	local targetPos = Vector3.New(pos.x, pg.me:getPosition().y, pos.z)

	pg.me.inTeleportFinding = true

	pg.global.ui.interact:hide()

	local startPathFinding = pg.pawn:pawnAutoPathFinding(targetPos, function(arrived)
		pg.global.ui.interact:show()

		if not arrived then
			pg.me.inTeleportFinding = false

			return
		end

		local skeletonView = ent.eModel.skeletonView

		if skeletonView and skeletonView.skeletonRoot then
			local teleportPoint = skeletonView.skeletonRoot:GetComponent("ArkTeleportPoint")

			if teleportPoint then
				teleportPoint:PlayTeleportVX()
			end
		end

		ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
			pg.me:CheckAndCallServerTeleport(sceneId, function()
				pg.me:serverMsg("RPC_CS_NotifyStartTeleport", sceneId, portalId)
			end)
		end)
	end, AutoPathFindUtils.PathFindType.ForceMove)

	if not startPathFinding then
		pg.me.inTeleportFinding = false
	end
end

function ClientEventComponent:event_playDialogueGraph(eventParam, context)
	local id = eventParam[1]

	if id == nil or id <= 0 then
		return
	end

	local callback = context and context.callback

	if context then
		local src = context.dialogueSrc

		if not src and context.source == Const.ESM_INTERACT then
			src = DialogueConst.SrcType.Interaction
		end

		if src == DialogueConst.SrcType.Interaction then
			pg.global.ui.interact:hide()

			if callback == nil then
				function callback()
					pg.global.ui.interact:show()
				end
			else
				local cb = callback

				function callback()
					cb()
					pg.global.ui.interact:show()
				end
			end
		end
	end

	pg.game.dialogue:playDialogueGraph(id, callback, nil, context)

	return true
end

function ClientEventComponent:event_dialogueGraphTeleport(eventParam, context)
	if not eventParam then
		return false
	end

	local beGraphId = eventParam[1] or 0
	local blackScreenId = eventParam[2] or 0
	local sceneId = eventParam[3] or 0
	local portalId = eventParam[4] or 0
	local isBanEffect = eventParam[5] or 0
	local afGraphId = eventParam[6] or 0
	local reTrigger = context and context.eventId and self:getReTriggerEvent(context.eventId)
	local currentIndex = reTrigger and reTrigger.currentIndex or 1
	local tasks = {}

	pg.game.isReTriggerEvent = true

	if beGraphId ~= 0 and currentIndex == 1 then
		table.insert(tasks, function(nextTask)
			pg.game.dialogue:playDialogueGraph(beGraphId, nextTask, context)
		end)
	end

	local needTeleport = currentIndex == 1 or beGraphId ~= 0 and currentIndex == 2

	if needTeleport then
		table.insert(tasks, function(nextTask)
			if pg.me == nil or pg.me:isServerLost() then
				nextTask()

				return
			end

			local isFinished = false

			local function onLoadingFinish(ret)
				if isFinished then
					return
				end

				isFinished = true

				if ret == nil then
					ret = true
				end

				self:removeCheckTeleportTimer()

				if pg.global.ui:checkUIShow(UIConst.UI_ID_LOADING) then
					pg.global.ui:close(UIConst.UI_ID_LOADING)
				end

				if pg.global.ui:checkUIShow(UIConst.UI_ID_LOADING_SHOW) then
					if ret == true then
						pg.global.ui.loadingShow:tryClosePanel(function()
							nextTask()
						end)
					else
						pg.global.ui:close(UIConst.UI_ID_LOADING_SHOW)
						nextTask()
					end
				else
					nextTask()
				end
			end

			local function reqTeleportFunc()
				if pg.me and not pg.me:isServerLost() then
					pg.me:tryTeleportToScene(sceneId, portalId, true)
				end
			end

			local function onLoadingStart()
				if pg.me and not pg.me:isServerLost() then
					self:_startTeleportTimeoutCheck(onLoadingFinish, reqTeleportFunc, sceneId, portalId)
				end
			end

			if pg.pawn and blackScreenId > 0 then
				pg.pawn:restoreNormalState()
			end

			self:teleportScenePosition(sceneId, portalId, isBanEffect, blackScreenId, onLoadingStart, onLoadingFinish)
		end)
	end

	if afGraphId > 0 then
		table.insert(tasks, function(nextTask)
			if sceneId ~= 0 and needTeleport and not self:checkTeleportFinished(sceneId, portalId) then
				nextTask()

				return
			end

			pg.game.dialogue:playDialogueGraph(afGraphId, nextTask, nil, context)
		end)
	end

	ClientUtils.sequenceExecute(tasks, function()
		pg.game.isReTriggerEvent = nil

		local callback = context and context.callback

		if callback then
			SafeCallback(callback)
		end

		if pg.game.loading:isFinished() and pg.me then
			pg.me:doCacheEvents()
		end
	end)

	return true
end

function ClientEventComponent:checkTeleportFinished(sceneId, portalId)
	if pg.me == nil or pg.me.space == nil or pg.me.space.sceneId ~= sceneId then
		return false
	end

	if portalId == 0 then
		return true
	end

	local scenePortalData = SceneUtils.getScenePortalData(sceneId, pg.me.space.id)
	local portalData = scenePortalData and scenePortalData[portalId]

	if portalData == nil or portalData.markPosition == nil then
		return false
	end

	return Utils.distance2D(pg.me:getPosition(), portalData.markPosition) <= 4
end

function ClientEventComponent:_startTeleportTimeoutCheck(onLoadingFinish, reqTeleportFunc, sceneId, portalId)
	self:removeCheckTeleportTimer()

	local tickCount = 0
	local RETRY_INTERVAL_TICKS = 4
	local MAX_TIMEOUT_TICKS = 40
	local hasStartedLoading = false

	pg.game.checkTeleportTimerId = TimerManager.addRepeatTimer(0.5, function()
		tickCount = tickCount + 1

		local isLoading = not pg.game.loading:isFinished()

		if not isLoading and tickCount >= RETRY_INTERVAL_TICKS then
			local teleportFinished = self:checkTeleportFinished(sceneId, portalId)

			if hasStartedLoading or teleportFinished then
				if onLoadingFinish then
					onLoadingFinish(true)
				end

				return
			end
		end

		if tickCount >= MAX_TIMEOUT_TICKS then
			if onLoadingFinish then
				onLoadingFinish(false)
			end

			return
		end

		if isLoading then
			hasStartedLoading = true

			return
		end

		if tickCount >= RETRY_INTERVAL_TICKS and tickCount % RETRY_INTERVAL_TICKS == 0 then
			reqTeleportFunc()
		end
	end)
end

function ClientEventComponent:removeCheckTeleportTimer()
	if pg.game.checkTeleportTimerId then
		TimerManager.removeTimer(pg.game.checkTeleportTimerId)

		pg.game.checkTeleportTimerId = nil
	end
end

function ClientEventComponent:event_batchPlayDialogueGraph(eventParam, context)
	local eventId = context.eventId
	local dialogueIds = eventParam[1] or {}
	local isRandom = eventParam[2] or 0

	if eventId and dialogueIds then
		local curDialogueId = pg.me.curBatchDialogueMap:getCurBatchDialogue(eventId)

		if not getBit(pg.me.finishedBatchDialogueMap, eventId) then
			if pg.me.curBatchDialogueMap[eventId] and curDialogueId then
				local context = {}

				context.eventId = eventId

				pg.game.dialogue:playDialogueGraph(curDialogueId, nil, nil, context)
			else
				pg.me:ReqBatchDialogue(eventId, dialogueIds, isRandom == 1)
			end
		end
	end
end

function ClientEventComponent:event_clientStartGuide(eventParam, context, cb)
	local guidanceId = eventParam[1] or 0

	pg.game.guide:startGuide(guidanceId)
end

function ClientEventComponent:event_clientFinishGuide(eventParam)
	local guidanceId = eventParam[1] or 0

	pg.game.guide:finishGuide(guidanceId, Const.GUIDE_FINISH_REASON.SERVER_FINISH)
end

function ClientEventComponent:event_finishGuideStep(eventParam)
	pg.game.guide:eventfinishStep(eventParam[1])
end

function ClientEventComponent:event_startGuideStep(eventParam)
	pg.game.guide:startGuide(eventParam[1], eventParam[2])
end

function ClientEventComponent:event_sendAIEvent(eventParam)
	local staticId = eventParam[1]
	local params = eventParam[2]
	local suffix = eventParam[3]

	if staticId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("event_sendAIEvent failed, staticId = nil !")
		end

		return
	end

	local ent = pg.me.space:getEntityByStaticId(staticId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("event_sendAIEvent failed, ent = nil !", staticId)
		end

		return
	end

	local triggerName

	if suffix ~= nil then
		triggerName = string.format("CommonClientMsgTrigger%s", suffix)
	else
		triggerName = "CommonClientMsgTrigger"
	end

	local context = CTRPool.getContext()

	context.var = params

	AIControllerUtils.sendAIEvent(ent, triggerName, context)
end

function ClientEventComponent:event_playCutsceneByStaticId(eventParam)
	local cutsceneResId = eventParam[1]
	local staticId = eventParam[2] or 0
	local hideSelf = eventParam[3]
	local ent = self.space:getEntityByStaticId(staticId)

	if not ent then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("event_playCutsceneByStaticId failed, getEntityByStaticId failed, resId:", cutsceneResId)
		end

		return
	end

	local entPos = ent:getPosition()
	local entRot = ent:getRotation()
	local extraData = {}
	local refEntId = ent.id

	extraData.refEntId = refEntId

	if hideSelf == 1 then
		function extraData.startCallback()
			local hideEnt = pg.getEntity(refEntId)

			if hideEnt then
				hideEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE_SELF, false)
			end
		end

		function extraData.endCallback()
			local hideEnt = pg.getEntity(refEntId)

			if hideEnt then
				hideEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE_SELF, true)
			end
		end
	end

	pg.game.cutscene:playCutscene(cutsceneResId, cutsceneResId, entPos, entRot, nil, nil, extraData)
end

function ClientEventComponent:event_setNpcBehavior(eventParam, context)
	if #eventParam ~= 3 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("event_setNpcBehavior failed, #eventParam ~= 3")
		end

		return
	end

	local npcStaticId, behavior, opt = eventParam[1], eventParam[2], eventParam[3]
	local ent = self.space:getEntityByStaticId(npcStaticId)

	if ent then
		if opt == Const.NpcBehaviorOpt.REMOVE then
			ent:dynamicRemoveBehavior(behavior)
		elseif opt == Const.NpcBehaviorOpt.ADD then
			ent:dynamicAddBehavior(behavior)
		end
	end
end

function ClientEventComponent:event_playCutscene(eventParam)
	local cutsceneResId = eventParam[1]
	local extraData = {
		keepPrefabTrans = true
	}

	pg.game.cutscene:playCutscene(cutsceneResId, cutsceneResId, nil, nil, nil, nil, extraData)
end

function ClientEventComponent:event_startHomeSeasonCelebration(eventParam)
	local festivalId = tonumber(eventParam and eventParam[1])
	local player = pg.me

	if not festivalId or not player or not player.reqStartHomeSeasonCelebration then
		return
	end

	local celebrationData = HomeSeasonCelebrationData[festivalId]

	if celebrationData and self:isHomeSeasonCelebrationOpenCountReached(player, festivalId, celebrationData) then
		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_CELEBRATION_LIMIT_REACHED)

		return
	end

	player:reqStartHomeSeasonCelebration(festivalId)
end

function ClientEventComponent:isHomeSeasonCelebrationOpenCountReached(player, festivalId, celebrationData)
	local dailyOpenCount = celebrationData.dailyOpenCount or 0

	if dailyOpenCount <= 0 then
		return false
	end

	local celebrationCountMap = player.homeSeasonCelebrationCount

	if not celebrationCountMap then
		return false
	end

	local currentCount = celebrationCountMap[festivalId] or 0

	return dailyOpenCount <= currentCount
end

function ClientEventComponent:event_playCutsceneSelf(eventParam, eventContext)
	local cutsceneResId = eventParam[1]
	local hideSelf = eventParam[2]
	local fromEntId = eventContext.fromEntId or eventContext.globalId or ""
	local ent = pg.getEntity(fromEntId)

	if not ent then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("event_playCutsceneSelf failed, pg.getEntity failed, resId:", cutsceneResId)
		end

		return
	end

	local entPos = ent:getPosition()
	local entRot = ent:getRotation()
	local extraData = {}
	local refEntId = ent.id

	extraData.refEntId = refEntId

	if hideSelf == 1 then
		function extraData.startCallback()
			local hideEnt = pg.getEntity(refEntId)

			if hideEnt then
				hideEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE_SELF, false)
			end
		end

		function extraData.endCallback()
			local hideEnt = pg.getEntity(refEntId)

			if hideEnt then
				hideEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE_SELF, true)
			end
		end
	end

	pg.game.cutscene:playCutscene(cutsceneResId, cutsceneResId, entPos, entRot, nil, nil, extraData)
end

function ClientEventComponent:event_setClientCustomVariable(eventParam, eventContext)
	self:setClientCustomVariable(eventParam[1], eventParam[2])
end

function ClientEventComponent:event_sendGroupSingPuzzleEvent(eventParam, extraParam)
	local eventId = eventParam[2]
	local npcEntity = pg.getEntityByGlobalId(extraParam.globalId)

	if npcEntity then
		local groupSingLevelItem = npcEntity.relatedGroupSingLevelItem

		if not groupSingLevelItem then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("event_sendGroupSingPuzzleEvent failed relatedGroupSingLevelItem is nil")
			end

			return
		end

		if eventId == 1 then
			groupSingLevelItem:resetAndStartPuzzle()
		elseif eventId == 2 then
			groupSingLevelItem:resetPuzzle()
		elseif eventId == 3 then
			groupSingLevelItem:playSuccessCutscene()
		end
	end
end

function ClientEventComponent:event_showContent(eventParam)
	for _, id in ipairs(eventParam) do
		self:tryClientTrigger(TriggerConst.TRIGGER_TARGET_READ_CONTENT, id, 1)
	end

	LuaUIUtils.openItemViewer(eventParam)
end

function ClientEventComponent:event_startSlotMachine(eventParam, extraParam)
	local npcId = extraParam.globalId
	local npcFx = pg.getEntity(npcId)
	local staticId = eventParam[1]
	local ent = pg.me.space:getEntityByStaticId(staticId)

	if ent then
		for _, rewardId in pairs(ArkSlotMachineData[1].arkRewardList) do
			local checkRet = Utils.checkSendArkReward(pg.me, rewardId)

			if NoticeDef.SUCCESS ~= checkRet then
				pg.global.showBubbleMessageById(checkRet)

				return
			end
		end

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("ARK_SLOT_MACHINE_CONSUME_FAIL"), function()
			pg.me:startSlotMachine(1, function(isSuccess, result)
				if isSuccess then
					ent.levelItem:startPlay(npcFx)
					ent.levelItem:setResult(result)
				end
			end)
		end, nil)
	end
end

function ClientEventComponent:event_applyPhotoPreset(eventParam, extraParam)
	if not pg.space then
		return
	end

	local sceneId = pg.space.sceneId
	local key = eventParam[1]
	local preset = pg.global.cameraMgr.vcManager:GetPhotoPreset(key, sceneId)

	if preset and pg.me then
		pg.me:pawnAutoPathFinding(preset.playerPos, function()
			self:applyPhotoPresetInner(preset)
		end, AutoPathFindUtils.PathFindType.Voxel)
	end
end

function ClientEventComponent:applyPhotoPresetInner(preset)
	if not pg.me then
		return
	end

	pg.me:faceToRotation(Quaternion.Euler(preset.playerRot))
	pg.global.ui.hudV2:openPhotoPanel(preset)
end

function ClientEventComponent:event_startBehavior(eventParam, extraParam)
	local staticId = eventParam[1]
	local animStateName = eventParam[2]
	local ent = pg.me.space:getEntityByStaticId(staticId)

	if ent and ent.playRawAnimation then
		local state = ent:playRawAnimation(animStateName, nil, 0, 1, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)

		ent.eModel:SetSequenceStepCallback(Const.COMPONENT_IDX_PLAYABLE, state, state.Length - 0.1, function()
			if not state.IsLooping then
				ent:stopAnimation(animStateName, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			end

			return true
		end)
	end
end

function ClientEventComponent:event_finishBehavior(eventParam, extraParam)
	local staticId = eventParam[1]
	local animStateName = eventParam[2]
	local ent = pg.me.space:getEntityByStaticId(staticId)

	if ent and ent.stopAnimation then
		ent:stopAnimation(animStateName, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
	end
end

function ClientEventComponent:event_setCurPetVisible(eventParam, extraParam)
	local visible = true

	if eventParam[1] == 0 then
		visible = false
	end

	pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, visible)
end

function ClientEventComponent:event_showIPContent(eventParam, extraParam)
	local piecesId = eventParam[1]
	local msg = {}

	if piecesId ~= nil and piecesId > 0 then
		msg.piecesId = piecesId

		if msg ~= nil and not Bitset.getBit(pg.me.notifiedPiecesSet, piecesId) then
			pg.global.ui:open(UIConst.UI_ID_PIECES_ITEM_PANEL, msg)
		end
	end
end

function ClientEventComponent:event_sendCustomLog(eventParam, extraParam)
	local logName = eventParam[1]
	local logParam = eventParam[2] or {}

	if string.isNilOrEmpty(logName) then
		return
	end

	local mainPlayer = pg.me
	local logData = {
		server_id = mainPlayer.serverId,
		role_name = mainPlayer.playerName,
		role_level = mainPlayer.level,
		game_scene_id = pg.me.space.sceneId,
		game_space_nuid = pg.me.space.id
	}

	for k, v in pairs(logParam) do
		logData[k] = v
	end

	local npc_id = self.staticId

	if not npc_id and self.refLevelItemId then
		npc_id = self.refLevelItemId
	end

	logData.npc_id = npc_id

	local selfPosition = self:getPosition()

	logData.position = {
		selfPosition.x,
		selfPosition.y,
		selfPosition.z
	}

	GlobalData.BILogger:customeLog(logName, logData)
end

function ClientEventComponent:event_showPetBallHatch(eventParam, extraParam)
	if not pg.global.ui:checkUIShow(UIConst.UI_ID_PET_BALL) and pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		pg.global.ui.hudV2:openPetBall({
			ignoreUIScene = true,
			openHatch = true
		})
	end
end

function ClientEventComponent:event_forceNormalState(eventParam, extraParam)
	if self:MAGNESIS_READY_ST() or self:MAGNESIS_ST() then
		self:_cancel_MAGNESIS_ST()
	end

	self:_cancel_CATCH_MODE_ST()
	pg.pawn:_cancel_CLIMB_ST()
	pg.pawn:_cancel_GLIDE_ST()
end

function ClientEventComponent:event_showBranchLineArea(eventParam, extraParam)
	local isEnter = eventParam[1] == 1
	local MSG = isEnter and MessageName.ENTER_TRIGGER or MessageName.LEAVE_TRIGGER

	facade:SendMessageCommand(MSG, {
		actionPrototypeId = 257,
		globalId = extraParam.areaId,
		interactionType = InteractionConst.INTERACTION_TYPE_BRANCH_LINE_AREA
	})
end

function ClientEventComponent:event_enterSeamless(eventParam, extraParam)
	local sceneId = eventParam[1]

	self:seamless_event_enterSeamless(sceneId, false)
end

function ClientEventComponent:event_enterSeamlessDynamic(eventParam, extraParam)
	local sceneId = eventParam[1]

	self:seamless_event_enterSeamless(sceneId, true)
end

function ClientEventComponent:event_changeMapLayerData(eventParam, extraParam)
	print("`[MapLayer]` change", "param=", inspect(eventParam), "areaId=", extraParam and extraParam.areaId, "pos=", inspect(pg.me:getPosition()), "areas=", inspect(pg.me.areas))
	pg.game.map:setMapLayerData(eventParam[1], eventParam[2], eventParam[3], extraParam.areaId)
	facade:SendMessageCommand(MessageName.CHANGE_MAP_LAYER_DATA, {})
end

function ClientEventComponent:event_setInSocialArea(eventParam, extraParam)
	if eventParam == nil then
		return
	end

	local inAreaNum, areaId

	if eventParam[1] ~= nil then
		inAreaNum = tonumber(eventParam[1])
	end

	if eventParam[2] ~= nil then
		areaId = tonumber(eventParam[2])
	end

	if inAreaNum == nil or areaId == nil then
		return
	end

	if pg.me == nil then
		return
	end

	pg.me:setInSocialArea(inAreaNum == 1, areaId)
end

function ClientEventComponent:event_activeMapLayer(eventParam, extraParam)
	if not pg.me then
		return
	end

	pg.me:setMapLayerUnlockData(eventParam)
end

function ClientEventComponent:event_logout(eventParam, extraParam)
	ClientUtils.backToHome()
end

function ClientEventComponent:event_acceptHornNotify(eventParam, extraParam)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("event_acceptHornNotify begin eventParam", inspect(eventParam), self:repr())
	end

	if eventParam and eventParam[2] and eventParam[2].enable then
		pg.game.social:acceptInvitation()
	end
end

function ClientEventComponent:event_finishEvolution(eventParam, extraParam)
	pg.game.evolution:finishEvolution(true)
end

function ClientEventComponent:onSkillVisibleChange()
	facade:SendMessageCommand(MessageName.SKILL_VISIBLE_CHANGE)
end

function ClientEventComponent:event_grabEggHatchEgg(eventParam, extraParam)
	local ent = pg.getEntity(extraParam.fromEntId)

	if not ent then
		return
	end

	local spawnerId = ent.ownerSpawnerId

	if not spawnerId then
		return
	end

	pg.global.ui.hudV2:openPetBall({
		ignoreUIScene = true,
		openHatch = true,
		spawnerId = spawnerId,
		targetId = extraParam.fromEntId
	})
end

function ClientEventComponent:event_grabEggHatchCollectEgg(eventParam, extraParam)
	local ent = pg.getEntity(extraParam.fromEntId)

	if not ent then
		return
	end

	local spawnerId = ent.ownerSpawnerId

	if not spawnerId then
		return
	end

	self:grabEgg_TakeRobEgg(spawnerId)
end

function ClientEventComponent:event_grabEggHatchRobEgg(eventParam, extraParam)
	local ent = pg.getEntity(extraParam.fromEntId)

	if not ent then
		return
	end

	local spawnerId = ent.ownerSpawnerId

	if not spawnerId then
		return
	end

	self:grabEgg_robEgg(spawnerId)
end

function ClientEventComponent:event_clientQuizResult(eventParam, extraParam)
	if pg.me.clientQuizResult then
		pg.me:clientQuizResult(eventParam[1] or 0)
	end
end

function ClientEventComponent:event_clientQuizAgain(eventParam, extraParam)
	if pg.me.clientQuizAgain then
		pg.me:clientQuizAgain()
	end
end

function ClientEventComponent:event_clientQuizContinue(eventParam, extraParam)
	if pg.me.startQuiz then
		pg.me:continueQuiz()
	end
end

function ClientEventComponent:event_enableHighGrassDither(eventParam, context)
	local id = context.areaId
	local space = self.space

	if not space or not Utils.isRobEggSceneId(space.sceneId) then
		return
	end

	local staticId = eventParam[1]
	local enable = ToBool(eventParam[2])
	local highGrassEntity = space:getEntityByStaticId(staticId)

	if highGrassEntity and highGrassEntity.eModel then
		highGrassEntity.eModel.shaderView:SetMaterialProperty("_AreaDitheringStrength", enable and 0.35 or 0)
	end
end

function ClientEventComponent:event_startDigEggQte(eventParam, extraParam)
	local enterQteGroupId = eventParam[1]
	local mainQteGroupId = eventParam[2]

	if not enterQteGroupId or not mainQteGroupId then
		return
	end

	local entityId = extraParam.globalId
	local entity = entityId and pg.getEntity(entityId)

	if not entity then
		return
	end

	pg.me:setInputCommandDigEgg()

	local function qteMainCb(eventName, info)
		if eventName == "qtePartHit" then
			if entity and entity.triggerDigEggEffect then
				local hitPercent = info.clipHitPercent

				entity:triggerDigEggEffect(hitPercent)
			end

			local controllerComponent = pg.me:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

			if NotNil(controllerComponent) then
				controllerComponent.abilityCharacterStateInfo.abilityQteInput = true
			end
		elseif eventName == "qteDigEggGood" then
			local controllerComponent = pg.me:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

			if NotNil(controllerComponent) then
				controllerComponent.abilityCharacterStateInfo.abilityQteInput = true
			end

			pg.me:setInputCommandDigEgg()
			self:serverMsg("RPC_CS_OpenResourceBoxWithQTE", entityId, 100)
		end
	end

	local function qteEnterSuccessCb(eventName, info)
		if eventName == "qtePartGood" then
			pg.game.qte:startQte(pg.me.actorId, mainQteGroupId, {
				src = Const.QTE_SRC.DigEgg,
				triggerCallback = qteMainCb
			})
		end
	end

	pg.game.qte:startQte(pg.me.actorId, enterQteGroupId, {
		src = Const.QTE_SRC.DigEgg,
		triggerCallback = qteEnterSuccessCb
	})
end

function ClientEventComponent:event_guideEffectToLeylineTree(eventParam, extraParam)
	if not pg.me or not pg.me.space or not pg.me.space.sceneId then
		return
	end

	local entId = extraParam.globalId
	local npc = pg.getEntity(entId)

	if not npc then
		return
	end

	local sourceStaticId = npc.staticId
	local effectName = eventParam[1]
	local targetStaticId = eventParam[2]
	local positionOffset = Vector3.constZero

	if string.notNilOrEmpty(eventParam[3]) then
		local temp = string.split(eventParam[3], ",")

		positionOffset = Vector3(tonumber(temp[1]), tonumber(temp[2]), tonumber(temp[3]))
	end

	local sceneAreaData = SceneUtils.getSceneEntityData(pg.me.space.sceneId)

	if not sceneAreaData[sourceStaticId] or not sceneAreaData[targetStaticId] then
		return
	end

	local sourcePosition = sceneAreaData[sourceStaticId].position + positionOffset
	local targetPosition = sceneAreaData[targetStaticId].position
	local rot = Quaternion.LookRotation(targetPosition - sourcePosition, Vector3.up) * Quaternion.Euler(0, -90, 0)
	local eulerAngles = rot:ToEulerAngles()

	pg.game.effect:playEffectAt(nil, effectName, sourcePosition, eulerAngles, nil)
end

function ClientEventComponent:event_showFishingCaptureStartUI(eventParam, extraParam)
	if not pg.me then
		return
	end

	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)

	if not activityData or not ActivityUtils.isOprActivityTabOpenByType(ActivityConst.EventType.FishingCapture, pg.me) then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)

		return
	end

	local entranceType = tonumber(eventParam and eventParam[1])

	if entranceType ~= FishingCaptureConst.EntranceType.Final then
		entranceType = FishingCaptureConst.EntranceType.Weekly
	end

	if entranceType == FishingCaptureConst.EntranceType.Final then
		local cubeExchangeCountMap = activityData.cubeExchangeCountMap
		local irisCubeExchangeCount = tonumber(cubeExchangeCountMap and cubeExchangeCountMap[FishingCaptureConst.CubeType.LEGEND]) or 0

		if irisCubeExchangeCount <= 0 then
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)

			return
		end
	end

	pg.global.ui:open(UIConst.UI_ID_FISHING_CAPTURE_MAIN, {
		entranceType = entranceType
	})
end

function ClientEventComponent:event_showFishingCaptureContractConfirm(eventParam, extraParam)
	if not pg.me or not pg.me:isInFishingCapture() then
		return
	end

	if pg.me:getFishingCaptureCurrentPhase() ~= FishingCaptureConst.Phase.CAPTURE then
		return
	end

	if not pg.me:canConfirmFishingCaptureContract() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_FISHING_CAPTURE_PURIFICATION)
	pg.global.ui.tips:hideBossCatchTips()
end

function ClientEventComponent:event_showCatchRogueStartUI(eventParam, extraParam)
	if not pg.me then
		return
	end

	if not pg.me:getCatchRogueCurGameId() or pg.me:getCatchRogueCurGameId() == 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_CATCH_ROGUE_ENTRY)
end

function ClientEventComponent:event_goNextCatchRogue(eventParam, extraParam)
	if not Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		return
	end

	pg.me:nextCatchRogueGame()
end

function ClientEventComponent:event_showCatchRogueFinishUI(eventParam, extraParam)
	if not Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		return
	end

	if pg.me.catchRogueInfo:isTopFloor() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TIMEPUZZLE_SUCC"))
		pg.me:settleCatchRogueGame(true)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("event_showCatchRogueFinishUI is not top floor! cur floor:%s", pg.me.catchRogueInfo:getCurSettleFloorCount(), self:repr())
	end
end

function ClientEventComponent:event_replyFluteNotify(eventParam, eventContext)
	pg.game.social:replyFluteNotify(eventParam[1])
end

function ClientEventComponent:event_playFlute(eventParam, eventContext)
	if pg.me:SOCIAL_ANIM_ST() or pg.me:SOCIAL_INTERACT_ACTION_ST() then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_PLAY_FLUTE)
end

function ClientEventComponent:event_openChat(eventParam, eventContext)
	local initTab = eventParam[1] and tonumber(eventParam[1]) or nil
	local initSecondTab = eventParam[2] and tonumber(eventParam[2]) or nil

	pg.global.ui:open(UIConst.UI_ID_CHAT, {
		initTab = initTab,
		initSecondTab = initSecondTab
	}, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function ClientEventComponent:event_openMapFocusPoint(eventParam, eventContext)
	local markStaticId = tonumber(eventParam[1])
	local sceneId = tonumber(eventParam[2]) or 3000
	local scenePointData = SceneUtils.getSceneMarkPointData(sceneId)
	local markType = markStaticId and scenePointData[markStaticId] and scenePointData[markStaticId].markType or nil
	local isSceneWorld = pg.me and pg.me.space and (pg.me.space.sceneId == 3000 or pg.me.space.sceneId == sceneId)

	if isSceneWorld and markStaticId and markType then
		pg.global.ui:open(UIConst.UI_ID_MAP, {}, function()
			pg.global.ui.map:focusMark({
				string.format("mark_%s_%s", markType, markStaticId),
				nil,
				true
			})
		end)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("FAILED"))
	end
end

function ClientEventComponent:event_teleportToHomeCar(eventParam, eventContext)
	if pg.space and pg.space:isHomeland() and pg.me:isInSelfHomeland() then
		pg.me:serverMsg("RPC_CS_ReqEnterSelfHomeCamp")

		return
	end

	local uid = pg.me.space.ownerUid or ""

	pg.me:queryHomeBasicInfo(uid, function(homeUnlocked, syncInfo, homelandKey, homeCampKey)
		if not homeCampKey or homeCampKey == "" then
			pg.global.showBubbleMessage(NoticeDef.HOME_CAR_CANNOT_TELEPORT)
		else
			pg.me:enterHomeCamp(homeCampKey, uid)
		end
	end)
end

function ClientEventComponent:event_openHugPetSelectPanel(eventParam, eventContext)
	if pg.me.petTeamType ~= Const.PET_TEAM_TYPE_DEFAULT then
		pg.global.showBubbleMessage(NoticeDef.FLUTE_CANNOT_USE_IN_CURRENT_SCENE)

		return
	end

	if pg.me:SOCIAL_ANIM_ST() or pg.me:SOCIAL_INTERACT_ACTION_ST() then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_SELECT_POPUP, nil, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function ClientEventComponent:event_showSource(eventParam)
	if eventParam and eventParam[1] then
		local sourceData = ItemSourceData[eventParam[1]]

		LuaUIUtils.clueSeek(sourceData)
	end
end

function ClientEventComponent:event_hintAnimeState(eventParam)
	facade:sendMsgToSystem(MessageName.HINT_ANIME_STATE, eventParam)
end

function ClientEventComponent:event_quickEnterControlMode(eventParam)
	local canSwitch = ClientUtils.computeFuseSwitchState({
		"emptyPrepareList"
	})

	if not canSwitch then
		self.logger:error("[快速联结] : 当前不满足快速联结的条件!!!")

		return
	end

	if not ClientUtils.checkLinkedCondition() or pg.me.life == Const.LIFE_DE or pg.me:isInCombat() then
		self.logger:error("[快速联结] : 当前状态不可进行快速联结!!!")

		return
	end

	local templateId, basicId, familyId, formName, stage, label = unpack(eventParam, 1, 6)
	local pets = ClientUtils.findCanLinkedPetsInBag(templateId, basicId, familyId, formName, stage, label)

	self.logger:info("[快速联结] : templateId = %s, basicId = %s, familyId = %s, stage = %s, label = %s", inspect(templateId), inspect(basicId), inspect(familyId), inspect(formName), inspect(stage), inspect(label))

	if #pets > 0 then
		ClientUtils.sortCanLinkedPetsInBag(pets)

		local quickEnterData = {
			petInfo = pets[1]
		}

		pg.me:cachePendingQuickEnter(quickEnterData, SysConfigData.PetConjunctionCountdownTime or 15)
		facade:sendMsgToUI(MessageName.QUICK_ENTER_CONTROL_MODE, quickEnterData)
	else
		self.logger:error("[快速联结] : 角色身上未找到对应的宠物，请检查配置是否与预期一致!!!")
	end
end

function ClientEventComponent:event_questManualJump(eventParam)
	local jumpType = tonumber(eventParam[1]) or 1
	local id = eventParam[2] or {}

	if type(id) == "number" then
		id = {
			id
		}
	end

	if jumpType and id and id[1] then
		QuestUtils.questManualJump(jumpType, id)
	end
end

function ClientEventComponent:event_questManualJumpAndTrace(eventParam)
	if eventParam and eventParam[1] then
		QuestUtils.questManualJumpAndTrace(eventParam)
	end
end

function ClientEventComponent:event_openSpecialTrainAndTraceType(eventParam)
	local trainType = tonumber(eventParam[1])

	QuestUtils.openSpecialTrainAndTraceType(trainType)
end

function ClientEventComponent:event_openNourish(eventParam)
	if not eventParam then
		return
	end

	local leylineTreeId = pg.game.leylineTree:getCurLeylineTreeId()

	if not leylineTreeId or leylineTreeId == 0 then
		return
	end

	local blockId = eventParam[1]

	if not blockId then
		return
	end

	local openMapAfterNourish = eventParam[2] == true

	if not pg.me.leylineTreeInfoMap then
		return
	end

	local leylineTreeInfoMapData = pg.me.leylineTreeInfoMap[leylineTreeId]

	if not leylineTreeInfoMapData then
		return
	end

	local imprintList = leylineTreeInfoMapData.activePointList

	if not imprintList then
		return
	end

	local imprintInjectedCount = leylineTreeInfoMapData.leylineTreePoint

	if not imprintInjectedCount then
		return
	end

	local leylineTreeData = LeylineTreeData[leylineTreeId]

	if not leylineTreeData then
		return
	end

	local levelData = leylineTreeData[SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL or 4]

	if not levelData then
		return
	end

	local numRequired = levelData.point or 0

	if imprintInjectedCount < numRequired then
		pg.global.showBubbleMessageRaw(pg.getGameString("LEYLINETREE_LEVEL_TOO_LOW"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_MAP_NOURISH, {
		to = "Nourish",
		leylineTreeId = leylineTreeId,
		blockId = blockId,
		openMapAfterNourish = openMapAfterNourish
	})
end

function ClientEventComponent:event_playAction(eventParam, eventContext)
	if not eventParam or not pg.game.social.interactGestureComponent then
		return
	end

	local interactGestureComponent = pg.game.social.interactGestureComponent
	local actionIds = {}

	for _, actionId in ipairs(eventParam) do
		actionId = tonumber(actionId)

		local actionData = actionId and AppearanceAction[actionId]

		if actionData and interactGestureComponent:isActionUnlocked({
			index = actionId,
			initialClaim = actionData.initialClaim
		}) then
			actionIds[#actionIds + 1] = actionId
		end
	end

	if #actionIds == 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("NO_ACTION_AVAILABLE"))

		return
	end

	local targetEntId = eventContext and (eventContext.fromEntId or eventContext.globalId)
	local targetEnt = eventContext and eventContext.fromEntUid and pg.getEntityByUid(eventContext.fromEntUid) or targetEntId and (pg.getEntity(targetEntId) or pg.getEntityByGlobalId(targetEntId))

	if not targetEnt then
		return
	end

	local InteractData = require("Data.interact_data")
	local interactCfg = InteractData[eventContext.interactId]

	for _, eventData in ipairs(interactCfg.events) do
		local eventName, param, ratio, delay = Utils.safeUnpack(eventData)
		local eventCfg = EventEnumData[eventName]

		if eventCfg and eventCfg.eventFlag == "s" then
			eventContext.eventDelay = delay or 0

			pg.me:serverMsg("RPC_CS_doEventFromClient", eventName, param or {}, eventContext)
		end
	end

	local actionId = actionIds[math.random(1, #actionIds)]
	local actionData = AppearanceAction[actionId]

	if eventContext.actionState then
		local actionData = AppearanceAction[eventContext.actionState]

		if actionData.interactToast then
			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getLocalizationText(actionData.interactToast), targetEnt.playerName))
		end
	end

	interactGestureComponent:requestFriendAction(targetEnt, {
		index = actionId,
		costItemId = actionData ~= nil and actionData.costItemId or nil,
		needTargetAgree = actionData ~= nil and actionData.needTargetAgree or nil,
		interactAction = actionData ~= nil and actionData.interactAction or nil
	}, true)
end

function ClientEventComponent:event_joinMultiAction(eventParam, eventContext)
	if eventContext.fromEntUid then
		pg.me:joinMultiAction(eventContext.fromEntUid)
	end
end

function ClientEventComponent:event_autoFollow(eventParam, eventContext)
	if eventContext.fromEntUid then
		pg.me:quickInviteSpaceFollow(eventContext.fromEntUid)
	end
end

function ClientEventComponent:event_createPrivateHomeCamp(eventParam, eventContext)
	local homeCampInfo = pg.me:getPlayerHomeCampInfo()
	local campLineInfo = homeCampInfo.lineInfo or {}

	if campLineInfo.isPrivate then
		pg.global.showBubbleMessage(NoticeDef.HOMELAND_ALREADY_IN_PRIVATE_CAMP)

		return
	end

	local curSceneId = pg.space.sceneId
	local staticId = HomeLandUtils.getHomeCampStaticId(curSceneId)

	if not staticId then
		return
	end

	local campInfo = HomeCampData[staticId] or {}

	if not campInfo then
		return
	end

	local costItemList = HomelandConfigData.campPrivateLineCostItemList
	local costText = ""

	if costItemList and costItemList[1] then
		costText = LuaUIUtils.getItemObtainShowText(costItemList[1][1], costItemList[1][2], false)
	end

	local desc = pg.getFormatText(pg.getGameString("CREATE_PRIVATE_CAMP_DESC"), costText, pg.getLocalizationText(campInfo.name), campInfo.campUid)

	pg.global.ui.commonUseConfirm:open({
		type = 4,
		title = pg.getGameString("CREATE_PRIVATE_CAMP_TITLE"),
		tipTop = desc,
		data = costItemList,
		notEnoughCallback = function(itemId, itemNum)
			pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK)
		end,
		confirmCb = function()
			pg.global.ui.commonUseConfirm:close()
			pg.me:requireCreatePrivateHomeCamp(staticId, function()
				pg.global.ui.homeCampMoveLoading:open()
			end)
		end,
		cancelCb = function()
			pg.global.ui.commonUseConfirm:close()
		end
	})
end

function ClientEventComponent:event_teleportFlower(eventParam, eventContext)
	local flowerId = pg.game.leylineTree.curPlentyLeylineFlowerId

	if not flowerId then
		return
	end

	pg.me:doEventByData({
		"finishAIRemind",
		{
			115
		}
	})

	local sceneId = pg.game.map:convertSceneId(pg.me.space.sceneId)
	local markStatus = pg.me:getSpaceOwnerMapMarkStatus(sceneId, Const.MAP_MARK_LeylineFlower_Create, flowerId)

	if not markStatus or markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
		pg.global.showBubbleMessage(NoticeDef.FUNC_NOT_UNLOCK)

		return
	end

	ClientUtils.playTeleportDissolveEffectAndTeleport(sceneId, flowerId)
end

function ClientEventComponent:clearEmotionAction(eventParam, eventContext)
	return
end

function ClientEventComponent:event_switchCatchMode(eventParam, eventContext)
	if not pg.me then
		return
	end

	local arg = eventParam and eventParam[1]

	if arg == nil then
		pg.game.controller:onHandleSwitchCatchMode()
	else
		pg.game.controller:setCatchModeEnable(arg == 1)
	end
end

function ClientEventComponent:event_displayUnlockEffect(eventParam)
	local badgeId = eventParam and eventParam[1] or 0
	local cfgData = PlayerBadgeData[badgeId]

	if cfgData then
		BadgeUtils.openBadgeTip(badgeId)
	end
end

function ClientEventComponent:event_openAreaInfo(eventParam, eventContext)
	local smallAreaId = eventParam[1] and tonumber(eventParam[1]) or nil

	if not smallAreaId then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_MAP, {
		muteBlackScreen = true,
		focusSmallArea = smallAreaId
	})
end

function ClientEventComponent:event_triggerExplode(eventParam, eventContext)
	local targetEnt

	if eventContext then
		targetEnt = eventContext.fromEntId and pg.getEntity(eventContext.fromEntId) or eventContext.globalId and pg.getEntityByGlobalId(eventContext.globalId)
	end

	if targetEnt and targetEnt.triggerExplode then
		return targetEnt:triggerExplode()
	end

	return false
end

function ClientEventComponent:customCheckCanOpen(uid, info, cb, closeCb, sceneParams)
	if uid == UIConst.UI_ID_PET_TRAINING_NEW then
		local petId = pg.game.petManage:getPetManageFallbackPetId(pg.me, info and info.petId)

		if not petId then
			pg.global.showBubbleMessageById(NoticeDef.CANT_OPEN_PET_TRAINING_NEW)

			return false
		end

		local checkUnlock = LuaUIUtils.tryOpenPetCultivateUI(info, nil, nil, nil, true)

		if not checkUnlock then
			return false
		end
	end

	if uid == UIConst.UI_ID_HOMELAND_MAIN_PAGE then
		if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.HOMELAND) then
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))

			return false
		end

		if not pg.me.isHomeCampUnlocked then
			pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_NOT_UNLOCKED)

			return false
		end
	end

	return true
end

function ClientEventComponent:event_getRiftReward(eventParam)
	if not pg.me then
		return
	end

	pg.me:claimRiftRewardByEventParam(eventParam)
end

function ClientEventComponent:event_preStartRift(eventParam, eventContext)
	local npcId = eventParam and eventParam[1]

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("event_preStartRift", inspect(eventParam), inspect(eventContext), self:repr())
	end

	local globalId = eventContext and eventContext.globalId
	local entity = globalId and (pg.getEntity(globalId) or pg.getEntityByGlobalId(globalId)) or nil

	if not npcId and entity then
		npcId = entity.templateId
	end

	if pg.me and entity and pg.me.focusRift then
		pg.me:focusRift(entity)
	end

	pg.global.ui:open(UIConst.UI_ID_FISSURE_MAIN, {
		npcId = npcId
	})
end

function ClientEventComponent:event_openRechargeRebate()
	local isOverseas = Utils.isOverseas()
	local configKey = isOverseas and "REBATE_LINK_OVERSEA" or "REBATE_LINK_CN"
	local url = SysConfigData[configKey]

	if not url or url == "" then
		return
	end

	if isOverseas then
		local languageType = pg.languageType or 0

		if languageType == ClientConst.LANGUAGE_TYPE_MAP.zh_CN or languageType > 4 then
			languageType = ClientConst.LANGUAGE_TYPE_MAP.en
		end

		url = string.gsub(url, "{0}", pg.global.sdkManager.LANGUAGE_TYPE_MAP[languageType], 1)
	end

	local sessionKey = pg.global.sdkManager:getSessionKey()

	if sessionKey and sessionKey ~= "" then
		local sep = string.find(url, "?", 1, true) and "&" or string.sub(url, -1) == "/" and "?" or "/?"

		url = url .. sep .. "session_key=" .. StringEx.urlencode(sessionKey) .. "&uid=" .. StringEx.urlencode(pg.me.uid)
	end

	pg.global.sdkManager:openUrl("ClientEventComponent", "SysConfigData." .. configKey, url)
end

function ClientEventComponent:event_switchOnAreaMask(eventParam)
	local areaMaskParam = eventParam and eventParam[1]
	local areaMaskValue = areaMaskParam and (tonumber(areaMaskParam) or NavMeshServiceUtils.AreaMaskType[areaMaskParam] or 0)

	NavMeshServiceUtils.switchOnAreaMask(areaMaskValue)
end

function ClientEventComponent:event_switchOffAreaMask(eventParam)
	local areaMaskParam = eventParam and eventParam[1]
	local areaMaskValue = areaMaskParam and (tonumber(areaMaskParam) or NavMeshServiceUtils.AreaMaskType[areaMaskParam] or 0)

	NavMeshServiceUtils.switchOffAreaMask(areaMaskValue)
end

return ClientEventComponent
