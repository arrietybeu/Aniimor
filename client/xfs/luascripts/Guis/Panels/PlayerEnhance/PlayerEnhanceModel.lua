-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\PlayerEnhanceModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PlayerEnhanceModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PlayerEnhanceModel = Class.LightClass("PlayerEnhanceModel", UIModel)
local AbilityConst = require("Common.Const.AbilityConst")
local SkillTreeData = require("Data.player_skill_tree_data")
local SkillData = require("Data.player_skill_data")
local LevelData = require("Data.player_level_data")
local TitleData = require("Data.player_title_data")
local PetData = require("Data.pet_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local PetAvatarData = require("Data.pet_avatar_data")
local SysConfigData = require("Data.sys_config_data")
local ItemConst = require("Common.Const.ItemConst")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientConst = require("Const.ClientConst")
local PlayerSkillReverseData = require("Data.player_skill_reverse_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local ShowTitleUtils = require("Utils.ShowTitleUtils")
local PlayerTitleData = require("Data.player_title_data")

PlayerEnhanceModel.ACTIVE_SKILL_ROW_COUNT = 6
PlayerEnhanceModel.ACTIVE_SKILL_COL_COUNT = 5
PlayerEnhanceModel.PASSIVE_SKILL_ROW_COUNT = 6
PlayerEnhanceModel.PASSIVE_SKILL_COL_COUNT = 7
PlayerEnhanceModel.MAX_LEVEL = 6
PlayerEnhanceModel.SKILL_STATE = {
	CANT_UNLOCK_CONDITION_NOT_MEET = 2,
	CANT_UNLOCK_LEVEL_INSUFFICIENT = 1,
	NEED_TURN_POSITIVE = 8,
	MAX_LEVEL = 7,
	CAN_UPGRADE = 6,
	CANT_UPGRADE_CONDITION_NOT_MEET = 5,
	CANT_UPGRADE_LEVEL_INSUFFICIENT = 4,
	CAN_UNLOCK = 3
}
PlayerEnhanceModel.RANK_STATE = {
	WAITING = 2,
	CANT_UPGRADE = 1,
	CAN_UPGRADE = 3,
	MAX_RANK = 4
}
PlayerEnhanceModel.STATE_NAME = {
	[PlayerEnhanceModel.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT] = "UNLOCK_PLAYER_ENHANCE",
	[PlayerEnhanceModel.SKILL_STATE.CAN_UNLOCK] = "LEARN",
	[PlayerEnhanceModel.SKILL_STATE.CANT_UPGRADE_LEVEL_INSUFFICIENT] = "UNLOCK_PLAYER_ENHANCE",
	[PlayerEnhanceModel.SKILL_STATE.CAN_UPGRADE] = "UPGRADE",
	[PlayerEnhanceModel.SKILL_STATE.MAX_LEVEL] = "FULL_LEVEL",
	[PlayerEnhanceModel.SKILL_STATE.NEED_TURN_POSITIVE] = "TURN_POSITIVE"
}
PlayerEnhanceModel.SKILL_TYPE = {
	SPECIAL = 4,
	EXPLORE = 3,
	PASSIVE = 2,
	COMBATS = 1
}
PlayerEnhanceModel.SKILL_TYPE_NAME = {
	[AbilityConst.SKILL_TYPE.COMBATS] = "PLAYER_SKILLS_1",
	[AbilityConst.SKILL_TYPE.PASSIVE] = "PLAYER_SKILLS_2",
	[AbilityConst.SKILL_TYPE.EXPLORE] = "PLAYER_SKILLS_3",
	[AbilityConst.SKILL_TYPE.SPECIAL] = "PLAYER_SKILLS_4"
}
PlayerEnhanceModel.LEVEL_AWARD_STATE = {
	CAN_RECEIVE = 2,
	LOCKED = 1,
	HAS_RECEIVED = 3
}
PlayerEnhanceModel.MODEL_STATE = {
	SKILL_TREE = 2,
	MAIN_PAGE = 1,
	BADGE_PAGE = 4,
	SKILL_EQUIP = 3
}
PlayerEnhanceModel.SKILL_TREE_COL = {
	[AbilityConst.SKILL_TYPE.COMBATS] = {
		1,
		2
	},
	[AbilityConst.SKILL_TYPE.PASSIVE] = {
		3,
		4,
		5,
		6,
		7,
		8
	}
}
PlayerEnhanceModel.EXPLORE_SKILL_TITLE = {
	"CLIMB",
	"GLIDE",
	"SWIM"
}
PlayerEnhanceModel.EXPLORE_SKILL_FIELD = {
	"canClimb",
	"canGlide",
	"canSwim"
}
PlayerEnhanceModel.HIDE_LEVEL = 1

function PlayerEnhanceModel:getPlayerBaseInfo()
	local me = pg.me
	local res = {
		name = me.playerName,
		star = me.starTitle,
		lv = me.level,
		curExp = me.exp,
		starName = LuaUIUtils.getStarTitleNameForIcon(me.starTitle),
		fullStarName = LuaUIUtils.getStarTitleName(me.starTitle, true)
	}
	local cData = LevelData[res.lv]

	res.maxPetLv = me:getMaxControlLevel() or 15
	cData = LevelData[res.lv + 1]

	if cData == nil then
		cData = LevelData[res.lv]
	end

	if cData then
		res.maxExp = cData.needExp
	end

	res.icon = LuaUIUtils.getStarIcon(me.starTitle)

	return res
end

function PlayerEnhanceModel:getRowCount()
	return #TitleData
end

function PlayerEnhanceModel:getTreeHeadList()
	local res = {}
	local maxLevel = self:getRowCount()

	for i = 1 + PlayerEnhanceModel.HIDE_LEVEL, maxLevel do
		table.insert(res, {
			star = i,
			icon = LuaUIUtils.getStarIcon(i),
			starName = LuaUIUtils.getStarTitleNameForIcon(i)
		})

		if i ~= maxLevel then
			table.insert(res, {
				tIndex = 1
			})
		end
	end

	return res
end

function PlayerEnhanceModel:getTreeLearnPointDataList(type)
	local items = {}

	for k, v in pairs(SkillTreeData) do
		if v.abilityType == type then
			local node = pg.me.skillNodeMap[k] or {
				lv = 0
			}

			for _Lv, sk in pairs(SkillData[k]) do
				local cItems = sk.needItem or {}

				for id, num in pairs(cItems) do
					if items[id] == nil then
						items[id] = {
							max = 0,
							use = 0
						}
					end

					items[id].max = items[id].max + num

					if _Lv <= node.lv then
						items[id].use = items[id].use + num
					end
				end
			end
		end
	end

	local res = {}

	for id, v in pairs(items) do
		res[#res + 1] = {
			id = id,
			use = v.use,
			max = v.max,
			icon = LuaUIUtils.getIconByItemId(id)
		}
	end

	return res
end

function PlayerEnhanceModel:getSkillTreeDataList(type)
	local res = {}
	local columns = self.SKILL_TREE_COL[type]

	if not columns then
		return res
	end

	local isActiveSkill = AbilityConst.SKILL_TYPE.COMBATS == type
	local colNum = #columns
	local minCol = columns[1]
	local rowNum = self:getRowCount()

	for k, v in pairs(SkillTreeData) do
		if self:checkSkillInColumns(v, columns) then
			local curRow = v.row - PlayerEnhanceModel.HIDE_LEVEL

			res[curRow] = res[curRow] or {}

			local hasLearnId = SkillData[k] and SkillData[k][1].learnAbilityId
			local item = {
				isEmpty = false,
				id = k,
				abilityType = v.abilityType,
				maxLv = v.maxLv,
				row = curRow,
				col = v.column,
				active = isActiveSkill,
				tIndex = isActiveSkill and hasLearnId == nil and 1 or 0
			}

			self:parseSkillInfo(item)
			self:parseSkillKeyBoard(item)

			res[curRow][v.column - minCol + 1] = item
		end
	end

	for i = 1, rowNum do
		if res[i] == nil then
			res[i] = {}
		end

		for j = 1, colNum do
			if res[i][j] == nil then
				res[i][j] = {
					isEmpty = true
				}
			end
		end
	end

	return res
end

function PlayerEnhanceModel:refreshSkillTreeDataList(dataList)
	local max = dataList.Count - 1

	for i = 0, max do
		local colMax = #dataList[i]

		for j = 1, colMax do
			local item = dataList[i][j]

			self:parseSkillInfo(item)
		end
	end
end

function PlayerEnhanceModel:getSkillDataWithLv(skillId, level)
	local cData = SkillTreeData[skillId]

	if cData == nil then
		return nil
	end

	local item = {
		active = false,
		isEmpty = false,
		id = skillId,
		abilityType = cData.abilityType,
		maxLv = cData.maxLv,
		row = cData.row,
		col = cData.column
	}

	self:parseSkillInfo(item, level)
	self:parseSkillKeyBoard(item)

	return item
end

function PlayerEnhanceModel:parseSkillInfo(item, fixedLv)
	if item.isEmpty then
		return
	end

	local k = item.id
	local v = SkillTreeData[k]

	item.abilityType = v.abilityType
	item.isActiveSkill = v.abilityType == AbilityConst.SKILL_TYPE.COMBATS
	item.isRare = v.isRare == 1
	item.cornerMark = v.iconTxt

	local me = pg.me
	local nData = me.skillNodeMap[k]
	local curLv = 0
	local nextLv = 0

	if nData then
		curLv = nData.lv
		nextLv = curLv + 1
	else
		curLv = 0
		nextLv = 1
	end

	if fixedLv then
		curLv = fixedLv
		nextLv = fixedLv + 1
	end

	item.level = curLv
	item.nextLv = nextLv
	item.maxLv = v.maxLv or item.level

	local cLevel = curLv == 0 and 1 or curLv
	local sData = SkillData[k][cLevel] or {}

	item.attrs = {}

	if sData.learnAbilityId then
		local abParam = pg.global.abilityMgr:getAbilityParamData(sData.learnAbilityId or 0)

		if abParam then
			item.icon = LuaUIUtils.getSkillIcon(abParam.icon)
			item.name = pg.getLocalizationText(abParam.name)
			item.attrs[#item.attrs + 1] = {
				tIndex = 1,
				name = abParam.cd
			}
		end
	else
		item.icon = LuaUIUtils.getSkillIcon(v.icon)
		item.name = pg.getLocalizationText(sData.name)
	end

	local attr2 = {
		tIndex = 0
	}

	item.attrs[#item.attrs + 1] = attr2

	if string.isNilOrEmpty(v.typeName) then
		attr2.name = pg.getGameString(self.SKILL_TYPE_NAME[item.abilityType])
	else
		attr2.name = pg.getLocalizationText(v.typeName)
	end

	item.realId = sData.learnAbilityId

	local video
	local configData = pg.me:getConfigData()
	local gender = pg.me.gender or configData.gender

	if gender == 1 then
		video = sData.videoM
	else
		video = sData.videoF
	end

	if string.isNilOrEmpty(video) then
		video = sData.video
	end

	item.video = video

	if pg.game.setting:getShowDebugId() then
		item.name = string.format("%s - %d - %d", item.name, k, curLv)
	end

	if sData.desc then
		item.desc = pg.getLocalizationText(sData.desc) or "Empty!"
	end

	local upDescList = {}

	if sData.diffName1 then
		upDescList[#upDescList + 1] = {
			tIndex = 1,
			name = pg.getLocalizationText(sData.diffName1),
			cur = pg.getLocalizationText(sData.diffValueBefore1),
			next = pg.getLocalizationText(sData.diffValueAfter1)
		}
	end

	if sData.diffName2 then
		upDescList[#upDescList + 1] = {
			tIndex = 1,
			name = pg.getLocalizationText(sData.diffName2),
			cur = pg.getLocalizationText(sData.diffValueBefore2),
			next = pg.getLocalizationText(sData.diffValueAfter2)
		}
	end

	if sData.diffName3 then
		upDescList[#upDescList + 1] = {
			tIndex = 1,
			name = pg.getLocalizationText(sData.diffName3),
			cur = pg.getLocalizationText(sData.diffValueBefore3),
			next = pg.getLocalizationText(sData.diffValueAfter3)
		}
	end

	if #upDescList > 0 then
		table.insert(upDescList, 1, {
			tIndex = 0,
			name = pg.getGameString("LEVEL_UP_GAIN")
		})
	end

	if curLv == 0 then
		table.clear(upDescList)
	end

	item.upDescList = upDescList

	local consume = {}
	local nextData = SkillData[k][nextLv] or {}
	local consumeItems = nextData.needItem or {}

	for id, num in pairs(consumeItems) do
		consume[#consume + 1] = {
			id = id,
			name = LuaUIUtils.getNameByItemId(id),
			icon = LuaUIUtils.getIconByItemId(id),
			num = num,
			ownNum = ItemUtils.getItemCountById(me, id)
		}
	end

	item.consume = consume

	self:parseConditionTrigger(item)
	self:parseSkillState(item)
end

function PlayerEnhanceModel:parseConditionTrigger(item)
	local me = pg.me
	local needCondition = true
	local triggerNum = 0
	local nextData = SkillData[item.id][item.nextLv] or {}

	for idx, tId in ipairs(nextData.customTriggerId or EMPTY_TABLE) do
		if triggerNum == 0 then
			item.upDescList[#item.upDescList + 1] = {
				tIndex = 0,
				name = pg.getGameString("LEVEL_UP_CONDITION")
			}
		end

		local trigger = {
			tIndex = 2,
			id = tId
		}
		local finishedCount = me.triggerMap:getConditionFinishCount(tId, 1)

		trigger.finishedCount = finishedCount

		local ctData = CustomTriggerData[tId]

		if ctData then
			trigger.name = pg.getLocalizationText(ctData.note)
		end

		local mData = nextData.customTriggerConditionNum

		if mData then
			trigger.max = mData[idx]
		end

		local finished = finishedCount >= trigger.max

		trigger.finished = finished
		needCondition = needCondition and finished

		if not needCondition then
			item.noMatchDesc = trigger.name
		end

		triggerNum = triggerNum + 1
		item.upDescList[#item.upDescList + 1] = trigger
	end

	if needCondition then
		for _, v in ipairs(item.consume) do
			if v.num > v.ownNum then
				needCondition = false

				break
			end
		end
	end

	item.needCondition = needCondition
end

function PlayerEnhanceModel:parseSkillState(item)
	item.state = self:getSkillState(item)
end

function PlayerEnhanceModel:parseSkillKeyBoard(item, abilities)
	if item.abilityType ~= AbilityConst.SKILL_TYPE.COMBATS then
		return
	end

	if abilities == nil then
		abilities = {}

		for i, v in pairs(pg.me.curAbilityMap) do
			abilities[i] = v.abilityId
		end
	end

	item.keyBoard = nil

	for qe, id in pairs(abilities) do
		if PlayerSkillReverseData[id] == item.id and qe < AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T then
			item.keyBoard = AbilityConst.PLAYER_ABILITY_HOTKEY[qe]

			break
		end
	end
end

function PlayerEnhanceModel:parseSkillFixedKeyBoard(item)
	item.fixedKeyBoard = AbilityConst.PLAYER_ABILITY_HOTKEY[item.index or 1]
end

function PlayerEnhanceModel:checkSkillInColumns(data, columns)
	if data.row == nil or data.column == nil then
		return false
	end

	if data.row <= PlayerEnhanceModel.HIDE_LEVEL then
		return false
	end

	if not table.contains(columns, data.column) then
		return false
	end

	return true
end

function PlayerEnhanceModel:parseColumnIndex(data, columns)
	if data.row == nil or data.column == nil then
		return false, 0
	end

	if not table.contains(columns, data.column) then
		return false, 0
	end

	local min = 999

	for _, v in ipairs(columns) do
		if v < min then
			min = v
		end
	end

	local diff = min - 1
	local colNum = #columns
	local index = (data.row - 1) * colNum + data.column - diff

	return true, index
end

function PlayerEnhanceModel:getEquipSkillList(isCombat)
	local scheme = isCombat and (pg.me.fightCustomAbilityIds[pg.me.fightCustomIndex or 1] or {}) or pg.me.exploreCustomAbilityIds[pg.me.exploreCustomIndex or 1] or {}
	local filter = self:parseFilter()
	local res = {}

	for k, v in pairs(SkillTreeData) do
		if v.abilityType == AbilityConst.SKILL_TYPE.COMBATS then
			local item = {
				isEmpty = false,
				id = k,
				abilityType = v.abilityType,
				maxLv = v.maxLv,
				row = v.row,
				col = v.column
			}

			self:parseSkillInfo(item)
			self:parseSkillKeyBoard(item, scheme.abilityIds)

			if self:checkSkillValidWithFilter(item, filter) then
				res[#res + 1] = item
			end
		end
	end

	local orders = self:parseOrders()

	table.sort(res, function(a, b)
		if a.state ~= b.state then
			return a.state > b.state
		end

		if orders[2].select and a.id ~= b.id then
			return a.id > b.id
		end

		if orders[3].select and a.isRare ~= b.isRare then
			return a.isRare
		end

		return a.state > b.state
	end)

	local additionNum = 15 - #res

	if additionNum > 0 then
		for i = 1, additionNum do
			table.insert(res, {
				isEmpty = true
			})
		end
	end

	return res
end

function PlayerEnhanceModel:refreshEquipSkillList(isCombat, dataList)
	local scheme = isCombat and (pg.me.fightCustomAbilityIds[pg.me.fightCustomIndex or 1] or {}) or pg.me.exploreCustomAbilityIds[pg.me.exploreCustomIndex or 1] or {}
	local max = dataList.Count - 1

	for i = 0, max do
		local item = dataList[i]

		self:parseSkillInfo(item)
		self:parseSkillKeyBoard(item, scheme.abilityIds)
	end
end

function PlayerEnhanceModel:getEquipSkillItemIndex(dataList, id)
	local index = 0
	local max = dataList.Count - 1

	for i = 0, max do
		local item = dataList[i]

		if item.id == id then
			index = i
		end
	end

	return index
end

function PlayerEnhanceModel:getEquippedSkillList(isCombat, defaultId)
	local res = {}
	local defIndex = 1
	local scheme = isCombat and (pg.me.fightCustomAbilityIds[pg.me.fightCustomIndex or 1] or {}) or pg.me.exploreCustomAbilityIds[pg.me.exploreCustomIndex or 1] or {}

	for i = 1, 2 do
		local record = scheme.abilityIds and scheme.abilityIds[i]
		local item = {
			isEquippedData = true,
			abilityType = AbilityConst.SKILL_TYPE.COMBATS,
			index = i,
			isCombat = isCombat
		}

		if record and record ~= 0 then
			local treeId = PlayerSkillReverseData[record] or 0

			item.id = treeId
			item.isEmpty = false

			self:parseSkillInfo(item)
			self:parseSkillKeyBoard(item, scheme.abilityIds)

			if treeId == defaultId then
				defIndex = i
			end
		else
			item.isEmpty = true
		end

		self:parseSkillFixedKeyBoard(item)

		if i == AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T then
			item.locked = true
		end

		res[i] = item
	end

	return res, defIndex
end

function PlayerEnhanceModel:refreshEquippedSkillList(isCombat, dataList)
	local scheme = isCombat and (pg.me.fightCustomAbilityIds[pg.me.fightCustomIndex or 1] or {}) or pg.me.exploreCustomAbilityIds[pg.me.exploreCustomIndex or 1] or {}

	for i = 1, 2 do
		local record = scheme.abilityIds and scheme.abilityIds[i]
		local treeId = PlayerSkillReverseData[record] or 0
		local item = dataList[i - 1]

		if treeId and treeId ~= 0 then
			item.id = treeId
			item.isEmpty = false

			self:parseSkillInfo(item)
			self:parseSkillKeyBoard(item, scheme.abilityIds)
		else
			item.isEmpty = true
			item.id = nil
			item.realId = nil
		end
	end
end

function PlayerEnhanceModel:getLearnDataList()
	local res = {}

	for i, v in ipairs(SysConfigData.skillItemIds) do
		res[i] = {
			id = v,
			num = ItemUtils.getItemCountById(pg.me, v),
			icon = LuaUIUtils.getIconByItemId(v)
		}
	end

	return res
end

function PlayerEnhanceModel:getSkillState(item)
	local skillId = item.id
	local skillData = SkillData[skillId]

	if skillData == nil then
		return self.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT
	end

	local me = pg.me
	local node = me.skillNodeMap[skillId]

	if node == nil then
		local lv1Data = skillData[1]
		local needTitle = lv1Data.needTitle or 1

		if needTitle > me.starTitle then
			item.noMatchDesc = LuaUIUtils.getStarTitleName(lv1Data.needTitle, true)

			return self.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT
		else
			if not item.needCondition then
				return self.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET
			end

			return self.SKILL_STATE.CAN_UNLOCK
		end
	end

	if node.lv >= (SkillTreeData[skillId] or {
		maxLv = 0
	}).maxLv then
		return self.SKILL_STATE.MAX_LEVEL
	else
		local nextLv = node.lv + 1
		local nextData = skillData[nextLv] or {}
		local needTitle = nextData.needTitle or 1

		if needTitle > me.starTitle then
			item.noMatchDesc = LuaUIUtils.getStarTitleName(needTitle, true)

			return self.SKILL_STATE.CANT_UPGRADE_LEVEL_INSUFFICIENT
		else
			if not item.needCondition then
				return self.SKILL_STATE.CANT_UPGRADE_CONDITION_NOT_MEET
			end

			return self.SKILL_STATE.CAN_UPGRADE
		end
	end
end

function PlayerEnhanceModel:getCurSkillIndex(isCombat)
	return isCombat and pg.me.fightCustomIndex or pg.me.exploreCustomIndex
end

function PlayerEnhanceModel:getDefaultGroupName(isCombat)
	return isCombat and "COMBAT_SKILL_GROUP" or "EXPLORE_SKILL_GROUP"
end

function PlayerEnhanceModel:getGroupName(isCombat)
	local curIndex = isCombat and pg.me.fightCustomIndex or pg.me.exploreCustomIndex
	local abilities = isCombat and pg.me.fightCustomAbilityIds or pg.me.exploreCustomAbilityIds
	local defaultName = pg.getGameString(self:getDefaultGroupName(isCombat))
	local v = abilities[curIndex] or {}
	local name = string.isNilOrEmpty(v.name) and defaultName or v.name

	return name
end

function PlayerEnhanceModel:getSkillGroupOptions(isCombat)
	local options = {}
	local me = pg.me
	local abilities = isCombat and me.fightCustomAbilityIds or me.exploreCustomAbilityIds
	local useIndex = isCombat and me.fightCustomIndex or me.exploreCustomIndex
	local defaultName = pg.getGameString(self:getDefaultGroupName(isCombat))
	local index = 1

	for _, v in pairs(abilities) do
		local option = {
			index = index,
			label = string.isNilOrEmpty(v.name) and ClientTextUtils.concatByLanguage(defaultName, index) or v.name,
			canDelete = index > 1 and index ~= useIndex
		}

		options[index] = option
		index = index + 1
	end

	local maxCount = isCombat and SysConfigData.fightCustomAbilityIdsMaxCount or SysConfigData.exploreCustomAbilityIdsMaxCount

	if maxCount > #options then
		table.insert(options, {
			add = true
		})
	end

	return options
end

function PlayerEnhanceModel:checkSkillValidWithFilter(item, filter)
	if not filter then
		return true
	end

	if filter.rareMode > 0 and filter.rareMode <= 3 then
		if item.isRare then
			if bit.band(filter.rareMode, bit.lshift(1, 1)) == 0 then
				return false
			end
		elseif bit.band(filter.rareMode, bit.lshift(1, 0)) == 0 then
			return false
		end
	end

	if filter.state > 0 and filter.state <= 7 then
		if item.state == self.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT or item.state == self.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET then
			if bit.band(filter.state, bit.lshift(1, 2)) == 0 then
				return false
			end
		elseif item.state == self.SKILL_STATE.CAN_UNLOCK then
			if bit.band(filter.state, bit.lshift(1, 1)) == 0 then
				return false
			end
		elseif bit.band(filter.state, bit.lshift(1, 0)) == 0 then
			return false
		end
	end

	return true
end

function PlayerEnhanceModel:initFilter()
	self.filter = {
		orders = {
			{
				select = true,
				label = pg.getGameString("DEFAULT_ORDER")
			},
			{
				select = false,
				label = pg.getGameString("ORDER_BY_ID")
			},
			{
				select = false,
				label = pg.getGameString("ORDER_BY_QUALITY")
			}
		},
		{
			name = pg.getGameString("RARITY"),
			{
				select = false,
				optionName = pg.getGameString("RARE"),
				bit = bit.lshift(1, 0)
			},
			{
				select = false,
				optionName = pg.getGameString("NORMAL"),
				bit = bit.lshift(1, 1)
			}
		},
		{
			name = pg.getGameString("STATE"),
			{
				select = false,
				optionName = pg.getGameString("LEARNED"),
				bit = bit.lshift(1, 0)
			},
			{
				select = false,
				optionName = pg.getGameString("UNLEARN"),
				bit = bit.lshift(1, 1)
			},
			{
				select = false,
				optionName = pg.getGameString("LOCKED"),
				bit = bit.lshift(1, 2)
			}
		}
	}
end

function PlayerEnhanceModel:getFilter()
	if self.filter == nil then
		self:initFilter()
	end

	return self.filter
end

function PlayerEnhanceModel:parseFilter()
	local filter = self:getFilter()
	local res = {
		rareMode = 0,
		state = 0
	}
	local isNoFilter = true

	for _, v in ipairs(filter[1]) do
		if v.select then
			res.rareMode = res.rareMode + v.bit
			isNoFilter = false
		end
	end

	for _, v in ipairs(filter[2]) do
		if v.select then
			res.state = res.state + v.bit
			isNoFilter = false
		end
	end

	if isNoFilter then
		return false
	end

	return res
end

function PlayerEnhanceModel:parseOrders()
	local filter = self:getFilter()

	return filter.orders
end

function PlayerEnhanceModel:selectOrder(index)
	local orders = self:parseOrders()

	for i, v in ipairs(orders) do
		v.select = i == index + 1
	end
end

function PlayerEnhanceModel:getSelectOrderIndex()
	local index = 0
	local orders = self:parseOrders()

	for i, v in ipairs(orders) do
		if v.select then
			index = i - 1

			break
		end
	end

	return index
end

function PlayerEnhanceModel:parseOrderName()
	local orders = self:parseOrders()
	local orderName = ""

	for _, v in ipairs(orders) do
		if not string.isNilOrEmpty(orderName) then
			orderName = orderName .. "..."

			break
		end

		if v.select then
			orderName = v.label
		end
	end

	if string.isNilOrEmpty(orderName) then
		orderName = pg.getGameString("DEFAULT_ORDER")
	end

	return orderName
end

function PlayerEnhanceModel:clearFilter()
	self:initFilter()
end

function PlayerEnhanceModel:getExplorePetList()
	local dataList = {}
	local serverList = pg.global.ui.petManagement.model:getPetExploreGroupPetsInModel()

	for i = 1, 3 do
		local pId = serverList[i]
		local item = {
			index = i
		}

		if not string.isNilOrEmpty(pId) then
			item.isEmpty = false

			self:parsePetInfo(pId, item, i)
		else
			item.isEmpty = true
		end

		dataList[i] = item
	end

	return dataList
end

function PlayerEnhanceModel:parsePetInfo(petId, item, index)
	local pInfo = pg.me:getPetInfo(petId)

	if pInfo == nil then
		return
	end

	item.name = LuaUIUtils.getPetName(petId)
	item.id = petId
	item.shine = Utils.isLabelShiny(pInfo.label)
	item.templateId = pInfo.templateId

	local cData = PetData[pInfo.templateId]

	if cData == nil then
		return
	end

	item.icon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, pInfo.label)

	local pName = AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[index] or ""

	item.exploreData = {
		{
			index = index,
			propertyLv = cData[pName] or 0
		}
	}
end

function PlayerEnhanceModel:redDot_CheckSaveDirty()
	if self.redDotDirty then
		pg.global.prefsCacheUtils:save()
	end
end

function PlayerEnhanceModel:redDot_GetPlayerTreeTrListItemState(data)
	local showRedDot = false

	if data.state and data.state ~= self.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT then
		local record = pg.me:getRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.PLAYER_TREE_LIST .. data.id, true)

		showRedDot = record and not data.selected
	end

	return showRedDot
end

function PlayerEnhanceModel:redDot_SetPlayerTreeTrListItemState(data)
	if data.state and data.state ~= self.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT then
		self.redDotDirty = true

		pg.me:setRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.PLAYER_TREE_LIST .. data.id, false)
		self:redDot_SetPlayerTabTreeState()
		self:redDot_SetPlayerFuncMenuTreeState()
		self:redDot_SetPlayerHUDTreeState()
	end
end

function PlayerEnhanceModel:redDot_GetPlayerTreeItemNum()
	local dotNum = 0

	for _, tp in pairs(AbilityConst.SKILL_TYPE) do
		local dataList = self:getSkillTreeDataList(tp)

		for _, v in ipairs(dataList) do
			for _, data in ipairs(v) do
				if self:redDot_GetPlayerTreeTrListItemState(data) then
					dotNum = dotNum + 1
				end
			end
		end
	end

	return dotNum
end

function PlayerEnhanceModel:redDot_GetPlayerTabTreeState()
	local dotNum = self:redDot_GetPlayerTreeItemNum()
	local oldNum = pg.me:getRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.PLAYER_TAB_TREE, 0)

	return oldNum ~= dotNum
end

function PlayerEnhanceModel:redDot_SetPlayerTabTreeState()
	self.redDotDirty = true

	local dotNum = self:redDot_GetPlayerTreeItemNum()

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.PLAYER_TAB_TREE, dotNum)
end

