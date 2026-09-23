-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsPrepRoom\\GrabEggsPrepRoomModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsPrepRoomModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsPrepRoomModel = Class.LightClass("GrabEggsPrepRoomModel", UIModel)
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local LevelData = require("Data.level_data")
local SceneData = require("Data.scene_data")
local Utils = require("Common.Utils.Utils")

function GrabEggsPrepRoomModel:setAutoFill(autoFill)
	self.autoFill = autoFill or false
end

function GrabEggsPrepRoomModel:setDungeonInfo(dungeonId, difficultLv)
	self.dungeonSceneId = dungeonId
	self.difficultLv = difficultLv
end

function GrabEggsPrepRoomModel:getDifficultLv()
	return self.difficultLv
end

function GrabEggsPrepRoomModel:tryParseTeamInfo()
	local me = pg.me
	local teamInfo = me:getShowTeamInfo()
	local data = {
		members = {}
	}

	self:parseMapInfo(data)

	local cData = LevelData[self.dungeonSceneId]

	data.teamNum = #teamInfo.sortList

	if cData then
		data.maxTeamNum = cData.playerNumMax or 2
		data.maxTeamNum = math.max(data.maxTeamNum, data.teamNum)
	else
		data.maxTeamNum = 4
	end

	data.isFullTeam = data.teamNum >= data.maxTeamNum

	local memberMe
	local isAllReady = true
	local readyNum = 0

	for i, uid in ipairs(teamInfo.sortList) do
		local sConfirmInfo = teamInfo.prepareInfos[uid] or {}
		local sMember = teamInfo.membersInfo[uid] or {}
		local member = {
			order = i,
			isLeader = uid == teamInfo.leaderUid,
			isReady = sConfirmInfo.isPrepare,
			uid = uid,
			isSelf = uid == me.uid,
			playerName = sMember.playerName,
			platformDisplayName = sMember.platformDisplayName,
			platformUserId = sMember.platformUserId,
			platformFamily = sMember.platformFamily,
			platform = sMember.platform,
			os = sMember.os,
			isAllowedCrossPlatform = sMember.isAllowedCrossPlatform,
			showTitles = sMember.showTitles,
			showTitleExtra = sMember.showTitleExtra,
			isWholeTitle = sMember.isWholeTitle
		}

		if not member.isLeader then
			if member.isReady then
				readyNum = readyNum + 1
			else
				isAllReady = false
			end
		end

		member.icon = PlayerHeadIconData[sMember.headIcon or 1].res
		member.petList = {}

		self:parsePetList(sMember.petInfoList, member.petList)

		data.members[i] = member

		if me.uid == uid then
			memberMe = member
		end
	end

	data.isAllReady = true
	data.readyNum = readyNum

	if memberMe then
		data.isLeader = memberMe.isLeader
		data.isReady = memberMe.isReady
	end

	return data
end

function GrabEggsPrepRoomModel:parsePetList(src, dest)
	for i = 1, 4 do
		local v = src[i]

		if v then
			dest[i] = {
				empty = false,
				level = v.level,
				cp = v.cp,
				label = v.label,
				templateId = v.templateId
			}

			local cData = PetData[v.templateId]

			if cData then
				dest[i].icon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, v.label, 1)
				dest[i].name = pg.getLocalizationText(cData.name)
				dest[i].mainElementType = cData.mainElementType
				dest[i].coreAbilityId = v.coreAbilityId or nil
			end

			if not string.isNilOrEmpty(v.name) then
				dest[i].name = v.name
			end
		else
			dest[i] = {
				empty = true
			}
		end
	end
end

function GrabEggsPrepRoomModel:parseMapInfo(data)
	local cData = LevelData[self.dungeonSceneId]

	if cData == nil then
		return
	end

	data.mapName = pg.getLocalizationText(cData.name)
	data.mapIcon = cData.pic
end

return GrabEggsPrepRoomModel
