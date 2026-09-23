-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\CollectItemPuzzle.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SceneUtils = require("Common.Utils.SceneUtils")
local inspect = require("Core.Common.inspect")
local Time = require("Core.Common.Time")
local AudioConst = require("Const.AudioConst")
local SandboxConst = require("Common.Const.SandboxConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local ConflictTypes = require("Common.ConflictTypes")
local Const = require("Common.Const.Const")
local CommonSwitch = require("Common.CommonSwitch")
local CollectItemPuzzle = Class.LightClass("CollectItemPuzzle", LevelItem)

function CollectItemPuzzle:ctor(sandbox, spawnInfo, syncInfo)
	CollectItemPuzzle.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function CollectItemPuzzle:onInit()
	local defaultValue = self.spawnInfo.defaultValue or {}

	self.chestSpawnerId = defaultValue.chestSpawnerId
	self.duration = defaultValue.duration or 10
	self.initData = self:getConfigData().initData or {}
	self.warningTime = self.initData.warningTime or 8
	self.lastPuzzleState = nil
	self.challengeKey = "CollectItem_" .. self.id

	local majorConfig = self:getMajorConfig()

	self.markId = majorConfig.markId or 0
end

function CollectItemPuzzle:onSandboxReady()
	CollectItemPuzzle.super.onSandboxReady(self)

	self.collectSB = self.shell.gameObject:GetComponent("CollectItemPuzzleSB")

	self:initRefChestStaticId()

	local majorConfig = self:getMajorConfig()

	if majorConfig then
		self.cameraHeightDelta = majorConfig.cameraHeightDelta or 0.5
		self.cameraMaxLockTime = majorConfig.cameraMaxLockTime or 2
		self.cameraTargetShoulder = majorConfig.cameraTargetShoulder or Vector3(0, 3, 0)
		self.cameraTransitionSpeed = majorConfig.cameraTransitionSpeed or 2
	end

	if not self.puzzleTimer then
		self.puzzleTimer = self:addTimer(0.1, function()
			self:puzzleTick()
		end, true)
	end

	if self.syncInfo.puzzleState ~= SandboxConst.CollectPuzzleState.Default then
		self.collectSB:StartPuzzle(false, self:getCollectItems())
	end

	if pg.me:isSpaceOwner() then
		local startTriggerTrans = self.collectSB:TryGetStartTriggerTrans()

		if startTriggerTrans then
			self.startTriggerPos = startTriggerTrans.position
		end
	end

	self:refreshAiHelperState()
end

function CollectItemPuzzle:destroy()
	if self.lastPuzzleState == SandboxConst.CollectPuzzleState.Playing then
		pg.global.ui.tips:hideCountDown(self.id)
		pg.game.challenge:removeChallenge(self.challengeKey, 0)
		pg.game.audio:stopBgm(AudioConst.BgmPriority.PuzzleGame)
	end

	if self.puzzleTimer then
		self:removeTimer(self.puzzleTimer)

		self.puzzleTimer = nil
	end

	if pg.me and self.startTriggerPos then
		pg.me:unRegisterAiHelperLevelItem(self.challengeKey)
	end

	CollectItemPuzzle.super.destroy(self)
end

function CollectItemPuzzle:onValueChange(key, oldValue, value, isInit)
	CollectItemPuzzle.super.onValueChange(self, key, oldValue, value, isInit)

	if key == "puzzleState" then
		self:onPuzzleStateChange(isInit)
	elseif key == "state" then
		self:refreshAiHelperState()
	end
end

function CollectItemPuzzle:initRefChestStaticId()
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

function CollectItemPuzzle:puzzleTick()
	if self:isPlaying() then
		local curTime = Time.secondCache - self.syncInfo.startTime

		if not self.inWarning and curTime >= self.duration - self.warningTime then
			self.inWarning = true

			self:onStartWarning()
		end
	end
end

function CollectItemPuzzle:RPC_SC_ChestCreated()
	if self.collectSB and self.chestPosition then
		self.collectSB:OnChestCreated(self.chestPosition, self.chestRotation)
	end
end

function CollectItemPuzzle:onReachStartTrigger()
	local itemCount = self.collectSB.totalItemCount

	self:serverMsg("RPC_CS_StartCollectPuzzle", itemCount)
end

function CollectItemPuzzle:RPC_SC_OnTriggerPuzzle()
	self:lookAtFirstPos()

	if self.collectSB then
		self.collectSB:StartPuzzle(true, self:getCollectItems())
		pg.game.audio:triggerEvent("SFX_SceneObject_RacePuzzle_TriggerTouch")
		self:toastPoiPopup(pg.getGameString("TIMEPUZZLE_START"), 3)
		pg.game.challenge:clearWaitRemoveChallenges()
		facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_START .. self.sandbox.id .. "_" .. self.id)
	end
end

function CollectItemPuzzle:getCollectItems()
	local items = {}

	for index, _ in pairs(self.syncInfo.collectPuzzleInfo) do
		table.insert(items, index)
	end

	return items
end

function CollectItemPuzzle:isPlaying()
	return self.syncInfo.puzzleState == SandboxConst.CollectPuzzleState.Playing
end

