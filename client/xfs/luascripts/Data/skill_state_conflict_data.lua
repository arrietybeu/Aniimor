-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\skill_state_conflict_data.lua

local data = {
	CMD_NAME_TABLE = {
		AIM = {
			"瞄准",
			0
		},
		AIM_ATTACK = {
			"瞄准射击",
			0
		},
		ATTACK = {
			"攻击",
			0
		},
		BE_CONTROL_PET = {
			"被附身",
			0
		},
		CONTROL_PET = {
			"附身",
			0
		},
		CROUCH = {
			"下蹲",
			0
		},
		DASH = {
			"突进",
			0
		},
		ENTER_CATCH_MODE = {
			"进入捕捉模式",
			0
		},
		FLY = {
			"飞行",
			0
		},
		FLYRIDE = {
			"飞行骑乘",
			0
		},
		INTERACT = {
			"交互",
			0
		},
		INTERACT_LOCATION_CHANGE_BLOCK = {
			"交互",
			0
		},
		INTERACT_LOCATION_CHANGE_CANCEL = {
			"交互",
			0
		},
		INTERACT_MODEL_CHANGE_BLOCK = {
			"交互",
			0
		},
		INTERACT_MODEL_CHANGE_CANCEL = {
			"交互",
			0
		},
		INTERACT_PLAY_ANIM_BLOCK = {
			"交互",
			0
		},
		INTERACT_PLAY_ANIM_CANCEL = {
			"交互",
			0
		},
		JUMP = {
			"跳跃",
			0
		},
		MOVE = {
			"移动",
			0
		},
		RESUME_BT = {
			"恢复AI",
			0
		},
		SKILL = {
			"技能",
			0
		},
		SKILL_AIM = {
			"技能瞄准",
			0
		},
		SNEAK = {
			"蹲下潜行",
			0
		},
		STOP_CONTROL_PET = {
			"解除附身",
			0
		},
		SWITCH_PET = {
			"切换",
			0
		},
		SWITCHING = {
			"切换",
			0
		}
	},
	STATE_NAME_TABLE = {
		BACKSWING_ST = {
			"后摇状态",
			0
		},
		CAST_ST = {
			"释放状态",
			0
		},
		COMBO_ST = {
			"可连招状态",
			0
		},
		KEY_FRAME_BACKSWING_ST = {
			"关键帧后摇态",
			0
		}
	},
	AIM = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	AIM_ATTACK = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	ATTACK = {
		block = {
			"CAST_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"COMBO_ST"
		}
	},
	BE_CONTROL_PET = {
		block = {},
		cancel = {}
	},
	CONTROL_PET = {
		block = {},
		cancel = {
			"BACKSWING_ST",
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		}
	},
	CROUCH = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	DASH = {
		block = {
			"CAST_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"COMBO_ST"
		}
	},
	ENTER_CATCH_MODE = {
		block = {
			"CAST_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		}
	},
	FLY = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	FLYRIDE = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	INTERACT = {
		block = {},
		cancel = {}
	},
	INTERACT_LOCATION_CHANGE_BLOCK = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {}
	},
	INTERACT_LOCATION_CHANGE_CANCEL = {
		block = {},
		cancel = {
			"BACKSWING_ST",
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		}
	},
	INTERACT_MODEL_CHANGE_BLOCK = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	INTERACT_MODEL_CHANGE_CANCEL = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	INTERACT_PLAY_ANIM_BLOCK = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	INTERACT_PLAY_ANIM_CANCEL = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	JUMP = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	MOVE = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	RESUME_BT = {
		block = {},
		cancel = {}
	},
	SKILL = {
		block = {
			"CAST_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"COMBO_ST"
		}
	},
	SKILL_AIM = {
		block = {
			"CAST_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"COMBO_ST"
		}
	},
	SNEAK = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	},
	STOP_CONTROL_PET = {
		block = {
			"CAST_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"COMBO_ST"
		}
	},
	SWITCH_PET = {
		block = {
			"CAST_ST",
			"COMBO_ST"
		},
		cancel = {
			"BACKSWING_ST",
			"KEY_FRAME_BACKSWING_ST"
		}
	},
	SWITCHING = {
		block = {
			"CAST_ST",
			"COMBO_ST",
			"KEY_FRAME_BACKSWING_ST"
		},
		cancel = {
			"BACKSWING_ST"
		}
	}
}

return data
