-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\Component\\QuestArrowTipComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("QuestArrowTipComponent")
local QuestConst = require("Common.Const.QuestConst")
local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local QuestArrowTipComponent = Class.LightClass("QuestArrowTipComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local UIConst = require("Const.UIConst")
local CircularQueue = require("Core.Framework.CircularQueue")
local Time = require("Core.Common.Time")
local Vector2 = Vector2
local Vector3 = Vector3
local Quaternion = Quaternion
local ToBool = ToBool
local math = math

QuestArrowTipComponent.PRELOAD_QUEST_ARROW_COUNT = 5
QuestArrowTipComponent.SCREEN_CENTER = Vector3(0.5, 0.5, 0)
QuestArrowTipComponent.relatedScreenWidth = 3840
QuestArrowTipComponent.relatedScreenHeight = 2160
QuestArrowTipComponent.INVALID_POS = Vector3(9999, 9999, 9999)

function QuestArrowTipComponent:findObjects()
	return
end

function QuestArrowTipComponent:onShow()
	return
end

local minNotTracedQuestHudSqrDis = 0
local maxNotTracedQuestHudSqrDis = 9999999

function QuestArrowTipComponent:initView()
	self.curDataIndex = 0
	self.timer = nil
	self.questArrowPool = {}
	self.questArrowData = {}
	self.questShowData = {}
	self.trackDisplayPositions = {}
	self.trackDisplayPositionIds = {}
	self.trackDisplayPositionCount = 0
	self.questTargetInfo = {}
	self.arrowPos = Vector2(0, 0)
	self.arrowObjPrefab = self.view.questRectTransform.gameObject
	self.arrowRot = Quaternion(0, 0, 0, 1)
	self.cachedTargetPos = Vector3(0, 0, 0)
	self.playerPos = Vector3(0, 0, 0)

	local widthRatio = self.ctrl.width / self.relatedScreenWidth
	local heightRatio = self.ctrl.height / self.relatedScreenHeight

	self.ratioX = widthRatio * 0.5
	self.ratioY = heightRatio * 0.5
	self.sqrX = math.pow(self.ratioX, 2)
	self.sqrY = math.pow(self.ratioY, 2)

	LuaUIUtils.setUIViewVisible(self.view.questRectTransform, false)
	self:initQuestArrowTipData()

	local visibleDistance = (SysConfigData.GuidenceArrowVisibleDistance or 100)^2

	self.enableHudShow = DefaultMapMarkData[100] and DefaultMapMarkData[100].enableHudShow or true

	local noTracedDistanceConfig = DefaultMapMarkData[100] and DefaultMapMarkData[100].hudShowDistance or {
		0,
		30
	}

	minNotTracedQuestHudSqrDis = noTracedDistanceConfig[1]^2
	maxNotTracedQuestHudSqrDis = math.min(noTracedDistanceConfig[2]^2, visibleDistance)
	self.m_tempQuestComp = nil
	self._textQueue = CircularQueue.new(16)
	self._caches = {}
	self._loadingSet = {}
end

function QuestArrowTipComponent:startQuestArrowTipTimer()
	self:clearQuestArrowTipTimer()

	self.timer = pg.game.camera:addLateUpdateTimer(function()
		self:startTick()
	end)
end

function QuestArrowTipComponent:clearQuestArrowTipTimer()
	if self.timer then
		pg.game.camera:removeLateUpdateTimer(self.timer)

		self.timer = nil
	end
end

function QuestArrowTipComponent:clearTrackDisplayPositions()
	self.trackDisplayPositions = self.trackDisplayPositions or {}
	self.trackDisplayPositionIds = self.trackDisplayPositionIds or {}
	self.trackDisplayPositionCount = 0
end

function QuestArrowTipComponent:removeTrackDisplayPosition(id)
	local count = self.trackDisplayPositionCount or 0

	for i = 1, count do
		if self.trackDisplayPositionIds[i] == id then
			if i ~= count then
				self.trackDisplayPositions[i]:Copy(self.trackDisplayPositions[count])

				self.trackDisplayPositionIds[i] = self.trackDisplayPositionIds[count]
			end

			self.trackDisplayPositionIds[count] = nil
			self.trackDisplayPositionCount = count - 1

			return
		end
	end
end

function QuestArrowTipComponent:recordDisplayedQuestTarget(id, data, targetPos)
	local arrowData = self.questArrowPool[id]

	if arrowData == nil or arrowData.taskId or arrowData.isHidden then
		return
	end

	if not data.showQuestIcon or targetPos == nil then
		return
	end

	local index = self.trackDisplayPositionCount + 1

	if self.trackDisplayPositions[index] == nil then
		self.trackDisplayPositions[index] = Vector3(0, 0, 0)
	end

	self.trackDisplayPositions[index]:Copy(targetPos)

	self.trackDisplayPositionIds[index] = id
	self.trackDisplayPositionCount = index
end

local oldTab

function QuestArrowTipComponent:startTick()
	self:clearTrackDisplayPositions()

	if pg.me == nil or pg.me.space == nil then
		return
	end

	self.playerPos:Copy(pg.me:getPosition())

	local playerSceneId = pg.game.map.mainSceneId
	local questArrowPool = self.questArrowPool
	local curTab = QuestUtils.getCurSelPage()

	if curTab ~= oldTab then
		table.clear(self.questShowData)

		oldTab = curTab

		for id, data in raw_next, self.questArrowData do
			local sceneId = data.sceneId
			local curPageType = QuestUtils.getPageType(data.questId)
			local legalScene = sceneId == -1 or SceneUtils.getMainSceneId(sceneId) == playerSceneId
			local validPageType = curPageType == curTab

			if legalScene and validPageType then
				self.questShowData[id] = data
			elseif questArrowPool[id] then
				self:hideQuestArrowEx(id)
			end
		end
	end

	local tmpPos = self.cachedTargetPos

	for id, data in raw_next, self.questShowData do
		local oriPos = data.targetPos
		local isShowQuestIcon = data.showQuestIcon
		local targetPos = tmpPos

		if data.targetEntityStaticId then
			local entity = pg.me.space:getEntityByStaticId(data.targetEntityStaticId)

			if entity then
				local entityPosition = entity:getPosition()

				targetPos:Copy(entityPosition)

				local topLogoHeight = entity.topLogoData and entity.topLogoData.heightToRoot or 0

				targetPos.y = targetPos.y + topLogoHeight

				local canShow, sqrDis = self:checkGuidenceVisibleDistance(targetPos, data.showSqrDis, isShowQuestIcon)

				if canShow then
					self.m_tempQuestComp = entity:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST)

					local inGuidanceRegion, dx, dy, vz = self:checkPosInScreenGuidanceRegion(targetPos)
					local shouldHide = false

					if self.m_tempQuestComp then
						if inGuidanceRegion then
							shouldHide = self.m_tempQuestComp:shouldSuppressMark()
						else
							shouldHide = self.m_tempQuestComp:isQuestActive()
						end
					end

					if not shouldHide then
						if inGuidanceRegion then
							self:ShowQuestMark(id, targetPos, sqrDis, data, dx, dy)
						else
							self:ShowQuestArrow(id, targetPos, data, dx, dy, vz)
						end

						self:recordDisplayedQuestTarget(id, data, entityPosition)
					elseif questArrowPool[id] then
						self:hideQuestArrowEx(id)
					end
				elseif questArrowPool[id] then
					self:hideQuestArrowEx(id)
				end
			else
				local canShow, sqrDis = self:checkGuidenceVisibleDistance(oriPos, data.showSqrDis, isShowQuestIcon)

				if canShow then
					local inGuidanceRegion, dx, dy, vz = self:checkPosInScreenGuidanceRegion(oriPos)

					if not inGuidanceRegion then
						self:ShowQuestArrow(id, oriPos, data, dx, dy, vz)
					else
						self:ShowQuestMark(id, oriPos, sqrDis, data, dx, dy)
					end

					self:recordDisplayedQuestTarget(id, data, oriPos)
				elseif questArrowPool[id] then
					self:hideQuestArrowEx(id)
				end
			end
		else
			local canShow, sqrDis = self:checkGuidenceVisibleDistance(oriPos, data.showSqrDis, isShowQuestIcon)

			if canShow then
				local inGuidanceRegion, dx, dy, vz = self:checkPosInScreenGuidanceRegion(oriPos)

				if not inGuidanceRegion then
					self:ShowQuestArrow(id, oriPos, data, dx, dy, vz)
				else
					self:ShowQuestMark(id, oriPos, sqrDis, data, dx, dy)
				end

				self:recordDisplayedQuestTarget(id, data, oriPos)
			elseif questArrowPool[id] then
				self:hideQuestArrowEx(id)
			end
		end
	end

	self:updateLoadingSet()

	local index = self._textQueue:pop()

	if index then
		local questItem = self.questArrowPool[index]

		if questItem and questItem.distanceText and questItem.showDist then
			questItem.distanceText.text = questItem.showedDistance .. "m"
		end
	end

	if Time.luaFrameCount % 31 == 0 then
		self:updateCache()
	end
