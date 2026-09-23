-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\BossRushScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local BossRushScene = Class.LightClass("BossRushScene", UISceneBase)
local ClientConst = require("Const.ClientConst")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local Const = require("Common.Const.Const")
local EffectConst = require("Const.EffectConst")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local BossRushUtils = require("Utils.BossRushUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")

function BossRushScene:onStart(param)
	self.leftEntity = nil
	self.rightEntity = nil
	self.midEntity = nil
	self.seasonPlayerEntity = nil
	self.leftMiniGameEntity = nil
	self.rightMiniGameEntity = nil
	self.playerModels = {}
	self.playerModelUids = {}

	self:initScene(param)
end

function BossRushScene:initScene(param)
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.cameraCamera = self.objectReference:GetRefValue("cameraCamera")
	self.bossMidTransform = self.objectReference:GetRefValue("bossMidTransform")
	self.bossLeftTransform = self.objectReference:GetRefValue("bossLeftTransform")
	self.bossRightTransform = self.objectReference:GetRefValue("bossRightTransform")
	self.miniGameLeftTransform = self.objectReference:GetRefValue("miniGameLeftTransform")
	self.miniGameRightTransform = self.objectReference:GetRefValue("miniGameRightTransform")
	self.player1Transform = self.objectReference:GetRefValue("player1Transform")
	self.player2Transform = self.objectReference:GetRefValue("player2Transform")
	self.player3Transform = self.objectReference:GetRefValue("player3Transform")
	self.player4Transform = self.objectReference:GetRefValue("player4Transform")
	self.mainVirtualCamera = self.objectReference:GetRefValue("mainVirtualCamera")
	self.leftVirtualCamera = self.objectReference:GetRefValue("leftVirtualCamera")
	self.midVirtualCamera = self.objectReference:GetRefValue("midVirtualCamera")
	self.rightVirtualCamera = self.objectReference:GetRefValue("rightVirtualCamera")
	self.pointBossUButton = self.objectReference:GetRefValue("pointBossUButton")
	self.pointBossLeftUButton = self.objectReference:GetRefValue("pointBossLeftUButton")
	self.pointBossRightUButton = self.objectReference:GetRefValue("pointBossRightUButton")
	self.bossInfoUComponent = self.objectReference:GetRefValue("bossInfoUComponent")
	self.bossInfoLeftUComponent = self.objectReference:GetRefValue("bossInfoLeftUComponent")
	self.bossInfoRightUComponent = self.objectReference:GetRefValue("bossInfoRightUComponent")
	self.luckyPetTransform = self.objectReference:GetRefValue("luckyPetTransform")
	self.midFxTransform = self.objectReference:GetRefValue("midFxTransform")
	self.leftFxTransform = self.objectReference:GetRefValue("leftFxTransform")
	self.rightFxTransform = self.objectReference:GetRefValue("rightFxTransform")
	self.midLightTransform = self.objectReference:GetRefValue("midLightTransform")
	self.leftLightTransform = self.objectReference:GetRefValue("leftLightTransform")
	self.rightLightTransform = self.objectReference:GetRefValue("rightLightTransform")
	self.leftArrowTransform = self.objectReference:GetRefValue("leftArrowTransform")
	self.rightArrowTransform = self.objectReference:GetRefValue("rightArrowTransform")
	self.luckyPetFxTransform = self.objectReference:GetRefValue("luckyPetFxTransform")
	self.pBossRushUISceneEnv = self.objectReference:GetRefValue("pBossRushUISceneEnv")
	self.seasonVirtualCamera = self.objectReference:GetRefValue("seasonVirtualCamera")
	self.playerSeasonTransform = self.objectReference:GetRefValue("playerSeasonTransform")
	self.mountainTransform = self.objectReference:GetRefValue("mountainTransform")
	self.courseTransform = self.objectReference:GetRefValue("courseTransform")

	self.leftArrowTransform.gameObject:SetActiveEx(false)
	self.rightArrowTransform.gameObject:SetActiveEx(false)

	self.playerPos = {
		self.player1Transform,
		self.player2Transform,
		self.player3Transform,
		self.player4Transform
	}

	pg.global.cameraMgr:SetUISceneCamera(self.cameraCamera)
	self.luckyPetFxTransform.gameObject:SetActiveEx(false)
