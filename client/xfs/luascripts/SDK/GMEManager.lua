-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\GMEManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("GMEManager")
local Class = require("Core.Framework.Class")
local ClientSwitch = require("Common.ClientSwitch")
local MessageName = require("Const.MessageName")
local AudioConst = require("Const.AudioConst")
local Time = require("Core.Common.Time")
local json = require("Lib.json")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common/Utils/Utils")
local base64 = require("base64")
local zlib = require("zlib")
local GMEManager = Class.OldLightClass("GMEManager", nil, true)
local NVIDIA_RECORD_MIN_HOLD_SECONDS = 1.5
local MIN_RECORD_DURATION = 1000
local TRANSLATE_TEXT_TIMEOUT = 15
local TRANSLATE_TEXT_SUSPEND_RECOVER = 30
local RECORD_STOP_TIMEOUT = 10
local USER_SIG_REFRESH_ADVANCE = 300
local USER_SIG_REQUEST_TIMEOUT = 10
local ENTER_ROOM_REQUEST_TIMEOUT = 15
local ROOM_REQUEST_ENTER = "enter"
local ROOM_REQUEST_SWITCH = "switch"
local ROOM_EVENT_SWITCH_COMPLETE = 13
local GME_ERROR_MESSAGE = {
	[4100] = "VOICE_RECORD_AUDIO_TOO_SHORT",
	[32769] = "ERR_VOICE_S2T_SYSTEM_INTERNAL_ERROR"
}
local RoomType = {
	FLUENCY = 1,
	HIGHQUALITY = 3,
	STANDARD = 2
}

function GMEManager:ctor()
	self:clear()
end

function GMEManager:clear()
	self:_cancelTranslateTimers()
	self:_cancelRecordStopTimeout()
	self:_cancelEnterRoomRequestTimer()

	if self.userSigRequestTimerId then
		TimerManager.removeTimer(self.userSigRequestTimerId)
	end

	self.recordFiles = {}
	self.recordStopCallbacks = {}
	self.recording = false
	self.recordStopping = false
	self.recordStartedAt = nil
	self.recordStopTimerId = nil
	self.cacheVolume = nil
	self.playFromSequence = false
	self.audioPlaySequence = {}
	self.playCompleteIgnoreMap = {}
	self.curPlayingFilePath = nil
	self.curPlayingChannel = nil
	self.playFileCallback = nil
	self.pendingPlayFileId = nil
	self.downloadFileNames = {}
	self.downloadFileNameSeq = 0
	self.uploadFileCallbacks = {}
	self.downloadFileCallbacks = {}
	self.translateTextRequestId = 0
	self.translateTextQueue = {}
	self.translateTextRequests = {}
	self.currentTranslateTextRequest = nil
	self.translateTextSuspended = false
	self.translateSuspendTimerId = nil
	self.enterRoomCallback = nil
	self.enterRoomRequesting = false
	self.enterRoomRequestRoomId = nil
	self.enterRoomRequestType = nil
	self.enterRoomRequestSent = false
	self.enterRoomRequestTimerId = nil
	self.currentRoomId = nil
	self.exitRoomCallback = nil
	self.exitRoomRequesting = false
	self.exitRoomPreviousRoomId = nil
	self.userSig = nil
	self.userSigExpireTime = 0
	self.userSigRequesting = false
	self.userSigRequestTimerId = nil
	self.userSigCallbacks = {}
	self.userSigRequestUid = nil
	self.userSigRequestAppId = nil
	self.userSigGeneration = (self.userSigGeneration or 0) + 1
	self.enterRoomRequestSeq = 0
end

function GMEManager:connect()
	local appId = tostring(Utils.getServerAppId())

	self.csgmeManager:Connect(appId, tostring(pg.me.uid))
end

function GMEManager:getUserSign(callback)
	local now = math.floor(Time.secondCache)

	if not string.isNilOrEmpty(self.userSig) and now < (self.userSigExpireTime or 0) - USER_SIG_REFRESH_ADVANCE then
		self:_invokeCallback(callback, self.userSig, self.userSigExpireTime)

		return self.userSig
	end

	if callback then
		table.insert(self.userSigCallbacks, callback)
	end

	if self.userSigRequesting then
		return nil
	end

	if not pg.me or not pg.me.serverMsg then
		local callbacks = self.userSigCallbacks

		self.userSigCallbacks = {}

		for _, pendingCallback in ipairs(callbacks) do
			self:_invokeCallback(pendingCallback, nil, 0)
		end

		return nil
	end

	self.userSigRequesting = true
	self.userSigRequestUid = tostring(pg.me.uid)
	self.userSigRequestAppId = tostring(Utils.getServerAppId())

	local generation = self.userSigGeneration

	self.userSigRequestTimerId = TimerManager.addTimer(USER_SIG_REQUEST_TIMEOUT, function()
		if generation ~= self.userSigGeneration or not self.userSigRequesting then
			return
		end

		self.userSigRequestTimerId = nil
		self.userSigRequesting = false
		self.userSigRequestUid = nil
		self.userSigRequestAppId = nil

		local callbacks = self.userSigCallbacks

		self.userSigCallbacks = {}

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("GenerateUserSig timeout")
		end

		for _, pendingCallback in ipairs(callbacks) do
			self:_invokeCallback(pendingCallback, nil, 0)
		end
	end)

	pg.me:serverMsg("RPC_CS_GenerateUserSig")

	return nil
end

