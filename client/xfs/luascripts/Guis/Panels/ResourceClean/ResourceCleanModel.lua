-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ResourceClean\\ResourceCleanModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PackDownloadGroup = require("Data.pack_download_group")
local PackDownloadItem = require("Data.pack_download_item")
local ResourceCleanModel = Class.LightClass("ResourceCleanModel", UIModel)

function ResourceCleanModel:getDownloadedPackGroups()
	local resourceDownload = pg.game.resourceDownload

	if not resourceDownload or not resourceDownload:isXPartEnabled() then
		return {}
	end

	local groupMap = {}

	for packId, packData in pairs(PackDownloadItem) do
		local state = resourceDownload:getPackDownloadState(packData, nil, packId)

		if state and state.stateName == "Downloaded" and packData.showInList then
			local groupId = packData.group or 0
			local group = groupMap[groupId]

			if not group then
				local groupData = PackDownloadGroup[groupId]

				group = {
					totalSize = 0,
					groupId = groupId,
					order = tonumber(groupData and groupData.order) or groupId,
					name = groupData and pg.getLocalizationText(groupData.name) or tostring(groupId),
					items = {}
				}
				groupMap[groupId] = group
			end

			local item = {
				selected = false,
				packId = packId,
				packData = packData,
				order = packData.order or 0,
				name = pg.getLocalizationText(packData.name),
				totalSize = state.totalSize or 0
			}

			group.totalSize = group.totalSize + item.totalSize
			group.items[#group.items + 1] = item
		end
	end

	local groups = {}

	for _, group in pairs(groupMap) do
		table.sort(group.items, function(a, b)
			return (a.order or 0) < (b.order or 0)
		end)

		groups[#groups + 1] = group
	end

	table.sort(groups, function(a, b)
		return (a.order or 0) < (b.order or 0)
	end)

	return groups
end

return ResourceCleanModel