end

function BossRushScene:setEntityParam(root, ent, lightTransform, fxTransform, cfg)
	if not ent or not cfg then
		return
	end

	if cfg.modelPos then
		root.transform.position = Vector3(cfg.modelPos[1], cfg.modelPos[2], cfg.modelPos[3])
	end

	if cfg.modelRot then
		root.transform.rotation = Quaternion(cfg.modelRot[1], cfg.modelRot[2], cfg.modelRot[3], cfg.modelRot[4])
	end

	if cfg.modelScale then
		root.transform.localScale = Vector3(cfg.modelScale[1], cfg.modelScale[2], cfg.modelScale[3])
	end

	if cfg.lightPos and lightTransform then
		lightTransform.transform.position = Vector3(cfg.lightPos[1], cfg.lightPos[2], cfg.lightPos[3])
	end

	if cfg.lightRot and lightTransform then
		lightTransform.transform.rotation = Quaternion(cfg.lightRot[1], cfg.lightRot[2], cfg.lightRot[3], cfg.lightRot[4])
	end

	if cfg.lightIntensity and lightTransform then
		pgUtils.SetLightIntensity(lightTransform, cfg.lightIntensity)
	end

	if cfg.effectScale and fxTransform then
		fxTransform.transform.localScale = Vector3(cfg.effectScale[1], cfg.effectScale[2], cfg.effectScale[3])
	end
end

