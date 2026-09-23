-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomelandEnvManager.lua

local Class = require("Core.Framework.Class")
local HomelandFastFindMap = require("Common.Homeland.HomelandFastFindMap")
local Utils = require("Common.Utils.Utils")
local HomelandFacilityData = require("Data.homeland_facility_data")
local Const = require("Common.Const.Const")
local HomeLinkGroupInfo = require("CustomTypes.HomeLinkGroupInfo")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeObjectData = require("Data.home_object_data")
local HomelandEnvManager = Class.LightClass("HomelandEnvManager")
local HomelandFormulaData = require("Data.homeland_formula_data")

function HomelandEnvManager:ctor(isSimulate)
	self.isSimulate = isSimulate
	self.homeEnvFastFindMap = HomelandFastFindMap.new(16)
	self.homeEnvOrnamentFastFindMap = HomelandFastFindMap.new(16)
	self.envOrnamentDirtyDict = {}
	self.envFacilityTypeDict = {}
	self.facilityTypeFastFindMap = {}
	self.tempLinkMeetDict = {}
	self.tempRequireCheckList = {}
	self.tempGroupMeetDict = {}
end

function HomelandEnvManager:isProduceAreaOrnament(ornamentInfo)
	return (ornamentInfo.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE) == Const.HOMELAND_AREA_TYPE.PRODUCE
end

function HomelandEnvManager:init(space, ornaments, homeEnvMap, ornamentEnvMap, homeLinkMap, homeLinkGroupMap)
	self.space = space

	self.homeEnvFastFindMap:clearFastFindInfo()
	self.homeEnvOrnamentFastFindMap:clearFastFindInfo()

	self.ornament = ornaments
	self.homeEnvMap = homeEnvMap
	self.ornamentEnvMap = ornamentEnvMap
	self.homeLinkMap = homeLinkMap
	self.homeLinkGroupMap = homeLinkGroupMap

	for ornamentId, ornamentInfo in pairs(ornaments) do
		if self:isProduceAreaOrnament(ornamentInfo) then
			self:addEnvTypeDict(ornamentId, ornamentInfo)

			if Utils.isHomeEnvFacility(ornamentInfo.homeId) then
				self.homeEnvFastFindMap:addOrUpdateFastFindInfo(ornamentId, self:getHomelandEnvBounds(ornamentInfo), ornamentInfo:getPosition(), ornamentInfo:getRotation(), self:getHomelandEnvExtraInfo(ornamentInfo))
			end

			if Utils.isHomeEnvOrnament(ornamentInfo.homeId) then
				self.homeEnvOrnamentFastFindMap:addOrUpdateFastFindInfo(ornamentId, self:getHomelandEnvBounds(ornamentInfo), ornamentInfo:getPosition(), ornamentInfo:getRotation(), self:getHomelandEnvExtraInfo(ornamentInfo))
			end
		end
	end
end

function HomelandEnvManager:getHomelandEnvBounds(ornamentInfo)
	local homeObjectData = HomeObjectData[ornamentInfo.homeId]
	local bounds = homeObjectData.boundSize
	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)

	if not facilityId then
		return bounds
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	if facilityData.facilityType and facilityData.envBounds then
		bounds = facilityData.envBounds
	end

	return bounds
end

function HomelandEnvManager:clear()
	table.clear(self.envOrnamentDirtyDict)
	table.clear(self.envFacilityTypeDict)
	table.clear(self.facilityTypeFastFindMap)
end

function HomelandEnvManager:onOrnamentAdd(ornamentId, ornamentInfo)
	if not self:isProduceAreaOrnament(ornamentInfo) then
		return
	end

	self:addEnvTypeDict(ornamentId, ornamentInfo)

	if Utils.isHomeEnvFacility(ornamentInfo.homeId) then
		self.homeEnvFastFindMap:addOrUpdateFastFindInfo(ornamentId, self:getHomelandEnvBounds(ornamentInfo), ornamentInfo:getPosition(), ornamentInfo:getRotation(), self:getHomelandEnvExtraInfo(ornamentInfo))

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:addHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvFacility(ornamentId)
	end

	if Utils.isHomeEnvOrnament(ornamentInfo.homeId) then
		self.homeEnvOrnamentFastFindMap:addOrUpdateFastFindInfo(ornamentId, self:getHomelandEnvBounds(ornamentInfo), ornamentInfo:getPosition(), ornamentInfo:getRotation(), self:getHomelandEnvExtraInfo(ornamentInfo))

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:addHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvRef(ornamentId)
		self:onOrnamentEnvChange(ornamentId)
	end
end

function HomelandEnvManager:onOrnamentRemove(ornamentId, ornamentInfo)
	self.homeEnvFastFindMap:removeFastFindInfo(ornamentId)
	self.homeEnvOrnamentFastFindMap:removeFastFindInfo(ornamentId)
	self:removeHomeEnvRef(ornamentId)
	self:removeHomeLinkInfo(ornamentId)
	self:removeHomeEnvFacility(ornamentId)
	self:removeEnvTypeDict(ornamentId, ornamentInfo)
