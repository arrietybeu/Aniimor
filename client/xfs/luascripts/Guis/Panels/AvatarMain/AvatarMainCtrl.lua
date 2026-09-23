-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarMain\\AvatarMainCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UICtrl = require("Guis.UICtrl")
local AvatarPresetData = require("Data.avatar_preset_data")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local FeedLogin = require("GameApp.Feed.FeedLogin")
local AvatarMainCtrl = Class.LightClass("AvatarMainCtrl", UICtrl)
local FEED_TRIAL_DURATION = 180

AvatarMainCtrl.messages = {}

function AvatarMainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isFeedTrial = info and info.isFeedTrial == true
	self.forcePresetKey = info and info.forcePresetKey
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	pg.game.avatar.createPlayerSceneBgId = nil
end

function AvatarMainCtrl:closePanel()
	if self.isOpenAvatarPanel then
		return
	end

	if self.isFeedTrial then
		return
	end

	pg.global.avatarMgr:ClearAvatar()
	pg.game.avatar:setFusionData()
	UICtrl.closePanel(self)

	pg.game.avatar.jumpToCreateRoleTimelineEnd = true

	pg.global.ui.createRoleTimeline:showPreparedTimeline(self.forcePresetKey)
end

function AvatarMainCtrl:addListener()
	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	function self.view.tab1UButton.luaClick()
		if not self.tabSimulateClick and self.avatarScene:reachMinZoom() then
			self.avatarScene.cameraDuration = 0.05
		end

		self:refreshModelList(self.model.GENDER.BOY)
		self:selectFirstModel()
	end

	function self.view.tab2UButton.luaClick()
		if not self.tabSimulateClick and self.avatarScene:reachMinZoom() then
			self.avatarScene.cameraDuration = 0.05
		end

		self:refreshModelList(self.model.GENDER.GIRL)
		self:selectFirstModel()
	end

	function self.view.presetUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.icon
	end

	function self.view.presetUList.luaClick(button, data)
		if not self.avatarScene:isSameEntity(data.presetKey) then
			local function inner()
				self.avatarScene:showAvatarTemplate(data.presetKey, function()
					self.avatarScene:setCurEntityRot(0)
					self.avatarScene:setAvatarCameraModeCloseHead()

					self.avatarScene.cameraDuration = 1
				end)
				pg.game.avatar:setFusionData()

				AvatarUtils.hairAssetIdRecord = nil

				self.view.root:TryChangePage("State", 0)
			end

			local fusionData = pg.game.avatar:getFusionData()

			if fusionData then
				local hintShow = pg.global.prefsCacheUtils:getBool("fusionCoverage", true, ClientConst.CACHE_TYPE_FLAG.USER)

				if hintShow then
					pg.global.showConfirmMsgRaw(pg.getGameString("FUSION_AVATAR_TIP_7"), pg.getGameString("FUSION_AVATAR_TIP_8"), function()
						if self.hintHideFlag then
							pg.global.prefsCacheUtils:setBool("fusionCoverage", false, ClientConst.CACHE_TYPE_FLAG.USER)
							pg.global.prefsCacheUtils:save()
						end

						inner()
					end, nil, function()
						local presetKey = self.avatarScene:getCurEntityId()

						self:selectModelPreset(presetKey, true)
					end, nil, nil, {
						hint = true,
						hintDesc = pg.getGameString("FUSION_AVATAR_TIP_9"),
						hintCb = function(isSelected)
							if isSelected then
								self.hintHideFlag = true
							else
								self.hintHideFlag = nil
							end
						end
					})
				else
					inner()
				end
			else
				inner()
			end
		end
	end

	function self.view.nextUButton.luaClick()
		local presetKey = self.avatarScene:getCurEntityId()

		if presetKey then
			self.isOpenAvatarPanel = true

			pg.global.ui:open(UIConst.UI_ID_AVATAR, {
				presetKey = presetKey,
				isFeedTrial = self.isFeedTrial
			}, function()
				self.isOpenAvatarPanel = false
			end)
		end
	end

	function self.view.btnFusionUButton.luaClick()
		local globalStack = pg.global.avatarMgr.globalStack

		if globalStack:CanBackward() or globalStack:CanForward() then
			pg.global.showConfirmMsgRaw(pg.getGameString("FUSION_AVATAR_TIP_4"), pg.getGameString("FUSION_AVATAR_TIP_5"), function()
				local presetKey = self.avatarScene:getCurEntityId()

				self.avatarScene:showAvatarTemplate(presetKey, function()
					self.avatarScene:setCurEntityRot(0)
				end, nil, true)
				pg.game.avatar:setFusionData()

				AvatarUtils.hairAssetIdRecord = nil

				local fusionData = pg.game.avatar:getFusionData()

				pg.global.ui:open(UIConst.UI_ID_AVATAR_FUSION, {
					presetKey = presetKey,
					fusionData = fusionData,
					backFunc = function()
						fusionData = pg.game.avatar:getFusionData()

						self.view.root:TryChangePage("State", fusionData and 1 or 0)
					end
				})
			end)
		else
			local presetKey = self.avatarScene:getCurEntityId()
			local fusionData = pg.game.avatar:getFusionData()

			pg.global.ui:open(UIConst.UI_ID_AVATAR_FUSION, {
				presetKey = presetKey,
				fusionData = fusionData,
				backFunc = function()
					fusionData = pg.game.avatar:getFusionData()

					self.view.root:TryChangePage("State", fusionData and 1 or 0)
				end
			})
		end
	end

	if not pg.me then
		self.view.backgroundSelectorUSelector:SetActiveFastest(false)
	else
		AvatarUtils.renderBackGroundSwitchSelector(self.view.backgroundSelectorUSelector, true)
	end
