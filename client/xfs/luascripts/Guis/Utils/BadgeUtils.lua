-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\BadgeUtils.lua

local Const = require("Common.Const.Const")
local PlayerBadgeMainTypeMap = require("Data.player_badge_main_type_map")
local PlayerBadgeGroupMap = require("Data.player_badge_group_map")
local PlayerBadgeLayoutData = require("Data.player_badge_layout_data")
local PlayerBadgeData = require("Data.player_badge_data")
local PlayerBadgeTypeData = require("Data.player_badge_Type_data")
local ClientConst = require("Const.ClientConst")
local Lume = require("Core.Common.lume")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerSkillTreeData = require("Data.player_skill_tree_data")
local PlayerSkillData = require("Data.player_skill_data")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local ShowTitleData = require("Data.show_title_data")
local SourceData = require("Data.item_source_data")
local BadgeUtils = {}

BadgeUtils.BADGE_TYPE = {
	SPECIAL_PATH = 5,
	GLITZ_PATH = 4,
	EXPLORE_PATH = 3,
	CHAMPION_PATH = 2,
	MASTER_PATH = 1
}
BadgeUtils.TYPE_ICON = {
	[BadgeUtils.BADGE_TYPE.MASTER_PATH] = "",
	[BadgeUtils.BADGE_TYPE.CHAMPION_PATH] = "",
	[BadgeUtils.BADGE_TYPE.EXPLORE_PATH] = "",
	[BadgeUtils.BADGE_TYPE.GLITZ_PATH] = "",
	[BadgeUtils.BADGE_TYPE.SPECIAL_PATH] = ""
}
BadgeUtils.QUALITY_ICON = {
	[0] = "$UI_Icon_Badge_QualityLevelNone.png",
	"$UI_Icon_Badge_QualityLevelCopper.png",
	"$UI_Icon_Badge_QualityLevelSilver.png",
	"$UI_Icon_Badge_QualityLevelGold.png",
	"$UI_Icon_Badge_QualityLevelRainbow.png"
}
BadgeUtils.BADGE_STATE = {
	COMPLETE = 3,
	UNLOCK = 2,
	LOCK = 1
}
BadgeUtils.PET_STATE_IS_KNOWN = 2
BadgeUtils.PET_STATE_IS_EMPTY = 3
BadgeUtils.PET_STATE_IS_CATCH = 1
BadgeUtils.Default_Badge_ID = -1
BadgeUtils.SubTypeState_Hide = 0
BadgeUtils.SubTypeState_Show = 1
BadgeUtils.RainBowMatPath = "$VX_Mat_Noise243_03b.mat"
BadgeUtils.RainBowQuality = 4
BadgeUtils.TitleDisplayType = {
	replaceColon = 2,
	normal = 1
}

local LastLookBadgeBoxKey = "PLAYER_BADGE_OVERVIEW_BOX_%s"

function BadgeUtils.renderEntry(button, index, data, canOpenTooltip, titleDisplayType)
	local objectReference = button:GetComponent("ObjectReference")
	local badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtDescUSDFText = objectReference:GetRefValue("txtDescUSDFText")

	badgeIconUImage.url = data.icon

	if data.isTitle then
		local displayType = titleDisplayType or BadgeUtils.TitleDisplayType.normal
		local name

		if displayType == BadgeUtils.TitleDisplayType.replaceColon then
			name = string.gsub(data.name, "：", "\n")
		else
			name = data.name
		end

		ClientTextUtils.setText(txtNameUSDFText, name)
	else
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
	end

	ClientTextUtils.setText(txtDescUSDFText, pg.getLocalizationText(data.desc))

	local canOpen = canOpenTooltip or false

	button.enabledTooltip = canOpen

	if canOpen then
		function button.luaRenderTooltip(btn, tooltip)
			BadgeUtils._renderTooltip(tooltip, data, btn)
		end
	end
end