end

function HomelandEnvManager:onOrnamentUpgrade(ornamentId, ornamentInfo)
	if not self:isProduceAreaOrnament(ornamentInfo) then
		return
	end

	if Utils.isHomeEnvFacility(ornamentInfo.homeId) then
		self.homeEnvFastFindMap:addOrUpdateFastFindInfo(ornamentId, self:getHomelandEnvBounds(ornamentInfo), ornamentInfo:getPosition(), ornamentInfo:getRotation(), self:getHomelandEnvExtraInfo(ornamentInfo))

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:updateHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvFacility(ornamentId)
	end

	if Utils.isHomeEnvOrnament(ornamentInfo.homeId) then
		self.homeEnvOrnamentFastFindMap:addOrUpdateFastFindInfo(ornamentId, self:getHomelandEnvBounds(ornamentInfo), ornamentInfo:getPosition(), ornamentInfo:getRotation(), self:getHomelandEnvExtraInfo(ornamentInfo))

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:updateHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvRef(ornamentId)

		if self:checkIsEnvReqFacility(ornamentId) and self:updateOrnamentElectricCost(ornamentId) then
			self:markElectricStateDirty()
		end
	end
end

function HomelandEnvManager:onOrnamentPosChange(ornamentId, ornamentInfo)
	if not self:isProduceAreaOrnament(ornamentInfo) then
		return
	end

	if Utils.isHomeEnvFacility(ornamentInfo.homeId) then
		self.homeEnvFastFindMap:refreshFastFindInfo(ornamentId, ornamentInfo:getPosition(), ornamentInfo:getRotation())

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:updateHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvFacility(ornamentId)
	end

	if Utils.isHomeEnvOrnament(ornamentInfo.homeId) then
		self.homeEnvOrnamentFastFindMap:refreshFastFindInfo(ornamentId, ornamentInfo:getPosition(), ornamentInfo:getRotation())

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:updateHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvRef(ornamentId)
	end
end

function HomelandEnvManager:onFacilityElectricModeChanged(ornamentId, ornamentInfo)
	if not self:isProduceAreaOrnament(ornamentInfo) then
		return
	end

	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch) then
		self:addEnvTypeDict(ornamentId, ornamentInfo)
		self.homeEnvOrnamentFastFindMap:refreshExtraInfo(ornamentId, self:getHomelandEnvExtraInfo(ornamentInfo))

		if Utils.isHomeLinkOrnament(ornamentInfo.homeId) then
			self:updateHomeLinkInfo(ornamentId, ornamentInfo)
		end

		self:updateHomeEnvRef(ornamentId)
		self:updateOrnamentElectricCost(ornamentId)
		self:markElectricStateDirty()
	end
end

function HomelandEnvManager:onFacilityAllocationChanged(ornamentId)
	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Electric) then
		self:updateFacilityElectricProduce(ornamentId)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light)
	end
end

function HomelandEnvManager:onFacilityWorkRatioChanged(ornamentId)
	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Electric) then
		self:updateFacilityElectricProduce(ornamentId)
	end
end

function HomelandEnvManager:onFacilityProduceChanged(ornamentId)
	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Electric) then
		self:updateFacilityElectricProduce(ornamentId)
	elseif self:checkIsEnvReqFacility(ornamentId) then
		if self:updateOrnamentElectricCost(ornamentId) then
			self:markElectricStateDirty()
		end
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.EnvRequire) then
		self:updateOrnamentNormalWorkRatio(ornamentId)
	end
end

function HomelandEnvManager:onFacilityDisableChanged(ornamentId)
	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Electric) then
		self:updateFacilityElectricProduce(ornamentId)
	elseif self:checkIsEnvReqFacility(ornamentId) then
		if self:updateOrnamentElectricCost(ornamentId) then
			self:markElectricStateDirty()
		end
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate)
	elseif self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light) then
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light)
	end
end

function HomelandEnvManager:addEnvTypeDict(ornamentId, ornamentInfo)
	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)

	if not facilityId then
		return
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	if facilityData.facilityType then
		local facilityTypeDict = self.envFacilityTypeDict[facilityData.facilityType]

		if not facilityTypeDict then
			facilityTypeDict = {}
			self.envFacilityTypeDict[facilityData.facilityType] = facilityTypeDict
		end

		facilityTypeDict[ornamentId] = ornamentInfo
		self.facilityTypeFastFindMap[ornamentId] = facilityData.facilityType
	end
end

function HomelandEnvManager:removeEnvTypeDict(ornamentId, ornamentInfo)
	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)

	if not facilityId then
		return
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	if facilityData.facilityType then
		local facilityTypeDict = self.envFacilityTypeDict[facilityData.facilityType]

		if facilityTypeDict then
			facilityTypeDict[ornamentId] = nil
		end

		self.facilityTypeFastFindMap[ornamentId] = nil
	end
