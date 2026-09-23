-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushChallenge\\BossRushChallengeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushChallengeCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BossRushChallengeCtrl = Class.LightClass("BossRushChallengeCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local PuppetData = require("Data.puppet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local PetData = require("Data.pet_data")
local lume = require("Core.Common.lume")
local BossRushUtils = require("Utils.BossRushUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local BossRushBuffData = require("Data.bossrush_buff_data")
local AvatarRobotData = require("Data.avatar_robot_data")
local CameraConst = require("GameApp.Camera.CameraConst")
local RedDotConst = require("Const.RedDotConst")
local AddressDataConst = require("Const.AddressDataConst")
local UICardRenderUtils = require("Guis.Utils.UICardRenderUtils")
local Utils = require("Common.Utils.Utils")

BossRushChallengeCtrl.messages = {
	[MessageName.BOSS_RUSH_TEAM_INFO_CHANGED] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.BOSS_RUSH_TEAM_BUFF_CHANGED] = {
		"refreshBuffInfo",
		true
	},
	[MessageName.BOSS_RUSH_TEAM_LEVEL_ID_CHANGED] = {
		"refreshOpenLevelMatch",
		true
	}
}
BossRushChallengeCtrl.luckyPetConsoleData = {
	path = "Raw/GamepadLeftStickPress",
	label = pg.getGameString("CONSOLE_BAR_LUCKY_IMO")
}
BossRushChallengeCtrl.infoConsoleData = {
	path = "Raw/GamepadStart",
	label = pg.getGameString("CONSOLE_BAR_PLAYMODE_INFO")
}
BossRushChallengeCtrl.buffDefailData = {
	path = "Raw/GamepadButtonWest",
	label = pg.getGameString("CONSOLE_BAR_BUFF_DETAILS")
}
BossRushChallengeCtrl.checkData = {
	path = "Raw/GamepadButtonSouth",
	label = pg.getGameString("CONSOLE_BAR_VIEW")
}
BossRushChallengeCtrl.exitData = {
	path = "Raw/GamepadButtonEast",
	label = pg.getGameString("CONSOLE_BAR_LEAVE")
}
BossRushChallengeCtrl.viewPetData = {
	path = "Raw/GamepadButtonSouth",
	label = pg.getGameString("CONSOLE_BAR_VIEW_IMO")
}
BossRushChallengeCtrl.changePetData = {
	path = "Raw/GamepadButtonSouth",
	label = pg.getGameString("CONSOLE_BAR_MODIFY_IMO")
}
BossRushChallengeCtrl.viewBuffData = {
	path = "Raw/GamepadButtonSouth",
	label = pg.getGameString("CONSOLE_BAR_VIEW_BUFF")
}
BossRushChallengeCtrl.changeBuffData = {
	path = "Raw/GamepadButtonSouth",
	label = pg.getGameString("CONSOLE_BAR_MODIFY_BUFF")
}
BossRushChallengeCtrl.orders = {
	BossRushChallengeCtrl.luckyPetConsoleData,
	BossRushChallengeCtrl.infoConsoleData,
	BossRushChallengeCtrl.buffDefailData,
	BossRushChallengeCtrl.checkData,
	BossRushChallengeCtrl.viewPetData,
	BossRushChallengeCtrl.changePetData,
	BossRushChallengeCtrl.viewBuffData,
	BossRushChallengeCtrl.changeBuffData,
	BossRushChallengeCtrl.exitData
}

function BossRushChallengeCtrl:generateConsoleData(extraItems)
	local extras = {}

	if extraItems then
		for _, v in ipairs(extraItems) do
			extras[v] = true
		end
	end

	local result = {}

	for _, item in ipairs(self.orders) do
		if item == self.luckyPetConsoleData then
			if self.showLuckyPet then
				table.insert(result, item)
			end
		elseif item == self.buffDefailData or item == self.exitData or extras[item] then
			table.insert(result, item)
		end
	end

	return {
		right = result
	}
end

function BossRushChallengeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isShow = info.isShow
	self.levelId = info.levelId
	self.levelData = BossRushLevelData[self.levelId]
	self.target = info.target
	self.levelIds = info.levelIds or {}

	if self.levelIds then
		for index, value in ipairs(self.levelIds) do
			if value == self.levelId then
				self.curBossIndex = index

				break
			end
		end
	end

	if self.target == nil and self.curBossIndex then
		self.target = Const.BossRushBattlePlace[self.curBossIndex]
	end

	self.isOpen = BossRushUtils.checkIsOpen()

	if self.isOpen then
		self.cycleData = BossRushCycleData[pg.me.curBossRushCycleId]
	else
		self.cycleData = BossRushCycleData[pg.me.nextBossRushCycleId]
	end

	if not self.isShow then
		pg.me:openChallengeBoss(self.levelId)
		BossRushUtils.checkSelfPetAvailable(self.levelId)
	end

	self.needNotifyCancelOpen = not self.isShow and pg.me:isInTeam() and pg.me:isTeamLeader()
	self.tempOpenLevelId = nil

	if pg.me:isTeamLeader() or info.isFromServer then
		self.tempOpenLevelId = self.levelId
	end

	self.showTarget = self.target or self:getShowTarget()

	self:initUI()
	self:renderBossModel()

	self.isInit = true

	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, self:generateConsoleData({
		self.checkData
	}))
