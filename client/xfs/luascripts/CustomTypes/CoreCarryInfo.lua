-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CoreCarryInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local logger = require("Core.Log.LoggerManager").getLogger("CoreCarryInfo")
local lume = require("Core.Common.lume")
local ItemPos = require("CustomTypes.ItemPos")
local ItemUtils = require("Common.Utils.ItemUtils")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local CommonSwitch = require("Common.CommonSwitch")
local AttributeConst = require("Common.Const.AttributeConst")
local DungeonConst = require("Common.Const.DungeonConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local ItemData = require("Data.item_data")
local CoreCarryData = require("Data.core_carry_data")
local CoreCarryLevelData = require("Data.core_carry_level_data")
local BuffCalcValueData = require("Data.buff_calc_value_data")
local CoreCarryInfo = class.LiteClass("CoreCarryInfo", CustomDict)

function CoreCarryInfo:isValid()
	return self.itemId ~= 0
end

function CoreCarryInfo:getQuality()
	local idd = ItemData[self.itemId]

	return idd and idd.quality or 0
end

function CoreCarryInfo:getFamilyId()
	local ccdd = CoreCarryData[self.itemId]

	return ccdd and ccdd.familyId or 0
end

function CoreCarryInfo:getTalentIds()
	return lume.imap(self.talentList, "templateId")
end

function CoreCarryInfo:onFirstCreate()
	assert(pg.component == "game", "server only")
	assert(self:isValid(), "itemId is 0")

	if #self.talentList > 0 then
		logger:error("talentList is not empty", self:repr())

		return
	end

	local ccdd = CoreCarryData[self.itemId]

	if not ccdd then
		logger:error("core_carry_data config nil", self.itemId)

		return
	end

	if ccdd.propGroup then
		self.talentList:initByTemplate(ccdd.propGroup, {
			sourceRepr = self:repr()
		})
	end

	for i, slotType in ipairs(ccdd.slotType or EMPTY_TABLE) do
		if type(slotType) == "number" then
			self.assistCarryTypeList:insert(i, slotType)
		else
			self.assistCarryTypeList:insert(i, lume.randomchoice(slotType))
		end

		self.assistCarryPosList:insert(i, ItemPos({
			0,
			0
		}))
	end
end

function CoreCarryInfo:getLevelAndExp()
	return PetAttributeCalcUtils.getCoreCarryLevel(self)
end

function CoreCarryInfo:getEnhanceRatio()
	local level, exp = self:getLevelAndExp()
	local lvdd = CoreCarryLevelData[level]

	return lvdd and lvdd.enhanceRatio or 0
end

function CoreCarryInfo:getMaxLevelAndTotalExp(forceMaxLevel)
	local maxLevel, totalExp = 0, 0
	local quality = ItemData[self.itemId] and ItemData[self.itemId].quality or 0

	for i = 1, Const.FOR_LOOP_MAX_1000 do
		if forceMaxLevel and forceMaxLevel < i then
			break
		end

		local lvdd = CoreCarryLevelData[i]

		if not lvdd then
			break
		end

		local needExp = lvdd.needExp or 0

		if lume.find(lvdd.needQuality or {}, quality) then
			maxLevel = i
			totalExp = totalExp + needExp
		else
			break
		end
	end

	return maxLevel, totalExp
end

function CoreCarryInfo:getExpMaxAdd()
	local _, totalExp = self:getMaxLevelAndTotalExp()

	return math.max(0, totalExp - self.totalExp)
end

function CoreCarryInfo:getCpValue()
	local ccdd = CoreCarryData[self.itemId]
	local baseCp = ccdd.cp or 0
	local lvCp = ccdd.cp1 or 0
	local curLv, _ = self:getLevelAndExp()

	return baseCp + lvCp * curLv
end

function CoreCarryInfo:isMaxLevel()
	local curLv, _ = self:getLevelAndExp()
	local maxLv, _ = self:getMaxLevelAndTotalExp()

	return maxLv <= curLv
end

function CoreCarryInfo:getAssistCarryEnergySum(player)
	local energySum = 0

	for _, itemPos in ipairs(self.assistCarryPosList) do
		if itemPos:isValid() then
			local invId, itemGenId = itemPos:unpack()
			local item = player:getItem(invId, itemGenId)
			local assistCarryInfo = ItemUtils.getPropertyWithType(item)

			if assistCarryInfo then
				energySum = energySum + assistCarryInfo:getEnergy()
			else
				logger:error("assistCarryInfo is nil", invId, itemGenId, self:repr())
			end
		end
	end

	return energySum
end

function CoreCarryInfo:removeAssistCarry(player, coreCarry, pos)
	if not self.assistCarryPosList[pos] then
		return false
	end

	if not self.assistCarryPosList[pos]:isValid() then
		return false
	end

	local invId, itemGenId = self.assistCarryPosList[pos]:unpack()
	local item = player:getItem(invId, itemGenId)

	if not item then
		logger:error("item not found", invId, itemGenId, self:repr())

		return false
	end

	local assistCarryInfo = ItemUtils.getPropertyWithType(item)

	if not assistCarryInfo then
		logger:error("assistCarryInfo is nil", item:repr(), self:repr())

		return false
	end

	self.assistCarryPosList[pos] = {
		0,
		0
	}
	assistCarryInfo.ownerCoreCarryPos = ItemPos({
		0,
		0
	})

	item:setExtraProp(assistCarryInfo:getRawTable())

	local quality = ItemData[item.id] and ItemData[item.id].quality

	player.BILogger:customeLog("gem_equip_flow", {
		equipment_id_after = 0,
		equipment_uid_after = 0,
		gem_uuid = item:getGenID(),
		gem_id = item.id,
		quality = quality,
		random_prop = assistCarryInfo.talentList:getPropInfo(),
		equipment_id_before = coreCarry.id,
		equipment_uid_before = coreCarry:getGenID()
	})

	return true
end

function CoreCarryInfo:getActiveEnergyEffectCount(player)
	local ccdd = CoreCarryData[self.itemId]

	if not ccdd then
		return 0
	end

	local energySum = 0

	for index, itemPos in ipairs(self.assistCarryPosList) do
		if itemPos:isValid() then
			local invId, itemGenId = itemPos:unpack()
			local item = player:getItem(invId, itemGenId)
			local assistCarryInfo = ItemUtils.getPropertyWithType(item)

			if assistCarryInfo then
				energySum = energySum + assistCarryInfo:getEnergy()
			end
		end
	end

	local count = 0
	local coreCarryLevel = self:getLevelAndExp()

	if ccdd.energyEffects then
		for _, energyEffect in ipairs(ccdd.energyEffects) do
			if PetAttributeCalcUtils.isEnergyEffectActive(energyEffect, energySum, coreCarryLevel) then
				count = count + 1
			end
		end
	end

	return count
end

function CoreCarryInfo:_applyBuffAttrForFakeActor(ownerEntity, buffIds)
	local actorCombatAttribute = ownerEntity.actorCombatAttribute
	local applicator = ownerEntity.actorAttributeApplicator

	for _, buffId in ipairs(buffIds) do
		local buffTemplate = pg.global.abilityMgr:getBuffTemplate(buffId)

		if buffTemplate then
			for attributeName, v in pairs(buffTemplate.calcInfo or EMPTY_TABLE) do
				local attributeId = AttributeConst[attributeName]

				if attributeId then
					local value

					if type(v) == "table" then
						if v.name == "getParamByLuaConfig" then
							local data = ((BuffCalcValueData[v.calcId] or EMPTY_TABLE)[v.paramName] or EMPTY_TABLE)[1]

							value = data and CombatActionTool.getCalcValue(data, actorCombatAttribute, nil) or nil
						end
					else
						value = v
					end

					if value then
						applicator:changeAttrib(AbilityConst.ATTRIBUTE_SRC_TYPE_BUFF, buffId, attributeId, value)
					end
				end
			end

			local luaCfg = buffTemplate.calcInfoByLuaConfig

			if luaCfg then
				for attributeName, paramName in pairs(luaCfg) do
					local attributeId = AttributeConst[attributeName]

					if attributeId then
						local data = ((BuffCalcValueData[luaCfg.id] or EMPTY_TABLE)[paramName] or EMPTY_TABLE)[1]

						if data then
							local value = CombatActionTool.getCalcValue(data, actorCombatAttribute, nil)

							applicator:changeAttrib(AbilityConst.ATTRIBUTE_SRC_TYPE_BUFF, buffId, attributeId, value)
						end
					end
				end
			end
		end
	end
end

function CoreCarryInfo:active(ownerEntity)
	if not CommonSwitch.PETEQUIPMENT then
		logger:debug("pet equipment not open, %s", ownerEntity:repr())

		return
	end

	local ccdd = CoreCarryData[self.itemId]

	if not ccdd then
		logger:error("core_carry_data config nil", self.itemId)

		return
	end

	local enhanceRatio = self:getEnhanceRatio()

	self.talentList:applyProperty(ownerEntity, AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY, enhanceRatio)

	if ccdd.prop then
		for propId, propValue in pairs(ccdd.prop) do
			propValue = propValue * (1 + enhanceRatio)

			ownerEntity.actorAttributeApplicator:changeAttribGroup(AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY_EX, 0, propId, propValue, {})
			logger:debug("core_carry_info active, propId=%d, propValue=%.4f, enhanceRatio=%.4f", propId, propValue, enhanceRatio, ownerEntity:repr())
		end
	end

	local player = ownerEntity.master
	local isGemEnabled = true
	local space = player and player.space

	if space and space:isRobEgg() and space.mode == DungeonConst.RobEggMode.MultiTeam then
		isGemEnabled = false
	end

	local energySum = 0

	if player and isGemEnabled then
		for index, itemPos in ipairs(self.assistCarryPosList) do
			if itemPos:isValid() then
				local invId, itemGenId = itemPos:unpack()
				local item = player:getItem(invId, itemGenId)
				local assistCarryInfo = ItemUtils.getPropertyWithType(item)

				if assistCarryInfo then
					assistCarryInfo.talentList:applyProperty(ownerEntity, AbilityConst["ATTRIBUTE_SRC_TYPE_ASSIST_CARRY" .. "_" .. index])

					energySum = energySum + assistCarryInfo:getEnergy()

					for propId, propValue in pairs(assistCarryInfo:getBaseProp()) do
						ownerEntity.actorAttributeApplicator:changeAttribGroup(AbilityConst.ATTRIBUTE_SRC_TYPE_ASSIST_CARRY_EX, index, propId, propValue, {})
					end
				else
					logger:error("assistCarryInfo is nil", invId, itemGenId, self:repr())
				end
			end
		end
	end

	local buffInstanceIds = {}
	local buffIds = {}

	if ccdd.buffId then
		for _, buffId in ipairs(ccdd.buffId) do
			buffIds[#buffIds + 1] = buffId
		end
	end

	local coreCarryLevel = self:getLevelAndExp()

	if isGemEnabled and ccdd.energyEffects then
		for _, energyEffect in ipairs(ccdd.energyEffects) do
			if PetAttributeCalcUtils.isEnergyEffectActive(energyEffect, energySum, coreCarryLevel) then
				for _, buffId in ipairs(energyEffect[2]) do
					buffIds[#buffIds + 1] = buffId
				end
			end
		end
	end

	if ownerEntity.isFakeActor then
		self:_applyBuffAttrForFakeActor(ownerEntity, buffIds)
	else
		for _, buffId in ipairs(buffIds) do
			local overrideData = {
				duration = -1,
				specialType = AbilityConst.BUFF_SPECIAL_TYPES.CORE_CARRY
			}
			local buff = ownerEntity:addBuff(buffId, overrideData)

			if buff then
				buffInstanceIds[#buffInstanceIds + 1] = buff.buffData.instanceId

				logger:debug("core_carry_info active, buffId=%d, buffInstanceId=%d", buffId, buff.buffData.instanceId, ownerEntity:repr())
			else
				logger:error("add buff failed", buffId, ownerEntity:repr())
			end
		end
	end

	if ccdd.propConversions then
		for _, conversionInfo in ipairs(ccdd.propConversions) do
			local fromAttributeName, toAttributeName, rate = unpack(conversionInfo)
			local fromAttributeId = AttributeConst[fromAttributeName]
			local toAttributeId = AttributeConst[toAttributeName]

			if not fromAttributeId or not toAttributeId then
				logger:error("invalidAttributeName", fromAttributeName, toAttributeName)
			else
				local id = string.format("%d_%s->%s", self.itemId, fromAttributeName, toAttributeName)

				ownerEntity.actorAttributeApplicator:addConversionByRate(AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY_CONVERSION, id, fromAttributeId, toAttributeId, rate)
			end
		end
	end

	return {
		buffInstanceIds = buffInstanceIds
	}
end

function CoreCarryInfo:deactive(ownerEntity, activeInfo)
	if activeInfo == nil then
		logger:debug("activeInfo is nil", self:repr())

		return
	end

	local ccdd = CoreCarryData[self.itemId]

	if not ccdd then
		logger:error("core_carry_data config nil", self.itemId)

		return
	end

	self.talentList:unapplyProperty(ownerEntity, AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY)

	if ccdd.prop then
		ownerEntity.actorAttributeApplicator:removeAllAttribBySrc(AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY_EX, 0)
		logger:debug("core_carry_info deactive, prop", ownerEntity:repr())
	end

	local player = ownerEntity.master
	local isGemEnabled = true
	local space = player and player.space

	if space and space:isRobEgg() and space.mode == DungeonConst.RobEggMode.MultiTeam then
		isGemEnabled = false
	end

	if player and isGemEnabled then
		for index, itemPos in ipairs(self.assistCarryPosList) do
			if itemPos:isValid() then
				local invId, itemGenId = itemPos:unpack()
				local item = player:getItem(invId, itemGenId)
				local assistCarryInfo = ItemUtils.getPropertyWithType(item)

				if assistCarryInfo then
					assistCarryInfo.talentList:unapplyProperty(ownerEntity, AbilityConst["ATTRIBUTE_SRC_TYPE_ASSIST_CARRY" .. "_" .. index])
					ownerEntity.actorAttributeApplicator:removeAllAttribBySrc(AbilityConst.ATTRIBUTE_SRC_TYPE_ASSIST_CARRY_EX, index)
				else
					logger:error("assistCarryInfo is nil", invId, itemGenId, self:repr())
				end
			end
		end
	end

	if ccdd.buffId or ccdd.energyEffects and not ownerEntity.isFakeActor then
		for _, buffInstanceId in ipairs(activeInfo.buffInstanceIds) do
			ownerEntity:removeBuffByInstanceId(buffInstanceId, AbilityConst.BUFF_DESTROY_REASON_INTERRUPT, AbilityConst.BUFF_SPECIAL_TYPES.CORE_CARRY)
			logger:debug("core_carry_info deactive, buffInstanceId=%d", buffInstanceId, ownerEntity:repr())
		end
	end

	if ccdd.propConversions then
		for _, conversionInfo in ipairs(ccdd.propConversions) do
			local fromAttributeName, toAttributeName, rate = unpack(conversionInfo)
			local fromAttributeId = AttributeConst[fromAttributeName]
			local toAttributeId = AttributeConst[toAttributeName]

			if not fromAttributeId or not toAttributeId then
				logger:error("invalidAttributeName", fromAttributeName, toAttributeName)
			else
				local id = string.format("%d_%s->%s", self.itemId, fromAttributeName, toAttributeName)

				ownerEntity.actorAttributeApplicator:removeConversionByRate(AbilityConst.ATTRIBUTE_SRC_TYPE_CORE_CARRY_CONVERSION, id, fromAttributeId, toAttributeId)
			end
		end
	end
end

function CoreCarryInfo:repr()
	return string.format("CoreCarryInfo(itemId=%d)", self.itemId)
end

return CoreCarryInfo
