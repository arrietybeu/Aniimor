-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\CmdSocket\\HomeCmdImplement.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("HomeCmdImplement")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeAddonData = require("Data.home_addon_data")
local HomeObjectData = require("Data.home_object_data")
local HomeObjectPlaceData = require("Data.home_object_place_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandZoneUnlockConfigData = require("Data.homeland_zone_unlock_config_data")
local ItemData = require("Data.item_data")
local OrderLibraryData = require("Data.order_library_data")
local OrderRefreshData = require("Data.order_refresh_data")
local OrderShopDescData = require("Data.order_shop_desc_data")
local OrderShopTypeData = require("Data.order_shop_type_data")
local PetData = require("Data.pet_data")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local OpDef = require("Common.OpDef")
local HomeCmdImplement = {}
local PLACEMENT_COLLISION_THRESHOLD = 0.01
local CMD_SOCKET_VIRTUAL_ORNAMENT_ID = -900000000
local EXTRA_STATES = Const.HOMELAND_EXTRA_STATES or {}
local FACILITY_OP_TYPE = Const.HOMELAND_FACILITY_OP_TYPE or {}
local FACILITY_STATE_NAMES = {
	[0] = "IDLE",
	nil,
	nil,
	nil,
	"NO_WORKLOAD",
	"ENV_INVALID",
	[100401] = "PRODUCING",
	[5002] = "ENV_WORK",
	[100311] = "WAITING",
	[100101] = "SEEDING",
	[100411] = "WORKING",
	[100211] = "TIMER",
	[100111] = "COLLECTING",
	[5000] = "ENV_UNSUITABLE",
	[100301] = "MINING",
	[FACILITY_OP_TYPE.NONE or 0] = "IDLE",
	[FACILITY_OP_TYPE.MOVING or 1000] = "MOVING",
	[FACILITY_OP_TYPE.TRANSPORT or 1001] = "TRANSPORT",
	[FACILITY_OP_TYPE.GOTO_TRANSPORT or 1002] = "GOTO_TRANSPORT",
	[FACILITY_OP_TYPE.TRANSPORT_TO_STORE or 1003] = "TRANSPORT_TO_STORE",
	[FACILITY_OP_TYPE.WELLCOME or 1004] = "WELLCOME",
	[FACILITY_OP_TYPE.CLEAN or 5001] = "CLEAN",
	[EXTRA_STATES.UNDER_CONSUME or 2] = "UNDER_CONSUME",
	[EXTRA_STATES.OUTPUT_LIMIT or 3] = "OUTPUT_LIMIT"
}
local _ABILITY_ID_TO_NAME = {
	[1006] = "鼓风",
	[1008] = "发光",
	[1001] = "播种",
	[1004] = "发电",
	[1007] = "收割",
	[1000] = "加热",
	[1003] = "开垦",
	[1002] = "浇水",
	[1100] = "搬运",
	[1005] = "制冷",
	[1101] = "手工",
	[1102] = "陪玩",
	[1103] = "制香"
}

HomeCmdImplement.CONFIG_TABLES = {
	item_data = {
		localizeFields = {
			"itemName",
			"itemDes",
			"funcRep"
		},
		hiddenFields = {}
	},
	pet_data = {
		localizeFields = {
			"name",
			"BossShowName",
			"EliteShowName",
			"condition",
			"rules",
			"weather1",
			"clue"
		},
		hiddenFields = {}
	},
	home_object_data = {
		localizeFields = {
			"name",
			"unlockDesc"
		},
		hiddenFields = {}
	},
	home_addon_data = {
		localizeFields = {
			"name"
		},
		hiddenFields = {}
	},
	home_type_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	home_sub_type_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	home_upgrade_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	home_trash_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	home_order_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_config_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_facility_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_operate_data = {
		localizeFields = {
			"workingName",
			"workingNameWithoutEllipsis"
		},
		hiddenFields = {}
	},
	homeland_formula_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_food_item = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_material_config_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_material_shop_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	homeland_zone_unlock_config_data = {
		localizeFields = {
			"name",
			"showName",
			"desc"
		},
		hiddenFields = {}
	},
	order_library_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	order_shop_type_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	order_refresh_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	order_shop_desc_data = {
		localizeFields = {},
		hiddenFields = {}
	},
	trigger_data = {
		localizeFields = {
			"displayName",
			"desc"
		},
		hiddenFields = {}
	},
	custom_trigger_data = {
		localizeFields = {
			"displayName",
			"desc"
		},
		hiddenFields = {}
	}
}
HomeCmdImplement.CMD_META = {
	isInHomeland = {
		desc = "检测当前是否在家园场景 / 是否在自己家园（vs. 串门），并返回 spaceType / spaceId / 自家 homelandKey / 当前家园 owner",
		category = "query"
	},
	getConfigTables = {
		desc = "列出所有允许查询的配置表（白名单），含每张表预配的本地化字段",
		category = "query"
	},
	getConfig = {
		category = "query",
		params = "{table, id, localizeFields?}",
		desc = "查询白名单配置表的指定行，自动把 i18n 字段转成本地化文本"
	},
	getFacility = {
		category = "query",
		params = "{facilityId}",
		desc = "查询指定家园设施 / 杂物的完整信息：位置 / 模板 / 配方 / 工作 / 环境 / 电力链 / isTrash"
	},
	getFacilities = {
		category = "query",
		params = "{type?, containsTrash?:bool=false, trashOnly?:bool=false}",
		desc = "列出当前家园里的所有设施 / 杂物，支持 containsTrash 返回全集、trashOnly 只看杂物，每条带 isTrash 标记"
	},
	getEnvironment = {
		category = "query",
		params = "{zoneId?:int}",
		desc = "查询当前家园环境源 / 地块环境概况，数据源 pg.space.homeEnvMap"
	},
	getZoneEnvironment = {
		category = "query",
		params = "{zoneId?:int}",
		desc = "home.getEnvironment 的兼容别名；返回 base/final/currentSeason/currentWeather 等字段"
	},
	getFacilityEnvEffect = {
		category = "query",
		params = "{homeTemplateId:int}",
		desc = "按 homeTemplateId 查询设施模板提供的环境效果配置：光照 / 温度 / 电力 / 范围 / 激活宠物能力。纯配置查询，不做方案评估"
	},
	previewEnvCoverage = {
		category = "query",
		params = "{homeTemplateId:int, position:{x,y,z}, yawAngle?:num=0, targetFacilityIds?:[int]}",
		desc = "dry-run 预测：把某个环境源设施（日光灯 / 制冷机 / 热能炉 / 噼啪发电杆等）放在指定位置后，会覆盖家园里哪些 ornament。基于 envBounds + yaw 旋转的 AABB 判定，复用 HomelandEnvManager 同款算法。用来回答外部 AI 的『我要放在哪才能让目标设施拿到加成』"
	},
	getFacilityAtPosition = {
		category = "query",
		params = "{x, z, threshold?:num=2.0, containsTrash?:bool=true}",
		desc = "查询某个 (x,z) 位置附近的设施 / 杂物（XZ 距离阈值过滤，按距离排序）"
	},
	checkPlacement = {
		category = "query",
		params = "{homeTemplateId, position:{x,y,z}, yawAngle?:num=0, scale?:{x,y,z}, excludeFacilityId?}",
		desc = "dry-run 检查指定位置能否放置某种设施；使用 placeFacility 同款客户端预检和 UI 同款碰撞检测"
	},
	getZoneUnlocks = {
		desc = "家园所有地块的解锁状态 / 解锁消耗 / 解锁条件 / 增加宠物上限 / 中心点（含本地化名称）",
		category = "query"
	},
	getZoneBounds = {
		desc = "每个家园地块的几何范围（XZ 平面 center/min/max），含统一的 zoneSize；不要求在家园里",
		category = "query"
	},
	getBagPets = {
		category = "query",
		params = "{includeHomeland?:bool=false}",
		desc = "玩家宠物背包列表（默认排除已上家园；includeHomeland=true 时包含并标记 isInHomeland；每只带 homeAbility / homeAbilityList）"
	},
	getHomePets = {
		desc = "家园内宠物列表 + 当前 / 最大数量；当前数据源为默认生产区，每只带 homeAbility / homeAbilityList",
		category = "query"
	},
	getDailyOrders = {
		desc = "每日订单系统当前订单列表（含订单名 / 描述 / 所需物品 / 可提交状态 / 刷新信息）",
		category = "query"
	},
	getWarehouse = {
		desc = "家园仓库道具列表",
		category = "query"
	},
	getBagItems = {
		category = "query",
		params = "{itemIds?}",
		desc = "玩家身上道具数量；建议传 itemIds 过滤"
	},
	canPetDoOper = {
		category = "query",
		params = "{templateId, operId}",
		desc = "判断指定模板的宠物能否做指定 operate 任务，requiredAbility 带可读 abilityName"
	},
	getRequiredAbility = {
		category = "query",
		params = "{formulaId}",
		desc = "反查指定配方需要的宠物 homeAbility 和等级要求，返回 abilityName"
	},
	getCar = {
		desc = "玩家房车信息：等级 / 模型等级 / 各组件等级 / 当前营地",
		category = "query"
	},
	getFoodState = {
		desc = "家园食物状态：食物槽 / 总食物量 / 速度 / 预计耗尽时间",
		category = "query"
	},
	getFacilityFormulas = {
		category = "query",
		params = "{facilityId}",
		desc = "获取某个设施能够**主动设置**的配方列表(facilityData.formulaList,每条带 homeland_formula_data 行完整字段)。环境源副产配方(发电桩 / 灯 / 热能炉等)和电力模式配方不在这里,要查用 home.getFacilityEnvEffect。total=0 可能表示该设施没有可主动设置的配方"
	},
	checkCondition = {
		category = "query",
		params = "{conditionId}",
		desc = "检测某个 conditionId 是否完成（pg.me.triggerMap:isCompleteOrMeetCondition）"
	},
	getCmdList = {
		desc = "获取家园支持的查询 / 操作指令清单（即本 cmd）",
		category = "query"
	},
	getCurrencies = {
		desc = "查询家园基础信息：相关货币 / 凭证道具 id 列表（来自 homeland_config_data）",
		category = "query"
	},
	getFacilityMaxCount = {
		category = "query",
		params = "{homeTemplateId}",
		desc = "查询某种 homeTemplateId 设施的当前已放置数量与上限（home_object_data.maxNum）"
	},
	setFormula = {
		async = true,
		category = "action",
		params = "{facilityId, formulaId}",
		desc = "设置设施配方"
	},
	removeFormula = {
		async = true,
		category = "action",
		params = "{facilityId, formulaId}",
		desc = "取消设施当前配方"
	},
	setFacilityPause = {
		async = true,
		category = "action",
		params = "{facilityId, paused:bool}",
		desc = "暂停 / 取消暂停某个设施的工作（底层是 setProduceDisable）"
	},
	setFacilityElectricMode = {
		async = true,
		category = "action",
		params = "{facilityId, enable:bool}",
		desc = "启用 / 禁用设施的电力模式（pg.me.space:setProduceElectricMode）"
	},
	placeFacility = {
		async = true,
		category = "action",
		params = "{homeTemplateId, position:{x,y,z}, yawAngle?:num=0, scale?:{x,y,z}={1,1,1}}",
		desc = "在家园摆放一件家具 / 设施（addOrnament，自带数量与位置基础校验）"
	},
	moveFacility = {
		async = true,
		category = "action",
		params = "{facilityId, position:{x,y,z}, yawAngle?:num, scale?:{x,y,z}}",
		desc = "移动家园里已存在的设施 / 家具到新位置（updateOrnament，自带位置校验，自身从碰撞中排除）"
	},
	recycleFacility = {
		async = true,
		category = "action",
		params = "{facilityId}",
		desc = "回收家园里的设施 / 家具（removeOrnament）"
	},
	placePet = {
		async = true,
		category = "action",
		params = "{petId}",
		desc = "把宠物从玩家宠物背包放入家园（addHomelandPetBatch），派发前预检出战 / 探索 / 已在家园状态"
	},
	placeHomePets = {
		async = true,
		category = "action",
		params = "{count?:int, petIds?:string[]}",
		desc = "批量把可用宠物放入家园；跳过出战、探索、已在家园宠物，并按家园宠物容量截断"
	},
	recallPet = {
		async = true,
		category = "action",
		params = "{petId}",
		desc = "把宠物从家园收回到玩家宠物背包（removeHomelandPetBatch）"
	},
	recallAllPets = {
		async = true,
		category = "action",
		params = "{petIds?:string[]}",
		desc = "批量把家园内宠物收回玩家背包（removeHomelandPetBatch）"
	},
	assignPetWork = {
		async = true,
		category = "action",
		params = "{petId, facilityId, force?:bool=false}",
		desc = "分配宠物到设施工作（派发 MOVING，让宠物先移动过去）"
	},
	assignPetTransport = {
		async = true,
		category = "action",
		params = "{petId, facilityId}",
		desc = "分配宠物到设施搬运（派发 GOTO_TRANSPORT）"
	},
	unassignPetWork = {
		async = true,
		category = "action",
		params = "{petId}",
		desc = "解除宠物当前设施上的工作；通常会触发服务端再分配"
	},
	callPetWork = {
		async = true,
		category = "action",
		params = "{facilityId}",
		desc = "自动召唤一只合适的宠物到设施工作（按 workload 挑选，派发 MOVING）"
	},
	submitDailyOrder = {
		async = true,
		category = "action",
		params = "{serverIndex?|orderId?|orderName?}",
		desc = "提交一个每日订单；支持 serverIndex / orderId / orderName 定位"
	},
	refreshDailyOrder = {
		async = true,
		category = "action",
		params = "{serverIndex?|orderId?|orderName?}",
		desc = "免费刷新一个每日订单；支持 serverIndex / orderId / orderName 定位"
	},
	payRefreshDailyOrder = {
		async = true,
		category = "action",
		params = "{serverIndex?|orderId?|orderName?}",
		desc = "付费刷新一个每日订单；支持 serverIndex / orderId / orderName 定位"
	},
	upgradeFacility = {
		async = true,
		category = "action",
		params = "{facilityId, upgradeHomeTemplateId?}",
		desc = "升级指定家园设施；仅允许不消耗家园币的材料升级，消耗家园币时返回阻塞"
	},
	curePetAbnormal = {
		async = true,
		category = "action",
		params = "{petId}",
		desc = "消除宠物的异常状态（占位，未实现 —— 当前返回 not_implemented）"
	}
}
HomeCmdImplement.CMD_META.getRuntimeSnapshot = {
	category = "query",
	params = "{includeOrders?:bool=true, includeFood?:bool=true}",
	desc = "一次性获取常用的家园运行时聚合快照：设施、宠物、仓库、订单、食物。减少外部 AI 反复搜表的往返开销。"
}
HomeCmdImplement.CMD_META.getLastOrnamentResult = {
	category = "query",
	params = "{sinceSeq?:int=0}",
	desc = "拉取最近 N 条家园 ornament RPC 真实回执(addOrnament / addOrnaments / removeOrnament / removeOrnaments / updateOrnament)。修复 placeFacility / placeOrnamentBatch / recycleFacility 等异步操作的『假成功』问题:服务端 RPC 回包(成功 / ERROR_ORNAMENT_COUNT_MAX 等)以前只弹气泡,现在通过这个 cmd 暴露给外部 AI。派发响应里带 callbackSinceSeq;1~2s 后用该 sinceSeq 调本 cmd 拿到 seq 大于它的新结果。"
}
HomeCmdImplement.CMD_META.findPlacementPoint = {
	category = "query",
	params = "{zoneId:int, homeTemplateId:int}",
	desc = "在指定地块内搜索一个不与现有 ornament 碰撞的放置点。先尝试地块中心，再按碰撞阈值螺旋扩展。"
}
HomeCmdImplement.CMD_META.queryDecorItems = {
	category = "query",
	params = "{entType?:int, subEntType?:int, ownedOnly?:bool=false}",
	desc = "过滤 home_object_data 查家具 / 装饰 / 积木道具。按 entType / subEntType 过滤；ownedOnly=true 时叠加玩家背包持有数。"
}
HomeCmdImplement.CMD_META.resolveName = {
	category = "query",
	params = "{name:string, type?:\"item\"|\"facility\"|\"pet\"|\"any\", limit?:int=8}",
	desc = "按中文名反查 item/facility/pet 的 id。item 会用 home_object_place_data 中文名兜底；纯配置查询,不带规划/打分。"
}
HomeCmdImplement.CMD_META.findFormulasByOutput = {
	category = "query",
	params = "{itemId:int}",
	desc = "按产出物 itemId 反查所有产出该物品的配方,并附上支持这些配方的设施模板。纯配置查询。"
}
HomeCmdImplement.CMD_META.upgradeCar = {
	async = true,
	category = "action",
	params = "{compId?:int}",
	desc = "升级家园房车。不传 compId 升级整车；传 compId 升级指定组件。底层走 pg.me:requestHomeCampOp。"
}
HomeCmdImplement.CMD_META.placeOrnamentBatch = {
	async = true,
	category = "action",
	params = "{items:[{homeTemplateId:int,position:{x,y,z},yawAngle?:num=0,scale?:{x,y,z}}]}",
	desc = "批量放置家具 / 设施。每件单独走 placeFacility 同款预检（模板、数量上限、背包拥有量、地块、碰撞）；任意一件失败则整批拒绝。"
}
HomeCmdImplement.CMD_META.moveOrnamentBatch = {
	async = true,
	category = "action",
	params = "{items:[{facilityId:int,position:{x,y,z},yawAngle?:num,scale?:{x,y,z}}]}",
	desc = "批量移动现有家具。每件单独走 moveFacility 同款预检；任意一件失败则整批拒绝。"
}
HomeCmdImplement.CMD_META.recycleOrnamentBatch = {
	async = true,
	category = "action",
	params = "{facilityIds:int[]}",
	desc = "批量回收家具。每件单独走 checkHomelandRemoveOrnament 预检；任意一件失败则整批拒绝。**不可逆**，外部 AI 调用前应让玩家明确授权。"
}

function HomeCmdImplement._err(code, msg)
	return {
		ok = false,
		error = {
			code = code,
			msg = msg
		}
	}
end

function HomeCmdImplement._ok(data)
	return {
		ok = true,
		data = data or {}
	}
end

function HomeCmdImplement._asyncOk(extra)
	local data = {
		dispatched = true,
		async = true
	}

	if extra then
		for k, v in pairs(extra) do
			data[k] = v
		end
	end

	return {
		ok = true,
		data = data
	}
end

function HomeCmdImplement._requireHomeland()
	if not pg.me or not pg.me.space then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player space")
	end

	if not pg.me.space.isHomeland or not pg.me.space:isHomeland() then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "not in homeland")
	end

	return nil
end

function HomeCmdImplement._isAddOrnamentLocked()
	local space = pg and pg.me and pg.me.space or nil

	if not space then
		return false
	end

	return space._isAddOrnamentRequesting == true
end

local ORNAMENT_RESULT_RING_SIZE = 16
local ORNAMENT_RETURN_CODE_NAMES = {
	[0] = "SUCCESS",
	"ERROR_CHECK_FAIL",
	"ERROR_NOT_HOME",
	"ERROR_PARAM",
	"ERROR_ORNAMENT_NOT_EXIST",
	"ERROR_ITEM_NOT_VALID",
	"ERROR_ORNAMENT_COUNT_MAX",
	"ERROR_NOT_EDITABLE",
	"ERROR_NOT_TRASH",
	"ERROR_ITEM_NOT_ENOUGH",
	"ERROR_MONEY_NOT_VALID",
	"ERROR_MONEY_NOT_ENOUGH",
	"ERROR_ORNAMENT_CANT_UPGRADE",
	"ERROR_ORNAMENT_BUY_COUNT_MAX",
	"ERROR_ORNAMENT_BUY_BAG_FULL",
	"ERROR_NOT_HOME_CAR",
	"ERROR_NOT_FIND_CAR",
	"ERROR_HOMECAR_ORNAMENT_COUNT_MAX"
}

function HomeCmdImplement._getOrnamentResultRing()
	local ring = rawget(HomeCmdImplement, "_ornamentResultRing")

	if not ring then
		ring = {
			head = 0,
			size = 0,
			seq = 0,
			items = {}
		}

		rawset(HomeCmdImplement, "_ornamentResultRing", ring)
	end

	return ring
end

function HomeCmdImplement._pushOrnamentResult(op, code, ornamentId, homeId)
	local ring = HomeCmdImplement._getOrnamentResultRing()

	ring.seq = ring.seq + 1
	ring.head = ring.head % ORNAMENT_RESULT_RING_SIZE + 1
	ring.items[ring.head] = {
		seq = ring.seq,
		op = op,
		code = code,
		codeName = ORNAMENT_RETURN_CODE_NAMES[code] or "UNKNOWN_" .. tostring(code),
		ok = code == 0,
		ornamentId = ornamentId,
		homeTemplateId = homeId,
		ts = os.time()
	}

	if ring.size < ORNAMENT_RESULT_RING_SIZE then
		ring.size = ring.size + 1
	end
end

