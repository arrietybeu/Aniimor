-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RogueUtils.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetSkillLearnData = require("Data.pet_skill_learn_map")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RandomBuffData = require("Data.random_buff_data")
local RogueBuffLevelInfo = require("Data.rogue_buff_level_info")
local RogueBuffExtend = require("Data.rogue_buff_extend")
local ExtraRandomBuff = require("Data.extra_random_buff")
local BuffConfigData = require("Data.buff_config_data")
local RandomBuffSeriesName = require("Data.random_buff_series_name")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local RogueTransformData = require("Data.rogue_transform_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("Rogue")
local PetManagementUtils = require("Utils.PetManagementUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local RogueConst = require("Const.RogueConst")
local RoguelikeData = require("Data.roguelike_data")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local AudioConst = require("Const.AudioConst")
local ItemData = require("Data.item_data")
local Time = require("Core.Common.Time")
local CustomTriggerData = require("Data.custom_trigger_data")
local RogueWeekBossRewardData = require("Data.rogue_week_boss_reward_data")
local ItemSourceData = require("Data.item_source_data")
local AbilityParamData = require("Data.ability_param_data")
local RogueRoomAffixesData = require("Data.rogue_room_affixes_data")
local SkillTagData = require("Data.skill_tag_data")
local json = require("json")
local ClientConst = require("Const.ClientConst")
local RougeSeasonData = require("Data.rogue_season_data")
local TimeUtils = require("Utils.TimeUtils")
local ID_ROGUE_RADAR = "rogueRadar"
local IDX_HP = RogueConst.PropIndex.IDX_HP
local IDX_ATK = RogueConst.PropIndex.IDX_ATK
local IDX_MATK = RogueConst.PropIndex.IDX_MATK
local IDX_DEF = RogueConst.PropIndex.IDX_DEF
local IDX_MDEF = RogueConst.PropIndex.IDX_MDEF
local IDX_REGEN = RogueConst.PropIndex.IDX_REGEN
local RogueUtils = Class.LiteClass("RogueUtils")

local function isRogueLevelStateMarked(stateInfo, levelId)
	if stateInfo == nil or levelId == nil then
		return false
	end

	local value = stateInfo[levelId]

	if value == true then
		return true
	end

	if type(value) == "number" then
		return value > 0
	end

	if type(value) == "string" then
		return (tonumber(value) or 0) > 0
	end

	return false
end

function RogueUtils.getRedDotState()
	local seasonWeeklyState = RogueUtils.getRedDotSeasonWeeklyRewardState()

	if seasonWeeklyState ~= RedDotConst.RedDotStyle.NONE then
		return seasonWeeklyState
	end

	return RedDotConst.RedDotStyle.NONE
end

function RogueUtils.isSeasonWeeklyRewardUnlocked(levelId)
	return RogueDifficultyData[levelId] ~= nil and pg.me ~= nil and isRogueLevelStateMarked(pg.me.rogueWeeklyLevelPassInfo, levelId)
end

function RogueUtils.isSeasonWeeklyRewardReceived(levelId)
	if not pg.me or levelId == nil then
		return false
	end

	return isRogueLevelStateMarked(pg.me.rogueWeeklyLevelRewardInfo, levelId)
end

function RogueUtils.canGetSeasonWeeklyReward(levelId)
	return RogueUtils.isSeasonWeeklyRewardUnlocked(levelId) and not RogueUtils.isSeasonWeeklyRewardReceived(levelId)
end

function RogueUtils.canGetSeasonWeeklyRewardByElement(elementType)
	if elementType == nil then
		return false
	end

	for levelId, levelData in ipairs(RogueDifficultyData) do
		if levelData.elementType == elementType and RogueUtils.canGetSeasonWeeklyReward(levelId) then
			return true
		end
	end

	return false
end

function RogueUtils.getRedDotSeasonWeeklyRewardState()
	for levelId in ipairs(RogueDifficultyData) do
		if RogueUtils.canGetSeasonWeeklyReward(levelId) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function RogueUtils.refreshSeasonWeeklyRewardRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.TOWER_SEASON_WEEKLY_REWARD)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.TOWER)
end

function RogueUtils.getRedDotBookState()
	if not pg.me then
		return RedDotConst.RedDotStyle.NONE
	end

	if pg.me.checkCanGetReward and pg.me:checkCanGetReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if pg.me.checkEventBookCanGetReward and pg.me:checkEventBookCanGetReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if pg.me.checkBossBookCanGetReward and pg.me:checkBossBookCanGetReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function RogueUtils.getRedDotDailyState()
	local hasReward = pg.me.rogueHarvestPendingRewards and #pg.me.rogueHarvestPendingRewards > 0

	if hasReward then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function RogueUtils.getRedDotWeeklyState()
	for index, config in ipairs(RogueWeekBossRewardData) do
		local state = RogueUtils.getRedDotWeeklyRewardBtnState(index)

		if state ~= RedDotConst.RedDotStyle.NONE then
			return state
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function RogueUtils.getRedDotWeeklyRewardBtnState(index)
	local config = RogueWeekBossRewardData[index]

	if not config then
		return RedDotConst.RedDotStyle.NONE
	end

	local canGet = pg.me.rogueWeeklyBossKillCount >= config.startPoint
	local hasGet = pg.me.rogueWeeklyBossRewardInfo and pg.me.rogueWeeklyBossRewardInfo[index] or false

	if canGet and not hasGet then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function RogueUtils.getWeeklyTime()
	local week = 604800

	return pg.me.lastWeekUpdateTs + week
end

function RogueUtils.isInRogueSpace()
	if pg.me and pg.me.space then
		return pg.me.space:isRogueEnv()
	end

	return false
end

function RogueUtils.getIndexInTeam(entityId)
	local teamIndex = -1

	for _idx, _id in ipairs(pg.me.roguePets) do
		if _id == entityId then
			teamIndex = _idx

			break
		end
	end

	return teamIndex
end

function RogueUtils.isUltimateUnlock()
	return pg.me.rogueUltimateSeries >= 0
end

function RogueUtils.getUltimatePetTemplateID()
	local series = pg.me.rogueUltimateSeries
	local cfg = RogueTransformData[series]

	return cfg and cfg.transformTemplateID or 0
end

function RogueUtils.getUltimatePetTransformAbilityId()
	local series = pg.me.rogueUltimateSeries
	local cfg = RogueTransformData[series]

	return cfg and cfg.transformSkill or 0
end

function RogueUtils.getUltimatePetTransformVerticalPainting()
	local series = pg.me.rogueUltimateSeries
	local cfg = RogueTransformData[series]

	return cfg and cfg.transformVerticalPainting or ""
end

