-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Reporter\\ReporterModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ReporterModel = Class.LightClass("ReporterModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local ClientUtils = require("Utils.ClientUtils")

ReporterModel.NONE = 0
ReporterModel.REPORTER = 1
ReporterModel.PET_SUBMIT_REPORTER = 2
ReporterModel.PROP_REPORTER = 3

function ReporterModel:getReportPets()
	local me = pg.me
	local catchPets = me.catchPetsInfoReportList
	local res = {}
	local count = #catchPets

	if count <= 15 then
		count = 15
	elseif count % 5 > 0 then
		count = 5 - count % 5 + count
	end

	for i = 1, count do
		local v = catchPets[i]

		if v then
			local tpData = PetData[v.templateId] or {}

			res[i] = {
				isEmpty = false,
				id = v.petId,
				icon = LuaUIUtils.getPetIcon(tpData.iconName, LuaUIUtils.PET_ICON, v.label),
				isShiny = Utils.isLabelShiny(v.label),
				isBoss = Utils.isLabelElite(v.label),
				lv = v.level
			}

			local _, names = LuaUIUtils.getElementInfo(tpData.elementType)

			res[i].elements = names
		else
			res[i] = {
				isEmpty = true
			}
		end
	end

	return res
end

function ReporterModel:getPetReportAwardList()
	local me = pg.me
	local awardList = {}

	for id, num in pairs(me.catchPetsReportReward or EMPTY_TABLE) do
		local iData = ItemData[id]

		awardList[#awardList + 1] = {
			id = id,
			icon = iData.icon,
			count = num
		}
	end

	return awardList
end

function ReporterModel:checkHasReportAward()
	local rewards = pg.me.catchPetsReportReward or {}

	return table.nums(rewards) > 0
end

function ReporterModel:getPetSubmitData(eventParam)
	local res = {}
	local item2ConditionMap = {}

	if eventParam == nil then
		return res, item2ConditionMap
	end

	for i, v in ipairs(eventParam) do
		local conditionParam = v.conditionParam
		local conditionData = TriggerUtils.getConditionByRegInfo(conditionParam[1], conditionParam[2], conditionParam[3])
		local itemId = conditionData[3][1]

		item2ConditionMap[itemId] = {
			params = conditionParam,
			npcId = v.npcId,
			needNum = conditionData[5]
		}

		local item = {
			id = itemId,
			needNum = conditionData[5]
		}
		local iData = PetData[item.id]

		if iData then
			item.icon = LuaUIUtils.getPetIcon(iData.iconName, LuaUIUtils.PET_ICON)
			item.name = iData.name
		end

		res[i] = item
	end

	return res, item2ConditionMap
end

function ReporterModel:getOwnPetData(needPets)
	local res = {}

	if needPets == nil or #needPets == 0 then
		return res
	end

	local allPets = {}

	for i, v in ipairs(needPets) do
		allPets[i] = v.id
	end

	local me = pg.me

	for k, v in pairs(me.pets) do
		if table.contains(allPets, v.templateId) and not v.isTwinChoice then
			local isInPrepareList = false

			for _, id in ipairs(me.petPrepareList) do
				if id == k then
					isInPrepareList = true

					break
				end
			end

			if not isInPrepareList then
				local item = {
					id = k,
					templateId = v.templateId,
					level = v.level
				}
				local iData = PetData[item.templateId]

				if iData then
					item.isShiny = Utils.isLabelShiny(v.label)
					item.isBoss = Utils.isLabelElite(v.label)
					item.isMini = Utils.isLabelRainbow(v.label)
					item.icon = LuaUIUtils.getPetIcon(iData.iconName, LuaUIUtils.PET_ICON, v.label)
					item.name = iData.name

					local elementIds, elementNames = LuaUIUtils.getElementInfo(iData.elementType)

					item.elementIds = elementIds
					item.elementNames = elementNames
					item.elementType = iData.elementType
				end

				item.cp = LuaUIUtils.getPetCpValue(k)
				res[#res + 1] = item
			end
		end
	end

	table.sort(res, function(a, b)
		if a.cp == nil then
			return true
		elseif b.cp == nil then
			return false
		end

		return a.cp < b.cp
	end)

	return res
end

function ReporterModel:getPropSubmitData(eventParam)
	local res = {}
	local item2ConditionMap = {}

	if eventParam == nil then
		return res, item2ConditionMap
	end

	for i, v in ipairs(eventParam) do
		local conditionParam = v.conditionParam
		local conditionData = TriggerUtils.getConditionByRegInfo(conditionParam[1], conditionParam[2], conditionParam[3])
		local itemId = Utils.isTable(conditionData[3]) and conditionData[3][1] or conditionData[3]

		item2ConditionMap[itemId] = {
			params = conditionParam,
			npcId = v.npcId
		}

		local item = {
			id = itemId,
			needNum = conditionData[5]
		}
		local iData = ItemData[item.id]

		if iData then
			item.icon = LuaUIUtils.getIconByIconId(iData.icon)
			item.quality = iData.quality
			item.name = iData.itemName
		end

		res[i] = item
	end

	table.sort(res, function(a, b)
		return a.quality < b.quality
	end)

	return res, item2ConditionMap
end

function ReporterModel:getOwnPropNum(itemId)
	local num = ItemUtils.getItemCountById(pg.me, itemId)

	if pg.me:isInSelfHomeland() then
		num = num + ClientUtils.getHomelandItemCountById(itemId)
	end

	return num
end

function ReporterModel:getOwnPropData(needProps)
	local res = {}

	if needProps == nil or #needProps == 0 then
		return res
	end

	for _, v in ipairs(needProps) do
		local num = self:getOwnPropNum(v.id)
		local item = {
			id = v.id,
			ownNum = num
		}
		local iData = ItemData[item.id]

		if iData then
			item.icon = LuaUIUtils.getIconByIconId(iData.icon)
			item.quality = iData.quality
			item.name = iData.itemName
		end

		res[#res + 1] = item
	end

	return res
end

return ReporterModel