end

function QuestArrowTipComponent:addQuestArrowTipData(questId, sceneId, targetInfo, targetTemplateId, targetEntityStaticId, questState, questType, showDistance, showNumMax)
	self.curDataIndex = self.curDataIndex + 1

	local curSqrDis = math.min((showDistance or 9999)^2, maxNotTracedQuestHudSqrDis)
	local data = {
		targetPos = Vector3(targetInfo.pos[1], targetInfo.pos[2], targetInfo.pos[3]),
		targetTemplateId = targetTemplateId,
		targetEntityStaticId = targetEntityStaticId,
		sceneId = sceneId,
		questId = questId,
		taskType = QuestUtils.getCurSideQuestShowType(questId),
		questType = questType,
		showSqrDis = curSqrDis,
		showNumMax = showNumMax,
		id = self.curDataIndex,
		targetInfo = targetInfo,
		questState = questState,
		showQuestIcon = (QuestUtils.isQuestTracing(questId) or QuestUtils.isRootQuestTracing(questId)) and not QuestUtils.isQuestIconOtherStyleType(questId)
	}
	local targetId = targetInfo.objId or targetInfo.index
	local id = QuestUtils.getCombinedId(questId, targetId)

	self.questArrowData[id] = data

	local sceneId = data.sceneId
	local curPageType = QuestUtils.getPageType(data.questId)

	if (sceneId == -1 or SceneUtils.getMainSceneId(sceneId) == pg.game.map.mainSceneId) and curPageType == QuestUtils.getCurSelPage() then
		self.questShowData[id] = data
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("QuestArrow", "@hyj addQuestArrowTipData: ", questId, sceneId, questState, questType, targetEntityStaticId)
	end

	if self.timer == nil and not pg.game.setting:getHideAllHudArrowType() then
		self:startQuestArrowTipTimer()
	end