function GMEManager:onUserSigGenerated(userSig, expireTime)
	if not self.userSigRequesting then
		return
	end

	local signedUid, signedAppId = self:decodeUserSigIdentity(userSig)

	if signedUid ~= self.userSigRequestUid or signedAppId ~= self.userSigRequestAppId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Ignore mismatched UserSig response: expected uid=%s appId=%s, actual uid=%s appId=%s", tostring(self.userSigRequestUid), tostring(self.userSigRequestAppId), tostring(signedUid), tostring(signedAppId))
		end

		return
	end

	if self.userSigRequestTimerId then
		TimerManager.removeTimer(self.userSigRequestTimerId)

		self.userSigRequestTimerId = nil
	end

	self.userSigRequesting = false
	self.userSigRequestUid = nil
	self.userSigRequestAppId = nil
	expireTime = tonumber(expireTime) or 0

	if not string.isNilOrEmpty(userSig) and expireTime > math.floor(Time.secondCache) then
		self.userSig = userSig
		self.userSigExpireTime = expireTime
	else
		self.userSig = nil
		self.userSigExpireTime = 0
	end

	local callbacks = self.userSigCallbacks

	self.userSigCallbacks = {}

	for _, pendingCallback in ipairs(callbacks) do
		self:_invokeCallback(pendingCallback, self.userSig, self.userSigExpireTime)
	end
end

function GMEManager:_getUserSignForImmediateOperation()
	local userSig = self:getUserSign()

	if not string.isNilOrEmpty(userSig) then
		return userSig
	end

	if not string.isNilOrEmpty(self.userSig) and math.floor(Time.secondCache) < (self.userSigExpireTime or 0) then
		return self.userSig
	end

	return nil
end

function GMEManager:_cancelEnterRoomRequestTimer()
	if self.enterRoomRequestTimerId then
		TimerManager.removeTimer(self.enterRoomRequestTimerId)

		self.enterRoomRequestTimerId = nil
	end
end

function GMEManager:_beginEnterRoomRequest(roomId, callback, requestType)
	self.enterRoomRequesting = true
	self.enterRoomRequestRoomId = roomId
	self.enterRoomRequestType = requestType
	self.enterRoomRequestSent = false
	self.enterRoomCallback = callback
	self.enterRoomRequestSeq = self.enterRoomRequestSeq + 1

	local requestSeq = self.enterRoomRequestSeq

	self:_cancelEnterRoomRequestTimer()

	self.enterRoomRequestTimerId = TimerManager.addTimer(ENTER_ROOM_REQUEST_TIMEOUT, function()
		if self.enterRoomRequesting and requestSeq == self.enterRoomRequestSeq then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("Enter/switch room timeout: roomId=%s timeout=%ss", tostring(roomId), tostring(ENTER_ROOM_REQUEST_TIMEOUT))
			end

			if self.enterRoomRequestSent and self:checkSDKValid() then
				self.currentRoomId = nil
				self.exitRoomRequesting = true
				self.exitRoomPreviousRoomId = nil
				self.exitRoomCallback = nil

				self.csgmeManager:ExitRoom()
			end

			self.enterRoomRequestSeq = self.enterRoomRequestSeq + 1

			self:_finishEnterRoomRequest(-1)
		end
	end)

	return requestSeq
end

function GMEManager:_finishEnterRoomRequest(error)
	if not self.enterRoomRequesting then
		return
	end

	local roomId = self.enterRoomRequestRoomId
	local callback = self.enterRoomCallback

	self:_cancelEnterRoomRequestTimer()

	self.enterRoomRequesting = false
	self.enterRoomRequestRoomId = nil
	self.enterRoomRequestType = nil
	self.enterRoomRequestSent = false
	self.enterRoomCallback = nil

	if error == 0 then
		self.currentRoomId = roomId
	end

	self:_invokeCallback(callback, error)
end

function GMEManager:_finishExitRoomRequest(error)
	if not self.exitRoomRequesting then
		return
	end

	local callback = self.exitRoomCallback

	if error ~= 0 then
		self.currentRoomId = self.exitRoomPreviousRoomId
	end

	self.exitRoomRequesting = false
	self.exitRoomPreviousRoomId = nil
	self.exitRoomCallback = nil

	self:_invokeCallback(callback, error)
end

function GMEManager:Init()
	local mgr = CS.FunPlus.WorldX.SDK.Tencent.GMEManager

	mgr.InitFromLua()

	self.csgmeManager = mgr.GetInstance()
end

function GMEManager:UnInit()
	if self:checkSDKValid() then
		self:restoreIOSRecordState()
		self.csgmeManager:UnInit()
	end

	self:clear()
end

function GMEManager:InitApp()
	if self:checkSDKValid() then
		self:connect()
		self:getUserSign(function(userSig)
			if self:checkSDKValid() and not string.isNilOrEmpty(userSig) then
				self.csgmeManager:InitApp(userSig)
			end
		end)
	end
end

function GMEManager:EnterRoom(roomId, roomType, callback)
	if not self:checkSDKValid() then
		self:_invokeCallback(callback, -1)

		return
	end

	if self.exitRoomRequesting then
		self:_invokeCallback(callback, -1)

		return
	end

	roomId = tostring(roomId)

	if self.currentRoomId == roomId then
		self:_invokeCallback(callback, 0, true)

		return
	end

	if self.enterRoomRequesting then
		if self.enterRoomRequestRoomId == roomId then
			self:_invokeCallback(callback, -1, true)

			return
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("EnterRoom ignored: pendingRoomId=%s targetRoomId=%s", tostring(self.enterRoomRequestRoomId), roomId)
		end

		self:_invokeCallback(callback, -1)

		return
	end

	local requestSeq = self:_beginEnterRoomRequest(roomId, callback, ROOM_REQUEST_ENTER)

	roomType = roomType or RoomType.FLUENCY

	self:connect()
	self:getUserSign(function(userSig)
		if requestSeq ~= self.enterRoomRequestSeq then
			return
		end

		if self:checkSDKValid() and not string.isNilOrEmpty(userSig) then
			self.enterRoomRequestSent = true

			self.csgmeManager:EnterRoom(roomId, userSig, roomType)

			return
		end

		self:_finishEnterRoomRequest(-1)
	end)
end

