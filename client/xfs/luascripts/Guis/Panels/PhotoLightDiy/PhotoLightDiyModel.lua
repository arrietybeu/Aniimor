-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoLightDiy\\PhotoLightDiyModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PhotoLightDiyModel = Class.LightClass("PhotoLightDiyModel", UIModel)

PhotoLightDiyModel.SchemeVersion = 3
PhotoLightDiyModel.LightCount = 3
PhotoLightDiyModel.NameMaxLength = 7
PhotoLightDiyModel.LightTabs = {
	{
		lightIndex = 1,
		tIndex = 0,
		label = "PHOTO_LIGHT_TAB_NAME"
	},
	{
		lightIndex = 2,
		tIndex = 1,
		label = "PHOTO_LIGHT_TAB_NAME"
	},
	{
		lightIndex = 3,
		tIndex = 2,
		label = "PHOTO_LIGHT_TAB_NAME"
	}
}
PhotoLightDiyModel.ParamType = {
	Switch = 1,
	Color = 3,
	Slider = 2
}
PhotoLightDiyModel.SwitchOptions = {
	{
		enabled = true,
		label = "PHOTO_LIGHT_ON"
	},
	{
		enabled = false,
		label = "PHOTO_LIGHT_OFF"
	}
}
PhotoLightDiyModel.LightDefaults = {
	{
		intensity = 6,
		colorIntensity = 50,
		tilt = -1,
		direction = 49,
		height = 107,
		distance = 112
	},
	{
		intensity = 14,
		colorIntensity = 54,
		tilt = 19,
		direction = 0,
		height = 109,
		distance = 154
	},
	{
		intensity = 68,
		colorIntensity = 50,
		tilt = 19,
		direction = 125,
		height = 116,
		distance = 100
	}
}
PhotoLightDiyModel.ParamList = {
	{
		tIndex = 0,
		label = "PHOTO_LIGHT_SWITCH",
		paramType = PhotoLightDiyModel.ParamType.Switch
	},
	{
		decimals = 0,
		stepSize = 1,
		defaultValue = 33,
		maxValue = 100,
		minValue = 0,
		key = "intensity",
		label = "PHOTO_LIGHT_INTENSITY",
		tIndex = 1,
		paramType = PhotoLightDiyModel.ParamType.Slider
	},
	{
		decimals = 0,
		stepSize = 1,
		defaultValue = 160,
		maxValue = 300,
		minValue = 100,
		key = "distance",
		label = "PHOTO_LIGHT_DISTANCE",
		tIndex = 1,
		reserved = true,
		paramType = PhotoLightDiyModel.ParamType.Slider
	},
	{
		decimals = 0,
		stepSize = 1,
		defaultValue = 140,
		maxValue = 200,
		minValue = 50,
		key = "height",
		label = "PHOTO_LIGHT_HEIGHT",
		tIndex = 1,
		reserved = true,
		paramType = PhotoLightDiyModel.ParamType.Slider
	},
	{
		decimals = 0,
		stepSize = 1,
		defaultValue = 0,
		maxValue = 180,
		minValue = -180,
		key = "direction",
		label = "PHOTO_LIGHT_DIRECTION",
		tIndex = 1,
		reserved = true,
		paramType = PhotoLightDiyModel.ParamType.Slider
	},
	{
		decimals = 0,
		stepSize = 1,
		defaultValue = 0,
		maxValue = 90,
		minValue = -90,
		key = "tilt",
		label = "PHOTO_LIGHT_TILT",
		tIndex = 1,
		reserved = true,
		paramType = PhotoLightDiyModel.ParamType.Slider
	},
	{
		decimals = 0,
		stepSize = 1,
		defaultValue = 50,
		maxValue = 100,
		minValue = 0,
		key = "colorIntensity",
		label = "PHOTO_LIGHT_COLOR_INTENSITY",
		tIndex = 1,
		paramType = PhotoLightDiyModel.ParamType.Slider
	},
	{
		tIndex = 2,
		label = "PHOTO_LIGHT_COLOR",
		paramType = PhotoLightDiyModel.ParamType.Color
	}
}

local function convertRangeValue(value, oldMin, oldMax, newMin, newMax)
	value = tonumber(value)

	if not value then
		return nil
	end

	local normalizedValue = (value - oldMin) / (oldMax - oldMin)

	return newMin + normalizedValue * (newMax - newMin)