end

function HomelandEnvManager:getHomelandEnvExtraInfo(ornamentInfo)
	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)

	if not facilityId then
		return nil
	end

	local extraInfo = {}
	local facilityData = HomelandFacilityData[facilityId] or {}

	if facilityData.facilityType then
		extraInfo.facilityType = facilityData.facilityType
		extraInfo.electricMode = ornamentInfo.electricMode
	end

	return extraInfo
end

function HomelandEnvManager:getHomeEnvFacilityRelatedOrnaments(envOrnamentId)
	local fastFindInfo = self.homeEnvFastFindMap:getFastFindInfo(envOrnamentId)

	if not fastFindInfo then
		return {}
	end

	if not self:checkEnvFastInfoValid(fastFindInfo) then
		return {}
	end

	local relatedTypes = Const.HOMELAND_ENV_FACILITY_RELATED_INFO[fastFindInfo.extraInfo.facilityType]

	if not relatedTypes then
		return {}
	end

	local result = {}
	local hBoundX, hBoundZ = fastFindInfo:getHalfBoundWithRot()
	local minX = fastFindInfo.position.x - hBoundX
	local maxX = fastFindInfo.position.x + hBoundX
	local minZ = fastFindInfo.position.z - hBoundZ
	local maxZ = fastFindInfo.position.z + hBoundZ

	self.homeEnvOrnamentFastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, result)

	result[envOrnamentId] = nil

	for ornamentId, fastInfo in pairs(result) do
		if not relatedTypes[fastInfo.extraInfo.facilityType] or not self:checkEnvFastInfoValid(fastInfo) then
			result[ornamentId] = nil
		end
	end

	return result
end

function HomelandEnvManager:checkEnvFastInfoValid(fastInfo)
	if not fastInfo then
		return false
	end

	if fastInfo.extraInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch and not fastInfo.extraInfo.electricMode then
		return false
	end

	return true
end

function HomelandEnvManager:getHomeEnvOrnamentRelatedFacilities(ornamentId)
	local fastFindInfo = self.homeEnvOrnamentFastFindMap:getFastFindInfo(ornamentId)

	if not fastFindInfo then
		return {}
	end

	if not self:checkEnvFastInfoValid(fastFindInfo) then
		return {}
	end

	local relatedTypes = Const.HOMELAND_ENV_ORNAMENT_RELATED_INFO[fastFindInfo.extraInfo.facilityType]

	if not relatedTypes then
		return {}
	end

	local result = {}
	local hBoundX, hBoundZ = fastFindInfo:getHalfBoundWithRot()
	local minX = fastFindInfo.position.x - hBoundX
	local maxX = fastFindInfo.position.x + hBoundX
	local minZ = fastFindInfo.position.z - hBoundZ
	local maxZ = fastFindInfo.position.z + hBoundZ

	self.homeEnvFastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, result)

	result[ornamentId] = nil

	for envOrnamentId, fastInfo in pairs(result) do
		if not relatedTypes[fastInfo.extraInfo.facilityType] then
			result[envOrnamentId] = nil
		end
	end

	for envOrnamentId, fastInfo in pairs(result) do
		if not self:checkEnvFastInfoValid(fastInfo) then
			result[envOrnamentId] = nil
		end
	end

	return result
end

function HomelandEnvManager:getHomeLinkOrnamentIds(ornamentId, ornamentInfo)
	local facilityType = Utils.getHomeFacilityType(ornamentInfo.homeId)
	local fastFindInfo

	if facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		fastFindInfo = self.homeEnvOrnamentFastFindMap:getFastFindInfo(ornamentId)
	else
		fastFindInfo = self.homeEnvFastFindMap:getFastFindInfo(ornamentId)
	end

	if not fastFindInfo then
		return {}
	end

	if not self:checkEnvFastInfoValid(fastFindInfo) then
		return {}
	end

	local relatedTypes = Const.HOMELAND_ENV_ORNAMENT_LINK_INFO[facilityType]

	if not relatedTypes then
		return {}
	end

	local result = {}
	local hBoundX, hBoundZ = fastFindInfo:getHalfBoundWithRot()
	local minX = fastFindInfo.position.x - hBoundX
	local maxX = fastFindInfo.position.x + hBoundX
	local minZ = fastFindInfo.position.z - hBoundZ
	local maxZ = fastFindInfo.position.z + hBoundZ

	self.homeEnvFastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, result)

	result[ornamentId] = nil

	for envOrnamentId, fastInfo in pairs(result) do
		if not relatedTypes[fastInfo.extraInfo.facilityType] then
			result[envOrnamentId] = nil
		end
	end

	if relatedTypes[Const.HOMELAND_FACILITY_TYPE.ElectricReq] or relatedTypes[Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch] then
		local ornamentResults = {}

		self.homeEnvOrnamentFastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, ornamentResults)

		for electricReqOrnamentId, fastInfo in pairs(ornamentResults) do
			if relatedTypes[fastInfo.extraInfo.facilityType] and self:checkEnvFastInfoValid(fastInfo) then
				result[electricReqOrnamentId] = fastInfo
			end
		end
	end

	return result