function PlayerEnhanceModel:redDot_GetPlayerFuncMenuTreeState()
	local dotNum = self:redDot_GetPlayerTreeItemNum()
	local oldNum = pg.me:getRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.FUNC_MENU_PLAYER, 0)

	return oldNum < dotNum
end

function PlayerEnhanceModel:redDot_SetPlayerFuncMenuTreeState()
	local dotNum = self:redDot_GetPlayerTreeItemNum()

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.FUNC_MENU_PLAYER, dotNum)
end

function PlayerEnhanceModel:redDot_GetPlayerHUDTreeState()
	local dotNum = self:redDot_GetPlayerTreeItemNum()
	local oldNum = pg.global.prefsCacheUtils:getInt(RedDotConst.RedDotPath.FUNC_MENU, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	return oldNum < dotNum
end

function PlayerEnhanceModel:redDot_SetPlayerHUDTreeState()
	local dotNum = self:redDot_GetPlayerTreeItemNum()

	pg.global.prefsCacheUtils:setInt(RedDotConst.RedDotPath.FUNC_MENU, dotNum, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PlayerEnhanceModel:redDot_CheckHasSkillCanEquip(isCombat)
	local me = pg.me
	local scheme = isCombat and (me.fightCustomAbilityIds[me.fightCustomIndex or 1] or {}) or me.exploreCustomAbilityIds[me.exploreCustomIndex or 1] or {}
	local equipNum = 0

	for _, v in pairs(scheme.abilityIds or EMPTY_TABLE) do
		if v and v ~= 0 then
			equipNum = equipNum + 1
		end
	end

	local unLockNum = 0

	for k, v in pairs(SkillTreeData) do
		if v.abilityType == AbilityConst.SKILL_TYPE.COMBATS then
			local node = me.skillNodeMap[k]

			if node then
				unLockNum = unLockNum + 1
			end
		end
	end

	return equipNum < unLockNum and equipNum < 2
end

function PlayerEnhanceModel:redDot_GetPlayerMainEquipState(data)
	return data.isEmpty and self:redDot_CheckHasSkillCanEquip(data.isCombat)
end

function PlayerEnhanceModel:redDot_CheckHasPetCanEquip(index)
	local ownPets = {}
	local pets = pg.me.pets

	for _, v in pairs(pets) do
		local cData = PetData[v.templateId]

		if cData and cData[self.EXPLORE_SKILL_FIELD[index]] then
			ownPets[v.id] = true
		end
	end

	local serverList = pg.me.petExploreList
	local matchPet = string.isNilOrEmpty(serverList[index]) and table.nums(ownPets) > 0

	return matchPet
end

function PlayerEnhanceModel:redDot_GetPlayerMainPetState(data)
	return data.isEmpty and self:redDot_CheckHasPetCanEquip(data.index)
end

function PlayerEnhanceModel:redDot_GetPointDotState()
	local dataList = self:getEquippedSkillList(true)

	table.mergeList(dataList, self:getEquippedSkillList(false))

	for _, v in ipairs(dataList) do
		if self:redDot_GetPlayerMainEquipState(v) then
			return true
		end
	end

	return false
end

function PlayerEnhanceModel:redDot_CheckCanStarUP()
	local nextTitle = pg.me.starTitle + 1

	return pg.global.ui.playerLvReward.model:redDot_CheckCanUPForCurTitle(nextTitle)
end

function PlayerEnhanceModel:redDot_GetFuncMenuPlayerState()
	if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PLAYERENHANCEMENT) then
		return RedDotConst.RedDotStyle.NONE
	end

	if pg.global.ui.playerLvReward.model:redDot_CheckHasLvTitleReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self:redDot_CheckCanStarUP() then
		return RedDotConst.RedDotStyle.POINT
	end

	if self:redDot_GetPointDotState() then
		return RedDotConst.RedDotStyle.POINT
	end

	if self:redDot_GetPlayerFuncMenuTreeState() then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function PlayerEnhanceModel:redDot_GetHUDPlayerState()
	if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PLAYERENHANCEMENT) then
		return RedDotConst.RedDotStyle.NONE
	end

	if pg.global.ui.playerLvReward.model:redDot_CheckHasLvTitleReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self:redDot_CheckCanStarUP() then
		return RedDotConst.RedDotStyle.UP_SIGN
	end

	if self:redDot_GetPointDotState() then
		return RedDotConst.RedDotStyle.POINT
	end

	if self:redDot_GetPlayerHUDTreeState() then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function PlayerEnhanceModel:getListTabData()
	local badgeTabIsUnlock = BadgeUtils.checkHasAnyBadgeTypeIsUnlock()
	local data = {}

	data[#data + 1] = {
		tIndex = 0,
		tabIndex = 0,
		tabName = pg.getGameString("PERSONAL_TAB_0"),
		setRedDot = function(btn)
			self:setMainTabRedDot(btn)
		end
	}

	if badgeTabIsUnlock then
		data[#data + 1] = {
			tIndex = 1,
			tabIndex = 1,
			tabName = pg.getGameString("PERSONAL_TAB_BADGE"),
			setRedDot = function(btn)
				self:setBadgeTabRedDot(btn)
			end
		}
	end

	data[#data + 1] = {
		tIndex = 2,
		tabIndex = 2,
		tabName = pg.getGameString("PERSONAL_TAB_1"),
		setRedDot = function(btn)
			self:setSkillEquipTabRedDot(btn)
		end
	}

	return data
