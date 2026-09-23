-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\OpDef.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local OpDef = {}

OpDef.OP = {
	SC_HC_CampExpired = 10504,
	SC_HC_LoginCampSuccess = 10503,
	SC_HC_ChangeCampSuccess = 10501,
	SC_HC_UnlockCampSuccess = 10500,
	CS_HC_ChangeCarIndex = 524,
	CS_HC_KickLineMember = 523,
	CS_HC_SetLinePermission = 522,
	CS_HC_DissolvePrivateLine = 521,
	CS_HC_CreatePrivateLine = 520,
	CS_HC_AcceptInvite = 515,
	CS_HC_InviteFriend = 514,
	CS_HC_ConfirmRelocate = 513,
	CS_HC_RefreshAddOns = 512,
	CS_HC_UpgradeReward = 511,
	CS_HC_DispatchFinish = 510,
	CS_HC_DispatchStop = 509,
	CS_HC_Dispatch = 508,
	CS_HC_ChangePets = 507,
	CS_HC_Like = 506,
	CS_HC_UpgradeCarComp = 505,
	CS_HC_UpgradeCar = 504,
	CS_HC_ChangeShape = 503,
	CS_HC_ChangeName = 502,
	CS_HC_ChangeCamp = 501,
	CS_HC_UnlockCamp = 500,
	SC_HF_Refresh = 10400,
	CS_HF_ClearSlot = 401,
	CS_HF_AddItem = 400,
	SC_CR_SettleFinish = 10302,
	SC_CR_AddOnNotify = 10301,
	SC_CR_SettleRequest = 10300,
	CS_CR_GameNext = 307,
	CS_CR_GameSettle = 306,
	CS_CR_GameSave = 305,
	CS_CR_GameStart = 304,
	CS_CR_GameEnter = 303,
	CS_CR_UpdateBallCount = 302,
	CS_CR_UpdateBalls = 301,
	CS_CR_UpdatePets = 300,
	GP_PLAYER_PET_READY = 203,
	GP_PLAYER_PET_DIE = 202,
	GP_RECEIVE_HEAL = 201,
	GP_TAKE_DAMAGE = 200,
	SC_PR_LOADING_INFO = 10103,
	SC_PR_CONFIRM_NOTIFY = 10102,
	SC_PR_PICK_NOTIFY = 10101,
	SC_PR_ROOM_INFO = 10100,
	CS_PR_CONFIRM = 101,
	CS_PR_PICK = 100,
	SC_FC_SettleResult = 10805,
	SC_FC_HeatUpdate = 10804,
	SC_FC_CaptureSuccess = 10803,
	SC_FC_ThrowResult = 10802,
	SC_FC_BattleResult = 10801,
	SC_FC_PhaseChange = 10800,
	CS_FS_ForgeAPact = 806,
	CS_FC_ExchangeTicket = 805,
	CS_FC_Quit = 804,
	CS_FC_ThrowBall = 803,
	CS_FC_SkipBattle = 802,
	CS_FC_StartBattle = 801,
	CS_FC_Enter = 800,
	SC_PC_HugInviteResult = 10603,
	SC_PC_HugInvite = 10602,
	SC_PC_OnDropCarry = 10601,
	SC_PC_OnStartCarry = 10600,
	CS_PC_InspectItem = 612,
	CS_PC_StrokePet = 611,
	CS_PC_HugReply = 610,
	CS_PC_BeHuggedPutDown = 609,
	CS_PC_PlayerPutDown = 608,
	CS_PC_PlayerTakeUp = 607,
	CS_PC_ItemPutBack = 606,
	CS_PC_ItemTakeOut = 605,
	CS_PC_PetAssign = 604,
	CS_PC_PetPutDown = 603,
	CS_PC_PetPutBack = 602,
	CS_PC_PetTakeOut = 601,
	CS_PC_PetTakeUp = 600,
	SC_HC_MembersNotUnlocked = 10527,
	SC_HC_PrivateLineMigrated = 10526,
	SC_HC_LineInfoChanged = 10525,
	SC_HC_ChangeCarIndex = 10524,
	SC_HC_PrivateLineKicked = 10523,
	SC_HC_PermissionChanged = 10522,
	SC_HC_PrivateLineDissolved = 10521,
	SC_HC_CreatePrivateLineSuccess = 10520,
	SC_HC_InviteReceived = 10514,
	SC_HC_Notice = 10510
}
OpDef.OP_needUnlockCamp = {
	[OpDef.OP.CS_HC_ChangeCamp] = true,
	[OpDef.OP.CS_HC_ChangeName] = true,
	[OpDef.OP.CS_HC_ChangeShape] = true,
	[OpDef.OP.CS_HC_UpgradeCar] = true,
	[OpDef.OP.CS_HC_UpgradeCarComp] = true,
	[OpDef.OP.CS_HC_ConfirmRelocate] = true,
	[OpDef.OP.CS_HC_InviteFriend] = true,
	[OpDef.OP.CS_HC_AcceptInvite] = true,
	[OpDef.OP.CS_HC_CreatePrivateLine] = true,
	[OpDef.OP.CS_HC_DissolvePrivateLine] = true,
	[OpDef.OP.CS_HC_SetLinePermission] = true,
	[OpDef.OP.CS_HC_KickLineMember] = true,
	[OpDef.OP.CS_HC_ChangeCarIndex] = true
}
OpDef.OP_needInHomeCamp = {
	[OpDef.OP.CS_HC_ChangeCamp] = true,
	[OpDef.OP.CS_HC_InviteFriend] = true,
	[OpDef.OP.CS_HC_KickLineMember] = true,
	[OpDef.OP.CS_HC_ChangeCarIndex] = true
}
OpDef.OP_needInSelfHomeCamp = {
	[OpDef.OP.CS_HC_ChangePets] = true,
	[OpDef.OP.CS_HC_Dispatch] = true,
	[OpDef.OP.CS_HC_DispatchStop] = true,
	[OpDef.OP.CS_HC_DispatchFinish] = true
}
OpDef.OP_PARAM_DEF = {
	[OpDef.OP.CS_PR_PICK] = {
		index = {
			"number",
			"选择的序号"
		}
	},
	[OpDef.OP.CS_PR_CONFIRM] = {},
	[OpDef.OP.SC_PR_ROOM_INFO] = {
		end_ts = {
			"number",
			"结束时间戳"
		},
		players = {
			__key = {
				"string",
				"玩家的uid"
			},
			__val = {
				__isDict = true,
				base = {
					"table",
					"CustomType:PlayerBaseInfo"
				},
				team = {
					"table",
					"CustomType:PVPPetTeamInfo"
				}
			}
		}
	},
	[OpDef.OP.SC_PR_PICK_NOTIFY] = {
		uid = {
			"string",
			"玩家的uid"
		},
		pickCnt = {
			"number",
			"已选择数量"
		}
	},
	[OpDef.OP.SC_PR_CONFIRM_NOTIFY] = {
		uid = {
			"string",
			"玩家的uid"
		}
	},
	[OpDef.OP.SC_PR_LOADING_INFO] = {
		players = {
			__key = {
				"string",
				"玩家的uid"
			},
			__val = {
				__isDict = true,
				petList = {
					__isList = true,
					__valDef = {
						"number",
						"宠物templateId"
					}
				}
			}
		}
	},
	[OpDef.OP.CS_CR_UpdatePets] = {
		petIds = {
			__isList = true,
			__valDef = {
				"string",
				"宠物ID"
			}
		}
	},
	[OpDef.OP.CS_CR_UpdateBalls] = {
		ballIds = {
			__isList = true,
			__valDef = {
				"number",
				"球ID"
			}
		}
	},
	[OpDef.OP.CS_CR_UpdateBallCount] = {
		ballCountMap = {
			__key = {
				"number",
				"球ID"
			},
			__val = {
				"number",
				"球数量"
			}
		}
	},
	[OpDef.OP.CS_CR_GameEnter] = {},
	[OpDef.OP.CS_CR_GameStart] = {},
	[OpDef.OP.CS_CR_GameSave] = {},
	[OpDef.OP.CS_CR_GameSettle] = {
		isQuit = {
			"boolean",
			"是否退出"
		},
		purchaseType = {
			"number",
			"购买类型, Const.CatchRogue.PURCHASE_...",
			true
		}
	},
	[OpDef.OP.SC_CR_SettleRequest] = {
		reason = {
			"number",
			"结算原因, Const.CatchRogue.SETTLE_REASON_..."
		}
	},
	[OpDef.OP.SC_CR_AddOnNotify] = {
		addonId = {
			"number",
			"增益ID"
		}
	},
	[OpDef.OP.SC_CR_SettleFinish] = {
		itemCountMap = {
			"table",
			"物品数量表，key为itemId，value为数量"
		}
	},
	[OpDef.OP.CS_HF_AddItem] = {
		itemId = {
			"number",
			"食材ID"
		},
		itemNum = {
			"number",
			"食材数量"
		}
	},
	[OpDef.OP.CS_HF_ClearSlot] = {
		slotIndex = {
			"number",
			"槽位ID"
		}
	},
	[OpDef.OP.CS_HC_Dispatch] = {
		dispatchId = {
			"number",
			"派遣配置id"
		},
		campId = {
			"number",
			"派遣奖励所属营地staticId；仅私人驿站可指定",
			true
		}
	},
	[OpDef.OP.CS_HC_ChangeCamp] = {
		staticId = {
			"number",
			"目标营地staticId"
		},
		lineId = {
			"number",
			"目标分线ID",
			true
		}
	},
	[OpDef.OP.CS_HC_InviteFriend] = {
		targetUid = {
			"string",
			"被邀请玩家uid"
		}
	},
	[OpDef.OP.CS_HC_AcceptInvite] = {
		inviteId = {
			"string",
			"邀请凭证ID"
		}
	},
	[OpDef.OP.CS_HC_RefreshAddOns] = {
		ownerUid = {
			"string",
			"目标车位主人uid",
			true
		}
	},
	[OpDef.OP.CS_HC_CreatePrivateLine] = {
		staticId = {
			"number",
			"目标营地staticId"
		}
	},
	[OpDef.OP.CS_HC_DissolvePrivateLine] = {},
	[OpDef.OP.CS_HC_SetLinePermission] = {
		permissions = {
			"number",
			"权限位掩码"
		}
	},
	[OpDef.OP.SC_HC_ChangeCampSuccess] = {
		staticId = {
			"number",
			"目标营地staticId"
		},
		lastStaticId = {
			"number",
			"切换前的营地staticId（本会话内），0 表示无切换；客户端按 staticId != lastStaticId 判断是否需要传送或弹切营地提示"
		},
		lineId = {
			"number",
			"当前分线ID"
		},
		lastLineId = {
			"number",
			"切换前的分线ID（本会话内），0 表示无切换；客户端按 lineId != lastLineId 判断分线是否变化"
		}
	},
	[OpDef.OP.SC_HC_LoginCampSuccess] = {
		staticId = {
			"number",
			"当前营地staticId"
		},
		lastStaticId = {
			"number",
			"切换前的营地staticId（本会话内），0 表示无切换/首次登录；客户端按 staticId != lastStaticId 判断是否需要传送或弹切营地提示"
		},
		spaceKey = {
			"string",
			"当前营地spaceKey"
		},
		lineId = {
			"number",
			"当前分线ID"
		},
		lastLineId = {
			"number",
			"切换前的分线ID（本会话内），0 表示无切换/首次登录；客户端按 lineId != lastLineId 判断分线是否变化"
		},
		carIndex = {
			"number",
			"当前停车位索引"
		},
		carTmplId = {
			"number",
			"当前房车模板ID"
		},
		displayCode = {
			"string",
			"新架构分线展示编号",
			true
		},
		transferReason = {
			"string",
			"传送原因；缺省表示普通登录同步，不强制传送",
			true
		},
		transferSourceOp = {
			"number",
			"触发该次就绪的业务事件协议Op（10520/10521/10523/10501等）",
			true
		},
		transferLineUid = {
			"number",
			"新架构 lineUid，便于客户端校验/日志",
			true
		},
		transferNoticeId = {
			"number",
			"可选提示，客户端可在传送后统一弹",
			true
		}
	},
	[OpDef.OP.SC_HC_InviteReceived] = {
		inviteId = {
			"string",
			"邀请凭证ID"
		},
		inviterUid = {
			"string",
			"邀请者uid"
		},
		targetUid = {
			"string",
			"被邀请玩家uid"
		},
		inviterName = {
			"string",
			"邀请者名字"
		},
		lineUid = {
			"number",
			"分线uid"
		},
		staticId = {
			"number",
			"营地staticId"
		},
		displayCode = {
			"string",
			"分线显示编号"
		},
		expireTs = {
			"number",
			"过期时间戳"
		}
	},
	[OpDef.OP.SC_HC_CreatePrivateLineSuccess] = {
		lineUid = {
			"number",
			"私人分线 lineUid"
		},
		displayCode = {
			"string",
			"分线显示编号",
			true
		},
		staticId = {
			"number",
			"目标营地 staticId"
		},
		pendingActivate = {
			"boolean",
			"true 表示仅创建成功、仍需等待 SwitchCamp 激活",
			true
		}
	},
	[OpDef.OP.SC_HC_PrivateLineDissolved] = {
		lineUid = {
			"number",
			"分线uid"
		},
		ownerName = {
			"string",
			"分线主人名字"
		},
		noticeId = {
			"number",
			"提示ID",
			true
		}
	},
	[OpDef.OP.SC_HC_PermissionChanged] = {
		permissions = {
			"number",
			"新权限位掩码"
		}
	},
	[OpDef.OP.CS_HC_KickLineMember] = {
		targetUid = {
			"string",
			"被踢玩家uid"
		}
	},
	[OpDef.OP.SC_HC_PrivateLineKicked] = {
		lineUid = {
			"number",
			"分线uid"
		},
		ownerName = {
			"string",
			"分线主人名字"
		},
		noticeId = {
			"number",
			"提示ID",
			true
		}
	},
	[OpDef.OP.CS_HC_ChangeCarIndex] = {
		targetCarIndex = {
			"number",
			"目标车位索引"
		}
	},
	[OpDef.OP.SC_HC_ChangeCarIndex] = {
		oldCarIndex = {
			"number",
			"原车位索引"
		},
		newCarIndex = {
			"number",
			"新车位索引"
		}
	},
	[OpDef.OP.SC_HC_LineInfoChanged] = {
		lineUid = {
			"number",
			"分线 lineUid"
		},
		ownerEpoch = {
			"number",
			"广播时刻的 ownerEpoch"
		},
		lineVersion = {
			"number",
			"lineInfo 单调递增版本号"
		},
		reason = {
			"string",
			"变更原因 login/logout/change_slot/kick_member/permission_changed/permission_revert/enter/leave_enter/full"
		},
		mode = {
			"string",
			"全量或增量 full/patch（首期仅 full）"
		},
		lineInfo = {
			"table",
			"mode=full 时携带的分线摘要（与 buildLineSummary 一致）",
			true
		},
		patch = {
			"table",
			"mode=patch 预留",
			true
		}
	},
	[OpDef.OP.SC_HC_PrivateLineMigrated] = {
		mode = {
			"string",
			"迁移模式 login/enter"
		},
		privateLineKey = {
			"string",
			"私人分线稳定身份",
			true
		},
		sourceLineUid = {
			"number",
			"源分线 lineUid",
			true
		},
		sourceAreaId = {
			"number",
			"源 areaId",
			true
		},
		sourceBucketId = {
			"number",
			"源 bucketId",
			true
		},
		sourceStaticId = {
			"number",
			"源营地 staticId",
			true
		},
		sourceSpaceKey = {
			"string",
			"源营地 spaceKey",
			true
		},
		targetLineUid = {
			"number",
			"目标分线 lineUid"
		},
		targetAreaId = {
			"number",
			"目标 areaId",
			true
		},
		targetBucketId = {
			"number",
			"目标 bucketId",
			true
		},
		targetStaticId = {
			"number",
			"目标营地 staticId"
		},
		targetSpaceKey = {
			"string",
			"目标营地 spaceKey",
			true
		}
	},
	[OpDef.OP.CS_PC_PetTakeUp] = {
		petId = {
			"string",
			"宠物ID"
		},
		fromType = {
			"number",
			"来源类型，Const.CARRY_REQ_FROM_..."
		}
	},
	[OpDef.OP.CS_PC_PetTakeOut] = {
		petId = {
			"string",
			"宠物ID"
		},
		fromType = {
			"number",
			"来源类型，Const.CARRY_REQ_FROM_..."
		}
	},
	[OpDef.OP.CS_PC_PetAssign] = {
		ornamentId = {
			"number",
			"家具ID"
		},
		opId = {
			"number",
			""
		}
	},
	[OpDef.OP.CS_PC_ItemTakeOut] = {
		invId = {
			"number",
			"背包ID"
		},
		genId = {
			"number",
			"道具格子ID"
		}
	},
	[OpDef.OP.CS_PC_PlayerTakeUp] = {
		targetId = {
			"string",
			"被抱玩家实体ID"
		},
		fromType = {
			"number",
			"来源类型，Const.CARRY_REQ_FROM_..."
		}
	},
	[OpDef.OP.CS_PC_HugReply] = {
		inviterId = {
			"string",
			"发起抱起邀请的玩家实体ID"
		},
		accept = {
			"boolean",
			"是否同意被抱"
		}
	},
	[OpDef.OP.CS_FC_Enter] = {},
	[OpDef.OP.CS_FC_StartBattle] = {},
	[OpDef.OP.CS_FC_SkipBattle] = {},
	[OpDef.OP.CS_FC_ThrowBall] = {
		ballItemId = {
			"number",
			"球道具ID"
		}
	},
	[OpDef.OP.CS_FC_Quit] = {},
	[OpDef.OP.SC_FC_PhaseChange] = {
		phase = {
			"number",
			"子阶段, FishingCaptureConst.Phase"
		},
		phaseEndTs = {
			"number",
			"阶段结束时间戳"
		},
		extraData = {
			"table",
			"额外数据",
			true
		}
	},
	[OpDef.OP.SC_FC_BattleResult] = {
		grade = {
			"number",
			"战斗评级 1=S,2=A,3=B"
		}
	},
	[OpDef.OP.SC_FC_ThrowResult] = {
		success = {
			"boolean",
			"是否捕获成功"
		},
		critType = {
			"number",
			"暴击类型,见 FishingCaptureConst.CritType (None/Small/Big)"
		},
		progressDelta = {
			"number",
			"进度增量"
		},
		curProgress = {
			"number",
			"当前进度"
		},
		curLayer = {
			"number",
			"当前虚弱层数"
		},
		coinNum = {
			"number",
			"获得的使徒代币数量,满进度随机失败才会有",
			true
		}
	},
	[OpDef.OP.SC_FC_CaptureSuccess] = {
		petId = {
			"string",
			"宠物ID",
			true
		},
		petTemplateId = {
			"number",
			"宠物数据表ID",
			true
		},
		rewardId = {
			"number",
			"捕获奖励Id",
			true
		},
		isByLevelRandom = {
			"boolean",
			"是否能量满随机发放(非直接捕捉)"
		}
	},
	[OpDef.OP.SC_FC_HeatUpdate] = {
		heatValue = {
			"number",
			"当前热度值"
		},
		frenzyActive = {
			"boolean",
			"狂热是否激活"
		}
	},
	[OpDef.OP.SC_FC_SettleResult] = {
		reason = {
			"number",
			"结算原因, FishingCaptureConst.SettleReason"
		},
		rewards = {
			"table",
			"奖励列表",
			true
		}
	},
	[OpDef.OP.CS_FC_ExchangeTicket] = {
		cubeType = {
			"number",
			"立方类型，1传说立方，2赛季立方"
		}
	}
}
OpDef.OP_REVERSE_MAP = {}

