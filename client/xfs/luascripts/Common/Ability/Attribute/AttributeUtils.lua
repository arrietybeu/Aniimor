-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Attribute\\AttributeUtils.lua

local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityConst = require("Common.Const.AbilityConst")
local attribute_entry_data = require("Data.attribute_entry_data")
local Utils = require("Common.Utils.Utils")
local AttributeUtils = Class.LiteClass("AttributeUtils")

function AttributeUtils.getAttribBeginId(attributeId)
	return AttributeConst.ID_INFO[attributeId].beginId
end

function AttributeUtils.isMagicIsV(attributeId)
	return AttributeConst.ID_INFO[attributeId].offset == AbilityConst.ATTRIBUTE_ID_OFFSET_V
end

function AttributeUtils.isMagicIsP(attributeId)
	return AttributeConst.ID_INFO[attributeId].offset == AbilityConst.ATTRIBUTE_ID_OFFSET_P
end

function AttributeUtils.isMagicIsPVC(attributeId)
	local offset = AttributeConst.ID_INFO[attributeId].offset

	return offset >= AbilityConst.ATTRIBUTE_ID_OFFSET_CUR and offset <= AbilityConst.ATTRIBUTE_ID_OFFSET_P
end

function AttributeUtils.isTeamProperty(attributeId)
	return attributeId
end

function AttributeUtils.isEntryAreaMatched(entity, data, blockId)
	if not data.area or #data.area == 0 then
		return true
	end

	local curLargeAreaBlockId

	if pg.game and pg.game.map then
		curLargeAreaBlockId = blockId or pg.game.map.curBlockId or 0
	else
		curLargeAreaBlockId = blockId or Utils.getCurLargeAreaBlockId(entity) or 0
	end

	if curLargeAreaBlockId == 0 then
		return false
	end

	for _, areaId in ipairs(data.area) do
		if areaId == curLargeAreaBlockId then
			return true
		end
	end

	return false
end

function AttributeUtils._getAttrComplexValue(value, data, attrType)
	if attrType == AttributeConst.quality_ratio_fix then
		for i, ratio in ipairs(data.attrComplexValue) do
			value[i] = (value[i] or 1) * ratio
		end
	elseif attrType == AttributeConst.close_pet then
		for _, petId in ipairs(data.attrComplexValue) do
			value[petId] = true
		end
	end

	return value
end

function AttributeUtils.getAttrComplexValue(player, attrType)
	local value = {}

	for entryId, configId in pairs(player.attrEntrysMap) do
		local data = attribute_entry_data[configId]

		if data.attrComplexValue and AttributeUtils.isEntryAreaMatched(player, data) and data.attrType == AttributeConst.ID2NAME[attrType] then
			value = AttributeUtils._getAttrComplexValue(value, data, attrType)
		end
	end

	return value
end

return AttributeUtils