end

function PlayerEnhanceModel:setMainTabRedDot(button)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PLAYER_REWARD, button, function()
		if pg.global.ui.playerLvReward.model:redDot_CheckHasLvReward() then
			return RedDotConst.RedDotStyle.REWARD
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function PlayerEnhanceModel:setBadgeTabRedDot(button)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PLAYER_BADGE_TAB, button, function()
		if BadgeUtils.checkHasNewUnlockBadge() then
			return RedDotConst.RedDotStyle.NEW
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function PlayerEnhanceModel:setSkillEquipTabRedDot(button)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PLAYER_TAB_TREE, button, function()
		if self:redDot_GetPlayerTabTreeState() then
			return RedDotConst.RedDotStyle.NEW
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function PlayerEnhanceModel:getBadgeTabData()
	local data = {}

	for k, v in pairs(BadgeUtils.BADGE_TYPE) do
		if v ~= BadgeUtils.BADGE_TYPE.SPECIAL_PATH then
			table.insert(data, {
				tabIndex = v,
				isUnlock = BadgeUtils.checkBadgeTypeIsUnlock(v)
			})
		end
	end

	table.sort(data, function(a, b)
		return a.tabIndex < b.tabIndex
	end)

	return data
end

function PlayerEnhanceModel.getBadgeNumByTab(tabIndex)
	return BadgeUtils.getBadgeNumByTab(tabIndex)