function RogueUtils.getUltimatePetAbilityIds()
	local templateId = RogueUtils.getUltimatePetTemplateID()
	local petPrototypeId = Utils.getPetPetPrototypeId(templateId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local data = PetSkillLearnData[basePetPrototypeId]
	local ultimateAbilityId
	local skillAbilityIds = {}

	if data and data.initAbilitys then
		for _, abilityInfo in ipairs(data.initAbilitys) do
			local abilityParamId, _ = unpack(abilityInfo)
			local abilityType = AbilityUtils.getAbilityParamSkillType(abilityParamId)

			if abilityType == Const.SkillType.Skill then
				skillAbilityIds[#skillAbilityIds + 1] = AbilityUtils.getAbilityIdByParamId(templateId, abilityParamId)
			elseif abilityType == Const.SkillType.Ultimate then
				ultimateAbilityId = AbilityUtils.getAbilityIdByParamId(templateId, abilityParamId)
			end
		end
	end

	return ultimateAbilityId, skillAbilityIds
end

function RogueUtils.useRogueQuality(itemId)
	if itemId and ItemData[itemId] then
		return ItemData[itemId].qualityType == 1
	end

	return false
end

function RogueUtils.getRogueBuffTagIcon(buffId)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	return buffCfg and buffCfg.buffTagIcon
end

function RogueUtils.getRogueBuffSeries(buffId)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	return buffCfg and buffCfg.buffSeries or 0
end

function RogueUtils.getRogueBuffSeriesName(series)
	local seriesCfg = RandomBuffSeriesName[series]

	return seriesCfg and seriesCfg.buffSeriesName
end

function RogueUtils.renderBigSkill(abilityId, skillBtn)
	PetManagementUtils.renderSkillWithAbilityId(abilityId, AbilityConst.ULTIMATE_ABILITY, skillBtn)
end

function RogueUtils.renderSmallSkill(abilityId, skillBtn)
	if abilityId and abilityId ~= 0 then
		LuaUIUtils.setUIViewVisible(skillBtn, true)
		PetManagementUtils.renderSkillWithAbilityId(abilityId, AbilityConst.WEAPON_SKILL_ABILITY, skillBtn)
	else
		LuaUIUtils.setUIViewVisible(skillBtn, false)
	end
end

function RogueUtils.renderSkillBtn(btn, paramId, video)
	if not paramId or paramId == 0 then
		return
	end

	local paramData = AbilityParamData[paramId]

	if not paramData then
		return
	end

	local tagList = {}

	if paramData.tags then
		for _, tagId in pairs(paramData.tags) do
			tagList[#tagList + 1] = {
				name = pg.getLocalizationText(SkillTagData[tagId].tagName)
			}
		end
	end

	local skillInfo = {
		showSkillName = false,
		enabledTooltip = false,
		hideSkillButton = true,
		name = pg.getLocalizationText(paramData.name),
		icon = paramData.icon,
		desc = pg.getLocalizationText(paramData.desc),
		attrs = tagList,
		video = video
	}

	LuaUIUtils.renderSkillCmpCommon(btn, skillInfo)

	function btn.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			btn:TryChangePage("Selected", 1)
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
				autoVer = true,
				targetRect = btn,
				data = skillInfo,
				onCloseCallback = function()
					btn:TryChangePage("Selected", 0)
				end
			})
		end
	end
end

function RogueUtils.getUltimatePetPropRadarBind(itemRadar)
	local radarRef = itemRadar.transform:GetComponent("ObjectReference")
	local ret = {}

	ret.go = itemRadar.gameObject
	ret.hpNum = radarRef:GetRefValue("hpNum")
	ret.atkNum = radarRef:GetRefValue("atkNum")
	ret.defNum = radarRef:GetRefValue("defNum")
	ret.regenNum = radarRef:GetRefValue("regenNum")
	ret.defMagNum = radarRef:GetRefValue("defMagNum")
	ret.atkMagNum = radarRef:GetRefValue("atkMagNum")
	ret.hpCmp = radarRef:GetRefValue("hpCmp")
	ret.atkCmp = radarRef:GetRefValue("atkCmp")
	ret.defCmp = radarRef:GetRefValue("defCmp")
	ret.regenCmp = radarRef:GetRefValue("regenCmp")
	ret.defMagCmp = radarRef:GetRefValue("defMagCmp")
	ret.atkMagCmp = radarRef:GetRefValue("atkMagCmp")
	ret.hpLevelCmp = radarRef:GetRefValue("hpLevelCmp")
	ret.atkLevelCmp = radarRef:GetRefValue("atkLevelCmp")
	ret.defLevelCmp = radarRef:GetRefValue("defLevelCmp")
	ret.regenLevelCmp = radarRef:GetRefValue("regenLevelCmp")
	ret.defMagLevelCmp = radarRef:GetRefValue("defMagLevelCmp")
	ret.atkMagLevelCmp = radarRef:GetRefValue("atkMagLevelCmp")
	ret.defaultRadar = radarRef:GetRefValue("defaultRadar")
	ret.hpCmp.interactable = false
	ret.atkCmp.interactable = false
	ret.defCmp.interactable = false
	ret.regenCmp.interactable = false
	ret.defMagCmp.interactable = false
	ret.atkMagCmp.interactable = false

	ret.hpLevelCmp.gameObject:SetActiveEx(false)
	ret.atkLevelCmp.gameObject:SetActiveEx(false)
	ret.defLevelCmp.gameObject:SetActiveEx(false)
	ret.regenLevelCmp.gameObject:SetActiveEx(false)
	ret.defMagLevelCmp.gameObject:SetActiveEx(false)
	ret.atkMagLevelCmp.gameObject:SetActiveEx(false)

	return ret
end

function RogueUtils.getUltimatePetPropIndividualPoints()
	local rogSpace = pg.me.space
	local petInfoArray = rogSpace.petInfos
	local cps = {}
	local lvs = {}

	for i = 1, #petInfoArray do
		local cp = petInfoArray[i].cp or 0
		local level = petInfoArray[i].level or 0
		local index = #cps + 1

		for j = index - 1, 1, -1 do
			if cp > cps[j] then
				index = j
			else
				break
			end
		end

		table.insert(cps, index, cp)
		table.insert(lvs, index, level)
	end

	local ultimatePetTemplateId = RogueUtils.getUltimatePetTemplateID()
	local petData = PetData[ultimatePetTemplateId]
	local species = {
		petData.species_hp_max_v,
		petData.species_atk_v,
		petData.species_bp_atk_v,
		petData.species_def_v,
		petData.species_def_mag_v,
		petData.species_ep_regen_force_v
	}
	local individualPoints = Utils.formulaSafeCall(nil, 3011, cps, lvs, species)

	return individualPoints
end

function RogueUtils.getUltimatePetProps(individualPoints)
	local rogSpace = pg.me.space
	local maxLv = rogSpace.petMaxLevel
	local ultimatePetTemplateId = RogueUtils.getUltimatePetTemplateID()
	local petData = PetData[ultimatePetTemplateId]
	local props = {}

	props[1] = Utils.formulaSafeCall(0, 3003, petData.species_hp_max_v, individualPoints and individualPoints[1] or 0, maxLv, math.floor)
	props[2] = Utils.formulaSafeCall(0, 3004, petData.species_atk_v, individualPoints and individualPoints[2] or 0, maxLv, math.floor)
	props[3] = Utils.formulaSafeCall(0, 3018, petData.species_bp_atk_v, individualPoints and individualPoints[3] or 0, maxLv, math.floor)
	props[4] = Utils.formulaSafeCall(0, 3007, petData.species_def_v, individualPoints and individualPoints[4] or 0, maxLv, math.floor)
	props[5] = Utils.formulaSafeCall(0, 3007, petData.species_def_mag_v, individualPoints and individualPoints[5] or 0, maxLv, math.floor)
	props[6] = Utils.formulaSafeCall(0, 3008, petData.species_ep_regen_force_v, individualPoints and individualPoints[6] or 0, maxLv, math.floor)

	return props
