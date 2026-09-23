-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\aictr_event_data.lua

local data = {
	AddAITag = {
		inPorts = {
			tagName = "",
			entityActorId = 0
		},
		outPorts = {}
	},
	AddBuff = {
		inPorts = {
			entityActorId = 0,
			duration = 0,
			buffId = 0
		},
		outPorts = {}
	},
	AddEntityTag = {
		inPorts = {
			tag = "",
			entityActorId = 0
		},
		outPorts = {}
	},
	BlendToFov = {
		inPorts = {
			blendTime = 0,
			fov = 0,
			blendType = {
				value__ = 0
			}
		},
		outPorts = {}
	},
	CancelFovBlend = {
		inPorts = {
			blendOutTime = 0,
			blendType = {
				value__ = 0
			}
		},
		outPorts = {}
	},
	CancelFovCurveAnim = {
		inPorts = {},
		outPorts = {}
	},
	CancelLookAtEntity = {
		inPorts = {},
		outPorts = {}
	},
	ClearNotTargetLetGoCD = {
		inPorts = {},
		outPorts = {}
	},
	DebugVar = {
		inPorts = {
			strVar = "",
			intVar = 0,
			floatVar = 0,
			boolVar = false,
			tableVar = {}
		},
		outPorts = {}
	},
	DestroyEnvObj = {
		inPorts = {
			delaySecond = 0,
			envObjActorId = 0
		},
		outPorts = {}
	},
	DoSysEvent = {
		inPorts = {
			eventId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	DynamicAddBehavior = {
		inPorts = {
			entityActorId = 0,
			behaviorId = ""
		},
		outPorts = {}
	},
	DynamicRemoveBehavior = {
		inPorts = {
			entityActorId = 0,
			behaviorId = ""
		},
		outPorts = {}
	},
	EnterCombat = {
		inPorts = {
			targetActorId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	EnterFollow = {
		inPorts = {
			targetActorId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	EnterPetGuide = {
		inPorts = {
			targetActorId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	EnterPhotoEcology = {
		inPorts = {
			pointId = 0
		},
		outPorts = {}
	},
	ExitPetGuide = {
		inPorts = {
			entityActorId = 0
		},
		outPorts = {}
	},
	ExitPhotoEcology = {
		inPorts = {
			pointId = 0
		},
		outPorts = {}
	},
	ExitResPointPort = {
		inPorts = {
			targetPortId = 0,
			targetPointId = 0,
			exitDistance = 0,
			delayTime = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	FinishHomeLandLeisure = {
		inPorts = {
			revision = 0
		},
		outPorts = {}
	},
	FinishHomeLandOperation = {
		inPorts = {
			needResetHomeWork = false
		},
		outPorts = {}
	},
	HideEmojiOnTarget = {
		inPorts = {
			targetActorId = 0,
			emojiStr = ""
		},
		outPorts = {}
	},
	HideQuestionMark = {
		inPorts = {
			entityActorId = 0
		},
		outPorts = {}
	},
	JoinResPointBehaviour = {
		inPorts = {
			targetPointId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	JoinResPointPort = {
		inPorts = {
			targetPointId = 0,
			targetPortId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	LerpProperty = {
		inPorts = {
			enable = false,
			targetActorId = 0,
			lerpTime = 0
		},
		outPorts = {}
	},
	LookAtEntity = {
		inPorts = {
			targetActorId = 0,
			force = false
		},
		outPorts = {}
	},
	PlayEffectOnTarget = {
		inPorts = {
			targetActorId = 0,
			duration = 0,
			effectStr = ""
		},
		outPorts = {}
	},
	PlayEmojiOnTarget = {
		inPorts = {
			targetActorId = 0,
			emojiStr = "",
			duration = 0
		},
		outPorts = {}
	},
	PlayFovCurveAnim = {
		inPorts = {
			blendInTime = 0,
			blendOutTime = 0,
			duration = 0,
			fovCurveName = ""
		},
		outPorts = {}
	},
	PreJoinResPointPort = {
		inPorts = {
			targetPointId = 0,
			targetPortId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	RecruitBeginFollowOneByOne = {
		inPorts = {
			ownerActorId = 0
		},
		outPorts = {}
	},
	RemoveAITag = {
		inPorts = {
			tagName = "",
			entityActorId = 0
		},
		outPorts = {}
	},
	RemoveBuff = {
		inPorts = {
			entityActorId = 0,
			buffId = 0
		},
		outPorts = {}
	},
	RemoveEntityTag = {
		inPorts = {
			tag = "",
			entityActorId = 0
		},
		outPorts = {}
	},
	ReqEnterRecruit = {
		inPorts = {
			targetActorId = 0
		},
		outPorts = {}
	},
	SendMessageToTrigger = {
		inPorts = {
			msgId = 0,
			entityActorId = 0
		},
		outPorts = {}
	},
	SendMessageToTriggerSpecial = {
		inPorts = {
			anotherActorId = 0,
			mainActorId = 0
		},
		outPorts = {}
	},
	SetAFKScreen = {
		inPorts = {
			enable = false
		},
		outPorts = {}
	},
	SetModelActive = {
		inPorts = {
			objectName = "",
			active = false,
			entityActorId = 0
		},
		outPorts = {}
	},
	SetNpcStatus = {
		inPorts = {
			staticId = 0,
			key = 0,
			forceRefresh = false,
			val = 0
		},
		outPorts = {}
	},
	SetPetAppearance = {
		inPorts = {
			targetActorId = 0,
			individuationId = 0
		},
		outPorts = {}
	},
	SetPlayerFaceToTarget = {
		inPorts = {
			duration = 0,
			targetActorId = 0
		},
		outPorts = {}
	},
	SetPlayerVar = {
		inPorts = {
			val = 0,
			key = 0
		},
		outPorts = {}
	},
	SetVisionAreaOverride = {
		inPorts = {
			areaName = ""
		},
		outPorts = {}
	},
	ShowQuestionMark = {
		inPorts = {
			markType = "",
			entityActorId = 0
		},
		outPorts = {}
	},
	StartNpcDialog = {
		inPorts = {
			dialogId = 0,
			actorId = 0
		},
		outPorts = {}
	},
	StopEffectOnTarget = {
		inPorts = {
			effectKey = "",
			targetActorId = 0
		},
		outPorts = {}
	},
	TriggerBluePrint = {
		inPorts = {
			eventName = ""
		},
		outPorts = {}
	},
	TryHomeLeisureMount = {
		inPorts = {
			vehicleActorId = 0,
			revision = 0,
			seatIndex = 0
		},
		outPorts = {}
	},
	playEmojiOnTeam = {
		inPorts = {
			targetActorId = 0,
			emojiStr = "",
			duration = 0
		},
		outPorts = {}
	},
	playSound = {
		inPorts = {
			duration = 0,
			targetActorId = 0,
			soundId = ""
		},
		outPorts = {}
	}
}

return data