end

function QuestArrowTipComponent:removeQuestArrowTipData(questId, targetId)
	local id = QuestUtils.getCombinedId(questId, targetId)

	if self.questArrowData[id] ~= nil then
		self.questArrowData[id] = nil

		local questArrow = self.questArrowPool[id]

		if questArrow ~= nil then
			self:AddToCache(questArrow)

			self.questArrowPool[id] = nil
		end

		self.questShowData[id] = nil

		self:removeTrackDisplayPosition(id)
	end
end

function QuestArrowTipComponent:onDestroy()
	self:destroyAllQuestArrowInstances(true)

	self.questArrowData = {}
	self.questShowData = {}
	self.trackDisplayPositions = nil
	self.trackDisplayPositionIds = nil
	self.trackDisplayPositionCount = 0

	if self._textQueue then
		self._textQueue:clear()
	end

	self:clearCaches()

	self._caches = nil
	self._loadingSet = nil

	self:clearQuestArrowTipTimer()
	UIComponent.onDestroy(self)
end

function QuestArrowTipComponent:checkPosInScreenGuidanceRegion(targetPos)
	local visible = false
	local vx, vy, vz = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])
	local dx = vx - 0.5
	local dy = vy - 0.5

	if vz > 0 then
		local dist = dx * dx / self.sqrX + dy * dy / self.sqrY

		visible = dist <= 1
	end

	return visible, dx, dy, vz
end