end

function RogueUtils.renderUltimatePetPropRadar(compRadar, isBase)
	if not RogueUtils.isUltimateUnlock() then
		return
	end

	local rogSpace = pg.me.space
	local lvFactor = rogSpace.petMaxLevel
	local props

	if isBase then
		props = RogueUtils.getUltimatePetProps()
	else
		props = RogueUtils.getUltimatePetProps(RogueUtils.getUltimatePetPropIndividualPoints())
	end

	local ratio = Utils.formulaSafeCall(nil, 3012, props, lvFactor)

	ClientTextUtils.setText(compRadar.hpNum, props[IDX_HP])
	ClientTextUtils.setText(compRadar.atkNum, props[IDX_ATK])
	ClientTextUtils.setText(compRadar.defNum, props[IDX_DEF])
	ClientTextUtils.setText(compRadar.regenNum, props[IDX_REGEN])
	ClientTextUtils.setText(compRadar.defMagNum, props[IDX_MDEF])
	ClientTextUtils.setText(compRadar.atkMagNum, props[IDX_MATK])
	compRadar.defaultRadar:SetSixProps(ratio[IDX_HP], ratio[IDX_ATK], ratio[IDX_DEF], ratio[IDX_REGEN], ratio[IDX_MDEF], ratio[IDX_MATK])
end

function RogueUtils.renderUltimatePetPropRadarTransit(compRadar)
	if not RogueUtils.isUltimateUnlock() then
		return
	end

	local rogSpace = pg.me.space
	local lvFactor = rogSpace.petMaxLevel
	local props_start = RogueUtils.getUltimatePetProps()
	local props_final = RogueUtils.getUltimatePetProps(RogueUtils.getUltimatePetPropIndividualPoints())
	local ratio_start = Utils.formulaSafeCall(nil, 3012, props_start, lvFactor)
	local ratio_final = Utils.formulaSafeCall(nil, 3012, props_final, lvFactor)

	DoTweenAnimMgr.DoFloat(compRadar.go, 0, 1, LuaUIUtils.TweenId(ID_ROGUE_RADAR), 0.5, 0, CS.DG.Tweening.Ease.__CastFrom(1), nil, function(val)
		ClientTextUtils.setText(compRadar.hpNum, math.floor(props_start[IDX_HP] * (1 - val) + props_final[IDX_HP] * val))
		ClientTextUtils.setText(compRadar.atkNum, math.floor(props_start[IDX_ATK] * (1 - val) + props_final[IDX_ATK] * val))
		ClientTextUtils.setText(compRadar.defNum, math.floor(props_start[IDX_DEF] * (1 - val) + props_final[IDX_DEF] * val))
		ClientTextUtils.setText(compRadar.regenNum, math.floor(props_start[IDX_REGEN] * (1 - val) + props_final[IDX_REGEN] * val))
		ClientTextUtils.setText(compRadar.defMagNum, math.floor(props_start[IDX_MDEF] * (1 - val) + props_final[IDX_MDEF] * val))
		ClientTextUtils.setText(compRadar.atkMagNum, math.floor(props_start[IDX_MATK] * (1 - val) + props_final[IDX_MATK] * val))
		compRadar.defaultRadar:SetSixProps(ratio_start[IDX_HP] * (1 - val) + ratio_final[IDX_HP] * val, ratio_start[IDX_ATK] * (1 - val) + ratio_final[IDX_ATK] * val, ratio_start[IDX_DEF] * (1 - val) + ratio_final[IDX_DEF] * val, ratio_start[IDX_REGEN] * (1 - val) + ratio_final[IDX_REGEN] * val, ratio_start[IDX_MDEF] * (1 - val) + ratio_final[IDX_MDEF] * val, ratio_start[IDX_MATK] * (1 - val) + ratio_final[IDX_MATK] * val)
	end, nil, false)
end

function RogueUtils.renderBuffSelectList(uList, buffIds, extraInfo)
	if IsNil(uList) then
		return
	end

	RogueUtils.curBuffSelectExtraInfo = extraInfo or {}

	function uList.luaRenderItem(button, index, data)
		RogueUtils.renderBuffItem(button, index, data)
	end

	function uList.luaClick(button, data)
		if IsNil(uList) then
			return
		end

		RogueUtils.onBuffSelectChange(button, data)

		if RogueUtils.curSelectedBuffId == data.buffId then
			RogueUtils.curSelectedBuffId = nil
		else
			RogueUtils.curSelectedBuffId = data.buffId
		end

		uList:RefreshList()
	end

	function uList.luaFinishRender(uList)
		RogueUtils.curBuffSelectExtraInfo.hasRender = true

		uList:SetEnableCustomInterval(false)
	end

	local buffData, hasRare = RogueUtils.parserBuffData(buffIds, extraInfo)

	uList:SetList(buffData)

	if hasRare then
		pg.game.audio:triggerEvent(AudioConst.EVENT_SHOW_RARE_BUFF)
	end

	if RogueUtils.delayRefreshSelectBuffTimer then
		TimerManager.removeTimer(RogueUtils.delayRefreshSelectBuffTimer)
	end

	RogueUtils.delayRefreshSelectBuffTimer = TimerManager.addTimer(1.2, function()
		if IsNil(uList) then
			return
		end

		for _, buff in ipairs(buffData) do
			buff.disabled = extraInfo.isShow or false
			buff.showRayBox = not buff.disabled
		end

		uList:SetList(buffData)

		if extraInfo.needSelect then
			RogueUtils.focusDefaultItem(uList, buffData)
		end
	end)

	if extraInfo.needSelect then
		RogueUtils.focusDefaultItem(uList, buffData)
	end
end

function RogueUtils.focusDefaultItem(uList, buffData)
	local index = 0

	if RogueUtils.curSelectedBuffId ~= nil then
		for i, v in ipairs(buffData) do
			if v.buffId == RogueUtils.curSelectedBuffId then
				index = i - 1

				break
			end
		end
	end

	local res, btn = uList:TryGetChildAt(index)

	if res then
		pg.global.navMgr:FocusItem(btn)
	end
end

