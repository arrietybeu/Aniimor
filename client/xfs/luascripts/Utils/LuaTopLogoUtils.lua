-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaTopLogoUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LuaTopLogoUtils")
local AddressDataConst = require("Const.AddressDataConst")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local SceneData = require("Data.scene_data")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = require("Const.TopLogoConst")
local IS_MOBILE = IS_MOBILE
local LuaTopLogoUtils = {}

function LuaTopLogoUtils.getTopLogoCompZoneName(componentName)
	if not componentName then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("getTopLogoCompZoneName componentName is nil")
		end

		return ""
	end

	local compConfig = TopLogoConst.TOPLOGO_NEW_ZONE_CONFIG[componentName]

	if not compConfig then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("compConfig is nil, componentName: %s", componentName)
		end

		return ""
	end

	return compConfig.zoneParent or ""
end

function LuaTopLogoUtils.getTopLogoCompZoneConfig(componentName)
	if not componentName then
		return
	end

	local compConfig = TopLogoConst.TOPLOGO_NEW_ZONE_CONFIG[componentName]

	if not compConfig then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("compConfig is nil, componentName: %s", componentName)
		end

		return
	end

	return compConfig
end

function LuaTopLogoUtils.getTopLogoCompRootContainerGoName(componentName)
	if not componentName then
		return
	end

	local newName = "RootContainer_" .. componentName
	local compZoneConfig = LuaTopLogoUtils.getTopLogoCompZoneConfig(componentName)

	newName = newName .. (compZoneConfig and compZoneConfig.mutexGroup and "_" .. compZoneConfig.mutexGroup or "")

	return newName
end

function LuaTopLogoUtils.getTopLogoZoneGroupConfigs(multiType, zoneName)
	if not multiType or not zoneName then
		return
	end

	local rootConfigs = TopLogoConst.TOPLOGO_NEW_ZONE_REVERSE_CONFIG[multiType]
	local zoneComps = rootConfigs and rootConfigs[zoneName] or {}

	return zoneComps
end

function LuaTopLogoUtils.getTopLogoCompPrefabUrl(compName)
	if not compName then
		return ""
	end

	local compZoneConfig = LuaTopLogoUtils.getTopLogoCompZoneConfig(compName)

	if not compZoneConfig then
		return ""
	end

	return compZoneConfig.url or ""
end

function LuaTopLogoUtils.isTopLogoSpecialScene(specialType)
	if not specialType then
		return false
	end

	return pg.space and pg.space.toplogoType == specialType
end

function LuaTopLogoUtils.isPvp2TopLogoScene()
	return LuaTopLogoUtils.isTopLogoSpecialScene(ClientConst.TopLogoSpecial.Pvp_2)
end

function LuaTopLogoUtils.getIsCreateTopLogo(isPetEnt, isGrabEggTransfer)
	local specialType = pg.space and pg.space.toplogoType

	if not specialType then
		return true
	end

	if specialType == ClientConst.TopLogoSpecial.Pvp and isPetEnt then
		return isGrabEggTransfer
	end

	return true
end

function LuaTopLogoUtils.isUseMobileSchedule()
	local USE_MOBILE_SCHEDULE = IS_MOBILE or TopLogoConst.IS_SIMULATE_MOBILE

	return USE_MOBILE_SCHEDULE
end

function LuaTopLogoUtils.getAgentToCapsuleCenterY(entity)
	if entity == nil then
		return 0
	end

	local topLogoData = entity.topLogoData
	local centerY = topLogoData and topLogoData.agentToCapsuleCenterY

	if centerY == nil and entity.getPhysxDataByState then
		local _, _, _, cy = entity:getPhysxDataByState(entity.characterState)

		centerY = cy
	end

	if centerY ~= nil then
		return centerY
	end

	local lockPos = entity.getLockPosition and entity:getLockPosition()
	local rootPos = entity.getPosition and entity:getPosition()

	return (lockPos and lockPos[2] or 0) - (rootPos and rootPos[2] or 0)
end

return LuaTopLogoUtils
