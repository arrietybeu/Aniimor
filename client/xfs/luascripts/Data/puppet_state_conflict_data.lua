-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\puppet_state_conflict_data.lua

local data = {
	CMD_NAME_TABLE = {
		ST_AlertDoubt = {
			"警觉疑惑",
			0
		},
		ST_AlertPatrol = {
			"巡逻",
			0
		},
		ST_AlertStare = {
			"警觉注视目标",
			0
		},
		ST_AttractFollow = {
			"吸引跟随",
			0
		},
		ST_Escape = {
			"逃跑",
			0
		},
		ST_HappyStare = {
			"开心注视",
			0
		},
		ST_Leave = {
			"远离",
			0
		},
		ST_MonBehav_LeaveVanish = {
			"远离并消失",
			0
		},
		ST_MoveToEat = {
			"接近吃",
			0
		},
		ST_None = {
			"默认",
			0
		},
		ST_PatrolAvoidTrap = {
			"避开陷阱",
			0
		},
		ST_ReadyToFight = {
			"准备战斗",
			0
		},
		ST_Stare = {
			"注视",
			0
		}
	},
	STATE_NAME_TABLE = {
		ST_AlertDoubt = {
			"警觉疑惑",
			0
		},
		ST_AlertPatrol = {
			"巡逻",
			0
		},
		ST_AlertStare = {
			"警觉注视目标",
			0
		},
		ST_AttractFollow = {
			"吸引跟随",
			0
		},
		ST_Escape = {
			"逃跑",
			0
		},
		ST_HappyStare = {
			"开心注视",
			0
		},
		ST_Leave = {
			"远离",
			0
		},
		ST_MonBehav_LeaveVanish = {
			"注视",
			0
		},
		ST_MoveToEat = {
			"接近吃",
			0
		},
		ST_None = {
			"默认",
			0
		},
		ST_PatrolAvoidTrap = {
			"避开陷阱",
			0
		},
		ST_ReadyToFight = {
			"准备战斗",
			0
		},
		ST_Stare = {
			"注视",
			0
		}
	},
	ST_AlertDoubt = {
		block = {
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_AlertPatrol = {
		block = {
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_AlertStare = {
		block = {
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_AttractFollow = {
		block = {
			"ST_AttractFollow",
			"ST_Escape",
			"ST_Leave",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_HappyStare",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_Escape = {
		block = {
			"ST_Escape",
			"ST_PatrolAvoidTrap"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_HappyStare",
			"ST_Leave",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_ReadyToFight",
			"ST_Stare"
		}
	},
	ST_HappyStare = {
		block = {
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_Leave = {
		block = {
			"ST_AttractFollow",
			"ST_Escape",
			"ST_Leave",
			"ST_PatrolAvoidTrap"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_HappyStare",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_ReadyToFight",
			"ST_Stare"
		}
	},
	ST_MonBehav_LeaveVanish = {
		block = {
			"ST_AttractFollow",
			"ST_MonBehav_LeaveVanish",
			"ST_PatrolAvoidTrap"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_MoveToEat",
			"ST_None",
			"ST_ReadyToFight",
			"ST_Stare"
		}
	},
	ST_MoveToEat = {
		block = {
			"ST_AttractFollow",
			"ST_Escape",
			"ST_Leave",
			"ST_MoveToEat",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_HappyStare",
			"ST_MonBehav_LeaveVanish",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_None = {
		block = {
			"ST_None"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight",
			"ST_Stare"
		}
	},
	ST_PatrolAvoidTrap = {
		block = {
			"ST_AlertStare",
			"ST_Escape",
			"ST_HappyStare",
			"ST_PatrolAvoidTrap"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AttractFollow",
			"ST_Leave",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_ReadyToFight",
			"ST_Stare"
		}
	},
	ST_ReadyToFight = {
		block = {
			"ST_AttractFollow",
			"ST_Escape",
			"ST_Leave",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight"
		},
		cancel = {
			"ST_AlertDoubt",
			"ST_AlertPatrol",
			"ST_AlertStare",
			"ST_HappyStare",
			"ST_MonBehav_LeaveVanish",
			"ST_MoveToEat",
			"ST_None",
			"ST_Stare"
		}
	},
	ST_Stare = {
		block = {
			"ST_AlertDoubt",
			"ST_AlertStare",
			"ST_AttractFollow",
			"ST_Escape",
			"ST_HappyStare",
			"ST_Leave",
			"ST_MonBehav_LeaveVanish",
			"ST_PatrolAvoidTrap",
			"ST_ReadyToFight",
			"ST_Stare"
		},
		cancel = {
			"ST_AlertPatrol",
			"ST_MoveToEat",
			"ST_None"
		}
	}
}

return data
