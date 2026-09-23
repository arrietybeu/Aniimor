-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LittleFireGardenManual\\LittleFireGardenManualCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ItemSourceData = require("Data.item_source_data")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local LittleFireGardenManualCtrl = Class.LightClass("LittleFireGardenManualCtrl", UICtrl)

LittleFireGardenManualCtrl.PAGE_TASK = "Task"
LittleFireGardenManualCtrl.PAGE_RANK = "Rank"
LittleFireGardenManualCtrl.RANK_EMPTY_ITEM_COUNT = 6
LittleFireGardenManualCtrl.LEFT_TAB_LIST = {
	{
		page = LittleFireGardenManualCtrl.PAGE_RANK
	},
	{
		page = LittleFireGardenManualCtrl.PAGE_TASK
	}
}
LittleFireGardenManualCtrl.messages = {
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"refreshUI",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"refreshUI",
		true
	},
	[MessageName.LITTLE_FIRE_PERSON_CHANGE] = {
		"refreshUI",
		true
	},
	[MessageName.RECV_FRIEND_LIST] = {
		"onFriendListChanged",
		true
	}
}

function LittleFireGardenManualCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function LittleFireGardenManualCtrl:addListener()
	if self.view.closeUButton then
		function self.view.closeUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.taskList then
		function self.view.taskList.luaRenderItem(button, index, data)
			self:renderTaskItem(button, index, data)
		end
	end

	if self.view.listRankUList then
		function self.view.listRankUList.luaRenderItem(button, index, data)
			self:renderRankItem(button, index, data)
		end
	end

	if self.view.leftTabUList then
		function self.view.leftTabUList.luaRenderItem(button, index, data)
			self:renderLeftTabItem(button, index, data)
		end
	end

	if self.view.friendBtnUButton then
		function self.view.friendBtnUButton.luaClick()
			self:onClickAddFriend()
		end
	end
end

function LittleFireGardenManualCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.eventId = info.eventId

	local selectedIndex = info.tab == 2 and 1 or 0

	self.view.leftTabUList:SetList(LittleFireGardenManualCtrl.LEFT_TAB_LIST)
	self:switchPage(LittleFireGardenManualCtrl.LEFT_TAB_LIST[selectedIndex + 1].page)
end

function LittleFireGardenManualCtrl:onShow()
	UICtrl.onShow(self)
end

function LittleFireGardenManualCtrl:onHide()
	UICtrl.onHide(self)
end

function LittleFireGardenManualCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function LittleFireGardenManualCtrl:refreshUI()
	if self.view.leftTabUList then
		self.view.leftTabUList:RefreshList()
	end

	if self.currentPage == LittleFireGardenManualCtrl.PAGE_TASK then
		local taskList = self.model:getTaskList()

		self.view.widget:TryChangePage("condition", LittleFireGardenManualCtrl.PAGE_TASK)

		if self.view.taskList then
			self.view.taskList:SetList(taskList)
		end
	elseif self.currentPage == LittleFireGardenManualCtrl.PAGE_RANK then
		self:refreshRankUI()
	end

	self:refreshTxt()
end

function LittleFireGardenManualCtrl:refreshTxt()
	if self.currentPage == LittleFireGardenManualCtrl.PAGE_TASK then
		ClientTextUtils.setText(self.view.tips1UBaseText, pg.getGameString("FIRE_TASK_RENEWTIME"))
		ClientTextUtils.setText(self.view.tips2UBaseText, "")
	elseif self.currentPage == LittleFireGardenManualCtrl.PAGE_RANK then
		ClientTextUtils.setText(self.view.tips1UBaseText, pg.getGameString("FIRE_PLAY_DESC1"))

		local cutNum, totalNum = ClientActivityUtils.getLittleFireSparkDailyProgress()

		ClientTextUtils.setText(self.view.tips2UBaseText, pg.getFormatText(pg.getGameString("FIRE_PLAY_DESC2"), cutNum, totalNum))
		ClientTextUtils.setText(self.view.titleEmptyUBaseText, pg.getGameString("FIRE_NO_FRIEND"))

		local friendBtnObjRef = self.view.friendBtnUButton:GetComponent("ObjectReference")
		local friendBtnTxt = friendBtnObjRef and friendBtnObjRef:GetRefValue("txtNameUText")

		if friendBtnTxt then
			ClientTextUtils.setText(friendBtnTxt, pg.getGameString("FIRE_ADD_FRIEND"))
		end
	end
