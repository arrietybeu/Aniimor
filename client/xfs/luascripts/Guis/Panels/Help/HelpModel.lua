-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Help\\HelpModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HelpConst = require("Const.HelpConst")
local Const = require("Common.Const.Const")
local HelpConst = require("Const.HelpConst")
local ClientUtils = require("Utils.ClientUtils")
local GuidenceItemData = require("Data.guidence_item_data")
local GuidenceSubItemData = require("Data.guidence_sub_item_data")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local HelpModel = Class.LightClass("HelpModel", UIModel)

function HelpModel:ctor()
	self.entryTitle = {
		{
			tIndex = 0,
			name = "ALL"
		},
		{
			tIndex = 1,
			name = "SYSTEM"
		},
		{
			tIndex = 1,
			name = "NOURISH"
		},
		{
			tIndex = 1,
			name = "BATTLE"
		},
		{
			tIndex = 2,
			name = "EXPLORE"
		}
	}
end

function HelpModel:getHelpEntryInfo(entry)
	if entry == nil then
		return nil
	end

	local helpIds = entry.helpId
	local entryInfo = {}

	for i = 1, #helpIds do
		table.insert(entryInfo, GuidenceSubItemData[helpIds[i]])
	end

	return entryInfo
end

function HelpModel.getHelpInfo(helpId)
	local data = GuidenceSubItemData[helpId] or {}

	return data
end

function HelpModel:getTotalHelpPageEntries(sceneId)
	local player = pg.me
	local cache = {}

	for k, data in pairs(GuidenceItemData) do
		local isSame = sceneId and data.type == sceneId or data.type < 5

		if isSame and ClientUtils.checkIsOpenToCurPlatform(data) then
			local unlockState = Utils.getHelpIsUnlock(player, k)

			if unlockState == nil then
				unlockState = Const.HELP_UNLOCK_LEVEL.UNLOCK
			end

			if unlockState ~= Const.HELP_UNLOCK_LEVEL.UNAPPEAR then
				if cache[data.type] == nil then
					cache[data.type] = {
						startIndex = 2,
						unlockCnt = 0,
						cnt = 0,
						entries = {}
					}
				end

				local typeCache = cache[data.type]
				local unlock = unlockState == Const.HELP_UNLOCK_LEVEL.UNLOCK

				typeCache.entries[typeCache.startIndex] = {
					tIndex = 1,
					index = k,
					groupIndex = data.group,
					id = typeCache.cnt,
					helpId = data.helpId,
					entryName = data.name,
					sortLevel = data.sort,
					isUnlock = unlock,
					actionPath = data.actionPath
				}
				typeCache.cnt = typeCache.cnt + 1
				typeCache.startIndex = typeCache.startIndex + 1
				typeCache.unlockCnt = typeCache.unlockCnt + (unlock == true and 1 or 0)
			end
		end
	end

	local allTab = {}

	for i, entries in pairs(cache) do
		if entries then
			if ToBool(entries.entries) then
				entries.entries[1] = {
					isTitle = true,
					tIndex = 0,
					entryName = HelpConst.EntryTypeName[i],
					totalNum = entries.cnt,
					unlockCnt = entries.unlockCnt
				}

				table.sort(entries.entries, function(a, b)
					if a.isTitle then
						return true
					end

					if b.isTitle then
						return false
					end

					return a.sortLevel < b.sortLevel
				end)
			end

			table.mergeList(allTab, entries.entries)
		end
	end

	cache[HelpConst.EntryType.ENTRY_ALL] = {
		entries = allTab
	}

	return cache
end

