-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoadProgress\\LoadProgressCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local LoadProgressCtrl = Class.LightClass("LoadProgressCtrl", UICtrl)
local LevelData = require("Data.level_data")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local TipsData = require("Data.load_tips_data")
local ClientUtils = require("Utils.ClientUtils")
local AudioConst = require("Const.AudioConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")

LoadProgressCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamLoadingInfo",
		true
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"refreshTeamLoadingInfo",
		true
	}
}

function LoadProgressCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.refreshTimer = nil
	self.curIndex = 0
	self.showContextLastTime = 0
	self.deltaTime = 0.03
	self.oldProgress = 0

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderTeamMemberItem(button, index, data)
	end
end

function LoadProgressCtrl:showNextContext()
	self.curIndex = self.curIndex + 1

	if self.curIndex > #self.loadList then
		self.curIndex = 1
	end

	self:onRefreshContext(self.curIndex)

	self.showContextLastTime = Time.getTickSecond()
end

function LoadProgressCtrl:startLoading()
	self.ticId = TimerManager.addRepeatTimer(self.deltaTime, function()
		local progress = pg.game.loading:getProgress()

		self:setProgress(progress)

		if self.loadList and Time.getTickSecond() - self.showContextLastTime > self.loadList[self.curIndex].DurationTime then
			self:showNextContext()
		end
	end)

	local progress = 0

	self:setProgress(progress)
	self:showNextContext()
end

function LoadProgressCtrl:setProgress(progress)
	if not progress or progress < self.oldProgress then
		return
	end

	if pg.game.loading.curSceneId == ClientConst.SCENE_LOADING_ID or pg.game.loading.curSceneId == ClientConst.SCENE_LOGIN_ID then
		return
	end

	if progress >= 1 then
		progress = 1
		self.oldProgress = 0

		TimerManager.removeTimer(self.ticId)

		self.ticId = nil
	end

	self.oldProgress = progress

	if self.view ~= nil then
		ClientTextUtils.setText(self.view.progressNum, tostring(math.modf(progress * 100)) .. "%")

		if self.view.progressLoad then
			self.view.progressLoad.value = tonumber(progress)
		end
	end
end

function LoadProgressCtrl:onRefreshContext(index)
	if not self.ticId then
		return
	end

	if self.loadList[index] == nil then
		return
	end

	local imageRes = self.loadList[index].panelAddress
	local randIdx = math.random(#imageRes)

	self:updateBgUrl(imageRes[randIdx])
	ClientTextUtils.setText(self.view.titleText, pg.getLocalizationText(self.loadList[index].TitleText))
	ClientTextUtils.setText(self.view.detailText, pg.getLocalizationText(self.loadList[index].DescribeTxt))
end

function LoadProgressCtrl:updateBgUrl(url)
	if self.bgUrl == url then
		return
	end

	self.bgUrl = url
	self.view.background.url = url
end

function LoadProgressCtrl:LoadProgress(val)
	self.view:progressValue(val)
end

function LoadProgressCtrl:disableSound()
	pg.game.audio:setVolume(AudioConst.VolumeType.Sfx, 0, AudioConst.SetVolumeReason.Loading)
	pg.game.audio:setVolume(AudioConst.VolumeType.Vox, 0, AudioConst.SetVolumeReason.Loading)
	pg.game.audio:playBgm("None", AudioConst.BgmPriority.Loading)
end

function LoadProgressCtrl:resetSound()
	pg.game.audio:setVolume(AudioConst.VolumeType.Sfx, nil, AudioConst.SetVolumeReason.Loading)
	pg.game.audio:setVolume(AudioConst.VolumeType.Vox, nil, AudioConst.SetVolumeReason.Loading)
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Loading)
end