end

function HomelandEnvManager:updateHomeLinkInfo(ornamentId, ornamentInfo)
	if not self.homeLinkMap[ornamentId] then
		self.homeLinkMap[ornamentId] = {}
	end

	local changed = false
	local linkOrnaments = self:getHomeLinkOrnamentIds(ornamentId, ornamentInfo)
	local linkIds = self.homeLinkMap[ornamentId].linkIds

	for otherOrnamentId, v in pairs(linkIds) do
		if not linkOrnaments[ornamentId] then
			self:setHomeLinkState(ornamentId, otherOrnamentId, false)

			changed = true
		end
	end

	for otherOrnamentId, _ in pairs(linkOrnaments) do
		if not linkIds[otherOrnamentId] then
			self:setHomeLinkState(ornamentId, otherOrnamentId, true)

			changed = true
		end
	end

	if changed then
		self:onEnvLinkChange()
	end

	return changed
end

function HomelandEnvManager:addHomeLinkInfo(ornamentId, ornamentInfo)
	if self.homeLinkMap[ornamentId] then
		return
	end

	self.homeLinkMap[ornamentId] = {}

	local ornaments = self:getHomeLinkOrnamentIds(ornamentId, ornamentInfo)
	local changed = false

	for otherOrnamentId, _ in pairs(ornaments) do
		self:setHomeLinkState(ornamentId, otherOrnamentId, true)

		changed = true
	end

	if changed or self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Electric) then
		self:onEnvLinkChange()
	end

	return changed
end

function HomelandEnvManager:removeHomeLinkInfo(ornamentId)
	local changed = false

	if self.homeLinkMap[ornamentId] then
		for otherOrnamentId, _ in pairs(self.homeLinkMap[ornamentId].linkIds) do
			self:setHomeLinkState(ornamentId, otherOrnamentId, false)

			changed = true
		end

		self.homeLinkMap[ornamentId] = nil
	end

	if changed or self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.Electric) then
		self:onEnvLinkChange()
	end

	return changed
end

function HomelandEnvManager:setHomeLinkState(ornamentId, otherOrnamentId, isLink)
	local val

	if isLink then
		val = 1
	end

	self.homeLinkMap[ornamentId].linkIds[otherOrnamentId] = val
	self.homeLinkMap[otherOrnamentId].linkIds[ornamentId] = val
end

function HomelandEnvManager:addHomeEnvFacility(envOrnamentId)
	if self.homeEnvMap[envOrnamentId] then
		return
	end

	self.homeEnvMap[envOrnamentId] = {}

	local ornaments = self:getHomeEnvFacilityRelatedOrnaments(envOrnamentId)

	for ornamentId, _ in pairs(ornaments) do
		self:addHomeEnvRef(ornamentId, envOrnamentId)
	end
end

function HomelandEnvManager:removeHomeEnvFacility(envOrnamentId)
	if self.homeEnvMap[envOrnamentId] then
		local ornaments = self.homeEnvMap[envOrnamentId].ornaments

		for refOrnamentId, v in pairs(ornaments) do
			self:removeHomeEnvRef(refOrnamentId, envOrnamentId)
		end
	end

	self.homeEnvMap[envOrnamentId] = nil
end

function HomelandEnvManager:updateHomeEnvFacility(envOrnamentId)
	if not self.homeEnvMap[envOrnamentId] then
		self.homeEnvMap[envOrnamentId] = {}
	end

	local ornaments = self:getHomeEnvFacilityRelatedOrnaments(envOrnamentId)
	local curOrnaments = self.homeEnvMap[envOrnamentId].ornaments

	for refOrnamentId, v in pairs(curOrnaments) do
		if not ornaments[refOrnamentId] then
			self:removeHomeEnvRef(refOrnamentId, envOrnamentId)
		end
	end

	for ornamentId, _ in pairs(ornaments) do
		if not curOrnaments[ornamentId] then
			self:addHomeEnvRef(ornamentId, envOrnamentId)
		end
	end
end

function HomelandEnvManager:updateHomeEnvRef(ornamentId)
	if self.ornamentEnvMap[ornamentId] == nil then
		self.ornamentEnvMap[ornamentId] = {}
	end

	local changed = false
	local refEnvFacilityInfo = self:getHomeEnvOrnamentRelatedFacilities(ornamentId)

	for envOrnamentId, v in pairs(self.ornamentEnvMap[ornamentId].refEnvFacilityInfo) do
		if not refEnvFacilityInfo[envOrnamentId] then
			self:removeHomeEnvRef(ornamentId, envOrnamentId)

			changed = true
		end
	end

	for envOrnamentId, v in pairs(refEnvFacilityInfo) do
		if not self.ornamentEnvMap[ornamentId].refEnvFacilityInfo[envOrnamentId] then
			self:addHomeEnvRef(ornamentId, envOrnamentId)

			changed = true
		end
	end

	if changed then
		self:onOrnamentEnvChange(ornamentId)
	end

	return changed
