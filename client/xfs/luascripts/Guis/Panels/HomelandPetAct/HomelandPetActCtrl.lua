-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetAct\\HomelandPetActCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UICtrl = require("Guis.UICtrl")
local HomelandPetActCtrl = Class.LightClass("HomelandPetActCtrl", UICtrl)
local HomeEventTextData = require("Data.home_event_text_data")
local PetData = require("Data.pet_data")
local PuppetData = require("Data.puppet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local GameStringConfig = require("Data.gamestring_config_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local HomeEventTypeData = require("Data.home_event_type_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandAreaData = require("Data.homeland_area_data")
local ItemData = require("Data.item_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Const = require("Common.Const.Const")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformNameMaskRefreshHelper = require("SDK.Platform.PlatformNameMaskRefreshHelper")

local function getMaskedHomeReportFriendName(friendId, fallbackName)
	local friendInfo = pg.game.chat:getPlayerInfo(friendId)
	local friendName = friendInfo and friendInfo.playerName or fallbackName or ""

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ToastName,
		uid = friendId,
		playerInfo = friendInfo,
		rawText = ClientTextUtils.getLocalizationText(friendName)
	})
end

HomelandPetActCtrl.PathFindMaxDistanceSqrt = 900
HomelandPetActCtrl.PetPathFindDistance = 1.5
HomelandPetActCtrl.PetPathFindNoTeleportDistance = 3.5
HomelandPetActCtrl.InteractPathFindInset = 0.1
HomelandPetActCtrl.PathFindPositionEpsilonSqr = 0.0001
HomelandPetActCtrl.PET_PATH_FIND_RETRY_INTERVAL = 0.2
HomelandPetActCtrl.PET_PATH_FIND_RETRY_MAX_COUNT = 50
HomelandPetActCtrl.PathFindTargetType = {
	Pet = 1,
	Mutation = 4,
	LoosenGift = 3,
	HomeRewardBox = 2
}
HomelandPetActCtrl.messages = {
	[MessageName.PLAYER_ONTELEPORT] = {
		"onPlayerTeleport",
		false
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		false
	}
}

function HomelandPetActCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.tillHelpReportSolved = false
	self.info = info

	if info then
		self.view.uIPbHomePetReportIn:TryChangePage("Panel", info.type)

		if info.type == 0 then
			self:refreshReport()
		else
			self:refreshLog(false)
			self:startTimer(function()
				self.view.btnNotFinishUButton:TryChangePage("button", 5)
			end, 0.1)
		end
	end

	PlatformNameMaskRefreshHelper.register(self, function(ctrl)
		if ctrl.info and ctrl.info.type == 0 then
			if not ctrl._platformNameMaskShowingOfflineReward then
				ctrl:refreshReport()
			end

			return
		end

		if ctrl.info then
			ctrl:refreshLog(ctrl._platformNameMaskLogIsFinish == true)
		end
	end)
end

function HomelandPetActCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:trySolveTillHelpReports()
		self:close()
	end

	function self.view.btnCloseUButton.luaClick()
		self:trySolveTillHelpReports()
		self:close()
	end

	function self.view.btnNotFinishUButton.luaClick()
		self.view.btnNotFinishUButton:TryChangePage("button", 5)
		self.view.btnFinishUButton:TryChangePage("button", 0)
		self:refreshLog(false)
	end

	function self.view.btnFinishUButton.luaClick()
		self.view.btnNotFinishUButton:TryChangePage("button", 0)
		self.view.btnFinishUButton:TryChangePage("button", 5)
		self:refreshLog(true)
	end

	function self.view.tabOffline.luaClick()
		self:refreshOfflineReward()
	end

	function self.view.tabPetAct.luaClick()
		self:refreshReport()
	end
end

function HomelandPetActCtrl:buildCurrencyText(num1, num2)
	num1 = num1 or 0
	num2 = num2 or 0

	if num1 > 0 and num2 > 0 then
		return pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_CURRENCY_1"), num1) .. " " .. pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_CURRENCY_2"), num2)
	elseif num1 > 0 then
		return pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_CURRENCY_1"), num1)
	elseif num2 > 0 then
		return pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_CURRENCY_2"), num2)
	end

	return pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_CURRENCY_1"), 0) .. " " .. pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_CURRENCY_2"), 0)
end