end

function AvatarMainCtrl:onDestroy()
	self:stopFeedTrialTimer()
	UICtrl.onDestroy(self)

	self.avatarScene = nil
end

function AvatarMainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.isFeedTrial = info and info.isFeedTrial == true
	self.forcePresetKey = info and info.forcePresetKey

	if self.isFeedTrial then
		self:startFeedTrialTimer()
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("AVATAR_ENTRANCE_TITLE"))
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)

	pg.game.avatar.createRoleStartTime = Time.realSecondCache

	local fromGenderSelection = info.fromCreateVideo ~= nil

	if not AvatarUtils.hasCustomDataInDisk() or fromGenderSelection then
		if fromGenderSelection then
			pg.game.avatar:setFusionData()
		end

		if fromGenderSelection then
			-- block empty
		end

		local forcePresetKey = info.forcePresetKey

		self:refreshPage(forcePresetKey, info.fromCreateVideo)
	else
		local autoSaveData = AvatarUtils.loadCustomDataFromDisk()

		if info.forcePresetKey and info.forcePresetKey ~= autoSaveData.presetKey then
			AvatarUtils.clearCustomDataFromDisk()
			self:refreshPage(info.forcePresetKey, info.fromCreateVideo)
		else
			pg.global.ui:open(UIConst.UI_ID_AVATAR_TIP, {
				autoSaveData = autoSaveData,
				desc = pg.getGameString("CREATE_PLAYER_CONTINUE"),
				isFeedTrial = self.isFeedTrial,
				cancelCb = function()
					pg.game.avatar:setFusionData()

					if self.isFeedTrial then
						self:refreshPage(info.forcePresetKey, info.fromCreateVideo)

						return
					end

					if pg.global.ui:checkUIOpen(UIConst.UI_ID_AVATAR) then
						pg.global.ui:close(UIConst.UI_ID_AVATAR)
					end

					self:closePanel()
				end,
				confirmCb = function()
					if autoSaveData.fusionData then
						pg.game.avatar:setFusionData(autoSaveData.fusionData)
						self.view.root:TryChangePage("State", 1)
					else
						pg.game.avatar:setFusionData()
						self.view.root:TryChangePage("State", 0)
					end

					self:refreshSelectState(autoSaveData.presetKey)

					if info.forcePresetKey then
						self:forbidChangeModel()
					end
				end
			})
		end
	end
end

function AvatarMainCtrl:startFeedTrialTimer()
	if self.feedTrialTimer then
		return
	end

	self.feedTrialTimer = TimerManager.addTimer(FEED_TRIAL_DURATION, function()
		self.feedTrialTimer = nil

		self:showFeedTrialTimeoutConfirm()
	end)
end

function AvatarMainCtrl:stopFeedTrialTimer()
	if not self.feedTrialTimer then
		return
	end

	TimerManager.removeTimer(self.feedTrialTimer)

	self.feedTrialTimer = nil