end

function PlayerEnhanceModel.getBadgeTabIconByTab(tabIndex)
	return BadgeUtils.TYPE_ICON[tabIndex]
end

function PlayerEnhanceModel.getMeTitle()
	local titleText = ShowTitleUtils.getShowTitleText(pg.me.showTitles, pg.me.showTitleExtra, pg.me.isWholeTitle)

	return string.isNilOrEmpty(titleText) and pg.getGameString("SHOW_TITLES_EMPTY") or titleText
end

function PlayerEnhanceModel.getStarSectionId()
	local curStarTitle = pg.me.starTitle or 0
	local nextTitle = curStarTitle + 1
	local cData = PlayerTitleData[nextTitle]

	if cData then
		local curStarQuestId = cData.quest
		local curAcceptedRequests = QuestUtils.getAllAcceptedQuestsData()

		if curAcceptedRequests[curStarQuestId] ~= nil then
			local cfg = QuestUtils.getMainQuestChapterConfig(curStarQuestId)

			if cfg then
				local sectionId = cfg.sectionId

				return sectionId
			end
		end
	end
end

function PlayerEnhanceModel.getStarTitleColor(starTitle)
	local cfg = PlayerTitleData[starTitle]

	if cfg then
		return cfg.quality or 0
	end

	return 0
end

return PlayerEnhanceModel