function HelpModel:getRecentlyUnlockEntries(pageId)
	local recentCnt = 0
	local showNum = SysConfigData.helpRecentNum or 5
	local spaceDay = SysConfigData.helpDuration or 7
	local spaceSec = spaceDay * 24 * 60 * 60
	local curTime = Time.secondCache
	local unlockList

	if pageId == HelpConst.EntryType.ENTRY_ALL then
		unlockList = {}

		for i = 1, HelpConst.EntryType.ENTRY_EXPLORE do
			local serverList = pg.me.unlockedHelpListMap[i]

			if serverList then
				local listCnt = #serverList
				local curInsertNum = 0

				for k = listCnt, 1, -1 do
					local info = serverList[k]

					if curInsertNum < showNum and curTime < info.timeStamp + spaceSec then
						table.insert(unlockList, info)

						curInsertNum = curInsertNum + 1
					end
				end
			end
		end

		table.sort(unlockList, function(a, b)
			return a.timeStamp < b.timeStamp
		end)
	else
		unlockList = pg.me.unlockedHelpListMap[pageId]
	end

	if unlockList then
		local outEntries = {}
		local titleEntry
		local listCnt = #unlockList

		for i = listCnt, 1, -1 do
			local info = unlockList[i]

			if recentCnt < showNum and curTime < info.timeStamp + spaceSec then
				local data = GuidenceItemData[info.guidenceId]

				if ClientUtils.checkIsOpenToCurPlatform(data) then
					if titleEntry == nil then
						titleEntry = {
							entryName = "RECENTLY_UNLOCKED",
							tIndex = 0,
							isTitle = true
						}

						table.insert(outEntries, titleEntry)
					end

					table.insert(outEntries, {
						tIndex = 1,
						isRecent = true,
						isUnlock = true,
						index = info.guidenceId,
						groupIndex = data.group,
						id = recentCnt,
						helpId = data.helpId,
						entryName = data.name,
						sortLevel = data.sort
					})

					recentCnt = recentCnt + 1
				end
			else
				if titleEntry then
					titleEntry.totalNum = recentCnt
				end

				return recentCnt, outEntries
			end
		end

		if titleEntry then
			titleEntry.totalNum = recentCnt
		end

		return recentCnt, outEntries
	end

	return recentCnt
end

function HelpModel:isEntryLocked(entryId)
	local entry = GuidenceItemData[entryId]

	if entry == nil then
		return false
	end
end

function HelpModel:getUnlockedEntries(pageId)
	local player = pg.me

	if player then
		if pageId == Const.GUIDANCE_TYPE_ALL then
			local ret = {}
			local systemEntries = player.unlockedGuidenceMap[Const.GUIDANCE_TYPE_SYSTEM]
			local growEntries = player.unlockedGuidenceMap[Const.GUIDANCE_TYPE_PROGRESSION]
			local combatEntries = player.unlockedGuidenceMap[Const.GUIDANCE_TYPE_COMBAT]
			local exoloreEntries = player.unlockedGuidenceMap[Const.GUIDANCE_TYPE_EXPLORE]

			table.move(systemEntries, 1, #systemEntries, #ret + 1, ret)
			table.move(growEntries, 1, #growEntries, #ret + 1, ret)
			table.move(combatEntries, 1, #combatEntries, #ret + 1, ret)
			table.move(exoloreEntries, 1, #exoloreEntries, #ret + 1, ret)

			return ret
		else
			return player.unlockedGuidenceMap[pageId]
		end
	end

	return nil
end

function HelpModel:getHelpType(helpId)
	local helpIdConf = GuidenceItemData[helpId]
	local type = HelpConst.EntryType.ENTRY_ALL

	if not helpIdConf then
		return
	end

	if HelpConst.EntryType.ENTRY_SYSTEM == helpIdConf.type then
		type = HelpConst.EntryType.ENTRY_SYSTEM
	elseif HelpConst.EntryType.ENTRY_GROW == helpIdConf.type then
		type = HelpConst.EntryType.ENTRY_GROW
	elseif HelpConst.EntryType.ENTRY_COMBAT == helpIdConf.type then
		type = HelpConst.EntryType.ENTRY_COMBAT
	elseif HelpConst.EntryType.ENTRY_EXPLORE == helpIdConf.type then
		type = HelpConst.EntryType.ENTRY_EXPLORE
	end

	return type
end

function HelpModel.getHelpIdByGroupId(groupId)
	for k, v in pairs(GuidenceItemData) do
		if v.group == groupId and ClientUtils.checkIsOpenToCurPlatform(v) then
			return true, k
		end
	end

	return false
end

return HelpModel
