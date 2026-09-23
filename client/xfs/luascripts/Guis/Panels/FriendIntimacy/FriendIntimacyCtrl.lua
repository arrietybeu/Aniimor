-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendIntimacy\\FriendIntimacyCtrl.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UICtrl = require("Guis.UICtrl")
local FriendIntimacyCtrl = Class.LightClass("FriendIntimacyCtrl", UICtrl)
local logger = LoggerManager.getLogger("FriendIntimacyCtrl")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local FriendshipEnumData = require("Data.friendship_enum_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local FriendshipLevelFuncData = require("Data.friendship_level_func_data")
local LimitData = require("Data.limit_data")
local SysConfigData = require("Data.sys_config_data")
local EditComponent = require("Guis.Panels.InfoPlayerMain.Component.EditComponent")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local TeamUtils = require("Utils.TeamUtils")

FriendIntimacyCtrl.messages = {
	[MessageName.FRIEND_PERMISSION_CHANGED] = {
		"onFriendPermissionChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local PROGRESS_TIME = 0.35
local ANIM_DELAY_TIME = 0.1
local FriendshipPermissionType = Const.FriendshipPermissionType
local PET_TRADE_LIMIT_PROGRESS_BY_TYPE = {
	[FriendshipPermissionType.TravelTogether] = {
		textKey = "FRIEND_PET_GIVE_LIMIT_PROGRESS"
	},
	[FriendshipPermissionType.ExchangePet] = {
		textKey = "FRIEND_PET_EXCHANGE_LIMIT_PROGRESS"
	}
}
local FUNCTION_TOOLTIP_PAGE = {
	Unlock = 2,
	Send = 0
}
local FUNCTION_TOOLTIP_SPONSOR_TEXT_BY_TYPE = {
	[FriendshipPermissionType.Action] = "FRIEND_INTIMACY_GO_TO_ACTION",
	[FriendshipPermissionType.TravelTogether] = "FRIEND_INTIMACY_GO_TO_TRAVEL",
	[FriendshipPermissionType.ExchangePet] = "FRIEND_INTIMACY_GO_TO_EXCHANGE_PET",
	[FriendshipPermissionType.SpecialFriend] = "FRIEND_INTIMACY_GO_TO_VARIANT",
	[FriendshipPermissionType.FriendNamePrefix] = "FRIEND_INTIMACY_MODIFY_TITLE"
}
local PLAYER_CARD_FOCUS_FUNCS_BY_TYPE = {
	[FriendshipPermissionType.TravelTogether] = {
		"inviteTeamFollow",
		"joinTeamFollow"
	},
	[FriendshipPermissionType.ExchangePet] = {
		"petExchange"
	},
	[FriendshipPermissionType.SpecialFriend] = {
		"petVariantInteract"
	}
}
local MEET_RANGE_REQUIRED_TYPE_SET = {
	[FriendshipPermissionType.Action] = true,
	[FriendshipPermissionType.TravelTogether] = true
}
local FRIEND_FUNC_SETTING_TYPE_SET = {
	[FriendshipPermissionType.EnterWorldAutoAccept] = true,
	[FriendshipPermissionType.OnlineReminder] = true,
	[FriendshipPermissionType.TeamAutoAccept] = true
}
local FRIEND_FUNC_MUST_MEET_MODULE_TEXT_BY_TYPE = {
	[FriendshipPermissionType.Action] = "CREATE_PLAYER_ANIMATION",
	[FriendshipPermissionType.TravelTogether] = "ENTER_FOLLOW_TEXT"
}

function FriendIntimacyCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	ClientTextUtils.setText(self.view.infoTextUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ENTRY"))

	self.playerInfo = info.playerInfo
	self.friendshipValue = info.friendshipValue

	local friendshipValueKey = self:getFriendshipPrefKey(ClientConst.PrefKey.FriendshipValue)
	local friendshipLevelKey = self:getFriendshipPrefKey(ClientConst.PrefKey.FriendshipLevel)

	self._friendshipValueCache = pg.global.prefsCacheUtils:getInt(friendshipValueKey, 0)
	self._friendshipLevelCache = pg.global.prefsCacheUtils:getInt(friendshipLevelKey, 0)
	self.friendshipLevel = pg.game.chat:getFriendship(self.playerInfo.uid)

	if self.friendshipValue < self._friendshipValueCache then
		self._friendshipValueCache = self.friendshipValue
		self._friendshipLevelCache = self.friendshipLevel
	end

	self.shouldShowFriendshipUp = self.friendshipLevel > self._friendshipLevelCache
	self._shouldDelayFriendshipAnimations = self.shouldShowFriendshipUp
	self._pendingFriendshipAnimations = {}
	self.openType = info.openType
	self.notBackToPlayerCard = info.notBackToPlayerCard

	self:refreshPlayerInfo()
	self:refreshIntimacyList()

	local _h = FriendIntimacyCtrl._platformHooks

	if _h and _h.onCreate then
		_h.onCreate(self)
	end
end

function FriendIntimacyCtrl:getFriendshipPrefKey(prefKey)
	return pg.me.uid .. prefKey .. self.playerInfo.uid
end

function FriendIntimacyCtrl:onFriendPermissionChanged(info)
	if info.friendId ~= self.playerInfo.uid then
		return
	end

	local intimacyList = self.view.intimacyListUList

	for index = 0, intimacyList.itemCount - 1 do
		local intimacyData = intimacyList:GetData(index)

		if table.contains(intimacyData.levelFunc, info.permissionId) then
			intimacyList:RefreshElement(index)

			return
		end
	end
end

function FriendIntimacyCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnBgCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.intimacyListUList.luaRenderItem(button, index, data)
		self:renderIntimacyItem(button, index, data)
	end

	function self.view.infoUButton.luaClick()
		self:openFriendIntimacyExplain()
	end

	self:refreshExplainHotkey()

	function self.view.intimacyListUList.luaFinishRender(uList)
		self:showFriendshipUpAfterRender()
		self:focusFirstUnlockedFunction(uList)
	end
end

function FriendIntimacyCtrl:openFriendIntimacyExplain()
	pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY_EXPLAIN, {
		friendUid = self.playerInfo.uid
	})
end

function FriendIntimacyCtrl:refreshExplainHotkey()
	local infoButton = self.view.infoUButton

	infoButton:RemoveLuaGamepadHotkey()
	infoButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart)
end

function FriendIntimacyCtrl:onInputDeviceChanged()
	self:refreshExplainHotkey()
end

function FriendIntimacyCtrl:showFriendshipUpAfterRender()
	if self.shouldShowFriendshipUp then
		self.shouldShowFriendshipUp = false

		local function onFriendshipUpClosed()
			self._shouldDelayFriendshipAnimations = false

			self:playPendingFriendshipAnimations()
		end

		pg.global.ui.friendshipUp:open({
			playerId = self.playerInfo.uid,
			playerInfo = self.playerInfo,
			formerLevel = self._friendshipLevelCache,
			curLevel = self.friendshipLevel
		}, nil, onFriendshipUpClosed, {
			cameraPresetKey = 2,
			rtHeight = 606,
			rtWidth = 1024,
			skipDecalCombineReadyCheck = true
		})
	end
end

function FriendIntimacyCtrl:focusFirstUnlockedFunction(uList)
	if not pg.game.input:isUsingGamepad() or not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	local highestUnlockedLevelIdx = 0

	for idx, levelData in ipairs(FriendshipLevelData) do
		if self.friendshipValue >= levelData.friendshipRange[1] then
			highestUnlockedLevelIdx = idx
		end
	end

	if highestUnlockedLevelIdx > 0 then
		local levelTransform = uList.content.transform:GetChild(highestUnlockedLevelIdx - 1)
		local levelBtn = levelTransform:GetComponent("UButton")

		if levelBtn then
			local levelObjRef = levelBtn:GetComponent("ObjectReference")
			local functionUList = levelObjRef:GetRefValue("functionUList")

			if functionUList and functionUList.content.transform.childCount > 0 then
				local functionTransform = functionUList.content.transform:GetChild(0)

				self._firstUnlockedFuncBtn = functionTransform:GetComponent("UButton")
			end
		end
	end

	CS.XGUI.Navigation.NavManager.Instance:FocusItem(self._firstUnlockedFuncBtn, CS.XGUI.Navigation.FocusEntryMode.Default)
end

function FriendIntimacyCtrl:playPendingFriendshipAnimations()
	local pendingAnimations = self._pendingFriendshipAnimations

	self._pendingFriendshipAnimations = {}

	for _, animation in ipairs(pendingAnimations) do
		self:startTimer(animation.callback, animation.delayTime)
	end
end

function FriendIntimacyCtrl:renderIntimacyItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local functionUList = objectReference:GetRefValue("functionUList")
	local intimacyItemUButton = objectReference:GetRefValue("intimacyItemUButton")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local iconBgUImage = objectReference:GetRefValue("iconBgUImage")

	self:renderIntimacyItemContent(iconUImage, iconBgUImage, textUSDFText, data)
	self:renderIntimacyItemTooltip(intimacyItemUButton, data)
	self:renderIntimacyItemState(button, index, data)
	self:renderIntimacyItemProgress(progressUProgress, index, data)
	self:renderIntimacyFunctionList(functionUList, index, data)
end

function FriendIntimacyCtrl:renderIntimacyItemContent(iconUImage, iconBgUImage, textUSDFText, data)
	iconUImage.url = data.levelIcon
	iconBgUImage.url = data.levelIconBg or ""

	ClientTextUtils.setText(textUSDFText, pg.getLocalizationText(data.levelName))
end

function FriendIntimacyCtrl:renderIntimacyItemTooltip(intimacyItemUButton, data)
	function intimacyItemUButton.luaRenderTooltip(_, tooltip)
		local objectReference = tooltip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if self.friendshipLevel >= data.friendshipLevel then
			ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_TIP_ACHIEVED"), pg.getLocalizationText(data.levelName)))

			return
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_TIP_UP"), self.friendshipValue, data.targetFriendshipValue))
	end
end

function FriendIntimacyCtrl:renderIntimacyItemState(button, index, data)
	button:TryChangePage("Type", index)

	if data.showUnlockAnim then
		local function showUnlockState()
			button:TryChangePage("FunctionState", 1)
		end

		self:playUnlockAnimation(button, showUnlockState, index * PROGRESS_TIME)
	else
		local functionState = self.friendshipValue - data.progressRange[1] >= 0 and 1 or 0

		button:TryChangePage("FunctionState", functionState)
	end
end

function FriendIntimacyCtrl:renderIntimacyItemProgress(progressUProgress, index, data)
	if data.hideProgress then
		progressUProgress:SetActive(false)

		return
	end

	progressUProgress:SetActive(true)

	progressUProgress.minValue = 0
	progressUProgress.maxValue = 1
	progressUProgress.value = data._progressFractionCache

	if data._progressFractionCache <= data.curProgressFraction then
		local function updateProgress()
			progressUProgress:ProgressToValue(data.curProgressFraction, nil, PROGRESS_TIME)
		end

		self:scheduleFriendshipAnimation(updateProgress, index * PROGRESS_TIME)
	end
end

function FriendIntimacyCtrl:renderIntimacyFunctionList(functionUList, index, data)
	function functionUList.luaRenderItem(funcBtn, funcIndex, funcData)
		self:renderFunctionItem(funcBtn, funcIndex, funcData, index, data)
	end

	local functionDataList = {}

	for _, functionId in ipairs(data.levelFunc) do
		local config = FriendshipLevelFuncData[functionId]

		if config == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("FriendshipLevelFuncData is missing, functionId=%s, skipped", tostring(functionId))
			end
		else
			local functionData = {
				funcId = functionId,
				funcName = config.funcName,
				funcDesc = config.funcDesc,
				funcRes = config.funcRes,
				funcLevel = config.funcLevel,
				cost = config.cost,
				funcType = config.type,
				funcValue = config.value,
				unlockFriendshipValue = data.progressRange[1],
				showUnlockAnim = data.showUnlockAnim
			}

			functionDataList[#functionDataList + 1] = functionData
		end
	end

	functionUList:SetList(functionDataList)
end

function FriendIntimacyCtrl:renderFunctionItem(funcBtn, funcIndex, funcData, index, data)
	local funcObjRef = funcBtn:GetComponent("ObjectReference")
	local funcLevelUSDFText = funcObjRef:GetRefValue("funcLevelUSDFText")
	local funcNameUSDFText = funcObjRef:GetRefValue("funcNameUSDFText")
	local funcIconUImage = funcObjRef:GetRefValue("funcIconUImage")

	ClientTextUtils.setText(funcNameUSDFText, pg.getLocalizationText(funcData.funcName))

	funcIconUImage.url = funcData.funcRes

	if funcData.funcLevel then
		ClientTextUtils.setText(funcLevelUSDFText, funcData.funcLevel)
		funcBtn:TryChangePage("Level", 0)
	else
		funcBtn:TryChangePage("Level", 1)
	end

	if funcData.showUnlockAnim then
		local function showFunctionState()
			self:refreshFunctionItemState(funcBtn, funcData)
		end

		local delayTime = index * PROGRESS_TIME + funcIndex * ANIM_DELAY_TIME

		self:playUnlockAnimation(funcBtn, showFunctionState, delayTime)
	else
		self:refreshFunctionItemState(funcBtn, funcData)
	end

	function funcBtn.luaRenderTooltip(btn, popup)
		self:renderFunctionTooltip(btn, popup, funcData)
	end
end

function FriendIntimacyCtrl:playUnlockAnimation(button, callback, delayTime)
	local function playAnimation()
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		callback()
	end

	self:scheduleFriendshipAnimation(playAnimation, delayTime)
end

function FriendIntimacyCtrl:scheduleFriendshipAnimation(callback, delayTime)
	if self._shouldDelayFriendshipAnimations then
		self._pendingFriendshipAnimations[#self._pendingFriendshipAnimations + 1] = {
			callback = callback,
			delayTime = delayTime
		}

		return
	end

	self:startTimer(callback, delayTime)
end

function FriendIntimacyCtrl:refreshFunctionItemState(funcBtn, funcData)
	local functionState = 0

	if self.friendshipValue >= funcData.unlockFriendshipValue then
		functionState = self:isFunctionTooltipUnlocked(funcData) and 1 or 2
	end

	funcBtn:TryChangePage("FunctionState", functionState)

	local isVariantFunction = funcData.funcType == FriendshipPermissionType.SpecialFriend
	local variantFriendUid = pg.game.chat:getSpecialFriendUId()
	local isVariantFriend = tostring(variantFriendUid) == tostring(self.playerInfo.uid)
	local showVariantState = functionState == 1 and isVariantFunction and isVariantFriend

	funcBtn:TryChangePage("Ischange", showVariantState and 1 or 0)
end

function FriendIntimacyCtrl:renderFunctionTooltip(btn, popup, funcData)
	local objectReference = popup:GetComponent("ObjectReference")
	local textTtileUSDFText = objectReference:GetRefValue("textTtileUSDFText")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local text1USDFText = objectReference:GetRefValue("text1USDFText")
	local conditionUSDFText = objectReference:GetRefValue("conditionUSDFText")
	local unlockUSDFText = objectReference:GetRefValue("unlockUSDFText")
	local unlock1USDFText = objectReference:GetRefValue("unlock1USDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnUWidget = objectReference:GetRefValue("btnUWidget")
	local btnUnlockUButton = objectReference:GetRefValue("btnUnlockUButton")

	unlock1USDFText:SetActive(false)
	ClientTextUtils.setText(textTtileUSDFText, pg.getLocalizationText(funcData.funcName))
	ClientTextUtils.setText(textUSDFText, pg.getLocalizationText(funcData.funcDesc))
	text1USDFText:SetActive(false)

	if not funcData.funcType then
		btnUWidget:SetActive(false)
		popup:TryChangePage("Type", FUNCTION_TOOLTIP_PAGE.Send)

		return
	end

	self:renderFunctionButtons(objectReference, funcData.funcType)

	function btnUnlockUButton.luaClick()
		pg.me:unlockFriendshipPermission(self.playerInfo.uid, funcData.funcId)
	end

	if self.friendshipValue < funcData.unlockFriendshipValue then
		btnUWidget:SetActive(false)

		return
	end

	btnUWidget:SetActive(true)

	local isUnlocked = self:isFunctionTooltipUnlocked(funcData)

	if not isUnlocked then
		self:renderFunctionUnlockCost(popup, conditionUSDFText, unlockUSDFText, unlock1USDFText, iconUImage, funcData)

		return
	end

	popup:TryChangePage("Type", FUNCTION_TOOLTIP_PAGE.Send)
	self:renderFunctionProgress(unlock1USDFText, funcData.funcType, funcData.funcValue)

	if FRIEND_FUNC_SETTING_TYPE_SET[funcData.funcType] then
		self:renderFriendFuncSettingTooltip(funcData, objectReference)

		return
	end

	if FUNCTION_TOOLTIP_SPONSOR_TEXT_BY_TYPE[funcData.funcType] then
		self:renderFunctionJump(btn, funcData, objectReference)
	end
end

function FriendIntimacyCtrl:renderFunctionProgress(unlock1USDFText, funcType, limitId)
	if funcType == FriendshipPermissionType.SpecialFriend then
		self:renderVariantPetCountProgress(unlock1USDFText)

		return
	end

	local progressConfig = PET_TRADE_LIMIT_PROGRESS_BY_TYPE[funcType]

	if not progressConfig or not limitId then
		return
	end

	local limitType = LimitData[limitId].type
	local limitTypeText = pg.getGameString(Const.LimitType2TextKeyMap[limitType])
	local usedCount = pg.me.useLimitMap:getUsedCount(limitId)
	local totalCount = pg.me.useLimitMap:getTotalCount(limitId)

	unlock1USDFText:SetActive(true)
	ClientTextUtils.setText(unlock1USDFText, pg.getFormatText(pg.getGameString(progressConfig.textKey), limitTypeText, usedCount, totalCount))
end

function FriendIntimacyCtrl:renderVariantPetCountProgress(unlock1USDFText)
	local variantPets = self:getVariantPetsByFriendUid(self.playerInfo.uid)

	unlock1USDFText:SetActive(true)
	ClientTextUtils.setText(unlock1USDFText, pg.getFormatText(pg.getGameString("FRIEND_PET_VARIANT_COUNT"), #variantPets, SysConfigData.VARIANT_LIMIT_1))
end

function FriendIntimacyCtrl:getVariantPetsByFriendUid(friendUid)
	return PetManagementDataHelper.getVariantPetsByFriendUid(friendUid)
end

function FriendIntimacyCtrl:renderFunctionJump(btn, funcData, objectReference)
	local btnSponsorUButton = objectReference:GetRefValue("btnSponsorUButton")
	local canJump = self:canJumpToFunction(funcData.funcType)

	if not canJump then
		local moduleTextKey = FRIEND_FUNC_MUST_MEET_MODULE_TEXT_BY_TYPE[funcData.funcType]

		if moduleTextKey then
			function btnSponsorUButton.luaClick()
				pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_MUST_MEET"), pg.getGameString(moduleTextKey)))
			end
		end

		return
	end

	function btnSponsorUButton.luaClick()
		self:jumpToFunction(btn, funcData)
	end
end

function FriendIntimacyCtrl:canJumpToFunction(funcType)
	if not MEET_RANGE_REQUIRED_TYPE_SET[funcType] then
		return true
	end

	return TeamUtils.isPlayerWithinMeetRange(self.playerInfo.uid)
end

function FriendIntimacyCtrl:jumpToFunction(btn, funcData)
	if not self:canJumpToFunction(funcData.funcType) then
		pg.global.showBubbleMessageById(NoticeDef.ONLY_FACE_TO_FACE_FUNC)

		return
	end

	if funcData.funcType == FriendshipPermissionType.Action then
		self:jumpToAction(btn, funcData.funcValue)

		return
	end

	if funcData.funcType == FriendshipPermissionType.FriendNamePrefix then
		self:jumpToTitlePrefix(btn)

		return
	end

	self:jumpToPlayerCardFunction(btn, funcData.funcType)
end

function FriendIntimacyCtrl:jumpToAction(btn, actionId)
	if PlatformSocialService:peekPlatformUserBlockedByLocalUser(self.playerInfo) == true then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	local playerId = self.playerInfo.uid

	self:closeForNavigation(btn)
	pg.global.ui:closeAllNormalPanel()
	pg.global.ui:show(UIConst.UI_ID_HUD_V2)
	pg.global.ui:show(UIConst.UI_ID_TOPLOGO)
	pg.global.ui:show(UIConst.UI_ID_INTERACT)

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.LD then
		pg.global.ui.hudV2.LD:openEmoticonPanel({
			interactAction = Const.APPEARANCE_ACTION_TYPE.Double,
			playerId = playerId,
			actionId = actionId
		})
	end
end

function FriendIntimacyCtrl:jumpToPlayerCardFunction(btn, funcType)
	local param = {
		openType = ClientConst.PlayerInfoOpenType.FaceToFace,
		playerId = self.playerInfo.uid,
		playerInfo = self.playerInfo,
		focusResponseFuncs = PLAYER_CARD_FOCUS_FUNCS_BY_TYPE[funcType],
		openSource = pg.game.chat.AddFriendSource.PlayerCard
	}

	self:closeForNavigation(btn)
	LuaUIUtils.openInfoPlayerCard(param)
end

function FriendIntimacyCtrl:jumpToTitlePrefix(btn)
	local returnCallback = self:createTitleReturnCallback()

	self:closeForNavigation(btn)
	pg.global.ui:open(UIConst.UI_ID_INFO_PLAYER_MAIN, {
		openType = ClientConst.PlayerInfoOpenType.Edit,
		playerId = pg.me.uid,
		defaultEditTabIndex = EditComponent.tabIndex.Title,
		defaultTitleType = Const.SHOW_TITLE_TYPE.Prefix,
		friendTitleInfo = {
			friendUid = tostring(self.playerInfo.uid),
			friendName = self.playerInfo.playerName or ""
		},
		callBack = returnCallback
	})
end

function FriendIntimacyCtrl:createTitleReturnCallback()
	if self.notBackToPlayerCard then
		return function()
			return
		end
	end

	local openType = self.openType
	local playerId = self.playerInfo.uid
	local playerInfo = self.playerInfo

	return function()
		LuaUIUtils.openInfoPlayerCard({
			openType = openType,
			playerId = playerId,
			playerInfo = playerInfo,
			openSource = pg.game.chat.AddFriendSource.PlayerCard
		})
	end
end

function FriendIntimacyCtrl:renderFunctionButtons(objectReference, funcType)
	local btnSponsorUButton = objectReference:GetRefValue("btnSponsorUButton")
	local btnUnlockUButton = objectReference:GetRefValue("btnUnlockUButton")
	local btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
	local btnApplyForUButton = objectReference:GetRefValue("btnApplyForUButton")
	local btnDisUButton = objectReference:GetRefValue("btnDisUButton")

	btnSponsorUButton.luaClick = nil
	btnInviteUButton.luaClick = nil
	btnApplyForUButton.luaClick = nil
	btnDisUButton.luaClick = nil

	btnSponsorUButton:TryChangePage("button", 0)

	btnSponsorUButton.interactable = true

	self:setFunctionButtonText(btnUnlockUButton, "ACCESSORY_UNLOCK")

	local sponsorTextKey = FUNCTION_TOOLTIP_SPONSOR_TEXT_BY_TYPE[funcType]

	if sponsorTextKey then
		self:setFunctionButtonText(btnSponsorUButton, sponsorTextKey)
		self:setFunctionButtonText(btnDisUButton, sponsorTextKey)
	end
end

function FriendIntimacyCtrl:setFunctionButtonText(button, gameStringKey)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString(gameStringKey))
end

function FriendIntimacyCtrl:isFunctionTooltipUnlocked(funcData)
	return pg.game.chat:isFriendshipPermissionUnlocked(self.playerInfo.uid, funcData.funcId)
end

function FriendIntimacyCtrl:renderFunctionUnlockCost(popup, conditionUSDFText, unlockUSDFText, unlock1USDFText, iconUImage, funcData)
	local cost = funcData.cost
	local itemId = cost[1]
	local needNum = cost[2]

	if not itemId or not needNum then
		popup:TryChangePage("Type", FUNCTION_TOOLTIP_PAGE.Unlock)
		ClientTextUtils.setText(conditionUSDFText, "")
		ClientTextUtils.setText(unlockUSDFText, "")
		ClientTextUtils.setText(unlock1USDFText, "")

		iconUImage.url = ""

		return
	end

	local ownNum = ClientUtils.getItemCountById(itemId, true) or 0
	local isEnough = needNum <= ownNum
	local costText = needNum

	if not isEnough then
		costText = pg.getFormatText("<style=Debuff>{0}</style>", costText)
	end

	unlock1USDFText:SetActive(true)
	ClientTextUtils.setText(unlock1USDFText, pg.getGameString("CONSUME_LABEL"))
	ClientTextUtils.setText(unlockUSDFText, pg.getFormatText("{0}/{1}", costText, ownNum))

	iconUImage.url = LuaUIUtils.getIconByItemId(itemId)

	popup:TryChangePage("Type", FUNCTION_TOOLTIP_PAGE.Unlock)
	ClientTextUtils.setText(conditionUSDFText, "")
end

function FriendIntimacyCtrl:renderFriendFuncSettingTooltip(funcData, objectReference)
	local btnSponsorUButton = objectReference:GetRefValue("btnSponsorUButton")
	local friendUid = self.playerInfo.uid
	local funcType = funcData.funcType

	local function refreshButtonText()
		local enabled = pg.me:isFriendFuncEnabled(friendUid, funcType)
		local textKey = enabled and "FRIEND_PRIVILEGE_CLOSE" or "FRIEND_PRIVILEGE_OPEN"

		self:setFunctionButtonText(btnSponsorUButton, textKey)
	end

	refreshButtonText()

	function btnSponsorUButton.luaClick()
		local enabled = not pg.me:isFriendFuncEnabled(friendUid, funcType)

		if not pg.me:setFriendFuncEnabled(friendUid, funcType, enabled) then
			return
		end

		refreshButtonText()
	end
end

function FriendIntimacyCtrl:refreshPlayerInfo()
	local friendUid = self.playerInfo.uid

	LuaUIUtils.renderPlayerAvatarButton(self.view.avatarUButton, {
		playerId = friendUid,
		playerInfo = self.playerInfo
	})

	local levelData = FriendshipLevelData[self.friendshipLevel]

	self.view.iconLikabilityUImage.url = levelData and levelData.levelIcon or ""

	local intimacyName = self:getIntimacyName(self.friendshipLevel)

	ClientTextUtils.setText(self.view.IntimacyUSDFText, pg.getLocalizationText(intimacyName))

	local todayIntimacy = pg.game.chat:getFriendIntimacyTodayAcquired(friendUid)
	local todayIntimacyLimit = pg.game.chat:getFriendIntimacyTodayLimit(friendUid)

	ClientTextUtils.setText(self.view.numGetUSDFText, pg.getFormatText("{0}/{1}", todayIntimacy, todayIntimacyLimit))

	local displayName = self.playerInfo.playerName or ""
	local _h = FriendIntimacyCtrl._platformHooks

	if _h and _h.refreshPlayerInfoName then
		displayName = _h.refreshPlayerInfoName(self, displayName)
	end

	ClientTextUtils.setText(self.view.textNameUSDFText, displayName)
end

function FriendIntimacyCtrl:getIntimacyName(friendshipLevel)
	for level = friendshipLevel, 1, -1 do
		local friendshipName = FriendshipLevelData[level].friendshipName

		if friendshipName and friendshipName ~= "" then
			return friendshipName
		end
	end

	return ""
end

function FriendIntimacyCtrl:refreshIntimacyList()
	local intimacyData = {}
	local progressFractionCache, curProgressFraction

	for idx, levelData in ipairs(FriendshipLevelData) do
		local data = {
			levelFunc = levelData.levelfunc,
			levelIcon = levelData.levelIcon,
			levelIconBg = levelData.levelIconBg,
			levelName = levelData.friendshipName or "",
			progressRange = levelData.friendshipRange,
			friendshipLevel = idx,
			targetFriendshipValue = levelData.friendshipRange[1],
			_progressFractionCache = progressFractionCache,
			curProgressFraction = curProgressFraction,
			showUnlockAnim = self._friendshipValueCache < levelData.friendshipRange[1] and self.friendshipValue >= levelData.friendshipRange[1],
			hideProgress = progressFractionCache == nil
		}

		intimacyData[#intimacyData + 1] = data
		progressFractionCache = self:getFriendshipProgressFraction(self._friendshipValueCache, levelData)
		curProgressFraction = self:getFriendshipProgressFraction(self.friendshipValue, levelData)
	end

	self.view.intimacyListUList:SetList(intimacyData)
	self.view.intimacyListUList:GoToIndex(self.friendshipLevel - 1, true)
end

function FriendIntimacyCtrl:onDestroy()
	local _h = FriendIntimacyCtrl._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end

	UICtrl.onDestroy(self)
end

function FriendIntimacyCtrl:closePanel()
	local tooltipBtn = pg.global.inputMgr:GetButtonPoppingUpToolTip()

	if tooltipBtn then
		tooltipBtn:ClosePopup()

		return
	end

	if not self.notBackToPlayerCard then
		local param = {
			openType = self.openType,
			playerId = self.playerInfo.uid,
			openSource = pg.game.chat.AddFriendSource.PlayerCard
		}

		LuaUIUtils.openInfoPlayerCard(param)
	end

	self:saveFriendshipCache()
	self:close()
end

function FriendIntimacyCtrl:closeForNavigation(btn)
	btn:ClosePopup()
	self:saveFriendshipCache()
	self:close()
end

function FriendIntimacyCtrl:saveFriendshipCache()
	local friendshipValueKey = self:getFriendshipPrefKey(ClientConst.PrefKey.FriendshipValue)
	local friendshipLevelKey = self:getFriendshipPrefKey(ClientConst.PrefKey.FriendshipLevel)

	pg.global.prefsCacheUtils:setInt(friendshipValueKey, self.friendshipValue)
	pg.global.prefsCacheUtils:setInt(friendshipLevelKey, self.friendshipLevel)
end

function FriendIntimacyCtrl:getFriendshipProgressFraction(friendshipValue, levelData)
	if friendshipValue < levelData.friendshipRange[1] then
		return 0
	end

	if friendshipValue >= levelData.friendshipRange[2] then
		return 1
	end

	local progress = friendshipValue - levelData.friendshipRange[1]
	local levelRange = levelData.friendshipRange[2] - levelData.friendshipRange[1]

	return progress / levelRange
end

return FriendIntimacyCtrl