function RogueUtils.renderBuffItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local buffName = objectReference:GetRefValue("buffName")
	local buffDetail = objectReference:GetRefValue("buffDetail")
	local buffIconUImage = objectReference:GetRefValue("buffIconUImage")
	local buffSeriesCountUBaseText = objectReference:GetRefValue("buffSeriesCountUBaseText")
	local buffSeriesNameUBaseText = objectReference:GetRefValue("buffSeriesNameUBaseText")
	local buffSeriesIconUImage = objectReference:GetRefValue("buffSeriesIconUImage")
	local iconBgUWidget = objectReference:GetRefValue("iconBgUWidget")
	local progressBarUComponent = objectReference:GetRefValue("progressBarUComponent")
	local panelAnimation = objectReference:GetRefValue("panelAnimation")
	local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")
	local ownUBaseText = objectReference:GetRefValue("ownUBaseText")
	local equipmentIconUImage = objectReference:GetRefValue("equipmentIconUImage")
	local recommendUWidget = objectReference:GetRefValue("recommendUWidget")
	local iconBossUImage = objectReference:GetRefValue("iconBossUImage")
	local guideUnlockUWidget = objectReference:GetRefValue("guideUnlockUWidget")
	local textUnlockUSDFText = objectReference:GetRefValue("textUnlockUSDFText")

	if not data.hasPlayFx then
		panelAnimation:Play("VX_Node_Roguelike_BuffCell_In")

		data.hasPlayFx = true
	end

	if data.showRayBox then
		rayBoxUWidget:SetActive(true)
	end

	local buffDesc = buffDetail.transform:Find("View/Content"):GetComponent("UBaseText")

	if data.isShow and data.curCount then
		ClientTextUtils.setText(buffSeriesCountUBaseText, data.curCount)
	else
		ClientTextUtils.setText(buffSeriesCountUBaseText, pg.me:getRogueBuffCount(data.buffSeries))
	end

	ClientTextUtils.setText(ownUBaseText, pg.getGameString("ROGUE_BUFF_OWN"), ": ")

	local name, _ = string.gsub(pg.getLocalizationText(data.buffName), "Hint_BgL", "Hint_BgD")

	ClientTextUtils.setText(buffName, name)

	local desc, _ = string.gsub(pg.getLocalizationText(data.buffDesc), "Hint_BgL", "Hint_BgD")

	ClientTextUtils.setText(buffDesc, desc)

	buffDesc.enabledHyperlink = true

	function buffDesc.luaOnHyperlinkClick(action, content, contentRect)
		if action == "" or action == nil then
			button:OnClickSimpleSimulate()

			return
		end

		LuaUIUtils.clickHyperText(action, content, contentRect)
	end

	buffIconUImage.url = data.buffIcon

	local buffSeriesInfo = RandomBuffSeriesName[data.buffSeries]

	if buffSeriesInfo then
		ClientTextUtils.setText(buffSeriesNameUBaseText, pg.getLocalizationText(buffSeriesInfo.buffSeriesName))
	end

	recommendUWidget:SetActive(pg.me.rogueInitSeriesInfo and pg.me.rogueInitSeriesInfo.curRealSeries == data.buffSeries)
	iconBgUWidget:SetActive(data.buffTagIcon ~= nil and data.buffTagIcon ~= "")

	if data.buffTagIcon then
		buffSeriesIconUImage.url = data.buffTagIcon
	end

	RogueUtils.setBuffQuality(button, data)

	if data.buffQuality == Const.RogueBuffQuality.Equipment then
		local isSelected = RogueUtils.curSelectedBuffId == data.buffId or data.isShow
		local progress = isSelected and data.buffCount or data.buffCount - 1

		progressBarUComponent:TryChangePage("ProgressBar", progress)
		progressBarUComponent:TryChangePage("Selected", isSelected and 1 or 0)

		local transformInfo = RogueTransformData[data.buffSeries]

		equipmentIconUImage.url = transformInfo and transformInfo.buffSeriesBg or ""
	elseif data.buffQuality == Const.RogueBuffQuality.Boss then
		local transformInfo = RogueTransformData[data.buffSeries]

		iconBossUImage.url = transformInfo and transformInfo.transformBuffLvUpIcon or ""
	end

	if data.buffQuality ~= Const.RogueBuffQuality.Boss then
		if RogueUtils.curBuffSelectExtraInfo.needSelect then
			LuaUIUtils.setUIViewVisible(guideUnlockUWidget, pg.me.isBuffUnlock and not pg.me:isBuffUnlock(data.buffId) or false)
			ClientTextUtils.setText(textUnlockUSDFText, pg.getGameString("ROGUE_BOOK_UN_COLLECT"))
		end
	else
		local extraRandomBuffData = ExtraRandomBuff[data.buffId]

		if extraRandomBuffData then
			LuaUIUtils.setUIViewVisible(guideUnlockUWidget, pg.me.isBuffUnlock and not pg.me:isBossUnlock(extraRandomBuffData.buffSeries, data.buffId) or false)
			ClientTextUtils.setText(textUnlockUSDFText, pg.getGameString("ROGUE_BOOK_UN_COLLECT"))
		else
			LuaUIUtils.setUIViewVisible(guideUnlockUWidget, false)
		end
	end
end

function RogueUtils.setBuffQuality(button, data)
	button:TryChangePage("Quality", data.showQuality)

	if data.buffQuality == Const.RogueBuffQuality.Equipment then
		button:TryChangePage("BuffGenre", 1)
	elseif data.buffQuality == Const.RogueBuffQuality.Boss then
		button:TryChangePage("BuffGenre", 2)
	else
		button:TryChangePage("BuffGenre", 0)
	end
end

function RogueUtils.onBuffSelectChange(button, data)
	button:InvokeCallback(CS.XGUI.EInvokeTime.User2)

	if RogueUtils.curBuffSelectExtraInfo and RogueUtils.curBuffSelectExtraInfo.onBuffSelectChange then
		RogueUtils.curBuffSelectExtraInfo.onBuffSelectChange(data)
	end
end

function RogueUtils.getBuffQuality(buffId)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	if buffCfg then
		return buffCfg.buffRarity or buffCfg.buffLv or 0
	end

	return 0
end

function RogueUtils.getBuffMaxLayer(buffId)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	return buffCfg and buffCfg.maxLayer or 0
end

function RogueUtils.parserBuffData(buffIds, extraInfo)
	local buffs = {}
	local hasRare = false

	for i, buffId in pairs(buffIds) do
		local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

		if buffCfg then
			local buffCfg2 = BuffConfigData[buffId]
			local buffCount = pg.me.rogueBuffs[buffId] or 0

			if not extraInfo.isShow then
				buffCount = buffCount + 1
			end

			local maxLayer = buffCfg.maxLayer or 1

			buffCount = math.min(buffCount, maxLayer)

			local buffName, buffDesc = RogueUtils.getBuffNameAndDesc(buffId, buffCount)

			buffs[i] = {
				hasPlayFx = false,
				buffId = buffId,
				buffCount = buffCount,
				buffName = buffName or buffCfg2.buffName,
				buffDesc = buffDesc or buffCfg2.buffDesc,
				buffIcon = buffCfg.buffIcon,
				buffQuality = buffCfg.buffRarity or buffCfg.buffLv,
				buffSeries = buffCfg.buffSeries,
				buffTagIcon = buffCfg.buffTagIcon
			}

			if extraInfo then
				buffs[i].isShow = extraInfo.isShow
				buffs[i].curCount = extraInfo.curCounts and extraInfo.curCounts[buffId]
			end

			buffs[i].disabled = true

			if buffs[i].isShow then
				buffs[i].selected = true
			end

			if buffs[i].buffQuality == Const.RogueBuffQuality.Equipment or buffs[i].buffQuality == Const.RogueBuffQuality.Boss then
				hasRare = true
			end

			buffs[i].showQuality = buffs[i].buffQuality

			if buffs[i].showQuality == Const.RogueBuffQuality.Equipment and maxLayer <= buffCount then
				buffs[i].showQuality = Const.RogueBuffQuality.Boss
			end
		end
	end

	return buffs, hasRare
end

function RogueUtils.getBuffNameAndDesc(buffId, buffLevel)
	buffLevel = buffLevel or 1

	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	if buffLevel > 1 then
		local buffLevelInfo = RogueBuffLevelInfo[buffId]

		if buffLevelInfo and buffLevelInfo[buffLevel] then
			local extendCfg = RogueBuffExtend[buffLevelInfo[buffLevel]]

			return extendCfg and extendCfg.buffName, extendCfg and extendCfg.buffDescFinal
		end
	end

	return buffCfg and buffCfg.buffName, buffCfg and buffCfg.buffDescFinal
