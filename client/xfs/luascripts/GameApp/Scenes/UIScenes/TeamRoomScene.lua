-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\TeamRoomScene.lua

local ClientUtils = require("Utils.ClientUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local TeamRoomScene = Class.LightClass("TeamRoomScene", UISceneBase)
local TimerManager = require("Core.Timer.TimerManager")
local SimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local lume = require("Core.Common.lume")
local LevelData = require("Data.level_data")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local Time = require("Core.Common.Time")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AppearanceAction = require("Data.appearance_action_data")
local TopLogoItemFocusIndicator = require("Guis.Panels.TopLogo.Node.TopLogoItemFocusIndicator")

TeamRoomScene.PLAYER_POS_ORDER_THREE = {
	1,
	2,
	3
}
TeamRoomScene.PLAYER_POS_ORDER_FOUR = {
	1,
	2,
	3,
	4
}

function TeamRoomScene:onCtor()
	self.dungeonConfig = nil
	self.petModels = {}
	self.petModelsId = {}
	self.playerModels = {}
	self.playerModelUids = {}
	self.focusTopLogo = nil
	self.petPos = {}
	self.playerPosFour = {}
	self.playerPosThree = {}
	self.petPosFour = {}
	self.petPosThree = {}
	self.idleAni = "Idle"
	self.playerAnis = {
		"IdleSpecial",
		"IdleSpecial02",
		{
			"Story_Akimbo02_Start",
			"Story_Akimbo02_Loop",
			"Story_Akimbo02_End"
		},
		"Idle_Sp"
	}
	self.playerReadyEnterAni = {
		"Emotion_Excited_Start",
		"Emotion_Excited_Loop"
	}
	self.playerReadyExitAni = {
		"Emotion_Excited_End"
	}
	self.petAnis = {
		"IdleSpecial",
		"Idle_Sp"
	}
	self.curPlayAniSteps = {}
	self.aniTicks = {}
	self.waitShowEffectIndex = {}
	self.curAvatarCfg = {}
	self.curShow = {}
	self.curPetAppearance = {}
	self.isInited = false
	self.modelsVisible = true
end

function TeamRoomScene:onStart()
	if IsNil(self.scene) or IsNil(self.scene.transform) then
		return
	end

	local globalObj = self.scene.transform:Find("Global")

	if IsNil(globalObj) then
		return
	end

	local objectReference = globalObj:GetComponent("ObjectReference")

	self.camera = objectReference:GetRefValue("camera")
	self.effectRoot = objectReference:GetRefValue("effectRoot")
	self.effectRootReady = objectReference:GetRefValue("effectRootReady")
	self.effectRootNoReady = objectReference:GetRefValue("effectRootNoReady")
	self.entRootTransform = objectReference:GetRefValue("entRootTransform")
	self.playerPosFour, self.petPosFour = self:getTeamRoomModelPosList("FourA", TeamRoomScene.PLAYER_POS_ORDER_FOUR)
	self.playerPosThree, self.petPosThree = self:getTeamRoomModelPosList("ThreeA", TeamRoomScene.PLAYER_POS_ORDER_THREE)
	self.dungeonConfig = LevelData[pg.me:getCurTeamInfo().dungeonSceneId]

	self:setActive(true)
	Vector3.enableCreateFromCache()

	local pos = self.camera.transform.position
	local rot = self.camera.transform.rotation
	local fov = self.camera.fieldOfView

	pg.game.camera:startTeamRoomCameraFix(pos, rot, fov)
	Quaternion.removeTempQuaterion(rot)
	Vector3.disableCreateFromCache(pos)
	self:refreshModels()
	self:refreshReadyEffect()
end

function TeamRoomScene:onActiveChanged(active)
	for index, model in pairs(self.playerModels) do
		model.eModel:SetActive(active)
	end

	for index, model in pairs(self.petModels) do
		model.eModel:SetActive(active)
	end

	if active then
		for index, model in pairs(self.playerModels) do
			if model then
				self:removeDelayAniTick(index)

				if self:isUidPrepare(self.playerDatas[index].uid) then
					self:playAniList(index, model, self.playerReadyEnterAni)
				elseif self:checkCanPlayAni(model, PlayableConst[self.idleAni]) then
					model:playAnimation(self.idleAni, true)
				end
			end
		end

		for index, model in pairs(self.petModels) do
			if model then
				self:removeDelayAniTick(self:getPetAniTickIndex(index))

				if self:checkCanPlayAni(model, PlayableConst[self.idleAni]) then
					model:playAnimation(self.idleAni, true)
				end
			end
		end
	end
end

function TeamRoomScene:checkPlayerAppearanceUpdate(playerData, index)
	if not playerData or playerData.empty then
		return false
	end

	local playerInfo = self:getTeamMembersInfo()[playerData.uid]

	if not playerInfo then
		return false
	end

	return self.curAvatarCfg[index] ~= playerInfo.avatarConfig or self.curShow[index] ~= playerInfo.curShow
end

function TeamRoomScene:checkPetAppearanceUpdate(petData, index)
	if not petData then
		return false
	end

	return self.curPetAppearance[index] ~= petData.petAppearance
end

function TeamRoomScene:getTeamInfo()
	if not pg.me:isInTeam() and self.teamInfo then
		return self.teamInfo
	end

	return pg.me:getShowTeamInfo()
end

function TeamRoomScene:getTeamMembersInfo()
	local teamInfo = self:getTeamInfo()

	return teamInfo and teamInfo.membersInfo or {}
end

function TeamRoomScene:getTeamMemberCount()
	local teamInfo = self:getTeamInfo()

	return teamInfo and teamInfo.sortList and #teamInfo.sortList or 0
end

function TeamRoomScene:isThreePosTeam()
	if not pg.me:isInTeam() then
		return true
	end

	local maxCount = self.dungeonConfig and self.dungeonConfig.playerNumMax or 4

	return maxCount % 2 == 1
end

function TeamRoomScene:getTeamRoomModelPosList(posPrefix, posOrder)
	local playerPosList = {}
	local petPosList = {}

	for index, posIndex in ipairs(posOrder) do
		local playerPos = self.entRootTransform:Find(posPrefix .. posIndex)

		playerPosList[index] = playerPos
		petPosList[index] = self:getPetPosTransform(playerPos, posIndex)
	end

	return playerPosList, petPosList
end

function TeamRoomScene:getPetPosTransform(playerPos, posIndex)
	if IsNil(playerPos) then
		return nil
	end

	local petPos = playerPos:Find("P" .. posIndex)

	if IsNil(petPos) then
		petPos = playerPos:Find(string.format("P%02d", posIndex))
	end

	if IsNil(petPos) then
		petPos = playerPos:Find("P01")
	end

	return IsNil(petPos) and playerPos or petPos
end

function TeamRoomScene:getTeamRoomPlayerOrderData()
	local data = {}
	local maxCount = self:isThreePosTeam() and #self.playerPosThree or #self.playerPosFour

	for i = 1, maxCount do
		data[i] = {
			tIndex = 0,
			empty = true
		}
	end

	local teamInfo = self:getTeamInfo()

	for i, uid in ipairs(teamInfo and teamInfo.sortList or EMPTY_TABLE) do
		if data[i] then
			data[i].empty = false
			data[i].uid = uid
		end
	end

	return data
end

function TeamRoomScene:isUidPrepare(uid)
	local teamInfo = self:getTeamInfo()
	local prepareInfo = teamInfo and teamInfo.prepareInfos and teamInfo.prepareInfos[uid]

	return prepareInfo and prepareInfo.isPrepare or false
end

function TeamRoomScene:getPlayerModelByUid(uid)
	for index, modelUid in pairs(self.playerModelUids or EMPTY_TABLE) do
		if modelUid == uid then
			return self.playerModels[index]
		end
	end

	return nil
end

function TeamRoomScene:refreshPlayerModelTransform(model, parent)
	if not model or not model.eModel or not parent then
		return
	end

	model.eModel:SetTransformParent(parent, false)
	model.eModel:SetTransformLocalPosition()
	model:setScaleNumber(1)
end

function TeamRoomScene:refreshModels()
	if not self.scene then
		return
	end

	local isThreePosTeam = self:isThreePosTeam()
	local isFourTeam = not isThreePosTeam

	self.playerPos = isThreePosTeam and self.playerPosThree or self.playerPosFour
	self.petPos = isThreePosTeam and self.petPosThree or self.petPosFour

	local memberCount = self:getTeamMemberCount()

	self.playerDatas = self:getTeamRoomPlayerOrderData()

	local needPlayHelpLess = false
	local lookAtTargetIndex = -1
	local membersInfo = self:getTeamMembersInfo()

	for index, model in pairs(self.playerModels) do
		if index > #self.playerPos then
			ClientUtils.safeDestroy(model)

			self.playerModels[index] = nil
			self.playerModelUids[index] = nil

			self:removeDelayAniTick(index)
		end
	end

	for index, tran in ipairs(self.playerPos) do
		local playerData = self.playerDatas[index] or {
			empty = true
		}

		if self.playerModels[index] and (playerData.empty or self.playerModelUids[index] ~= playerData.uid) then
			if not membersInfo[self.playerModelUids[index]] then
				needPlayHelpLess = true
			end

			ClientUtils.safeDestroy(self.playerModels[index])

			self.playerModels[index] = nil
			self.playerModelUids[index] = nil

			self:removeDelayAniTick(index)
		end

		if not playerData.empty and not self.playerModels[index] then
			local playerInfo = membersInfo[playerData.uid]

			if playerInfo then
				local newPlayerModel = ClientVirtualEntityUtils.createVirtualPlayer(playerInfo.avatarConfig, playerInfo.curShow, playerInfo.avatarPresetKey)

				self.curAvatarCfg[index] = playerInfo.avatarConfig
				self.curShow[index] = playerInfo.curShow
				self.playerModels[index] = newPlayerModel

				function newPlayerModel.eModel.modelModelView.luaOnModelRefreshFinshed()
					newPlayerModel.eModel.modelModelView:BoneSpringGlobalWindAffected(false)
				end

				self:refreshPlayerModelTransform(newPlayerModel, tran)
				newPlayerModel:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
				newPlayerModel:setRendererLod(0)
				newPlayerModel:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
				self:applyHairLayerCount(newPlayerModel)

				if self:isUidPrepare(playerData.uid) then
					self:onPlayerReady(playerData.uid)
				end

				if self:checkNewEnter(playerData.uid) then
					lookAtTargetIndex = index

					self:playEnterEffect(newPlayerModel, index)
				end

				self.playerModelUids[index] = playerData.uid
			end
		end

		self:refreshPlayerModelTransform(self.playerModels[index], tran)

		if self.playerModels[index] and self:checkPlayerAppearanceUpdate(playerData, index) then
			local playerInfo = membersInfo[playerData.uid]

			if playerInfo then
				ClientVirtualEntityUtils.refreshPlayerEntityAppearance(self.playerModels[index], playerInfo.avatarConfig, playerInfo.curShow, playerInfo.avatarPresetKey)

				self.curAvatarCfg[index] = playerInfo.avatarConfig
				self.curShow[index] = playerInfo.curShow
			end
		end
	end

	if needPlayHelpLess then
		self:playLeaveEffect()
	end

	self:playLookAt(lookAtTargetIndex)

	local petDatas = self:getFirstPetDataList()

	if not petDatas then
		self:clearPetModels()
	else
		for index, tran in ipairs(self.petPos) do
			local petData = petDatas[index]

			if self.petModels[index] and (petData == nil or self.petModelsId[index] ~= petData.templateId or self.petModels[index].shinyStyle ~= petData.shinyStyle) then
				ClientUtils.safeDestroy(self.petModels[index])

				self.petModels[index] = nil
				self.petModelsId[index] = nil

				local aniTickIndex = self:getPetAniTickIndex(index)

				self:removeDelayAniTick(aniTickIndex)
			end

			if self.petModels[index] == nil and petData ~= nil and not petData.empty then
				local newPetModel = ClientVirtualEntityUtils.createPetVirtualEntity(petData.templateId, petData.petAppearance, petData.label, petData.shinyStyle)

				self.curPetAppearance[index] = petData.petAppearance
				self.petModels[index] = newPetModel
				self.petModelsId[index] = petData.templateId

				newPetModel.eModel:SetTransformParent(tran)
				newPetModel.eModel:SetTransformLocalPosition()
				newPetModel:setScaleNumber(self:calPetModelScale(petData.templateId))

				function newPetModel.eModel.modelModelView.luaOnModelRefreshFinshed()
					newPetModel.eModel.modelModelView:BoneSpringGlobalWindAffected(false)
				end

				PetTransmogUtils.applySchemeTransmog(newPetModel, petData.templateId, petData.selectTransmogScheme, true)
				newPetModel:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
				self:applyHairLayerCount(newPetModel)

				if pg.global.ui:checkUIVisible(UIConst.UI_ID_TEAM_ROOM) then
					self:playPetShowEffect(index)
				else
					self.waitShowEffectIndex[index] = true
				end
			end

			if self.petModels[index] and self:checkPetAppearanceUpdate(petData, index) then
				ClientVirtualEntityUtils.refreshPetEntityAppearance(self.petModels[index], petData.petAppearance)

				self.curPetAppearance[index] = petData.petAppearance
			end

			if self.petModels[index] and petData ~= nil and not petData.empty and PetTransmogUtils.applySchemeTransmog(self.petModels[index], petData.templateId, petData.selectTransmogScheme, true) then
				self.petModels[index]:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
			end
		end
	end

	self.isInited = true
end

function TeamRoomScene:playLeaveEffect()
	if self.lastPlayAniTime and Time.realSecondCache - self.lastPlayAniTime < 3 then
		return
	end

	self.lastPlayAniTime = Time.realSecondCache

	local isFourTeam = not self:isThreePosTeam()

	if isFourTeam and self.playerModels[2] then
		self.playerModels[2]:playAnimation(PlayableConst.Emotion_Helpless, true)
		self:removeDelayAniTick(2)
	elseif self.playerModels[1] then
		self.playerModels[1]:playAnimation(PlayableConst.Emotion_Helpless, true)
		self:removeDelayAniTick(1)
	end
end

function TeamRoomScene:checkNewEnter(uid)
	if not self.isInited then
		return false
	end

	local exist = false

	for _, value in pairs(self.playerModelUids) do
		if value == uid then
			exist = true

			break
		end
	end

	return not exist
end

function TeamRoomScene:playLookAt(lookAtTargetIndex)
	if lookAtTargetIndex > 0 then
		if self.lookAtTimer then
			TimerManager.removeTimer(self.lookAtTimer)

			self.lookAtTimer = nil
		end

		for key, model in pairs(self.playerModels) do
			if key ~= lookAtTargetIndex and self.playerModels[lookAtTargetIndex] then
				model:lookAtRole(self.playerModels[lookAtTargetIndex])
			end
		end

		self.lookAtTimer = TimerManager.addTimer(4, function()
			self.lookAtTimer = nil

			for key, model in pairs(self.playerModels) do
				if key ~= lookAtTargetIndex then
					model:cancelLookAtRole(0.5)
				end
			end
		end)
	end
end

function TeamRoomScene:playEnterEffect(newPlayerModel, index)
	newPlayerModel:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.TEAM_ROOM_SCENE, false)
	self:runWhenAnimatorReady(newPlayerModel, function()
		if self.playerModels[index] ~= newPlayerModel then
			return
		end

		local state = newPlayerModel:playRawAnimation(PlayableConst.Revive, 0)

		self:resetIdle(newPlayerModel, state)
		state:AddPlayCallback(function()
			if self.playerModels[index] ~= newPlayerModel then
				return
			end

			newPlayerModel:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.TEAM_ROOM_SCENE, true)
			newPlayerModel:playTeleportAppearEffect(1.5, nil, 1.5)
		end)
	end)