function LoadProgressCtrl:onHide()
	pg.global.ui:enableMainCamera(true)
	self:resetSound()
	self:setIsModel(false)

	self.view.progressNum.text = "0%"

	self:updateBgUrl(nil)

	if self.view.progressLoad then
		self.view.progressLoad.value = 0
	end

	self.view.teamUWidget:SetActive(false)
	self.view.listUList:SetList({})

	self.oldProgress = 0

	TimerManager.removeTimer(self.ticId)

	self.ticId = nil

	if pg.space and pg.space:isRogueEnv() then
		pg.space:resumeCacheInfo()
	end

	UICtrl.onHide(self)
end

function LoadProgressCtrl:onShow()
	self:refreshLoadingList()
	self:disableSound()
	self:setIsModel(true)

	self.view.progressNum.text = "0%"

	if self.view.progressLoad then
		self.view.progressLoad.value = 0
	end

	self:refreshTeamLoadingInfo()
	UICtrl.onShow(self)
	self:startLoading()
	pg.global.ui:enableMainCamera(false)
	facade:sendMsgToSystem(MessageName.ON_LOADING_PANEL_SHOW)
end

function LoadProgressCtrl:OnDestroy()
	self:updateBgUrl(nil)
	TimerManager.removeTimer(self.ticId)

	self.ticId = nil
end

function LoadProgressCtrl:onInputDeviceChanged()
	self:showNextContext()
end

function LoadProgressCtrl:refreshTeamLoadingInfo()
	if not self.view then
		return
	end

	local data = self:getTeamLoadingMemberData()
	local showTeamInfo = data ~= nil and #data > 0

	self.view.teamUWidget:SetActive(showTeamInfo)
	self.view.listUList:SetList(data or {})
end

function LoadProgressCtrl:checkShowTeamLoadingInfo()
	if not pg.me or not pg.me:isInTeam() then
		return false
	end

	local sceneId = pg.global.scene and pg.global.scene.targetSceneId or nil
	local levelConfig = sceneId and LevelData[sceneId] or nil

	return levelConfig and levelConfig.playerNumMax and levelConfig.playerNumMax > 1
end

function LoadProgressCtrl:getTeamLoadingMemberData()
	if not self:checkShowTeamLoadingInfo() then
		return nil
	end

	local teamInfo = pg.me:getShowTeamInfo()

	if not teamInfo or not teamInfo.sortList then
		return nil
	end

	local data = {}

	for index, uid in ipairs(teamInfo.sortList) do
		data[#data + 1] = {
			tIndex = 0,
			uid = uid,
			order = index,
			playerInfo = teamInfo.membersInfo and teamInfo.membersInfo[uid]
		}
	end

	return data
end

function LoadProgressCtrl:getPlayerInfo(uid, playerInfo)
	if playerInfo then
		return playerInfo
	end

	if pg.me and uid == pg.me.uid then
		return {
			uid = pg.me.uid,
			playerName = pg.me.playerName,
			headIcon = pg.me.headIcon,
			headFrame = pg.me.headFrame,
			level = pg.me.level
		}
	end

	if pg.game and pg.game.chat then
		return pg.game.chat:getPlayerInfo(uid)
	end
end

function LoadProgressCtrl:renderTeamMemberItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local playerHeadUContainer = objectReference:GetRefValue("playerHeadUContainer")
	local titleIconUImage = objectReference:GetRefValue("titleIconUImage")
	local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	local btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
	local playerInfo = self:getPlayerInfo(data.uid, data.playerInfo)

	button.luaClick = nil
	button.tooltipMode = 0

	button:TryChangePage("Empty", 0)
	button:TryChangePage("Captain", 0)
	button:TryChangePage("Position", math.max(math.min(data.order or index or 1, 4), 1) - 1)

	if btnInviteUButton then
		btnInviteUButton.luaClick = nil
	end

	if titleIconUImage then
		titleIconUImage:SetActive(true)
	end

	ClientTextUtils.setText(textLvUSDFText, playerInfo and playerInfo.level or "")
	self:renderTeamMemberName(button, data.uid, playerInfo)

	if playerHeadUContainer then
		playerHeadUContainer:SetActive(playerInfo ~= nil)
	end

	if playerInfo then
		self:renderPlayerHead(playerHeadUContainer, data.uid, playerInfo)
	end
