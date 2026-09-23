-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Microphone.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AiConst = require("Common.Const.AiConst")
local AudioConst = require("Const.AudioConst")
local Microphone = Class.LightClass("Microphone", LevelItem)
local logger = LoggerManager.getLogger("Microphone")
local MICROPHONE_STATE = {
	CAMERA = 1,
	STOP = 0,
	PERFORMANCE = 2
}
local VOCAL_PREFIX = "VOX_Emotion_Parmon"
local VOCAL_LAST_TIME = 5

function Microphone:ctor(sandbox, spawnInfo, syncInfo)
	Microphone.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Microphone:onInitShareMem()
	self.shareMem:set("triggerEffect", false)
end

function Microphone:_syncState(targetState)
	self:serverMsg("RPC_CS_SetMicrophoneState", targetState)
end

function Microphone:StartCamera()
	if self.shareMem:get("state") ~= MICROPHONE_STATE.STOP and self.shareMem:get("curPlayerId") ~= pg.me.id then
		local noticeStr = pg.getGameString("ARK_MICROPHONE_USED")

		pg.global.showBubbleMessageRaw(noticeStr)
	else
		self:_syncState(MICROPHONE_STATE.CAMERA)
	end
end

function Microphone:_onCameraStart()
	local majorConfig = self:getMajorConfig()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onCameraStart", majorConfig.camPos)
	end

	pg.game.input:setBlockInput("Microphone", true)

	local extraParam
	local camPos = majorConfig.camPos or {
		0,
		0,
		0
	}
	local camRot = majorConfig.camRot and Quaternion.Euler(majorConfig.camRot[1], majorConfig.camRot[2], majorConfig.camRot[3]) or Quaternion.identity
	local camFov = majorConfig.camFov or 20
	local camBlendTime = majorConfig.camBlendTime or 1

	pg.game.camera:cameraBlendToFixed(camPos, camRot, camFov, camBlendTime, CallbackHandler(self, "_syncState", MICROPHONE_STATE.PERFORMANCE), extraParam)
end

function Microphone:_onMovingStart()
	local petEntity = pg.me:getCurPetEntity()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onMovingStart")
	end

	petEntity:pauseBt(AiConst.PauseBtReason.Microphone)
	petEntity:pawnAutoPathFinding(self:getPosition(), CallbackHandler(self, "_onPerformanceStart", false))

	if not self._pathFindTimer then
		self._pathFindTimer = self:addTimer(3, CallbackHandler(self, "_onPerformanceStart", true))
	end
end

function Microphone:_onPerformanceStart(isForce)
	if self._pathFindTimer then
		self:removeTimer(self._pathFindTimer)

		self._pathFindTimer = nil
	end

	local petEntity = pg.me:getCurPetEntity()

	if isForce then
		petEntity:forceSetPosRot(self:getPosition(), self:getRotation())
	end

	self.shareMem:set("triggerEffect", true)
	self.shareMem:flush()

	petEntity = pg.me:getCurPetEntity()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onPerformanceStart")
	end

	local aniState = petEntity:playAnimation("Idle")
	local resId = string.sub(petEntity.templateId, 1, 5)
	local eventName = VOCAL_PREFIX .. "_" .. resId .. "_Happy"

	petEntity:playSoundEvent(eventName, function(eventType, extraInfo)
		if AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_EndOfEvent) and self.shareMem:get("state") ~= MICROPHONE_STATE.STOP then
			if self._performanceTimer then
				self:removeTimer(self._performanceTimer)

				self._performanceTimer = nil
			end

			self:_syncState(MICROPHONE_STATE.STOP)
		end
	end)

	local effectKey = "Eff_SceneObject_Microphone_Parmon"
	local extInfo

	petEntity:playEffect(effectKey, extInfo)

	if not self._performanceTimer then
		self._performanceTimer = self:addTimer(VOCAL_LAST_TIME, CallbackHandler(self, "_syncState", MICROPHONE_STATE.STOP))
	end
end

function Microphone:_onPerformanceFinish()
	local petEntity = pg.me:getCurPetEntity()

	petEntity:resumeBt(AiConst.PauseBtReason.Microphone)
	pg.game.input:setBlockInput("Microphone", false)

	local majorConfig = self:getMajorConfig()

	pg.game.camera:cancelBlendToFixed(majorConfig.camBlendTime)
end

function Microphone:setSyncInfo(syncInfo, isInit)
	local id = pg.me.id
	local cacheId = self.shareMem:get("curPlayerId")
	local syncId = syncInfo.curPlayerId

	if id ~= cacheId and id ~= syncId then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("Microphone:setSyncInfo not owner", syncInfo.curPlayerId)
		end

		self._isOwner = false
	else
		self._isOwner = true
	end

	Microphone.super.setSyncInfo(self, syncInfo, isInit)
end

function Microphone:onLevelItemValueChange(key, oldValue, value)
	if not self._isOwner then
		return
	end

	if key == "state" then
		if value == MICROPHONE_STATE.CAMERA then
			self:_onCameraStart()
		elseif value == MICROPHONE_STATE.STOP then
			self:_onPerformanceFinish()
		elseif value == MICROPHONE_STATE.PERFORMANCE then
			self:_onMovingStart()
		end
	end
end

function Microphone:destroy()
	Microphone.super.destroy(self)
end

return Microphone