function QuestArrowTipComponent:checkPosInScreenGuidanceRegionXYZ(x, y, z)
	local visible = false
	local targetViewportPosX, targetViewportPosY, targetViewportPosZ = pg.global.cameraMgr:GetTargetViewportPosXYZ(x, y, z)

	if targetViewportPosZ > 0 then
		targetViewportPosX = targetViewportPosX - 0.5
		targetViewportPosY = targetViewportPosY - 0.5

		local dist = targetViewportPosX * targetViewportPosX / self.sqrX + targetViewportPosY * targetViewportPosY / self.sqrY

		if dist <= 1 then
			visible = true
		end
	end

	return visible
end

function QuestArrowTipComponent:checkGuidenceVisibleDistance(targetPos, showSqrDis, isShowQuestIcon)
	if targetPos[2] == 9999 then
		return false, 9999
	end

	local sqrDis = Vector3.SqrDistance(targetPos, self.playerPos)
	local isShow = isShowQuestIcon or sqrDis >= minNotTracedQuestHudSqrDis and sqrDis <= showSqrDis

	return isShow, sqrDis
end

function QuestArrowTipComponent:ShowQuestMark(id, targetPos, sqrDis, data, dx, dy)
	local arrowData = self.questArrowPool[id]

	if arrowData then
		if arrowData.taskId then
			return
		end

		if arrowData.isHidden then
			arrowData.isHidden = false

			LuaUIUtils.setUIViewVisible(arrowData.arrowTrans, true)
			arrowData.arrowTransWidget:ProgressActive(true)
		end

		if arrowData.firstShowAni and arrowData.panelUcomponent then
			arrowData.firstShowAni = false

			arrowData.panelUcomponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end

		if arrowData.isArrow ~= false then
			arrowData.isArrow = false

			arrowData.panelUcomponent:TryChangePage("Arrow", 1)

			arrowData.lastDx = nil
		end

		local newShow = sqrDis >= 121

		if newShow ~= arrowData.showDist then
			arrowData.showDist = newShow

			LuaUIUtils.setUIViewVisible(arrowData.distanceText, newShow)
		end

		local heightDiff = targetPos[2] - self.playerPos.y
		local layerGap = self.model.LAYER_GAP
		local curLayer = sqrDis <= self.model.LAYER_SQR_DISTANCE and (heightDiff < -layerGap and -1 or layerGap < heightDiff and 1 or 0) or 0

		if arrowData.showLayer ~= curLayer then
			arrowData.showLayer = curLayer

			if arrowData.panelUcomponent then
				arrowData.panelUcomponent:InvokeCallback(CS.XGUI.EInvokeTime.User3)
			end

			if curLayer < 0 then
				LuaUIUtils.setUIViewVisible(arrowData.txtDirectionUSDFText, true)

				arrowData.txtDirectionUSDFText.text = pg.getGameString("LAYER_BELOW")
			elseif curLayer > 0 then
				LuaUIUtils.setUIViewVisible(arrowData.txtDirectionUSDFText, true)

				arrowData.txtDirectionUSDFText.text = pg.getGameString("LAYER_ABOVE")
			else
				LuaUIUtils.setUIViewVisible(arrowData.txtDirectionUSDFText, false)
			end
		end

		if dx ~= arrowData.lastDx or dy ~= arrowData.lastDy then
			arrowData.lastDx = dx
			arrowData.lastDy = dy

			pg.global.uiMgr:SetRectTransformAnchoredByViewport(arrowData.arrowTrans, dx, dy)
		end

		local dis = math.floor(math.sqrt(sqrDis))

		if arrowData.showedDistance ~= dis then
			arrowData.showedDistance = dis

			self._textQueue:push_unique(id)
		end
	else
		self:addLoadingSet(id, data)
	end
end