end

function RogueUtils.getTotalRogueBuffCount()
	local totalCount = 0

	for _, count in pairs(pg.me.rogueBuffs) do
		totalCount = totalCount + count
	end

	return totalCount
end

function RogueUtils.getRogueBuffCountBySeries(buffSeries)
	local totalCount = 0

	for buffId, count in pairs(pg.me.rogueBuffs) do
		local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

		if buffCfg and buffCfg.buffSeries == buffSeries then
			totalCount = totalCount + count
		end
	end

	return totalCount
end

function RogueUtils.getBattlePetIds()
	local battlePetIds = {}
	local curBattlePet = pg.me.roguePets

	for _, petId in ipairs(curBattlePet) do
		table.insert(battlePetIds, petId)
	end

	if #battlePetIds == 0 then
		for id, index in pairs(pg.me.selectRoguePets) do
			if index <= Const.PET_PREPARE_NUM_LIMIT then
				battlePetIds[index] = id
			end
		end
	end

	return battlePetIds
end

function RogueUtils.getSelectedIndex(petId)
	local battleIds = RogueUtils.getBattlePetIds()

	for index, battlePetId in ipairs(battleIds) do
		if petId == battlePetId then
			return index
		end
	end

	return 0
end

function RogueUtils.getPetSortInfo(pet)
	if pet.isLock or pet.gridIsLock then
		return 4, math.huge, pet.id or math.huge
	end

	if pet.isEmpty or pet.gridIsEmpty then
		return 3, math.huge, pet.id or math.huge
	end

	local battleIndex = pet.id and RogueUtils.getSelectedIndex(pet.id) or 0

	if battleIndex > 0 then
		return 1, battleIndex, pet.id or math.huge
	end

	return 2, math.huge, pet.id or math.huge
end

function RogueUtils.comparePetSortInfo(a, b)
	local groupA, orderA, idA = RogueUtils.getPetSortInfo(a)
	local groupB, orderB, idB = RogueUtils.getPetSortInfo(b)

	if groupA ~= groupB then
		return groupA < groupB
	end

	if orderA ~= orderB then
		return orderA < orderB
	end

	return idA < idB
end

function RogueUtils.getLevelRenderData()
	local levelRenderDataList = {}
	local safeNum = 1
	local levelId = 1
	local levelData = RogueDifficultyData[levelId]
	local goToIndex, goToLevelId

	if pg.me.curRogueLayer > 0 then
		local levelCfg = RoguelikeData[pg.me.curRogueLayer]

		goToLevelId = levelCfg and levelCfg.levelId
	elseif pg.me.lastRogueLevel and pg.me.lastRogueLevel > 0 then
		goToLevelId = pg.me.lastRogueLevel
	end

	if levelId == goToLevelId then
		goToIndex = #levelRenderDataList
	end

	table.insert(levelRenderDataList, {
		tIndex = 0,
		levelRenderDataCol = {
			{
				levelId = 1
			}
		}
	})

	while levelData do
		safeNum = safeNum + 1

		if safeNum >= 100 then
			break
		end

		local nextLevelIds = levelData.postNode

		if #nextLevelIds > 0 then
			table.insert(levelRenderDataList, {
				tIndex = #nextLevelIds > 1 and 2 or 1,
				nextLevelIds = nextLevelIds
			})

			local levelRenderDataCol = {}

			for _, _levelId in ipairs(nextLevelIds) do
				table.insert(levelRenderDataCol, {
					levelId = _levelId
				})

				if _levelId == goToLevelId then
					goToIndex = #levelRenderDataList
				end
			end

			table.insert(levelRenderDataList, {
				tIndex = 0,
				levelRenderDataCol = levelRenderDataCol
			})
		end

		if #nextLevelIds ~= 1 then
			break
		end

		levelId = nextLevelIds[1]
		levelData = RogueDifficultyData[levelId]
	end

	return levelRenderDataList, goToIndex
end

function RogueUtils.renderLevelColumnItem(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local list = objectReference:GetRefValue("list")

		function list.luaRenderItem(_button, _index, _data)
			RogueUtils.renderLevelItem(_button, _index, _data)
		end

		list:SetList(data.levelRenderDataCol)
	elseif data.tIndex == 1 then
		local isUnlock = RogueUtils.checkLevelUnlock(data.nextLevelIds[1])

		button:TryChangePage("LineState", isUnlock and 1 or 0)
	elseif data.tIndex == 2 then
		local objectReference = button:GetComponent("ObjectReference")
		local lineUButtons = {}

		lineUButtons[1] = objectReference:GetRefValue("line1UButton")
		lineUButtons[2] = objectReference:GetRefValue("line2UButton")
		lineUButtons[3] = objectReference:GetRefValue("line3UButton")

		local anyUnlock = false

		for i = 1, 3 do
			local isUnlock = false

			if data.nextLevelIds[i] then
				isUnlock = RogueUtils.checkLevelUnlock(data.nextLevelIds[i])
			end

			anyUnlock = anyUnlock or isUnlock

			lineUButtons[i]:TryChangePage("LineState", isUnlock and 1 or 0)
		end

		button:TryChangePage("LineShare", anyUnlock and 1 or 0)
	end
end

function RogueUtils.getSelectedRogueLevelRecordKey()
	local seasonId = pg.me and tonumber(pg.me.rogueSeasonId) or 0

	if seasonId <= 0 then
		return nil
	end

	return string.format("%s.%s", RedDotConst.RedDotPath.TOWER_LEVEL_SELECTED, seasonId)
end

function RogueUtils.getSelectedRogueLevel()
	local recordKey = RogueUtils.getSelectedRogueLevelRecordKey()

	if not recordKey then
		return 0
	end

	local levelId = tonumber(pg.me:getRedDotRecord(Const.CLIENT_KEY.ROGUE, recordKey, 0)) or 0

	if levelId > 0 then
		local levelData = RogueDifficultyData[levelId]
		local isUnlock = levelData and RogueUtils.checkLevelUnlock(levelId)

		if not isUnlock then
			pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, recordKey, 0)

			return 0
		end
	end

	return levelId
end

function RogueUtils.setSelectedRogueLevel(levelId)
	local recordKey = RogueUtils.getSelectedRogueLevelRecordKey()

	if not recordKey then
		return false
	end

	return pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, recordKey, levelId)
end

function RogueUtils.getCurRogueLevel()
	local curLevelId = pg.me.curRogueLevel

	if not curLevelId or curLevelId <= 0 then
		curLevelId = RogueUtils.getSelectedRogueLevel()
	end

	return curLevelId
end

