-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CITipArea\\TeamInviteItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local HotkeyConst = require("Const.HotkeyConst")
local AudioConst = require("Const.AudioConst")
local LevelData = require("Data.level_data")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local FriendSourceData = require("Data.friend_source_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local TeamInviteItem = Class.LightClass("TeamInviteItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local RobEggInviteType = 7
local CancelActionPath = "Hud/ItemClose"
local ConfirmActionPath = "Hud/TipsConfirm"
local OpenInviteViewActionPath = "Hud/OpenInviteView"

function TeamInviteItem:getDungeonInviteTitle(dungeonSceneId, dungeonConfig, hardLv)
	local title = dungeonConfig and pg.getLocalizationText(dungeonConfig.name) or pg.getGameString("TEAM_NO_TARGET")

	hardLv = tonumber(hardLv or 0)

	if hardLv > 0 and DungeonDifficultLevelData[dungeonSceneId] and DungeonDifficultLevelData[dungeonSceneId][hardLv] then
		return ClientTextUtils.concatByLanguage(title, pg.getGameString("DUNGEON_DIFFICUITY_" .. hardLv))
	end

	return title
end

function TeamInviteItem:onInit()
	self.uContainer = self.uWidget
	self.listRequests = {}
	self.listRequestsMore = {}
	self.bigNoticeShowCount = 3
	self.noticeShowCount = 5
	self.refreshDelay = 0.5
end

function TeamInviteItem:pushData(data)
	data.remainderTime = data.duration
	data.hasPlayAniIn = false
	data.removing = nil

	self:enqueue(data)
	self:loadTeamInvite()
end

function TeamInviteItem:onUpdate()
	return
end

function TeamInviteItem:triggerNo()
	if self.dataQueue[1] then
		if self.dataQueue[1].btnNoFunc then
			self.dataQueue[1].btnNoFunc()
		end

		self:removeNotice(self.dataQueue[1].noticeId, CS.XGUI.EInvokeTime.User2)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end
end

function TeamInviteItem:triggerYes()
	if self.dataQueue[1] then
		if self.dataQueue[1].btnYesFunc then
			self.dataQueue[1].btnYesFunc()
		end

		self:removeNotice(self.dataQueue[1].noticeId, CS.XGUI.EInvokeTime.User3)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end
end

function TeamInviteItem:getConfirmKeyLabel(data)
	local textKey = data.extraParam and data.extraParam.overrideYesText or "COMMON_CONFIRM_SOCIAL"

	return pg.getGameString(textKey)
end

function TeamInviteItem:refreshKeyList(listKeyUList, data)
	LuaUIUtils.setKeyList(listKeyUList, {
		{
			path = CancelActionPath,
			label = pg.getGameString("INVITE_CANCEL")
		},
		{
			path = ConfirmActionPath,
			label = self:getConfirmKeyLabel(data)
		}
	})
end

function TeamInviteItem:renderTeamInvite(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local progress = objectReference:GetRefValue("progressUProgress")
	local btnNoUButton = objectReference:GetRefValue("btnNoUButton")
	local btnYesUButton = objectReference:GetRefValue("btnYesUButton")
	local playerNameUText = objectReference:GetRefValue("playerNameUText")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")
	local currentNotice = self.dataQueue[1]
	local isCurrentNotice = currentNotice and currentNotice.noticeId == data.noticeId
	local showKeyList = isCurrentNotice and not pg.global.ui:runPlatformByMobile()

	button:InvokeCallback(CS.XGUI.EInvokeTime.User1, data.hasPlayAniIn)

	if not data.hasPlayAniIn then
		pg.game.audio:playEvent("SFX_UI_InvitationCard")
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonTapLight")
	end

	data.hasPlayAniIn = true
	progress.minValue = 0
	progress.maxValue = data.duration
	progress.value = data.remainderTime

	function btnNoUButton.luaClick()
		if data.btnNoFunc then
			data.btnNoFunc()
		end

		self:removeNotice(data.noticeId, CS.XGUI.EInvokeTime.User2)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	function btnYesUButton.luaClick()
		if data.btnYesFunc then
			data.btnYesFunc()
		end

		self:removeNotice(data.noticeId, CS.XGUI.EInvokeTime.User3)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	local cancelBind = LuaUIUtils.bindHotKey(button.gameObject, CancelActionPath, function()
		self:triggerNo()
	end, nil, 10)

	if cancelBind then
		cancelBind.enabled = showKeyList
	end

	btnYesUButton:SetPCAction(ConfirmActionPath, nil, function()
		self:triggerYes()

		return false
	end)
	btnYesUButton:SetHotkeyForceHidden(not showKeyList)

	local inputMapActionKey = HotkeyConst.INPUT_MAP_ACTION_KEY
	local gamepadConfirmBind = LuaUIUtils.bindHotKey(button.gameObject, ConfirmActionPath, function()
		self:triggerYes()
	end, nil, 100)

	if gamepadConfirmBind then
		gamepadConfirmBind.enabled = showKeyList
	end

	local gamepadCancelBind = LuaUIUtils.bindHotKey(button.gameObject, CancelActionPath, function()
		self:triggerNo()
	end, nil, 100)

	if gamepadCancelBind then
		gamepadCancelBind.enabled = showKeyList
	end

	listKeyUList:SetActiveFastest(showKeyList)

	if showKeyList then
		self:refreshKeyList(listKeyUList, data)
	end

	local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, data.playerInfo.playerName, true)
	local _h = TeamInviteItem._platformHooks

	playerName = _h and _h.renderTeamInvite and _h.renderTeamInvite(self, button, index, data, playerName) or playerName

	ClientTextUtils.setText(playerNameUText, playerName)

	if data.tIndex == 0 then
		local noticeUText = objectReference:GetRefValue("noticeUText")
		local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")

		LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
			playerInfo = data.playerInfo
		})
		ClientTextUtils.setText(noticeUText, data.noticeMsg or "")

		local sourceUText = objectReference:GetRefValue("txtSourceUSDFText")
		local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")

		if data.extraParam and data.extraParam.isFriendApply then
			button:TryChangePage("Friend", 1)
			ClientTextUtils.setText(sourceUText, string.isNilOrEmpty(data.extraParam.sourceMsg) and FriendSourceData[pg.game.chat.AddFriendSource.PlayerCard].friendsourceText or data.extraParam.sourceMsg)
			ClientTextUtils.setText(textLvUSDFText, data.playerInfo.level)

			local presetData = pg.game.avatar:getAvatarPresetData(data.playerInfo.avatarPresetKey) or {}
			local templateId = presetData.templateId or 0

			if templateId == 3 then
				button:TryChangePage("Gender", 1)
			elseif templateId == 4 then
				button:TryChangePage("Gender", 0)
			else
				button:TryChangePage("Gender", 2)
			end
		elseif data.extraParam and data.extraParam.isSpaceFollow then
			button:TryChangePage("Icon", 1)
			button:TryChangePage("IconState", data.extraParam.followIconState)
		end
	elseif data.tIndex == 1 then
		if data.extraParam.dungeonSceneId == Const.ROB_EGG_SCENE_ID or data.extraParam.dungeonSceneId == Const.ROB_EGG_SCENE_CLIP_ID then
			button:TryChangePage("Type", RobEggInviteType)
		else
			button:TryChangePage("Type", data.extraParam.type)
		end

		local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
		local noticeUText = objectReference:GetRefValue("noticeUText")

		if data.extraParam.type == 0 then
			local memberNumUBaseText = objectReference:GetRefValue("memberNumUBaseText")
			local dungeonConfig = LevelData[data.extraParam.dungeonSceneId]

			if data.noticeMsg and data.noticeMsg ~= "" then
				ClientTextUtils.setText(noticeUText, data.noticeMsg)
			end

			local curMemberCount = data.playerInfo.teamId and data.playerInfo.teamId ~= "" and data.playerInfo.teamMembers or 1

			ClientTextUtils.setText(memberNumUBaseText, curMemberCount, "/", dungeonConfig and dungeonConfig.playerNumMax or 4)

			local titleText = data.extraParam.overrideTitleText or self:getDungeonInviteTitle(data.extraParam.dungeonSceneId, dungeonConfig, data.extraParam.hardLv or data.extraParam.difficultLv)

			ClientTextUtils.setText(titleUBaseText, titleText)
		elseif data.extraParam.type == 2 then
			ClientTextUtils.setText(titleUBaseText, pg.getGameString("ENTER_WORLD_REQUEST_TITLE"))
			ClientTextUtils.setText(noticeUText, data.noticeMsg)
		elseif data.extraParam.type == 3 then
			ClientTextUtils.setText(titleUBaseText, pg.getGameString("EXCHANGE_PET_INVITE"))
		elseif data.extraParam.type == 4 then
			ClientTextUtils.setText(titleUBaseText, pg.getGameString("ENTER_WORLD_REQUEST_TITLE"))
		elseif data.extraParam.type == 8 then
			local titleText = pg.getGameString("PET_VARIANT_INTERACT_INVITE_TITLE")
			local noticeText = pg.getGameString("PET_VARIANT_INTERACT_INVITE_NOTICE")

			ClientTextUtils.setText(titleUBaseText, titleText)
			ClientTextUtils.setText(noticeUText, noticeText)

			local nameisChangeUSDFText = objectReference:GetRefValue("nameisChangeUSDFText")
			local nameCoverUSDFText = objectReference:GetRefValue("nameCoverUSDFText")

			ClientTextUtils.setText(nameCoverUSDFText, playerName)
			ClientTextUtils.setText(nameisChangeUSDFText, playerName)
		end
	end