end

function AvatarMainCtrl:showFeedTrialTimeoutConfirm()
	FeedLogin.showFinishConfirm(function()
		self:confirmFinishFeedTrial()
	end)
end

function AvatarMainCtrl:confirmFinishFeedTrial()
	self:stopFeedTrialTimer()
	AvatarUtils.saveCustomDataToDisk(self.avatarScene:getCurEntityId())
	pg.global.ui.avatarLoading:open()

	if not FeedLogin.login(true) then
		pg.global.ui.avatarLoading:close()
	end
end

function AvatarMainCtrl:onShow()
	return
end

function AvatarMainCtrl:onHide()
	return
end

function AvatarMainCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
		self.view.transform.gameObject:SetActiveEx(true)
	else
		self.avatarScene:unRegisterGesture(self.uid)
		self.view.transform.gameObject:SetActiveEx(false)
	end
end

function AvatarMainCtrl:refreshPage(forcePresetKey, fromCreateVideo)
	if forcePresetKey then
		self:selectModelPreset(forcePresetKey)
		self:forbidChangeModel()
	else
		self.tabSimulateClick = true

		if fromCreateVideo == 1 then
			self.view.tab1UButton:OnClickSimulate()
		elseif fromCreateVideo == 2 then
			self.view.tab2UButton:OnClickSimulate()
		else
			self.view.tab1UButton:OnClickSimulate()
		end

		self.tabSimulateClick = nil
	end
end

function AvatarMainCtrl:forbidChangeModel()
	function self.view.tab1UButton.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("AVATAR_EXIST"), 3)
	end

	function self.view.tab2UButton.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("AVATAR_EXIST"), 3)
	end

	function self.view.presetUList.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("AVATAR_EXIST"), 3)
	end
end

function AvatarMainCtrl:selectModelPreset(presetKey, ignoreBtnClick)
	local presetData = pg.game.avatar:getAvatarPresetData(presetKey) or {}
	local body = presetData.body

	if body == self.model.GENDER.BOY and not ignoreBtnClick then
		self.tabSimulateClick = true

		self.view.tab1UButton:OnClickSimulate()

		self.tabSimulateClick = nil
	elseif body == self.model.GENDER.GIRL and not ignoreBtnClick then
		self.tabSimulateClick = true

		self.view.tab2UButton:OnClickSimulate()

		self.tabSimulateClick = nil
	end

	local isFound = false
	local list = self.model:getPresetList(body)

	for index, presetInfo in ipairs(list) do
		if presetInfo.presetKey == presetKey then
			isFound = true

			local presetRes, presetBtn = self.view.presetUList:TryGetChildAt(index - 1)

			if presetRes and not ignoreBtnClick then
				presetBtn:OnClickSimulate()
			end

			if ignoreBtnClick then
				presetBtn.isSelected = true
			end
		end
	end

	if not isFound and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(string.format("presetKey = %s cannot fount in list", presetKey))
	end
end

function AvatarMainCtrl:refreshSelectState(presetKey)
	local presetData = pg.game.avatar:getAvatarPresetData(presetKey) or {}
	local body = presetData.body

	self:refreshModelList(body)

	if body == self.model.GENDER.BOY then
		self.view.tab1UButton.isSelected = true
		self.view.tab2UButton.isSelected = false
	elseif body == self.model.GENDER.GIRL then
		self.view.tab1UButton.isSelected = false
		self.view.tab2UButton.isSelected = true
	end

	local list = self.model:getPresetList(body)

	for index, presetInfo in ipairs(list) do
		if presetInfo.presetKey == presetKey then
			self.view.presetUList:SelectItem(index - 1, false)

			break
		end
	end
end

function AvatarMainCtrl:refreshModelList(body)
	self.view.root:TryChangePage("Gender", body == self.model.GENDER.GIRL and 1 or 0)

	local list = self.model:getPresetList(body)

	self.view.presetUList:SetList(list)
end

function AvatarMainCtrl:selectFirstModel()
	local presetRes, presetBtn = self.view.presetUList:TryGetChildAt(0)

	if presetRes then
		presetBtn:OnClickSimulate()
	end
end

function AvatarMainCtrl:checkSkipBgmAttenuation()
	return true
end

return AvatarMainCtrl