end

function TeamRoomScene:playTeamRoomAni(configId)
	self:syncTeamRoomAni(pg.me.uid, configId)
	pg.game.chat:syncTeamRoomAni(configId)
end

function TeamRoomScene:syncTeamRoomAni(targetUid, configId)
	local actionCfg = AppearanceAction[configId]

	if not actionCfg then
		return
	end

	for index, uid in pairs(self.playerModelUids) do
		if uid == targetUid then
			self:playPlayerAni(targetUid, actionCfg.res1 or {})

			break
		end
	end
end

function TeamRoomScene:getPetAniTickIndex(index)
	return index + 4
end

function TeamRoomScene:clearPetModels()
	for index, model in pairs(self.petModels) do
		if model then
			ClientUtils.safeDestroy(model)
		end

		self:removeDelayAniTick(self:getPetAniTickIndex(index))
	end

	self.petModels = {}
	self.petModelsId = {}
	self.curPetAppearance = {}
	self.waitShowEffectIndex = {}
end

function TeamRoomScene:playWaitShowEffect()
	for index, value in pairs(self.waitShowEffectIndex) do
		if value then
			self:playPetShowEffect(index)
		end
	end

	self.waitShowEffectIndex = {}
end

function TeamRoomScene:setAllModelVisible(visible)
	for _, model in pairs(self.playerModels) do
		model:setActive(ClientConst.MODEL_VISIBLE_KEY.TEAM_ROOM_SCENE, visible)
	end

	for _, model in pairs(self.petModels) do
		model:setActive(ClientConst.MODEL_VISIBLE_KEY.TEAM_ROOM_SCENE, visible)
	end