function QuestArrowTipComponent:ShowQuestArrow(id, targetPos, data, dx, dy, vz)
	local arrowData = self.questArrowPool[id]

	if arrowData then
		if arrowData.taskId then
			return
		end

		if arrowData.isHidden then
			LuaUIUtils.setUIViewVisible(arrowData.arrowTrans, true)
			arrowData.arrowTransWidget:ProgressActive(true)

			arrowData.isHidden = false
		end

		if arrowData.showDist then
			LuaUIUtils.setUIViewVisible(arrowData.distanceText, false)

			arrowData.showDist = false
		end

		if arrowData.isArrow ~= true then
			arrowData.panelUcomponent:TryChangePage("Arrow", 0)
			LuaUIUtils.setUIViewVisible(arrowData.txtDirectionUSDFText, false)

			arrowData.isArrow = true
			arrowData.showLayer = nil
			arrowData.lastDx = nil
		end

		local vzSign = vz < 0

		if dx ~= arrowData.lastDx or dy ~= arrowData.lastDy or vzSign ~= arrowData.lastVzSign then
			arrowData.lastDx = dx
			arrowData.lastDy = dy
			arrowData.lastVzSign = vzSign

			LuaUIUtils.setArrowTipRtPosAndRotByViewport(arrowData.arrowTrans, arrowData.imgArrowTrans, targetPos, dx, dy, vz, self.ratioX, self.ratioY, 90)
		end
	else
		self:addLoadingSet(id, data)
	end
end

function QuestArrowTipComponent:hideQuestArrow(id)
	local arrowData = self.questArrowPool[id]

	if arrowData == nil then
		return
	end

	self:hideQuestArrowEx(id)
end

function QuestArrowTipComponent:hideQuestArrowEx(id)
	local arrowData = self.questArrowPool[id]

	self:AddToCache(arrowData)

	self.questArrowPool[id] = nil

	self:removeTrackDisplayPosition(id)
end

function QuestArrowTipComponent:addLoadingSet(id, data)
	self._loadingSet[id] = data
end

function QuestArrowTipComponent:updateLoadingSet()
	local id, data = raw_next(self._loadingSet)

	if not id then
		return
	end

	if self.questArrowPool[id] then
		return
	end

	self._loadingSet[id] = nil

	local cache = self:GetFromCache()

	if cache then
		self:initQuestItem(cache, id, data)

		self.questArrowPool[id] = cache

		return
	end

	local quest = {}

	self.questArrowPool[id] = quest
	quest.id = id
	quest.taskId = pg.global.resMgr:ResInstantiateAsync(self.arrowObjPrefab, function(objInfo, userData)
		if self.questArrowPool[id] ~= quest then
			if objInfo then
				pg.global.resMgr:ResDestroyObject(objInfo)
			end

			return
		end

		if not objInfo then
			self.questArrowPool[id] = nil

			return
		end

		local objectReference = objInfo.transform:GetComponent("ObjectReference")

		quest.obj = objInfo.gameObject
		quest.trans = objInfo.transform
		quest.arrowTrans = objInfo:GetComponent("RectTransform")
		quest.panelUcomponent = objectReference:GetRefValue("panelUComponent")
		quest.imgArrowTrans = objectReference:GetRefValue("arrowRectTransform")
		quest.distanceText = objectReference:GetRefValue("distanceUText")
		quest.arrowTransWidget = objectReference:GetRefValue("questNumberUWidget")
		quest.txtDirectionUSDFText = objectReference:GetRefValue("txtDirectionUSDFText")
		quest.iconUImage = objectReference:GetRefValue("iconUImage")

		quest.panelUcomponent:TryInit()
		self:initQuestItem(quest, id, data)

		quest.taskId = nil
	end, self.transform.position, Quaternion.identity, self.view.markerListTransformLayer99.transform)
end

function QuestArrowTipComponent:initQuestItem(quest, id, data)
	quest.id = id
	quest.firstShowAni = true
	quest.isHidden = true
	quest.showLayer = nil
	quest.isArrow = nil
	quest.showDist = false
	quest.activeStatus = false
	quest.showedDistance = 0
	quest.lastDx = nil
	quest.lastDy = nil
	quest.lastVzSign = nil
	quest.obj.name = string.format("Quest_Arrow_%s_%s", id, data.questId)

	local taskType = data.taskType

	if taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE then
		quest.panelUcomponent:TryChangePage("OtherTask", 0)
		quest.panelUcomponent:TryChangePage("TaskType", taskType.taskType)
	elseif taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
		quest.panelUcomponent:TryChangePage("OtherTask", 1)

		quest.iconUImage.url = taskType.deliverIcon
	end

	LuaUIUtils.setUIViewVisible(quest.arrowTrans, false)
	LuaUIUtils.setUIViewVisible(quest.distanceText, false)
	LuaUIUtils.setUIViewVisible(quest.txtDirectionUSDFText, false)
	quest.arrowTransWidget:ProgressActive(false)
