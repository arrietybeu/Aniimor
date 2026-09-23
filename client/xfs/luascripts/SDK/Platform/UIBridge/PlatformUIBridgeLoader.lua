-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\PlatformUIBridgeLoader.lua

if pg.isReloading then
	return
end

local platform = pg and pg.global and pg.global.platform

rawset(platform, "_platformUIBridgeLoader", rawget(platform, "_platformUIBridgeLoader") or {})

if not platform or not platform.shouldLoadPlatformBridge or not platform:shouldLoadPlatformBridge() then
	return
end

function platform._platformUIBridgeLoader.safeRequire(modulePath)
	local ok, result = pcall(require, modulePath)

	if not ok then
		print("[PlatformUIBridgeLoader] safeRequire failed: " .. tostring(modulePath) .. " - " .. tostring(result))

		return nil
	end

	return result
end

function platform._platformUIBridgeLoader.registerDynamicHook(targetModulePath, methodName, hookModulePath, hookName)
	return platform._platformUIBridgeLoader.registerDynamicHooks(targetModulePath, hookModulePath, {
		{
			methodName = methodName,
			hookName = hookName
		}
	})
end

function platform._platformUIBridgeLoader.registerDynamicHooks(targetModulePath, hookModulePath, hooks, exposeField)
	local hookModule = platform._platformUIBridgeLoader.safeRequire(hookModulePath)

	if hookModule == nil then
		return nil
	end

	local target = platform._platformUIBridgeLoader.safeRequire(targetModulePath)

	if target == nil then
		return nil
	end

	if exposeField ~= nil then
		rawset(target, exposeField, hookModule)
	end

	if not rawget(target, "_platformHooks") then
		rawset(target, "_platformHooks", {})
	end

	for _, hook in ipairs(hooks) do
		local methodName = hook.methodName
		local hookName = hook.hookName or methodName

		rawget(target, "_platformHooks")[methodName] = function(...)
			local currentHookModule = require(hookModulePath)
			local hookFn = currentHookModule and currentHookModule[hookName]

			assert(type(hookFn) == "function", string.format("[PlatformUIBridgeLoader] dynamic hook missing: %s.%s", tostring(hookModulePath), tostring(hookName)))

			return hookFn(...)
		end
	end

	return target
end

function platform._platformUIBridgeLoader.registerDynamicMembers(targetModulePath, hookModulePath, members, exposeField)
	local hookModule = platform._platformUIBridgeLoader.safeRequire(hookModulePath)

	if hookModule == nil then
		return nil
	end

	local target = platform._platformUIBridgeLoader.safeRequire(targetModulePath)

	if target == nil then
		return nil
	end

	if exposeField ~= nil then
		rawset(target, exposeField, hookModule)
	end

	for _, member in ipairs(members) do
		local fieldName = member.fieldName
		local hookName = member.hookName or fieldName

		if member.memberType == "value" then
			rawset(target, fieldName, hookModule[hookName])
		else
			rawset(target, fieldName, function(...)
				local currentHookModule = require(hookModulePath)
				local hookFn = currentHookModule and currentHookModule[hookName]

				assert(type(hookFn) == "function", string.format("[PlatformUIBridgeLoader] dynamic member missing: %s.%s", tostring(hookModulePath), tostring(hookName)))

				return hookFn(...)
			end)
		end
	end

	return target
end

function platform._platformUIBridgeLoader.loadDynamicModule(modulePath, initName)
	local module = platform._platformUIBridgeLoader.safeRequire(modulePath)

	if module == nil then
		return nil
	end

	if initName ~= nil then
		local initFn = module[initName]

		assert(type(initFn) == "function", string.format("[PlatformUIBridgeLoader] dynamic init missing: %s.%s", tostring(modulePath), tostring(initName)))
		initFn()
	end

	return module
end

local loader = platform._platformUIBridgeLoader