end

function LoadProgressCtrl:renderTeamMemberName(button, uid, playerInfo)
	local textTransform = button.transform:Find("Text")

	if not textTransform then
		return
	end

	local nameText = textTransform:GetComponent("USDFText")

	if not nameText then
		return
	end

	local playerName = playerInfo and playerInfo.playerName or ""
	local displayName = LuaUIUtils.getPlayerDisplayName(uid, playerName, true)
	local hooks = LoadProgressCtrl._platformHooks

	displayName = hooks and hooks.resolveTeamMemberDisplayName and hooks.resolveTeamMemberDisplayName(self, uid, playerInfo, displayName) or displayName

	ClientTextUtils.setText(nameText, displayName or playerName or "")
end

function LoadProgressCtrl:renderPlayerHead(playerHeadUContainer, uid, playerInfo)
	if not playerHeadUContainer then
		return
	end

	if playerHeadUContainer:CheckURLLoaded() then
		self:renderLoadedPlayerHead(playerHeadUContainer.content, uid, playerInfo)
	else
		playerHeadUContainer:LoadDefaultUrlManually(function(content)
			self:renderLoadedPlayerHead(content, uid, playerInfo)
		end)
	end
end

function LoadProgressCtrl:renderLoadedPlayerHead(content, uid, playerInfo)
	if not content or IsNil(content) then
		return
	end

	LuaUIUtils.renderPlayerAvatarImages(content, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})
end

function LoadProgressCtrl:refreshLoadingList()
	local loadList = {}
	local sceneId = pg.global.scene.targetSceneId
	local playerLevel = pg.me and pg.me.level
	local levelConfig = LevelData[sceneId]

	if levelConfig and levelConfig.loadingID then
		local tipData = self:getShowData(TipsData[levelConfig.loadingID], levelConfig.loadingID)

		loadList[#loadList + 1] = tipData
		self.loadList = loadList

		return
	end

	local fallbackList = {}

	for kid, tipInfo in pairs(TipsData) do
		local levelRange = tipInfo.level
		local levelIsSatisfy = true

		if #levelRange == 2 and (not playerLevel or playerLevel < levelRange[1] or playerLevel > levelRange[2]) then
			levelIsSatisfy = false
		end

		if levelIsSatisfy then
			if #tipInfo.map == 0 then
				local tipData = self:getShowData(tipInfo, kid)

				if tipData then
					fallbackList[#fallbackList + 1] = tipData
				end
			else
				for k, scene in pairs(tipInfo.map) do
					if scene == sceneId or sceneId == ClientConst.SCENE_INIT_ID or sceneId == ClientConst.SCENE_LOGIN_ID then
						local tipData = self:getShowData(tipInfo, kid)

						if tipData then
							loadList[#loadList + 1] = tipData
						end
					end
				end
			end
		end
	end

	if #loadList == 0 then
		loadList = fallbackList
	end

	self.loadList = self:shuffle(loadList)
end

function LoadProgressCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function LoadProgressCtrl:getShowData(tipInfo, id)
	if ClientUtils.checkIsOpenToCurPlatform(tipInfo) then
		local tableData = {
			weight = tipInfo.weight,
			panelAddress = tipInfo.image,
			TitleText = tipInfo.button,
			DescribeTxt = tipInfo.txt,
			DurationTime = tipInfo.displayTime,
			id = id
		}

		return tableData
	end
end

function LoadProgressCtrl:shuffle(t)
	if type(t) ~= "table" then
		return
	end

	local tab = {}

	while #t ~= 0 do
		local totalWeight = 0

		for _, v in ipairs(t) do
			totalWeight = totalWeight + v.weight
		end

		local rand = math.random() * totalWeight
		local sum = 0

		for index, data in ipairs(t) do
			sum = sum + data.weight

			if rand <= sum then
				tab[#tab + 1] = data

				table.remove(t, index)

				break
			end
		end
	end

	return tab
end

return LoadProgressCtrl