function BossRushScene:setEntities(left, right, mid, leftMiniGame, rightMiniGame)
	local cycleData = BossRushUtils.getCycleData()

	if left then
		if self.leftEntity then
			ClientUtils.safeDestroy(self.leftEntity)

			self.leftEntity = nil
		end

		self.leftEntity = ClientVirtualEntityUtils.createSimpleVirtualNpc(left)

		self.leftEntity.eModel:SetTransformParent(self.bossLeftTransform, false)
		self.leftEntity.eModel:SetTransformLocalPosition()
		self.leftEntity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
		self.leftEntity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)

		local leftBossData = BossRushLevelData[cycleData.bossLeft]

		if leftBossData then
			local cfg = {
				modelPos = leftBossData.leftModelPosition,
				modelRot = leftBossData.leftModelRotation,
				modelScale = leftBossData.leftModelScale,
				lightPos = leftBossData.leftLightPosition,
				lightRot = leftBossData.leftLightRotation,
				lightIntensity = leftBossData.leftLightIntensity,
				effectScale = leftBossData.leftEffectScale
			}

			self:setEntityParam(self.bossLeftTransform, self.leftEntity, self.leftLightTransform, self.leftFxTransform, cfg)
		end

		function self.leftEntity.onSkeletonLoadedCallback()
			ClientEffectUtils.PlayPreset(self.leftEntity, "Digital_Boss_Blue", -1, false)
			ClientEffectUtils.PlayPresetWithFilterMark(self.leftEntity, "BossRush_RedEyes_Frenel", -1, false, "Eye")
		end
	end

	if right then
		if self.rightEntity then
			ClientUtils.safeDestroy(self.rightEntity)

			self.rightEntity = nil
		end

		self.rightEntity = ClientVirtualEntityUtils.createSimpleVirtualNpc(right)

		self.rightEntity.eModel:SetTransformParent(self.bossRightTransform, false)
		self.rightEntity.eModel:SetTransformLocalPosition()
		self.rightEntity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
		self.rightEntity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)

		local rightBossData = BossRushLevelData[cycleData.bossRight]

		if rightBossData then
			local cfg = {
				modelPos = rightBossData.rightModelPosition,
				modelRot = rightBossData.rightModelRotation,
				modelScale = rightBossData.rightModelScale,
				lightPos = rightBossData.rightLightPosition,
				lightRot = rightBossData.rightLightRotation,
				lightIntensity = rightBossData.rightLightIntensity,
				effectScale = rightBossData.rightEffectScale
			}

			self:setEntityParam(self.bossRightTransform, self.rightEntity, self.rightLightTransform, self.rightFxTransform, cfg)
		end

		function self.rightEntity.onSkeletonLoadedCallback()
			ClientEffectUtils.PlayPreset(self.rightEntity, "Digital_Boss_Blue", -1, false)
			ClientEffectUtils.PlayPresetWithFilterMark(self.rightEntity, "BossRush_RedEyes_Frenel", -1, false, "Eye")
		end
	end

	if mid then
		if self.midEntity then
			ClientUtils.safeDestroy(self.midEntity)

			self.midEntity = nil
		end

		self.midEntity = ClientVirtualEntityUtils.createSimpleVirtualNpc(mid)

		self.midEntity.eModel:SetTransformParent(self.bossMidTransform, false)
		self.midEntity.eModel:SetTransformLocalPosition()
		self.midEntity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
		self.midEntity:playEffect(EffectConst.Eff_Level_BossRush_UI_BossRedEye)
		self.midEntity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)

		local midBossData = BossRushLevelData[cycleData.bossMid]

		if midBossData then
			local cfg = {
				modelPos = midBossData.midModelPosition,
				modelRot = midBossData.midModelRotation,
				modelScale = midBossData.midModelScale,
				lightPos = midBossData.midLightPosition,
				lightRot = midBossData.midLightRotation,
				lightIntensity = midBossData.midLightIntensity,
				effectScale = midBossData.midEffectScale
			}

			self:setEntityParam(self.bossMidTransform, self.midEntity, self.midLightTransform, self.midFxTransform, cfg)
		end

		function self.midEntity.onSkeletonLoadedCallback()
			ClientEffectUtils.PlayPreset(self.midEntity, "Digital_Boss_Gold", -1, false)
			ClientEffectUtils.PlayPresetWithFilterMark(self.midEntity, "BossRush_RedEyes_Frenel", -1, false, "Eye")
		end
	end

	if leftMiniGame then
		if self.leftMiniGameEntity then
			ClientUtils.safeDestroy(self.leftMiniGameEntity)

			self.leftMiniGameEntity = nil
		end

		self.leftMiniGameEntity = ClientVirtualEntityUtils.createSimpleVirtualNpc(leftMiniGame)

		self.leftMiniGameEntity.eModel:SetTransformParent(self.miniGameLeftTransform, false)
		self.leftMiniGameEntity.eModel:SetTransformLocalPosition()
		self.leftMiniGameEntity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	end

	if rightMiniGame then
		if self.rightMiniGameEntity then
			ClientUtils.safeDestroy(self.rightMiniGameEntity)

			self.rightMiniGameEntity = nil
		end

		self.rightMiniGameEntity = ClientVirtualEntityUtils.createSimpleVirtualNpc(rightMiniGame)

		self.rightMiniGameEntity.eModel:SetTransformParent(self.miniGameRightTransform, false)
		self.rightMiniGameEntity.eModel:SetTransformLocalPosition()
		self.rightMiniGameEntity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	end
end

function BossRushScene:showModels()
	local cycleData = BossRushUtils.getCycleData()

	if not cycleData then
		return
	end

	local bossDataLeft = BossRushLevelData[cycleData.bossLeft]
	local leftEntity = bossDataLeft and bossDataLeft.bossId and {
		applyAnim = true,
		templateId = bossDataLeft.bossId
	} or nil
	local bossDataRight = BossRushLevelData[cycleData.bossRight]
	local rightEntity = bossDataRight and bossDataRight.bossId and {
		applyAnim = true,
		templateId = bossDataRight.bossId
	} or nil
	local bossDataMid = BossRushLevelData[cycleData.bossMid]
	local midEntity = bossDataMid and bossDataMid.bossId and {
		applyAnim = true,
		templateId = bossDataMid.bossId
	} or nil
	local miniGameDataLeft = BossRushLevelData[cycleData.miniGameLeft]
	local leftMiniGameEntity = miniGameDataLeft and miniGameDataLeft.bossId and {
		templateId = miniGameDataLeft.bossId
	} or nil
	local miniGameDataRight = BossRushLevelData[cycleData.miniGameRight]
	local rightMiniGameEntity = miniGameDataRight and miniGameDataRight.bossId and {
		templateId = miniGameDataRight.bossId
	} or nil

	self:setEntities(leftEntity, rightEntity, midEntity, leftMiniGameEntity, rightMiniGameEntity)
	self:refreshPlayerModel()