function RogueUtils.renderLevelItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootComponent = objectReference:GetRefValue("rootComponent")
	local txtName = objectReference:GetRefValue("txtName")
	local imgHover = objectReference:GetRefValue("imgHover")
	local itemElement = objectReference:GetRefValue("itemElement")
	local txtLevelCondition = objectReference:GetRefValue("txtLevelCondition")
	local animRoot = objectReference:GetRefValue("animRoot")
	local orderUBaseText = objectReference:GetRefValue("orderUBaseText")
	local starUList = objectReference:GetRefValue("starUList")
	local doubleUComponent = objectReference:GetRefValue("doubleUComponent")
	local starUWidget = objectReference:GetRefValue("starUWidget")
	local levelIds = data.levelIds
	local levelData = RogueDifficultyData[levelIds[1]]
	local elementType = levelData.elementType
	local levelType = levelData.levelType or 0
	local levelRenderType

	if levelType == RogueConst.LevelType.BONUS then
		levelRenderType = RogueConst.LevelItemRenderType.BONUS
	else
		levelRenderType = RogueConst.Element2LevelItemRenderType[elementType]
	end

	rootComponent:TryChangePage("LevelType", levelRenderType)
	itemElement:TryChangePage("type", elementType)

	imgHover.url = levelData.hoverIcon

	ClientTextUtils.setTextWithId(txtName, levelData.levelName)
	ClientTextUtils.setText(txtLevelCondition, RogueConst.Num2RomanNum[levelData.levelConditionIcon])
	ClientTextUtils.setText(orderUBaseText, index + 1)

	local curLevelId = RogueUtils.getCurRogueLevel()
	local hasSave = curLevelId > 0
	local isSave = false

	if hasSave then
		isSave = table.contains(levelIds, curLevelId)
	end

	local isLastLevel = table.contains(levelIds, pg.me.lastRogueLevel) and not hasSave

	rootComponent:TryChangePage("SaveState", isSave and 1 or isLastLevel and 2 or 0)

	local isUnlock, reason = RogueUtils.checkLevelUnlock(levelIds[1])

	rootComponent:TryChangePage("LockState", isUnlock and 0 or 1)
	RogueUtils.setLevelRedDot(button, levelIds)

	function starUList.luaRenderItem(button2, index2, data2)
		button2:TryChangePage("finish", RogueUtils.checkLevelPass(data2.levelId) and 1 or 0)
	end

	local starData = {}

	for i = 1, #levelIds - 1 do
		table.insert(starData, {
			levelId = levelIds[i]
		})
	end

	starUList:SetList(starData)

	local highLevel = levelIds[#levelIds]
	local isPass = RogueUtils.checkLevelPass(highLevel)

	rootComponent:TryChangePage("finish", isPass and 1 or 0)
	doubleUComponent:SetActive(ClientActivityUtils.isRogueRewardUpWithRemainTimes())

	function rootComponent.luaClick(navConfirm)
		if navConfirm then
			return
		end

		if not data.selected then
			return
		end

		if isUnlock then
			if hasSave then
				if isSave then
					pg.global.ui:open(UIConst.UI_ID_TOWER_LEVEL_DETAIL, {
						levelIds = levelIds,
						levelId = curLevelId
					})
					RogueUtils.clearLevelRedDot(button, levelIds)
				else
					pg.global.showConfirmMsgRaw(pg.getGameString("ROGUE_RESET_TITLE"), pg.getGameString("ROGUE_RESET"), function()
						RogueUtils.resetRogue(function()
							pg.global.ui:open(UIConst.UI_ID_TOWER_LEVEL_DETAIL, {
								levelIds = levelIds,
								levelId = RogueUtils.getJumpLevelId(levelIds)
							})
							RogueUtils.clearLevelRedDot(button, levelIds)
						end)
					end)
				end
			else
				pg.global.ui:open(UIConst.UI_ID_TOWER_LEVEL_DETAIL, {
					levelIds = levelIds,
					levelId = RogueUtils.getJumpLevelId(levelIds)
				})
				RogueUtils.clearLevelRedDot(button, levelIds)
			end
		else
			rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			pg.global.ui.tips:showTextTip(reason)
		end
	end
end

function RogueUtils.setLevelRedDot(button, levelIds)
	for _, levelId in ipairs(levelIds) do
		local isNew = RogueUtils.checkLevelIsNew(levelId)
		local treePath = RedDotConst.RedDotPath.TOWER_LEVEL_GROUP .. levelId

		if isNew then
			pg.global.setRedDot(treePath, button, isNew, RedDotConst.RedDotStyle.NEW)

			break
		end
	end
end

function RogueUtils.clearLevelRedDot(button, levelIds)
	for _, levelId in ipairs(levelIds) do
		local isNew = RogueUtils.checkLevelIsNew(levelId)
		local treePath = RedDotConst.RedDotPath.TOWER_LEVEL_GROUP .. levelId

		if isNew then
			pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, treePath, false)
			pg.global.setRedDot(treePath, button, false, RedDotConst.RedDotStyle.NEW)

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_ROG_LEVEL_SELECT) then
				pg.global.ui.rogLevelSelect:refreshSwitchBtnRedDot()
			end

			break
		end
	end
end

function RogueUtils.resetRogue(settlementCloseCb)
	local hasChallenge = pg.me.curRogueLayer > 0

	pg.me.rogueInitSeriesInfo.curSeries = -1

	if hasChallenge then
		pg.global.ui:open(UIConst.UI_ID_TOWER_SETTLEMENT, nil, nil, settlementCloseCb)
	else
		pg.me:resetRogue()

		if settlementCloseCb then
			settlementCloseCb()
		end
	end

	RogueUtils.setSelectedRogueLevel(0)
	facade:sendMsgToUI(MessageName.ROGUE_LEVEL_CHANGE)
end