function HomeCmdImplement._collectOrnamentResults(sinceSeq)
	local ring = HomeCmdImplement._getOrnamentResultRing()

	sinceSeq = tonumber(sinceSeq) or 0

	local out = {}

	for i = 1, ring.size do
		local idx = (ring.head - i) % ORNAMENT_RESULT_RING_SIZE + 1
		local item = ring.items[idx]

		if item and sinceSeq < item.seq then
			out[#out + 1] = item
		end
	end

	local rev = {}

	for i = #out, 1, -1 do
		rev[#rev + 1] = out[i]
	end

	return rev, ring.seq
end

function HomeCmdImplement._isTableLike(v)
	local t = type(v)

	return t == "table" or t == "userdata"
end

function HomeCmdImplement._patchOrnamentCallback(component, methodName, op)
	if not HomeCmdImplement._isTableLike(component) then
		return false
	end

	local flagKey = "_cmdSocketPatched_" .. methodName

	if rawget(component, flagKey) then
		return true
	end

	local orig = component[methodName]

	if type(orig) ~= "function" then
		return false
	end

	rawset(component, methodName, function(self, code, ornamentId, homeId)
		local ok, err = pcall(function()
			HomeCmdImplement._pushOrnamentResult(op, code, ornamentId, homeId)
		end)

		if not ok then
			logger:error("ornament-callback echo failed: " .. tostring(err))
		end

		return orig(self, code, ornamentId, homeId)
	end)
	rawset(component, flagKey, true)

	return true
end

function HomeCmdImplement._ensureOrnamentCallbackHooks()
	local space = pg and pg.me and pg.me.space or nil

	if not space then
		return
	end

	HomeCmdImplement._patchOrnamentCallback(space, "onAddOrnamentCallback", "add")
	HomeCmdImplement._patchOrnamentCallback(space, "onAddOrnamentsCallback", "adds")
	HomeCmdImplement._patchOrnamentCallback(space, "onRemoveOrnamentCallback", "remove")
	HomeCmdImplement._patchOrnamentCallback(space, "onRemoveOrnamentsCallback", "removes")
	HomeCmdImplement._patchOrnamentCallback(space, "onUpdateOrnamentCallback", "update")
end

function HomeCmdImplement._vec3(v)
	if v == nil then
		return nil
	end

	local ok, x = pcall(function()
		return v.x
	end)

	if not ok or x == nil then
		return nil
	end

	return {
		x = v.x,
		y = v.y,
		z = v.z
	}
end

function HomeCmdImplement._localize(id)
	if id == nil then
		return nil
	end

	if type(id) ~= "number" then
		return id
	end

	local ok, txt = pcall(function()
		return pgI18N.LocalizationText.GetFinalTextNoParam(id)
	end)

	if ok and type(txt) == "string" and #txt > 0 then
		return txt
	end

	return id
end

function HomeCmdImplement._applyLocalize(row, fieldNames)
	if type(fieldNames) ~= "table" or #fieldNames == 0 then
		return row
	end

	local copy = {}

	for k, v in pairs(row) do
		copy[k] = v
	end

	for _, name in ipairs(fieldNames) do
		if copy[name] ~= nil then
			copy[name] = HomeCmdImplement._localize(copy[name])
		end
	end

	return copy
end

function HomeCmdImplement._applyHiddenFields(row, fieldNames)
	if type(fieldNames) ~= "table" or #fieldNames == 0 then
		return row
	end

	local copy = {}

	for k, v in pairs(row) do
		copy[k] = v
	end

	for _, name in ipairs(fieldNames) do
		copy[name] = nil
	end

	return copy
end

function HomeCmdImplement._applyWhiteList(row, fieldNames)
	local allow = {}

	if type(fieldNames) == "table" then
		for _, name in ipairs(fieldNames) do
			allow[name] = true
		end
	end

	local copy = {}

	for k, v in pairs(row) do
		if allow[k] then
			copy[k] = v
		end
	end

	return copy
end

function HomeCmdImplement._safeCall(fn, ...)
	local ok, ret = pcall(fn, ...)

	if not ok then
		return nil, ret
	end

	return ret, nil
end

function HomeCmdImplement._getRuntimeSpace()
	if pg and pg.me and pg.me.space then
		return pg.me.space
	end

	return pg and pg.space or nil
end

function HomeCmdImplement._getRuntimeMapValue(mapName, key)
	local space = HomeCmdImplement._getRuntimeSpace()

	if space and space[mapName] and space[mapName][key] ~= nil then
		return space[mapName][key], space, "pg.me.space." .. mapName
	end

	if pg and pg.space and pg.space[mapName] and pg.space[mapName][key] ~= nil then
		return pg.space[mapName][key], pg.space, "pg.space." .. mapName
	end

	return nil, space, nil
end

function HomeCmdImplement._getHomeOrderRawList()
	if not pg.me or not pg.me.showList then
		return {}
	end

	local raw

	if pg.me.showList.getRawTable then
		raw = HomeCmdImplement._safeCall(function()
			return pg.me.showList:getRawTable()
		end)
	end

	raw = raw or pg.me.showList

	return raw or {}
end

function HomeCmdImplement._getHomeOrderNeedItemData(orderCfg)
	local result = {}
	local countMap = {}
	local sortList = {}

	for _, key in ipairs({
		"unlockItem1",
		"unlockItem2",
		"unlockItem3"
	}) do
		local itemData = orderCfg and orderCfg[key] or nil

		if itemData and itemData[1] and itemData[2] then
			sortList[#sortList + 1] = {
				itemData[1],
				itemData[2]
			}
		end
	end

	for _, itemData in ipairs(sortList) do
		local itemId = itemData[1]
		local itemNum = itemData[2]

		countMap[itemId] = (countMap[itemId] or 0) + itemNum
	end

	for _, itemData in ipairs(sortList) do
		local itemId = itemData[1]
		local itemNum = countMap[itemId]

		if itemNum and itemNum > 0 then
			result[#result + 1] = {
				itemId,
				itemNum
			}
			countMap[itemId] = -1
		end
	end

	return result
end

function HomeCmdImplement._getHomeOrderRewardData(orderCfg)
	local result = {}

	for _, key in ipairs({
		"reward1",
		"reward2",
		"reward3"
	}) do
		local rewardId = orderCfg and orderCfg[key] or nil

		if rewardId then
			result[#result + 1] = {
				dropId = rewardId
			}
		end
	end

	return result
end

function HomeCmdImplement._getHomeOrderItemCount(itemId)
	if not itemId or not pg.me then
		return 0, 0, 0
	end

	local bagCount = HomeCmdImplement._safeCall(function()
		return pg.me:getItemCountById(itemId, false)
	end) or 0
	local warehouseCount = 0

	if pg.me.space and pg.me.space.itemMap then
		warehouseCount = pg.me.space.itemMap[itemId] or 0
	end

	return bagCount + warehouseCount, bagCount, warehouseCount
end

function HomeCmdImplement._getHomeOrderRefreshLevelCfg()
	local homeLevel = pg.me and pg.me.homeBasicInfo and pg.me.homeBasicInfo.level or nil

	if not homeLevel then
		return nil
	end

	return OrderRefreshData[homeLevel]
end

function HomeCmdImplement._getHomeOrderPayRefreshCost()
	local payRefreshCost = HomelandConfigData.homeOrderRefreshCost or {}
	local payCost = HomelandConfigData.homeOrderRefreshMaxCost or 0
	local levelCfg = HomeCmdImplement._getHomeOrderRefreshLevelCfg() or {}
	local freeRefreshTotal = levelCfg.freeRefresh or 0
	local refreshUsedCount = pg.me and pg.me.orderRefreshCount or 0
	local count = refreshUsedCount - freeRefreshTotal + 1

	for _, data in ipairs(payRefreshCost) do
		if count < data[1] then
			payCost = data[2]

			break
		end
	end

	return payCost
end

function HomeCmdImplement._normalizeCmdText(value)
	if value == nil then
		return nil
	end

	return string.lower(tostring(value))
end

function HomeCmdImplement._matchCmdText(source, keyword)
	local left = HomeCmdImplement._normalizeCmdText(source)
	local right = HomeCmdImplement._normalizeCmdText(keyword)

	if not left or not right or right == "" then
		return false
	end

	return string.find(left, right, 1, true) ~= nil
end

function HomeCmdImplement._serializeDailyOrder(rawOrder, serverIndex)
	local orderId = rawOrder and rawOrder.orderId or nil
	local orderCfg = orderId and OrderLibraryData[orderId] or nil
	local shopTypeCfg = orderCfg and OrderShopTypeData[orderCfg.shopType] or nil
	local shopDescCfg = rawOrder and rawOrder.desId and OrderShopDescData[rawOrder.desId] or nil
	local title = HomeCmdImplement._localize(shopTypeCfg and shopTypeCfg.name or nil)
	local desc = HomeCmdImplement._localize(shopDescCfg and shopDescCfg.levelDes or nil)
	local orderQuality = rawOrder and rawOrder.orderQuality or orderCfg and orderCfg.orderQuality or nil
	local state = rawOrder and rawOrder.orderStatus or nil
	local needItems = {}
	local missingItems = {}
	local canSubmit = true

	for _, itemData in ipairs(HomeCmdImplement._getHomeOrderNeedItemData(orderCfg)) do
		local itemId = itemData[1]
		local needCount = itemData[2]
		local totalCount, bagCount, warehouseCount = HomeCmdImplement._getHomeOrderItemCount(itemId)
		local itemRow = ItemData[itemId] or {}
		local enough = needCount <= totalCount

		if not enough then
			canSubmit = false
			missingItems[#missingItems + 1] = {
				itemId = itemId,
				itemName = HomeCmdImplement._localize(itemRow.itemName),
				needCount = needCount,
				totalCount = totalCount,
				lackCount = needCount - totalCount
			}
		end

		needItems[#needItems + 1] = {
			itemId = itemId,
			itemName = HomeCmdImplement._localize(itemRow.itemName),
			needCount = needCount,
			totalCount = totalCount,
			bagCount = bagCount,
			warehouseCount = warehouseCount,
			enough = enough
		}
	end

	if state ~= HomeOrderConst.STATUS.Incomplete then
		canSubmit = false
	end

	return {
		serverIndex = serverIndex,
		orderId = orderId,
		orderStatus = state,
		orderStatusName = state == HomeOrderConst.STATUS.Incomplete and "Incomplete" or "Finish",
		orderType = rawOrder and rawOrder.orderType or nil,
		isUrgent = rawOrder and rawOrder.orderType == HomeOrderConst.TYPE.HighPriority or false,
		rewardRate = rawOrder and rawOrder.rewardRate or nil,
		desId = rawOrder and rawOrder.desId or nil,
		orderQuality = orderQuality,
		shopType = orderCfg and orderCfg.shopType or nil,
		title = title,
		orderName = title,
		displayName = title,
		desc = desc,
		needItems = needItems,
		rewardData = HomeCmdImplement._getHomeOrderRewardData(orderCfg),
		canSubmit = canSubmit,
		missingItems = missingItems,
		template = HomeCmdImplement._cloneForCmd(orderCfg)
	}
end

function HomeCmdImplement._collectDailyOrders()
	local raw = HomeCmdImplement._getHomeOrderRawList()
	local orders = {}

	for key, value in pairs(raw) do
		if type(key) == "number" and type(value) == "table" and value.orderId then
			orders[#orders + 1] = HomeCmdImplement._serializeDailyOrder(value, key)
		end
	end

	table.sort(orders, function(a, b)
		return (a.serverIndex or 0) < (b.serverIndex or 0)
	end)

	return orders
end

function HomeCmdImplement._resolveDailyOrder(params)
	local orders = HomeCmdImplement._collectDailyOrders()
	local serverIndex = params and params.serverIndex or nil
	local orderId = params and params.orderId or nil
	local orderName = params and params.orderName or nil

	if serverIndex ~= nil then
		for _, order in ipairs(orders) do
			if order.serverIndex == serverIndex then
				return order, nil
			end
		end

		return nil, "daily order not found by serverIndex: " .. tostring(serverIndex)
	end

	if orderId ~= nil then
		for _, order in ipairs(orders) do
			if order.orderId == orderId then
				return order, nil
			end
		end

		return nil, "daily order not found by orderId: " .. tostring(orderId)
	end

	if orderName ~= nil and tostring(orderName) ~= "" then
		local exactMatches = {}
		local fuzzyMatches = {}

		for _, order in ipairs(orders) do
			if order.orderName == orderName or order.displayName == orderName then
				exactMatches[#exactMatches + 1] = order
			elseif HomeCmdImplement._matchCmdText(order.orderName, orderName) or HomeCmdImplement._matchCmdText(order.displayName, orderName) or HomeCmdImplement._matchCmdText(order.desc, orderName) then
				fuzzyMatches[#fuzzyMatches + 1] = order
			end
		end

		local matches = #exactMatches > 0 and exactMatches or fuzzyMatches

		if #matches == 1 then
			return matches[1], nil
		end

		if #matches > 1 then
			local candidates = {}

			for _, order in ipairs(matches) do
				candidates[#candidates + 1] = string.format("serverIndex=%s orderId=%s orderName=%s", tostring(order.serverIndex), tostring(order.orderId), tostring(order.orderName))
			end

			return nil, "multiple daily orders matched orderName: " .. tostring(orderName) .. " -> " .. table.concat(candidates, "; ")
		end

		return nil, "daily order not found by orderName: " .. tostring(orderName)
	end

	return nil, "missing daily order selector: serverIndex/orderId/orderName"
end

function HomeCmdImplement._serializeFacility(ornamentId)
	local ornamentInfo = HomeCmdImplement._getRuntimeMapValue("ornament", ornamentId)
	local facilityInfo = HomeCmdImplement._getRuntimeMapValue("facility", ornamentId)

	if not ornamentInfo and not facilityInfo then
		return nil
	end

	local out = {
		ornamentId = ornamentId
	}

	if ornamentInfo then
		out.homeId = ornamentInfo.homeId

		local pos = HomeCmdImplement._safeCall(function()
			return ornamentInfo:getPosition()
		end)

		if pos then
			out.position = HomeCmdImplement._vec3(pos)
		end

		local yaw = HomeCmdImplement._safeCall(function()
			return ornamentInfo:getYawAngle()
		end)

		if yaw ~= nil then
			out.yawAngle = yaw
		end

		out.electricMode = ornamentInfo.electricMode

		local trashId = ornamentInfo.trashId

		if trashId and trashId ~= 0 then
			out.isTrash = true
			out.trashId = trashId
		else
			out.isTrash = false
		end
	end

	if facilityInfo then
		out.formulaId = facilityInfo.formulaId
		out.disable = facilityInfo.disable and true or false
		out.facilityState = facilityInfo.facilityState
		out.facilityStateName = HomeCmdImplement._getFacilityStateName(out.facilityState)

		if facilityInfo.outputMap then
			local outputs = {}

			for itemId, count in pairs(facilityInfo.outputMap) do
				outputs[#outputs + 1] = {
					itemId = itemId,
					count = count
				}
			end

			out.outputs = outputs
		end
	end

	if out.homeId then
		out.requiredAbility = HomeCmdImplement._getFacilityRequiredAbility(out.homeId, facilityInfo)
	end

	local envInfo, envSpace, envSource = HomeCmdImplement._getRuntimeMapValue("ornamentEnvMap", ornamentId)
	local homeEnvInfo, _, homeEnvSource = HomeCmdImplement._getRuntimeMapValue("homeEnvMap", ornamentId)

	if envInfo or homeEnvInfo then
		local envSuitable, unmetRequirements = HomeCmdImplement._buildEnvSuitability(ornamentId, facilityInfo, envInfo)
		local base, bonus, final = {}, {}, {}

		HomeCmdImplement._putEnvAxis(base, bonus, final, "light", envInfo)
		HomeCmdImplement._putEnvAxis(base, bonus, final, "temperature", envInfo)
		HomeCmdImplement._putEnvAxis(base, bonus, final, "humidity", envInfo)

		out.env = {
			temperature = final.temperature,
			light = final.light,
			humidity = final.humidity,
			envProduce = homeEnvInfo and homeEnvInfo.envProduce or nil,
			electricCost = envInfo and envInfo.electricCost or nil,
			currentEnvFactor = envInfo and envInfo.currentEnvFactor or nil,
			totalTimeReductionRate = envInfo and envInfo.totalTimeReductionRate or nil,
			totalFixedReduction = envInfo and envInfo.totalFixedReduction or nil,
			envWorkRatio = facilityInfo and facilityInfo.envWorkRatio or nil,
			baseEnvWorkRatio = facilityInfo and facilityInfo.baseEnvWorkRatio or nil,
			refEnvFacilityIds = HomeCmdImplement._mapKeysToSortedList(envInfo and envInfo.refEnvFacilityInfo or nil),
			base = HomeCmdImplement._nilIfEmptyMap(base),
			bonus = HomeCmdImplement._nilIfEmptyMap(bonus),
			final = HomeCmdImplement._nilIfEmptyMap(final),
			source = envSource or homeEnvSource
		}

		local contributors = HomeCmdImplement._buildEnvContributors(ornamentId, envInfo, envSpace)

		if #contributors > 0 then
			out.env.contributors = contributors
		end

		out.env.envSuitable = envSuitable == nil and true or envSuitable
		out.env.unmetRequirements = unmetRequirements or {}
	end

	if pg.space and pg.space.homeLinkMap and pg.space.homeLinkGroupMap then
		local groupId = pg.space.homeLinkMap[ornamentId]

		if groupId then
			local groupInfo = pg.space.homeLinkGroupMap[groupId]

			if groupInfo then
				out.linkGroup = {
					groupId = groupId,
					totalProduce = groupInfo.totalProduce,
					totalCost = groupInfo.totalCost
				}
			end
		end
	end

	return out
end

function HomeCmdImplement._serializePet(pet)
	if pet == nil then
		return nil
	end

	local templateId = pet.templateId
	local homeAbility = pet.homeAbility

	if type(homeAbility) ~= "table" and templateId ~= nil then
		local cfg = PetData[templateId]

		homeAbility = cfg and cfg.homeAbility or nil
	end

	return {
		id = pet.id,
		templateId = templateId,
		name = pet.name,
		level = pet.level,
		bornScale = pet.bornScale,
		label = pet.label,
		totalExp = pet.totalExp,
		homeAbility = HomeCmdImplement._cloneForCmd(homeAbility),
		homeAbilityList = HomeCmdImplement._buildHomeAbilityList(homeAbility)
	}
end

function HomeCmdImplement._getHomeSpace()
	return HomeCmdImplement._getRuntimeSpace()
end

function HomeCmdImplement._getHomePetBox()
	local space = pg and pg.space or nil
	local petBox = space and space.petBoxMap and space.petBoxMap[Const.HOMELAND_AREA_TYPE.PRODUCE] or nil

	if petBox then
		return petBox
	end

	local meSpace = pg and pg.me and pg.me.space or nil

	return meSpace and meSpace.petBoxMap and meSpace.petBoxMap[Const.HOMELAND_AREA_TYPE.PRODUCE] or nil
end

function HomeCmdImplement._collectHomePetIds(filterPetIds)
	local allowSet

	if type(filterPetIds) == "table" then
		allowSet = {}

		for _, petId in pairs(filterPetIds) do
			if petId ~= nil then
				allowSet[tostring(petId)] = true
			end
		end
	end

	local seen = {}
	local petIds = {}

	local function addPetId(petId)
		if petId == nil or petId == 0 or petId == "" then
			return
		end

		local key = tostring(petId)

		if allowSet and not allowSet[key] then
			return
		end

		if seen[key] then
			return
		end

		seen[key] = true
		petIds[#petIds + 1] = petId
	end

	local space = HomeCmdImplement._getHomeSpace()
	local petBoxMap = space and space.petBoxMap

	if petBoxMap then
		local slotCount = petBoxMap:getSlotCount()

		for idx = 1, slotCount do
			addPetId(petBoxMap:getPetId(Const.HOMELAND_AREA_TYPE.PRODUCE, idx))
		end
	end

	if space and space.pets then
		for petId in pairs(space.pets) do
			addPetId(petId)
		end
	end

	if space and space.allocation then
		for petId in pairs(space.allocation) do
			addPetId(petId)
		end
	end

	table.sort(petIds, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return petIds
end

function HomeCmdImplement._getPetMapValue(map, petId)
	if not map or petId == nil then
		return nil
	end

	local value = map[petId]

	if value ~= nil then
		return value
	end

	value = map[tostring(petId)]

	if value ~= nil then
		return value
	end

	local numId = tonumber(petId)

	if numId ~= nil then
		return map[numId]
	end

	return nil
end

function HomeCmdImplement._getPetInfoById(petId)
	local petInfo

	if pg.me and type(pg.me.getPetInfo) == "function" then
		petInfo = HomeCmdImplement._safeCall(function()
			return pg.me:getPetInfo(petId)
		end)
	end

	if not petInfo and pg.me and pg.me.pets then
		petInfo = HomeCmdImplement._getPetMapValue(pg.me.pets, petId)
	end

	return petInfo
end

function HomeCmdImplement._buildHomePetEntry(petId, slotIdx)
	local petInfo = HomeCmdImplement._getPetInfoById(petId)
	local entry = HomeCmdImplement._serializePet(petInfo) or {
		id = petId
	}

	if entry.id == nil then
		entry.id = petId
	end

	entry.slotIdx = slotIdx
	entry.isInHomeland = true

	local space = HomeCmdImplement._getHomeSpace()
	local alloc = HomeCmdImplement._getPetMapValue(space and space.allocation, petId)

	if alloc then
		entry.ornamentId = alloc.ornamentId
		entry.opId = alloc.opId
		entry.workload = alloc.workload
		entry.fitPersonality = alloc.fitTalent
	end

	entry.isIdle = not alloc or not alloc.ornamentId or alloc.ornamentId == 0 or alloc.opId == 0

	local petEnt = HomeCmdImplement._getPetMapValue(space and space.pets, petId)

	if petEnt then
		if not entry.templateId and petEnt.templateId then
			entry.templateId = petEnt.templateId
		end

		if petEnt.checkAIHomeWorkState then
			local stateOk = HomeCmdImplement._safeCall(function()
				return petEnt:checkAIHomeWorkState()
			end)

			if stateOk ~= nil then
				entry.workStateOk = stateOk and true or false
			end
		end
	end

	if alloc and alloc.ornamentId then
		local facilityInfo = HomeCmdImplement._getPetMapValue(space and space.facility, alloc.ornamentId)

		if facilityInfo and alloc.opId and alloc.opId ~= 0 and facilityInfo.facilityState == alloc.opId then
			local operateData = HomelandOperateData[alloc.opId]

			if operateData then
				entry.inFacility = true
				entry.opUrl = operateData.workingIcon

				local operateName = HomeCmdImplement._localize(operateData.workingNameWithoutEllipsis or operateData.workingName)

				if operateName ~= nil then
					entry.opName = tostring(operateName)
				end
			end
		end
	end

	return entry
end

function HomeCmdImplement._countFacilityByHomeId(homeTemplateId)
	local c = 0

	if pg.space and pg.space.ornament then
		for _, info in pairs(pg.space.ornament) do
			if info.homeId == homeTemplateId then
				c = c + 1
			end
		end
	end

	return c
end

function HomeCmdImplement._getFacilityMaxNum(homeTemplateId)
	local row = HomeObjectData[homeTemplateId]

	if not row then
		return nil
	end

	return row.maxNum
end

function HomeCmdImplement._toXYZArray(t, default)
	if type(t) ~= "table" then
		return default
	end

	local x = type(t.x) == "number" and t.x or type(t[1]) == "number" and t[1] or nil
	local y = type(t.y) == "number" and t.y or type(t[2]) == "number" and t[2] or nil
	local z = type(t.z) == "number" and t.z or type(t[3]) == "number" and t[3] or nil

	if x == nil or y == nil or z == nil then
		return nil
	end

	return {
		x,
		y,
		z
	}
end

function HomeCmdImplement._makeYawQuaternion(yawDeg)
	yawDeg = yawDeg or 0

	local Q = CS and CS.UnityEngine and CS.UnityEngine.Quaternion

	if not Q or not Q.Euler then
		return nil
	end

	return Q.Euler(0, yawDeg, 0)
end

function HomeCmdImplement._isInUnlockedZone(qx, qz)
	local halfW = (Const.HomelandZoneWidth or 0) * 0.5
	local halfH = (Const.HomelandZoneHeight or 0) * 0.5

	if halfW <= 0 or halfH <= 0 then
		return true
	end

	local unlockMap = pg.space and pg.space.unlockZone

	for zoneId, zoneCfg in pairs(HomelandZoneUnlockConfigData) do
		if zoneCfg.prefabPos and (not unlockMap or unlockMap[zoneId]) then
			local cx, cz = zoneCfg.prefabPos[1], zoneCfg.prefabPos[2]

			if qx >= cx - halfW and qx <= cx + halfW and qz >= cz - halfH and qz <= cz + halfH then
				return true
			end
		end
	end

	return false
end

function HomeCmdImplement._nextVirtualPlacementId()
	CMD_SOCKET_VIRTUAL_ORNAMENT_ID = CMD_SOCKET_VIRTUAL_ORNAMENT_ID - 1

	return CMD_SOCKET_VIRTUAL_ORNAMENT_ID
end

function HomeCmdImplement._positionObjectFromArray(pos)
	if not pos then
		return nil
	end

	return {
		x = pos[1],
		y = pos[2] or 0,
		z = pos[3]
	}
end

function HomeCmdImplement._positionDataFromArray(pos)
	if not pos then
		return nil
	end

	return {
		x = pos[1],
		y = pos[2] or 0,
		z = pos[3]
	}
end

function HomeCmdImplement._scaleArrayFromAny(scale, default)
	default = default or {
		1,
		1,
		1
	}

	if scale == nil then
		return {
			default[1],
			default[2],
			default[3]
		}
	end

	local sx, sy, sz

	if type(scale) == "table" then
		sx = type(scale.x) == "number" and scale.x or type(scale[1]) == "number" and scale[1] or nil
		sy = type(scale.y) == "number" and scale.y or type(scale[2]) == "number" and scale[2] or nil
		sz = type(scale.z) == "number" and scale.z or type(scale[3]) == "number" and scale[3] or nil
	else
		sx = HomeCmdImplement._safeCall(function()
			return scale.x
		end)
		sy = HomeCmdImplement._safeCall(function()
			return scale.y
		end)
		sz = HomeCmdImplement._safeCall(function()
			return scale.z
		end)
	end

	if type(sx) ~= "number" or type(sy) ~= "number" or type(sz) ~= "number" then
		return nil
	end

	return {
		sx,
		sy,
		sz
	}
end

function HomeCmdImplement._getPlacementLayer(homeTemplateId)
	local configData = HomeObjectData[homeTemplateId] or {}
	local layers = Const.HOMELAND_ORNAMENT_LAYER or {}

	if configData.canEditYAxis or configData.overlapAllowed then
		return layers.None or 0
	end

	return layers.Default or 1
end

function HomeCmdImplement._getPlacementBoundSize(homeTemplateId, scale)
	local configData = HomeObjectData[homeTemplateId] or {}
	local boundSize = configData.boundSize or {
		1,
		1
	}
	local scaleArr = HomeCmdImplement._scaleArrayFromAny(scale, {
		1,
		1,
		1
	}) or {
		1,
		1,
		1
	}

	return {
		(boundSize[1] or 1) * (scaleArr[1] or 1),
		(boundSize[2] or 1) * (scaleArr[3] or 1)
	}
end

function HomeCmdImplement._buildPlacementGeometry(homeTemplateId, pos, rotation, scale)
	if not HomeObjectData[homeTemplateId] or not pos or not rotation then
		return nil
	end

	local boundSize = HomeCmdImplement._getPlacementBoundSize(homeTemplateId, scale)
	local vertical = HomeCmdImplement._safeCall(function()
		return Utils.checkRotationIsVertical(rotation)
	end) and true or false
	local boundX = vertical and boundSize[2] or boundSize[1]
	local boundZ = vertical and boundSize[1] or boundSize[2]

	return {
		homeTemplateId = homeTemplateId,
		position = pos,
		rotation = rotation,
		scale = HomeCmdImplement._scaleArrayFromAny(scale, {
			1,
			1,
			1
		}) or {
			1,
			1,
			1
		},
		boundSize = boundSize,
		layer = HomeCmdImplement._getPlacementLayer(homeTemplateId),
		aabb = {
			minX = pos[1] - boundX * 0.5,
			maxX = pos[1] + boundX * 0.5,
			minZ = pos[3] - boundZ * 0.5,
			maxZ = pos[3] + boundZ * 0.5
		}
	}
end

function HomeCmdImplement._placementGeometriesOverlap(a, b, threshold)
	if not a or not b or not a.aabb or not b.aabb then
		return false
	end

	if bit and bit.band and a.layer and b.layer and bit.band(a.layer, b.layer) == 0 then
		return false
	end

	threshold = threshold or PLACEMENT_COLLISION_THRESHOLD

	local bMinX = b.aabb.minX + threshold
	local bMaxX = b.aabb.maxX - threshold
	local bMinZ = b.aabb.minZ + threshold
	local bMaxZ = b.aabb.maxZ - threshold

	if bMaxX <= a.aabb.minX or bMinX >= a.aabb.maxX then
		return false
	end

	if bMaxZ <= a.aabb.minZ or bMinZ >= a.aabb.maxZ then
		return false
	end

	return true
end

function HomeCmdImplement._isExcludedOrnamentId(ornamentId, excludeIds)
	if excludeIds == nil then
		return false
	end

	if type(excludeIds) == "table" then
		for _, excludeId in pairs(excludeIds) do
			if tostring(ornamentId) == tostring(excludeId) then
				return true
			end
		end

		return false
	end

	return tostring(ornamentId) == tostring(excludeIds)
end

function HomeCmdImplement._removeExcludedCollisionIds(collideOrnaments, excludeIds)
	if not collideOrnaments or excludeIds == nil then
		return
	end

	if type(excludeIds) == "table" then
		for _, excludeId in pairs(excludeIds) do
			collideOrnaments[excludeId] = nil
			collideOrnaments[tostring(excludeId)] = nil
		end
	else
		collideOrnaments[excludeIds] = nil
		collideOrnaments[tostring(excludeIds)] = nil
	end
end

function HomeCmdImplement._findCollideOrnamentByUiFastMap(homeTemplateId, pos, rotation, scale, excludeId, threshold)
	local home = pg and pg.game and pg.game.home

	if not home or not home.getFastFindMap or not home.checkPosCollide then
		return nil, "ui_fast_map_unavailable"
	end

	local areaId = home.LOCK_ZONE_AREA_ID or 0
	local fastFindMap = home:getFastFindMap(areaId, true)

	if not fastFindMap then
		return nil, "ui_fast_map_unavailable"
	end

	local virtualId = HomeCmdImplement._nextVirtualPlacementId()
	local collideOrnaments = {}
	local positionObj = HomeCmdImplement._positionObjectFromArray(pos)
	local localPositionObj = home:getLocalPosition(areaId, positionObj)
	local localRotation = home:getLocalRotation(areaId, rotation)
	local boundSize = HomeCmdImplement._getPlacementBoundSize(homeTemplateId, scale)
	local extraInfo = {
		layer = HomeCmdImplement._getPlacementLayer(homeTemplateId),
		ent = {
			visible = true
		}
	}
	local ok, errMsg = pcall(function()
		fastFindMap:addOrUpdateFastFindInfo(virtualId, boundSize, localPositionObj, localRotation, extraInfo)
		home:checkPosCollide(areaId, virtualId, collideOrnaments, threshold or PLACEMENT_COLLISION_THRESHOLD)
	end)

	HomeCmdImplement._safeCall(function()
		fastFindMap:removeFastFindInfo(virtualId)
	end)

	if not ok then
		return nil, errMsg
	end

	HomeCmdImplement._removeExcludedCollisionIds(collideOrnaments, excludeId)

	local bestId, bestDistSqr

	for ornamentId in pairs(collideOrnaments) do
		local info = pg.space and pg.space.ornament and pg.space.ornament[ornamentId]
		local otherPos = info and HomeCmdImplement._safeCall(function()
			return info:getPosition()
		end)
		local distSqr = 0

		if otherPos then
			local dx = otherPos.x - pos[1]
			local dz = otherPos.z - pos[3]

			distSqr = dx * dx + dz * dz
		end

		if not bestId or distSqr < bestDistSqr then
			bestId = ornamentId
			bestDistSqr = distSqr
		end
	end

	return bestId, nil
end

function HomeCmdImplement._findCollideOrnament(qx, qz, excludeId, threshold, homeTemplateId, yawAngle, scale, rotation)
	if not homeTemplateId then
		return nil
	end

	local pos = {
		qx,
		0,
		qz
	}

	rotation = rotation or HomeCmdImplement._makeYawQuaternion(yawAngle or 0)

	if not rotation then
		return nil
	end

	threshold = threshold or PLACEMENT_COLLISION_THRESHOLD

	local hit, uiErr = HomeCmdImplement._findCollideOrnamentByUiFastMap(homeTemplateId, pos, rotation, scale, excludeId, threshold)

	if hit then
		return hit
	end

	if uiErr == nil then
		return nil
	end

	return nil, uiErr
end

function HomeCmdImplement._buildCollisionData(ornamentId, qx, qz)
	if not ornamentId then
		return nil
	end

	local info = pg.space and pg.space.ornament and pg.space.ornament[ornamentId]
	local data = {
		ornamentId = ornamentId
	}

	if info then
		data.homeTemplateId = info.homeId
		data.isTrash = info.trashId ~= nil and info.trashId ~= 0

		local pos = HomeCmdImplement._safeCall(function()
			return info:getPosition()
		end)

		if pos then
			data.position = {
				x = pos.x,
				y = pos.y or 0,
				z = pos.z
			}

			if type(qx) == "number" and type(qz) == "number" then
				local dx = pos.x - qx
				local dz = pos.z - qz

				data.distance = math.sqrt(dx * dx + dz * dz)
			end
		end
	end

	return data
end

function HomeCmdImplement._placementFailure(reasonCode, reason, collision, errorCode)
	return {
		valid = false,
		reasonCode = reasonCode,
		reason = reason,
		collision = collision,
		errorCode = errorCode or Const.CMD_SOCKET_ERROR.PARAM
	}
end

function HomeCmdImplement._placementFailureToErr(failure, prefix)
	local msg = failure and failure.reason or "placement validation failed"

	if prefix then
		msg = prefix .. ": " .. msg
	end

	if failure and failure.collision then
		msg = msg .. " (" .. HomeCmdImplement._describeCollideOrnament(failure.collision.ornamentId) .. ")"
	end

	return HomeCmdImplement._err(failure and failure.errorCode or Const.CMD_SOCKET_ERROR.PARAM, msg)
end

function HomeCmdImplement._checkPlacementBoundsLocked(homeTemplateId, pos, rotation, scale)
	local home = pg and pg.game and pg.game.home

	if home and home.checkBoundsLock then
		local boundSize = HomeCmdImplement._getPlacementBoundSize(homeTemplateId, scale)
		local positionObj = HomeCmdImplement._positionObjectFromArray(pos)
		local locked, errMsg = HomeCmdImplement._safeCall(function()
			return home:checkBoundsLock(home.LOCK_ZONE_AREA_ID or 0, positionObj, rotation, boundSize)
		end)

		if errMsg == nil then
			return locked and true or false
		end
	end

	return not HomeCmdImplement._isInUnlockedZone(pos[1], pos[3])
end

function HomeCmdImplement._validatePlacement(params, opts)
	opts = opts or {}

	local homeId = params and params.homeTemplateId

	if homeId == nil then
		return false, HomeCmdImplement._placementFailure("template_not_found", "缺少 homeTemplateId")
	end

	if not HomeObjectData[homeId] then
		return false, HomeCmdImplement._placementFailure("template_not_found", "home_object_data row not found: " .. tostring(homeId))
	end

	local pos = HomeCmdImplement._toXYZArray(params and params.position)

	if not pos then
		return false, HomeCmdImplement._placementFailure("invalid_position", "params.position must be {x, y, z} numbers")
	end

	local scale = HomeCmdImplement._scaleArrayFromAny(params and params.scale, {
		1,
		1,
		1
	})

	if not scale then
		return false, HomeCmdImplement._placementFailure("invalid_position", "params.scale must be {x, y, z} numbers")
	end

	local hasYaw = params and type(params.yawAngle) == "number"
	local yawAngle = hasYaw and params.yawAngle or 0
	local rotation = hasYaw and HomeCmdImplement._makeYawQuaternion(yawAngle) or opts.defaultRotation or HomeCmdImplement._makeYawQuaternion(0)

	if not rotation then
		return false, HomeCmdImplement._placementFailure("invalid_position", "construct Quaternion failed (CS.UnityEngine.Quaternion unavailable)", nil, Const.CMD_SOCKET_ERROR.INTERNAL)
	end

	if not opts.skipCount then
		local maxNum = HomeCmdImplement._getFacilityMaxNum(homeId)

		if maxNum then
			local cur = HomeCmdImplement._countFacilityByHomeId(homeId)
			local offset = opts.countOffset or 0

			if maxNum <= cur + offset then
				return false, HomeCmdImplement._placementFailure("max_count_reached", "facility count limit reached: " .. tostring(cur + offset) .. "/" .. tostring(maxNum))
			end
		end
	end

	if not opts.skipInventory and pg.me and type(pg.me.getItemCountById) == "function" then
		local bagCount = HomeCmdImplement._safeCall(function()
			return pg.me:getItemCountById(homeId, false)
		end) or 0
		local need = opts.inventoryNeed or 1

		if bagCount < need then
			return false, HomeCmdImplement._placementFailure("no_inventory", "no inventory of homeTemplateId=" .. tostring(homeId) .. " (need=" .. tostring(need) .. ", have=" .. tostring(bagCount) .. "; check via home.getBagItems)")
		end
	end

	if not opts.skipBounds and HomeCmdImplement._checkPlacementBoundsLocked(homeId, pos, rotation, scale) then
		return false, HomeCmdImplement._placementFailure("not_in_unlocked_zone", "position not in any unlocked zone")
	end

	if not opts.skipCollision then
		local excludeId = opts.excludeFacilityIds or opts.excludeFacilityId or params and params.excludeFacilityId
		local hit, collideErr = HomeCmdImplement._findCollideOrnament(pos[1], pos[3], excludeId, opts.collisionThreshold or PLACEMENT_COLLISION_THRESHOLD, homeId, yawAngle, scale, rotation)

		if collideErr then
			return false, HomeCmdImplement._placementFailure("collision_source_unavailable", "UI placement collision source unavailable: " .. tostring(collideErr), nil, Const.CMD_SOCKET_ERROR.INTERNAL)
		end

		if hit then
			return false, HomeCmdImplement._placementFailure("collides_with_ornament", "position collides with ornament", HomeCmdImplement._buildCollisionData(hit, pos[1], pos[3]))
		end
	end

	local placement = {
		homeTemplateId = homeId,
		homeId = homeId,
		pos = pos,
		position = HomeCmdImplement._positionDataFromArray(pos),
		scale = scale,
		yawAngle = yawAngle,
		rotation = rotation,
		geometry = HomeCmdImplement._buildPlacementGeometry(homeId, pos, rotation, scale)
	}

	return true, placement
end

function HomeCmdImplement._findCollidePreparedPlacement(placement, prepared)
	if not placement or not placement.geometry or not prepared then
		return nil
	end

	for i, prev in ipairs(prepared) do
		if HomeCmdImplement._placementGeometriesOverlap(placement.geometry, prev.geometry, PLACEMENT_COLLISION_THRESHOLD) then
			return i
		end
	end

	return nil
end

function HomeCmdImplement._describeCollideOrnament(ornamentId)
	if not ornamentId then
		return "nil"
	end

	local info = pg.space and pg.space.ornament and pg.space.ornament[ornamentId]

	if not info then
		return tostring(ornamentId) .. "(unknown)"
	end

	local homeId = info.homeId
	local trashId = info.trashId
	local pos = HomeCmdImplement._safeCall(function()
		return info:getPosition()
	end)
	local posStr = "?"

	if pos and type(pos.x) == "number" and type(pos.y) == "number" and type(pos.z) == "number" then
		posStr = string.format("(%.2f,%.2f,%.2f)", pos.x, pos.y, pos.z)
	end

	local isTrash = trashId and trashId ~= 0 and " trash" or ""

	return string.format("%s(homeId=%s%s pos=%s)", tostring(ornamentId), tostring(homeId), isTrash, posStr)
end

function HomeCmdImplement._getFacilityStateName(state)
	if state == nil then
		return nil
	end

	local fixedName = FACILITY_STATE_NAMES[state]

	if fixedName then
		return fixedName
	end

	local operateRow = HomelandOperateData[state]

	if operateRow then
		local operateName = HomeCmdImplement._localize(operateRow.workingNameWithoutEllipsis or operateRow.workingName)

		if operateName ~= nil then
			return tostring(operateName)
		end

		return "OPER_" .. tostring(state)
	end

	return "UNKNOWN"
end

function HomeCmdImplement._makeAbilityName(operateName)
	if type(operateName) ~= "string" then
		return operateName
	end

	local name = operateName

	name = string.gsub(name, "%.%.%.$", "")
	name = string.gsub(name, "…$", "")
	name = string.gsub(name, "中$", "")

	return name
end

function HomeCmdImplement._resolveAbilityName(abilityId, fallbackOperateName)
	if abilityId == nil then
		return nil
	end

	local aid = tonumber(abilityId)
	local fixedName = aid and _ABILITY_ID_TO_NAME[aid] or _ABILITY_ID_TO_NAME[abilityId]

	if fixedName then
		return fixedName
	end

	local abilityName = HomeCmdImplement._makeAbilityName(fallbackOperateName)

	if abilityName ~= nil then
		return tostring(abilityName)
	end

	return tostring(abilityId)
end

function HomeCmdImplement._getAbilityInfo(abilityId)
	if abilityId == nil then
		return nil
	end

	if not HomeCmdImplement._abilityInfoCache then
		local cache = {}

		for operateId, row in pairs(HomelandOperateData) do
			local homeAbility = row and row.homeAbility
			local aid = homeAbility and homeAbility[1] or nil

			if aid ~= nil then
				local operateName = HomeCmdImplement._localize(row.workingNameWithoutEllipsis or row.workingName)
				local info = cache[aid]

				if not info or operateId < info.operateId then
					cache[aid] = {
						abilityId = aid,
						abilityName = HomeCmdImplement._resolveAbilityName(aid, operateName),
						operateId = operateId,
						operateName = operateName
					}
				end
			end
		end

		HomeCmdImplement._abilityInfoCache = cache
	end

	return HomeCmdImplement._abilityInfoCache[abilityId] or HomeCmdImplement._abilityInfoCache[tonumber(abilityId)]
end

function HomeCmdImplement._getOperateDisplayInfo(operateId)
	if operateId == nil then
		return nil
	end

	local row = HomelandOperateData[operateId]

	if not row then
		return nil
	end

	local operateName = HomeCmdImplement._localize(row.workingNameWithoutEllipsis or row.workingName)

	return {
		operateId = operateId,
		operateName = operateName ~= nil and tostring(operateName) or tostring(operateId)
	}
end

function HomeCmdImplement._buildHomeAbilityList(homeAbility)
	local list = {}
	local t = type(homeAbility)

	if t ~= "table" and t ~= "userdata" then
		return list
	end

	for abilityId, level in pairs(homeAbility) do
		local aid = tonumber(abilityId)

		if aid ~= nil and type(level) == "number" then
			local abilityInfo = HomeCmdImplement._getAbilityInfo(aid) or {}

			list[#list + 1] = {
				abilityId = aid,
				abilityName = abilityInfo.abilityName or tostring(aid),
				level = level
			}
		end
	end

	table.sort(list, function(a, b)
		return (a.abilityId or 0) < (b.abilityId or 0)
	end)

	return list
end

function HomeCmdImplement._getEnvTypeDesc(kind)
	local map = {
		envRequireOperate = "环境状态匹配",
		facilityState = "设施状态",
		envWorkRatio = "环境效率",
		operate = "操作",
		environmentState = "环境状态",
		humidity = "湿度",
		temperature = "温度",
		light = "光照",
		electric = "电力"
	}

	return map[kind] or tostring(kind)
end

function HomeCmdImplement._getEnvValueDesc(kind, value)
	if value == nil then
		return nil
	end

	if kind == "temperature" then
		local map = {
			[0] = "温和",
			"温暖",
			"炎热",
			[-1] = "寒冷",
			[-2] = "严寒"
		}

		return map[value] or tostring(value)
	elseif kind == "light" then
		local map = {
			[0] = "暗",
			"亮"
		}

		return map[value] or tostring(value)
	elseif kind == "humidity" then
		local map = {
			[0] = "干燥",
			"正常",
			"湿润"
		}

		return map[value] or tostring(value)
	elseif kind == "facilityState" or kind == "envRequireOperate" or kind == "environmentState" then
		return HomeCmdImplement._getFacilityStateName(value) or tostring(value)
	elseif kind == "envWorkRatio" then
		return tostring(value)
	end

	return tostring(value)
end

function HomeCmdImplement._getEnvRequireDesc(kind, value)
	if value == nil then
		return nil
	end

	if kind == "temperature" then
		local map = {
			[0] = "需要温和气候",
			"需要温暖气候",
			"需要炎热气候",
			[-1] = "需要寒冷气候",
			[-2] = "需要严寒气候"
		}

		return map[value] or "需要温度档位 " .. tostring(value)
	elseif kind == "light" then
		local map = {
			[0] = "需要暗光",
			"需要光照"
		}

		return map[value] or "需要光照档位 " .. tostring(value)
	elseif kind == "humidity" then
		local map = {
			[0] = "需要干燥环境",
			"需要正常湿度",
			"需要湿润环境"
		}

		return map[value] or "需要湿度档位 " .. tostring(value)
	elseif kind == "facilityState" then
		return value ~= nil and "需要设施状态恢复，当前期望状态码 " .. tostring(value) or "需要设施状态恢复"
	elseif kind == "envRequireOperate" then
		return value ~= nil and "需要设施状态匹配到 " .. tostring(value) or "需要设施状态匹配"
	elseif kind == "envWorkRatio" then
		return "需要环境效率大于 0"
	elseif kind == "environmentState" then
		return HomeCmdImplement._getFacilityStateName(value) or tostring(value)
	end

	return tostring(value)
end

function HomeCmdImplement._decorateEnvUnmetRequirement(entry)
	if type(entry) ~= "table" then
		return entry
	end

	if entry.requireValue == nil and entry.requiredValue ~= nil then
		entry.requireValue = entry.requiredValue
	elseif entry.requiredValue == nil then
		entry.requiredValue = entry.requireValue
	end

	local kind = entry.type or entry.kind

	if kind == "env" then
		kind = entry.requireValue ~= nil and "envRequireOperate" or entry.currentValue ~= nil and "facilityState" or "environmentState"
		entry.type = kind
	end

	if kind == "envRequireOperate" then
		local requireInfo = HomeCmdImplement._getOperateDisplayInfo(entry.requireValue)
		local currentInfo = HomeCmdImplement._getOperateDisplayInfo(entry.currentValue)

		if requireInfo then
			entry.requireOperateId = entry.requireOperateId or requireInfo.operateId
			entry.requireOperateName = entry.requireOperateName or requireInfo.operateName
		end

		if currentInfo then
			entry.currentOperateId = entry.currentOperateId or currentInfo.operateId
			entry.currentOperateName = entry.currentOperateName or currentInfo.operateName
		end

		local currentName = entry.currentOperateName or tostring(entry.currentValue)
		local requireName = entry.requireOperateName or tostring(entry.requireValue)

		entry.requiredAbility = nil
		entry.desc = string.format("设施当前处于 [%s] 状态,配方要求处于 [%s] 状态;这是状态匹配要求,不是新操作要求", tostring(currentName), tostring(requireName))

		local requireOperateRow = HomelandOperateData[entry.requireValue]
		local homeAbility = requireOperateRow and requireOperateRow.homeAbility

		if homeAbility then
			entry.requiredAbilityId = homeAbility[1]
			entry.requiredAbilityLevel = homeAbility[2] or 0
			entry.requiredAbilityName = HomeCmdImplement._resolveAbilityName(entry.requiredAbilityId, requireName)
			entry.hint = "派对应能力宠物可推进此状态"
		else
			entry.requiredAbilityId = nil
			entry.requiredAbilityName = nil
			entry.requiredAbilityLevel = nil
			entry.hint = "目标 operate 无 homeAbility(可能是种子等待 sentinel 如 5000),不要派宠物——等待自然状态或检查配方/材料"
		end
	end

	entry.typeDesc = entry.typeDesc or HomeCmdImplement._getEnvTypeDesc(kind)
	entry.currentDesc = entry.currentDesc or HomeCmdImplement._getEnvValueDesc(kind, entry.currentValue)
	entry.requireDesc = entry.requireDesc or HomeCmdImplement._getEnvRequireDesc(kind, entry.requireValue) or entry.desc

	return entry
end

function HomeCmdImplement._normalizeEnvUnmetRequirements(list)
	if type(list) ~= "table" then
		return {}
	end

	for _, entry in pairs(list) do
		HomeCmdImplement._decorateEnvUnmetRequirement(entry)
	end

	return list
end

function HomeCmdImplement._buildEnvRequirementsDesc(formulaRow)
	local desc = {}
	local summary = {}
	local t = type(formulaRow)

	if t ~= "table" and t ~= "userdata" then
		desc.summary = "无特殊环境要求"
		desc.needsEnvironment = false

		return desc
	end

	if formulaRow.lightRequire ~= nil then
		desc.light = HomeCmdImplement._getEnvRequireDesc("light", formulaRow.lightRequire)
		desc.lightRequire = formulaRow.lightRequire

		if desc.light then
			summary[#summary + 1] = desc.light
		end
	end

	if formulaRow.temperatureRequire ~= nil then
		desc.temperature = HomeCmdImplement._getEnvRequireDesc("temperature", formulaRow.temperatureRequire)
		desc.temperatureRequire = formulaRow.temperatureRequire

		if desc.temperature then
			summary[#summary + 1] = desc.temperature
		end
	end

	if formulaRow.humidityRequire ~= nil then
		desc.humidity = HomeCmdImplement._getEnvRequireDesc("humidity", formulaRow.humidityRequire)
		desc.humidityRequire = formulaRow.humidityRequire

		if desc.humidity then
			summary[#summary + 1] = desc.humidity
		end
	end

	if formulaRow.envRequireOperate ~= nil then
		desc.envRequireOperate = HomeCmdImplement._getEnvRequireDesc("envRequireOperate", formulaRow.envRequireOperate)
		desc.envRequireOperateId = formulaRow.envRequireOperate

		if desc.envRequireOperate then
			summary[#summary + 1] = desc.envRequireOperate
		end
	end

	desc.summary = #summary > 0 and table.concat(summary, "，") or "无特殊环境要求"
	desc.needsEnvironment = #summary > 0

	return desc
end

function HomeCmdImplement._getEnvLevelDesc(kind, level)
	if level == nil then
		return nil
	end

	if kind == "temperature" then
		local map = {
			[0] = "normal",
			"warm",
			"hot",
			[-1] = "cold",
			[-2] = "frozen"
		}

		return map[level] or tostring(level)
	elseif kind == "light" then
		local map = {
			[0] = "dark",
			"sunny"
		}

		return map[level] or tostring(level)
	elseif kind == "humidity" then
		return tostring(level)
	end

	return tostring(level)
end

function HomeCmdImplement._makeEnvValue(kind, value)
	if value == nil then
		return nil
	end

	return {
		value = value,
		level = value,
		levelDesc = HomeCmdImplement._getEnvLevelDesc(kind, value)
	}
end

function HomeCmdImplement._mapKeysToSortedList(map)
	local list = {}

	if type(map) == "table" then
		for key in pairs(map) do
			list[#list + 1] = key
		end
	end

	table.sort(list, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return list
end

function HomeCmdImplement._getEnvNumber(info, names)
	if type(info) ~= "table" then
		return nil
	end

	for _, name in ipairs(names) do
		local value = info[name]

		if type(value) == "number" then
			return value
		end
	end

	return nil
end

function HomeCmdImplement._buildEnvAxis(info, kind)
	local final = HomeCmdImplement._getEnvNumber(info, {
		kind,
		"final" .. string.upper(string.sub(kind, 1, 1)) .. string.sub(kind, 2)
	})
	local base = HomeCmdImplement._getEnvNumber(info, {
		"base" .. string.upper(string.sub(kind, 1, 1)) .. string.sub(kind, 2),
		kind .. "Base"
	})
	local bonus = HomeCmdImplement._getEnvNumber(info, {
		"bonus" .. string.upper(string.sub(kind, 1, 1)) .. string.sub(kind, 2),
		kind .. "Bonus"
	})

	if final == nil then
		return nil, nil, nil
	end

	if base == nil then
		base = 0
	end

	if bonus == nil then
		bonus = final - base
	end

	return base, bonus, final
end

function HomeCmdImplement._putEnvAxis(base, bonus, final, kind, info)
	local baseValue, bonusValue, finalValue = HomeCmdImplement._buildEnvAxis(info, kind)

	if finalValue == nil then
		return
	end

	base[kind] = baseValue
	bonus[kind] = bonusValue
	final[kind] = finalValue
end

function HomeCmdImplement._nilIfEmptyMap(map)
	if type(map) ~= "table" then
		return map
	end

	if next(map) == nil then
		return nil
	end

	return map
end

function HomeCmdImplement._buildEnvContributors(ornamentId, envInfo, envSpace)
	local contributors = {}
	local refEnvFacilityInfo = envInfo and envInfo.refEnvFacilityInfo

	if type(refEnvFacilityInfo) ~= "table" then
		return contributors
	end

	local targetOrnament = envSpace and envSpace.ornament and envSpace.ornament[ornamentId]
	local targetPos = targetOrnament and HomeCmdImplement._safeCall(function()
		return targetOrnament:getPosition()
	end)
	local facilityTypes = Const.HOMELAND_FACILITY_TYPE or {}

	for refFacilityId in pairs(refEnvFacilityInfo) do
		local refOrnament = envSpace and envSpace.ornament and envSpace.ornament[refFacilityId] or nil

		refOrnament = refOrnament or HomeCmdImplement._getRuntimeMapValue("ornament", refFacilityId)

		local refHomeId = refOrnament and refOrnament.homeId or nil
		local facilityTemplateId = HomeCmdImplement._getFacilityTemplateId(refHomeId)
		local facilityData = facilityTemplateId and HomelandFacilityData[facilityTemplateId] or nil
		local homeEnvInfo = envSpace and envSpace.homeEnvMap and envSpace.homeEnvMap[refFacilityId] or nil

		homeEnvInfo = homeEnvInfo or HomeCmdImplement._getRuntimeMapValue("homeEnvMap", refFacilityId)

		local envProduce = homeEnvInfo and homeEnvInfo.envProduce or nil
		local provides = {}

		if envProduce ~= nil and facilityData then
			if facilityData.facilityType == facilityTypes.Light then
				provides.light = envProduce
			elseif facilityData.facilityType == facilityTypes.HighTemperate or facilityData.facilityType == facilityTypes.LowTemperate then
				provides.temperature = envProduce
			elseif facilityData.facilityType == facilityTypes.Electric then
				provides.electric = envProduce
			end
		end

		local entry = {
			facilityId = refFacilityId,
			homeTemplateId = refHomeId,
			facilityName = HomeCmdImplement._localize(refHomeId and HomeObjectData[refHomeId] and HomeObjectData[refHomeId].name),
			facilityTemplateId = facilityTemplateId,
			facilityType = facilityData and facilityData.facilityType or nil,
			facilityTypeName = facilityData and facilityData.typeName or nil,
			envProduce = envProduce,
			provides = provides
		}
		local refPos = refOrnament and HomeCmdImplement._safeCall(function()
			return refOrnament:getPosition()
		end)

		if refPos then
			entry.position = HomeCmdImplement._vec3(refPos)
		end

		if targetPos and refPos then
			local dx, dz = (targetPos.x or 0) - (refPos.x or 0), (targetPos.z or 0) - (refPos.z or 0)

			entry.distance = math.sqrt(dx * dx + dz * dz)
		end

		contributors[#contributors + 1] = entry
	end

	table.sort(contributors, function(a, b)
		return tostring(a.facilityId) < tostring(b.facilityId)
	end)

	return contributors
end

function HomeCmdImplement._addEnvUnmetRequirement(list, kind, requireValue, currentValue, desc)
	list[#list + 1] = HomeCmdImplement._decorateEnvUnmetRequirement({
		type = kind,
		requireValue = requireValue,
		requiredValue = requireValue,
		currentValue = currentValue,
		desc = desc
	})
end

function HomeCmdImplement._buildEnvSuitability(ornamentId, facilityInfo, envInfo)
	if not facilityInfo then
		return true, {}
	end

	local stateEnvInvalid = facilityInfo.facilityState == 5000 or facilityInfo.facilityState == 5 or facilityInfo.extraStateMap and facilityInfo.extraStateMap[5]

	if not facilityInfo.formulaId or facilityInfo.formulaId == 0 then
		if stateEnvInvalid then
			local unmet = {}

			HomeCmdImplement._addEnvUnmetRequirement(unmet, "facilityState", nil, facilityInfo.facilityState, "设施处于环境不适宜状态")

			return false, unmet
		end

		return true, {}
	end

	local formulaData = HomelandFormulaData[facilityInfo.formulaId]

	if not formulaData then
		if stateEnvInvalid then
			local unmet = {}

			HomeCmdImplement._addEnvUnmetRequirement(unmet, "facilityState", nil, facilityInfo.facilityState, "设施处于环境不适宜状态")

			return false, unmet
		end

		return true, {}
	end

	local envSuitable = true
	local unmet = {}

	if envInfo and envInfo.envSuitable ~= nil then
		envSuitable = envInfo.envSuitable and true or false
	end

	if envInfo and type(envInfo.unmetRequirements) == "table" then
		unmet = HomeCmdImplement._normalizeEnvUnmetRequirements(HomeCmdImplement._cloneForCmd(envInfo.unmetRequirements) or {})
	end

	if type(facilityInfo.envWorkRatio) == "number" and facilityInfo.envWorkRatio <= 0 then
		envSuitable = false
	elseif stateEnvInvalid then
		envSuitable = false
	end

	if Utils.checkNeedEnvRequire and Utils.checkNeedEnvRequire(facilityInfo) and envInfo then
		local tempRequire = formulaData.temperatureRequire

		if tempRequire ~= nil then
			local currentTemp = envInfo.temperature
			local tempInvalid = currentTemp == nil

			if currentTemp ~= nil then
				if formulaData.forceEnvRequire then
					tempInvalid = currentTemp ~= tempRequire
				else
					tempInvalid = math.abs(currentTemp - tempRequire) > 2
				end
			end

			if tempInvalid then
				envSuitable = false

				HomeCmdImplement._addEnvUnmetRequirement(unmet, "temperature", tempRequire, currentTemp, "temperature requirement not satisfied")
			end
		end

		local lightRequire = formulaData.lightRequire

		if lightRequire ~= nil then
			local currentLight = envInfo.light
			local lightInvalid = currentLight == nil

			if currentLight ~= nil then
				if formulaData.forceEnvRequire then
					lightInvalid = currentLight ~= lightRequire
				else
					lightInvalid = math.abs(currentLight - lightRequire) > 2
				end
			end

			if lightInvalid then
				envSuitable = false

				HomeCmdImplement._addEnvUnmetRequirement(unmet, "light", lightRequire, currentLight, "light requirement not satisfied")
			end
		end
	end

	if envSuitable == false and #unmet == 0 then
		if type(facilityInfo.envWorkRatio) == "number" and facilityInfo.envWorkRatio <= 0 then
			HomeCmdImplement._addEnvUnmetRequirement(unmet, "envWorkRatio", 1, facilityInfo.envWorkRatio, "环境 / 供电效率为 0")
		elseif formulaData.envRequireOperate ~= nil then
			HomeCmdImplement._addEnvUnmetRequirement(unmet, "envRequireOperate", formulaData.envRequireOperate, facilityInfo.facilityState, "设施状态不匹配")
		elseif stateEnvInvalid then
			HomeCmdImplement._addEnvUnmetRequirement(unmet, "facilityState", nil, facilityInfo.facilityState, "设施处于环境不适宜状态")
		else
			HomeCmdImplement._addEnvUnmetRequirement(unmet, "environmentState", nil, facilityInfo.facilityState, "环境状态不满足")
		end
	end

	return envSuitable, HomeCmdImplement._normalizeEnvUnmetRequirements(unmet)
end

function HomeCmdImplement._serializeEnvironmentSource(envOrnamentId, envInfo)
	local ornamentInfo = HomeCmdImplement._getRuntimeMapValue("ornament", envOrnamentId)
	local homeId = ornamentInfo and ornamentInfo.homeId or nil
	local facilityTemplateId

	if homeId and type(Utils.getHomeObjectFacilityId) == "function" then
		facilityTemplateId = HomeCmdImplement._safeCall(function()
			return Utils.getHomeObjectFacilityId(homeId)
		end)
	end

	local facilityData = facilityTemplateId and HomelandFacilityData[facilityTemplateId] or nil
	local facilityType = facilityData and facilityData.facilityType or nil
	local facilityTypes = Const.HOMELAND_FACILITY_TYPE or {}
	local entry = {
		source = "pg.space.homeEnvMap",
		zoneId = envOrnamentId,
		envOrnamentId = envOrnamentId,
		homeId = homeId,
		facilityTemplateId = facilityTemplateId,
		facilityType = facilityType,
		facilityTypeName = facilityData and facilityData.typeName or nil,
		envProduce = envInfo and envInfo.envProduce or nil,
		affectedOrnaments = HomeCmdImplement._mapKeysToSortedList(envInfo and envInfo.ornaments),
		raw = HomeCmdImplement._cloneForCmd(envInfo)
	}

	if ornamentInfo then
		local pos = HomeCmdImplement._safeCall(function()
			return ornamentInfo:getPosition()
		end)

		if pos then
			entry.position = HomeCmdImplement._vec3(pos)
		end
	end

	if envInfo then
		local currentSeason = envInfo.currentSeason or envInfo.season or envInfo.seasonId
		local currentWeather = envInfo.currentWeather or envInfo.weather or envInfo.weatherId

		entry.season = currentSeason
		entry.weather = currentWeather
		entry.currentSeason = currentSeason
		entry.currentWeather = currentWeather

		if envInfo.temperature ~= nil then
			entry.temperature = HomeCmdImplement._makeEnvValue("temperature", envInfo.temperature)
		elseif facilityType == facilityTypes.HighTemperate or facilityType == facilityTypes.LowTemperate then
			entry.temperature = HomeCmdImplement._makeEnvValue("temperature", envInfo.envProduce or 0)
		end

		if envInfo.light ~= nil then
			entry.light = HomeCmdImplement._makeEnvValue("light", envInfo.light)
		elseif facilityType == facilityTypes.Light then
			entry.light = HomeCmdImplement._makeEnvValue("light", envInfo.envProduce or 0)
		end

		if envInfo.humidity ~= nil then
			entry.humidity = HomeCmdImplement._makeEnvValue("humidity", envInfo.humidity)
		end
	end

	local base, final = {}, {}

	local function putAxis(kind, envValue)
		if not envValue then
			return
		end

		local value = envValue.value

		if value == nil then
			return
		end

		local baseValue = envInfo and (envInfo["base" .. string.upper(string.sub(kind, 1, 1)) .. string.sub(kind, 2)] or envInfo[kind .. "Base"]) or nil

		base[kind] = baseValue or 0
		final[kind] = value
	end

	putAxis("temperature", entry.temperature)
	putAxis("light", entry.light)
	putAxis("humidity", entry.humidity)

	entry.base = base
	entry.final = final

	return entry
end

function HomeCmdImplement._getEnvProvideInfo(facilityType, envFormulas)
	local provides = {}
	local provideRange, maxElectricProduce
	local facilityTypes = Const.HOMELAND_FACILITY_TYPE or {}

	if facilityType == facilityTypes.Electric then
		for _, formulaEntry in ipairs(envFormulas or EMPTY_TABLE) do
			local electricProduce = formulaEntry.electricProduce

			if type(electricProduce) == "number" then
				maxElectricProduce = math.max(maxElectricProduce or 0, electricProduce)
			end
		end

		if maxElectricProduce ~= nil then
			provides.electric = maxElectricProduce
		end
	elseif facilityType == facilityTypes.HighTemperate then
		provides.temperature = 1
		provideRange = {
			temperature = {
				max = 2,
				min = 1
			}
		}
	elseif facilityType == facilityTypes.LowTemperate then
		provides.temperature = -1
		provideRange = {
			temperature = {
				max = -1,
				min = -2
			}
		}
	elseif facilityType == facilityTypes.Light then
		provides.light = 1
	end

	return provides, provideRange
end

function HomeCmdImplement._getEnvStackInfo(facilityType)
	local facilityTypes = Const.HOMELAND_FACILITY_TYPE or {}

	if facilityType == facilityTypes.HighTemperate or facilityType == facilityTypes.LowTemperate then
		return true, 2
	elseif facilityType == facilityTypes.Light then
		return true, 1
	elseif facilityType == facilityTypes.Electric then
		return true, nil
	end

	return nil, nil
end

function HomeCmdImplement._buildFacilityEnvEffect(homeTemplateId, objectRow, facilityTemplateId, facilityData)
	local envFormulas = {}
	local needPet = false
	local firstRequirement

	for _, formulaId in ipairs(facilityData and facilityData.envFormulaList or EMPTY_TABLE) do
		local formulaRow = HomelandFormulaData[formulaId]
		local formulaEntry = {
			formulaId = formulaId,
			unitWorkload = formulaRow and formulaRow.unitWorkload or nil,
			electricProduce = formulaRow and formulaRow.electricProduce or nil,
			time = formulaRow and formulaRow.time or nil,
			operateIds = formulaRow and HomeCmdImplement._collectFormulaOperateIds(formulaRow) or {},
			requiredAbilities = {}
		}

		for _, operateId in ipairs(formulaEntry.operateIds) do
			local requirement = HomeCmdImplement._getOperateRequirement(operateId)

			if requirement then
				needPet = true
				firstRequirement = firstRequirement or requirement
				formulaEntry.requiredAbilities[#formulaEntry.requiredAbilities + 1] = requirement
			end
		end

		envFormulas[#envFormulas + 1] = formulaEntry
	end

	local addonId = objectRow and objectRow.addOnId or nil
	local addonRow = addonId and HomeAddonData[addonId] or nil
	local provides, provideRange = HomeCmdImplement._getEnvProvideInfo(facilityData and facilityData.facilityType, envFormulas)

	if addonRow and addonRow.element and addonRow.num ~= nil then
		provides[addonRow.element] = addonRow.num
	end

	local radius
	local envBounds = facilityData and facilityData.envBounds or nil

	if HomeCmdImplement._isTableLike(envBounds) then
		for _, value in pairs(envBounds) do
			if type(value) == "number" then
				radius = math.max(radius or 0, value)
			end
		end
	end

	local stackable, maxStack = HomeCmdImplement._getEnvStackInfo(facilityData and facilityData.facilityType)
	local data = {
		homeTemplateId = homeTemplateId,
		facilityName = HomeCmdImplement._localize(objectRow and objectRow.name),
		facilityTemplateId = facilityTemplateId,
		facilityType = facilityData and facilityData.facilityType or nil,
		facilityTypeName = facilityData and facilityData.typeName or nil,
		provides = provides,
		provideRange = provideRange,
		radius = radius,
		envBounds = HomeCmdImplement._cloneForCmd(envBounds),
		stackable = stackable,
		maxStack = maxStack,
		needPet = needPet,
		petAbilityRequired = firstRequirement and firstRequirement.abilityId or nil,
		petAbilityLevel = firstRequirement and firstRequirement.requiredLevel or nil,
		petAbilityName = firstRequirement and firstRequirement.operateName or nil,
		envFormulaList = HomeCmdImplement._cloneForCmd(facilityData and facilityData.envFormulaList),
		envFormulas = envFormulas,
		addonId = addonId,
		addonType = addonRow and addonRow.element or nil
	}

	if addonRow then
		data.addon = {
			addonId = addonId,
			addonType = addonRow.element,
			name = HomeCmdImplement._localize(addonRow.name),
			num = addonRow.num,
			buffId = addonRow.buffId
		}
	end

	return data
end

function HomeCmdImplement._cloneForCmd(value, depth)
	depth = depth or 0

	local vt = type(value)

	if vt ~= "table" and vt ~= "userdata" then
		return value
	end

	if depth > 4 then
		return nil
	end

	local out = {}

	for k, v in pairs(value) do
		local kt = type(k)
		local vt2 = type(v)

		if kt == "string" or kt == "number" then
			if vt2 == "string" or vt2 == "number" or vt2 == "boolean" then
				out[k] = v
			elseif vt2 == "table" or vt2 == "userdata" then
				out[k] = HomeCmdImplement._cloneForCmd(v, depth + 1)
			end
		end
	end

	return out
end

function HomeCmdImplement._bddDeepClone(value, seen)
	local vt = type(value)

	if vt ~= "table" and vt ~= "userdata" then
		return value
	end

	if vt == "userdata" and type(_G.bdd2DeepTable) == "function" then
		local ok, ret = pcall(_G.bdd2DeepTable, value)

		if ok and type(ret) == "table" then
			return ret
		end
	end

	seen = seen or {}

	if seen[value] then
		return "<cycle>"
	end

	seen[value] = true

	local out = {}

	for k, v in pairs(value) do
		out[k] = HomeCmdImplement._bddDeepClone(v, seen)
	end

	seen[value] = nil

	return out
end

function HomeCmdImplement._itemName(itemId)
	local row = itemId and ItemData[itemId] or nil

	return HomeCmdImplement._localize(row and row.itemName) or tostring(itemId)
end

function HomeCmdImplement._addItemCount(list, countMap, itemId, count)
	if type(itemId) ~= "number" or itemId <= 0 then
		return
	end

	if type(count) ~= "number" or count <= 0 then
		return
	end

	local entry = countMap[itemId]

	if not entry then
		entry = {
			count = 0,
			itemId = itemId,
			itemName = HomeCmdImplement._itemName(itemId)
		}
		countMap[itemId] = entry
		list[#list + 1] = entry
	end

	entry.count = entry.count + count
end

function HomeCmdImplement._collectFormulaOutputs(formulaRow)
	local list, countMap = {}, {}

	if not HomeCmdImplement._isTableLike(formulaRow) then
		return list
	end

	if HomeCmdImplement._isTableLike(formulaRow.outputs) then
		for _, pair in pairs(formulaRow.outputs) do
			if HomeCmdImplement._isTableLike(pair) then
				HomeCmdImplement._addItemCount(list, countMap, pair[1], pair[2] or 1)
			end
		end
	end

	if #list == 0 then
		HomeCmdImplement._addItemCount(list, countMap, formulaRow.output, formulaRow.outputNum or 1)
	end

	table.sort(list, function(a, b)
		return (a.itemId or 0) < (b.itemId or 0)
	end)

	return list
end

function HomeCmdImplement._collectFormulaConsumables(formulaRow)
	local list, countMap = {}, {}

	if not HomeCmdImplement._isTableLike(formulaRow) then
		return list
	end

	for index = 1, 5 do
		HomeCmdImplement._addItemCount(list, countMap, formulaRow["consumable" .. tostring(index)], formulaRow["consumableNum" .. tostring(index)] or 1)
	end

	table.sort(list, function(a, b)
		return (a.itemId or 0) < (b.itemId or 0)
	end)

	return list
end

function HomeCmdImplement._collectFormulaOperateIds(formulaRow)
	local list, seen = {}, {}

	local function add(operateId)
		if type(operateId) ~= "number" or operateId <= 0 or seen[operateId] then
			return
		end

		seen[operateId] = true
		list[#list + 1] = operateId
	end

	if HomeCmdImplement._isTableLike(formulaRow) then
		for _, operateId in ipairs(formulaRow.preOperateList or EMPTY_TABLE) do
			add(operateId)
		end

		for _, operateId in ipairs(formulaRow.postOperateList or EMPTY_TABLE) do
			add(operateId)
		end

		add(formulaRow.timerState)
		add(formulaRow.envRequireOperate)
	end

	table.sort(list)

	return list
end

function HomeCmdImplement._collectFacilityFormulaIds(homeTemplateId, facilityInfo)
	local list, seen = {}, {}

	local function add(formulaId)
		if type(formulaId) ~= "number" or formulaId <= 0 or seen[formulaId] then
			return
		end

		seen[formulaId] = true
		list[#list + 1] = formulaId
	end

	add(facilityInfo and facilityInfo.formulaId or nil)

	local facilityTemplateId = HomeCmdImplement._getFacilityTemplateId(homeTemplateId)
	local facilityData = facilityTemplateId and HomelandFacilityData[facilityTemplateId] or nil

	if facilityData then
		for _, formulaId in ipairs(facilityData.envFormulaList or EMPTY_TABLE) do
			add(formulaId)
		end

		for _, formulaId in ipairs(facilityData.formulaList or EMPTY_TABLE) do
			add(formulaId)
		end

		for _, formulaId in ipairs(facilityData.electricModeFormulaList or EMPTY_TABLE) do
			add(formulaId)
		end
	end

	return list
end

function HomeCmdImplement._getOperateRequirement(operateId)
	local row = HomelandOperateData[operateId]

	if row == nil or row.homeAbility == nil then
		return nil
	end

	local abilityId = row.homeAbility[1]
	local abilityInfo = HomeCmdImplement._getAbilityInfo(abilityId) or {}

	return {
		operateId = operateId,
		operateName = HomeCmdImplement._localize(row.workingNameWithoutEllipsis or row.workingName),
		abilityId = abilityId,
		abilityName = abilityInfo.abilityName or tostring(abilityId),
		requiredLevel = row.homeAbility[2] or 0
	}
end

function HomeCmdImplement._getFacilityRequiredAbility(homeTemplateId, facilityInfo)
	if not homeTemplateId then
		return nil
	end

	local formulaIds = HomeCmdImplement._collectFacilityFormulaIds(homeTemplateId, facilityInfo)

	for _, formulaId in ipairs(formulaIds) do
		local formulaRow = HomelandFormulaData[formulaId]

		if formulaRow then
			for _, operateId in ipairs(HomeCmdImplement._collectFormulaOperateIds(formulaRow)) do
				local requirement = HomeCmdImplement._getOperateRequirement(operateId)

				if requirement then
					return {
						abilityId = requirement.abilityId,
						abilityName = requirement.abilityName,
						requiredLevel = requirement.requiredLevel,
						operateId = requirement.operateId,
						operateName = requirement.operateName
					}
				end
			end
		end
	end

	return nil
end

function HomeCmdImplement._getPetAbilityLevel(templateId, abilityId)
	local petRow = templateId and PetData[templateId] or nil
	local abilityMap = petRow and petRow.homeAbility or nil

	if not abilityMap or abilityId == nil then
		return 0
	end

	return abilityMap[abilityId] or 0
end

function HomeCmdImplement._petCanDoOperate(pet, operateId)
	if not pet or not pet.templateId or type(operateId) ~= "number" or operateId <= 0 then
		return false
	end

	if type(Utils.checkHomePetCanDoOperId) == "function" then
		local canDo = HomeCmdImplement._safeCall(function()
			return Utils.checkHomePetCanDoOperId(pet.templateId, operateId)
		end)

		if canDo ~= nil then
			return canDo and true or false
		end
	end

	local req = HomeCmdImplement._getOperateRequirement(operateId)

	if not req or not req.abilityId then
		return true
	end

	return HomeCmdImplement._getPetAbilityLevel(pet.templateId, req.abilityId) >= (req.requiredLevel or 0)
end

function HomeCmdImplement._petCanDoOperateList(pet, operateIds)
	if not operateIds or #operateIds == 0 then
		return true
	end

	for _, operateId in ipairs(operateIds) do
		if not HomeCmdImplement._petCanDoOperate(pet, operateId) then
			return false
		end
	end

	return true
end

function HomeCmdImplement._collectFacilityPets()
	local homePetMap, homePets, bagPets = {}, {}, {}

	local function buildPetEntry(petId, petEnt, source)
		local petInfo

		if pg.me and type(pg.me.getPetInfo) == "function" then
			petInfo = HomeCmdImplement._safeCall(function()
				return pg.me:getPetInfo(petId)
			end)
		end

		if not petInfo and pg.me and pg.me.pets then
			petInfo = HomeCmdImplement._getPetMapValue(pg.me.pets, petId)
		end

		local entry = HomeCmdImplement._serializePet(petInfo) or {
			id = petId
		}

		if not entry.templateId and petEnt and petEnt.templateId then
			entry.templateId = petEnt.templateId
		end

		entry.source = source
		entry.isInHomeland = source == "home"

		local alloc = HomeCmdImplement._getPetMapValue(pg.space and pg.space.allocation, petId)

		if alloc then
			entry.ornamentId = alloc.ornamentId
			entry.opId = alloc.opId
		end

		entry.isIdle = not alloc or not alloc.ornamentId or alloc.ornamentId == 0
		entry.stateValid = true

		if petEnt and type(Utils.checkHomePetStateValid) == "function" then
			local valid = HomeCmdImplement._safeCall(function()
				return Utils.checkHomePetStateValid(petEnt, pg.me.space)
			end)

			if valid ~= nil then
				entry.stateValid = valid and true or false
			end
		end

		return entry
	end

	for _, petId in ipairs(HomeCmdImplement._collectHomePetIds()) do
		homePetMap[tostring(petId)] = true

		local petEnt = HomeCmdImplement._getPetMapValue(pg.space and pg.space.pets, petId)

		homePets[#homePets + 1] = buildPetEntry(petId, petEnt, "home")
	end

	local bagResult = HomeCmdImplement.getBagPets(nil, nil, {})

	if bagResult and bagResult.ok and bagResult.data then
		for _, pet in ipairs(bagResult.data.pets or EMPTY_TABLE) do
			if pet and pet.id and not homePetMap[tostring(pet.id)] then
				local entry = HomeCmdImplement._cloneForCmd(pet) or {}

				entry.source = "bag"
				entry.isInHomeland = false
				entry.isAvailable = not entry.isInPrepare and not entry.isInExplore
				entry.isIdle = true
				bagPets[#bagPets + 1] = entry
			end
		end
	end

	table.sort(homePets, function(a, b)
		return tostring(a.id) < tostring(b.id)
	end)
	table.sort(bagPets, function(a, b)
		return tostring(a.id) < tostring(b.id)
	end)

	return {
		homePets = homePets,
		bagPets = bagPets,
		homePetMap = homePetMap,
		homeCount = #homePets,
		bagCount = #bagPets
	}
end

function HomeCmdImplement._getPetBoxCapacity()
	local petBox = HomeCmdImplement._getHomePetBox()
	local space = HomeCmdImplement._getHomeSpace()
	local petBoxMap = space and space.petBoxMap
	local slotCount = petBoxMap and petBoxMap:getSlotCount() or 0
	local count = petBox and (petBox.count or 0) or 0

	if petBoxMap then
		local occupied = 0

		for idx = 1, slotCount do
			local petId = petBoxMap:getPetId(Const.HOMELAND_AREA_TYPE.PRODUCE, idx)

			if petId ~= nil and petId ~= 0 and petId ~= "" then
				occupied = occupied + 1
			end
		end

		local spaceCount = HomeCmdImplement._safeCall(function()
			return HomeLandUtils.getPetCurCount(HomeCmdImplement._getHomeSpace())
		end) or 0
		local boxCount = petBoxMap.getTotalPetCount and petBoxMap:getTotalPetCount() or 0

		count = math.max(count, occupied, spaceCount, boxCount)
	end

	return {
		count = count,
		slotCount = slotCount,
		remaining = math.max(0, slotCount - count),
		ready = petBoxMap ~= nil
	}
end

function HomeCmdImplement._getFacilityTemplateId(homeTemplateId)
	if type(Utils.getHomeObjectFacilityId) == "function" then
		local id = HomeCmdImplement._safeCall(function()
			return Utils.getHomeObjectFacilityId(homeTemplateId)
		end)

		if id then
			return id
		end
	end

	local row = homeTemplateId and HomeObjectData[homeTemplateId] or nil

	return row and row.facilityId or nil
end

function HomeCmdImplement._buildMaterialStatus(consumables)
	local list, missing, enough = {}, {}, true

	for _, item in ipairs(consumables or EMPTY_TABLE) do
		local totalCount, bagCount, warehouseCount = HomeCmdImplement._getHomeOrderItemCount(item.itemId)
		local needCount = item.count or 0
		local lackCount = math.max(0, needCount - (totalCount or 0))
		local entry = {
			itemId = item.itemId,
			itemName = item.itemName,
			needCount = needCount,
			totalCount = totalCount or 0,
			bagCount = bagCount or 0,
			warehouseCount = warehouseCount or 0,
			lackCount = lackCount,
			enough = lackCount <= 0
		}

		list[#list + 1] = entry

		if lackCount > 0 then
			enough = false
			missing[#missing + 1] = entry
		end
	end

	return {
		enough = enough,
		items = list,
		missingItems = missing
	}
end

function HomeCmdImplement._buildFormulaWorkInfo(formulaId)
	local formulaRow = formulaId and HomelandFormulaData[formulaId] or nil

	if not formulaRow then
		return nil
	end

	local operateIds = HomeCmdImplement._collectFormulaOperateIds(formulaRow)
	local requirements = {}

	for _, operateId in ipairs(operateIds) do
		local req = HomeCmdImplement._getOperateRequirement(operateId)

		if req then
			requirements[#requirements + 1] = req
		end
	end

	return {
		formulaId = formulaId,
		outputItems = HomeCmdImplement._collectFormulaOutputs(formulaRow),
		consumables = HomeCmdImplement._collectFormulaConsumables(formulaRow),
		operateIds = operateIds,
		requirements = requirements,
		requiresPetWork = #requirements > 0,
		unlockCondition = formulaRow.unlockCondition,
		time = formulaRow.time,
		workload = formulaRow.workload,
		forceEnvRequire = formulaRow.forceEnvRequire,
		lightRequire = formulaRow.lightRequire,
		temperatureRequire = formulaRow.temperatureRequire
	}
end

function HomeCmdImplement._findAssignedPet(petCtx, facilityId)
	for _, pet in ipairs(petCtx and petCtx.homePets or EMPTY_TABLE) do
		if pet.ornamentId == facilityId then
			return pet
		end
	end

	return nil
end

function HomeCmdImplement._findEligibleHomePet(petCtx, operateIds, reservedPetIds)
	for _, pet in ipairs(petCtx and petCtx.homePets or EMPTY_TABLE) do
		local petKey = tostring(pet.id)

		if pet.id and pet.isIdle and pet.stateValid ~= false and not reservedPetIds[petKey] and HomeCmdImplement._petCanDoOperateList(pet, operateIds) then
			reservedPetIds[petKey] = true

			return pet
		end
	end

	return nil
end

function HomeCmdImplement._findEligibleBagPet(petCtx, operateIds, reservedPetIds)
	for _, pet in ipairs(petCtx and petCtx.bagPets or EMPTY_TABLE) do
		local petKey = tostring(pet.id)

		if pet.id and pet.isAvailable ~= false and not reservedPetIds[petKey] and HomeCmdImplement._petCanDoOperateList(pet, operateIds) then
			reservedPetIds[petKey] = true

			return pet
		end
	end

	return nil
end

function HomeCmdImplement._makeFacilityAction(phase, cmd, params, reason)
	return {
		riskLevel = "safe",
		phase = phase,
		cmd = cmd,
		params = params or {},
		reason = reason
	}
end

function HomeCmdImplement._buildFacilityWorkPlan(facility, petCtx, reservedHomePets, reservedBagPets)
	local facilityId = facility and facility.ornamentId or nil
	local plan = {
		status = "blocked",
		facilityId = facilityId,
		homeTemplateId = facility and facility.homeId or nil,
		formulaId = facility and facility.formulaId or nil,
		disabled = facility and facility.disable and true or false,
		facilityState = facility and facility.facilityState or nil,
		env = facility and facility.env or nil,
		linkGroup = facility and facility.linkGroup or nil
	}

	if not facility or not facilityId then
		plan.reasonCode, plan.reason = "invalid_facility", "设施数据无效。"

		return plan
	end

	if facility.isTrash then
		plan.status, plan.reasonCode, plan.reason = "skipped", "trash", "杂物不是生产设施。"

		return plan
	end

	local facilityTemplateId = HomeCmdImplement._getFacilityTemplateId(facility.homeId)
	local facilityRow = facilityTemplateId and HomelandFacilityData[facilityTemplateId] or nil

	plan.facilityTemplateId = facilityTemplateId
	plan.facilityType = facilityRow and facilityRow.facilityType or nil
	plan.facilityTypeName = facilityRow and facilityRow.typeName or nil

	if not facilityRow then
		plan.status, plan.reasonCode, plan.reason = "skipped", "not_produce_facility", "没有关联 homeland_facility_data，按非生产设施处理。"

		return plan
	end

	if not facility.formulaId or facility.formulaId == 0 then
		plan.reasonCode, plan.reason = "missing_formula", "设施未设置配方，不能为“全部开工”自动挑配方，避免误消耗材料。"

		return plan
	end

	local formulaInfo = HomeCmdImplement._buildFormulaWorkInfo(facility.formulaId)

	plan.formula = formulaInfo

	if not formulaInfo then
		plan.reasonCode, plan.reason = "formula_not_found", "配方配置不存在: " .. tostring(facility.formulaId)

		return plan
	end

	plan.materialStatus = HomeCmdImplement._buildMaterialStatus(formulaInfo.consumables)

	if not plan.materialStatus.enough then
		plan.reasonCode, plan.reason = "missing_material", "配方材料不足，需要先补齐材料或走生产链。"

		return plan
	end

	if facility.disable then
		plan.status, plan.reasonCode, plan.reason = "ready", "paused", "设施处于暂停/禁用状态，先恢复生产。"
		plan.action = HomeCmdImplement._makeFacilityAction("restorePaused", "home.setFacilityPause", {
			paused = false,
			facilityId = facilityId
		}, plan.reason)

		return plan
	end

	if not formulaInfo.requiresPetWork then
		plan.status, plan.reasonCode, plan.reason = "completed", "no_pet_work_required", "当前配方不需要宠物工作，设施已处于可生产或等待产出状态。"

		return plan
	end

	local assignedPet = HomeCmdImplement._findAssignedPet(petCtx, facilityId)

	if assignedPet then
		plan.status, plan.reasonCode, plan.reason = "completed", "pet_assigned", "已有宠物在该设施工作或移动中。"
		plan.assignedPet = {
			id = assignedPet.id,
			name = assignedPet.name,
			templateId = assignedPet.templateId,
			opId = assignedPet.opId
		}

		return plan
	end

	if not facility.facilityState or facility.facilityState == 0 then
		plan.status, plan.reasonCode, plan.reason = "waiting", "waiting_operate_state", "设施当前没有可分配宠物的活动工序，等待服务端状态刷新。"

		return plan
	end

	local currentOperateIds = {
		facility.facilityState
	}

	plan.currentOperateIds = currentOperateIds

	local homePet = HomeCmdImplement._findEligibleHomePet(petCtx, currentOperateIds, reservedHomePets)

	if homePet then
		plan.status, plan.reasonCode, plan.reason = "ready", "assign_home_pet", "找到空闲且能力匹配的家园宠物，可以直接分配开工。"
		plan.pet = {
			source = "home",
			id = homePet.id,
			name = homePet.name,
			templateId = homePet.templateId
		}
		plan.action = HomeCmdImplement._makeFacilityAction("assignWorks", "home.assignPetWork", {
			force = false,
			petId = homePet.id,
			facilityId = facilityId
		}, plan.reason)

		return plan
	end

	local bagPet = HomeCmdImplement._findEligibleBagPet(petCtx, currentOperateIds, reservedBagPets)

	if bagPet then
		plan.status, plan.reasonCode, plan.reason = "ready", "place_bag_pet", "能力匹配的宠物在背包里，先放入家园，下一轮再分配开工。"
		plan.pet = {
			source = "bag",
			id = bagPet.id,
			name = bagPet.name,
			templateId = bagPet.templateId
		}
		plan.action = HomeCmdImplement._makeFacilityAction("placePets", "home.placePet", {
			petId = bagPet.id
		}, plan.reason)

		return plan
	end

	plan.reasonCode, plan.reason = "missing_pet", "没有空闲家园宠物或背包宠物能执行当前工序。"

	return plan
end

function HomeCmdImplement._normalizeMaxActions(params)
	local maxActions = params and params.maxActions or 5

	if type(maxActions) ~= "number" then
		maxActions = 5
	end

	maxActions = math.floor(maxActions)

	if maxActions < 1 then
		maxActions = 1
	end

	if maxActions > 20 then
		maxActions = 20
	end

	return maxActions
end

function HomeCmdImplement._selectFacilityBatchActions(actionsByPhase, params)
	local phase = params and params.phase or nil
	local maxActions = HomeCmdImplement._normalizeMaxActions(params)
	local phaseOrder = {
		"restorePaused",
		"placePets",
		"assignWorks"
	}

	if phase ~= nil then
		local valid = false

		for _, p in ipairs(phaseOrder) do
			if p == phase then
				valid = true
			end
		end

		if not valid then
			return nil, {}, "invalid phase: " .. tostring(phase)
		end

		phaseOrder = {
			phase
		}
	end

	for _, curPhase in ipairs(phaseOrder) do
		local source = actionsByPhase[curPhase] or {}

		if #source > 0 then
			local selected = {}

			for index = 1, math.min(maxActions, #source) do
				selected[#selected + 1] = source[index]
			end

			return curPhase, selected, nil
		end
	end

	return nil, {}, nil
end

function HomeCmdImplement._buildUpgradeCostList(costMap)
	local list = {}
	local enough = true

	for itemId, needCount in pairs(costMap or EMPTY_TABLE) do
		local totalCount, bagCount, warehouseCount = HomeCmdImplement._getHomeOrderItemCount(itemId)
		local entry = {
			itemId = itemId,
			itemName = HomeCmdImplement._itemName(itemId),
			need = needCount or 0,
			have = totalCount or 0,
			bagCount = bagCount or 0,
			warehouseCount = warehouseCount or 0,
			enough = (totalCount or 0) >= (needCount or 0)
		}

		if not entry.enough then
			enough = false
		end

		list[#list + 1] = entry
	end

	table.sort(list, function(a, b)
		return (a.itemId or 0) < (b.itemId or 0)
	end)

	return list, enough
end

function HomeCmdImplement._buildSingleFacilityUpgradePlan(facility)
	local facilityId = facility and facility.ornamentId or nil
	local homeTemplateId = facility and facility.homeId or nil
	local plan = {
		status = "blocked",
		facilityId = facilityId,
		homeTemplateId = homeTemplateId
	}

	if not facilityId or not homeTemplateId then
		plan.reasonCode = "invalid_facility"
		plan.reason = "设施数据不完整，无法升级。"

		return plan
	end

	local curType, curLevel = Utils.getHomeOrnamentCurLevelInfo(homeTemplateId)

	plan.facilityType = curType
	plan.level = curLevel

	if not curType or not curLevel then
		plan.reasonCode = "not_upgradeable"
		plan.reason = "该设施没有升级配置。"

		return plan
	end

	local upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(homeTemplateId)

	if not upgradeInfo or not upgradeInfo.homeTemplateId then
		plan.status = "completed"
		plan.reasonCode = "max_level"
		plan.reason = "该设施已经没有下一档升级。"

		return plan
	end

	plan.upgradeHomeTemplateId = upgradeInfo.homeTemplateId

	local _, nextLevel = Utils.getHomeOrnamentCurLevelInfo(upgradeInfo.homeTemplateId)

	plan.nextLevel = nextLevel

	if upgradeInfo.upgradeCost and next(upgradeInfo.upgradeCost) ~= nil then
		plan.reasonCode = "home_currency_cost_blocked"
		plan.reason = "该升级需要消耗家园币或货币类资源，按规则不自动执行，请玩家手动升级。"
		plan.currencyCosts = HomeCmdImplement._buildUpgradeCostList(upgradeInfo.upgradeCost)

		return plan
	end

	local materialCosts, enough = HomeCmdImplement._buildUpgradeCostList(upgradeInfo.upgradeItemCost)

	plan.materialCosts = materialCosts

	if #materialCosts <= 0 then
		plan.reasonCode = "missing_cost_config"
		plan.reason = "升级配置没有可自动校验的材料消耗。"

		return plan
	end

	if not enough then
		plan.reasonCode = "material_not_enough"
		plan.reason = "升级材料不足，需要先补齐材料。"

		return plan
	end

	plan.status = "ready"
	plan.reasonCode = "ready"
	plan.reason = "升级材料满足，且不消耗家园币，可以由 home.upgradeFacility 执行。"
	plan.recommendedAction = {
		cmd = "home.upgradeFacility",
		params = {
			facilityId = facilityId,
			upgradeHomeTemplateId = upgradeInfo.homeTemplateId
		}
	}

	return plan
end

function HomeCmdImplement._buildSetFromList(list)
	local set = {}

	if type(list) == "table" then
		for _, value in pairs(list) do
			if value ~= nil then
				set[tostring(value)] = true
			end
		end
	end

	return set
end

function HomeCmdImplement._normalizePlacePetCount(params, fallback)
	local count = params and params.count or fallback

	if type(count) ~= "number" then
		count = fallback
	end

	count = math.floor(count or 0)

	if count < 0 then
		count = 0
	end

	return count
end

function HomeCmdImplement._buildPlaceHomePetsPlanData(params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return nil, err
	end

	if not pg.me or not pg.me.pets then
		return nil, HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player pets")
	end

	local petBox = HomeCmdImplement._getPetBoxCapacity()

	if not petBox.ready then
		return nil, HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "petBoxMap not ready")
	end

	local prepareSet, exploreSet = {}, {}

	if pg.me.petPrepareList then
		for _, id in pairs(pg.me.petPrepareList) do
			prepareSet[tostring(id)] = true
		end
	end

	if pg.me.petExploreList then
		for _, id in pairs(pg.me.petExploreList) do
			exploreSet[tostring(id)] = true
		end
	end

	local homeSet = HomeCmdImplement._buildSetFromList(HomeCmdImplement._collectHomePetIds())
	local requestSet

	if type(params and params.petIds) == "table" then
		requestSet = HomeCmdImplement._buildSetFromList(params.petIds)
	end

	local candidates = {}
	local skipped = {}

	local function addSkipped(petId, reasonCode, reason)
		skipped[#skipped + 1] = {
			petId = petId,
			reasonCode = reasonCode,
			reason = reason
		}
	end

	for petId, pet in pairs(pg.me.pets) do
		local key = tostring(petId)

		if not requestSet or requestSet[key] then
			if homeSet[key] then
				addSkipped(petId, "already_in_home", "宠物已经在家园中。")
			elseif prepareSet[key] then
				addSkipped(petId, "in_prepare", "宠物在出战队列中，跳过。")
			elseif exploreSet[key] then
				addSkipped(petId, "in_explore", "宠物在探索队列中，跳过。")
			elseif pg.me.checkHomelandAddPet and not pg.me:checkHomelandAddPet(petId) then
				addSkipped(petId, "check_failed", "checkHomelandAddPet 不通过。")
			else
				local entry = HomeCmdImplement._serializePet(pet) or {
					id = petId
				}

				entry.source = "bag"
				candidates[#candidates + 1] = entry
			end
		end
	end

	table.sort(candidates, function(a, b)
		return tostring(a.id) < tostring(b.id)
	end)
	table.sort(skipped, function(a, b)
		return tostring(a.petId) < tostring(b.petId)
	end)

	local missingRequested = {}

	if requestSet then
		local known = {}

		for _, pet in ipairs(candidates) do
			known[tostring(pet.id)] = true
		end

		for _, item in ipairs(skipped) do
			known[tostring(item.petId)] = true
		end

		for _, petId in pairs(params.petIds) do
			if petId ~= nil and not known[tostring(petId)] then
				missingRequested[#missingRequested + 1] = petId
			end
		end

		table.sort(missingRequested, function(a, b)
			return tostring(a) < tostring(b)
		end)
	end

	local requestedCount

	if requestSet then
		requestedCount = #candidates
	else
		requestedCount = HomeCmdImplement._normalizePlacePetCount(params, petBox.remaining)
	end

	local selectCount = math.min(requestedCount, petBox.remaining, #candidates)
	local selectedPets = {}
	local selectedPetIds = {}

	for index = 1, selectCount do
		local pet = candidates[index]

		selectedPets[#selectedPets + 1] = pet
		selectedPetIds[#selectedPetIds + 1] = pet.id
	end

	local blockedReasons = {}
	local status = "ready"

	if petBox.remaining <= 0 then
		status = "blocked"
		blockedReasons[#blockedReasons + 1] = {
			reason = "家园宠物容量已满。",
			reasonCode = "pet_box_full",
			current = petBox.count,
			max = petBox.slotCount
		}
	elseif #candidates <= 0 then
		status = "blocked"
		blockedReasons[#blockedReasons + 1] = {
			reason = "没有可放入家园的宠物。",
			reasonCode = "no_available_pets",
			available = 0,
			requested = requestedCount
		}
	elseif selectCount <= 0 then
		status = "completed"
	end

	local truncated = selectCount < requestedCount
	local action

	if status == "ready" and #selectedPetIds > 0 then
		action = {
			cmd = "home.placeHomePets",
			params = {
				petIds = selectedPetIds
			}
		}
	end

	return {
		snapshotId = "placeHomePetsPlan",
		bridgeVersion = "v2",
		safetyRule = "批量放宠物只选择玩家背包中可加入家园的宠物；跳过出战、探索、已在家园宠物；按家园宠物剩余容量截断。",
		planStatus = status,
		petBox = petBox,
		requestedCount = requestedCount,
		selectedCount = #selectedPetIds,
		availableCount = #candidates,
		skippedCount = #skipped,
		truncated = truncated,
		selectedPetIds = selectedPetIds,
		selectedPets = selectedPets,
		availablePets = candidates,
		skippedPets = skipped,
		missingRequestedPetIds = missingRequested,
		blockedReasons = blockedReasons,
		recommendedAction = action
	}, nil
end

function HomeCmdImplement.isInHomeland(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	if not pg.me.space then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player space")
	end

	local space = pg.me.space
	local inHomeland = false

	if space.isHomeland then
		local ok, ret = pcall(function()
			return space:isHomeland()
		end)

		if ok then
			inHomeland = ret and true or false
		end
	end

	local isSelfHomeland = false

	if inHomeland and space.isSelfHomeland then
		local ok, ret = pcall(function()
			return space:isSelfHomeland(pg.me)
		end)

		if ok then
			isSelfHomeland = ret and true or false
		end
	end

	local data = {
		inHomeland = inHomeland,
		isSelfHomeland = isSelfHomeland,
		spaceType = space.spaceType,
		spaceId = space.id
	}

	if type(Utils.getSelfHomelandKey) == "function" then
		local key = HomeCmdImplement._safeCall(function()
			return Utils.getSelfHomelandKey(pg.me)
		end)

		if key ~= nil then
			data.selfHomelandKey = key
		end
	end

	if inHomeland and space.id and type(HomeLandUtils.parseHomelandKey) == "function" then
		local pair = HomeCmdImplement._safeCall(function()
			local sid, uid = HomeLandUtils.parseHomelandKey(space.id)

			return {
				serverId = sid,
				uid = uid
			}
		end)

		if pair then
			data.ownerServerId = pair.serverId
			data.ownerUid = pair.uid
		end
	end

	return HomeCmdImplement._ok(data)
end

function HomeCmdImplement.getConfigTables(self_, connId, params)
	local list = {}

	for name, entry in pairs(HomeCmdImplement.CONFIG_TABLES) do
		list[#list + 1] = {
			name = name,
			module = "Data." .. name,
			localizeFields = entry.localizeFields or {},
			useWhiteList = entry.useWhiteList and true or false,
			showFields = entry.showFields or {},
			hiddenFields = entry.hiddenFields or {}
		}
	end

	table.sort(list, function(a, b)
		return a.name < b.name
	end)

	return HomeCmdImplement._ok({
		tables = list
	})
end

function HomeCmdImplement.getConfig(self_, connId, params)
	local tableName = params and params.table
	local id = params and params.id

	if type(tableName) ~= "string" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.table")
	end

	if id == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.id")
	end

	local entry = HomeCmdImplement.CONFIG_TABLES[tableName]

	if not entry then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.AUTH, "forbidden: '" .. tableName .. "' not in allowlist")
	end

	local modulePath = "Data." .. tableName
	local mod, errMsg = HomeCmdImplement._safeCall(require, modulePath)

	if type(mod) ~= "table" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "load '" .. modulePath .. "' failed: " .. tostring(errMsg))
	end

	local row = mod[id]

	if not row then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "row not found in " .. tableName .. ": " .. tostring(id))
	end

	row = HomeCmdImplement._bddDeepClone(row)

	local fields = params.localizeFields

	if fields == nil then
		fields = entry.localizeFields
	end

	local useWhiteList = entry.useWhiteList and true or false
	local result

	if useWhiteList then
		result = HomeCmdImplement._applyWhiteList(row, entry.showFields)
	else
		result = HomeCmdImplement._applyHiddenFields(row, entry.hiddenFields)
	end

	result = HomeCmdImplement._applyLocalize(result, fields)

	return HomeCmdImplement._ok({
		table = tableName,
		id = id,
		row = result,
		localizedFields = fields or {},
		useWhiteList = useWhiteList,
		showFields = entry.showFields or {},
		hiddenFields = entry.hiddenFields or {}
	})
end

function HomeCmdImplement.getFacility(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	local data = HomeCmdImplement._serializeFacility(fid)

	if not data then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility not found: " .. tostring(fid))
	end

	return HomeCmdImplement._ok(data)
end

function HomeCmdImplement.getFacilities(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local typeFilter = params and params.type
	local containsTrash = params and params.containsTrash and true or false
	local trashOnly = params and params.trashOnly and true or false
	local list = {}
	local trashCount = 0

	if pg.space and pg.space.ornament then
		for ornamentId in pairs(pg.space.ornament) do
			local data = HomeCmdImplement._serializeFacility(ornamentId)

			if data then
				local isTrash = data.isTrash == true
				local typeOk = not typeFilter or data.homeId == typeFilter
				local trashOk

				if trashOnly then
					trashOk = isTrash
				else
					trashOk = containsTrash or not isTrash
				end

				if typeOk and trashOk then
					list[#list + 1] = data

					if isTrash then
						trashCount = trashCount + 1
					end
				end
			end
		end
	end

	return HomeCmdImplement._ok({
		facilities = list,
		total = #list,
		trashCount = trashCount
	})
end

function HomeCmdImplement.getEnvironment(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local space = HomeCmdImplement._getRuntimeSpace()

	if not space or not space.homeEnvMap then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "homeEnvMap not ready")
	end

	local zoneId = params and params.zoneId

	if zoneId ~= nil then
		local envInfo = space.homeEnvMap[zoneId]

		if not envInfo then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "zoneId not found in homeEnvMap: " .. tostring(zoneId))
		end

		return HomeCmdImplement._ok({
			source = "pg.space.homeEnvMap",
			total = 1,
			zones = {
				HomeCmdImplement._serializeEnvironmentSource(zoneId, envInfo)
			}
		})
	end

	local zones = {}

	for envOrnamentId, envInfo in pairs(space.homeEnvMap) do
		zones[#zones + 1] = HomeCmdImplement._serializeEnvironmentSource(envOrnamentId, envInfo)
	end

	table.sort(zones, function(a, b)
		return tostring(a.zoneId) < tostring(b.zoneId)
	end)

	return HomeCmdImplement._ok({
		source = "pg.space.homeEnvMap",
		zones = zones,
		total = #zones
	})
end

function HomeCmdImplement.getZoneEnvironment(self_, connId, params)
	return HomeCmdImplement.getEnvironment(self_, connId, params)
end

function HomeCmdImplement.getFacilityEnvEffect(self_, connId, params)
	params = params or {}

	local homeTemplateId = params.homeTemplateId

	if type(homeTemplateId) ~= "number" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.homeTemplateId")
	end

	local objectRow = HomeObjectData[homeTemplateId]

	if not objectRow then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home object not found: " .. tostring(homeTemplateId))
	end

	local facilityTemplateId = HomeCmdImplement._getFacilityTemplateId(homeTemplateId)
	local facilityData = facilityTemplateId and HomelandFacilityData[facilityTemplateId] or nil

	return HomeCmdImplement._ok(HomeCmdImplement._buildFacilityEnvEffect(homeTemplateId, objectRow, facilityTemplateId, facilityData))
end

function HomeCmdImplement.previewEnvCoverage(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local homeTemplateId = params.homeTemplateId

	if type(homeTemplateId) ~= "number" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.homeTemplateId")
	end

	local pos = params.position

	if type(pos) ~= "table" or type(pos.x) ~= "number" or type(pos.z) ~= "number" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.position {x,y,z}")
	end

	local yawAngle = tonumber(params.yawAngle) or 0
	local objectRow = HomeObjectData[homeTemplateId]

	if not objectRow then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home object not found: " .. tostring(homeTemplateId))
	end

	local facilityTemplateId = HomeCmdImplement._getFacilityTemplateId(homeTemplateId)
	local facilityData = facilityTemplateId and HomelandFacilityData[facilityTemplateId] or nil

	if not facilityData then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility data not found for homeTemplateId " .. tostring(homeTemplateId))
	end

	local envBounds = facilityData.envBounds

	if type(envBounds) ~= "table" or type(envBounds[1]) ~= "number" or type(envBounds[2]) ~= "number" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "this facility has no envBounds (not an env source): homeTemplateId=" .. tostring(homeTemplateId))
	end

	local halfX = envBounds[1] * 0.5
	local halfZ = envBounds[2] * 0.5
	local yawMod = yawAngle % 180
	local isVertical = math.abs(yawMod - 90) < 1

	if isVertical then
		halfX, halfZ = halfZ, halfX
	end

	local minX = pos.x - halfX
	local maxX = pos.x + halfX
	local minZ = pos.z - halfZ
	local maxZ = pos.z + halfZ
	local envFacilityType = facilityData.facilityType
	local relatedTypesAll = Const.HOMELAND_ENV_FACILITY_RELATED_INFO
	local relatedTypes = relatedTypesAll and relatedTypesAll[envFacilityType] or nil
	local space = HomeCmdImplement._getRuntimeSpace()
	local ornaments = space and space.ornament or nil

	if type(ornaments) ~= "table" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no space.ornament map")
	end

	local covered = {}

	for ornamentId, ornamentInfo in pairs(ornaments) do
		local opos = HomeCmdImplement._safeCall(function()
			return ornamentInfo:getPosition()
		end)

		if opos ~= nil and opos.x ~= nil and opos.z ~= nil and minX <= opos.x and maxX >= opos.x and minZ <= opos.z and maxZ >= opos.z then
			local oHomeId = ornamentInfo.homeId
			local oFacilityTplId = oHomeId and HomeCmdImplement._getFacilityTemplateId(oHomeId)
			local oFacilityData = oFacilityTplId and HomelandFacilityData[oFacilityTplId] or nil
			local oFacilityType = oFacilityData and oFacilityData.facilityType or nil
			local relevant = relatedTypes == nil or oFacilityType ~= nil and relatedTypes[oFacilityType] == true
			local dx = opos.x - pos.x
			local dz = opos.z - pos.z

			covered[#covered + 1] = {
				ornamentId = ornamentId,
				homeTemplateId = oHomeId,
				facilityName = HomeCmdImplement._localize(oHomeId and HomeObjectData[oHomeId] and HomeObjectData[oHomeId].name),
				facilityType = oFacilityType,
				facilityTypeName = oFacilityData and oFacilityData.typeName or nil,
				position = HomeCmdImplement._vec3(opos),
				distance = math.sqrt(dx * dx + dz * dz),
				relevantToEnvSource = relevant
			}
		end
	end

	table.sort(covered, function(a, b)
		return (a.distance or 0) < (b.distance or 0)
	end)

	local relevantCount = 0

	for _, entry in ipairs(covered) do
		if entry.relevantToEnvSource then
			relevantCount = relevantCount + 1
		end
	end

	local targetCoverage

	if type(params.targetFacilityIds) == "table" then
		targetCoverage = {}

		local coveredMap = {}

		for _, entry in ipairs(covered) do
			coveredMap[entry.ornamentId] = entry
		end

		for _, tid in ipairs(params.targetFacilityIds) do
			local entry = coveredMap[tid]

			targetCoverage[#targetCoverage + 1] = {
				facilityId = tid,
				covered = entry ~= nil,
				relevantToEnvSource = entry ~= nil and entry.relevantToEnvSource or false,
				distance = entry ~= nil and entry.distance or nil
			}
		end
	end

	local providesFromEnvFormulas = HomeCmdImplement._getEnvProvideInfo(envFacilityType, {})

	return HomeCmdImplement._ok({
		homeTemplateId = homeTemplateId,
		facilityName = HomeCmdImplement._localize(objectRow.name),
		facilityTemplateId = facilityTemplateId,
		facilityType = envFacilityType,
		facilityTypeName = facilityData.typeName,
		provides = providesFromEnvFormulas,
		envBounds = HomeCmdImplement._cloneForCmd(envBounds),
		position = {
			x = pos.x,
			y = pos.y or 0,
			z = pos.z
		},
		yawAngle = yawAngle,
		isVerticalRotation = isVertical,
		aabb = {
			minX = minX,
			maxX = maxX,
			minZ = minZ,
			maxZ = maxZ
		},
		coveredOrnaments = covered,
		coveredCount = #covered,
		relevantCount = relevantCount,
		targetCoverage = targetCoverage
	})
end

function HomeCmdImplement.getBagPets(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	params = params or {}

	local includeHomeland = params.includeHomeland == true
	local prepareSet, exploreSet, homeSet = {}, {}, {}

	if pg.me.petPrepareList then
		for _, id in pairs(pg.me.petPrepareList) do
			prepareSet[tostring(id)] = true
		end
	end

	if pg.me.petExploreList then
		for _, id in pairs(pg.me.petExploreList) do
			exploreSet[tostring(id)] = true
		end
	end

	for _, petId in ipairs(HomeCmdImplement._collectHomePetIds()) do
		homeSet[tostring(petId)] = true
	end

	local list = {}

	if pg.me.pets then
		for petId, pet in pairs(pg.me.pets) do
			local key = tostring(petId)
			local isInHome = homeSet[key] and true or false

			if pet and (includeHomeland or not isInHome) then
				local entry = HomeCmdImplement._serializePet(pet)

				entry.isInPrepare = prepareSet[key] and true or false
				entry.isInExplore = exploreSet[key] and true or false
				entry.isInHomeland = isInHome
				list[#list + 1] = entry
			end
		end
	end

	table.sort(list, function(a, b)
		return tostring(a.id) < tostring(b.id)
	end)

	return HomeCmdImplement._ok({
		pets = list,
		total = #list
	})
end

function HomeCmdImplement.getHomePets(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local pets = {}
	local seen = {}
	local space = HomeCmdImplement._getHomeSpace()
	local petBoxMap = space and space.petBoxMap

	if petBoxMap then
		local slotCount = petBoxMap:getSlotCount()

		for idx = 1, slotCount do
			local petId = petBoxMap:getPetId(Const.HOMELAND_AREA_TYPE.PRODUCE, idx)

			if petId ~= nil and petId ~= 0 and petId ~= "" then
				seen[tostring(petId)] = true
				pets[#pets + 1] = HomeCmdImplement._buildHomePetEntry(petId, idx)
			end
		end
	end

	for _, petId in ipairs(HomeCmdImplement._collectHomePetIds()) do
		if not seen[tostring(petId)] then
			seen[tostring(petId)] = true
			pets[#pets + 1] = HomeCmdImplement._buildHomePetEntry(petId, nil)
		end
	end

	table.sort(pets, function(a, b)
		local as = a.slotIdx or 999999
		local bs = b.slotIdx or 999999

		if as ~= bs then
			return as < bs
		end

		return tostring(a.id) < tostring(b.id)
	end)

	local max = petBox and HomeCmdImplement._getHomeSpace().petBoxMap:getSlotCount() or HomeCmdImplement._safeCall(function()
		return HomeLandUtils.getPetMaxCount(HomeCmdImplement._getHomeSpace())
	end) or 0

	return HomeCmdImplement._ok({
		pets = pets,
		current = #pets,
		max = max
	})
end

function HomeCmdImplement.getDailyOrders(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	local orders = HomeCmdImplement._collectDailyOrders()
	local levelCfg = HomeCmdImplement._getHomeOrderRefreshLevelCfg() or {}
	local refreshUsedCount = pg.me.orderRefreshCount or 0
	local freeRefreshTotal = levelCfg.freeRefresh or 0
	local remainingFreeRefreshCount = math.max(0, freeRefreshTotal - refreshUsedCount)
	local payRefreshCost = HomeCmdImplement._getHomeOrderPayRefreshCost()
	local homeCurrencyId = HomelandConfigData.homeCurrencyId
	local homeCurrencyCount = 0

	if homeCurrencyId and pg.me and type(pg.me.getItemCountById) == "function" then
		homeCurrencyCount = HomeCmdImplement._safeCall(function()
			return pg.me:getItemCountById(homeCurrencyId, false)
		end) or 0
	end

	local refreshInfo = {
		homeLevel = pg.me.homeBasicInfo and pg.me.homeBasicInfo.level or nil,
		totalOrderSlots = levelCfg.orderNum or 0,
		freeRefreshTotal = freeRefreshTotal,
		refreshUsedCount = refreshUsedCount,
		remainingFreeRefreshCount = remainingFreeRefreshCount,
		nextRefreshTime = pg.me.nextRefreshTime or nil,
		payRefreshCost = payRefreshCost,
		homeCurrencyId = homeCurrencyId,
		homeCurrencyCount = homeCurrencyCount,
		canFreeRefresh = remainingFreeRefreshCount > 0,
		canPayRefresh = payRefreshCost <= homeCurrencyCount
	}

	return HomeCmdImplement._ok({
		orders = orders,
		total = #orders,
		refreshInfo = refreshInfo
	})
end

function HomeCmdImplement.getWarehouse(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local items = {}

	if pg.me.space.itemMap then
		for itemId, count in pairs(pg.me.space.itemMap) do
			items[#items + 1] = {
				id = itemId,
				count = count
			}
		end
	end

	return HomeCmdImplement._ok({
		items = items,
		total = #items
	})
end

function HomeCmdImplement.getBagItems(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	local items = {}

	if params and params.itemIds then
		if type(params.itemIds) ~= "table" then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.itemIds must be array")
		end

		for _, itemId in ipairs(params.itemIds) do
			local count = HomeCmdImplement._safeCall(function()
				return pg.me:getItemCountById(itemId, false)
			end) or 0

			items[#items + 1] = {
				id = itemId,
				count = count
			}
		end

		return HomeCmdImplement._ok({
			items = items,
			total = #items
		})
	end

	local bagMap

	if pg.me.itemMap then
		bagMap = pg.me.itemMap
	elseif pg.me.bagMap then
		bagMap = pg.me.bagMap
	elseif pg.me.inventory and pg.me.inventory.itemMap then
		bagMap = pg.me.inventory.itemMap
	end

	if not bagMap then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "no bag iteration support; pass params.itemIds")
	end

	for itemId, count in pairs(bagMap) do
		items[#items + 1] = {
			id = itemId,
			count = count
		}
	end

	return HomeCmdImplement._ok({
		items = items,
		total = #items
	})
end

function HomeCmdImplement.canPetDoOper(self_, connId, params)
	local templateId = params and params.templateId
	local operId = params and params.operId

	if templateId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.templateId")
	end

	if operId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.operId")
	end

	local pData = PetData[templateId]

	if not pData then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet template not found: " .. tostring(templateId))
	end

	local opData = HomelandOperateData[operId]

	if not opData then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "operate not found: " .. tostring(operId))
	end

	local opAbility = opData.homeAbility

	if not opAbility then
		return HomeCmdImplement._ok({
			reason = "operate has no homeAbility requirement",
			canDo = true,
			templateId = templateId,
			operId = operId
		})
	end

	local abilityId = opAbility[1]
	local requirement = HomeCmdImplement._getOperateRequirement(operId) or {}
	local requiredLevel = requirement.requiredLevel or opAbility[2] or 0
	local petAbilityMap = pData.homeAbility or {}
	local petLevel = petAbilityMap[abilityId] or 0

	return HomeCmdImplement._ok({
		canDo = requiredLevel <= petLevel,
		templateId = templateId,
		operId = operId,
		requiredAbility = {
			id = abilityId,
			level = requiredLevel,
			abilityId = abilityId,
			abilityName = requirement.abilityName or tostring(abilityId),
			requiredLevel = requiredLevel,
			operateId = operId,
			operateName = requirement.operateName
		},
		petAbilityLevel = petLevel
	})
end

function HomeCmdImplement.getRequiredAbility(self_, connId, params)
	local formulaId = params and params.formulaId

	if formulaId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.formulaId")
	end

	local formulaRow = HomelandFormulaData[formulaId]

	if not formulaRow then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "formula not found: " .. tostring(formulaId))
	end

	local operateIds = HomeCmdImplement._collectFormulaOperateIds(formulaRow)
	local requiredAbilities = {}

	for _, operateId in ipairs(operateIds) do
		local requirement = HomeCmdImplement._getOperateRequirement(operateId)

		if requirement then
			requiredAbilities[#requiredAbilities + 1] = requirement
		end
	end

	return HomeCmdImplement._ok({
		formulaId = formulaId,
		operateIds = operateIds,
		requiredAbilities = requiredAbilities,
		total = #requiredAbilities
	})
end

function HomeCmdImplement.getFoodState(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local home = pg.me.space
	local slotList = home.homeFoodSlotList

	if not slotList then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "homeFoodSlotList not ready")
	end

	local slots = {}

	for i = 1, #slotList do
		local slot = slotList[i]

		if slot then
			local itemId = slot.itemId
			local itemNum = slot.itemNum or 0
			local foodPerItem = 0

			if itemId and ItemData[itemId] then
				foodPerItem = ItemData[itemId].homeFoodAdd or 0
			end

			slots[#slots + 1] = {
				slotIndex = i,
				itemId = itemId,
				itemNum = itemNum,
				foodPerItem = foodPerItem,
				subTotal = foodPerItem * itemNum
			}
		end
	end

	local totalFood = HomeCmdImplement._safeCall(function()
		return slotList:getTotalFood(home)
	end) or 0
	local curSpeed = home.foodSlotCurSpeed or 0
	local nextRefreshTs = home.foodSlotNextRefreshTs or 0
	local isWorking = nextRefreshTs > 0
	local data = {
		slots = slots,
		slotCount = #slotList,
		totalFood = totalFood,
		curSpeed = curSpeed,
		isWorking = isWorking,
		nextRefreshTs = nextRefreshTs
	}

	if isWorking and curSpeed > 0 then
		local pair = HomeCmdImplement._safeCall(function()
			local endTs, totalSec = slotList:getEstimatedEndTs(home)

			return {
				endTs = endTs,
				totalSec = totalSec
			}
		end)

		if pair then
			data.estimatedEndTs = pair.endTs
			data.estimatedEndSeconds = pair.totalSec
		end
	end

	return HomeCmdImplement._ok(data)
end

function HomeCmdImplement.getCar(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	if not pg.me.homeBasicInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "homeBasicInfo not ready")
	end

	local info, ierr = HomeCmdImplement._safeCall(function()
		return HomeLandUtils.getHomeCarInfo()
	end)

	if not info then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "getHomeCarInfo failed: " .. tostring(ierr))
	end

	local components = {}

	if info.carCompsLevel then
		for tabId, level in pairs(info.carCompsLevel) do
			components[#components + 1] = {
				tabId = tabId,
				level = level
			}
		end

		table.sort(components, function(a, b)
			return a.tabId < b.tabId
		end)
	end

	return HomeCmdImplement._ok({
		level = info.level or 1,
		modelLevel = info.modelLevel,
		name = info.name or "",
		components = components,
		curCampStaticId = info.curCampStaticId,
		curCampLineId = info.curCampLineId,
		displayCode = info.displayCode
	})
end

function HomeCmdImplement.getFacilityAtPosition(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local qx = params and params.x
	local qz = params and params.z

	if type(qx) ~= "number" or type(qz) ~= "number" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.x / params.z must be number")
	end

	local threshold = params and type(params.threshold) == "number" and params.threshold or 2
	local thrSqr = threshold * threshold
	local containsTrash = true

	if params and params.containsTrash == false then
		containsTrash = false
	end

	local list = {}

	if pg.space and pg.space.ornament then
		for ornamentId, info in pairs(pg.space.ornament) do
			local isTrash = info.trashId and info.trashId ~= 0

			if containsTrash or not isTrash then
				local pos = HomeCmdImplement._safeCall(function()
					return info:getPosition()
				end)

				if pos then
					local dx = pos.x - qx
					local dz = pos.z - qz

					if thrSqr >= dx * dx + dz * dz then
						local data = HomeCmdImplement._serializeFacility(ornamentId)

						if data then
							data.distance = math.sqrt(dx * dx + dz * dz)
							list[#list + 1] = data
						end
					end
				end
			end
		end
	end

	table.sort(list, function(a, b)
		return (a.distance or 0) < (b.distance or 0)
	end)

	return HomeCmdImplement._ok({
		facilities = list,
		total = #list,
		query = {
			x = qx,
			z = qz,
			threshold = threshold
		}
	})
end

function HomeCmdImplement.getZoneUnlocks(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local unlockMap = pg.space and pg.space.unlockZone or {}
	local localizeFields = {
		"name",
		"showName",
		"desc"
	}
	local zones, unlockedCount = {}, 0

	for zoneId, zoneCfg in pairs(HomelandZoneUnlockConfigData) do
		local unlocked = unlockMap[zoneId] and true or false

		if unlocked then
			unlockedCount = unlockedCount + 1
		end

		local row = HomeCmdImplement._applyLocalize(zoneCfg, localizeFields)
		local entry = {
			zoneId = zoneId,
			unlocked = unlocked,
			isUnlockDefault = zoneCfg.isUnlock == 1,
			canUnlock = zoneCfg.canUnlock == 1,
			unlockCost = HomeCmdImplement._cloneForCmd(zoneCfg.unlockCost),
			unlockCondition = HomeCmdImplement._cloneForCmd(zoneCfg.unlockCondition),
			addPetNum = zoneCfg.addPetNum,
			name = row.name,
			showName = row.showName,
			desc = row.desc
		}

		if zoneCfg.prefabPos then
			entry.prefabPos = {
				x = zoneCfg.prefabPos[1],
				z = zoneCfg.prefabPos[2]
			}
		end

		zones[#zones + 1] = entry
	end

	table.sort(zones, function(a, b)
		return a.zoneId < b.zoneId
	end)

	return HomeCmdImplement._ok({
		zones = zones,
		unlockedCount = unlockedCount,
		totalCount = #zones
	})
end

function HomeCmdImplement.getZoneBounds(self_, connId, params)
	local width = Const.HomelandZoneWidth or 0
	local height = Const.HomelandZoneHeight or 0
	local halfW = width * 0.5
	local halfH = height * 0.5
	local unlockMap = pg.space and pg.space.unlockZone
	local zones = {}

	for zoneId, zoneCfg in pairs(HomelandZoneUnlockConfigData) do
		local prefabPos = zoneCfg.prefabPos

		if prefabPos then
			local cx, cz = prefabPos[1], prefabPos[2]
			local entry = {
				zoneId = zoneId,
				center = {
					x = cx,
					z = cz
				},
				min = {
					x = cx - halfW,
					z = cz - halfH
				},
				max = {
					x = cx + halfW,
					z = cz + halfH
				}
			}

			if unlockMap ~= nil then
				entry.unlocked = unlockMap[zoneId] and true or false
			end

			zones[#zones + 1] = entry
		end
	end

	table.sort(zones, function(a, b)
		return a.zoneId < b.zoneId
	end)

	return HomeCmdImplement._ok({
		zoneSize = {
			width = width,
			height = height
		},
		zones = zones
	})
end

function HomeCmdImplement.getFacilityFormulas(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	local ornamentInfo = pg.space and pg.space.ornament and pg.space.ornament[fid]

	if not ornamentInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament not found: " .. tostring(fid))
	end

	local homeId = ornamentInfo.homeId

	if type(Utils.getHomeObjectFacilityId) ~= "function" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "Utils.getHomeObjectFacilityId unavailable")
	end

	local facilityTemplateId = Utils.getHomeObjectFacilityId(homeId)

	if not facilityTemplateId then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament has no facilityId mapping: homeId=" .. tostring(homeId))
	end

	local facilityData = HomelandFacilityData[facilityTemplateId]

	if not facilityData then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility data not found: facilityTemplateId=" .. tostring(facilityTemplateId))
	end

	local formulaIds = facilityData.formulaList or {}
	local formulas = {}

	for _, formulaId in ipairs(formulaIds) do
		local entry = {
			formulaId = formulaId
		}
		local row = HomelandFormulaData[formulaId]

		if row then
			for k, v in pairs(row) do
				entry[k] = HomeCmdImplement._bddDeepClone(v)
			end

			entry.envRequirementsDesc = HomeCmdImplement._buildEnvRequirementsDesc(row)
		end

		formulas[#formulas + 1] = entry
	end

	return HomeCmdImplement._ok({
		ornamentId = fid,
		homeId = homeId,
		facilityTemplateId = facilityTemplateId,
		facilityType = facilityData.facilityType,
		formulas = formulas,
		total = #formulas
	})
end

function HomeCmdImplement.checkCondition(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	local triggerMap = pg.me.triggerMap

	if not triggerMap or type(triggerMap.isCompleteOrMeetCondition) ~= "function" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "triggerMap.isCompleteOrMeetCondition unavailable")
	end

	local conditionId = params and params.conditionId

	if conditionId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.conditionId")
	end

	local completed = HomeCmdImplement._safeCall(function()
		return triggerMap:isCompleteOrMeetCondition(conditionId)
	end)

	return HomeCmdImplement._ok({
		conditionId = conditionId,
		completed = completed and true or false
	})
end

function HomeCmdImplement.getCmdList(self_, connId, params)
	local queries, actions, others = {}, {}, {}

	for fnName, fn in pairs(HomeCmdImplement) do
		if type(fn) == "function" and string.sub(fnName, 1, 1) ~= "_" then
			local entry = {
				cmd = "home." .. fnName,
				fn = fnName
			}
			local meta = HomeCmdImplement.CMD_META[fnName]

			if meta then
				entry.category = meta.category
				entry.desc = meta.desc

				if meta.params then
					entry.params = meta.params
				end

				if meta.async then
					entry.async = true
				end
			else
				entry.category = "unknown"
			end

			if entry.category == "query" then
				queries[#queries + 1] = entry
			elseif entry.category == "action" then
				actions[#actions + 1] = entry
			else
				others[#others + 1] = entry
			end
		end
	end

	local function byCmd(a, b)
		return a.cmd < b.cmd
	end

	table.sort(queries, byCmd)
	table.sort(actions, byCmd)
	table.sort(others, byCmd)

	local result = {
		queries = queries,
		actions = actions,
		queryCount = #queries,
		actionCount = #actions
	}

	if #others > 0 then
		result.others = others
		result.otherCount = #others
	end

	return HomeCmdImplement._ok(result)
end

function HomeCmdImplement.getCurrencies(self_, connId, params)
	local list = {}

	if HomelandConfigData.homeCurrencyId then
		list[#list + 1] = {
			label = "家园主货币",
			key = "homeCurrencyId",
			itemId = HomelandConfigData.homeCurrencyId
		}
	end

	if HomelandConfigData.homeVoucherId then
		list[#list + 1] = {
			label = "家园凭证",
			key = "homeVoucherId",
			itemId = HomelandConfigData.homeVoucherId
		}
	end

	return HomeCmdImplement._ok({
		currencies = list,
		total = #list
	})
end

function HomeCmdImplement.getFacilityMaxCount(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local homeId = params and params.homeTemplateId

	if homeId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.homeTemplateId")
	end

	return HomeCmdImplement._ok({
		homeTemplateId = homeId,
		currentCount = HomeCmdImplement._countFacilityByHomeId(homeId),
		maxCount = HomeCmdImplement._getFacilityMaxNum(homeId)
	})
end

function HomeCmdImplement.getLastOrnamentResult(self_, connId, params)
	params = params or {}

	local results, currentSeq = HomeCmdImplement._collectOrnamentResults(params.sinceSeq)

	return HomeCmdImplement._ok({
		results = results,
		total = #results,
		currentSeq = currentSeq
	})
end

function HomeCmdImplement.getRuntimeSnapshot(self_, connId, params)
	params = params or {}

	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local snapshot = {
		bridgeVersion = "v1",
		snapshotId = "homeRuntimeSnapshot",
		errors = {}
	}

	local function attach(name, fn, fnParams, required)
		local result = fn(nil, nil, fnParams or {})

		if result and result.ok then
			snapshot[name] = result.data or {}
		else
			local e = result and result.error or {
				msg = "unknown error"
			}

			snapshot.errors[#snapshot.errors + 1] = {
				section = name,
				code = e.code,
				msg = e.msg
			}

			if required then
				return false
			end
		end

		return true
	end

	if not attach("homeland", HomeCmdImplement.isInHomeland, {}, true) then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "homeRuntimeSnapshot failed at homeland")
	end

	attach("facilities", HomeCmdImplement.getFacilities, {
		containsTrash = false
	}, true)
	attach("homePets", HomeCmdImplement.getHomePets, {}, false)
	attach("bagPets", HomeCmdImplement.getBagPets, {}, false)
	attach("warehouse", HomeCmdImplement.getWarehouse, {}, false)

	if params.includeOrders ~= false then
		attach("dailyOrders", HomeCmdImplement.getDailyOrders, {}, false)
	end

	if params.includeFood ~= false then
		attach("foodState", HomeCmdImplement.getFoodState, {}, false)
	end

	snapshot.errorCount = #snapshot.errors

	return HomeCmdImplement._ok(snapshot)
end

function HomeCmdImplement.setFormula(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId
	local fmId = params and params.formulaId

	if fid == nil or fmId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing facilityId/formulaId")
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:setHomelandProduce(fid, fmId)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "setHomelandProduce failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		facilityId = fid,
		formulaId = fmId
	})
end

function HomeCmdImplement.removeFormula(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId
	local fmId = params and params.formulaId

	if fid == nil or fmId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing facilityId/formulaId")
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:removeHomelandProduce(fid, fmId)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "removeHomelandProduce failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		facilityId = fid,
		formulaId = fmId
	})
end

function HomeCmdImplement.placePet(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local petId = params and params.petId

	if petId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	local petBox = HomeCmdImplement._getPetBoxCapacity()

	if not petBox.ready then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "petBoxMap not ready")
	end

	if petBox.remaining < 1 then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet box full: " .. tostring(petBox.count) .. "/" .. tostring(petBox.slotCount))
	end

	if not pg.me.checkHomelandAddPet or not pg.me:checkHomelandAddPet(petId) then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "checkHomelandAddPet failed: " .. tostring(petId))
	end

	local petIdStr = tostring(petId)

	if pg.me.petPrepareList then
		for _, pid in pairs(pg.me.petPrepareList) do
			if tostring(pid) == petIdStr then
				return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet_busy: pet is in prepare team: " .. petIdStr)
			end
		end
	end

	if pg.me.petExploreList then
		for _, pid in pairs(pg.me.petExploreList) do
			if tostring(pid) == petIdStr then
				return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet_busy: pet is in explore team: " .. petIdStr)
			end
		end
	end

	local homePetIds = HomeCmdImplement._collectHomePetIds()

	if homePetIds then
		for _, hpid in ipairs(homePetIds) do
			if tostring(hpid) == petIdStr then
				return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet_already_in_home: " .. petIdStr)
			end
		end
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:addHomelandPetBatch({
			petId
		})
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "addHomelandPetBatch failed: " .. tostring(errMsg))
	end

	local data = {
		note = "placePet 是 fire-and-forget RPC,客户端 pg.space.pets 需要 ~1 秒更新。派发后等 1 秒再调 home.getHomePets 才能看到新宠物。",
		noteWaitSeconds = 1,
		petId = petId
	}
	local petInfo = HomeCmdImplement._safeCall(function()
		if type(pg.me.getPetInfo) == "function" then
			return pg.me:getPetInfo(petId)
		end

		return nil
	end)

	if not petInfo and pg.me.pets then
		petInfo = pg.me.pets[petId] or pg.me.pets[tostring(petId)]
	end

	local petData = HomeCmdImplement._serializePet(petInfo)

	if petData then
		data.pet = petData
	end

	return HomeCmdImplement._asyncOk(data)
end

function HomeCmdImplement.placeHomePets(self_, connId, params)
	params = params or {}

	local plan, planErr = HomeCmdImplement._buildPlaceHomePetsPlanData(params)

	if planErr then
		return planErr
	end

	local action = plan.recommendedAction
	local petIds = action and action.params and action.params.petIds or {}

	if #petIds <= 0 then
		return HomeCmdImplement._ok({
			dispatched = false,
			reason = "no pets selected",
			async = false,
			planStatus = plan.planStatus,
			plan = plan
		})
	end

	local petBox = HomeCmdImplement._getPetBoxCapacity()

	if not petBox.ready then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "petBoxMap not ready")
	end

	if #petIds > petBox.remaining then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet box remaining slots not enough: need=" .. tostring(#petIds) .. " remaining=" .. tostring(petBox.remaining))
	end

	if pg.me.checkHomelandAddPet then
		for _, petId in ipairs(petIds) do
			if not pg.me:checkHomelandAddPet(petId) then
				return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "checkHomelandAddPet failed: " .. tostring(petId))
			end
		end
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:addHomelandPetBatch(petIds)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "addHomelandPetBatch failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		petIds = petIds,
		count = #petIds,
		plan = plan
	})
end

function HomeCmdImplement.recallPet(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local petId = params and params.petId

	if petId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	local homePets = pg.space and pg.space.pets

	if homePets and not homePets[petId] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in home: " .. tostring(petId))
	end

	local areaId = HomeLandUtils.getHomePetAreaId(pg.space, petId)

	if areaId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home pet area not found: " .. tostring(petId))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:removeHomelandPetBatch({
			petId
		}, -1, areaId)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "removeHomelandPetBatch failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		petId = petId
	})
end

function HomeCmdImplement.recallAllPets(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local filterPetIds = params and params.petIds or nil

	if filterPetIds ~= nil and type(filterPetIds) ~= "table" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.petIds must be array")
	end

	local petIds = HomeCmdImplement._collectHomePetIds(filterPetIds)

	if #petIds <= 0 then
		return HomeCmdImplement._ok({
			dispatched = false,
			async = false,
			alreadyEmpty = true,
			count = 0,
			petIds = {}
		})
	end

	if not pg.space or not pg.space.petsPlaceData then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "petsPlaceData not ready")
	end

	local petIdsByArea = {}

	for _, petId in ipairs(petIds) do
		local areaId = HomeLandUtils.getHomePetAreaId(pg.space, petId)

		if areaId == nil then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home pet area not found: " .. tostring(petId))
		end

		petIdsByArea[areaId] = petIdsByArea[areaId] or {}
		petIdsByArea[areaId][#petIdsByArea[areaId] + 1] = petId
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		for areaId, areaPetIds in pairs(petIdsByArea) do
			pg.me.space:removeHomelandPetBatch(areaPetIds, -1, areaId)
		end
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "removeHomelandPetBatch failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		petIds = petIds,
		count = #petIds
	})
end

function HomeCmdImplement.assignPetWork(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local petId = params and params.petId
	local fid = params and params.facilityId
	local force = params and params.force

	if force == nil then
		force = false
	end

	if petId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	if type(force) ~= "boolean" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.force must be boolean")
	end

	if not pg.space or not pg.space.facility or not pg.space.facility[fid] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility not found: " .. tostring(fid))
	end

	if pg.space.pets and not pg.space.pets[petId] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in home: " .. tostring(petId))
	end

	if not HomeLandUtils.isHomePetInProduceArea(pg.space, petId) then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in produce area: " .. tostring(petId))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:allocateHomePetWork(petId, fid, Const.HOMELAND_FACILITY_OP_TYPE.MOVING, force)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "allocateHomePetWork failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		petId = petId,
		facilityId = fid,
		opId = Const.HOMELAND_FACILITY_OP_TYPE.MOVING,
		force = force
	})
end

function HomeCmdImplement.assignPetTransport(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local petId = params and params.petId
	local fid = params and params.facilityId

	if petId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	if not pg.space or not pg.space.facility or not pg.space.facility[fid] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility not found: " .. tostring(fid))
	end

	local petInfo = pg.space.pets and pg.space.pets[petId]

	if not petInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in home: " .. tostring(petId))
	end

	if not HomeLandUtils.isHomePetInProduceArea(pg.space, petId) then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in produce area: " .. tostring(petId))
	end

	if type(Utils.checkHomePetCanDoOperId) ~= "function" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "Utils.checkHomePetCanDoOperId unavailable")
	end

	local canTransport = Utils.checkHomePetCanDoOperId(petInfo.templateId, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT)

	if not canTransport then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet cannot do transport: petId=" .. tostring(petId) .. " templateId=" .. tostring(petInfo.templateId))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:allocateHomePetWork(petId, fid, Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT, false)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "allocateHomePetWork failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		petId = petId,
		facilityId = fid,
		opId = Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT
	})
end

function HomeCmdImplement.unassignPetWork(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local petId = params and params.petId

	if petId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	if pg.space and pg.space.pets and not pg.space.pets[petId] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in home: " .. tostring(petId))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:deallocateHomePetWork(petId, 0, false)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "deallocateHomePetWork failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		petId = petId
	})
end

function HomeCmdImplement.callPetWork(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	local facilityInfo = pg.space and pg.space.facility and pg.space.facility[fid]

	if not facilityInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility not found: " .. tostring(fid))
	end

	local ornamentInfo = pg.space and pg.space.ornament and pg.space.ornament[fid]

	if not ornamentInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament not found: " .. tostring(fid))
	end

	local operId = facilityInfo.facilityState or 0

	if operId <= 0 then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility has no active operId (facilityState=" .. tostring(operId) .. ")")
	end

	local checkValid = Utils.checkHomePetStateValid
	local canDoOper = Utils.checkHomePetCanDoOperId
	local calcWorkload = Utils.calcHomePetTimeWorkload
	local facilityTemplateId = Utils.getHomeObjectFacilityId and Utils.getHomeObjectFacilityId(ornamentInfo.homeId)

	if not facilityTemplateId then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament has no facility template id")
	end

	local hasFood = false

	if pg.me.space.checkHomePetHasFood then
		local h = HomeCmdImplement._safeCall(function()
			return pg.me.space:checkHomePetHasFood()
		end)

		hasFood = h and true or false
	end

	local bestPetId, bestWorkload = nil, -1

	if pg.space and pg.space.pets then
		for petId, petInfo in pairs(pg.space.pets) do
			local alloc = pg.space.allocation and pg.space.allocation[petId]
			local sameFacility = alloc and alloc.ornamentId == fid

			if not sameFacility and petInfo and HomeLandUtils.isHomePetInProduceArea(pg.space, petId) then
				local stateOk = checkValid and HomeCmdImplement._safeCall(function()
					return checkValid(petInfo, pg.me.space)
				end) or false

				if stateOk then
					local canDo = canDoOper and canDoOper(petInfo.templateId, operId)

					if canDo then
						local workload = 0

						if calcWorkload then
							local w = HomeCmdImplement._safeCall(function()
								return calcWorkload(petInfo, operId, facilityTemplateId, hasFood)
							end)

							workload = w or 0
						end

						if bestWorkload < workload then
							bestPetId = petId
							bestWorkload = workload
						end
					end
				end
			end
		end
	end

	if not bestPetId then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no eligible pet for facility " .. tostring(fid) .. " operId=" .. tostring(operId))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:allocateHomePetWork(bestPetId, fid, Const.HOMELAND_FACILITY_OP_TYPE.MOVING, false)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "allocateHomePetWork failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		facilityId = fid,
		petId = bestPetId,
		operId = operId
	})
end

function HomeCmdImplement.submitDailyOrder(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	if type(pg.me.reqSubmitHomeOrder) ~= "function" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "pg.me.reqSubmitHomeOrder unavailable")
	end

	local order, resolveErr = HomeCmdImplement._resolveDailyOrder(params)

	if not order then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, resolveErr)
	end

	if order.orderStatus ~= HomeOrderConst.STATUS.Incomplete then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "daily order is not open: serverIndex=" .. tostring(order.serverIndex))
	end

	if not order.canSubmit then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "daily order requirements not met: serverIndex=" .. tostring(order.serverIndex))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me:reqSubmitHomeOrder(order.serverIndex)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "reqSubmitHomeOrder failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		serverIndex = order.serverIndex,
		orderId = order.orderId,
		orderName = order.orderName
	})
end

function HomeCmdImplement.refreshDailyOrder(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	if type(pg.me.reqRefreshHomeOrder) ~= "function" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "pg.me.reqRefreshHomeOrder unavailable")
	end

	local order, resolveErr = HomeCmdImplement._resolveDailyOrder(params)

	if not order then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, resolveErr)
	end

	local levelCfg = HomeCmdImplement._getHomeOrderRefreshLevelCfg() or {}
	local remainingFreeRefreshCount = math.max(0, (levelCfg.freeRefresh or 0) - (pg.me.orderRefreshCount or 0))

	if remainingFreeRefreshCount <= 0 then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no free daily order refresh remaining")
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me:reqRefreshHomeOrder(order.serverIndex)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "reqRefreshHomeOrder failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		refreshMode = "free",
		serverIndex = order.serverIndex,
		orderId = order.orderId,
		orderName = order.orderName
	})
end

function HomeCmdImplement.payRefreshDailyOrder(self_, connId, params)
	if not pg.me then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	if type(pg.me.reqPayRefreshHomeOrder) ~= "function" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "pg.me.reqPayRefreshHomeOrder unavailable")
	end

	local order, resolveErr = HomeCmdImplement._resolveDailyOrder(params)

	if not order then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, resolveErr)
	end

	local payRefreshCost = HomeCmdImplement._getHomeOrderPayRefreshCost()
	local homeCurrencyId = HomelandConfigData.homeCurrencyId

	if homeCurrencyId and type(pg.me.getItemCountById) == "function" then
		local have = HomeCmdImplement._safeCall(function()
			return pg.me:getItemCountById(homeCurrencyId, false)
		end) or 0

		if have < payRefreshCost then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home currency insufficient for pay refresh: have=" .. have .. " need=" .. payRefreshCost .. " (currencyItemId=" .. tostring(homeCurrencyId) .. ")")
		end
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me:reqPayRefreshHomeOrder(order.serverIndex)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "reqPayRefreshHomeOrder failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		refreshMode = "paid",
		serverIndex = order.serverIndex,
		orderId = order.orderId,
		orderName = order.orderName,
		payRefreshCost = payRefreshCost
	})
end

function HomeCmdImplement.setFacilityPause(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId
	local paused = params and params.paused

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	if type(paused) ~= "boolean" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.paused must be boolean")
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.space:setProduceDisable(fid, paused)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "setProduceDisable failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		facilityId = fid,
		paused = paused
	})
end

function HomeCmdImplement.setFacilityElectricMode(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId
	local enable = params and params.enable

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	if type(enable) ~= "boolean" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.enable must be boolean")
	end

	if not pg.space or not pg.space.ornament or not pg.space.ornament[fid] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament not found: " .. tostring(fid))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:setProduceElectricMode(fid, enable)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "setProduceElectricMode failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		facilityId = fid,
		enable = enable
	})
end

function HomeCmdImplement.placeFacility(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local valid, placement = HomeCmdImplement._validatePlacement(params)

	if not valid then
		return HomeCmdImplement._placementFailureToErr(placement)
	end

	if HomeCmdImplement._isAddOrnamentLocked() then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "previous addOrnament RPC still pending, retry in a moment (lock auto-releases within 5s)")
	end

	HomeCmdImplement._ensureOrnamentCallbackHooks()

	local sinceSeq = HomeCmdImplement._getOrnamentResultRing().seq
	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:addOrnament(placement.homeTemplateId, placement.pos, placement.rotation, placement.scale)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "addOrnament failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		callbackHint = "home.getLastOrnamentResult",
		callbackWaitSeconds = 2,
		homeTemplateId = placement.homeTemplateId,
		position = placement.position,
		yawAngle = placement.yawAngle,
		callbackSinceSeq = sinceSeq
	})
end

function HomeCmdImplement.checkPlacement(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local valid, result = HomeCmdImplement._validatePlacement(params)

	if valid then
		return HomeCmdImplement._ok({
			valid = true,
			reason = "可以放置"
		})
	end

	return HomeCmdImplement._ok({
		valid = false,
		reasonCode = result.reasonCode,
		reason = result.reason,
		collision = result.collision
	})
end

function HomeCmdImplement.moveFacility(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	local ornamentInfo = pg.space and pg.space.ornament and pg.space.ornament[fid]

	if not ornamentInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament not found: " .. tostring(fid))
	end

	local pos = HomeCmdImplement._toXYZArray(params and params.position)

	if not pos then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.position must be {x, y, z} numbers")
	end

	local currentScale = HomeCmdImplement._safeCall(function()
		return ornamentInfo:getScale()
	end)
	local requestedScale = HomeCmdImplement._toXYZArray(params and params.scale)
	local scale = requestedScale or HomeCmdImplement._scaleArrayFromAny(currentScale, {
		1,
		1,
		1
	})
	local yawAngle = params and type(params.yawAngle) == "number" and params.yawAngle or nil
	local currentRotation = HomeCmdImplement._safeCall(function()
		return ornamentInfo:getRotation()
	end)
	local valid, placement = HomeCmdImplement._validatePlacement({
		homeTemplateId = ornamentInfo.homeId,
		position = HomeCmdImplement._positionDataFromArray(pos),
		yawAngle = yawAngle,
		scale = HomeCmdImplement._positionDataFromArray(scale),
		excludeFacilityId = fid
	}, {
		skipInventory = true,
		skipCount = true,
		excludeFacilityId = fid,
		defaultRotation = currentRotation
	})

	if not valid then
		return HomeCmdImplement._placementFailureToErr(placement)
	end

	local rotation

	if yawAngle ~= nil then
		rotation = HomeCmdImplement._makeYawQuaternion(yawAngle)

		if not rotation then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "construct Quaternion failed (CS.UnityEngine.Quaternion unavailable)")
		end
	end

	HomeCmdImplement._ensureOrnamentCallbackHooks()

	local sinceSeq = HomeCmdImplement._getOrnamentResultRing().seq
	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:updateOrnament(fid, placement.pos, rotation, requestedScale and placement.scale or nil)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "updateOrnament failed: " .. tostring(errMsg))
	end

	local data = {
		callbackHint = "home.getLastOrnamentResult",
		callbackWaitSeconds = 2,
		facilityId = fid,
		position = placement.position,
		callbackSinceSeq = sinceSeq
	}

	if yawAngle ~= nil then
		data.yawAngle = yawAngle
	end

	return HomeCmdImplement._asyncOk(data)
end

function HomeCmdImplement.recycleFacility(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	local ornamentInfo = pg.space and pg.space.ornament and pg.space.ornament[fid]

	if not ornamentInfo then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "ornament not found: " .. tostring(fid))
	end

	if pg.me.checkHomelandRemoveOrnament and not pg.me:checkHomelandRemoveOrnament(fid, ornamentInfo) then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "checkHomelandRemoveOrnament failed: " .. tostring(fid))
	end

	HomeCmdImplement._ensureOrnamentCallbackHooks()

	local sinceSeq = HomeCmdImplement._getOrnamentResultRing().seq
	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:removeOrnament(fid)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "removeOrnament failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		callbackHint = "home.getLastOrnamentResult",
		callbackWaitSeconds = 2,
		facilityId = fid,
		callbackSinceSeq = sinceSeq
	})
end

function HomeCmdImplement.upgradeFacility(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local fid = params and params.facilityId

	if fid == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.facilityId")
	end

	local facility = HomeCmdImplement._serializeFacility(fid)

	if not facility then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility not found: " .. tostring(fid))
	end

	local plan = HomeCmdImplement._buildSingleFacilityUpgradePlan(facility)

	if plan.status ~= "ready" or not plan.upgradeHomeTemplateId then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, plan.reason or "facility upgrade blocked")
	end

	local expectedUpgradeId = params and params.upgradeHomeTemplateId or nil

	if expectedUpgradeId ~= nil and expectedUpgradeId ~= plan.upgradeHomeTemplateId then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "upgradeHomeTemplateId mismatch: expected=" .. tostring(plan.upgradeHomeTemplateId) .. " actual=" .. tostring(expectedUpgradeId))
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:upgradeOrnament(fid, plan.upgradeHomeTemplateId)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "upgradeOrnament failed: " .. tostring(errMsg))
	end

	return HomeCmdImplement._asyncOk({
		facilityId = fid,
		homeTemplateId = plan.homeTemplateId,
		upgradeHomeTemplateId = plan.upgradeHomeTemplateId,
		level = plan.level,
		nextLevel = plan.nextLevel,
		materialCosts = plan.materialCosts or {}
	})
end

function HomeCmdImplement.curePetAbnormal(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local petId = params and params.petId

	if petId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "not_implemented: curePetAbnormal is a placeholder, business API not finalized")
end

function HomeCmdImplement._getPlacementThreshold(homeTemplateId)
	local homeRow = HomeObjectData[homeTemplateId]
	local boundSize = homeRow and homeRow.boundSize or nil

	if type(boundSize) ~= "table" then
		return 1, 0, 0
	end

	local halfX = (boundSize[1] or 0) * 0.5
	local halfZ = (boundSize[2] or 0) * 0.5
	local threshold = math.max(1, halfX, halfZ)

	return threshold, halfX, halfZ
end

function HomeCmdImplement._findPlacementPointInZone(zone, homeTemplateId)
	if not zone or not zone.min or not zone.max or not zone.center then
		return nil
	end

	local threshold, halfX, halfZ = HomeCmdImplement._getPlacementThreshold(homeTemplateId)
	local minX = (zone.min.x or 0) + halfX
	local maxX = (zone.max.x or 0) - halfX
	local minZ = (zone.min.z or 0) + halfZ
	local maxZ = (zone.max.z or 0) - halfZ

	if maxX < minX or maxZ < minZ then
		return nil
	end

	local centerX = zone.center.x or 0
	local centerZ = zone.center.z or 0
	local step = math.max(1, threshold)

	local function tryPoint(x, z)
		if x < minX or x > maxX or z < minZ or z > maxZ then
			return nil
		end

		local valid = HomeCmdImplement._validatePlacement({
			yawAngle = 0,
			homeTemplateId = homeTemplateId,
			position = {
				y = 0,
				x = x,
				z = z
			}
		}, {
			skipInventory = true,
			skipCount = true
		})

		if not valid then
			return nil
		end

		return {
			y = 0,
			x = x,
			z = z
		}
	end

	local direct = tryPoint(centerX, centerZ)

	if direct then
		return direct
	end

	local rangeX = math.max(maxX - minX, 0)
	local rangeZ = math.max(maxZ - minZ, 0)
	local maxRing = math.ceil(math.max(rangeX, rangeZ) / step)

	for r = 1, maxRing do
		local d = r * step
		local x = centerX - d

		while x <= centerX + d + 0.0001 do
			local p = tryPoint(x, centerZ - d) or tryPoint(x, centerZ + d)

			if p then
				return p
			end

			x = x + step
		end

		local z = centerZ - d + step

		while z <= centerZ + d - step + 0.0001 do
			local p = tryPoint(centerX - d, z) or tryPoint(centerX + d, z)

			if p then
				return p
			end

			z = z + step
		end
	end

	return nil
end

function HomeCmdImplement.findPlacementPoint(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local zoneId = params and params.zoneId
	local homeId = params and params.homeTemplateId

	if zoneId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.zoneId")
	end

	if homeId == nil then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.homeTemplateId")
	end

	if not HomeObjectData[homeId] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home_object_data row not found: " .. tostring(homeId))
	end

	local boundsResult = HomeCmdImplement.getZoneBounds(nil, nil, {})

	if not boundsResult.ok then
		return boundsResult
	end

	local zone

	for _, z in ipairs(boundsResult.data.zones or EMPTY_TABLE) do
		if z.zoneId == zoneId then
			zone = z

			break
		end
	end

	if not zone then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "zoneId not found: " .. tostring(zoneId))
	end

	if zone.unlocked == false then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "zone not unlocked: " .. tostring(zoneId))
	end

	local staticValid, staticCheck = HomeCmdImplement._validatePlacement({
		yawAngle = 0,
		homeTemplateId = homeId,
		position = {
			y = 0,
			x = zone.center.x or 0,
			z = zone.center.z or 0
		}
	}, {
		skipCollision = true,
		skipBounds = true
	})

	if not staticValid then
		return HomeCmdImplement._ok({
			found = false,
			zoneId = zoneId,
			homeTemplateId = homeId,
			reasonCode = staticCheck.reasonCode,
			reason = staticCheck.reason
		})
	end

	local point = HomeCmdImplement._findPlacementPointInZone(zone, homeId)

	if not point then
		return HomeCmdImplement._ok({
			reason = "no available placement point in this zone (boundSize too large or zone fully occupied)",
			found = false,
			zoneId = zoneId,
			homeTemplateId = homeId
		})
	end

	local threshold = HomeCmdImplement._getPlacementThreshold(homeId)

	return HomeCmdImplement._ok({
		found = true,
		zoneId = zoneId,
		homeTemplateId = homeId,
		position = point,
		threshold = threshold
	})
end

function HomeCmdImplement.queryDecorItems(self_, connId, params)
	params = params or {}

	local filterEnt = params.entType
	local filterSub = params.subEntType
	local ownedOnly = params.ownedOnly == true
	local list = {}

	for homeId, row in pairs(HomeObjectData) do
		local matchEnt = filterEnt == nil or row.entType == filterEnt
		local matchSub = filterSub == nil or row.subEntType == filterSub

		if matchEnt and matchSub then
			local bagCount = 0

			if pg.me and type(pg.me.getItemCountById) == "function" then
				bagCount = HomeCmdImplement._safeCall(function()
					return pg.me:getItemCountById(homeId, false)
				end) or 0
			end

			if not ownedOnly or (bagCount or 0) > 0 then
				list[#list + 1] = {
					homeTemplateId = homeId,
					entType = row.entType,
					subEntType = row.subEntType,
					name = HomeCmdImplement._localize(row.name),
					bagCount = bagCount,
					canHomePlace = row.canHomePlace,
					maxNum = row.maxNum
				}
			end
		end
	end

	table.sort(list, function(a, b)
		return (a.homeTemplateId or 0) < (b.homeTemplateId or 0)
	end)

	return HomeCmdImplement._ok({
		items = list,
		total = #list
	})
end

function HomeCmdImplement.resolveName(self_, connId, params)
	params = params or {}

	local name = params.name

	if type(name) ~= "string" or name == "" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.name")
	end

	local typeFilter = params.type or "any"
	local validTypes = {
		item = true,
		facility = true,
		any = true,
		pet = true
	}

	if not validTypes[typeFilter] then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.type must be item/facility/pet/any")
	end

	local limit = math.min(math.max(tonumber(params.limit) or 8, 1), 20)
	local exact, contains, seen = {}, {}, {}

	local function addMatch(id, localizedName, kind, sourceType, source)
		local key = tostring(sourceType) .. ":" .. tostring(id) .. ":" .. tostring(localizedName)

		if seen[key] then
			return
		end

		seen[key] = true

		local entry = {
			id = id,
			name = localizedName,
			type = sourceType,
			matchKind = kind
		}

		if source then
			entry.source = source
		end

		if kind == "exact" then
			exact[#exact + 1] = entry
		else
			contains[#contains + 1] = entry
		end
	end

	if typeFilter == "any" or typeFilter == "item" then
		for itemId in pairs(ItemData) do
			local row = ItemData[itemId]

			if HomeCmdImplement._isTableLike(row) then
				local n = HomeCmdImplement._localize(row.itemName)

				if type(n) == "string" then
					if n == name then
						addMatch(itemId, n, "exact", "item")
					elseif string.find(n, name, 1, true) then
						addMatch(itemId, n, "contains", "item")
					end
				end
			end
		end

		for homeId in pairs(HomeObjectData) do
			local row = HomeObjectData[homeId]

			if ItemData[homeId] ~= nil and HomeCmdImplement._isTableLike(row) then
				local names = {}
				local n = HomeCmdImplement._localize(row.name)

				if type(n) == "string" then
					names[#names + 1] = n
				end

				local placeRows = row.placeId and HomeObjectPlaceData[row.placeId] or nil

				if HomeCmdImplement._isTableLike(placeRows) then
					for _, placeRow in pairs(placeRows) do
						local pn = HomeCmdImplement._isTableLike(placeRow) and HomeCmdImplement._localize(placeRow.name) or nil

						if type(pn) == "string" then
							names[#names + 1] = pn
						end
					end
				end

				for _, n2 in ipairs(names) do
					if n2 == name then
						addMatch(homeId, n2, "exact", "item", "home_object_data")
					elseif string.find(n2, name, 1, true) then
						addMatch(homeId, n2, "contains", "item", "home_object_data")
					end
				end
			end
		end
	end

	if typeFilter == "any" or typeFilter == "facility" then
		for homeId in pairs(HomeObjectData) do
			local row = HomeObjectData[homeId]

			if HomeCmdImplement._isTableLike(row) then
				local n = HomeCmdImplement._localize(row.name)

				if type(n) == "string" then
					if n == name then
						addMatch(homeId, n, "exact", "facility")
					elseif string.find(n, name, 1, true) then
						addMatch(homeId, n, "contains", "facility")
					end
				end
			end
		end
	end

	if typeFilter == "any" or typeFilter == "pet" then
		for petTplId in pairs(PetData) do
			local row = PetData[petTplId]

			if HomeCmdImplement._isTableLike(row) then
				local n = HomeCmdImplement._localize(row.name)

				if type(n) == "string" then
					if n == name then
						addMatch(petTplId, n, "exact", "pet")
					elseif string.find(n, name, 1, true) then
						addMatch(petTplId, n, "contains", "pet")
					end
				end
			end
		end
	end

	local matches = {}

	for _, e in ipairs(exact) do
		if limit <= #matches then
			break
		end

		matches[#matches + 1] = e
	end

	for _, e in ipairs(contains) do
		if limit <= #matches then
			break
		end

		matches[#matches + 1] = e
	end

	return HomeCmdImplement._ok({
		matches = matches,
		total = #matches,
		ambiguous = #matches > 1
	})
end

function HomeCmdImplement._getHomeTemplateIdsByFacilityTemplate(facilityTemplateId)
	local ids = {}

	for homeId, row in pairs(HomeObjectData) do
		if HomeCmdImplement._isTableLike(row) then
			local mappedId = row.facilityId

			if not mappedId and type(Utils.getHomeObjectFacilityId) == "function" then
				mappedId = HomeCmdImplement._safeCall(function()
					return Utils.getHomeObjectFacilityId(homeId)
				end)
			end

			if mappedId == facilityTemplateId then
				ids[#ids + 1] = homeId
			end
		end
	end

	table.sort(ids)

	return ids
end

function HomeCmdImplement.findFormulasByOutput(self_, connId, params)
	params = params or {}

	local itemId = params.itemId

	if type(itemId) ~= "number" then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.itemId")
	end

	local formulas = {}

	for fid in pairs(HomelandFormulaData) do
		local frow = HomelandFormulaData[fid]

		if HomeCmdImplement._isTableLike(frow) then
			local outputs = HomeCmdImplement._collectFormulaOutputs(frow)

			for _, outputItem in ipairs(outputs) do
				if outputItem.itemId == itemId then
					local envDesc = HomeCmdImplement._buildEnvRequirementsDesc(frow)

					formulas[#formulas + 1] = {
						formulaId = fid,
						output = outputItem.itemId,
						outputNum = outputItem.count,
						timeCost = frow.timeCost or frow.time,
						inputs = HomeCmdImplement._collectFormulaConsumables(frow),
						workload = frow.workload,
						envRequirementsDesc = envDesc,
						needsEnvironment = envDesc and envDesc.needsEnvironment or false
					}

					break
				end
			end
		end
	end

	table.sort(formulas, function(a, b)
		return (a.formulaId or 0) < (b.formulaId or 0)
	end)

	for _, fEntry in ipairs(formulas) do
		local supporting = {}

		for facTplId in pairs(HomelandFacilityData) do
			local facRow = HomelandFacilityData[facTplId]

			if HomeCmdImplement._isTableLike(facRow) and HomeCmdImplement._isTableLike(facRow.formulaList) then
				for _, fid in ipairs(facRow.formulaList) do
					if fid == fEntry.formulaId then
						local homeTemplateIds = HomeCmdImplement._getHomeTemplateIdsByFacilityTemplate(facTplId)

						supporting[#supporting + 1] = {
							homeTemplateId = homeTemplateIds[1],
							homeTemplateIds = homeTemplateIds,
							facilityTemplateId = facTplId,
							facilityTypeName = facRow.typeName,
							facilityLevel = facRow.facilityLevel,
							facilityType = facRow.facilityType
						}

						break
					end
				end
			end
		end

		table.sort(supporting, function(a, b)
			return (a.facilityTemplateId or 0) < (b.facilityTemplateId or 0)
		end)

		fEntry.supportingFacilities = supporting
	end

	return HomeCmdImplement._ok({
		formulas = formulas,
		total = #formulas
	})
end

function HomeCmdImplement.upgradeCar(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local compId = params.compId
	local opCode, opParams

	if compId == nil then
		opCode = OpDef.OP.CS_HC_UpgradeCar
		opParams = {}
	else
		if type(compId) ~= "number" then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.compId must be integer")
		end

		opCode = OpDef.OP.CS_HC_UpgradeCarComp
		opParams = {
			compId = compId
		}
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me:requestHomeCampOp(opCode, opParams)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "requestHomeCampOp failed: " .. tostring(errMsg))
	end

	local data = {}

	if compId ~= nil then
		data.compId = compId
	end

	return HomeCmdImplement._asyncOk(data)
end

function HomeCmdImplement.placeOrnamentBatch(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local items = params and params.items

	if type(items) ~= "table" or #items <= 0 then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.items must be non-empty array")
	end

	local prepared = {}
	local countsByHomeId = {}
	local bagNeededByHomeId = {}

	for i, item in ipairs(items) do
		local homeId = item and item.homeTemplateId

		if homeId == nil then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: missing homeTemplateId")
		end

		if not HomeObjectData[homeId] then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: home_object_data row not found: " .. tostring(homeId))
		end

		local pos = HomeCmdImplement._toXYZArray(item.position)

		if not pos then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: position must be {x,y,z} numbers")
		end

		local scale = HomeCmdImplement._toXYZArray(item.scale, {
			1,
			1,
			1
		})
		local yawAngle = type(item.yawAngle) == "number" and item.yawAngle or 0
		local placedInBatch = countsByHomeId[homeId] or 0
		local maxNum = HomeCmdImplement._getFacilityMaxNum(homeId)

		if maxNum then
			local cur = HomeCmdImplement._countFacilityByHomeId(homeId)
			local future = cur + placedInBatch + 1

			if maxNum < future then
				return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: facility count limit will be exceeded: " .. future .. "/" .. maxNum)
			end
		end

		local bagNeeded = bagNeededByHomeId[homeId] or 0

		if bagNeeded == 0 and pg.me and type(pg.me.getItemCountById) == "function" then
			local bagCount = HomeCmdImplement._safeCall(function()
				return pg.me:getItemCountById(homeId, false)
			end) or 0

			bagNeededByHomeId[homeId] = bagCount
			bagNeeded = bagCount
		end

		if bagNeeded < placedInBatch + 1 then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: inventory short for homeTemplateId=" .. tostring(homeId) .. " (need=" .. placedInBatch + 1 .. ", have=" .. bagNeeded .. ")")
		end

		countsByHomeId[homeId] = placedInBatch + 1

		local valid, placement = HomeCmdImplement._validatePlacement({
			homeTemplateId = homeId,
			position = HomeCmdImplement._positionDataFromArray(pos),
			yawAngle = yawAngle,
			scale = HomeCmdImplement._positionDataFromArray(scale)
		}, {
			skipInventory = true,
			skipCount = true
		})

		if not valid then
			return HomeCmdImplement._placementFailureToErr(placement, "items[" .. i .. "]")
		end

		local batchHit = HomeCmdImplement._findCollidePreparedPlacement(placement, prepared)

		if batchHit then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: position collides with items[" .. batchHit .. "] within this batch")
		end

		prepared[#prepared + 1] = placement
	end

	if HomeCmdImplement._isAddOrnamentLocked() then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "previous addOrnament RPC still pending, retry in a moment (lock auto-releases within 5s)")
	end

	HomeCmdImplement._ensureOrnamentCallbackHooks()

	local sinceSeq = HomeCmdImplement._getOrnamentResultRing().seq
	local createList = {}

	for _, p in ipairs(prepared) do
		createList[#createList + 1] = {
			homeTemplateId = p.homeId,
			position = p.pos,
			rotation = p.rotation,
			scale = p.scale
		}
	end

	local _, errMsg = HomeCmdImplement._safeCall(function()
		pg.me.space:addOrnaments(createList)
	end)

	if errMsg then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "addOrnaments failed: " .. tostring(errMsg))
	end

	local dispatched = {}

	for _, p in ipairs(prepared) do
		dispatched[#dispatched + 1] = {
			homeTemplateId = p.homeId,
			position = {
				x = p.pos[1],
				y = p.pos[2],
				z = p.pos[3]
			},
			yawAngle = p.yawAngle
		}
	end

	return HomeCmdImplement._asyncOk({
		callbackWaitSeconds = 2,
		callbackHint = "home.getLastOrnamentResult",
		count = #dispatched,
		items = dispatched,
		callbackSinceSeq = sinceSeq
	})
end

function HomeCmdImplement.moveOrnamentBatch(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local items = params and params.items

	if type(items) ~= "table" or #items <= 0 then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.items must be non-empty array")
	end

	local movingIds = {}

	for _, item in ipairs(items) do
		if item and item.facilityId ~= nil then
			movingIds[#movingIds + 1] = item.facilityId
		end
	end

	local prepared = {}

	for i, item in ipairs(items) do
		local fid = item and item.facilityId

		if fid == nil then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: missing facilityId")
		end

		local ornamentInfo = pg.space and pg.space.ornament and pg.space.ornament[fid]

		if not ornamentInfo then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: ornament not found: " .. tostring(fid))
		end

		local pos = HomeCmdImplement._toXYZArray(item.position)

		if not pos then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: position must be {x,y,z} numbers")
		end

		local currentScale = HomeCmdImplement._safeCall(function()
			return ornamentInfo:getScale()
		end)
		local requestedScale = HomeCmdImplement._toXYZArray(item.scale)
		local scale = requestedScale or HomeCmdImplement._scaleArrayFromAny(currentScale, {
			1,
			1,
			1
		})
		local yawAngle = type(item.yawAngle) == "number" and item.yawAngle or nil
		local currentRotation = HomeCmdImplement._safeCall(function()
			return ornamentInfo:getRotation()
		end)
		local valid, placement = HomeCmdImplement._validatePlacement({
			homeTemplateId = ornamentInfo.homeId,
			position = HomeCmdImplement._positionDataFromArray(pos),
			yawAngle = yawAngle,
			scale = HomeCmdImplement._positionDataFromArray(scale),
			excludeFacilityId = fid
		}, {
			skipInventory = true,
			skipCount = true,
			excludeFacilityIds = movingIds,
			defaultRotation = currentRotation
		})

		if not valid then
			return HomeCmdImplement._placementFailureToErr(placement, "items[" .. i .. "]")
		end

		local batchHit = HomeCmdImplement._findCollidePreparedPlacement(placement, prepared)

		if batchHit then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "items[" .. i .. "]: position collides with items[" .. batchHit .. "] within this batch")
		end

		local rotation

		if yawAngle ~= nil then
			rotation = HomeCmdImplement._makeYawQuaternion(yawAngle)

			if not rotation then
				return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "items[" .. i .. "]: construct Quaternion failed")
			end
		end

		prepared[#prepared + 1] = {
			facilityId = fid,
			pos = placement.pos,
			scale = requestedScale and placement.scale or nil,
			yawAngle = yawAngle,
			rotation = rotation,
			geometry = placement.geometry
		}
	end

	HomeCmdImplement._ensureOrnamentCallbackHooks()

	local sinceSeq = HomeCmdImplement._getOrnamentResultRing().seq
	local dispatched = {}

	for i, p in ipairs(prepared) do
		local _, errMsg = HomeCmdImplement._safeCall(function()
			pg.me.space:updateOrnament(p.facilityId, p.pos, p.rotation, p.scale)
		end)

		if errMsg then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "items[" .. i .. "]: updateOrnament failed: " .. tostring(errMsg) .. " (already dispatched: " .. #dispatched .. ")")
		end

		local entry = {
			facilityId = p.facilityId,
			position = {
				x = p.pos[1],
				y = p.pos[2],
				z = p.pos[3]
			}
		}

		if p.yawAngle ~= nil then
			entry.yawAngle = p.yawAngle
		end

		dispatched[#dispatched + 1] = entry
	end

	return HomeCmdImplement._asyncOk({
		callbackWaitSeconds = 2,
		callbackHint = "home.getLastOrnamentResult",
		count = #dispatched,
		items = dispatched,
		callbackSinceSeq = sinceSeq
	})
end

function HomeCmdImplement.recycleOrnamentBatch(self_, connId, params)
	local err = HomeCmdImplement._requireHomeland()

	if err then
		return err
	end

	local ids = params and params.facilityIds

	if type(ids) ~= "table" or #ids <= 0 then
		return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.facilityIds must be non-empty array")
	end

	for i, fid in ipairs(ids) do
		if type(fid) ~= "number" then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facilityIds[" .. i .. "]: must be integer")
		end

		if not pg.space or not pg.space.ornament or not pg.space.ornament[fid] then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facilityIds[" .. i .. "]: ornament not found: " .. tostring(fid))
		end

		if pg.me.checkHomelandRemoveOrnament and not pg.me:checkHomelandRemoveOrnament(fid) then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facilityIds[" .. i .. "]: checkHomelandRemoveOrnament rejected: " .. tostring(fid))
		end
	end

	HomeCmdImplement._ensureOrnamentCallbackHooks()

	local sinceSeq = HomeCmdImplement._getOrnamentResultRing().seq
	local dispatched = {}

	for i, fid in ipairs(ids) do
		local _, errMsg = HomeCmdImplement._safeCall(function()
			pg.me.space:removeOrnament(fid)
		end)

		if errMsg then
			return HomeCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "facilityIds[" .. i .. "]: removeOrnament failed: " .. tostring(errMsg) .. " (already dispatched: " .. #dispatched .. ")")
		end

		dispatched[#dispatched + 1] = fid
	end

	return HomeCmdImplement._asyncOk({
		callbackWaitSeconds = 2,
		callbackHint = "home.getLastOrnamentResult",
		count = #dispatched,
		facilityIds = dispatched,
		callbackSinceSeq = sinceSeq
	})
end

return HomeCmdImplement