end

function QuestArrowTipComponent:destroyAllQuestArrowInstances(destroy)
	self:clearTrackDisplayPositions()

	for index, data in raw_next, self.questArrowPool do
		if destroy then
			self:clearCache(data)
		else
			self:AddToCache(data)
		end

		self.questArrowPool[index] = nil
	end

	table.clear(self._loadingSet)
end

function QuestArrowTipComponent:GetFromCache()
	local tip = raw_next(self._caches)

	if tip then
		self._caches[tip] = nil

		return tip
	end

	return nil
end

function QuestArrowTipComponent:AddToCache(tip)
	if tip.taskId then
		pg.global.uiMgr:CancelUIAsyncTask(tip.taskId)

		tip.taskId = nil

		return
	end

	if not tip.obj then
		return
	end

	tip.arrowTransWidget:ProgressActive(false)

	tip.isHidden = true
	tip.firstShowAni = true
	self._caches[tip] = Time.unityFrameCount
end

function QuestArrowTipComponent:clearCache(cache)
	if cache.obj then
		pg.global.resMgr:ResDestroyObject(cache.obj)
	end

	self._caches[cache] = nil
end

function QuestArrowTipComponent:clearCaches()
	for cache in raw_next, self._caches do
		self:clearCache(cache)
	end
end

function QuestArrowTipComponent:updateCache()
	local now = Time.unityFrameCount

	for cache, time in raw_next, self._caches do
		if now > time + 1800 then
			self:clearCache(cache)

			break
		end
	end
end

function QuestArrowTipComponent:getTopLogoCount(entities)
	local count = 0

	for entId, ent in raw_next, entities do
		self.m_tempQuestComp = ent and ent.getToplogoComponent and ent:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST) or nil

		if self.m_tempQuestComp and self.m_tempQuestComp:isQuestActive() then
			count = count + 1
		end
	end

	return count
end

function QuestArrowTipComponent:onSceneLoaded()
	self:destroyAllQuestArrowInstances(false)

	self.questArrowData = {}
	self.questShowData = {}

	self:clearQuestArrowTipTimer()
	self:initQuestArrowTipData()
end

function QuestArrowTipComponent:initQuestArrowTipData()
	local quests = QuestUtils.getAllCanShowArrowQuests()

	if quests == nil then
		return
	end

	self:refreshQuestArrowTipData(quests)
end