function GMEManager:SwitchRoom(roomId, callback)
	if not self:checkSDKValid() then
		self:_invokeCallback(callback, -1)

		return
	end

	if self.exitRoomRequesting then
		self:_invokeCallback(callback, -1)

		return
	end

	roomId = tostring(roomId)

	if self.currentRoomId == roomId then
		self:_invokeCallback(callback, 0, true)

		return
	end

	if self.enterRoomRequesting then
		if self.enterRoomRequestRoomId == roomId then
			self:_invokeCallback(callback, -1, true)

			return
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("SwitchRoom ignored: pendingRoomId=%s targetRoomId=%s", tostring(self.enterRoomRequestRoomId), roomId)
		end

		self:_invokeCallback(callback, -1)

		return
	end

	local requestSeq = self:_beginEnterRoomRequest(roomId, callback, ROOM_REQUEST_SWITCH)

	self:connect()
	self:getUserSign(function(userSig)
		if requestSeq ~= self.enterRoomRequestSeq then
			return
		end

		if self:checkSDKValid() and not string.isNilOrEmpty(userSig) then
			self.enterRoomRequestSent = true

			self.csgmeManager:SwitchRoom(roomId, userSig)

			return
		end

		self:_finishEnterRoomRequest(-1)
	end)
end

function GMEManager:ExitRoom(callback)
	if not self:checkSDKValid() then
		self:_invokeCallback(callback, -1)

		return
	end

	if self.exitRoomRequesting then
		self:_invokeCallback(callback, -1)

		return
	end

	if self.enterRoomRequesting then
		self.enterRoomRequestSeq = self.enterRoomRequestSeq + 1

		self:_finishEnterRoomRequest(-1)
	end

	self.exitRoomRequesting = true
	self.exitRoomPreviousRoomId = self.currentRoomId
	self.currentRoomId = nil
	self.exitRoomCallback = callback

	self.csgmeManager:ExitRoom()
end

function GMEManager:MutedUser(userId)
	if self:checkSDKValid() then
		self.csgmeManager:MutedUser(userId)
	end
end

function GMEManager:UnMutedUser(userId)
	if self:checkSDKValid() then
		self.csgmeManager:UnMutedUser(userId)
	end
end

function GMEManager:EnableMic(isOn, isSend)
	if self:checkSDKValid() then
		isSend = isSend or false

		self.csgmeManager:EnableMic(isOn, isSend)

		local micVol = pg.game.setting:getMicVol()

		self:SetMicVolume(micVol)
	end
end

function GMEManager:EnableSpeaker(isOn, isRecv)
	if self:checkSDKValid() then
		isRecv = isRecv or false

		self.csgmeManager:EnableSpeaker(isOn, isRecv)
	end
end

function GMEManager:SetMicVolume(volume)
	if self:checkSDKValid() then
		self.csgmeManager:SetMicVolume(volume)
	end
end

function GMEManager:SetSpeakerVolume(volume)
	if self:checkSDKValid() then
		local masterVol = pg.game.setting:getVolume(AudioConst.VolumeType.All)

		self.csgmeManager:SetSpeakerVolume(math.floor(volume * masterVol * 0.02))
	end
end

function GMEManager:StartRecord_Test(speechLanguage, translateLanguage)
	if self:checkSDKValid() then
		if self.recording or self.recordStopping then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("StartRecord_Test ignored: recording=%s recordStopping=%s", tostring(self.recording), tostring(self.recordStopping))
			end

			return false
		end

		if UNITY_IOS then
			self.csgmeManager:SetMediaCapture(true)

			self.cacheVolume = pg.game.setting:getVolume(AudioConst.VolumeType.All)

			pg.game.setting:setVolume(AudioConst.VolumeType.All, 0)
		end

		self:EnableMic(true, false)
		self:connect()

		local userSig = self:_getUserSignForImmediateOperation()

		if string.isNilOrEmpty(userSig) then
			self:EnableMic(false, true)
			self:restoreIOSRecordState()

			return false
		end

		speechLanguage = speechLanguage or Const.COUNTRY_LANGUAGES_CODE.EN_US
		translateLanguage = translateLanguage or Const.COUNTRY_LANGUAGES_CODE.EN_US

		local result = self.csgmeManager:StartRecording(self:getRecordFileName(), userSig, speechLanguage, translateLanguage)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("StartRecord_Test result=%s", tostring(result))
		end

		if result ~= 0 then
			self:EnableMic(false, true)
			self:restoreIOSRecordState()

			return false
		end

		self.recording = true
		self.recordStartedAt = Time.realtimeSinceStartup

		return true
	end

	return false
end

function GMEManager:StartRecording(speechLanguage, translateLanguage)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("StartRecording entered at=%.3f recording=%s recordStopping=%s", Time.realtimeSinceStartup, tostring(self.recording), tostring(self.recordStopping))
	end

	local _h = GMEManager._platformHooks

	if _h and _h.StartRecording and _h.StartRecording(self) then
		return false
	end

	if self:checkSDKValid() then
		if self.recording or self.recordStopping then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("StartRecording ignored: recording=%s recordStopping=%s", tostring(self.recording), tostring(self.recordStopping))
			end

			return false
		end

		if UNITY_IOS then
			self.csgmeManager:SetMediaCapture(true)

			self.cacheVolume = pg.game.setting:getVolume(AudioConst.VolumeType.All)

			pg.game.setting:setVolume(AudioConst.VolumeType.All, 0)
		end

		self:EnableMic(false, true)
		self:connect()

		local userSig = self:_getUserSignForImmediateOperation()

		if string.isNilOrEmpty(userSig) then
			self:restoreMicAfterRecording()
			self:restoreIOSRecordState()

			return false
		end

		speechLanguage = speechLanguage or Const.COUNTRY_LANGUAGES_CODE.CN
		translateLanguage = translateLanguage or Const.COUNTRY_LANGUAGES_CODE.CN

		local fileName = self:getRecordFileName()

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("SDK StartRecording called at=%.3f fileName=%s speechLanguage=%s translateLanguage=%s", Time.realtimeSinceStartup, tostring(fileName), tostring(speechLanguage), tostring(translateLanguage))
		end

		local result = self.csgmeManager:StartRecording(fileName, userSig, speechLanguage, translateLanguage)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("StartRecording result=%s", tostring(result))
		end

		if result ~= 0 then
			self:restoreMicAfterRecording()
			self:restoreIOSRecordState()

			return false
		end

		self.recording = true
		self.recordStartedAt = Time.realtimeSinceStartup

		return true
	end

	return false
