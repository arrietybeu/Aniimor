-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\TipAreaConst.lua

local TipAreaConst = {}

TipAreaConst.TICK_INTERVAL = 0.02
TipAreaConst.RECYCLE_TIMEOUT = 5
TipAreaConst.RECYCLE_CHECK_INTERVAL = 0.1
TipAreaConst.RECYCLE_REASON = {
	NORMAL = "normal",
	ERROR = "error",
	DESTROY = "destroy",
	FORCE = "force",
	TIMEOUT = "timeout"
}
TipAreaConst.AREAS = {
	A2 = "A2TipArea",
	MI = "MITipArea",
	A1I = "A1ITipArea",
	M = "MTipArea",
	A1 = "A1TipArea",
	CI = "CITipArea",
	TOP = "TOPTipArea",
	C = "CTipArea",
	CF = "CFTipArea",
	BI = "BITipArea",
	B = "BTipArea",
	A3 = "A3TipArea",
	PA2 = "PA2TipArea"
}
TipAreaConst.UITipAreaFlag = {
	AreaFlag_CIShow = "CIShow",
	AreaFlag_Force = "Force",
	AreaFlag_CShow = "CShow",
	AreaFlag_Cutscene = "Cutscene",
	AreaFlag_BIShow = "BIShow",
	AreaFlag_A1IShow = "A1IShow",
	AreaFlag_A3Show = "A3Show",
	AreaFlag_A2Show = "A2Show",
	AreaFlag_A1Show = "A1Show",
	AreaFlag_SeasonOpenTip = "SeasonOpenTip",
	AreaFlag_PanelHide = "PanelHide",
	AreaFlag_FullScreen = "FullScreen",
	AreaFlag_PetFirstShow = "PetFirstShow",
	AreaFlag_Level = "Level",
	AreaFlag_DialogueGraph = "Dialogue",
	AreaFlag_Quest = "Quest",
	AreaFlag_Default = "Default",
	AreaFlag_CustomAreaShow = "CustomAreaShow"
}
TipAreaConst.EDGE_AREAS = {
	Target = "Edge_Target",
	Quest = "Edge_Quest",
	Challenge = "Edge_Challenge",
	QuestArea = "Edge_QuestArea"
}
TipAreaConst.EDGE_HIDE_AREA_C_ITEMS = {
	"ExplorePetReplace",
	"MultiPetObtains",
	"PetEvolve",
	"PetResearch",
	"PropObtain"
}
TipAreaConst.CUTSCENE_HIDE_AREA_C_ITEMS = {
	"ExplorePetReplace",
	"MultiPetObtains",
	"PetEvolve",
	"PetResearch",
	"PropObtain",
	"PetObtain",
	"GiftTips",
	"HomeBookUnlock",
	"QuickUse",
	"FriendOnLine",
	"ScreenCaptureShare"
}
TipAreaConst.CUTSCENE_MAX_SUSPEND_TIME = 60
TipAreaConst.AREAS_CONFIG = {
	[TipAreaConst.AREAS.TOP] = {
		resKey = "topArea",
		maxRunItemNum = 3,
		priority = 1,
		customAreaShow = {
			TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
			TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
		}
	},
	[TipAreaConst.AREAS.A1] = {
		resKey = "a1Area",
		priority = 9
	},
	[TipAreaConst.AREAS.A1I] = {
		resKey = "a1IArea",
		priority = 10
	},
	[TipAreaConst.AREAS.A2] = {
		resKey = "a2Area",
		maxRunItemNum = 2,
		priority = 8
	},
	[TipAreaConst.AREAS.A3] = {
		resKey = "a3Area",
		priority = 1
	},
	[TipAreaConst.AREAS.B] = {
		resKey = "bArea",
		priority = 1
	},
	[TipAreaConst.AREAS.BI] = {
		resKey = "bIArea",
		priority = 1
	},
	[TipAreaConst.AREAS.CF] = {
		resKey = "cFArea",
		priority = 1
	},
	[TipAreaConst.AREAS.C] = {
		resKey = "cArea",
		priority = 1,
		customAreaShow = {
			TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen
		}
	},
	[TipAreaConst.AREAS.CI] = {
		resKey = "cIArea",
		priority = 3
	},
	[TipAreaConst.AREAS.M] = {
		resKey = "empty",
		priority = 11
	},
	[TipAreaConst.AREAS.MI] = {
		resKey = "empty",
		priority = 12
	},
	[TipAreaConst.AREAS.PA2] = {
		resKey = "pA2Area",
		priority = 1
	}
}
TipAreaConst.FULL_SCREEN_HIDE_AREA = {
	[TipAreaConst.AREAS.TOP] = true,
	[TipAreaConst.AREAS.A1] = true,
	[TipAreaConst.AREAS.A1I] = true,
	[TipAreaConst.AREAS.A2] = true,
	[TipAreaConst.AREAS.A3] = false,
	[TipAreaConst.AREAS.B] = true,
	[TipAreaConst.AREAS.BI] = true,
	[TipAreaConst.AREAS.CF] = true,
	[TipAreaConst.AREAS.C] = true,
	[TipAreaConst.AREAS.CI] = false,
	[TipAreaConst.AREAS.M] = true,
	[TipAreaConst.AREAS.MI] = false,
	[TipAreaConst.AREAS.PA2] = false
}
TipAreaConst.AREA_ITEMS = {
	[TipAreaConst.AREAS.TOP] = {
		PvpInviteState = {
			resKey = "pvpInvite",
			priority = 30,
			testParam = {
				mode = 1
			}
		},
		PvpPreparation = {
			resKey = "pvpPreparation",
			priority = 31,
			testParam = {
				duration = 50
			}
		},
		HomeName = {
			resKey = "homeName",
			fixed = true,
			priority = 1,
			testParam = {
				name = "测试Home"
			}
		},
		CountDown = {
			resKey = "countDown",
			priority = 11,
			testParam = {
				duration = 5,
				infoText = "测试倒计时",
				useGameTime = true
			},
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
				TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
			}
		},
		TimeViolent = {
			resKey = "timeViolent",
			priority = 12,
			testParam = {
				duration = 5,
				infoText = "测试狂暴倒计时",
				useGameTime = true
			},
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
				TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
			}
		},
		BossTitle = {
			resKey = "bossBlood",
			fixed = true,
			priority = 5,
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
				TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
			}
		},
		GetEggLimitedTime = {
			resKey = "getEggLimitedTime",
			fixed = true,
			priority = 8,
			testParam = {
				title = "测试进度",
				progress = 0.5
			},
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
				TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
			}
		},
		GrabEggWaitingInfo = {
			resKey = "waitingInfo",
			fixed = true,
			priority = 8,
			testParam = {
				tipsTextKey = "GRAB_EGG_LOADING_WAIT"
			},
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
				TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
			}
		},
		TargetEntityInfo = {
			resKey = "petSmallHp",
			priority = 8,
			testParam = {
				duration = 5
			},
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_A1Show,
				TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow
			}
		}
	},
	[TipAreaConst.AREAS.A1] = {
		POIPop = {
			resKey = "pOINew",
			priority = 1
		},
		QuestComplete = {
			resKey = "questComplete",
			priority = 11,
			testParam = {
				duration = 5,
				id = 1202075
			}
		},
		TowerResultWin = {
			resKey = "towerResultWin",
			priority = 21,
			testParam = {
				duration = 3
			}
		},
		TowerResultWave = {
			resKey = "towerResultWave",
			priority = 22,
			testParam = {
				duration = 5,
				params = {
					totalStage = 10,
					stage = 6
				}
			}
		},
		TowerResultStart = {
			resKey = "towerResultStart",
			priority = 23,
			testParam = {
				duration = 4
			}
		},
		MapAreaUnlockTip = {
			resKey = "mapUnlock",
			priority = 3,
			testParam = {
				unlockName = "测试解锁"
			}
		},
		ArchaicCharacter = {
			resKey = "archaicCharacter",
			priority = 5,
			testParam = {
				noticeKey = "测试1",
				characters = {}
			}
		},
		BossFirstKill = {
			resKey = "bossFirstKill",
			priority = 8,
			testParam = {
				title = "Dragon Lord"
			}
		},
		GrabEggsIncubator = {
			resKey = "grabEggsIncubator",
			fixed = true,
			priority = 0,
			testParam = {
				title = "测试Title",
				duration = 3
			}
		},
		CountDownBeat = {
			resKey = "countDownBeat",
			priority = 30,
			testParam = {
				endTime = 0
			}
		},
		TransferEgg = {
			resKey = "transferEgg",
			priority = 24,
			testParam = {
				endTime = 0
			}
		},
		EventSeason = {
			resKey = "eventSeasonUContainer",
			priority = 101,
			testParam = {
				endTime = 0
			}
		},
		ResultFail = {
			resKey = "resultFail",
			priority = 20,
			testParam = {
				duration = 3
			}
		},
		BossCatchWarning = {
			resKey = "bossCatchWarning",
			priority = 31,
			testNames = {
				duration = 3
			}
		},
		CountDownLimitedTime = {
			resKey = "countDownLimitedTime",
			priority = 26,
			testParam = {
				duration = 5,
				title = "测试限时"
			}
		},
		HomeSeasonCelebration = {
			resKey = "HomeSeasonCelebration",
			priority = 100,
			testParam = {
				duration = 600,
				title = "庆典准备中"
			}
		}
	},
	[TipAreaConst.AREAS.A1I] = {
		MapTips = {
			resKey = "mapTipsUContainer",
			priority = 100
		},
		PlayerExpChanged = {
			resKey = "playerExpChanged",
			priority = 56,
			hidAreas = {
				TipAreaConst.AREAS.A2,
				TipAreaConst.AREAS.A3
			},
			testParam = {
				maxExp = 200,
				addExp = 120,
				curExp = 100,
				oldExp = 100,
				batch = true,
				isLvUp = true,
				newLevel = 11,
				oldLevel = 10
			}
		},
		ItemObtain = {
			resKey = "itemObtain",
			priority = 99
		}
	},
	[TipAreaConst.AREAS.A2] = {
		OutCombatProgress = {
			resKey = "outBattleProgress",
			priority = 11,
			testParam = {
				progress = 45
			}
		},
		BossMechanismTips = {
			resKey = "bossMechanismTips",
			priority = 12,
			testParam = {
				text = "测试"
			}
		},
		BossMechanismProgress = {
			resKey = "bossMechanismProgress",
			priority = 13,
			testParam = {
				countDownDuration = 5,
				text = "测试"
			}
		},
		BattleRoomMechanismTips = {
			resKey = "battleRoomMechanismTips",
			priority = 15,
			testParam = {
				duration = 3,
				text = "测试道馆机制提示"
			}
		},
		DungeonTips = {
			resKey = "dungeonTips",
			priority = 14,
			testParam = {
				countDownDuration = 5,
				text = "测试"
			}
		},
		POIPopArea = {
			resKey = "poiAreaTips",
			priority = 1
		},
		BossCatchTips = {
			resKey = "bossCatchTips",
			priority = 16,
			testParam = {
				text = "与鸢尾交互，缔结契约"
			}
		}
	},
	[TipAreaConst.AREAS.A3] = {
		NormalText = {
			resKey = "normalText",
			testParam = {
				desc = "测试提示"
			}
		}
	},
	[TipAreaConst.AREAS.B] = {
		ItemRepeatObtain = {
			resKey = "itemRepeatObtain",
			priority = 99,
			testParam = {
				id = 552000,
				piecesId = 551000,
				num = 87
			}
		},
		HelpTips = {
			resKey = "helpTips",
			priority = 10,
			testParam = {
				helpId = 100
			}
		},
		UnderTips = {
			resKey = "underTips",
			priority = 1
		},
		CompletionPrompt = {
			resKey = "completionPrompt",
			priority = 20,
			testParam = {
				templateId = 1001100,
				pointNum = 100
			}
		},
		badgeRepeatObtain = {
			resKey = "badgeRepeatObtain",
			priority = 101
		},
		GainCrop = {
			resKey = "gainCrop",
			priority = 5,
			testParam = {
				itemId = 1
			}
		}
	},
	[TipAreaConst.AREAS.BI] = {
		AIHelperTips = {
			resKey = "aiHelperTips",
			priority = 1,
			testParam = {
				id = 1004103
			}
		},
		NewClueTips = {
			resKey = "newClueTips",
			priority = 2,
			testParam = {
				questId = 3705043
			}
		},
		ControlPanel = {
			resKey = "controlPanel",
			priority = 3,
			testParam = {
				text = "测试"
			}
		},
		PetConjunctionTips = {
			resKey = "petConjunctionTips",
			priority = 4
		}
	},
	[TipAreaConst.AREAS.CF] = {
		ShortCutKey = {
			resKey = "shortCutKey",
			fixed = true,
			priority = 1
		}
	},
	[TipAreaConst.AREAS.C] = {
		PropObtain = {
			resKey = "propObtain",
			priority = 10,
			testParam = {
				id = 1000,
				num = 10
			}
		},
		QuickUse = {
			resKey = "quickUse",
			priority = 11
		},
		FriendOnLine = {
			resKey = "friendOnLine",
			priority = 12
		},
		HomeBookUnlock = {
			resKey = "homeBookUnlock",
			priority = 12,
			testParam = {
				itemId = 4001000,
				duration = 5
			},
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen
			}
		},
		PetObtain = {
			resKey = "petObtain",
			priority = 54
		},
		MultiPetObtains = {
			resKey = "petObtains",
			priority = 53
		},
		PetEvolve = {
			resKey = "petEvolve",
			priority = 20,
			testParam = {
				templateId = 1002200,
				canStageUp = true
			}
		},
		PetResearch = {
			resKey = "petResearch",
			priority = 51
		},
		ExplorePetReplace = {
			resKey = "petAbility",
			priority = 52
		},
		GiftTips = {
			resKey = "giftTips",
			priority = 25
		},
		ScreenCaptureShare = {
			resKey = "screenCaptureShareUContainer",
			priority = 32,
			customAreaShow = {
				TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen
			}
		}
	},
	[TipAreaConst.AREAS.CI] = {
		TeamInvite = {
			resKey = "friendInvite",
			priority = 60
		},
		PvpInvite = {
			resKey = "pvpInvite",
			priority = 61
		},
		NpcCall = {
			resKey = "npcCall",
			priority = 1
		}
	},
	[TipAreaConst.AREAS.M] = {
		PreciousProp = {
			resKey = "preciousProp",
			priority = 10
		},
		QuestChapter = {
			resKey = "questChapter",
			priority = 11
		},
		PetFirstShow = {
			resKey = "petFirstShow",
			priority = 12
		}
	},
	[TipAreaConst.AREAS.MI] = {
		PropsObtain = {
			resKey = "propsObtain",
			priority = 10
		}
	},
	[TipAreaConst.AREAS.PA2] = {
		DropHint = {
			resKey = "dropHint",
			priority = 20,
			testParam = {
				str = "You got a rare item!",
				progressDuration = 5
			}
		}
	}
}
TipAreaConst.TipItemFlag = {
	ItemFlag_BigWhiteBall = 102,
	ItemFlag_SkillFreeAim = 101,
	ItemFlag_NoHUD = 100,
	ItemFlag_Mobile = 99,
	ItemFlag_HideFixed = 1,
	ItemFlag_Default = 0
}
TipAreaConst.ITEM_RUN_STATE = {
	RUN_QUEUE = 3,
	WAITING = 2,
	RUN_FIXED = 1,
	EMPTY = 0
}
TipAreaConst.GMKeyMaps = {
	"TOPTipArea_PvpInviteState",
	"TOPTipArea_PvpPreparation",
	"TOPTipArea_HomeName",
	"TOPTipArea_CountDown",
	"TOPTipArea_TimeViolent",
	"TOPTipArea_CommonTimer",
	"TOPTipArea_BossTitle",
	"TOPTipArea_GetEggLimitedTime",
	"TOPTipArea_GrabEggWaitingInfo",
	"A1TipArea_POIPop",
	"A1TipArea_QuestComplete",
	"A1TipArea_TowerResultWin",
	"A1TipArea_TowerResultWave",
	"A1TipArea_TowerResultStart",
	"A1TipArea_MapAreaUnlockTip",
	"A1TipArea_ArchaicCharacter",
	"A1TipArea_BossFirstKill",
	"A1TipArea_GrabEggsIncubator",
	"A1TipArea_TransferEgg",
	"A1TipArea_BossCatchWarning",
	"A1TipArea_CountDownLimitedTime",
	"A1TipArea_HomeSeasonCelebration",
	"A1TipArea_EventSeason",
	"A1ITipArea_PlayerExpChanged",
	"A1ITipArea_ItemObtain",
	"A2TipArea_OutCombatProgress",
	"A2TipArea_BossMechanismTips",
	"A2TipArea_BossMechanismProgress",
	"A2TipArea_BattleRoomMechanismTips",
	"A2TipArea_DungeonTips",
	"A2TipArea_POIPopArea",
	"A2TipArea_BossCatchTips",
	"A3TipArea_NormalText",
	"BTipArea_ItemRepeatObtain",
	"BTipArea_HelpTips",
	"BTipArea_UnderTips",
	"BTipArea_CompletionPrompt",
	"BTipArea_GainCrop",
	"BITipArea_AIHelperTips",
	"BITipArea_ControlPanel",
	"CFTipArea_ShortCutKey",
	"CTipArea_PropObtain",
	"CTipArea_QuickUse",
	"CTipArea_FriendOnLine",
	"CTipArea_HomeBookUnlock",
	"CTipArea_PetObtain",
	"CTipArea_MultiPetObtains",
	"CTipArea_PetEvolve",
	"CTipArea_PetResearch",
	"CTipArea_ExplorePetReplace",
	"CTipArea_GiftTips",
	"CITipArea_TeamInvite",
	"CITipArea_PvpInvite",
	"CITipArea_NpcCall",
	"MTipArea_PreciousProp",
	"MTipArea_QuestChapter",
	"MITipArea_PropsObtain",
	"PA2TipArea_DropHint"
}

return TipAreaConst