function HomelandPetActCtrl:getRevenueNumber()
	local iconId1 = HomelandConfigData.homeCurrencyId or 1010
	local iconId2 = HomelandConfigData.homeVoucherId or 1011
	local num1 = 0
	local num2 = 0
	local rewardData = self.model:getOfflineRewardData()

	for _, data in ipairs(rewardData) do
		local priceInfo = Utils.getHomeItemPrice(data.id)

		if priceInfo then
			if priceInfo[1] == iconId1 then
				num1 = num1 + priceInfo[2] * data.num
			elseif priceInfo[1] == iconId2 then
				num2 = num2 + priceInfo[2] * data.num
			end
		end
	end

	return num1, num2
end

function HomelandPetActCtrl:refreshOfflineReward()
	self._platformNameMaskShowingOfflineReward = true

	self.view.listRewardUList.gameObject:SetActiveEx(true)
	self.view.reportListUList.gameObject:SetActiveEx(false)

	local rewardData = self.model:getOfflineRewardData()

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		data.autoHor = true
		data.padding = 8

		LuaUIUtils.renderRewardItem(button, data)
	end

	self.view.listRewardUList:SetList(rewardData)
	self.view.emptyUWidget.gameObject:SetActiveEx(false)
	self.view.emptyOffline.gameObject:SetActiveEx(#rewardData == 0)

	local totalSeconds = pg.me.simulateOutputDuration or 0
	local leaveTime = LuaUIUtils.getCountDownString(totalSeconds, UIConst.TimeType.Short, true)

	if #rewardData > 0 then
		ClientTextUtils.setText(self.view.txtDetailsUBaseText, string.format(pg.getGameString("HOMELAND_LOG_WITH_OUTPUT"), leaveTime))
	else
		ClientTextUtils.setText(self.view.txtDetailsUBaseText, string.format(pg.getGameString("HOMELAND_LOG_NO_OUTPUT"), leaveTime))
	end
end

function HomelandPetActCtrl:refreshReport()
	self._platformNameMaskShowingOfflineReward = false

	self.view.reportListUList.gameObject:SetActiveEx(true)
	self.view.listRewardUList.gameObject:SetActiveEx(false)

	local actionData = self.model:getPetActData(false)

	if pg.me.lastLeaveHomelandTs == 0 then
		actionData = {}
	end

	self.hasTillHelpReport = false

	local num1, num2 = self:getRevenueNumber()

	if num1 > 0 or num2 > 0 then
		local textIcon = self:buildCurrencyText(num1, num2)
		local textProduction = pg.getFormatText(pg.getGameString("HOMELAND_PRODUCTION_VALUE"), textIcon)

		table.insert(actionData, 1, {
			specialMode = 1,
			text = textProduction
		})
	end

	for _, data in ipairs(actionData) do
		if data.eventId == Const.HOME_EVENT_TYPE.HELP_LOOSEN then
			self.hasTillHelpReport = true

			break
		end
	end

	if #actionData > 0 then
		function self.view.reportListUList.luaRenderItem(button, index, data)
			local itemObjectReference = button:GetComponent("ObjectReference")
			local txtDetailsUBaseText = itemObjectReference:GetRefValue("txtDetailsUBaseText")
			local imgBgGoUImage = itemObjectReference:GetRefValue("imgBgGoUImage")

			button:TryChangePage("MutantCrops", 0)

			if data.specialMode == 1 then
				ClientTextUtils.setText(txtDetailsUBaseText, data.text)

				function button.luaClick()
					self.view.tabPetAct:TryChangePage("button", 0)
					self.view.tabOffline:TryChangePage("button", 5)
					self.view.tabOffline:OnClickSimulate()
				end

				return
			end

			if data.eventId == Const.HOME_EVENT_TYPE.MUTATION then
				self:renderMutationLog(button, txtDetailsUBaseText, imgBgGoUImage, data, false)

				return
			end

			if data.eventId == Const.HOME_EVENT_TYPE.HELP_LOOSEN then
				self:renderHelpLoosenLog(button, txtDetailsUBaseText, imgBgGoUImage, data)

				return
			end

			if data.eventId == Const.HOME_EVENT_TYPE.LOOSEN_GIFT then
				self:renderLoosenGiftLog(button, txtDetailsUBaseText, imgBgGoUImage, data, false)

				return
			end

			local eventText = ClientTextUtils.getLocalizationText(HomeEventTextData[data.textId].text)
			local needPathFind = true

			if data.otherPetName then
				eventText = string.format(eventText, ClientTextUtils.getLocalizationText(data.name), ClientTextUtils.getLocalizationText(data.otherPetName), ClientTextUtils.getLocalizationText(data.name))
			elseif data.eventId == 5 then
				needPathFind = data.pos ~= nil
				eventText = string.format(eventText, getMaskedHomeReportFriendName(data.friendId, data.friendName))
			else
				eventText = string.format(eventText, ClientTextUtils.getLocalizationText(data.name))
			end

			button:TryChangePage("Type", 0)
			ClientTextUtils.setText(txtDetailsUBaseText, eventText)

			if needPathFind then
				imgBgGoUImage:SetActive(true)

				function button.luaClick()
					if data.eventId == 5 then
						self:pathFindToHomeRewardBox()
					else
						self:pathFindToPet(data.petId, data.pos)
					end

					self:close()
				end
			else
				imgBgGoUImage:SetActive(false)

				button.luaClick = nil
			end
		end

		self.view.reportListUList:SetList(actionData)
	end

	self.view.emptyUWidget.gameObject:SetActiveEx(#actionData == 0)
	self.view.emptyOffline.gameObject:SetActiveEx(false)

	local totalSeconds = pg.me.simulateOutputDuration or 0
	local leaveTime = LuaUIUtils.getCountDownString(totalSeconds, UIConst.TimeType.Short, true)

	if #actionData > 0 then
		ClientTextUtils.setText(self.view.txtDetailsUBaseText, string.format(pg.getGameString("HOME_LOG_TIME_DES"), leaveTime))
	else
		ClientTextUtils.setText(self.view.txtDetailsUBaseText, string.format(pg.getGameString("HOME_REPORT_BACK_HOME_DESC"), leaveTime))
	end

	local emojiUrl = self:getEmojiUrl(actionData)

	if emojiUrl ~= "" then
		self.view.emojiUContainer.url = emojiUrl
	else
		self.view.emojiUContainer:LoadDefaultUrlManually(nil)
	end
end

function HomelandPetActCtrl:refreshLog(isFinish)
	self._platformNameMaskLogIsFinish = isFinish == true

	local logActionData = self.model:getPetActData(isFinish)

	if isFinish then
		logActionData = self.model:getPetResolvedActData()
	end

	if pg.me.lastLeaveHomelandTs == 0 then
		logActionData = {}
	end

	local logActionShowData = {}
	local time = ""

	for i = 1, #logActionData do
		local actionData = logActionData[i]

		if isFinish then
			local curTime = TimeUtils.timeToFormatString4(actionData.solvedTs)

			if time ~= curTime then
				table.insert(logActionShowData, {
					tIndex = 0,
					time = actionData.solvedTs
				})

				time = curTime
			end
		else
			local curTime = TimeUtils.timeToFormatString4(actionData.createTs)

			if time ~= actionData.createTs then
				table.insert(logActionShowData, {
					tIndex = 0,
					time = actionData.createTs
				})

				time = curTime
			end
		end

		actionData.tIndex = 1

		table.insert(logActionShowData, actionData)
	end

	function self.view.logListUList.luaRenderItem(button, index, data)
		local itemObjectReference = button:GetComponent("ObjectReference")

		if data.tIndex == 0 then
			local txtTimeUBaseText = itemObjectReference:GetRefValue("txtTimeUBaseText")

			ClientTextUtils.setText(txtTimeUBaseText, TimeUtils.timeToFormatString4(data.time))
		else
			local txtDetailsUBaseText = itemObjectReference:GetRefValue("txtDetailsUBaseText")
			local imgBgGoUImage = itemObjectReference:GetRefValue("imgBgGoUImage")

			button:TryChangePage("MutantCrops", 0)

			if data.eventId == Const.HOME_EVENT_TYPE.MUTATION then
				self:renderMutationLog(button, txtDetailsUBaseText, imgBgGoUImage, data, isFinish)

				return
			end

			if data.eventId == Const.HOME_EVENT_TYPE.PRODUCTION then
				self:renderProductionLog(button, txtDetailsUBaseText, imgBgGoUImage, data)

				return
			end

			if data.eventId == Const.HOME_EVENT_TYPE.HELP_LOOSEN then
				self:renderHelpLoosenLog(button, txtDetailsUBaseText, imgBgGoUImage, data)

				return
			end

			if data.eventId == Const.HOME_EVENT_TYPE.LOOSEN_GIFT then
				self:renderLoosenGiftLog(button, txtDetailsUBaseText, imgBgGoUImage, data, isFinish)

				return
			end

			local eventText = ClientTextUtils.getLocalizationText(HomeEventTextData[data.textId].text)
			local needPathFind = true

			if data.otherPetName then
				eventText = string.format(eventText, ClientTextUtils.getLocalizationText(data.name), ClientTextUtils.getLocalizationText(data.otherPetName), ClientTextUtils.getLocalizationText(data.name))
			elseif data.eventId == 5 then
				needPathFind = data.pos ~= nil
				eventText = string.format(eventText, getMaskedHomeReportFriendName(data.friendId, data.friendName))
			else
				eventText = string.format(eventText, ClientTextUtils.getLocalizationText(data.name))
			end

			button:TryChangePage("Type", isFinish and 1 or 0)

			if isFinish then
				needPathFind = false
			end

			ClientTextUtils.setText(txtDetailsUBaseText, eventText)

			if needPathFind then
				function button.luaClick()
					if data.eventId == 5 then
						self:pathFindToHomeRewardBox()
					else
						self:pathFindToPet(data.petId, data.pos)
					end

					self:close()
				end

				imgBgGoUImage:SetActive(true)
			else
				imgBgGoUImage:SetActive(false)

				button.luaClick = nil
			end
		end
	end

	self.view.logListUList:SetList(logActionShowData)

	local emojiUrl = self:getEmojiUrl(logActionData)

	if emojiUrl ~= "" then
		self.view.emojiUContainer.url = emojiUrl
	else
		self.view.emojiUContainer:LoadDefaultUrlManually(nil)
	end

	self.view.emptyUWidget.gameObject:SetActiveEx(#logActionData == 0)
	self.view.emptyOffline.gameObject:SetActiveEx(false)
end

function HomelandPetActCtrl:getPetPathFindPosition(petId, fallbackPos)
	local petEntity = petId and pg.getEntity(petId)

	if not petEntity then
		return fallbackPos
	end

	local petPos = petEntity:getPosition()
	local petForward = petEntity:getForward()

	if not petForward then
		return petPos
	end

	local frontDirection = Vector3.New(petForward.x, 0, petForward.z)

	if frontDirection:Magnitude() < 0.0001 then
		return petPos
	end

	local targetPos = petPos + Vector3.Normalize(frontDirection) * HomelandPetActCtrl.PetPathFindDistance

	return PhysicsUtils.getGroundPos(targetPos) or targetPos
end

function HomelandPetActCtrl:isPetPathFindTargetReached(petId, targetPos)
	if not pg.me or not targetPos then
		return false
	end

	local playerPos = pg.me:getPosition()

	if AutoPathFindUtils.checkTwoPosClose(pg.me, playerPos.x, playerPos.y, playerPos.z, targetPos.x, targetPos.y, targetPos.z) then
		return true
	end

	local petEntity = petId and pg.getEntity(petId)

	if not petEntity or not petEntity.getInteractiveDist then
		return false
	end

	local interactiveDist = petEntity:getInteractiveDist() or 0
	local offset = playerPos - petEntity:getPosition()

	offset.y = 0

	local noTeleportDistance = math.max(interactiveDist, HomelandPetActCtrl.PetPathFindNoTeleportDistance)

	return offset:SqrMagnitude() <= noTeleportDistance * noTeleportDistance
end

function HomelandPetActCtrl:requestTeleportForPathFind(target)
	local breakPoint = target and target.teleportPoint or HomeLandUtils.getHomePetBreakTeleportPoint()

	if not target or not breakPoint or not pg.space or not pg.me then
		return false
	end

	self:clearPendingPathFindTarget()

	target.sceneId = pg.space.sceneId
	self.pendingPathFindTarget = target

	pg.me:CallServerMsgTeleportToScene(pg.space.sceneId, breakPoint, false)

	return true
end

function HomelandPetActCtrl:requestTeleportForPetPathFind(petId, fallbackPos)
	local petEntity = petId and pg.getEntity(petId)
	local areaId = HomeLandUtils.getHomePetAreaId(pg.space, petId, petEntity)

	if areaId == nil then
		return false
	end

	local teleportPoint = HomeLandUtils.getHomePetBreakTeleportPoint()

	if not teleportPoint then
		return false
	end

	return self:requestTeleportForPathFind({
		targetType = HomelandPetActCtrl.PathFindTargetType.Pet,
		petId = petId,
		fallbackPos = fallbackPos,
		teleportPoint = teleportPoint
	})
end

function HomelandPetActCtrl:startPathFindToPet(petId, fallbackPos, hasTeleported)
	local targetPos = self:getPetPathFindPosition(petId, fallbackPos)

	if not targetPos then
		return false
	end

	return pg.me:pawnAutoPathFinding(targetPos, function(arrived)
		if arrived or self:isPetPathFindTargetReached(petId, targetPos) then
			return
		end

		if not hasTeleported and self:requestTeleportForPetPathFind(petId, fallbackPos) then
			return
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("INTERACT_ANIMATION_CANT_REACH_POINT"))
	end, AutoPathFindUtils.PathFindType.Voxel)
end

function HomelandPetActCtrl:pathFindToPet(petId, fallbackPos)
	local targetPos = self:getPetPathFindPosition(petId, fallbackPos)

	if not targetPos then
		return self:requestTeleportForPetPathFind(petId, fallbackPos)
	end

	local curPos = pg.me:getPosition()

	if self:isPetPathFindTargetReached(petId, targetPos) or Vector3.SqrDistance(curPos, targetPos) < HomelandPetActCtrl.PathFindMaxDistanceSqrt then
		self:clearPendingPathFindTarget()

		return self:startPathFindToPet(petId, fallbackPos, false)
	end

	return self:requestTeleportForPetPathFind(petId, fallbackPos)
end

function HomelandPetActCtrl:onPlayerTeleport()
	local target = self.pendingPathFindTarget

	if not target or not pg.space or pg.space.sceneId ~= target.sceneId then
		self:clearPendingPathFindTarget()

		return
	end

	if target.targetType == HomelandPetActCtrl.PathFindTargetType.HomeRewardBox then
		self:clearPendingPathFindTarget()
		self:pathFindToHomeRewardBox(true)

		return
	end

	if target.targetType == HomelandPetActCtrl.PathFindTargetType.LoosenGift then
		self:clearPendingPathFindTarget()
		self:pathFindToLoosenGift(true)

		return
	end

	if target.targetType == HomelandPetActCtrl.PathFindTargetType.Mutation then
		self:clearPendingPathFindTarget()
		self:pathFindToMutation(target.ornamentId, target.itemId, true)

		return
	end

	if not self:tryStartPendingPetPathFind() then
		self:startPendingPetPathFindRetry()
	end
end

function HomelandPetActCtrl:onSceneLoaded()
	if not self:tryStartPendingPetPathFind() then
		self:startPendingPetPathFindRetry()
	end
end

function HomelandPetActCtrl:renderMutationLog(button, txtDetailsUBaseText, imgBgGoUImage, data, isFinish)
	local itemCfg = ItemData[data.itemId]
	local itemName = itemCfg and ClientTextUtils.getLocalizationText(itemCfg.itemName) or ""
	local eventText = string.format(ClientTextUtils.getLocalizationText(HomeEventTextData[data.textId].text), itemName)

	button:TryChangePage("Type", isFinish and 1 or 0)
	button:TryChangePage("MutantCrops", 1)
	ClientTextUtils.setText(txtDetailsUBaseText, eventText)

	if isFinish then
		if imgBgGoUImage then
			imgBgGoUImage:SetActive(false)
		end

		function button.luaClick()
			pg.global.showBubbleMessage(NoticeDef.HOME_MUTATION_COLLECTED)
		end
	else
		if imgBgGoUImage then
			imgBgGoUImage:SetActive(true)
		end

		function button.luaClick()
			self:pathFindToMutation(data.ornamentId, data.itemId)
			self:close()
		end
	end
end

function HomelandPetActCtrl:pathFindToMutation(ornamentId, itemId, hasTeleported)
	local facility = pg.space.facility and pg.space.facility[ornamentId]
	local stillThere = facility and facility.specialOutputMap and facility.specialOutputMap[itemId] ~= nil

	if not stillThere then
		pg.global.showBubbleMessage(NoticeDef.HOME_MUTATION_COLLECTED)
		pg.me:reqSolveMutationEvent(itemId)

		return false
	end

	local ornamentInfo = pg.space.ornament and pg.space.ornament[ornamentId]
	local homeEntity = pg.game.home and pg.game.home:getHomeEntity(ornamentId)

	if not ornamentInfo or not homeEntity then
		pg.global.showBubbleMessageRaw(pg.getGameString("INTERACT_ANIMATION_CANT_REACH_POINT"))

		return false
	end

	local pos = homeEntity:getPosition()
	local curPos = pg.me:getPosition()

	if hasTeleported or Vector3.SqrDistance(curPos, pos) < HomelandPetActCtrl.PathFindMaxDistanceSqrt then
		self:clearPendingPathFindTarget()

		local xzPosOffset = curPos - pos

		xzPosOffset.y = 0

		local dir = Vector3.forward

		if xzPosOffset:SqrMagnitude() > HomelandPetActCtrl.PathFindPositionEpsilonSqr then
			dir = Vector3.Normalize(xzPosOffset)
		end

		local pathFindPos = pos + dir * (homeEntity:getInteractiveDist() - HomelandPetActCtrl.InteractPathFindInset)

		return pg.me:pawnAutoPathFinding(pathFindPos, nil, AutoPathFindUtils.PathFindType.Voxel)
	end

	local areaData = HomelandAreaData[ornamentInfo.areaId]

	if not areaData or not areaData.teleportPos then
		return false
	end

	return self:requestTeleportForPathFind({
		targetType = HomelandPetActCtrl.PathFindTargetType.Mutation,
		ornamentId = ornamentId,
		itemId = itemId,
		teleportPoint = areaData.teleportPos
	})
end

function HomelandPetActCtrl:renderProductionLog(button, txtDetailsUBaseText, imgBgGoUImage, data)
	button:TryChangePage("Type", 1)

	local textIcon = self:buildCurrencyText(data.num1, data.num2)
	local eventText = string.format(ClientTextUtils.getLocalizationText(HomeEventTextData[data.textId].text), textIcon)

	ClientTextUtils.setText(txtDetailsUBaseText, eventText)

	if imgBgGoUImage then
		imgBgGoUImage:SetActive(false)
	end

	button.luaClick = nil
end

function HomelandPetActCtrl:renderHelpLoosenLog(button, txtDetailsUBaseText, imgBgGoUImage, data)
	button:TryChangePage("Type", 0)

	local friendName = getMaskedHomeReportFriendName(data.friendId, data.friendName)
	local template = ClientTextUtils.getLocalizationText(HomeEventTextData[data.textId].text)
	local eventText = string.format(template, friendName, tostring(data.count or 1))

	ClientTextUtils.setText(txtDetailsUBaseText, eventText)

	if imgBgGoUImage then
		imgBgGoUImage:SetActive(false)
	end

	button.luaClick = nil
end

function HomelandPetActCtrl:renderLoosenGiftLog(button, txtDetailsUBaseText, imgBgGoUImage, data, isFinish)
	button:TryChangePage("Type", isFinish and 1 or 0)

	local friendName = getMaskedHomeReportFriendName(data.friendId, data.friendName)
	local eventText = string.format(ClientTextUtils.getLocalizationText(HomeEventTextData[data.textId].text), friendName)

	ClientTextUtils.setText(txtDetailsUBaseText, eventText)

	if isFinish then
		if imgBgGoUImage then
			imgBgGoUImage:SetActive(false)
		end

		button.luaClick = nil
	else
		if imgBgGoUImage then
			imgBgGoUImage:SetActive(true)
		end

		function button.luaClick()
			self:pathFindToLoosenGift()
			self:close()
		end
	end
end

function HomelandPetActCtrl:pathFindToRewardBox(staticId, targetType, hasTeleported)
	if not staticId or not targetType or not pg.space or not pg.me then
		return false
	end

	local rewardBoxEntity = pg.space:getEntityByStaticId(staticId)

	if not rewardBoxEntity then
		return false
	end

	local pos = rewardBoxEntity:getPosition()
	local interactiveDist = rewardBoxEntity:getInteractiveDist()
	local curPos = pg.me:getPosition()

	if hasTeleported or Vector3.SqrDistance(curPos, pos) < HomelandPetActCtrl.PathFindMaxDistanceSqrt then
		self:clearPendingPathFindTarget()

		local xzPosOffset = curPos - pos

		xzPosOffset.y = 0

		local dir = Vector3.forward

		if xzPosOffset:SqrMagnitude() > HomelandPetActCtrl.PathFindPositionEpsilonSqr then
			dir = Vector3.Normalize(xzPosOffset)
		end

		local pathFindPos = pos + dir * (interactiveDist - HomelandPetActCtrl.InteractPathFindInset)

		return pg.me:pawnAutoPathFinding(pathFindPos, nil, AutoPathFindUtils.PathFindType.Voxel)
	end

	return self:requestTeleportForPathFind({
		targetType = targetType
	})
end

function HomelandPetActCtrl:clearPendingPathFindTarget()
	if self.pendingPetPathFindRetryTimerId then
		TimerManager.removeTimer(self.pendingPetPathFindRetryTimerId)

		self.pendingPetPathFindRetryTimerId = nil
	end

	self.pendingPetPathFindRetryCount = nil
	self.pendingPathFindTarget = nil
end

function HomelandPetActCtrl:tryStartPendingPetPathFind()
	local target = self.pendingPathFindTarget

	if not target or target.targetType ~= HomelandPetActCtrl.PathFindTargetType.Pet or not pg.space or pg.space.sceneId ~= target.sceneId then
		return false
	end

	if not self:getPetPathFindPosition(target.petId, target.fallbackPos) then
		return false
	end

	if not self:startPathFindToPet(target.petId, target.fallbackPos, true) then
		return false
	end

	self:clearPendingPathFindTarget()

	return true
end

function HomelandPetActCtrl:startPendingPetPathFindRetry()
	local target = self.pendingPathFindTarget

	if self.pendingPetPathFindRetryTimerId or not target or target.targetType ~= HomelandPetActCtrl.PathFindTargetType.Pet then
		return
	end

	self.pendingPetPathFindRetryCount = self.pendingPetPathFindRetryCount or 0
	self.pendingPetPathFindRetryTimerId = TimerManager.addRepeatTimer(HomelandPetActCtrl.PET_PATH_FIND_RETRY_INTERVAL, function()
		if self:tryStartPendingPetPathFind() then
			return
		end

		self.pendingPetPathFindRetryCount = (self.pendingPetPathFindRetryCount or 0) + 1

		if self.pendingPetPathFindRetryCount >= HomelandPetActCtrl.PET_PATH_FIND_RETRY_MAX_COUNT then
			self:clearPendingPathFindTarget()
			pg.global.showBubbleMessageRaw(pg.getGameString("INTERACT_ANIMATION_CANT_REACH_POINT"))
		end
	end)
end

function HomelandPetActCtrl:pathFindToHomeRewardBox(hasTeleported)
	return self:pathFindToRewardBox(HomeLandUtils.getHomeRewardBoxId(), HomelandPetActCtrl.PathFindTargetType.HomeRewardBox, hasTeleported)
end

function HomelandPetActCtrl:pathFindToLoosenGift(hasTeleported)
	return self:pathFindToRewardBox(HomeLandUtils.getTillRewardBoxId(), HomelandPetActCtrl.PathFindTargetType.LoosenGift, hasTeleported)
end

function HomelandPetActCtrl:getEmojiUrl(actionData)
	local url = ""

	for _, data in pairs(actionData) do
		if data.eventId then
			local eventTypeData = HomeEventTypeData[data.eventId]

			if eventTypeData then
				if data.eventId ~= 5 and url == "" then
					url = eventTypeData.emoji
				end

				if data.eventId == 5 and url ~= "" then
					url = eventTypeData.emoji
				end
			end
		end
	end

	return url
end

function HomelandPetActCtrl:trySolveTillHelpReports()
	if self.tillHelpReportSolved then
		return
	end

	if self.info and self.info.type == 0 and self.hasTillHelpReport and pg.me and pg.me.space and pg.me.space:isSelfHomeland(pg.me) then
		self.tillHelpReportSolved = true

		pg.me:reqSolveTillHelpEvents()
	end
end

function HomelandPetActCtrl:onDestroy()
	PlatformNameMaskRefreshHelper.unregister(self)
	self:trySolveTillHelpReports()
	UICtrl.onDestroy(self)
end

function HomelandPetActCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandPetActCtrl:onShow()
	return
end

function HomelandPetActCtrl:onHide()
	return
end

return HomelandPetActCtrl
