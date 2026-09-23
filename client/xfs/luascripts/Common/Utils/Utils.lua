-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\Utils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local SafeCallbackWithReturn = require("Core.Framework.SafeCallbackWithReturn")
local IDManager = require("Core.Common.IDManager")
local RandomString = require("Core.Common.RandomString")
local CoreConst = require("Core.Common.Const")
local Const = require("Common.Const.Const")
local logger = LoggerManager.getLogger("Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local AccessControl = require("Core.Framework.AccessControl")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local NoticeDef = require("Common.NoticeDef")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AoiLodConst = require("Common.Const.AoiLodConst")
local TriggerConst = require("Common.Const.TriggerConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local SceneSeamlessData = require("Data.scene_seamless_data")
local AreaNavTransitData = require("Data.area_nav_transit_data")
local GmConst = require("Common.Const.GmConst")
local CommonSwitch = require("Common.CommonSwitch")
local VehicleData = require("Data.vehicle_data")
local json = require("json")
local InfoStampAnimationConfigData = require("Data.info_stamp_animation_config_data")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local GameEventData = require("Data.game_event_data")
local SeasonStageTimelineData = require("Data.season_stage_timeline_data")
local CommonTimeConfigData = require("Data.common_time_config_data")
local PetBasePropAttrNames = require("Data.pet_base_prop_attr_names")
local PetFamilyData = require("Data.pet_family_data")
local ExchangePetData = require("Data.exchange_pet_data")
local GivePetData = require("Data.send_pet_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local ArkSendRewardData = require("Data.ark_send_reward_data")
local PetSkillData = require("Data.pet_skill_data")
local camp_data = require("Data.camp_data")
local tempCampData = require("Data.temp_camp_data")
local ElementAgainstData = require("Data.real_element_against")
local PetData = require("Data.pet_data")
local PuppetData = require("Data.puppet_data")
local CreationData = require("Data.creation_data")
local RigidbodyData = require("Data.rigidbody_data")
local ItemEffectData = require("Data.item_effect_data")
local MatchRuleData = require("Data.match_rule_data")
local SceneData = require("Data.scene_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local PetFeedData = require("Data.pet_feed_data")
local PetExerciseData = require("Data.pet_exercise_data")
local PetBreedData = require("Data.pet_breed_data")
local ChestData = require("Data.chest_data")
local DropData = require("Data.drop_data")
local LimitData = require("Data.limit_data")
local PropertyData = require("Data.property_data")
local PetConfigData = require("Data.pet_config_data")
local NpcFuncData = require("Data.npc_func_data")
local FormulaData = require("Data.formula_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local ItemData = require("Data.item_data")
local ItemObjectBindingData = require("Data.item_object_binding_data")
local EnvObjData = require("Data.envobj_data")
local CastItemData = require("Data.cast_item_data")
local EntityTagData = require("Data.entity_tag_data")
local EntityTagIndexData = require("Data.entity_tag_to_index_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local SandboxConst = require("Common.Const.SandboxConst")
local MapAreaData = require("Data.map_area_config_data")
local MapBlockPosData = require("Data.map_block_pos_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local SceneToFormalBlockIds = require("Data.scene_to_formal_blockId_data")
local SysConfigData = require("Data.sys_config_data")
local ServerEventConst = require("Const.ServerEventConst")
local Bitset = require("Common.Bitset")
local PetEthnicGroupData = require("Data.pet_ethnic_group_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetFormTypeData = require("Data.pet_form_type_data")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local PetFeedItemData = require("Data.pet_feed_item_data")
local PetBallData = require("Data.pet_ball_data")
local PetLevelData = require("Data.pet_level_data")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local RandomMapBatchUtils = require("Common.Utils.RandomMapBatchUtils")
local WorkShopConsumeData = require("Data.design_workshop_consume_data")
local PetCharacterData = require("Data.pet_character_data")
local LevelData = require("Data.level_data")
local PetPropLevelData = require("Data.pet_prop_level_data")
local PetPropLevelMax = require("Data.pet_prop_level_max")
local NpcFuncConfigData = require("Data.npc_func_config_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetResearchSpeciesCountrySet = require("Data.pet_research_species_country_set")
local EMPTY_PET_COUNTRY_ID_SET = {}
local PetTalentData = require("Data.pet_talent_data")
local CatchProbData = require("Data.catch_prob_data")
local Time = require("Core.Common.Time")
local MapLineConfigData = require("Data.map_line_config_data")
local PlayerTitleData = require("Data.player_title_data")
local PlayerLevelData = require("Data.player_level_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local NpcIdData = require("Data.npc_id_data")
local TargetPositionData = require("Common.Data.Scene.scene_target_position_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetAllPrototypeList = require("Data.pet_all_prototype_list")
local PetAvatarData = require("Data.pet_avatar_data")
local AttributeEntryData = require("Data.attribute_entry_data")
local PetToPuppetCatchMap = require("Data.pet_to_puppet_catch_map")
local HomeObjectData = require("Data.home_object_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandUpgradeData = require("Data.home_upgrade_data")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandItemToMaterialData = require("Data.homeland_item_to_material_data")
local HomelandMaterialConfigData = require("Data.homeland_material_config_data")
local FriendshipLevelUpData = require("Data.friendship_level_up_data")
local PetFormChangeData = require("Data.pet_form_change_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local CatchDisplayData = require("Data.catch_display_data")
local CollectItemData = require("Data.collect_item_data")
local PetBodyEntryData = require("Data.pet_body_entry_data")
local CoreCarryData = require("Data.core_carry_data")
local AttributeGroupData = require("Data.attribute_group_data")
local PriProRevertData = require("Data.primaryproperty_revert_data")
local PetAttrConvertData = require("Data.pet_attr_convert_data")
local ResonanceData = require("Data.pet_resonance_data")
local PetPropLearnData = require("Data.pet_prop_learn_data")
local HomelandFormulaRandomData = require("Data.homeland_formula_random_data")
local PetTalentRandomGroupData = require("Data.pet_talent_random_group_data")
local PetEvolveData = require("Data.pet_evolve_data")
local PetTalentStageWeightRevertData = require("Data.pet_talent_stage_weight_revert_data")
local HomelandRandomTypeData = require("Data.homeland_formula_random_type_data")
local HomelandRandomAddData = require("Data.homeland_formula_random_add_data")
local RobEggBaseData = require("Data.rob_egg_base_data")
local GuidenceItemData = require("Data.guidence_item_data")
local MapTideData = require("Data.map_tide_data")
local CurrencyAutoData = require("Data.currency_auto_change_data")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local LeylineFlowerConst = require("Common.Const.LeylineFlowerConst")
local ShopMallCommodityData = require("Data.shopmall_commodity_data")
local ShopMallCommodityTabData = require("Data.shopmall_commodity_tab_data")
local ShopMallGiftData = require("Data.shopmall_gift_data")
local RebateGearData = require("Data.rechage_rebate_gear_data")
local ShopmallRechargeData = require("Data.shopmall_recharge_data")
local ActivityConst = require("Common.Const.ActivityConst")
local PetTalentAllWeightData = require("Data.pet_talent_all_weight_data")
local BaseProperty = require("CustomTypes.BaseProperty")
local PetFriendTradeUtils = require("Common.Utils.PetFriendTradeUtils")
local SceneToLeylineTreeData = require("Data.scene_to_leylineTree_data")
local TablePool = require("Common.Container.TablePool")
local ListPool = require("Common.Container.ListPool")
local PetShinyStyleData = require("Data.pet_shiny_style_data")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local LanguageAssociateData = require("Data.language_associate_data")
local ReviewRiskControlCallbackData = require("Data.review_risk_control_callback_data")
local SANDBOX_TYPE = SandboxConst.SANDBOX_TYPE
local AUTO_LOAD = SandboxConst.AUTO_LOAD
local SIGHT_LEVEL = SandboxConst.SIGHT_LEVEL
local math_abs = math.abs
local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local lume_random = lume.random
local bit = bit
local unpack = unpack
local Vector3 = Vector3
local pg = pg
local Utils = {}

function Utils.getParamNumber(params, key, defaultValue)
	local value = params[key]

	if value == nil or value == "nil" or value == "" then
		return defaultValue
	end

	return tonumber(value) or defaultValue
end

function Utils.isPositiveInteger(value)
	return type(value) == "number" and value > 0 and value < math.huge and value == math_floor(value)
end

function Utils.getParamString(params, key, defaultValue)
	local value = params[key]

	if value == nil or value == "nil" or value == "" then
		return defaultValue
	end

	return tostring(value)
end

function Utils.getParamValue(params, key, defaultValue)
	local value = params[key]

	if value == nil or value == "nil" or value == "" then
		return defaultValue
	end

	return value
end

local lshift = Bitset.lshift
local rshift = Bitset.rshift
local band = Bitset.band
local getBit = Bitset.getBit
local SHIFT = 10
local SHIFT_MASK = 1023
local TILE_DELTA = 995
local MARKER_TILE_DELTA = 1024
local ACTOR_TYPE_PET = Const.ACTOR_TYPE_PET

function Utils.isEmptyTable(t)
	return next(t) == nil
end

function Utils.safeUnpack(t)
	if type(t) == "table" or type(t) == "userdata" and t._BddData_ == true then
		return unpack(t, 1, lume.getListLenWithNil(t))
	end

	return t
end

function Utils.callMsg(ent, msgName, msgParams)
	local rpcMethod = ent and ent[msgName]

	if rpcMethod == nil then
		return
	end

	local method = ent[rpcMethod.originFuncName]

	if type(method) ~= "function" then
		return
	end

	return method(ent, Utils.safeUnpack(msgParams))
end

local _sceneTypes = {}

setmetatable(_sceneTypes, {
	__index = function(t, sceneId)
		local sceneType = Utils.getSpaceTypeEx(sceneId)

		rawset(t, sceneId, sceneType)

		return sceneType
	end
})

function Utils.getSpaceTypeEx(sceneId)
	local scene = SceneData[sceneId]

	if scene then
		return scene.type
	end

	return Const.SPACE_TYPE_SINGLEWORLD
end

function Utils.getSpaceType(sceneId)
	return _sceneTypes[sceneId]
end

function Utils.canLoadTile(spaceType, sceneId)
	return spaceType == Const.SPACE_TYPE_SINGLEWORLD or spaceType == Const.SPACE_TYPE_ROBEGG or sceneId == Const.SCENE_ID.ARK
end

function Utils.getSpaceTile(sceneId, posX, posZ)
	local tile_size = AoiLodConst.SPACE_TILE_SIZE
	local tileX = math.floor(posX / tile_size)
	local tileZ = math.floor(posZ / tile_size)
	local tileKey = Utils.getTileKey(tileX, tileZ)

	return tileKey, tileX, tileZ
end

function Utils.getSpaceMarkerTile(posX, posZ)
	local tile_size = AoiLodConst.SPACE_MARKER_TILE_SIZE
	local tileX = math.floor(posX / tile_size)
	local tileZ = math.floor(posZ / tile_size)

	return Utils.getMarkerTileKey(tileX, tileZ)
end

function Utils.getMarkerTileKey(tileX, tileZ)
	return string.format("%sX%s", tileX + MARKER_TILE_DELTA, tileZ + MARKER_TILE_DELTA)
end

function Utils.getTileKey(tileX, tileZ)
	return lshift(tileX + TILE_DELTA, SHIFT) + tileZ + TILE_DELTA
end

function Utils.getTileXZByKey(tileKey)
	local tileX = rshift(tileKey, SHIFT) - TILE_DELTA
	local tileZ = band(tileKey, SHIFT_MASK) - TILE_DELTA

	return tileX, tileZ
end

function Utils.getOffsetTileKey(tileKey, tileXOffset, tileZOffset)
	local tileX, tileZ = Utils.getTileXZByKey(tileKey)

	tileX = tileX + tileXOffset
	tileZ = tileZ + tileZOffset

	return Utils.getTileKey(tileX, tileZ)
end

function Utils.getEntNameBySpaceType(spaceType, sceneId)
	if Utils.isLine(sceneId) then
		return "Line"
	end

	if spaceType == Const.SPACE_TYPE_ROBEGG then
		return Const.ROBEGG_SCENEID_TO_NAME[sceneId]
	end

	local spaceClass = Const.SPACE_TYPE_TO_NAME[spaceType]

	if not spaceClass then
		local errorMsg = "spaceType: " .. spaceType

		assert(false, errorMsg)

		return
	end

	return spaceClass
end

function Utils.getEntNameBySceneId(sceneId)
	if Utils.isLine(sceneId) then
		return "Line"
	end

	local spaceType = Utils.getSpaceType(sceneId)

	return Utils.getEntNameBySpaceType(spaceType, sceneId)
end

function Utils.isLine(sceneId)
	return MapLineConfigData[sceneId]
end

function Utils.isSceneWorld()
	return pg.me and pg.me.space and pg.me.space.sceneId == 3000
end

function Utils.isScenePhoto()
	return pg.me and pg.me.space and pg.me.space:isPhotoWorld()
end

function Utils.getPhaseMainSceneId(sceneId)
	local sceneData = SceneData[sceneId]

	return sceneData and sceneData.mainScene
end

function Utils.isDynamicPhasePortId(portalId)
	return portalId == Const.DynamicPhasePortId
end

function Utils.isSeamlessPortalId(portalId)
	return portalId == Const.SeamlessPortalId or portalId == Const.ClientSeamlessQuitPortalId or portalId == Const.DynamicPhasePortId
end

function Utils.isClientSeamlessQuitPortalId(portalId)
	return portalId == Const.ClientSeamlessQuitPortalId
end

function Utils.isSpacePhase(sceneId)
	local sceneData = SceneData[sceneId]

	return sceneData and sceneData.mainScene
end

function Utils.isBonFire(sceneId)
	local sceneData = SceneData[sceneId]

	return sceneData.isBonfire == 1
end

function Utils.isInSocialScene()
	if not pg.space then
		return false
	end

	return pg.space:isHomeCamp() or pg.space:isHomeland() or Utils.isBonFire(pg.space.sceneId) or pg.space.sceneId == Const.SCENE_ID.ARK
end

function Utils.isSpaceDynamicPhase(sceneId)
	local sceneData = SceneData[sceneId]

	return sceneData and sceneData.mainScene and not sceneData.autoCutSeamless
end

function Utils.isSceneHomeland(sceneId)
	return sceneId == Utils.getHomelandSceneId()
end

function Utils.isSceneSingleWorld(sceneId)
	local sceneData = SceneData[sceneId]

	return Utils.isSpaceSingleWorld(sceneData and sceneData.type)
end

function Utils.isLeaderInSpace(player)
	local leader = player:getTeamLeaderPlayer()

	return leader and (leader.space and leader.space.id) == (player.space and player.space.id)
end

function Utils.isSelfInSpaceDungeon()
	return pg.me and pg.me.space and pg.me.space.sceneId and Utils.isSpaceDungeon(Utils.getSpaceType(pg.me.space.sceneId))
end

function Utils.isSpaceDungeon(spaceType)
	return spaceType >= Const.SPACE_TYPE_DUNGEON and spaceType <= Const.SPACE_TYPE_DUNGEON_END or spaceType >= Const.SPACE_TYPE_DUNGEON_START and spaceType <= Const.SPACE_TYPE_DUNGEON_OVER
end

function Utils.isSelfInSpaceTown()
	return pg.me and pg.me.space and pg.me.space.sceneId and (Utils.getSpaceType(pg.me.space.sceneId) == Const.SPACE_TYPE_TOWN or Utils.getSpaceType(pg.me.space.sceneId) == Const.SPACE_TYPE_LINE)
end

function Utils.isPlayerInSpaceCatchRogueDungeon(player)
	return player and player.space and player.space.sceneId and Utils.isSpaceCatchRogueDungeon(Utils.getSpaceType(player.space.sceneId))
end

function Utils.isSelfInSpaceFishingCaptureDungeon(player, phase)
	local inFishingCaptureDungeon = player and player.space and player.space.sceneId and Utils.isSpaceFishingCaptureDungeon(Utils.getSpaceType(player.space.sceneId))

	if phase then
		return inFishingCaptureDungeon and player.space.gamePhase == phase
	else
		return inFishingCaptureDungeon
	end
end

function Utils.isRawTown(spaceType)
	return spaceType == Const.SPACE_TYPE_TOWN
end

function Utils.isSpaceTown(spaceType)
	return spaceType == Const.SPACE_TYPE_TOWN or spaceType == Const.SPACE_TYPE_LINE or spaceType == Const.SPACE_TYPE_HOMECAMP
end

function Utils.isSpaceSingleWorld(spaceType)
	return spaceType == Const.SPACE_TYPE_SINGLEWORLD
end

function Utils.isSpaceTimePrivate(sceneId)
	return SceneData[sceneId] and SceneData[sceneId].timeprivate == 1
end

function Utils.isSpaceSingleDungeon(sceneId)
	return LevelData[sceneId] and LevelData[sceneId].playerNumMax <= 1
end

function Utils.isRobEggUnderGround(spaceType)
	return spaceType == Const.SPACE_TYPE_ROBEGG_UNDERGROUND
end

function Utils.isSpacePvpDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_PVP_DUNGEON
end

function Utils.isSpacePveDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_PVE_DUNGEON or spaceType == Const.SPACE_TYPE_TEAM_PVE_DUNGEON or spaceType == Const.SPACE_TYPE_WEEKLY_DUNGEON
end

function Utils.isSpaceWeeklyDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_WEEKLY_DUNGEON
end

function Utils.isSpaceRogueDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_ROGUE_DUNGEON
end

function Utils.isSpaceCatchRogueDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_CATCH_ROGUE_DUNGEON
end

function Utils.isSpaceFishingCaptureDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_FISHING_CAPTURE_DUNGEON
end

function Utils.isSpaceBossRushDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_BOSS_RUSH
end

function Utils.isSpaceNpcDuelDungeon(spaceType)
	return spaceType == Const.SPACE_TYPE_NPC_DUEL
end

function Utils.isSpaceSpecialBattleMode(space)
	return space and space.battleMode > 0
end

function Utils.isHomeCamp(spaceType)
	return spaceType == Const.SPACE_TYPE_HOMECAMP
end

function Utils.isHomeCampBySceneId(sceneId)
	local spaceType = Utils.getSpaceType(sceneId)

	return Utils.isHomeCamp(spaceType)
end

function Utils.isHomeland(spaceType)
	return spaceType == Const.SPACE_TYPE_HOMELAND
end

function Utils.isHomelandBySceneId(sceneId)
	local spaceType = Utils.getSpaceType(sceneId)

	return Utils.isHomeland(spaceType)
end

function Utils.isTownLikeScene(sceneId)
	local spaceType = Utils.getSpaceType(sceneId)

	return Utils.isLine(sceneId) or Utils.isSpaceTown(spaceType)
end

function Utils.getSelfHomelandKey(player)
	return Utils.getSpaceInstanceServiceKey(player.serverId, player.uid, Utils.getHomelandSceneId())
end

function Utils.getSelfHomeCampKey(player)
	return player.campSpaceKeyMap[player.curCampStaticId]
end

function Utils.getHomelandSceneId()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.homelandNewSceneId
	end

	return HomelandConfigData.homelandSceneId
end

function Utils.getHomeCampKeyGroupId(spaceKey)
	return "homeCamp_" .. spaceKey
end

function Utils.getDefaultCarShapeInfo()
	local shapeInfo = {}

	for i, partId in pairs(Const.HOME_CAR_BASE_PART) do
		shapeInfo[partId] = 1
	end

	return shapeInfo
end

function Utils.isHomeCampKeyGroupId(groupId)
	return string.startsWith(groupId, "homeCamp_")
end

function Utils.getDungeonPlayIdStr(sceneId, hardLv)
	hardLv = hardLv or 0

	return string.format("%d_%d", sceneId, hardLv)
end

function Utils.getDungeonSceneIdAndHardLv(dungeonPlayId)
	local parts = dungeonPlayId:split("_")

	if #parts ~= 2 then
		logger:error("getDungeonSceneIdAndHardLv invalid dungeonPlayId", dungeonPlayId)

		return 0, 0
	end

	local sceneId = ToInt(parts[1])
	local hardLv = ToInt(parts[2])

	return sceneId, hardLv
end

function Utils.isRobEggSceneId(sceneId)
	local spaceType = Utils.getSpaceType(sceneId)

	return spaceType == Const.SPACE_TYPE_ROBEGG or spaceType == Const.SPACE_TYPE_ROBEGG_UNDERGROUND
end

function Utils.isServerDrivenDungeonFog(sceneId)
	return Const.SERVER_DRIVEN_DUNGEON_FOG and sceneId ~= nil and Utils.isRobEggSceneId(sceneId)
end

function Utils.isBossRushSceneId(sceneId)
	return Utils.getSpaceType(sceneId) == Const.SPACE_TYPE_BOSS_RUSH
end

function Utils.isWeeklyDungeonSceneId(sceneId)
	return Utils.getSpaceType(sceneId) == Const.SPACE_TYPE_WEEKLY_DUNGEON
end

function Utils.canQuitBackScene(sceneId)
	local spaceType = Utils.getSpaceType(sceneId)

	if Utils.isHomeCamp(spaceType) then
		return false
	end

	if spaceType == Const.SPACE_TYPE_TOWN or spaceType == Const.SPACE_TYPE_SINGLEWORLD or spaceType == Const.SPACE_TYPE_LINE or Utils.isSpacePhase(sceneId) then
		return true
	end

	return false
end

function Utils.quitBack(player)
	if player.space:isPhotoWorld() then
		return true
	end

	local spaceType = Utils.getSpaceType(player.space.sceneId)

	if Utils.isSpaceDungeon(spaceType) then
		return true
	elseif Utils.isSpaceTown(spaceType) then
		return true
	elseif Utils.isHomeland(spaceType) and not Utils.isHomelandBySceneId(player.lastSceneId) then
		return true
	elseif Utils.isSpaceSingleWorld(spaceType) and player.space:isMultiPlayerEnv() then
		return true
	end

	return false
end

function Utils.squareDist(pos1, pos2)
	return Vector3.SqrDistance(pos1, pos2)
end

function Utils.squareDistNoZAxis(pos1, pos2)
	return Vector3.squareDistNoZAxis(pos1, pos2)
end

function Utils.squareDistNoYAxis(pos1, pos2)
	return Vector3.HoriSqrDistance(pos1, pos2)
end

function Utils.getMaxXZDist(pos1, pos2)
	local x = pos1[1] - pos2[1]
	local z = pos1[3] - pos2[3]

	return math.max(math.abs(x), math.abs(z))
end

function Utils.distance(pos1, pos2)
	return Vector3.Distance(pos1, pos2)
end

function Utils.distance2D(pos1, pos2)
	return Vector3.HoriDistance(pos1, pos2)
end

function Utils.distanceEntity(ent1, ent2)
	if not ent1 or not ent1.space then
		return Const.NUMBER_MAX
	end

	if not ent2 or not ent2.space then
		return Const.NUMBER_MAX
	end

	if ent1.space.id ~= ent2.space.id then
		return Const.NUMBER_MAX
	end

	local pos1 = ent1.getPosition and ent1:getPosition()
	local pos2 = ent2.getPosition and ent2:getPosition()

	return math.sqrt(Utils.squareDist(pos1, pos2))
end

function Utils.genRandomPosition(pos, radius, yaw)
	local random_theta

	if yaw then
		random_theta = yaw
	else
		random_theta = math.random() * math.pi * 2
	end

	local random_r = math.sqrt(math.random()) * radius
	local dz = math.cos(random_theta) * random_r
	local dx = math.sin(random_theta) * random_r
	local tmpPos = Vector3(pos[1] + dx, pos[2], pos[3] + dz)

	return tmpPos
end

function Utils.velocity(pos1, pos2, dtime)
	assert(dtime > 0, "divide zero or negative!")

	local x = (pos2[1] - pos1[1]) / dtime
	local y = (pos2[2] - pos1[2]) / dtime
	local z = (pos2[3] - pos1[3]) / dtime

	return {
		x,
		y,
		z
	}
end

function Utils.logicTimeDuringPeriod(logicTime, startTime, endTime)
	return startTime <= logicTime and logicTime < endTime
end

function Utils.getAngleByEntity(ent1, ent2)
	Vector3.enableCreateFromCache()

	local selfPos = ent1:getPosition()
	local targetPos = ent2:getPosition()
	local selfDir = ent1:getRotation():Forward():Normalize()

	selfDir[2] = 0

	local dirVec = targetPos - selfPos

	dirVec[2] = 0

	local angle = lume.getVector3Angle(selfDir, dirVec)

	if lume.getVector3Cross(selfDir, dirVec)[2] < 0 then
		angle = -angle
	end

	Vector3.disableCreateFromCache()

	return angle
end

function Utils.getAbsAngleByEntityForward(ent1, ent2)
	local angle = Utils.getAngleByEntity(ent1, ent2)

	return math.abs(angle)
end

function Utils.getAbsAngleByEntityBehind(ent1, ent2)
	local angle = Utils.getAngleByEntity(ent1, ent2)

	return math.abs(math.pi - math.abs(angle))
end

function Utils.getYawByEntity(ent1, ent2)
	local dirVec = ent2:getPosition() - ent1:getPosition()

	return dirVec:ToYaw()
end

function Utils.checkValidPlayer(target)
	if not Utils.isPlayerOrBotPlayer(target) then
		return false
	end

	if not target:isAlive() then
		return false
	end

	return true
end

function Utils.checkValidTarget(target, owner)
	if not target then
		return false
	end

	if target.isAbilityInvalidTarget then
		return false
	end

	if target.knockUpInvincibleTimer then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			target.logger:debug("knockUpInvincibleTimer, ignore target")
		end

		return false
	end

	if target.lastStartDashTime then
		local dashDuration = target:getGameTime() - target.lastStartDashTime

		if dashDuration >= AbilitySettingGlobalConstData.dashInInvincibleTime[1] and dashDuration <= AbilitySettingGlobalConstData.dashInInvincibleTime[2] then
			return false
		end
	end

	if target.dialoguePauseInvincibleEndTs then
		local dialoguePauseInvincibleEndTs = target.dialoguePauseInvincibleEndTs

		if dialoguePauseInvincibleEndTs > 0 and dialoguePauseInvincibleEndTs > Time.secondCache then
			return false
		end
	end

	if target.syncEntityRole == 1 then
		if owner and owner.space and owner.space.ownerPlayerId ~= owner.authorityId then
			return false
		end
	elseif owner and owner.syncEntityRole == 1 and target and target.space and target.space.ownerPlayerId ~= target.authorityId then
		return false
	end

	return true
end

function Utils.checkValidLock(target, ignoreEnemy, ignoreLock, ignoreHit)
	if pg.component == "client" and not ignoreLock and (target.canBeLocked == nil or not target:canBeLocked()) then
		return false
	end

	if target.isInValidLockTarget then
		return false
	end

	if not ignoreEnemy and Utils.isEnemy(pg.pawn, target) and target.isCamouflage then
		return false
	end

	if CharacterStateConst.isMimicryState(target.characterState) then
		return false
	end

	if not ignoreHit and target.canBeHit == false then
		return false
	end

	if target.isDisableCombatNpc then
		return false
	end

	return true
end

function Utils.getLockState(player)
	local lockedEntity = pg.getEntityByActorId(player.lockedActorId)

	if not lockedEntity then
		return AbilityConst.LockState.None
	end

	local lockState = AbilityConst.LockState.None

	if player:isInCatchMode() then
		lockState = lockedEntity.topLogoData.showCatchLocked and AbilityConst.LockState.AutoLock or nil
	elseif Utils.isEnvObj(lockedEntity) then
		lockState = AbilityConst.LockState.None
	else
		lockState = pg.game.controller.lockHelper.forceLockActorId ~= 0 and AbilityConst.LockState.Lock or AbilityConst.LockState.AutoLock
	end

	return lockState
end

function Utils.getEntityLockedActorId(ent)
	local lockedActorId = 0

	if Utils.isPlayer(ent) then
		local partId = ent.lockedPartId

		lockedActorId = ent.lockedActorId
		lockedActorId, partId = pg.game.controller.lockHelper:tryLockTarget(lockedActorId, partId)
	elseif Utils.isPlayerPet(ent) then
		local player = ent:getMasterEntity()

		if player and player:isControllingPet() then
			local partId = player.lockedPartId

			lockedActorId = player.lockedActorId
			lockedActorId, partId = pg.game.controller.lockHelper:tryLockTarget(lockedActorId, partId)
		else
			lockedActorId = ent:getLockedActorId()
		end
	elseif Utils.isPuppet(ent) then
		-- block empty
	end

	return lockedActorId
end

function Utils:checkRelation(target, relation)
	if self == nil or target == nil then
		return false
	end

	if relation == Const.WORLD_PAIRS_CAMP_ARBITRARY then
		return true
	end

	if self.tempCampGroup ~= 0 and self.tempCampGroup == target.tempCampGroup and tempCampData[self.tempCampGroup] then
		local tempCampInfo = tempCampData[self.tempCampGroup]

		if tempCampInfo == nil or tempCampInfo[self.tempCamp] == nil then
			return false
		end

		return tempCampInfo[self.tempCamp][target.tempCamp] == relation
	end

	local campInfo = camp_data[self.camp]

	if campInfo == nil then
		return false
	end

	return campInfo[target.camp] == relation
end

function Utils:getRelation(target)
	if self == nil or target == nil then
		return AbilityConst.WORLD_PAIRS_CAMP_ARBITRARY
	end

	local campInfo = camp_data[self.camp]

	if campInfo == nil then
		return AbilityConst.WORLD_PAIRS_CAMP_ARBITRARY
	end

	return campInfo[target.camp]
end

function Utils:isEnemy(target)
	return Utils.checkRelation(self, target, Const.WORLD_PAIRS_CAMP_ENEMY)
end

function Utils:isPartner(target)
	return Utils.checkRelation(self, target, Const.WORLD_PAIRS_CAMP_PARTNER)
end

function Utils.canBeCallFriends(player, puppet)
	if not player:isControllingPet() or Utils.isBoss(puppet) then
		return false
	end

	local petEnt = player:getCurPetEntity()

	return Utils.canBeCallFriendsByPet(petEnt, puppet)
end

function Utils.canBeCallFriendsByPet(pet, puppet)
	local petConfig = pet:getConfigData()
	local puppetConfig = puppet:getConfigData()

	if petConfig.ethnicGroup ~= puppetConfig.ethnicGroup then
		return false
	end

	if CharacterStateConst.isMimicryState(puppet.characterState) and not puppetConfig.canMimicryOutByBeCallFriends then
		return false
	end

	if puppetConfig.ethnicCallFriendType == Const.CALL_FRIEND_TYPE_HIGH_STAGE then
		return petConfig.stage >= puppetConfig.stage
	elseif puppetConfig.ethnicCallFriendType == Const.CALL_FRIEND_TYPE_SAME_STAGE then
		return petConfig.stage == puppetConfig.stage
	end

	return true
end

function Utils.tableIsEmptyOrNil(t)
	if t == nil or Utils.isEmptyTable(t) then
		return true
	end

	return false
end

function Utils.tableIsValidVector3(vec)
	return vec and vec[1] and vec[2] and vec[3]
end

function Utils.getEntityConfigData(entity)
	local entityConfigData

	if entity.getConfigData then
		entityConfigData = entity:getConfigData()

		if entityConfigData == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("not find actor data", entity.templateId, entity.actorType)
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("not support actor type", entity.templateId, entity.actorType)
	end

	return entityConfigData or {}
end

function Utils.getEntityPropId(entity, entityConfigData)
	if not entityConfigData then
		return 0
	end

	local space = entity.space

	if space and space.getPropId then
		local propId = space:getPropId(entity, entityConfigData)

		if propId then
			return propId
		end
	end

	if entity.overridePropId then
		return entity.overridePropId
	end

	local propId = entityConfigData.propId

	if Utils.isPuppet(entity) and Utils.isLabelElite(entity.label) and entityConfigData.ElitePropId then
		propId = entityConfigData.ElitePropId
	end

	return propId
end

function Utils.getCamp(actorType)
	local camp = Const.ACTOR_TYPE_TO_CAMP[actorType]

	return camp or Const.CAMP_PEACE
end

function Utils.getTagMaterialInfo(entity)
	local entityConfigData = Utils.getEntityConfigData(entity)

	if Utils.isEmptyTable(entityConfigData) then
		return 0
	end

	local tagMaterial = 0

	for k, v in pairs(entityConfigData) do
		if ToBool(v) then
			local tagNumber = AbilityConst.TAG_STR_TO_NUM[k]

			if ToBool(tagNumber) then
				tagMaterial = bit.bor(tagMaterial, tagNumber)
			end
		end
	end

	return tagMaterial
end

function Utils.getPropertyValue(value, interface, propBossGrade, speciesPoint)
	if not value then
		return 0
	end

	if type(value) == "table" then
		local formulaId, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5 = unpack(value)

		if not FormulaData[formulaId] then
			local ent = interface:getEntity()

			if ent and ent.logger then
				ent.logger:error("formula data not found", formulaId)
			end

			return 0
		end

		if propBossGrade and speciesPoint then
			return FormulaData[formulaId].formula(interface:getLevel(), propBossGrade, speciesPoint, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5)
		else
			return FormulaData[formulaId].formula(interface:getLevel(), extraArg1, extraArg2, extraArg3, extraArg4, extraArg5)
		end
	else
		return value
	end
end

function Utils.getAttribTemplateInfoByConfig(entityConfigData, pdd, actorInterface)
	local info = {
		attribs = {}
	}
	local ent = actorInterface:getEntity()
	local bossLevelGrade, speciesPoint

	bossLevelGrade = ent.levelStage or 0

	for _, attribName in ipairs(Const.COMMON_BASIC_ATTRIBS) do
		info[attribName] = Utils.getPropertyValue(entityConfigData[attribName] or pdd[attribName] or 0, actorInterface)
	end

	for attribName, val in pairs(pdd) do
		local attribId = AttributeConst[attribName]

		if attribId and not lume.find(Const.COMMON_BASIC_ATTRIBS, attribName) then
			if entityConfigData.isBossRushGrade and Const.BOSS_GRADE_ATTRIBUTE_MAP[attribName] then
				speciesPoint = 0

				if ent.petInfo then
					local index = Utils.getBasePropIndex(attribName)

					speciesPoint = ent.petInfo.basePropertyList:getSpeciesPoint(index)
				end

				info.attribs[attribId] = Utils.getPropertyValue(val, actorInterface, bossLevelGrade, speciesPoint)
			else
				info.attribs[attribId] = Utils.getPropertyValue(val, actorInterface)
			end
		end
	end

	for _, attribName in ipairs(Const.COMMON_BASIC_ATTRIBS_EXTRA) do
		local attribId = AttributeConst[attribName]

		info.attribs[attribId] = Utils.getPropertyValue(entityConfigData[attribName] or pdd[attribName], actorInterface)
	end

	return info
end

if pg and pg.component == "game" then
	function Utils.checkClient()
		if pg and pg.component == "game" then
			return false
		end

		return true
	end
else
	function Utils.checkClient()
		return true
	end
end

function Utils.getCurrentFileDir()
	local path = debug.getinfo(1).source

	path = string.sub(path, 2, -1)
	path = string.match(path, "^.*/")

	return path
end

function Utils.getScriptPath()
	if Utils.checkClient() == true then
		return LUA_ROOT_PATH
	end

	local currentPath = arg[1]

	return currentPath
end

function Utils.getScriptRelativeTreePath(path)
	return path
end

function Utils.firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

function Utils.firstToLower(str)
	return (str:gsub("^%u", string.lower))
end

function Utils.isPetInfoType(obj)
	return obj and obj.__ClassType and obj.__ClassType.typeName == "PetInfo"
end

function Utils.isActorTypeByType(t, actorType)
	return t and t == actorType
end

function Utils.isActorType(entity, actorType)
	return entity and entity.actorType == actorType
end

function Utils.isPlayer(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PLAYER)
end

function Utils.isPlayerGhost(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PLAYER_GHOST)
end

function Utils.isPetGhost(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PET_GHOST)
end

function Utils.getSourceIdByGhostUid(ghostId)
	return ghostId and string.match(ghostId, "^(.-)_") or ghostId
end

function Utils.getSourceUidByPlayerGhostUid(playerUid)
	return playerUid and string.match(playerUid, "^(.-)_") or playerUid
end

function Utils.getPlayerGhostUidBySourceUid(sourceUid, targetSpaceId)
	if sourceUid == nil then
		return nil
	end

	targetSpaceId = targetSpaceId or pg.me and pg.me.space and pg.me.space.id

	if targetSpaceId == nil then
		return nil
	end

	return Utils.getPlayerGhostUid(sourceUid, targetSpaceId)
end

function Utils.isPlayerOrBotPlayer(entity)
	return Utils.isPlayer(entity) or Utils.isBotPlayer(entity)
end

function Utils.isMainPlayer(entity)
	return Utils.isPlayer(entity) and entity.isMainPlayer
end

function Utils.isBotPlayer(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_BOTPLAYER)
end

function Utils.isPet(entity, ignoreBot)
	local ret = Utils.isActorType(entity, ACTOR_TYPE_PET)

	if ignoreBot then
		return ret and not entity.isBot
	else
		return ret
	end
end

function Utils.isBot(entity)
	return entity and entity.isBot
end

function Utils.isBotPet(entity)
	return Utils.isActorType(entity, ACTOR_TYPE_PET) and entity.isBot
end

function Utils.isHomePet(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PUPPET) and entity.isHomePet
end

function Utils.isCarryPet(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PUPPET) and entity.isCarryPet
end

function Utils.isPuppet(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PUPPET)
end

function Utils.isCreatePlenty(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_PUPPET) and entity.isCreatePlenty
end

function Utils.isServerPuppet(entity)
	return Utils.isPuppet(entity) and entity.isServerAI
end

function Utils.isWildPuppet(entity)
	if not Utils.isPuppet(entity) then
		return false
	end

	local masterPlayer = Utils.getMasterPlayer(entity)

	return masterPlayer == nil
end

function Utils.isStaticNpc(entity)
	return entity and entity:getConfigData().npcControlType == Const.NPC_CONTROL_TYPE.Static or false
end

function Utils.isStaticNpcWithNpcTopLogo(entity)
	return entity and Utils.isStaticNpc(entity) and entity.topLogoType == 13 or false
end

function Utils.isSimpleMoveNpc(entity)
	return entity and entity:getConfigData().npcControlType == Const.NPC_CONTROL_TYPE.SimpleMove or false
end

function Utils.isVehicle(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_VEHICLE)
end

function Utils.isClientHomeOrnament(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_HOME_OBJECT)
end

function Utils.isClientHomeFacility(entity)
	return Utils.isClientHomeOrnament(entity) and entity.getFacilityId and entity:getFacilityId()
end

function Utils.isClientHomeTrash(entity)
	return Utils.isClientHomeOrnament(entity) and entity.getFacilityId and entity:getFacilityId() and entity.isHomeTrash
end

function Utils.isCampCar(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_CAMPCAR)
end

function Utils.isPetPuppet(entity)
	return Utils.isPuppet(entity) or Utils.isPet(entity)
end

function Utils.isPlayerPet(entity)
	if Utils.isActorType(entity, ACTOR_TYPE_PET) then
		local player = entity:getMasterEntity()

		if player then
			return Utils.isActorType(player, Const.ACTOR_TYPE_PLAYER)
		end
	end

	return false
end

function Utils.isPlayerCurPet(entity)
	if Utils.isActorType(entity, ACTOR_TYPE_PET) then
		local player = entity:getMasterEntity()

		if player then
			return Utils.isActorType(player, Const.ACTOR_TYPE_PLAYER) and entity == player:getCurPetEntity()
		end
	end

	return false
end

function Utils.isPawnFollowPet(entity)
	if not Utils.checkClient() then
		return false
	end

	if Utils.isActorType(entity, ACTOR_TYPE_PET) then
		local player = entity:getMasterEntity()

		return player and player == pg.pawn
	end

	return false
end

local _npcIds = setmetatable({}, {
	__index = function(t, npcId)
		local isNpc = NpcIdData[npcId] == true

		rawset(t, npcId, isNpc)

		return isNpc
	end
})

function Utils.isNpc(entity)
	if Utils.checkClient() then
		return entity and entity.isNpcEntity
	end

	return Utils._isNpc(entity)
end

function Utils._isNpc(entity)
	local owner = pg.getEntity(entity.ownerId)
	local isSpecialNpc = owner and owner.specialNpcDict and owner.specialNpcDict[entity.staticId]

	return (_npcIds[entity.templateId] == true or isSpecialNpc) and (Utils.isPuppet(entity) or Utils.isSimpleMoveNpc(entity))
end

local _puppetType = setmetatable({}, {
	__index = function(t, npcId)
		local puppet = PuppetData[npcId]
		local npcType = false

		if puppet then
			npcType = puppet.npcType or Const.NPC_TYPE.None
		end

		rawset(t, npcId, npcType)

		return npcType
	end
})

function Utils.isPeopleNpc(ent)
	if Utils.checkClient() then
		return Utils.isNpc(ent) and ent.npcType == Const.NPC_TYPE.Human
	else
		if not ent or not ent.templateId then
			return false
		end

		if not Utils.isNpc(ent) then
			return false
		end

		local npcType = _puppetType[ent.templateId]

		return npcType == Const.NPC_TYPE.None or npcType == Const.NPC_TYPE.Human
	end
end

function Utils.isPetNpc(ent)
	if not ent or not ent.templateId then
		return false
	end

	if not Utils.isNpc(ent) then
		return false
	end

	return _puppetType[ent.templateId] == Const.NPC_TYPE.Pet
end

function Utils.isCombatOnlyNameNpc(ent)
	if PetConfigData.tutorialIgnoreToplogoNPCList and next(PetConfigData.tutorialIgnoreToplogoNPCList) then
		return PetConfigData.tutorialIgnoreToplogoNPCList[ent.templateId] and true or false
	end

	return false
end

function Utils.isInteractNpc(ent)
	if not ent or not Utils.isPuppet(ent) and not Utils.isVirtualPuppet(ent) or ent.isBot then
		return false
	end

	local actionPrototypeIds = ent:getNpcActionPrototypeIds()
	local specialInteractionData = ent._specialInteractionData
	local hasSpecialInteract = specialInteractionData and not Utils.isEmptyTable(specialInteractionData)
	local npcFuncData = NpcFuncData[ent.templateId]
	local funcMenuId = npcFuncData and npcFuncData.funcMenuId or nil
	local hasFuc = funcMenuId and NpcFuncConfigData[funcMenuId]
	local hasInteractiveDist = ToBool(ent.interactiveDist)

	if actionPrototypeIds or hasFuc or hasSpecialInteract or hasInteractiveDist then
		return true
	end

	return false
end

function Utils.isTeamPlayerOrPet(ent)
	return Utils.isPlayer(ent) and not ent.isMainPlayer or Utils.isPet(ent) and not ent.isMainPet
end

function Utils.isNpcTopLogo(entity)
	return Utils.isPuppet(entity) and PuppetData[entity.templateId].isNpc
end

function Utils.isChest(entity)
	if entity and entity.templateId and Utils.isInteractor(entity) and entity.isChest and ChestData[entity.templateId] then
		return true
	end

	return false
end

function Utils.isCollectItem(entity)
	if entity and entity.templateId and Utils.isInteractor(entity) and entity.isCollectItem and CollectItemData[entity.templateId] then
		return true
	end

	return false
end

function Utils.isVirtualPet(entity)
	if entity == nil then
		return false
	end

	return entity.virtualTemplateActorType == ACTOR_TYPE_PET
end

function Utils.isVirtualPetNotNull(entity)
	return entity.virtualTemplateActorType == ACTOR_TYPE_PET
end

function Utils.isVirtualPuppet(entity)
	if entity == nil then
		return false
	end

	if entity.virtualTemplateActorType == nil then
		return false
	end

	return entity.virtualTemplateActorType == Const.ACTOR_TYPE_PUPPET
end

function Utils.isCatchBall(entity)
	if entity == nil then
		return false
	end

	return entity.ballUid ~= nil
end

function Utils.isCreation(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_CREATION)
end

function Utils.isInteractor(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_INTERACTOR)
end

function Utils.isVirtualEntity(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_VIRTUAL)
end

function Utils.isTrapBall(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_TrapBall)
end

function Utils.isEnvObj(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_ENVOBJ)
end

function Utils.isVirtualTarget(entity)
	return entity and entity.isVirtualTarget
end

function Utils.isGamePlay(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_GAMEPLAY)
end

function Utils.isSpellField(entity)
	return Utils.isActorType(entity, Const.ACTOR_TYPE_SPELLFIELD)
end

function Utils.isCrystal(ent)
	return Utils.hasEntityTag(ent, "TE_Wild_Crystal")
end

function Utils.isBoss(ent)
	if not ent or not ent.label then
		return false
	end

	return Utils.isLabelBoss(ent.label) and ent.actorType ~= Const.ACTOR_TYPE_PET
end

function Utils.isElite(ent)
	if not ent or not ent.label then
		return false
	end

	return Utils.isLabelElite(ent.label) and ent.actorType ~= Const.ACTOR_TYPE_PET
end

function Utils.isSemanticallyBoss(ent)
	return Utils.isElite(ent) or Utils.isBoss(ent)
end

function Utils.isDark(ent)
	if not ent or not ent.label then
		return false
	end

	return Utils.isLabelDark(ent.label) and ent.actorType ~= Const.ACTOR_TYPE_PET
end

function Utils.isLabelShiny(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.SHINY) ~= 0
end

function Utils.isLabelBoss(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.BOSS) ~= 0
end

function Utils.isLabelElite(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.ELITE) ~= 0
end

function Utils.isLabelVariant(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.VARIANT) ~= 0
end

function Utils.isLabelDark(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.DARK) ~= 0
end

function Utils.isLabelMagic(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.MAGIC) ~= 0
end

function Utils.isLabelRainbow(label)
	return bit.band(label or 0, Const.PET_LABEL_MASK.RAINBOW) ~= 0
end

local SHINY_COLLECT_STYLE_MAX = 32

local function getShinyCollectBit(shinyStyle)
	if type(shinyStyle) ~= "number" or shinyStyle % 1 ~= 0 or shinyStyle < 1 or shinyStyle > SHINY_COLLECT_STYLE_MAX then
		return nil
	end

	return bit.lshift(1, shinyStyle - 1)
end

function Utils.hasShinyCollectStyle(shinyCollectMask, shinyStyle)
	local styleBit = getShinyCollectBit(shinyStyle)

	if not styleBit then
		return false
	end

	return bit.band(shinyCollectMask or 0, styleBit) ~= 0
end

function Utils.addShinyCollectStyle(shinyCollectMask, shinyStyle)
	local oldMask = shinyCollectMask or 0
	local styleBit = getShinyCollectBit(shinyStyle)

	if not styleBit then
		return oldMask, false
	end

	if bit.band(oldMask, styleBit) ~= 0 then
		return oldMask, false
	end

	return bit.bor(oldMask, styleBit), true
end

function Utils.isAiBoss(label, sceneId)
	if not Utils.isLabelBoss(label) then
		return false
	end

	local spaceType = Utils.getSpaceType(sceneId)

	if not Utils.isSpacePveDungeon(spaceType) then
		return false
	end

	return true
end

function Utils.isCombatEntity(entity)
	if not entity then
		return false
	end

	if not entity.clenUsrType or entity.clenUsrType <= 0 then
		return false
	end

	return bit.band(bit.lshift(1, entity.clenUsrType), Const.SEARCH_USR_TYPE_ACTOR_CREATION) ~= 0
end

function Utils.isRainbowType(petPrototypeId)
	if not petPrototypeId then
		return false
	end

	local Const = require("Common.Const.Const")
	local formId = Utils.getPetFormIdByPrototypeId(petPrototypeId)

	return formId == Const.FormName2Id.rainbow
end

function Utils.matchFormTypeByTempId(templateId, typeIds)
	if not templateId or not typeIds then
		return false
	end

	local formId = Utils.getPetFormIdByTemplateId(templateId)

	for _, typeId in ipairs(typeIds) do
		if formId == typeId then
			return true
		end
	end

	return false
end

function Utils.isRainbowTypeByTemplateId(templateId)
	local Const = require("Common.Const.Const")
	local formId = Utils.getPetFormIdByTemplateId(templateId)

	return formId == Const.FormName2Id.rainbow
end

function Utils.isSpecialCharacter(characterId)
	local pcd = PetCharacterData[characterId]

	return pcd and pcd.rare == 1 or false
end

function Utils.isBlackRainbowType(petPrototypeId)
	if not petPrototypeId then
		return false
	end

	local Const = require("Common.Const.Const")
	local formId = Utils.getPetFormIdByPrototypeId(petPrototypeId)

	return formId == Const.FormName2Id.blackrainbow
end

function Utils.isBlackRainbowTypeByTemplateId(templateId)
	local Const = require("Common.Const.Const")
	local formId = Utils.getPetFormIdByTemplateId(templateId)

	return formId == Const.FormName2Id.blackrainbow
end

function Utils.isAnyRainbowType(petPrototypeId)
	return Utils.isRainbowType(petPrototypeId)
end

function Utils.isAnyRainbowTypeByTemplateId(templateId)
	return Utils.isRainbowTypeByTemplateId(templateId)
end

function Utils.checkCanSwim(entity)
	if entity then
		local canSwim = entity:getConfigData()[AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM]]

		if not canSwim or canSwim == 0 then
			return false
		end

		return canSwim
	end

	return false
end

function Utils.getEntityHealthInfo(entity)
	if entity then
		return {
			curHp = entity.actorCombatAttribute:getHp(),
			maxHp = entity.actorCombatAttribute:getMaxHp()
		}
	end
end

function Utils.getEntityShieldInfo(entity)
	if entity then
		return {
			curShieldPoint = entity.shieldDataList:getCurPoint(entity),
			maxHp = entity.actorCombatAttribute:getMaxHp()
		}
	end
end

function Utils.getEntityBreakInfo(entity, result)
	if entity then
		result = result or {}
		result.inBreakStatus = entity:inBreak() or entity:inBreakRecover()
		result.breakBuffFreezeTime = entity.breakBuffFreezeTime
		result.breakRecoverEndTime = entity.breakRecoverTime
		result.breakRecoverFreezeTime = entity.breakRecoverFreezeTime
		result.breakEndTime = entity.breakEndTime
		result.breakRecoverTime = entity.actorBuff:getBreakRecoverTime()
		result.breakTime = entity.actorBuff:getBreakTime()
		result.maxBp = entity.actorCombatAttribute:getMaxBp()
		result.curBp = entity.actorCombatAttribute:getBp()

		return result
	end
end

function Utils.getNpcInfoData(templateId)
	local npcFuncData = NpcFuncData[templateId]
	local npcData = PuppetData[templateId]
	local npcInfo = {}

	if npcData and npcFuncData then
		npcInfo.name = npcData.name
		npcInfo.careerName = npcFuncData.funcRep
		npcInfo.icon = npcFuncData.icon
	end

	return npcInfo
end

function Utils.clampAngle(angle, min, max)
	angle = angle - math.floor((angle + 180) / 360) * 360

	local start = (min + max) * 0.5 - 180
	local floor = math.floor((angle - start) / 360) * 360

	min = min + floor
	max = max + floor

	return math.clamp(angle, min, max)
end

function Utils.normalizeAngle(angle)
	angle = angle % 360

	if angle < 0 then
		angle = 360 + angle
	end

	return angle
end

function Utils.angleDiff(angle1, angle2)
	angle1 = Utils.normalizeAngle(angle1)
	angle2 = Utils.normalizeAngle(angle2)

	local deltaAngle = math.abs(angle1 - angle2)

	return deltaAngle <= 180 and deltaAngle or 360 - deltaAngle
end

local pi_div_180 = math.pi / 180

function Utils.angle2radian(angle)
	return angle * pi_div_180
end

function Utils.deepCopyTable(t, lookup_table, retTable)
	lookup_table = lookup_table or {}

	if type(t) ~= "table" and type(t) ~= "userdata" then
		return t
	elseif t._AccessControl_ then
		return AccessControl:getRawTable(t)
	elseif lookup_table[t] then
		return lookup_table[t]
	elseif t._BddData_ then
		return bdd2DeepTable(t)
	elseif type(t) == "userdata" then
		local metatable = getmetatable(t)

		if metatable and metatable._BddData_ then
			return bdd2DeepTable(t)
		end
	end

	local ret = retTable or {}

	lookup_table[t] = ret

	for k, v in pairs(t) do
		if type(v) == "table" then
			ret[k] = Utils.deepCopyTable(v, lookup_table, ret[k])
		else
			ret[k] = v
		end
	end

	return ret
end

function Utils.getElementAgainstValue(attackElement, defenceElements, atkEntity, defEntity)
	local factor = 1

	if attackElement == nil or defenceElements == nil then
		return factor
	end

	local againstFactor = 1

	for targetType, _ in pairs(defenceElements) do
		if ElementAgainstData[attackElement] and ElementAgainstData[attackElement][targetType] then
			local value = ElementAgainstData[attackElement][targetType]
			local localFactor = value

			factor = factor * value
			localFactor = localFactor > 1 and 2 or localFactor < 1 and 0.5 or 1
			againstFactor = againstFactor * localFactor
		end
	end

	local usePuppetElementResistProp = atkEntity and atkEntity.space and atkEntity.space.usePuppetElementResistProp or false

	if math.Approximately(againstFactor, 1) then
		return factor
	elseif againstFactor > 1 then
		local restraintAddRatio = atkEntity and atkEntity.actorCombatAttribute:getRawAttribValue(AttributeConst.element_restraint_add_ratio) or 0

		if usePuppetElementResistProp and Utils.isPuppet(defEntity) then
			restraintAddRatio = restraintAddRatio + (atkEntity and atkEntity.actorCombatAttribute:getRawAttribValue(AttributeConst.puppet_element_restraint_add_ratio) or 0)
		end

		return factor * (1 + restraintAddRatio)
	else
		local resistAddRatio = defEntity and defEntity.actorCombatAttribute:getRawAttribValue(AttributeConst.element_resist_add_ratio) or 0

		if usePuppetElementResistProp and Utils.isPuppet(atkEntity) then
			resistAddRatio = resistAddRatio + (defEntity and defEntity.actorCombatAttribute:getRawAttribValue(AttributeConst.puppet_element_resist_add_ratio) or 0)
		end

		return factor / (1 + resistAddRatio)
	end
end

function Utils.getElementAgainstShowEnum(attackElement, defenceElements)
	local enum = Const.DAMAGE_SHOW_ENUM_NORMAL

	if attackElement == nil or defenceElements == nil then
		return enum
	end

	local total_fator = 1
	local local_factor = 1

	for targetType, _ in pairs(defenceElements) do
		if ElementAgainstData[attackElement] and ElementAgainstData[attackElement][targetType] then
			local_factor = ElementAgainstData[attackElement][targetType]

			if local_factor == 0 then
				return Const.DAMAGE_SHOW_ENUM_USELESS
			end

			local_factor = local_factor > 1 and 2 or local_factor < 1 and 0.5 or 1
			total_fator = total_fator * local_factor
		end
	end

	if math.Approximately(total_fator, 1) then
		return Const.DAMAGE_SHOW_ENUM_NORMAL
	elseif total_fator > 1 then
		return Const.DAMAGE_SHOW_ENUM_EXCELLENT
	else
		return Const.DAMAGE_SHOW_ENUM_WEAK
	end
end

function Utils.getAllAgainstElementsWithValues(defenceElements)
	if defenceElements == nil then
		return nil
	end

	local ret = {}

	for targetType, _ in pairs(defenceElements) do
		for testElement, data in pairs(ElementAgainstData) do
			if data[targetType] and data[targetType] > 1 then
				if ret[testElement] == nil then
					ret[testElement] = {
						element = testElement,
						value = data[targetType]
					}
				elseif ret[testElement].value < data[targetType] then
					ret[testElement].value = data[targetType]
				end
			end
		end
	end

	return ret
end

function Utils.getElementsAgainstValueList(attackElements, defenceElements, outResult)
	if not attackElements or not defenceElements then
		return
	end

	for atkE in pairs(attackElements) do
		local p = 1
		local dataAtkE = ElementAgainstData[atkE]

		if dataAtkE then
			for defE in pairs(defenceElements) do
				if dataAtkE[defE] then
					p = p * dataAtkE[defE]
				end
			end
		end

		outResult[#outResult + 1] = p
	end

	if #outResult <= 1 then
		return
	end

	for i = 2, #outResult do
		local v = outResult[i]
		local j = i - 1

		while j >= 1 and v > outResult[j] do
			outResult[j + 1] = outResult[j]
			j = j - 1
		end

		outResult[j + 1] = v
	end
end

function Utils.getMainElementsAgainstValue(attackMainElement, defenceElements)
	if not attackMainElement or not defenceElements then
		return
	end

	local againstValue = 1
	local dataAtkE = ElementAgainstData[attackMainElement]

	if dataAtkE then
		for defE in pairs(defenceElements) do
			if dataAtkE[defE] then
				againstValue = againstValue * dataAtkE[defE]
			end
		end
	end

	return againstValue
end

function Utils.compareElementFactors(setA, setB)
	local n = math.max(#setA, #setB)

	for i = 1, n do
		local va = setA[i] or 1
		local vb = setB[i] or 1

		if va ~= vb then
			return va - vb
		end
	end

	return 0
end

function Utils.isTableEqual(a, b)
	local typeA = type(a)
	local typeB = type(b)

	if typeA == typeB and a == b then
		return true
	end

	if typeA ~= "table" or typeB ~= "table" then
		return false
	end

	for key in pairs(a) do
		if b[key] == nil or not Utils.isTableEqual(a[key], b[key]) then
			return false
		end
	end

	for key in pairs(b) do
		if a[key] == nil then
			return false
		end
	end

	return true
end

function Utils.getItemCdInfo(itemId)
	local iedd = ItemEffectData[itemId]
	local cd, cdOutOfBattle = iedd.cd, iedd.cdOutOfBattle

	if iedd.cdGroup then
		local ieddGroup = ItemEffectData[iedd.cdGroup]

		cd, cdOutOfBattle = ieddGroup.cd, ieddGroup.cdOutOfBattle
	end

	cd = cd or 0
	cdOutOfBattle = cdOutOfBattle or cd

	return itemId, cd, cdOutOfBattle
end

function Utils.getNearestCreationByTag(player, tagStr, range)
	local myPosition = player:getPosition()
	local entityList = player:entitiesInRange(range, Const.SEARCH_USR_TYPE_CREATION)
	local minDistance = range * range
	local closestCreation
	local tag = AbilityConst.TAG_STR_TO_NUM[tagStr]

	if tag == nil then
		return nil
	end

	for _, actorId in ipairs(entityList) do
		local creation = pg.getEntityByActorId(actorId)

		if creation ~= nil and Bit.band(tag, creation:getTagMaterial()) ~= 0 then
			local distance = Vector3.SqrDistance(myPosition, creation:getPosition())

			if distance < minDistance then
				minDistance = distance
				closestCreation = creation
			end
		end
	end

	return closestCreation
end

function Utils.getNearestPuppet(player, range, filter)
	local myPosition = player:getPosition()
	local entityList = player:entitiesInRange(range, Const.SEARCH_USR_TYPE_MONSTER)
	local minDistance = range * range
	local closestEntity

	for _, actorId in ipairs(entityList) do
		local entity = pg.getEntityByActorId(actorId)

		if entity ~= nil and (not filter or filter(entity)) then
			local distance = Vector3.SqrDistance(myPosition, entity:getPosition())

			if distance < minDistance then
				minDistance = distance
				closestEntity = entity
			end
		end
	end

	return closestEntity
end

function Utils.checkCreationOverlap(templateId, entity, pos)
	local createData = CreationData[templateId]

	if not createData then
		return false
	end

	if not createData.minOverlayDis then
		return false
	end

	local entityList = entity:entitiesInRangeByPos({
		pos[1],
		pos[2],
		pos[3]
	}, createData.minOverlayDis + 0.5, Const.SEARCH_USR_TYPE_CREATION)

	for _, actorId in ipairs(entityList or EMPTY_TABLE) do
		local ent = pg.getEntityByActorId(actorId)

		if ent ~= nil and ent.templateId == templateId then
			local distance = Vector3.SqrDistance(pos, ent:getPosition())

			if distance < createData.minOverlayDis then
				return true
			end
		end
	end

	return false
end

function Utils.isEntityMatchRule(ent, ruleId)
	if not ruleId then
		return true
	end

	if not ent then
		return false
	end

	local ruleInfo = MatchRuleData[ruleId]

	if not ruleInfo then
		return false
	end

	if ruleInfo.entityType and not table.contains(ruleInfo.entityType, ent.actorType) then
		return false
	end

	if ruleInfo.templateId and not table.contains(ruleInfo.templateId, ent.templateId) then
		return false
	end

	return true
end

local abilityReason2NoticeMap

function Utils.abilityReason2noticeId(reason, abilityType)
	if not abilityReason2NoticeMap then
		abilityReason2NoticeMap = {
			[AbilityConst.ABILITY_CAST_NOT_ENOUGH_EP] = NoticeDef.EP_LACK,
			[AbilityConst.ABILITY_CAST_NOT_ENOUGH_SP] = NoticeDef.SP_LACK,
			[AbilityConst.ABILITY_CAST_FAILED_IN_CD] = NoticeDef.CD_LACK,
			[AbilityConst.ABILITY_CAST_FAILED_NOT_IN_BURROW] = NoticeDef.BURROW_SKILL_RESTRICT,
			[AbilityConst.ABILITY_CAST_FAILED_IN_BURROW] = NoticeDef.NONBURROW_SKILL_RESTRICT,
			[AbilityConst.ABILITY_CAST_ABILITY_NOT_ENOUGH_ITEM] = NoticeDef.SHOP_ITEM_NOT_ENOUGH,
			[AbilityConst.ABILITY_CAST_FAILED_PET_NOT_FOUND] = NoticeDef.PET_ABILITY_DISABLE,
			[AbilityConst.ABILITY_CAST_FAILED_ROUGE_DUNGEON_NOT_IN_COMBAT] = NoticeDef.CAST_ABILITY_FAILED_ROUGE_DUNGEON_NOT_IN_COMBAT,
			[AbilityConst.ABILITY_CAST_FAILED_IN_TAKEROOT] = NoticeDef.IN_TAKE_ROOT_SATE,
			[AbilityConst.ABILITY_CAST_FAILED_LOADED_CNT] = NoticeDef.NEED_LOADED_CNT,
			[AbilityConst.ABILITY_CAST_FAILED_BACK_NOT_IN_COMBAT] = NoticeDef.BACK_NOT_IN_COMBAT,
			[AbilityConst.ABILITY_CAST_ABILITY_NOT_ENOUGH_WATER] = NoticeDef.WATER_LACK,
			[AbilityConst.ABILITY_CAST_FAILED_NOT_ENOUGH_STAMINA] = NoticeDef.STAMINA_NOT_ENOUGH,
			[AbilityConst.ABILITY_CAST_FAILED_CUR_STATE_FORBIDDEN] = NoticeDef.CUR_STATE_CANNOT_USE_ABILITY,
			[AbilityConst.ABILITY_CAST_FAILED_IN_FLY] = NoticeDef.CUR_STATE_CANNOT_USE_ABILITY
		}
	end

	if reason == AbilityConst.ABILITY_CAST_ABILITY_NOT_EXIST and abilityType == AbilityConst.EnumAbilityType.Ultimate then
		return NoticeDef.WITHOUT_COMBO_ABILITY
	end

	return abilityReason2NoticeMap[reason] or NoticeDef.FAIL
end

function Utils.keepDecimal(num, n)
	if type(num) ~= "number" then
		return num
	end

	n = n or 2

	if num < 0 then
		return -(math_abs(num) - math_abs(num) % 0.1^n)
	else
		return num - num % 0.1^n
	end
end

function Utils.genPetHandbookProgessRewardKey(catagory, progress)
	return catagory * 1000 + progress
end

function Utils.getPetBallActionConfigParams(actionType, templateId)
	local configData, limitId

	if actionType == Const.PET_BALL.ACTION_FEED then
		configData = PetFeedData[templateId]
		limitId = PetBallConfigData.feedLimit
	elseif actionType == Const.PET_BALL.ACTION_EXERCISE then
		configData = PetExerciseData[templateId]
		limitId = PetBallConfigData.exerciseLimit
	elseif actionType == Const.PET_BALL.ACTION_BREED then
		configData = PetBreedData[templateId]
		limitId = PetBallConfigData.breedLimit
	end

	return configData, limitId
end

function Utils.checkPetCanBreed(petInfo, subPetInfo, count)
	if petInfo == nil or subPetInfo == nil or count < 0 then
		return false
	end

	if petInfo.breedCount + count > Const.PET_BALL.PET_BREED_LIMIT or subPetInfo.breedCount + count > Const.PET_BALL.PET_BREED_LIMIT then
		return false
	end

	if bit.bxor(petInfo.gender, subPetInfo.gender) == 0 and petInfo.gender ~= Const.GENDER_TYPE_NONE then
		return false
	end

	local pdd = PetData[petInfo.templateId]
	local pddSub = PetData[subPetInfo.templateId]

	if pdd == nil or pddSub == nil then
		return false
	end

	if pdd.ethnicGroup and pddSub.ethnicGroup and pdd.ethnicGroup ~= pddSub.ethnicGroup then
		return false
	elseif pdd.stage and pddSub.stage and pdd.stage ~= pddSub.stage then
		return false
	end

	return true
end

function Utils.getRandGroupId(puppetOrPetInfo)
	local configData = puppetOrPetInfo:getConfigData()

	return configData and configData.randomTalentGroup
end

function Utils.getPetEggRandGroupId(eggConfigId)
	local phedd = PetHatchEggData[eggConfigId]

	return phedd and phedd.setRollGroup
end

function Utils.getForceRandGroupId(puppetOrPetInfo)
	local configData = puppetOrPetInfo:getConfigData()

	if configData == nil then
		return nil
	end

	if Utils.isPuppet(puppetOrPetInfo) then
		local puppet = puppetOrPetInfo

		if Utils.isDark(puppet) then
			return configData.darkRandomTalentGroup
		end

		if Utils.isElite(puppet) then
			return configData.eliteRandomTalentGroup
		end

		if Utils.isCrystal(puppet) then
			return configData.crystalRandomTalentGroup
		end

		if puppet.isCreatePlenty then
			return configData.createPlentyRandomTalentGroup
		end
	end

	return nil
end

function Utils.getTotalIndividualLevelMax(propIndex)
	return PetConfigData.individualPropMax or 0
end

function Utils.getBaseIndividualLevelMax(propIndex, pdd, propdd)
	local propdd = propdd or pdd.propId and PropertyData[pdd.propId] or {}

	return math.min(Utils.getTotalIndividualLevelMax(propIndex), propdd and propdd.individualLevelRandMax or Const.INT_MAX)
end

function Utils.modifyIndividualLearnLevel(index, prop, toLearnLevel)
	local maxLevel = Utils.getTotalIndividualLevelMax(index)
	local maxOffsetLevel = maxLevel - prop.indLv
	local offsetLevel = toLearnLevel - prop.iLvLn

	if maxOffsetLevel < offsetLevel then
		offsetLevel = maxOffsetLevel
	end

	prop.iLvLn = toLearnLevel
	prop.indLv = prop.indLv + offsetLevel
end

function Utils.resolveIndividualAddIndex(petInfo, boostAttr)
	boostAttr = tonumber(boostAttr) or 0

	local list = {}
	local basePropertyList = petInfo.basePropertyList
	local propEnhanceMax = PetConfigData.individualPropEnhanceMax or 0

	local function isFull(idx)
		local prop = basePropertyList[idx]

		if not prop then
			return true
		end

		return prop:getBaseIndividualLevel() >= propEnhanceMax
	end

	if boostAttr >= 1 and boostAttr <= 6 then
		if basePropertyList[boostAttr] and not isFull(boostAttr) then
			list[#list + 1] = boostAttr
		end

		return list
	end

	local configData = petInfo.getConfigData and petInfo:getConfigData()
	local recommend = configData and configData.recommend_attr or {}
	local hasRecommend = #recommend > 0

	if not hasRecommend and (boostAttr == -2 or boostAttr == -3 or boostAttr == -4) then
		boostAttr = 0
	end

	if boostAttr == 0 then
		local unfull = {}

		for idx = 1, 6 do
			if basePropertyList[idx] and not isFull(idx) then
				unfull[#unfull + 1] = idx
			end
		end

		if #unfull > 0 then
			list[#list + 1] = unfull[math.random(1, #unfull)]
		end
	elseif boostAttr == -1 then
		local minIdx, minLv = nil, math.huge

		for idx = 1, 6 do
			local prop = basePropertyList[idx]

			if prop and not isFull(idx) and minLv > prop.indLv then
				minIdx, minLv = idx, prop.indLv
			end
		end

		if minIdx then
			list[#list + 1] = minIdx
		end
	elseif boostAttr == -2 then
		local pickIdx, pickLv = nil, math.huge

		for _, idx in ipairs(recommend) do
			local prop = basePropertyList[idx]

			if prop and not isFull(idx) and pickLv > prop.indLv then
				pickIdx, pickLv = idx, prop.indLv
			end
		end

		if pickIdx then
			list[#list + 1] = pickIdx
		end
	elseif boostAttr == -3 then
		for _, idx in ipairs(recommend) do
			if basePropertyList[idx] and not isFull(idx) then
				list[#list + 1] = idx
			end
		end
	elseif boostAttr == -4 then
		local recommendSet = {}

		for _, idx in ipairs(recommend) do
			recommendSet[idx] = true
		end

		local candidates = {}

		for idx = 1, 6 do
			if not recommendSet[idx] and basePropertyList[idx] and not isFull(idx) then
				candidates[#candidates + 1] = idx
			end
		end

		if #candidates > 0 then
			list[#list + 1] = candidates[math.random(1, #candidates)]
		end
	end

	return list
end

function Utils.isAllIndividualFull(petInfo)
	if not petInfo or not petInfo.basePropertyList then
		return false
	end

	local propEnhanceMax = PetConfigData.individualPropEnhanceMax or 0

	for idx = 1, 6 do
		local prop = petInfo.basePropertyList[idx]

		if prop and propEnhanceMax > prop:getBaseIndividualLevel() then
			return false
		end
	end

	return true
end

function Utils.getIndividualAddCapacity(petInfo)
	if not petInfo or not petInfo.basePropertyList then
		return false, nil
	end

	local maxCount = PetConfigData.individualPropEnhanceTimesMax or 0

	if maxCount <= 0 or maxCount <= (petInfo.propertyCountByEvent or 0) then
		return false, nil
	end

	local propMax = PetConfigData.individualPropEnhanceMax or 0
	local capacityMap

	for idx, prop in petInfo.basePropertyList:items() do
		local remain = propMax - prop:getBaseIndividualLevel()

		if remain > 0 then
			capacityMap = capacityMap or {}
			capacityMap[idx] = remain
		end
	end

	if not capacityMap then
		return false, nil
	end

	return true, capacityMap
end

function Utils.getBasePropertySpeciesPoint(configData, propIndex)
	if not configData then
		return 0
	end

	local propName = Utils.getPropSpeciesAttrName(propIndex)
	local speciesPoint = configData[propName] or 0
	local propdd = configData.propId and PropertyData[configData.propId] or {}

	if propdd then
		speciesPoint = speciesPoint + (propdd[propName] or 0)
	end

	if speciesPoint < Const.BASE_SPECIES_POINT_MIN or speciesPoint > Const.BASE_SPECIES_POINT_MAX then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("speciesPoint out range", propName, speciesPoint, Const.BASE_SPECIES_POINT_MIN, Const.BASE_SPECIES_POINT_MAX)
		end

		speciesPoint = lume.clamp(speciesPoint, Const.BASE_SPECIES_POINT_MIN, Const.BASE_SPECIES_POINT_MAX)
	end

	return speciesPoint
end

function Utils.getPropertyInitDict(objType, pdd, propIndex, forceIndividualLevel, forceRandGroupId, individualLevelInfo, createPlentyTalentEffect)
	local propName = Utils.getPropSpeciesAttrName(propIndex)
	local speciesPoint = Utils.getBasePropertySpeciesPoint(pdd, propIndex)
	local propdd = pdd.propId and PropertyData[pdd.propId] or {}
	local indLv = 0

	if forceIndividualLevel == nil then
		local randGroup = forceRandGroupId

		if not randGroup or #randGroup == 0 then
			randGroup = {
				pdd.randomTalentGroup
			}
		end

		if randGroup == nil then
			logger:warn("randomTalentGroup is nil: %s", pdd.templateId)

			indLv = 0
		elseif individualLevelInfo == nil then
			logger:warn("individualLevelInfo is nil objType=%s petPrototypeId=%s defaultPet=%s", objType, pdd.petPrototypeId, pdd.defaultPet)

			indLv = 0
		else
			indLv = Utils._getPropertyInitIndividualLevelInfo(objType, pdd, propIndex, randGroup, individualLevelInfo, createPlentyTalentEffect)
		end
	elseif forceIndividualLevel == -1 then
		indLv = Utils.getTotalIndividualLevelMax(propIndex)
	else
		indLv = forceIndividualLevel
	end

	local individualLevelMax = Utils.getBaseIndividualLevelMax(propIndex, pdd, propdd)

	return {
		strengthPoint = 0,
		iLvLn = 0,
		speciesPoint = speciesPoint,
		indLv = lume.clamp(indLv or 0, 0, individualLevelMax)
	}
end

function Utils._getPropertyInitIndividualLevelInfo(objType, pdd, propIndex, forceRandGroupIdList, individualLevelInfo, createPlentyTalentEffect)
	if not individualLevelInfo then
		return 0
	end

	if individualLevelInfo.individualLevelList then
		return individualLevelInfo.individualLevelList[propIndex] or 0
	end

	if (individualLevelInfo.forcePropertyScoreStage or 0) > 0 then
		local recommendAttr = Utils.getPetRecommendAttr(pdd)

		if not recommendAttr or #recommendAttr ~= 2 then
			recommendAttr = {
				1,
				2
			}
		end

		local individualBaseSum = Utils.rollIndividualBaseSumByPropertyScoreStage(individualLevelInfo.forcePropertyScoreStage)

		if individualBaseSum ~= nil then
			individualLevelInfo.individualLevelList = Utils._genIndividualBaseByFormula(individualBaseSum, recommendAttr)
			individualLevelInfo.propertyScoreStage = Utils.getPropertyScoreStageByWeightedTotal(individualBaseSum)
			individualLevelInfo.individualWeightedSum = Utils.getTalentInitLevelSum(Utils.deepCopyTable(individualLevelInfo.individualLevelList), pdd.templateId)

			return individualLevelInfo.individualLevelList[propIndex] or 0
		end

		logger:warn("force propertyScoreStage failed stage=%s objType=%s petPrototypeId=%s defaultPet=%s", tostring(individualLevelInfo.forcePropertyScoreStage), tostring(objType), tostring(pdd.petPrototypeId), tostring(pdd.defaultPet))
	end

	local groupIds = {}

	if Utils.isTable(forceRandGroupIdList) then
		for _, id in ipairs(forceRandGroupIdList) do
			if id then
				groupIds[#groupIds + 1] = id
			end
		end
	elseif forceRandGroupIdList then
		groupIds[1] = forceRandGroupIdList
	end

	if #groupIds == 0 then
		return 0
	end

	local sideConfigs = {}

	for _, groupId in ipairs(groupIds) do
		local data = PetTalentRandomGroupData[groupId]

		if data and data.value then
			local method, params = Utils.safeUnpack(data.value)

			if method ~= nil and params ~= nil then
				sideConfigs[#sideConfigs + 1] = {
					method = method,
					params = params
				}
			end
		end
	end

	if #sideConfigs == 0 then
		return 0
	end

	local recommendAttr = Utils.getPetRecommendAttr(pdd)

	if not recommendAttr or #recommendAttr ~= 2 then
		if _G_IsDebugMode and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:warn("@property InitIndividualLevel no recommendAttr: objType=%s petPrototypeId=%s defaultPet=%s ", objType, pdd.petPrototypeId, pdd.defaultPet)
		end

		recommendAttr = {
			1,
			2
		}
	end

	local winner, individualList

	for _, cfg in ipairs(sideConfigs) do
		local result

		if Const.NEW_BASE_PRO_INIT_TYPE.Direct == cfg.method then
			result = Utils._rollIVByDirect(cfg.params, pdd.defaultPet)
		elseif Const.NEW_BASE_PRO_INIT_TYPE.Random == cfg.method then
			result = Utils._rollIVByRandom(cfg.params, createPlentyTalentEffect)
		elseif Const.NEW_BASE_PRO_INIT_TYPE.CubeRandom == cfg.method then
			result = Utils._rollIVByCube(cfg.params)
		else
			logger:warn("ivRoll unknown method=%s", tostring(cfg.method))
		end

		if result and (not winner or result.individualBaseSum > winner.individualBaseSum or result.individualBaseSum == winner.individualBaseSum and result.method < winner.method) then
			winner = result
			individualList = cfg.params
		end
	end

	if winner == nil then
		return 0
	end

	if winner.method ~= Const.NEW_BASE_PRO_INIT_TYPE.Direct then
		individualList = Utils._genIndividualBaseByFormula(winner.individualBaseSum, recommendAttr)
	end

	individualLevelInfo.individualLevelList = individualList
	individualLevelInfo.propertyScoreStage = Utils.getPropertyScoreStageByWeightedTotal(winner.individualBaseSum)
	individualLevelInfo.individualWeightedSum = Utils.getTalentInitLevelSum(Utils.deepCopyTable(individualList), pdd.templateId)

	return individualLevelInfo.individualLevelList[propIndex] or 0
end

function Utils.mapRawIndividualValuesToIndividualLevel(recommendAttr, rawIndividualValues)
	local isRecommend = {}

	for _, id in ipairs(recommendAttr) do
		isRecommend[id] = true
	end

	local nonRec = {}

	for i = 1, Const.BASE_PROPERTY_CNT do
		if not isRecommend[i] then
			table.insert(nonRec, i)
		end
	end

	local final = {}

	final[recommendAttr[1]] = rawIndividualValues[1]
	final[recommendAttr[2]] = rawIndividualValues[2]

	for i = 1, Const.BASE_PROPERTY_CNT - 2 do
		final[nonRec[i]] = rawIndividualValues[2 + i]
	end

	return final
end

function Utils.getPetRecommendAttr(pdd)
	local recommendAttr = pdd.recommend_attr or {}
	local recommendAttrCount = #recommendAttr

	if recommendAttrCount == 2 then
		return lume.sort(recommendAttr)
	end

	local function collectRecommendAttrs(petPrototypeId, visited, attrList)
		if not petPrototypeId or visited[petPrototypeId] then
			return
		end

		visited[petPrototypeId] = true

		local petEvolveData = PetEvolveData[petPrototypeId] or {}

		for _, evolveInfo in pairs(petEvolveData) do
			local targetPetId = evolveInfo.targetPetId

			if targetPetId and targetPetId > 0 then
				local tarPetTemplateId = PetPrototypeData[targetPetId] and PetPrototypeData[targetPetId].defaultPet or 0
				local targetPetData = PetData[tarPetTemplateId]

				if targetPetData then
					local tmpAttr = targetPetData.recommend_attr or {}

					if tmpAttr and #tmpAttr == 2 then
						table.insert(attrList, tmpAttr)
					end

					collectRecommendAttrs(targetPetData.petPrototypeId, visited, attrList)
				end
			end
		end
	end

	local attrList = {}
	local visited = {}

	collectRecommendAttrs(pdd.petPrototypeId, visited, attrList)

	if #attrList > 0 then
		recommendAttr = lume.randomchoice(attrList)

		return lume.sort(recommendAttr)
	end

	return nil
end

function Utils.getPropertyScoreStageByWeightedTotal(individualBaseSum)
	local stageSection = PetConfigData.PetEvaluateLevelRangeValue or {}
	local stage = 1

	for index, threshold in ipairs(stageSection) do
		if individualBaseSum < threshold then
			break
		else
			stage = index
		end
	end

	return stage
end

function Utils.rollIndividualBaseSumByPropertyScoreStage(stage)
	stage = tonumber(stage) or 0

	local stageCount = #(PetConfigData.PetEvaluateLevelRangeValue or {})

	if stage <= 0 or stageCount < stage then
		return nil
	end

	local stageInfo = PetTalentStageWeightRevertData[stage]

	if stageInfo and #stageInfo == 2 then
		return lume.weightRandomChoiceOne(stageInfo[1], stageInfo[2])
	end

	local minValue = PetConfigData.PetEvaluateLevelRangeValue[stage]
	local maxValue = PetConfigData.PetEvaluateLevelRangeValue[stage + 1]

	if minValue == nil then
		return nil
	end

	if maxValue == nil then
		maxValue = minValue

		for total, data in pairs(PetTalentAllWeightData) do
			if (data.weight or 0) > 0 and maxValue < total then
				maxValue = total
			end
		end

		maxValue = maxValue + 1
	end

	local elementsData = {}
	local weightsData = {}

	for total, data in pairs(PetTalentAllWeightData) do
		local weight = data.weight or 0

		if minValue <= total and total < maxValue and weight > 0 then
			elementsData[#elementsData + 1] = total
			weightsData[#weightsData + 1] = weight
		end
	end

	if #elementsData == 0 then
		return minValue
	end

	return lume.weightRandomChoiceOne(elementsData, weightsData)
end

function Utils._genIndividualBaseByFormula(totalIndividualLevel, recommendAttr)
	local formulaId = PetConfigData.petEvaluateLevelFormulaId or 3022

	if not FormulaData[formulaId] then
		return {
			0,
			0,
			0,
			0,
			0,
			0
		}
	end

	local rawIndividualValues = FormulaData[formulaId].formula(totalIndividualLevel, PetConfigData.fitPropEvaluateRatio or 1.2)

	if #rawIndividualValues ~= Const.BASE_PROPERTY_CNT then
		return {
			0,
			0,
			0,
			0,
			0,
			0
		}
	end

	return Utils.mapRawIndividualValuesToIndividualLevel(recommendAttr, rawIndividualValues)
end

function Utils._rollIVByDirect(params, templateId)
	local individualBaseSum = Utils.getTalentInitLevelSum(Utils.deepCopyTable(params), templateId)

	return {
		method = Const.NEW_BASE_PRO_INIT_TYPE.Direct,
		individualBaseSum = individualBaseSum
	}
end

function Utils._rollIVByRandom(params, createPlentyTalentEffect)
	local stageCount = #(PetConfigData.PetEvaluateLevelRangeValue or {})

	if #params ~= stageCount then
		logger:warn("ivRoll method 1 params count mismatch: cnt=%s", #params)

		return
	end

	local elementsData = {}
	local weightsData = {}

	for i = 1, #params do
		elementsData[i] = i
		weightsData[i] = math_max(params[i], 0) * (createPlentyTalentEffect and createPlentyTalentEffect[i] or 1)
	end

	local stage = lume.weightRandomChoiceOne(elementsData, weightsData)
	local stageInfo = PetTalentStageWeightRevertData[stage]

	if not stageInfo or #stageInfo ~= 2 then
		logger:warn("ivRoll method 1 stage info missing stage=%s", stage)

		return
	end

	local totalIndividualLevel = lume.weightRandomChoiceOne(stageInfo[1], stageInfo[2])

	return {
		method = Const.NEW_BASE_PRO_INIT_TYPE.Random,
		individualBaseSum = totalIndividualLevel
	}
end

function Utils._rollIVByCube(params)
	local minN = params and params[1] or 0
	local IndividualBaseSumList = {}
	local IndividualBaseWeightList = {}

	for idx, data in pairs(PetTalentAllWeightData) do
		local weight = data.weight or 0

		if minN <= idx and weight > 0 then
			IndividualBaseSumList[#IndividualBaseSumList + 1] = idx
			IndividualBaseWeightList[#IndividualBaseWeightList + 1] = weight
		end
	end

	assert(#IndividualBaseSumList == #IndividualBaseWeightList)

	local individualBaseSum = 0

	if #IndividualBaseSumList ~= 0 then
		individualBaseSum = lume.weightRandomChoiceOne(IndividualBaseSumList, IndividualBaseWeightList)
	end

	return {
		method = Const.NEW_BASE_PRO_INIT_TYPE.CubeRandom,
		individualBaseSum = individualBaseSum
	}
end

function Utils.getWeightByHeightBMI(height, bmi)
	return height * height * bmi
end

function Utils.getHeightRange(pdd)
	local minRange, maxRange = unpack(pdd.modelScaleRange or {})

	minRange = minRange or 0
	maxRange = maxRange or 1

	if pdd.scaleElite ~= nil then
		maxRange = math_max(maxRange, maxRange * pdd.scaleElite)
		minRange = math_min(minRange, minRange * pdd.scaleElite)
	end

	local min = lume.round((pdd.height or 0) * minRange, 0.01)
	local max = lume.round((pdd.height or 0) * maxRange, 0.01)

	return min, max
end

function Utils.getWeightRange(pdd)
	local minRange, maxRange = unpack(PetConfigData.bmiRateRange or {})

	minRange = minRange or 0
	maxRange = maxRange or 1

	local minHeight, maxHeight = Utils.getHeightRange(pdd)
	local min = lume.round(Utils.getWeightByHeightBMI(minHeight, (pdd.BMI or 0) * minRange), 0.01)
	local max = lume.round(Utils.getWeightByHeightBMI(maxHeight, (pdd.BMI or 0) * maxRange), 0.01)

	return min, max
end

function Utils.getHeightWeightTargetLine(pdd)
	local minRateLine, maxRateLine = unpack(PetConfigData.trophySet or {})

	minRateLine = minRateLine or 0
	maxRateLine = maxRateLine or 1

	local minHeight, maxHeight = Utils.getHeightRange(pdd)
	local heightMinLine = minHeight + (maxHeight - minHeight) * (minRateLine - 0)
	local heightMaxLine = maxHeight - (maxHeight - minHeight) * (1 - maxRateLine)
	local minWeight, maxWeight = Utils.getWeightRange(pdd)
	local weightMinLine = minWeight + (maxWeight - minWeight) * (minRateLine - 0)
	local weightMaxLine = maxWeight - (maxWeight - minWeight) * (1 - maxRateLine)

	return heightMinLine, heightMaxLine, weightMinLine, weightMaxLine
end

function Utils.debugHeightWeightRange(needTemplateId)
	local res1, res2, res3 = {}, {}, {}

	local function funcPushRes(templateId, pdd, prefix)
		local minScale, maxScale = unpack(pdd.modelScaleRange or {})
		local minHeight, maxHeight = Utils.getHeightRange(pdd)
		local minWeight, maxWeight = Utils.getWeightRange(pdd)
		local heightMinLine, heightMaxLine, weightMinLine, weightMaxLine = Utils.getHeightWeightTargetLine(pdd)

		res1[templateId] = string.format(prefix .. " minHeight:%.2f, maxHeight:%.2f, minWeight:%.2f, maxWeight:%.2f", minHeight, maxHeight, minWeight, maxWeight)
		res2[templateId] = string.format(prefix .. " heightMinLine:%.2f, heightMaxLine:%.2f, weightMinLine:%.2f, weightMaxLine:%.2f", heightMinLine, heightMaxLine, weightMinLine, weightMaxLine)
		res3[templateId] = string.format(prefix .. " minScale:%.2f, maxScale:%.2f, height:%.2f, BMI:%.2f, scaleBoss:%.2f, scaleElite:%.2f", minScale, maxScale, pdd.height or 0, pdd.BMI or 0, pdd.scaleBoss or 0, pdd.scaleElite or 0)
	end

	for templateId, pdd in pairs(PetData) do
		if needTemplateId == nil or needTemplateId == templateId then
			funcPushRes(templateId, pdd, "pet")
		end
	end

	for templateId, pdd in pairs(PuppetData) do
		if needTemplateId == nil or needTemplateId == templateId or needTemplateId == pdd.spriteIdAfterCatch then
			funcPushRes(templateId, pdd, "puppet")
		end
	end

	return {
		res1,
		res2,
		res3
	}
end

function Utils.getLoadCapacityLevel(loadValue, loadBearingValue)
	local weight = loadBearingValue == 0 and 0 or loadValue * 100 / loadBearingValue
	local maxLevel = #SysConfigData.WEIGHT_RANGE

	for i = maxLevel, 2, -1 do
		local val = SysConfigData.WEIGHT_RANGE[i]

		if val < weight then
			return i
		end
	end

	return 1
end

function Utils.isTargetInSelfRescue(ent)
	if not ent or not ent.lastFallenAidActorId then
		return false
	end

	return ent.lastFallenAidActorId == ent.actorId
end

function Utils.getExploreSkillTypeByState(state)
	if CharacterStateConst.isChildOfState(state, CharacterStateConst.CLIMBING) then
		return Const.EXPLORE_SKILL_CLIMBING
	elseif CharacterStateConst.isChildOfState(state, CharacterStateConst.GLIDING) then
		return Const.EXPLORE_SKILL_GLIDING
	elseif CharacterStateConst.isChildOfState(state, CharacterStateConst.SWIMMING) then
		return Const.EXPLORE_SKILL_SWIMMING
	end

	return nil
end

function Utils.getPetBaseId(templateId)
	return math.floor(templateId / 100)
end

local _targetPosData = {}

function Utils.InitcheckPositionMatchByClient(sceneId)
	local stpd = TargetPositionData[sceneId]

	_targetPosData = {}

	if stpd == nil then
		return
	end

	for id, tpdd in pairs(stpd) do
		local tpos = tpdd.position

		if tpos and tpdd.arriveType == Const.ARRIVE_TYPE_SPHERE then
			local arriveParam = tpdd.arriveParam
			local radius = arriveParam and arriveParam[1]

			if radius ~= nil then
				_targetPosData[id] = {
					tpos[1],
					tpos[2],
					tpos[3],
					(radius + Const.SERVER_POS_CHECK_TOLERANCE)^2
				}
			end
		end
	end
end

if pg.component ~= "client" then
	function Utils.checkPositionMatch(scene, pos, targetPositionConfigId, enableServerTolerance)
		local stpd = TargetPositionData[scene]

		if stpd == nil then
			return false
		end

		local tpdd = stpd[targetPositionConfigId]

		if tpdd == nil then
			return false
		end

		local tpos = tpdd.position

		if tpos == nil then
			return false
		end

		if tpdd.arriveType == Const.ARRIVE_TYPE_SPHERE then
			local arriveParam = tpdd.arriveParam
			local radius = arriveParam and arriveParam[1]

			if radius == nil then
				return false
			end

			if pg.component == "game" and enableServerTolerance then
				radius = radius + Const.SERVER_POS_CHECK_TOLERANCE
			end

			local dx, dy, dz = pos[1] - tpos[1], pos[2] - tpos[2], pos[3] - tpos[3]

			return dx * dx + dy * dy + dz * dz <= radius * radius
		end

		return false
	end

	function Utils.existPositionMatch(triggerId)
		return true
	end

	function Utils.checkPositionMatchClient(targetPositionConfigId)
		return false
	end
else
	function Utils.checkPositionMatch(scene, pos, targetPositionConfigId, enableServerTolerance)
		local tpos = _targetPosData[targetPositionConfigId]

		if tpos == nil then
			return false
		end

		local dx, dy, dz = pos[1] - tpos[1], pos[2] - tpos[2], pos[3] - tpos[3]

		return dx * dx + dy * dy + dz * dz <= tpos[4]
	end

	function Utils.checkPositionMatchClient(targetPositionConfigId)
		local tpos = _targetPosData[targetPositionConfigId]

		if tpos == nil then
			return false
		end

		local ent = pg.me

		if not ent.space then
			return false
		end

		local pos = ent:getPosition()
		local dx, dy, dz = pos[1] - tpos[1], pos[2] - tpos[2], pos[3] - tpos[3]

		return dx * dx + dy * dy + dz * dz <= tpos[4]
	end

	function Utils.existPositionMatch(triggerId)
		return _targetPosData[triggerId] ~= nil
	end
end

function Utils.checkRotationMatch(curRot, lastRot, angle)
	if lastRot == nil then
		return false
	end

	if angle == nil then
		return curRot ~= lastRot
	elseif angle <= Quaternion.Angle(curRot, lastRot) then
		return true
	end

	return false
end

function Utils.formulaSafeCall(minNum, funcId, ...)
	local fdd = FormulaData[funcId]

	if fdd == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("formulaSafeCall no function, funcId=%s", tostring(funcId))
		end

		return minNum
	end

	local ret = {
		SafeCallbackWithReturn(fdd.formula, ...)
	}

	if #ret == 1 and type(ret[1]) == "number" then
		local min, max = Utils.formulaRange(minNum, funcId)

		ret[1] = lume.clamp(ret[1], min, max)
	end

	return unpack(ret, 1, lume.getListLenWithNil(ret))
end

function Utils.formulaRange(minNum, funcId)
	local fdd = FormulaData[funcId]

	if fdd == nil then
		return 0, 0
	end

	local min = fdd.range and fdd.range[1] or Const.INT_MIN
	local max = fdd.range and fdd.range[2] or Const.INT_MAX

	if type(min) ~= "number" or type(max) ~= "number" then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("formulaRange error, funcId=%s, range=%s", tostring(funcId), inspect(fdd.range))
		end

		return 0, 0
	end

	if minNum ~= nil then
		min = math.max(min, minNum)
	end

	return min, max
end

function Utils.debugFormula(loopCount, funcId, ...)
	local res = {}

	for i = 1, loopCount do
		res[1000 + i] = {
			Utils.formulaSafeCall(nil, funcId, ...)
		}
	end

	return res
end

local function isDefNil(v)
	return type(v) == "string" and v == Const.NIL
end

function Utils.updateTableByDefine(resultTable, updateTable, defineTable, errorPrompt, needSetMetatable)
	if type(resultTable) ~= "table" or type(defineTable) ~= "table" then
		logger:warn("updateTableByDefine invalid param, resultTable=%s, defineTable=%s", inspect(resultTable), inspect(defineTable))

		return resultTable
	end

	errorPrompt = errorPrompt or "ERROR"

	local DEF_INDEX_TYPE = 1
	local DEF_INDEX_DEFAULT_VAL = 2
	local deepCopyTable = Utils.deepCopyTable

	for key, def in pairs(defineTable) do
		if resultTable[key] == nil and def[DEF_INDEX_DEFAULT_VAL] ~= nil then
			resultTable[key] = deepCopyTable(def[DEF_INDEX_DEFAULT_VAL])
		end
	end

	if updateTable ~= nil then
		for key, val in pairs(updateTable) do
			local def = defineTable[key]

			if def == nil then
				logger:warn("[%s]updateTableByDefine undefined key, key=%s, updateTable=%s", errorPrompt, key, inspect(updateTable))
			elseif def[DEF_INDEX_TYPE] ~= type(val) then
				logger:warn("[%s]updateTableByDefine invalid value type, key=%s, needtype=%s, realtype=%s", errorPrompt, key, def[DEF_INDEX_TYPE], type(val))
			end

			if isDefNil(val) then
				resultTable[key] = nil
			else
				resultTable[key] = deepCopyTable(val)
			end
		end
	end

	for key, val in pairs(resultTable) do
		local def = defineTable[key]

		if def == nil then
			logger:warn("[%s]updateTableByDefine undefined key, key=%s, resultTable=%s", errorPrompt, key, inspect(resultTable))
		elseif def[DEF_INDEX_TYPE] ~= type(val) then
			logger:warn("[%s]updateTableByDefine invalid value type, key=%s, needtype=%s, realtype=%s", errorPrompt, key, def[DEF_INDEX_TYPE], type(val))
		end
	end

	if needSetMetatable then
		local curMt = getmetatable(resultTable)

		if curMt == nil then
			local mt = {
				banInspect = true,
				__defineTable = defineTable,
				__newindex = function(tbl, key, val)
					local def = defineTable[key]

					if def == nil then
						logger:warn("[%s]__newindex undefined key, key=%s", errorPrompt, key)
					elseif val ~= nil and def[DEF_INDEX_TYPE] ~= type(val) then
						logger:warn("[%s]__newindex invalid value type, key=%s, needtype=%s, realtype=%s", errorPrompt, key, def[DEF_INDEX_TYPE], type(val))
					end

					rawset(tbl, key, val)
				end
			}

			setmetatable(resultTable, mt)
		elseif curMt.__defineTable ~= defineTable then
			logger:warn("[%s]updateTableByDefine already has metatable", errorPrompt)
		end
	end

	return resultTable
end

function Utils.protoCodec()
	if pg.component == "game" then
		return require("Core.Server.GameServerRepo").protoCodec
	else
		return require("Core.Client.ClientRepo").protoCodec
	end
end

function Utils.encodeToStr(data)
	return Utils.protoCodec():safeEncodeToStr(data)
end

function Utils.decodeFromStr(data)
	return Utils.protoCodec():safeDecodeFromStr(data)
end

function Utils.pvpGetValidFeatureMap(templateId)
	local res = {}
	local pptd = TmpPetTemplateData[templateId]
	local pdd = pptd and PetData[pptd.templateBaseId]

	if pptd == nil or pdd == nil then
		return res
	end

	if ToBool(pptd.useTemplateFeatures) then
		for _, characterId in pairs(pdd.feature or EMPTY_TABLE) do
			res[characterId] = true
		end
	end

	for _, characterId in pairs(pptd.otherFeatures or EMPTY_TABLE) do
		res[characterId] = true
	end

	if pptd.defaultFeature ~= nil then
		res[pptd.defaultFeature] = true
	end

	return res
end

function Utils.pvpGetValidAbilityMap(templateId)
	local res = {}
	local pptd = TmpPetTemplateData[templateId]
	local pdd = pptd and PetData[pptd.templateBaseId]

	if pptd == nil or pdd == nil then
		return res
	end

	if ToBool(pptd.useTemplateSkills) then
		local ActorUtils = require("Common.Utils.ActorUtils")
		local _, validAbilityList = ActorUtils.genPvpAbility(pptd.templateBaseId)

		for _, abilityParamId in pairs(validAbilityList or EMPTY_TABLE) do
			res[abilityParamId] = true
		end
	end

	for _, abilityParamId in pairs(pptd.otherSkills or EMPTY_TABLE) do
		res[abilityParamId] = true
	end

	return res
end

function Utils.genEmptyPvpPetInfo(templateId)
	local dict = {}
	local pptd = TmpPetTemplateData[templateId]
	local pdd = pptd and PetData[pptd.templateBaseId]

	if pptd == nil or pdd == nil then
		return nil
	end

	dict.templateId = templateId
	dict.curCharacter = pptd.defaultFeature or 0
	dict.abilityPresetMap = {}

	for presetId = 1, Const.PET_ABILITY_PRESET_COUNT do
		dict.abilityPresetMap[presetId] = {}

		for abilityType, _ in pairs(AbilityConst.CAN_PRESET_ABILITY_TYPE) do
			dict.abilityPresetMap[presetId][abilityType] = 0
		end
	end

	dict.curAbilityPreset = 1

	return dict
end

function Utils.genPvpPetInfo(pet)
	if not pet or not pet.abilityPresetMap then
		return nil
	end

	local dict = {}

	dict.templateId = pet.templateId
	dict.curCharacter = pet.characterInfo.curCharacter
	dict.abilityPresetMap = {}

	for presetId, v in pairs(pet.abilityPresetMap) do
		dict.abilityPresetMap[presetId] = {}

		for abilityType, sub in pairs(v) do
			dict.abilityPresetMap[presetId][abilityType] = sub
		end
	end

	dict.curAbilityPreset = pet.curAbilityPreset

	return dict
end

function Utils.getPetFamilyLearnItem(ethnicGroup, fromLevel, toLevel)
	local lo = math.min(fromLevel, toLevel)
	local hi = math.max(fromLevel, toLevel)

	if hi <= lo then
		return {}
	end

	local familyData = PetFamilyData[ethnicGroup or 0]

	if not familyData then
		return {}
	end

	local tierNeedDict = {}

	for i = lo + 1, hi do
		local ppldd = PetPropLearnData[i]

		if ppldd and ppldd.costItemlevel and (ppldd.costItemNum or 0) > 0 then
			local tier = ppldd.costItemlevel

			tierNeedDict[tier] = (tierNeedDict[tier] or 0) + ppldd.costItemNum
		end
	end

	local result = {}

	for tier, need in pairs(tierNeedDict) do
		local itemId = familyData.potentialPointItems and familyData.potentialPointItems[tier]

		if itemId and itemId ~= 0 then
			result[itemId] = (result[itemId] or 0) + need
		end
	end

	return result
end

function Utils.calcPetLearnCost(ethnicGroup, fromLevel, toLevel)
	local lo = math.min(fromLevel, toLevel)
	local hi = math.max(fromLevel, toLevel)

	if hi <= lo then
		return {}
	end

	local itemDict = Utils.getPetFamilyLearnItem(ethnicGroup, lo, hi)

	for i = lo + 1, hi do
		local ppldd = PetPropLearnData[i]

		if ppldd and ppldd.costItem then
			for _, itemInfo in ipairs(ppldd.costItem) do
				local itemId, itemNum = itemInfo[1], itemInfo[2]

				if itemId and itemNum then
					itemDict[itemId] = (itemDict[itemId] or 0) + itemNum
				end
			end
		end
	end

	return itemDict
end

function Utils.getPetResonanceFamilyItemDIct(ethnicGroup, itemNumList)
	local result = {}
	local familyData = PetFamilyData[ethnicGroup or 0]
	local mainList = familyData and familyData.enhanceItem
	local backupList = familyData.enhanceItemBackup

	for i, num in ipairs(itemNumList) do
		local mainId = mainList[i]

		if num > 0 and mainId and mainId ~= 0 then
			result[#result + 1] = {
				mainId,
				backupList and backupList[i],
				num
			}
		end
	end

	return result
end

function Utils.allocPetResonanceFamilyConsume(reqList, player)
	local ItemUtils = require("Common.Utils.ItemUtils")
	local consumeDict, remaining = {}, {}

	local function take(itemId, want)
		if not itemId or itemId == 0 or want <= 0 then
			return 0
		end

		if remaining[itemId] == nil then
			remaining[itemId] = player and ItemUtils.getItemCountById(player, itemId) or 0
		end

		local use = math.min(remaining[itemId], want)

		remaining[itemId] = remaining[itemId] - use
		consumeDict[itemId] = (consumeDict[itemId] or 0) + use

		return use
	end

	for _, req in ipairs(reqList or EMPTY_TABLE) do
		local mainId, backupId, num = req[1], req[2], req[3]
		local lack = num - take(mainId, num)

		lack = lack - take(backupId, lack)

		if lack > 0 then
			return false, consumeDict, mainId
		end
	end

	return true, consumeDict
end

function Utils.calcPetResonanceCost(petInfo, toStage, toLevel, fromStage, fromLevel)
	fromStage = fromStage or 1
	fromLevel = fromLevel or 0

	local itemDict = {}
	local ethnicGroup = petInfo:getConfigData().ethnicGroup or 0
	local mainElementType = petInfo:getConfigData().mainElementType

	for stage = fromStage, toStage do
		local stageData = ResonanceData[stage]

		if stageData then
			local beginLevel = stage == fromStage and fromLevel or 0
			local endLevel = stage == toStage and toLevel or lume.tableLength(stageData)

			for level = beginLevel, endLevel do
				local levelData = stageData[level]

				if not levelData then
					break
				end

				if stage ~= fromStage or level ~= fromLevel then
					if levelData.itemNum then
						for _, req in ipairs(Utils.getPetResonanceFamilyItemDIct(ethnicGroup, levelData.itemNum)) do
							itemDict[req[1]] = (itemDict[req[1]] or 0) + req[3]
						end
					end

					local elementItemNum = levelData.elementItemNum

					if elementItemNum and elementItemNum > 0 and mainElementType then
						local elementItemId = PetConfigData.petElementItemId[mainElementType]

						if elementItemId then
							itemDict[elementItemId] = (itemDict[elementItemId] or 0) + elementItemNum
						end
					end

					if levelData.extraItems then
						for _, extra in ipairs(levelData.extraItems) do
							local itemId, itemNum = extra[1], extra[2]

							if itemId and itemNum then
								itemDict[itemId] = (itemDict[itemId] or 0) + itemNum
							end
						end
					end
				end
			end
		end
	end

	return itemDict
end

function Utils.needPetLearnTransfer(sourcePetInfo, targetPetInfo, mode)
	if mode == Const.INHERITANCE_SWAP then
		for propIndex, sourceProp in sourcePetInfo.basePropertyList:items() do
			local targetProp = targetPetInfo.basePropertyList[propIndex]

			if sourceProp.iLvLn ~= targetProp.iLvLn then
				return true
			end
		end

		return false
	else
		for _, sourceProp in sourcePetInfo.basePropertyList:items() do
			if sourceProp.iLvLn > 0 then
				return true
			end
		end

		for _, targetProp in targetPetInfo.basePropertyList:items() do
			if targetProp.iLvLn > 0 then
				return true
			end
		end

		return false
	end
end

function Utils.getPetPropertyEnhancedCount(petInfo)
	if not petInfo then
		return 0
	end

	local propertyEnhancedCount = petInfo.propertyEnhancedCount or 0

	if propertyEnhancedCount > 0 then
		return propertyEnhancedCount
	end

	local enhancedCount = 0

	if petInfo.basePropertyList and petInfo.basePropertyList.items then
		for _, prop in petInfo.basePropertyList:items() do
			enhancedCount = math.max(enhancedCount, Utils.getBasePropertyEnhancedCount(prop))
		end
	elseif petInfo.basePropertyList then
		for _, prop in pairs(petInfo.basePropertyList) do
			enhancedCount = math.max(enhancedCount, Utils.getBasePropertyEnhancedCount(prop))
		end
	end

	return math.max(propertyEnhancedCount, enhancedCount)
end

function Utils.isPetPropertyEnhanced(petInfo)
	if not petInfo then
		return false
	end

	local maxPropertyEnhancedCount = PetConfigData.PET_PROPENHANCE_MAX_COUNT or 2

	return maxPropertyEnhancedCount <= Utils.getPetPropertyEnhancedCount(petInfo)
end

function Utils.getBasePropertyEnhancedCount(prop)
	if not prop then
		return 0
	end

	return prop.enhancedCount or 0
end

function Utils.needPetTalentTransfer(sourcePetInfo, targetPetInfo, mode)
	if mode == Const.INHERITANCE_SWAP then
		if Utils.getPetPropertyEnhancedCount(sourcePetInfo) ~= Utils.getPetPropertyEnhancedCount(targetPetInfo) then
			return true
		end

		for propIndex, sourceProp in sourcePetInfo.basePropertyList:items() do
			local targetProp = targetPetInfo.basePropertyList[propIndex]

			if Utils.getBasePropertyEnhancedCount(sourceProp) ~= Utils.getBasePropertyEnhancedCount(targetProp) then
				return true
			end
		end

		return false
	else
		if Utils.getPetPropertyEnhancedCount(sourcePetInfo) > 0 or Utils.getPetPropertyEnhancedCount(targetPetInfo) > 0 then
			return true
		end

		for propIndex, sourceProp in sourcePetInfo.basePropertyList:items() do
			local targetProp = targetPetInfo.basePropertyList[propIndex]

			if Utils.getBasePropertyEnhancedCount(sourceProp) > 0 or Utils.getBasePropertyEnhancedCount(targetProp) > 0 then
				return true
			end
		end

		return false
	end
end

function Utils.needPetResonanceTransfer(sourcePetInfo, targetPetInfo, mode)
	local srcRI = sourcePetInfo.resonanceInfo
	local tgtRI = targetPetInfo.resonanceInfo

	if mode == Const.INHERITANCE_SWAP then
		return srcRI.resonanceStage ~= tgtRI.resonanceStage or srcRI.resonanceLevel ~= tgtRI.resonanceLevel
	else
		local srcHas = srcRI.resonanceStage > 1 or srcRI.resonanceLevel > 0
		local tgtHas = tgtRI.resonanceStage > 1 or tgtRI.resonanceLevel > 0

		return srcHas or tgtHas
	end
end

function Utils.normalizeInheritanceMode(mode)
	if mode == Const.INHERITANCE_SWAP or mode == Const.INHERITANCE_INHERIT then
		return mode
	end

	if mode ~= nil then
		logger:warn("invalid inheritanceSetting mode=%s, fallback to SWAP", tostring(mode))
	end

	return Const.INHERITANCE_SWAP
end

function Utils.needPetLevelTransfer(sourcePetInfo, targetPetInfo, mode)
	if mode == Const.INHERITANCE_SWAP then
		return sourcePetInfo.level ~= targetPetInfo.level or sourcePetInfo.exp ~= targetPetInfo.exp
	else
		return sourcePetInfo.level > 1
	end
end

function Utils.needPetTalentFruitTransfer(sourcePetInfo, targetPetInfo, fruitSetting)
	if fruitSetting ~= Const.INHERITANCE_FRUIT_SWAP then
		return false
	end

	return Utils.needPetTalentTransfer(sourcePetInfo, targetPetInfo, Const.INHERITANCE_SWAP)
end

function Utils.getRandomShinyStyle()
	local count = SysConfigData.ShinyStyleCount or 15

	return math.random(1, count)
end

function Utils.randomPetShinyStyle(shinyStyleRandWeightId, label, excludeShinyStyleDict)
	if not Utils.isLabelShiny(label) or shinyStyleRandWeightId < 1 then
		return 0
	end

	local weightDict = {}
	local weightNum = 0

	for id, data in pairs(PetShinyStyleData) do
		local weights = data.weight or {}

		if shinyStyleRandWeightId <= #weights and weights[shinyStyleRandWeightId] > 0 and (not excludeShinyStyleDict or not excludeShinyStyleDict[id]) then
			weightDict[id] = weights[shinyStyleRandWeightId]
			weightNum = weightNum + 1
		end
	end

	if weightNum <= 0 then
		return Utils.getRandomShinyStyle()
	end

	return lume.weightedchoice(weightDict)
end

function Utils.needPetInheritanceTransfer(sourcePetInfo, targetPetInfo, setting, fruitSetting)
	setting = setting or {}
	fruitSetting = fruitSetting or Const.INHERITANCE_FRUIT_KEEP

	local resonace = setting[Const.INHERITANCE_IDX_RESONANCE]
	local learn = setting[Const.INHERITANCE_IDX_LEARN]
	local level = setting[Const.INHERITANCE_IDX_LEVEL]
	local qualityOver = Utils.checkPetInheritanceQuality(sourcePetInfo, targetPetInfo)
	local resonanceMode = Utils.normalizeInheritanceMode(resonace)
	local learnMode = Utils.normalizeInheritanceMode(learn)
	local levelMode = Const.INHERITANCE_SWAP
	local needLearn = Utils.needPetLearnTransfer(sourcePetInfo, targetPetInfo, learnMode)
	local needTalentFruit = Utils.needPetTalentFruitTransfer(sourcePetInfo, targetPetInfo, fruitSetting)
	local needResonance = Utils.needPetResonanceTransfer(sourcePetInfo, targetPetInfo, resonanceMode)
	local hasTransfer = needLearn or needTalentFruit or needResonance

	return {
		qualityOver = qualityOver,
		hasTransfer = hasTransfer,
		needAny = qualityOver and hasTransfer,
		learnMode = learnMode,
		levelMode = levelMode,
		resonanceMode = resonanceMode,
		talentFruitMode = fruitSetting
	}
end

function Utils.checkPetInheritanceQuality(sourcePetInfo, targetPetInfo)
	local sourceResoance = sourcePetInfo.resonanceInfo
	local targetResoance = targetPetInfo.resonanceInfo
	local hasBetter = false

	if sourceResoance.resonanceStage ~= targetResoance.resonanceStage then
		if sourceResoance.resonanceStage < targetResoance.resonanceStage then
			return false
		end

		hasBetter = true
	elseif sourceResoance.resonanceLevel ~= targetResoance.resonanceLevel then
		if sourceResoance.resonanceLevel < targetResoance.resonanceLevel then
			return false
		end

		hasBetter = true
	end

	local sourceIndividualResetItems = sourcePetInfo.basePropertyList:getIndividualResetPayback()
	local targetIndividualResetItems = targetPetInfo.basePropertyList:getIndividualResetPayback()
	local familyData = PetFamilyData[sourcePetInfo:getEthnicGroup()]

	if familyData then
		for level = #familyData.potentialPointItems, 1, -1 do
			local itemId = familyData.potentialPointItems[level]
			local sourceNumInfo = sourceIndividualResetItems[itemId]
			local sourceItemCount = sourceNumInfo and sourceNumInfo[Const.INV_BOUND_TYPE_INSENSITIVE] or 0
			local targetNumInfo = targetIndividualResetItems[itemId]
			local targetItemCount = targetNumInfo and targetNumInfo[Const.INV_BOUND_TYPE_INSENSITIVE] or 0

			if targetItemCount ~= sourceItemCount then
				return targetItemCount < sourceItemCount
			end
		end
	end

	return hasBetter
end

function Utils.checkInheritPetPropLevel(player, sourcePetId, targetPetId)
	if sourcePetId == targetPetId then
		return NoticeDef.ERROR_CLIENT_PARAM
	end

	local sourcePetInfo = player.pets[sourcePetId]

	if sourcePetInfo == nil then
		return NoticeDef.ERROR_PET_NOT_FOUND
	end

	local targetPetInfo = player.pets[targetPetId]

	if targetPetInfo == nil then
		return NoticeDef.ERROR_PET_NOT_FOUND
	end

	for i_, templateId in pairs(PetConfigData.PET_INHERIT_UNLIMITED_TEMPIDS) do
		if sourcePetInfo.templateId == templateId then
			return NoticeDef.SUCCESS
		end
	end

	if sourcePetInfo:getEthnicGroup() ~= targetPetInfo:getEthnicGroup() then
		return NoticeDef.ERROR_CLIENT_PARAM
	end

	return NoticeDef.SUCCESS
end

function Utils.isIndividualFullLearned(dict)
	for idx = 1, Const.BASE_PROPERTY_CNT do
		local prop = dict[idx]

		if prop == nil or prop.indLv < Utils.getTotalIndividualLevelMax(idx) then
			return false
		end
	end

	return true
end

function Utils.getIndividualInitStage(dict, templateId, curRating)
	curRating = curRating or 0

	local coefficient = PetConfigData.fitPropEvaluateRatio or 1.2
	local stageSection = PetConfigData.PetEvaluateLevelRange or {
		0,
		0.4,
		0.7,
		0.95
	}
	local configData = PetData[templateId]
	local recommend = configData and configData.recommend_attr
	local talentInitLevelTable = lume.imap(dict, function(v)
		return v.indLv - v.iLvLn
	end)

	if recommend ~= nil then
		for _, v in pairs(recommend) do
			talentInitLevelTable[v] = talentInitLevelTable[v] and talentInitLevelTable[v] * coefficient
		end
	end

	local talentInitLevelSum = lume.sum(talentInitLevelTable)
	local talentInitLevelMax = Utils.getTotalIndividualLevelMax() * Const.BASE_PROPERTY_CNT
	local stage = 1
	local rating = talentInitLevelSum / talentInitLevelMax

	for index, needRating in ipairs(stageSection) do
		if rating < needRating then
			break
		else
			stage = index
		end
	end

	return curRating < stage and stage or curRating
end

function Utils.getIndividualInitStageNew(dict, templateId, curRating, useRecommendAttr)
	curRating = curRating or 0

	local stageSection = PetConfigData.PetEvaluateLevelRangeValue
	local talentInitLevelTable = lume.imap(dict, function(v)
		return BaseProperty.getBaseIndividualLevel(v)
	end)
	local talentInitLevelSum = Utils.getTalentInitLevelSum(talentInitLevelTable, templateId, useRecommendAttr)
	local stage = 1

	for index, needRating in ipairs(stageSection) do
		if talentInitLevelSum < needRating then
			break
		else
			stage = index
		end
	end

	return curRating < stage and stage or curRating, talentInitLevelSum
end

function Utils.cleanExchangeBaseProperty(dict)
	for _, baseProperty in pairs(dict) do
		baseProperty.indLv = BaseProperty.getBaseIndividualLevel(baseProperty, true, true)
		baseProperty.iLvLn = 0
		baseProperty.iLvEv = 0
		baseProperty.iLvEx = 0
		baseProperty.enhancedCount = 0
	end
end

function Utils.getBaseIndividualInitStageNew(dict, templateId, curRating, useRecommendAttr)
	curRating = curRating or 0

	local stageSection = PetConfigData.PetEvaluateLevelRangeValue
	local BaseProperty = require("CustomTypes.BaseProperty")
	local talentInitLevelTable = lume.imap(dict, function(v)
		return BaseProperty.getBaseIndividualLevel(v, true, true)
	end)
	local talentInitLevelSum = Utils.getTalentInitLevelSum(talentInitLevelTable, templateId, useRecommendAttr)
	local stage = 1

	for index, needRating in ipairs(stageSection) do
		if talentInitLevelSum < needRating then
			break
		else
			stage = index
		end
	end

	return curRating < stage and stage or curRating, talentInitLevelSum
end

function Utils.getTalentInitLevelSum(talentInitLevelTable, templateId, useRecommendAttr)
	local coefficient = PetConfigData.fitPropEvaluateRatio or 1.2
	local configData = PetData[templateId]
	local recommend = configData and configData.recommend_attr or {}

	if useRecommendAttr ~= true or #recommend ~= 2 then
		recommend = {}

		for k, v in pairs(talentInitLevelTable) do
			if #recommend < 2 then
				table.insert(recommend, k)
			else
				local idx = 1

				if talentInitLevelTable[recommend[2]] < talentInitLevelTable[recommend[1]] then
					idx = 2
				end

				if v > talentInitLevelTable[recommend[idx]] then
					recommend[idx] = k
				end
			end
		end
	end

	for _, v in pairs(recommend) do
		talentInitLevelTable[v] = talentInitLevelTable[v] and talentInitLevelTable[v] * coefficient
	end

	return lume.sum(talentInitLevelTable)
end

function Utils.genRefreshTotalParamsByPetInfo(level, scoreStage, isFullLearned)
	local ratingPropUpTable = PetConfigData["ratingPropImprovement" .. scoreStage]
	local allPropMaxUpTable = isFullLearned and PetConfigData.allPropMaxImprovement or nil

	return {
		needExtraUp = true,
		objLevel = level,
		ratingPropUpTable = ratingPropUpTable,
		allPropMaxUpTable = allPropMaxUpTable
	}
end

function Utils.PropertyRefreshTotal(idx, dict, params, speciesPoint)
	local individualPoint = BaseProperty.getAllIndividualLevel(dict)
	local rawTotal = 0
	local totalByUp = 0
	local attributeSatisfy, attributeUp
	local propName = Utils.getPropSpeciesAttrName(idx)
	local objLevel = params.objLevel or 1
	local mathFloorFun = params.mathFloorFun or math_floor

	speciesPoint = speciesPoint == nil and dict.speciesPoint or speciesPoint

	if propName == "species_hp_max_v" then
		rawTotal = FormulaData[3003].formula(speciesPoint, individualPoint, objLevel, mathFloorFun)
		attributeSatisfy, attributeUp = PetConfigData.attributeSatisfyHP, PetConfigData.attributeUpHP
	elseif propName == "species_ep_regen_force_v" then
		rawTotal = FormulaData[3008].formula(speciesPoint, individualPoint, objLevel, mathFloorFun)
		attributeSatisfy, attributeUp = PetConfigData.attributeSatisfy, PetConfigData.attributeUp
	elseif propName == "species_atk_v" or propName == "species_atk_mag_v" then
		rawTotal = FormulaData[3004].formula(speciesPoint, individualPoint, objLevel, mathFloorFun)
		attributeSatisfy, attributeUp = PetConfigData.attributeSatisfy, PetConfigData.attributeUp
	elseif propName == "species_bp_atk_v" then
		rawTotal = FormulaData[3018].formula(speciesPoint, individualPoint, objLevel, mathFloorFun)
		attributeSatisfy, attributeUp = PetConfigData.attributeSatisfy, PetConfigData.attributeUp
	elseif propName == "species_def_v" or propName == "species_def_mag_v" then
		rawTotal = FormulaData[3007].formula(speciesPoint, individualPoint, objLevel, mathFloorFun)
		attributeSatisfy, attributeUp = PetConfigData.attributeSatisfy, PetConfigData.attributeUp
	else
		assert(false, "not support propName" .. propName)
	end

	if params.ratingPropUpTable then
		rawTotal = rawTotal + (params.ratingPropUpTable[idx] or 0)
	end

	if params.allPropMaxUpTable then
		rawTotal = rawTotal + (params.allPropMaxUpTable[idx] or 0)
	end

	if params.needExtraUp and attributeUp and attributeSatisfy and attributeSatisfy > 0 then
		totalByUp = FormulaData[3005].formula(rawTotal, attributeSatisfy, attributeUp, math_floor)
	end

	return rawTotal + totalByUp, totalByUp
end

function Utils.genBasePropertyDisplayDict(basePropertyList, attrValMap, inPlace)
	local dict = inPlace and basePropertyList or {}

	for index, prop in pairs(basePropertyList) do
		local attrName = Utils.getPropDisplayAttrName(index)
		local attrId = AttributeConst[attrName]

		if not inPlace then
			dict[index] = Utils.deepCopyTable(prop)
		end

		dict[index].displayValue = math_floor(attrValMap[attrId] or 0)
	end

	return dict
end

function Utils.primaryPropertyUpdate(petInfo, priProIndex, points, stage, level)
	local attriMap = {}

	Utils.calcTalentAttr(petInfo, attriMap)
	Utils.calcPersonlityAndSpecialAnRaceAtt(petInfo, attriMap)

	local primaryProperty = petInfo and petInfo.primaryProperty or {}

	Utils.calcPriamryProperty(petInfo, attriMap, priProIndex, points)
	Utils.updateResonance(petInfo, attriMap, stage, level)
	Utils.coreItemAttr(petInfo, attriMap)

	for i, _ in pairs(primaryProperty.propertyStrengPoint or EMPTY_TABLE) do
		local propertyName = PriProRevertData[i]

		if attriMap[propertyName] ~= nil then
			local convertAttrMap = Utils.calcPetIndividualConvertAttrMap(i, attriMap[propertyName])

			for attrName, convertValue in pairs(convertAttrMap) do
				attriMap[attrName] = (attriMap[attrName] or 0) + convertValue
			end
		end
	end

	return attriMap
end

function Utils.calcTalentAttr(petInfo, attriMap)
	local talentList = petInfo and petInfo.talentList or {}

	for i, talentInfo in ipairs(talentList) do
		local petTalentData = PetTalentData[talentInfo.templateId]

		for j, value in pairs(talentInfo.propValues) do
			local propId = petTalentData.props[j]

			Utils.getProperRefAttrName({
				[propId[1]] = value
			}, attriMap)
		end
	end
end

function Utils.calcPersonlityAndSpecialAnRaceAtt(petInfo, attriMap)
	local basePropertyList = petInfo and petInfo.basePropertyList or {}

	for i, data in ipairs(basePropertyList) do
		local attrName = Utils.getPropFinalAttrName(i)

		if attrName ~= nil then
			attriMap[attrName] = attriMap[attrName] or 0

			local total = basePropertyList.getTotal and basePropertyList:getTotal(i) or data.total

			attriMap[attrName] = attriMap[attrName] + total
		end
	end
end

function Utils.calcPriamryProperty(petInfo, attriMap, priProIndex, points)
	local primaryProperty = petInfo and petInfo.primaryProperty or {}

	for i, value in pairs(primaryProperty.propertyStrengPoint or EMPTY_TABLE) do
		local propertyName = PriProRevertData[i]

		attriMap[propertyName] = attriMap[propertyName] or 0
		attriMap[propertyName] = attriMap[propertyName] + value

		if priProIndex == i then
			attriMap[propertyName] = attriMap[propertyName] + (points or 0)
		end
	end
end

function Utils.coreItemAttr(petInfo, attriMap)
	local item = petInfo:getCoreCarryItem()

	if item ~= nil and CoreCarryData[item.id] ~= nil then
		local carryData = CoreCarryData[item.id]

		if carryData ~= nil then
			Utils.getProperRefAttrName(carryData.prop, attriMap)

			return item.id
		end
	end
end

function Utils.updateResonance(petInfo, attriMap, stage, level)
	local resonanceStage = stage or petInfo.resonanceInfo.resonanceStage
	local resonanceLevel = level or petInfo.resonanceInfo.resonanceLevel
	local resonanceMap = {}

	for i = 1, resonanceStage do
		local data = ResonanceData[i]

		if data ~= nil then
			for j = 0, lume.tableLength(data) do
				if data[j] ~= nil then
					if i == resonanceStage and resonanceLevel < j then
						break
					end

					local props = data[j].props

					for _, prop in pairs(props or EMPTY_TABLE) do
						resonanceMap[prop[1]] = (resonanceMap[prop[1]] or 0) + (prop[2] or 0)
					end
				end
			end
		end
	end

	Utils.getProperRefAttrName(resonanceMap, attriMap)

	return resonanceMap
end

function Utils.getProperRefAttrName(props, attriMap)
	for id, value in pairs(props or EMPTY_TABLE) do
		local attribute = AttributeGroupData[id]

		if attribute ~= nil then
			for _, attr in pairs(attribute.attrs or EMPTY_TABLE) do
				attriMap[attr] = attriMap[attr] or 0
				attriMap[attr] = attriMap[attr] + value
			end
		end
	end
end

function Utils.calcPetIndividualConvertAttrMap(propIndex, level)
	local attrMap = {}
	local primaryAttrName = PriProRevertData[propIndex]
	local convertData = primaryAttrName and PetAttrConvertData[primaryAttrName]

	if convertData == nil then
		return attrMap
	end

	level = level or 0

	for _, prop in ipairs(convertData.addprops or EMPTY_TABLE) do
		local divisor = prop[1] or 0
		local targetAttrName = prop[2]
		local valuePerLevel = prop[3] or 0

		if divisor > 0 and targetAttrName ~= nil then
			local value = math_floor(level / divisor) * valuePerLevel

			attrMap[targetAttrName] = (attrMap[targetAttrName] or 0) + value
		end
	end

	return attrMap
end

function Utils.getPrimaryPropertySrc(petInfo)
	local attriMap = {}

	attriMap.talent = {}
	attriMap.coreItem = {}
	attriMap.streng = {}

	local tmpMap = {}

	Utils.calcTalentAttr(petInfo, tmpMap)

	for i, _ in pairs(PetAttrConvertData) do
		if tmpMap[i] then
			attriMap.talent[i] = tmpMap[i]
		end
	end

	tmpMap = {}

	Utils.calcPriamryProperty(petInfo, tmpMap)

	for i, _ in pairs(PetAttrConvertData) do
		if tmpMap[i] then
			attriMap.streng[i] = tmpMap[i]
		end
	end

	tmpMap = {}

	Utils.coreItemAttr(petInfo, tmpMap)

	for i, _ in pairs(PetAttrConvertData) do
		if tmpMap[i] then
			attriMap.coreItem[i] = tmpMap[i]
		end
	end

	return attriMap
end

function Utils.genPreviewPetInfo(templateId, level, label, botTemplateId)
	if pg.component ~= "game" then
		return nil
	end

	local ServerUtils = require("GameServer.ServerUtils")
	local PetInfo = require("CustomTypes.PetInfo")

	templateId = templateId or 0

	local petData = PetData[templateId]

	if not petData then
		return nil
	end

	level = level or 1
	label = label or 0

	local petPrototypeId = Utils.getPetPetPrototypeId(templateId)
	local bornScale = ServerUtils.getBornScale(petData, label, Const.PET_BODY_SIZE_TYPE.NORMAL)

	if Utils.isLabelElite(label) or Utils.isLabelBoss(label) then
		local petPrototypeData = PetPrototypeData[petPrototypeId]

		bornScale = petPrototypeData and petPrototypeData.capturedBossModelScale or bornScale
	end

	local height = ServerUtils.getHeight(petData, bornScale)
	local shinyStyle = Utils.isLabelShiny(label) and Utils.getRandomShinyStyle() or 0
	local previewPetInfo = PetInfo({
		propertyEnhancedCount = 0,
		propertyCountByEvent = 0,
		customName = "",
		countId = 0,
		id = IDManager.genB64ID(),
		templateId = templateId,
		time = Time.getMillisecondUTC(),
		level = level,
		gender = ServerUtils.getPuppetGender(petData),
		label = label,
		shinyStyle = shinyStyle,
		nature = ServerUtils.getPuppetNature(petData),
		stage = petData.stage or 1,
		bornScale = bornScale,
		height = height,
		weight = ServerUtils.getWeight(petData, height),
		individuationIds = ServerUtils.getPuppetIndividuation(petPrototypeId),
		exploreAbilityList = petData.exploreAbilityList or {},
		elementTypes = petData.elementType or {},
		botTemplateId = botTemplateId or 0
	})

	for _, property in pairs(previewPetInfo) do
		if type(property) == "table" and property.rawset then
			property:rawset("_parent", previewPetInfo)
		end
	end

	previewPetInfo:petInfoFirstCreate()

	previewPetInfo.levelOnCreate = previewPetInfo.level

	local nextLevelData = PetLevelData[previewPetInfo.level + 1]

	if nextLevelData and nextLevelData.breakthroughItemNums then
		previewPetInfo.needBreakthrough = true
	end

	return previewPetInfo:getRawTable()
end

function Utils.genBasePropertyPreview(petInfo, previewType, previewParams, callback)
	local basePropertyList = petInfo.basePropertyList
	local dict = basePropertyList.getRawTableWithDerived and basePropertyList:getRawTableWithDerived() or basePropertyList.getRawTable and basePropertyList:getRawTable() or basePropertyList
	local previewReplaceInfo = {}
	local previewBasePropertyParams

	if previewType == Const.PROP_PREVIEW_MAX_LEVEL then
		local petMaxLevel = PetConfigData.propPreviewLevel or #PetLevelData
		local params = Utils.genRefreshTotalParamsByPetInfo(petMaxLevel, petInfo.propertyScoreStage, true)

		previewBasePropertyParams = {
			isFullLearned = true,
			level = petMaxLevel,
			propertyScoreStage = petInfo.propertyScoreStage
		}

		for idx = 1, Const.BASE_PROPERTY_CNT do
			local maxLevel = Utils.getTotalIndividualLevelMax(idx)
			local offsetLevel = maxLevel - dict[idx].indLv

			dict[idx].indLv = maxLevel
			dict[idx].iLvLn = dict[idx].iLvLn + offsetLevel
			dict[idx].total, dict[idx].totalByUp = Utils.PropertyRefreshTotal(idx, dict[idx], params)
		end
	elseif previewType == Const.PROP_PREVIEW_EXCHANGE then
		local individualLevelUpMap = previewParams[1]

		for idx, count in pairs(individualLevelUpMap) do
			dict[idx].indLv = dict[idx].indLv - count
		end

		local newPropertyScoreStage = Utils.getBaseIndividualInitStageNew(dict, petInfo.templateId, petInfo.propertyScoreStage)
		local params = Utils.genRefreshTotalParamsByPetInfo(petInfo.level, newPropertyScoreStage, false)

		previewBasePropertyParams = {
			isFullLearned = false,
			level = petInfo.level,
			propertyScoreStage = newPropertyScoreStage
		}

		for idx = 1, Const.BASE_PROPERTY_CNT do
			dict[idx].total, dict[idx].totalByUp = Utils.PropertyRefreshTotal(idx, dict[idx], params)
		end
	elseif previewType == Const.PROP_PREVIEW_EXCHANGE_SEND then
		Utils.cleanExchangeBaseProperty(dict)

		local newPropertyScoreStage = Utils.getBaseIndividualInitStageNew(dict, petInfo.templateId, 0)
		local params = Utils.genRefreshTotalParamsByPetInfo(petInfo.level, newPropertyScoreStage, false)

		previewBasePropertyParams = {
			isFullLearned = false,
			level = petInfo.level,
			propertyScoreStage = newPropertyScoreStage
		}

		for idx = 1, Const.BASE_PROPERTY_CNT do
			dict[idx].total, dict[idx].totalByUp = Utils.PropertyRefreshTotal(idx, dict[idx], params)
		end

		previewReplaceInfo.skipResonance = true
	end

	previewBasePropertyParams = previewBasePropertyParams or {
		level = petInfo.level,
		propertyScoreStage = petInfo.propertyScoreStage,
		isFullLearned = Utils.isIndividualFullLearned(dict)
	}
	previewReplaceInfo.previewBasePropertyList = dict
	previewReplaceInfo.previewBasePropertyParams = previewBasePropertyParams

	if pg.component == "game" then
		local attrs = petInfo:genPreviewAttributeValue(previewReplaceInfo)
		local displayDict = Utils.genBasePropertyDisplayDict(dict, attrs, true)

		if callback then
			callback(displayDict)
		end
	else
		pg.me:serverMsg("RPC_CS_GenPetPreviewAttributeValue", petInfo.id, previewReplaceInfo, function(attrs)
			local displayDict = Utils.genBasePropertyDisplayDict(dict, attrs, true)

			if callback then
				callback(displayDict)
			end
		end)
	end

	return dict
end

function Utils.getBindingItemId(bindingId)
	local iobd = bindingId and ItemObjectBindingData[bindingId]

	return iobd and iobd.itemId
end

function Utils.getBindingSceneObjectId(bindingId)
	local iobd = bindingId and ItemObjectBindingData[bindingId]

	return iobd and iobd.sceneObjectId
end

function Utils.getBindingCastObjectId(bindingId)
	local iobd = bindingId and ItemObjectBindingData[bindingId]

	return iobd and iobd.castObjectId
end

function Utils.itemId2CastItemId(itemId)
	local idd = ItemData[itemId]

	return idd and Utils.getBindingCastObjectId(idd.bindingId)
end

function Utils.isQuickCaptureItemIdValid(playerEnt, itemId)
	if playerEnt.getItemCountById and playerEnt:getItemCountById(itemId) <= 0 then
		return false
	end

	local castItemId = Utils.itemId2CastItemId(itemId)

	if castItemId == nil then
		return false
	end

	local cidd = CastItemData[castItemId]

	return cidd and cidd.canQuickCapture
end

function Utils.randomByExtractMode(extractMode, dataList, selectRatioFunc)
	local proportionList = Utils.getProportionList(extractMode, dataList, selectRatioFunc)
	local selectedIndex = lume.weightedchoice(proportionList)

	return dataList[selectedIndex]
end

function Utils.getProportionList(extractMode, dataList, selectRatioFunc)
	local proportionList = {}

	if extractMode == Const.EXTRACT_MODE_PROPORTION then
		for _, v in ipairs(dataList) do
			proportionList[#proportionList + 1] = selectRatioFunc(v)
		end
	elseif extractMode == Const.EXTRACT_MODE_PROPORTION_OVERFLOW then
		local weightSum = 0

		for _, v in ipairs(dataList) do
			local ratio = selectRatioFunc(v)

			weightSum = weightSum + ratio

			if weightSum > 1 then
				local newWeight = ratio - (weightSum - 1)

				newWeight = newWeight < 0 and 0 or newWeight
				proportionList[#proportionList + 1] = newWeight

				break
			else
				proportionList[#proportionList + 1] = ratio
			end
		end

		if weightSum < 1 then
			proportionList[#proportionList + 1] = 1 - weightSum
		end
	else
		logger:warn(string.format("unsupported extract mode %s", extractMode))
	end

	return proportionList
end

function Utils.hasAnyEntityTag(ent, tagList)
	if Utils.tableIsEmptyOrNil(tagList) then
		return false
	end

	for _, tag in ipairs(tagList) do
		if Utils.hasEntityTag(ent, tag) then
			return true
		end
	end

	return false
end

function Utils.hasEntityTag(ent, tag)
	if ent == nil or ent.entityTag == nil then
		return false
	end

	local tagIndex

	if type(tag) == "string" then
		local tagData = EntityTagData[tag]

		tagIndex = tagData and tagData.value
	else
		tagIndex = tag
	end

	if tagIndex == nil then
		return false
	end

	return Bitset.getBit(ent.entityTag, tagIndex)
end

function Utils.addEntityTag(ent, tag)
	if not ent or Utils.hasEntityTag(ent, tag) then
		return
	end

	local tagIndex, tagName

	if type(tag) == "string" then
		tagIndex = (EntityTagData[tag] or EMPTY_TABLE).value
		tagName = tag
	else
		tagIndex = tag
		tagName = EntityTagIndexData[tag]
	end

	if tagIndex == nil or tagName == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("addEntityTag tag not found", tagName, tagIndex)
		end

		return
	end

	if Utils.checkClient() then
		if ent.requestAddEntityTag then
			ent:requestAddEntityTag(tagIndex)
		end
	else
		Bitset.setBit(ent.entityTag, tagIndex)

		if ent.space then
			ent.space:emitSpaceEvent(ServerEventConst.ADD_ENTITY_TAG, {
				staticId = ent.staticId or 0,
				entityTag = tagName
			})
		end
	end
end

function Utils.removeEntityTag(ent, tag)
	if not ent or not Utils.hasEntityTag(ent, tag) then
		return
	end

	local tagIndex, tagName

	if type(tag) == "string" then
		tagIndex = (EntityTagData[tag] or EMPTY_TABLE).value
		tagName = tag
	else
		tagIndex = tag
		tagName = EntityTagIndexData[tag]
	end

	if tagIndex == nil or tagName == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("removeEntityTag tag not found", tagName, tagIndex, tag)
		end

		return
	end

	if Utils.checkClient() then
		if ent.requestRemoveEntityTag then
			ent:requestRemoveEntityTag(tagIndex)
		end
	else
		Bitset.clrBit(ent.entityTag, tagIndex)

		if ent.space and ent.space.emitSpaceEvent then
			ent.space:emitSpaceEvent(ServerEventConst.REMOVE_ENTITY_TAG, {
				staticId = ent.staticId or 0,
				entityTag = tagName
			})
		end
	end
end

function Utils.getEntityTags(ent)
	if not ent then
		return {}
	end

	local tags = {}

	for tag, data in pairs(EntityTagData) do
		if Bitset.getBit(ent.entityTag, data.value) then
			table.insert(tags, tag)
		end
	end

	return tags
end

function Utils.addEntityTagByIndex(ent, tagIndex)
	Utils.addEntityTag(ent, EntityTagIndexData[tagIndex])
end

function Utils.removeEntityTagByIndex(ent, tagIndex)
	Utils.removeEntityTag(ent, EntityTagIndexData[tagIndex])
end

function Utils.IsSameSpecies(targetEnt1, targetEnt2)
	if targetEnt1 == nil or targetEnt2 == nil then
		return false
	end

	if Utils.isEnvObj(targetEnt1) or Utils.isEnvObj(targetEnt2) then
		return targetEnt1.templateId == targetEnt2.templateId
	end

	return targetEnt1:getConfigData().petPrototypeId == targetEnt2:getConfigData().petPrototypeId
end

function Utils.IsSameEthnicGroup(targetEnt1, targetEnt2)
	if targetEnt1 == nil or targetEnt2 == nil then
		return false
	end

	if Utils.isEnvObj(targetEnt1) or Utils.isEnvObj(targetEnt2) then
		return targetEnt1.templateId == targetEnt2.templateId
	end

	return targetEnt1:getConfigData().ethnicGroup == targetEnt2:getConfigData().ethnicGroup
end

function Utils.IsPetSameEthnicGroupByTemplateId(templateId, templateId2)
	return PetData[templateId].ethnicGroup == PetData[templateId2].ethnicGroup
end

function Utils.isPetsCanCommunicate(petEnt1, petEnt2)
	if petEnt1 == nil or petEnt2 == nil then
		return false
	end

	local pet1EthnicGroup = petEnt1:getConfigData().ethnicGroup
	local pet2EthnicGroup = petEnt2:getConfigData().ethnicGroup

	if pet1EthnicGroup == nil or pet2EthnicGroup == nil then
		return false
	end

	if pet1EthnicGroup == pet2EthnicGroup then
		return true
	end

	if PetFamilyData[pet1EthnicGroup] and PetFamilyData[pet1EthnicGroup].canCommunicateEthnicGroup and PetFamilyData[pet1EthnicGroup].canCommunicateEthnicGroup[pet2EthnicGroup] then
		return true
	end

	if PetFamilyData[pet2EthnicGroup] and PetFamilyData[pet2EthnicGroup].canCommunicateEthnicGroup and PetFamilyData[pet2EthnicGroup].canCommunicateEthnicGroup[pet1EthnicGroup] then
		return true
	end

	return false
end

function Utils.isInputEventShowPet(inputEvent)
	return inputEvent == Const.EVENT_SHOW_PET or inputEvent == Const.EVENT_SHOW_PET_BY_SKILL or inputEvent == Const.EVENT_SHOW_PET_BY_EVENT or inputEvent == Const.EVENT_SHOW_PET_QTE or inputEvent == Const.EVENT_SHOW_PET_BY_PVP or inputEvent == Const.EVENT_SHOW_PET_BY_REVIVE
end

function Utils.isInputEventLeavePet(inputEvent)
	return inputEvent == Const.EVENT_LEAVE_PET or inputEvent == Const.EVENT_LEAVE_PET_BY_EVENT or inputEvent == Const.EVENT_LEAVE_PET_CLIENT_FORCE
end

function Utils.isInputEventEnterPet(inputEvent)
	return inputEvent == Const.EVENT_ENTER_PET or inputEvent == Const.EVENT_ENTER_PET_BY_EVENT or inputEvent == Const.EVENT_ENTER_PET_BY_PVP or inputEvent == Const.EVENT_ENTER_PET_BY_REVIVE
end

function Utils.getRegionReviveConfig(player)
	local sceneId = player.space and player.space.sceneId or 0
	local blackScreenId = SceneData[sceneId] and SceneData[sceneId].respawnBlackScreenId
	local autoRevive = SceneData[sceneId] and SceneData[sceneId].respawnByCheckpoint == Const.REVIVE_AUTO_ON or false
	local reviveInfo = {
		autoRevive = autoRevive,
		blackScreenId = blackScreenId
	}

	return reviveInfo
end

function Utils.convertPointDataToTypeFilteredData(sceneMarkPointData)
	local result = {}

	for spawnerId, spawnerTable in pairs(sceneMarkPointData) do
		if not result[spawnerTable.markConfigId] then
			result[spawnerTable.markConfigId] = {}
		end

		result[spawnerTable.markConfigId][spawnerId] = Utils.deepCopyTable(spawnerTable)
	end

	return result
end

function Utils.getPosResetInfoByReason(player, reason)
	local sceneId = player.space and player.space.sceneId or 0
	local spaceId = player.space and player.space.id
	local sceneData = SceneData[sceneId]

	if sceneData then
		local sceneMarkData = Utils.convertPointDataToTypeFilteredData(SceneUtils.getSceneMarkPointData(sceneId, spaceId))
		local resetPosParam

		if reason == Const.LIFE_DEAD_BY_FALL_TO_GROUND then
			if sceneMarkData and sceneData.positionResetParam1 then
				resetPosParam = sceneMarkData[sceneData.positionResetParam1] and sceneMarkData[sceneData.positionResetParam1].markPosition
				resetPosParam = resetPosParam and Vector3(unpack(resetPosParam))
			end

			return {
				posType = sceneData.positionResetType1,
				posParam = resetPosParam,
				blackScreenId = sceneData.positionResetBlackScreenId1
			}
		elseif reason == Const.LIFE_DEAD_BY_CLIFF then
			if sceneMarkData and sceneData.positionResetParam2 then
				resetPosParam = sceneMarkData[sceneData.positionResetParam2] and sceneMarkData[sceneData.positionResetParam2].markPosition
				resetPosParam = resetPosParam and Vector3(unpack(resetPosParam))
			end

			return {
				posType = sceneData.positionResetType2,
				posParam = resetPosParam,
				blackScreenId = sceneData.positionResetBlackScreenId2
			}
		elseif reason == Const.LIFE_DEAD_BY_WATER then
			if sceneMarkData and sceneData.positionResetParam3 then
				resetPosParam = sceneMarkData[sceneData.positionResetParam3] and sceneMarkData[sceneData.positionResetParam3].markPosition
				resetPosParam = resetPosParam and Vector3(unpack(resetPosParam))
			end

			return {
				posType = sceneData.positionResetType3,
				posParam = resetPosParam,
				blackScreenId = sceneData.positionResetBlackScreenId3
			}
		elseif reason == Const.LIFE_DEAD_BY_ROLL_OVER then
			if sceneMarkData and sceneData.positionResetParam4 then
				resetPosParam = sceneMarkData[sceneData.positionResetParam4] and sceneMarkData[sceneData.positionResetParam4].markPosition
				resetPosParam = resetPosParam and Vector3(unpack(resetPosParam))
			end

			return {
				posType = sceneData.positionResetType4,
				posParam = resetPosParam,
				blackScreenId = sceneData.positionResetBlackScreenId4
			}
		end
	end

	return {}
end

function Utils.getPosByMarkData(pointData)
	if not pointData then
		logger:error("getPosByMarkData nil")

		return Vector3(0, 0, 0), 0
	end

	local destPos = Vector3(unpack(pointData.markPosition))

	return destPos, pointData.yaw
end

function Utils.getNearbyPortalInfo(playerEnt)
	local playerPos = playerEnt:getPosition()
	local nearPosition, nearYaw, nearMarkType
	local minDistance = -1
	local nearPointId = 0
	local blackScreenId
	local sceneId = playerEnt.sceneId
	local spaceId = playerEnt.space and playerEnt.space.id
	local HomeLandUtils = require("Common.Utils.HomeLandUtils")
	local homelandSpace = Utils.isHomelandBySceneId(sceneId) and playerEnt.space

	local function getNearPosition(pointData, pointId)
		if homelandSpace and not HomeLandUtils.canResetToPortal(homelandSpace, pointId) then
			return
		end

		local position, yaw = Utils.getPosByMarkData(pointData)
		local distance = Vector3.Distance(position, playerPos)

		if minDistance < 0 then
			minDistance = distance
			nearPosition, nearYaw, nearMarkType = position, yaw, pointData.markType
			nearPointId = pointId
			blackScreenId = pointData.blackScreenId
		elseif distance < minDistance then
			minDistance = distance
			nearPosition, nearYaw, nearMarkType = position, yaw, pointData.markType
			nearPointId = pointId
			blackScreenId = pointData.blackScreenId
		end
	end

	local scenePortalData = SceneUtils.getScenePortalData(sceneId, spaceId)

	for pointId, pointData in pairs(scenePortalData) do
		if pointData.revivedPointState then
			getNearPosition(pointData, pointId)
		elseif playerEnt.savePortals[pointId] then
			getNearPosition(pointData, pointId)
		elseif playerEnt:getSpaceOwnerMapMarkStatus(sceneId, pointData.markType, pointId) >= Const.MAP_MARK_STATUS_UNLOCKED then
			getNearPosition(pointData, pointId)
		end
	end

	if minDistance < 0 then
		local mainSceneId = SceneUtils.getMainSceneId(sceneId)

		scenePortalData = SceneUtils.getScenePortalData(mainSceneId, spaceId)

		for pointId, pointData in pairs(scenePortalData) do
			if pointData.revivedPointState then
				getNearPosition(pointData, pointId)
			elseif playerEnt.savePortals[pointId] then
				getNearPosition(pointData, pointId)
			elseif playerEnt:getSpaceOwnerMapMarkStatus(sceneId, pointData.markType, pointId) >= Const.MAP_MARK_STATUS_UNLOCKED then
				getNearPosition(pointData, pointId)
			end
		end
	end

	return nearPosition, nearYaw, nearMarkType, minDistance, nearPointId, blackScreenId
end

function Utils.calcFallToGroundDamage(height)
	return FormulaData[4001].formula(height, math_floor)
end

function Utils.getPetPetPrototypeId(templateId)
	local pdd = PetData[templateId]

	return pdd and pdd.petPrototypeId or 0
end

function Utils.getPuppetPetPrototypeId(templateId)
	local pdd = PuppetData[templateId]

	return pdd and pdd.petPrototypeId or 0
end

function Utils.getPetPrototypeData(ent)
	if not Utils.isPet(ent) and not Utils.isPuppet(ent) then
		return nil
	end

	local pdd = ent:getConfigData()
	local petPrototypeId = pdd and pdd.petPrototypeId or 0

	return PetPrototypeData[petPrototypeId]
end

function Utils.getPetFormIdByPrototypeId(petPrototypeId)
	if not petPrototypeId then
		return 0
	end

	local protoData = PetPrototypeData[petPrototypeId]

	return protoData and protoData.formId or 0
end

function Utils.getPetFormIdByTemplateId(templateId)
	return Utils.getPetFormIdByPrototypeId(Utils.getPetPetPrototypeId(templateId))
end

function Utils.getPetFormTypeDataByPrototypeId(petPrototypeId)
	local formId = Utils.getPetFormIdByPrototypeId(petPrototypeId)

	return formId ~= 0 and PetFormTypeData[formId] or nil
end

function Utils.getPetFormTypeDataByTemplateId(templateId)
	local formId = Utils.getPetFormIdByTemplateId(templateId)

	return formId ~= 0 and PetFormTypeData[formId] or nil
end

function Utils.getPetFormNameByPrototypeId(petPrototypeId)
	local Const = require("Common.Const.Const")
	local formId = Utils.getPetFormIdByPrototypeId(petPrototypeId)

	return Const.FormId2Name[formId] or ""
end

function Utils.getPetFormNameByTemplateId(templateId)
	local Const = require("Common.Const.Const")
	local formId = Utils.getPetFormIdByTemplateId(templateId)

	return Const.FormId2Name[formId] or ""
end

function Utils.getPetFormQualityByPrototypeId(petPrototypeId)
	local formTypeData = Utils.getPetFormTypeDataByPrototypeId(petPrototypeId)

	return formTypeData and formTypeData.formQuality
end

function Utils.getPetFormQualityByTemplateId(templateId)
	local formTypeData = Utils.getPetFormTypeDataByTemplateId(templateId)

	return formTypeData and formTypeData.formQuality
end

function Utils.getPuppetEthnicGroup(puppetTemplateId)
	local petPrototypeId = Utils.getPuppetPetPrototypeId(puppetTemplateId)

	if petPrototypeId == 0 then
		return 0
	end

	local protoData = PetPrototypeData[petPrototypeId]

	return protoData and protoData.ethnicGroup or 0
end

function Utils.getBornBuffList(ent)
	local space = ent.space

	if space and space.getBornBuffList then
		return space:getBornBuffList(ent)
	end

	local petPrototypeData = Utils.getPetPrototypeData(ent)

	return petPrototypeData and petPrototypeData.bornBuffList or {}
end

function Utils.getBasePropsValue(petInfo, points, stage, level)
	if petInfo == nil then
		return
	end

	local attriMap = {}

	Utils.calcTalentAttr(petInfo, attriMap)
	Utils.calcPersonlityAndSpecialAnRaceAtt(petInfo, attriMap)
	Utils.updateResonance(petInfo, attriMap, stage, level)

	return attriMap
end

function Utils.getCpValue(petInfoDict, level)
	local ret = 0
	local baseCp = 0
	local basePropertyList = petInfoDict.basePropertyList
	local configData = PetData[petInfoDict.templateId]

	if not configData then
		logger:error("Utils.getCpValue pet config not found", petInfoDict:repr())

		return 0
	end

	local player = petInfoDict and petInfoDict.getOwnerPlayer and petInfoDict:getOwnerPlayer() or nil
	local carryCp = 0

	if petInfoDict.getCoreCarryInfo then
		local ItemUtils = require("Common.Utils.ItemUtils")
		local coreCarryInfo = petInfoDict:getCoreCarryInfo()

		if player and coreCarryInfo then
			carryCp = carryCp + coreCarryInfo:getCpValue() or 0

			for _, itemPos in ipairs(coreCarryInfo.assistCarryPosList) do
				if itemPos:isValid() then
					local invId, itemGenId = itemPos:unpack()
					local item = ItemUtils.getItem(player, invId, itemGenId)
					local assistCarryInfo = ItemUtils.getPropertyWithType(item)

					if assistCarryInfo then
						carryCp = carryCp + assistCarryInfo:getCpValue() or 0
					end
				end
			end
		end
	end

	local potentialCp = 0
	local recommend = configData and configData.recommend_attr

	for idx, prop in pairs(basePropertyList) do
		local indLv = prop.indLv or 0
		local ppldd = PetPropLevelData[idx] and PetPropLevelData[idx][indLv]
		local rate = 1

		if recommend ~= nil then
			for _, v in pairs(recommend) do
				if v == idx and ppldd and ppldd.cpRate then
					rate = ppldd.cpRate

					break
				end
			end
		end

		local addVal = ppldd and ppldd.cpValue and ppldd.cpValue * rate or 0

		potentialCp = potentialCp + addVal
	end

	local resonanceCp = 0
	local resonanceInfo = petInfoDict.resonanceInfo
	local resonanceStage = resonanceInfo and resonanceInfo.resonanceStage or 0
	local resonanceLevel = resonanceInfo and resonanceInfo.resonanceLevel or 0

	if resonanceStage > 0 then
		local resonanceData = ResonanceData[resonanceStage] and ResonanceData[resonanceStage][resonanceLevel]

		if resonanceData and resonanceData.cpValue then
			resonanceCp = resonanceCp + resonanceData.cpValue
		end
	end

	local totalParams

	if level then
		totalParams = {
			objLevel = level
		}

		for idx, prop in pairs(basePropertyList) do
			local speciesPoint = basePropertyList.getSpeciesPoint and basePropertyList:getSpeciesPoint(idx) or prop.speciesPoint

			prop.total, prop.totalByUp = Utils.PropertyRefreshTotal(idx, prop, totalParams, speciesPoint)
		end
	end

	local basePetPrototypeId = Utils.getBasePetPrototypeId(petInfoDict.petPrototypeId)
	local psdd = PetSkillData[basePetPrototypeId] or {}
	local hasEnhanceSkill = 0

	for _, sdd in pairs(psdd) do
		if sdd.enhancedSkillId and sdd.enhancedSkillId ~= 0 and petInfoDict.unlockedAbilityMap and petInfoDict.unlockedAbilityMap[sdd.enhancedSkillId] then
			hasEnhanceSkill = 1

			break
		end
	end

	local collectedFormCount = 1
	local rainbowFormCount = 0

	if player and player.petHandbookMap then
		collectedFormCount = player.petHandbookMap:getFormCatchedCount(nil, petInfoDict.petPrototypeId, false)
		rainbowFormCount = player.petHandbookMap:getRainbowFormCatchedCount(nil, petInfoDict.petPrototypeId, false)
	end

	local formulaId = PetConfigData.cpFormulaId
	local propTotalValues = {}

	if formulaId ~= nil then
		local hp = configData.species_hp_max_v
		local atk = configData.species_atk_v
		local def = configData.species_def_v
		local def_mag = configData.species_def_mag_v
		local ep_regen = configData.species_ep_regen_force_v
		local bp_atk = configData.species_bp_atk_v

		propTotalValues = {
			hp,
			atk,
			def,
			def_mag,
			ep_regen,
			bp_atk,
			carryCp,
			potentialCp,
			resonanceCp,
			rainbowFormCount
		}
		baseCp = Utils.formulaSafeCall(0, formulaId, petInfoDict.level, hasEnhanceSkill, collectedFormCount, unpack(propTotalValues))
	else
		local attriMap = Utils.getBasePropsValue(petInfoDict)
		local basePropsList = {}

		if not attriMap then
			basePropsList = basePropertyList
		else
			for idx, prop in pairs(basePropertyList) do
				local attriName_v = Utils.getPropFinalAttrName(idx)
				local attriName_p = Const.basePropsRate[idx]

				basePropsList[idx] = {}
				basePropsList[idx].total = (attriMap[attriName_v] or 0) * (1 + (attriMap[attriName_p] or 0))
			end
		end

		for propIndex, baseProp in pairs(basePropsList) do
			local addVal = basePropsList == basePropertyList and basePropertyList.getTotal and basePropertyList:getTotal(propIndex, totalParams) or baseProp.total

			if propIndex == Const.BASE_PROPERTY_HP_IDX then
				addVal = math_floor(addVal / Const.CP_VALUE_HP_DIVISOR)
			end

			baseCp = baseCp + addVal
		end

		baseCp = baseCp + carryCp + potentialCp + resonanceCp

		logger:debug("PetInfo:getCpValue no formula, use default method", petInfoDict:repr())
	end

	ret = baseCp

	return math.floor(ret)
end

function Utils.checkBlackScreen(reason)
	if not reason then
		return false
	end

	return bit.band(reason, Const.LIFE_DEAD_BLACK_SCREEN_TYPE) ~= 0
end

function Utils.checkTriggerActorType(entity, targetType, petInControl)
	if Utils.isActorType(entity, ACTOR_TYPE_PET) and petInControl then
		if Utils.isPlayerPet(entity) then
			local player = entity:getMasterEntity()

			if player and player:isControllingPet() then
				return true
			else
				return false
			end
		else
			return false
		end
	end

	return Utils.isActorType(entity, targetType)
end

function Utils.fromSpawner(ent)
	return ent and ent.spawnType
end

function Utils.fromSandbox(ent)
	return ent and ent.sandboxType and ent.sandboxType ~= SANDBOX_TYPE.SIMPLE and ent.sandboxType ~= SANDBOX_TYPE.ARK
end

function Utils.fromHomeland(ent)
	return ent and ent.ornamentId and ent.ornamentId ~= 0
end

function Utils.isSandboxAutoLoad(sandboxType)
	return sandboxType and sandboxType ~= SANDBOX_TYPE.SIMPLE and sandboxType ~= SANDBOX_TYPE.ARK
end

function Utils.isSandboxChunkLoad(sandboxConf)
	return sandboxConf.sandboxType == SANDBOX_TYPE.NORMAL and sandboxConf.sightLevel <= SIGHT_LEVEL.NEAR
end

function Utils.isSandboxDungeonLoad(sandboxType)
	return sandboxType == SANDBOX_TYPE.DUNGEON
end

function Utils.isSandboxManualLoad(sandboxType)
	return sandboxType == SANDBOX_TYPE.MANUAL
end

function Utils.openChestLimit(player, chest)
	if not player.interactRecord then
		return false
	end

	local configData = chest:getConfigData()
	local limitCount = configData.interactCount or 1

	if not chest.staticId or chest.staticId == 0 then
		return false
	end

	local openCount = player.interactRecord[chest.staticId] or 0

	if limitCount == -1 or openCount < limitCount then
		return false
	end

	return true
end

local RewardLimitTypeTextIdMap = {
	[Const.LIMIT_DAY] = 1946886156,
	[Const.LIMIT_WEEK] = 1969589599,
	[Const.LIMIT_MONTH] = 1443124541
}

function Utils.getRewardLimitTypeTextId(limitType)
	return RewardLimitTypeTextIdMap[limitType]
end

function Utils.convertRewardLimitPrecheckError(rewardId, checkRet)
	if checkRet ~= NoticeDef.ERROR_LIMIT_EXCEED then
		return checkRet
	end

	local rewardData = DropData[rewardId]
	local limitData = rewardData and rewardData.limitId and LimitData[rewardData.limitId]
	local limitTypeTextId = limitData and Utils.getRewardLimitTypeTextId(limitData.type)

	if not limitTypeTextId then
		return NoticeDef.ERROR_CONFIG_NIL
	end

	return NoticeDef.ITEM_REWARD_LIMITED, {
		limitTypeTextId
	}
end

function Utils.isRewardLimited(useLimitMap, rewardId)
	if not useLimitMap or not rewardId then
		return false
	end

	local rewardData = DropData[rewardId]

	if not rewardData then
		return false, nil, NoticeDef.ERROR_CONFIG_NIL
	end

	local limitId = rewardData and rewardData.limitId

	if not limitId then
		return false
	end

	local limitConfig = LimitData[limitId]

	if not limitConfig then
		return false, nil, NoticeDef.ERROR_CONFIG_NIL
	end

	local canUse, errorCode = useLimitMap:testLimit(limitId, 1)

	if canUse then
		return false, limitConfig.type
	end

	if errorCode == NoticeDef.ERROR_LIMIT_EXCEED then
		return true, limitConfig.type
	end

	return false, limitConfig.type, errorCode
end

function Utils.openCollectItemLimit(player, collectItem)
	local configData = collectItem:getConfigData()
	local limitCount = configData.interactCount or -1

	if not collectItem.staticId or collectItem.staticId == 0 then
		return false
	end

	local openCount = player.interactRecord[collectItem.staticId] or 0

	if limitCount == -1 or openCount < limitCount then
		return false
	end

	return true
end

function Utils.isAttributeChangeEntity(entity)
	if Utils.isPlayer(entity) or Utils.isPuppet(entity) or Utils.isPet(entity) then
		return true
	end

	return false
end

function Utils.getValidSkillAbilityParamIds(petTemplateId)
	local result = {}
	local petPrototypeId = Utils.getPetPetPrototypeId(petTemplateId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local skillTable = PetSkillData[basePetPrototypeId]

	for abilityParamId, stdd in pairs(skillTable or EMPTY_TABLE) do
		if stdd.abilityType == "skill" then
			result[#result + 1] = abilityParamId
		end
	end

	return result
end

function Utils.hasEnhancedSkillConfig(petTemplateId)
	local petPrototypeId = Utils.getPetPetPrototypeId(petTemplateId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local skillTable = PetSkillData[basePetPrototypeId]

	for _, skillData in pairs(skillTable or EMPTY_TABLE) do
		if skillData.enhancedSkillId then
			return true
		end
	end

	return false
end

function Utils.getGuidancePlayerFilePath(fileName)
	local configPath = package.searchpath("Data.guidance_player_template_data", package.path)

	return configPath and configPath:gsub("guidance_player_template_data.lua$", "GuidancePlayer/" .. fileName)
end

function Utils.getPlayerDocInherit(playerEntOrDoc, copyType)
	return {
		copyType = copyType,
		_id = playerEntOrDoc.id or playerEntOrDoc._id,
		uid = playerEntOrDoc.uid,
		username = playerEntOrDoc.username,
		createdTime = playerEntOrDoc.createdTime
	}
end

local QUEST_DOC_FIELD_MIGRATION = {
	acceptedQuests = "acceptedQuestMap",
	pendingQuests = "pendingQuestMap",
	initialQuests = "initialQuestMap"
}

function Utils.migrateQuestDocFields(doc)
	if type(doc) ~= "table" then
		return
	end

	for oldName, newName in pairs(QUEST_DOC_FIELD_MIGRATION) do
		local old = doc[oldName]

		if type(old) == "table" and doc[newName] == nil then
			local flat = {
				_ = ""
			}

			for questType, inner in pairs(old) do
				if questType ~= "_" and type(inner) == "table" then
					for questId, leaf in pairs(inner) do
						if questId ~= "_" then
							flat[questId] = leaf
						end
					end
				end
			end

			doc[newName] = flat
			doc[oldName] = nil
		end
	end
end

function Utils.modifyPlayerDocCopy(doc, docInherit)
	Utils.migrateQuestDocFields(doc)

	local pet_replace_dict = {}

	for petid, pet_info in pairs(doc.pets) do
		if petid ~= "_" then
			pet_replace_dict[petid] = IDManager.genB64ID()
		end
	end

	for petid, _ in pairs(pet_replace_dict) do
		local pet_info = doc.pets[petid]

		doc.pets[petid] = nil
		pet_info.id = pet_replace_dict[petid]
		doc.pets[pet_replace_dict[petid]] = pet_info
	end

	for _, formation_info in ipairs(doc.prepareFormationList) do
		for i = 1, #formation_info.formation do
			local key = formation_info.formation[i]

			if pet_replace_dict[key] then
				formation_info.formation[i] = pet_replace_dict[key]
			end
		end

		for i = 1, #formation_info.exploreFormation do
			local key = formation_info.exploreFormation[i]

			if pet_replace_dict[key] then
				formation_info.exploreFormation[i] = pet_replace_dict[key]
			end
		end
	end

	for boxindex, pet_box in pairs(doc.petBoxMap) do
		if tonumber(boxindex) then
			for key, value in pairs(pet_box) do
				if pet_replace_dict[value] then
					pet_box[key] = pet_replace_dict[value]
				end
			end
		end
	end

	doc.copySrc = doc.username
	doc.copySrcUid = doc.uid

	for k, v in pairs(docInherit or EMPTY_TABLE) do
		doc[k] = v
	end

	return doc, pet_replace_dict
end

function Utils.replaceHomeDocPetIds(doc, petReplaceDict, newId)
	local function replaceInTable(t)
		local renameKeys = {}

		for k, v in pairs(t) do
			if type(v) == "table" then
				replaceInTable(v)
			elseif petReplaceDict[v] then
				t[k] = petReplaceDict[v]
			end

			if petReplaceDict[k] then
				renameKeys[k] = petReplaceDict[k]
			end
		end

		for oldKey, newKey in pairs(renameKeys) do
			t[newKey] = t[oldKey]
			t[oldKey] = nil
		end
	end

	replaceInTable(doc)

	doc._id = newId
	doc.dbversion = nil
	doc.dbterm = nil

	return doc
end

function Utils.gmModifyDesignData(tablePath, tableKey, tableVal)
	if not tablePath or not tableKey or not tableVal then
		return false, "gmModifyDesignData failed, Please check the parameters"
	end

	local keys = string.split(tableKey, "-")
	local error

	if not keys or #keys < 1 then
		return false, "gmModifyDesignData failed, The number of tableKey is less than 1"
	end

	local status, table = pcall(require, tablePath)

	if not status then
		return false, "gmModifyDesignData failed, table is nil, tablePath = " .. tablePath, true
	end

	for i = 1, #keys - 1 do
		local key = keys[i]:match("^%s*(.-)%s*$")

		if key:match("^%-?%d+$") or key:match("^%-?%d+%.%d+$") then
			key = tonumber(key)
		end

		if not table[key] then
			return false, "gmModifyDesignData failed, Table modify failed, tableKey not exist, key = " .. tostring(key)
		end

		table = table[key]
	end

	local lastKey = keys[#keys]:match("^%s*(.-)%s*$")

	if lastKey:match("^%-?%d+$") or lastKey:match("^%-?%d+%.%d+$") then
		lastKey = tonumber(lastKey)
	end

	if not table[lastKey] then
		return false, "gmModifyDesignData failed, Table modify failed, tableKey not exist, key = " .. tostring(lastKey)
	end

	pg.isReloading = true
	tableVal = tableVal:match("^%s*(.-)%s*$")

	if string.startsWith(tableVal, "{") then
		tableVal = string.toTable(tableVal)
	elseif string.startsWith(tableVal, "function") then
		tableVal = "return " .. tableVal
		tableVal, error = load(tableVal)

		if error ~= nil then
			return false, "gmModifyDesignData failed, Table modify failed, errorInfo = " .. error
		end
	elseif tableVal:match("^%-?%d+$") or tableVal:match("^%-?%d+%.%d+$") then
		tableVal = tonumber(tableVal)
	elseif tableVal == "true" or tableVal == "false" then
		tableVal = tableVal == "true" or false
	elseif tableVal == "nil" then
		tableVal = nil
	end

	table[lastKey] = tableVal
	pg.isReloading = nil

	local mapMarkStatusMap = package.loaded["CustomTypes.MapMarkStatusMap"]
	local clearAllStatusCache = type(mapMarkStatusMap) == "table" and mapMarkStatusMap.clearAllStatusCache

	if type(clearAllStatusCache) == "function" then
		clearAllStatusCache()
	end

	return true, "gmModifyDesignData success."
end

function Utils.getBelongedMapBlockIds(sceneId, position)
	local res = {}

	for blockId, mbpdd in pairs(MapBlockPosData) do
		if Utils.checkInBlock(position, sceneId, mbpdd) then
			res[#res + 1] = blockId
		end
	end

	return res
end

function Utils.getCurLargeAreaBlockId(entity)
	local position = entity:getPosition()
	local sceneId = entity.space and entity.space.sceneId or 0
	local formalBlockIds = SceneToFormalBlockIds[sceneId]

	if formalBlockIds then
		for _, blockId in ipairs(formalBlockIds) do
			local mbpdd = MapBlockPosData[blockId]

			if mbpdd and Utils.checkInBlock(position, sceneId, mbpdd) then
				return blockId
			end
		end

		return nil
	end

	for blockId, mbpdd in pairs(MapBlockPosData) do
		local mbdd = MapBlockConfigData[blockId]

		if mbdd and mbdd.unlockReward1 ~= nil and Utils.checkInBlock(position, sceneId, mbpdd) then
			return blockId
		end
	end

	return nil
end

function Utils.getCurMapBlockId(entity)
	if pg.component == "client" then
		if Utils.isMainPlayer(entity) then
			return entity.curBlockId or 0
		elseif Utils.isPawnFollowPet(entity) then
			return entity:getMasterEntity().curBlockId or 0
		elseif Utils.isPuppet(entity) then
			local blockId = entity.curBlockId or SceneUtils.getBlockIdByEntity(entity)

			entity.curBlockId = blockId

			return blockId
		end
	elseif pg.component == "game" then
		if Utils.isPlayer(entity) then
			return entity.curBlockId
		else
			local blockId = entity.curBlockId or SceneUtils.getBlockIdByEntity(entity)

			entity.curBlockId = blockId

			return blockId
		end
	end

	return 0
end

function Utils.getCurWeatherInfo(entity)
	local space = entity.space

	if space == nil then
		return nil
	end

	local blockId = Utils.getCurMapBlockId(entity)

	return space.spaceWeatherInfoMap and space.spaceWeatherInfoMap[blockId]
end

function Utils.getCurWeatherId(entity)
	local weatherInfo = Utils.getCurWeatherInfo(entity)

	return weatherInfo and weatherInfo.weatherId or 0
end

function Utils.getCurMeteorologyId(entity)
	local space = entity.space

	if space == nil then
		return 0
	end

	local blockId = Utils.getCurMapBlockId(entity)
	local meteorologyInfo = space.meteorologyInfoMap and space.meteorologyInfoMap[blockId]

	if meteorologyInfo and meteorologyInfo.endTime >= Time.secondCache then
		return meteorologyInfo.meteorologyId or 0
	end

	return 0
end

function Utils.getCurTimePeriod(entity)
	return entity.space and entity.space.timePeriod or 0
end

function Utils.checkInBlock(position, sceneId, mbpdd)
	local x = position[1] or position[1] or 0
	local z = position[3] or position[3] or 0

	return sceneId == mbpdd.sceneId and x >= mbpdd.minX and x <= mbpdd.maxX and z >= mbpdd.minZ and z <= mbpdd.maxZ and Utils.isPointInPolygon(position, mbpdd.posList or {})
end

function Utils.isPointInPolygon(position, verts)
	local l = #verts

	if l < 3 then
		return false
	end

	local x = position[1] or 0
	local z = position[3] or 0
	local res = false
	local j = l

	for i = 1, l do
		local vert_i = verts[i]
		local vert_j = verts[j]

		if z < vert_i[3] ~= (z < vert_j[3]) and x < (z - vert_i[3]) * (vert_j[1] - vert_i[1]) / (vert_j[3] - vert_i[3]) + vert_i[1] then
			res = not res
		end

		j = i
	end

	return res
end

function Utils.isPointInBlock(posX, posY, blockId, sceneId)
	local sceneBlocks = require("Data.scene_block_info_server")
	local mainSceneId = SceneUtils.getMainSceneId(sceneId)
	local blocks = sceneBlocks[mainSceneId]

	if not blocks then
		return false
	end

	local points = blocks[blockId]

	if not points then
		return false
	end

	return Utils.isPointInPoly2(posX, posY, points)
end

function Utils.isPointInPoly2(mapPosX, mapPosY, points)
	local iCount = #points

	if iCount < 6 then
		return false
	end

	local inside = false
	local x1 = points[iCount - 1]
	local y1 = points[iCount]

	for i = 1, iCount, 2 do
		local x2 = points[i]
		local y2 = points[i + 1]

		if mapPosY < y1 ~= (mapPosY < y2) and mapPosX < (x2 - x1) * (mapPosY - y1) / (y2 - y1) + x1 then
			inside = not inside
		end

		x1, y1 = x2, y2
	end

	return inside
end

function Utils.dumpPolygon(position, verts)
	if #verts == 0 then
		return
	end

	local LINE_MAX_CHAR = 50
	local MARGIN = 5
	local pos_x = position[1] or 0
	local pos_z = position[3] or 0
	local x_min = pos_x
	local z_min = pos_z
	local x_max = pos_x
	local z_max = pos_z

	for _, v in ipairs(verts) do
		x_min = math.min(x_min, v[1])
		z_min = math.min(z_min, v[3])
		x_max = math.max(x_max, v[1])
		z_max = math.max(z_max, v[3])
	end

	local offset_x = -x_min
	local offset_z = -z_min
	local scale = LINE_MAX_CHAR / math.max(z_max - z_min, x_max - x_min)
	local new_verts = {}

	for _, v in ipairs(verts) do
		new_verts[#new_verts + 1] = {
			(v[1] + offset_x) * scale,
			(v[3] + offset_z) * scale
		}
	end

	local new_pos = {
		(pos_x + offset_x) * scale,
		(pos_z + offset_z) * scale
	}
	local buffer = {}

	for z = LINE_MAX_CHAR + MARGIN, -MARGIN, -1 do
		local line = ""

		for x = -MARGIN, LINE_MAX_CHAR + MARGIN do
			local hit_flag, verts_hit_flag, pos_hit_flag = false, false, false
			local idx = 0

			for i, v in ipairs(new_verts) do
				if math.floor(v[1]) == x and math.floor(v[2]) == z then
					hit_flag, verts_hit_flag, idx = true, true, i

					break
				end
			end

			if math.floor(new_pos[1]) == x and math.floor(new_pos[2]) == z then
				hit_flag, pos_hit_flag = true, true
			end

			if not hit_flag then
				line = line .. "  "
			elseif verts_hit_flag and pos_hit_flag then
				line = line .. "o" .. idx
			elseif verts_hit_flag then
				line = line .. "v" .. idx
			elseif pos_hit_flag then
				line = line .. "O"
			end
		end

		buffer[#buffer + 1] = line
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug(table.concat(buffer, "\n"))
	end
end

function Utils.getUpgradePuppetTemplateId(templateId)
	local index = lume.find(SysConfigData.initialPets, templateId)

	return SysConfigData.upgradedPets and SysConfigData.upgradedPets[index] or 0
end

function Utils.getPuppetEmergenceOverrideData()
	return SysConfigData.PET_GROUP_EMERGENCE_OVERRIDE_BEHAV
end

function Utils.getTwinPetTemplateId(chooseIndex)
	local puppetTemplateId = SysConfigData.initialPets[chooseIndex]
	local puppetData = PuppetData[puppetTemplateId]

	return puppetData and puppetData.spriteIdAfterCatch
end

function Utils.getTwinPuppetTemplateId(chooseIndex)
	local puppetTemplateId = SysConfigData.initialPets[chooseIndex]

	return puppetTemplateId
end

function Utils.isVirtualTwinPuppet(templateId)
	return PuppetData[templateId] and PuppetData[templateId].virtualDataId ~= nil
end

function Utils.getVirtualTwinPuppetTemplateId(templateId, playerChooseIndex)
	local virtualDataId = PuppetData[templateId].virtualDataId

	if virtualDataId == nil then
		return templateId
	end

	local playerNotChooseIndex = Const.TWIN_PET_CHOICE_MAP[playerChooseIndex]

	if playerNotChooseIndex == nil then
		return templateId
	end

	if virtualDataId == Const.VIRTUAL_PUPPET_PLAYER_CHOOSE then
		return Utils.getTwinPuppetTemplateId(playerChooseIndex)
	elseif virtualDataId == Const.VIRTUAL_PUPPET_PLAYER_NOT_CHOOSE then
		return Utils.getTwinPuppetTemplateId(playerNotChooseIndex)
	else
		logger:warn("invalid config virtualDataId=%d", virtualDataId)
	end
end

function Utils.isTwinPet(petPrototypeId)
	for _, templateId in ipairs(SysConfigData.initialPets) do
		if PuppetData[templateId] and PuppetData[templateId].petPrototypeId == petPrototypeId then
			return true
		end
	end

	return false
end

function Utils.isPlayerTwinPet(player, petPrototypeId)
	local templateId = SysConfigData.initialPets[player.twinPetChoiceIndex]

	if templateId and PuppetData[templateId] and PuppetData[templateId].petPrototypeId == petPrototypeId then
		return true
	end

	return false
end

function Utils.getPetPrototypeStage(petPrototypeId)
	local petPrototypeData = PetPrototypeData[petPrototypeId]

	return petPrototypeData and petPrototypeData.stage or 0
end

function Utils.getMinStagePetTemplateIdByEthnic(ethnicGroup)
	local minStage, petTemplateId = math.huge
	local pegdd = PetEthnicGroupData[ethnicGroup] and PetEthnicGroupData[ethnicGroup][1]

	if pegdd then
		for petPrototypeId, _ in pairs(pegdd) do
			local stage = Utils.getPetPrototypeStage(petPrototypeId)

			minStage = math.min(minStage, stage)
		end

		for petPrototypeId, _ in pairs(pegdd) do
			local stage = Utils.getPetPrototypeStage(petPrototypeId)

			if stage == minStage then
				local ppdd = PetPrototypeData[petPrototypeId]

				petTemplateId = ppdd and ppdd.defaultPet

				break
			end
		end
	end

	return petTemplateId
end

function Utils.genDispatchPetEggInfo(player, parentPetInfo)
	if not player or not parentPetInfo then
		return nil, "invalid_parent"
	end

	local parentPrototypeId = parentPetInfo.petPrototypeId

	if parentPrototypeId <= 0 then
		parentPrototypeId = Utils.getPetPetPrototypeId(parentPetInfo.templateId)
	end

	local parentPrototypeData = PetPrototypeData[parentPrototypeId]

	if not parentPrototypeData then
		return nil, "invalid_parent_prototype"
	end

	local cannotBreedList = PetBallConfigData.cannotBreedList or {}

	if lume.find(cannotBreedList, parentPrototypeId) then
		return nil, "cannot_breed"
	end

	local basePrototypeId = parentPrototypeData.baseFormPet

	if basePrototypeId <= 0 then
		return nil, "invalid_base_prototype"
	end

	local childPrototypeId

	if lume_random() < (parentPrototypeData.geneticProb or 0) then
		childPrototypeId = parentPrototypeId
	else
		local prototypeIds = PetBasePrototypeToPrototypeMap[basePrototypeId] or {}
		local randomWeights = {}
		local totalWeight = 0

		for _, prototypeId in ipairs(prototypeIds) do
			local prototypeData = PetPrototypeData[prototypeId] or {}
			local weight = prototypeData.breedRandomProb or 0

			if ToBool(prototypeData.isNeedOwn) and not player.petHandbookMap:isCatched(prototypeId, Const.GROUP_TYPE_SELF) then
				weight = 0
			end

			randomWeights[prototypeId] = weight
			totalWeight = totalWeight + weight
		end

		if totalWeight > 0 then
			childPrototypeId = Utils.randomByExtractMode(Const.EXTRACT_MODE_PROPORTION, prototypeIds, function(prototypeId)
				return randomWeights[prototypeId] or 0
			end)
		end
	end

	childPrototypeId = childPrototypeId or parentPrototypeId

	local childPrototypeData = PetPrototypeData[childPrototypeId]
	local childTemplateId = childPrototypeData and childPrototypeData.defaultPet

	if not childTemplateId or not PetData[childTemplateId] then
		return nil, "invalid_child_template"
	end

	local parentLabel = parentPetInfo.label or 0
	local childLabel = Const.PET_LABEL_MASK.NORMAL

	local function rollLabel(mask, geneticProb, randomProb)
		local inherited = bit.band(parentLabel, mask) ~= 0 and lume_random() < (geneticProb or 0)

		if inherited or lume_random() < (randomProb or 0) then
			childLabel = bit.bor(childLabel, mask)
		end
	end

	rollLabel(Const.PET_LABEL_MASK.SHINY, PetBallConfigData.shinyGeneticProb, PetBallConfigData.shinyBreedRandomProb)
	rollLabel(Const.PET_LABEL_MASK.ELITE, PetBallConfigData.eliteGeneticProb, PetBallConfigData.eliteBreedRandomProb)
	rollLabel(Const.PET_LABEL_MASK.RAINBOW, PetBallConfigData.miniGeneticProb, PetBallConfigData.miniBreedRandomProb)
	rollLabel(Const.PET_LABEL_MASK.VARIANT, PetBallConfigData.variantGeneticProb, PetBallConfigData.variantBreedRandomProb)

	local shinyStyle

	if Utils.isLabelShiny(childLabel) then
		local canInheritShinyStyle = Utils.isRainbowType(parentPrototypeId) and Utils.isLabelShiny(parentLabel) and Utils.isRainbowType(childPrototypeId) and ToInt(parentPetInfo.shinyStyle) > 0

		if canInheritShinyStyle and lume_random() < (PetBallConfigData.rainbowShinyGeneticProb or 0) then
			shinyStyle = parentPetInfo.shinyStyle
		else
			shinyStyle = Utils.randomPetShinyStyle(SysConfigData.rerollShinyStyleRandomGroup, childLabel, nil)
		end
	end

	local individualLevelList, propertyScoreStage
	local parentPropertyScoreStage = ToInt(parentPetInfo.propertyScoreStage)

	if parentPropertyScoreStage > 0 and lume_random() < (PetBallConfigData.qualityGeneticProb or 0) then
		local individualLevelInfo = {
			forcePropertyScoreStage = parentPropertyScoreStage
		}
		local BasePropertyList = require("CustomTypes.BasePropertyList")
		local ObjHelper = require("Common.ObjHelper")
		local basePropertyList = BasePropertyList.genInitDict(ObjHelper.TYPE_PET_INFO, PetData[childTemplateId], nil, {}, individualLevelInfo)

		individualLevelList = {}

		for index = 1, Const.BASE_PROPERTY_CNT do
			local propertyInfo = basePropertyList[index]

			individualLevelList[index] = propertyInfo and propertyInfo.indLv or 0
		end

		propertyScoreStage = individualLevelInfo.propertyScoreStage or Utils.getBaseIndividualInitStageNew(basePropertyList, childTemplateId, 0)
	end

	return {
		templateId = childTemplateId,
		label = childLabel,
		shinyStyle = shinyStyle,
		basePropertyindividualLevelList = individualLevelList,
		propertyScoreStage = propertyScoreStage
	}
end

function Utils.isBreedPetEgg(itemId)
	return itemId == PetBallConfigData.breedingEggItemId or itemId == PetBallConfigData.specialBreedingEggItemId or false
end

function Utils.isDispatchPetEgg(itemId)
	local dispatchEggItemId = PetBallConfigData.dispatchEggItemId

	return dispatchEggItemId and itemId == dispatchEggItemId or false
end

function Utils.getDispatchPetEggInfo(item)
	if not item then
		return nil
	end

	local eggInfo = item:getExtraProp()

	if eggInfo then
		return eggInfo
	end

	local props = item:getProps()
	local eggData = props and props.eggData
	local encodedEggInfo = eggData and eggData.dispatchEggInfo

	return encodedEggInfo and item.getCodec():safeDecodeFromStr(encodedEggInfo) or nil
end

function Utils.isSealedPetEgg(itemId)
	local petSaveEgg = SysConfigData.PETSAVE_EGG or {}

	return petSaveEgg[itemId] ~= nil
end

function Utils.isNormalPetEgg(itemId)
	local phedd = PetHatchEggData[itemId]

	return phedd ~= nil and not Utils.isBreedPetEgg(itemId)
end

function Utils.getHatchTime(itemId)
	local phedd = PetHatchEggData[itemId]

	if phedd == nil or phedd.times == nil then
		return 0
	end

	return math.floor(phedd.times * Const.SECONDS_ONE_MINUTE)
end

function Utils.getFixedInitHatchTime(player, itemId)
	if not player then
		return 0
	end

	local hatchTime = Utils.getHatchTime(itemId)
	local speedupTime = {}
	local speedUpTimeActivity = Utils.getActivitySpeedupHatchTime(player, itemId) or 0

	if speedUpTimeActivity > 0 then
		speedupTime[Const.HatchSpeedUpReason.activty_petHatch] = speedUpTimeActivity
		hatchTime = math.max(1, hatchTime - speedUpTimeActivity)
	end

	local speedUpTimeMonthCard = Utils.getMonthCardSpeedupHatchTime(player) or 0

	if speedUpTimeMonthCard > 0 then
		speedupTime[Const.HatchSpeedUpReason.monthcard] = speedUpTimeMonthCard
		hatchTime = math.max(1, hatchTime - speedUpTimeMonthCard)
	end

	return hatchTime, speedupTime
end

function Utils.getActivitySpeedupHatchTime(player, itemId)
	if not player then
		return 0
	end

	local hatchTime = Utils.getHatchTime(itemId)

	if not hatchTime or hatchTime <= 0 then
		return 0
	end

	local ActivityUtils = require("Common.Utils.ActivityUtils")
	local activity = ActivityUtils.getActivityData(player, ActivityConst.EventType.PetHatch)

	if not activity or not activity.activityBase:isGoing() then
		return 0
	end

	local speedTimeRate = activity:getSpeedUpTimeRate() or 0

	if speedTimeRate <= 0 then
		return 0
	end

	local perHatchTime = hatchTime

	hatchTime = math.max(1, math.floor(hatchTime * speedTimeRate / 1000))

	return perHatchTime - hatchTime
end

function Utils.getMonthCardSpeedupHatchTime(player)
	if not player then
		return 0
	end

	local accelMinutes = player.actorCombatAttribute:getAttribValue(AttributeConst.reduce_hatch_time)

	if accelMinutes and accelMinutes > 0 then
		return math.floor(accelMinutes * Const.SECONDS_ONE_MINUTE)
	end

	return 0
end

function Utils.getHatchBoxShowSlotIndex()
	local specialSlotIndex = 1
	local specialSlotInfo = Utils.getHatchSlotEggInfoByIndex(specialSlotIndex)

	if specialSlotInfo then
		return specialSlotIndex
	end

	local resultIndex
	local minRemainTime = math.huge

	for hatchSlotIndex, info in pairs(pg.me.hatchSlotMap or EMPTY_TABLE) do
		local status = info.status

		if status == Const.PET_BALL.HATCH_STATUS_SUCC then
			resultIndex = hatchSlotIndex

			return resultIndex
		elseif status == Const.PET_BALL.HATCH_STATUS_START then
			local ts = info.endTs
			local remainTime = ts - Time.secondCache

			if remainTime < minRemainTime then
				minRemainTime = remainTime
				resultIndex = hatchSlotIndex
			end
		end
	end

	return resultIndex
end

function Utils.getHatchSlotEggInfoByIndex(index)
	local ret
	local player = pg.me
	local hatchSlotInfo = player.hatchSlotMap[index]

	if not hatchSlotInfo then
		return ret
	end

	local item = hatchSlotInfo.item

	ret = Utils.getInfoByItem(item)

	return ret
end

function Utils.isHatchEggRuntimeDataValid(eggItem)
	if not eggItem or type(eggItem.id) ~= "number" or eggItem.id <= 0 then
		return false
	end

	if not Utils.isBreedPetEgg(eggItem.id) then
		return true
	end

	if not eggItem.getExtraProp then
		return false
	end

	local extraProp = eggItem:getExtraProp()

	return extraProp and next(extraProp) ~= nil
end

function Utils.getEggBindingSceneObjectIdByItemId(eggItemId, context, fallbackPrefabResID)
	context = context or "unknown"

	if type(eggItemId) ~= "number" or eggItemId <= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] invalid eggItemId, eggItemId=%s, context=%s", tostring(eggItemId), tostring(context))
		end

		return
	end

	if not PetHatchEggData[eggItemId] and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("[SoulEggChooseCubeConfig] missing pet_hatch_egg_data, eggItemId=%s, context=%s", tostring(eggItemId), tostring(context))
	end

	local itemData = ItemData[eggItemId]

	if not itemData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] missing item_data, eggItemId=%s, context=%s", tostring(eggItemId), tostring(context))
		end

		return nil, fallbackPrefabResID
	end

	local bindingId = itemData.bindingId

	if type(bindingId) ~= "number" or bindingId <= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] missing item_data.bindingId, eggItemId=%s, bindingId=%s, context=%s", tostring(eggItemId), tostring(bindingId), tostring(context))
		end

		return nil, fallbackPrefabResID
	end

	local bindingData = ItemObjectBindingData[bindingId]

	if not bindingData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] missing item_object_binding_data, eggItemId=%s, bindingId=%s, context=%s", tostring(eggItemId), tostring(bindingId), tostring(context))
		end

		return nil, fallbackPrefabResID
	end

	local envObjTemplateId = bindingData.sceneObjectId

	if type(envObjTemplateId) ~= "number" or envObjTemplateId <= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] missing item_object_binding_data.sceneObjectId, eggItemId=%s, bindingId=%s, sceneObjectId=%s, context=%s", tostring(eggItemId), tostring(bindingId), tostring(envObjTemplateId), tostring(context))
		end

		return nil, fallbackPrefabResID
	end

	local envObjData = EnvObjData[envObjTemplateId]

	if not envObjData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] missing envobj_data, eggItemId=%s, bindingId=%s, sceneObjectId=%s, context=%s", tostring(eggItemId), tostring(bindingId), tostring(envObjTemplateId), tostring(context))
		end

		return envObjTemplateId, fallbackPrefabResID
	end

	if type(envObjData.prefabResID) ~= "string" or envObjData.prefabResID == "" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SoulEggChooseCubeConfig] missing envobj_data.prefabResID, eggItemId=%s, bindingId=%s, sceneObjectId=%s, context=%s", tostring(eggItemId), tostring(bindingId), tostring(envObjTemplateId), tostring(context))
		end

		return envObjTemplateId, fallbackPrefabResID
	end

	return envObjTemplateId, envObjData.prefabResID
end

function Utils.getEggBindingSceneObjectId(slotIndex, fallbackPrefabResID)
	local player = pg.me
	local hatchSlotInfo = player and player.hatchSlotMap and player.hatchSlotMap[slotIndex]
	local eggItem = hatchSlotInfo and hatchSlotInfo.item

	if not eggItem then
		return
	end

	local context = string.format("hatchSlotIndex=%s", tostring(slotIndex))
	local envObjTemplateId, prefabResID = Utils.getEggBindingSceneObjectIdByItemId(eggItem.id, context, fallbackPrefabResID)

	if not prefabResID or prefabResID == "" then
		return
	end

	if not Utils.isHatchEggRuntimeDataValid(eggItem) then
		return
	end

	return envObjTemplateId, prefabResID
end

function Utils.getInfoByItem(item)
	local ret

	if Utils.isBreedPetEgg(item.id) then
		local extraProp = item:getExtraProp()

		if not extraProp or not next(extraProp) then
			return ret
		end

		local featureInfo = PetCharacterData[extraProp.characterId]
		local featureInfoNew = {}

		if featureInfo then
			featureInfoNew = {
				rare = featureInfo.rare or 0,
				desc = featureInfo.desc,
				name = featureInfo.name,
				icon = featureInfo.icon,
				characterId = extraProp.characterId
			}
		else
			featureInfoNew = featureInfo
		end

		local breedTalent = {}
		local talentList = extraProp.talentIds

		for i = 1, #talentList do
			local talentTemplateId = talentList[i]

			if talentTemplateId then
				local name = PetTalentData[talentTemplateId].talentName
				local icon = PetTalentData[talentTemplateId].talentIcon
				local quality = PetTalentData[talentTemplateId].rarity
				local id = talentTemplateId
				local group = PetTalentData[talentTemplateId].group
				local desc = PetTalentData[talentTemplateId].dec

				breedTalent[#breedTalent + 1] = {
					name = name,
					icon = icon,
					quality = quality,
					id = id,
					group = group,
					desc = desc
				}
			end
		end

		table.sort(breedTalent, function(a, b)
			return a.quality > b.quality
		end)

		ret = {
			isNormalEgg = false,
			isHatching = false,
			genId = item:getGenID(),
			id = item.id,
			count = item:getCount(),
			icon = ItemData[item.id].icon,
			quality = ItemData[item.id].quality,
			eggName = ItemData[item.id].itemName,
			eggDes = ItemData[item.id].itemDes,
			basePropertyIndividualLevelList = extraProp.basePropertyIndividualLevelList,
			characterId = extraProp.characterId,
			talentIds = extraProp.talentIds,
			templateId = extraProp.templateId,
			petName = PetData[extraProp.templateId].name,
			petIcon = PetData[extraProp.templateId].iconName,
			templateIdFather = extraProp.templateIdFather,
			templateIdMother = extraProp.templateIdMother,
			label = extraProp.label,
			gender = extraProp.gender,
			isShiny = Utils.isLabelShiny(extraProp.label),
			featureInfo = featureInfoNew,
			breedTalent = breedTalent
		}
	elseif Utils.isNormalPetEgg(item.id) then
		ret = {
			isHatching = false,
			isNormalEgg = true,
			genId = item:getGenID(),
			id = item.id,
			count = item:getCount(),
			icon = ItemData[item.id].icon,
			quality = ItemData[item.id].quality,
			eggName = ItemData[item.id].name,
			eggDes = ItemData[item.id].itemDes
		}
	end

	return ret
end

function Utils.getExpActionCount(itemId)
	local pfidd = PetFeedItemData[itemId]

	return pfidd and pfidd.times or 0
end

function Utils.getExpActionTime(itemId)
	local pfidd = PetFeedItemData[itemId]

	if pfidd == nil or pfidd.needTime == nil then
		return 0
	end

	return math.floor(pfidd.needTime * Const.SECONDS_ONE_HOUR)
end

function Utils.getPetBallExpNum(petballTemplateId, petLevel)
	local pbdd = PetBallData[petballTemplateId]

	if pbdd == nil or pbdd.exp == nil then
		return 0
	end

	return Utils.formulaSafeCall(0, pbdd.exp, petLevel)
end

function Utils.isPetLevelMax(player, petInfo, pldNext, level)
	level = level or petInfo.level
	pldNext = pldNext or PetLevelData[level + 1]

	local stage = petInfo.stage

	if not pldNext then
		return true
	end

	if stage < pldNext.needStage then
		return true
	end

	return false
end

function Utils.isPetLevelLimited(player, petInfo, pldNext, level)
	level = level or petInfo.level
	pldNext = pldNext or PetLevelData[level + 1]

	if Utils.isPetLevelMax(player, petInfo, pldNext, level) then
		return true
	end

	if level >= player:getMaxControlLevel() then
		return true
	end

	if petInfo.needBreakthrough then
		return true
	end

	return false
end

local petMaxOverFlowExp = 0

function Utils.getPetMaxOverFlowExp(curLeve)
	if SysConfigData.PET_EXCEED_LEVEL_MAX <= 0 then
		logger:warn("petMaxOverFlowExp opt, Utils.getPetMaxOverFlowExp PET_EXCEED_LEVEL_MAX == 0")

		return 0
	end

	if petMaxOverFlowExp > 0 then
		return petMaxOverFlowExp
	end

	local level = curLeve

	for i = 1, SysConfigData.PET_EXCEED_LEVEL_MAX do
		level = level + 1

		local pldNext = PetLevelData[level]

		if not pldNext then
			break
		end

		petMaxOverFlowExp = petMaxOverFlowExp + pldNext.needExp
	end

	logger:debug("petMaxOverFlowExp opt, Utils.getPetMaxOverFlowExp curLeve:%s, level:%s, petMaxOverFlowExp:%s", curLeve, level, petMaxOverFlowExp)

	return petMaxOverFlowExp
end

function Utils.resetPetMaxOverFlowExp()
	petMaxOverFlowExp = 0

	logger:debug("petMaxOverFlowExp opt, Utils.resetPetMaxOverFlowExp petMaxOverFlowExp:%s", petMaxOverFlowExp)
end

function Utils.getPetExpMaxAdd(player, petId, toLevel, donotOverflowExp)
	local maxControlLevel = player:getMaxControlLevel()

	toLevel = toLevel or maxControlLevel
	toLevel = math.min(toLevel, maxControlLevel)

	if pg.component == "client" and donotOverflowExp == nil then
		donotOverflowExp = true
	end

	local petInfo = player.pets[petId]

	if petInfo == nil then
		return 0, 0, 0
	end

	local maxExp = 0
	local level, levelExp = petInfo.level, 0

	while true do
		local pldNext = PetLevelData[level + 1]

		if not pldNext or Utils.isPetLevelLimited(player, petInfo, pldNext, level) or pldNext.breakthroughItemNums and level > petInfo.level then
			levelExp = pldNext and pldNext.needExp or 0

			if not donotOverflowExp then
				maxExp = maxExp + Utils.getPetMaxOverFlowExp(level)
			end

			break
		else
			level = level + 1
			levelExp = pldNext.needExp
			maxExp = maxExp + levelExp
		end

		if toLevel <= level then
			break
		end
	end

	maxExp = math_max(0, maxExp - petInfo.exp)

	if level > petInfo.level and maxExp == 0 then
		maxExp = 1
	end

	return maxExp, level, levelExp
end

function Utils.getSysMediaMarkerIdByNo(no)
	return string.format("SystemMediaMarkerId_%s", no)
end

function Utils.getNoBySysMediaMarkerId(markerId)
	local num = string.match(markerId, "^SystemMediaMarkerId_(%d+)$")

	return tonumber(num)
end

function Utils.isSysMediaMarkerId(markerId)
	local num = string.match(markerId, "^SystemMediaMarkerId_(%d+)$")

	return num ~= nil
end

function Utils.getMarkConfigId(markId, spaceId)
	local data = RandomMapBatchUtils.getMapMarkConfigData(spaceId)

	return data[markId] or 0
end

function Utils.checkTransmit(staticId)
	local t = SysConfigData.STONE_NOT_ACTIVE_AREA or {}

	for _, v in pairs(t) do
		if v == staticId then
			return false
		end
	end

	return true
end

function Utils.getMarkConfigByMarkId(markId, spaceId)
	local markConfigId = Utils.getMarkConfigId(markId, spaceId)

	return DefaultMapMarkData[markConfigId]
end

function Utils.getFuncTypeByMarkId(markId, spaceId)
	local dmmdd = Utils.getMarkConfigByMarkId(markId, spaceId)

	return dmmdd and dmmdd.funcType or 0
end

function Utils.calculateWsStainConsume(unit, needDecompress)
	local consumeMap = {
		[1] = false,
		[3] = false
	}
	local stainMap = unit.stainMatMap

	if needDecompress then
		stainMap = not string.isNilOrEmpty(unit.stainMatMap) and string.toTable(decompressFromStr(unit.stainMatMap)) or {}
	end

	for k, v in pairs(stainMap) do
		if type(v) == "table" and v.matAreas then
			for _, area in pairs(v.matAreas) do
				if area.colors or area.gradientColors then
					consumeMap[1] = true
				end

				if area.matTexIdx then
					consumeMap[3] = true
				end
			end
		end
	end

	local consumes = {}
	local fashion = 0

	for i, v in pairs(consumeMap) do
		local cData = WorkShopConsumeData[i]

		fashion = fashion + cData.fashion

		if v and cData and cData.consumes then
			for _, consume in ipairs(cData.consumes) do
				local num = consumes[consume[1]]

				if num == nil then
					consumes[consume[1]] = consume[2]
				else
					consumes[consume[1]] = num + consume[2]
				end
			end
		end
	end

	return consumes, fashion
end

function Utils.calculateWsAvatarConfigConsume()
	local cData = WorkShopConsumeData[4]
	local consumes = {}

	for _, v in ipairs(cData.consumes) do
		consumes[v[1]] = v[2]
	end

	return consumes, cData.fashion
end

function Utils.calculateWsHairConsume()
	local cData = WorkShopConsumeData[5]
	local consumes = {}

	for _, v in ipairs(cData.consumes) do
		consumes[v[1]] = v[2]
	end

	return consumes, cData.fashion
end

function Utils.getAppearanceCustomPhotoId(uid, custom, index)
	return "photo-" .. uid .. "-" .. custom .. index
end

function Utils.getAppearanceHairPhotoId(uid, hairSuitId, index)
	return "photo-" .. uid .. "-" .. "hairCustom" .. "-" .. hairSuitId .. index
end

function Utils.getAppearanceClothesPhotoId(uid, configId, index)
	return "photo-" .. uid .. "-" .. "clothesDesign" .. "-" .. configId .. index
end

function Utils.getPetPrepareFormationCnt(player)
	local cnt = 0

	if Utils.isPlayer(player) then
		for _, formationInfo in ipairs(player.prepareFormationList) do
			if #formationInfo.formation > 0 then
				cnt = cnt + 1
			end
		end
	end

	return cnt
end

function Utils.getRareCharacterId(petPrototypeId)
	local pptdd = PetPrototypeData[petPrototypeId]

	if pptdd == nil then
		return nil
	end

	for _, characterId in ipairs(pptdd.feature or EMPTY_TABLE) do
		local cdd = PetCharacterData[characterId]

		if cdd and ToBool(cdd.rare) then
			return characterId
		end
	end

	return nil
end

function Utils.genSandbxVersion(sceneId, sandboxId, spaceId)
	if pg.component == "game" then
		local sandboxConf = SceneUtils.getSceneSandboxIdData(sceneId, sandboxId, spaceId)

		if sandboxConf == nil then
			return ""
		end

		local graphId = sandboxConf.graphId

		if not graphId or graphId == 0 then
			return ""
		end

		local levelItems = lume.getTableKeys(sandboxConf.levelItems)

		table.sort(levelItems)

		local levelItemsStr = table.concat(levelItems, "-")
		local sandboxConfVersion = string.format("%s-%s-%s-%s-%s", sandboxConf.sandboxType, sandboxConf.autoSave, sandboxConf.disposable, sandboxConf.onFinished, levelItemsStr)
		local sceneGraphData = SceneUtils.getSceneGraphData(sceneId, spaceId)
		local graphData = sceneGraphData[graphId]
		local graphVersion = ""

		if graphData then
			graphVersion = graphData.md5 or ""
		end

		local version = string.format("%s-%s", graphVersion, sandboxConfVersion)
		local md5 = require("md5")

		return md5.sumhexa(version)
	end

	return ""
end

function Utils.interpolate(interFunc, from, to, t, exponent)
	if interFunc == nil or interFunc == Const.InterpolateFunc.Linear then
		return math.lerp(from, to, t)
	end

	if interFunc == Const.InterpolateFunc.EaseIn then
		return Utils.interpEaseIn(from, to, t, exponent)
	end

	if interFunc == Const.InterpolateFunc.EaseOut then
		return Utils.interpEaseOut(from, to, t, exponent)
	end

	if interFunc == Const.InterpolateFunc.EaseInOut then
		return Utils.interpEaseInOut(from, to, t, exponent)
	end

	return to
end

function Utils.interpEaseIn(from, to, t, exponent)
	local modifiedAlpha = math.pow(t, exponent)

	return math.lerp(from, to, modifiedAlpha)
end

function Utils.interpEaseOut(from, to, t, exponent)
	local modifiedAlpha = 1 - math.pow(1 - t, exponent)

	return math.lerp(from, to, modifiedAlpha)
end

function Utils.interpEaseInOut(from, to, t, exponent)
	if t < 0.5 then
		return Utils.interpEaseIn(from, to, t, exponent)
	end

	return Utils.interpEaseOut(from, to, t, exponent)
end

function Utils.getPetCountryId(petPrototypeId)
	local prcdd = PetResearchContentData[petPrototypeId]

	if prcdd and prcdd.countryId ~= nil then
		return prcdd.countryId
	end

	local basePrcdd = PetResearchContentData[Utils.getBasePetPrototypeId(petPrototypeId)]

	if basePrcdd and basePrcdd.countryId ~= nil then
		return basePrcdd.countryId
	end

	return 0
end

function Utils.getPetCountryIdSet(petPrototypeId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

	return PetResearchSpeciesCountrySet[basePetPrototypeId] or EMPTY_PET_COUNTRY_ID_SET
end

function Utils.checkPetHasFormInCountry(petPrototypeId, countryId)
	if not petPrototypeId or not countryId then
		return false
	end

	return Utils.getPetCountryIdSet(petPrototypeId)[countryId] == true
end

function Utils.isPetSkillUnlock(player, petPrototypeId, abilityParamId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local psdd = PetSkillData[basePetPrototypeId] and PetSkillData[basePetPrototypeId][abilityParamId]

	if psdd == nil then
		return false
	end

	if player == nil and (psdd.unlockCondition or psdd.needPetFormsUnlock) then
		return false
	end

	if psdd.unlockCondition and not player.triggerMap:isCompleteOrMeetCondition(psdd.unlockCondition) then
		return false
	end

	local function funIsFormUnlock(id)
		return id == petPrototypeId or player.petHandbookMap:isCatched(id, Const.GROUP_TYPE_SELF)
	end

	if psdd.needPetFormsUnlock and not lume.any(psdd.needPetFormsUnlock, funIsFormUnlock) then
		return false
	end

	return true
end

function Utils.checkNeedDoGroupReward(puppet)
	if not CommonSwitch.GROUP_DROP then
		return false
	end

	if puppet == nil or not Utils.isLabelElite(puppet.label) then
		return false
	end

	if puppet:isInCatchRogueSpace() or puppet:isInFishingCaptureSpace() then
		return false
	end

	local pudd = puppet:getConfigData()
	local cpdd = pudd and CatchProbData[pudd.catchProbGroup]

	return (cpdd and cpdd.baseProbDeath or 0) > 0
end

function Utils.getGroupDropDelayDie(puppet)
	if not Utils.checkNeedDoGroupReward(puppet) then
		return puppet.delayDie
	end

	return SysConfigData.eliteDeadCatchDuration or puppet.delayDie or 60
end

function Utils.getMasterPlayer(ent)
	if ent == nil then
		return nil
	end

	if Utils.isPlayer(ent) or Utils.isBotPlayer(ent) then
		return ent
	end

	local master = ent.getMasterEntity and ent:getMasterEntity()

	return master and Utils.getMasterPlayer(master) or nil
end

function Utils.getPetTeamAvgLevel(player)
	local sumLevel = 0
	local petCount = 0

	for _, petId in pairs(player.petPrepareList) do
		local petInfo = player:getPetInfo(petId)

		if petInfo then
			sumLevel = sumLevel + petInfo.level
			petCount = petCount + 1
		end
	end

	return petCount > 0 and lume.round(sumLevel / petCount, 0.01) or 0
end

function Utils.getPetTeamUltimateCnt()
	local masterEntity = pg.me

	if not masterEntity then
		return 0
	end

	local prepareList = masterEntity.petPrepareList

	if not ToBool(prepareList) then
		return 0
	end

	local cnt = 0

	for _, petId in ipairs(prepareList) do
		local abilityInfo = masterEntity.pets and masterEntity.pets[petId] and masterEntity.pets[petId].curAbilityMap and masterEntity.pets[petId].curAbilityMap[AbilityConst.ULTIMATE_ABILITY]

		if abilityInfo then
			cnt = cnt + 1
		end
	end

	return cnt
end

function Utils.getPlayerPetByTeamIndex(player, petTeamIdx)
	if not player or not Utils.isPlayer(player) then
		return nil
	end

	local petPrepareInfoList = player.petPrepareList

	if not petPrepareInfoList then
		return nil
	end

	local petId = petPrepareInfoList[petTeamIdx]

	if petId == nil then
		return nil
	end

	return pg.getEntity(petId)
end

function Utils.convertPlayerEntity(ent)
	if Utils.isPlayer(ent) or Utils.isBotPlayer(ent) then
		return ent
	elseif Utils.isPet(ent) then
		return ent:getMasterEntity()
	end

	return nil
end

function Utils.getTelnetExtraLocals()
	local res = {
		IDManager = require("Core.Common.IDManager"),
		Time = require("Core.Common.Time"),
		lume = require("Core.Common.lume"),
		CallbackHandler = require("Core.Common.CallbackHandler"),
		NoticeDef = require("Common.NoticeDef"),
		Const = require("Common.Const.Const"),
		GmConst = require("Common.Const.GmConst"),
		ItemConst = require("Common.Const.ItemConst"),
		TriggerConst = require("Common.Const.TriggerConst"),
		AbilityConst = require("Common.Const.AbilityConst"),
		AttributeConst = require("Common.Const.AttributeConst"),
		ActivityConst = require("Common.Const.ActivityConst"),
		SocialConst = require("Common.Const.SocialConst"),
		Utils = require("Common.Utils.Utils"),
		ItemUtils = require("Common.Utils.ItemUtils"),
		DropUtils = require("Common.Utils.DropUtils"),
		TriggerUtils = require("Common.Utils.TriggerUtils"),
		ActivityUtils = require("Common.Utils.ActivityUtils"),
		TimeUtils = require("Common.Utils.TimeUtils"),
		HomeLandUtils = require("Common.Utils.HomeLandUtils"),
		CommonSwitch = require("Common.CommonSwitch"),
		OpDef = require("Common.OpDef")
	}

	if pg.component == "game" then
		table.merge(res, {
			GameServerRepo = require("Core.Server.GameServerRepo"),
			Globals = require("Globals"),
			ServerConst = require("GameServer.ServerConst"),
			ServerUtils = require("GameServer.ServerUtils")
		})
	else
		table.merge(res, {
			ClientRepo = require("Core.Client.ClientRepo"),
			GlobalData = require("Core.Client.GlobalData"),
			ClientUtils = require("Utils.ClientUtils"),
			ClientConst = require("Const.ClientConst")
		})
	end

	return res
end

function Utils.isHasCheckPositionMatchChest(playerEnt, chestId, distance)
	local entityList = playerEnt and playerEnt.GetRangeEntsChest and playerEnt:GetRangeEntsChest()

	if entityList then
		for _, chestEntity in pairs(entityList) do
			if chestId == chestEntity.templateId and Utils.isChestVisible(playerEnt, chestEntity) and Vector3.SqrDistance(playerEnt:getPosition(), chestEntity:getPosition()) < distance * distance then
				return true
			end
		end
	end

	return false
end

function Utils.isHasCheckPositionMatchChestFast(playerEnt, chestId, distance)
	local typeEnts = playerEnt and playerEnt.GetRangeTypeChests and playerEnt:GetRangeTypeChests()

	if typeEnts then
		local list = typeEnts[chestId]

		if list then
			for _, chestEntity in pairs(list) do
				if Vector3.SqrDistance(playerEnt:getPosition(), chestEntity:getPosition()) < distance * distance then
					return true
				end
			end
		end
	end

	return false
end

function Utils.dcmp(x)
	local eps = 1e-06

	if eps > math.abs(x) then
		return 0
	else
		return x < 0 and -1 or 1
	end
end

function Utils.onSegment(p1, p2, pos)
	local cross = (p1[1] - pos[1]) * (p2[3] - pos[3]) - (p2[1] - pos[1]) * (p1[3] - pos[3])
	local dot = (p1[1] - pos[1]) * (p2[1] - pos[1]) + (p1[3] - pos[3]) * (p2[3] - pos[3])

	return Utils.dcmp(cross) == 0 and Utils.dcmp(dot) <= 0
end

function Utils.inPloygon2D(pos, verts)
	local flag = false
	local n = #verts

	for i = 1, n do
		local j = i % n + 1
		local p1 = verts[i]
		local p2 = verts[j]

		if Utils.onSegment(p1, p2, pos) then
			return true
		end

		if p1[3] > pos[3] ~= (p2[3] > pos[3]) and pos[1] < (pos[3] - p1[3]) * (p2[1] - p1[1]) / (p2[3] - p1[3]) + p1[1] then
			flag = not flag
		end
	end

	return flag
end

local verts = {}

function Utils.inSeamlessRange(sceneId, areaId, myPosition, isEnter, isDynamic, spaceId)
	local mainScene = SceneUtils.getMainSceneId(sceneId)
	local sceneAreaData = SceneUtils.getSceneAreaData(mainScene, spaceId)
	local areaData = sceneAreaData[areaId] or {}
	local checkType = areaData.areaShapeType

	if not checkType then
		return false
	end

	local inRange = true
	local x_p = myPosition[1]
	local y_p = myPosition[2]
	local z_p = myPosition[3]
	local centerPos = areaData.position

	if checkType == Const.AREA_CIRCLE then
		local addCheckDis = isEnter and 0 or 0.5
		local x_c = centerPos[1]
		local z_c = centerPos[3]
		local radius = areaData.radius
		local distance_squared = (x_p - x_c)^2 + (z_p - z_c)^2

		inRange = distance_squared <= radius^2 + addCheckDis
	elseif checkType == Const.AREA_RECTANGLE or checkType == Const.AREA_POLYGON then
		local areaPoints = areaData.areaPoints

		if isDynamic then
			areaPoints = Utils.getDynamicSeamlessArea(myPosition, sceneId, areaId)
		end

		local myPos = Vector3.createTempLightVector(x_p, 0, z_p)

		for i = 1, #areaPoints, 2 do
			verts[#verts + 1] = Vector3.createTempLightVector(areaPoints[i], 0, areaPoints[i + 1])
		end

		inRange = Utils.inPloygon2D(myPos, verts)

		Vector3.returnTempLightVector(myPos)
		Vector3.returnTempLightVectorArray(verts)
	else
		inRange = false
	end

	if inRange then
		local y_c = centerPos[2]
		local yAddCheckDis = isEnter and 0 or 0.5

		inRange = inRange and y_c <= y_p and y_p - y_c <= areaData.height + yAddCheckDis
	end

	return inRange
end

function Utils.getDynamicSeamlessArea(dynamicPos, sceneId, areaId, spaceId)
	local sceneAreaData = SceneUtils.getSceneAreaData(sceneId, spaceId)
	local areaData = sceneAreaData[areaId] or {}
	local s_ps = {}
	local areaShapeType = areaData.areaShapeType
	local curPos = dynamicPos
	local c_x = curPos[1]
	local c_z = curPos[3]

	if areaShapeType == 1 or areaShapeType == 2 then
		local s_x = areaData.position[1]
		local s_z = areaData.position[3]
		local p_x = c_x - s_x
		local p_z = c_z - s_z
		local ps = areaData.areaPoints
		local p_num = #ps
		local c_idx = 1

		while c_idx < p_num do
			local x = ps[c_idx]
			local z = ps[c_idx + 1]

			s_ps[c_idx] = x + p_x
			s_ps[c_idx + 1] = z + p_z
			c_idx = c_idx + 2
		end
	end

	return s_ps
end

function Utils.checkInSpecificAreaRange(sceneId, dynamicPos, spaceId)
	local function inner(sceneIdTemp)
		local sceneAreaData = SceneUtils.getSceneAreaData(sceneIdTemp, spaceId)

		for areaId, areaData in pairs(sceneAreaData) do
			if AreaNavTransitData[areaId] and Utils.areaCheck(areaData, dynamicPos) then
				return areaId
			end
		end

		return nil
	end

	local mainSceneId = SceneUtils.getMainSceneId(sceneId)

	if not SceneSeamlessData[mainSceneId] or not SceneSeamlessData[mainSceneId].seamlessGroup then
		return inner(sceneId)
	else
		for seamlessId, _ in pairs(SceneSeamlessData[mainSceneId].seamlessGroup) do
			local result = inner(seamlessId)

			if result then
				return result
			end
		end
	end

	return nil
end

function Utils.areaCheck(areaData, dynamicPos)
	local checkType = areaData.areaShapeType

	if not checkType then
		return false
	end

	local inRange = true
	local x_p = dynamicPos[1]
	local y_p = dynamicPos[2]
	local z_p = dynamicPos[3]
	local centerPos = areaData.position
	local bot_y = centerPos[2]

	if checkType == Const.AREA_CIRCLE then
		local x_c = centerPos[1]
		local z_c = centerPos[3]
		local radius = areaData.radius
		local distance_squared = (x_p - x_c)^2 + (z_p - z_c)^2

		inRange = distance_squared <= radius^2
	elseif checkType == Const.AREA_RECTANGLE or checkType == Const.AREA_POLYGON then
		local areaPoints = areaData.areaPoints
		local verts = {}
		local myPos = {
			x_p,
			0,
			z_p,
			y = 0,
			x = x_p,
			z = z_p
		}

		for i = 1, #areaPoints, 2 do
			verts[#verts + 1] = {
				areaPoints[i],
				0,
				areaPoints[i + 1],
				y = 0,
				x = areaPoints[i],
				z = areaPoints[i + 1]
			}
		end

		inRange = Utils.inPloygon2D(myPos, verts)
	else
		inRange = false
	end

	if y_p < bot_y or y_p > bot_y + areaData.height then
		inRange = false
	end

	return inRange
end

function Utils.checkInAreaRange(sceneId, areaId, dynamicPos, spaceId)
	local sceneAreaData = SceneUtils.getSceneAreaData(sceneId, spaceId)
	local areaData = sceneAreaData[areaId] or {}

	return Utils.areaCheck(areaData, dynamicPos)
end

function Utils.checkSendArkReward(player, arkRewardId)
	local asrdd = ArkSendRewardData[arkRewardId]

	if asrdd == nil then
		return NoticeDef.ERROR_CONFIG_NIL
	end

	if not asrdd.chestId and not asrdd.rewardId then
		return NoticeDef.ERROR_CONFIG_HAS_ERROR
	end

	if player.unclaimedArkRewardMap[arkRewardId] then
		return NoticeDef.ARK_REWARD_UNLAIMED
	end

	if asrdd.rewardMax ~= -1 and (player.arkRewardCountMap[arkRewardId] or 0) >= asrdd.rewardMax then
		return NoticeDef.ERROR_LIMIT_EXCEED
	end

	return NoticeDef.SUCCESS
end

function Utils.getTitleAssessInfo(title, player, isIgnoreTime, isIgnoreLevel)
	local info = {
		can = false,
		formatTime = "",
		state = "None",
		title = title
	}

	if title == 0 then
		return info
	end

	if title > #PlayerTitleData then
		info.state = "MaxStar"

		return info
	end

	local me = player or pg.me
	local tmpTitle = title - 1
	local cData = PlayerTitleData[tmpTitle]
	local needLv = cData and cData.needLevel or 0

	if not isIgnoreLevel and needLv > me.level then
		info.state = "LvNotMatch"

		return info
	end

	while cData and cData.unlockDay == nil do
		tmpTitle = tmpTitle - 1
		cData = PlayerTitleData[tmpTitle]

		if tmpTitle <= 0 then
			break
		end
	end

	if not isIgnoreTime and cData and cData.unlockDay and Time.ServerOpenTime then
		local endSecond = TimeUtils.getServerDayBegin(Time.ServerOpenTime) + cData.unlockDay * Const.SECONDS_ONE_DAY

		if endSecond > Time.secondCache then
			info.state = "TimeNotMatch"
			info.formatTime = endSecond

			return info
		end
	end

	info.can = true
	info.state = "Match"

	return info
end

function Utils.checkCanUpGradeStar(player, isIgnoreTime)
	local info = Utils.getTitleAssessInfo(player.starTitle + 1, player, isIgnoreTime)

	return info.can
end

function Utils.checkMatchStarCanUp(title)
	local info = Utils.getTitleAssessInfo(title)

	return info.can
end

function Utils.checkUPStarTimeMatch(star)
	local info = Utils.getTitleAssessInfo(star)

	return info.can
end

function Utils.getUPStarFormatTime(star)
	local info = Utils.getTitleAssessInfo(star)

	return info.formatTime
end

function Utils.getCurTankActorId(space)
	if not space or not space.selectedTankEntId then
		return 0
	end

	local playerEntity = pg.getEntity(space.selectedTankEntId)

	if not playerEntity then
		return 0
	end

	local pet = playerEntity:getCurPetEntity()

	return pet and pet.actorId or 0
end

function Utils.queryIsFriend(owner, target, callback)
	local function serviceCallback(result, resp)
		if not result.status then
			callback(false, false)

			return
		end

		callback(resp.IsFriend, resp.IsBlackList)
	end

	owner:callService("FriendService", "chatQuery", {
		owner.uid,
		target.uid
	}, serviceCallback)
end

function Utils.queryFriendship(owner, targetUid, callback)
	local function serviceCallback(result, resp)
		if not result.status then
			callback(0)

			return
		end

		callback(resp.Intimacy or 0)
	end

	owner:callService("FriendService", "chatQuery", {
		owner.uid,
		targetUid
	}, serviceCallback)
end

function Utils.calFriendshipLevel(friendshipValue)
	friendshipValue = friendshipValue or 0

	local level, levelExp, levelTotalExp = 0, 0, 0

	if friendshipValue > FriendshipLevelData[#FriendshipLevelData].friendshipRange[2] then
		return #FriendshipLevelData, 0, 0
	end

	for k, v in pairs(FriendshipLevelData) do
		if friendshipValue >= v.friendshipRange[1] and friendshipValue <= v.friendshipRange[2] then
			level = k
			levelExp = friendshipValue - v.friendshipRange[1]
			levelTotalExp = v.friendshipRange[2] - v.friendshipRange[1]

			break
		end
	end

	return level, levelExp, levelTotalExp
end

function Utils.isPetTradeFriendshipLevelEnough(petInfoDict, pedd, friendshipLevel)
	if friendshipLevel < pedd.friendshipLevel then
		return false
	end

	if not pedd.credential then
		return true
	end

	local minCredential, maxCredential

	for requiredFriendshipLevel, credential in pairs(pedd.credential) do
		if not minCredential or credential <= minCredential then
			minCredential = credential
		end

		if requiredFriendshipLevel <= friendshipLevel and (not maxCredential or maxCredential < credential) then
			maxCredential = credential
		end
	end

	if not minCredential then
		return true
	end

	maxCredential = maxCredential or minCredential - 1

	for _, baseProperty in ipairs(petInfoDict.basePropertyList) do
		if maxCredential < BaseProperty.getBaseIndividualLevel(baseProperty, true, true) then
			return false
		end
	end

	return true
end

function Utils.getExchangePetConfig(petInfoDict)
	local formQuality = Utils.getPetFormQualityByTemplateId(petInfoDict.templateId)

	if not formQuality then
		return nil, 0
	end

	for k, v in pairs(ExchangePetData) do
		if v.stage == petInfoDict.stage and v.label == petInfoDict.label and lume.find(v.formQuality, formQuality) ~= nil then
			return v, k
		end
	end

	return nil, 0
end

function Utils.getExchangePetCost(petInfoDict, friendshipLevel, pedd, hasShinyStar)
	pedd = pedd or Utils.getExchangePetConfig(petInfoDict)

	local fldd = FriendshipLevelData[friendshipLevel]
	local rate = fldd.petExchangeCostRate or 1
	local ItemUtils = require("Common.Utils.ItemUtils")
	local costItems = ItemUtils.itemList2Dict(pedd.itemCost, rate, math.ceil)

	if hasShinyStar then
		ItemUtils.mergeShinyExtraCost(costItems)
	end

	return costItems
end

function Utils.getExchangePetReward(petInfoDict, friendshipLevel, pedd)
	pedd = pedd or Utils.getExchangePetConfig(petInfoDict)

	local fldd = FriendshipLevelData[friendshipLevel]
	local rate = fldd.petExchangeRewardRate or 1

	return pedd.rewardId, rate
end

function Utils.checkExchangeRemovePet(player, petInfoDict, friendshipLevel, pedd)
	pedd = pedd or Utils.getExchangePetConfig(petInfoDict)

	if pedd == nil then
		return false, Const.EPRR_PET_TYPE_FORBID
	end

	if lume.find(player.petPrepareList, petInfoDict.id) then
		return false, Const.EPRR_PET_IN_TEAM
	end

	if lume.find(player.petExploreList, petInfoDict.id) then
		return false, Const.EPRR_PET_IN_TEAM
	end

	if not Utils.isPetTradeFriendshipLevelEnough(petInfoDict, pedd, friendshipLevel) then
		return false, Const.EPRR_FRIENDSHIP_LOW
	end

	if player:getPetExchangeTs(petInfoDict) + SysConfigData.CHANGE_PETS_CD * Const.SECONDS_ONE_DAY > Time.secondCache then
		return false, Const.EPRR_EXCHANGE_CD
	end

	if lume.find(SysConfigData.NO_CHANGE_PETS, petInfoDict.petPrototypeId) then
		return false, Const.EPRR_PET_TYPE_FORBID
	end

	if petInfoDict.isTwinChoice then
		return false, Const.EPRR_PET_TYPE_FORBID
	end

	local ownedPetInfo = player.pets[petInfoDict.id]
	local isCredentialKnown = not ownedPetInfo:isCatchReporting()
	local canExchange = PetFriendTradeUtils.checkExchangeLimit(player.useLimitMap, petInfoDict, pedd, friendshipLevel, isCredentialKnown)

	if not canExchange then
		return false, Const.EPRR_LIMIT_EXCEED
	end

	if player:isPetPutInHomeland(petInfoDict) then
		return false, Const.EPRR_PET_IN_HOME
	end

	if player:isPetActivityDispatching(petInfoDict) then
		return false, Const.EPRR_PET_IN_DISPATCH
	end

	if pg.component == "game" then
		local ItemUtils = require("Common.Utils.ItemUtils")
		local itemDict = ItemUtils.getExchangePetBackItem(player, petInfoDict.id)

		if NoticeDef.SUCCESS ~= player:checkAddItemsByIdNumDict(itemDict, ItemConstSourceData.ITEM_SOURCE_EXCHANGE_PET) then
			return false, Const.EPRR_ITEM_BAG_FULL
		end

		local PetConstSourceData = require("Data.pet_const_source_data")

		return player:checkRemovePet(petInfoDict.id, PetConstSourceData.PET_REMOVE_EXCHANGE)
	else
		return true
	end
end

function Utils.checkExchangeAddPet(player, petInfoDict, friendshipLevel, pedd, hasShinyStar)
	pedd = pedd or Utils.getExchangePetConfig(petInfoDict)

	local idNumDict = Utils.getExchangePetCost(petInfoDict, friendshipLevel, pedd, hasShinyStar)

	if pg.component == "game" then
		if player:checkDelItemsByIdNumDict(idNumDict, ItemConstSourceData.ITEM_CONSUME_COMMON) ~= NoticeDef.SUCCESS then
			return false, Const.EPAR_COST_LACK
		end
	else
		local ItemUtils = require("Common.Utils.ItemUtils")

		if not ItemUtils.simpleCheckItemCountEnough(player, idNumDict) then
			return false, Const.EPAR_COST_LACK
		end
	end

	if not Utils.isPetTradeFriendshipLevelEnough(petInfoDict, pedd, friendshipLevel) then
		return false, Const.EPAR_FRIENDSHIP_LOW
	end

	if (petInfoDict.petExchangeTs or 0) + SysConfigData.CHANGE_PETS_CD * Const.SECONDS_ONE_DAY > Time.secondCache then
		return false, Const.EPAR_EXCHANGE_CD
	end

	if lume.find(SysConfigData.NO_CHANGE_PETS, petInfoDict.petPrototypeId) then
		return false, Const.EPAR_PET_TYPE_FORBID
	end

	if petInfoDict.isTwinChoice then
		return false, Const.EPAR_PET_TYPE_FORBID
	end

	if not player.useLimitMap:testLimit(SysConfigData.CHANGE_PETS_DAILY_LIMIT) then
		return false, Const.EPAR_LIMIT_EXCEED
	end

	if pg.component == "game" and player:checkAddPet(petInfoDict.templateId, petInfoDict, Const.PET_FROM_EXCHANGE) ~= NoticeDef.SUCCESS then
		return false, Const.EPAR_ADD_PET_FORBID
	end

	return true
end

function Utils.checkNeedDamageStatistic(entity)
	local pdd = PuppetData[entity.templateId]

	if not pdd then
		return false
	end

	return pdd.rewardType == Const.DROP_REWARD.TYPE_MAX_DAMAGE or pdd.rewardType == Const.DROP_REWARD.TYPE_DAMAGE_THRESHOLD
end

function Utils.getStableAttributesValue(who, key)
	return who.stableAttributesDict and who.stableAttributesDict[key]
end

function Utils.getBlockCatchedCount(who, blockId)
	local blockConfig = MapBlockConfigData[blockId]

	if not blockConfig then
		return 0, 0
	end

	local petList = blockConfig.petList

	if not petList then
		return 0, 0
	end

	local blockCatchedMap = who.blockCatchedPetMap or Utils.getStableAttributesValue(who, "blockCatchedPetMap")
	local catchedMap = blockCatchedMap and blockCatchedMap[blockId]
	local count = 0

	for _, petPrototypeId in ipairs(petList) do
		if catchedMap and catchedMap[petPrototypeId] and catchedMap[petPrototypeId].isCatched then
			count = count + 1
		end
	end

	return count, #petList
end

function Utils.getBlockCatchedRate(who, blockId)
	local count, total = Utils.getBlockCatchedCount(who, blockId)

	return total > 0 and lume.round(count / total, 0.01) or 0
end

function Utils.isBlockPetCatched(who, blockId, petPrototypeId, groupType)
	groupType = groupType or Const.GROUP_TYPE_SELF

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		return Utils.isBlockPetCatchedOrKnown(who, blockId, innerPetPrototypeId, true)
	end)
end

function Utils.isBlockPetKnown(who, blockId, petPrototypeId, groupType)
	groupType = groupType or Const.GROUP_TYPE_SELF

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		return Utils.isBlockPetCatchedOrKnown(who, blockId, innerPetPrototypeId, false)
	end)
end

function Utils.getBlockPetCatchedInfo(who, blockId, innerPetPrototypeId)
	local blockCatchedMap = who.blockCatchedPetMap or Utils.getStableAttributesValue(who, "blockCatchedPetMap")
	local catchedMap = blockCatchedMap and blockCatchedMap[blockId]

	if not catchedMap then
		return false
	end

	return catchedMap[innerPetPrototypeId]
end

function Utils.isBlockPetCatchedOrKnown(who, blockId, innerPetPrototypeId, needIsCatched)
	local catchedInfo = Utils.getBlockPetCatchedInfo(who, blockId, innerPetPrototypeId)

	if not catchedInfo then
		return false
	end

	if needIsCatched then
		return catchedInfo.isCatched
	end

	return true
end

function Utils.isPetCatched(who, petPrototypeId, groupType)
	groupType = groupType or Const.GROUP_TYPE_SELF

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		return Utils.innerIsPetCatched(who, innerPetPrototypeId)
	end)
end

function Utils.innerIsPetCatched(who, innerPetPrototypeId)
	local flags = who.catchedPetSet or Utils.getStableAttributesValue(who, "catchedPetSet")

	if flags == nil then
		return false
	end

	if not Bitset.getBit(flags, innerPetPrototypeId) then
		return false
	end

	return true
end

function Utils.isWeatherPetProgressUnlocked(player, smallAreaId)
	local smallAreaCfg = MapBlockConfigData[smallAreaId]

	if not smallAreaCfg then
		return false
	end

	if not smallAreaCfg.badge2 then
		return true
	end

	return player.badgeStatusMap[smallAreaCfg.badge2] == Const.BADGE_STATUS.Complete
end

function Utils.isSmallAreaPetProgressUnlocked(player, smallAreaId)
	local smallAreaCfg = MapBlockConfigData[smallAreaId]

	if not smallAreaCfg then
		return false
	end

	if not smallAreaCfg.badge1 then
		return true
	end

	return player.badgeStatusMap[smallAreaCfg.badge1] == Const.BADGE_STATUS.Complete
end

function Utils.isDuringLeylineFlowerCreatePlenty(player, blockId)
	if not player.space then
		return false
	end

	local staticId = LeylineFlowerUtils.getStaticIdByBlockId(player.space.sceneId, blockId)

	if not staticId then
		return false
	end

	local info = player.leylineFlowerInfoMap and player.leylineFlowerInfoMap[staticId]

	if not info then
		return false
	end

	return info.flowerState ~= LeylineFlowerConst.FLOWER_STATE.Growing
end

function Utils.pos3ToPosition(pos3)
	local position = Vector3(0, 0, 0)

	position[1] = (pos3[1] or 0) * 0.01
	position[2] = (pos3[2] or 0) * 0.01
	position[3] = (pos3[3] or 0) * 0.01

	return position
end

function Utils.positionToPos3(position)
	local pos3 = {
		math.round((position[1] or 0) * 100),
		math.round((position[2] or 0) * 100),
		math.round((position[3] or 0) * 100)
	}

	return pos3
end

function Utils.yawAngleIntToQuaternion(yawAngle)
	local rotation = Quaternion.Euler(0, yawAngle * 0.01, 0)

	return rotation
end

function Utils.yawToYawAngleInt(eulerYaw)
	local yawAngle = math.floor(eulerYaw * 100)

	return yawAngle
end

function Utils.quaternionToYawAngleInt(rotation)
	local eulerYaw = rotation:GetEulerAnglesY()

	eulerYaw = Utils.normalizeAngle(eulerYaw)

	local yawAngle = math.floor(eulerYaw * 100)

	return yawAngle
end

function Utils.checkRotationIsVertical(rotation)
	return Utils.checkYawIsVertical(rotation:GetEulerAnglesY())
end

function Utils.checkYawIsVertical(eulerYaw)
	eulerYaw = Utils.normalizeAngle(eulerYaw)

	return eulerYaw > 45 and eulerYaw < 135 or eulerYaw > 225 and eulerYaw < 315
end

function Utils.calcBoundsYaw(eulerYaw)
	eulerYaw = Utils.normalizeAngle(eulerYaw)

	if eulerYaw <= 45 then
		return 0
	end

	if eulerYaw <= 135 then
		return 90
	end

	if eulerYaw <= 225 then
		return 180
	end

	if eulerYaw <= 315 then
		return 270
	end

	return 0
end

function Utils.isOdd(number)
	return number % 2 ~= 0
end

function Utils.convertToGridValue(value, gridSize)
	value = math.round(value / gridSize) * gridSize

	return value
end

function Utils.getAuthorityPlayerActorId(entity)
	if entity then
		local authorityEnt = pg.getEntity(entity.authorityId)

		if Utils.isPlayer(authorityEnt) then
			return authorityEnt.actorId
		end
	end

	return 0
end

function Utils.checkIsAuthorityMaster(entity)
	return entity and entity.authority == Const.AUTHORITY_MASTER or false
end

function Utils.checkIsSpaceAuthorityMaster(playerEntity)
	return playerEntity and playerEntity.space.authorityId == playerEntity.id
end

function Utils.checkIsSpaceOwner(playerEntity)
	if playerEntity == nil or playerEntity.space == nil then
		return false
	end

	if not string.isNilOrEmpty(playerEntity.space.ownerPlayerId) then
		return playerEntity.space.ownerPlayerId == pg.me.id
	end

	return Utils.checkIsSpaceAuthorityMaster(playerEntity)
end

function Utils.isBasePetPrototypeId(prototypeId)
	local ppdd = PetPrototypeData[prototypeId]

	return ppdd and ppdd.baseFormPet == prototypeId or false
end

function Utils.getBasePetPrototypeId(prototypeId)
	local ppdd = PetPrototypeData[prototypeId]

	return ppdd and ppdd.baseFormPet or 0
end

function Utils.getBasePetPrototypeIdCount(petPrototypeIds)
	local idSet = {}

	for _, petPrototypeId in ipairs(petPrototypeIds) do
		idSet[Utils.getBasePetPrototypeId(petPrototypeId)] = true
	end

	return lume.count(idSet)
end

function Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, func)
	if groupType == Const.GROUP_TYPE_SELF then
		return func(petPrototypeId)
	elseif groupType == Const.GROUP_TYPE_BASE then
		return func(Utils.getBasePetPrototypeId(petPrototypeId))
	else
		local ret
		local ids = PetAllPrototypeList[petPrototypeId] or PetBasePrototypeToPrototypeMap[petPrototypeId] or {}

		if groupType == Const.GROUP_TYPE_ANY then
			ret = lume.iany(ids, func)
		elseif groupType == Const.GROUP_TYPE_ALL then
			ret = lume.iall(ids, func)
		end

		return ret or false
	end
end

function Utils.getValueByPetPrototypeIdAndMergeType(petPrototypeId, mergeType, func)
	if mergeType == Const.MERGE_TYPE_SELF then
		return func(petPrototypeId)
	elseif mergeType == Const.MERGE_TYPE_BASE then
		return func(Utils.getBasePetPrototypeId(petPrototypeId))
	else
		local ids = PetAllPrototypeList[petPrototypeId] or PetBasePrototypeToPrototypeMap[petPrototypeId] or {}
		local values = lume.imap(ids, func)
		local ret

		if mergeType == Const.MERGE_TYPE_MIN then
			ret = lume.min(values)
		elseif mergeType == Const.MERGE_TYPE_MAX then
			ret = lume.max(values)
		elseif mergeType == Const.MERGE_TYPE_SUM then
			ret = lume.sum(values)
		end

		return ret and lume.clamp(ret, Const.NUMBER_MIN, Const.NUMBER_MAX)
	end
end

function Utils.checkHasGender(petPrototypeId)
	petPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

	local ppdd = PetPrototypeData[petPrototypeId]
	local noGenderRatio = ppdd and ppdd.genderRatio and ppdd.genderRatio[0]

	return not ToBool(noGenderRatio)
end

function Utils.getPetFormCollectEntryId(player, petPrototypeId)
	local collectCount = player.petHandbookMap:getFormCatchedCount(nil, petPrototypeId, true)

	return Utils.getPetFormCollectEntryIdByCount(petPrototypeId, collectCount)
end

function Utils.getPetFormCollectEntryIdByCount(petPrototypeId, collectCount)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local padd = PetAvatarData[basePetPrototypeId] and PetAvatarData[basePetPrototypeId][0]

	if padd == nil then
		return
	end

	local entryList = padd.collectEntryList

	if not entryList or not next(entryList) then
		return
	end

	local collectLevel = lume.clamp(collectCount, 0, #entryList)

	return entryList[collectLevel], collectLevel, #entryList
end

function Utils.getDesiredPetFormAbilityMap(petHandbookMap, petPrototypeId, countryId)
	local desiredFormAbilityMap = {}

	if not petHandbookMap or not petPrototypeId then
		return desiredFormAbilityMap
	end

	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local formPrototypeIds = PetBasePrototypeToPrototypeMap[basePetPrototypeId] or {}

	for _, formPrototypeId in ipairs(formPrototypeIds) do
		local handbookInfo = petHandbookMap[formPrototypeId]

		if (countryId == nil or Utils.getPetCountryId(formPrototypeId) == countryId) and handbookInfo and handbookInfo:isCatched() then
			local avatarData = PetAvatarData[formPrototypeId]
			local typeZeroData = avatarData and avatarData[0]
			local abilityId = typeZeroData and typeZeroData.ability

			if abilityId and abilityId ~= 0 and AttributeEntryData[abilityId] then
				desiredFormAbilityMap[formPrototypeId] = abilityId
			end
		end
	end

	return desiredFormAbilityMap
end

function Utils.checkHomeObjectEditable(homeTemplateId)
	if not homeTemplateId then
		return false
	end

	if not HomeObjectData[homeTemplateId] then
		return false
	end

	local entType = (HomeObjectData[homeTemplateId] or EMPTY_TABLE).entType or Const.HomelandEntType.Ornament

	if entType == Const.HomelandEntType.Trash then
		return false
	end

	return true
end

function Utils.checkIsServerHomeObject(homeTemplateId)
	if not homeTemplateId then
		return false
	end

	local homeEntInfo = HomeObjectData[homeTemplateId] or {}
	local entType = homeEntInfo.entType or Const.HomelandEntType.Ornament
	local subEntType = homeEntInfo.subEntType or Const.HomelandEntSubType.Normal

	if entType ~= Const.HomelandEntType.Ornament then
		return false
	end

	if subEntType == Const.HomelandEntSubType.HatchBox then
		return false
	end

	return subEntType ~= Const.HomelandEntSubType.Normal
end

function Utils.getHomeCarOrnamentEntClassName(homeTemplateId)
	if not homeTemplateId then
		return nil
	end

	local homeEntInfo = HomeObjectData[homeTemplateId] or {}
	local subEntType = homeEntInfo.subEntType or Const.HomelandEntSubType.Normal

	if subEntType == Const.HomelandEntSubType.Normal then
		return nil
	elseif subEntType == Const.HomelandEntSubType.Vehicle then
		local vehicleInfo = VehicleData[homeEntInfo.refTemplateId] or {}

		if vehicleInfo.vehicleType == "Bench" then
			return "HomeCarBench"
		end

		return nil
	end

	return nil
end

function Utils.getHomeObjectEntClassName(homeTemplateId)
	if not homeTemplateId then
		return nil
	end

	local homeEntInfo = HomeObjectData[homeTemplateId] or {}
	local subEntType = homeEntInfo.subEntType or Const.HomelandEntSubType.Normal

	if subEntType == Const.HomelandEntSubType.Normal then
		return nil
	elseif subEntType == Const.HomelandEntSubType.EnvObj then
		return "HomeEnvObject"
	elseif subEntType == Const.HomelandEntSubType.Vehicle then
		local vehicleInfo = VehicleData[homeEntInfo.refTemplateId] or {}

		if vehicleInfo.vehicleType == "Bench" then
			return "HomeBench"
		end

		return nil
	elseif subEntType == Const.HomelandEntSubType.Npc then
		return "HomeStaticNpc"
	elseif subEntType == Const.HomelandEntSubType.FacilityVehicle then
		return "HomeFacilityVehicle"
	end

	return nil
end

function Utils.getHomeObjectEntProps(homeTemplateId)
	if not homeTemplateId then
		return {}
	end

	local props = {}
	local homeEntInfo = HomeObjectData[homeTemplateId] or {}

	props.templateId = homeEntInfo.refTemplateId

	return props
end

function Utils.getSpaceFurnitureEntClassName(homeTemplateId)
	if not homeTemplateId then
		return nil
	end

	local homeEntInfo = HomeObjectData[homeTemplateId] or {}
	local subEntType = homeEntInfo.subEntType or Const.HomelandEntSubType.Normal

	if subEntType == Const.HomelandEntSubType.Vehicle or subEntType == Const.HomelandEntSubType.FacilityVehicle then
		return "SpaceFurnitureVehicle"
	end

	return "SpaceFurniture"
end

function Utils.getHomePetPuppetTemplateId(petTemplateId)
	local pdd = PetData[petTemplateId]

	if pdd and pdd.homeNpcId then
		return pdd.homeNpcId
	end

	local petPrototypeId = Utils.getPetPetPrototypeId(petTemplateId)
	local templateIds = PetToPuppetCatchMap[petTemplateId]

	if not templateIds then
		return nil
	end

	for _, templateId in ipairs(templateIds) do
		local pdd = PuppetData[templateId]

		if pdd and pdd.petPrototypeId == petPrototypeId then
			return templateId
		end
	end

	return nil
end

function Utils.getHomeObjectFacilityId(homeTemplateId)
	if not homeTemplateId then
		return nil
	end

	local homeEntInfo = HomeObjectData[homeTemplateId] or {}

	return homeEntInfo.facilityId
end

function Utils.checkOperNeedHandle(formulaId)
	local formulaData = HomelandFormulaData[formulaId]
	local produceType = formulaData.type

	if produceType == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		return true
	end

	if produceType == Const.HOMELAND_PRODUCE_TYPE.ENV then
		return true
	end

	return false
end

function Utils.getHomePetTransportCount(petTemplateId)
	local transportCountConfig = HomelandConfigData.transportCountConfig
	local transportLevel = Utils.getHomePetOperLevel(petTemplateId, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT)

	return transportCountConfig[transportLevel] or transportCountConfig[1] or 1
end

function Utils.getHomePetOperLevel(petTemplateId, operId)
	local pdd = PetData[petTemplateId] or {}
	local operInfo = HomelandOperateData[operId] or {}
	local homeAbility = operInfo.homeAbility

	if homeAbility then
		local needAbilityType = operInfo.homeAbility[1]

		if not pdd.homeAbility then
			return 0
		end

		if pdd.homeAbility[needAbilityType] then
			return pdd.homeAbility[needAbilityType]
		end
	end

	return 0
end

function Utils.checkHasPetInTransport(allocation, ornamentId, checkPetId)
	local count = 0

	for petId, allocationInfo in pairs(allocation) do
		if petId ~= checkPetId and allocationInfo.ornamentId == ornamentId and (allocationInfo.opId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT or allocationInfo.opId == Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT) then
			count = count + 1
		end
	end

	return count >= 1
end

function Utils.checkOverHomePetWorkMaxCount(allocation, ornamentId, homeTemplateId, checkPetId)
	local count = 0

	for petId, allocationInfo in pairs(allocation) do
		if petId ~= checkPetId and allocationInfo.ornamentId == ornamentId and not Const.HOMELAND_IGNORE_WORK_TYPE[allocationInfo.opId] then
			count = count + 1
		end
	end

	return count >= Utils.getFacilityMaxPetCount(homeTemplateId)
end

function Utils.getFacilityMaxPetCount(homeTemplateId)
	local homeEntInfo = HomeObjectData[homeTemplateId] or {}

	return homeEntInfo.maxPetCount or 0
end

function Utils.getHomeFacilityPetAllocationInfo(space, petId, ornamentId, petAllocationDict)
	table.clear(petAllocationDict)

	local allocation = space.allocation
	local allocatePets = space.facilityAllocationInfo[ornamentId]
	local curWorkCount = 0
	local curWorkPosIndex = 0

	if allocatePets then
		for _, allocatePetId in ipairs(allocatePets) do
			local petAllocation = space.allocation[allocatePetId]

			if not Const.HOMELAND_IGNORE_WORK_TYPE[petAllocation.opId] then
				local posIndex = petAllocation.posIndex

				petAllocationDict[posIndex] = petAllocation
				curWorkCount = curWorkCount + 1

				if petId == allocatePetId then
					curWorkPosIndex = posIndex
				end
			end
		end
	end

	return curWorkCount, curWorkPosIndex
end

function Utils.checkHomePetStateValid(petInfo, space)
	if not space or not Utils.isHomeland(space.spaceType) then
		return true
	end

	return petInfo:getHomeEventPetStatus(space) == nil
end

function Utils.checkHomeFacilityStateValid(facilityInfo)
	if not facilityInfo then
		return false
	end

	if facilityInfo.formulaId == 0 then
		return false
	end

	if facilityInfo.disable then
		return false
	end

	if facilityInfo.envWorkRatio <= 0 then
		return false
	end

	if facilityInfo.facilityStateInfo and facilityInfo.facilityStateInfo.ptype == 0 then
		return false
	end

	for _, state in pairs(Const.HOMELAND_CHECK_VALID_STATES) do
		if facilityInfo.extraStateMap[state] then
			return false
		end
	end

	return true
end

function Utils.checkHomePetCanDoOperId(petTemplateId, operId)
	if Const.HOMELAND_NO_CHECK_OPERS[operId] then
		return true
	end

	local pdd = PetData[petTemplateId] or {}
	local operInfo = HomelandOperateData[operId]

	if not operInfo then
		return false
	end

	if operInfo.type == Const.HOMELAND_OPERATE_TYPE.TIME then
		return false
	end

	if operInfo.ethnicGroup then
		if pdd.ethnicGroup ~= operInfo.ethnicGroup then
			return false
		end
	elseif operInfo.petPrototype and not table.contains(operInfo.petPrototype, pdd.petPrototypeId) then
		return false
	end

	local homeAbility = operInfo.homeAbility

	if homeAbility then
		local needAbilityType = homeAbility[1]
		local needAbilityLevel = homeAbility[2]

		if not pdd.homeAbility then
			return false
		end

		if pdd.homeAbility[needAbilityType] then
			if operInfo.needLevelFit then
				return needAbilityLevel <= pdd.homeAbility[needAbilityType]
			end

			return true
		end

		return false
	end

	return true
end

function Utils.checkHomeOperateDataValid(operId)
	return Const.HOMELAND_NO_CHECK_OPERS[operId] or HomelandOperateData[operId] ~= nil
end

function Utils.getOperationRequireOpType(operId)
	local operInfo = HomelandOperateData[operId] or {}
	local homeAbility = operInfo.homeAbility

	if homeAbility then
		return Const.HOME_OPER_REQUIRE_TYPE.HomeAbility, homeAbility[1], homeAbility[2]
	end

	return Const.HOME_OPER_REQUIRE_TYPE.None
end

function Utils.checkHasStoreOrnament(space)
	return next(space.storeOrnaments) ~= nil
end

function Utils.getNearestStoreOrnament(space, curPos)
	local minDistance, targetOrnamentId

	for ornamentId, _ in pairs(space.storeOrnaments) do
		local ornamentInfo = space.ornament[ornamentId]
		local ornamentPos = ornamentInfo:getPosition()
		local distance = Vector3.SqrDistance(ornamentPos, curPos)

		if not minDistance or distance < minDistance then
			minDistance = distance
			targetOrnamentId = ornamentId
		end
	end

	return targetOrnamentId
end

function Utils.getPosRotByOrnamentId(ornamentInfo, posIndex, homelandSpace)
	local homeTemplateId = ornamentInfo.homeId
	local ornamentPos = ornamentInfo:getPosition()
	local ornamentRot = ornamentInfo:getRotation()
	local ornamentYaw = ornamentInfo:getYawAngle()

	if homelandSpace then
		local areaId = ornamentInfo.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE
		local areaRotation = homelandSpace:getOrnamentWorldRotation(areaId, Quaternion.identity)
		local areaYaw = areaRotation.eulerAngles[2]

		ornamentPos = homelandSpace:getOrnamentWorldPosition(areaId, ornamentPos)
		ornamentRot = homelandSpace:getOrnamentWorldRotation(areaId, ornamentRot)
		ornamentYaw = ornamentYaw + areaYaw
	end

	if not posIndex or posIndex == 0 then
		posIndex = 1
	end

	local homeObjectData = HomeObjectData[homeTemplateId]
	local attachPos = homeObjectData["attachPoint" .. posIndex]

	attachPos = attachPos or homeObjectData.attachPoint1

	local resultPos = ornamentPos
	local resultYaw = ornamentYaw

	if attachPos then
		local offset = Vector3(attachPos[1], attachPos[2], attachPos[3])

		resultPos = resultPos + ornamentRot * offset
		resultYaw = resultYaw + attachPos[4]
	end

	return resultPos, resultYaw
end

function Utils.isHomeTrashOrnament(homeTemplateId)
	local homeObjectInfo = HomeObjectData[homeTemplateId] or {}

	return homeObjectInfo.entType == Const.HomelandEntType.Trash
end

function Utils.isHomeVehicle(homeTemplateId)
	local homeObjectInfo = HomeObjectData[homeTemplateId] or {}

	return homeObjectInfo.subEntType == Const.HomelandEntSubType.FacilityVehicle
end

function Utils.innerGetPetTimeWorkload(needAbilityLv, petAbilityLv, isPersonalityMatch, functionId)
	if functionId then
		local formulaInfo = FormulaData[functionId]

		if not formulaInfo then
			logger:error("innerGetPetTimeWorkload formula data not found", functionId)

			return 0
		end

		return formulaInfo.formula(Const.HOME_WORKLOAD_ATK, Const.HOME_WORKLOAD_DEF, needAbilityLv, petAbilityLv, isPersonalityMatch and 1 or 0)
	end

	local atkValue = Const.HOME_WORKLOAD_ATK[petAbilityLv]
	local defValue = Const.HOME_WORKLOAD_DEF[needAbilityLv]

	if not atkValue or not defValue then
		logger:error("innerGetPetTimeWorkload invalid ability level", needAbilityLv, petAbilityLv)

		return 0
	end

	local matchRatio = 1

	if isPersonalityMatch then
		matchRatio = 1.2
	end

	local result = (atkValue - defValue) * matchRatio

	return result
end

function Utils.getHomeFacilityMbti(facilityId)
	if not facilityId then
		return nil
	end

	local facilityData = HomelandFacilityData[facilityId] or {}
	local mbti = facilityData.mbti

	if mbti == nil or mbti == "" then
		return nil
	end

	return mbti
end

function Utils.getHomePetFitPersonality(petInfo, facilityId)
	local facilityMbti = Utils.getHomeFacilityMbti(facilityId)

	if facilityMbti and petInfo and petInfo.talentList then
		for _, talentInfo in ipairs(petInfo.talentList) do
			local talentData = PetTalentData[talentInfo.templateId]

			if talentData and talentData.mbti == facilityMbti then
				return talentInfo.templateId
			end
		end
	end

	return 0
end

function Utils.calcHomePetTimeWorkload(petInfo, operId, facilityId, hasFood)
	local operInfo = HomelandOperateData[operId] or {}
	local pdd = PetData[petInfo.templateId] or {}
	local hasFoodRatio = hasFood == false and (HomelandConfigData.noFoodWorkRatio or Const.NoFoodWorkloadRatio) or 1
	local homeAbility = operInfo.homeAbility

	if homeAbility then
		local isPersonalityMatch = Utils.getHomePetFitPersonality(petInfo, facilityId) ~= 0
		local needAbilityLv = operInfo.homeAbility[2]
		local needAbilityType = operInfo.homeAbility[1]
		local petAbilityLv = pdd.homeAbility and pdd.homeAbility[needAbilityType] or 0

		return Utils.innerGetPetTimeWorkload(needAbilityLv, petAbilityLv, isPersonalityMatch, operInfo.functionId) * hasFoodRatio
	end

	return 60 * hasFoodRatio
end

function Utils.calcDefaultHomePetTimeWorkload(operId)
	local operInfo = HomelandOperateData[operId]

	if not operInfo then
		return 60
	end

	local homeAbility = operInfo.homeAbility

	if homeAbility then
		local needAbilityLv = operInfo.homeAbility[2]

		return Utils.innerGetPetTimeWorkload(needAbilityLv, needAbilityLv, nil, operInfo.functionId)
	end

	return 60
end

function Utils.calcTemperatureDiffWorkRatio(diffValue)
	local envDiffWorkRatioInfo = HomelandConfigData.envDiffWorkRatioInfo or {}

	diffValue = math.abs(diffValue)

	if diffValue == 0 then
		return envDiffWorkRatioInfo[1] or 1.2
	elseif diffValue == 1 then
		return envDiffWorkRatioInfo[2] or 0.9
	elseif diffValue == 2 then
		return envDiffWorkRatioInfo[3] or 0.5
	elseif diffValue > 2 then
		return envDiffWorkRatioInfo[4] or 0
	end

	return 1
end

function Utils.calcLightDiffWorkRatio(diffValue)
	local envDiffWorkRatioInfo = HomelandConfigData.envDiffWorkRatioInfo or {}

	diffValue = math.abs(diffValue)
	diffValue = math.clamp(diffValue, 0, 1)

	if diffValue == 0 then
		return envDiffWorkRatioInfo[1] or 1.2
	elseif diffValue == 1 then
		return envDiffWorkRatioInfo[2] or 0.9
	elseif diffValue == 2 then
		return envDiffWorkRatioInfo[3] or 0.5
	elseif diffValue > 2 then
		return envDiffWorkRatioInfo[4] or 0
	end

	return 1
end

function Utils.calcWorkRate(facilityType, opId, workload, formulaId)
	if facilityType == Const.HOMELAND_FACILITY_TYPE.Light or facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate or facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
		return 1
	end

	if facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
		local formulaData = HomelandFormulaData[formulaId]

		return math.min(1, workload / formulaData.unitWorkload)
	end

	local defaultWorkload = Utils.calcDefaultHomePetTimeWorkload(opId)

	if defaultWorkload > 0 then
		return workload / defaultWorkload
	end

	return 1
end

function Utils.checkEnvReqRelated(formulaId, facilityType)
	local formulaInfo = HomelandFormulaData[formulaId]

	if formulaInfo then
		if facilityType == Const.HOMELAND_FACILITY_TYPE.Light then
			if formulaInfo.lightRequire then
				return true
			else
				return false
			end
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate or facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
			if formulaInfo.temperatureRequire then
				return true
			else
				return false
			end
		end
	end

	return false
end

function Utils.getHomePetTimeWorkloadAbilityLevel(operId)
	local operInfo = HomelandOperateData[operId]

	if not operInfo then
		return nil
	end

	local homeAbility = operInfo.homeAbility

	if homeAbility then
		local needAbilityLv = operInfo.homeAbility[2]

		return homeAbility[1], needAbilityLv
	end

	return nil
end

function Utils.getHomeOrnamentCurLevelInfo(homeTemplateId)
	local revertInfo = RevertHomeUpgradeData[homeTemplateId]

	if not revertInfo then
		return nil
	end

	return revertInfo[1], revertInfo[2]
end

function Utils.getHomeOrnamentUpgradeInfo(homeTemplateId)
	local revertInfo = RevertHomeUpgradeData[homeTemplateId]

	if not revertInfo then
		return nil
	end

	return HomelandUpgradeData[revertInfo[1]][revertInfo[2] + 1]
end

function Utils.getHomeItemPrice(itemId)
	local materialId = HomelandItemToMaterialData[itemId]

	if not materialId then
		return nil
	end

	return HomelandMaterialConfigData[materialId].price
end

function Utils.getRefIdByPetPrototypeId(petPrototypeId)
	if not PetData[petPrototypeId] then
		return nil
	end

	return PetData[petPrototypeId].refId or petPrototypeId
end

function Utils.formatAttrDesc(value, type, dontFloor)
	value = value or 0

	if type == 0 then
		return tostring(math.floor(value))
	elseif type == 1 then
		if dontFloor then
			value = Utils.m_customParseFloatPropVal(value * 100)
		else
			value = math.floor(value * 100 + 0.5)
		end

		return tostring(value) .. "%"
	elseif type == 2 then
		return Utils.m_customParseFloatPropVal(value)
	else
		return tostring(value)
	end
end

function Utils.m_customParseFloatPropVal(propValue, excludeZero)
	propValue = propValue or 0

	local intPart = math.floor(propValue)
	local decimalPart = propValue - intPart
	local absDecimal = math.abs(decimalPart)
	local firstDecimal = math.floor(absDecimal * 10)
	local secondDecimal = math.floor(absDecimal * 100) % 10
	local finalFirstDecimal = firstDecimal

	if firstDecimal == 9 and secondDecimal >= 5 then
		finalFirstDecimal = 9
	elseif secondDecimal >= 5 then
		finalFirstDecimal = finalFirstDecimal + 1

		if finalFirstDecimal == 10 then
			intPart = intPart + (decimalPart >= 0 and 1 or -1)
			finalFirstDecimal = 0
		end
	end

	local sign = decimalPart < 0 and "-" or ""
	local result

	if excludeZero == true and finalFirstDecimal == 0 then
		result = string.format("%s%d", sign, math.abs(intPart))
	else
		result = string.format("%s%d.%d", sign, math.abs(intPart), finalFirstDecimal)
	end

	if sign == "-" and intPart == 0 then
		result = "-" .. result:sub(2)
	end

	return result
end

function Utils.canLevelBreakthrough(petId)
	local petInfo = pg.me:getPetInfo(petId)

	return petInfo.needBreakthrough
end

function Utils.npcShowForbidCatchReason(ent)
	local forbidCatchReason = ent:getConfigData().forbidCatchReason

	return forbidCatchReason ~= nil
end

function Utils.getPetInControlConfigScaleByTemplateId(templateId)
	local templateData = templateId and PetData[templateId]
	local scale = 1

	if templateData then
		local scaleRange = templateData.modelScaleRange

		scale = scaleRange and scaleRange[3] or 1
	end

	return scale
end

function Utils.getPetCapsuleDataByTemplateId(templateId)
	local templateData = templateId and PetData[templateId]
	local rigidbodyId = templateData.rigidbody

	if not rigidbodyId then
		return
	end

	local rigidbodyData = RigidbodyData[rigidbodyId]

	if not rigidbodyData then
		return
	end

	local radius = ToBool(rigidbodyData.radius) and rigidbodyData.radius or 0.1
	local height = ToBool(rigidbodyData.height) and rigidbodyData.height or 0.1
	local centerOffset = ToBool(rigidbodyData.center) and rigidbodyData.center[2] or height * 0.5

	return radius, height, centerOffset
end

function Utils.getBreakthroughItems(petTemplateId)
	local pdd = PetData[petTemplateId]

	if not pdd then
		return nil
	end

	local pfdd = PetFamilyData[pdd.ethnicGroup]

	return pfdd and pfdd.breakthroughItems
end

function Utils.petCanChangeForm(player, sourceFormId, targetFormId)
	if not player or not player.petHandbookMap then
		return false
	end

	if not sourceFormId then
		return false
	end

	local petHandbookMap = player.petHandbookMap
	local basePetPrototypeId = Utils.getBasePetPrototypeId(sourceFormId)

	if not basePetPrototypeId then
		return false
	end

	local ids = PetBasePrototypeToPrototypeMap[basePetPrototypeId] or {}

	for index, id in ipairs(ids) do
		if id ~= sourceFormId and (not targetFormId or targetFormId == id) and PetFormChangeData[id] and petHandbookMap:isCatched(id, Const.GROUP_TYPE_SELF) then
			return id
		end
	end

	return false
end

function Utils.getPetChangeTargetId(player, sourceFormId, isMagic)
	if not player or not player.petHandbookMap then
		return false
	end

	if not sourceFormId then
		return false
	end

	local petHandbookMap = player.petHandbookMap
	local basePetPrototypeId = Utils.getBasePetPrototypeId(sourceFormId)

	if not basePetPrototypeId then
		return false
	end

	local noDemonicId
	local ids = PetBasePrototypeToPrototypeMap[basePetPrototypeId] or {}

	for index, id in ipairs(ids) do
		if id ~= sourceFormId and PetFormChangeData[id] and petHandbookMap:isCatched(id, Const.GROUP_TYPE_SELF) then
			if isMagic == false then
				return id
			elseif Utils.petHasDemonicAvatar(id) then
				return id
			elseif noDemonicId == nil then
				noDemonicId = id
			end
		end
	end

	if noDemonicId then
		return noDemonicId
	end

	return false
end

function Utils.petHasDemonicAvatar(petId)
	local pAvatarData = PetAvatarData[petId]

	if pAvatarData and pAvatarData[16] then
		return true
	else
		return false
	end
end

function Utils.isChestVisible(player, chestEntity)
	if not player or not chestEntity or not chestEntity.isChest then
		return false
	end

	if chestEntity:getChestType() == Const.ChestType.HomeGift then
		return not string.isNilOrEmpty(chestEntity.space and chestEntity.space.giftEventInsId)
	elseif Utils.openChestLimit(player, chestEntity) then
		return false
	elseif chestEntity.chestVisibleType == Const.ChestVisibleType.Owner then
		return player.id == chestEntity.ownerId
	end

	return true
end

function Utils.isCollectItemVisible(player, collectItemEntity)
	if not player or not collectItemEntity or not collectItemEntity.isCollectItem then
		return false
	end

	if Utils.openCollectItemLimit(player, collectItemEntity) then
		return false
	elseif collectItemEntity.collectItemVisibleType == Const.CollectItemVisibleType.Owner then
		return player.id == collectItemEntity.ownerId
	end

	return true
end

function Utils.getCharacterWeight(pcd, targetLabel)
	targetLabel = targetLabel or 0

	local baseWeight = pcd.weight or 0

	if pcd.labelWeightFactor then
		for k, v in pairs(pcd.labelWeightFactor) do
			if bit.band(targetLabel, k) == k then
				baseWeight = baseWeight * v
			end
		end
	end

	return baseWeight
end

function Utils.getValidCharacterList(petInfoOrPuppet, excludeCur)
	local res = {}

	if not Utils.isPuppet(petInfoOrPuppet) and not Utils.isPetInfoType(petInfoOrPuppet) then
		return res
	end

	local characterInfo = petInfoOrPuppet.characterInfo
	local configData = petInfoOrPuppet.getConfigData and petInfoOrPuppet:getConfigData() or nil

	if not configData or not characterInfo then
		return res
	end

	local excludeIds = excludeCur and {
		characterInfo.curCharacter
	} or {}

	return Utils.getValidCharacterListByConfig(configData, excludeIds, petInfoOrPuppet.label)
end

function Utils.getValidCharacterListByConfig(configData, excludeIds, targetLabel)
	targetLabel = targetLabel or configData.label or 0

	local res = {}

	for _, characterId in ipairs(configData.feature or EMPTY_TABLE) do
		local pcd = PetCharacterData[characterId]

		if pcd ~= nil then
			local valid = true

			if pcd.stage and pcd.stage > (configData.stage or 0) then
				valid = false
			end

			if excludeIds and lume.find(excludeIds, characterId) then
				valid = false
			end

			if valid == true then
				res[#res + 1] = characterId
			end
		end
	end

	return res
end

function Utils.getPropDisplayAttrName(index, isDisplayIndex)
	if isDisplayIndex then
		local pdpdd = PetDetailPropertyData[index] and PetDetailPropertyData[index][Const.PROP_TYPE_BASE]

		return pdpdd and pdpdd.displayProp
	else
		local pbpan = PetBasePropAttrNames[index]

		return pbpan and pbpan.displayProp
	end
end

function Utils.getPropSpeciesAttrName(index)
	return PetBasePropAttrNames[index] and PetBasePropAttrNames[index].speciesProp
end

function Utils.getPropFinalAttrName(index)
	return PetBasePropAttrNames[index] and PetBasePropAttrNames[index].finalProp
end

function Utils.getBasePropIndex(propName)
	for index, info in pairs(PetBasePropAttrNames) do
		if info.finalProp == propName then
			return index
		end
	end

	return 0
end

function Utils.getBasePropDisplayIndex(index)
	return PetBasePropAttrNames[index] and PetBasePropAttrNames[index].displayIndex or 0
end

function Utils.isAIEntity(entity)
	if Utils.isPuppet(entity) or Utils.isBot(entity) then
		return true
	end

	if Utils.isPet(entity) then
		local player = entity:getMasterEntity()

		if player and player.controlState ~= Const.CONTROL_STATE_CONTROL then
			return true
		end
	end

	return false
end

function Utils.isSupportPet(petEntity)
	if not Utils.isPet(petEntity) then
		return false
	end

	local space = petEntity.space

	return space and space.supportPetMode > 0 and petEntity.partnerIndex > space.battleMode
end

function Utils.isRobEggSpaceEgg(entity)
	return entity and entity.isRobSpaceEgg
end

function Utils.isResourceBox(entity)
	return entity.isResourceBox
end

function Utils.isGrabEggTransfer(entity)
	return entity.isGrabEggTransfer
end

function Utils.isEggShip(entity)
	return entity.isEggShip
end

function Utils.isNotEnableTopLogo(entity)
	if not entity then
		return true
	end

	local actorType = entity.actorType

	if actorType == Const.ACTOR_TYPE_PUPPET and entity.isHomePet then
		return true
	end

	if actorType == Const.ACTOR_TYPE_CREATION then
		return true
	end

	if entity.isEggShip then
		return true
	end
end

function Utils.IsPuppetAll(entity)
	local actorType = entity.actorType

	if actorType == Const.ACTOR_TYPE_PUPPET then
		return true
	end

	if entity.virtualTemplateActorType == Const.ACTOR_TYPE_PUPPET then
		return true
	end

	return false
end

local _topLogoCombat = {
	[Const.ACTOR_TYPE_PET] = true,
	[Const.ACTOR_TYPE_PLAYER] = true,
	[Const.ACTOR_TYPE_CREATION] = true
}

function Utils.isTopLogoCombat(entity)
	local actorType = entity.actorType

	return _topLogoCombat[actorType]
end

function Utils.checkHasOutput(facilityInfo)
	for itemId, itemNum in pairs(facilityInfo.outputMap) do
		if itemNum > 0 then
			return true
		end
	end

	if facilityInfo.specialOutputMap then
		for _, info in pairs(facilityInfo.specialOutputMap) do
			if info.num > 0 then
				return true
			end
		end
	end

	return false
end

function Utils.checkReturnHomeProduceCost(facilityInfo)
	local facilityState = facilityInfo.facilityState
	local formulaId = facilityInfo.formulaId

	if formulaId == 0 then
		return false
	end

	if facilityState == 0 then
		return false
	end

	local formulaData = HomelandFormulaData[formulaId]

	if not formulaData then
		return false
	end

	if facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.UNDER_CONSUME] then
		return false
	end

	local preOperateList = formulaData.preOperateList or {}
	local postOperateList = formulaData.postOperateList or {}

	for i = 1, #preOperateList do
		local opId = preOperateList[i]
		local operationInfo = HomelandOperateData[opId]

		if operationInfo.itemConsume then
			return true
		end

		if opId == facilityState then
			return false
		end
	end

	for i = 1, #postOperateList do
		local opId = postOperateList[i]
		local operationInfo = HomelandOperateData[opId]

		if operationInfo.itemConsume then
			return true
		end

		if opId == facilityState then
			return false
		end
	end

	return false
end

function Utils.isHomeEnvFacility(homeTemplateId)
	local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)

	if not facilityId then
		return false
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	return facilityData.facilityType and Const.HOMELAND_ENV_FACILITY_TYPES[facilityData.facilityType]
end

function Utils.isHomeHatchBox(homeTemplateId)
	local Const = require("Common.Const.Const")
	local homeObjCfg = homeTemplateId and HomeObjectData[homeTemplateId]

	if homeObjCfg and homeObjCfg.subEntType == Const.HomelandEntSubType.HatchBox then
		return true
	end

	return false
end

function Utils.getHomeFacilityType(homeTemplateId)
	local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)

	if not facilityId then
		return nil
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	return facilityData.facilityType
end

function Utils.isHomeEnvOrnament(homeTemplateId)
	local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)

	if not facilityId then
		return false
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	return facilityData.facilityType and Const.HOMELAND_ENV_ORNAMENT_TYPES[facilityData.facilityType]
end

function Utils.isHomeLinkOrnament(homeTemplateId)
	local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)

	if not facilityId then
		return false
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	return Utils.isHomeLinkFacilityType(facilityData.facilityType)
end

function Utils.isHomeLinkFacilityType(facilityType)
	return facilityType == Const.HOMELAND_FACILITY_TYPE.Electric or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch
end

function Utils.getFacilityCurWorkRate(facilityInfo, homeTemplateId, ornamentId, statePaused)
	local facilityState = facilityInfo.facilityState
	local facilityStateInfo = facilityInfo.facilityStateInfo
	local relatedPets = pg.space.facilityAllocationInfo[ornamentId]
	local workloadRate = 0

	if statePaused then
		workloadRate = 0
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		local curWorkload = 0

		if relatedPets then
			for _, petId in ipairs(relatedPets) do
				local allocation = pg.me.space.allocation[petId]

				if allocation.opId == facilityState then
					curWorkload = curWorkload + allocation.workload
				end
			end
		end

		local homeEntInfo = HomeObjectData[homeTemplateId] or {}
		local maxPetCount = homeEntInfo.maxPetCount or 0

		workloadRate = curWorkload / (Utils.calcDefaultHomePetTimeWorkload(facilityState) * maxPetCount)
	else
		workloadRate = 1
	end

	workloadRate = workloadRate * facilityInfo.envWorkRatio

	return workloadRate
end

function Utils.checkNeedEnvRequire(facilityInfo, customOpId)
	local formulaId = facilityInfo.formulaId

	if formulaId == 0 then
		return false
	end

	local formulaData = HomelandFormulaData[formulaId]

	if formulaData and formulaData.envRequireOperate then
		local curOpId = customOpId or facilityInfo.facilityState

		if curOpId ~= formulaData.envRequireOperate then
			return false
		end
	end

	return true
end

function Utils.checkIsElectricReqType(facilityType, electricMode)
	if facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq then
		return true
	end

	if facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		return electricMode or false
	end

	return false
end

function Utils.getFinalEnvWorkRatio(facilityInfo, customOpId)
	if not Utils.checkNeedEnvRequire(facilityInfo, customOpId) then
		return 1
	end

	return facilityInfo.baseEnvWorkRatio
end

function Utils.serializePetExportId(petInfo)
	return Utils.encodeToStr({
		id = petInfo.id,
		templateId = petInfo.templateId,
		label = petInfo.label,
		gender = petInfo.gender
	})
end

function Utils.deserializePetExportId(petId)
	return Utils.decodeFromStr(petId)
end

function Utils.checkPort(host, port, timeout)
	timeout = timeout or 0.1

	local socket = require("socket")
	local client = socket.tcp()

	client:settimeout(timeout)

	local result, err = client:connect(host, port)

	client:close()

	return result, err
end

function Utils.getCombatPetMaxNum(combatMode)
	return combatMode == Const.COMBAT_TYPE_DEFAULT and Const.PET_PREPARE_NUM_LIMIT or combatMode
end

function Utils.checkIsInTown(entity)
	return entity.space and Utils.getSpaceType(entity.space.sceneId) == Const.SPACE_TYPE_TOWN
end

function Utils.getDebugCatchInfo(player, ent, itemId, fromBehind, effectiveFinalProb, evaluatedContext)
	local context = evaluatedContext

	if not context then
		local CatchProbContext = require("Common.Utils.CatchProbContext")

		if pg.component == "game" then
			context = CatchProbContext.get(player, ent, itemId, fromBehind)
		else
			context = CatchProbContext.clientGet(ent, itemId)
		end
	end

	local catchInfo = {}

	catchInfo.valid = context.valid
	catchInfo.finalProb = effectiveFinalProb ~= nil and effectiveFinalProb or context.finalProb
	catchInfo.canCatch = context.canCatch
	catchInfo.cantCatchDebugInfo = context.cantCatchDebugInfo
	catchInfo.showCantCatchKey = context.canCatch ~= true and context.cantCatchReason or ""
	catchInfo.minMaxReason = context.minMaxReason
	catchInfo.detailProb = context:dump(effectiveFinalProb)

	local copyNames = {
		"baseProb",
		"ballProb",
		"levelStateProb",
		"fromBehindProb",
		"hpStateProb",
		"entTagKey",
		"entTagProb",
		"aiStateKey",
		"aiStateProb",
		"aiTagKey",
		"aiTagProb",
		"breakProb",
		"buffStateKey",
		"buffStateProb",
		"affinityKey",
		"affinityProb"
	}

	for _, name in ipairs(copyNames) do
		if context[name] then
			if string.endsWith(name, "Key") and CatchDisplayData[context[name]] then
				catchInfo[name] = string.format("%s %s", context[name], pg.getLocalizationText(CatchDisplayData[context[name]].catchDisplayText))
			else
				catchInfo[name] = context[name]
			end
		end
	end

	catchInfo.isAffinity = context.isAffinity
	catchInfo.affinityReason = context.affinityReason

	if player.actorCombatAttribute then
		catchInfo.baseCatchRatio = player.actorCombatAttribute:getAttribValue(AttributeConst.base_catch_ratio)
		catchInfo.maxSkillCatchLevel = player.actorCombatAttribute:getAttribValue(AttributeConst.max_skill_catch_level)
	end

	return catchInfo
end

function Utils.genBodyEntryId(type, id)
	assert(id < 10000, "id must be less than 10000")

	return type * 10000 + id
end

function Utils.parseBodyEntryId(bodyEntryId)
	return math.floor(bodyEntryId / 10000), bodyEntryId % 10000
end

function Utils.randomPetBodyEntries(petTemplateId, forceRandGroupId, forceBodyEntriesInfo)
	return {}
end

function Utils.randomPuppetBodyEntries(puppetTemplateId, forceRandGroupId, forceBodyEntriesInfo)
	local pdd = PuppetData[puppetTemplateId]
	local randGroupId = forceRandGroupId or pdd and pdd.randomAppearanceGroup

	if not randGroupId then
		return {}
	end

	return Utils.randomBodyEntries(pdd.petPrototypeId, randGroupId, forceBodyEntriesInfo)
end

function Utils.randomBodyEntries(petPrototypeId, randGroupId, forceBodyEntriesInfo)
	local pbedd = PetBodyEntryData[petPrototypeId]
	local bodyEntries = {}

	if pbedd then
		for type, typeData in pairs(pbedd) do
			if forceBodyEntriesInfo and forceBodyEntriesInfo[type] then
				local id = forceBodyEntriesInfo[type]

				if typeData[id] then
					bodyEntries[#bodyEntries + 1] = Utils.genBodyEntryId(type, id)
				else
					logger:error("Utils.randomBodyEntries forceBodyEntriesInfo[%s] not found, id=%s, petPrototypeId=%s", type, id, petPrototypeId)
				end
			else
				local idSelectTable = lume.mapToList(typeData)
				local idWeightTable = Utils.getProportionList(Const.EXTRACT_MODE_PROPORTION_OVERFLOW, idSelectTable, function(v)
					return v[2].notBreedProbs[randGroupId] or 0
				end)
				local idSelectIndex = lume.weightedchoice(idWeightTable)
				local id = idSelectTable[idSelectIndex] and idSelectTable[idSelectIndex][1]

				if id then
					bodyEntries[#bodyEntries + 1] = Utils.genBodyEntryId(type, id)
				end
			end
		end
	end

	return bodyEntries
end

function Utils.unpackSocialPlayerInfo(socialPlayerInfo, selfUid)
	local selfInfo, otherInfo, otherUid

	for uid, info in pairs(socialPlayerInfo) do
		if uid == selfUid or selfUid == nil then
			selfUid = uid
			selfInfo = info
		else
			otherUid = uid
			otherInfo = info
		end
	end

	return selfInfo, otherInfo, otherUid
end

function Utils.checkPetBreed(petInfo1, petInfo2)
	if not petInfo1 or not petInfo2 then
		return false, NoticeDef.ERROR_INVALID_TARGET
	end

	local PetInfo = require("CustomTypes.PetInfo")
	local queryInfo1 = PetInfo.getBreedQueryInfo(petInfo1)
	local queryInfo2 = PetInfo.getBreedQueryInfo(petInfo2)

	return PetInfo.checkBreedByQuery(petInfo1, queryInfo2) and PetInfo.checkBreedByQuery(petInfo2, queryInfo1)
end

function Utils.getAreaDayRefreshTime()
	local Const = require("Common.Const.Const")

	if pg.component == "game" then
		local GameServerRepo = require("Core.Server.GameServerRepo")

		if GameServerRepo.areaNo == Const.SERVER_AREANO.CN then
			return SysConfigData.refreshTimestampCN
		elseif GameServerRepo.areaNo == Const.SERVER_AREANO.US then
			return SysConfigData.refreshTimestampUS
		elseif GameServerRepo.areaNo == Const.SERVER_AREANO.AP then
			return SysConfigData.refreshTimestampAP
		elseif GameServerRepo.areaNo == Const.SERVER_AREANO.EN then
			return SysConfigData.refreshTimestampEU
		else
			return SysConfigData.refreshTimestampCN
		end
	else
		if pg.me == nil then
			return SysConfigData.refreshTimestampCN
		end

		if pg.me.serverArea == Const.SERVER_AREANO.CN then
			return SysConfigData.refreshTimestampCN
		elseif pg.me.serverArea == Const.SERVER_AREANO.US then
			return SysConfigData.refreshTimestampUS
		elseif pg.me.serverArea == Const.SERVER_AREANO.AP then
			return SysConfigData.refreshTimestampAP
		elseif pg.me.serverArea == Const.SERVER_AREANO.EN then
			return SysConfigData.refreshTimestampEU
		else
			return SysConfigData.refreshTimestampCN
		end
	end
end

function Utils.getSecondsAreaDayStart()
	return Utils.getAreaDayRefreshTime() * 60 * 60
end

function Utils.getDayRefreshTime()
	local Const = require("Common.Const.Const")
	local areaNo = Utils.getServerArea()

	if pg.component == "client" then
		if areaNo == Const.SERVER_AREANO.CN then
			return SysConfigData.refreshTimestampCN
		elseif areaNo == Const.SERVER_AREANO.US then
			return SysConfigData.refreshTimestampUS
		elseif areaNo == Const.SERVER_AREANO.AP then
			return SysConfigData.refreshTimestampAP
		elseif areaNo == Const.SERVER_AREANO.EN then
			return SysConfigData.refreshTimestampEU
		else
			return SysConfigData.refreshTimestampCN
		end
	end

	local timezone_offset = Const.TIME_AREA_OFFSET_FROM_UTCO[areaNo]

	if areaNo == Const.SERVER_AREANO.CN then
		return SysConfigData.refreshTimestampCN
	elseif areaNo == Const.SERVER_AREANO.US then
		local refreshTm = (SysConfigData.refreshTimestampUS - timezone_offset + 24) % 24

		return refreshTm
	elseif areaNo == Const.SERVER_AREANO.AP then
		local refreshTm = (SysConfigData.refreshTimestampAP - timezone_offset + 24) % 24

		return refreshTm
	elseif areaNo == Const.SERVER_AREANO.EN then
		local refreshTm = (SysConfigData.refreshTimestampEU - timezone_offset + 24) % 24

		return refreshTm
	else
		return SysConfigData.refreshTimestampCN
	end
end

function Utils.getWeekRefreshDayOfWeek()
	local Const = require("Common.Const.Const")
	local areaNo = Utils.getServerArea()

	if pg.component == "client" or areaNo == Const.SERVER_AREANO.CN then
		return 1
	end

	local timezone_offset = Const.TIME_AREA_OFFSET_FROM_UTCO[areaNo] or 0
	local refreshTimestamp = Utils.getAreaDayRefreshTime()
	local dayOffset = math.floor((refreshTimestamp - timezone_offset) / 24)

	return (1 + dayOffset) % 7
end

function Utils.getSecondsDayStart()
	return Utils.getDayRefreshTime() * 60 * 60
end

function Utils.getMidnightRefreshTime()
	local Const = require("Common.Const.Const")
	local areaNo = Utils.getServerArea()

	if areaNo == Const.SERVER_AREANO.CN then
		return 0
	else
		local timezone_offset = Const.TIME_AREA_OFFSET_FROM_UTCO[areaNo]

		return (0 - timezone_offset + 24) % 24
	end
end

function Utils.getSecondsMidnightStart()
	return Utils.getMidnightRefreshTime() * 60 * 60
end

function Utils.getEventTimeConfig(eventId)
	local eventData = GameEventData[eventId] or {}

	return {
		tabStartDayTime = Utils.getConfigTimeOfArea(eventData, "tabStartDayTime"),
		tabEndDayTime = Utils.getConfigTimeOfArea(eventData, "tabEndDayTime")
	}
end

function Utils.isInRogueSpace(entity)
	local spaceType = entity and entity.space and entity.space.spaceType

	return spaceType == Const.SPACE_TYPE_CATCH_ROGUE_DUNGEON
end

function Utils.isOverseas()
	if not Utils.checkClient() then
		local GameServerRepo = require("Core.Server.GameServerRepo")

		return GameServerRepo.areaNo ~= Const.SERVER_AREANO.CN
	elseif pg.me then
		return pg.me.serverArea ~= Const.SERVER_AREANO.CN
	else
		return ClientConfigAppCountry ~= "cn"
	end
end

function Utils.getServerArea()
	if not Utils.checkClient() then
		local GameServerRepo = require("Core.Server.GameServerRepo")

		return GameServerRepo.areaNo
	else
		if pg.me and pg.me.serverArea then
			return pg.me.serverArea
		end

		for areaNo, areaName in pairs(Const.SERVER_AREANO_NAME) do
			if areaName == ClientConfigAppCountry then
				return areaNo
			end
		end

		if ClientConfigAppCountry == "cn" then
			return Const.SERVER_AREANO.CN
		end

		return Const.SERVER_AREANO.EN
	end
end

function Utils.getClass(classId)
	if classId == nil or classId == "" then
		return nil
	end

	return tonumber(string.sub(classId, 1, 7))
end

function Utils.getClassKey(classId)
	if classId == "" then
		return nil
	end

	return string.sub(classId, 2, 9)
end

function Utils.getConfigTimeOfArea(tbRow, columnName)
	local areaNo

	if pg.component == "game" then
		local GameServerRepo = require("Core.Server.GameServerRepo")

		areaNo = GameServerRepo.areaNo
	else
		areaNo = pg.me.serverArea
	end

	if tbRow == nil or columnName == "" or not Utils.isTable(tbRow) then
		return nil
	end

	local data = tbRow[columnName]

	if data == nil then
		return nil
	end

	return data[tostring(areaNo)]
end

function Utils.getConfigTimeOfAreaByData(data, timeRefId)
	if timeRefId and timeRefId ~= 0 then
		local commonTimeConfig = CommonTimeConfigData[timeRefId]

		if commonTimeConfig == nil or commonTimeConfig.time == nil then
			logger:error("Utils.getConfigTimeOfAreaByData common time config not found, timeRefId=%s", tostring(timeRefId))

			return nil
		end

		data = commonTimeConfig.time
	end

	if not data then
		return nil
	end

	local areaNo

	if pg.component == "game" then
		local GameServerRepo = require("Core.Server.GameServerRepo")

		areaNo = GameServerRepo.areaNo
	else
		areaNo = pg.me.serverArea
	end

	return data[tostring(areaNo)]
end

function Utils.isTable(value)
	local t = type(value)

	return t == "table" or t == "userdata"
end

function Utils._buildSeasonStageInfo(stageConfig, startTime, endTime)
	if not stageConfig then
		return nil
	end

	return {
		seasonId = stageConfig.seasonId,
		stageId = stageConfig.stageId,
		seasonCoinId = stageConfig.seasonCoinId,
		stageName = stageConfig.name,
		seasonTagImage = stageConfig.seasonTagImg,
		seasonTagIcon = stageConfig.seasonTagNo,
		seasonTagTextId = stageConfig.seasonTagText,
		startTime = startTime,
		endTime = endTime
	}
end

local _lastSeasonStageInfo = Utils._buildSeasonStageInfo(SeasonStageTimelineData[1])

function Utils.getCurrentSeasonStage(now)
	now = now or Time.getSecond()

	local latestPastConfig, latestPastEndTime, latestPastStartTime

	for _, stageConfig in ipairs(SeasonStageTimelineData) do
		local startTime = Utils.getConfigTimeOfArea(stageConfig, "startDayTime")
		local endTime = Utils.getConfigTimeOfArea(stageConfig, "endDayTime")

		if startTime and endTime then
			if startTime <= now and now < endTime then
				_lastSeasonStageInfo = Utils._buildSeasonStageInfo(stageConfig, startTime, endTime)

				return _lastSeasonStageInfo
			end

			if startTime <= now and (latestPastStartTime == nil or latestPastStartTime < startTime) then
				latestPastStartTime = startTime
				latestPastEndTime = endTime
				latestPastConfig = stageConfig
			end
		end
	end

	return Utils._buildSeasonStageInfo(latestPastConfig, latestPastStartTime, latestPastEndTime) or _lastSeasonStageInfo
end

function Utils.getSeasonStageInfo(seasonId, stageId)
	for _, stageConfig in ipairs(SeasonStageTimelineData) do
		if stageConfig.seasonId == seasonId and stageConfig.stageId == stageId then
			local startTime = Utils.getConfigTimeOfArea(stageConfig, "startDayTime")
			local endTime = Utils.getConfigTimeOfArea(stageConfig, "endDayTime")

			return Utils._buildSeasonStageInfo(stageConfig, startTime, endTime)
		end
	end

	return nil
end

function Utils.getSeasonTimeRange(seasonId)
	local seasonStartTime, seasonEndTime

	for _, stageConfig in ipairs(SeasonStageTimelineData) do
		if stageConfig.seasonId == seasonId then
			local stageStartTime = Utils.getConfigTimeOfArea(stageConfig, "startDayTime")
			local stageEndTime = Utils.getConfigTimeOfArea(stageConfig, "endDayTime")

			if stageStartTime and (not seasonStartTime or stageStartTime < seasonStartTime) then
				seasonStartTime = stageStartTime
			end

			if stageEndTime and (not seasonEndTime or seasonEndTime < stageEndTime) then
				seasonEndTime = stageEndTime
			end
		end
	end

	return seasonStartTime, seasonEndTime
end

function Utils.isSeasonStageInfoActive(seasonStageInfo, now)
	if not seasonStageInfo or not seasonStageInfo.startTime or not seasonStageInfo.endTime then
		return false
	end

	now = now or Time.getSecond()

	return now >= seasonStageInfo.startTime and now < seasonStageInfo.endTime
end

function Utils.isSeasonStageActive(seasonId, stageId, now)
	local seasonStageInfo = Utils.getSeasonStageInfo(seasonId, stageId)

	return Utils.isSeasonStageInfoActive(seasonStageInfo, now)
end

function Utils.getSeasonWeek(seasonStartTime, specifiedTime)
	if not seasonStartTime then
		return nil
	end

	specifiedTime = specifiedTime or Time.getSecond()

	if specifiedTime < seasonStartTime then
		return 0
	end

	return math.floor((specifiedTime - seasonStartTime) / Const.SECONDS_ONE_WEEK) + 1
end

function Utils.getCurrentSeasonWeek(seasonStartTime)
	return Utils.getSeasonWeek(seasonStartTime, Time.getSecond())
end

function Utils.packCaptureInfo(entId, catchResult, petInfoDict, extraInfo)
	return {
		entId,
		catchResult,
		petInfoDict,
		extraInfo
	}
end

function Utils.unpackCaptureInfo(captureInfo)
	if not captureInfo then
		return nil
	end

	return unpack(captureInfo, 1, 4)
end

function Utils.genPhotographyStudioUniqueId(rawId)
	rawId = rawId:gsub("[^%w]", function()
		return RandomString.gen(1)
	end)

	return string.format("photographystudio_%s", rawId)
end

function Utils.genPhotoPresetUniqueId(isOfficial, rawId)
	rawId = rawId:gsub("[^%w]", function()
		return RandomString.gen(1)
	end)

	if isOfficial then
		return string.format("official_%s", rawId)
	else
		return string.format("user_%s", rawId)
	end
end

function Utils.parsePhotoPresetUniqueId(presetId)
	if string.startsWith(presetId, "official_") then
		return true, string.sub(presetId, 10)
	elseif string.startsWith(presetId, "user_") then
		return false, string.sub(presetId, 6)
	else
		return nil, nil
	end
end

function Utils.genPhotoPresetPicId(rawId)
	return string.format("presetPic_%s_%s", pg.me.uid, rawId)
end

function Utils.genPresetAvatarPicId(rawId, useId)
	return string.format("presetAvatar_%s_%s", useId, rawId)
end

function Utils.captureAndCheckPhoto(sceneType, callback, needCheck, ...)
	local captureArgs = {
		...
	}

	if needCheck == nil then
		needCheck = true
	elseif type(needCheck) ~= "boolean" then
		table.insert(captureArgs, 1, needCheck)

		needCheck = true
	end

	local getCheckParams

	if type(captureArgs[1]) == "function" then
		getCheckParams = table.remove(captureArgs, 1)
	end

	pg.global.mobileCameraMgr:CaptureScreenDelaySave(function(sprite)
		if not needCheck then
			if callback then
				callback(sprite, nil, true, nil)
			end

			return
		end

		if not pg.me then
			if callback then
				callback(sprite, nil, true, nil)
			end

			return
		end

		pg.me:addPhotoImgSprite(sprite, function(key, success, imgUrl)
			if not success or not imgUrl or imgUrl == "" then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("captureAndCheckPhoto addPicture failed, key=%s", tostring(key))
				end

				pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

				if callback then
					callback(sprite, nil, false, key)
				end

				return
			end

			local checkParams = sceneType

			if getCheckParams then
				local extraParams = getCheckParams(sprite)

				if extraParams then
					checkParams = {}

					if Utils.isTable(sceneType) then
						for k, v in pairs(sceneType) do
							checkParams[k] = v
						end
					else
						checkParams.CheckType = sceneType
					end

					for k, v in pairs(extraParams) do
						checkParams[k] = v
					end
				end
			end

			Utils.checkPhoto(checkParams, imgUrl, function(pass)
				if callback then
					callback(sprite, pass and imgUrl or nil, pass, key)
				end
			end)
		end)
	end, unpack(captureArgs))
end

function Utils.checkPhoto(sceneType, imgUrl, callback)
	local params = {}
	local checkType = sceneType or Const.PhotoCheckScene.Share

	if Utils.isTable(checkType) then
		for k, v in pairs(checkType) do
			if k ~= "Type" and k ~= "type" and k ~= "checkType" then
				params[k] = v
			end
		end

		checkType = params.CheckType or params.checkType or checkType.Type or checkType.type or Const.PhotoCheckScene.Share
	end

	params.CheckType = params.CheckType or checkType

	pg.me:serverMsg("RPC_CS_TakePhoto", params, imgUrl, function(pass)
		if pass then
			if callback then
				callback(true)
			end
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_FAIL"))

			if callback then
				callback(false)
			end
		end
	end)
end

function Utils.uploadPhotoToOSS(imgUrl, localPhotoId, callback)
	if not pg.me or string.isNilOrEmpty(imgUrl) or localPhotoId == nil then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_CheckPhotoUploadLimit", function(result, failureReason)
		if result ~= NoticeDef.SUCCESS then
			if callback then
				callback(false, failureReason)
			end

			return
		end

		Utils.checkPhoto({
			CheckType = Const.PhotoCheckScene.OSS,
			localPhotoId = tostring(localPhotoId)
		}, imgUrl, callback)
	end)
end

function Utils.genKVKey(kvType, rawKey)
	local prefix = Const.KV_KEY_PREFIX[kvType]

	assert(prefix, "gen invalid kvType:" .. tostring(kvType))

	return string.format("%s=%s", tostring(prefix), tostring(rawKey))
end

function Utils.parseKVKey(kvType, kvKey)
	local prefix = Const.KV_KEY_PREFIX[kvType]

	assert(prefix, "parse invalid kvType:" .. tostring(kvType))

	local pattern = string.format("^%s=(.+)$", tostring(prefix))
	local rawKey = string.match(kvKey, pattern)

	return rawKey
end

function Utils.getInfoStampDefaultAnimation()
	for k, v in pairs(InfoStampAnimationConfigData) do
		if v[1].order == 1 then
			return k
		end
	end

	return nil
end

function Utils.getInfoStampCostTypeList(animation, bubbleType, txtClips)
	local cost = {}

	if animation ~= Utils.getInfoStampDefaultAnimation() and animation ~= -1 then
		cost[#cost + 1] = 2
	end

	if bubbleType then
		cost[#cost + 1] = 3
	end

	if txtClips and #txtClips > 0 then
		cost[#cost + 1] = 1
	end

	return cost
end

function Utils.getVehicleEntName(templateId)
	return VehicleData[templateId] and VehicleData[templateId].vehicleType
end

function Utils.hasBuff(ent, buffId)
	return ent.actorBuff:findOneBuffByTemplateId(buffId) ~= nil
end

function Utils.getSpaceInstanceServiceKey(serverId, uid, sceneId, lineId)
	if lineId then
		local lineStr = type(lineId) == "number" and string.format("%.0f", lineId) or tostring(lineId)

		return string.format("%s-%s-%s-%s", serverId, uid, sceneId, lineStr)
	end

	return string.format("%s-%s-%s", serverId, uid, sceneId)
end

function Utils.parseSpaceInstanceServiceKey(spaceKey)
	local serverId, uid, sceneId, lineId = string.match(spaceKey, "^(%d+)%-([%w_]+)%-(%d+)%-(.+)$")

	if not serverId then
		serverId, uid, sceneId, lineId = string.match(spaceKey, "^(%d+)%-([%w_]+)%-(%d+)$")
	end

	return tonumber(serverId), tostring(uid), tonumber(sceneId), tonumber(lineId)
end

function Utils.isSpaceKeyMatchUid(spaceKey, matchUid)
	local _, uid, _ = Utils.parseSpaceInstanceServiceKey(spaceKey)

	return uid == matchUid
end

function Utils.getGivePetConfig(petInfoDict)
	local formQuality = Utils.getPetFormQualityByTemplateId(petInfoDict.templateId)

	if not formQuality then
		return nil, 0
	end

	for k, v in pairs(GivePetData) do
		if v.stage == petInfoDict.stage and v.label == petInfoDict.label and lume.find(v.formQuality, formQuality) ~= nil then
			return v, k
		end
	end

	return nil, 0
end

function Utils.getGivePetLimitId(petInfoDict, pedd)
	pedd = pedd or Utils.getGivePetConfig(petInfoDict)

	return pedd.limitId
end

function Utils.getGivePetReceiveLimitId(petInfoDict, pedd)
	pedd = pedd or Utils.getGivePetConfig(petInfoDict)

	return pedd.receiveLimitId
end

function Utils.checkGiveRemovePet(player, petInfoDict, friendshipLevel, pedd)
	pedd = pedd or Utils.getGivePetConfig(petInfoDict)

	if pedd == nil then
		return false, Const.FollowGivePetError.EPRR_PET_TYPE_FORBID
	end

	local originFlag = player:getPetOriginFlag(petInfoDict)

	if Utils.isAnyRainbowType(petInfoDict.petPrototypeId) and originFlag ~= Const.PET_ORIGIN.LEYLINE_FLOWER then
		return false, Const.FollowGivePetError.EPRR_PET_TYPE_FORBID
	end

	if lume.find(SysConfigData.CANNOT_SEND_CATCH_BALL_LIST, petInfoDict.cubeItemId) then
		return false, Const.FollowGivePetError.EPRR_PET_TYPE_FORBID
	end

	if lume.find(player.petPrepareList, petInfoDict.id) then
		return false, Const.FollowGivePetError.EPRR_PET_IN_TEAM
	end

	if lume.find(player.petExploreList, petInfoDict.id) then
		return false, Const.FollowGivePetError.EPRR_PET_IN_TEAM
	end

	if lume.find(SysConfigData.NO_GIVE_PETS, petInfoDict.petPrototypeId) then
		return false, Const.FollowGivePetError.EPRR_PET_TYPE_FORBID
	end

	if petInfoDict.isTwinChoice then
		return false, Const.FollowGivePetError.EPRR_PET_TYPE_FORBID
	end

	if player:isPetPutInHomeland(petInfoDict) then
		return false, Const.FollowGivePetError.EPRR_PET_IN_HOME
	end

	if not Utils.isPetTradeFriendshipLevelEnough(petInfoDict, pedd, friendshipLevel) then
		return false, Const.FollowGivePetError.EPRR_FRIENDSHIP_LOW
	end

	local ownedPetInfo = player.pets[petInfoDict.id]
	local isCredentialKnown = not ownedPetInfo:isCatchReporting()
	local canGive = PetFriendTradeUtils.checkGiveLimit(player.useLimitMap, petInfoDict, pedd, friendshipLevel, isCredentialKnown)

	if not canGive then
		return false, Const.FollowGivePetError.EPRR_LIMIT_EXCEED
	end

	if pg.component == "game" then
		return player:checkRemovePet(petInfoDict.id)
	else
		return true
	end
end

function Utils.checkGiveAddPet(player, petInfoDict, friendshipLevel, pedd)
	pedd = pedd or Utils.getGivePetConfig(petInfoDict)

	if pedd == nil then
		return false, Const.FollowGivePetError.EPRR_PET_TYPE_FORBID
	end

	if not Utils.isPetTradeFriendshipLevelEnough(petInfoDict, pedd, friendshipLevel) then
		return false, Const.FollowGivePetError.EPAR_FRIENDSHIP_LOW
	end

	if not player:checkRecGivePetLimit() then
		return false, Const.FollowGivePetError.EPRR_RECEIVER_CANNOT_GET
	end

	if not player.useLimitMap:testLimit(pedd.receiveLimitId) then
		return false, Const.FollowGivePetError.EPRR_RECEIVER_CANNOT_GET
	end

	if pg.component == "game" and player:checkAddPet(petInfoDict.templateId, petInfoDict, Const.PET_FROM_GIVE) ~= NoticeDef.SUCCESS then
		return false, Const.FollowGivePetError.EPRR_RECEIVER_CANNOT_GET
	end

	return true
end

function Utils.checkHateModeEqual(entity)
	return entity:getConfigData().hateMode == AbilityConst.HATE_MODE.Team_Hate_Mode_Equal
end

function Utils.genRandomHomeFormulaConfig(carLevel, DNALevel)
	local randomTable = {}

	for type, randomInfo in pairs(HomelandRandomTypeData) do
		randomTable[type] = {}

		if randomInfo.unlockLevel and DNALevel < randomInfo.unlockLevel then
			randomTable[type].lock = true
		end
	end

	for type, addPropDict in pairs(HomelandRandomAddData) do
		randomTable[type] = randomTable[type] or {}

		for subLevel, propInfo in pairs(addPropDict) do
			if subLevel <= DNALevel then
				randomTable[type].addValue = math.max(propInfo.addProbability, randomTable[type].addValue or 0)
			end
		end
	end

	return randomTable
end

function Utils.randomHomeFormulaProduce(formulaId, randomFormulaConfig)
	return Utils.randomHomeFormulaProduceByData(HomelandFormulaRandomData[formulaId], randomFormulaConfig)
end

function Utils.randomHomeFormulaProduceByData(randomHomelandFormulaData, randomFormulaConfig)
	if not randomHomelandFormulaData then
		return 0
	end

	randomFormulaConfig = randomFormulaConfig or {}

	local randomType = 0
	local rnd = math.random()

	for rType, randomInfo in pairs(randomHomelandFormulaData) do
		local randomConfig = randomFormulaConfig[rType] or {}

		if not randomConfig.lock then
			local probability = (randomInfo.probability or 0) + (randomConfig.addValue or 0)

			if probability > 0 then
				if rnd < probability then
					randomType = rType

					break
				end

				rnd = rnd - probability
			end
		end
	end

	return randomType
end

function Utils.getCarryPetPuppetTemplateId(petTemplateId)
	return Utils.getHomePetPuppetTemplateId(petTemplateId)
end

function Utils.getCarryItemTemplateId(itemTemplateId)
	return itemTemplateId
end

function Utils.checkEntBeCarried(ent)
	if not ent then
		return false
	end

	return not string.isNilOrEmpty(ent.moveUser)
end

function Utils.getPlantBookSum(plantsBookData)
	local count = 0

	for _, data in pairs(plantsBookData or EMPTY_TABLE) do
		count = count + lume.tableLength(data)
	end

	return count
end

function Utils.checkSpaceFollowAvailable()
	if not pg or pg.component ~= "client" then
		return true
	end

	if not pg.game or not pg.game.chat then
		return true
	end

	return pg.game.chat:checkSpaceFollowAvailable()
end

function Utils.setSpaceFollowAvailable(key, available)
	if not pg or pg.component ~= "client" then
		return
	end

	if not pg.game or not pg.game.chat then
		return
	end

	return pg.game.chat:setSpaceFollowAvailable(key, available)
end

function Utils.canSpaceFollow(sceneId)
	local mainSceneId = SceneUtils.getMainSceneId(sceneId)

	if lume.findInList(Const.FOLLOW_SCENE_IDS, mainSceneId) then
		return true
	end

	return false
end

function Utils.isInPVPScene()
	local sceneId = pg.space and pg.space.sceneId or pg.global.scene.targetSceneId
	local sceneData = SceneData[sceneId]

	if not sceneData then
		return false
	end

	local tpType = sceneData.toplogoType or 0

	return tpType == 1
end

function Utils.getRobEggTargetId(sceneId, hardLv)
	local robEggBaseData = RobEggBaseData[sceneId]

	if not robEggBaseData then
		return
	end

	local gameGoalID = robEggBaseData.GameGoalID

	if not gameGoalID then
		return
	end

	return gameGoalID[hardLv]
end

function Utils.strIsNilOrEmpty(str)
	return not str or str == ""
end

function Utils.getPetInfoSimpleMirror(player, petInfo)
	if not petInfo then
		return nil
	end

	local mirror = {}

	mirror.id = petInfo.id
	mirror.templateId = petInfo.templateId
	mirror.petPrototypeId = petInfo.petPrototypeId
	mirror.label = petInfo.label
	mirror.basePropertyList = petInfo.basePropertyList:getRawTableWithDerived()
	mirror.level = petInfo.level
	mirror.unlockedAbilityMap = petInfo.unlockedAbilityMap:getRawTable()
	mirror.resonanceInfo = petInfo.resonanceInfo and petInfo.resonanceInfo:getRawTable() or nil

	if player then
		player:fillPetTransmogInfoToRawDict(petInfo.id, mirror)
	end

	return mirror
end

function Utils.getHelpIsUnlock(playerEnt, helpId)
	if not GuidenceItemData[helpId] then
		return
	end

	local lockType = playerEnt.unlockedHelpMap[helpId]

	lockType = lockType or GuidenceItemData[helpId].initState

	return lockType or Const.HELP_UNLOCK_LEVEL.UNLOCK
end

function Utils.getTideStateId(player)
	local space = player.space

	if not space or not space.sceneId or not space.curPeriodIndex or not space.tideEventInfo then
		return Const.TIDE_STATES.TIDE_DEFAULT
	end

	local curTime = Time.secondCache

	if curTime < space.tideEventInfo.expiredTime or space.tideEventInfo.expiredTime == -1 then
		local tideState = space.tideEventInfo.tideType == -1 and Const.TIDE_STATES.TIDE_DEFAULT or space.tideEventInfo.tideType

		return tideState
	end

	local mapTideData = MapTideData[space.sceneId]

	if not mapTideData or not mapTideData.time then
		return Const.TIDE_STATES.TIDE_DEFAULT
	end

	local tideStateList = mapTideData.time
	local TideId = tideStateList[space.curPeriodIndex]

	return TideId or Const.TIDE_STATES.TIDE_DEFAULT
end

function Utils.enableClientUseGm(player)
	if not player then
		return false
	end

	if true then return true end -- [GM-DEMO] force-enable client GM/debug UI (review check #8)

	if not _G_IsDebugMode then
		if CommonSwitch.ENABLE_PUBLISH_BOT_GM then
			return true
		end

		return player ~= nil and player._clientGmPanel
	end

	if CommonSwitch.ENABLE_CLIENT_GM == true then
		return true
	end

	return false
end

function Utils.strCheckContains(checkStr, matchStr)
	if not checkStr then
		return false
	end

	return string.find(checkStr, matchStr, 1, true) ~= nil
end

function Utils.getPlayerCreateDays(player)
	if player and player.createdTime and player.createdTime > 0 then
		return TimeUtils.getServerDayDiff(player.createdTime, Time.secondCache) + 1
	end

	return 0
end

function Utils.getPlayerNatureCreateDays(player)
	if player and player.createdTime and player.createdTime > 0 then
		return TimeUtils.getAreaDayDiff(player.createdTime, Time.secondCache) + 1
	end

	return 0
end

function Utils.getTeamInfo(entity)
	if not entity or not entity.getCurTeamInfo then
		return nil
	end

	return entity:getCurTeamInfo()
end

function Utils.getTeamMembers(entity)
	local teamInfo = Utils.getTeamInfo(entity)

	return teamInfo and teamInfo.membersInfo or {}
end

function Utils.getTeamMemberEntIdWithBot(entity)
	local teamInfo = Utils.getTeamInfo(entity)
	local entIdList = {}

	if teamInfo and teamInfo.sortList then
		for _, uid in ipairs(teamInfo.sortList) do
			local memberInfo = teamInfo.membersInfo[uid]

			if memberInfo and memberInfo.entityId then
				table.insert(entIdList, memberInfo.entityId)
			end
		end
	elseif entity and entity.id then
		table.insert(entIdList, entity.id)
	end

	if pg.space and pg.space.playerBotUidList then
		for _, entId in ipairs(pg.space.playerBotUidList) do
			table.insert(entIdList, entId)
		end
	end

	return entIdList
end

function Utils.getPvpMatchMode()
	local dungeonSceneId = pg.me.teamInfo and pg.me.teamInfo.dungeonSceneId
	local modeType = dungeonSceneId == Const.ROB_EGG_SCENE_CLIP_ID and Const.PvpMatchMode.Single or Const.PvpMatchMode.Double

	return modeType
end

local function _isCoreOnOtherPet(coreInfo, petId)
	local opi = coreInfo.ownerPetId or ""

	return opi ~= "" and opi ~= petId
end

local function _isAssistOwnerCoreOnOtherPet(player, ItemUtils, ownerCoreCarryPos, petId)
	if not ownerCoreCarryPos:isValid() then
		return false
	end

	local coreItem = ItemUtils.getItem(player, ownerCoreCarryPos:invId(), ownerCoreCarryPos:genId())

	if not coreItem then
		return false
	end

	local coreInfo = ItemUtils.getPropertyWithType(coreItem)

	if not coreInfo then
		return false
	end

	return _isCoreOnOtherPet(coreInfo, petId)
end

function Utils.getMaxCpRecommendCarrySet(player, petId)
	local ItemConst = require("Common.Const.ItemConst")
	local ItemUtils = require("Common.Utils.ItemUtils")
	local AssistCarryData = require("Data.assist_carry_data")
	local INV_PLAYER = ItemConst.INV_TYPE_PLAYER
	local playerBag = ItemUtils.getTypedBag(player, INV_PLAYER)

	if not playerBag then
		return nil
	end

	local petInfo = player.pets and player.pets[petId]

	if not petInfo then
		return nil
	end

	local MAX_PER_TYPE = 6

	local function insertTopN(bucket, item, cp)
		local size = #bucket

		if size >= MAX_PER_TYPE and cp <= bucket[size].cp then
			return
		end

		local newEntry = {
			item = item,
			cp = cp
		}
		local i = size < MAX_PER_TYPE and size or MAX_PER_TYPE - 1

		while i >= 1 and cp > bucket[i].cp do
			bucket[i + 1] = bucket[i]
			i = i - 1
		end

		bucket[i + 1] = newEntry

		if #bucket > MAX_PER_TYPE then
			bucket[#bucket] = nil
		end
	end

	local candidateCores = {}
	local assistByType = {}

	for _, item in playerBag:items() do
		local iid = item.id

		if CoreCarryData[iid] ~= nil then
			local coreInfo = ItemUtils.getPropertyWithType(item)

			if coreInfo and coreInfo:isValid() and not _isCoreOnOtherPet(coreInfo, petId) then
				candidateCores[#candidateCores + 1] = {
					item = item,
					info = coreInfo
				}
			end
		elseif AssistCarryData[iid] ~= nil then
			local assistInfo = ItemUtils.getPropertyWithType(item)

			if assistInfo and assistInfo:isValid() and not _isAssistOwnerCoreOnOtherPet(player, ItemUtils, assistInfo.ownerCoreCarryPos, petId) then
				local t = assistInfo:getAssistType()
				local bucket = assistByType[t]

				if not bucket then
					bucket = {}
					assistByType[t] = bucket
				end

				insertTopN(bucket, item, assistInfo:getCpValue())
			end
		end
	end

	if #candidateCores == 0 then
		return nil
	end

	local function evalCore(cand)
		local coreInfo = cand.info
		local level = coreInfo:getLevelAndExp()
		local ccdd = CoreCarryData[coreInfo.itemId]
		local slotUnlockLv = ccdd and ccdd.slotUnlockLv or {}
		local usedGenIds = {}
		local slotAssigns = {}
		local totalCp = coreInfo:getCpValue()

		for slotIdx, slotType in ipairs(coreInfo.assistCarryTypeList) do
			local unlockLv = slotUnlockLv[slotIdx] or 0

			if unlockLv <= level then
				local bucket = assistByType[slotType]

				if bucket then
					for i = 1, #bucket do
						local entry = bucket[i]
						local genId = entry.item:getGenID()

						if not usedGenIds[genId] then
							usedGenIds[genId] = true
							slotAssigns[slotIdx] = {
								INV_PLAYER,
								genId
							}
							totalCp = totalCp + entry.cp

							break
						end
					end
				end
			end
		end

		return {
			coreCarryPos = {
				INV_PLAYER,
				cand.item:getGenID()
			},
			assistCarryPosList = slotAssigns,
			totalCp = totalCp
		}
	end

	local best

	for _, cand in ipairs(candidateCores) do
		local result = evalCore(cand)

		if not best or result.totalCp > best.totalCp then
			best = result
		end
	end

	return best
end

function Utils.getRecommendSuitCarrySet(player, petId)
	local petInfo = player.pets and player.pets[petId]

	if not petInfo then
		return nil
	end

	local petPrototypeId = Utils.getPetPetPrototypeId(petInfo.templateId)
	local ppd = PetPrototypeData[petPrototypeId]

	if not ppd or not ppd.recommendEquipment then
		return nil
	end

	local ItemConst = require("Common.Const.ItemConst")
	local ItemUtils = require("Common.Utils.ItemUtils")
	local AssistCarryData = require("Data.assist_carry_data")
	local INV_PLAYER = ItemConst.INV_TYPE_PLAYER
	local playerBag = ItemUtils.getTypedBag(player, INV_PLAYER)

	if not playerBag then
		return nil
	end

	local recommendEquipmentSet = {}

	for _, itemId in ipairs(ppd.recommendEquipment) do
		recommendEquipmentSet[itemId] = true
	end

	local recommendGemIdSet = {}

	if ppd.recommendGemId then
		for _, itemId in ipairs(ppd.recommendGemId) do
			recommendGemIdSet[itemId] = true
		end
	end

	local recommendGemType = ppd.recommendGemType
	local recommendSuit = ppd.recommendSuit
	local suitAssistIdSet = {}
	local suitTypeList

	if recommendSuit then
		suitTypeList = {}

		for i = 2, #recommendSuit do
			local assistId = recommendSuit[i]

			suitAssistIdSet[assistId] = true

			local acdd = AssistCarryData[assistId]

			suitTypeList[i - 1] = acdd and acdd.type or 0
		end
	end

	local suitTypeListLen = suitTypeList and #suitTypeList or 0

	local function matchesTypeList(coreInfo, typeList, typeListLen)
		if typeListLen == 0 then
			return false
		end

		if #coreInfo.assistCarryTypeList ~= typeListLen then
			return false
		end

		for i, slotType in ipairs(coreInfo.assistCarryTypeList) do
			if typeList[i] ~= slotType then
				return false
			end
		end

		return true
	end

	local recommendGemTypeLen = recommendGemType and #recommendGemType or 0
	local suitMatchCores = {}
	local gemTypeMatchCores = {}
	local otherCores = {}
	local MAX_PER_TYPE = 6

	local function insertSorted(bucket, item, cp, isRecommendGem)
		local size = #bucket

		if size >= MAX_PER_TYPE then
			local last = bucket[size]

			if isRecommendGem == last.isRecommendGem and cp <= last.cp then
				return
			end

			if not isRecommendGem and last.isRecommendGem then
				return
			end
		end

		local newEntry = {
			item = item,
			cp = cp,
			isRecommendGem = isRecommendGem
		}
		local insertAt = size < MAX_PER_TYPE and size or MAX_PER_TYPE - 1

		while insertAt >= 1 do
			local b = bucket[insertAt]

			if b.isRecommendGem and not isRecommendGem then
				break
			end

			if b.isRecommendGem == isRecommendGem and cp <= b.cp then
				break
			end

			bucket[insertAt + 1] = bucket[insertAt]
			insertAt = insertAt - 1
		end

		bucket[insertAt + 1] = newEntry

		if #bucket > MAX_PER_TYPE then
			bucket[#bucket] = nil
		end
	end

	local assistByType = {}
	local assistByItemId = {}

	for _, item in playerBag:items() do
		local iid = item.id

		if CoreCarryData[iid] and recommendEquipmentSet[iid] then
			local coreInfo = ItemUtils.getPropertyWithType(item)

			if coreInfo and coreInfo:isValid() and not _isCoreOnOtherPet(coreInfo, petId) then
				local cand = {
					item = item,
					info = coreInfo
				}

				if matchesTypeList(coreInfo, suitTypeList, suitTypeListLen) then
					suitMatchCores[#suitMatchCores + 1] = cand
				elseif matchesTypeList(coreInfo, recommendGemType, recommendGemTypeLen) then
					gemTypeMatchCores[#gemTypeMatchCores + 1] = cand
				else
					otherCores[#otherCores + 1] = cand
				end
			end
		elseif AssistCarryData[iid] then
			local assistInfo = ItemUtils.getPropertyWithType(item)

			if assistInfo and assistInfo:isValid() and not _isAssistOwnerCoreOnOtherPet(player, ItemUtils, assistInfo.ownerCoreCarryPos, petId) then
				local t = assistInfo:getAssistType()
				local cp = assistInfo:getCpValue()
				local isRecGem = recommendGemIdSet[iid] or false
				local bucket = assistByType[t]

				if not bucket then
					bucket = {}
					assistByType[t] = bucket
				end

				insertSorted(bucket, item, cp, isRecGem)

				if suitAssistIdSet[iid] then
					local byId = assistByItemId[iid]

					if not byId then
						byId = {}
						assistByItemId[iid] = byId
					end

					local entry = {
						item = item,
						cp = cp
					}
					local pos = #byId

					while pos >= 1 and cp > byId[pos].cp do
						byId[pos + 1] = byId[pos]
						pos = pos - 1
					end

					byId[pos + 1] = entry
				end
			end
		end
	end

	local isSuitCore = recommendSuit and recommendSuit[1] or nil

	local function evalCore(cand)
		local coreInfo = cand.info
		local level = coreInfo:getLevelAndExp()
		local ccdd = CoreCarryData[coreInfo.itemId]
		local slotUnlockLv = ccdd and ccdd.slotUnlockLv or {}
		local trySuit = isSuitCore == coreInfo.itemId
		local usedGenIds = {}
		local slotAssigns = {}
		local totalCp = coreInfo:getCpValue()

		for slotIdx, slotType in ipairs(coreInfo.assistCarryTypeList) do
			local unlockLv = slotUnlockLv[slotIdx] or 0

			if unlockLv <= level then
				if trySuit then
					local suitAssistId = recommendSuit[slotIdx + 1]

					if suitAssistId then
						local acdd = AssistCarryData[suitAssistId]

						if acdd and acdd.type == slotType then
							local candidates = assistByItemId[suitAssistId]

							if candidates then
								for j = 1, #candidates do
									local entry = candidates[j]
									local genId = entry.item:getGenID()

									if not usedGenIds[genId] then
										usedGenIds[genId] = true
										slotAssigns[slotIdx] = {
											INV_PLAYER,
											genId
										}
										totalCp = totalCp + entry.cp

										break
									end
								end
							end
						end
					end
				end

				if not slotAssigns[slotIdx] then
					local bucket = assistByType[slotType]

					if bucket then
						for i = 1, #bucket do
							local entry = bucket[i]
							local genId = entry.item:getGenID()

							if not usedGenIds[genId] then
								usedGenIds[genId] = true
								slotAssigns[slotIdx] = {
									INV_PLAYER,
									genId
								}
								totalCp = totalCp + entry.cp

								break
							end
						end
					end
				end
			end
		end

		return {
			coreCarryPos = {
				INV_PLAYER,
				cand.item:getGenID()
			},
			assistCarryPosList = slotAssigns,
			totalCp = totalCp
		}
	end

	local evalList = #suitMatchCores > 0 and suitMatchCores or #gemTypeMatchCores > 0 and gemTypeMatchCores or otherCores

	if #evalList == 0 then
		return nil
	end

	local best

	for _, cand in ipairs(evalList) do
		local result = evalCore(cand)

		if not best or result.totalCp > best.totalCp then
			best = result
		end
	end

	return best
end

function Utils.getCertifiedRecommendCarrySet(player, petId)
	local ItemConst = require("Common.Const.ItemConst")
	local ItemUtils = require("Common.Utils.ItemUtils")
	local petInfo = player and player.pets and player.pets[petId]

	if not petInfo then
		return nil
	end

	local invPlayer = ItemConst.INV_TYPE_PLAYER
	local playerBag = ItemUtils.getTypedBag(player, invPlayer)

	if not playerBag then
		return nil
	end

	local petData = PetData[petInfo.templateId]
	local targetBaseFormPet = petData and petData.baseFormPet or 0
	local petPrototypeId = Utils.getPetPetPrototypeId(petInfo.templateId)
	local prototypeData = PetPrototypeData[petPrototypeId]
	local recommendEquipmentSet = {}

	for _, itemId in ipairs(prototypeData and prototypeData.recommendEquipment or EMPTY_TABLE) do
		recommendEquipmentSet[itemId] = true
	end

	local bestPriority = -1
	local bestCp = -1
	local bestGenId

	for _, item in playerBag:items() do
		local itemId = item.id

		if CoreCarryData[itemId] then
			local coreInfo = ItemUtils.getPropertyWithType(item)

			if coreInfo and coreInfo:isValid() and not _isCoreOnOtherPet(coreInfo, petId) then
				local priority = 0

				if targetBaseFormPet ~= 0 and coreInfo.certifiedBaseFormPet == targetBaseFormPet then
					priority = priority + 2
				end

				if recommendEquipmentSet[itemId] == true then
					priority = priority + 1
				end

				if bestPriority <= priority then
					local cp = coreInfo:getCpValue()

					if bestPriority < priority or bestCp < cp then
						bestPriority = priority
						bestCp = cp
						bestGenId = item:getGenID()
					end
				end
			end
		end
	end

	if not bestGenId then
		return nil
	end

	return {
		coreCarryPos = {
			invPlayer,
			bestGenId
		},
		totalCp = bestCp
	}
end

function Utils.getRecommendCarrySetList(player, petPrototypeId, petInfo)
	local list = {}
	local recommendInfoMap = player and player.petCarryRecommendInfoMap
	local recommendInfo = petInfo and recommendInfoMap and recommendInfoMap:getValidRecommendInfo(petInfo.id) or nil
	local appliedType = recommendInfo and recommendInfo.appliedType or 0
	local isApplied = appliedType > 0
	local appliedItemIds = isApplied and recommendInfo.appliedItemIds or {}
	local appliedSuits = {
		appliedType = appliedType,
		isApplied = isApplied,
		appliedItemIds = appliedItemIds
	}

	if appliedType == 2 then
		list[#list + 1] = {
			isApplied = true,
			recommendType = 1,
			recommendRatio = PetConfigData.PET_RECOMMEND_CARRY_RATIO_2,
			appliedSuits = appliedSuits
		}
	else
		local maxCpSet = Utils.getMaxCpRecommendCarrySet(player, petInfo and petInfo.id)

		if maxCpSet then
			maxCpSet.recommendType = 1
			maxCpSet.recommendRatio = PetConfigData.PET_RECOMMEND_CARRY_RATIO_2
			list[#list + 1] = maxCpSet
		end
	end

	if #list == 0 then
		return nil
	end

	return list
end

function Utils.isMatchPetFuncType(checkType, matchType)
	if not checkType or not matchType then
		return false
	end

	return checkType == matchType
end

function Utils.monthCardIsOpen(player)
	if not player then
		return false
	end

	local mcBegTm = player.mcBegTm or 0
	local mcEndTm = player.mcEndTm or 0

	if mcEndTm == 0 then
		return false
	end

	if mcEndTm <= mcBegTm then
		return false
	end

	local now = Time.secondCache

	if mcBegTm <= now and now <= mcEndTm then
		return true
	end

	return false
end

function Utils.monthCardHaveSum(player)
	if not player then
		return 0
	end

	if not Utils.monthCardIsOpen(player) then
		return 0
	end

	local now = Time.secondCache
	local daysOneCard = SysConfigData.MONTH_CARD_STATE_TIME or 30
	local monthcardRemainDays = math.ceil((player.mcEndTm - now + 1) / Const.SECONDS_ONE_DAY)
	local cardSum = math.ceil(monthcardRemainDays / daysOneCard)

	return cardSum
end

function Utils.monthCardRemainDays(player)
	if not player then
		return 0
	end

	if not Utils.monthCardIsOpen(player) then
		return 0
	end

	local now = Time.secondCache
	local monthcardRemainDays = math.ceil((player.mcEndTm - now + 1) / Const.SECONDS_ONE_DAY)

	return monthcardRemainDays
end

function Utils.checkPrivType(privType)
	if not privType or privType < Const.PrivilegeType.Priv_Min or privType > Const.PrivilegeType.Priv_Max then
		return false
	end

	return true
end

function Utils.getEnergyMaxRecoverValue(player, type)
	if not player or not type then
		return 0
	end

	local data = CurrencyAutoData[type]

	if not data then
		logger:error("Utils.getEnergyMaxValue not data")

		return 0
	end

	local maxRecoverValue = data.autoChangeRange and data.autoChangeRange[2] or 0

	if type == Const.CommonEnergyType_Stamina then
		local extraRate = player:getAttrVal(AttributeConst.energy_max_v, 0)

		if extraRate and extraRate > 0 then
			maxRecoverValue = maxRecoverValue * extraRate / 100
		end
	end

	return maxRecoverValue
end

function Utils.concatTableOrUserdata(value, concatStr)
	concatStr = concatStr or ""

	local ok, len = pcall(function()
		return #value
	end)

	if not ok or type(len) ~= "number" then
		local okListLen, listLen = pcall(lume.getListLenWithNil, value)

		len = okListLen and type(listLen) == "number" and listLen or 0
	end

	if len <= 0 then
		return ""
	end

	local list = {}
	local idx = 1

	for i = 1, len do
		local item = value[i]

		if item == nil then
			error(string.format("invalid value (nil) at index %d in table for 'concat'", i), 2)
		end

		list[idx] = item
		idx = idx + 1
	end

	return table.concat(list, concatStr)
end

function Utils.checkShopMallGiftpackType(giftpackType)
	return giftpackType and giftpackType >= Const.ShopMallGiftpackType.Fixed and giftpackType <= Const.ShopMallGiftpackType.FreeFixed
end

function Utils.getCurLimitShopSceneId(tmpSpace)
	local sceneId = 0

	if not tmpSpace then
		return sceneId
	end

	sceneId = tmpSpace.sceneId

	if tmpSpace:isRobEgg() then
		local masterSpace = tmpSpace:getMasterSpace()

		if masterSpace then
			sceneId = masterSpace.sceneId
		end
	end

	return sceneId
end

function Utils.checkShopMallCommodityFree(commodityId)
	local tabId = ShopMallCommodityTabData[commodityId] or 0

	if tabId == Const.ShopMallTabType.Tab_GiftPack then
		local commodityData = ShopMallCommodityData[commodityId]

		if not commodityData then
			return false
		end

		local giftId = commodityData.itemId or 0
		local giftType = ShopMallGiftData[giftId] and ShopMallGiftData[giftId].giftPackType

		if giftType and giftType == Const.ShopMallGiftpackType.FreeFixed then
			return true
		end
	end

	return false
end

function Utils.getRechargeCurrentSymboy()
	local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
	local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
	local allsdkProducts = UNITY_EDITOR and RechargeUtils.getTestSDKProducts() or csSDKManager:GetPayProductsTable()

	if allsdkProducts then
		for _, info in pairs(allsdkProducts) do
			if info.currency_symbol then
				return info.currency_symbol
			end
		end
	end

	return "￥"
end

function Utils.getRechargeRebateAmount(sum)
	sum = sum or 0

	local total = 0

	for _, gear in pairs(RebateGearData) do
		if sum > gear.beginSum then
			local capped = math_min(sum, gear.endsum)

			total = total + (capped - gear.beginSum) * gear.rebateRate / 10
		end
	end

	return math_floor(total)
end

function Utils.isRechargeProductSwitchOn(packageId)
	local data = ShopmallRechargeData[packageId]
	local productType = data and data.type

	if productType then
		if productType == Const.RECHARGE_TYPE.RECHARGE then
			return CommonSwitch.ShopMall_Recharge == true
		end

		if productType == Const.RECHARGE_TYPE.MONTHCAR then
			return CommonSwitch.ShopMall_MonthlyCard == true
		end

		if productType == Const.RECHARGE_TYPE.BP then
			return CommonSwitch.ACT_TYPE_BattlePass == true
		end
	end

	return true
end

function Utils.getPetDisptachReduceTimeRatio(player, petList)
	if not player or not petList or #petList == 0 then
		return 0
	end

	local reduceRatio = 0
	local reduceTag = {}

	for i, petId in ipairs(petList) do
		local petInfo = player:getPetInfo(petId)

		if petInfo then
			if Utils.isLabelShiny(petInfo.label) and not reduceTag[1] then
				reduceTag[1] = 1
				reduceRatio = reduceRatio + (SysConfigData.DISPATCH_SHINY_TIME or 0)
			end

			if Utils.isAnyRainbowType(petInfo.petPrototypeId) and not reduceTag[2] then
				reduceTag[2] = 1
				reduceRatio = reduceRatio + (SysConfigData.DISPATCH_RAINBOW_TIME or 0)
			end
		end
	end

	return reduceRatio
end

function Utils.isPetQualitiesFull(petInfo)
	return #Utils.getPetQualityCanEventAddIndexes(petInfo) == 0
end

function Utils.getPetQualityCanEventAddIndexes(petInfo)
	local indexes = {}

	if not petInfo then
		return indexes
	end

	local maxCount = PetConfigData.individualPropEnhanceTimesMax or 0

	if maxCount <= 0 or maxCount <= (petInfo.propertyCountByEvent or 0) then
		return indexes
	end

	local maxIndividual = PetConfigData.individualPropEnhanceMax or 0

	if maxIndividual <= 0 then
		return indexes
	end

	local basePropertyList = petInfo.basePropertyList or {}

	for idx = 1, Const.BASE_PROPERTY_CNT do
		local prop = basePropertyList[idx]

		if prop then
			local individual = prop.getAllBaseIndividual and prop:getAllBaseIndividual() or (prop.indLv or 0) - (prop.iLvEx or 0) - (prop.iLvLn or 0)

			if individual < maxIndividual then
				indexes[#indexes + 1] = idx
			end
		end
	end

	return indexes
end

function Utils.getGoldAdveRewardId(adventureRewards)
	adventureRewards = adventureRewards or {}

	for id, reward in ipairs(adventureRewards) do
		if reward[1] and reward[1] == 1 then
			return id
		end
	end

	return 0
end

function Utils.getLeylineTreeIdBySceneId(sceneId)
	return sceneId and SceneToLeylineTreeData[sceneId] or nil
end

function Utils.isUnlockFreelanceMode(player, templateId)
	if not player or not player.leylineTreeInfoMap or not templateId then
		return false
	end

	local unlockLevel = SysConfigData.LEYLINETREE_FREELANCE_LEVEL

	if not unlockLevel then
		return false
	end

	local treeInfo = player.leylineTreeInfoMap[templateId]

	if not treeInfo or not treeInfo.leylineTreeLevel then
		return false
	end

	return unlockLevel <= treeInfo.leylineTreeLevel
end

function Utils.getI18nText(uid, text, language)
	if type(text) ~= "string" then
		return text
	end

	local index = string.find(text, ":", 1, true)

	if not index or string.sub(text, 1, index - 1) ~= "i18n" then
		return text
	end

	local jsonStr = string.sub(text, index + 1)
	local ok, parsedText = pcall(json.decode, jsonStr)

	if not ok then
		logger:warn("getI18nText decode failed, uid=%s, text=%s, err=%s", tostring(uid), tostring(text), tostring(parsedText))

		return ""
	end

	if type(parsedText) ~= "table" then
		logger:warn("getI18nText decoded data is not table, uid=%s, text=%s", tostring(uid), tostring(text))

		return ""
	end

	language = language or ""

	if parsedText[language] ~= nil then
		return parsedText[language]
	end

	local defaultLanguage = Const.SERVER_AREANO_DEAFULT_LANGUAGE[Utils.getServerArea()]

	logger:error("getI18nText language not found, uid=%s, language=%s, defaultLanguage=%s, text=%s", tostring(uid), tostring(language), tostring(defaultLanguage), tostring(text))

	return parsedText[defaultLanguage] or ""
end

Utils.clearDirtyDataLevel = {
	{
		32,
		32,
		32
	},
	{
		256,
		256,
		256
	},
	{
		512,
		512,
		512
	}
}

function Utils.clearDirtyDataInPool(clearLevel, canClearCurrentFrameData)
	clearLevel = clearLevel or 1

	local clearInfo = Utils.clearDirtyDataLevel[clearLevel] or Utils.clearDirtyDataLevel[1]

	CallbackHandlerNoGC.checkAutoDisposeCache(clearInfo[3])
	TablePool.clearDirtyData(clearInfo[1], canClearCurrentFrameData)
	ListPool.clearDirtyData(clearInfo[2], canClearCurrentFrameData)
end

function Utils.checkHatchEggQuality(eggItemId, extraArg)
	if not extraArg then
		return true
	end

	local quality = ItemData[eggItemId].quality

	if quality == nil then
		return false
	end

	for _, needQuality in ipairs(extraArg) do
		if quality == needQuality then
			return true
		end
	end

	return false
end

function Utils.getHatchEggQualityKey(statType, quality)
	return statType * 100 + quality + 1
end

function Utils.getRobEggRetreatKey(sceneId, hardLv)
	return (sceneId or 0) * 1000 + (hardLv or 0) + 100
end

function Utils.getPlayerGhostId(ghostId, targetId)
	return ghostId .. "_" .. targetId .. Const.PlayerGhostIdSuffix
end

function Utils.getPlayerGhostUid(sourceUid, targetId)
	return sourceUid .. "_" .. targetId .. Const.PlayerGhostIdSuffix
end

function Utils.getPetGhostId(petId, targetId)
	return petId .. "_" .. targetId .. Const.PetGhostIdSuffix
end

function Utils.addHatchEggQualityCount(triggerMap, statType, eggItemId, count)
	local quality = ItemData[eggItemId].quality

	if quality == nil then
		return
	end

	triggerMap:addTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_HATCH_EGG, Utils.getHatchEggQualityKey(statType, quality), count or 1)
end

function Utils.getHatchEggQualityCount(triggerMap, statType, extraArg)
	if not extraArg then
		return 0
	end

	local count = 0

	for _, quality in ipairs(extraArg) do
		count = count + (triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_HATCH_EGG, Utils.getHatchEggQualityKey(statType, quality)) or 0)
	end

	return count
end

function Utils.duringTimePeriod(tbRow)
	local function isInTimeRange(sec, startSec, endSec)
		if startSec < endSec then
			return startSec <= sec and sec < endSec
		end

		return startSec <= sec or sec < endSec
	end

	if not tbRow then
		return false
	end

	local now = Time.secondCache
	local todaySec = now - TimeUtils.getAreaDayBegin(now)
	local startSec = Utils.getConfigTimeOfArea(tbRow, "startTime")
	local endSec = Utils.getConfigTimeOfArea(tbRow, "endTime")

	if startSec and endSec and isInTimeRange(todaySec, startSec, endSec) then
		return true
	end

	return false
end

function Utils.parseClassId(classId)
	if type(classId) ~= "string" or not string.match(classId, "^%d%d%d%d%d%d%d%d%d%d%d%d$") then
		return nil
	end

	local function isIntegerInRange(value, minValue, maxValue)
		return type(value) == "number" and value == math.floor(value) and minValue <= value and value <= maxValue
	end

	local function checkAreaNo(areaNo)
		return isIntegerInRange(areaNo, Const.SERVER_AREANO.CN, Const.SERVER_AREANO.AP)
	end

	local function checkLanguageNo(languageNo)
		return isIntegerInRange(languageNo, Const.LANGUAGE_TYPE_MAP.zh_CN, Const.LANGUAGE_TYPE_MAP.th_TH)
	end

	local areaNo = tonumber(string.sub(classId, 1, 1))
	local languageNo = tonumber(string.sub(classId, 2, 3))

	if not checkLanguageNo(languageNo) or not checkAreaNo(areaNo) then
		return nil
	end

	return areaNo, languageNo
end

function Utils.getAssociatedLanguageNo(areaNo, languageNo)
	local areaConfig = LanguageAssociateData[areaNo]
	local languageConfig = areaConfig and areaConfig[languageNo]

	return languageConfig and languageConfig.mainLanguageId or languageNo
end

function Utils.getServerAppId()
	local serverAreaNo = Utils.getServerArea()
	local serverAreaCfg = ReviewRiskControlCallbackData[serverAreaNo]

	serverAreaCfg = serverAreaCfg or ReviewRiskControlCallbackData[Const.GLOBAL_SERVER_AREA_NO]

	if not serverAreaCfg then
		return 0
	end

	return serverAreaCfg.AppId
end

function Utils.getServerSecretId()
	local serverAreaNo = Utils.getServerArea()
	local serverAreaCfg = ReviewRiskControlCallbackData[serverAreaNo]

	serverAreaCfg = serverAreaCfg or ReviewRiskControlCallbackData[Const.GLOBAL_SERVER_AREA_NO]

	if not serverAreaCfg then
		return ""
	end

	return serverAreaCfg.SecretID
end

function Utils.getServerSecretKey()
	local serverAreaNo = Utils.getServerArea()
	local serverAreaCfg = ReviewRiskControlCallbackData[serverAreaNo]

	serverAreaCfg = serverAreaCfg or ReviewRiskControlCallbackData[Const.GLOBAL_SERVER_AREA_NO]

	if not serverAreaCfg then
		return ""
	end

	return serverAreaCfg.SecretKey
end

function Utils.getServerGmePermissionKey()
	local serverAreaNo = Utils.getServerArea()
	local serverAreaCfg = ReviewRiskControlCallbackData[serverAreaNo]

	serverAreaCfg = serverAreaCfg or ReviewRiskControlCallbackData[Const.GLOBAL_SERVER_AREA_NO]

	if not serverAreaCfg then
		return ""
	end

	return serverAreaCfg.GmePermissionKey
end

function Utils.getServerRegion()
	local serverAreaNo = Utils.getServerArea()
	local serverAreaCfg = ReviewRiskControlCallbackData[serverAreaNo]

	serverAreaCfg = serverAreaCfg or ReviewRiskControlCallbackData[Const.GLOBAL_SERVER_AREA_NO]

	if not serverAreaCfg then
		return ""
	end

	return serverAreaCfg.ServerRegion
end

return Utils
