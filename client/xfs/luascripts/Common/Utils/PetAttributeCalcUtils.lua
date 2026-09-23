-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PetAttributeCalcUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local AttributeCalcUtils = require("Common.Ability.Attribute.AttributeCalcUtils")
local CommonSwitch = require("Common.CommonSwitch")
local DungeonConst = require("Common.Const.DungeonConst")
local PetData = require("Data.pet_data")
local PropertyData = require("Data.property_data")
local PetTalentData = require("Data.pet_talent_data")
local CoreCarryData = require("Data.core_carry_data")
local CoreCarryLevelData = require("Data.core_carry_level_data")
local AssistCarryData = require("Data.assist_carry_data")
local ItemData = require("Data.item_data")
local PetPropLevelData = require("Data.pet_prop_level_data")
local PrimaryPropertyRevertData = require("Data.primaryproperty_revert_data")
local AttributeGroupData = require("Data.attribute_group_data")
local AttributeIdData = require("Data.attribute_id_data")
local PetDisplayAttrNames = require("Data.pet_display_attr_names")
local AttributeEntryData = require("Data.attribute_entry_data")
local BuffCalcValueData = require("Data.buff_calc_value_data")
local FormulaData = require("Data.formula_data")
local FormulaExplictData = require("Data.formula_explict_data")
local ResonancePropertyData = require("Data.pet_resonance_property_data")
local unpack = unpack
local PetAttributeCalcUtils = {}
local COMMON_BASIC_ATTR_NAME_MAP = {}

for _, attrName in ipairs(Const.COMMON_BASIC_ATTRIBS or EMPTY_TABLE) do
	COMMON_BASIC_ATTR_NAME_MAP[attrName] = true
end

local PET_INDIVIDUAL_POINT_ATTR_NAME_TO_PROP_INDEX = {
	pet_individual_point_hp = Const.BASE_PROPERTY_HP_IDX,
	pet_individual_point_atk = Const.BASE_PROPERTY_ATK_IDX,
	pet_individual_point_def = Const.BASE_PROPERTY_DEF_IDX,
	pet_individual_point_ep_regen_force = Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX,
	pet_individual_point_def_mag = Const.BASE_PROPERTY_DEF_MAG_IDX,
	pet_individual_point_bp_atk = Const.BASE_PROPERTY_ATK_MAG_IDX
}
local petAttributeCalcContextDef = {
	templateId = {
		"number"
	},
	petPrototypeId = {
		"number"
	},
	player = {
		"table"
	},
	level = {
		"number",
		0
	},
	propertyScoreStage = {
		"number",
		0
	},
	basePropertyList = {
		"table"
	},
	talentList = {
		"table"
	},
	coreCarryInfo = {
		"table"
	},
	assistCarryInfos = {
		"table"
	},
	resonanceInfo = {
		"table"
	}
}

function PetAttributeCalcUtils.formatPetAttributeCalcContext(context)
	if not Utils.isTable(context) then
		context = {}
	end

	local result = {}

	for key, def in pairs(petAttributeCalcContextDef) do
		local value = context[key]

		if value == nil then
			value = def[2]
		end

		if value ~= nil then
			local isValid

			if def[1] == "table" then
				isValid = Utils.isTable(value)
			else
				isValid = type(value) == def[1]
			end

			if isValid then
				result[key] = value
			elseif def[2] ~= nil then
				result[key] = def[2]
			end
		end
	end

	return result
end

function PetAttributeCalcUtils.getPropertyValue(value, context)
	if not value then
		return 0
	end

	if not Utils.isTable(value) then
		return value
	end

	local formulaId, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5 = unpack(value)
	local formulaData = FormulaData[formulaId]

	if not formulaData then
		return 0
	end

	return formulaData.formula(context.level or 0, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5)
end

function PetAttributeCalcUtils.addAttributeValue(attributeMap, attrName, value)
	if not AttributeConst[attrName] then
		return
	end

	attributeMap[attrName] = (attributeMap[attrName] or 0) + (value or 0)
end

function PetAttributeCalcUtils.addPropsToAttributeMap(attributeMap, props, rate)
	rate = rate or 1

	for propId, value in pairs(props or EMPTY_TABLE) do
		local attribute = AttributeGroupData[propId]

		for _, attrName in ipairs(attribute and attribute.attrs or EMPTY_TABLE) do
			PetAttributeCalcUtils.addAttributeValue(attributeMap, attrName, (value or 0) * rate)
		end
	end
end

function PetAttributeCalcUtils.addConversionInfo(conversionList, fromAttrName, toAttrName, rate, srcType, srcId)
	if AttributeConst[fromAttrName] and AttributeConst[toAttrName] and rate and rate ~= 0 then
		conversionList[#conversionList + 1] = {
			fromAttrName = fromAttrName,
			toAttrName = toAttrName,
			rate = rate,
			srcType = srcType,
			srcId = srcId
		}
	end