end

function HomelandEnvManager:addHomeEnvRef(ornamentId, envOrnamentId)
	if self.ornamentEnvMap[ornamentId] == nil then
		self.ornamentEnvMap[ornamentId] = {}
	end

	if self.ornamentEnvMap[ornamentId].refEnvFacilityInfo[envOrnamentId] ~= 1 then
		self.ornamentEnvMap[ornamentId].refEnvFacilityInfo[envOrnamentId] = 1

		self:onOrnamentEnvChange(ornamentId)
	end

	self.homeEnvMap[envOrnamentId].ornaments[ornamentId] = 1
end

function HomelandEnvManager:removeHomeEnvRef(ornamentId, envOrnamentId)
	local changed = false

	if self.ornamentEnvMap[ornamentId] then
		if not envOrnamentId then
			for curEnvOrnamentId, v in pairs(self.ornamentEnvMap[ornamentId].refEnvFacilityInfo) do
				if self.homeEnvMap[curEnvOrnamentId] then
					self.homeEnvMap[curEnvOrnamentId].ornaments[ornamentId] = nil
				end
			end

			self.ornamentEnvMap[ornamentId] = nil
			changed = true
		else
			if self.ornamentEnvMap[ornamentId].refEnvFacilityInfo[envOrnamentId] then
				self.ornamentEnvMap[ornamentId].refEnvFacilityInfo[envOrnamentId] = nil
				changed = true
			end

			if self.homeEnvMap[envOrnamentId] then
				self.homeEnvMap[envOrnamentId].ornaments[ornamentId] = nil
			end
		end
	end

	if changed then
		self:onOrnamentEnvChange(ornamentId)
	end
end

function HomelandEnvManager:checkIsFacilityType(ornamentId, type)
	return self.facilityTypeFastFindMap[ornamentId] == type
end

function HomelandEnvManager:onOrnamentEnvChange(ornamentId)
	self.envOrnamentDirtyDict[ornamentId] = true

	if self:checkIsEnvReqFacility(ornamentId) then
		self:markElectricStateDirty()
	end
end

function HomelandEnvManager:onEnvLinkChange()
	self.linkDirty = true

	if self.linkChangeCallback then
		self.linkChangeCallback()
	end
end

function HomelandEnvManager:updateEnvFacilityProduce()
	if self.isSimulate then
		return
	end

	self:updateElectricProduce()
	self:updateNormalEnvProduce()
end

function HomelandEnvManager:updateFacilityNormalEnvProduce(ornamentId, facilityType)
	if self.isSimulate then
		return
	end

	local ornamentInfo = self.ornament[ornamentId]

	if not ornamentInfo then
		return
	end

	local facilityInfo = self.space.facility[ornamentId]

	if not facilityInfo then
		return
	end

	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
	local facilityData = HomelandFacilityData[facilityId]
	local homeEnvInfo = self.homeEnvMap[ornamentId]
	local envProduce = 0

	if facilityData and not facilityInfo.disable and facilityInfo.formulaId ~= 0 then
		local relatedPetList = self.space.facilityAllocationInfo[ornamentId]

		if relatedPetList then
			for _, petId in ipairs(relatedPetList) do
				local petAllocationInfo = self.space.allocation[petId]

				if petAllocationInfo.opId == facilityInfo.facilityState then
					if facilityType == Const.HOMELAND_FACILITY_TYPE.Light then
						envProduce = 1

						break
					end

					if facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
						envProduce = facilityInfo.envParam

						break
					end

					if facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
						envProduce = -facilityInfo.envParam
					end

					break
				end
			end
		else
			envProduce = 0
		end
	else
		envProduce = 0
	end

	if envProduce ~= homeEnvInfo.envProduce then
		homeEnvInfo.envProduce = envProduce

		local ornaments = homeEnvInfo.ornaments

		for childOrnament, _ in pairs(ornaments) do
			self:onOrnamentEnvChange(childOrnament)
		end
	end
end