function OpDef.initOpReverseMap()
	for k, v in pairs(OpDef.OP) do
		OpDef.OP_REVERSE_MAP[v] = k
	end
end

function OpDef._checkNode(nodeParam, nodeDef)
	if nodeParam == nil and (nodeDef.__optional or nodeDef[3]) then
		return true
	end

	if nodeDef.__key and nodeDef.__val then
		if type(nodeParam) ~= "table" then
			return false
		end

		for k, v in pairs(nodeParam) do
			local ret = OpDef._checkNode(k, nodeDef.__key) and OpDef._checkNode(v, nodeDef.__val)

			if not ret then
				return false
			end
		end
	elseif nodeDef.__isDict then
		if type(nodeParam) ~= "table" then
			return false
		end

		for k, v in pairs(nodeDef) do
			local ret = OpDef._checkNode(nodeParam[k], v)

			if not ret then
				return false
			end
		end
	elseif nodeDef.__isList then
		if type(nodeParam) ~= "table" then
			return false
		end

		for k, v in pairs(nodeParam) do
			local ret = type(k) == "number" and OpDef._checkNode(v, nodeDef.__valDef)

			if not ret then
				return false
			end
		end
	elseif type(nodeParam) ~= nodeDef[1] then
		return false
	end

	return true
end

function OpDef.repr(op, params)
	return string.format("%s(%s)", OpDef.OP_REVERSE_MAP[op] or "", inspect(params, {
		depth = 3,
		indent = " ",
		newline = " "
	}))
end

function OpDef.checkParams(op, params)
	if type(op) ~= "number" or type(params) ~= "table" then
		return false, string.format("invalid args, typeOp=%s, typeParams=%s", type(op), type(params))
	end

	if OpDef.OP_REVERSE_MAP[op] == nil then
		return false, string.format("invalid opType, op=%s", tostring(op))
	end

	for nodeName, nodeDef in pairs(OpDef.OP_PARAM_DEF[op] or EMPTY_TABLE) do
		local nodeParam = params[nodeName]
		local ret = OpDef._checkNode(nodeParam, nodeDef)

		if not ret then
			return false, string.format("invalid nodeParam, node=%s", tostring(nodeName))
		end
	end

	return true
end

return OpDef
