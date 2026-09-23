-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Lottery\\Component\\LotteryRewardComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("LotteryRewardComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local AudioConst = require("Const.AudioConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LotteryRewardComponent = Class.LightClass("LotteryRewardComponent", UIComponent)

function LotteryRewardComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtTitle2 = objectReference:GetRefValue("txtTitle2")
	self.txtTitleNum = objectReference:GetRefValue("txtTitleNum")
	self.listTab = objectReference:GetRefValue("listTab")
	self.txtHeadFrame = objectReference:GetRefValue("txtHeadFrame")
	self.imgHeadFrame = objectReference:GetRefValue("imgHeadFrame")
	self.txtHead = objectReference:GetRefValue("txtHead")
	self.imgHead = objectReference:GetRefValue("imgHead")
	self.txtMusic = objectReference:GetRefValue("txtMusic")
	self.musicBtn = objectReference:GetRefValue("musicBtn")
	self.txtMusicBtn = objectReference:GetRefValue("txtMusicBtn")
	self.videoPlayer = objectReference:GetRefValue("videoPlayer")
	self.videoPlayerX = objectReference:GetRefValue("videoPlayerX")
	self.rawImage = objectReference:GetRefValue("rawImage")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnHead = objectReference:GetRefValue("btnHead")
	self.btnHeadFrame = objectReference:GetRefValue("btnHeadFrame")
	self.btnVideoUButton = objectReference:GetRefValue("btnVideoUButton")
end

function LotteryRewardComponent:registerObjects()
	function self.listTab.luaRenderItem(button, index, data)
		self:renderTab(button, index, data)
	end

	function self.listTab.luaClick(button, data)
		self:selectTab(data)
	end

	function self.musicBtn.luaClick()
		self:toggleMusic()
	end

	if self.btnClose then
		function self.btnClose.luaClick()
			self.ctrl:closeRewardContainer()
		end
	end

	if self.btnHead then
		function self.btnHead.luaClick()
			self:openItemDetail(self._info and self._info.head or nil, self.btnHead)
		end
	end

	if self.btnHeadFrame then
		function self.btnHeadFrame.luaClick()
			self:openItemDetail(self._info and self._info.headFrame or nil, self.btnHeadFrame)
		end
	end

	if self.btnVideoUButton then
		function self.btnVideoUButton.luaClick()
			self:toggleVideo()
		end
	end

	if self.videoPlayerX then
		local _ = self.videoPlayerX.isPlaying

		self.videoPlayerX.luaLoopEnd = CallbackHandler(self, "onVideoCompleted")
	end

	local lotteryCtrl = self.ctrl and self.ctrl.ctrl

	if lotteryCtrl and lotteryCtrl.addNavFocusListener then
		lotteryCtrl:addNavFocusListener(CallbackHandler(self, "refreshConsoleBarState"), "LotteryRewardMedia")
	end
end

function LotteryRewardComponent:initView()
	ClientTextUtils.setText(self.txtTitle, pg.getGameString("LOTTERY_REWARD_TITLE"))
	ClientTextUtils.setText(self.txtTitle2, pg.getGameString("LOTTERY_REWARD_TITLE2"))
	ClientTextUtils.setText(self.txtHeadFrame, pg.getGameString("LOTTERY_REWARD_HEAD"))
	ClientTextUtils.setText(self.txtHead, pg.getGameString("LOTTERY_REWARD_HEAD_FRAME"))
	ClientTextUtils.setText(self.txtMusic, pg.getGameString("LOTTERY_REWARD_BGM"))

	self._videoPlaying = false
	self._videoPaused = false

	self:setVideoButtonPlaying(false)
	self:setMusicPlaying(false)
	self:setMediaVisible(false, false)
end

function LotteryRewardComponent:openItemDetail(itemId, targetRect)
	itemId = tonumber(itemId)

	if not itemId or not targetRect then
		return
	end

	LuaUIUtils.onRewardItemClick(targetRect, {
		num = 1,
		id = itemId
	}, false)
end

function LotteryRewardComponent:getDisplayText(value)
	if type(value) == "number" then
		return pg.getLocalizationText(value)
	end

	return value or ""
end

function LotteryRewardComponent:setMusicPlaying(playing)
	self._musicPlaying = playing == true

	self.musicBtn:SetSelected(self._musicPlaying)
	self:refreshConsoleBarState()
end

function LotteryRewardComponent:refreshConsoleBarState()
	local consoleBar = CS.XGUI.Navigation.ConsoleBar

	if not consoleBar or not consoleBar.SetStateForAll then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance
	local focusedItem = navMgr and navMgr.CurrentFocusedUContent or nil
	local focusOnVideo = self:checkUIShow() and self.btnVideoUButton and focusedItem == self.btnVideoUButton
	local focusOnMusic = self:checkUIShow() and self.musicBtn and focusedItem == self.musicBtn
	local mediaSelected = focusOnVideo or focusOnMusic
	local mediaPlaying = focusOnVideo and self._videoPlaying == true and not self._videoPaused or focusOnMusic and self._musicPlaying == true

	consoleBar.SetStateForAll("Video", not not focusOnVideo)
	consoleBar.SetStateForAll("Music", not not focusOnMusic)
	consoleBar.SetStateForAll("Stop", not not mediaSelected and not not mediaPlaying)
	consoleBar.SetStateForAll("Start", not not mediaSelected and not not not mediaPlaying)
end

function LotteryRewardComponent:toggleMusic()
	if self._musicPlaying then
		self:stopMusic()
	else
		self:playMusic()
	end
end

function LotteryRewardComponent:playMusic()
	local bgm = self._info and self._info.bgm or nil

	if type(bgm) ~= "string" or bgm == "" then
		return
	end

	pg.game.audio:playBgm(bgm, AudioConst.BgmPriority.UI)
	self:setMusicPlaying(true)
	self:pauseVideo()
end

function LotteryRewardComponent:stopMusic()
	if not self._musicPlaying then
		self:setMusicPlaying(false)

		return
	end

	local originalBgm = self._info and self._info.originalBgm or nil

	if type(originalBgm) == "string" and originalBgm ~= "" then
		pg.game.audio:playBgm(originalBgm, AudioConst.BgmPriority.UI)
	else
		pg.game.audio:stopBgm(AudioConst.BgmPriority.UI)
	end

	self:setMusicPlaying(false)
end

function LotteryRewardComponent:setInfo(info)
	if not Utils.isTable(info) then
		return
	end

	self._info = info
	self._tabList = Utils.isTable(info.tabList) and info.tabList or {}

	ClientTextUtils.setText(self.txtTitleNum, string.format("%d/%d", info.acquiredCount or 0, info.totalCount or 0))
	ClientTextUtils.setText(self.txtMusicBtn, self:getDisplayText(info.suitName))

	self.imgHead.url = info.head and LuaUIUtils.getIconByItemId(info.head) or ""
	self.imgHeadFrame.url = info.headFrame and LuaUIUtils.getIconByItemId(info.headFrame) or ""

	self.listTab:SetList(self._tabList)

	self._selectedTab = self._tabList[1]

	if self._selectedTab then
		self.listTab:SelectItem(0, false)
	else
		self:stopVideo()

		self.rawImage.url = ""

		self:setMediaVisible(false, false)
	end

	if self:checkUIShow() then
		self:refreshSelectedMedia()
	end
end

function LotteryRewardComponent:renderTab(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")

	ClientTextUtils.setText(txtTitle, pg.getGameString(data.titleKey))
	button:SetSelected(self._selectedTab and self._selectedTab.type == data.type)
	button:TryChangePage("Line", index + 1 == #(self._tabList or {}) and 1 or 0)
end

function LotteryRewardComponent:selectTab(data)
	if not Utils.isTable(data) then
		return
	end

	local tabChanged = not self._selectedTab or self._selectedTab.type ~= data.type

	if tabChanged and self._musicPlaying then
		self:stopMusic()
	end

	self._selectedTab = data

	self.listTab:RefreshList()
	self:refreshSelectedMedia()
end

function LotteryRewardComponent:setMediaVisible(videoVisible, imageVisible)
	self.videoPlayer.gameObject:SetActiveEx(videoVisible)
	self.rawImage.gameObject:SetActiveEx(imageVisible)
end

function LotteryRewardComponent:setVideoButtonPlaying(playing)
	if self.btnVideoUButton then
		self.btnVideoUButton:TryChangePage("videobtn", playing == true and 1 or 0)
	end
end

function LotteryRewardComponent:onVideoCompleted()
	if not self._videoPlaying then
		return
	end

	self.videoPlayer:Pause()

	self._videoPaused = true

	self:setVideoButtonPlaying(false)
	self:refreshConsoleBarState()
end

function LotteryRewardComponent:stopVideo()
	if self.videoPlayer then
		self.videoPlayer:Close()
	end

	self._videoPlaying = false
	self._videoPaused = false

	self:setVideoButtonPlaying(false)
	self:refreshConsoleBarState()
end

function LotteryRewardComponent:playVideo(tabData)
	if not self.videoPlayer or not Utils.isTable(tabData) or tabData.mediaType ~= "video" or type(tabData.resource) ~= "string" or tabData.resource == "" then
		self:setVideoButtonPlaying(false)

		return false
	end

	local success = self.videoPlayer:Play(tabData.resource, false)

	self._videoPlaying = success ~= false
	self._videoPaused = false

	self:setVideoButtonPlaying(self._videoPlaying)
	self:refreshConsoleBarState()

	if not self._videoPlaying then
		logger:error("抽奖奖励预览视频播放失败, type=%s, resource=%s", tostring(tabData.type), tostring(tabData.resource))
	end

	return self._videoPlaying
end

function LotteryRewardComponent:pauseVideo()
	if not self.videoPlayer or not self._videoPlaying or self._videoPaused then
		return false
	end

	self.videoPlayer:Pause()

	self._videoPaused = true

	self:setVideoButtonPlaying(false)
	self:refreshConsoleBarState()

	return true
end

function LotteryRewardComponent:restartVideo(tabData)
	if not self.videoPlayer then
		return
	end

	self:stopVideo()
	self:playVideo(tabData)
end

function LotteryRewardComponent:toggleVideo()
	local tabData = self._selectedTab

	if not Utils.isTable(tabData) or tabData.mediaType ~= "video" then
		return
	end

	if self._musicPlaying then
		self:stopMusic()
	end

	if not self._videoPlaying then
		self:playVideo(tabData)
	elseif self._videoPaused then
		self:restartVideo(tabData)
	else
		self:pauseVideo()
	end
end

function LotteryRewardComponent:refreshSelectedMedia()
	local tabData = self._selectedTab

	if not Utils.isTable(tabData) then
		self:stopVideo()
		self:setMediaVisible(false, false)

		return
	end

	if tabData.mediaType == "video" then
		self.rawImage.url = ""

		self:stopVideo()
		self:setMediaVisible(true, false)
		self:playVideo(tabData)
	else
		self:stopVideo()
		self:setMediaVisible(false, true)

		self.rawImage.url = tabData.resource
	end

	self:refreshConsoleBarState()
end

function LotteryRewardComponent:onShow()
	self:refreshSelectedMedia()
	self:refreshConsoleBarState()
end

function LotteryRewardComponent:onHide()
	self:stopVideo()
	self:stopMusic()
	self:refreshConsoleBarState()
end

function LotteryRewardComponent:onDestroy()
	if self.videoPlayerX then
		self.videoPlayerX.luaLoopEnd = nil
	end

	self:stopVideo()
	self:stopMusic()

	if self.rawImage then
		self.rawImage.url = ""
	end

	UIComponent.onDestroy(self)
end

return LotteryRewardComponent