function HomelandEnvManager:updateFacilityElectricProduce(ornamentId)
	if self.isSimulate then
		return
	end

	local ornamentInfo = self.ornament[ornamentId]

	if not ornamentInfo then
		return
	end

	local facilityInfo = self.space.facility[ornamentId]

	if not facilityInfo then
		return
	end

	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
	local facilityData = HomelandFacilityData[facilityId]
	local homeEnvInfo = self.homeEnvMap[ornamentId]
	local envProduce = 0

	if facilityInfo.formulaId ~= 0 then
		local formulaData = HomelandFormulaData[facilityInfo.formulaId]

		if facilityData and not facilityInfo.disable then
			local relatedPetList = self.space.facilityAllocationInfo[ornamentId]

			if relatedPetList and formulaData.unitWorkload > 0 then
				local totalWorkLoad = 0

				for _, petId in ipairs(relatedPetList) do
					local petAllocationInfo = self.space.allocation[petId]

					if petAllocationInfo.opId == facilityInfo.facilityState then
						totalWorkLoad = totalWorkLoad + petAllocationInfo.workload
					end
				end

				envProduce = math.min(1, totalWorkLoad / formulaData.unitWorkload) * formulaData.electricProduce
			else
				envProduce = 0
			end
		else
			envProduce = 0
		end
	end

	if envProduce ~= homeEnvInfo.envProduce then
		homeEnvInfo.envProduce = envProduce

		self:markElectricStateDirty()
	end
end

function HomelandEnvManager:updateElectricProduce()
	local electricList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.Electric] or {}

	for ornamentId, _ in pairs(electricList) do
		self:updateFacilityElectricProduce(ornamentId)
	end
end

function HomelandEnvManager:updateNormalEnvProduce(force)
	if not self.normalEnvProduceDirty and not force then
		return
	end

	self.normalEnvProduceDirty = false

	local highList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.HighTemperate] or {}

	for ornamentId, _ in pairs(highList) do
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.HighTemperate)
	end

	local lowList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.LowTemperate] or {}

	for ornamentId, _ in pairs(lowList) do
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.LowTemperate)
	end

	local lightList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.Light] or {}

	for ornamentId, _ in pairs(lightList) do
		self:updateFacilityNormalEnvProduce(ornamentId, Const.HOMELAND_FACILITY_TYPE.Light)
	end
end

function HomelandEnvManager:updateNormalEnvInfo(force)
	if force then
		local reqEnvList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.EnvRequire] or {}

		for ornamentId, _ in pairs(reqEnvList) do
			self:updateOrnamentNormalEnvInfo(ornamentId)
		end
	else
		for ornamentId, _ in pairs(self.envOrnamentDirtyDict) do
			self:updateOrnamentNormalEnvInfo(ornamentId)
		end
	end
end

function HomelandEnvManager:updateOrnamentNormalEnvInfo(ornamentId)
	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.EnvRequire) then
		local ornamentEnvInfo = self.ornamentEnvMap[ornamentId]

		if ornamentEnvInfo then
			local refEnvFacilityInfo = self.ornamentEnvMap[ornamentId].refEnvFacilityInfo
			local light = 0
			local temperature = 0

			for refEnvFacilityId, _ in pairs(refEnvFacilityInfo) do
				local envFacilityInfo = self.homeEnvMap[refEnvFacilityId]

				if envFacilityInfo then
					if self:checkIsFacilityType(refEnvFacilityId, Const.HOMELAND_FACILITY_TYPE.Light) then
						light = light + envFacilityInfo.envProduce
					elseif self:checkIsFacilityType(refEnvFacilityId, Const.HOMELAND_FACILITY_TYPE.HighTemperate) then
						temperature = temperature + envFacilityInfo.envProduce
					elseif self:checkIsFacilityType(refEnvFacilityId, Const.HOMELAND_FACILITY_TYPE.LowTemperate) then
						temperature = temperature + envFacilityInfo.envProduce
					end
				end
			end

			ornamentEnvInfo.temperature = math.clamp(temperature, -2, 2)
			ornamentEnvInfo.light = math.clamp(light, 0, 1)

			self:updateOrnamentNormalWorkRatio(ornamentId)

			if self.space then
				self.space:postComponentMethod("EVENT_OnOrnamentEvnInfoChanged", ornamentId)
			end
		end
	end
end

function HomelandEnvManager:updateOrnamentNormalWorkRatio(ornamentId)
	if self.isSimulate then
		return
	end

	local workRatio = 1
	local ornamentInfo = self.ornament[ornamentId]

	if not ornamentInfo then
		return
	end

	local facilityInfo = self.space.facility[ornamentId]

	if not facilityInfo or facilityInfo.formulaId == 0 then
		return
	end

	local ornamentEnvInfo = self.ornamentEnvMap[ornamentId]
	local formulaData = HomelandFormulaData[facilityInfo.formulaId]

	if not formulaData then
		return
	end

	if formulaData.forceEnvRequire then
		if formulaData.temperatureRequire and ornamentEnvInfo.temperature ~= formulaData.temperatureRequire then
			workRatio = 0
		end

		if formulaData.lightRequire and ornamentEnvInfo.light ~= formulaData.lightRequire then
			workRatio = 0
		end
	else
		if formulaData.temperatureRequire then
			local tempDiff = ornamentEnvInfo.temperature - formulaData.temperatureRequire

			workRatio = workRatio * Utils.calcTemperatureDiffWorkRatio(tempDiff)
		end

		if formulaData.lightRequire then
			local lightDiff = ornamentEnvInfo.light - formulaData.lightRequire

			workRatio = workRatio * Utils.calcLightDiffWorkRatio(lightDiff)
		end
	end

	self.space:setFacilityEnvBaseWorkRatio(ornamentId, workRatio)