end

function BossRushChallengeCtrl:onGamePadFocusChange()
	return
end

function BossRushChallengeCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		if self.needNotifyCancelOpen then
			if BossRushUtils.checkNeedShowCancelChallengeTip() and self.prepareCount and self.prepareCount > 1 then
				local title = pg.getGameString("WARNING")
				local desc = pg.getGameString("BOSS_RUSH_CANCEL_OPEN_CHALLENGE_TIP")

				pg.global.showConfirmMsgRaw(title, desc, function()
					pg.me:bossRushCancelOpen()
					self:close()
				end, false, function()
					return
				end, nil, nil, {
					hint = true,
					hintDesc = pg.getGameString("BOSS_RUSH_CANCEL_OPEN_CHALLENGE_TIME_TIP"),
					okBtnDesc = pg.getGameString("COMMON_CONFIRM_SOCIAL"),
					cancelBtnDesc = pg.getGameString("CONSOLE_COMMON_CANCEL"),
					hintCb = function(isSelected)
						if isSelected then
							BossRushUtils.setLastShowCancelChallengeTipTime()
						end
					end
				})
			else
				pg.me:bossRushCancelOpen()
				self:close()
			end

			return
		end

		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		if not pg.me:isInTeam() or pg.me:isTeamLeader() then
			if not self:checkCanChallenge() then
				return
			end

			if not self:checkSelectPet() then
				return
			end

			if not self:checkSelectBuff() then
				pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
					isShow = false,
					tab = 0
				})

				return
			end

			pg.me:goBossRushDungeon(self.levelId)
			self:close()
		elseif BossRushUtils.isPlayerReady(pg.me.id, self.levelId) then
			pg.me:serverMsg("RPC_CS_BossRushPrepare", self.levelId, 0)
		else
			if not self:checkSelectPet() then
				return
			end

			pg.me:serverMsg("RPC_CS_BossRushPrepare", self.levelId, 1)
		end
	end

	function self.view.btnLeftUButton.luaClick()
		self.curBossIndex = self.curBossIndex - 1

		if self.curBossIndex < 1 then
			self.curBossIndex = #self.levelIds
		end

		self.levelId = self.levelIds[self.curBossIndex]

		self:onLevelIdUpdate()
	end

	function self.view.btnRightUButton.luaClick()
		self.curBossIndex = self.curBossIndex + 1

		if self.curBossIndex > #self.levelIds then
			self.curBossIndex = 1
		end

		self.levelId = self.levelIds[self.curBossIndex]

		self:onLevelIdUpdate()
	end

	function self.view.recommendUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_RECOMMEND_PET, {
			isBossRush = true,
			levelId = self.levelId
		})
	end

	ClientTextUtils.setText(self.view.recommendPetUBaseText, pg.getGameString("RECOMMEND_PET_POPUP_TITLE"))
	self:bindHotKeyPerform("Raw/GamepadLeftShoulder", function()
		self.view.btnLeftUButton:OnClickSimulate()
	end)
	self:bindHotKeyPerform("Raw/GamepadRightShoulder", function()
		self.view.btnRightUButton:OnClickSimulate()
	end)
	self:bindHotKeyPerform("Raw/GamepadButtonNorth", function()
		self.view.btnConfirmUButton:OnClickSimulate()
	end)
	self:bindHotKeyPerform("Raw/GamepadDPadRight", function()
		self.view.panelTankUButton:OnClickSimulate()

		return false
	end)
	self:bindHotKeyPerform("Raw/GamepadLeftStickPress", function()
		self.view.luckyUButton:OnClickSimulate()
	end)
	self:bindHotKeyPerform("Raw/GamepadButtonWest", function()
		local canSelect = not pg.me:isInTeam() or pg.me:isTeamLeader()

		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			tab = 0,
			isShow = not canSelect
		})
	end)