end

function TeamInviteItem:refreshItemDelayTime(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local progress = objectReference:GetRefValue("progressUProgress")

	progress.minValue = 0
	progress.maxValue = data.duration
	progress.value = data.remainderTime
end

function TeamInviteItem:stopTimeTrigger()
	self.noticeTimerLastTime = nil

	if self.timeTrigger then
		self:killTimer(self.timeTrigger)

		self.timeTrigger = nil
	end
end

function TeamInviteItem:hideById()
	self:stopTimeTrigger()
	self:clearDataQueue()

	self.objectReference = nil
	self.listRequestUList = nil
	self.listMoreUList = nil

	self.uContainer:DestroyContent()
end

function TeamInviteItem:removeNotice(noticeId, animKey)
	if self.removingNoticeId then
		return
	end

	for _, data in ipairs(self.dataQueue) do
		if data.noticeId == noticeId then
			self:requestRecycle(data, false, animKey or CS.XGUI.EInvokeTime.User2)

			return
		end
	end
end

function TeamInviteItem:_removeItem(noticeId)
	local removeIndex = -1

	for index, value in ipairs(self.dataQueue) do
		if value.noticeId == noticeId then
			removeIndex = index

			break
		end
	end

	if removeIndex ~= -1 then
		self:removeNoticeAt(removeIndex)
	end
end

function TeamInviteItem:syncRequestList(nextListRequests)
	local nextNoticeIdSet = {}

	for _, data in ipairs(nextListRequests) do
		nextNoticeIdSet[data.noticeId] = true
	end

	local workingList = {}

	for _, data in ipairs(self.listRequests) do
		table.insert(workingList, data)
	end

	for index = #workingList, 1, -1 do
		if not nextNoticeIdSet[workingList[index].noticeId] then
			self.listRequestUList:RemoveElement(index - 1)
			table.remove(workingList, index)
		end
	end

	for index, data in ipairs(nextListRequests) do
		local currentData = workingList[index]

		if not currentData or currentData.noticeId ~= data.noticeId then
			self.listRequestUList:InsertElement(index - 1, data)
			table.insert(workingList, index, data)
		else
			self.listRequestUList:SetElement(index - 1, data)

			workingList[index] = data
		end
	end

	self.listRequests = nextListRequests
end

function TeamInviteItem:refreshNoticeList()
	if self.removingNoticeId then
		return
	end

	if #self.dataQueue >= 1 and not self.timeTrigger then
		self.noticeTimerLastTime = Time.realSecondCache
		self.timeTrigger = self:startTimer(function()
			local tickTime = Time.realSecondCache
			local delta = tickTime - self.noticeTimerLastTime

			self.noticeTimerLastTime = tickTime

			if self.removingNoticeId or not self.dataQueue[1] or IsNil(self.listRequestUList) then
				return
			end

			self.dataQueue[1].remainderTime = math.max(0, self.dataQueue[1].remainderTime - delta)

			local listIndex = math.min(#self.dataQueue, self.bigNoticeShowCount) - 1
			local res, btn = self.listRequestUList:TryGetChildAt(listIndex)

			if res then
				self:refreshItemDelayTime(btn, listIndex, self.dataQueue[1])
			end

			if self.dataQueue[1].remainderTime <= 0 then
				if self.dataQueue[1].timeEndFunc then
					self.dataQueue[1].timeEndFunc()
				end

				self:removeNotice(self.dataQueue[1].noticeId)
			end
		end, 0.1, true)
	elseif #self.dataQueue == 0 and self.timeTrigger then
		self:stopTimeTrigger()
	end

	if self:isQueueEmpty() and self.uContainer:CheckURLLoaded() then
		self.uContainer:DestroyContent()

		return
	end

	local nextListRequests = {}

	self.listRequestsMore = {}

	local hasMore1 = false
	local hasMore2 = false
	local moreCount = 0

	for index, notice in ipairs(self.dataQueue) do
		if index <= self.bigNoticeShowCount then
			table.insert(nextListRequests, 1, notice)
		elseif index <= self.noticeShowCount then
			hasMore1 = true

			table.insert(self.listRequestsMore, notice)
		else
			hasMore2 = true
			moreCount = #self.dataQueue - self.noticeShowCount

			break
		end
	end

	self:syncRequestList(nextListRequests)
	self.listMoreUList:SetList(self.listRequestsMore)

	if self.hasMoreRequest ~= hasMore1 then
		self.hasMoreRequest = hasMore1

		if hasMore1 then
			self.requestMiniULayoutBox:SetActiveQuickly(false)
			self.requestMiniULayoutBox:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		else
			self.requestMiniULayoutBox:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end
	end

	LuaUIUtils.setUIViewVisible(self.ringTransform, hasMore2)
	pg.global.setRedDot(RedDotConst.RedDotPath.TIP_FRIEND_INVITE_NUM, self.ringUButton, hasMore2, RedDotConst.RedDotStyle.NUM, moreCount)

	local showOpenInviteViewKey = hasMore2 and not pg.global.ui:runPlatformByMobile()

	self.keyHotKeyContent.gameObject:SetActiveEx(showOpenInviteViewKey)
	self.ringUButton:SetHotkeyForceHidden(not showOpenInviteViewKey)
end

function TeamInviteItem:loadTeamInvite()
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(function()
			self:initTeamView()
		end)
	else
		self:refreshTeamInvite()
	end
end

function TeamInviteItem:initTeamView()
	self.objectReference = self.uContainer.content:GetComponent("ObjectReference")
	self.listRequestUList = self.objectReference:GetRefValue("listRequestUList")
	self.listRequests = {}
	self.requestMiniULayoutBox = self.objectReference:GetRefValue("requestMiniULayoutBox")
	self.hasMoreRequest = nil
	self.listMoreUList = self.objectReference:GetRefValue("listMoreUList")
	self.listRequestsMore = {}
	self.ringTransform = self.objectReference:GetRefValue("ringTransform")
	self.keyHotKeyContent = self.objectReference:GetRefValue("keyHotKeyContent")
	self.ringUButton = self.ringTransform:GetComponent("UButton")

	function self.listRequestUList.luaRenderItem(button, index, data)
		self:renderTeamInvite(button, index, data)
	end

	function self.listMoreUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local avatarUImage = objectReference:GetRefValue("avatarUImage")
		local avatarFrameUImage = objectReference:GetRefValue("avatarFrameUImage")

		TeamInviteItem._renderPlayerHead(data, avatarUImage, avatarFrameUImage)
	end

	local function openInviteView()
		pg.global.ui:open(UIConst.UI_ID_FRIEND_INVITE_LIST, self.dataQueue)

		return false
	end

	self.ringUButton.luaClick = openInviteView

	self.ringUButton:SetGamepadLongPress(OpenInviteViewActionPath, self.keyHotKeyContent.gameObject, 0, openInviteView)
	self.ringUButton:SetPCLongPress(OpenInviteViewActionPath, self.keyHotKeyContent.gameObject, 0, openInviteView)
	self:refreshTeamInvite()
end

function TeamInviteItem:refreshTeamInvite()
	pg.game.audio:playEvent(AudioConst.EVENT_TEAM_INVITE)
	self:refreshNoticeList()
end

function TeamInviteItem:GMPushData(data)
	self.hudNoticeId = self.hudNoticeId or 0
	self.hudNoticeId = self.hudNoticeId + 1
	data.noticeId = self.hudNoticeId
	data.duration = 5
	data.playerId = pg.me.uid
	data.playerInfo = pg.me
	data.noticeMsg = "Test"
	data.tIndex = 0
end

function TeamInviteItem:hasRecycleData(data)
	for _, notice in ipairs(self.dataQueue) do
		if notice == data then
			return true
		end
	end

	return false
end

function TeamInviteItem:removeNoticeAt(index)
	local data = table.remove(self.dataQueue, index)

	if not data then
		return
	end

	if index == 1 then
		self.noticeTimerLastTime = Time.realSecondCache
	end

	self.owner.owner.recycleController:invalidate(self, data)

	if self.removingNoticeId == data.noticeId then
		self.removingNoticeId = nil
	end

	return data
end

function TeamInviteItem:removeRecycleData(data)
	for index, notice in ipairs(self.dataQueue) do
		if notice == data then
			self:removeNoticeAt(index)

			return
		end
	end
end

function TeamInviteItem:getRecycleTarget(data)
	if IsNil(self.listRequestUList) then
		return
	end

	for index, notice in ipairs(self.listRequests) do
		if notice == data then
			local found, button = self.listRequestUList:TryGetChildAt(index - 1)

			if found then
				return button
			end
		end
	end
end

function TeamInviteItem:onRecycleStarted(data, target)
	self.removingNoticeId = data.noticeId
end

function TeamInviteItem:onRecycleCleanup(data, target, reason)
	return
end

function TeamInviteItem:hasRecycleRunningData()
	return #self.dataQueue > 0
end

function TeamInviteItem:onClearDataQueue()
	for index = #self.dataQueue, 1, -1 do
		self:removeNoticeAt(index)
	end

	self.removingNoticeId = nil

	self:stopTimeTrigger()
end

function TeamInviteItem:onRecycleFinished(data, reason)
	if self:isQueueEmpty() then
		self:stopTimeTrigger()
	end

	if not self:isRecycleCancelled(reason) then
		self:refreshNoticeList()
	end
end

return TeamInviteItem
