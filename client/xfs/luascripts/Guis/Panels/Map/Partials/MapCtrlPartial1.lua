-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Partials\\MapCtrlPartial1.lua

local MapMarkResourceData = require("Data.map_mark_resource_data")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local Const = require("Common.Const.Const")
local MapUtils = require("Guis.Utils.MapUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local PuppetData = require("Data.puppet_data")
local NpcFuncData = require("Data.npc_func_data")
local QuestConst = require("Common.Const.QuestConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MapLayerLevelData = require("Data.map_layer_level_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("MapCtrl")
local MapHelper = require("GameApp.Map.MapHelper")
local GrabEggMapMarkUtils = require("GameApp.GrabEgg.GrabEggMapMarkUtils")
local MAP_MARK_CONFIG_ZONE_CENTER = 14
local BOSS_CHALLENGE_MARK_CONFIG_ID = 10304

local function refreshAreaLabelAlignment(markConfigId, areaTxt)
	if markConfigId ~= MAP_MARK_CONFIG_ZONE_CENTER or not areaTxt then
		return
	end

	local textRect = areaTxt.transform

	if not textRect then
		return
	end

	textRect.pivot = Vector2(0.5, textRect.pivot.y)
	textRect.anchoredPosition = Vector2(0, textRect.anchoredPosition.y)
	areaTxt.alignment = CS.TMPro.TextAlignmentOptions.Center
end

return function(MapCtrl)
	function MapCtrl:resetBossChallengeInfo(objectReference)
		local bossChallengeRectTransform = objectReference:GetRefValue("bossChallengeRectTransform")

		bossChallengeRectTransform.gameObject:SetActiveEx(false)

		local bossChallengeObjectReference = bossChallengeRectTransform:GetComponent("ObjectReference")
		local imageRectTransform = bossChallengeObjectReference:GetRefValue("imageRectTransform")

		if NotNil(imageRectTransform) then
			imageRectTransform.gameObject:SetActiveEx(false)
		end

		return bossChallengeRectTransform, bossChallengeObjectReference, imageRectTransform
	end

	function MapCtrl:renderBossChallengeInfo(objectReference, spawnerId, markConfigId)
		local bossChallengeRectTransform, bossChallengeObjectReference, imageRectTransform = self:resetBossChallengeInfo(objectReference)

		if markConfigId ~= BOSS_CHALLENGE_MARK_CONFIG_ID then
			return
		end

		local markCache = self.markCaches[spawnerId]

		if not markCache or markCache.markStatus <= Const.MAP_MARK_STATUS_LOCKED then
			return
		end

		local challengeInfo = self.model:getBossChallengeInfo(spawnerId)

		if not challengeInfo then
			return
		end

		local textAwardUSDFText = bossChallengeObjectReference:GetRefValue("textAwardUSDFText")
		local textAwardNumUSDFText = bossChallengeObjectReference:GetRefValue("textAwardNumUSDFText")
		local textAwardMaxUSDFText = bossChallengeObjectReference:GetRefValue("textAwardMaxUSDFText")
		local textConsumptionUSDFText = bossChallengeObjectReference:GetRefValue("textConsumptionUSDFText")
		local textConsumptionNumUSDFText = bossChallengeObjectReference:GetRefValue("textConsumptionNumUSDFText")

		ClientTextUtils.setText(textAwardUSDFText, pg.getGameString("MAP_BOSS_CHALLENGE_WEEKLY_REWARD_COUNT"))
		ClientTextUtils.setText(textAwardNumUSDFText, pg.getFormatText(pg.getGameString("MAP_BOSS_CHALLENGE_REWARD_COUNT_FORMAT"), challengeInfo.remainCount, challengeInfo.totalCount))
		ClientTextUtils.setText(textAwardMaxUSDFText, pg.getGameString("MAP_BOSS_CHALLENGE_REWARD_COUNT_MAX"))
		ClientTextUtils.setText(textConsumptionUSDFText, pg.getGameString("MAP_BOSS_CHALLENGE_REWARD_COST"))
		ClientTextUtils.setText(textConsumptionNumUSDFText, pg.getFormatText(pg.getGameString("MAP_BOSS_CHALLENGE_REWARD_COST_FORMAT"), challengeInfo.costItemNum))

		if NotNil(imageRectTransform) then
			imageRectTransform.gameObject:SetActiveEx(challengeInfo.remainCount == challengeInfo.totalCount)
		end

		bossChallengeRectTransform.gameObject:SetActiveEx(true)
	end

	function MapCtrl:renderBossPanelInfo(objectReference, locationInfo, spawnerId)
		local bossInfoUWidget = objectReference:GetRefValue("bossInfoUWidget")

		bossInfoUWidget.gameObject:SetActiveEx(true)

		local objectReference1 = bossInfoUWidget.transform:GetComponent("ObjectReference")
		local txtLvUSDFText = objectReference1:GetRefValue("txtLvUSDFText")
		local listElementUList = objectReference1:GetRefValue("listElementUList")

		ClientTextUtils.setText(txtLvUSDFText, locationInfo.maxLevelRequire and ClientTextUtils.formatShortLevel(locationInfo.maxLevelRequire) or pg.getGameString("LEVEL_NOT_VALID"))

		if locationInfo.idInType then
			LuaUIUtils.requestMapPuppetLevel(locationInfo.idInType, function(level)
				if locationInfo.entityId then
					pg.game.map.puppetStaticIdInitRecord[locationInfo.entityId] = level
				end

				ClientTextUtils.setText(txtLvUSDFText, ClientTextUtils.formatShortLevel(level))
			end)
		end

		function listElementUList.luaRenderItem(b, _, d)
			LuaUIUtils.setElementButtonNew(b, d.elementId)
		end

		if locationInfo.extraProperties then
			listElementUList:SetList(locationInfo.extraProperties and (locationInfo.extraProperties.originalProperties or {}) or {})
		else
			listElementUList:SetList({})
		end
	end

	function MapCtrl:renderBossPanelPropertyInfo(objectReference, locationInfo, spawnerTable)
		local bossEffectTransform = objectReference:GetRefValue("bossEffectTransform")
		local objectReference1 = bossEffectTransform:GetComponent("ObjectReference")
		local txtRestrainUSDFText = objectReference1:GetRefValue("txtRestrainUSDFText")
		local txtRestrainedUSDFText = objectReference1:GetRefValue("txtRestrainedUSDFText")
		local listRestrainElementUList = objectReference1:GetRefValue("listRestrainElementUList")
		local listRestrainedElementUList = objectReference1:GetRefValue("listRestrainedElementUList")
		local btnEffectUButton = objectReference1:GetRefValue("btnEffectUButton")
		local textUSDFText = objectReference1:GetRefValue("textUSDFText")

		ClientTextUtils.setText(txtRestrainUSDFText, pg.getGameString("SUPER_EFFECTIVE"))
		ClientTextUtils.setText(txtRestrainedUSDFText, pg.getGameString("NOT_EFFECTIVE"))
		ClientTextUtils.setText(textUSDFText, pg.getGameString("RECOMMEND_PET_POPUP_TITLE"))

		if Const.MAP_INFO_BOSS_PANEL[spawnerTable.markConfigId] then
			bossEffectTransform.gameObject:SetActiveEx(true)
		else
			bossEffectTransform.gameObject:SetActiveEx(false)

			return
		end

		if locationInfo.extraProperties and locationInfo.extraProperties.restrainedProperties and locationInfo.propertyPrefer then
			function listRestrainElementUList.luaRenderItem(b, _, d)
				LuaUIUtils.setElementButtonNew(b, d.elementId)
			end

			function listRestrainedElementUList.luaRenderItem(b, _, d)
				LuaUIUtils.setElementButtonNew(b, d.elementId)
			end

			listRestrainElementUList:SetList(locationInfo.propertyPrefer)
			listRestrainedElementUList:SetList(locationInfo.extraProperties.restrainedProperties)
		else
			bossEffectTransform.gameObject:SetActiveEx(false)

			return
		end

		local recommendPet = locationInfo.recommendPet
		local hasRecommendPet = recommendPet ~= nil and #recommendPet > 0

		btnEffectUButton.gameObject:SetActiveEx(hasRecommendPet)

		if hasRecommendPet then
			function btnEffectUButton.luaClick()
				pg.global.ui:open(UIConst.UI_ID_RECOMMEND_PET, {
					recommendPet = recommendPet
				})
			end
		end
	end

	function MapCtrl:loadResInner(objInfo, spawnerId, spawnerTable)
		if not self.view then
			return
		end

		if spawnerTable.markType == Const.MAP_MARK_CUSTOM and spawnerTable.type ~= Const.MAP_CONST.TYPE.CUSTOM then
			self.customMarkerPool:recycleToPool(spawnerId)

			return
		end

		local x = spawnerTable.markPosition[1]
		local z = spawnerTable.markPosition[3]
		local cache = {}
		local mapX, mapY = pg.game.map:convertPos(x, z, spawnerTable.realSceneId, true)

		cache.markName = string.format("mark_%s_%s", spawnerTable.markType, spawnerId)
		objInfo.gameObject.name = cache.markName

		local root = objInfo.gameObject.transform:GetComponent("UButton")
		local recTrans = objInfo.gameObject:GetComponent("RectTransform")

		recTrans.anchoredPosition = Vector2(mapX, mapY)
		cache.spawnerId = spawnerId
		cache.anchoredPositionX = mapX
		cache.anchoredPositionY = mapY
		cache.realAnchoredPositionX = mapX
		cache.realAnchoredPositionY = mapY
		cache.realSceneId = spawnerTable.realSceneId
		cache.scale1 = spawnerTable.scale1
		cache.scale2 = spawnerTable.scale2
		cache.scale3 = spawnerTable.scale3
		cache.scale4 = spawnerTable.scale4
		cache.mapX = mapX
		cache.mapY = mapY
		cache.spawnerId = spawnerId
		cache.type = spawnerTable.type
		cache.objId = spawnerTable.objId
		cache.markPos = {
			spawnerTable.markPosition[1],
			spawnerTable.markPosition[2],
			spawnerTable.markPosition[3]
		}
		cache.markType = spawnerTable.markType
		cache.markConfigId = spawnerTable.markConfigId
		cache.belongAreaId = spawnerTable.belongAreaId
		cache.markStatus = self:markTypeProcessed(spawnerId, spawnerTable.markType)

		if spawnerTable.markType == Const.MAP_MARK_CLUE then
			cache.markStatus = QuestUtils.getClueMarkStatus(spawnerId)
		end

		cache.UsableState = spawnerTable.UsableState
		cache.recTrans = recTrans
		cache.gameObject = objInfo.gameObject
		cache.button = root
		cache.ClickorNot = spawnerTable.ClickorNot
		cache.priority = pg.game.map:getMarkPriorityByConfigId(spawnerTable.markConfigId)

		objInfo.gameObject:SetActiveEx(false)

		local markLevel = DefaultMapMarkData[spawnerTable.markConfigId].markLevel or 1
		local objRef = objInfo.gameObject:GetComponent("ObjectReference")
		local btnRectTransform = objRef:GetRefValue("btnRectTransform")
		local lowerDynamicLoadTransform = objRef:GetRefValue("lowerDynamicLoadTransform")
		local upperDynamicLoadTransform = objRef:GetRefValue("upperDynamicLoadTransform")

		btnRectTransform.localScale = UIConst.MAP_CONST.SIZE_DELTA[markLevel]
		cache.markLevel = markLevel
		cache.btnRectTransform = btnRectTransform
		cache.lowerDynamicLoadTransform = lowerDynamicLoadTransform
		cache.upperDynamicLoadTransform = upperDynamicLoadTransform
		cache.finishStateAlwaysShow = spawnerTable.finishStateAlwaysShow

		local trackMarkExists = self:_checkTrackMarkExists(spawnerId)

		if trackMarkExists then
			self:_cleanupTrackPrefab(spawnerId)

			cache.trackTaskId = self.view:addPrefabWithPathAsync(lowerDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_TRACK, function(obj)
				cache.trackObj = obj.gameObject
				self.trackTaskObjTable[spawnerId] = obj.gameObject
			end, false, false, 0)
			self.trackTaskTable[spawnerId] = cache.trackTaskId
		else
			self:_cleanupTrackPrefab(spawnerId)
		end

		if spawnerTable.ClickorNot ~= 0 then
			objInfo.gameObject.transform:Find("RayBox").gameObject:SetActiveEx(false)
		end

		local scale = spawnerTable[string.format("scale%s", self:curStageScaleConvertor(self.curStage))]

		cache.scale = scale

		self:clearPreviousTask(spawnerId)

		cache.poolGeneration = self._markPoolGenerations[spawnerId]

		self:renderInAreaRange(spawnerId, cache)
		self:renderCompleteIcon(spawnerId, cache)
		self:renderCoffeeShopCornerIcon(spawnerId, cache)
		self:renderTeamTrack(spawnerId, cache)

		local imgPath, locationImgPath, isUnKnownImg

		if spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
			recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

			local worldTemplateId = MapHelper.getRainbowPetTemplateIdByPointId(spawnerId, spawnerTable.realSceneId or self.sceneId)
			local puppetData = PuppetData[worldTemplateId]
			local petTemplateId = puppetData and puppetData.petPrototypeId or worldTemplateId

			imgPath = LuaUIUtils.getPetIconByTemplateId(petTemplateId, LuaUIUtils.PET_ICON)
			locationImgPath = imgPath
			cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_CULTIVATE, function(obj1)
				local objectReference = obj1.gameObject:GetComponent("ObjectReference")
				local worldTemplateId = pg.space and pg.space.getRainbowPetTemplateIdByPointId and pg.space:getRainbowPetTemplateIdByPointId(spawnerId)

				LuaUIUtils.renderRainbowPetIcon(objectReference:GetRefValue("playerHeadRectTransform"), MapHelper.getRainbowPetTemplateIdByPointId(spawnerId, spawnerTable.realSceneId or self.sceneId))

				cache.resObj = obj1.gameObject
			end, false, false, 0)

			local isUsable = spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus)
			local shouldShow = isUsable and self:shouldShowMarkOnLoad(scale, spawnerId)

			objInfo.gameObject:SetActiveEx(shouldShow)

			if shouldShow then
				self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
			end
		elseif MapMarkResourceData[spawnerTable.markConfigId] and (MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]) or spawnerTable.markType == Const.MAP_MARK_ZONE or spawnerTable.markType == Const.MAP_MARK_QUEST or spawnerTable.markType == Const.MAP_MARK_CUSTOM or spawnerTable.markType == Const.MAP_MARK_SHARE or spawnerTable.markType == Const.MAP_MARK_DYNAMIC or spawnerTable.markType == Const.MAP_MARK_ALLY or spawnerTable.markType == Const.MAP_MARK_FAST_TARGET or spawnerTable.markType == Const.MAP_MARK_GOLD_MONSTER then
			if spawnerTable.type == Const.MAP_CONST.TYPE.NORMAL then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				if spawnerTable.replaceIcon then
					imgPath = spawnerTable.replaceIcon
				else
					local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

					if Const.MAP_MARK_STATUS_HIDE == cache.markStatus or Const.MAP_MARK_STATUS_LOCKED == cache.markStatus then
						if spawnerTable.markType == Const.MAP_MARK_CLUE then
							imgPath = nil
						else
							imgPath = MapUtils.getMarkDefaultUnKnownResIcon(spawnerTable.markConfigId)
						end
					elseif Const.MAP_MARK_STATUS_UNLOCKED == cache.markStatus then
						imgPath = defaultRes.icon
					elseif Const.MAP_MARK_STATUS_CLOSED == cache.markStatus then
						imgPath = defaultRes.icon
					end
				end

				local isGrabEggTransmitter = spawnerTable.markConfigId == MapUtils.GRAB_EGG_TRANSMITTER_MARK_CONFIG_ID

				if isGrabEggTransmitter then
					locationImgPath = MapUtils.getGrabEggTransmitterIcon(spawnerId)
				else
					locationImgPath = imgPath
				end

				if imgPath then
					if isGrabEggTransmitter then
						cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_GRAB_EGG_TRANSMITTER, function(obj1)
							local uComponent = obj1.gameObject:GetComponent("UComponent")

							if NotNil(uComponent) then
								local isInUse = MapUtils.isGrabEggTransmitterInUse(spawnerId)

								uComponent:TryChangePage("Active", isInUse and 1 or 0)
							end

							cache.resObj = obj1.gameObject
						end, false, false, 0)
					else
						self:_acquireCommonMarkIcon(cache, btnRectTransform, imgPath)
					end
				end

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end

				if spawnerTable.markType == Const.MAP_MARK_TRACE and not pg.game.map.curTraceMark[spawnerId] and not pg.game.map.trackMarksRecord[spawnerId] then
					objInfo.gameObject:SetActiveEx(false)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.SINGLE_PUPPET then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local idInType = spawnerTable.idInType
				local puppetData = idInType and PuppetData[idInType] or nil
				local iconName = puppetData and puppetData.iconName or nil

				imgPath = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)

				if cache.markStatus == Const.MAP_MARK_STATUS_LOCKED then
					locationImgPath = AddressDataConst.UI_MARK_IMG_BORDER_BOSS2
					imgPath = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE
					cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_NO_ACTIVE, function(obj1)
						local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

						objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE
						objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS2
						cache.resObj = obj1.gameObject
					end, false, false, 0)
				else
					locationImgPath = AddressDataConst.UI_MARK_IMG_BORDER_BOSS
					cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_ACTIVE, function(obj1)
						local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

						objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = imgPath
						objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS
						cache.resObj = obj1.gameObject
					end, false, false, 0)
				end

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.BOSS then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local idInType = spawnerTable.idInType
				local puppetData = idInType and PuppetData[idInType] or nil
				local iconName = puppetData and puppetData.iconName or nil

				imgPath = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)

				if cache.markStatus == Const.MAP_MARK_STATUS_LOCKED then
					locationImgPath = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
					imgPath = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE1
					cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_NO_ACTIVE, function(obj1)
						local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

						objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE1
						objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
						cache.resObj = obj1.gameObject
					end, false, false, 0)
				else
					locationImgPath = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
					cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_ACTIVE, function(obj1)
						local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

						objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = imgPath
						objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
						cache.resObj = obj1.gameObject
					end, false, false, 0)
				end

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.NPC then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local npcId = spawnerTable.idInType

				if not npcId then
					imgPath = nil
				else
					local spData = pg.game.map:getNPCSpecialState(spawnerId)

					if spData and spData.iconMap then
						imgPath = spData.iconMap
					elseif NpcFuncData[npcId] and NpcFuncData[npcId].iconMap then
						imgPath = NpcFuncData[npcId].iconMap
					else
						imgPath = nil
					end
				end

				locationImgPath = imgPath

				self:_acquireCommonMarkIcon(cache, btnRectTransform, imgPath)

				if self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.QUEST then
				cache.questId = spawnerTable.questId or 0

				local questConfig = QuestUtils.getQuestConfig(spawnerTable.questId)

				if not questConfig then
					return
				end

				spawnerTable.questMarkInfo = QuestUtils.getQuestMarkInfo(spawnerTable.questId, spawnerTable.objId)
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local showTag = false
				local id, isSpawnerId, relateData = pg.game.map:isContainMarkSpawnerId(cache.questId, cache.objId)
				local relateShow = false

				if isSpawnerId then
					relateShow = self.markMap:getStatus(self.sceneId, relateData.markType, id) > Const.MAP_MARK_STATUS_HIDE
				end

				if spawnerTable and isSpawnerId and pg.game.map:isShowQuestTagMark(cache.questId, cache.objId) and relateShow then
					showTag = true
				end

				if showTag then
					local relatePos = pg.game.map:getQuestTagRelateMarkPosition(cache.questId, cache.objId)

					if relatePos then
						local relX, relY = pg.game.map:convertPos(relatePos[1], relatePos[3], spawnerTable.realSceneId, true)

						recTrans.anchoredPosition = Vector2(relX, relY)
						cache.anchoredPositionX = relX
						cache.anchoredPositionY = relY
						cache.realAnchoredPositionX = relX
						cache.realAnchoredPositionY = relY
						cache.mapX = relX
						cache.mapY = relY
					end
				end

				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_QUEST, function(obj1)
					local questCmp = obj1.gameObject:GetComponent("UComponent")
					local objRef1 = obj1.gameObject:GetComponent("ObjectReference")
					local circleAreaTransform = objRef1:GetRefValue("circleAreaTransform")
					local questNumberUComponent = objRef1:GetRefValue("questNumberUComponent")
					local questNumberUComponentObj = questNumberUComponent.gameObject:GetComponent("ObjectReference")
					local iconUImage = questNumberUComponentObj:GetRefValue("iconUImage")

					if spawnerTable.questType == nil then
						if LoggerManager.checkLogger(LoggerConst.ERROR) then
							logger:error("questType is nil", inspect(spawnerTable))
						end

						return
					end

					obj1.gameObject.transform:SetSiblingIndex(spawnerTable.siblingIndex)

					local taskType = QuestUtils.getCurSideQuestShowType(cache.questId)

					if taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE then
						questNumberUComponent:TryChangePage("OtherTask", 0)
						questNumberUComponent:TryChangePage("TaskType", taskType.taskType)
					elseif taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
						questNumberUComponent:TryChangePage("OtherTask", 1)

						iconUImage.url = taskType.deliverIcon
					end

					questNumberUComponent:TryChangePage("Arrow", 1)
					questCmp:TryChangePage("showQuest", 1)
					questCmp:TryChangePage("showCircle", 0)

					if spawnerTable.circleRadius and spawnerTable.circleRadius > 0 then
						cache.circleRadius = spawnerTable.circleRadius

						questCmp:TryChangePage("showCircle", 1)

						local r = pg.game.map:calRadius(self.sceneId, spawnerTable.circleRadius)
						local sizeDeltaNum = r / (1 / self.currentZoom) * 2

						circleAreaTransform.transform.sizeDelta = Vector2(sizeDeltaNum, sizeDeltaNum)
					end

					local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

					locationImgPath = defaultRes.icon

					if self:shouldShowMarkOnLoad(scale, spawnerId) then
						objInfo.gameObject:SetActiveEx(true)
						self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
					end

					questNumberUComponent:SetActive(not showTag)

					cache.resObj = obj1.gameObject
				end, false, false, 0)

				if spawnerTable and isSpawnerId then
					cache.resTaskTagId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_QUEST_TAG, function(obj1)
						local questCmp = obj1.gameObject:GetComponent("UComponent")

						if spawnerTable.questId and spawnerTable.questId > 0 then
							local taskType = QuestUtils.getCurSideQuestShowType(spawnerTable.questId)

							questCmp:TryChangePage("TaskType", taskType.taskType)
						end

						questCmp:SetActive(showTag)

						cache.resTagObj = obj1.gameObject
					end, false, false, 0)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.AREA then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_AREA, function(obj1)
					local objRef1 = obj1.gameObject:GetComponent("ObjectReference")
					local cmp = obj1.gameObject:GetComponent("UComponent")
					local areaTxt = objRef1:GetRefValue("txtNameUText")
					local isGrabEgg = pg.space and pg.space:isGrabEgg()

					objRef1:GetRefValue("imgGlowRectTransform").gameObject:SetActiveEx(not isGrabEgg)
					ClientTextUtils.setText(areaTxt, pg.getLocalizationText(spawnerTable.txt))
					refreshAreaLabelAlignment(spawnerTable.markConfigId, areaTxt)

					local petProgressUBaseText = objRef1:GetRefValue("petProgressUBaseText")
					local recommandLvTxt = objRef1:GetRefValue("recommandLvTxt")
					local layoutInfoRectTransform = objRef1:GetRefValue("iconWeatherRectTransform")
					local redDotUButton = objRef1:GetRefValue("redDotUButton")
					local areaUButton = objRef1:GetRefValue("areaUButton")

					areaUButton.enableVirtualMouseHoverFunc = false

					local rayBoxUWidget = objRef1:GetRefValue("rayBoxUWidget")
					local iconUImage = objRef1:GetRefValue("iconUImage")

					if spawnerTable.favorableCollectId and spawnerTable.favorableCollectId ~= 0 then
						self.petCollectEffect[spawnerTable.favorableCollectId] = cmp

						cmp:TryChangePage("State", 0)

						local minLv, maxLv = MapHelper.getAreaRecommandLevel(spawnerTable.favorableCollectId)

						ClientTextUtils.setText(recommandLvTxt, string.format("%s~%s", minLv, maxLv))

						local showPetProgress = pg.me:getAreaFirstInData(spawnerTable.favorableCollectId)

						petProgressUBaseText:SetActive(showPetProgress)
						iconUImage:SetActive(showPetProgress)

						if self.mapPetAreaComponent then
							ClientTextUtils.setText(petProgressUBaseText, self.mapPetAreaComponent:getSmallAreaPetProgressStr(spawnerTable.favorableCollectId))
						end

						if showPetProgress then
							iconUImage.url = MapHelper.getPetCollectBadgeIconResId(spawnerTable.favorableCollectId)
							self.weatherEffectParent[spawnerTable.favorableCollectId] = layoutInfoRectTransform

							self:refreshAreaWeatherEffect(spawnerTable.favorableCollectId)

							self.petAreaRedDots[spawnerTable.favorableCollectId] = redDotUButton

							self:refreshPetAreaRedDot(spawnerTable.favorableCollectId, redDotUButton)

							function areaUButton.luaClick()
								if self.mapPetAreaComponent then
									self.mapPetAreaComponent:setPetAreaProgressTipInfo(nil, false, spawnerTable.favorableCollectId)
								end
							end

							self.petAreaRayBoxs[spawnerTable.favorableCollectId] = rayBoxUWidget

							rayBoxUWidget:SetActive(self.curStage == #self.view.scaleBasicTable)
						else
							cmp:TryChangePage("Weather", 1)
						end

						if not minLv then
							cmp:TryChangePage("Unlocked", showPetProgress and 0 or 1)
						elseif minLv >= pg.me.level + ClientConst.MAP_AREA_DANGER_LEVEL then
							cmp:TryChangePage("Unlocked", showPetProgress and 3 or 1)
						elseif minLv >= pg.me.level + ClientConst.MAP_AREA_WARNING_LEVEL then
							cmp:TryChangePage("Unlocked", showPetProgress and 2 or 1)
						else
							cmp:TryChangePage("Unlocked", showPetProgress and 0 or 1)
						end
					else
						cmp:TryChangePage("State", 1)
						cmp:TryChangePage("Unlocked", 0)
						cmp:TryChangePage("Weather", 1)
						petProgressUBaseText:SetActive(false)
						iconUImage:SetActive(false)
					end

					if scale == 1 then
						objInfo.gameObject:SetActiveEx(true)
					end

					cache.resObj = obj1.gameObject
				end, false, false, 0)
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.DISTRIBUTION_AREA then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local idInType = spawnerTable.idInType
				local puppetData = idInType and PuppetData[idInType] or nil
				local iconName = puppetData and puppetData.iconName or nil

				imgPath = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				locationImgPath = defaultRes.icon
				isUnKnownImg = "$UI_Img_Bg_Map_Mark_Pet_Unknown.png"
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_DISTRIBUTION, function(obj1)
					if cache.markStatus > Const.MAP_MARK_STATUS_LOCKED then
						local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

						objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = imgPath

						obj1.gameObject:GetComponent("UComponent"):TryChangePage("IsUnknown", 0)
					else
						obj1.gameObject:GetComponent("UComponent"):TryChangePage("IsUnknown", 1)
					end

					cache.resObj = obj1.gameObject
				end, false, false, 0)

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local flowerState = pg.me:getCurFlowerState(spawnerId)

				imgPath = MapUtils.getLeylineFlowerMarkIcon(spawnerTable.markConfigId, self.sceneId, cache.markStatus, flowerState)
				locationImgPath = imgPath
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_PLENTY, function(obj1)
					local currentFlowerState = pg.me:getCurFlowerState(spawnerId)
					local currentImgPath = MapUtils.getLeylineFlowerMarkIcon(spawnerTable.markConfigId, self.sceneId, cache.markStatus, currentFlowerState)
					local flowerInfo = pg.me:getCurFlowerInfo(spawnerId)
					local createId = pg.me:getCurFlowerCreateId(spawnerId)
					local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(spawnerId, createId)
					local radius = pg.game.map:calRadius(self.sceneId, plentyInfo and plentyInfo.radius or 0)
					local showCircle = pg.me:shouldShowPlentyCircle(spawnerId)
					local qualityPage

					if showCircle then
						qualityPage = (flowerInfo.bloomQuality or 0) - 1
					end

					MapUtils.renderLeylineFlowerMark(obj1.gameObject, currentImgPath, showCircle, qualityPage, radius, self.currentZoom)

					cache.resObj = obj1.gameObject

					self:tryPlayLeylineFlowerQualityVx(spawnerId)
					pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "imgPath", currentImgPath)
					pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "locationImgPath", currentImgPath)
				end, false, false, 0)

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.MARK_SHARE then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				imgPath = defaultRes.icon
				locationImgPath = imgPath

				self:_acquireCommonMarkIcon(cache, btnRectTransform, AddressDataConst.UI_MARK_IMG_MARK_SHARE)

				local expireState = pg.game.markShare:getMyExpireInfoById(spawnerId)

				if expireState ~= pg.game.markShare.EXPIRE_STATE.Permanent then
					cache.resTaskIds = cache.resTaskIds or {}
					cache.resObjs = cache.resObjs or {}
					cache.resTaskIds.countdown = self.view:addPrefabWithPathAsync(upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_COUNTDOWN, function(obj1)
						local uComponent = obj1.gameObject:GetComponent("UComponent")

						uComponent:TryChangePage("Time", expireState == pg.game.markShare.EXPIRE_STATE.Expired and 1 or 0)

						obj1.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.MARK_SHARE_COUNTDOWN_LOC
						cache.resObjs.countdown = obj1.gameObject
					end, false, false, 0)
				end

				if self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.ECO_TRACE then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				imgPath = defaultRes.icon
				locationImgPath = imgPath

				local radius = ClientActivityUtils.getEcoTraceMarkRadius()
				local r = pg.game.map:calRadius(self.sceneId, radius)

				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_ECO_TRACE, function(obj1)
					local objectReference = obj1.gameObject:GetComponent("ObjectReference")
					local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")
					local bgUImage = objectReference:GetRefValue("bgUImage")

					bgUImage.url = imgPath
					imgGlowUImage.transform.sizeDelta = Vector2(r * 2, r * 2)
					imgGlowUImage.transform.localScale = Vector3(self.currentZoom, self.currentZoom, 1)
					cache.resObj = obj1.gameObject
				end, false, false, 0)

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.GOLD then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				imgPath = defaultRes.icon
				locationImgPath = imgPath
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_GOLD_TRACE, function(obj1)
					local objectReference = obj1.gameObject:GetComponent("ObjectReference")
					local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")
					local bgUImage = objectReference:GetRefValue("bgUImage")

					bgUImage.url = imgPath

					imgGlowUImage.gameObject:SetActiveEx(false)

					cache.resObj = obj1.gameObject
				end, false, true, 0)

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.CUSTOM then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)
				imgPath = string.format("$UI_Icon_Mark0%s.png", spawnerTable.markIconIndex + 1)
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_CUSTOM, function(obj1)
					obj1.gameObject:GetComponent("UButton"):TryChangePage("IconType", spawnerTable.markIconIndex)

					cache.resObj = obj1.gameObject
				end, false, false, 0)
				locationImgPath = imgPath

				if self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.DYNAMIC then
				imgPath, locationImgPath = self.dynamicMarkComponent:renderDynamicMarkIcon(cache, spawnerId, spawnerTable, objInfo)
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.ALLY then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				imgPath = defaultRes.icon
				locationImgPath = imgPath
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_ALLY, function(obj1)
					local uComponent = obj1.gameObject:GetComponent("UComponent")
					local ent = pg.getEntity(spawnerId)

					if ent and ent.uid and pg.me:getCurTeamInfo().sortList then
						local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, ent.uid)

						if contain and NotNil(uComponent) then
							uComponent:TryChangePage("Teammate", idx - 1)
						end
					end

					cache.resObj = obj1.gameObject
				end, false, true, 0)

				if self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.FAST_TARGET then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				imgPath = defaultRes.icon
				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_FAST_TARGET, function(obj1)
					local uComponent = obj1.gameObject:GetComponent("UComponent")
					local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, spawnerTable.creatorUid)

					if contain and NotNil(uComponent) then
						uComponent:TryChangePage("Teammate", idx - 1)
					end

					cache.resObj = obj1.gameObject

					objInfo.gameObject:SetActiveEx(true)
				end, false, true, 0)

				if #self.view.mapLevelBreakdown == 4 then
					if scale == 1 or self.curStage ~= #self.view.scaleBasicTable then
						objInfo.gameObject:SetActiveEx(true)
					end
				elseif scale == 1 then
					objInfo.gameObject:SetActiveEx(true)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.GRAB_EGG then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][self.sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

				imgPath = defaultRes.icon
				locationImgPath = imgPath

				local eggView = GrabEggMapMarkUtils.getEggView(spawnerId)

				cache.resTaskId = self.view:addPrefabWithPathAsync(btnRectTransform, AddressDataConst.UI_MARK_NODE_GRAB_EGG_HUGE_EGG, function(obj1)
					local objectReference = obj1.gameObject:GetComponent("ObjectReference")

					GrabEggMapMarkUtils.applyEggMarkView(objectReference, eggView, imgPath)

					cache.resObj = obj1.gameObject
				end, false, true, 0)

				if self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
				end
			elseif spawnerTable.type == Const.MAP_CONST.TYPE.DUEL then
				recTrans.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

				local markStatus = cache.markStatus

				if markStatus <= Const.MAP_MARK_STATUS_LOCKED then
					imgPath = MapUtils.getMarkDefaultUnKnownResIcon(spawnerTable.markConfigId)
				else
					imgPath = MapUtils.getMarkDefaultResIcon(spawnerTable.markConfigId)
				end

				locationImgPath = imgPath

				self:_acquireCommonMarkIcon(cache, btnRectTransform, imgPath)

				if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, cache.markStatus) and self:shouldShowMarkOnLoad(scale, spawnerId) then
					objInfo.gameObject:SetActiveEx(true)
					self:checkMarkDisplay(root, spawnerTable.refreshLogicTimes)
				end
			end

			if self.tempFilter and self.tempFilter.configIds and #self.tempFilter.configIds > 0 then
				if LuaUIUtils.tableContains(self.tempFilter.configIds, cache.markConfigId) or pg.game.map:isSpawnerTracked(spawnerId) then
					root:TryChangePage("MapFilterHide", 0)
				else
					root:TryChangePage("MapFilterHide", 1)
				end
			else
				root:TryChangePage("MapFilterHide", not pg.game.map:isEnabledByFilter(self.sceneId, cache.markConfigId, cache.markStatus, cache.spawnerId, {
					finishStateAlwaysShow = cache.finishStateAlwaysShow
				}) and 1 or 0)

				root.renderOpacity = pg.game.map:isEnabledByTotalFilter(self.sceneId, cache.markConfigId) and 1 or 0
			end
		end

		pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "imgPath", imgPath)
		pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "locationImgPath", locationImgPath)
		pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "isUnKnownImg", isUnKnownImg)
		pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "inAreaRange", cache.inAreaRange)

		root.enableVirtualMouseHoverFunc = true

		function root.luaClick()
			self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)

			local player = pg.me

			if not player:checkTeleport() then
				return
			end

			local boundEntityId = pg.game.map.bindMap and pg.game.map.bindMap[spawnerId]

			if boundEntityId and ToBool(player.controlEggId) and player.controlEggId == boundEntityId then
				return
			end

			self.stackIcons = self:checkIfIconStack(root)

			if #self.stackIcons > 1 and self.manualClick == true then
				self:openLocationPanel(false)

				if self.mapPetAreaComponent then
					self.mapPetAreaComponent:closePanel()
				end

				self.chooseListClick = false

				self.view.chooseList.gameObject:SetActiveEx(true)
				self:onChooseListSetActive(true)

				function self.view.chooseList.luaFinishRender(_)
					local btns = self.view.chooseList:GetAllButtons()

					btns[0].isSelected = true
				end

				self.view.chooseList:SetList(self.stackIcons)

				if self.mapMarkFilterComponent.panelOpened then
					self.mapMarkFilterComponent:closePanel()
				end

				self:centralizeMark(self.stackIcons[1].button.name)

				if not self.enableMultiDeleteMode then
					self:selectMark(nil)
					self:renderMultiIconSelectBox(true, self.stackIcons)
				end
			else
				if self.enableMultiDeleteMode then
					self:addToCustomMarkMultiDeleteGroup(root, spawnerId)
					self:centralizeMark(objInfo.gameObject.name)
					self:selectMark(objInfo.gameObject.name)
					self.view.chooseList.gameObject:SetActiveEx(false)
					self:onChooseListSetActive(false)

					self.manualClick = true

					self:renderMultiIconSelectBox(false)

					return
				end

				if spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					self:openLocationPanel(true)
					self:setLocationInfo(root, spawnerId, spawnerTable, spawnerTable.infoTitle, AddressDataConst.UI_MAP_RAINBOW_PET_PREVIEW, spawnerTable.infoText, false)
				elseif spawnerTable.markType == Const.MAP_MARK_QUEST then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					self:openLocationPanel(true)

					local title = spawnerTable.questMarkInfo.chapter and string.format("%s", spawnerTable.questMarkInfo.title) or spawnerTable.questMarkInfo.title
					local infoImage = spawnerTable.questMarkInfo.image
					local infoText = spawnerTable.questMarkInfo.chapter and string.format("%s\n%s", spawnerTable.questMarkInfo.desc, spawnerTable.questMarkInfo.subDesc) or spawnerTable.questMarkInfo.desc

					self:setLocationInfo(root, spawnerId, spawnerTable, title, infoImage, infoText, false, spawnerTable.questMarkInfo.rewardTable)
				elseif spawnerTable.markType == Const.MAP_MARK_CLUE then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					if cache.markStatus == Const.MAP_MARK_STATUS_HIDE or cache.markStatus == Const.MAP_MARK_STATUS_LOCKED then
						return
					end

					self:openLocationPanel(true)

					local title = spawnerTable.questMarkInfo.title
					local infoImage = spawnerTable.infoImageNot
					local infoText = string.format("%s\n%s", spawnerTable.questMarkInfo.desc, spawnerTable.questMarkInfo.subDesc)

					self:setLocationInfo(root, spawnerId, spawnerTable, title, infoImage, infoText, false, spawnerTable.questMarkInfo.rewardTable)
				elseif spawnerTable.markType == Const.MAP_MARK_CUSTOM then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					local data = self:getMarkInfo(spawnerId)

					self:openLocationPanel(true)
					self:setPinInfo(root, spawnerId, data.markIconIndex, objInfo, mapX, mapY, data)
				elseif spawnerTable.infoPage == 2 or DefaultMapMarkData[spawnerTable.markConfigId].infoPage == 2 then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					self:openLocationPanel(true)
					self:setLocationInfo(root, spawnerId, spawnerTable, spawnerTable.infoTitle, spawnerTable.infoImage, spawnerTable.infoText, cache.markStatus ~= Const.MAP_MARK_STATUS_HIDE and cache.markStatus ~= Const.MAP_MARK_STATUS_LOCKED)
				elseif DefaultMapMarkData[spawnerTable.markConfigId].infoPage == 1 then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					self:openLocationPanel(true)
					self:setLocationInfo(root, spawnerId, spawnerTable, spawnerTable.infoTitle, spawnerTable.infoImage, spawnerTable.infoText, false)
				elseif DefaultMapMarkData[spawnerTable.markConfigId].infoPage == 3 then
					if self.view.locationInfo.gameObject.activeSelf then
						self.chooseListClick = false
					end

					self:openLocationPanel(true)
					self:setLocationInfo(root, spawnerId, spawnerTable, spawnerTable.infoTitle, spawnerTable.infoImage, spawnerTable.infoText, false)
				else
					self:openLocationPanel(false)

					if self.mapPetAreaComponent then
						self.mapPetAreaComponent:closePanel()
					end

					self.chooseListClick = false
				end

				if spawnerTable.belongAreaId and MapLayerLevelData[self.sceneId] and MapLayerLevelData[self.sceneId][spawnerTable.belongAreaId] then
					local layerLevel = MapLayerLevelData[self.sceneId][spawnerTable.belongAreaId]

					self.layerComponent:internalSetListData(self.sceneId, layerLevel.layerId, layerLevel.layerLevel, true)
				else
					self.layerComponent:internalSetListData(self.sceneId, 0, 0, nil, true)
				end

				self:centralizeMark(objInfo.gameObject.name)

				if spawnerTable.markType == Const.MAP_MARK_FAST_TARGET then
					if spawnerTable.creatorUid and spawnerTable.creatorUid ~= pg.me.uid then
						self:trackMark(spawnerId, spawnerTable)
					end
				else
					self:selectMark(objInfo.gameObject.name)
				end

				self.view.chooseList.gameObject:SetActiveEx(false)
				self:onChooseListSetActive(false)

				self.manualClick = true

				self:renderMultiIconSelectBox(false)
			end
		end

		self.markCaches[spawnerId] = cache

		if trackMarkExists then
			self:swapMarkLayer(spawnerId, 99, nil)
		end

		if self.guideFocusFlag and self.guideFocusFlag[1] == objInfo.gameObject.name then
			local stage = self.guideFocusFlag[2]

			if not stage or stage == 0 then
				stage = self:_getMarkDisplayStage(spawnerId)
			end

			if stage then
				if stage == 0 then
					local markInfo = self:getMarkInfo(spawnerId)

					if markInfo then
						for i = 1, 4 do
							if markInfo["scale" .. i] == 1 then
								stage = i

								break
							end
						end
					end
				end

				self:scaleMap((#self.view.scales - stage) * self.view.stepSize)
			end

			if #self.view.mapLevelBreakdown == 4 and self.curStage == #self.view.scaleBasicTable then
				self:scaleMap(self.scaleValue + self.view.stepSize)
			end

			local flag4 = self.guideFocusFlag[4]

			if self.guideFocusFlag[3] then
				self:centralizeMark(self.guideFocusFlag[1], false, function()
					self.manualClick = false

					if NotNil(cache.button) then
						cache.button:OnClickSimulate()
					end

					if flag4 then
						flag4()
					end
				end)
			else
				self:centralizeMark(self.guideFocusFlag[1], nil, function()
					if flag4 then
						flag4()
					end
				end)
			end

			self.guideFocusFlag = nil
		end

		if pg.game.navEffect.recordPath and pg.game.navEffect.recordPath.sceneId == self.sceneId and pg.game.navEffect.recordPath.overrideStartPosInfo and spawnerId == pg.game.navEffect.recordPath.overrideStartPosInfo.startSpawnerId then
			self:drawNavEffLine(pg.game.navEffect.recordPath, objInfo.gameObject)
		end

		if self.onMarkLoaded then
			self.onMarkLoaded(spawnerId, spawnerTable, cache)
		end

		for order, func in pairs(self.onMarkLoadedManualCallback) do
			func(spawnerId, spawnerTable)
		end

		if self.diffSceneTrackDelayFlag == spawnerId then
			self.markCaches[spawnerId].button:OnClickSimulate()
			self.mapNavLineComponent:delayLoadDependencyBtn(cache.button)

			self.diffSceneTrackDelayFlag = nil

			if self.diffSceneTrackIsSwitchingMap then
				self:centralizeMark(cache.markName)

				self.diffSceneTrackIsSwitchingMap = nil
			end
		end

		if self.differentSceneTrackMark == spawnerId then
			self:diffSceneTrack(spawnerId, spawnerTable, true)
		end

		if spawnerTable.type == Const.MAP_CONST.TYPE.FAST_TARGET and spawnerTable.creatorUid and spawnerTable.creatorUid == pg.me.uid then
			self:trackMark(spawnerId, spawnerTable)
		elseif pg.game.map:isMarkTeamTrack(self.sceneId, spawnerId, false) then
			self:trackMark(spawnerId, spawnerTable)
		end
	end
end
