-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Screen.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Screen = Class.LightClass("Screen", LevelItem)
local ClientConst = require("Const.ClientConst")
local SandboxConst = require("Common.Const.SandboxConst")
local AdvertisingScreenData = require("Data.advertising_screen_data")
local AdvertisingContentData = require("Data.advertising_content_data")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local CallbackHandler = require("Core.Common.CallbackHandler")

function Screen:ctor(sandbox, spawnInfo, syncInfo)
	Screen.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.mainScreenId = 101
	self.subScreenId = 102
	self.defaultContentId = 1001
	self.lastVideoNames = {}
	self.lastVideoTimes = {}

	local isMobile = IS_MOBILE

	self.cdnHost = "https://" .. ClientConst.SERVER_LIST.CN_HOST .. "/public/video/"

	if isMobile then
		self.cdnHost = "https://" .. ClientConst.SERVER_LIST.CN_HOST .. "/public/video/m/"
	end

	if Utils.isOverseas() then
		self.cdnHost = "https://" .. ClientConst.SERVER_LIST.GLOBAL_HOST .. "/public/video/"

		if isMobile then
			self.cdnHost = "https://" .. ClientConst.SERVER_LIST.GLOBAL_HOST .. "/public/video/m/"
		end
	end

	for screenId, screenInfo in pairs(AdvertisingScreenData) do
		self.lastVideoNames[screenId] = ""
		self.lastVideoTimes[screenId] = 0
	end
end

function Screen:onSandboxReady()
	self.screenSB = self.shell.gameObject:GetComponent("ScreenSB")

	self:Refresh()

	if pg.me and pg.me.space and pg.me.space.registerScreenRefreshCallback then
		self.screenRefreshCallback = CallbackHandler(self, "refreshScreen")

		local eventName = pg.me.id .. SandboxConst.COMMON_EVENT.ARK_VIDEO_REFRESH

		pg.me.space:registerScreenRefreshCallback(self.screenRefreshCallback)
	end
end

function Screen:Refresh()
	if pg.me.arkScreenInfoMap then
		for screenId, screenInfo in pairs(pg.me.arkScreenInfoMap) do
			self:refreshScreen(screenId, screenInfo.contentId)
		end
	end
end

local _scaleVec3 = Vector3.one

function Screen:refreshScreen(screenId, contentId, skipVideoRefresh)
	local screenData = AdvertisingScreenData[screenId]
	local contentData = AdvertisingContentData[contentId]

	if not screenData or not contentData then
		return
	end

	if screenId == self.subScreenId then
		self.lastSubContentId = contentId
	end

	local scale = contentData.modelScale

	_scaleVec3:Set(scale, scale, scale)
	self.screenSB:InitScreen(screenId, contentData.restype, contentData.picRes, contentData.modelOffset, _scaleVec3)

	if skipVideoRefresh and screenId == self.mainScreenId then
		self.lastMainContentId = contentId

		return
	end

	if screenId == self.mainScreenId or contentData.restype == Const.ARK_SCREEN_CONTENT_TYPE.VEDIO then
		local screenInfo = pg.me.arkScreenInfoMap[screenId]
		local startTime = self:getStartTime(screenInfo.contentBeginTime)

		if contentData.videoRes and contentData.videoRes ~= "" or contentData.videoUrl and contentData.videoUrl ~= "" then
			local audioRes = contentData.audioRes

			audioRes = audioRes or ""

			local videoRes = contentData.videoRes
			local isUrl = false

			if contentData.videoUrl and contentData.videoUrl ~= "" then
				videoRes = self.cdnHost .. contentData.videoUrl
				isUrl = true

				local localPath = self.screenSB:EnsureLocalVideo(videoRes)

				if localPath then
					videoRes = localPath
				else
					if self.lastSubContentId then
						if self.lastMainContentId == self.lastSubContentId then
							return
						end

						self:refreshScreen(self.mainScreenId, self.lastSubContentId, true)
					else
						if self.lastMainContentId == self.defaultContentId then
							return
						end

						self:refreshScreen(self.mainScreenId, self.defaultContentId, true)
					end

					return
				end
			end

			self:play(screenId, videoRes, audioRes, startTime, isUrl)
		end
	end
end

function Screen:onVideoDownload()
	for screenId, screenInfo in pairs(pg.me.arkScreenInfoMap) do
		if screenId == self.mainScreenId then
			self:refreshScreen(screenId, screenInfo.contentId)

			return
		end
	end
end

function Screen:play(screenId, videoName, audioName, startTime, isUrl)
	self.screenSB:Play(screenId, videoName, audioName, startTime, isUrl)
end

function Screen:getStartTime(contentBeginTime)
	local startTime = Time.secondCache - contentBeginTime

	if startTime < 0 then
		startTime = 0
	end

	return startTime
end

function Screen:destroy()
	if pg.me and pg.me.space and pg.me.space.removeScreenRefreshCallback and self.screenRefreshCallback then
		pg.me.space:removeScreenRefreshCallback(self.screenRefreshCallback)
	end

	Screen.super.destroy(self)
end

return Screen