end

function GMEManager:StopRecord_Test(onComplete)
	if not self.recording then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("StopRecord_Test ignored: recording=%s recordStopping=%s", tostring(self.recording), tostring(self.recordStopping))
		end

		return false
	end

	if self:checkSDKValid() then
		local holdDuration = self.recordStartedAt and Time.realtimeSinceStartup - self.recordStartedAt or 0

		self.recording = false
		self.recordStartedAt = nil

		self:EnableMic(false, true)

		if holdDuration < NVIDIA_RECORD_MIN_HOLD_SECONDS then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("StopRecord_Test cancelled: holdDuration=%.3f minDuration=%.3f", holdDuration, NVIDIA_RECORD_MIN_HOLD_SECONDS)
			end

			local result = self.csgmeManager:CancelRecording()

			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("CancelRecording for short press result=%s", tostring(result))
			end

			self:restoreIOSRecordState()
			pg.global.showBubbleMessageRaw(pg.getGameString("VOICE_RECORD_AUDIO_TOO_SHORT"))

			if onComplete then
				table.insert(self.recordStopCallbacks, onComplete)
				self:_notifyRecordStopped(nil, nil, nil, nil, nil, nil)
			end

			return false
		end

		if onComplete then
			table.insert(self.recordStopCallbacks, onComplete)
		end

		self.recordStopping = true

		local result = self.csgmeManager:StopRecording()

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("StopRecord_Test result=%s", tostring(result))
		end

		self:restoreIOSRecordState()

		if result ~= 0 then
			self.recordStopping = false

			self:onReceiveError(result)
			self:_notifyRecordStopped(nil, nil, nil, nil, nil, nil)

			return false
		end

		self:_scheduleRecordStopTimeout()

		return true
	elseif onComplete then
		self:_invokeCallback(onComplete, nil, nil, nil, nil, nil, nil, -1, false)
	end

	return false
end

function GMEManager:StopRecording(onComplete)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("StopRecording entered at=%.3f recording=%s recordStopping=%s", Time.realtimeSinceStartup, tostring(self.recording), tostring(self.recordStopping))
	end

	if not self.recording then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("StopRecording ignored: recording=%s recordStopping=%s", tostring(self.recording), tostring(self.recordStopping))
		end

		return false
	end

	if self:checkSDKValid() then
		self.recording = false
		self.recordStartedAt = nil

		self:restoreMicAfterRecording()

		if onComplete then
			table.insert(self.recordStopCallbacks, onComplete)
		end

		self.recordStopping = true

		local result = self.csgmeManager:StopRecording()

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("StopRecording result=%s", tostring(result))
		end

		self:restoreIOSRecordState()

		if result ~= 0 then
			self.recordStopping = false

			self:onReceiveError(result)
			self:_notifyRecordStopped(nil, nil, nil, nil, nil, nil)

			return false
		end

		self:_scheduleRecordStopTimeout()

		return true
	elseif onComplete then
		self:_invokeCallback(onComplete, nil, nil, nil, nil, nil, nil, -1, false)
	end

	return false
end

function GMEManager:CancelRecording()
	if self:checkSDKValid() then
		self.recording = false
		self.recordStopping = false
		self.recordStartedAt = nil

		self:_cancelRecordStopTimeout()

		local result = self.csgmeManager:CancelRecording()

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("CancelRecording result=%s", tostring(result))
		end

		self:restoreIOSRecordState()

		return result == 0
	end

	return false
end

function GMEManager:restoreMicAfterRecording()
	facade:SendMessageCommand(MessageName.GME_RECORD_WILL_STOP, {})
end

function GMEManager:restoreIOSRecordState()
	if UNITY_IOS and self.cacheVolume then
		pg.game.setting:setVolume(AudioConst.VolumeType.All, self.cacheVolume)

		self.cacheVolume = nil

		self.csgmeManager:SetMediaCapture(false)
	end
end

function GMEManager:_cancelRecordStopTimeout()
	if self.recordStopTimerId then
		TimerManager.removeTimer(self.recordStopTimerId)

		self.recordStopTimerId = nil
	end
end

function GMEManager:_scheduleRecordStopTimeout()
	self:_cancelRecordStopTimeout()

	self.recordStopTimerId = TimerManager.addTimer(RECORD_STOP_TIMEOUT, function()
		self.recordStopTimerId = nil

		if not self.recordStopping then
			return
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("StopRecording timeout: no onStreamingSpeechComplete in %ss", tostring(RECORD_STOP_TIMEOUT))
		end

		self.recording = false
		self.recordStopping = false
		self.recordStartedAt = nil

		self:_notifyRecordStopped(nil, nil, nil, nil, nil, nil, -1, false)
	end)
end

function GMEManager:_notifyRecordStopped(fileId, filePath, fileSize, duration, text, auditResult, code, tooShort)
	if not self.recordStopCallbacks or #self.recordStopCallbacks == 0 then
		return
	end

	local callbacks = self.recordStopCallbacks

	self.recordStopCallbacks = {}

	for _, callback in ipairs(callbacks) do
		local res, err = xpcall(callback, debug.traceback, fileId, filePath, fileSize, duration, text, auditResult, code, tooShort)

		if not res and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Error in record stop callback : %s", tostring(err))
		end
	end