end

function TeamRoomScene:playPetShowEffect(index)
	if self.petModels[index] then
		self.petModels[index]:playEffect("Eff_Common_Parmon_Switch")
		self.petModels[index]:playSwitchAppearEffect(0.8)
	end
end

function TeamRoomScene:refreshModelsAni()
	math.randomseed(os.time())

	for index, model in pairs(self.playerModels) do
		if not self:isUidPrepare(self.playerDatas[index].uid) then
			local ani = self.playerAnis[math.random(#self.playerAnis)]

			if type(ani) == "table" then
				self:delayExec(index, function()
					self:playAniList(index, model, ani)
				end)
			else
				self:tryPlaySpecialAni(index, model, PlayableConst[ani])
			end
		end
	end

	for index, model in pairs(self.petModels) do
		self:tryPlaySpecialAni(self:getPetAniTickIndex(index), model, PlayableConst[self.petAnis[math.random(#self.petAnis)]])
	end
end

function TeamRoomScene:checkCanPlayAni(model, ani)
	return model and model.eModel and model.eModel:HasPlayableMotion(Const.COMPONENT_IDX_PLAYABLE, ani)
end

function TeamRoomScene:delayExec(index, func)
	self:removeDelayAniTick(index)

	local delay = math.random() * 10

	self.aniTicks[index] = TimerManager.addTimer(delay, func)
end

function TeamRoomScene:removeDelayAniTick(index)
	if self.aniTicks[index] then
		TimerManager.removeTimer(self.aniTicks[index])

		self.aniTicks[index] = nil
	end
end

function TeamRoomScene:tryPlaySpecialAni(index, model, ani)
	if self:checkCanPlayAni(model, ani) then
		self:delayExec(index, function()
			if self:checkCanPlayAni(model, ani) then
				local state = model:playAnimation(ani, true)

				self:resetIdle(model, state)
			end
		end)
	end
end

function TeamRoomScene:resetIdle(model, state)
	model:setAnimationSequence(state, state.Length - 0.2, function(stateTime)
		if stateTime > 0 then
			model:playAnimation(PlayableConst[self.idleAni], true)
		end

		return true
	end)
end

function TeamRoomScene:refreshReadyEffect()
	self.effectRootNoReady.gameObject:SetActiveEx(false)
	self.effectRootReady.gameObject:SetActiveEx(true)
end

function TeamRoomScene:onPlayerReady(uid)
	self:playPlayerAni(uid, self.playerReadyEnterAni)
end

function TeamRoomScene:onPlayerUnReady(uid)
	self:playPlayerAni(uid, self.playerReadyExitAni)
end

function TeamRoomScene:playPlayerAni(uid, aniList)
	if not self.playerDatas then
		return
	end

	for index, playerData in pairs(self.playerDatas) do
		if playerData.uid == uid and self.playerModels[index] then
			self:removeDelayAniTick(index)

			local model = self.playerModels[index]

			self:playAniList(index, model, aniList)

			return
		end
	end
end

function TeamRoomScene:playAniList(index, model, aniList)
	self.curPlayAniSteps[index] = 1

	self:playAniListStep(index, model, aniList)
end

function TeamRoomScene:playAniListStep(index, model, aniList)
	local curStep = self.curPlayAniSteps[index]

	if curStep > #aniList then
		return true
	end

	if self:checkCanPlayAni(model, PlayableConst[aniList[curStep]]) then
		local state = model:playAnimation(PlayableConst[aniList[curStep]], true)

		self.curPlayAniSteps[index] = self.curPlayAniSteps[index] + 1

		model:setAnimationSequence(state, state.Length - 0.2, function(stateTime)
			if stateTime > 0 then
				return self:playAniListStep(index, model, aniList)
			end

			return true
		end)
	end

	return false
end

function TeamRoomScene:calPetModelScale(templateId)
	local petCfg = PetData[templateId]
	local minPetHeight = 0.6
	local maxPetHeight = 2
	local adjustMinPetHeight = 0.6
	local adjustMaxPetHeight = 1.6
	local rate = (adjustMaxPetHeight - adjustMinPetHeight) / (maxPetHeight - minPetHeight)
	local petHeight = petCfg.modelHeight
	local adjustPetHeight = adjustMinPetHeight + (petHeight - minPetHeight) * rate
	local result = adjustPetHeight / petHeight

	return result
end

function TeamRoomScene:getPetData()
	if not self.dungeonConfig then
		return
	end

	local petDatas = {}
	local takePet = self.dungeonConfig.petOrNot == 1

	if not takePet then
		return petDatas
	end

	local startIndex = self.dungeonConfig.playerNumMax > 2 and pg.me:isTeamFull() and 2 or 1
	local teamInfo = self:getTeamInfo()

	for _, uid in ipairs(teamInfo and teamInfo.sortList or EMPTY_TABLE) do
		local petCount = pg.me:getTeamPetCount(uid)
		local memberInfo = teamInfo.membersInfo and teamInfo.membersInfo[uid] or {}
		local petInfoList = memberInfo.petInfoList or {}

		for i = 1, petCount do
			if petInfoList[i] then
				petDatas[startIndex] = petInfoList[i]
			end

			startIndex = startIndex + 1

			if startIndex > Const.PET_PREPARE_NUM_LIMIT then
				startIndex = 1
			end
		end
	end

	return petDatas
end

function TeamRoomScene:getFirstPetDataList()
	if not self.dungeonConfig then
		return
	end

	local takePet = self.dungeonConfig.petOrNot == 1

	if not takePet then
		return {}
	end

	local petDatas = {}
	local teamInfo = self:getTeamInfo()

	for i, uid in ipairs(teamInfo and teamInfo.sortList or EMPTY_TABLE) do
		local memberInfo = teamInfo.membersInfo and teamInfo.membersInfo[uid] or {}
		local petInfoList = memberInfo.petInfoList or {}

		petDatas[i] = petInfoList[1] or {
			empty = true
		}
	end

	return petDatas
end

function TeamRoomScene:showFocusTriangle(uid)
	self:hideFocusTriangle()

	for index, modelUid in pairs(self.playerModelUids) do
		if modelUid == uid and self.playerModels[index] then
			local model = self.playerModels[index]

			self.focusTopLogo = TopLogoItemFocusIndicator.new(model.eModel.transform, model.eModel)

			self.focusTopLogo:createTopLogo()

			break
		end
	end
end

function TeamRoomScene:hideFocusTriangle()
	if self.focusTopLogo then
		self.focusTopLogo:destroy()

		self.focusTopLogo = nil
	end
end

function TeamRoomScene:onDestroy()
	self:hideFocusTriangle()

	for key, tick in pairs(self.aniTicks) do
		TimerManager.removeTimer(tick)
	end

	if self.lookAtTimer then
		TimerManager.removeTimer(self.lookAtTimer)

		self.lookAtTimer = nil
	end

	self.aniTicks = {}

	self:clearPetModels()

	for _, v in pairs(self.playerModels) do
		ClientUtils.safeDestroy(v)
	end

	self.playerModels = {}
	self.playerModelUids = {}

	pg.game.camera:closeTeamRoomCamera()
end

return TeamRoomScene