end

function PhotoLightDiyModel:applySliderRanges(cameraMode)
	if not cameraMode or not cameraMode.GetDiyLightSliderRange then
		return
	end

	for _, config in ipairs(self.ParamList) do
		if config.paramType == self.ParamType.Slider then
			local range = cameraMode:GetDiyLightSliderRange(config.key)
			local minValue = range and tonumber(range.x)
			local maxValue = range and tonumber(range.y)

			if minValue and maxValue and minValue == minValue and maxValue == maxValue then
				if maxValue < minValue then
					minValue, maxValue = maxValue, minValue
				end

				config.minValue = minValue
				config.maxValue = maxValue
				config.referenceDefaultValue = config.referenceDefaultValue or config.defaultValue
				config.defaultValue = math.clamp(config.referenceDefaultValue, minValue, maxValue)
			end
		end
	end
end

function PhotoLightDiyModel:migrateScheme(scheme, oldVersion)
	if oldVersion >= self.SchemeVersion or type(scheme.lights) ~= "table" then
		return
	end

	for _, lightData in ipairs(scheme.lights) do
		if type(lightData) == "table" then
			lightData.intensity = convertRangeValue(lightData.intensity, 0, 3, 0, 100)
			lightData.distance = convertRangeValue(lightData.distance, 0, 10, 100, 300)
			lightData.height = convertRangeValue(lightData.height, -5, 5, 50, 200)
			lightData.colorIntensity = convertRangeValue(lightData.colorIntensity, 0, 2, 0, 100)
		end
	end
end

function PhotoLightDiyModel:getDefaultSchemeName(slot)
	return string.format(pg.getGameString("PHOTO_LIGHT_CUSTOM_NAME"), slot)
end

function PhotoLightDiyModel:getLightDefaultValue(lightIndex, config)
	local lightDefaults = self.LightDefaults[lightIndex]
	local defaultValue = lightDefaults and lightDefaults[config.key] or config.defaultValue

	return math.clamp(defaultValue, config.minValue, config.maxValue)
end

function PhotoLightDiyModel:normalizeNumber(value, config, defaultValue)
	value = tonumber(value) or defaultValue or config.defaultValue

	return math.clamp(value, config.minValue, config.maxValue)
end

function PhotoLightDiyModel:normalizeLightData(lightIndex, lightData)
	if type(lightData) ~= "table" then
		lightData = {}
	end

	if lightData.enabled == nil then
		lightData.enabled = lightIndex == 1
	else
		lightData.enabled = lightData.enabled == true
	end

	for _, config in ipairs(self.ParamList) do
		if config.paramType == self.ParamType.Slider then
			local defaultValue = self:getLightDefaultValue(lightIndex, config)

			lightData[config.key] = self:normalizeNumber(lightData[config.key], config, defaultValue)
		end
	end

	if type(lightData.color) ~= "table" then
		lightData.color = {}
	end

	lightData.color.r = math.clamp(tonumber(lightData.color.r) or 1, 0, 1)
	lightData.color.g = math.clamp(tonumber(lightData.color.g) or 1, 0, 1)
	lightData.color.b = math.clamp(tonumber(lightData.color.b) or 1, 0, 1)

	return lightData
end

function PhotoLightDiyModel:buildDefaultScheme(slot)
	local lights = {}

	for lightIndex = 1, self.LightCount do
		lights[lightIndex] = self:normalizeLightData(lightIndex)
	end

	return {
		version = self.SchemeVersion,
		slot = slot,
		name = self:getDefaultSchemeName(slot),
		lights = lights
	}
end

function PhotoLightDiyModel:normalizeScheme(slot, scheme)
	if type(scheme) ~= "table" then
		return self:buildDefaultScheme(slot)
	end

	local oldVersion = tonumber(scheme.version) or 1

	self:migrateScheme(scheme, oldVersion)

	scheme.slot = slot

	if type(scheme.name) ~= "string" or string.isNilOrEmpty(scheme.name) then
		scheme.name = self:getDefaultSchemeName(slot)
	end

	if type(scheme.lights) ~= "table" then
		scheme.lights = {}
	end

	for lightIndex = 1, self.LightCount do
		scheme.lights[lightIndex] = self:normalizeLightData(lightIndex, scheme.lights[lightIndex])
	end

	scheme.version = self.SchemeVersion

	return scheme
end

return PhotoLightDiyModel