end

function GMEManager:PlayRecordedFile(fileId, callback)
	if string.isNilOrEmpty(fileId) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PlayRecordedFile invalid fileId: %s", tostring(fileId))
		end

		self:_invokeCallback(callback, -1, nil)

		return
	end

	if not self:checkSDKValid() then
		self:_invokeCallback(callback, -1, nil)

		return
	end

	if self.playFileCallback then
		self:_invokeCallback(self.playFileCallback, -1, self.curPlayingFilePath)
	end

	self.playFromSequence = false
	self.audioPlaySequence = {}
	self.curPlayingChannel = nil
	self.playFileCallback = callback

	local filePath = self.recordFiles[fileId]

	if filePath then
		self:_playRecordedFile(filePath, fileId)
	else
		self.pendingPlayFileId = fileId

		self:DownloadRecordedFile(fileId, self:_getDownloadFileName(fileId))
	end
end

function GMEManager:PlayRecordedFileSequence(fileId, curChannel, callback)
	if string.isNilOrEmpty(fileId) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PlayRecordedFileSequence invalid fileId: %s", tostring(fileId))
		end

		self:_invokeCallback(callback, -1, nil)

		return
	end

	if not self:checkSDKValid() then
		self:_invokeCallback(callback, -1, nil)

		return
	end

	if not self.playFromSequence and self.playFileCallback and self.playFileCallback ~= callback then
		local previous = self.playFileCallback

		self.playFileCallback = nil

		self:_invokeCallback(previous, -1, self.curPlayingFilePath)
	end

	if callback then
		self.playFileCallback = callback
	end

	if not table.contains(self.audioPlaySequence, fileId) then
		self.audioPlaySequence[#self.audioPlaySequence + 1] = fileId
	end

	if not self.playFromSequence then
		self.playFromSequence = true
		self.curPlayingChannel = curChannel

		local filePath = self.recordFiles[fileId]

		if filePath then
			self:_playRecordedFileSeqTop()
		else
			self.pendingPlayFileId = fileId

			self:DownloadRecordedFile(fileId, self:_getDownloadFileName(fileId))
		end
	end
end

function GMEManager:getCurPlayingChannel()
	return self.curPlayingChannel
end

function GMEManager:_playRecordedFileSeqTop()
	if not self.audioPlaySequence[1] then
		self.playFromSequence = false

		return
	end

	local fileId = self.audioPlaySequence[1]
	local filePath = self.recordFiles[fileId]

	if filePath then
		self:_playRecordedFile(filePath, fileId, true)
		table.remove(self.audioPlaySequence, 1)
	else
		self.pendingPlayFileId = fileId

		self:DownloadRecordedFile(fileId, self:_getDownloadFileName(fileId))
	end
end

function GMEManager:_playRecordedFile(filePath, fileId, fromSequence)
	if self:checkSDKValid() then
		if self.curPlayingFilePath == filePath then
			self:_markIgnorePlayComplete(self.curPlayingFilePath)
		end

		self.curPlayingFilePath = filePath

		self.csgmeManager:PlayRecordedFile(filePath)
		facade:SendMessageCommand(MessageName.GME_PLAY_FILE_START, {
			filePath = filePath,
			fileId = fileId,
			fromSequence = fromSequence or false
		})
	end
end

function GMEManager:_markIgnorePlayComplete(filePath)
	if string.isNilOrEmpty(filePath) then
		return
	end

	if not self.playCompleteIgnoreMap then
		self.playCompleteIgnoreMap = {}
	end

	self.playCompleteIgnoreMap[filePath] = (self.playCompleteIgnoreMap[filePath] or 0) + 1
end

function GMEManager:_consumeIgnorePlayComplete(filePath)
	if string.isNilOrEmpty(filePath) or not self.playCompleteIgnoreMap then
		return false
	end

	local count = self.playCompleteIgnoreMap[filePath]

	if not count or count <= 0 then
		return false
	end

	if count == 1 then
		self.playCompleteIgnoreMap[filePath] = nil
	else
		self.playCompleteIgnoreMap[filePath] = count - 1
	end

	return true
end

function GMEManager:StopPlayFile()
	if self:checkSDKValid() then
		local stoppedFilePath = self.curPlayingFilePath

		if self.curPlayingFilePath then
			self:_markIgnorePlayComplete(self.curPlayingFilePath)
		end

		self.csgmeManager:StopPlayFile()

		self.curPlayingFilePath = nil
		self.playFromSequence = false
		self.audioPlaySequence = {}
		self.curPlayingChannel = nil
		self.pendingPlayFileId = nil

		local callback = self.playFileCallback

		self.playFileCallback = nil

		if callback then
			self:_invokeCallback(callback, -1, stoppedFilePath)
		end
	end
end

function GMEManager:UploadRecordedFile(filePath, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("UploadRecordedFile entered at=%.3f filePath=%s", Time.realtimeSinceStartup, tostring(filePath))
	end

	local _h = GMEManager._platformHooks

	if _h and _h.UploadRecordedFile and _h.UploadRecordedFile(self, filePath) then
		self:_invokeCallback(callback, -1, filePath, nil, nil)

		return
	end

	if self:checkSDKValid() then
		if callback then
			self.uploadFileCallbacks[filePath] = self.uploadFileCallbacks[filePath] or {}

			table.insert(self.uploadFileCallbacks[filePath], callback)
		end

		self.csgmeManager:UploadRecordedFile(filePath)
	elseif callback then
		self:_invokeCallback(callback, -1, filePath, nil, nil)
	end
end

function GMEManager:DownloadRecordedFile(fileId, filePath, callback)
	if string.isNilOrEmpty(fileId) or string.isNilOrEmpty(filePath) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("DownloadRecordedFile invalid args: fileId=%s filePath=%s", tostring(fileId), tostring(filePath))
		end

		self:_invokeCallback(callback, -1, filePath, fileId, nil)

		return
	end

	if self:checkSDKValid() then
		if callback then
			self.downloadFileCallbacks[fileId] = self.downloadFileCallbacks[fileId] or {}

			table.insert(self.downloadFileCallbacks[fileId], callback)
		end

		self.csgmeManager:DownloadRecordedFile(fileId, filePath)
	elseif callback then
		self:_invokeCallback(callback, -1, filePath, fileId, nil)
	end
end

function GMEManager:SpeechToText(fileId, speechLanguage, translateLanguage)
	if not self:checkSDKValid() then
		return
	end

	speechLanguage = speechLanguage or Const.COUNTRY_LANGUAGES_CODE.CN
	translateLanguage = translateLanguage or Const.COUNTRY_LANGUAGES_CODE.CN

	self.csgmeManager:SpeechToText(fileId, speechLanguage, translateLanguage)
end

function GMEManager:_notifyTranslateTextRequest(request, success, translatedText, response)
	if not request or request.notified then
		return
	end

	request.notified = true

	if self.translateTextRequests then
		self.translateTextRequests[request.id] = nil
	end

	local callback = request.callback

	request.callback = nil

	if callback then
		self:_invokeCallback(callback, request.id, success, translatedText or "", response)
	end
end

function GMEManager:CancelTranslateText(requestId)
	requestId = tonumber(requestId)

	local request = requestId and self.translateTextRequests and self.translateTextRequests[requestId] or nil

	if not request then
		return false
	end

	request.cancelled = true

	if self.currentTranslateTextRequest ~= request then
		for index = #self.translateTextQueue, 1, -1 do
			if self.translateTextQueue[index] == request then
				table.remove(self.translateTextQueue, index)

				break
			end
		end
	end

	self:_notifyTranslateTextRequest(request, false, "", nil)

	return true
end

function GMEManager:_resumeTranslateText(reason)
	if self.translateSuspendTimerId then
		TimerManager.removeTimer(self.translateSuspendTimerId)

		self.translateSuspendTimerId = nil
	end

	if not self.translateTextSuspended then
		return
	end

	self.translateTextSuspended = false

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("TranslateText resumed: %s", tostring(reason))
	end

	self:_startNextTranslateTextRequest()
end

function GMEManager:_scheduleTranslateSuspendRecover()
	if self.translateSuspendTimerId then
		TimerManager.removeTimer(self.translateSuspendTimerId)
	end

	self.translateSuspendTimerId = TimerManager.addTimer(TRANSLATE_TEXT_SUSPEND_RECOVER, function()
		self.translateSuspendTimerId = nil

		self:_resumeTranslateText("recover timer")
	end)
end

function GMEManager:_startNextTranslateTextRequest()
	if self.currentTranslateTextRequest or not self.translateTextQueue or #self.translateTextQueue == 0 then
		return
	end

	local request = table.remove(self.translateTextQueue, 1)

	self.currentTranslateTextRequest = request
	request.timerId = TimerManager.addTimer(TRANSLATE_TEXT_TIMEOUT, function()
		if self.currentTranslateTextRequest ~= request then
			return
		end

		self.currentTranslateTextRequest = nil
		request.timerId = nil
		self.translateTextSuspended = true

		self:_scheduleTranslateSuspendRecover()

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("TranslateText timeout: requestId=%s", tostring(request.id))
		end

		self:_notifyTranslateTextRequest(request, false, "", nil)

		if not request.cancelled then
			while #self.translateTextQueue > 0 do
				self:_notifyTranslateTextRequest(table.remove(self.translateTextQueue, 1), false, "", nil)
			end
		end
	end)

	local ok, err = pcall(self.csgmeManager.TranslateText, self.csgmeManager, request.text, request.sourceLanguage, request.translateLanguage)

	if not ok and self.currentTranslateTextRequest == request then
		TimerManager.removeTimer(request.timerId)

		request.timerId = nil
		self.currentTranslateTextRequest = nil

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("TranslateText call failed: requestId=%s error=%s", tostring(request.id), tostring(err))
		end

		self:_notifyTranslateTextRequest(request, false, "", nil)
		self:_startNextTranslateTextRequest()
	end
end

function GMEManager:TranslateText(text, sourceLanguage, translateLanguage, callback)
	self.translateTextRequestId = self.translateTextRequestId + 1

	local request = {
		id = self.translateTextRequestId,
		text = text,
		sourceLanguage = sourceLanguage or Const.COUNTRY_LANGUAGES_CODE.CN,
		translateLanguage = translateLanguage or Const.COUNTRY_LANGUAGES_CODE.CN,
		callback = callback
	}

	self.translateTextRequests[request.id] = request

	if not self:checkSDKValid() then
		self:_notifyTranslateTextRequest(request, false, "", nil)

		return request.id
	end

	if self.translateTextSuspended then
		self:_notifyTranslateTextRequest(request, false, "", nil)

		return request.id
	end

	self:connect()
	self:getUserSign(function(userSig)
		if request.cancelled then
			return
		end

		if not self:checkSDKValid() or self.translateTextSuspended or string.isNilOrEmpty(userSig) then
			self:_notifyTranslateTextRequest(request, false, "", nil)

			return
		end

		table.insert(self.translateTextQueue, request)
		self:_startNextTranslateTextRequest()
	end)

	return request.id
end

function GMEManager:onEnterRoomComplete(error)
	if self.enterRoomRequestType ~= ROOM_REQUEST_ENTER then
		return
	end

	self:onReceiveError(error)
	self:_finishEnterRoomRequest(error)
end

function GMEManager:onExitRoomComplete(error)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onExitRoomComplete")
	end

	self:_finishExitRoomRequest(error or 0)
end

function GMEManager:onRoomDisconnect(result, errorInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onRoomDisconnect result=%s errorInfo=%s", tostring(result), tostring(errorInfo))
	end

	self.currentRoomId = nil

	if self.enterRoomRequesting then
		self.enterRoomRequestSeq = self.enterRoomRequestSeq + 1

		self:_finishEnterRoomRequest(result ~= 0 and result or -1)
	end

	if self.exitRoomRequesting then
		self:_finishExitRoomRequest(0)
	end

	facade:SendMessageCommand(MessageName.GME_ROOM_DISCONNECT, {})
end

function GMEManager:onRoomMembersChange(userIDList)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onRoomMembersChange", inspect(userIDList))
	end

	facade:SendMessageCommand(MessageName.GME_ROOM_MEMBERS_CHANGE, {
		uids = userIDList
	})
end

function GMEManager:onRoomSpeakingMembersChange(userIDList)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onRoomSpeakingMembersChange", inspect(userIDList))
	end

	facade:SendMessageCommand(MessageName.GME_ROOM_SPEAKING_MEMBERS_CHANGE, {
		uids = userIDList
	})
end

function GMEManager:onRoomEvent(eventType, subType, data)
	if eventType == ROOM_EVENT_SWITCH_COMPLETE and self.enterRoomRequestType == ROOM_REQUEST_SWITCH then
		self:onReceiveError(subType)
		self:_finishEnterRoomRequest(subType)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onRoomEvent type=%s subType=%s data=%s", tostring(eventType), tostring(subType), tostring(data))
	end
end

function GMEManager:onNetworkQualityStatistics(localQuality, remoteQualityList)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onNetworkQualityStatistics local=%s remote=%s", inspect(localQuality), inspect(remoteQualityList))
	end
end

function GMEManager:onRoomTypeChanged(roomType)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onRoomTypeChanged roomType=%s", tostring(roomType))
	end
end

function GMEManager:onStreamingSpeechisRunning(text)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onStreamingSpeechisRunning")
	end
end

function GMEManager:onStreamingSpeechComplete(code, fileId, filePath, fileSize, duration, text, auditResult)
	self.recording = false
	self.recordStopping = false
	self.recordStartedAt = nil

	self:_cancelRecordStopTimeout()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("Streaming speech complete at=%.3f code=%s fileId=%s filePath=%s fileSize=%s duration=%s text=%s auditResult=%s", Time.realtimeSinceStartup, tostring(code), tostring(fileId), tostring(filePath), tostring(fileSize), tostring(duration), tostring(text), tostring(auditResult))
	end

	self:onReceiveError(code)

	local tooShort = code == 0 and (duration or 0) < MIN_RECORD_DURATION
	local success = code == 0 and not tooShort

	if success and LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onStreamingSpeechComplete", fileId, filePath, fileSize, duration, text, auditResult)
	end

	if success then
		self.recordFiles[fileId] = filePath
	end

	if success then
		self:_notifyRecordStopped(fileId, filePath, fileSize, duration, text, auditResult, code, false)
	else
		self:_notifyRecordStopped(nil, nil, nil, nil, nil, nil, code, tooShort)
	end
end

function GMEManager:onPlayFileComplete(code, filepath)
	self:onReceiveError(code)

	if self:_consumeIgnorePlayComplete(filepath) then
		return
	end

	if self.curPlayingFilePath and filepath ~= self.curPlayingFilePath then
		return
	end

	if code ~= 0 then
		self.curPlayingFilePath = nil
		self.playFromSequence = false
		self.audioPlaySequence = {}
		self.curPlayingChannel = nil

		local callback = self.playFileCallback

		self.playFileCallback = nil

		self:_invokeCallback(callback, code, filepath)

		return
	end

	self.curPlayingFilePath = nil

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onPlayFileComplete", filepath)
	end

	local callback = self.playFileCallback

	if self.playFromSequence then
		self:_invokeCallback(callback, code, filepath)
		self:_playRecordedFileSeqTop()

		if not self.playFromSequence then
			self.playFileCallback = nil
		end
	else
		self.audioPlaySequence = {}
		self.playFileCallback = nil

		self:_invokeCallback(callback, code, filepath)
	end
end

function GMEManager:onUploadFileComplete(code, filePath, fileId, auditResult)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("upload complete at=%.3f code=%s fileId=%s filePath=%s auditResult=%s", Time.realtimeSinceStartup, tostring(code), tostring(fileId), tostring(filePath), tostring(auditResult))
	end

	self:onReceiveError(code)

	if code == 0 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("onUploadFileComplete", filePath, fileId, auditResult)
		end

		self.recordFiles[fileId] = filePath
	end

	local callbacks = self.uploadFileCallbacks[filePath]
	local callback = callbacks and table.remove(callbacks, 1) or nil

	if callbacks and #callbacks == 0 then
		self.uploadFileCallbacks[filePath] = nil
	end

	self:_invokeCallback(callback, code, filePath, fileId, auditResult)
end

function GMEManager:onDownloadFileAuditComplete(code, filePath, fileId, auditResult)
	self:onReceiveError(code)

	local waitingToPlay = self.pendingPlayFileId ~= nil and self.pendingPlayFileId == fileId

	if waitingToPlay then
		self.pendingPlayFileId = nil
	end

	if code == 0 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("onDownloadFileAuditComplete", filePath, fileId, auditResult)
		end

		self.recordFiles[fileId] = filePath

		if waitingToPlay then
			if self.playFromSequence then
				self:_playRecordedFileSeqTop()
			else
				self:_playRecordedFile(filePath, fileId)
			end
		end
	elseif waitingToPlay then
		if self.playFromSequence then
			if self.audioPlaySequence[1] == fileId then
				table.remove(self.audioPlaySequence, 1)
			end

			self:_playRecordedFileSeqTop()

			if not self.playFromSequence then
				self.playFileCallback = nil
			end
		else
			local playCallback = self.playFileCallback

			self.playFileCallback = nil

			self:_invokeCallback(playCallback, code, filePath)
		end
	end

	local callbacks = self.downloadFileCallbacks[fileId]
	local callback = callbacks and table.remove(callbacks, 1) or nil

	if callbacks and #callbacks == 0 then
		self.downloadFileCallbacks[fileId] = nil
	end

	self:_invokeCallback(callback, code, filePath, fileId, auditResult)
end

function GMEManager:onTranslateTextComplete(code, targetText)
	self:onReceiveError(code)

	local request = self.currentTranslateTextRequest

	self.currentTranslateTextRequest = nil

	if not request then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("onTranslateTextComplete ignored: no pending request")
		end

		self:_resumeTranslateText("late callback arrived")

		return
	end

	TimerManager.removeTimer(request.timerId)

	request.timerId = nil

	if code ~= 0 then
		self:_notifyTranslateTextRequest(request, false, "", nil)
		self:_startNextTranslateTextRequest()

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onTranslateTextComplete")
	end

	local decoded, res = pcall(json.decode, targetText)

	if not decoded or type(res) ~= "table" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("onTranslateTextComplete decode failed : %s", tostring(targetText))
		end

		self:_notifyTranslateTextRequest(request, false, "", nil)
		self:_startNextTranslateTextRequest()

		return
	end

	if tonumber(res.result) ~= 0 then
		self:_notifyTranslateTextRequest(request, false, "", res)
		self:_startNextTranslateTextRequest()

		return
	end

	local targetList = res.target_text
	local first = type(targetList) == "table" and targetList[1] or nil

	if first == nil then
		self:_notifyTranslateTextRequest(request, false, "", res)
		self:_startNextTranslateTextRequest()

		return
	end

	self:_notifyTranslateTextRequest(request, true, first.translated_text or "", res)
	self:_startNextTranslateTextRequest()
end

function GMEManager:onRecordFileComplete(code, filePath, fileSize, duration)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onRecordFileComplete code=%s filePath=%s fileSize=%s duration=%s", tostring(code), tostring(filePath), tostring(fileSize), tostring(duration))
	end

	self:onReceiveError(code)
end

function GMEManager:onDownloadFileComplete(code, filePath, fileId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onDownloadFileComplete code=%s filePath=%s fileId=%s", tostring(code), tostring(filePath), tostring(fileId))
	end

	self:onDownloadFileAuditComplete(code, filePath, fileId, nil)
end

function GMEManager:onSpeechToTextAuditComplete(code, fileId, result, auditResult)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onSpeechToTextAuditComplete code=%s fileId=%s result=%s auditResult=%s", tostring(code), tostring(fileId), tostring(result), tostring(auditResult))
	end

	self:onReceiveError(code)
end

function GMEManager:onSpeechToTextTargetTextComplete(code, fileId, result, auditResult, targetText)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onSpeechToTextTargetTextComplete code=%s fileId=%s result=%s auditResult=%s targetText=%s", tostring(code), tostring(fileId), tostring(result), tostring(auditResult), tostring(targetText))
	end

	self:onReceiveError(code)
end

function GMEManager:onTextToSpeechComplete(code, serialNumber, fileId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onTextToSpeechComplete code=%s serialNumber=%s fileId=%s", tostring(code), tostring(serialNumber), tostring(fileId))
	end

	self:onReceiveError(code)
end

function GMEManager:_cancelTranslateTimers()
	if self.currentTranslateTextRequest and self.currentTranslateTextRequest.timerId then
		TimerManager.removeTimer(self.currentTranslateTextRequest.timerId)

		self.currentTranslateTextRequest.timerId = nil
	end

	if self.translateSuspendTimerId then
		TimerManager.removeTimer(self.translateSuspendTimerId)

		self.translateSuspendTimerId = nil
	end
end

function GMEManager:checkSDKValid()
	return ClientSwitch.EnableGMESDK and self.csgmeManager
end

function GMEManager:getRecordFileName()
	return tostring(pg.me.uid) .. "_" .. os.date("!%Y_%m_%d_%H_%M_%S") .. ".ogg"
end

function GMEManager:_getDownloadFileName(fileId)
	if string.isNilOrEmpty(fileId) then
		return nil
	end

	local name = self.downloadFileNames[fileId]

	if not name then
		self.downloadFileNameSeq = self.downloadFileNameSeq + 1
		name = string.format("%s_dl_%d.ogg", tostring(pg.me.uid), self.downloadFileNameSeq)
		self.downloadFileNames[fileId] = name
	end

	return name
end

function GMEManager:getRecordedFilePath(fileId)
	return self.recordFiles[fileId] or ""
end

function GMEManager:onReceiveError(errorCode)
	if errorCode == 0 then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("GME onReceiveError", errorCode)
	end

	facade:SendMessageCommand(MessageName.GME_ERROR, {
		code = errorCode,
		tipKey = GME_ERROR_MESSAGE[errorCode]
	})
end

function GMEManager:decodeUserSigIdentity(userSig)
	if string.isNilOrEmpty(userSig) then
		return nil, nil
	end

	local success, payload = pcall(function()
		local standardBase64 = userSig:gsub("%*", "+"):gsub("%-", "/"):gsub("_", "=")
		local compressed = base64.decode(standardBase64)
		local jsonText = zlib.inflate()(compressed)

		return json.decode(jsonText)
	end)

	if not success or type(payload) ~= "table" then
		return nil, nil
	end

	return tostring(payload["TLS.identifier"]), tostring(payload["TLS.sdkappid"])
end

function GMEManager:_invokeCallback(callback, ...)
	if not callback then
		return
	end

	local ok, err = xpcall(callback, debug.traceback, ...)

	if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("GME callback failed: %s", tostring(err))
	end
end

return GMEManager