loader.registerDynamicHooks("Guis.Panels.TeamRoom.TeamRoomCtrl", "SDK.Platform.UIBridge.ImpPlatformTeamRoomCtrl", {
	{
		methodName = "getRenderPlayerName"
	},
	{
		methodName = "renderPlayerOnlineID"
	}
}, "_platformTeamRoomOnlineID")
loader.registerDynamicHooks("GameApp.Speech.SpeechSystem", "SDK.Platform.UIBridge.ImpPlatformSpeechSystem", {
	{
		methodName = "joinSpeechChannel"
	},
	{
		methodName = "quitSpeechChannel"
	},
	{
		methodName = "updateSpeechRoomMembers"
	},
	{
		methodName = "updateSpeakingMembers"
	},
	{
		methodName = "handlePlayerVoiceState"
	}
}, "_platformImpPlatformSpeechSystem")
loader.loadDynamicModule("SDK.Platform.UIBridge.ImpPlatformSpeechSystem", "registerPlatformCallbacks")
loader.registerDynamicHooks("Guis.Panels.DungeonInvite.DungeonInviteCtrl", "SDK.Platform.UIBridge.ImpPlatformDungeonInviteCtrl", {
	{
		methodName = "renderInvitePlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.DungeonInvitePopup.DungeonInvitePopupCtrl", "SDK.Platform.UIBridge.ImpPlatformDungeonInvitePopupCtrl", {
	{
		methodName = "renderInvitePlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.HomeCampVisit.HomeCampVisitCtrl", "SDK.Platform.UIBridge.ImpPlatformHomeCampVisitCtrl", {
	{
		methodName = "rendererFriendCampName"
	}
})
loader.registerDynamicHooks("Guis.Panels.HomeCampInviteFriend.HomeCampInviteFriendCtrl", "SDK.Platform.UIBridge.ImpPlatformHomeCampInviteFriendCtrl", {
	{
		methodName = "getMaskedPlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.HomeStationManage.Component.HomeStationSearchComponent", "SDK.Platform.UIBridge.ImpPlatformHomeStationManageComponent", {
	{
		methodName = "renderFriendStationPlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.HomeStationManage.Component.HomeCurrentStationComponent", "SDK.Platform.UIBridge.ImpPlatformHomeCurrentStationComponent", {
	{
		methodName = "renderCurrentStationPlayerName"
	}
})
loader.registerDynamicHooks("Utils.PetManagementUtils", "SDK.Platform.UIBridge.ImpPlatformDetailComponent", {
	{
		methodName = "refreshSourcePlayerName",
		hookName = "refreshPetUtilSourcePlayerName"
	}
}, "_platformImpPlatformDetailComponent")
loader.registerDynamicHooks("Guis.Panels.PetManagement.Component.DetailComponent", "SDK.Platform.UIBridge.ImpPlatformDetailComponent", {
	{
		methodName = "refreshSourcePlayerName",
		hookName = "refreshDetailSourcePlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.InfoPlayerCard.InfoPlayerCardCtrl", "SDK.Platform.UIBridge.ImpPlatformInfoPlayerCardCtrl", {
	{
		methodName = "setPlayerBaseInfoName"
	},
	{
		methodName = "setPlayerBaseInfoSign"
	},
	{
		methodName = "setPlayerBaseInfoOnlineID"
	},
	{
		methodName = "visitHome"
	},
	{
		methodName = "setInteractIconColor"
	}
}, "_platformImpPlatformInfoPlayerCardCtrl")
loader.registerDynamicHooks("Utils.ShowTitleUtils", "SDK.Platform.UIBridge.ImpPlatformShowTitleUtils", {
	{
		methodName = "resolveFriendPrefixName"
	}
})
loader.registerDynamicHooks("Guis.Panels.InfoPlayerMain.InfoPlayerMainCtrl", "SDK.Platform.UIBridge.ImpPlatformInfoPlayerMainCtrl", {
	{
		methodName = "onCreate"
	},
	{
		methodName = "setPlayerBaseInfoName"
	},
	{
		methodName = "refreshPlayerName"
	},
	{
		methodName = "onDestroy"
	},
	{
		methodName = "setPlayerBaseInfoSign"
	},
	{
		methodName = "setPlayerBaseInfoOnlineID"
	}
}, "_platformInfoPlayerMain")
loader.registerDynamicHooks("Guis.Panels.Accusation.AccusationCtrl", "SDK.Platform.UIBridge.ImpPlatformAccusationCtrl", {
	{
		methodName = "renderPlayerName"
	}
}, "_platformImpPlatformAccusationCtrl")
loader.registerDynamicHooks("Guis.Panels.HomeCampReport.HomeCampReportCtrl", "SDK.Platform.UIBridge.ImpPlatformHomeCampReportCtrl", {
	{
		methodName = "renderPlayerName"
	}
}, "_platformImpPlatformHomeCampReportCtrl")
loader.registerDynamicHooks("Guis.Panels.TopLogo.Node.TopLogoCarBoard", "SDK.Platform.UIBridge.ImpPlatformTopLogoCarBoard", {
	{
		methodName = "refreshBoardName"
	}
}, "_platformImpPlatformTopLogoCarBoard")
loader.registerDynamicHooks("Guis.Panels.Tips.Component.TeamMatchTipComponent", "SDK.Platform.UIBridge.ImpPlatformTeamMatchTipComponent", {
	{
		methodName = "renderPlayerState"
	},
	{
		methodName = "confirmStateChanged"
	}
})
loader.registerDynamicHooks("Guis.Panels.Tips.Items.CTipArea.FriendOnLineItem", "SDK.Platform.UIBridge.ImpPlatformFriendOnLineItem", {
	{
		methodName = "resolveFriendOnlineDisplayName"
	}
})
loader.registerDynamicHooks("Guis.Panels.Tips.Items.CITipArea.TeamInviteItem", "SDK.Platform.UIBridge.ImpPlatformTeamInviteItem", {
	{
		methodName = "renderTeamInvite"
	}
}, "_platformImpPlatformTeamInviteItem")
loader.registerDynamicHooks("Guis.Utils.UICardRenderUtils", "SDK.Platform.UIBridge.ImpPlatformUICardRenderUtils", {
	{
		methodName = "getRender1Plus3RoomPlayerName"
	},
	{
		methodName = "render1Plus3RoomOnlineID"
	},
	{
		methodName = "getRender1Plus3PrimaryPetName"
	}
}, "_platform1Plus3RoomOnlineID")
loader.registerDynamicHooks("Guis.Panels.Tips.Items.TopTipArea.HomeNameItem", "SDK.Platform.UIBridge.ImpPlatformHomeNameItem", {
	{
		methodName = "renderItemName"
	}
})
loader.registerDynamicHooks("Guis.Panels.TopLogo.Component.TopLogoCombatComponent", "SDK.Platform.UIBridge.ImpPlatformTopLogoCombatComponent", {
	{
		methodName = "onCtor"
	},
	{
		methodName = "onFindObjects"
	},
	{
		methodName = "refreshName"
	},
	{
		methodName = "refreshSubName"
	},
	{
		methodName = "onDestroy"
	}
}, "_platformTopLogoOnlineID")
loader.registerDynamicMembers("Guis.Panels.Chat.Component.FriendTabComponent", "SDK.Platform.UIBridge.ImpPlatformFriendTabComponent", {
	{
		fieldName = "ConsolePlatformType",
		memberType = "value"
	},
	{
		fieldName = "FriendChannelType",
		memberType = "value"
	},
	{
		fieldName = "getConsolePlatformType"
	},
	{
		fieldName = "openPlatformProfileEntry"
	},
	{
		fieldName = "getPlatformUidMappingEntry"
	},
	{
		fieldName = "getMappedGameUid"
	},
	{
		fieldName = "setPlatformUidMappingCacheEntry"
	},
	{
		fieldName = "shouldQueryPlatformUidMapping"
	},
	{
		fieldName = "queryPlatformUidMapping"
	},
	{
		fieldName = "refreshPlatformUidMappingAsync"
	},
	{
		fieldName = "cachePlatformPlayerInfo"
	},
	{
		fieldName = "cachePlatformFriendSnapshot"
	},
	{
		fieldName = "convertPlatformFriendToPlayerInfo"
	},
	{
		fieldName = "getRealtimePlatformPlayerInfo"
	},
	{
		fieldName = "requestPlatformPlayerInfo"
	},
	{
		fieldName = "fetchPlatformFriendList"
	},
	{
		fieldName = "registerPlatformCallbacks"
	}
}, "_platformImpPlatformFriendTabComponent")
loader.registerDynamicHooks("Guis.Panels.Chat.Component.FriendTabComponent", "SDK.Platform.UIBridge.ImpPlatformFriendTabComponent", {
	{
		methodName = "initView"
	},
	{
		methodName = "addListener"
	},
	{
		methodName = "renderRecommendPlayerName"
	},
	{
		methodName = "renderRecommendPlayerOnlineID"
	},
	{
		methodName = "renderApplyPlayerName"
	},
	{
		methodName = "renderFriendItemName"
	},
	{
		methodName = "beforeRenderFriendItem"
	},
	{
		methodName = "afterAssignFriendItemClick"
	},
	{
		methodName = "afterAssignFriendAvatarClick"
	},
	{
		methodName = "afterRenderFriendBlacklistButton"
	},
	{
		methodName = "injectFriendGroupList"
	},
	{
		methodName = "setPlayerBaseInfoSign"
	},
	{
		methodName = "onDestroy"
	},
	{
		methodName = "renderChatGroupName"
	}
})
loader.registerDynamicHooks("Guis.Panels.Chat.Component.FriendNewComponent", "SDK.Platform.UIBridge.ImpPlatformFriendNewComponent", {
	{
		methodName = "renderFriendItemName"
	}
})
loader.registerDynamicHooks("GameApp.Chat.ChatSystem", "SDK.Platform.UIBridge.ImpPlatformChatSystem", {
	{
		methodName = "getFriendList"
	},
	{
		methodName = "buildSelfPlayerData"
	},
	{
		methodName = "refreshTeamMiniChatMessage"
	},
	{
		methodName = "resolveFriendshipUpdateName"
	}
})
loader.registerDynamicHooks("Guis.Panels.Chat.Component.ChatComponent", "SDK.Platform.UIBridge.ImpPlatformChatComponent", {
	{
		methodName = "replyMessageName"
	},
	{
		methodName = "renderMessageRootPlayerName"
	},
	{
		methodName = "renderMessagePopPlayerName"
	},
	{
		methodName = "renderChannelLastMessagePlayerName"
	},
	{
		methodName = "renderChannelItemName"
	},
	{
		methodName = "refreshChatMessageTitleName"
	},
	{
		methodName = "renderGroupChannelDisplayName"
	}
}, "_platformImpPlatformChatComponent")
loader.registerDynamicHooks("GameApp.Setting.SettingSystem", "SDK.Platform.UIBridge.ImpPlatformSettingSystem", {
	{
		methodName = "trySyncCrossPlatformToServer"
	}
}, "_platformImpPlatformSettingSystem")
loader.loadDynamicModule("SDK.Platform.UIBridge.ImpPlatformSettingSystem", "init")
loader.registerDynamicHooks("Guis.Panels.Setting.SettingCtrl", "SDK.Platform.UIBridge.ImpPlatformSettingCtrl", {
	{
		methodName = "isCrossPlatformSettingReadOnly"
	}
})
loader.registerDynamicHooks("Guis.Panels.Setting.SettingModel", "SDK.Platform.UIBridge.ImpPlatformSettingModel", {
	{
		methodName = "handlePlatformSettingData"
	}
})
loader.registerDynamicHooks("Utils.LuaUIUtils", "SDK.Platform.UIBridge.ImpPlatformLuaUIUtils", {
	{
		methodName = "checkPlatformFuncUnlock"
	}
})
loader.registerDynamicHooks("Guis.Panels.Chat.Component.MailNewComponent", "SDK.Platform.UIBridge.ImpPlatformMailNewComponent", {
	{
		methodName = "getGiftMailGiverName"
	},
	{
		methodName = "getGiftMailGiverDisplayName"
	}
}, "_platformImpPlatformMailNewComponent")
loader.registerDynamicHooks("Guis.Panels.MarkShareView.MarkShareViewCtrl", "SDK.Platform.UIBridge.ImpPlatformMarkShareViewCtrl", {
	{
		methodName = "initOnlineID"
	},
	{
		methodName = "clearOnlineID"
	},
	{
		methodName = "applyMarkShareImage"
	},
	{
		methodName = "applyMarkShareText"
	},
	{
		methodName = "applyMarkShareName"
	},
	{
		methodName = "initCloseButtons"
	}
}, "_platformImpPlatformMarkShareViewCtrl")
loader.registerDynamicHooks("Guis.Panels.Chat.ChatCtrl", "SDK.Platform.UIBridge.ImpPlatformChatCtrl", {
	{
		methodName = "getAddFriendSuccessPlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.FriendshipUp.FriendshipUpCtrl", "SDK.Platform.UIBridge.ImpPlatformFriendshipUpCtrl", {
	{
		methodName = "initUI"
	}
})
loader.registerDynamicHooks("Guis.Panels.FriendIntimacy.FriendIntimacyCtrl", "SDK.Platform.UIBridge.ImpPlatformFriendIntimacyCtrl", {
	{
		methodName = "refreshPlayerInfoName"
	},
	{
		methodName = "onCreate"
	},
	{
		methodName = "onDestroy"
	}
})
loader.registerDynamicHooks("Guis.Panels.LoadProgress.LoadProgressCtrl", "SDK.Platform.UIBridge.ImpPlatformLoadProgressCtrl", {
	{
		methodName = "resolveTeamMemberDisplayName"
	}
})
loader.registerDynamicHooks("Guis.Panels.InfoPlayerMain.Component.EditTitleBarComponent", "SDK.Platform.UIBridge.ImpPlatformEditTitleBarComponent", {
	{
		methodName = "resolveFriendTitleDisplayName"
	}
})
loader.registerDynamicHooks("Guis.Panels.BossRushChallenge.BossRushChallengeCtrl", "SDK.Platform.UIBridge.ImpPlatformBossRushChallengeCtrl", {
	{
		methodName = "getMaskedEntDisplayName"
	},
	{
		methodName = "getMaskedPlayerDisplayName"
	}
})
loader.registerDynamicHooks("Guis.Panels.BossRushBattleResult.BossRushBattleResultCtrl", "SDK.Platform.UIBridge.ImpPlatformBossRushBattleResultCtrl", {
	{
		methodName = "getMaskedPlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.RankBase.Component.RankBaseDisplayRegistry", "SDK.Platform.UIBridge.ImpPlatformRankBaseDisplayRegistry", {
	{
		methodName = "getRenderPlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.EventFriend.EventFriendCtrl", "SDK.Platform.UIBridge.ImpPlatformEventFriendCtrl", {
	{
		methodName = "renderFriendItemName"
	}
})
loader.registerDynamicHooks("Guis.Panels.SpaceFollowGiveConfirm.SpaceFollowGiveConfirmCtrl", "SDK.Platform.UIBridge.ImpPlatformSpaceFollowGiveConfirmCtrl", {
	{
		methodName = "refreshTextDetailName"
	}
})
loader.registerDynamicHooks("Guis.Panels.FriendInviteList.FriendInviteListCtrl", "SDK.Platform.UIBridge.ImpPlatformFriendInviteListCtrl", {
	{
		methodName = "renderInvitePlayerName"
	}
})
loader.registerDynamicHooks("Guis.Panels.InviteFriend.InviteFriendCtrl", "SDK.Platform.UIBridge.ImpPlatformInviteFriendCtrl", {
	{
		methodName = "renderFriendItemName"
	}
})
loader.registerDynamicHooks("Guis.Panels.FriendGift.FriendGiftCtrl", "SDK.Platform.UIBridge.ImpPlatformFriendGiftCtrl", {
	{
		methodName = "refreshUI"
	}
})
loader.registerDynamicHooks("Guis.Panels.FriendSetup.FriendSetupCtrl", "SDK.Platform.UIBridge.ImpPlatformFriendSetupCtrl", {
	{
		methodName = "prepareFriendSetupItem"
	},
	{
		methodName = "getFriendGroupUid"
	},
	{
		methodName = "renderFriendItemName"
	}
}, "_platformImpPlatformFriendSetupCtrl")
loader.registerDynamicHooks("Guis.Panels.Interact.InteractView", "SDK.Platform.UIBridge.ImpPlatformInteractView", {
	{
		methodName = "showSwitchCtrlText"
	}
}, "_platformImpPlatformInteractView")
loader.registerDynamicHooks("Guis.Panels.Interact.Component.InteractUIComponent", "SDK.Platform.UIBridge.ImpPlatformInteractUIComponent", {
	{
		methodName = "setupMultInteractBtnText"
	}
}, "_platformImpPlatformInteractUIComponent")
loader.registerDynamicHooks("Guis.Panels.PetExchangeSelect.PetExchangeSelectCtrl", "SDK.Platform.UIBridge.ImpPlatformPetExchangeSelectCtrl", {
	{
		methodName = "applyPlayerNameMask"
	},
	{
		methodName = "applyExchangeTipNameMask"
	}
}, "_platformImpPlatformPetExchangeSelectCtrl")
loader.registerDynamicHooks("Guis.Panels.PetExchangeWait.PetExchangeWaitCtrl", "SDK.Platform.UIBridge.ImpPlatformPetExchangeWaitCtrl", {
	{
		methodName = "applyFriendPlayerNameMask"
	},
	{
		methodName = "applyBottomBaseInfoMask"
	}
}, "_platformImpPlatformPetExchangeWaitCtrl")
loader.registerDynamicHooks("GameApp.Interaction.InteractUnit.InteractionUnitPlayerFunc", "SDK.Platform.UIBridge.ImpPlatformInteractionUnitPlayerFunc", {
	{
		methodName = "getPlayerDisplayName"
	}
}, "_platformImpPlatformInteractionUnitPlayerFunc")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientInteractionAnimationComponent", "SDK.Platform.UIBridge.ImpPlatformInteractionAnimationComponent", {
	{
		methodName = "resolveInteractPlayerDisplayName"
	}
}, "_platformImpPlatformInteractionAnimationComponent")
loader.registerDynamicHooks("Guis.Panels.CashGift.CashGiftCtrl", "SDK.Platform.UIBridge.ImpPlatformCashGiftCtrl", {
	{
		methodName = "resolveGiftReceiverName"
	},
	{
		methodName = "_onConfirmGift"
	}
}, "_platformImpPlatformCashGiftCtrl")
loader.registerDynamicHooks("Utils.ClientCashShopUtils", "SDK.Platform.UIBridge.ImpPlatformClientCashShopUtils", {
	{
		methodName = "resolveGiftReceiverName"
	}
}, "_platformImpPlatformClientCashShopUtils")
loader.registerDynamicHooks("Guis.Panels.ShopGiftReceive.ShopGiftReceiveCtrl", "SDK.Platform.UIBridge.ImpPlatformShopGiftReceiveCtrl", {
	{
		methodName = "resolveGiverDisplayName"
	},
	{
		methodName = "resolveGiftBlessText"
	}
}, "_platformImpPlatformShopGiftReceiveCtrl")
loader.registerDynamicHooks("Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentComponent", "SDK.Platform.EntityMixin.ImpPlatformClientHomeCarOrnamentComponent", {
	{
		methodName = "start"
	},
	{
		methodName = "destroy"
	}
}, "_platformImpPlatformClientHomeCarOrnamentComponent")
loader.registerDynamicHooks("GameApp.Home.HomeCar.HomeCarGroup", "SDK.Platform.EntityMixin.ImpPlatformHomeCarGroup", {
	{
		methodName = "createHomeCarEntities"
	},
	{
		methodName = "createHomeCarEntity"
	},
	{
		methodName = "updateHomeCarEntity"
	},
	{
		methodName = "destroy"
	}
}, "_platformImpPlatformHomeCarGroup")
loader.registerDynamicHooks("Guis.Panels.WorkShopCostumeStain.WorkShopCostumeStainModel", "SDK.Platform.EntityMixin.ImpPlatformWorkShopCostumeStainModel", {
	{
		methodName = "onSubmitChanged"
	}
})
loader.registerDynamicHooks("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent", "SDK.Platform.EntityMixin.ImpPlatformClientCombatEntityComponent", {
	{
		methodName = "onLifeChange"
	}
}, "_platformImpPlatformClientCombatEntityComponent")
loader.registerDynamicHooks("Guis.Panels.Photo.Component.NormalPhotoUIComponent", "SDK.Platform.EntityMixin.ImpPlatformNormalPhotoUIComponent", {
	{
		methodName = "savePhoto"
	}
}, "_platformImpPlatformNormalPhotoUIComponent")
loader.registerDynamicHooks("Utils.ClientSettingUtils", "SDK.Platform.EntityMixin.ImpPlatformClientSettingUtils", {
	{
		methodName = "setDefault_crossPlatform"
	},
	{
		methodName = "get_crossPlatform"
	},
	{
		methodName = "set_crossPlatform"
	},
	{
		methodName = "handleAccountBindClick"
	}
}, "_platformImpPlatformClientSettingUtils")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientMatchComponent", "SDK.Platform.EntityMixin.ImpPlatformClientMatchComponent", {
	{
		methodName = "RPC_SC_EnterRoomSucc"
	}
}, "_platformImpPlatformClientMatchComponent")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientRoomComponent", "SDK.Platform.EntityMixin.ImpPlatformClientRoomComponent", {
	{
		methodName = "rpc_waitingEnterWorld"
	}
}, "_platformImpPlatformClientRoomComponent")
loader.registerDynamicHooks("GameApp.MarkShare.MarkShareSystem", "SDK.Platform.EntityMixin.ImpPlatformMarkShareSystem", {
	{
		methodName = "onCtor"
	},
	{
		methodName = "onDestroy"
	},
	{
		methodName = "checkInfoStampVisible"
	}
})
loader.registerDynamicHooks("Guis.Panels.Photo.PhotoCtrl", "SDK.Platform.UIBridge.ImpPlatformPhotoCtrl", {
	{
		methodName = "takePhoto"
	}
}, "_platformImpPlatformPhotoCtrl")
loader.registerDynamicHooks("Guis.Panels.Login.LoginView", "SDK.Platform.UIBridge.ImpPlatformLoginView", {
	{
		methodName = "initView"
	}
})
loader.registerDynamicHooks("Guis.Panels.Login.LoginCtrl", "SDK.Platform.UIBridge.ImpPlatformLoginCtrl", {
	{
		methodName = "getOnlineIDText"
	},
	{
		methodName = "shouldBlockLoginClick"
	},
	{
		methodName = "refreshLoginButtonInteractable"
	}
}, "_platformImpPlatformLoginCtrl")
loader.registerDynamicHooks("Entities.LoginAgent", "SDK.Platform.UIBridge.ImpPlatformLoginAgent", {
	{
		methodName = "_enrichLoginExtraInfo"
	}
}, "_platformImpPlatformLoginAgent")
loader.registerDynamicHooks("GameApp.Core.GameApp", "SDK.Platform.UIBridge.ImpPlatformGameApp", {
	{
		methodName = "onAppFocus"
	}
})
loader.registerDynamicHooks("Guis.Panels.DevelopHint.DevelopHintCtrl", "SDK.Platform.UIBridge.ImpPlatformDevelopHintCtrl", {
	{
		methodName = "shouldShowDevelopHint"
	}
})
loader.registerDynamicHooks("Guis.Panels.Avatar.AvatarCtrl", "SDK.Platform.UIBridge.ImpPlatformAvatarCtrl", {
	{
		methodName = "shouldShowAvatarShareButtons"
	}
})
loader.registerDynamicHooks("Guis.Panels.CashShop.CashShopCtrl", "SDK.Platform.UIBridge.ImpPlatformCashShopCtrl", {
	{
		methodName = "shouldShowWebPayButton"
	},
	{
		methodName = "filterGiftFriendList"
	}
})
loader.registerDynamicHooks("Guis.Panels.Map.MapCtrl", "SDK.Platform.UIBridge.ImpPlatformMapCtrl", {
	{
		methodName = "handleCancelOnLocationInfo"
	},
	{
		methodName = "shouldHideLocationInfoCloseBtn"
	}
})
loader.registerDynamicHooks("GameApp.Recharge.RechargeUtils", "SDK.Platform.UIBridge.ImpPlatformRechargeUtils", {
	{
		methodName = "getProductsPrice"
	}
})
loader.registerDynamicHooks("Entities.SpaceEntities.ClientMainPlayer", "SDK.Platform.EntityMixin.ImpPlatformClientMainPlayer", {
	{
		methodName = "onLeaveSpace"
	},
	{
		methodName = "onLoseServer"
	},
	{
		methodName = "RPC_SC_receiveNotice"
	},
	{
		methodName = "replaceNoticeArgs"
	}
}, "_platformImpPlatformClientMainPlayer")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientFunctionUnlockComponent", "SDK.Platform.EntityMixin.ImpPlatformClientFunctionUnlockComponent", {
	{
		methodName = "on_functionUnlocks_changed"
	}
}, "_platformImpPlatformClientFunctionUnlockComponent")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientFriendComponent", "SDK.Platform.EntityMixin.ImpPlatformClientFriendComponent", {
	{
		methodName = "appendFriendQueryAttributes"
	},
	{
		methodName = "FriendService_onSpecialFriendSet"
	},
	{
		methodName = "inviteEnterPhotoWorldByShellActivity"
	},
	{
		methodName = "onInit"
	},
	{
		methodName = "onPsnBlockStatesUpdated"
	}
}, "_platformImpPlatformClientFriendComponent")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientSocialComponent", "SDK.Platform.EntityMixin.ImpPlatformClientFriendComponent", {
	{
		methodName = "RPC_SC_PsnAuthCodeRequired"
	}
}, "_platformImpPlatformClientSocialComponent")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientChatComponent", "SDK.Platform.EntityMixin.ImpPlatformClientChatComponent", {
	{
		methodName = "enrichSenderInfo"
	},
	{
		methodName = "checkSendMessagePolicy"
	},
	{
		methodName = "sensitiveWordsCheck"
	},
	{
		methodName = "createChatGroup"
	},
	{
		methodName = "setChatGroupStatus"
	}
})
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientTeamComponent", "SDK.Platform.EntityMixin.ImpPlatformClientTeamComponent", {
	{
		methodName = "init"
	},
	{
		methodName = "destroy"
	},
	{
		methodName = "onLeaveTeam"
	},
	{
		methodName = "handleSyncTeamInfo"
	},
	{
		methodName = "RPC_SC_TeamNoticeId"
	},
	{
		methodName = "RPC_SC_SyncDungeonTeamInfo"
	},
	{
		methodName = "beforeJoinSpeechChannel"
	},
	{
		methodName = "beforeReceiveTeamInvite"
	},
	{
		methodName = "beforeReceiveJoinTeamRequest"
	},
	{
		methodName = "beforeReceiveEnterWorldRequest"
	},
	{
		methodName = "beforeReceiveEnterWorldInvite"
	},
	{
		methodName = "inviteTeamMemberByPlatformFriend"
	},
	{
		methodName = "inviteTeamMemberBySamePlatformFamily"
	},
	{
		methodName = "requestJoinTeamByPlatformFriend"
	},
	{
		methodName = "requestJoinTeamBySamePlatformFamily"
	},
	{
		methodName = "beforeAcceptTeamInvite"
	},
	{
		methodName = "beforeAcceptEnterWorldInvite"
	},
	{
		methodName = "beforeRequestEnterWorld"
	},
	{
		methodName = "requestEnterWorldByPlatformFriend"
	},
	{
		methodName = "requestEnterWorldBySamePlatformFamily"
	},
	{
		methodName = "inviteEnterWorldByPlatformFriend"
	},
	{
		methodName = "inviteEnterWorldBySamePlatformFamily"
	},
	{
		methodName = "canHandleOfflineInviteEnterWorld"
	},
	{
		methodName = "reqSpaceFollowByPlatformFriend"
	},
	{
		methodName = "reqSpaceFollowBySamePlatformFamily"
	},
	{
		methodName = "quickInviteSpaceFollowByPlatformFriend"
	},
	{
		methodName = "quickInviteSpaceFollowBySamePlatformFamily"
	},
	{
		methodName = "inviteSpaceFollowByPlatformFriend"
	},
	{
		methodName = "inviteSpaceFollowBySamePlatformFamily"
	},
	{
		methodName = "notifyReqSpaceFollowRetName"
	},
	{
		methodName = "notifyInviteSpaceFollowRetName"
	},
	{
		methodName = "kickSpaceFollowName"
	}
}, "_platformImpPlatformClientTeamComponent")
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientPetsExchangeComponent", "SDK.Platform.EntityMixin.ImpPlatformClientPetsExchangeComponent", {
	{
		methodName = "init"
	},
	{
		methodName = "destroy"
	},
	{
		methodName = "onStartPetExchangeSocial"
	},
	{
		methodName = "beforeSendPetExchangeInvite"
	},
	{
		methodName = "beforeRecvPetExchangeInvite"
	}
})
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeCampComponent", "SDK.Platform.EntityMixin.ImpPlatformClientPlayerHomeCampComponent", {
	{
		methodName = "canEnterHomeCamp"
	}
})
loader.registerDynamicHooks("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomelandComponent", "SDK.Platform.EntityMixin.ImpPlatformClientPlayerHomelandComponent", {
	{
		methodName = "canEnterHomeland"
	}
})
loader.registerDynamicHooks("Entities.SpaceEntities.HomeCar.ClientHomeCar", "SDK.Platform.EntityMixin.ImpPlatformClientHomeCar", {
	{
		methodName = "getName"
	}
}, "_platformImpPlatformClientHomeCar")
loader.registerDynamicHooks("GameApp.Chat.ChatSystem", "SDK.Platform.EntityMixin.ImpPlatformImpChatMessage", {
	{
		methodName = "addNewMessage"
	},
	{
		methodName = "filterChatHistoryMessages"
	},
	{
		methodName = "getChatGroupDisplayName"
	},
	{
		methodName = "getChatNoticePlayerName"
	},
	{
		methodName = "recvPrivateChatPush"
	},
	{
		methodName = "recvGroupChatPush"
	},
	{
		methodName = "recvFriendChatPush"
	},
	{
		methodName = "recvWorldChatPush"
	},
	{
		methodName = "recvNearbyChatPush"
	},
	{
		methodName = "renderChatGroupMemberNoticePlayerName"
	}
}, "_platformImpPlatformImpChatMessage")
loader.registerDynamicMembers("GameApp.Chat.ChatSystem", "SDK.Platform.EntityMixin.ImpPlatformImpChatMessage", {
	{
		fieldName = "refreshPlatformFilteredChatMessages"
	}
})
loader.registerDynamicHooks("GameApp.Chat.ChatSystem", "SDK.Platform.EntityMixin.ImpPlatformImpChatTeam", {
	{
		methodName = "canHandleOfflineTeamInvite"
	},
	{
		methodName = "recvTeamNotice"
	},
	{
		methodName = "tryMaskPlayerName"
	},
	{
		methodName = "handleRequireSpaceFollowNotify"
	},
	{
		methodName = "handleInviteSpaceFollowNotify"
	}
}, "_platformImpPlatformImpChatTeam")
loader.registerDynamicHooks("GameApp.Chat.ChatSystem", "SDK.Platform.EntityMixin.ImpPlatformImpChatMail", {
	{
		methodName = "shouldShowMail"
	},
	{
		methodName = "onVisibleMailPending"
	},
	{
		methodName = "onMailRemoved"
	}
}, "_platformImpPlatformImpChatMail")
loader.registerDynamicMembers("GameApp.Chat.ChatSystem", "SDK.Platform.EntityMixin.ImpPlatformImpChatMail", {
	{
		fieldName = "refreshPlatformFilteredMails"
	}
})
loader.registerDynamicHooks("SDK.GMEManager", "SDK.Platform.EntityMixin.ImpPlatformGMEManager", {
	{
		methodName = "StartRecording"
	},
	{
		methodName = "UploadRecordedFile"
	}
})
loader.registerDynamicHooks("Guis.Panels.PlayerEnhanceLoading.PlayerEnhanceLoadingCtrl", "SDK.Platform.UIBridge.ImpPlatformPlayerEnhanceLoadingCtrl", {
	{
		methodName = "onShow"
	},
	{
		methodName = "onHide"
	},
	{
		methodName = "onDestroy"
	},
	{
		methodName = "onStartEnter"
	},
	{
		methodName = "afterOpenPlayerEnhanceInBackground"
	}
}, "_platformImpPlatformPlayerEnhanceLoadingCtrl")
loader.registerDynamicHooks("Guis.Panels.PiecesItemTip.PiecesItemTipCtrl", "SDK.Platform.UIBridge.ImpPlatformPiecesItemTipCtrl", {
	{
		methodName = "onShow"
	},
	{
		methodName = "onHide"
	},
	{
		methodName = "onDestroy"
	}
}, "_platformImpPlatformPiecesItemTipCtrl")