end

function PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, addMap, srcType)
	for attrName, value in pairs(addMap or EMPTY_TABLE) do
		local attrId = AttributeConst[attrName]
		local isBindPlayerAttr = attrId and (attrId >= AttributeConst.GROUP_BASE_XP_BIND_PLAYER_BEGIN and attrId <= AttributeConst.GROUP_BASE_XP_BIND_PLAYER_END or attrId >= AttributeConst.GROUP_BASE_SINGLE_BIND_PLAYER_BEGIN and attrId <= AttributeConst.GROUP_BASE_SINGLE_BIND_PLAYER_END)

		if attrId and not isBindPlayerAttr then
			attributeMap[attrName] = (attributeMap[attrName] or 0) + (value or 0)

			local propIndex = extraMap and PET_INDIVIDUAL_POINT_ATTR_NAME_TO_PROP_INDEX[attrName]

			if propIndex and value ~= 0 then
				extraMap[propIndex] = extraMap[propIndex] or {
					iLvEx = 0,
					extraSrcMap = {}
				}
				extraMap[propIndex].iLvEx = extraMap[propIndex].iLvEx + value

				if srcType then
					extraMap[propIndex].extraSrcMap[srcType] = (extraMap[propIndex].extraSrcMap[srcType] or 0) + value
				end
			end
		end
	end
end

function PetAttributeCalcUtils.getTemplateAttributeMap(context)
	local attributeMap = {}
	local petConfig = PetData[context.templateId]

	if not petConfig then
		return attributeMap
	end

	local propData = petConfig.propId and PropertyData[petConfig.propId] or {}

	PetAttributeCalcUtils.addAttributeValue(attributeMap, "level", context.level or 0)
	PetAttributeCalcUtils.addAttributeValue(attributeMap, "hp_max_v", PetAttributeCalcUtils.getPropertyValue(propData.hp_max_v or 0, context))

	for attrName, value in pairs(propData or EMPTY_TABLE) do
		if AttributeConst[attrName] and not COMMON_BASIC_ATTR_NAME_MAP[attrName] then
			local realValue = PetAttributeCalcUtils.getPropertyValue(value, context)

			PetAttributeCalcUtils.addAttributeValue(attributeMap, attrName, realValue)
		end
	end

	return attributeMap
end

function PetAttributeCalcUtils.getTalentAttributeMap(talentList, enhanceRatio)
	local attributeMap = {}

	if not Utils.isTable(talentList) then
		return attributeMap
	end

	enhanceRatio = enhanceRatio or 0

	for _, talentInfo in pairs(talentList) do
		local talentData = Utils.isTable(talentInfo) and PetTalentData[talentInfo.templateId]

		for propIndex, prop in ipairs(talentData and talentData.props or EMPTY_TABLE) do
			local propId = prop[Const.TALENT_PROP_IDX_PROPID]
			local propValue = talentInfo.propValues and talentInfo.propValues[propIndex] or 0

			if propId then
				PetAttributeCalcUtils.addPropsToAttributeMap(attributeMap, {
					[propId] = propValue
				}, 1 + enhanceRatio)
			end
		end
	end

	return attributeMap
end

function PetAttributeCalcUtils.getCoreCarryLevel(coreCarryInfo)
	local itemId = coreCarryInfo and coreCarryInfo.itemId or 0
	local quality = ItemData[itemId] and ItemData[itemId].quality or 0
	local exp = coreCarryInfo and coreCarryInfo.totalExp or 0
	local level = 0

	for i = 1, Const.FOR_LOOP_MAX_1000 do
		local levelData = CoreCarryLevelData[i]

		if not levelData then
			break
		end

		if exp >= (levelData.needExp or 0) and lume.find(levelData.needQuality or {}, quality) then
			level = i
			exp = exp - (levelData.needExp or 0)
		else
			break
		end
	end

	return level, exp
end

function PetAttributeCalcUtils.isEnergyEffectActive(energyEffect, energySum, coreCarryLevel)
	energyEffect = energyEffect or {}

	local needEnergy = energyEffect[1] or 0
	local needLevel = energyEffect[3] or 0

	return needEnergy <= energySum and needLevel <= coreCarryLevel
end

function PetAttributeCalcUtils.getCoreCarryEnhanceRatio(coreCarryInfo)
	local level = PetAttributeCalcUtils.getCoreCarryLevel(coreCarryInfo)

	return CoreCarryLevelData[level] and CoreCarryLevelData[level].enhanceRatio or 0
end