end

function HomelandEnvManager:updateEnvInfo(force)
	self:updateNormalEnvInfo(force)
	self:updateElectricLinkGroup(force)
	self:updateElectricState(force)
	table.clear(self.envOrnamentDirtyDict)
end

function HomelandEnvManager:updateElectricLinkGroup(force)
	if not self.linkDirty and not force then
		return
	end

	self.linkDirty = false

	table.clear(self.tempLinkMeetDict)

	local electricList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.Electric] or {}
	local electricLinkList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.ElectricLink] or {}
	local groups = {}

	for ornamentId, _ in pairs(electricList) do
		if not self.tempLinkMeetDict[ornamentId] then
			self.tempLinkMeetDict[ornamentId] = 1

			table.clear(self.tempRequireCheckList)

			self.tempRequireCheckList[1] = ornamentId

			local linkGroupId = ornamentId
			local groupInfo = HomeLinkGroupInfo({})

			while #self.tempRequireCheckList > 0 do
				local curOrnamentId = table.remove(self.tempRequireCheckList)

				if electricList[curOrnamentId] then
					groupInfo.mainOrnaments:insert(curOrnamentId)
				else
					groupInfo.subOrnaments:insert(curOrnamentId)
				end

				local linkInfo = self.homeLinkMap[curOrnamentId]

				linkInfo.groupId = linkGroupId

				for otherOrnamentId, _ in pairs(linkInfo.linkIds) do
					if not self.tempLinkMeetDict[otherOrnamentId] then
						self.tempLinkMeetDict[otherOrnamentId] = 1
						self.tempRequireCheckList[#self.tempRequireCheckList + 1] = otherOrnamentId
					end
				end
			end

			groups[linkGroupId] = true
			self.homeLinkGroupMap[linkGroupId] = groupInfo
		end
	end

	for linkOrnamentId, linkInfo in pairs(self.homeLinkMap) do
		if not self.tempLinkMeetDict[linkOrnamentId] then
			linkInfo.groupId = 0
		end
	end

	for groupId, _ in pairs(self.homeLinkGroupMap) do
		if not groups[groupId] then
			self.homeLinkGroupMap[groupId] = nil
		end
	end

	self.electricDirty = true
	self.electricLinkDirty = true
end

function HomelandEnvManager:getLinkGroupChilds(groupInfo)
	local childOrnaments = {}

	for _, mainOrnamentId in pairs(groupInfo.mainOrnaments) do
		local homeEnvInfo = self.homeEnvMap[mainOrnamentId]

		for ornamentId, _ in pairs(homeEnvInfo.ornaments) do
			childOrnaments[ornamentId] = 1
		end
	end

	for _, subOrnamentId in pairs(groupInfo.subOrnaments) do
		local homeEnvInfo = self.homeEnvMap[subOrnamentId]

		if homeEnvInfo then
			for ornamentId, _ in pairs(homeEnvInfo.ornaments) do
				childOrnaments[ornamentId] = 1
			end
		end
	end

	return childOrnaments
end

function HomelandEnvManager:getOrnamentElectricCost(ornamentId)
	local ornamentInfo = self.ornament[ornamentId]

	if not ornamentInfo then
		return
	end

	local envOrnamentInfo = self.ornamentEnvMap[ornamentId]

	if not envOrnamentInfo then
		return
	end

	local linkGroupCount = 0

	table.clear(self.tempGroupMeetDict)

	for refOrnamentId, _ in pairs(envOrnamentInfo.refEnvFacilityInfo) do
		local linkInfo = self.homeLinkMap[refOrnamentId]

		if linkInfo.groupId ~= 0 and not self.tempGroupMeetDict[linkInfo.groupId] then
			self.tempGroupMeetDict[linkInfo.groupId] = true
			linkGroupCount = linkGroupCount + 1
		end
	end

	if linkGroupCount == 0 then
		linkGroupCount = 1
	end

	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
	local facilityData = HomelandFacilityData[facilityId]

	return (facilityData.electricRequire or 0) / linkGroupCount
end

function HomelandEnvManager:markElectricStateDirty()
	self.electricDirty = true
end

function HomelandEnvManager:checkNeedElectricCost(ornamentId)
	if self.isSimulate then
		return false
	end

	local facilityInfo = self.space.facility[ornamentId]

	if not facilityInfo then
		return false
	end

	if facilityInfo.formulaId == 0 then
		return false
	end

	if facilityInfo.disable then
		return false
	end

	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch) then
		local ornamentInfo = self.ornament[ornamentId]

		if not ornamentInfo.electricMode then
			return false
		end
	end

	return true