function RogueUtils.getJumpLevelId(levelIds)
	local jumpLevelId = levelIds[#levelIds]

	for _, levelId in ipairs(levelIds) do
		if RogueUtils.checkLevelUnlock(levelId) then
			jumpLevelId = levelId

			if not RogueUtils.checkLevelPass(levelId) then
				return levelId
			end
		end
	end

	return jumpLevelId
end

function RogueUtils.checkLevelPass(levelId)
	if pg.me == nil then
		return false
	end

	local levelData = RogueDifficultyData[levelId]

	if levelData == nil then
		return false
	end

	local passInfo = pg.me.rogueSeasonLevelPassInfo

	if isRogueLevelStateMarked(passInfo, levelId) then
		return true
	end

	for higherLevelId, higherLevelData in ipairs(RogueDifficultyData) do
		if higherLevelData.elementType == levelData.elementType and higherLevelData.difficultyLabel > levelData.difficultyLabel and isRogueLevelStateMarked(passInfo, higherLevelId) then
			return true
		end
	end

	return false
end

function RogueUtils.getCurPassLevels()
	local passLevels = {}

	for index, cfg in ipairs(RogueDifficultyData) do
		if RogueUtils.checkLevelPass(index) then
			if passLevels[cfg.difficultyLabel] == nil then
				passLevels[cfg.difficultyLabel] = {}
			end

			table.insert(passLevels[cfg.difficultyLabel], index)
		end
	end

	return passLevels
end

function RogueUtils.getCurDailyRewardLevel()
	local passLevels = RogueUtils.getCurPassLevels()
	local lvMaxPassCount = 3
	local openDailyRewardLevels = {
		1,
		2,
		3
	}

	if passLevels[openDailyRewardLevels[1]] and #passLevels[openDailyRewardLevels[1]] ~= lvMaxPassCount then
		return -1
	end

	local res = 1

	for i = 2, #openDailyRewardLevels do
		res = res + (passLevels[openDailyRewardLevels[i]] and #passLevels[openDailyRewardLevels[i]] or 0)
	end

	return res
end

function RogueUtils.checkLevelUnlock(levelId)
	local levelData = RogueDifficultyData[levelId]
	local preNodes = levelData.preNode or {}

	for _, preLevelId in ipairs(preNodes) do
		if not RogueUtils.checkLevelPass(preLevelId) then
			return false, pg.getGameString("TOWER_UNLOCK_TIP_PRELEVEL")
		end
	end

	local conditionIds = levelData.levelCondition or {}

	for _, conditionId in ipairs(conditionIds) do
		if not pg.me.triggerMap:isCompleteOrMeetCondition(conditionId) then
			local tip = CustomTriggerData[conditionId] and CustomTriggerData[conditionId].note or ""

			return false, pg.getLocalizationText(tip)
		end
	end

	return true
end

function RogueUtils.checkLevelIsNew(levelId)
	local isUnlock = RogueUtils.checkLevelUnlock(levelId)

	return isUnlock and pg.me:getRedDotRecord(Const.CLIENT_KEY.ROGUE, RedDotConst.RedDotPath.TOWER_LEVEL_GROUP .. levelId, true)
end

function RogueUtils.renderPetCard(button, index, data)
	if data.gridIsLock then
		button:TryChangePage("State", 2)

		return
	elseif data.gridIsEmpty then
		button:TryChangePage("State", 1)

		return
	end

	button:TryChangePage("State", 0)

	local objectReference = button:GetComponent("ObjectReference")
	local elementUList = objectReference:GetRefValue("elementUList")
	local orderUBaseText = objectReference:GetRefValue("orderUBaseText")
	local levelUBaseText = objectReference:GetRefValue("levelUBaseText")
	local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")
	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local petHpProgress = objectReference:GetRefValue("petHpProgress")

	function elementUList.luaRenderItem(_button, _index, _data)
		LuaUIUtils.setElementButtonNew(_button, _data.element)
	end

	elementUList:SetList(data.elementNames)

	local teamIndex = RogueUtils.getIndexInTeam(data.id)

	ClientTextUtils.setText(orderUBaseText, string.format("%02d", teamIndex))
	ClientTextUtils.setText(levelUBaseText, data.level)
	ClientTextUtils.setText(petNameUBaseText, pg.getLocalizationText(data.name))

	local iconUrl = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_FIRST_SHOW, data.label, data.gender)

	petIconUImage.url = iconUrl

	local realtimeData = pg.me:getPetInfo(data.id)

	petHpProgress.value = realtimeData.hpRatio

	local ent = pg.getEntity(data.id)
	local isDead = ent and ent:isDead() or false

	if isDead == false and realtimeData.hpRatio <= 0 then
		isDead = true
	end

	local isInTeam = teamIndex > 0

	button:TryChangePage("Status", isInTeam and 1 or 0)
	button:TryChangePage("isDead", isDead and 1 or 0)
	button:TryChangePage("button", 0)

	button.isSelected = false
end

function RogueUtils.playRevivalAnim(button)
	local objectReference = button:GetComponent("ObjectReference")
	local petRevivalAnim = objectReference:GetRefValue("petRevivalAnim")

	UIUtils.PlayAnimation(petRevivalAnim, "VX_Ani_Node_Tower_PetCard_Rebirth")
end

function RogueUtils.renderMonsterEffectItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textInfoUSDFText = objectReference:GetRefValue("textInfoUSDFText")

	iconUImage.url = data.buffEffectTag

	local name, _ = string.gsub(pg.getLocalizationText(data.buffName), "Hint_BgL", "Hint_BgD")

	ClientTextUtils.setText(textTitleUSDFText, name)

	local desc, _ = string.gsub(pg.getLocalizationText(data.buffDesc), "Hint_BgL", "Hint_BgD")

	ClientTextUtils.setText(textInfoUSDFText, desc)
end

function RogueUtils.renderMonsterEffect(uList, buffList)
	function uList.luaRenderItem(button, index, data)
		RogueUtils.renderMonsterEffectItem(button, index, data)
	end

	uList:SetList(buffList)
end

function RogueUtils.getCurRogueLevelMaxEquipmentCount()
	if pg.me.curRogueLevel == 0 then
		return 0
	end

	local levelInfo = RogueDifficultyData[pg.me.curRogueLevel]

	return levelInfo and levelInfo.equipTypeNum or 0
end

function RogueUtils.getCurRogueLevelTotalLayerCount()
	if pg.me.curRogueLevel == 0 then
		return 0
	end

	local levelInfo = RogueDifficultyData[pg.me.curRogueLevel]

	if not levelInfo then
		return 0
	end

	return RoguelikeData[levelInfo.roguelikeIDEnd].floor
end

function RogueUtils.setMoneyText(txt, needNum, ownNum)
	local enough = needNum <= ownNum
	local formatStr = enough and "%s/%s" or "<style=Debuff>%s/%s</style>"
	local str = string.format(formatStr, needNum, ownNum)

	ClientTextUtils.setText(txt, str)
end

function RogueUtils.getRandomStyleRealId()
	local styleInfo = pg.me.rogueInitSeriesInfo[Const.ROGUE_SERIES_SELECT_DELAY_VALUE]

	if not styleInfo then
		return nil
	end

	local buffId = styleInfo.buffInfo[1]
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	if not buffCfg then
		return nil
	end

	return buffCfg.buffSeries
end

function RogueUtils.refreshSelectedStyleInfo(uiCtrl, styleId, showReal)
	local styleCfg = RandomBuffSeriesName[styleId]

	if not styleCfg and styleId ~= Const.ROGUE_SERIES_SELECT_DELAY_VALUE then
		return
	end

	local styleInfo = pg.me.rogueInitSeriesInfo[styleId]

	if not styleInfo then
		return
	end

	if showReal then
		local buffCfg = RandomBuffData[styleInfo.buffInfo[1]] or ExtraRandomBuff[styleInfo.buffInfo[1]]

		styleCfg = RandomBuffSeriesName[buffCfg.buffSeries]
	end

	ClientTextUtils.setText(uiCtrl.view.styleMainUBaseText, pg.getGameString("ROGUE_STYLE_MAIN_BUFF"))

	local isRandomStyle = styleId == Const.ROGUE_SERIES_SELECT_DELAY_VALUE and not showReal

	uiCtrl.view.styleIconUComponent:TryChangePage("Equipment", isRandomStyle and 0 or 1)

	if styleCfg then
		uiCtrl.view.styleIconUImage.url = styleCfg.coreBuffIcon
		uiCtrl.view.styleIcon1UImage.url = styleCfg.coreBuffIcon

		ClientTextUtils.setText(uiCtrl.view.styleNameUBaseText, pg.getLocalizationText(styleCfg.preselectionName))
		ClientTextUtils.setText(uiCtrl.view.styleDescriptionUBaseText, pg.getLocalizationText(styleCfg.buffSeriesIntro))
		ClientTextUtils.setText(uiCtrl.view.styleMainBuffUBaseText, pg.getLocalizationText(styleCfg.coreBuffName))

		uiCtrl.view.equipmentAnimation:get_Item("VX_Ani_Node_Tower_Style_Item_In01").time = 0

		uiCtrl.view.equipmentAnimation:Play()
	else
		ClientTextUtils.setText(uiCtrl.view.styleNameUBaseText, pg.getGameString("ROGUE_RANDOM_STYLE_NAME"))
		ClientTextUtils.setText(uiCtrl.view.styleDescriptionUBaseText, pg.getGameString("ROGUE_RANDOM_STYLE_DESC"))
		ClientTextUtils.setText(uiCtrl.view.styleMainBuffUBaseText, pg.getGameString("ROGUE_RANDOM_STYLE_MAIN_BUFF"))

		uiCtrl.view.randomAnimation:get_Item("VX_Ani_Node_Tower_Style_Item_In02").time = 0

		uiCtrl.view.randomAnimation:Play()
	end

	local items = {}

	if styleId == Const.ROGUE_SERIES_SELECT_DELAY_VALUE and not showReal then
		for _, buffId in ipairs(styleInfo.buffInfo) do
			local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]
			local buffQuality = buffCfg.buffRarity or buffCfg.buffLv

			table.insert(items, {
				num = 1,
				type = 0,
				hideCount = true,
				id = Const.ROGUE_SERIES_SELECT_DELAY_SHOW_ITEMS[buffQuality + 1],
				typeText = pg.getGameString("ROGUE_RANDOM_STYLE_BATTLE")
			})
		end
	else
		for _, buffId in ipairs(styleInfo.buffInfo) do
			table.insert(items, {
				hideCount = true,
				num = 1,
				type = 2,
				id = buffId
			})
		end
	end

	for key, value in pairs(styleInfo.itemInfo) do
		table.insert(items, {
			hideCount = true,
			type = 0,
			id = key,
			num = value
		})
	end

	uiCtrl.view.styleItemUList:SetList(items)

	uiCtrl.view.tooltipUButton.enabledTooltip = styleCfg ~= nil

	function uiCtrl.view.tooltipUButton.luaRenderTooltip(button, popup)
		local tipId = styleCfg.coreBuffIconTip

		if tipId and ItemSourceData[tipId] then
			local title = pg.getLocalizationText(ItemSourceData[tipId].buttonTxt or "")
			local desc = pg.getLocalizationText(ItemSourceData[tipId].tips or "")

			LuaUIUtils.renderCommonSmallTip(popup, title, desc)
		end
	end