end

function BossRushChallengeCtrl:checkSelectBuff()
	local selectBuffs = pg.me.space.selectBatBuffs or {}

	return selectBuffs[1] ~= nil
end

function BossRushChallengeCtrl:checkSelectTank()
	return pg.space.selectedTankEntId ~= nil and pg.space.selectedTankEntId ~= "" or not pg.me:isInTeam()
end

function BossRushChallengeCtrl:checkSelectPet()
	local pList = pg.space.teamerInfos[pg.me.id] and pg.space.teamerInfos[pg.me.id].levelBatPetList

	pList = pList and pList[self.levelId]

	local petInfo = pList and pList[1]

	if petInfo == nil then
		pg.global.ui.tips:showTextTip(pg.getGameString("BOSS_RUSH_CHALLENGE_NO_PET"))

		return false
	end

	return true
end

function BossRushChallengeCtrl:checkCanChallenge()
	return true
end

function BossRushChallengeCtrl:initUI()
	self:refreshPageInfoType()
	self:renderRankData()
	self:renderBossInfo()
	self:initTeamInfo()
	self:initBuffInfo()
	self.view.btnChat:SetActive(pg.me:isInTeam())
	pg.game.chat:setTeamMiniChatWidget(self.view.btnChat)
end

function BossRushChallengeCtrl:onLevelIdUpdate()
	self.levelData = BossRushLevelData[self.levelId]

	if not self.levelData then
		return
	end

	self.showTarget = self:getShowTarget()

	self:refreshPageInfoType()
	self:renderRankData()
	self:renderBossInfo()
	self:renderBossModel()
	self:refreshBuffInfo()
	self:refreshTeamInfo()
end

function BossRushChallengeCtrl:refreshPageInfoType()
	if not self.levelData then
		return
	end

	self.type = 0

	if self.isShow then
		self.type = 2
	end

	self.view.rootUComponent:TryChangePage("InfoType", self.type)
	self.view.btnLeftUButton:SetActive(self.isShow)
	self.view.btnRightUButton:SetActive(self.isShow)
end

function BossRushChallengeCtrl:checkHasRecord()
	return self.isOpen and pg.me.curBossRushCycBossBestScores[self.levelData.bossId] and pg.me.curBossRushCycBossBestScores[self.levelData.bossId] > 0
end

function BossRushChallengeCtrl:renderRankData()
	if not self.levelData then
		return
	end

	local score = 0
	local star = 0

	if self.isOpen then
		score = pg.me.curBossRushCycBossBestScores[self.levelData.bossId] or 0
		star = pg.me.curBossRushCycBossBestGrades[self.levelData.bossId] or 0
	end

	ClientTextUtils.setText(self.view.scoreUBaseText, ClientTextUtils.concatByLanguage("", score))
	ClientTextUtils.setText(self.view.starUBaseText, star)
end