end

function HomelandEnvManager:updateOrnamentElectricCost(ornamentId)
	local envOrnamentInfo = self.ornamentEnvMap[ornamentId]

	if not envOrnamentInfo then
		return false
	end

	local electricCost = 0

	if self:checkNeedElectricCost(ornamentId) then
		electricCost = self:getOrnamentElectricCost(ornamentId)
	else
		electricCost = 0
	end

	if envOrnamentInfo.electricCost ~= electricCost then
		envOrnamentInfo.electricCost = electricCost

		return true
	end

	return false
end

function HomelandEnvManager:updateOrnamentElectricWorkRatio(ornamentId, ornamentInfo)
	local envOrnamentInfo = self.ornamentEnvMap[ornamentId]

	if not envOrnamentInfo then
		return
	end

	if self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch) and not ornamentInfo.electricMode then
		self.space:setFacilityEnvBaseWorkRatio(ornamentId, 1)

		return
	end

	if envOrnamentInfo.electricCost <= 0 then
		self.space:setFacilityEnvBaseWorkRatio(ornamentId, 0)
	else
		local linkGroupCount = 0
		local workRatio = 0

		table.clear(self.tempGroupMeetDict)

		for refOrnamentId, _ in pairs(envOrnamentInfo.refEnvFacilityInfo) do
			local linkInfo = self.homeLinkMap[refOrnamentId]

			if linkInfo.groupId ~= 0 and not self.tempGroupMeetDict[linkInfo.groupId] then
				self.tempGroupMeetDict[linkInfo.groupId] = true

				local envGroupInfo = self.homeLinkGroupMap[linkInfo.groupId]

				if envGroupInfo then
					linkGroupCount = linkGroupCount + 1
					workRatio = workRatio + math.min(HomelandConfigData.electricMaxWorkRate or 1, envGroupInfo.totalProduce / envGroupInfo.totalCost)
				end
			end
		end

		if linkGroupCount == 0 then
			self.space:setFacilityEnvBaseWorkRatio(ornamentId, 0)
		else
			self.space:setFacilityEnvBaseWorkRatio(ornamentId, workRatio / linkGroupCount)
		end
	end
end

function HomelandEnvManager:checkIsEnvReqFacility(ornamentId)
	return self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.ElectricReq) or self:checkIsFacilityType(ornamentId, Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch)
end

function HomelandEnvManager:updateElectricState(force)
	if self.isSimulate then
		return
	end

	if not self.electricDirty and not force then
		for ornamentId, _ in pairs(self.envOrnamentDirtyDict) do
			if self:checkIsEnvReqFacility(ornamentId) then
				self:updateOrnamentElectricCost(ornamentId)
			end
		end

		for ornamentId, ornamentInfo in pairs(self.envOrnamentDirtyDict) do
			if self:checkIsEnvReqFacility(ornamentId) then
				self:updateOrnamentElectricWorkRatio(ornamentId, ornamentInfo)
			end
		end

		return
	end

	self.electricDirty = false

	local reqElectricList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.ElectricReq] or {}
	local reqElectricSwitchList = self.envFacilityTypeDict[Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch] or {}

	if self.electricLinkDirty or force then
		self.electricLinkDirty = false

		for ornamentId, ornamentInfo in pairs(reqElectricList) do
			self:updateOrnamentElectricCost(ornamentId)
		end

		for ornamentId, ornamentInfo in pairs(reqElectricSwitchList) do
			self:updateOrnamentElectricCost(ornamentId)
		end
	else
		for ornamentId, _ in pairs(self.envOrnamentDirtyDict) do
			if self:checkIsEnvReqFacility(ornamentId) then
				self:updateOrnamentElectricCost(ornamentId)
			end
		end
	end

	for groupId, groupInfo in pairs(self.homeLinkGroupMap) do
		local totalProduce = 0

		for _, mainOrnamentId in pairs(groupInfo.mainOrnaments) do
			local envInfo = self.homeEnvMap[mainOrnamentId]

			totalProduce = totalProduce + envInfo.envProduce
		end

		groupInfo.totalProduce = totalProduce

		local totalElectricCost = 0
		local childs = self:getLinkGroupChilds(groupInfo)

		for ornamentId, _ in pairs(childs) do
			local envOrnamentInfo = self.ornamentEnvMap[ornamentId]

			totalElectricCost = totalElectricCost + envOrnamentInfo.electricCost
		end

		groupInfo.totalCost = totalElectricCost
	end

	for ornamentId, ornamentInfo in pairs(reqElectricList) do
		self:updateOrnamentElectricWorkRatio(ornamentId, ornamentInfo)
	end

	for ornamentId, ornamentInfo in pairs(reqElectricSwitchList) do
		self:updateOrnamentElectricWorkRatio(ornamentId, ornamentInfo)
	end
end

return HomelandEnvManager
