-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\stamina_config_data.lua

local StaminaConst = {}

StaminaConst.StaminaCostType = {
	COST_BY_TIME = 3,
	COST_ON_ENTER = 1,
	None = 0
}
StaminaConst.StaminaCostConfig = {
	Default = {
		CanRecover = true,
		Dash = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				multiplier = "dashCostRate",
				cost = 16.5
			}
		},
		Sprint = {
			CostRateNotInCombat = 0,
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 15
			}
		},
		Fall = {
			CanRecover = false
		}
	},
	Glide = {
		[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
			cost = 1
		},
		Move = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 5
			}
		},
		Jump = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 20
			}
		}
	},
	Climb = {
		Move = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 8
			}
		},
		Sprint = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 13
			}
		},
		Dash = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 12
			}
		},
		Default = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 1
			}
		}
	},
	Swim = {
		CanRecover = true,
		Move = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				multiplier = "swimCostRate",
				cost = 0
			}
		},
		Sprint = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				multiplier = "swimSprintCostRate",
				cost = 8
			}
		},
		Dash = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				multiplier = "swimDashCostRate",
				cost = 20
			}
		}
	},
	Fly = {
		[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
			cost = 1
		},
		Move = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost_h = 15,
				cost_v = 66,
				CostRateNotInCombat = 0.3333333
			}
		},
		Dash = {
			EnterWithoutCost = true,
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 24
			},
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost_h = 10,
				cost_v = 60
			}
		},
		Sprint = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost_h = 9,
				cost_v = 48
			}
		},
		Jump = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 10
			}
		},
		Default = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 15,
				CostRateNotInCombat = 0
			}
		}
	},
	Sneak = {
		Move = {
			CanRecover = true,
			EnterWithoutCost = true,
			CostRateNotInCombat = 0,
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 30
			},
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 15
			}
		},
		Default = {
			CanRecover = true,
			EnterWithoutCost = true,
			CostRateNotInCombat = 0,
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 30
			},
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 15
			}
		}
	},
	SpeedBurst = {
		CostRateNotInCombat = 0.8,
		Dash = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 35
			}
		},
		Sprint = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				multiplier = "speedBurstLoopCostRate",
				cost = 20
			}
		}
	},
	SkillRoll = {
		CostRateNotInCombat = 0.8,
		Sprint = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				multiplier = "skillRollLoopCostRate",
				cost = 20
			}
		}
	}
}
StaminaConst.StaminaCostConfigAvatar = {
	Default = {
		CanRecover = true,
		Dash = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				multiplier = "dashCostRate",
				cost = 16.5
			}
		},
		Sprint = {
			CostRateNotInCombat = 0,
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 15
			}
		},
		Fall = {
			CanRecover = false
		}
	},
	Climb = {
		[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
			cost = 1
		},
		Move = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 10
			}
		}
	},
	Swim = {
		CanRecover = true,
		Move = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 0
			}
		},
		Sprint = {
			[StaminaConst.StaminaCostType.COST_BY_TIME] = {
				cost = 10
			}
		},
		Dash = {
			[StaminaConst.StaminaCostType.COST_ON_ENTER] = {
				cost = 25
			}
		}
	}
}
StaminaConst.StaminaRegenCoolDown = 0.5
StaminaConst.RegenReduceInCombatBuffId = 0

return StaminaConst