function BossRushChallengeCtrl:renderBossInfo()
	local levelData = self.levelData

	if not levelData or not levelData.bossId then
		return
	end

	local bossInfo = PuppetData[levelData.bossId]

	if not bossInfo then
		return
	end

	ClientTextUtils.setText(self.view.bossTitleUBaseText, pg.getLocalizationText(bossInfo.BossShowName or ""))
	ClientTextUtils.setText(self.view.timeUBaseText, LuaUIUtils.getLoginWaitingCountDownFormateText(SysConfigData.BossRushCombatDuration))

	local playId, envId

	if self.showTarget == Const.BossRushTeleportTarget.BossLeft then
		playId = self.cycleData.interactBuffRefLeft
		envId = self.cycleData.envBuffRefLeft
	elseif self.showTarget == Const.BossRushTeleportTarget.BossMid then
		playId = self.cycleData.interactBuffRefMid
		envId = self.cycleData.envBuffRefMid
	elseif self.showTarget == Const.BossRushTeleportTarget.BossRight then
		playId = self.cycleData.interactBuffRefRight
		envId = self.cycleData.envBuffRefRight
	end

	local playInfo = BossRushBuffData[playId] or {}

	self.view.playIconUImage.url = playInfo.buffIcon or ""

	ClientTextUtils.setText(self.view.playTitleUBaseText, pg.getLocalizationText(playInfo.buffName or ""))
	ClientTextUtils.setText(self.view.playDetailUScrollRect.content, pg.getLocalizationText(playInfo.descShort or ""))
	LuaUIUtils.setSkillTipButton2(self.view.detail1UButton, {
		tags = {},
		skillName = playInfo.buffName or "",
		skillDesc = playInfo.desc or "",
		skillIcon = playInfo.buffIcon or ""
	})

	local envInfo = BossRushBuffData[envId] or {}

	self.view.envIconUImage.url = envInfo.buffIcon or ""

	ClientTextUtils.setText(self.view.envTitleUBaseText, pg.getLocalizationText(envInfo.buffName or ""))
	ClientTextUtils.setText(self.view.envDetailUScrollRect.content, pg.getLocalizationText(envInfo.descShort or ""))
	LuaUIUtils.setSkillTipButton2(self.view.detail2UButton, {
		tags = {},
		skillName = envInfo.buffName or "",
		skillDesc = envInfo.desc or "",
		skillIcon = envInfo.buffIcon or ""
	})

	local recommendEle = levelData.elementRecmmend or {}

	LuaUIUtils.renderPetElement(self.view.recommentEleUList, recommendEle)

	function self.view.listTipsUList.luaRenderItem(button, index, data)
		button:TryChangePage("Recommend", data.isRecommend and 0 or 1)
	end

	local tags = BossRushUtils.getLevelTagInfos(self.levelId)

	self.view.listTipsUList:SetList(tags)

	function self.view.luckyUButton.luaRenderTooltip(button, popup)
		LuaUIUtils.renderCommonSmallTip(popup, pg.getGameString("BOSS_RUSH_LUCKY_PET_TIP_TITLE"), pg.getGameString("BOSS_RUSH_LUCKY_PET_TIP"))
	end
end

function BossRushChallengeCtrl:refreshBossBaseInfo(target)
	local levelData = self.levelData

	if not levelData or not levelData.bossId then
		return
	end

	local bossInfo = PuppetData[levelData.bossId]

	if not bossInfo then
		return
	end

	local titleText = ""
	local uCom

	if target == Const.BossRushTeleportTarget.BossLeft then
		titleText = pg.getGameString("BOSS_RUSH_TITLE_LEFT")
		uCom = self.uiScene.bossInfoLeftUComponent
	elseif target == Const.BossRushTeleportTarget.BossMid then
		titleText = pg.getGameString("BOSS_RUSH_TITLE_MID")
		uCom = self.uiScene.bossInfoUComponent
	elseif target == Const.BossRushTeleportTarget.BossRight then
		titleText = pg.getGameString("BOSS_RUSH_TITLE_RIGHT")
		uCom = self.uiScene.bossInfoRightUComponent
	end

	if not uCom then
		return
	end

	local objectReference = uCom:GetComponent("ObjectReference")
	local textLevelUBaseText = objectReference:GetRefValue("textLevelUBaseText")
	local textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	local listElementUList = objectReference:GetRefValue("listElementUList")
	local textNameBackUBaseText = objectReference:GetRefValue("textNameBackUBaseText")

	ClientTextUtils.setText(textLevelUBaseText, self.cycleData.bossLv)

	local bossName = pg.getLocalizationText(bossInfo.BossShowName or "")

	ClientTextUtils.setText(textNameUBaseText, bossName)
	ClientTextUtils.setText(textNameBackUBaseText, bossName)
	ClientTextUtils.setText(titleUBaseText, titleText)

	local elementData = {}
	local elementType = bossInfo.elementType or {}

	for key, value in pairs(elementType) do
		table.insert(elementData, key)
	end

	LuaUIUtils.renderPetElement(listElementUList, elementData)
end

