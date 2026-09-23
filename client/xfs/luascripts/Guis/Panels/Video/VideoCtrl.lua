-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Video\\VideoCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local VideoCtrl = Class.LightClass("VideoCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ID_PV_FADE_OUT = "PVFadeOut"
local ID_BLACK_TRANSITION = "BlackTransition"
local typeof = typeof

VideoCtrl.VIDEO_TYPE_CHECK_CAN_PLAY_FUNC = {
	[Const.VideoType.PV] = "canPlayPV",
	[Const.VideoType.NormalVideo] = "canPlayNormalVideo",
	[Const.VideoType.BlackTransition] = "canPlayBlackTransition"
}
VideoCtrl.VIDEO_TYPE_DO_PLAY_FUNC = {
	[Const.VideoType.PV] = "playPV",
	[Const.VideoType.NormalVideo] = "playNormalVideo",
	[Const.VideoType.BlackTransition] = "playBlackTransition"
}
VideoCtrl.VIDEO_TYPE_END_CALLBACK = {
	[Const.VideoType.PV] = "onPVEnd",
	[Const.VideoType.NormalVideo] = "onNormalVideoEnd",
	[Const.VideoType.BlackTransition] = "onBlackTransitionEnd"
}
VideoCtrl.DEFAULT_FADE_OUT_TIME = 0.5
VideoCtrl.DEFAULT_PV_FADE_OUT_TIME = 2.5
VideoCtrl.messages = {}

function VideoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.videoType = info.videoType
	self.videoClip = info.videoClip
	self.videoSoundEvent = info.videoSoundEvent
	self.endCb = info.endCb
	self.looped = info.looped or false
	self.alphaMaterial = info.alphaMaterial or false
	self.videoPreparedCb = info.videoPreparedCb

	function self.view.skipBtn.luaClick()
		self:onSkipBtnClick()
	end
end

function VideoCtrl:addListener()
	return
end

function VideoCtrl:onDestroy()
	if self.curSoundEvent then
		pg.game.audio:stopEvent(self.curSoundEvent)

		self.curSoundEvent = nil
	end

	UICtrl.onDestroy(self)
end

function VideoCtrl:onShow()
	UICtrl.onShow(self)
	self:startPlayVideo(self.videoType, self.videoClip)
end

function VideoCtrl:startPlayVideo(videoType, videoClip)
	if self:canPlayVideo(videoType) then
		self:doPlayVideo(videoType, videoClip)
	end
end

function VideoCtrl:onSkipBtnClick()
	if self.view.videoPlayer.isPlaying then
		self.view.videoPlayer:StopVideo()
	end

	if self.curSoundEvent then
		pg.game.audio:stopEvent(self.curSoundEvent)

		self.curSoundEvent = nil
	end

	self:onVideoEndCallback(self.videoType)
end

function VideoCtrl:enableSkipBtn(enable)
	LuaUIUtils.setUIViewVisible(self.view.skipBtn, enable)
end

function VideoCtrl:canPlayVideo(videoType)
	local checkFunc = self.VIDEO_TYPE_CHECK_CAN_PLAY_FUNC[videoType]

	if checkFunc and self[checkFunc] then
		return self[checkFunc](self)
	end

	return false
end

function VideoCtrl:doPlayVideo(videoType, videoClip)
	local doPlayFunc = self.VIDEO_TYPE_DO_PLAY_FUNC[videoType]

	self.view.videoPlayer.videoLoop = self.looped
	self.view.videoPlayer.useAlpha = self.alphaMaterial

	if doPlayFunc and self[doPlayFunc] then
		self[doPlayFunc](self, videoClip)
	end
end

function VideoCtrl:onVideoEndCallback(videoType)
	local cbFunc = self.VIDEO_TYPE_END_CALLBACK[videoType]

	if self.endCb then
		self.endCb()
	end

	if cbFunc and self[cbFunc] then
		self[cbFunc](self)
	end
end

function VideoCtrl:canPlayPV()
	if pg.game.gameState == ClientConst.GS_PLAYGAME and pg.me.clientFirstCreateFlag == true then
		return true
	end

	return false
end

function VideoCtrl:canPlayNormalVideo()
	if pg.game.gameState == ClientConst.GS_PLAYGAME then
		return true
	end

	return false
end

function VideoCtrl:canPlayBlackTransition()
	if pg.game.gameState == ClientConst.GS_PLAYGAME then
		return true
	end

	return false
end

function VideoCtrl:playPV(videoClip, fadeOutTime)
	if videoClip == nil then
		self:onPVEnd()

		return
	end

	if self.curSoundEvent then
		pg.game.audio:stopEvent(self.curSoundEvent)
	end

	self.curSoundEvent = self.videoSoundEvent

	if not string.isNilOrEmpty(self.curSoundEvent) then
		pg.game.audio:playEvent(self.curSoundEvent)
	end

	if fadeOutTime == nil then
		fadeOutTime = VideoCtrl.DEFAULT_PV_FADE_OUT_TIME
	end

	if ToBool(SysConfigData.OPENING_PV_SKIP) then
		self:enableSkipBtn(true)
	else
		self:enableSkipBtn(false)
	end

	LuaUIUtils.setUIViewVisible(self.view.background, true)
	LuaUIUtils.setUIViewVisible(self.view.videoPlayer, true)

	self.view.videoPlayer.resID = videoClip

	function self.view.videoPlayer.luaLoopEnd()
		self:enableSkipBtn(false)
		DoTweenAnimMgr.DoAlpha(self.view.videoPlayer, LuaUIUtils.TweenId(ID_PV_FADE_OUT), 0, fadeOutTime, 0, CS.DG.Tweening.Ease.__CastFrom(Const.DoTweenEaseType.InQuad), function()
			self:onPVEnd()
		end)
	end
end

function VideoCtrl:playNormalVideo(videoClip)
	if pg.space then
		pg.space:pauseGameByType(Const.GameTimeScaleType.VIDEO, -1)
	end

	if self.curSoundEvent then
		pg.game.audio:stopEvent(self.curSoundEvent)
	end

	self.curSoundEvent = self.videoSoundEvent

	if not string.isNilOrEmpty(self.curSoundEvent) then
		pg.game.audio:playEvent(self.curSoundEvent)
	end

	LuaUIUtils.setUIViewVisible(self.view.background, true)
	self:enableSkipBtn(true)
	LuaUIUtils.setUIViewVisible(self.view.videoPlayer, true)

	self.view.videoPlayer.resID = videoClip

	function self.view.videoPlayer.luaVideoPrepared()
		if self.videoPreparedCb then
			self:videoPreparedCb()
		end
	end

	self.view.videoPlayer:PrepareVideo()

	function self.view.videoPlayer.luaLoopEnd()
		if self.endCb then
			self:endCb()
		end

		self:onNormalVideoEnd()
	end
end

function VideoCtrl:playBlackTransition()
	local delayTime = SysConfigData.BlackTransitionDuration or 0.3
	local fadeOutTime = self.DEFAULT_FADE_OUT_TIME

	self:enableSkipBtn(false)
	LuaUIUtils.setUIViewVisible(self.view.background, true)
	LuaUIUtils.setUIViewVisible(self.view.videoPlayer, false)
	DoTweenAnimMgr.DoAlpha(self.view.background, LuaUIUtils.TweenId(ID_BLACK_TRANSITION), 0, fadeOutTime, delayTime, CS.DG.Tweening.Ease.__CastFrom(Const.DoTweenEaseType.InQuad), function()
		self:onBlackTransitionEnd()
	end)
end

function VideoCtrl:onPVEnd()
	pg.me.clientFirstCreateFlag = false
	self.view.videoPlayer.color = Color(self.view.videoPlayer.color.r, self.view.videoPlayer.color.g, self.view.videoPlayer.color.b, 1)

	self:close()
	pg.global.scene:onSceneReady()
end

function VideoCtrl:onNormalVideoEnd()
	if pg.me and pg.space then
		pg.space:resumeGameByType(Const.GameTimeScaleType.VIDEO)
	end

	self:close()
end

function VideoCtrl:onBlackTransitionEnd()
	self.view.background.color = Color(self.view.background.color.r, self.view.background.color.g, self.view.background.color.b, 1)

	self:close()
end

return VideoCtrl