end

function LittleFireGardenManualCtrl:onFriendListChanged(refreshReason)
	if refreshReason == pg.game.chat.queryPlayerInfoType.ShowPlayerInfo then
		return
	end

	self:refreshUI()
end

function LittleFireGardenManualCtrl:refreshRankUI()
	local rankList = self.model:getRankList(self.eventId)

	self.view.widget:TryChangePage("condition", #rankList > 0 and LittleFireGardenManualCtrl.PAGE_RANK or "Empty")
	self:refreshRankHeadButton(self.view.rankHead1UButton, rankList[1])
	self:refreshRankHeadButton(self.view.rankHead2UButton, rankList[2])
	self:refreshRankHeadButton(self.view.rankHead3UButton, rankList[3])

	if self.view.listRankUList then
		local normalRankList = {}

		if #rankList > 0 and #rankList <= 3 then
			for _ = 1, LittleFireGardenManualCtrl.RANK_EMPTY_ITEM_COUNT do
				normalRankList[#normalRankList + 1] = {
					isEmpty = true
				}
			end
		else
			for index = 4, #rankList do
				normalRankList[#normalRankList + 1] = rankList[index]
			end
		end

		self.view.listRankUList:SetList(normalRankList)
	end
end

function LittleFireGardenManualCtrl:_getRankHotNum(rankData)
	return rankData.sparkDays or 0
end

function LittleFireGardenManualCtrl:_getRankState(rankData)
	local hotNum = self:_getRankHotNum(rankData)
	local sparkedToday = rankData.sparkedToday

	if hotNum <= 0 or sparkedToday ~= true then
		return 2
	end

	return hotNum >= 5 and 0 or 1
end

function LittleFireGardenManualCtrl:_getPlayerState(uid)
	if not uid or not pg.game or not pg.game.chat then
		return 0
	end

	local playerInfo = pg.game.chat:getPlayerInfo(uid)

	if not playerInfo or playerInfo.online == nil then
		return 0
	end

	return playerInfo.online and 1 or 2
end

function LittleFireGardenManualCtrl:renderRankItem(button, index, rankData)
	local objectReference = button:GetComponent("ObjectReference")
	local btnHeadUButton = objectReference:GetRefValue("btnHeadUButton")
	local headUWidget = objectReference:GetRefValue("headUWidget")
	local taskBtnUButton = objectReference:GetRefValue("taskBtnUButton")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local hotIconUImage = objectReference:GetRefValue("hotIconUImage")
	local hotNumUBaseText = objectReference:GetRefValue("hotNumUBaseText")
	local lvTxt = objectReference:GetRefValue("lvTxt")
	local isEmpty = rankData.isEmpty == true

	button:TryChangePage("Empty", isEmpty and 1 or 0)

	if isEmpty then
		btnHeadUButton.luaClick = nil
		taskBtnUButton.luaClick = nil

		return
	end

	button:TryChangePage("Rank", self:_getRankState(rankData))

	local uid = rankData.uid or rankData.playerId
	local playerInfo = rankData.playerInfo or uid and pg.game.chat:getPlayerInfo(uid) or rankData

	uid = uid or playerInfo.uid

	button:TryChangePage("State", self:_getPlayerState(uid))
	ClientTextUtils.setText(txtNameUBaseText, playerInfo.playerName or rankData.playerName or rankData.name or "")
	ClientTextUtils.setText(lvTxt, playerInfo.level or rankData.level or 0)
	ClientTextUtils.setText(hotNumUBaseText, self:_getRankHotNum(rankData))

	if headUWidget then
		LuaUIUtils.renderPlayerAvatarImages(headUWidget, {
			avatarIconId = playerInfo.headIcon,
			avatarFrameIconId = playerInfo.headFrame
		})
	end

	function btnHeadUButton.luaClick()
		if uid then
			LuaUIUtils.openInfoPlayerCard({
				openType = ClientConst.PlayerInfoOpenType.Chat,
				playerId = uid,
				playerInfo = playerInfo
			})
		end
	end

	function taskBtnUButton.luaClick()
		self:onClickRankChat(uid)
	end
end

function LittleFireGardenManualCtrl:refreshRankHeadButton(button, rankData)
	if not button then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local btnHeadUButton = objectReference:GetRefValue("btnHeadUButton")
	local headUWidget = objectReference:GetRefValue("headUWidget")
	local lvNumUBaseText = objectReference:GetRefValue("lvNumUBaseText")
	local hotNumUBaseText = objectReference:GetRefValue("hotNumUBaseText")
	local taskBtnUButton = objectReference:GetRefValue("taskBtnUButton")

	if not rankData then
		btnHeadUButton.luaClick = nil
		taskBtnUButton.luaClick = nil

		button:TryChangePage("Empty", 1)

		return
	end

	local uid = rankData.uid or rankData.playerId

	button:TryChangePage("Empty", 0)
	button:TryChangePage("State", self:_getPlayerState(uid))
	button:TryChangePage("Rank", self:_getRankState(rankData))

	local playerInfo = rankData.playerInfo or uid and pg.game.chat:getPlayerInfo(uid) or rankData

	uid = uid or playerInfo.uid

	ClientTextUtils.setText(txtNameUBaseText, playerInfo.playerName or rankData.playerName or rankData.name or "")
	ClientTextUtils.setText(lvNumUBaseText, playerInfo.level or rankData.level or 0)
	ClientTextUtils.setText(hotNumUBaseText, self:_getRankHotNum(rankData))

	if headUWidget then
		LuaUIUtils.renderPlayerAvatarImages(headUWidget, {
			avatarIconId = playerInfo.headIcon,
			avatarFrameIconId = playerInfo.headFrame
		})
	end

	function btnHeadUButton.luaClick()
		if uid then
			LuaUIUtils.openInfoPlayerCard({
				openType = ClientConst.PlayerInfoOpenType.Chat,
				playerId = uid,
				playerInfo = playerInfo
			})
		end
	end

	function taskBtnUButton.luaClick()
		self:onClickRankChat(uid)
	end
end

function LittleFireGardenManualCtrl:switchPage(page)
	self.currentPage = page

	self:refreshUI()
end

function LittleFireGardenManualCtrl:renderLeftTabItem(button, index, data)
	button:TryChangePage("State", self.currentPage == data.page and 1 or 0)

	local objRef = button:GetComponent("ObjectReference")
	local titleUBaseText = objRef:GetRefValue("titleUBaseText")

	ClientTextUtils.setText(titleUBaseText, data.page == LittleFireGardenManualCtrl.PAGE_TASK and pg.getGameString("FIRE_TASK") or pg.getGameString("FIRE_PLAY"))

	local taskRedDotStyle = ClientActivityUtils.getLittleFirePersonManualTaskRedDotStyle()
	local showTaskRedDot = data.page == LittleFireGardenManualCtrl.PAGE_TASK and taskRedDotStyle ~= RedDotConst.RedDotStyle.NONE

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_LITTLE_FIRE_PERSON_MANUAL_TAB, index), button, showTaskRedDot, taskRedDotStyle)

	function button.luaClick()
		self:switchPage(data.page)
	end
