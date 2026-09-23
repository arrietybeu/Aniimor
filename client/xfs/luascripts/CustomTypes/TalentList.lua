-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\TalentList.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("TalentList")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetTalentGroupData = require("Data.pet_talent_group_data")
local PetTalentPoolToIds = require("Data.pet_talent_pool_to_ids")
local PetTalentData = require("Data.pet_talent_data")
local TalentList = class.LiteClass("TalentList", CustomList)

function TalentList:getTalentIds()
	return lume.values(self, "templateId")
end

function TalentList:initByTemplate(templateId, talentInitParams)
	local PET_TALENT = Const.PET_TALENT
	local ptgdd = PetTalentGroupData[templateId]

	if ptgdd == nil or ptgdd.propNumId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("pet_talent_group_data config nil", templateId)
		end

		return
	end

	local countSelectTable = lume.mapToList(ptgdd.propNumId)
	local countWeightTable = Utils.getProportionList(Const.EXTRACT_MODE_PROPORTION_OVERFLOW, countSelectTable, function(v)
		return v[2]
	end)
	local countSelectIndex = lume.weightedchoice(countWeightTable)
	local talentCount = countSelectTable[countSelectIndex] and countSelectTable[countSelectIndex][1] or 0
	local groupWeightTable = Utils.getProportionList(Const.EXTRACT_MODE_PROPORTION, ptgdd.pool, function(v)
		return v[PET_TALENT.GROUP_IDX_WEIGHT] or 0
	end)
	local poolCount = {}
	local poolCfgData = {}

	for i = 1, talentCount do
		local groupSelectIndex = next(groupWeightTable) and lume.weightedchoice(groupWeightTable)
		local poolData = ptgdd.pool[groupSelectIndex]

		if poolData ~= nil then
			local poolId, extractWay, weight, limitNum = unpack(poolData, 1, PET_TALENT.GROUP_IDX_MAX)

			poolCount[poolId] = (poolCount[poolId] or 0) + 1

			if limitNum and limitNum <= poolCount[poolId] then
				groupWeightTable[groupSelectIndex] = nil
			end

			poolCfgData[poolId] = poolData
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("random group error, i=%d, talentCount=%d, groupWeightTable=%s", i, talentCount, inspect(groupWeightTable))
		end
	end

	local resultTalentIds = {}
	local innerGroupSelected = {}

	for poolId, count in pairs(poolCount) do
		local talentIds = PetTalentPoolToIds[poolId]

		for i = 1, count do
			local talentWeightTable = Utils.getProportionList(Const.EXTRACT_MODE_PROPORTION, talentIds, function(v)
				local ptdd = PetTalentData[v]

				if innerGroupSelected[ptdd.group] then
					return 0
				end

				return ptdd.weight
			end)
			local talentSelectIndex = next(talentWeightTable) and lume.weightedchoice(talentWeightTable)
			local talentId = talentIds[talentSelectIndex]

			if talentId ~= nil then
				resultTalentIds[#resultTalentIds + 1] = talentId
				innerGroupSelected[PetTalentData[talentId].group] = true
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("random talent error, groupId=%d, i=%d, count=%d, talentWeightTable=%s", groupId, i, count, inspect(talentWeightTable))
			end
		end
	end

	local dict = self.genInitDict(resultTalentIds, talentInitParams)

	for k, v in ipairs(dict) do
		self:insert(k, v)
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("init talent finish, talentCount=%d dict=%s", talentCount, inspect(dict), talentInitParams.sourceRepr)
	end
end

function TalentList.genInitDict(talentIds, talentInitParams)
	talentInitParams = talentInitParams or require("GameServer.ContextHelper").formatTalentInitParams({})

	local dict = {}

	for _, talentId in ipairs(talentIds) do
		dict[#dict + 1] = TalentList.genSingleTalentInitDict(talentId, talentInitParams)
	end

	return dict
end

function TalentList.genSingleTalentInitDict(talentId, talentInitParams)
	local ptdd = PetTalentData[talentId]

	if ptdd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("pet_talent_data config nil", talentId)
		end

		return
	end

	local propValues = {}
	local scaleFixs = {}
	local cp = 0

	for _, prop in ipairs(ptdd.props or EMPTY_TABLE) do
		local realValue, realCp, scaleFix = TalentList.getSingleTalentPropValue(prop, talentInitParams)

		propValues[#propValues + 1] = realValue
		scaleFixs[#scaleFixs + 1] = scaleFix
		cp = cp + realCp
	end

	return {
		templateId = talentId,
		propValues = propValues,
		cp = cp,
		scaleFixs = scaleFixs
	}
end

function TalentList.getSingleTalentPropValue(prop, talentInitParams)
	local propId, transType, propValue, propRange, cp = unpack(prop, 1, Const.TALENT_PROP_IDX_MAX)

	if propId == nil then
		return 0
	end

	local realValue

	if transType then
		realValue = Utils.formulaSafeCall(0, transType, propValue, talentInitParams.petLevel)
	else
		realValue = propValue
	end

	if realValue == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("propValue init nil, propId=%d", propId, transType, propValue)
		end

		realValue = 0
	end

	local scaleFix = 0

	if propRange then
		local scaleMin, scaleMax = propRange[1], propRange[2]

		if scaleMin and scaleMax then
			scaleFix = lume.random(scaleMin, scaleMax)
			realValue = lume.round(realValue * scaleFix, 0.0001)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("propRange config error, propId=%d", propId, scaleMin, scaleMax)
		end
	end

	local realCp = 0

	if cp and cp > 0 then
		realCp = math.floor(realValue / propValue * cp)
	end

	return realValue, realCp, scaleFix
end

function TalentList:refreshTotal()
	return
end

function TalentList:getPropInfo()
	local propInfo = {}

	for _, info in self:items() do
		local ptdd = PetTalentData[info.templateId]

		if ptdd then
			for k, v in ipairs(ptdd.props or EMPTY_TABLE) do
				local propId = v[Const.TALENT_PROP_IDX_PROPID]

				if propId ~= nil then
					local propValue = info.propValues[k] or 0

					propInfo[propId] = (propInfo[propId] or 0) + propValue
				end
			end
		end
	end

	return propInfo
end

function TalentList:applyProperty(ownerEntity, src, enhanceRatio)
	if ownerEntity == nil or src == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("applyProperty error, ownerEntity=%s, src=%s", ownerEntity and ownerEntity:repr() or "nil", src)
		end

		return
	end

	enhanceRatio = enhanceRatio or 0

	for index, info in self:items() do
		local ptdd = PetTalentData[info.templateId]

		if ptdd == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("config nil", info.templateId)
			end
		else
			for k, v in ipairs(ptdd.props or EMPTY_TABLE) do
				local propId = v[Const.TALENT_PROP_IDX_PROPID]

				if propId ~= nil then
					local propValue = info.propValues[k] or 0

					propValue = propValue * (1 + enhanceRatio)

					ownerEntity.actorAttributeApplicator:changeAttribGroup(src, index, propId, propValue, {})
				end
			end
		end
	end
end

function TalentList:unapplyProperty(ownerEntity, src)
	if ownerEntity == nil or src == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("unapplyProperty error, ownerEntity=%s, src=%s", ownerEntity and ownerEntity:repr() or "nil", src)
		end

		return
	end

	for index, info in self:items() do
		ownerEntity.actorAttributeApplicator:removeAllAttribBySrc(src, index)
		logger:debug("talent unapplyProperty, index=%d, talentId=%d, src=%d", index, info.templateId, src, ownerEntity:repr())
	end
end

function TalentList:petInfoInitByTemplate(petInfo)
	if #self ~= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("reinit", #self)
		end

		return
	end

	local petPrototypeId = petInfo.petPrototypeId
	local ppdd = PetPrototypeData[petPrototypeId]

	if ppdd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("pet_prototype_data config nil", petPrototypeId)
		end

		return
	end

	local talentInitParams = require("GameServer.ContextHelper").formatTalentInitParams({
		sourceRepr = petInfo:repr(),
		petLevel = petInfo.level
	})

	self:initByTemplate(ppdd.randomPropId, talentInitParams)
	self:petInfoOnModifyTalent(petInfo)
end

function TalentList:petInfoOnModifyTalent(petInfo)
	self:refreshTotal()

	local entity = petInfo:getEntity()

	if entity ~= nil then
		self:petInfoApplyProperty(entity)
	end

	logger:debug("petInfoOnModifyTalent, entity=%s", entity and entity:repr() or "nil", petInfo:repr())
end

function TalentList:petInfoApplyProperty(ownerEntity)
	self:applyProperty(ownerEntity, AbilityConst.ATTRIBUTE_SRC_TYPE_PET_TALENT, 0)
end

function TalentList:getCpValue()
	local totalCp = 0

	for _, info in self:items() do
		totalCp = totalCp + (info.cp or 0)
	end

	return totalCp
end

return TalentList