function BadgeUtils._renderTooltip(tooltip, data, btn)
	local objectReference = tooltip:GetComponent("ObjectReference")
	local rootUPopupForm = objectReference:GetRefValue("rootUPopupForm")
	local btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local iconUWidget = objectReference:GetRefValue("iconUWidget")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local titleUWidget = objectReference:GetRefValue("titleUWidget")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")

	iconUImage.url = data.icon

	ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(data.name))

	if string.isNilOrEmpty(data.desc) then
		tooltip:TryChangePage("State", 2)
	else
		tooltip:TryChangePage("State", 1)
		ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.desc))
	end

	function btnCloseUButton.luaClick()
		btn:ClosePopup()
	end
end

function BadgeUtils.checkHasAnyBadgeTypeIsUnlock()
	for _, v in pairs(BadgeUtils.BADGE_TYPE) do
		local isUnlock = BadgeUtils.checkBadgeTypeIsUnlock(v)

		if isUnlock then
			return true
		end
	end

	return false
end

function BadgeUtils.checkBadgeTypeIsUnlock(badgeType)
	local badgeTypeData = PlayerBadgeTypeData[badgeType]

	for k, v in ipairs(badgeTypeData) do
		if v.initState == BadgeUtils.SubTypeState_Show then
			return true
		elseif BadgeUtils.checkSubTypeIsUnlockInServer(badgeType, k) then
			return true
		end
	end

	return false
end

function BadgeUtils.checkSubTypeIsUnlock(mainTab, subTab)
	local serverData = BadgeUtils.checkSubTypeIsUnlockInServer(mainTab, subTab)

	if serverData == nil then
		local badgeTypeData = PlayerBadgeTypeData[mainTab]

		return badgeTypeData[subTab].initState == BadgeUtils.SubTypeState_Show
	else
		return serverData
	end
end

function BadgeUtils.checkSubTypeIsUnlockInServer(mainTab, subTab)
	local mainData = pg.me.badgeTypeMap[mainTab]

	if mainData and mainData[subTab] then
		return mainData[subTab] == BadgeUtils.SubTypeState_Show
	end
end

function BadgeUtils.getBadgeInitStateFromCfg(badgeId)
	local groupId = PlayerBadgeData[badgeId] and PlayerBadgeData[badgeId].group or 0
	local ids = PlayerBadgeGroupMap[groupId]

	if ids and #ids > 0 then
		return PlayerBadgeData[ids[1]].initState
	end

	return Const.BADGE_STATUS.None
end

function BadgeUtils.getNameAndIconByMainType(mainType)
	local mainData = PlayerBadgeTypeData[mainType]

	if mainData and mainData[0] then
		local mainTypeCfg = mainData[0]

		return mainTypeCfg.mainTypeName, mainTypeCfg.mainTypeIconOther, mainTypeCfg.mainTypeIconChoose
	end
end

function BadgeUtils.getBadgeSlotIcon(badgeGroupId, badgeLevel)
	local ids = PlayerBadgeGroupMap[badgeGroupId]

	if not ids then
		return
	end

	if badgeLevel and ids[badgeLevel] then
		local cfg = PlayerBadgeData[ids[badgeLevel]]

		if not string.isNilOrEmpty(cfg.iconLocked) then
			return cfg.iconLocked
		end
	end

	if ids[1] then
		return PlayerBadgeData[ids[1]].iconLocked
	end
end

function BadgeUtils.getBadgeIcon(badgeGroupId, badgeLevel)
	local ids = PlayerBadgeGroupMap[badgeGroupId]

	if ids and ids[badgeLevel] then
		local cfg = PlayerBadgeData[ids[badgeLevel]]

		return cfg.icon
	end
end

function BadgeUtils.getBadgeQuality(badgeGroupId, badgeLevel)
	local ids = PlayerBadgeGroupMap[badgeGroupId]

	if ids and ids[badgeLevel] then
		local cfg = PlayerBadgeData[ids[badgeLevel]]

		return cfg.quality
	end
end

function BadgeUtils.getBadgeQualityByBadgeId(badgeId)
	local cfg = PlayerBadgeData[badgeId]

	if cfg then
		return cfg.quality
	end
end

function BadgeUtils.setBadgeQuality(badgeId, uImage)
	local cfgData = PlayerBadgeData[badgeId]

	if cfgData then
		if cfgData.quality == BadgeUtils.RainBowQuality then
			uImage:SetMaterial(BadgeUtils.RainBowMatPath)
		else
			uImage.material = ""
		end
	end
