-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogVideo\\PetTransmogVideoCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local VIDEO_LOAD_TIMEOUT = 10
local PetTransmogVideoCtrl = Class.LightClass("PetTransmogVideoCtrl", UICtrl)

PetTransmogVideoCtrl.messages = {}

function PetTransmogVideoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setContext(info and info.petId or nil, info and info.videoUrl or nil)

	self.videoRequestSerial = 0
	self.activeVideoRequestSerial = nil
	self.videoLoadTimer = nil
end

function PetTransmogVideoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info then
		self.model:setContext(info.petId, info.videoUrl)
	end
end

function PetTransmogVideoCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.videoButton then
		function self.view.videoButton.luaClick()
			self:onVideoSurfaceClick()
		end
	end

	if self.view.btnPlay then
		function self.view.btnPlay.luaClick()
			self:onBtnPlay()
		end
	end
end

function PetTransmogVideoCtrl:onVideoSurfaceClick()
	local videoPlayer = self.view and self.view.videoPlayer

	if not videoPlayer then
		return
	end

	if videoPlayer.isPlaying and not videoPlayer.isPaused then
		videoPlayer:PauseVideo()
		self:refreshVideoButtonState(true)
	elseif videoPlayer.firstFrameReady and videoPlayer.isPaused then
		videoPlayer:ResumeVideo(false)
		self:refreshVideoButtonState(false)
	end
end

function PetTransmogVideoCtrl:onBtnPlay()
	local videoPlayer = self.view and self.view.videoPlayer

	if not videoPlayer or not videoPlayer.firstFrameReady or not videoPlayer.isPaused then
		return
	end

	videoPlayer:ResumeVideo(false)
	self:refreshVideoButtonState(false)
end

function PetTransmogVideoCtrl:refreshVideoButtonState(isPaused)
	if self.view and self.view.videoButton then
		self.view.videoButton:TryChangePage("State", isPaused and 1 or 0)
	end
end

function PetTransmogVideoCtrl:onShow()
	UICtrl.onShow(self)
	self:startVideo()
end

function PetTransmogVideoCtrl:getVideoUrl()
	local configuredUrl = self.model:getVideoUrl()

	if string.isNilOrEmpty(configuredUrl) then
		return nil
	end

	configuredUrl = string.gsub(configuredUrl, "\\", "/")

	if string.match(configuredUrl, "^https?://") then
		return configuredUrl
	end

	configuredUrl = string.gsub(configuredUrl, "^/+", "")
	configuredUrl = string.gsub(configuredUrl, "^public/video/m/", "")
	configuredUrl = string.gsub(configuredUrl, "^public/video/", "")

	local host = Utils.isOverseas() and ClientConst.SERVER_LIST.GLOBAL_HOST or ClientConst.SERVER_LIST.CN_HOST
	local videoPath = IS_MOBILE and "/public/video/m/" or "/public/video/"

	return "https://" .. host .. videoPath .. configuredUrl
end

function PetTransmogVideoCtrl:setVideoVisible(visible)
	local videoPlayer = self.view and self.view.videoPlayer

	if not videoPlayer then
		return
	end

	local color = videoPlayer.color

	videoPlayer.color = Color(color.r, color.g, color.b, visible and 1 or 0)
end

function PetTransmogVideoCtrl:isCurrentVideoRequest(requestSerial)
	return self.view and self.activeVideoRequestSerial == requestSerial and self.view.videoPlayer
end

function PetTransmogVideoCtrl:clearVideoLoadTimer()
	if not self.videoLoadTimer then
		return
	end

	self:killTimer(self.videoLoadTimer)

	self.videoLoadTimer = nil
end

function PetTransmogVideoCtrl:onVideoPrepared(requestSerial)
	if not self:isCurrentVideoRequest(requestSerial) then
		return
	end

	self.view.videoPlayer:PlayVideo()
end

function PetTransmogVideoCtrl:onVideoFirstFrameReady(requestSerial)
	if not self:isCurrentVideoRequest(requestSerial) then
		return
	end

	self:clearVideoLoadTimer()
	self:setVideoVisible(true)
	self:refreshVideoButtonState(false)
end

function PetTransmogVideoCtrl:onVideoLoadFailed(requestSerial)
	if not self:isCurrentVideoRequest(requestSerial) then
		return
	end

	self:stopVideo()
end

function PetTransmogVideoCtrl:startVideo()
	local videoPlayer = self.view and self.view.videoPlayer
	local videoUrl = self:getVideoUrl()

	if not videoPlayer or string.isNilOrEmpty(videoUrl) then
		return
	end

	self:stopVideo()
	videoPlayer.gameObject:SetActiveEx(true)

	self.videoRequestSerial = self.videoRequestSerial + 1

	local requestSerial = self.videoRequestSerial

	self.activeVideoRequestSerial = requestSerial

	self:setVideoVisible(false)
	self:refreshVideoButtonState(false)

	videoPlayer.videoLoop = true
	videoPlayer.autoPlay = false

	function videoPlayer.luaVideoPrepared()
		self:onVideoPrepared(requestSerial)
	end

	function videoPlayer.luaVideoFirstFrameReady()
		self:onVideoFirstFrameReady(requestSerial)
	end

	if videoPlayer.url == videoUrl then
		videoPlayer.url = ""
	end

	self.videoLoadTimer = self:startTimer(function()
		self.videoLoadTimer = nil

		self:onVideoLoadFailed(requestSerial)
	end, VIDEO_LOAD_TIMEOUT)

	videoPlayer:SetVideoUrlWithCallback(videoUrl, nil, function()
		self:onVideoLoadFailed(requestSerial)
	end)
end

function PetTransmogVideoCtrl:stopVideo()
	self:clearVideoLoadTimer()

	self.activeVideoRequestSerial = nil

	local videoPlayer = self.view and self.view.videoPlayer

	if not videoPlayer then
		return
	end

	videoPlayer.luaVideoPrepared = nil
	videoPlayer.luaVideoFirstFrameReady = nil

	self:setVideoVisible(false)
	self:refreshVideoButtonState(false)
	videoPlayer:StopVideo()
	videoPlayer:CloseVideo()
	videoPlayer.gameObject:SetActiveEx(false)
end

function PetTransmogVideoCtrl:onHide()
	self:stopVideo()
	UICtrl.onHide(self)
end

function PetTransmogVideoCtrl:onDestroy()
	self:stopVideo()
	UICtrl.onDestroy(self)
end

return PetTransmogVideoCtrl