function QuestArrowTipComponent:refreshQuestArrowTipData(questData)
	for _, curTracingQuest in pairs(questData) do
		local isReceived = QuestUtils.isQuestInState(curTracingQuest.configId, QuestConst.QUEST_STATE.RECEIVED)
		local isCompleted = QuestUtils.isQuestInState(curTracingQuest.configId, QuestConst.QUEST_STATE.COMPLETED)
		local questTargetInfo = QuestUtils.getQuestTargetInfo(curTracingQuest, true)
		local isShowCurPage = QuestUtils.isPageContainQuest(curTracingQuest.configId)
		local isShowQuestTracking = QuestUtils.canShowQuestTracking(curTracingQuest.configId)

		if isReceived and questTargetInfo ~= nil and isShowQuestTracking then
			local targetCount = #questTargetInfo.posInfo
			local isAdd = false

			if targetCount > 0 then
				local questConfig = QuestUtils.getQuestConfig(curTracingQuest.configId)
				local curQuestData = QuestUtils.getQuestData(curTracingQuest.configId)

				for i = 1, targetCount do
					local targetInfo = questTargetInfo.posInfo[i]
					local targetPosConfig = targetInfo.posConfig
					local sceneId = targetPosConfig and targetPosConfig.scene
					local targetTemplateId = targetPosConfig and targetPosConfig.petPrototypeId
					local targetEntityStaticId = targetPosConfig and targetPosConfig.entity
					local showDistance = targetPosConfig and targetPosConfig.showDistance or 9999
					local showNumMax = targetPosConfig and targetPosConfig.showNumMax

					if targetInfo.pos ~= nil and sceneId ~= nil and not QuestUtils.isQuestIconOtherStyleType(curTracingQuest.configId) and (QuestUtils.isQuestTracing(curTracingQuest.configId) or QuestUtils.isRootQuestTracing(curTracingQuest.configId)) then
						self:addQuestArrowTipData(curTracingQuest.configId, sceneId, targetInfo, targetTemplateId, targetEntityStaticId, curQuestData.state, questConfig.questType, showDistance, showNumMax)

						isAdd = true
					end
				end
			end

			self.questTargetInfo[curTracingQuest.configId] = questTargetInfo
		elseif QuestUtils.isQuestManualClaimable(curTracingQuest.configId) then
			local questConfig = QuestUtils.getQuestConfig(curTracingQuest.configId)
			local curQuestData = QuestUtils.getQuestData(curTracingQuest.configId)
			local targetEntityStaticId = questConfig.receiveNpc

			if ToBool(targetEntityStaticId) then
				local targetInfo = {
					index = 50,
					pos = self.INVALID_POS
				}

				self:addQuestArrowTipData(curTracingQuest.configId, -1, targetInfo, nil, targetEntityStaticId, curQuestData.state, questConfig.questType)

				self.questTargetInfo[curTracingQuest.configId] = targetInfo
			end
		elseif QuestUtils.isQuestManualCommit(curTracingQuest.configId) then
			local questConfig = QuestUtils.getQuestConfig(curTracingQuest.configId)
			local curQuestData = QuestUtils.getQuestData(curTracingQuest.configId)
			local targetEntityStaticId = questConfig.deliverNpc

			if ToBool(targetEntityStaticId) then
				local targetInfo = {
					index = 51,
					pos = self.INVALID_POS
				}

				self:addQuestArrowTipData(curTracingQuest.configId, -1, targetInfo, nil, targetEntityStaticId, curQuestData.state, questConfig.questType)

				self.questTargetInfo[curTracingQuest.configId] = targetInfo
			end
		elseif isCompleted and QuestUtils.isShowQuestDialogueGraphMark(curTracingQuest.configId) then
			local questConfig = QuestUtils.getQuestConfig(curTracingQuest.configId)
			local curQuestData = QuestUtils.getQuestData(curTracingQuest.configId)
			local dialogueId = QuestUtils.getComActionObjcvDialogueId(curTracingQuest.configId)

			if dialogueId and dialogueId > 0 then
				local scene, targetPosition = QuestUtils.getDialogueGraphTargetPosition(dialogueId)

				if scene and targetPosition then
					local targetScenePositionData = SceneUtils.getSceneTargetPositionData(scene)
					local targetScenePosition = targetScenePositionData and targetScenePositionData[targetPosition] or nil

					if targetScenePosition then
						local targetInfo = {
							index = 51,
							pos = targetScenePosition.position
						}

						self:addQuestArrowTipData(curTracingQuest.configId, scene, targetInfo, nil, targetScenePosition.entity, curQuestData.state, questConfig.questType)

						self.questTargetInfo[curTracingQuest.configId] = targetInfo
					end
				end
			end
		end
	end
end

function QuestArrowTipComponent:onQuestStateChange(data)
	local questData = QuestUtils.getQuestData(data.questId)

	if questData == nil then
		if self.questTargetInfo[data.questId] ~= nil then
			self:removeQuestArrowTip(data.questId)
		end

		return
	end

	if not QuestUtils.canQusetShowArrowFlag(questData.configId) then
		if self.questTargetInfo[data.questId] ~= nil then
			self:removeQuestArrowTip(data.questId)
		end

		return
	end

	if self.questTargetInfo[data.questId] == nil then
		self:refreshQuestArrowTipData({
			questData
		})
	else
		self:removeQuestArrowTip(data.questId)
		self:refreshQuestArrowTipData({
			questData
		})
	end
end