function BossRushChallengeCtrl:initTeamInfo()
	self.selectTankExpand = false

	function self.view.listPlayerUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
		local playerHeadUButton = objectReference:GetRefValue("playerHeadUButton")
		local petIconUImage = objectReference:GetRefValue("petIconUImage")
		local iconTakenUWidget = objectReference:GetRefValue("iconTakenUWidget")

		iconTakenUWidget:SetActive(false)

		button.draggable = false

		button:TryChangePage("Belong", data.uid == pg.me.uid and 0 or 1)
		playerHeadUButton:TryChangePage("Teammate", data.isAi and 4 or index)
		playerHeadUButton:TryChangePage("Ready", pg.me:isInTeam() and (data.isReady and 1 or 2) or 0)

		local ent = data.entId and pg.getEntity(data.entId)

		if ent then
			local playerName = ent.playerName

			if data.isAi then
				local robotData = AvatarRobotData[ent.botTemplateId]

				if robotData and robotData.name then
					playerName = pg.getLocalizationText(robotData.name)
				end
			end

			local _h = BossRushChallengeCtrl._platformHooks

			playerName = _h and _h.getMaskedEntDisplayName and _h.getMaskedEntDisplayName(self, ent, playerName) or playerName

			ClientTextUtils.setText(playerNameUBaseText, playerName)
		else
			local playerInfo = pg.game.chat:getPlayerInfo(data.uid)

			if playerInfo then
				local playerName = playerInfo.playerName
				local _h = BossRushChallengeCtrl._platformHooks

				playerName = _h and _h.getMaskedPlayerDisplayName and _h.getMaskedPlayerDisplayName(self, data.uid, playerInfo, playerName) or playerName

				ClientTextUtils.setText(playerNameUBaseText, playerName)
			else
				pg.game.chat:getPlayerInfoFromServer(data.uid, nil, function()
					playerInfo = pg.game.chat:getPlayerInfo(data.uid)

					if playerInfo then
						local playerName = playerInfo.playerName
						local _h = BossRushChallengeCtrl._platformHooks

						playerName = _h and _h.getMaskedPlayerDisplayName and _h.getMaskedPlayerDisplayName(self, data.uid, playerInfo, playerName) or playerName

						ClientTextUtils.setText(playerNameUBaseText, playerName)
					end
				end)
			end
		end

		playerHeadUButton:TryChangePage("Empty", data.empty and 1 or 0)

		if not data.empty and data.petInfo.templateId then
			petIconUImage.url = LuaUIUtils.getPetIcon(PetData[data.petInfo.templateId].iconName, LuaUIUtils.PET_ICON, data.petInfo.label)
		end

		button.enabledTooltip = not data.empty

		function button.luaRenderTooltip(button2, popup)
			local petList = {}

			for index, pet in ipairs(data.pList) do
				local cData = PetData[pet.templateId]

				table.insert(petList, {
					mainElementType = cData.mainElementType,
					coreAbilityId = pet.coreAbilityId,
					icon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, pet.label),
					level = pet.level,
					cp = pet.cp,
					name = pg.getLocalizationText(pet.name)
				})
			end

			UICardRenderUtils.render1Plus3Pet(popup, {
				petList = petList,
				isSelf = data.isSelf
			})
		end
	end

	function self.view.listPlayerUList.luaClick(button, data)
		if self.isShow then
			return
		end

		if data.uid == pg.me.uid then
			pg.global.ui.petManagement:open({
				isBossRush = true,
				levelId = self.levelId
			}, nil, nil, nil, nil, true)
		elseif button.enabledTooltip then
			button:OpenTooltip()
		end
	end

	LuaUIUtils.bindCommonTipInfo(self.view.btnTankUButton, pg.getGameString("BOSS_RUSH_TANK_TIP"))

	function self.view.selectTankUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local playerNameUText = objectReference:GetRefValue("playerNameUText")
		local petIconUImage = objectReference:GetRefValue("petIconUImage")
		local playerName2UBaseText = objectReference:GetRefValue("playerName2UBaseText")

		button:TryChangePage("Belong", data.uid == pg.me.uid and 1 or 0)
		button:TryChangePage("isTank", pg.space.selectedTankEntId == data.entId and 1 or 0)
		button:TryChangePage("Teammate", data.index - 1)

		local playerInfo = pg.game.chat:getPlayerInfo(data.uid)

		if playerInfo then
			ClientTextUtils.setText(playerNameUText, playerInfo.playerName)
			ClientTextUtils.setText(playerName2UBaseText, playerInfo.playerName)
		end

		petIconUImage.url = LuaUIUtils.getPetIcon(PetData[data.petInfo.templateId].iconName, LuaUIUtils.PET_ICON, data.petInfo.label)
	end

	function self.view.selectTankUList.luaClick(button, data)
		if data.uid == nil then
			return
		end

		self.view.selectTankUList:RefreshList()

		self.selectTankExpand = false

		self.view.panelTankUButton:TryChangePage("expand", self.selectTankExpand and 1 or 0)
		self.view.panelTankUButton:TryChangePage("Teammate", data.index - 1)
		pg.me:selectTankEntId(data.entId)
	end

	self:refreshTeamInfo()
end

function BossRushChallengeCtrl:refreshTeamInfo()
	if self.type == 0 then
		self:refreshChallengeTeamInfo()
	elseif self.type == 1 then
		self:refreshHistoryChallengeRecord()
	end
