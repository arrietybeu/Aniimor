-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\HudSplicingCfg.lua

local cfg = {}

cfg.HudType = {
	World = "World",
	OffLine = "OffLine",
	HomeLand = "Homeland",
	Ark = "Ark"
}
cfg.LayoutName = {
	RM = "RM",
	RU = "RU",
	MU = "MU",
	MD = "MD",
	LD = "LD",
	LM = "LM",
	LU = "LU",
	RD = "RD"
}
cfg.SubCanvasMode = {
	Interactive = 2,
	RenderOnly = 1
}
cfg.SceneConfig = {
	[cfg.HudType.World] = {
		[cfg.LayoutName.LU] = {
			parentNode = "uiNode",
			resId = "$UI_Node_Hud_LeftTopPanel.prefab",
			subCanvasMode = cfg.SubCanvasMode.Interactive
		},
		[cfg.LayoutName.LM] = {
			parentNode = "uiNode"
		},
		[cfg.LayoutName.LD] = {
			parentNode = "uiNode",
			mobileResId = "$UI_Node_Hud_Function_Mobile.prefab",
			resId = "$UI_Node_Hud_Ball_PC.prefab",
			subCanvasMode = cfg.SubCanvasMode.Interactive
		},
		[cfg.LayoutName.MD] = {
			parentNode = "uiNode"
		},
		[cfg.LayoutName.RU] = {
			parentNode = "uiNode"
		},
		[cfg.LayoutName.RM] = {
			parentNode = "uiNode"
		},
		[cfg.LayoutName.RD] = {
			parentNode = "uiNode"
		},
		[cfg.LayoutName.MU] = {
			parentNode = "uiNode"
		}
	},
	[cfg.HudType.Ark] = {
		[cfg.LayoutName.LM] = {
			isEmpty = true
		},
		[cfg.LayoutName.MD] = {
			isEmpty = true
		}
	},
	[cfg.HudType.HomeLand] = {
		[cfg.LayoutName.LM] = {
			isEmpty = true
		}
	},
	[cfg.HudType.OffLine] = {
		[cfg.LayoutName.LU] = {
			isEmpty = true
		},
		[cfg.LayoutName.LM] = {
			isEmpty = true
		},
		[cfg.LayoutName.LD] = {
			parentNode = "uiNode",
			resId = "$UI_Node_Hud_Ball_PC.prefab",
			subCanvasMode = cfg.SubCanvasMode.Interactive
		},
		[cfg.LayoutName.MD] = {
			isEmpty = true
		},
		[cfg.LayoutName.RU] = {
			isEmpty = true
		},
		[cfg.LayoutName.RM] = {
			isEmpty = true
		},
		[cfg.LayoutName.RD] = {
			parentNode = "uiNode"
		}
	}
}
cfg.componentName = {
	switchMode = "switchMode",
	mobileCarryEntOperate = "mobileCarryEntOperate",
	interactSign = "interactSign",
	aimMobile = "aimMobile",
	robEggSprite = "robEggSprite",
	TowerInfo = "TowerInfo",
	bossRushBtnInfo = "bossRushBtnInfo",
	bossRushInfo = "bossRushInfo",
	mobileAddonBtn = "mobileAddonBtn",
	interactGesture = "interactGesture",
	formulaTracking = "FormulaTracking",
	npcDuelInCombat = "npcDuelInCombat",
	aimSense = "aimSense",
	aim = "aim",
	exploreBtn = "exploreBtn",
	focus = "focus",
	team = "team",
	mobileBallBtn = "mobileBallBtn",
	mobileExplore = "MobileExplore",
	mobileSkill = "MobileSkillRD",
	mobile3C = "Mobile3C",
	mobileHpFuse = "MobileHpFuse",
	quitBtn = "quitBtn",
	aiHelperLit = "AIHelperLit",
	carryEntOperate = "carryEntOperate",
	quickChat = "quickChat",
	miniMapV2 = "miniMapV2",
	syncope = "syncope",
	skillRD = "skillRD",
	funcList = "funcList",
	homeFunc = "homeFunc",
	hpFuse = "hpFuse",
	hp = "hp",
	mobilePetList = "mobilePetList",
	petList = "petList",
	chatBullet = "chatBullet",
	temperature = "temperature",
	focusFrame = "focusFrame"
}
cfg.resConfig = {
	[cfg.componentName.petList] = {
		parentNode = "uiNode",
		resId = "$UI_Pb_Hud_Mate.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.mobilePetList] = {
		parentNode = "uiNode",
		topSibling = true,
		resId = "$UI_Pb_Hud_Mate.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.hp] = {
		parentNode = "uiNode",
		resId = "$UI_Node_HUD_HP.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.hpFuse] = {
		parentNode = "uiNode",
		resId = "$UI_Node_HUD_HP_Fuse.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.mobileHpFuse] = {
		parentNode = "uiNode",
		resId = "$UI_Node_FuseBtnPanel_Mobile.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.homeFunc] = {
		parentNode = "uiNode",
		resId = "$UI_Pb_Home_Function.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.funcList] = {
		parentNode = "uiNode",
		resId = "$UI_Pb_Hud_Function.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.skillRD] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_BtnPanel_PC.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.quickChat] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_ChatBubble.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.carryEntOperate] = {
		parentNode = "uiNode",
		resId = "$UI_Node_BattleUI_SimpleBtn.prefab",
		excludedComponent = {
			cfg.componentName.exploreBtn
		}
	},
	[cfg.componentName.mobileSkill] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_BtnSkillPanel_Mobile.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.mobile3C] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_MainBtnPanel_Mobile.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.mobileBallBtn] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_BallBtnPanel_Mobile.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.focus] = {
		resId = "$UI_Pb_Hud_Focus.prefab",
		parentNode = "uiWorldNode"
	},
	[cfg.componentName.exploreBtn] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_PanelExplore.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.aim] = {
		parentNode = "uiWorldNode",
		resId = "$UI_Node_Hud_Aim.prefab",
		subCanvasMode = cfg.SubCanvasMode.RenderOnly
	},
	[cfg.componentName.aimSense] = {
		resId = "$UI_Node_Hud_Frame_Sense.prefab",
		parentNode = "uiCoverNode"
	},
	[cfg.componentName.npcDuelInCombat] = {
		parentNode = "uiNode",
		resId = "$UI_Node_HUD_BattleRoom_Toast.prefab",
		subCanvasMode = cfg.SubCanvasMode.RenderOnly
	},
	[cfg.componentName.interactGesture] = {
		parentNode = "uiNode",
		resId = "$UI_Pb_EmoticonPanel.prefab",
		excludedComponent = {
			cfg.componentName.skillRD,
			cfg.componentName.mobileSkill,
			cfg.componentName.aim,
			cfg.componentName.mobileBallBtn,
			cfg.componentName.mobile3C,
			cfg.componentName.exploreBtn
		},
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.mobileAddonBtn] = {
		resId = "$UI_Node_Hud_AddonPanel_Mobile.prefab",
		parentNode = "uiNode"
	},
	[cfg.componentName.bossRushInfo] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_BossMod.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.TowerInfo] = {
		resId = "$UI_Node_Hud_Quest_ModTower.prefab",
		parentNode = "uiNode"
	},
	[cfg.componentName.robEggSprite] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_AddonPanel_GrabEggs.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.mobileExplore] = {
		resId = "$UI_Node_Hud_BattleUI_Explore_Mobile.prefab",
		parentNode = "uiNode"
	},
	[cfg.componentName.aimMobile] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_AimPanel_Mobile.prefab",
		subCanvasMode = cfg.SubCanvasMode.Interactive
	},
	[cfg.componentName.interactSign] = {
		resId = "$UI_Node_Hud_Interaction_Sign_Root.prefab",
		parentNode = "uiWorldNode"
	},
	[cfg.componentName.mobileCarryEntOperate] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_InteractionBtn.prefab",
		excludedComponent = {
			cfg.componentName.exploreBtn
		}
	},
	[cfg.componentName.switchMode] = {
		parentNode = "uiNode",
		resId = "$UI_Pb_Switch.prefab",
		subCanvasMode = cfg.SubCanvasMode.RenderOnly
	},
	[cfg.componentName.focusFrame] = {
		resId = "$UI_Node_Hud_FocusFrame.prefab",
		parentNode = "uiWorldNode"
	},
	[cfg.componentName.syncope] = {
		resId = "$UI_Node_Hud_PanelSyncope.prefab",
		parentNode = "uiNode"
	},
	[cfg.componentName.chatBullet] = {
		parentNode = "uiNode",
		resId = "$UI_Node_Hud_ChatBarrage.prefab",
		subCanvasMode = cfg.SubCanvasMode.RenderOnly
	}
}
cfg.mobileResConfig = {}

return cfg
