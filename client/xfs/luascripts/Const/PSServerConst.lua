-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\PSServerConst.lua

local PSServerConst = {}

PSServerConst.AUTO_SELECT_SERVER_DEFAULT_ENABLED = RemoteConfigEnablePSAutoSelectServer == true
PSServerConst.autoSelectServerEnabled = PSServerConst.AUTO_SELECT_SERVER_DEFAULT_ENABLED
PSServerConst.SERVER_REGION = {
	APAC = "AP",
	EUROPE = "EU",
	AMERICA = "NA"
}

local COUNTRY_CODES_BY_REGION = {
	[PSServerConst.SERVER_REGION.AMERICA] = {
		"ar",
		"bo",
		"br",
		"ca",
		"cl",
		"co",
		"cr",
		"ec",
		"sv",
		"gt",
		"hn",
		"mx",
		"ni",
		"pa",
		"py",
		"pe",
		"us",
		"uy"
	},
	[PSServerConst.SERVER_REGION.EUROPE] = {
		"at",
		"bh",
		"be",
		"bg",
		"hr",
		"cy",
		"cz",
		"dk",
		"fi",
		"fr",
		"de",
		"gr",
		"hu",
		"is",
		"ie",
		"il",
		"it",
		"kw",
		"lb",
		"lu",
		"mt",
		"nl",
		"no",
		"pl",
		"pt",
		"qa",
		"ro",
		"ru",
		"sa",
		"sk",
		"si",
		"za",
		"es",
		"se",
		"ch",
		"tr",
		"ua",
		"ae",
		"gb"
	},
	[PSServerConst.SERVER_REGION.APAC] = {
		"au",
		"in",
		"id",
		"jp",
		"kr",
		"my",
		"nz",
		"om",
		"sg",
		"hk",
		"tw",
		"th"
	}
}

PSServerConst.COUNTRY_TO_SERVER_REGION = {}

for serverRegion, countryCodes in pairs(COUNTRY_CODES_BY_REGION) do
	for _, countryCode in ipairs(countryCodes) do
		PSServerConst.COUNTRY_TO_SERVER_REGION[countryCode] = serverRegion
	end
end

function PSServerConst.getServerRegion(countryCode)
	if type(countryCode) ~= "string" or countryCode == "" then
		return nil
	end

	return PSServerConst.COUNTRY_TO_SERVER_REGION[string.lower(countryCode)]
end

function PSServerConst.isAutoSelectServerEnabled()
	return PSServerConst.autoSelectServerEnabled
end

function PSServerConst.toggleAutoSelectServer()
	PSServerConst.autoSelectServerEnabled = not PSServerConst.autoSelectServerEnabled

	return PSServerConst.autoSelectServerEnabled
end

function PSServerConst.resetAutoSelectServer()
	PSServerConst.autoSelectServerEnabled = PSServerConst.AUTO_SELECT_SERVER_DEFAULT_ENABLED
end

return PSServerConst