end

function LittleFireGardenManualCtrl:renderTaskItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local underwayTextUBaseText = objectReference:GetRefValue("underwayTextUBaseText")
	local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	local btnGetUButton = objectReference:GetRefValue("btnGetUButton")
	local tagTitleUBaseText = objectReference:GetRefValue("tagTitleUBaseText")
	local taskInfo = data.taskInfo

	button:TryChangePage("Tag", taskInfo.taskType == ActivityConst.ActivityTaskType.Active_DailyTask and 1 or 0)

	local taskState = taskInfo.taskState
	local isUnFinished = taskState == ActivityConst.TaskState.UnFinished
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv
	local hasReceived = taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail
	local canGo = isUnFinished and (taskInfo.sourceId or taskInfo.taskEvent)

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_LITTLE_FIRE_PERSON_MANUAL_TASK_ITEM, taskInfo.taskId), button, canReceive, RedDotConst.RedDotStyle.POINT)

	local rewards = LuaUIUtils.getRewardItemByDropId(taskInfo.taskAward, hasReceived, canReceive)
	local reward = rewards[1]

	if reward then
		iconUImage.url = LuaUIUtils.getIconByItemId(reward.id)

		ClientTextUtils.setText(numUBaseText, reward.num or 0)
	else
		iconUImage.url = taskInfo.eventIcon

		ClientTextUtils.setText(numUBaseText, 0)
	end

	local taskDesc = pg.getLocalizationText(taskInfo.taskDes)

	ClientTextUtils.setText(txtNameUBaseText, pg.getFormatText(taskDesc, taskInfo.progress or 0, taskInfo.target or 0))
	ClientTextUtils.setText(tagTitleUBaseText, self:_getTaskTypeText(taskInfo.taskType))

	local itemState = 3

	if canReceive then
		itemState = 1
	elseif hasReceived then
		itemState = 2
	elseif canGo then
		itemState = 0
	end

	button:TryChangePage("state", itemState)

	if itemState == 3 then
		ClientTextUtils.setText(underwayTextUBaseText, pg.getGameString("BUTTON_NAME_3"))
	end

	function btnGoUButton.luaClick()
		self:onClickGo(taskInfo)
	end

	function btnGetUButton.luaClick()
		self:onClickReceive(taskInfo)
	end

	local goRef = btnGoUButton:GetComponent("ObjectReference")
	local goTxt = goRef and goRef:GetRefValue("txtNameUText")

	if goTxt then
		ClientTextUtils.setText(goTxt, pg.getGameString("BUTTON_NAME_1"))
	end

	local getRef = btnGetUButton:GetComponent("ObjectReference")
	local getTxt = getRef and getRef:GetRefValue("txtNameUText")

	if getTxt then
		ClientTextUtils.setText(getTxt, pg.getGameString("BUTTON_NAME_2"))
	end