end

function BadgeUtils.getMainTypeNameAndIconInPlayerUI(mainType)
	local mainData = PlayerBadgeTypeData[mainType]

	if mainData and mainData[0] then
		local mainTypeCfg = mainData[0]

		return mainTypeCfg.mainTypeName, mainTypeCfg.mainTypeIconHomepage, mainTypeCfg.subTypeArkName
	end
end

function BadgeUtils.getDataByTab(tab)
	local ret = {}
	local subTypeIds = PlayerBadgeMainTypeMap[tab]

	if subTypeIds then
		for subType, subInfo in ipairs(subTypeIds) do
			if BadgeUtils.checkSubTypeIsUnlock(tab, subType) then
				local item = {}

				item.suite = {}
				item.subType = subInfo.subType or subType
				item.subName = subInfo.subTypeName
				item.subArkName = BadgeUtils.getSubTypeArkName(tab, subType)

				local groupIds = subInfo.groupIds

				if groupIds then
					for _, groupId in ipairs(groupIds) do
						local badgeId, state, level = BadgeUtils.getBadgeByGroupId(groupId)
						local sort = PlayerBadgeLayoutData[groupId].sort

						table.insert(item.suite, {
							badgeGroupId = groupId,
							badgeId = badgeId,
							badgeState = state,
							process = BadgeUtils.getBadgeProcessById(badgeId),
							resKey = sort,
							level = level
						})
					end
				end

				local bigBadgeId, bigState, bigLevel = BadgeUtils.getBadgeByGroupId(subInfo.bigBadgeId)

				item.bigBadgeGroupId = subInfo.bigBadgeId
				item.bigBadgeLevel = bigLevel
				item.bigBadgeState = bigState
				item.bigBadgeId = bigBadgeId
				item.bigProcess = BadgeUtils.getBadgeProcessById(bigBadgeId)
				item.tIndex = 0
				item.resPath = subInfo.resPath

				table.insert(ret, item)
			end
		end
	end

	return ret
end

