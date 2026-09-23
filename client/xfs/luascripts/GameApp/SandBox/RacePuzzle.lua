-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\RacePuzzle.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SceneUtils = require("Common.Utils.SceneUtils")
local inspect = require("Core.Common.inspect")
local AudioConst = require("Const.AudioConst")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local SandboxConst = require("Common.Const.SandboxConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local ConflictTypes = require("Common.ConflictTypes")
local Const = require("Common.Const.Const")
local RacePuzzle = Class.LightClass("RacePuzzle", LevelItem)

function RacePuzzle:ctor(sandbox, spawnInfo, syncInfo)
	RacePuzzle.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function RacePuzzle:onInit()
	local defaultValue = self.spawnInfo.defaultValue or {}

	self.chestSpawnerId = defaultValue.chestSpawnerId
	self.duration = defaultValue.duration
	self.initData = self:getConfigData().initData or {}
	self.warningTime = self.initData.warningTime or 8
	self.lastPuzzleState = nil
	self.challengeKey = "RacePuzzle_" .. self.id

	local majorConfig = self:getMajorConfig()

	self.markId = majorConfig.markId or 0
end

function RacePuzzle:onSandboxReady()
	RacePuzzle.super.onSandboxReady(self)

	self.raceSB = self.shell.gameObject:GetComponent("RaceSB")

	self:initRefChestStaticId()

	if not self.raceTimer then
		self.raceTimer = self:addTimer(0.1, function()
			self:raceTick()
		end, true)
	end

	if pg.me:isSpaceOwner() then
		local startTriggerTrans = self.raceSB:TryGetStartTriggerTrans()

		if startTriggerTrans then
			self.startTriggerPos = startTriggerTrans.position
		end
	end

	self:refreshAiHelperState()
end

function RacePuzzle:onValueChange(key, oldValue, value, isInit)
	RacePuzzle.super.onValueChange(self, key, oldValue, value, isInit)

	if key == "puzzleState" then
		self:onPuzzleStateChange(isInit)
	elseif key == "state" then
		self:refreshAiHelperState()
	end
end

function RacePuzzle:destroy()
	if self.lastPuzzleState == SandboxConst.RacePuzzleState.Playing then
		pg.game.challenge:removeChallenge(self.challengeKey, 0)
		pg.global.ui.tips:hideCountDown(self.id)
		pg.game.audio:stopBgm(AudioConst.BgmPriority.PuzzleGame)
	end

	if self.raceTimer then
		self:removeTimer(self.raceTimer)

		self.raceTimer = nil
	end

	self:resetHideChest()

	if pg.me and self.startTriggerPos then
		pg.me:unRegisterAiHelperLevelItem(self.challengeKey)
	end

	RacePuzzle.super.destroy(self)
end

function RacePuzzle:initRefChestStaticId()
	if self.chestSpawnerId and self.chestSpawnerId ~= 0 then
		local sceneSpawnerData = SceneUtils.getSceneSpawnerData(self.sandbox.space.sceneId, self.sandbox.space.id)
		local sceneEntityData = SceneUtils.getSceneEntityData(self.sandbox.space.sceneId, self.sandbox.space.id)
		local spawnerInfo = sceneSpawnerData[self.chestSpawnerId] or {}
		local spawnGroups = spawnerInfo.spawnGroups or {}

		if spawnGroups[1] then
			self.chestStaticId = (spawnGroups[1].spawnIds or EMPTY_TABLE)[1]

			if self.chestStaticId then
				local entityInfo = sceneEntityData[self.chestStaticId]

				self.chestPosition = Vector3(unpack(entityInfo.position))
				self.chestRotation = Quaternion(unpack(entityInfo.rotation))
			end
		end
	end
end

function RacePuzzle:raceTick()
	if self:isPlaying() then
		local curTime = Time.secondCache - self.syncInfo.startTime

		if not self.inWarning and curTime >= self.duration - self.warningTime then
			self.inWarning = true

			self:onStartWarning()
		end
	end
end

function RacePuzzle:RPC_SC_ChestCreated()
	if self.raceSB and self.chestPosition then
		self.raceSB:OnChestCreated(self.chestPosition, self.chestRotation)
	end
end

function RacePuzzle:onReachStartTrigger()
	self:serverMsg("RPC_CS_StartRacePuzzle")
end

function RacePuzzle:RPC_SC_OnTriggerPuzzle()
	if self.raceSB then
		self:tempHideChest()
		self.raceSB:PlayFlyToChestEffect(function()
			self:resetHideChest()
		end)
		pg.game.audio:triggerEvent("SFX_SceneObject_RacePuzzle_TriggerTouch")
		self:toastPoiPopup(pg.getGameString("TIMEPUZZLE_START"), 3)

		local lookAtTrans = self.raceSB.lookAtTransform

		if lookAtTrans ~= nil then
			pg.game.camera.playerCameraMode:FaceToTarget(lookAtTrans.position, 0, 3)
		end

		pg.game.challenge:clearWaitRemoveChallenges()
		facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_START .. self.sandbox.id .. "_" .. self.id)
	end
end

function RacePuzzle:updateEffects(force)
	if not self.raceSB then
		return
	end

	local needCreateEffect = self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.Playing or self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.CountDown

	if self.doorsCreated ~= needCreateEffect or force then
		self.doorsCreated = needCreateEffect

		if needCreateEffect then
			self.raceSB:CreateDoors()
		else
			self.raceSB:DestroyDoors()
		end
	end
end