end

function BossRushChallengeCtrl:refreshHistoryChallengeRecord()
	local levelData = self.levelData

	if not levelData or not levelData.bossId then
		return
	end

	local record

	if self.isOpen then
		record = pg.me.curBossRushCycBestScoreTeamInfo[levelData.bossId]
	else
		record = nil
	end

	if not record then
		return
	end

	local teamInfo = {}

	for i, info in ipairs(record) do
		local petInfo = info.pets and info.pets[1]

		table.insert(teamInfo, {
			isReady = true,
			uid = info.uid,
			petInfo = petInfo,
			empty = petInfo == nil
		})
	end

	self.memTeamInfo = teamInfo

	self.view.listPlayerUList:SetList(teamInfo)
end

function BossRushChallengeCtrl:refreshChallengeTeamInfo()
	if not pg.me:isInTeam() or pg.me:isTeamLeader() then
		ClientTextUtils.setText(self.view.confirmUText, pg.getGameString("TEAM_START_CHALLENGE"))
	else
		local isReady = BossRushUtils.isPlayerReady(pg.me.id, self.levelId)
		local text = isReady and pg.getGameString("TEAM_CANCEL_READY") or pg.getGameString("TEAM_READY")

		ClientTextUtils.setText(self.view.confirmUText, text)
		self.view.btnConfirmUButton:TryChangePage("Type", isReady and 1 or 0)
	end

	local botUidList = pg.space.playerBotUidList or {}
	local showReady = pg.me:isInTeam() or #botUidList > 0

	self.view.readyUWidget:SetActive(showReady)

	local teamInfo = {}
	local teamInfo2 = {}
	local prepareCount = 0

	if pg.me:isInTeam() then
		local curTeamInfo = pg.me:getCurTeamInfo()

		for i, uid in ipairs(curTeamInfo.sortList) do
			local entId = curTeamInfo.membersInfo[uid].entityId
			local pList = pg.space.teamerInfos[entId] and pg.space.teamerInfos[entId].levelBatPetList

			pList = pList and pList[self.levelId]

			local petInfo = pList and pList[1]
			local isReady = BossRushUtils.isPlayerReady(entId, self.levelId) or pg.me:isUidTeamLeader(uid)

			table.insert(teamInfo, {
				uid = uid,
				petInfo = petInfo,
				isReady = isReady,
				empty = petInfo == nil,
				pList = pList,
				isSelf = uid == pg.me.uid,
				entId = entId
			})

			if petInfo and LuaUIUtils.isPetTank(petInfo.templateId) then
				table.insert(teamInfo2, {
					uid = uid,
					petInfo = petInfo,
					index = i,
					entId = entId
				})
			end

			if isReady then
				prepareCount = prepareCount + 1
			end
		end
	else
		local pList = pg.space.teamerInfos[pg.me.id] and pg.space.teamerInfos[pg.me.id].levelBatPetList

		pList = pList and pList[self.levelId]

		local petInfo = pList and pList[1]

		table.insert(teamInfo, {
			isReady = true,
			isSelf = true,
			uid = pg.me.uid,
			petInfo = petInfo,
			empty = petInfo == nil,
			pList = pList,
			entId = pg.me.id
		})

		prepareCount = prepareCount + 1

		if petInfo and LuaUIUtils.isPetTank(petInfo.templateId) then
			table.insert(teamInfo2, {
				index = 1,
				uid = pg.me.uid,
				petInfo = petInfo
			})
		end
	end

	for _, entId in ipairs(botUidList) do
		local pLists = pg.space.teamerInfos[entId] and pg.space.teamerInfos[entId].levelBatPetList
		local pList = pLists and pLists[self.levelId]

		if pList == nil then
			pList = pLists and pLists[0]
		end

		local petInfo = pList and pList[1]

		table.insert(teamInfo, {
			isReady = true,
			isAi = true,
			isSelf = false,
			uid = entId,
			petInfo = petInfo,
			empty = petInfo == nil,
			pList = pList,
			entId = entId
		})

		prepareCount = prepareCount + 1
	end

	local teamMembersCount = #teamInfo

	self.view.btnConfirmUButton.interactable = not pg.me:isTeamLeader() or prepareCount == teamMembersCount

	ClientTextUtils.setText(self.view.readyUBaseText, prepareCount, "/", teamMembersCount)

	if showReady and prepareCount == teamMembersCount then
		self.view.fxRefreshAnimation:Play()
	end

	self.prepareCount = prepareCount

	for i = #teamInfo + 1, 4 do
		table.insert(teamInfo, {
			tIndex = 1
		})
	end

	self.memTeamInfo = teamInfo

	self.view.listPlayerUList:SetList(teamInfo)
	self.view.panelTankUButton:SetActive(false)

	if pg.me:isInTeam() then
		self:refreshOpenLevelMatch()

		if not pg.me:isTeamLeader() and not self.isMatchOpenLevel and BossRushUtils.getCurBossRushPlace() == Const.BossRushTeleportTarget.Prepare then
			pg.global.ui.tips:showTextTip(pg.getGameString("BOSS_RUSH_OPEN_LEVEL_WAIT_LEADER"))
		end
	end
