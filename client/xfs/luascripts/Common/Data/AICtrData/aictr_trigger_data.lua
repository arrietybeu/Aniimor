-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\aictr_trigger_data.lua

local data = {
	AbilityNoHit = {
		inPorts = {},
		outPorts = {}
	},
	AlertMsgTrigger = {
		inPorts = {},
		outPorts = {}
	},
	CastSameTypeSkillMsgTrigger = {
		inPorts = {},
		outPorts = {
			tSkillId = 0,
			tSkillTargetActorId = 0
		}
	},
	CastSkillMsgTrigger = {
		inPorts = {},
		outPorts = {
			tSkillId = 0,
			tSkillTargetActorId = 0
		}
	},
	CombatDodgeTrigger = {
		inPorts = {},
		outPorts = {
			tTargetActorId = 0
		}
	},
	CommandGoTrigger = {
		inPorts = {},
		outPorts = {
			partId = 0,
			targetActorId = 0,
			skillId = 0
		}
	},
	CommonClientMsgTrigger = {
		inPorts = {},
		outPorts = {
			var = {}
		}
	},
	DontCombatTrigger = {
		inPorts = {},
		outPorts = {
			tTargetActorId = 0
		}
	},
	EnterCannotFollowAreaMsg = {
		inPorts = {},
		outPorts = {
			waitPos = {}
		}
	},
	EnterCombatTrigger = {
		inPorts = {},
		outPorts = {
			tTargetActorId = 0
		}
	},
	EntityCastAbilityTrigger = {
		inPorts = {},
		outPorts = {
			entityActorId = 0
		}
	},
	Event_Ability_ = {
		inPorts = {},
		outPorts = {}
	},
	Event_GB_SheepAbility = {
		inPorts = {},
		outPorts = {
			targetActorId = 0
		}
	},
	Event_GB_SheepGather = {
		inPorts = {},
		outPorts = {
			memberIndex = 0,
			targetActorId = 0
		}
	},
	Event_PER_ = {
		inPorts = {
			interactBehav = ""
		},
		outPorts = {
			interactObjectActorId = 0,
			interactArg = {}
		}
	},
	Event_PetRespondToPlayerAction = {
		inPorts = {},
		outPorts = {
			emojiBubbleKey = "",
			animationStartKey = "",
			animationLoopKey = "",
			animationKey = "",
			animationEndKey = "",
			entityActorId = 0
		}
	},
	Event_Recruit_Follow = {
		inPorts = {},
		outPorts = {
			followOneByOneActorId = 0,
			recruitTargetActorId = 0
		}
	},
	ForbidCatchOnBallHitTrigger = {
		inPorts = {},
		outPorts = {
			tBallMasterId = 0
		}
	},
	GBPMsg_Common = {
		inPorts = {},
		outPorts = {
			tRoleIndex = 0
		}
	},
	GBPMsg_ResPoint = {
		inPorts = {},
		outPorts = {
			tRoleIndex = 0,
			tPortId = 0,
			tPointId = 0
		}
	},
	GBTrigger_Test_CustomAnimation = {
		inPorts = {},
		outPorts = {
			tMemberIndex = 0,
			tTriggerCount = 0
		}
	},
	GBTrigger_Test_MoveToResPoint = {
		inPorts = {},
		outPorts = {
			tPortId = 0,
			tPointId = 0
		}
	},
	GroupBehavWaitTrigger = {
		inPorts = {},
		outPorts = {
			tWaitTime = 0
		}
	},
	HpDamageTrigger = {
		inPorts = {},
		outPorts = {
			damageSourceId = 0,
			targetId = 0
		}
	},
	IdleMsgTrigger = {
		inPorts = {},
		outPorts = {}
	},
	LevelMsgTrigger = {
		inPorts = {
			in_filtKey = ""
		},
		outPorts = {
			filtKey = ""
		}
	},
	LevelMsg_CastSkill = {
		inPorts = {},
		outPorts = {
			WaitTime = 0,
			SkillId = 0,
			RaycastOpen = false,
			EmojiBubbleTimeout = 0,
			EmojiBubbleKey = ""
		}
	},
	LevelMsg_EnterCombat = {
		inPorts = {},
		outPorts = {}
	},
	LevelMsg_Route = {
		inPorts = {},
		outPorts = {
			loopTime = 0,
			routeId = 0
		}
	},
	LevelMsg_SwitchState = {
		inPorts = {},
		outPorts = {
			targetState = "",
			replaceAnimationKey = ""
		}
	},
	LevelUpTrigger = {
		inPorts = {},
		outPorts = {
			targetId = 0
		}
	},
	MasterOpenChestTrigger = {
		inPorts = {},
		outPorts = {
			chestId = 0
		}
	},
	MasterSwitchTargetMsgTrigger = {
		inPorts = {},
		outPorts = {
			enemyId = 0
		}
	},
	MimicryOutByEcsStateChangeTrigger = {
		inPorts = {},
		outPorts = {
			tStateName = ""
		}
	},
	MimicryOutByElementAbilityTrigger = {
		inPorts = {},
		outPorts = {
			tSrcActorId = 0,
			tSrcAbilityId = 0,
			tAbilityElementType = 0
		}
	},
	MimicryOutByImpulseTrigger = {
		inPorts = {},
		outPorts = {
			tImpulseValue = 0
		}
	},
	MimicryOutMsgTrigger = {
		inPorts = {},
		outPorts = {}
	},
	Msg_Home_Common = {
		inPorts = {},
		outPorts = {
			yawAngle = 0,
			animationKey = "",
			faceAnimationKey = "",
			pos = {},
			workPos = {}
		}
	},
	Msg_Home_Leisure_Mount = {
		inPorts = {},
		outPorts = {
			vehicleActorId = 0,
			seatIndex = 0,
			revision = 0,
			vehiclePos = {}
		}
	},
	Msg_Home_Leisure_Petting = {
		inPorts = {},
		outPorts = {
			animationLoopKey = "",
			animationStartKey = "",
			emojiKey = "",
			isStartLoopEndAnim = false,
			animationEndKey = "",
			targetActorId = 0,
			revision = 0
		}
	},
	Msg_Home_Leisure_Walk = {
		inPorts = {},
		outPorts = {
			animationLoopKey = "",
			animationStartKey = "",
			emojiKey = "",
			isStartLoopEndAnim = false,
			animationEndKey = "",
			revision = 0,
			onlyWalk = false
		}
	},
	Msg_Home_MoveToPos = {
		inPorts = {},
		outPorts = {
			yawAngle = 0,
			moveSpeed = 0,
			moveMaxTime = 0,
			isTransport = false,
			pos = {}
		}
	},
	Msg_Home_RandomEvent = {
		inPorts = {},
		outPorts = {
			animationKey = ""
		}
	},
	Msg_Home_Wellcome = {
		inPorts = {},
		outPorts = {
			targetActorId = 0,
			targetPos = {}
		}
	},
	NpcStatusChangeTrigger = {
		inPorts = {},
		outPorts = {
			tNewValue = 0,
			tKey = 0,
			tIsInit = false,
			tOldValue = 0
		}
	},
	NvidiaReviewDemoTrigger = {
		inPorts = {},
		outPorts = {
			stopDist = 0,
			speed = 0,
			isGoTargetPos = false,
			isFollow = false,
			emojiTime = 0,
			animationTime = 0,
			actorId = 0,
			emojiKey = "",
			animationKey = "",
			waitTime = 0,
			animationLoopKey = {},
			speedRateType = {
				value__ = 0
			},
			targetPos = {}
		}
	},
	OnAITagAddMsgTrigger = {
		inPorts = {},
		outPorts = {
			tag = ""
		}
	},
	OnAITagRemoveMsgTrigger = {
		inPorts = {},
		outPorts = {
			tag = ""
		}
	},
	OnCharacterStateChange = {
		inPorts = {},
		outPorts = {
			newState = "",
			oldState = ""
		}
	},
	OnEntityTagAddMsgTrigger = {
		inPorts = {},
		outPorts = {
			tag = ""
		}
	},
	OnEntityTagRemoveMsgTrigger = {
		inPorts = {},
		outPorts = {
			tag = ""
		}
	},
	OnLandStateEnterTrigger = {
		inPorts = {},
		outPorts = {
			height = 0
		}
	},
	OnNearByEntityTrapped = {
		inPorts = {},
		outPorts = {
			targetActorId = 0
		}
	},
	PercpetEntityReactionTrigger = {
		inPorts = {
			interactBehav = ""
		},
		outPorts = {
			interactObjectActorId = 0,
			interactArg = {}
		}
	},
	PlayerSwitchControllTrigger = {
		inPorts = {},
		outPorts = {
			entityActorId = 0
		}
	},
	PlayerVarChangeTrigger = {
		inPorts = {
			in_filtKey = 0
		},
		outPorts = {
			tNewValue = 0,
			filtKey = 0,
			tOldValue = 0
		}
	},
	ProjectileMoveTo = {
		inPorts = {},
		outPorts = {
			velocity = 0,
			distance = 0
		}
	},
	ProtectMasterMsgTrigger = {
		inPorts = {},
		outPorts = {
			enemyId = 0
		}
	},
	RecruitBeginTrigger = {
		inPorts = {},
		outPorts = {
			recruitTargetActorId = 0
		}
	},
	RecruitMoveToPointMsgTrigger = {
		inPorts = {},
		outPorts = {
			index = 0,
			movePos = {},
			turnPos = {}
		}
	},
	SeekLoveMsgTrigger = {
		inPorts = {},
		outPorts = {}
	},
	SeekLoveStartMsgTrigger = {
		inPorts = {},
		outPorts = {
			targetActorId = 0
		}
	},
	SensedMsgTrigger = {
		inPorts = {},
		outPorts = {}
	},
	SlaveOwnerEnterCombatTrigger = {
		inPorts = {},
		outPorts = {}
	},
	SneakColliderTrigger = {
		inPorts = {},
		outPorts = {}
	},
	TimePeriodChangeTrigger = {
		inPorts = {},
		outPorts = {
			tIsInit = false,
			tCurTimePeriod = 0
		}
	}
}

return data