function QuestArrowTipComponent:onQuestObjectiveFinished(data)
	local questId = data.questId
	local objectiveId = data.objectiveId
	local questTargetInfo = self.questTargetInfo[questId]

	if questTargetInfo == nil then
		return
	end

	if questTargetInfo.posInfo == nil then
		return
	end

	for i = 1, #questTargetInfo.posInfo do
		local targetInfo = questTargetInfo.posInfo[i]

		if questTargetInfo.questId == questId and targetInfo.objId == objectiveId then
			self:removeQuestArrowTipData(questTargetInfo.questId, targetInfo.objId)

			break
		end
	end

	if #questTargetInfo.posInfo == 0 then
		self.questTargetInfo[questId] = nil
	end
end

function QuestArrowTipComponent:onQuestTraceChange(questData)
	if self.questTargetInfo ~= nil then
		self:removeAllQuestArrowTip()
	end

	local quests = QuestUtils.getAllCanShowArrowQuests()

	if quests == nil then
		return
	end

	self:refreshQuestArrowTipData(quests)
end

function QuestArrowTipComponent:onQuestRunStateChange(data)
	local questId = data and data.questId

	if not questId then
		return
	end

	if not QuestUtils.isQuestTracing(questId) and not QuestUtils.isRootQuestTracing(questId) then
		return
	end

	self:removeQuestArrowTip(questId)

	if data.isRun then
		local questData = QuestUtils.getQuestData(questId)

		if questData then
			self:refreshQuestArrowTipData({
				questData
			})
		end
	end
end

function QuestArrowTipComponent:onQuestTabSwitch(questData)
	for id, data in pairs(self.questArrowData) do
		if not questData or not questData.questId or questData.questId <= 0 or data.questId == questData.questId then
			local arrowData = self.questArrowPool[id]

			if arrowData and not arrowData.taskId and arrowData.panelUcomponent and not QuestUtils.isQuestIconOtherStyleType(data.questId) and QuestUtils.getQuestType(data.questId) ~= QuestConst.QUEST_TYPE.CLUE then
				arrowData.panelUcomponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end
		end
	end
end

function QuestArrowTipComponent:removeAllQuestArrowTip()
	for questId, v in pairs(self.questTargetInfo) do
		self:removeQuestArrowTip(questId)
	end

	self.questTargetInfo = {}
end

function QuestArrowTipComponent:removeQuestArrowTip(questId)
	local questTargetInfo = self.questTargetInfo[questId]

	if questTargetInfo ~= nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:log2Tag("QuestArrow", "@hyj removeQuestArrowTip: ", questId)
		end

		self:removeQuestArrowTipData(questId, 50)
		self:removeQuestArrowTipData(questId, 51)

		if not questTargetInfo.posInfo then
			self.questTargetInfo[questId] = nil

			return
		end

		local targetCount = #questTargetInfo.posInfo

		if targetCount > 0 then
			for i = 1, targetCount do
				local targetInfo = questTargetInfo.posInfo[i]

				self:removeQuestArrowTipData(questId, targetInfo.objId)
			end
		end

		self.questTargetInfo[questId] = nil
	end
end

function QuestArrowTipComponent:refreshAllQuestArrowHideState()
	if pg.game.setting:getHideAllHudArrowType() then
		self:clearTrackDisplayPositions()

		for id, data in pairs(self.questArrowData) do
			self:hideQuestArrow(id)
		end

		self:clearQuestArrowTipTimer()
	elseif ToBool(self.questArrowData) then
		self:startQuestArrowTipTimer()
	end
end

function QuestArrowTipComponent:isTrackDisplayActiveAt(targetPos)
	if targetPos == nil then
		return false
	end

	for i = 1, self.trackDisplayPositionCount or 0 do
		if self.ctrl:isSameTrackTarget(self.trackDisplayPositions[i], targetPos) then
			return true
		end
	end

	return false
end

function QuestArrowTipComponent:findQuestArrowDataByStaticId(targetEntityStaticId)
	if not self.questArrowData then
		return nil
	end

	for idx, data in pairs(self.questArrowData) do
		if data.targetEntityStaticId == targetEntityStaticId then
			return data
		end
	end

	return nil
end

return QuestArrowTipComponent