function PetAttributeCalcUtils.getCoreCarryAttributeMaps(context)
	local attributeMaps = {}
	local buffIds = {}
	local conversionList = {}

	if not CommonSwitch.PETEQUIPMENT then
		return attributeMaps, buffIds, conversionList
	end

	local coreCarryInfo = context.coreCarryInfo
	local coreCarryData = coreCarryInfo and CoreCarryData[coreCarryInfo.itemId]

	if not coreCarryData then
		return attributeMaps, buffIds, conversionList
	end

	local coreCarryLevel = PetAttributeCalcUtils.getCoreCarryLevel(coreCarryInfo)
	local enhanceRatio = CoreCarryLevelData[coreCarryLevel] and CoreCarryLevelData[coreCarryLevel].enhanceRatio or 0

	attributeMaps[#attributeMaps + 1] = {
		srcType = AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY,
		attributeMap = PetAttributeCalcUtils.getTalentAttributeMap(coreCarryInfo.talentList, enhanceRatio)
	}

	local corePropMap = {}

	PetAttributeCalcUtils.addPropsToAttributeMap(corePropMap, coreCarryData.prop, 1 + enhanceRatio)

	attributeMaps[#attributeMaps + 1] = {
		srcType = AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY_EX,
		attributeMap = corePropMap
	}

	local energySum = 0

	for index, assistCarryInfo in pairs(context.assistCarryInfos or EMPTY_TABLE) do
		local assistCarryData = assistCarryInfo and AssistCarryData[assistCarryInfo.itemId]

		if assistCarryData then
			energySum = energySum + (assistCarryData.energy or 0)
			attributeMaps[#attributeMaps + 1] = {
				srcType = AbilityConst["ATTRIBUTE_SRC_TYPE_ASSIST_CARRY_" .. index],
				attributeMap = PetAttributeCalcUtils.getTalentAttributeMap(assistCarryInfo.talentList, 0)
			}

			local assistPropMap = {}

			PetAttributeCalcUtils.addPropsToAttributeMap(assistPropMap, assistCarryData.baseprop, 1)

			attributeMaps[#attributeMaps + 1] = {
				srcType = AbilityConst.ATTRIBUTE_SRC_TYPE_ASSIST_CARRY_EX,
				attributeMap = assistPropMap
			}
		end
	end

	for _, buffId in ipairs(coreCarryData.buffId or EMPTY_TABLE) do
		buffIds[#buffIds + 1] = buffId
	end

	for _, energyEffect in ipairs(coreCarryData.energyEffects or EMPTY_TABLE) do
		if PetAttributeCalcUtils.isEnergyEffectActive(energyEffect, energySum, coreCarryLevel) then
			for _, buffId in ipairs(energyEffect[2] or EMPTY_TABLE) do
				buffIds[#buffIds + 1] = buffId
			end
		end
	end

	for _, conversionInfo in ipairs(coreCarryData.propConversions or EMPTY_TABLE) do
		local fromAttrName, toAttrName, rate = unpack(conversionInfo)
		local srcId = string.format("%s_%s->%s", tostring(coreCarryInfo.itemId), tostring(fromAttrName), tostring(toAttrName))

		PetAttributeCalcUtils.addConversionInfo(conversionList, fromAttrName, toAttrName, rate, AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY_CONVERSION, srcId)
	end

	return attributeMaps, buffIds, conversionList
end

function PetAttributeCalcUtils.getBuffTemplate(buffId)
	if pg and pg.global and pg.global.abilityMgr and pg.global.abilityMgr.getBuffTemplate then
		return pg.global.abilityMgr:getBuffTemplate(buffId)
	end

	local ok, data = pcall(require, "Common.Data.SkillBPData.BuffBP.Buff_" .. tostring(buffId))

	if ok then
		return data
	end

	return nil
end

function PetAttributeCalcUtils.getBuffCalcValue(data, currentAttributeMap)
	if not data then
		return 0
	end

	if data.formulaValue or data.formulaByPetCacheProp then
		local formulaArgs = data.formulaValue or data.formulaByPetCacheProp
		local formulaData = FormulaData[formulaArgs[1]]
		local args = {}

		if not formulaData then
			return 0
		end

		if data.formulaValue then
			for i = 2, 6 do
				local arg = formulaArgs[i]

				if not arg then
					break
				end

				if AttributeConst[arg] then
					args[#args + 1] = PetAttributeCalcUtils.calcAttrNameValue(arg, currentAttributeMap or {})
				else
					args[#args + 1] = arg
				end
			end
		else
			for i = 2, 6 do
				args[#args + 1] = 0
			end
		end

		if data.formulaExplictId then
			local explictData = FormulaExplictData[data.formulaExplictId]

			if not explictData then
				return 0
			end

			args[#args + 1] = explictData.minNum
			args[#args + 1] = explictData.rate
			args[#args + 1] = explictData.upRate
			args[#args + 1] = explictData.maxNum
		end

		return formulaData.formula(unpack(args)) or 0
	end

	return data.calcValue or 0
end

function PetAttributeCalcUtils.getBuffConversionRate(valueConfig, currentAttributeMap)
	if type(valueConfig) == "number" then
		return valueConfig
	end

	if not Utils.isTable(valueConfig) then
		return 0
	end

	if valueConfig.name == "constNumber" then
		return valueConfig.number or 0
	end

	if valueConfig.name == "getParamByLuaConfig" then
		local data = ((BuffCalcValueData[valueConfig.calcId] or EMPTY_TABLE)[valueConfig.paramName] or EMPTY_TABLE)[1]

		return PetAttributeCalcUtils.getBuffCalcValue(data, currentAttributeMap)
	end

	if valueConfig.name == "div" then
		local leftValue = PetAttributeCalcUtils.getBuffConversionRate(valueConfig.lValue, currentAttributeMap)
		local rightValue = PetAttributeCalcUtils.getBuffConversionRate(valueConfig.rValue, currentAttributeMap)

		if ToBool(rightValue) then
			return leftValue / rightValue
		end

		return 0
	end

	if valueConfig.name == "mul" then
		return PetAttributeCalcUtils.getBuffConversionRate(valueConfig.lValue, currentAttributeMap) * PetAttributeCalcUtils.getBuffConversionRate(valueConfig.rValue, currentAttributeMap)
	end

	if valueConfig.name == "add" then
		return PetAttributeCalcUtils.getBuffConversionRate(valueConfig.lValue, currentAttributeMap) + PetAttributeCalcUtils.getBuffConversionRate(valueConfig.rValue, currentAttributeMap)
	end

	if valueConfig.name == "sub" then
		return PetAttributeCalcUtils.getBuffConversionRate(valueConfig.lValue, currentAttributeMap) - PetAttributeCalcUtils.getBuffConversionRate(valueConfig.rValue, currentAttributeMap)
	end

	return 0
end

function PetAttributeCalcUtils.getBuffAttributeMap(buffIds, currentAttributeMap)
	local attributeMap = {}
	local conversionList = {}

	for _, buffId in ipairs(buffIds or EMPTY_TABLE) do
		local buffTemplate = PetAttributeCalcUtils.getBuffTemplate(buffId)

		if buffTemplate then
			for attrName, valueConfig in pairs(buffTemplate.calcInfo or EMPTY_TABLE) do
				if AttributeConst[attrName] then
					local value = valueConfig

					if Utils.isTable(valueConfig) then
						value = nil

						if valueConfig.name == "getParamByLuaConfig" then
							local data = ((BuffCalcValueData[valueConfig.calcId] or EMPTY_TABLE)[valueConfig.paramName] or EMPTY_TABLE)[1]

							if data then
								value = PetAttributeCalcUtils.getBuffCalcValue(data, currentAttributeMap)
							end
						end
					end

					if value ~= nil then
						PetAttributeCalcUtils.addAttributeValue(attributeMap, attrName, value)
					end
				end
			end

			local luaConfig = buffTemplate.calcInfoByLuaConfig

			if luaConfig then
				for attrName, paramName in pairs(luaConfig) do
					if attrName ~= "id" and attrName ~= "type" and AttributeConst[attrName] then
						local data = ((BuffCalcValueData[luaConfig.id] or EMPTY_TABLE)[paramName] or EMPTY_TABLE)[1]

						if data then
							PetAttributeCalcUtils.addAttributeValue(attributeMap, attrName, PetAttributeCalcUtils.getBuffCalcValue(data, currentAttributeMap))
						end
					end
				end
			end

			for _, actionId in ipairs(buffTemplate.onBuffStartIds or EMPTY_TABLE) do
				local actionData = buffTemplate.nodeMap and buffTemplate.nodeMap[actionId]

				if actionData and actionData.name == "attributeConversion" then
					for fromAttrName, conversionInfoList in pairs(actionData.conversionByCurValueMap or EMPTY_TABLE) do
						for _, conversionInfo in ipairs(conversionInfoList or EMPTY_TABLE) do
							local rate = PetAttributeCalcUtils.getBuffConversionRate(conversionInfo.rate, currentAttributeMap)

							PetAttributeCalcUtils.addConversionInfo(conversionList, conversionInfo.fromAttributeName or fromAttrName, conversionInfo.toAttributeName, rate, AbilityConst.ATTRIBUTE_SRC_TYPE_BUFF_CONVERSION, buffId)
						end
					end
				end
			end
		end
	end

	return attributeMap, conversionList
end

function PetAttributeCalcUtils.getResonanceAttributeMap(context)
	local attributeMap = {}
	local resonanceStage = context.resonanceInfo and context.resonanceInfo.resonanceStage or 0
	local resonanceLevel = context.resonanceInfo and context.resonanceInfo.resonanceLevel or 0
	local stageData = ResonancePropertyData[resonanceStage]
	local levelData = stageData and stageData[resonanceLevel]

	for _, prop in pairs(levelData and levelData.props or EMPTY_TABLE) do
		PetAttributeCalcUtils.addPropsToAttributeMap(attributeMap, {
			[prop[1]] = prop[2]
		}, 1)
	end

	return attributeMap
end

function PetAttributeCalcUtils.getFormCollectEntryAttributeMap(context, countryId)
	local attributeMap = {}
	local formAbilityMap = {}

	if context.player and context.player.petHandbookMap and context.petPrototypeId then
		formAbilityMap = Utils.getDesiredPetFormAbilityMap(context.player.petHandbookMap, context.petPrototypeId, countryId)
	end

	for _, entryConfigId in pairs(formAbilityMap) do
		local entryData = AttributeEntryData[entryConfigId]

		if entryData and entryData.attrType and entryData.attrValue and AttributeConst[entryData.attrType] then
			PetAttributeCalcUtils.addAttributeValue(attributeMap, entryData.attrType, entryData.attrValue)
		end
	end

	return attributeMap, formAbilityMap
end

function PetAttributeCalcUtils.getBasePropertyList(context, extraMap)
	local basePropertyList = Utils.deepCopyTable(context.basePropertyList or {}) or {}

	extraMap = extraMap or {}

	local configData = PetData[context.templateId]

	for propIndex, baseProp in pairs(basePropertyList or EMPTY_TABLE) do
		if not Utils.isTable(baseProp) then
			baseProp = {}
			basePropertyList[propIndex] = baseProp
		end

		if not baseProp.speciesPoint or baseProp.speciesPoint == 0 then
			baseProp.speciesPoint = Utils.getBasePropertySpeciesPoint(configData, propIndex)
		end

		baseProp.indLv = baseProp.indLv or 0

		local extraInfo = extraMap[propIndex]

		baseProp.iLvEx = extraInfo and extraInfo.iLvEx or 0
	end

	local refreshParams = Utils.genRefreshTotalParamsByPetInfo(context.level, context.propertyScoreStage, Utils.isIndividualFullLearned(basePropertyList))

	for propIndex, baseProp in pairs(basePropertyList or EMPTY_TABLE) do
		baseProp.total, baseProp.totalByUp = Utils.PropertyRefreshTotal(propIndex, baseProp, refreshParams)
	end

	return basePropertyList
end

function PetAttributeCalcUtils.getBasePropertyAttributeMap(context, basePropertyList)
	local attributeMap = {}
	local petConfig = PetData[context.templateId]

	if not petConfig then
		return attributeMap
	end

	local propData = petConfig.propId and PropertyData[petConfig.propId] or {}

	for propIndex, baseProp in pairs(basePropertyList or EMPTY_TABLE) do
		local attrName = Utils.getPropFinalAttrName(propIndex)

		if attrName then
			local fixedRateName = Const.BASE_ATTRS_FIXED_RATE_MAP[attrName]
			local fixedRate = PetAttributeCalcUtils.getPropertyValue(propData[fixedRateName] or 1, context)

			PetAttributeCalcUtils.addAttributeValue(attributeMap, attrName, (baseProp.total or 0) * fixedRate)
		end

		local individualAttrName = PrimaryPropertyRevertData[propIndex]

		if individualAttrName then
			PetAttributeCalcUtils.addAttributeValue(attributeMap, individualAttrName, baseProp.indLv or 0)
		end

		local allIndividualLevel = (baseProp.indLv or 0) + (baseProp.iLvEx or 0)
		local levelData = PetPropLevelData[propIndex]
		local curData = levelData and levelData[allIndividualLevel]

		if curData and curData.extraPropId and curData.extraPropNum then
			PetAttributeCalcUtils.addPropsToAttributeMap(attributeMap, {
				[curData.extraPropId] = curData.extraPropNum
			}, 1)
		end

		PetAttributeCalcUtils.mergeAttributeMap(attributeMap, nil, Utils.calcPetIndividualConvertAttrMap(propIndex, allIndividualLevel))
	end

	return attributeMap
end

function PetAttributeCalcUtils.getBasePropertyExtraSrcMap(basePropertyList, extraMap)
	local extraSrcMap = {}

	for propIndex, baseProp in pairs(basePropertyList or EMPTY_TABLE) do
		local extraInfo = extraMap and extraMap[propIndex]

		extraSrcMap[propIndex] = {
			iLvEx = baseProp.iLvEx or 0,
			extraSrcMap = Utils.deepCopyTable(extraInfo and extraInfo.extraSrcMap or {}),
			allIndividualLevel = (baseProp.indLv or 0) + (baseProp.iLvEx or 0),
			total = baseProp.total or 0,
			totalByUp = baseProp.totalByUp or 0
		}
	end

	return extraSrcMap
end

function PetAttributeCalcUtils.clampAttrNameValue(attrName, value)
	if type(value) ~= "number" then
		return value
	end

	local attrData = AttributeIdData[attrName]

	if attrData and attrData.min ~= nil and value < attrData.min then
		return attrData.min
	end

	if attrData and attrData.max ~= nil and value > attrData.max then
		return attrData.max
	end

	return value
end

function PetAttributeCalcUtils.calcXpMaxCurValue(beginId, attributeMap)
	attributeMap = attributeMap or {}

	return AttributeCalcUtils.calcXpMaxCurValue(attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_SCALE]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_FORCE_SET]] or 0)
end

function PetAttributeCalcUtils.calcPvcCurValue(beginId, attributeMap)
	attributeMap = attributeMap or {}

	return AttributeCalcUtils.calcPvcCurValue(attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV]] or 0)
end

function PetAttributeCalcUtils.calcMaxPvcCurValue(beginId, attributeMap)
	attributeMap = attributeMap or {}

	return AttributeCalcUtils.calcMaxPvcCurValue(attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX]] or 0, attributeMap[AttributeConst.ID2NAME[beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV]] or 0)
end

function PetAttributeCalcUtils.calcAttrNameValue(attrName, attributeMap)
	attributeMap = attributeMap or {}

	local attributeId = AttributeConst[attrName]
	local info = attributeId and AttributeConst.ID_INFO[attributeId]
	local value = attributeMap[attrName] or 0

	if info and attributeId >= AttributeConst.GROUP_BASE_XP_BEGIN and attributeId <= AttributeConst.GROUP_BASE_XP_END then
		if info.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CUR then
			value = PetAttributeCalcUtils.calcXpMaxCurValue(info.beginId, attributeMap)
		elseif info.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_XP_CUR then
			value = AttributeCalcUtils.calcLimitCurValue(value, PetAttributeCalcUtils.calcXpMaxCurValue(info.beginId, attributeMap))
		end
	elseif info and attributeId >= AttributeConst.GROUP_BASE_PVC_BEGIN and attributeId <= AttributeConst.GROUP_BASE_PVC_END then
		if info.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CUR then
			value = PetAttributeCalcUtils.calcPvcCurValue(info.beginId, attributeMap)
		end
	elseif info and attributeId >= AttributeConst.GROUP_BASE_MAX_PVC_CUR_BEGIN and attributeId <= AttributeConst.GROUP_BASE_MAX_PVC_CUR_END then
		if info.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CUR then
			value = PetAttributeCalcUtils.calcMaxPvcCurValue(info.beginId, attributeMap)
		elseif info.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_MAX_PVC_CUR then
			value = AttributeCalcUtils.calcLimitCurValue(value, PetAttributeCalcUtils.calcMaxPvcCurValue(info.beginId, attributeMap))
		end
	elseif info and attributeId >= AttributeConst.GROUP_BASE_CUR_MAX_BEGIN and attributeId <= AttributeConst.GROUP_BASE_CUR_MAX_END and info.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CUR then
		local maxName = AttributeConst.ID2NAME[info.beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR_MAX]

		value = AttributeCalcUtils.calcLimitCurValue(value, attributeMap[maxName] or 0)
	end

	return PetAttributeCalcUtils.clampAttrNameValue(attrName, value)
end

function PetAttributeCalcUtils.calculateAttrNameMap(attributeMap, targetAttrNames)
	local result = {}

	if targetAttrNames then
		for attrName, _ in pairs(targetAttrNames) do
			result[attrName] = PetAttributeCalcUtils.calcAttrNameValue(attrName, attributeMap)
		end
	else
		for attrName, _ in pairs(attributeMap or EMPTY_TABLE) do
			result[attrName] = PetAttributeCalcUtils.calcAttrNameValue(attrName, attributeMap)
		end
	end

	return result
end

function PetAttributeCalcUtils.convertAttrNameMapToIdMap(attributeMap)
	local attrIdMap = {}

	for attrName, value in pairs(attributeMap or EMPTY_TABLE) do
		local attrId = AttributeConst[attrName]

		if attrId then
			attrIdMap[attrId] = value
		end
	end

	return attrIdMap
end

function PetAttributeCalcUtils.getConversionBaseValue(fromAttrName, attributeMap)
	attributeMap = attributeMap or {}

	local fromAttributeId = AttributeConst[fromAttrName]
	local fromInfo = fromAttributeId and AttributeConst.ID_INFO[fromAttributeId]
	local curValue = PetAttributeCalcUtils.calcAttrNameValue(fromAttrName, attributeMap) or 0
	local hasConversion = fromInfo and (fromAttributeId >= AttributeConst.GROUP_BASE_XP_BEGIN and fromAttributeId <= AttributeConst.GROUP_BASE_XP_END or fromAttributeId >= AttributeConst.GROUP_BASE_PVC_BEGIN and fromAttributeId <= AttributeConst.GROUP_BASE_PVC_END or fromAttributeId >= AttributeConst.GROUP_BASE_MAX_PVC_CUR_BEGIN and fromAttributeId <= AttributeConst.GROUP_BASE_MAX_PVC_CUR_END)

	if not hasConversion then
		return curValue
	end

	local conversionAttrName = AttributeConst.ID2NAME[fromInfo.beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV]
	local conversionValue = conversionAttrName and attributeMap[conversionAttrName] or 0
	local scale = 1 + (fromInfo.beginId == AttributeConst.hp_max_cur and (attributeMap.hp_scale or 0) or 0)

	return AttributeCalcUtils.calcConversionBaseValue(curValue, conversionValue, scale)
end

function PetAttributeCalcUtils.applyConversionList(attributeMap, conversionList)
	local result = Utils.deepCopyTable(attributeMap or {}) or {}
	local conversionAttrNameMap = {}

	for _, conversionInfo in ipairs(conversionList or EMPTY_TABLE) do
		local fromAttrName = conversionInfo.fromAttrName or conversionInfo.fromAttributeName or conversionInfo[1]
		local toAttrName = conversionInfo.toAttrName or conversionInfo.toAttributeName or conversionInfo[2]
		local rate = conversionInfo.rate or conversionInfo[3] or 0
		local toAttributeId = AttributeConst[toAttrName]
		local toInfo = toAttributeId and AttributeConst.ID_INFO[toAttributeId]

		if AttributeConst[fromAttrName] and toInfo and toInfo.offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CONV and rate ~= 0 then
			local value = PetAttributeCalcUtils.getConversionBaseValue(fromAttrName, attributeMap) * rate

			PetAttributeCalcUtils.addAttributeValue(result, toAttrName, value)
			PetAttributeCalcUtils.addAttributeValue(conversionAttrNameMap, toAttrName, value)
		end
	end

	return result, conversionAttrNameMap
end

function PetAttributeCalcUtils.getPetCoreCarryInfo(player, petInfo)
	if player and petInfo then
		local petId = petInfo.id
		local carryPosMap

		if petId and player.tempPets and player.tempPets[petId] then
			carryPosMap = player.tempPetCoreCarryPosMap
		elseif petId and player.pets and player.pets[petId] then
			carryPosMap = player.petCoreCarryPosMap
		end

		if carryPosMap and carryPosMap.getItemInfo then
			return carryPosMap:getItemInfo(petId)
		end
	end

	return petInfo and petInfo.coreCarryInfo or nil
end

function PetAttributeCalcUtils.isAssistCarryEnabled(player)
	local space = player and player.space

	if space and space.isRobEgg and space:isRobEgg() and space.mode == DungeonConst.RobEggMode.MultiTeam then
		return false
	end

	return true
end

function PetAttributeCalcUtils.getAssistCarryInfos(player, coreCarryInfo, petInfo)
	if player and not PetAttributeCalcUtils.isAssistCarryEnabled(player) then
		return {}
	end

	if petInfo and petInfo.assistCarryInfos then
		return petInfo.assistCarryInfos
	end

	if coreCarryInfo and coreCarryInfo.assistCarryInfos then
		return coreCarryInfo.assistCarryInfos
	end

	local assistCarryInfos = {}
	local assistCarryPosList = coreCarryInfo and coreCarryInfo.assistCarryPosList

	if not player or not Utils.isTable(assistCarryPosList) then
		return assistCarryInfos
	end

	for index, itemPos in ipairs(assistCarryPosList) do
		local invId, genId = 0, 0
		local isValid = false

		if itemPos and itemPos.isValid then
			isValid = itemPos:isValid()

			if isValid then
				invId, genId = itemPos:unpack()
			end
		elseif Utils.isTable(itemPos) then
			invId = itemPos[1] or itemPos.invId or 0
			genId = itemPos[2] or itemPos.genId or 0
			isValid = invId ~= 0 and genId ~= 0
		end

		if isValid then
			local item = player.getItem and player:getItem(invId, genId) or ItemUtils.getItem(player, invId, genId)
			local assistCarryInfo = item and ItemUtils.getPropertyWithType(item)

			if assistCarryInfo then
				assistCarryInfos[index] = assistCarryInfo
			end
		end
	end

	return assistCarryInfos
end

function PetAttributeCalcUtils.collectPetAttrNameMapByContext(context)
	context = PetAttributeCalcUtils.formatPetAttributeCalcContext(context)

	local attributeMap = {}
	local extraMap = {}
	local conversionList = {}

	PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, PetAttributeCalcUtils.getTemplateAttributeMap(context), AbilityConst.ATTRIBUTE_SRC_TYPE_LEVEL)
	PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, PetAttributeCalcUtils.getTalentAttributeMap(context.talentList, 0), AbilityConst.ATTRIBUTE_SRC_TYPE_PET_TALENT)

	local coreCarryAttributeMaps, buffIds, coreCarryConversionList = PetAttributeCalcUtils.getCoreCarryAttributeMaps(context)

	for _, info in ipairs(coreCarryAttributeMaps) do
		PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, info.attributeMap, info.srcType)
	end

	for _, conversionInfo in ipairs(coreCarryConversionList or EMPTY_TABLE) do
		conversionList[#conversionList + 1] = conversionInfo
	end

	local buffAttributeMap, buffConversionList = PetAttributeCalcUtils.getBuffAttributeMap(buffIds, attributeMap)

	PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, buffAttributeMap, AbilityConst.ATTRIBUTE_SRC_TYPE_BUFF)

	for _, conversionInfo in ipairs(buffConversionList or EMPTY_TABLE) do
		conversionList[#conversionList + 1] = conversionInfo
	end

	PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, PetAttributeCalcUtils.getResonanceAttributeMap(context), AbilityConst.ATTRIBUTE_SRC_TYPE_PET_RESONANCE)

	local formCollectEntryAttributeMap, formAbilityMap = PetAttributeCalcUtils.getFormCollectEntryAttributeMap(context)

	PetAttributeCalcUtils.mergeAttributeMap(attributeMap, extraMap, formCollectEntryAttributeMap, AbilityConst.ATTRIBUTE_SRC_TYPE_ENTRY)

	local basePropertyList = PetAttributeCalcUtils.getBasePropertyList(context, extraMap)

	PetAttributeCalcUtils.mergeAttributeMap(attributeMap, nil, PetAttributeCalcUtils.getBasePropertyAttributeMap(context, basePropertyList))

	local extraSrcMap = PetAttributeCalcUtils.getBasePropertyExtraSrcMap(basePropertyList, extraMap)

	return attributeMap, {
		context = context,
		attrNameMap = attributeMap,
		extraMap = extraMap,
		extraSrcMap = extraSrcMap,
		basePropertyList = basePropertyList,
		conversionList = conversionList,
		formAbilityMap = formAbilityMap
	}
