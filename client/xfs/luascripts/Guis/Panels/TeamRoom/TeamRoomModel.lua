-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\TeamRoomModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local TeamRoomModel = Class.LightClass("TeamRoomModel", UIModel)
local PetData = require("Data.pet_data")
local LevelData = require("Data.level_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")

function TeamRoomModel:getDungeonConfig(dungeonSceneId)
	return dungeonSceneId and LevelData[dungeonSceneId] or nil
end

function TeamRoomModel:setDungeonInfo(dungeonId, difficultLv)
	self.dungeonSceneId = dungeonId
	self.difficultLv = difficultLv
end

function TeamRoomModel:isSinglePreviewRoom()
	return not pg.me:isInTeam()
end

function TeamRoomModel:getSelfMemberInfo()
	local petInfoList = pg.me.getTeamPetInfos and pg.me:getTeamPetInfos() or {}

	return {
		uid = pg.me.uid,
		playerName = pg.me.playerName,
		showTitles = pg.me.showTitles,
		showTitleExtra = pg.me.showTitleExtra,
		isWholeTitle = pg.me.isWholeTitle,
		avatarConfig = pg.me.avatarConfig,
		avatarPresetKey = pg.me.avatarPresetKey,
		curShow = pg.me.curShow,
		exploreAbilityIds = pg.me.exploreAbilityIds or {},
		petInfoList = petInfoList
	}
end

function TeamRoomModel:getTeamInfo()
	if not self:isSinglePreviewRoom() then
		return pg.me:getShowTeamInfo()
	end

	local uid = pg.me.uid
	local memberInfo = self:getSelfMemberInfo()

	return {
		leaderUid = uid,
		dungeonSceneId = self.dungeonSceneId,
		hardLv = self:getDifficultLv(),
		sortList = {
			uid
		},
		membersInfo = {
			[uid] = memberInfo
		},
		prepareInfos = {
			[uid] = {
				isPrepare = false,
				petInfoList = memberInfo.petInfoList
			}
		},
		confirms = {
			[uid] = {
				isPrepare = false
			}
		}
	}
end

function TeamRoomModel:getDifficultLv()
	if self.difficultLv then
		return self.difficultLv
	end

	local teamInfo = pg.me:getShowTeamInfo()

	return teamInfo and teamInfo.hardLv or 0
end

function TeamRoomModel:getMemberContainerCount(dungeonConfig)
	if self:isSinglePreviewRoom() then
		return 3
	end

	local maxCount = dungeonConfig and dungeonConfig.playerNumMax or 4

	return maxCount % 2 == 1 and 3 or 4
end

function TeamRoomModel:needPreEquip(dungeonConfig)
	return dungeonConfig and dungeonConfig.fb_type == Const.CUR_DUNGEON_TYPE.Egg
end

function TeamRoomModel:isGrabEggsEquipDungeon(dungeonId)
	return dungeonId == Const.ROB_EGG_SCENE_ID or dungeonId == Const.ROB_EGG_SCENE_CLIP_ID
end

function TeamRoomModel:getTeamMemberRenderData(dungeonConfig)
	local maxCount = self:getMemberContainerCount(dungeonConfig)
	local data = {}

	for i = 1, maxCount do
		data[i] = {
			empty = true,
			tIndex = 0
		}
	end

	local teamInfo = self:getTeamInfo()

	for i, uid in ipairs(teamInfo.sortList or EMPTY_TABLE) do
		if data[i] then
			data[i].empty = false
			data[i].uid = uid
		end
	end

	return data
end

function TeamRoomModel:getPreEquipMemberRenderData(dungeonConfig)
	local maxCount = self:getMemberContainerCount(dungeonConfig)
	local data = {}

	for i = 1, maxCount do
		data[i] = {
			empty = true,
			tIndex = 0
		}
	end

	local teamInfo = self:getTeamInfo()

	for i, uid in ipairs(teamInfo.sortList or EMPTY_TABLE) do
		local memberInfo = teamInfo.membersInfo[uid] or {}
		local prepareInfo = teamInfo.prepareInfos[uid] or {}

		if data[i] then
			data[i] = {
				tIndex = 0,
				empty = false,
				order = i,
				uid = uid,
				isLeader = uid == teamInfo.leaderUid,
				isReady = prepareInfo.isPrepare,
				isSelf = uid == pg.me.uid,
				playerName = memberInfo.playerName,
				platformDisplayName = memberInfo.platformDisplayName,
				platformUserId = memberInfo.platformUserId,
				platformFamily = memberInfo.platformFamily,
				platform = memberInfo.platform,
				os = memberInfo.os,
				isAllowedCrossPlatform = memberInfo.isAllowedCrossPlatform,
				showTitles = memberInfo.showTitles,
				showTitleExtra = memberInfo.showTitleExtra,
				isWholeTitle = memberInfo.isWholeTitle,
				petList = {}
			}

			self:parsePetList(memberInfo.petInfoList or {}, data[i].petList)
		end
	end

	return data
end

function TeamRoomModel:parsePetList(src, dest)
	for i = 1, 4 do
		local petInfo = src[i]

		if petInfo then
			dest[i] = {
				empty = false,
				level = petInfo.level,
				cp = petInfo.cp,
				label = petInfo.label,
				templateId = petInfo.templateId
			}

			local petConfig = PetData[petInfo.templateId]

			if petConfig then
				dest[i].icon = LuaUIUtils.getPetIcon(petConfig.iconName, LuaUIUtils.PET_ICON, petInfo.label, 1)
				dest[i].name = pg.getLocalizationText(petConfig.name)
				dest[i].mainElementType = petConfig.mainElementType
				dest[i].coreAbilityId = petInfo.coreAbilityId
			end

			if not string.isNilOrEmpty(petInfo.name) then
				dest[i].name = petInfo.name
			end
		else
			dest[i] = {
				empty = true
			}
		end
	end
end

return TeamRoomModel