end

function BossRushScene:setPlayers(playerDatas)
	for index, tran in ipairs(self.playerPos) do
		local playerData = playerDatas[index] or {
			empty = true
		}

		if self.playerModels[index] and (playerData.empty or self.playerModelUids[index] ~= playerData.uid) then
			ClientUtils.safeDestroy(self.playerModels[index])

			self.playerModels[index] = nil
			self.playerModelUids[index] = nil
		end

		if not playerData.empty and not self.playerModels[index] then
			local newPlayerModel = self:createPlayer(playerData, tran)

			self.playerModels[index] = newPlayerModel
			self.playerModelUids[index] = playerData.uid
		end
	end

	for index, val in ipairs(playerDatas) do
		if val.uid == pg.me.uid then
			if self.seasonPlayerEntity then
				ClientUtils.safeDestroy(self.seasonPlayerEntity)
			end

			self.seasonPlayerEntity = self:createPlayer(val, self.playerSeasonTransform)

			return
		end
	end
end

function BossRushScene:refreshPlayerModel()
	local playerDatas = {}

	if pg.me:isInTeam() then
		local teamInfo = pg.me:getCurTeamInfo()
		local membersInfo = teamInfo.membersInfo

		for _, uid in ipairs(teamInfo.sortList) do
			local playerInfo = membersInfo[uid]

			table.insert(playerDatas, {
				uid = uid,
				avatarConfig = playerInfo.avatarConfig,
				curShow = playerInfo.curShow,
				avatarPresetKey = playerInfo.avatarPresetKey
			})
		end
	else
		table.insert(playerDatas, {
			uid = pg.me.uid
		})
	end

	self:setPlayers(playerDatas)
end

function BossRushScene:createPlayer(playerData, tran)
	local newPlayerModel

	if playerData.uid == pg.me.uid then
		newPlayerModel = ClientSimpleVirtualPlayer.new()

		local initInfo = {
			copyEntity = pg.me
		}

		initInfo = self:getPlayerOriginInitDict(initInfo, ClientSimpleVirtualPlayer)

		newPlayerModel:init(initInfo)
		newPlayerModel:postInit(initInfo)
		newPlayerModel:start()
	else
		newPlayerModel = ClientVirtualEntityUtils.createVirtualPlayer(playerData.avatarConfig, playerData.curShow, playerData.avatarPresetKey)
	end

	newPlayerModel:setScaleNumber(0.3)
	newPlayerModel.eModel:SetTransformParent(tran)
	newPlayerModel.eModel:SetTransformLocalPosition()
	newPlayerModel.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	newPlayerModel:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	newPlayerModel:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)

	return newPlayerModel
end

function BossRushScene:switchCameraPos(target)
	self.mainVirtualCamera.Priority = 0
	self.leftVirtualCamera.Priority = 0
	self.midVirtualCamera.Priority = 0
	self.rightVirtualCamera.Priority = 0
	self.seasonVirtualCamera.Priority = 0

	self.bossInfoUComponent:SetActive(false)
	self.bossInfoLeftUComponent:SetActive(false)
	self.bossInfoRightUComponent:SetActive(false)

	if self.seasonPlayerEntity ~= nil then
		self.seasonPlayerEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, false)
		self.mountainTransform.gameObject:SetActiveEx(true)
		self.courseTransform.gameObject:SetActiveEx(false)
	end

	if target == nil then
		self.mainVirtualCamera.Priority = 10

		self:setModelVisible(self.leftEntity, self.leftFxTransform, true)
		self:setModelVisible(self.rightEntity, self.rightFxTransform, true)
		self:setModelVisible(self.midEntity, self.midFxTransform, true)
		self.pointBossUButton:SetActive(true)
		self.pointBossLeftUButton:SetActive(true)
		self.pointBossRightUButton:SetActive(true)

		return
	end

	self.pointBossUButton:SetActive(false)
	self.pointBossLeftUButton:SetActive(false)
	self.pointBossRightUButton:SetActive(false)
	self:setModelVisible(self.leftEntity, self.leftFxTransform, false)
	self:setModelVisible(self.rightEntity, self.rightFxTransform, false)
	self:setModelVisible(self.midEntity, self.midFxTransform, false)

	if target == Const.BossRushTeleportTarget.BossLeft then
		self.leftVirtualCamera.Priority = 10

		self:setModelVisible(self.leftEntity, self.leftFxTransform, true)
		self.bossInfoLeftUComponent:SetActive(true)
	elseif target == Const.BossRushTeleportTarget.BossMid then
		self.midVirtualCamera.Priority = 10

		self:setModelVisible(self.midEntity, self.midFxTransform, true)
		self.bossInfoUComponent:SetActive(true)
	elseif target == Const.BossRushTeleportTarget.BossRight then
		self.rightVirtualCamera.Priority = 10

		self:setModelVisible(self.rightEntity, self.rightFxTransform, true)
		self.bossInfoRightUComponent:SetActive(true)
	elseif target == Const.BossRushTeleportTarget.Season then
		self.seasonVirtualCamera.Priority = 10

		self.seasonPlayerEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, true)
		self.mountainTransform.gameObject:SetActiveEx(false)
		self.courseTransform.gameObject:SetActiveEx(true)
	end
