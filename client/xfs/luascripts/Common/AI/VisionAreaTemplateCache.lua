-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\VisionAreaTemplateCache.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local VisionAreaTemplateCache = {}
local templateCache = {}
local emptyTemplate = {
	maxVisionDistance = 0,
	visionAreas = EMPTY_TABLE
}

local function compareVisionArea(left, right)
	local leftDistance = math.abs(left.distanceEnd)
	local rightDistance = math.abs(right.distanceEnd)

	if leftDistance == rightDistance then
		return left.angleStart < right.angleStart
	end

	return leftDistance < rightDistance
end

local function isVisionAreaListSorted(visionAreaList)
	for index = 2, #visionAreaList do
		if compareVisionArea(visionAreaList[index], visionAreaList[index - 1]) then
			return false
		end
	end

	return true
end

local function appendVisionAreaList(target, visionAreaList)
	for index = 1, #visionAreaList do
		target[#target + 1] = visionAreaList[index]
	end
end

local function mergeSortedVisionAreaLists(visionAreaList, visualAreaData)
	local result = {}
	local listIndexes = {}

	while true do
		local selectedData, selectedListIndex

		for listIndex = 1, #visionAreaList do
			local sourceList = visualAreaData[visionAreaList[listIndex]]

			if sourceList then
				local sourceIndex = listIndexes[listIndex] or 1
				local candidate = sourceList[sourceIndex]

				if candidate and (selectedData == nil or compareVisionArea(candidate, selectedData)) then
					selectedData = candidate
					selectedListIndex = listIndex
				end
			end
		end

		if selectedData == nil then
			return result
		end

		result[#result + 1] = selectedData
		listIndexes[selectedListIndex] = (listIndexes[selectedListIndex] or 1) + 1
	end
end

local function createTemplate(visionAreaList, visualAreaData)
	local isSorted = true

	for index = 1, #visionAreaList do
		local sourceList = visualAreaData[visionAreaList[index]]

		if sourceList and not isVisionAreaListSorted(sourceList) then
			isSorted = false

			break
		end
	end

	local visionAreas

	if isSorted then
		visionAreas = mergeSortedVisionAreaLists(visionAreaList, visualAreaData)
	else
		visionAreas = {}

		for index = 1, #visionAreaList do
			local sourceList = visualAreaData[visionAreaList[index]]

			if sourceList then
				appendVisionAreaList(visionAreas, sourceList)
			end
		end

		table.sort(visionAreas, compareVisionArea)
	end

	local maxVisionDistance = 0

	for index = 1, #visionAreas do
		maxVisionDistance = math.max(maxVisionDistance, visionAreas[index].distanceEnd)
	end

	return {
		visionAreas = visionAreas,
		maxVisionDistance = maxVisionDistance
	}
end

function VisionAreaTemplateCache.getOrCreate(groupId, vpGroupName, visionAreaList, visualAreaData)
	if groupId == nil or vpGroupName == nil then
		return emptyTemplate
	end

	local groupCache = templateCache[groupId]

	if groupCache == nil then
		groupCache = {}
		templateCache[groupId] = groupCache
	end

	local template = groupCache[vpGroupName]

	if template == nil then
		template = createTemplate(visionAreaList, visualAreaData)
		groupCache[vpGroupName] = template
	end

	return template
end

function VisionAreaTemplateCache.clearCache()
	templateCache = {}
end

return VisionAreaTemplateCache