function CollectItemPuzzle:lookAtFirstPos(firstTransform)
	if not firstTransform and self.collectSB then
		self.collectSB:LookAtFirstPos()

		return
	end

	if firstTransform then
		pg.game.camera.playerCameraMode:faceToTargetTransfomWithTargetShoulder(firstTransform, self.cameraHeightDelta, self.cameraMaxLockTime, self.cameraTargetShoulder, self.cameraTransitionSpeed)
	end
end

function CollectItemPuzzle:onPuzzleStateChange(isInit)
	if self.syncInfo.playerId ~= pg.me.id then
		return
	end

	if self.syncInfo.puzzleState == SandboxConst.CollectPuzzleState.Playing then
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

		if not CommonSwitch.TARGET then
			pg.global.ui.tips:showCountDown(remainDuration, self.id, {
				customFunc = customFunc,
				infoText = self:getCountDownInfoText()
			})
		end

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
		if self.lastPuzzleState == SandboxConst.CollectPuzzleState.Playing then
			pg.game.audio:playBgm(nil, AudioConst.BgmPriority.PuzzleGame)
			pg.global.ui.tips:hideCountDown(self.id)
		end

		self.inWarning = false
	end

	if self.syncInfo.puzzleState == SandboxConst.CollectPuzzleState.CountDown then
		pg.game.cutscene:setInCutsceneState("CollectPuzzle_" .. tostring(self.id), true)
	else
		pg.game.cutscene:setInCutsceneState("CollectPuzzle_" .. tostring(self.id), false)
	end

	self.lastPuzzleState = self.syncInfo.puzzleState

	self:refreshAiHelperState()
end

function CollectItemPuzzle:refreshAiHelperState()
	if self.syncInfo.puzzleState == SandboxConst.CollectPuzzleState.Default and self.syncInfo.state == Const.RefChestPuzzleState.Default then
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

function CollectItemPuzzle:onCollectItem(collectIndex)
	self:serverMsg("RPC_CS_OnCollectItem", collectIndex)
end

function CollectItemPuzzle:RPC_SC_OnCollectItem(collectIndex)
	if self.collectSB then
		self.collectSB:SetItemCollected(collectIndex, false)
	end

	self:refreshCountDownInfo()
end

function CollectItemPuzzle:refreshCountDownInfo()
	pg.global.ui.tips:refreshCountDownData(self.id, {
		infoText = self:getCountDownInfoText()
	})
end

function CollectItemPuzzle:getCountDownInfoText()
	local totalCont = self.syncInfo.collectItemCount
	local collectCount = self:getCollectCount()
	local desc = pg.getGameString("COLLECT_PUZZLE_DESC")

	return desc .. collectCount .. "/" .. totalCont
end

function CollectItemPuzzle:getCollectCount()
	local collectCount = 0

	for i = 0, self.syncInfo.collectItemCount - 1 do
		if self.syncInfo.collectPuzzleInfo[i] then
			collectCount = collectCount + 1
		end
	end

	return collectCount
end

function CollectItemPuzzle:RPC_SC_OnPuzzleSuccess()
	pg.game.challenge:removeChallenge(self.challengeKey, 0)
	pg.game.audio:triggerEvent("SFX_SceneObject_Puzzle_Success")
	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_SUCC .. self.sandbox.id .. "_" .. self.id)

	if self.collectSB then
		self.collectSB:OnPuzzleSuccess()
	end

	self:toastPoiPopup(pg.getGameString("TIMEPUZZLE_SUCC"), nil, {
		isSuccess = true
	})
end

function CollectItemPuzzle:RPC_SC_OnPuzzleFailed()
	pg.game.audio:triggerEvent("SFX_SceneObject_Puzzle_Fail")
	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_FAIL .. self.sandbox.id .. "_" .. self.id)

	if self.collectSB then
		self.collectSB:OnPuzzleFailed()
	end

	self:toastPoiPopup(pg.getGameString("TIMEPUZZLE_FAIL"), nil, {
		isSuccess = false
	})
end

function CollectItemPuzzle:onStartWarning()
	pg.game.audio:trySetState("BGM_Puzzle_Game", "BGM_Puzzle_Warning")
	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_WARN .. self.sandbox.id .. "_" .. self.id)

	if self.collectSB then
		self.collectSB:OnPuzzleWarning()
	end
end

function CollectItemPuzzle:getMarkConfigData()
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(self.sandbox.space.sceneId, self.sandbox.space.id)
	local markConfig = sceneMarkPointData[self.markId] or {}

	return markConfig
end

function CollectItemPuzzle:toastPoiPopup(subTitle, duration, extraArgs)
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

function CollectItemPuzzle:resetAndTeleport()
	LuaUIUtils.clearToastPoiPopup(self.id)
	self:serverMsg("RPC_CS_ResetPuzzle")
end

function CollectItemPuzzle:RPC_SC_OnResetPuzzle(reason)
	pg.pawn:checkStatus(ConflictTypes.CT_TELEPORT, false)

	if reason == SandboxConst.ResetPuzzleReason.Fail then
		pg.game.challenge:removeChallenge(self.challengeKey, 5)
	else
		pg.game.challenge:removeChallenge(self.challengeKey, 0)
	end

	facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_PUZZLE_RESET .. self.sandbox.id .. "_" .. self.id)

	if self.collectSB then
		self.collectSB:ResetPuzzle()
	end
end

return CollectItemPuzzle