end

function BossRushScene:setLuckyPetModel(tId, uiRect)
	self.luckyPetEntity = ClientVirtualEntityUtils.createPetVirtualEntity(tId)

	if not self.luckyPetEntity then
		return
	end

	self.luckyPetEntity.eModel:SetTransformParent(self.luckyPetTransform, false)
	self.luckyPetEntity.eModel:SetTransformLocalPosition()
	self.luckyPetEntity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	PetTransmogUtils.applySchemeTransmog(self.luckyPetEntity, tId, nil, false, true)
	self.luckyPetFxTransform.gameObject:SetActiveEx(true)
	UIUtils.SetRectLocalPosByWorldPos(self.luckyPetTransform.position + Vector3(0.75, -0.75, 0), uiRect)
end

function BossRushScene:setModelVisible(entity, fxRoot, visible)
	if entity then
		entity.eModel:SetModelVisible(visible)
	end

	if fxRoot then
		fxRoot.gameObject:SetActiveEx(visible)
	end
end

function BossRushScene:setAllModelVisible(visible)
	if self.leftEntity then
		self.leftEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, visible)
	end

	if self.rightEntity then
		self.rightEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, visible)
	end

	if self.midEntity then
		self.midEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, visible)
	end

	if self.luckyPetEntity then
		self.luckyPetEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, visible)
	end

	for index, value in ipairs(self.playerModels) do
		value:setActive(ClientConst.MODEL_VISIBLE_KEY.BOSS_RUSH_SCENE, visible)
	end
end

function BossRushScene:setEnvComponentEnable(enable)
	if self.pBossRushUISceneEnv then
		self.pBossRushUISceneEnv:SetEnvSceneComponentEnable(enable)
	end
end

function BossRushScene:onDestroy()
	if self.leftEntity then
		ClientUtils.safeDestroy(self.leftEntity)

		self.leftEntity = nil
	end

	if self.midEntity then
		ClientUtils.safeDestroy(self.midEntity)

		self.midEntity = nil
	end

	if self.rightEntity then
		ClientUtils.safeDestroy(self.rightEntity)

		self.rightEntity = nil
	end

	if self.leftMiniGameEntity then
		ClientUtils.safeDestroy(self.leftMiniGameEntity)

		self.leftMiniGameEntity = nil
	end

	if self.rightMiniGameEntity then
		ClientUtils.safeDestroy(self.rightMiniGameEntity)

		self.rightMiniGameEntity = nil
	end

	if self.luckyPetEntity then
		ClientUtils.safeDestroy(self.luckyPetEntity)

		self.luckyPetEntity = nil
	end

	if self.seasonPlayerEntity then
		ClientUtils.safeDestroy(self.seasonPlayerEntity)

		self.seasonPlayerEntity = nil
	end

	for index, value in ipairs(self.playerModels) do
		ClientUtils.safeDestroy(value)
	end

	self.playerModels = {}
	self.playerModelUids = {}
end

return BossRushScene