function BadgeUtils.getLastLookBadgeBoxSubType(mainType)
	if mainType == nil then
		return 0
	end

	return pg.global.prefsCacheUtils:getInt(string.format(LastLookBadgeBoxKey, mainType), 0, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.setLastLookBadgeBoxSubType(mainType, subType)
	if mainType == nil or subType == nil or subType <= 0 then
		return
	end

	pg.global.prefsCacheUtils:setInt(string.format(LastLookBadgeBoxKey, mainType), subType, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.getSeasonBadgeBoxSubType(mainType, seasonId, stageId)
	if mainType == nil or seasonId == nil then
		return
	end

	local subTypeIds = PlayerBadgeTypeData[mainType]

	if subTypeIds == nil then
		return
	end

	for subType, data in ipairs(subTypeIds) do
		if data.seasonBadgeBox and data.seasonBadgeBox[1] == seasonId and data.seasonBadgeBox[2] == stageId then
			return subType
		end
	end
end

function BadgeUtils.getSubTypeArkName(mainType, subType)
	local mainData = PlayerBadgeTypeData[mainType]

	if mainData and mainData[subType] then
		return mainData[subType].subTypeArkName
	end
end

function BadgeUtils.getLatestCompleteBadgeId(badgeGroupId)
	local serverBadgeMap = pg.me.badgeStatusMap
	local ids = PlayerBadgeGroupMap[badgeGroupId]

	if ids then
		for i = #ids, 1, -1 do
			local id = ids[i]
			local serverState = serverBadgeMap[id]

			if serverState == Const.BADGE_STATUS.Complete then
				return id
			end
		end
	end
end

function BadgeUtils.getBadgeByGroupId(groupId)
	local serverBadgeMap = pg.me.badgeStatusMap
	local ids = PlayerBadgeGroupMap[groupId]

	if ids then
		local curBadgeId
		local curState = Const.BADGE_STATUS.None
		local curLevel = 0
		local cfgInitState = PlayerBadgeData[ids[1]].initState or Const.BADGE_STATUS.None

		for k, id in ipairs(ids) do
			local serverState = serverBadgeMap[id] or cfgInitState

			if serverState <= Const.BADGE_STATUS.Hide then
				break
			end

			curBadgeId = id
			curState = serverState

			if BadgeUtils.badgeStateIsShow(curState) then
				curLevel = k
			end

			if curState ~= Const.BADGE_STATUS.Complete then
				break
			end
		end

		return curBadgeId, curState, curLevel
	end

	return groupId, Const.BADGE_STATUS.None, 0
end

function BadgeUtils.getAllBadgeByGroupId(groupId)
	local ret = {}
	local serverBadgeMap = pg.me.badgeStatusMap
	local ids = PlayerBadgeGroupMap[groupId]

	if ids then
		local cfgInitState = PlayerBadgeData[ids[1]].initState or Const.BADGE_STATUS.None

		for k, id in ipairs(ids) do
			local cfgData = PlayerBadgeData[id]
			local condition = cfgData and cfgData.condition and Lume.iclone(cfgData.condition) or {}
			local unlockTime, unlockLv, unlockStar = BadgeUtils.getBadgeUnlockInfo(id)

			table.insert(ret, {
				badgeId = id,
				badgeState = serverBadgeMap[id] or cfgInitState,
				process = BadgeUtils.getBadgeProcessById(id),
				condition = condition,
				unlockTime = unlockTime,
				unlockLevel = unlockLv,
				unlockStarName = unlockStar,
				quality = cfgData.quality,
				index = k
			})
		end
	end

	return ret
end

function BadgeUtils.getBadgeUnlockInfo(badgeId)
	local serverData = pg.me.badgeUnlockInfoMap

	if not serverData then
		return
	end

	local serverUnlockInfo = pg.me.badgeUnlockInfoMap[badgeId]

	if serverUnlockInfo then
		return LuaUIUtils.timeStampToUtcString(serverUnlockInfo.unlockTime), serverUnlockInfo.unlockLevel, LuaUIUtils.getStarTitleName(serverUnlockInfo.unlockStarTitle, true)
	end
end

function BadgeUtils.getBadgeProcessById(badgeId)
	local cfgData = PlayerBadgeData[badgeId]
	local curNum = 0
	local totalNum = 0
	local normalNum, normalCnt = BadgeUtils.getNormalConditionInfo(cfgData)
	local catchNum, petCount = BadgeUtils.getPetCollectInfo(cfgData)
	local enoughNum, itemCount = BadgeUtils.getItemCollectInfo(cfgData)

	curNum = normalNum + catchNum + enoughNum
	totalNum = normalCnt + petCount + itemCount

	if totalNum == 0 then
		return 1
	else
		return curNum / totalNum
	end

	return 1
end

function BadgeUtils.getConditionInfoOnlyNormal(cfgData)
	local ret = {}
	local player = pg.me
	local triggerMap = player.triggerMap
	local condition = cfgData and cfgData.condition

	if condition then
		for _, v in ipairs(condition) do
			local cnt, num, byCondition = BadgeUtils._getOneNormalConditionCount(triggerMap, v)
			local desc = v[1] and CustomTriggerData[v[1]].note

			table.insert(ret, {
				tIndex = 0,
				conditionId = v[1],
				desc = desc,
				needNum = num,
				byCondition = byCondition,
				curNum = cnt,
				source = SourceData[v[4]]
			})
		end
	end

	return ret
end

function BadgeUtils.getConditionInfo(cfgData, forceComplete)
	local ret = {}
	local triggerMap

	if forceComplete ~= true then
		triggerMap = pg.me.triggerMap
	end

	local condition = cfgData and cfgData.condition

	if condition then
		for _, v in ipairs(condition) do
			local cnt, num, byCondition = BadgeUtils._getOneNormalConditionCount(triggerMap, v, forceComplete)
			local desc = v[1] and CustomTriggerData[v[1]].note

			ret[#ret + 1] = {
				tIndex = 0,
				conditionId = v[1],
				desc = desc,
				needNum = num,
				byCondition = byCondition,
				curNum = cnt,
				source = SourceData[v[4]]
			}
		end
	end

	local playerHandBookMap

	if forceComplete ~= true then
		playerHandBookMap = pg.me.petHandbookMap
	end

	local petCollect = cfgData and cfgData.petCollect

	if petCollect then
		local petRet = {
			tIndex = 1,
			collect = {}
		}
		local maxNumPet = 4
		local curNum = 0

		for _, v in pairs(petCollect) do
			local state

			if forceComplete == true then
				state = BadgeUtils.PET_STATE_IS_CATCH
			elseif playerHandBookMap:isCatched(v, Const.GROUP_TYPE_SELF) then
				state = BadgeUtils.PET_STATE_IS_CATCH
			elseif playerHandBookMap:isKnown(v, Const.GROUP_TYPE_SELF) then
				state = BadgeUtils.PET_STATE_IS_KNOWN
			else
				state = BadgeUtils.PET_STATE_IS_EMPTY
			end

			petRet.collect[#petRet.collect + 1] = {
				petId = v,
				petIcon = LuaUIUtils.getPetIconByTemplateId(v, LuaUIUtils.PET_ICON),
				state = state
			}
			curNum = curNum + 1

			if curNum == maxNumPet then
				ret[#ret + 1] = petRet
				petRet = {
					tIndex = 1,
					collect = {}
				}
				maxNumPet = maxNumPet == 4 and 3 or 4
				curNum = 0
			end
		end

		if curNum > 0 then
			ret[#ret + 1] = petRet
		end
	end

	local itemCollect = cfgData and cfgData.itemCollect

	if itemCollect then
		local itemRet = {
			tIndex = 2
		}

		itemRet.collect = {}

		for _, v in pairs(itemCollect) do
			local itemId = v[1]
			local needNum = v[2]
			local curNum = forceComplete == true and needNum or BadgeUtils._getItemCount(itemId)

			itemRet.collect[#itemRet.collect + 1] = {
				itemId = itemId,
				needNum = needNum,
				curNum = curNum
			}
		end

		ret[#ret + 1] = itemRet
	end

	return ret
end

function BadgeUtils.getConditionInfoByBadgeIdAndIndex(badgeId, index)
	local cfgData = PlayerBadgeData[badgeId]
	local triggerMap = pg.me.triggerMap
	local condition = cfgData and cfgData.condition

	if condition and condition[index] then
		local cnt, total, byCondition = BadgeUtils._getOneNormalConditionCount(triggerMap, condition[index])

		return cnt, total, byCondition
	end
end

function BadgeUtils.getNormalConditionInfo(cfgData)
	local curNum = 0
	local totalNum = 0
	local triggerMap = pg.me.triggerMap
	local condition = cfgData and cfgData.condition

	if condition then
		for _, v in ipairs(condition) do
			local cnt, numLimit = BadgeUtils._getOneNormalConditionCount(triggerMap, v)

			curNum = curNum + cnt
			totalNum = totalNum + numLimit
		end
	end

	return curNum, totalNum
end

function BadgeUtils._getOneNormalConditionCount(triggerMap, condition, forceComplete)
	if forceComplete == true then
		local byCondition = condition[3] == -1
		local needNum = byCondition and 1 or condition[2] or 1

		return needNum, needNum, byCondition
	end

	if condition[3] == -1 then
		local isComplete = triggerMap:isCompleteOrMeetCondition(condition[1])

		return isComplete and 1 or 0, 1, true
	else
		local pos = condition[3] or 1
		local isComplete = triggerMap:isCompleteOrMeetCondition(condition[1])
		local targetCount = triggerMap:getConditionTargetCount(condition[1], pos)

		if isComplete then
			return targetCount, targetCount, false
		else
			local cnt = condition[1] and triggerMap:getConditionFinishCount(condition[1], pos) or 0

			return cnt, targetCount, false
		end
	end
end

function BadgeUtils.getPetCollectInfo(cfgData)
	local playerHandBookMap = pg.me.petHandbookMap
	local catchNum = 0
	local totalNum = 0
	local petCollect = cfgData and cfgData.petCollect

	if petCollect then
		for _, v in pairs(petCollect) do
			if playerHandBookMap:isCatched(v, Const.GROUP_TYPE_SELF) then
				catchNum = catchNum + 1
			end

			totalNum = totalNum + 1
		end
	end

	return catchNum, totalNum
end

function BadgeUtils.getItemCollectInfo(cfgData)
	local enoughNum = 0
	local totalNum = 0
	local itemCollect = cfgData and cfgData.itemCollect

	if itemCollect then
		for _, v in pairs(itemCollect) do
			local itemId = v[1]
			local needNum = v[2]
			local curNum = BadgeUtils._getItemCount(itemId)

			if needNum <= curNum then
				enoughNum = enoughNum + needNum
			else
				enoughNum = enoughNum + curNum
			end

			totalNum = totalNum + needNum
		end
	end

	return enoughNum, totalNum
end

function BadgeUtils._getItemCount(itemId)
	local bagNum = ClientUtils.getItemCountById(itemId)
	local invNum = ClientUtils.getHomelandItemCountById(itemId)

	return bagNum + invNum
end

function BadgeUtils.getBadgeNumByTab(tab)
	local num = 0
	local subTypeIds = PlayerBadgeMainTypeMap[tab]

	if subTypeIds then
		for _, subInfo in ipairs(subTypeIds) do
			local groupIds = subInfo.groupIds

			if groupIds then
				for _, groupId in ipairs(groupIds) do
					local id, state, level = BadgeUtils.getBadgeByGroupId(groupId)

					if state == Const.BADGE_STATUS.Complete or level > 1 then
						num = num + 1
					end
				end
			end
		end
	end

	return num
end

function BadgeUtils.getEntryData(cfgData)
	local ret = {}

	if cfgData.title then
		local titleData = ShowTitleData[cfgData.title]

		if titleData then
			table.insert(ret, {
				icon = "$UI_PassiveSkillIcon_Avatar_130009.png",
				isTitle = true,
				tIndex = 0,
				name = BadgeUtils._getPlayerTitleDisplay(titleData)
			})
		end
	end

	if cfgData.ability then
		for _, v in ipairs(cfgData.ability) do
			local skillCfg = PlayerSkillTreeData[v]

			if skillCfg then
				local item = {}

				item.id = v
				item.icon = skillCfg.icon

				local skillData = PlayerSkillData[v]

				if skillData and skillData[1] then
					item.desc = skillData[1].desc
					item.name = skillData[1].name
				end

				table.insert(ret, item)
			end
		end
	end

	return ret
end

function BadgeUtils._getPlayerTitleDisplay(titleData)
	local content

	content = titleData.titleType == 1 and "APPELLATION_FRONT" or titleData.titleType == 2 and "APPELLATION_BEHIND" or "APPELLATION_FULL"

	return pg.getFormatText(pg.getGameString(content), pg.getLocalizationText(titleData.titleText))
end

function BadgeUtils.getTypeByBadgeId(badgeId)
	local badgeData = PlayerBadgeData[badgeId]

	if badgeData then
		local layout = PlayerBadgeLayoutData[badgeData.group]

		if layout then
			return layout.mainType, layout.subType, true
		end
	end

	return BadgeUtils.BADGE_TYPE.MASTER_PATH, 1, false
end

function BadgeUtils.checkHasNewUnlockBadge()
	for k, v in pairs(BadgeUtils.BADGE_TYPE) do
		local ret = BadgeUtils.checkHasNewUnlockBadgeByTab(v)

		if ret then
			return true
		end
	end

	return false
end

function BadgeUtils.checkHasNewUnlockBadgeByTab(tab)
	local subTypeIds = PlayerBadgeMainTypeMap[tab]

	if subTypeIds then
		for _, subInfo in ipairs(subTypeIds) do
			local groupIds = subInfo.groupIds

			if groupIds then
				for _, groupId in ipairs(groupIds) do
					local badgeId, state = BadgeUtils.getBadgeByGroupId(groupId)
					local isNew = BadgeUtils.getBadgeStateFromPrefs(badgeId)

					if isNew then
						return true
					end
				end
			end
		end
	end

	return false
end

function BadgeUtils.getBadgeStateFromPrefs(badgeId)
	return pg.global.prefsCacheUtils:getBool(string.format("PLAYER_BADGE_STATE_%s", badgeId), false, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.setBadgeStateToPrefs(badgeId)
	return pg.global.prefsCacheUtils:setBool(string.format("PLAYER_BADGE_STATE_%s", badgeId), true, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.deleteBadgeStateInPrefs(badgeId)
	pg.global.prefsCacheUtils:deleteKey(string.format("PLAYER_BADGE_STATE_%s", badgeId), ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.getBadgeObtainFromPrefs(badgeGroupId)
	return pg.global.prefsCacheUtils:getBool(string.format("PLAYER_BADGE_OBTAIN_%s", badgeGroupId), false, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.setBadgeObtainFromPrefs(badgeGroupId)
	return pg.global.prefsCacheUtils:setBool(string.format("PLAYER_BADGE_OBTAIN_%s", badgeGroupId), true, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.deleteBadgeObtainFromPrefs(badgeGroupId)
	return pg.global.prefsCacheUtils:deleteKey(string.format("PLAYER_BADGE_OBTAIN_%s", badgeGroupId), ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.getFirstEnterBadgeUI()
	return pg.global.prefsCacheUtils:getBool("FIRST_ENTER_BADGE_OVERVIEW", true, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.setFirstEnterBadgeUI(val)
	return pg.global.prefsCacheUtils:setBool("FIRST_ENTER_BADGE_OVERVIEW", val, ClientConst.CACHE_TYPE_FLAG.USER)
end

function BadgeUtils.badgeStateIsShow(state)
	return state > Const.BADGE_STATUS.Hide
end

function BadgeUtils.badgeStateIsGet(state)
	return state == Const.BADGE_STATUS.Complete
end

function BadgeUtils.getGroupId(badgeId)
	if badgeId == nil then
		return
	end

	return PlayerBadgeData[badgeId].group
end

function BadgeUtils.onServerDataChanged(badgeId, ov, nv)
	if nv == BadgeUtils.getBadgeInitStateFromCfg(badgeId) then
		return
	end

	if BadgeUtils.badgeStateIsGet(ov) == false and BadgeUtils.badgeStateIsGet(nv) == true then
		BadgeUtils.displayBadge(badgeId)
		BadgeUtils.setBadgeObtainFromPrefs(BadgeUtils.getGroupId(badgeId))
	elseif BadgeUtils.badgeStateIsShow(ov) == false and BadgeUtils.badgeStateIsShow(nv) == true and nv ~= Const.BADGE_STATUS.Secret then
		BadgeUtils.setBadgeStateToPrefs(badgeId)
	end
end

function BadgeUtils.onServerDataAdd(badgeId, state)
	if state == BadgeUtils.getBadgeInitStateFromCfg(badgeId) then
		return
	end

	if BadgeUtils.badgeStateIsGet(state) then
		BadgeUtils.displayBadge(badgeId)
		BadgeUtils.setBadgeObtainFromPrefs(BadgeUtils.getGroupId(badgeId))
	elseif BadgeUtils.badgeStateIsShow(state) and state ~= Const.BADGE_STATUS.Secret then
		BadgeUtils.setBadgeStateToPrefs(badgeId)
	end
end

function BadgeUtils.displayBadge(badgeId)
	local cfgData = PlayerBadgeData[badgeId]

	if not cfgData or cfgData.manualDisplayUnlockEffect ~= nil and cfgData.manualDisplayUnlockEffect ~= 0 then
		return
	end

	BadgeUtils.openBadgeTip(badgeId)
end

function BadgeUtils.openBadgeTip(badgeId)
	local cfg = PlayerBadgeData[badgeId]

	if cfg then
		pg.global.ui.tips:showBadgeItem({
			badgeId = badgeId,
			icon = cfg.icon,
			name = cfg.name,
			quality = BadgeUtils._getItemQuality(cfg.quality),
			customClick = function()
				BadgeUtils.openBadgeObtainUI(badgeId)
			end
		})
	end
end

function BadgeUtils.openBadgeObtainUI(badgeId)
	if pg.me:isInCatchMode() then
		pg.game.controller:onHandleSwitchCatchMode()
	end

	pg.global.ui.badgeObtain:open({
		badgeId = badgeId
	})
end

function BadgeUtils._getItemQuality(quality)
	return quality - 1
end

return BadgeUtils