end

function BossRushChallengeCtrl:refreshOpenLevelMatch()
	self.isMatchOpenLevel = pg.space.openLevelId == self.levelId or self.tempOpenLevelId == self.levelId
	self.tempOpenLevelId = nil

	self.view.textWarningTipsUBaseText:SetActive(not self.isMatchOpenLevel)

	if not pg.me:isTeamLeader() then
		self.view.btnConfirmUButton.interactable = self.isMatchOpenLevel
	end

	if not self.isMatchOpenLevel then
		ClientTextUtils.setText(self.view.textWarningTipsUBaseText, pg.getGameString("BOSS_RUSH_OPEN_LEVEL_NOT_MATCH"))
	end
end

function BossRushChallengeCtrl:refreshTankSelected(isTankChange)
	local selectIndex = -1
	local tankIndex = -1

	for i, data in ipairs(self.selectTankData) do
		if data.entId == pg.space.selectedTankEntId then
			selectIndex = i - 1
			tankIndex = data.index - 1

			break
		end
	end

	if selectIndex >= 0 then
		self.view.panelTankUButton:TryChangePage("Teammate", tankIndex)
		self.view.selectTankUList:SelectItem(selectIndex)
	else
		if pg.space.selectedTankEntId and pg.space.selectedTankEntId ~= "" and not self.hasReset then
			self.hasReset = true

			pg.me:selectTankEntId("")
			pg.global.ui.tips:showTextTip(pg.getGameString("BOSS_RUSH_TANK_SELECT_PET_CHANGE"))
		end

		self.view.panelTankUButton:TryChangePage("Teammate", 4)
	end

	if isTankChange then
		self.view.selectTankUList:RefreshList()
		self.view.listPlayerUList:RefreshList()

		self.hasReset = false

		if pg.me.id == pg.space.selectedTankEntId then
			pg.global.ui.tips:showTextTip(pg.getGameString("BOSS_RUSH_BECOME_TANK_TIP"))
		end
	end
end

function BossRushChallengeCtrl:initBuffInfo()
	function self.view.buffUList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	function self.view.buffUList.luaClick(button, data)
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			buffIndex = 1,
			tab = 0,
			isShow = true
		})
	end

	function self.view.helpUList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	function self.view.helpUList.luaClick(button, data)
		if not pg.me:isInTeam() or pg.me:isTeamLeader() then
			pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
				tab = 1
			})
		end
	end

	function self.view.specialBuffUList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	function self.view.specialBuffUList.luaClick(button, data)
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			isShow = true,
			tab = 0
		})
	end

	function self.view.normalBuffUList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	function self.view.normalBuffUList.luaClick(button, data)
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			buffIndex = 1,
			tab = 0,
			isShow = true
		})
	end

	function self.view.cycleBuffUList.luaRenderItem(button, index, data)
		BossRushUtils.renderBuffItem(button, index, data)
	end

	function self.view.cycleBuffUList.luaClick(button, data)
		local canSelect = not pg.me:isInTeam() or pg.me:isTeamLeader()

		canSelect = canSelect and pg.me.space:isBossRushEnv()

		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT, {
			tab = 0,
			isShow = not canSelect
		})

		if self.buffIsNew then
			self.buffIsNew = false

			self.view.cycleBuffUList:SetList(BossRushUtils.getSelectBatBuffs())
		end
	end

	function self.view.seasonBuffBtnSearchUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.BOSS_RUSH_HELP_SEASON_BUFF)
	end

	function self.view.seasonBuffBtnSearch2UButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.BOSS_RUSH_HELP_SEASON_BUFF)
	end

	function self.view.cycleBuffBtnSearchUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.BOSS_RUSH_HELP_CYCLE_BUFF)
	end

	self:refreshBuffInfo()
end

