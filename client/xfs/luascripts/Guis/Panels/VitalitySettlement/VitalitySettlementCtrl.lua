-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalitySettlement\\VitalitySettlementCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TimerManager = require("Core.Timer.TimerManager")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local VitalitySettlementCtrl = Class.LightClass("VitalitySettlementCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local AudioConst = require("Const.AudioConst")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local UIObjectPool = require("Utils.UIObjectPool")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local ItemData = require("Data.item_data")
local EventVitalityPetAnimationData = require("Data.event_vitality_pet_animation_data")
local EnergyAccessoriesRankData = require("Data.energy_accessories_rank_data")

VitalitySettlementCtrl.BonusType = {
	Personality = "personality",
	Position = "position",
	Evolution = "evolution",
	Attribute = "attribute",
	Ability = "ability",
	Form = "form"
}
VitalitySettlementCtrl.BonusTypeOrder = {
	"Ability",
	"Attribute",
	"Position",
	"Form",
	"Personality",
	"Evolution"
}
VitalitySettlementCtrl.ShowStage = {
	Accessory = 3,
	Multiplier = 2,
	Base = 1
}
VitalitySettlementCtrl.ScoreNodeInterval = 0.5
VitalitySettlementCtrl.MultiplierScoreNodeInterval = 0.5
VitalitySettlementCtrl.RandomScoreNodeIntervals = {
	0.4,
	0.5,
	0.6
}
VitalitySettlementCtrl.AccessoryScoreNodeIntervals = {
	0.2,
	0.3,
	0.4
}
VitalitySettlementCtrl.StageStayDuration = 0.5
VitalitySettlementCtrl.StageStayDurations = {
	[VitalitySettlementCtrl.ShowStage.Base] = 1.5,
	[VitalitySettlementCtrl.ShowStage.Multiplier] = 1.5
}
VitalitySettlementCtrl.FinalStageStayDuration = 2
VitalitySettlementCtrl.TextPoolType = {
	Normal = 1,
	Points = 2
}

function VitalitySettlementCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isDestroyed = false
	self.petScoreData = info.petScoreData or {}
	self.accessoryScoreData = info.accessoryScoreData or {
		tagCount = 0,
		tagScore = 0,
		fashion = 0,
		totalScore = 0,
		tagScores = {},
		accessoryScores = {}
	}
	self.petScore = self.petScoreData.totalScore or 0
	self.accessoryScore = self.accessoryScoreData.totalScore or 0

	local sumScore = self.petScore + self.accessoryScore
	local phase, day = ActivityUtils.getNewEnergyTheme(pg.me)
	local themeId = ActivityUtils.getEnergyThemeId(pg.me)
	local themeData = EnergyMatchThemeData[phase] and EnergyMatchThemeData[phase][themeId] or {}

	self.themeId = themeId
	self.progressTime = 2
	self.entityId = info.entityId
	self.scoreNodeInterval = self.ScoreNodeInterval
	self.multiplierScoreNodeInterval = self.MultiplierScoreNodeInterval
	self.stageStayDuration = self.StageStayDuration
	self.stageStayDurations = self.StageStayDurations
	self.finalStageStayDuration = self.FinalStageStayDuration
	self.tweenTime = self.scoreNodeInterval
	self.petId = info.petId
	self.tryAccessData = info.tryAccessData or {}
	self.sumScore = sumScore
	self.scoreListData = self.model:getScoreListData()

	local maxScoreData = self.scoreListData[#self.scoreListData]

	self.maxScore = maxScoreData and maxScoreData.score or 1
	self.displayMaxScore = themeData.displayScore
	self.view.progressUProgress.minValue = 0
	self.view.progressUProgress.maxValue = self.displayMaxScore
	self.view.progressUProgress.value = 0

	ClientTextUtils.setText(self.view.petScoreText, tostring(self.petScore))
	ClientTextUtils.setText(self.view.accessoryScoreText, tostring(self.accessoryScore))
	ClientTextUtils.setText(self.view.sumScoreText, tostring(sumScore))
	self.view.animationUWidget.gameObject:SetActiveEx(true)
	self.view.settlementUWidget.gameObject:SetActiveEx(false)

	if self.view.vXEventSettlementAnimation then
		self.view.vXEventSettlementAnimation.playAutomatically = false
	end

	ClientTextUtils.setText(self.view.stageScoreUBaseText, 0)

	self.scoreListButtons = {}

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderScoreListItem(button, index, data)
	end

	self.view.listUList:SetList(self.scoreListData)

	self.chatMessagePools = {
		[self.TextPoolType.Normal] = UIObjectPool.new(AddressDataConst.UI_ACTIVITY_VITALITY_HUD_TEXT, self.view.animationRectTransform, 3, 1, 1, 1),
		[self.TextPoolType.Points] = UIObjectPool.new(AddressDataConst.UI_ACTIVITY_VITALITY_POINTS_TEXT, self.view.animationRectTransform, 3, 1, 1, 1)
	}

	ClientTextUtils.setText(self.view.stageTextUBaseText, pg.getGameString("VITALITY_SHOW_PET"))

	self.showStageData = self:getScoreShowStageData(themeData)
	self.curProcess = 0
	self.scoreIndex = 1
	self.stageScore = 0
	self.scoreTextIndex = 0
	self.scoreTextPoolId = 0
	self.perfectReached = false
	self.lastBgm = "BGM_Vitality_Show_Normal"

	if sumScore >= self.maxScore then
		self.lastBgm = "BGM_Vitality_Show_Great"
	end

	pg.game.audio:playBgm(self.lastBgm, AudioConst.BgmPriority.Vitality_UI)

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.VITALITY_SCENE)
	self.avatarScene.disableBackground = true

	local aniTime = self:getShowTotalTime()

	self.showStarted = false

	self:showPetModel(pg.me.energyMatchPetId, function()
		self:startShowAfterModelReady(aniTime)
	end)
	self.adapter:blackFadeOut(0.3)
end

function VitalitySettlementCtrl:startShowAfterModelReady(aniTime)
	if self.showStarted then
		return
	end

	self.showStarted = true

	self:wearTryAccess()
	self:playPetShowAnimation(aniTime)
	self:startShowStages()
end

function VitalitySettlementCtrl:wearTryAccess()
	local curEnt = self.avatarScene:getCurEntity()

	if not curEnt then
		return
	end

	local modelView = curEnt.eModel.modelView
	local modelInfo = modelView.modelInfo

	for _, data in pairs(self.tryAccessData) do
		local attachInfo = self.model:parseDefaultAccessInfo(self.entityId, data.accessoryId, self.modelSliderInfo)

		attachInfo.instanceId = data.instanceId

		local scale = Vector3.New(attachInfo.scale, attachInfo.scale, attachInfo.scale)

		modelInfo:AddAttachInfo(attachInfo.resId, attachInfo.instanceId, attachInfo.attachHp, attachInfo.localPosition, attachInfo.localRotation, scale, false)
		modelView:RefreshModels()
	end
end

function VitalitySettlementCtrl:showPetModel(showPetId, loadedCallback)
	if not string.isNilOrEmpty(self.curPetId) then
		local pInfo = pg.me:getPetInfo(self.curPetId)

		self.avatarScene:destroyPet(pInfo.templateId)
	end

	if string.isNilOrEmpty(showPetId) then
		return
	end

	self.curPetId = showPetId

	self.model:clearCacheData()

	local baseInfo = self.model:setPetProId(showPetId)

	if baseInfo == nil then
		return
	end

	local pInfo = pg.me:getPetInfo(showPetId)
	local petHeight = pInfo.height or 1

	self.adjustHeight = petHeight * 1.2
	self.modelSliderInfo = AvatarUtils.generatePetJewelrySlider(petHeight, baseInfo.scale, 1.5, pInfo.sizeLevel)

	self.avatarScene:showPetTemplate(pInfo, baseInfo.scale, baseInfo.offset, loadedCallback)
end

function VitalitySettlementCtrl:playPetShowAnimation(aniTime)
	local overrideAnimation = EventVitalityPetAnimationData[self.entityId]

	if overrideAnimation then
		self.avatarScene:playCfgAnimation(self.entityId, {
			overrideAnimation.showStart,
			overrideAnimation.showAction,
			overrideAnimation.showEnd,
			{
				false,
				aniTime
			}
		})
	else
		self.avatarScene:playCfgAnimation(self.entityId, {
			"Behav_HappyStart",
			"Behav_HappyLoop",
			"Behav_HappyEnd",
			{
				false,
				aniTime
			}
		})
	end
end

function VitalitySettlementCtrl:showText(name, score, poolType, lightIndex, arrowPage, colorPage, scoreText)
	if self.isDestroyed or not self.chatMessagePools then
		return
	end

	score = score or 0

	local chatMessagePool = self.chatMessagePools[poolType or self.TextPoolType.Normal] or self.chatMessagePools[self.TextPoolType.Normal]

	if not chatMessagePool then
		return
	end

	self.scoreTextPoolId = (self.scoreTextPoolId or 0) + 1

	local poolId = self.scoreTextPoolId

	chatMessagePool:createFromPool(nil, poolId, function(objInfo)
		if self.isDestroyed then
			chatMessagePool:recycleToPool(poolId)

			return
		end

		self.scoreTextIndex = (self.scoreTextIndex or 0) + 1

		local isLeft = self.scoreTextIndex % 2 == 1
		local posX = isLeft and math.random(-1000, -500) or math.random(500, 1000)
		local posY = math.random(-1000, 1000)
		local scale = math.random(90, 110) / 100

		objInfo.gameObject.transform.localPosition = Vector3(posX, posY, 0)
		objInfo.gameObject.transform.localScale = Vector3(scale, scale, scale)

		local objectReference = objInfo.gameObject:GetComponent("ObjectReference")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")
		local numText = objectReference:GetRefValue("textUBaseText")
		local nameText = objectReference:GetRefValue("textNameUSDFText")

		ClientTextUtils.setText(numText, scoreText or "+" .. score)
		ClientTextUtils.setText(nameText, name or "")

		if rootUComponent then
			if arrowPage ~= nil then
				rootUComponent:TryChangePage("Arrow", arrowPage)
			end

			if colorPage ~= nil then
				rootUComponent:TryChangePage("Color", colorPage)
			end
		end

		self:playScoreTextAnimation(rootUComponent, poolType, lightIndex, chatMessagePool, poolId)

		self.curProcess = self.curProcess + score

		ClientTextUtils.setText(self.view.stageScoreUBaseText, self.curProcess)
		ClientTextUtils.setText(self.view.processScore, string.format("%s: %s", pg.getGameString("VITALITY_GET_SCORE"), self.curProcess))
		pg.game.audio:triggerEvent("SFX_UI_Vitality_Score_Up")
		self:refreshProgress()
		self:triggerStageLight(lightIndex)

		if self.curProcess >= self.maxScore then
			self:triggerPerfectLight()
		end
	end)
end

function VitalitySettlementCtrl:getScoreTextInvokeTime(poolType, stage)
	if poolType == self.TextPoolType.Points then
		return CS.XGUI.EInvokeTime.Custom1
	end

	if stage == self.ShowStage.Accessory then
		return CS.XGUI.EInvokeTime.Custom2
	end

	return CS.XGUI.EInvokeTime.Custom1
end

function VitalitySettlementCtrl:playScoreTextAnimation(rootUComponent, poolType, stage, chatMessagePool, poolId)
	local function recycle()
		if chatMessagePool then
			chatMessagePool:recycleToPool(poolId)
		end
	end

	if not rootUComponent then
		recycle()

		return
	end

	local invokeTime = self:getScoreTextInvokeTime(poolType, stage)

	if rootUComponent:CheckHasEvent(invokeTime) then
		rootUComponent:InvokeCallbackWithCallback(invokeTime, recycle)
	else
		recycle()
	end
end

function VitalitySettlementCtrl:refreshProgress()
	local maxScore = math.max(self.displayMaxScore or 1, 1)
	local progressValue = math.min(self.curProcess, maxScore)

	self.view.progressUProgress:ProgressToValue(progressValue, nil)

	while self.scoreIndex <= #self.scoreListData and self.curProcess >= (self.scoreListData[self.scoreIndex].score or 0) do
		local scoreData = self.scoreListData[self.scoreIndex]

		if not scoreData.showVX then
			scoreData.showVX = true

			self:refreshScoreListItemState(self.scoreIndex, true)
			pg.game.audio:triggerEvent("SFX_UI_Vitality_Score_Light")
		end

		self.scoreIndex = self.scoreIndex + 1
	end
end

function VitalitySettlementCtrl:renderScoreListItem(button, index, data)
	if not button or not data then
		return
	end

	self.scoreListButtons[index] = button

	local objectReference = button:GetComponent("ObjectReference")
	local rootAnimation = objectReference:GetRefValue("rootAnimation")
	local textNumberUBaseText = objectReference:GetRefValue("textNumberUBaseText")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local scoreIndex = data.index or index or 1
	local colorIndex = math.max(scoreIndex - 1, 0)

	button:TryChangePage("State", data.showVX and 1 or 0)
	button:TryChangePage("Color", colorIndex)
	ClientTextUtils.setText(textNumberUBaseText, data.score)

	local strName = "VITALITY_SCORE_" .. scoreIndex

	ClientTextUtils.setText(textUBaseText, pg.getGameString(strName))

	if data.showVX then
		rootAnimation:Play("VX_Node_Event_Review_Reached")
	end
end

function VitalitySettlementCtrl:refreshScoreListItemState(index, reached)
	local ok, button = self.view.listUList:TryGetChildAt(index - 1)

	if not ok or not button then
		button = self.scoreListButtons and self.scoreListButtons[index]
		ok = button ~= nil
	end

	if not ok or not button then
		return
	end

	button:TryChangePage("State", reached and 1 or 0)

	if reached then
		local objectReference = button:GetComponent("ObjectReference")
		local rootAnimation = objectReference:GetRefValue("rootAnimation")

		rootAnimation:Play("VX_Node_Event_Review_Reached")
	end
end

function VitalitySettlementCtrl:triggerStageLight(lightIndex)
	if not lightIndex then
		return
	end

	local lightIndexes = {
		lightIndex
	}

	if lightIndex == self.ShowStage.Base or lightIndex == self.ShowStage.Multiplier then
		lightIndexes = {
			self.ShowStage.Base,
			self.ShowStage.Multiplier
		}
	end

	if lightIndex == self.ShowStage.Base then
		self:startTimer(CallbackHandler(self, "triggerStageLightInternal", lightIndexes), 0.5, false)

		return
	end

	self:triggerStageLightInternal(lightIndexes)
end

function VitalitySettlementCtrl:triggerStageLightInternal(lightIndexes)
	self:setStageLights(lightIndexes)
	TimerManager.addNextFrameCb(CallbackHandler(self, "setStageLights", lightIndexes))
end

function VitalitySettlementCtrl:setStageLights(lightIndexes)
	if not self.avatarScene then
		return
	end

	for _, index in ipairs(lightIndexes or EMPTY_TABLE) do
		self.avatarScene:setStageLight(index)
	end
end

function VitalitySettlementCtrl:triggerPerfectLight()
	if self.perfectReached then
		return
	end

	self.perfectReached = true

	self.avatarScene:setStageLight(4)

	if self.view.vXEventSettlementAnimation then
		self.view.vXEventSettlementAnimation:Play()
	end

	pg.game.audio:triggerEvent("SFX_UI_Vitality_Score_Streamer")
end

function VitalitySettlementCtrl:startShowStages()
	self:playShowStage(1)
end

function VitalitySettlementCtrl:playShowStage(stageIndex)
	local stageData = self.showStageData[stageIndex]

	if not stageData then
		self:finishShowStages()

		return
	end

	local items = stageData.items or {}

	if #items <= 0 then
		self:playShowStage(stageIndex + 1)

		return
	end

	ClientTextUtils.setText(self.view.stageTextUBaseText, stageData.title)
	ClientTextUtils.setText(self.view.stageScoreUBaseText, self.curProcess)
	self:triggerStageLight(stageData.lightIndex)
	self:playScoreNode(stageIndex, 1)
end

function VitalitySettlementCtrl:playScoreNode(stageIndex, itemIndex)
	local stageData = self.showStageData[stageIndex]
	local items = stageData and stageData.items or {}
	local item = items[itemIndex]

	if not item then
		local stayDuration = self:getStageStayDuration(stageData)

		self.timerId = self:startTimer(function()
			self.timerId = nil

			self:playShowStage(stageIndex + 1)
		end, stayDuration, false)

		return
	end

	self:showText(item.name, item.score, item.poolType, item.lightIndex, item.arrowPage, item.colorPage, item.scoreText)

	local interval = self:getScoreNodeInterval(stageData)

	self.timerId = self:startTimer(function()
		self.timerId = nil

		self:playScoreNode(stageIndex, itemIndex + 1)
	end, interval, false)
end

function VitalitySettlementCtrl:finishShowStages()
	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	self.view.btnSkipUButton:OnClickSimulate()
end

function VitalitySettlementCtrl:getShowTotalTime()
	local totalTime = 0

	for _, stageData in ipairs(self.showStageData or EMPTY_TABLE) do
		local itemCount = #(stageData.items or {})

		if itemCount > 0 then
			totalTime = totalTime + itemCount * self:getAverageScoreNodeInterval(stageData) + self:getStageStayDuration(stageData)
		end
	end

	return math.max(totalTime, self.scoreNodeInterval)
end

function VitalitySettlementCtrl:getStageStayDuration(stageData)
	if stageData and stageData.stage == self.ShowStage.Accessory then
		return self.finalStageStayDuration
	end

	local stageStayDuration = stageData and self.stageStayDurations and self.stageStayDurations[stageData.stage]

	if stageStayDuration then
		return stageStayDuration
	end

	return self.stageStayDuration
end

function VitalitySettlementCtrl:getScoreNodeInterval(stageData)
	if stageData and stageData.stage == self.ShowStage.Multiplier then
		return self.multiplierScoreNodeInterval
	end

	if stageData and stageData.stage == self.ShowStage.Accessory then
		local intervals = self.AccessoryScoreNodeIntervals

		if not intervals or #intervals <= 0 then
			return self.scoreNodeInterval
		end

		return intervals[math.random(1, #intervals)] or self.scoreNodeInterval
	end

	local intervals = self.RandomScoreNodeIntervals

	if not intervals or #intervals <= 0 then
		return self.scoreNodeInterval
	end

	return intervals[math.random(1, #intervals)] or self.scoreNodeInterval
end

function VitalitySettlementCtrl:getAverageScoreNodeInterval(stageData)
	if stageData and stageData.stage == self.ShowStage.Multiplier then
		return self.multiplierScoreNodeInterval
	end

	if stageData and stageData.stage == self.ShowStage.Accessory then
		return 0.3
	end

	return self.scoreNodeInterval
end

function VitalitySettlementCtrl:insertScoreShowItem(items, itemData)
	if (itemData.score or 0) <= 0 then
		return
	end

	table.insert(items, itemData)
end

function VitalitySettlementCtrl:getNewBonusScoreText(themeData)
	return "×" .. tostring(themeData and themeData.newBonus or 1)
end

function VitalitySettlementCtrl:getScoreShowStageData(themeData)
	local stages = {}
	local baseItems = {}
	local baseScore = themeData.baseScore or 0

	for _, bonusTypeKey in ipairs(self.BonusTypeOrder) do
		local v = self.BonusType[bonusTypeKey]
		local score = self.petScoreData[v] or 0
		local name = self.petScoreData[v .. "Name"] or ""

		self:insertScoreShowItem(baseItems, {
			name = name,
			score = score,
			poolType = self.TextPoolType.Normal,
			lightIndex = self.ShowStage.Base,
			arrowPage = baseScore < score and 1 or 0
		})
	end

	table.insert(stages, {
		stage = self.ShowStage.Base,
		title = pg.getGameString("VITALITY_SHOW_PET"),
		lightIndex = self.ShowStage.Base,
		items = baseItems
	})

	local multiplierItems = {}

	self:insertScoreShowItem(multiplierItems, {
		colorPage = 0,
		name = pg.getGameString("VITALITY_PET_SCORE_FORM"),
		score = self.petScoreData.formBonusScore or 0,
		poolType = self.TextPoolType.Points,
		lightIndex = self.ShowStage.Multiplier
	})
	self:insertScoreShowItem(multiplierItems, {
		colorPage = 1,
		name = self.petScoreData.newStarName or pg.getGameString("GLAMOUR_EVENT_NEW_TITLE"),
		score = self.petScoreData.newStarScore or 0,
		scoreText = self:getNewBonusScoreText(themeData),
		poolType = self.TextPoolType.Points,
		lightIndex = self.ShowStage.Multiplier
	})
	table.insert(stages, {
		stage = self.ShowStage.Multiplier,
		title = pg.getGameString("VITALITY_SHOW_PET"),
		lightIndex = self.ShowStage.Multiplier,
		items = multiplierItems
	})

	local accessoryItems = self:getAccessoryShowItems()

	for _, item in ipairs(accessoryItems) do
		item.lightIndex = self.ShowStage.Accessory
	end

	table.insert(stages, {
		stage = self.ShowStage.Accessory,
		title = pg.getGameString("VITALITY_SHOW_ACCESSORY"),
		lightIndex = self.ShowStage.Accessory,
		items = accessoryItems
	})

	return stages
end

function VitalitySettlementCtrl:getAccessoryShowItems()
	local accessoryItems = {}
	local accessoryScores = self.accessoryScoreData.accessoryScores or {}

	for _, data in ipairs(accessoryScores) do
		local score = data.totalScore or 0

		if score > 0 then
			local itemData = ItemData[data.accessoryId]

			table.insert(accessoryItems, {
				arrowPage = 0,
				name = itemData and pg.getLocalizationText(itemData.itemName) or "",
				score = score,
				poolType = self.TextPoolType.Normal
			})
		end
	end

	if #accessoryItems > 0 then
		return accessoryItems
	end

	if (self.accessoryScoreData.fashion or 0) > 0 then
		table.insert(accessoryItems, {
			arrowPage = 0,
			name = pg.getGameString("VITALITY_ACCESSORY_SCORE"),
			score = self.accessoryScoreData.fashion,
			poolType = self.TextPoolType.Normal
		})
	end

	for id, score in pairs(self.accessoryScoreData.tagScores or EMPTY_TABLE) do
		if score > 0 then
			local itemData = ItemData[id]

			table.insert(accessoryItems, {
				arrowPage = 0,
				name = itemData and pg.getLocalizationText(itemData.itemName) or "",
				score = score,
				poolType = self.TextPoolType.Normal
			})
		end
	end

	return accessoryItems
end

function VitalitySettlementCtrl:getRankPermille(score)
	score = tonumber(score) or 0

	local minScore
	local minRank = 0
	local maxScore
	local maxRank = 0

	for _, data in pairs(EnergyAccessoriesRankData or EMPTY_TABLE) do
		local scoreRange = data.scoreRange or {}
		local rankRange = data.rankRange or {}
		local scoreMin = tonumber(scoreRange[1])
		local scoreMax = tonumber(scoreRange[2])
		local rankMin = tonumber(rankRange[1])
		local rankMax = tonumber(rankRange[2])

		if scoreMin and scoreMax and rankMin and rankMax then
			if not minScore or scoreMin < minScore then
				minScore = scoreMin
				minRank = rankMin
			end

			if not maxScore or maxScore < scoreMax then
				maxScore = scoreMax
				maxRank = rankMax
			end

			if scoreMin < score and score <= scoreMax then
				if scoreMax == scoreMin then
					return rankMax
				end

				return rankMin + (rankMax - rankMin) * (score - scoreMin) / (scoreMax - scoreMin)
			end
		end
	end

	if maxScore and maxScore < score then
		return maxRank
	end

	return minRank
end

function VitalitySettlementCtrl:getRankText(score)
	local rankPercentText = string.format("%.1f", self:getRankPermille(score) / 10)
	local rankFormat = pg.getGameString("GLAMOUR_EVENT_SCORE_RANK")

	if rankFormat and rankFormat ~= "" and rankFormat ~= "GLAMOUR_EVENT_SCORE_RANK" and string.find(rankFormat, "{0}", 1, true) then
		local hasPercentSymbol = string.find(rankFormat, "%%") or string.find(rankFormat, "％")

		return pg.getFormatText(rankFormat, hasPercentSymbol and rankPercentText or rankPercentText .. "%")
	end

	return rankPercentText .. "%"
end

function VitalitySettlementCtrl:refreshRankText()
	if not self.view.txtRank then
		return
	end

	ClientTextUtils.setText(self.view.txtRank, self:getRankText(self.sumScore))
end

function VitalitySettlementCtrl:addListener()
	function self.view.btnSettlementUButton.luaClick()
		pg.global.ui:closeAllNormalPanel({
			[UIConst.UI_ID_EVENT] = true
		})
		facade:sendMsgToUI(MessageName.EVENT_GET_VITALITY_REWARD)
	end

	function self.view.btnInfoUButton.luaRenderTooltip(btn, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local tipText = pg.getGameString("VITALITY_SCORE_TOTAL")

		ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(tipText, self.petScore, self.accessoryScore, self.sumScore))
	end

	function self.view.btnSkipUButton.luaClick()
		if self.timerId then
			self:killTimer(self.timerId)

			self.timerId = nil
		end

		self.curProcess = self.sumScore

		ClientTextUtils.setText(self.view.processScore, string.format("%s: %s", pg.getGameString("VITALITY_GET_SCORE"), self.curProcess))
		self:refreshProgress()

		if self.curProcess >= self.maxScore then
			self:triggerPerfectLight()
		end

		local ratingIndex = 0

		for scoreIndex, scoreData in ipairs(self.scoreListData) do
			if self.sumScore >= scoreData.score then
				ratingIndex = scoreIndex
			end
		end

		ratingIndex = ratingIndex - 1

		if ratingIndex < 0 then
			ratingIndex = 0
		end

		self:refreshRankText()
		self.view.settlementUWidget:TryChangePage("Rating", ratingIndex)
		self.view.animationUWidget.gameObject:SetActiveEx(false)
		self.view.settlementUWidget.gameObject:SetActiveEx(true)
		self.avatarScene:playShowAnimation(self.entityId, "Idle")
		pg.game.audio:stopBgm(AudioConst.BgmPriority.Vitality_UI)
		pg.game.audio:triggerEvent("SFX_UI_Vitality_Score_Total")
	end

	function self.view.btnPhotoUButton.luaClick()
		self.view.btnPhotoUButton.gameObject:SetActiveEx(false)
		self.view.btnSettlementUButton.gameObject:SetActiveEx(false)

		self.view.settlementUWidget:GetComponent("Animation").playAutomatically = false
		self.view.vXEventSettlementAnimation.playAutomatically = false

		Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, imgUrl, success)
			self.view.btnPhotoUButton.gameObject:SetActiveEx(true)
			self.view.btnSettlementUButton.gameObject:SetActiveEx(true)

			if not success then
				return
			end

			local playerPos = pg.me:getPositionAgentPosition()
			local photoInfo = pg.global.mobileCameraMgr:GetPetPhotoInfo(os.time(), playerPos, pg.me.space.sceneId, {
				self.entityId
			})
			local info = {}

			info.sprite = sprite
			info.needSave = true
			info.position = photoInfo.pos
			info.sceneId = photoInfo.sceneId
			info.timeStamp = photoInfo.ts

			function info.saveCallback()
				if ClientSettingUtils.isCloudGame() then
					pg.global.mobileCameraMgr:SaveImageToAlbum(photoInfo, function(path)
						if string.isNilOrEmpty(path) then
							pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH_FAILED_DISC_FULL)

							return
						end

						pg.global.ui.tips:showTextTip(ClientSettingUtils.getPhotoSyncingToPhoneText())
					end)
				else
					pg.global.mobileCameraMgr:SaveImageToAlbum(photoInfo)
					pg.global.ui.tips:showTextTip(pg.getGameString("VITALITY_PHOTO_TIP"))
				end
			end

			pg.global.ui.albumPhoto:open({
				photoInfo = info
			})
		end)
	end
end

function VitalitySettlementCtrl:destroyChatMessagePools()
	if not self.chatMessagePools then
		return
	end

	for _, pool in pairs(self.chatMessagePools) do
		pool:destroy()
	end

	self.chatMessagePools = nil
end

function VitalitySettlementCtrl:onDestroy()
	self.isDestroyed = true

	self:destroyChatMessagePools()
	UICtrl.onDestroy(self)
end

function VitalitySettlementCtrl:onShow()
	UICtrl.onShow(self)
end

return VitalitySettlementCtrl
