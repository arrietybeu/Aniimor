-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Setting\\DeviceVideoOverride.lua

local DeviceVideoOverride = {
	enabled = true,
	defaults = {
		transparentInIndependentPass = false,
		transparentInOnePass = false,
		postTaa5TapSharpen = true
	},
	valueTypes = {
		transparentInIndependentPass = "bool",
		transparentInOnePass = "bool",
		postTaa5TapSharpen = "bool"
	},
	rules = {
		{
			id = "android_transparency_independent_pass",
			platforms = {
				Android = true
			},
			values = {
				transparentInIndependentPass = true,
				transparentInOnePass = false
			}
		},
		{
			id = "ios_transparency_independent_pass",
			platforms = {
				IOS = true
			},
			values = {
				transparentInIndependentPass = true,
				transparentInOnePass = false
			}
		}
	}
}

local function matchesRule(rule, platform, deviceModel)
	if rule.platforms and not rule.platforms[platform] then
		return false
	end

	if rule.deviceModels and not rule.deviceModels[deviceModel] then
		return false
	end

	return true
end

function DeviceVideoOverride.resolve(key, requestedValue, platform, deviceModel)
	if not DeviceVideoOverride.enabled then
		return requestedValue
	end

	local effectiveValue = requestedValue

	for _, rule in ipairs(DeviceVideoOverride.rules) do
		if matchesRule(rule, platform, deviceModel) and rule.values[key] ~= nil then
			effectiveValue = rule.values[key]
		end
	end

	return effectiveValue
end

return DeviceVideoOverride
