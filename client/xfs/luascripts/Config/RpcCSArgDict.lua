-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Config\\RpcCSArgDict.lua

local Config = {
	RPC_CS_SendBallMsg = {
		"string",
		"table"
	},
	RPC_CS_BotPlayerCreated = {},
	RPC_CS_StartDialogue = {},
	RPC_CS_FailDialogue = {},
	RPC_CS_SuccessDialogue = {},
	RPC_CS_ExitDittoDungeon = {
		"string"
	},
	RPC_CS_InteractSheep = {
		"int"
	},
	RPC_CS_RestartRacing = {
		"string"
	},
	RPC_CS_PauseRacingTimer = {
		"string"
	},
	RPC_CS_ResumeRacingTimer = {
		"string"
	},
	RPC_CS_FinishRacing = {
		"string"
	},
	RPC_CS_SetPetPos = {
		"table",
		"table"
	},
	RPC_CS_TriggerAIMsg = {
		"number"
	},
	RPC_CS_ClientPlayerCreateInitSuccess = {},
	RPC_CS_Heartbeat = {
		"float",
		"table"
	},
	RPC_CS_ChangePlayerName = {
		"string"
	},
	RPC_CS_UpdateUIOpened = {
		"int",
		"boolean"
	},
	RPC_CS_UpdateMsGateInfo = {
		"string",
		"string",
		"boolean"
	},
	RPC_CS_ReportProcessStuckDebug = {},
	RPC_CS_SetLanguage = {
		"string"
	},
	RPC_CS_TransferBotPlayerMsg = {
		"string",
		"string",
		"table"
	},
	RPC_CS_TiktokRequest = {
		"string",
		"table"
	},
	RPC_CS_UpdateClientVersion = {
		"int",
		"int"
	},
	RPC_CS_BindSocialMediaAccount = {
		"string",
		"string"
	},
	RPC_CS_UnbindSocialMediaAccount = {
		"string"
	},
	RPC_CS_BatchResolveSocialAccounts = {
		"string",
		"string",
		"table"
	},
	RPC_CS_ChangeThemePhotographyStudioUid = {
		"string"
	},
	RPC_CS_AICallTeleport = {
		"float",
		"float",
		"float"
	},
	RPC_CS_SyncDebugPlayEffect = {
		"string",
		"float",
		"int"
	},
	RPC_CS_SyncAnimation = {
		"int"
	},
	RPC_CS_FinishOpeningShow = {
		"string"
	},
	RPC_CS_SelectBuff = {
		"string",
		"table"
	},
	RPC_CS_ReRandomBuff = {
		"string"
	},
	RPC_CS_StartBattle = {
		"string",
		"table"
	},
	RPC_CS_ModifyBattleFormation = {
		"string",
		"table"
	},
	RPC_CS_StartGlobalFreeze = {
		"string",
		"float",
		"float",
		"float",
		"float"
	},
	RPC_CS_StartGameTime = {
		"string",
		"int",
		"float",
		"int"
	},
	RPC_CS_SyncGameTimeScaleRequest = {
		"string",
		"int",
		"float",
		"int"
	},
	RPC_CS_StopGameTime = {
		"string",
		"int",
		"int"
	},
	RPC_CS_SyncCustomEvent = {
		"string",
		"string",
		"string",
		"table"
	},
	RPC_CS_RemoteSyncAIAction = {
		"string",
		"string",
		"string",
		"table"
	},
	RPC_CS_HitPuppet = {
		"string",
		"string"
	},
	RPC_CS_BallHitTarget = {
		"string",
		"string",
		"number",
		"string"
	},
	RPC_CS_DeathBoxTeleport = {
		"string",
		"string",
		"boolean",
		"table",
		"number"
	},
	RPC_CS_RequestDestroy = {},
	RPC_CS_Avatar_RefreshAuth = {},
	RPC_CS_TriggerBlueprint = {
		"string"
	},
	RPC_CS_OnAttachBreak = {},
	RPC_CS_OnAbilityHitBreakableItem = {},
	RPC_CS_SyncAIState = {
		"int"
	},
	RPC_CS_SpecialDamage = {
		"number",
		"number"
	},
	RPC_CS_SetBacktrackPos = {},
	RPC_CS_ResetPosByRecord = {
		"table",
		"number"
	},
	RPC_CS_DumpHatredInfo = {},
	RPC_CS_TryAddHatred = {
		"int"
	},
	RPC_CS_FeatureMsg = {
		"string",
		"string",
		"table"
	},
	RPC_CS_UpdateAreaInfo = {
		"table"
	},
	RPC_CS_OnFloorHeightCheckInvalid = {
		"number"
	},
	RPC_CS_StartInteract = {
		"int",
		"string",
		"int",
		"table"
	},
	RPC_CS_Interact = {
		"int",
		"string",
		"int",
		"table"
	},
	RPC_CS_InterruptInteract = {},
	RPC_CS_InteractWithNPC = {
		"string",
		"int"
	},
	RPC_CS_ClientEventNotifyInteractWithNPC = {
		"string",
		"int"
	},
	RPC_CS_InteractWithLevelItem = {
		"int",
		"int",
		"int"
	},
	RPC_CS_PlayAppearanceAction = {
		"int",
		"string",
		"boolean"
	},
	RPC_CS_InteractNpcSandboxCustomEvent = {
		"int",
		"int",
		"boolean"
	},
	RPC_CS_InteractOrnamentSwitch = {
		"int",
		"boolean",
		"string"
	},
	RPC_CS_EnableInteractCallFriend = {
		"boolean",
		"number"
	},
	RPC_CS_LiftEntity = {
		"string",
		"int"
	},
	RPC_CS_UnLiftEntity = {
		"boolean",
		"table",
		"table"
	},
	RPC_CS_SyncPlayMagnesisEffect = {
		"string"
	},
	RPC_CS_SyncStopMagnesisEffect = {
		"string"
	},
	RPC_CS_CastAbilityNoTarget = {
		"int",
		"int"
	},
	RPC_CS_CastAbilityOnTarget = {
		"int",
		"int",
		"int"
	},
	RPC_CS_CastAbilityOnPosRot = {
		"int",
		"table",
		"table",
		"int"
	},
	RPC_CS_NotifyAbilityTeleport = {
		"number",
		"table",
		"table",
		"table"
	},
	RPC_CS_ProjectileHitTarget = {
		"number",
		"table",
		"table",
		"table",
		"number",
		"int"
	},
	RPC_CS_NotifyProjHit = {
		"number",
		"number",
		"number",
		"string",
		"table"
	},
	RPC_CS_ProjectileOnGround = {
		"number",
		"table",
		"table"
	},
	RPC_CS_LockTarget = {
		"number",
		"boolean"
	},
	RPC_CS_ChangeAttackTarget = {
		"number"
	},
	RPC_CS_StopCombatActionTimeline = {
		"boolean"
	},
	RPC_CS_AddProjectile = {
		"table",
		"number",
		"table"
	},
	RPC_CS_NotifyCustomEvent = {
		"string",
		"table"
	},
	RPC_CS_StartCharge = {
		"number",
		"number"
	},
	RPC_CS_StopCharge = {
		"number",
		"number"
	},
	RPC_CS_NotifySwitch = {
		"number",
		"boolean"
	},
	RPC_CS_ProjectileDestroy = {
		"number",
		"table",
		"table"
	},
	RPC_CS_ProjectileFinish = {
		"number",
		"table",
		"table"
	},
	RPC_CS_SetCombatActionTimeline = {
		"number",
		"number",
		"table",
		"number",
		"table"
	},
	RPC_CS_SetHitActionTimeline = {
		"number",
		"number",
		"number"
	},
	RPC_CS_DoActOnActorActions = {
		"number",
		"table"
	},
	RPC_CS_NotifyActOnActor = {
		"number",
		"number",
		"string",
		"table"
	},
	RPC_CS_ActOnActorsEnd = {
		"number",
		"table"
	},
	RPC_CS_DoFindTargetAction = {
		"number",
		"table"
	},
	RPC_CS_DoTagReaction = {
		"number",
		"table",
		"number"
	},
	RPC_CS_JumpToNextTimelineByCombo = {
		"string",
		"number",
		"number"
	},
	RPC_CS_JumpToNextTimeline = {
		"string",
		"number",
		"number",
		"number",
		"table"
	},
	RPC_CS_StopActionTimeline = {
		"string",
		"number"
	},
	RPC_CS_StopTimelineByTime = {
		"number",
		"number"
	},
	RPC_CS_SetKnockState = {
		"number"
	},
	RPC_CS_ChainPropagation = {
		"number",
		"table"
	},
	RPC_SC_StunOnCollision = {
		"string",
		"number"
	},
	RPC_CS_OnAbilityCollisionHitTarget = {
		"table",
		"table",
		"table"
	},
	RPC_CS_OnTriggerAbilityCollisionHit = {
		"table",
		"table"
	},
	RPC_CS_OnSkillHookWait = {
		"float",
		"float",
		"float"
	},
	RPC_CS_OnSkillHookFail = {},
	RPC_CS_OnSkillHookSuccess = {
		"float",
		"float",
		"float",
		"int"
	},
	RPC_CS_OnSkillHookEnd = {},
	RPC_CS_OnSkillHookExit = {},
	RPC_CS_OnMovementHitBlocked = {},
	RPC_CS_ProjectileReset = {
		"number",
		"table",
		"table",
		"number",
		"table"
	},
	RPC_CS_ChangeTpInCast = {
		"number",
		"number",
		"boolean"
	},
	RPC_CS_AddAbilityImpulse = {
		"table",
		"number",
		"table"
	},
	RPC_CS_DoActOnSweepTargetsActions = {
		"table",
		"number",
		"table"
	},
	RPC_CS_NotifyActOnSweepTargets = {
		"number",
		"number",
		"string",
		"table"
	},
	RPC_CS_OnSkillMovePathEnclosed = {
		"table",
		"table"
	},
	RPC_CS_OnInteractProj = {
		"int",
		"table"
	},
	RPC_CS_DebugModeCallDoAction = {
		"number",
		"table"
	},
	RPC_CS_DebugModeAddProjectile = {
		"table",
		"number"
	},
	RPC_CS_ClientGotRandomInt = {
		"number",
		"number",
		"string",
		"string"
	},
	RPC_CS_SetAppearDash = {
		"boolean"
	},
	RPC_CS_RePressSkillSlot = {
		"number"
	},
	RPC_CS_OnSkillMotionStateChange = {
		"table",
		"string",
		"boolean"
	},
	RPC_CS_NotifyPlayAbilityAnimation = {
		"int"
	},
	RPC_CS_DestroyByImpulse = {
		"number"
	},
	RPC_CS_DoDeathByECS = {},
	RPC_CS_LeaveAppearDash = {},
	RPC_CS_OnThornsCollision = {
		"number",
		"table",
		"boolean"
	},
	RPC_CS_OnPuppetThornsCollision = {
		"number",
		"number",
		"table",
		"boolean"
	},
	RPC_CS_OnClientCombatDataPrepared = {
		"table",
		"string"
	},
	RPC_CS_CreateCreationFromAniEvent = {
		"number",
		"table",
		"table"
	},
	RPC_CS_ReboundDashHitActor = {
		"number",
		"table"
	},
	RPC_CS_ReboundDashEnd = {},
	RPC_CS_MoveByDirectionEnd = {
		"number",
		"table"
	},
	RPC_CS_CamouFlagEnemyDetected = {
		"boolean"
	},
	RPC_CS_InflateStateChange = {
		"boolean"
	},
	RPC_CS_SyncForceBipRotation = {
		"boolean",
		"float",
		"float",
		"float",
		"float"
	},
	RPC_CS_SyncCombatContextTarget = {
		"number",
		"number"
	},
	RPC_CS_WaterAbsorbDataReady = {
		"table",
		"number",
		"number",
		"number"
	},
	RPC_CS_FinishDestroyAllProjectile = {},
	RPC_CS_OnConductHit = {
		"number",
		"table"
	},
	RPC_CS_SyncVoxelTagNum = {
		"number",
		"number"
	},
	RPC_CS_SyncServerPuppetCreationVoxelTagNum = {
		"number",
		"number",
		"string",
		"number"
	},
	RPC_CS_DoActionCallback = {
		"number",
		"table"
	},
	RPC_CS_OnPawnMovedDistanceReachThreshold = {},
	RPC_CS_OnCSProjectileHit = {
		"number",
		"number",
		"number",
		"table"
	},
	RPC_CS_OnEnterAimSense = {
		"number"
	},
	RPC_CS_AIAddBuff = {
		"int",
		"float"
	},
	RPC_CS_AIRemoveBuff = {
		"int"
	},
	RPC_CS_OnFreeAimConfirmBtnClicked = {},
	RPC_CS_OnFreeAimCancelBtnClicked = {},
	RPC_CS_FastForwardTimeline = {
		"number",
		"table",
		"number",
		"number",
		"number"
	},
	RPC_CS_DisableReturnAbilityConsumes = {
		"number"
	},
	RPC_CS_CharacterStateChange = {
		"number"
	},
	RPC_CS_AddEntityTag = {
		"int"
	},
	RPC_CS_RemoveEntityTag = {
		"int"
	},
	RPC_CS_OnReachImpulseThreshold = {},
	RPC_CS_SetEntityCacheValue = {
		"string",
		"number"
	},
	RPC_CS_RemoveEntityCacheValue = {
		"string"
	},
	RPC_CS_SetGhostEyeState = {
		"int"
	},
	RPC_CS_NotifyAbilityTeleportByUltimate = {},
	RPC_CS_EnterTrigger = {
		"string",
		"number"
	},
	RPC_CS_LeaveTrigger = {
		"string",
		"number"
	},
	RPC_CS_ReportVehicleBodyAnimationPhase = {
		"int",
		"int",
		"boolean"
	},
	RPC_CS_MountVehicle = {
		"int",
		"int"
	},
	RPC_CS_StartDriveVehicle = {
		"int"
	},
	RPC_CS_StopDriveVehicle = {
		"int"
	},
	RPC_CS_InviteRideVehicle = {
		"int",
		"string"
	},
	RPC_CS_AcceptRideVehicleInvite = {
		"int",
		"string",
		"boolean"
	},
	RPC_CS_ApplyRideVehicle = {
		"int"
	},
	RPC_CS_ApproveRideVehicleApply = {
		"int",
		"string",
		"boolean"
	},
	RPC_CS_DismountVehicle = {
		"int"
	},
	RPC_CS_DismountVehicleSeat = {
		"int"
	},
	RPC_CS_ExchangeSeat = {
		"int",
		"int",
		"int"
	},
	RPC_CS_ProgressFull = {
		"int",
		"int"
	},
	RPC_CS_PetAttractHatred = {},
	RPC_CS_ReqActReceiveTaskReward = {
		"int"
	},
	RPC_CS_ReqActReceiveGroupTaskReward = {
		"int"
	},
	RPC_CS_ReqActivityVotePet = {
		"int",
		"int"
	},
	RPC_CS_ReqActWeekPrayReceiveEgg = {
		"int"
	},
	RPC_CS_ReqActivityReunionTaskScore = {
		"int",
		"int"
	},
	RPC_CS_ReqActivityReunionScoreReward = {
		"int",
		"table"
	},
	RPC_CS_LuckyPetSubmit = {
		"int"
	},
	RPC_CS_LuckyPetGetReward = {
		"int"
	},
	RPC_CS_FormResearchReport = {
		"int",
		"table"
	},
	RPC_CS_FormResearchGetReward = {},
	RPC_CS_FormResearchGetStageReward = {
		"int"
	},
	RPC_CS_FormResearchGetObReward = {},
	RPC_CS_GetCommunityGuideReward = {
		"int",
		"int"
	},
	RPC_CS_EcoTraceSearchCreate = {},
	RPC_CS_GetEnergyMatchAward = {
		"int"
	},
	RPC_CS_GetTotalScore = {
		"string",
		"table"
	},
	RPC_CS_ReceivePetSaveWeekSumyReward = {
		"int"
	},
	RPC_CS_ReqActArkCarnVoteMusicPet = {
		"int",
		"table"
	},
	RPC_CS_ActArkCarnTakePhotePet = {
		"table"
	},
	RPC_CS_ActArkCarnTakePhotoStagePet = {},
	RPC_CS_ReqActPetDispatchStart = {
		"int",
		"table"
	},
	RPC_CS_ReqActPetDispatchRecall = {
		"int"
	},
	RPC_CS_ActivityAddedWeCom = {
		"int"
	},
	RPC_CS_ExchangeGiftCode = {
		"string"
	},
	RPC_CS_PreHeatGuideActivity = {
		"int"
	},
	RPC_CS_BattlePassBuyBpLevel = {
		"int"
	},
	RPC_CS_BattlePassReceiveBackItem = {},
	RPC_CS_GrowthGiftChooseEgg = {
		"int"
	},
	RPC_CS_GrowthGiftReceiveEgg = {},
	RPC_CS_ReceiveBindAccountAward = {
		"int"
	},
	RPC_CS_GetBindAccountAwardStatus = {},
	RPC_CS_GetGuideMiniProgramCode = {
		"string"
	},
	RPC_CS_ReceiveBpCycleReward = {},
	RPC_CS_SetAvatarConfig = {
		"string",
		"int"
	},
	RPC_CS_CheckAvatarSuitUnlocked = {
		"int"
	},
	RPC_CS_SetAvatarMakeupConfig = {
		"string",
		"int"
	},
	RPC_CS_SetAppearanceShow = {
		"int",
		"boolean",
		"int"
	},
	RPC_CS_MultiSetAppearanceShow = {
		"table"
	},
	RPC_CS_SetSuitShow = {
		"int"
	},
	RPC_CS_UnlockCustom = {},
	RPC_CS_UnlockHairCustom = {
		"int"
	},
	RPC_CS_UnlockMakeUpCustom = {},
	RPC_CS_UnlockClothesDesignInfo = {
		"int"
	},
	RPC_CS_UnlockPoint = {
		"int"
	},
	RPC_CS_UnlockJewelryInfo = {
		"int",
		"int"
	},
	RPC_CS_SetJewelryInfo = {
		"int",
		"int",
		"table"
	},
	RPC_CS_DesignClothes = {
		"int",
		"int",
		"table",
		"string"
	},
	RPC_CS_ApplyClothesDesign = {
		"int",
		"int",
		"int"
	},
	RPC_CS_UpdateAppearanceCustom = {
		"string",
		"int",
		"boolean",
		"table"
	},
	RPC_CS_SetCustomNameAndBag = {
		"string",
		"int",
		"string",
		"boolean"
	},
	RPC_CS_SaveHairCustom = {
		"int",
		"int",
		"table",
		"string",
		"string"
	},
	RPC_CS_SaveMakeUpCustom = {
		"int",
		"table"
	},
	RPC_CS_SaveAppearanceCustom = {
		"int",
		"table",
		"string"
	},
	RPC_CS_SetHairCustom = {
		"int",
		"int"
	},
	RPC_CS_SetMakeUpCustom = {
		"int"
	},
	RPC_CS_SetAppearanceCustom = {
		"int"
	},
	RPC_CS_UploadAppearancePhoto = {
		"string",
		"string"
	},
	RPC_CS_CheckAppearanceItemList = {
		"table"
	},
	RPC_CS_SetAppearanceBackGround = {
		"int",
		"int"
	},
	RPC_CS_SetQuickCaptureItemId = {
		"int"
	},
	RPC_CS_CaptureHoldBall = {
		"string",
		"int"
	},
	RPC_CS_CaptureClearBall = {
		"string"
	},
	RPC_CS_PlayerHoldEnv = {
		"string"
	},
	RPC_CS_PlayerUnHoldEnv = {
		"string"
	},
	RPC_CS_FireBall = {
		"int",
		"string",
		"int"
	},
	RPC_CS_NotifyCatchBallMissed = {
		"string"
	},
	RPC_CS_BallHitEntity = {
		"string",
		"string",
		"boolean"
	},
	RPC_CS_NotifyCaptureAnimStart = {
		"string",
		"table"
	},
	RPC_CS_NotifyCaptureAnimEnd = {
		"string",
		"table"
	},
	RPC_CS_CaptureBossMonster = {
		"string",
		"int",
		"boolean"
	},
	RPC_CS_StartPlayerTeamChainAttack = {},
	RPC_CS_RespondPlayerTeamChainChance = {
		"string"
	},
	RPC_CS_StartNextPlayerTeamChainRespond = {
		"number"
	},
	RPC_CS_TriggerPlayerTeamExtremeChain = {
		"number"
	},
	RPC_CS_ReportChat = {
		"table"
	},
	RPC_CS_OpenPrivateChat = {
		"boolean",
		"string"
	},
	RPC_CS_SwitchChannel = {
		"string",
		"number"
	},
	RPC_CS_GetChatPositionCard = {},
	RPC_CS_GoChatPositionCard = {
		"table"
	},
	RPC_CS_NotifyPlayerTyping = {
		"table",
		"int"
	},
	RPC_CS_SetSkipScenePromptToday = {
		"boolean"
	},
	RPC_CS_StartDialogueGroup = {
		"int"
	},
	RPC_CS_SetDialogueGroup = {
		"int",
		"int",
		"int",
		"table"
	},
	RPC_CS_SkipDialogueGroup = {
		"int",
		"int",
		"int",
		"table"
	},
	RPC_CS_RequestPlayDialogueGraph = {
		"int",
		"table"
	},
	RPC_CS_FinishPlayDialogueGraph = {
		"int",
		"int",
		"table",
		"table"
	},
	RPC_CS_ForbidPositionCheck = {
		"table"
	},
	RPC_CS_ReqBatchDialogue = {
		"int",
		"table",
		"boolean"
	},
	RPC_CS_DialoguePauseRenewInvincible = {
		"table",
		"int"
	},
	RPC_CS_SpaceMethod = {
		"int",
		"table"
	},
	RPC_CS_ReliableSpaceMethod = {
		"int",
		"table",
		"string"
	},
	RPC_CS_OtherEntityMethod = {
		"string",
		"string",
		"table"
	},
	RPC_CS_OtherEntityMethod_Bot = {
		"string",
		"string",
		"table"
	},
	RPC_CS_SetPlayerAoiLevel = {
		"int",
		"int"
	},
	RPC_CS_RequestCreateClientEntity = {
		"string"
	},
	RPC_CS_ServerEntityMsg = {
		"string",
		"int",
		"table"
	},
	RPC_CS_ClientLoggerReport = {
		"table"
	},
	RPC_CS_GetLevelReward = {
		"table"
	},
	RPC_CS_PlayerSwitchAbility = {
		"int",
		"int"
	},
	RPC_CS_UnlockSkillNode = {
		"int"
	},
	RPC_CS_upgradeSkillNode = {
		"int"
	},
	RPC_CS_ResetSkillTree = {
		"boolean"
	},
	RPC_CS_AddCustomAbilityIds = {
		"boolean"
	},
	RPC_CS_DeleteCustomAbilityIds = {
		"boolean",
		"int"
	},
	RPC_CS_UpdateCustomAbilityIdsName = {
		"boolean",
		"string"
	},
	RPC_CS_UpdateFightAbilityId = {
		"int",
		"int"
	},
	RPC_CS_UpdateExploreAbilityId = {
		"int",
		"int"
	},
	RPC_CS_SelectCustomAbilityIds = {
		"boolean",
		"int"
	},
	RPC_CS_StartReTriggerEvent = {
		"boolean"
	},
	RPC_CS_doEventFromClient = {
		"string",
		"table",
		"table"
	},
	RPC_CS_GetRecentDungeonPlaymates = {},
	RPC_CS_GetRecommendPlayer = {},
	RPC_CS_UnlockFriendshipPermission = {
		"string",
		"int"
	},
	RPC_CS_SendGift = {
		"string",
		"table"
	},
	RPC_CS_AddIntimacyByChat = {
		"string"
	},
	RPC_CS_InviteEnterPhotoWorld = {
		"string"
	},
	RPC_CS_HandleEnterPhotoWorldRequest = {
		"table",
		"table"
	},
	RPC_CS_CreatePlatformShellInviteToken = {
		"string",
		"string",
		"boolean"
	},
	RPC_CS_QueryPlatformShellInviteDestination = {
		"table"
	},
	RPC_CS_AcceptPlatformShellInvite = {
		"table"
	},
	RPC_CS_RequestPsnBlockStates = {
		"table"
	},
	RPC_CS_CreateDiscordActivityInvite = {
		"int",
		"string"
	},
	RPC_CS_AcceptDiscordActivityInvite = {
		"string"
	},
	RPC_CS_GachaDraw = {
		"int",
		"int"
	},
	RPC_CS_GachaClaimTimesReward = {
		"int",
		"int"
	},
	RPC_CS_GachaShare = {
		"int",
		"table"
	},
	RPC_CS_GachaClaimShareReward = {
		"string",
		"int"
	},
	RPC_CS_QueryShareInfo = {
		"string"
	},
	RPC_CS_ResetTarget = {
		"int"
	},
	RPC_CS_CurrencyConsumeEvent = {
		"int"
	},
	RPC_CS_ThrowItemFromRobBag = {
		"int",
		"int",
		"int"
	},
	RPC_CS_UseItemById = {
		"int",
		"int",
		"table"
	},
	RPC_CS_UseItem = {
		"int",
		"int",
		"int",
		"table"
	},
	RPC_CS_SetQuickSlotBall = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_SetQuickSlotItem = {
		"int",
		"int"
	},
	RPC_CS_ModifyItemStatus = {
		"int",
		"table",
		"int",
		"boolean"
	},
	RPC_CS_ItemDecompose = {
		"int",
		"table"
	},
	RPC_CS_ThrowItem = {
		"int",
		"int"
	},
	RPC_CS_ItemCompoundProduce = {
		"int",
		"int"
	},
	RPC_CS_OnItemSpecialNotify = {
		"int"
	},
	RPC_CS_OnPiecesNotify = {
		"int"
	},
	RPC_CS_LeylineFlowerNourish = {
		"int",
		"table"
	},
	RPC_CS_UpgradeLeylineTree = {
		"int",
		"int"
	},
	RPC_CS_LeylineTreeChangeMeteorology = {
		"int",
		"int"
	},
	RPC_CS_ClaimLeylineTreeLevelReward = {
		"int",
		"int"
	},
	RPC_CS_OnMagnesisControl = {
		"string"
	},
	RPC_CS_OnMagnesisThrow = {
		"table"
	},
	RPC_CS_OnMagnesisLevel = {
		"table",
		"boolean"
	},
	RPC_CS_MagnesisHitTarget = {
		"table",
		"table"
	},
	RPC_CS_SyncPlayerPlayMagnesisEffect = {
		"string"
	},
	RPC_CS_SyncPlayerStopMagnesisEffect = {
		"string"
	},
	RPC_CS_ReceiveMailGift = {
		"table"
	},
	RPC_CS_ReceiveAllMailGift = {},
	RPC_CS_DeleteMail = {
		"table"
	},
	RPC_CS_DeleteReadedMail = {},
	RPC_CS_SyncMapBlockId = {
		"int",
		"int"
	},
	RPC_CS_SyncMapFormalBlockId = {
		"int",
		"int"
	},
	RPC_CS_MapMarkUnlock = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_AddCustomMapMark = {
		"int",
		"int",
		"table",
		"string"
	},
	RPC_CS_DelCustomMapMark = {
		"int",
		"int"
	},
	RPC_CS_UpdateCustomMapMark = {
		"int",
		"int",
		"table"
	},
	RPC_CS_TrackTeamMapMark = {
		"int",
		"int",
		"int"
	},
	RPC_CS_UnTrackTeamMapMark = {
		"int",
		"int",
		"int"
	},
	RPC_CS_ShowMapPuppetLevel = {
		"table"
	},
	RPC_CS_RefreshMapFog = {
		"int",
		"int",
		"table"
	},
	RPC_CS_ChangeMapShowScale = {
		"int",
		"float"
	},
	RPC_CS_ChangeQuestMarkStatus = {
		"int",
		"int"
	},
	RPC_CS_AddMediaMarker = {
		"int",
		"table"
	},
	RPC_CS_RemoveMediaMarker = {
		"string"
	},
	RPC_CS_LikeMediaMarker = {
		"string",
		"string"
	},
	RPC_CS_LikeSysMediaMarker = {
		"string",
		"table"
	},
	RPC_CS_DislikeMediaMarker = {
		"string",
		"string"
	},
	RPC_CS_DislikeSysMediaMarker = {
		"string",
		"table"
	},
	RPC_CS_SetMediaMarkerView = {
		"int"
	},
	RPC_CS_NpcFirstMeet = {
		"int"
	},
	RPC_CS_SetDirectBuySwitchChecked = {
		"boolean"
	},
	RPC_CS_ClaimRechargeRebateReward = {},
	RPC_CS_CreatePayOrder = {
		"string",
		"string",
		"string",
		"string"
	},
	RPC_CS_DeletePayOrder = {
		"string"
	},
	RPC_CS_StartHatchPetEgg = {
		"int",
		"int",
		"int"
	},
	RPC_CS_QuitHatchPetEgg = {
		"int"
	},
	RPC_CS_GetHatchPetEgg = {
		"int",
		"int"
	},
	RPC_CS_PutPetEgg = {
		"int",
		"int"
	},
	RPC_CS_GetBlockCatchReward = {
		"int",
		"int"
	},
	RPC_CS_PetResearchTargetsReward = {
		"table"
	},
	RPC_CS_PetResearchClearNew = {
		"int",
		"int",
		"table"
	},
	RPC_CS_GetPetResearchLevelReward = {
		"int",
		"int"
	},
	RPC_CS_GetAllPetResearchLevelReward = {},
	RPC_CS_GetPetHandbookCountryLevelReward = {
		"int",
		"int"
	},
	RPC_CS_GetPetHandbookCountryCollectReward = {
		"int",
		"int"
	},
	RPC_CS_GetPetHandbookSpeciesCollectReward = {
		"int",
		"int"
	},
	RPC_CS_PetResearchReport = {
		"int"
	},
	RPC_CS_ChangeDisplayPetForm = {
		"int",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_ChangeDisplayPetLabel = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_ChangeSortMode = {
		"int"
	},
	RPC_CS_ChangeDisplayMode = {
		"int"
	},
	RPC_CS_CustomPetName = {
		"string",
		"string"
	},
	RPC_CS_PetModifyAbilityPreset = {
		"string",
		"int",
		"int",
		"int"
	},
	RPC_CS_PetApplyAbilityPreset = {
		"string",
		"int"
	},
	RPC_CS_PetRenameAbilityPreset = {
		"string",
		"int",
		"string"
	},
	RPC_CS_UnlockPetAppearancePoint = {
		"int"
	},
	RPC_CS_UnlockPetAppearanceCustom = {
		"int"
	},
	RPC_CS_MultiSetPetJewelry = {
		"string",
		"table"
	},
	RPC_CS_SetPetJewelryInfo = {
		"string",
		"int",
		"table"
	},
	RPC_CS_SavePetJewelryCustom = {
		"int",
		"int",
		"string"
	},
	RPC_CS_SetPetJewelryCustom = {
		"int",
		"int",
		"table",
		"table"
	},
	RPC_CS_SetPetJewelryCustomName = {
		"int",
		"int",
		"string"
	},
	RPC_CS_ApplyPetJewelryCustom = {
		"string",
		"int"
	},
	RPC_CS_PetBreedSelf = {
		"string",
		"string",
		"table"
	},
	RPC_CS_ShowPet = {
		"int",
		"int",
		"int"
	},
	RPC_CS_NotifyExitSupportPetControl = {},
	RPC_CS_HidePet = {},
	RPC_CS_StartControll = {
		"int"
	},
	RPC_CS_QuickBattlePet = {
		"string",
		"int"
	},
	RPC_CS_StopControll = {
		"int"
	},
	RPC_CS_StartExploreControll = {
		"int",
		"int"
	},
	RPC_CS_StopExploreControll = {
		"int"
	},
	RPC_CS_LeavePet = {},
	RPC_CS_PetBoxUpdateSequence = {
		"table"
	},
	RPC_CS_PetBoxMovePet = {
		"string",
		"int",
		"int"
	},
	RPC_CS_PetBoxSwitchLocked = {
		"int",
		"boolean"
	},
	RPC_CS_PetBoxAutoAdjust = {
		"int",
		"int",
		"int"
	},
	RPC_CS_PetBoxSetCurIndex = {
		"int"
	},
	RPC_CS_PetBoxRename = {
		"int",
		"string"
	},
	RPC_CS_PetModifyFavorite = {
		"string",
		"boolean"
	},
	RPC_CS_PetModifyFavoriteType = {
		"string",
		"int"
	},
	RPC_CS_PetCatchReport = {
		"table"
	},
	RPC_CS_SetPetActionMode = {
		"int"
	},
	RPC_CS_StartPetBehavior = {
		"int",
		"int"
	},
	RPC_CS_StartCallFriend = {
		"int",
		"int"
	},
	RPC_CS_UnFairPvpChangeCharacter = {
		"string",
		"int"
	},
	RPC_CS_UpdateTwinChoiceScore = {
		"int"
	},
	RPC_CS_UpdateTwinPetChoice = {
		"int"
	},
	RPC_CS_ExportPetLegacy = {
		"string"
	},
	RPC_CS_ImportPetLegacy = {},
	RPC_CS_GenPetPreviewAttributeValue = {
		"string",
		"table"
	},
	RPC_CS_GivePetToSpaceFollower = {
		"string",
		"string"
	},
	RPC_CS_PetCreateTransmogScheme = {
		"string",
		"table"
	},
	RPC_CS_PetSaveTransmogSchemeToCustom = {
		"string",
		"int",
		"string"
	},
	RPC_CS_PetReplaceCustomTransmogScheme = {
		"string",
		"int",
		"int",
		"string"
	},
	RPC_CS_PetDelTransmogScheme = {
		"string",
		"int"
	},
	RPC_CS_PetUseCustomTransmogScheme = {
		"string",
		"int"
	},
	RPC_CS_PetUseCurrTransmogScheme = {
		"string",
		"string"
	},
	RPC_CS_PetReplaceAndUseCurrTransmogScheme = {
		"string",
		"int",
		"string"
	},
	RPC_CS_PetLockTransmogSchemeHole = {
		"string",
		"table"
	},
	RPC_CS_SetUseItemFlag = {
		"string",
		"boolean"
	},
	RPC_CS_PetBreakthrough = {
		"string"
	},
	RPC_CS_StartEvolve = {
		"string",
		"int"
	},
	RPC_CS_StartChangeForm = {
		"string",
		"int"
	},
	RPC_CS_RecyclePet = {
		"table"
	},
	RPC_CS_LearnPetAbility = {
		"string",
		"int"
	},
	RPC_CS_LearnPetPropLevel = {
		"string",
		"int",
		"int"
	},
	RPC_CS_ResetPetPropLevel = {
		"string"
	},
	RPC_CS_InheritPetPropLevel = {
		"string",
		"string"
	},
	RPC_CS_EquipCoreCarry = {
		"string",
		"int",
		"int"
	},
	RPC_CS_UnequipCoreCarry = {
		"string"
	},
	RPC_CS_UpgradeCoreCarry = {
		"int",
		"int",
		"table",
		"table"
	},
	RPC_CS_CertifyCoreCarry = {
		"string"
	},
	RPC_CS_ComposeAssistCarry = {
		"table"
	},
	RPC_CS_AddAssistCarry = {
		"int",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_RemoveAssistCarry = {
		"int",
		"int",
		"int"
	},
	RPC_CS_BatchEquipCarry = {
		"string",
		"table"
	},
	RPC_CS_UpgradeResonance = {
		"string"
	},
	RPC_CS_ModifyPrepareFormation = {
		"int",
		"table",
		"boolean"
	},
	RPC_CS_RenamePrepareFormation = {
		"int",
		"string"
	},
	RPC_CS_SelectPrepareFormation = {
		"int"
	},
	RPC_CS_DeletePrepareFormation = {
		"int"
	},
	RPC_CS_TakePhoto = {
		"table",
		"string"
	},
	RPC_CS_TakePhotoGuess = {
		"int"
	},
	RPC_CS_TakePhotePet = {},
	RPC_CS_SavePhotoPresetAdd = {
		"string"
	},
	RPC_CS_SavePhotoPresetDel = {
		"string"
	},
	RPC_CS_LikePhotoPresetAdd = {
		"string"
	},
	RPC_CS_LikePhotoPresetDel = {
		"string"
	},
	RPC_CS_CheckPhotoUploadLimit = {},
	RPC_CS_UploadPhotoLightScheme = {
		"int",
		"string"
	},
	RPC_CS_RemoveOSSPhoto = {
		"string"
	},
	RPC_CS_ReqPhotoStudioUnlock = {
		"int"
	},
	RPC_CS_NotifyPhotoStudioMsg = {
		"table"
	},
	RPC_CS_SendMainPhotoStudioMsg = {
		"table"
	},
	RPC_CS_SendSpecifyPhotoStudioMsg = {
		"table",
		"table"
	},
	RPC_CS_ReqPhotographyStudioUnlock = {},
	RPC_CS_CreatePhotographyStudio = {},
	RPC_CS_UpdatePhotographyStudioName = {
		"string",
		"string"
	},
	RPC_CS_SyncPhotographyStudioContent = {
		"string",
		"string"
	},
	RPC_CS_InvitePhotographyStudio = {
		"string",
		"string"
	},
	RPC_CS_AcceptInvitePhotographyStudio = {
		"string",
		"string"
	},
	RPC_CS_RemoveInvitePhotographyStudio = {
		"string",
		"string"
	},
	RPC_CS_RemovePhotographyStudio = {
		"string",
		"string"
	},
	RPC_CS_LeaveInvitePhotographyStudio = {
		"string",
		"string"
	},
	RPC_CS_ChangeProfilePhotographyStudioUid = {
		"string"
	},
	RPC_CS_EnterPhotographyStudio = {
		"string"
	},
	RPC_CS_GetPhotographyStudioActives = {
		"string"
	},
	RPC_CS_LeavePhotographyStudio = {
		"string"
	},
	RPC_CS_UpQualityById = {
		"int"
	},
	RPC_CS_UpQualityAll = {},
	RPC_CS_BadgeRewards = {
		"int"
	},
	RPC_CS_PlayAnime = {},
	RPC_CS_SetBadgeShow = {
		"table"
	},
	RPC_CS_ConfirmContinueDungeon = {
		"int"
	},
	RPC_CS_BossRushGotoGuanka = {
		"int"
	},
	RPC_CS_BossRushSetBatPetList = {
		"int",
		"table"
	},
	RPC_CS_BossRushSelectTankEntId = {
		"string"
	},
	RPC_CS_BossRushSelectBattleBuff = {
		"int"
	},
	RPC_CS_BossRushGuankaEndBat = {},
	RPC_CS_BossRushGuankaBatAgain = {},
	RPC_CS_BossRushQuitAndSettle = {},
	RPC_CS_BossRushRequireAddBot = {},
	RPC_CS_BossRushOpenChangeBoss = {
		"int"
	},
	RPC_CS_BossRushCancelOpen = {},
	RPC_CS_BossRushPrepare = {
		"int",
		"int"
	},
	RPC_CS_BossRushReceiveSeasonReward = {
		"int"
	},
	RPC_CS_BossRushReceiveAllSeasonReward = {},
	RPC_CS_PlayerEnterCafeArea = {
		"int"
	},
	RPC_CS_PlayerLeaveCafeArea = {
		"int"
	},
	RPC_CS_CarryOp = {
		"int",
		"table"
	},
	RPC_CS_CatchRogueOp = {
		"int",
		"table"
	},
	RPC_CS_TestCreateStumpPuppet = {
		"int",
		"boolean",
		"boolean"
	},
	RPC_CS_DestoryStumpPuppet = {},
	RPC_CS_StumpPuppetSwitch = {
		"boolean"
	},
	RPC_CS_StartRevive = {
		"number"
	},
	RPC_CS_GroupDropChoice = {
		"int",
		"int"
	},
	RPC_CS_ExitProgressDisengage = {
		"number",
		"number"
	},
	RPC_CS_StartCommonExchange = {
		"int"
	},
	RPC_CS_FinishCommonExchange = {
		"int"
	},
	RPC_CS_DoGmCmd = {
		"string",
		"table"
	},
	RPC_CS_RequestPlayerGmList = {},
	RPC_CS_DoPlayerGmCmd = {
		"string",
		"table"
	},
	RPC_CS_StressTestMethod = {
		"string",
		"table"
	},
	RPC_CS_DebugTeleportScene = {
		"int"
	},
	RPC_CS_DebugCheckAttributeConstVersion = {
		"string"
	},
	RPC_CS_BotServerTest = {
		"int",
		"string",
		"table"
	},
	RPC_CS_FishingCaptureOp = {
		"int",
		"table"
	},
	RPC_CS_ReqFluteMatch = {
		"int",
		"int"
	},
	RPC_CS_StopFluteMatch = {},
	RPC_CS_ReplyFluteNotify = {
		"string",
		"string"
	},
	RPC_CS_AcceptFluteNotify = {
		"string",
		"string"
	},
	RPC_CS_PullScrollingtext = {},
	RPC_CS_FinishedSurvey = {
		"int"
	},
	RPC_CS_FinishedFirstDisplaySurvey = {
		"int"
	},
	RPC_CS_SetIsNewGamerToFalse = {},
	RPC_CS_UnlockHelpItem = {
		"int"
	},
	RPC_CS_StartGuidanceRecord = {
		"int"
	},
	RPC_CS_UnlockCourse = {
		"int"
	},
	RPC_CS_StartCourse = {
		"int"
	},
	RPC_CS_ContinueNextCourse = {
		"int"
	},
	RPC_CS_GetCourseLevelReward = {
		"int",
		"int"
	},
	RPC_CS_GetCourseReward = {
		"int"
	},
	RPC_CS_SubmitHomeCampSnapshot = {
		"string"
	},
	RPC_CS_ReqEnterSelfHomeCamp = {},
	RPC_CS_ReqEnterHomeCamp = {
		"string",
		"string"
	},
	RPC_CS_HomeCampOp = {
		"int",
		"table"
	},
	RPC_CS_AddCarOrnament = {
		"table"
	},
	RPC_CS_AddCarOrnaments = {
		"table"
	},
	RPC_CS_RemoveCarOrnament = {
		"int"
	},
	RPC_CS_RemoveCarOrnaments = {
		"table"
	},
	RPC_CS_UpdateCarOrnament = {
		"int",
		"table"
	},
	RPC_CS_UpdateCarOrnaments = {
		"table",
		"table"
	},
	RPC_CS_RecordHandbookViewedGrade = {},
	RPC_CS_ReceiveHandbookGradeReward = {},
	RPC_CS_ReceiveCategoryProgressReward = {
		"int"
	},
	RPC_CS_ReceiveHomeSeasonTaskReward = {
		"int"
	},
	RPC_CS_SubmitHomeSeasonOrder = {
		"int"
	},
	RPC_CS_ReceiveHomeSeasonCollectionReward = {
		"int"
	},
	RPC_CS_StartHomeSeasonCelebration = {
		"int"
	},
	RPC_CS_BeginHomeSeasonCelebration = {},
	RPC_CS_CancelHomeSeasonCelebration = {},
	RPC_CS_RecordHomeSeasonMutation = {
		"int"
	},
	RPC_CS_ReceiveHomeSeasonMutationReward = {
		"table"
	},
	RPC_CS_DecomposeHomeSeasonMutationItems = {
		"table"
	},
	RPC_CS_SendHomeSeasonMutationGift = {
		"string",
		"int"
	},
	RPC_CS_RequestHelpToFriend = {
		"string",
		"int"
	},
	RPC_CS_RequestHelpToChannel = {
		"string",
		"int"
	},
	RPC_CS_RespondHelp = {
		"string"
	},
	RPC_CS_GetSimulateOutputRecord = {},
	RPC_CS_SetHomelandBgm = {
		"int"
	},
	RPC_CS_SubmitHomelandSnapshot = {
		"string"
	},
	RPC_CS_UnlockHomeland = {},
	RPC_CS_ReqEnterSelfHomeland = {},
	RPC_CS_ReqEnterHomeland = {
		"string"
	},
	RPC_CS_DeleteHomeBlueprintBuildGroup = {
		"int"
	},
	RPC_CS_UploadHomeBlueprint = {
		"table",
		"string",
		"string",
		"table",
		"table"
	},
	RPC_CS_QueryHomeBlueprintByCode = {
		"string"
	},
	RPC_CS_SaveOtherHomeBlueprint = {
		"string"
	},
	RPC_CS_DeleteUploadedHomeBlueprint = {
		"string"
	},
	RPC_CS_UpdateUploadedHomeBlueprint = {
		"string",
		"string",
		"string",
		"table"
	},
	RPC_CS_DeleteSavedOtherHomeBlueprint = {
		"string"
	},
	RPC_CS_GetHomeBlueprintTabList = {
		"int",
		"int",
		"int"
	},
	RPC_CS_BuildHomeBlueprint = {
		"int",
		"string",
		"table",
		"int",
		"int"
	},
	RPC_CS_AddOrnament = {
		"table",
		"table"
	},
	RPC_CS_AddOrnaments = {
		"table",
		"table"
	},
	RPC_CS_RemoveOrnament = {
		"int"
	},
	RPC_CS_RemoveOrnaments = {
		"table"
	},
	RPC_CS_ClearAllHomeOrnaments = {
		"int"
	},
	RPC_CS_UpdateOrnament = {
		"int",
		"table",
		"table"
	},
	RPC_CS_UpdateOrnaments = {
		"table",
		"table"
	},
	RPC_CS_LiftOrnaments = {
		"table"
	},
	RPC_CS_UpgradeOrnament = {
		"int",
		"int"
	},
	RPC_CS_CleanTrash = {
		"int"
	},
	RPC_CS_BuyOrnament = {
		"int"
	},
	RPC_CS_BuyMultiOrnament = {
		"int",
		"int"
	},
	RPC_CS_RedeemMultiOrnament = {
		"int",
		"int"
	},
	RPC_CS_FavoriteOrnament = {
		"int",
		"int"
	},
	RPC_CS_FavoriteCarOrnament = {
		"int",
		"int"
	},
	RPC_CS_BatchAddHomelandPet = {
		"table",
		"int"
	},
	RPC_CS_AddHomelandPet = {
		"string",
		"int",
		"int"
	},
	RPC_CS_BatchRemoveHomelandPet = {
		"table",
		"int",
		"table",
		"int"
	},
	RPC_CS_RemoveHomelandPet = {
		"string",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_UpdateHomelandPetPosition = {
		"string",
		"table"
	},
	RPC_CS_UpdateHomelandPetIndex = {
		"string",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_HomelandSellMaterials = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_AccelerateHomelandPlant = {
		"int"
	},
	RPC_CS_BatchAccelerateHomelandPlant = {
		"table"
	},
	RPC_CS_SetHomelandFacilityDisable = {
		"int",
		"boolean"
	},
	RPC_CS_SetHomelandFacilityEnvParam = {
		"int",
		"int"
	},
	RPC_CS_SetHomelandFacilityElectricMode = {
		"int",
		"boolean"
	},
	RPC_CS_SetHomelandProduce = {
		"int",
		"int"
	},
	RPC_CS_RemoveHomelandProduce = {
		"int",
		"int"
	},
	RPC_CS_ResetHomelandProduce = {
		"int",
		"int",
		"int"
	},
	RPC_CS_AllocateHomePet = {
		"string",
		"int",
		"int",
		"boolean"
	},
	RPC_CS_DeallocateHomePet = {
		"string",
		"int",
		"boolean"
	},
	RPC_CS_ResetAllHomePetWork = {},
	RPC_CS_AllocatePlayerWork = {
		"int",
		"int"
	},
	RPC_CS_CancelHomeInteractState = {},
	RPC_CS_HomelandPlayerTransport = {
		"int"
	},
	RPC_CS_ReqStoreHomelandItems = {
		"table"
	},
	RPC_CS_ReqTakeHomelandItems = {
		"table"
	},
	RPC_CS_HomelandStartHatchPetEgg = {
		"int",
		"int",
		"int"
	},
	RPC_CS_HomelandQuitHatchPetEgg = {
		"int"
	},
	RPC_CS_HomelandHatchFondlePetEgg = {
		"int"
	},
	RPC_CS_HomelandItemSpeedUp = {
		"int",
		"int",
		"int"
	},
	RPC_CS_HomelandGetHatchPetEgg = {
		"int",
		"int"
	},
	RPC_CS_HomelandFoodOp = {
		"int",
		"table"
	},
	RPC_CS_HomePettingReward = {},
	RPC_CS_HomeOperationFinished = {
		"string",
		"int"
	},
	RPC_CS_HomeLeisureFinished = {
		"string",
		"int"
	},
	RPC_CS_TryMountHomeLeisureRide = {
		"string",
		"int",
		"int",
		"int"
	},
	RPC_CS_HomeLeisureManualOperationFinished = {
		"string"
	},
	RPC_CS_DoSpecialPetAIAction = {
		"string",
		"int",
		"int"
	},
	RPC_CS_CancelSpecialPetAIAction = {
		"string"
	},
	RPC_CS_SetPlantAutoCollectSwitch = {
		"int",
		"boolean"
	},
	RPC_CS_SolveMutationEvent = {
		"int"
	},
	RPC_CS_SetPinnedFormulas = {
		"table"
	},
	RPC_CS_SolveTillHelpEvents = {},
	RPC_CS_HomelandDemoGreet = {},
	RPC_CS_HomelandDemoChat = {},
	RPC_CS_HomelandDemoLearnMine = {},
	RPC_CS_HomelandDemoResetTargetChain = {},
	RPC_CS_HomeLotteryDraw = {},
	RPC_CS_CollectHomeVoucher = {
		"int"
	},
	RPC_CS_RefreshHomeOrder = {
		"int"
	},
	RPC_CS_RefreshOrderByMoney = {
		"int"
	},
	RPC_CS_SubmitHomeOrder = {
		"int"
	},
	RPC_CS_UnlockHomelandZone = {
		"int"
	},
	RPC_CS_ReqStopHornAction = {},
	RPC_CS_AcceptHornNotify = {
		"string",
		"string"
	},
	RPC_CS_SetHeadIcon = {
		"int"
	},
	RPC_CS_SetHeadFrame = {
		"int"
	},
	RPC_CS_SetChatBubble = {
		"int"
	},
	RPC_CS_SetCardBackground = {
		"int"
	},
	RPC_CS_SetShowTitle = {
		"table",
		"boolean",
		"table"
	},
	RPC_CS_SetPlayerTags = {
		"table"
	},
	RPC_CS_SetActionShowId = {
		"int"
	},
	RPC_CS_DoActionId = {
		"int"
	},
	RPC_CS_SetShowPetInfo = {
		"string"
	},
	RPC_CS_SetShowSignature = {
		"string"
	},
	RPC_CS_SetVoiceSignature = {
		"string"
	},
	RPC_CS_SetSingleActionState = {
		"int"
	},
	RPC_CS_SetActionState = {
		"int"
	},
	RPC_CS_RequestFriendAction = {
		"string",
		"number",
		"boolean"
	},
	RPC_CS_ConfirmFriendAction = {
		"string",
		"number",
		"boolean"
	},
	RPC_CS_ExitFriendAction = {},
	RPC_CS_PlayMultiAppearanceAction = {
		"int"
	},
	RPC_CS_JoinMultiAppearanceAction = {
		"string"
	},
	RPC_CS_ExitMultiAppearanceAction = {},
	RPC_CS_ReadKnowledge = {
		"table"
	},
	RPC_CS_OnShowContent = {
		"table"
	},
	RPC_CS_OnShowPieces = {
		"int"
	},
	RPC_CS_MappingRegionEnter = {
		"int"
	},
	RPC_CS_MappingRegionLeave = {
		"int"
	},
	RPC_CS_StartMatch = {
		"int",
		"int"
	},
	RPC_CS_StopMatch = {},
	RPC_CS_PvpBattleInvite = {
		"string"
	},
	RPC_CS_AcceptPvpBattleInvite = {
		"string",
		"boolean"
	},
	RPC_CS_ConfirmInvitePVPTeamInfo = {
		"string"
	},
	RPC_CS_PVPBattleAgain = {},
	RPC_CS_CanclePvpBattle = {},
	RPC_CS_MonthCardReceiveDailyAward = {},
	RPC_CS_MonthCardReceiveStoreAward = {},
	RPC_CS_OpenResourceBoxWithQTE = {
		"string",
		"float"
	},
	RPC_CS_RequestExitObMode = {},
	RPC_CS_SwitchObTarget = {
		"boolean"
	},
	RPC_CS_SplitRobBagItem = {
		"int",
		"int"
	},
	RPC_CS_SplitResourceBoxItem = {
		"string",
		"int",
		"int"
	},
	RPC_CS_TidyRobEggBag = {},
	RPC_CS_rspCarry = {
		"string",
		"boolean"
	},
	RPC_CS_EggShipInteract = {
		"int",
		"table"
	},
	RPC_CS_FetchAllRobEggBag = {},
	RPC_CS_GetDailyReward = {
		"int"
	},
	RPC_CS_RobEggActivateDG = {},
	RPC_CS_RobEggResetPosition = {
		"table",
		"number"
	},
	RPC_CS_InsertChip = {
		"int",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_RemoveChip = {
		"int",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_MoveChipFromLootBox = {
		"string",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_MoveChipToLootBox = {
		"string",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_RepairEquip = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_RepairEquipByMoney = {
		"int",
		"int"
	},
	RPC_CS_DirectInstallChip = {
		"string",
		"int",
		"int",
		"int"
	},
	RPC_CS_OpenRobEggLevelRewardBox = {
		"int"
	},
	RPC_CS_SwapRobEggEquipChip = {
		"int",
		"int",
		"int"
	},
	RPC_CS_PutIntoShowCase = {
		"int",
		"int",
		"int"
	},
	RPC_CS_PutOutSideShowCase = {
		"int",
		"int"
	},
	RPC_CS_GetShowCaseReward = {
		"int",
		"int"
	},
	RPC_CS_RefineRobEggAntique = {
		"int"
	},
	RPC_CS_GetRobEggLevelReward = {
		"int",
		"int",
		"int"
	},
	RPC_CS_OnOpenRobEggBag = {},
	RPC_CS_EnterNpcDuel = {
		"int"
	},
	RPC_CS_StartNpcDuel = {},
	RPC_CS_NpcDuelRematch = {},
	RPC_CS_NpcDuelExit = {},
	RPC_CS_FairPVPModifyTeamInfo = {
		"table",
		"int"
	},
	RPC_CS_FairPVPModifyPetInfo = {
		"table",
		"int"
	},
	RPC_CS_UnFairPVPModifyTeamInfo = {
		"table",
		"int"
	},
	RPC_CS_GetPvpRankReward = {
		"int"
	},
	RPC_CS_GetAllPvpRankReward = {},
	RPC_CS_PVPClientReady = {},
	RPC_CS_AcceptQuest = {
		"int",
		"boolean",
		"string"
	},
	RPC_CS_AbandonQuest = {
		"int"
	},
	RPC_CS_SubmitQuest = {
		"int",
		"boolean",
		"string"
	},
	RPC_CS_TraceQuest = {
		"int",
		"boolean"
	},
	RPC_CS_SetSideQuestAiTip = {
		"boolean"
	},
	RPC_CS_ReDoQuestCompleteActions = {
		"int"
	},
	RPC_CS_GetChapterQuestProgressReward = {
		"int"
	},
	RPC_CS_QuizAnswer = {
		"int",
		"boolean"
	},
	RPC_CS_QuizTimer = {
		"boolean"
	},
	RPC_CS_StopQuiz = {},
	RPC_CS_RequestQuizResult = {
		"int"
	},
	RPC_CS_RequestQuizAgain = {},
	RPC_CS_QuizSettlement = {
		"int"
	},
	RPC_CS_SendArkReward = {
		"int"
	},
	RPC_CS_RiftStart = {
		"int"
	},
	RPC_CS_RiftEnd = {},
	RPC_CS_RiftRestart = {
		"int"
	},
	RPC_CS_RiftClaimReward = {
		"int"
	},
	RPC_CS_MoveRobEggItem = {
		"int",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_InteractRegEggEntity = {
		"string",
		"int"
	},
	RPC_CS_StartDiscoveryItem = {
		"string",
		"int"
	},
	RPC_CS_EndDiscoveryItem = {
		"string",
		"int"
	},
	RPC_CS_MarkRobEggMapPos = {
		"table"
	},
	RPC_CS_RemoveRobEggMapPos = {},
	RPC_CS_TakeItemFromResourceBox = {
		"string",
		"int",
		"int",
		"int"
	},
	RPC_CS_PutOffMovedEgg = {
		"number",
		"number",
		"number",
		"number",
		"number",
		"number",
		"number"
	},
	RPC_CS_MoveItemToResourceBox = {
		"string",
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_StartSearchPlayer = {
		"string"
	},
	RPC_CS_EndSearchPlayer = {
		"string"
	},
	RPC_CS_HatchRobEgg = {
		"int",
		"int"
	},
	RPC_CS_RobberyRobEgg = {
		"int"
	},
	RPC_CS_TakeRobEgg = {
		"int"
	},
	RPC_CS_TakeItemFromPlayer = {
		"string",
		"int",
		"int",
		"int"
	},
	RPC_CS_NotifyAttachCarryEgg = {},
	RPC_CS_StartFallenAid = {
		"int"
	},
	RPC_CS_StopFallenAid = {
		"int"
	},
	RPC_CS_StopTargetFallenAid = {},
	RPC_CS_CallHelp = {},
	RPC_CS_SkipFallenPhase = {},
	RPC_CS_RequestSelfRescue = {},
	RPC_CS_EscapeCarryEgg = {},
	RPC_CS_ControlEgg = {
		"int"
	},
	RPC_CS_RobEggHurt = {
		"string",
		"int",
		"int"
	},
	RPC_CS_RobEggRamHit = {
		"int",
		"number",
		"number"
	},
	RPC_CS_UncontrolEgg = {},
	RPC_CS_RequestLeaveEggManMode = {},
	RPC_CS_DirectCollect = {
		"int",
		"string",
		"int",
		"table",
		"int"
	},
	RPC_CS_SwapResourceBoxItem = {
		"string",
		"int",
		"int"
	},
	RPC_CS_OpenTheDoor = {
		"int",
		"int"
	},
	RPC_CS_UnlockRobEggTalent = {
		"int"
	},
	RPC_CS_ReceiveRogueBookBuffReward = {
		"int"
	},
	RPC_CS_ReceiveRogueBookBossReward = {
		"int",
		"int"
	},
	RPC_CS_GetRogueWeeklyKillBossReward = {
		"int"
	},
	RPC_CS_GetAllRogueWeeklyKillBossReward = {},
	RPC_CS_GetRogueWeeklyLevelReward = {
		"int"
	},
	RPC_CS_GetAllRogueWeeklyLevelReward = {
		"int"
	},
	RPC_CS_SelectRoguePets = {
		"table"
	},
	RPC_CS_StartRoguePetRevive = {
		"string"
	},
	RPC_CS_StartRogue = {
		"int"
	},
	RPC_CS_ReStartRogue = {
		"int"
	},
	RPC_CS_StartRandomRogue = {
		"int"
	},
	RPC_CS_ResetRogue = {},
	RPC_CS_ExitRogue = {
		"boolean"
	},
	RPC_CS_FocusedRogueLevel = {
		"int"
	},
	RPC_CS_GetRogueCombatStatistic = {},
	RPC_CS_ReqRogueExchangeReward = {
		"int"
	},
	RPC_CS_RandomRogueInitSeriesInfo = {},
	RPC_CS_SelectRogueSeries = {
		"int"
	},
	RPC_CS_ReqRogueRandomEventChooseOption = {
		"int",
		"int"
	},
	RPC_CS_ReqRogueSweepLevel = {
		"int",
		"int",
		"int"
	},
	RPC_CS_ReqRogueHarvestCollectAll = {},
	RPC_CS_ReqRogueOpenDice = {
		"int"
	},
	RPC_CS_ReqRogueStartRoll = {
		"int"
	},
	RPC_CS_ReqRogueEndRoll = {
		"int"
	},
	RPC_CS_ReqRogueDiceSendReward = {
		"int"
	},
	RPC_CS_UnlockRogueTalentLevel = {
		"int"
	},
	RPC_CS_UpgradeRogueTalentLevel = {
		"int"
	},
	RPC_CS_ResetRogueTalentLevel = {},
	RPC_CS_CancelLevelItemInteractState = {},
	RPC_CS_PlayChestRewardAttract = {
		"table"
	},
	RPC_CS_StartSlotMachine = {
		"int"
	},
	RPC_CS_SlotMachineReward = {
		"int"
	},
	RPC_CS_SocialQuery = {
		"int",
		"string",
		"table"
	},
	RPC_CS_SocialInvite = {
		"int",
		"string",
		"table"
	},
	RPC_CS_SocialInviteReply = {
		"int",
		"string",
		"table"
	},
	RPC_CS_PveHeartbeat = {
		"int",
		"int",
		"table"
	},
	RPC_CS_BlackScreenTeleport = {
		"int",
		"table"
	},
	RPC_CS_ResetPosition = {},
	RPC_CS_QuitSpace = {},
	RPC_CS_ClientSpawnerVisible = {
		"string",
		"boolean"
	},
	RPC_CS_SpawnerProductionShowOne = {
		"number"
	},
	RPC_CS_TeleportToScene = {
		"int",
		"int",
		"boolean"
	},
	RPC_CS_TeleportToDynamicPhase = {
		"int",
		"table"
	},
	RPC_CS_ClientLoadSceneEnd = {
		"int",
		"table"
	},
	RPC_CS_EnterLeaderSpaceRet = {
		"boolean",
		"int",
		"int",
		"int"
	},
	RPC_CS_NotifyStartTeleport = {
		"int",
		"int"
	},
	RPC_CS_TimePeriodSwitch = {
		"int",
		"int"
	},
	RPC_CS_GetSpaceLogicTime = {
		"int"
	},
	RPC_CS_SetSpaceLogicTime = {
		"int",
		"int"
	},
	RPC_CS_GetSpecialTrainChapterReward = {
		"int"
	},
	RPC_CS_FirstViewSpeicalTrainChapter = {
		"int"
	},
	RPC_CS_ViewSpecialTrainStarTitleQuest = {
		"int"
	},
	RPC_CS_GetSpecialTrainEntryReward = {
		"table",
		"int"
	},
	RPC_CS_GetSpecialTrainBadgeReward = {
		"boolean"
	},
	RPC_CS_GetSpecialTrainBadgeContinuousReward = {},
	RPC_CS_FirstOpenSpecialTrainInterface = {},
	RPC_CS_QueryTeamMemberCount = {
		"string"
	},
	RPC_CS_DisbandTeam = {},
	RPC_CS_LeaveTeam = {},
	RPC_CS_InviteTeamMember = {
		"string"
	},
	RPC_CS_AcceptTeamInvite = {
		"string",
		"boolean"
	},
	RPC_CS_RequestJoinTeam = {
		"string"
	},
	RPC_CS_SetAutoAcceptTeamJoinRequest = {
		"boolean"
	},
	RPC_CS_AcceptTeamJoinRequest = {
		"string",
		"boolean"
	},
	RPC_CS_ChangeTeamLeader = {
		"string"
	},
	RPC_CS_KickTeamMember = {
		"string"
	},
	RPC_CS_SetCrossPlatformPermissions = {
		"boolean"
	},
	RPC_CS_SetPlatformUGCSwitch = {
		"int"
	},
	RPC_CS_KickRtcRoomMember = {
		"int",
		"table"
	},
	RPC_CS_SetRtcRoomMute = {
		"int",
		"string",
		"boolean"
	},
	RPC_CS_GenerateUserSig = {},
	RPC_CS_CreateDungeonSingleTeam = {
		"int",
		"int"
	},
	RPC_CS_ApplyChangeTeamDungeon = {
		"int",
		"int"
	},
	RPC_CS_ApplyEnterTeamDungeon = {
		"int",
		"int",
		"int"
	},
	RPC_CS_RepeatApplyTeamDungeon = {},
	RPC_CS_QueryDungeonEnterTips = {
		"int",
		"int"
	},
	RPC_CS_PrepareTeam = {},
	RPC_CS_CancelPrepareTeam = {},
	RPC_CS_ReqSpaceFollow = {
		"string"
	},
	RPC_CS_AgreeSpaceFollow = {
		"string"
	},
	RPC_CS_InviteSpaceFollow = {
		"string"
	},
	RPC_CS_AgreeInviteSpaceFollow = {
		"string"
	},
	RPC_CS_QuickInviteTeamSpaceFollow = {
		"string"
	},
	RPC_CS_RefuseSpaceFollow = {
		"string",
		"int"
	},
	RPC_CS_ExitSpaceFollow = {},
	RPC_CS_KickSpaceFollow = {
		"string"
	},
	RPC_CS_NotifyFollowState = {
		"int"
	},
	RPC_CS_CancelMatch = {},
	RPC_CS_ConfirmDungeonTeam = {
		"int"
	},
	RPC_CS_RequestEnterWorld = {
		"string"
	},
	RPC_CS_HandleEnterWorldRequest = {
		"string",
		"boolean"
	},
	RPC_CS_InviteSinglePlayer = {
		"string",
		"table"
	},
	RPC_CS_InviteMultiPlayer = {
		"table"
	},
	RPC_CS_HandleEnterWorldInvite = {
		"string",
		"boolean"
	},
	RPC_CS_AcceptGatherTeammate = {
		"string",
		"boolean"
	},
	RPC_CS_LeaveLeaderWorld = {},
	RPC_CS_AddTotemRunes = {
		"int",
		"int"
	},
	RPC_CS_TradeList = {
		"int",
		"int",
		"string",
		"int",
		"int"
	},
	RPC_CS_TradeRemoveListing = {
		"string"
	},
	RPC_CS_TradeBuy = {
		"int",
		"string",
		"int"
	},
	RPC_CS_TradeBuyByPrice = {
		"string",
		"int",
		"int"
	},
	RPC_CS_TradeWatch = {
		"string",
		"boolean"
	},
	RPC_CS_TradeGetWatchList = {},
	RPC_CS_TradeRush = {
		"int",
		"string"
	},
	RPC_CS_TradeGetListings = {
		"table",
		"string",
		"int",
		"int"
	},
	RPC_CS_TradeGetListingsByPrice = {
		"string",
		"string",
		"int",
		"int"
	},
	RPC_CS_TradeGetMyListings = {},
	RPC_CS_TradeGetRecords = {
		"int",
		"int",
		"int"
	},
	RPC_CS_TradeGetOverview = {
		"int",
		"int"
	},
	RPC_CS_TradeGetRecommendPrice = {
		"string"
	},
	RPC_CS_SummonVehicle = {
		"int",
		"boolean"
	},
	RPC_CS_PlaceWorldFurniture = {
		"table"
	},
	RPC_CS_RecycleWorldFurniture = {},
	RPC_CS_SyncPsnAuthCode = {
		"string"
	},
	RPC_CS_RandomShopBuyGoods = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_RandomShopRefresh = {
		"int"
	},
	RPC_CS_RandomShopSetGoodsLock = {
		"int",
		"int",
		"int",
		"boolean"
	},
	RPC_CS_MoneyChange = {
		"int",
		"int"
	},
	RPC_CS_NotifyPetSelectChange = {
		"string",
		"table"
	},
	RPC_CS_PlayerGetReady = {
		"string",
		"table"
	},
	RPC_CS_GetShopRefreshList = {
		"int"
	},
	RPC_CS_BuyCommodity = {
		"int",
		"int",
		"int"
	},
	RPC_CS_SellItemByConfigId = {
		"table"
	},
	RPC_CS_SellItemByGenId = {
		"int",
		"table"
	},
	RPC_CS_ShopMallBuyCommodity = {
		"int",
		"int",
		"table"
	},
	RPC_CS_ShopMallGiveCommodity = {
		"string",
		"int",
		"int",
		"string"
	},
	RPC_CS_ShopMallCartModifyCommodityNum = {
		"int",
		"int"
	},
	RPC_CS_ShopMallCartDelCommodity = {
		"table"
	},
	RPC_CS_ShopMallCartBuyCommodity = {
		"table"
	},
	RPC_CS_ApplyTeamDungeon = {
		"int",
		"int",
		"boolean"
	},
	RPC_CS_CancelTeamDungeon = {},
	RPC_CS_PrepareTeamDungeon = {},
	RPC_CS_CancelPrepareTeamDungeon = {},
	RPC_CS_StartTeam = {
		"boolean"
	},
	RPC_CS_StartRobEgg = {
		"boolean",
		"int"
	},
	RPC_CS_StartTeamDungeon = {},
	RPC_CS_StartMatchTeam = {
		"int",
		"int"
	},
	RPC_CS_CancelMatchTeam = {},
	RPC_CS_ConfirmMatchReadyTeams = {
		"int"
	},
	RPC_CS_OnClientSetConditionValue = {
		"int",
		"int",
		"int",
		"int"
	},
	RPC_CS_OnClientTrigger = {
		"int",
		"int",
		"int",
		"table"
	},
	RPC_CS_RegisterGuideTrigger = {
		"int"
	},
	RPC_CS_UnRegisterGuideTrigger = {
		"int"
	},
	RPC_CS_SubPet = {
		"int",
		"int",
		"int",
		"string",
		"table"
	},
	RPC_CS_SubItem = {
		"int",
		"int",
		"int",
		"string",
		"int"
	},
	RPC_CS_SetCustomVariable = {
		"int",
		"int"
	},
	RPC_CS_SetNpcBehaviorStatus = {
		"int",
		"int",
		"int",
		"boolean"
	},
	RPC_CS_ActionMeteorSandbox = {
		"int"
	},
	RPC_CS_SubscribeWeather = {
		"number",
		"table"
	},
	RPC_CS_BotTrySwitchToSupportPet = {
		"int"
	},
	RPC_CS_BotTrySwitchPet = {
		"int"
	},
	RPC_CS_LevelItemFieldChange = {
		"string",
		"int",
		"int",
		"table"
	},
	RPC_CS_SandboxEvent = {
		"string",
		"int",
		"int",
		"int"
	},
	RPC_CS_SandboxCustomEvent = {
		"string",
		"int",
		"string"
	},
	RPC_CS_LevelItemServerMsg = {
		"string",
		"int",
		"int",
		"string",
		"boolean",
		"table"
	},
	RPC_CS_ReloadSandbox = {
		"string",
		"int"
	},
	RPC_CS_DebugLoadSandbox = {
		"string",
		"table"
	},
	RPC_CS_DebugGetSandboxInfo = {
		"string"
	},
	RPC_CS_EcsUploadState = {
		"string",
		"table"
	},
	RPC_CS_EcsRequestFullState = {
		"string",
		"table"
	},
	RPC_CS_EcsAuthorityReady = {
		"string",
		"table"
	},
	RPC_CS_EcsBuffCountChangeBatch = {
		"string",
		"table"
	},
	RPC_CS_CreateEnvEntity = {
		"string",
		"int",
		"table",
		"table"
	},
	RPC_CS_DestroyEnvEntity = {
		"string",
		"string",
		"float",
		"table",
		"int"
	},
	RPC_CS_DestroyVehicleByEcs = {
		"string",
		"int",
		"float",
		"int"
	},
	RPC_CS_SetGraphDebug = {
		"string",
		"int",
		"boolean"
	},
	RPC_CS_CallGraphNodePort = {
		"string",
		"int",
		"int",
		"string"
	},
	RPC_CS_MmoItemConditionTrigger = {
		"string",
		"int",
		"int"
	}
}

return Config