end

function RogueUtils.recoverBossCountDownTip()
	local paramStr = pg.global.prefsCacheUtils:getString(ClientConst.PrefKey.RogueBattleCountDown)

	if not string.isNilOrEmpty(paramStr) then
		local param = json.decode(paramStr)
		local startTime = param.saveStartTime
		local duration = param.saveDuration
		local tipType = tonumber(param.type) or 0
		local elapsed = math.max(0, Time.secondCache - startTime)

		if tipType == 0 then
			if duration <= elapsed then
				return
			end

			pg.global.ui.tips:showTimeViolentCountDown(duration - elapsed, nil, param)
		elseif tipType == 1 then
			if duration <= elapsed then
				param._violentState = 1

				pg.global.ui.tips:showTimeViolentCountDown(duration, nil, param)
			else
				pg.global.ui.tips:showTimeViolentCountDown(duration - elapsed, nil, param)
			end
		elseif tipType == 2 then
			if duration <= elapsed then
				param._violentState = 2
				param._violentLooping = true

				local loopDuration = param.loopTime or 1
				local loopElapsed = elapsed - duration

				param._violentLoopStartTime = Time.realSecondCache - loopElapsed % loopDuration
				param.isRecover = true

				pg.global.ui.tips:showTimeViolentCountDown(duration, nil, param)
			else
				pg.global.ui.tips:showTimeViolentCountDown(duration - elapsed, nil, param)
			end
		end
	end
end

function RogueUtils.isPetInRogue(petId)
	if pg.me and pg.me.selectRoguePets and pg.me.selectRoguePets[petId] then
		return true
	end

	return false
end

function RogueUtils.getMonsterEffect()
	if pg.me.curRogueLevel == 0 then
		return nil
	end

	if not pg.me.curRogueLayer or pg.me.curRogueLayer <= 0 then
		return nil
	end

	local levelCfg = RoguelikeData[pg.me.curRogueLayer]

	if levelCfg.randomEffectNum == nil or levelCfg.randomEffectNum <= 0 then
		return nil
	end

	local ids = pg.me.curRogueRoomAffixIds

	if ids == nil or #ids <= 0 then
		return nil
	end

	local buffId
	local buffList = {}
	local count = 0

	for _, id in ipairs(pg.me.curRogueRoomAffixIds) do
		if RogueRoomAffixesData[id] then
			buffId = RogueRoomAffixesData[id].buffId

			local buffCfg = BuffConfigData[buffId]

			if buffCfg then
				count = count + 1
				buffList[count] = {
					hasPlayFx = false,
					buffId = buffId,
					buffName = buffCfg.buffName,
					buffDesc = buffCfg.buffDesc,
					buffIcon = buffCfg.buffIcon,
					buffEffectTag = RogueRoomAffixesData[id].icon,
					buffQuality = buffCfg.buffRarity or buffCfg.buffLv,
					buffSeries = buffCfg.buffSeries,
					buffTagIcon = buffCfg.buffTagIcon
				}
			end
		end
	end

	return buffList
end

local _lastSeasonStage = {
	stageId = 1,
	seasonId = 1
}

function RogueUtils.getCurrentSeasonStage(seasonId)
	local now = Time.getSecond()
	local latestPast

	for id, info in ipairs(RougeSeasonData) do
		local startTime = Utils.getConfigTimeOfArea(info, "seasonStart")
		local endTime = Utils.getConfigTimeOfArea(info, "seasonEnd")

		if startTime and endTime and (seasonId ~= nil and seasonId == id or startTime <= now and now < endTime) then
			_lastSeasonStage = {
				seasonId = id,
				stageId = info.stageId,
				startDayTime = startTime,
				endDayTime = endTime
			}

			return _lastSeasonStage
		end
	end

	for id, info in ipairs(RougeSeasonData) do
		local startTime = Utils.getConfigTimeOfArea(info, "seasonStart")
		local endTime = Utils.getConfigTimeOfArea(info, "seasonEnd")

		if startTime and endTime and now < startTime and now < endTime then
			_lastSeasonStage = {
				seasonId = id,
				stageId = info.stageId,
				startDayTime = startTime,
				endDayTime = endTime
			}

			return _lastSeasonStage
		end
	end

	local lastInfo = RougeSeasonData[#RougeSeasonData]
	local startTime = Utils.getConfigTimeOfArea(lastInfo, "seasonStart")
	local endTime = Utils.getConfigTimeOfArea(lastInfo, "seasonEnd")

	latestPast = {
		seasonId = #RougeSeasonData,
		stageId = lastInfo.stageId,
		startDayTime = startTime,
		endDayTime = endTime
	}

	return latestPast or _lastSeasonStage
end

function RogueUtils.checkInReason()
	if pg.me.rogueSeasonId and pg.me.rogueSeasonId > 0 then
		return true
	end

	local season = RogueUtils.getCurrentSeasonStage()
	local now = Time.getSecond()

	if season.startDayTime and season.endDayTime and now >= season.startDayTime and now < season.endDayTime then
		return true
	end

	return false
end

function RogueUtils.log(str, ...)
	logger:info(str, ...)
end

function RogueUtils.logError(str, ...)
	logger:error(str, ...)
end

return RogueUtils