function RacePuzzle:onPuzzleStateChange(isInit)
	if self.syncInfo.playerId ~= pg.me.id then
		return
	end

	if self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.Playing then
		if not isInit then
			pg.game.audio:triggerEvent("SFX_SceneObject_Puzzle_Start")
		end

		pg.game.audio:playBgm("BGM_Puzzle_Game", AudioConst.BgmPriority.PuzzleGame)
		pg.game.audio:trySetState("BGM_Puzzle_Game", "BGM_Puzzle_Loop")
		pg.global.ui.tips:hideCountDown(self.id)

		local confirmExtraInfo = {
			pauseGame = true
		}
		local customFunc

		LuaUIUtils.clearToastPoiPopup(self.id)

		local remainDuration = self.syncInfo.startTime + self.duration - Time.secondCache
		local infoText = pg.getGameString("RACE_PUZZLE_DESC")
		local markConfig = self:getMarkConfigData()

		pg.game.challenge:addChallenge(self.challengeKey, {
			title = markConfig.POIDesc,
			resetFunc = function()
				if not self:isValid() then
					return
				end

				self:resetAndTeleport()
			end
		})

		self.inWarning = false
	else
		if self.lastPuzzleState == SandboxConst.RacePuzzleState.Playing then
			pg.game.audio:playBgm(nil, AudioConst.BgmPriority.PuzzleGame)
			pg.global.ui.tips:hideCountDown(self.id)
		end

		if self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.CountDown then
			self:updateEffects(true)
		end

		self.inWarning = false
	end

	if self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.CountDown then
		pg.game.cutscene:setInCutsceneState("RacePuzzle_" .. tostring(self.id), true)
	else
		pg.game.cutscene:setInCutsceneState("RacePuzzle_" .. tostring(self.id), false)
	end

	self:updateEffects()

	self.lastPuzzleState = self.syncInfo.puzzleState

	self:refreshAiHelperState()
end

function RacePuzzle:refreshAiHelperState()
	if self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.Default and self.syncInfo.state == Const.RefChestPuzzleState.Default then
		if self.startTriggerPos and pg.me then
			pg.me:registerAiHelperLevelItem(self.challengeKey, {
				isLevelItem = true,
				targetPos = self.startTriggerPos
			})
		end
	elseif self.startTriggerPos and pg.me then
		pg.me:unRegisterAiHelperLevelItem(self.challengeKey)
	end
end

function RacePuzzle:isPlaying()
	return self.syncInfo.puzzleState == SandboxConst.RacePuzzleState.Playing
end

function RacePuzzle:RPC_SC_OnPuzzleSuccess()
	pg.game.challenge:removeChallenge(self.challengeKey, 0)
	pg.game.audio:triggerEvent("SFX_SceneObject_Puzzle_Success")
	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_SUCC .. self.sandbox.id .. "_" .. self.id)

	if self.raceSB then
		self.raceSB:OnPuzzleSuccess()
	end

	self:toastPoiPopup(pg.getGameString("TIMEPUZZLE_SUCC"), nil, {
		isSuccess = true
	})
end

function RacePuzzle:RPC_SC_OnPuzzleFailed()
	pg.game.audio:triggerEvent("SFX_SceneObject_Puzzle_Fail")
	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_FAIL .. self.sandbox.id .. "_" .. self.id)

	if self.raceSB then
		self.raceSB:OnPuzzleFailed()
	end

	self:toastPoiPopup(pg.getGameString("TIMEPUZZLE_FAIL"), nil, {
		isSuccess = false
	})
end

function RacePuzzle:onStartWarning()
	pg.game.audio:trySetState("BGM_Puzzle_Game", "BGM_Puzzle_Warning")
	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_WARN .. self.sandbox.id .. "_" .. self.id)

	if self.raceSB then
		self.raceSB:OnPuzzleWarning()
	end
end

function RacePuzzle:tempHideChest()
	if self.chestStaticId then
		self.sandbox.space:setClientEntVisible(self.chestStaticId, false, false)
	end
end

function RacePuzzle:resetHideChest()
	if self.chestStaticId then
		self.sandbox.space:setClientEntVisible(self.chestStaticId, true, true)
	end
end

function RacePuzzle:getMarkConfigData()
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(self.sandbox.space.sceneId, self.sandbox.space.id)
	local markConfig = sceneMarkPointData[self.markId] or {}

	return markConfig
end

function RacePuzzle:toastPoiPopup(subTitle, duration, extraArgs)
	LuaUIUtils.clearToastPoiPopup()

	local markConfig = self:getMarkConfigData()
	local POIIcon = markConfig.POIIcon
	local POIDesc = markConfig.POIDesc
	local POIMusic = markConfig.POIMusic
	local markConfigId = markConfig.markConfigId
	local POIShowType = {
		0,
		1
	}

	if markConfigId then
		POIShowType = (DefaultMapMarkData[markConfigId] or EMPTY_TABLE).POIShowType
		POIShowType = POIShowType or {
			0,
			1
		}
	end

	LuaUIUtils.toastPoiPopup(2, 10, self.id, POIShowType, POIIcon, POIDesc, subTitle, POIMusic, duration, extraArgs)
end

function RacePuzzle:resetAndTeleport()
	LuaUIUtils.clearToastPoiPopup(self.id)
	self:serverMsg("RPC_CS_ResetPuzzle")
end

function RacePuzzle:RPC_SC_OnResetPuzzle(reason)
	pg.pawn:checkStatus(ConflictTypes.CT_TELEPORT, false)

	if reason == SandboxConst.ResetPuzzleReason.Fail then
		pg.game.challenge:removeChallenge(self.challengeKey, 5)
	else
		pg.game.challenge:removeChallenge(self.challengeKey, 0)
	end

	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_RESET .. self.sandbox.id .. "_" .. self.id)

	if self.raceSB then
		self.raceSB:ResetPuzzle()
	end
end

return RacePuzzle