end

function PetAttributeCalcUtils.getAttributeMapByCaculate(context, petInfo)
	local existEntity = pg.getEntity(petInfo and petInfo.id)
	local attributeMap, result = PetAttributeCalcUtils.collectPetAttrNameMapByContext(context)

	result.firstAttrNameMap = PetAttributeCalcUtils.calculateAttrNameMap(attributeMap)
	result.convertedAttrNameMap, result.conversionAttrNameMap = PetAttributeCalcUtils.applyConversionList(attributeMap, result.conversionList)
	result.displayAttrNameMap = PetAttributeCalcUtils.calculateAttrNameMap(result.convertedAttrNameMap, PetDisplayAttrNames)
	result.displayAttrMap = existEntity and existEntity.baseAttr or PetAttributeCalcUtils.convertAttrNameMapToIdMap(result.displayAttrNameMap)
	result.rawAttrNameMap = result.attrNameMap
	result.attrNameMap = result.displayAttrNameMap
	result.attrMap = result.displayAttrMap

	return result.attrMap, result.extraSrcMap, result
end

function PetAttributeCalcUtils.getAttributeMapByPetInfo(player, petInfo)
	local calculatedAttributeMap = petInfo and petInfo.calculatedAttributeMap

	if Utils.isTable(calculatedAttributeMap) then
		return calculatedAttributeMap, petInfo.extraSrcMap or {}
	end

	local templateId = petInfo and (petInfo.templateId or petInfo.petPrototypeId)
	local petConfig = templateId and PetData[templateId]
	local petPrototypeId = petInfo and (petInfo.petPrototypeId or petInfo.basePetPrototypeId) or nil

	petPrototypeId = petPrototypeId or petConfig and petConfig.petPrototypeId or templateId
	petPrototypeId = petPrototypeId and Utils.getBasePetPrototypeId(petPrototypeId)

	local coreCarryInfo = PetAttributeCalcUtils.getPetCoreCarryInfo(player, petInfo)
	local context = {
		templateId = templateId,
		petPrototypeId = petPrototypeId,
		player = player,
		level = petInfo and petInfo.level or 0,
		propertyScoreStage = petInfo and petInfo.propertyScoreStage or 0,
		basePropertyList = petInfo and petInfo.basePropertyList or nil,
		talentList = petInfo and petInfo.talentList or nil,
		coreCarryInfo = coreCarryInfo,
		assistCarryInfos = PetAttributeCalcUtils.getAssistCarryInfos(player, coreCarryInfo, petInfo),
		resonanceInfo = petInfo and petInfo.resonanceInfo or nil
	}

	return PetAttributeCalcUtils.getAttributeMapByCaculate(context, petInfo)
end

return PetAttributeCalcUtils