end

function LittleFireGardenManualCtrl:_getTaskTypeText(taskType)
	if taskType == ActivityConst.ActivityTaskType.Active_DailyTask then
		return pg.getGameString("FIRE_TASK_DAILY")
	end

	if taskType == ActivityConst.ActivityTaskType.Active_WeeklyTask then
		return pg.getGameString("BATTLEPASS_MISSION_WEEKLY")
	end

	return pg.getGameString("SHOP_ITEM_LIMIT_FOREVER")
end

function LittleFireGardenManualCtrl:onClickGo(taskInfo)
	local sourceData = taskInfo.sourceId and ItemSourceData[taskInfo.sourceId]

	if sourceData then
		LuaUIUtils.clueSeek(sourceData)
	elseif taskInfo.taskEvent then
		pg.me:doEvent(taskInfo.taskEvent)
	end

	self:dismiss()
end

function LittleFireGardenManualCtrl:onClickReceive(taskInfo)
	if taskInfo and taskInfo.taskId and taskInfo.taskId > 0 then
		pg.me:reqActReceiveTaskReward(taskInfo.taskId, self.eventId)
	end
end

function LittleFireGardenManualCtrl:onClickRankChat(uid)
	if uid then
		pg.global.ui.chat:createNewChat(nil, uid)
	end
end

function LittleFireGardenManualCtrl:onClickAddFriend()
	pg.global.ui:open(UIConst.UI_ID_CHAT, {
		openAddFriend = true,
		initTab = pg.game.chat.tabType.Friend
	}, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function LittleFireGardenManualCtrl:getWhiteList()
	return {
		[UIConst.UI_ID_EVENT] = true
	}
end

function LittleFireGardenManualCtrl:onSysMsg(msg, data)
	if (msg == MessageName.EVENT_CUR_PAGE_REFRESH or msg == MessageName.EVENT_TASK_STATE_CHANGE or msg == MessageName.LITTLE_FIRE_PERSON_CHANGE) and self.currentPage == LittleFireGardenManualCtrl.PAGE_TASK then
		self:refreshUI()
	end
end

return LittleFireGardenManualCtrl