function BossRushChallengeCtrl:refreshBuffInfo()
	if self.type == 0 then
		local key = RedDotConst.RedDotPath.BOSS_RUSH_MAIN_BUFF .. pg.me.curBossRushCycleId

		self.buffIsNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.BOSS_RUSH, key, true)

		self.view.buffUList:SetList(BossRushUtils.getNormalBuffList(pg.space.teamLeaderSeasonStar))
		self.view.cycleBuffUList:SetList(BossRushUtils.getSelectBatBuffs(self.buffIsNew))
		self.view.helpUList:SetList(BossRushUtils.getUnlockMingameBuffs())
	elseif self.type == 1 then
		local bossId = self.levelData and self.levelData.bossId

		self.view.buffUList:SetList(BossRushUtils.getHistoryRecordSeasonBuffs(self.isOpen, bossId, true))
		self.view.cycleBuffUList:SetList(BossRushUtils.getHistoryRecordBatBuffs(self.isOpen, bossId))
	elseif self.type == 2 then
		self.view.normalBuffUList:SetList(BossRushUtils.getNormalBuffList())
		self.view.specialBuffUList:SetList(BossRushUtils.getSpecialBuffList(self.isOpen))
	end
end

function BossRushChallengeCtrl:renderBossModel()
	if not self.uiScene then
		return
	end

	self.showLuckyPet = false

	if not self.isShow and self.target then
		local leftEntity = self.target == Const.BossRushTeleportTarget.BossLeft and {
			applyAnim = true,
			templateId = self.levelData.bossId
		} or nil
		local rightEntity = self.target == Const.BossRushTeleportTarget.BossRight and {
			applyAnim = true,
			templateId = self.levelData.bossId
		} or nil
		local midEntity = self.target == Const.BossRushTeleportTarget.BossMid and {
			applyAnim = true,
			templateId = self.levelData.bossId
		} or nil

		self.uiScene:setEntities(leftEntity, rightEntity, midEntity, nil, nil)

		if self.target == Const.BossRushTeleportTarget.BossMid then
			self.uiScene:setLuckyPetModel(self.cycleData.recommendPet, self.view.luckyUButton.transform)
		end
	end

	if self.showTarget then
		self.uiScene:switchCameraPos(self.showTarget)
		self:refreshDof(true)
	end

	self:refreshBossBaseInfo(self.showTarget)
	self.view.luckyPetUWidget:SetActive(self.showLuckyPet)
end

function BossRushChallengeCtrl:refreshDof(visible)
	local visibleL, visibleM, visibleR = false, false, false

	if self.showTarget == Const.BossRushTeleportTarget.BossLeft then
		visibleL = visible
	elseif self.showTarget == Const.BossRushTeleportTarget.BossMid then
		visibleM = visible
	elseif self.showTarget == Const.BossRushTeleportTarget.BossRight then
		visibleR = visible
	end

	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossRushChallengeL, visibleL)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossRushChallengeM, visibleM)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossRushChallengeR, visibleR)
end

function BossRushChallengeCtrl:getShowTarget()
	if not self.isShow or not self.levelIds then
		return
	end

	if self.levelId == self.levelIds[1] then
		return Const.BossRushTeleportTarget.BossLeft
	elseif self.levelId == self.levelIds[2] then
		return Const.BossRushTeleportTarget.BossMid
	elseif self.levelId == self.levelIds[3] then
		return Const.BossRushTeleportTarget.BossRight
	end
end

function BossRushChallengeCtrl:onVisibleChange(visible)
	if self.uiScene and not self.isShow then
		self.uiScene:setAllModelVisible(visible)
		self.uiScene:setEnvComponentEnable(visible)
	end

	self:refreshDof(visible)
end

function BossRushChallengeCtrl:onDestroy()
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossRushChallengeL, false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossRushChallengeM, false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossRushChallengeR, false)
	pg.game.chat:clearTeamMiniChatWidget()
	UICtrl.onDestroy(self)
end

function BossRushChallengeCtrl:closeBattleResultPanel()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_BATTLE_RESULT) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_BOSS_RUSH_BATTLE_RESULT)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_BATTLE_DETAIL_RESULT) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_BOSS_RUSH_BATTLE_DETAIL_RESULT)
	end
end

function BossRushChallengeCtrl:onOpen(info)
	self:closeBattleResultPanel()
	UICtrl.onOpen(self, info)
end

function BossRushChallengeCtrl:onShow()
	return
end

function BossRushChallengeCtrl:onHide()
	return
end

return BossRushChallengeCtrl
