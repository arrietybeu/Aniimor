-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ValueDisplayUtils.lua

local ValueShowCfg = require("Data.value_display_type_data")
local ValueDisplayUtils = {}

function ValueDisplayUtils.getFormatTxt(cfgIds, txt, ...)
	local newTxt = pg.getLocalizationText(txt)

	if cfgIds == nil then
		return pg.getFormatText(newTxt, ...)
	end

	local params = {
		...
	}

	for k, v in ipairs(cfgIds) do
		params[k] = ValueDisplayUtils.processValueById(v, params[k])
	end

	return pg.getFormatText(newTxt, unpack(params))
end

function ValueDisplayUtils.getFormatTxtNoParam(cfgIds, txt)
	local newTxt = pg.getLocalizationText(txt)
	local ret = ValueDisplayUtils.getValueByIds(cfgIds)

	if ret == nil then
		return newTxt
	end

	return pg.getFormatText(newTxt, unpack(ret))
end

function ValueDisplayUtils.getValueByIds(cfgIds)
	if cfgIds == nil or type(cfgIds) ~= "table" then
		return
	end

	local ret = {}

	for _, v in ipairs(cfgIds) do
		local func = ValueDisplayUtils["process_cfg" .. v]
		local data

		if func then
			data = func()
		end

		table.insert(ret, data)
	end

	return ret
end

function ValueDisplayUtils.process_cfg1()
	local starTitle = pg.me.starTitle or 0

	return ValueDisplayUtils.process_starTitle(ValueShowCfg[1], starTitle)
end

function ValueDisplayUtils.process_cfg2()
	local starTitle = pg.me.starTitle or 0

	return ValueDisplayUtils.process_starTitle(ValueShowCfg[2], starTitle + 1)
end

function ValueDisplayUtils.process_cfg3()
	local starTitle = pg.me.starTitle or 0

	if starTitle > 0 then
		starTitle = starTitle - 1
	end

	return ValueDisplayUtils.process_starTitle(ValueShowCfg[3], starTitle)
end

function ValueDisplayUtils.process_cfg4()
	local level = pg.me.level

	return ValueDisplayUtils.process_type2(ValueShowCfg[4], level)
end

function ValueDisplayUtils.processValueById(cfgId, data)
	if cfgId == nil or cfgId == 0 then
		return data
	end

	local cfg = ValueShowCfg[cfgId]

	if cfg == nil then
		return data
	end

	local func = ValueDisplayUtils["process_type" .. cfg.type]

	if func then
		return func(cfg, data)
	end

	return data
end

function ValueDisplayUtils.process_type1(cfg, data)
	if cfg.length then
		local curLen = ValueDisplayUtils.utf8len(data)

		if curLen > cfg.length then
			return string.sub(data, 1, cfg.length)
		end
	end

	return data
end

function ValueDisplayUtils.process_type2(cfg, data)
	local dataStr = tostring(data)
	local curLen = #dataStr

	if cfg.shortShow then
		if data >= 1000000000 then
			return string.format("%.0fB", data / 1000000000)
		elseif data >= 1000000 then
			return string.format("%.0fM", data / 1000000)
		elseif data >= 3 then
			return string.format("%.0fk", data / 1000)
		end
	elseif cfg.length and curLen > cfg.length then
		return string.sub(dataStr, 1, cfg.length)
	end

	return data
end

function ValueDisplayUtils.process_type3(cfg, data)
	return data * 0.001
end

function ValueDisplayUtils.utf8len(str)
	local _, count = string.gsub(str, "[^\x80-\xC1]", "")

	return count
end

function ValueDisplayUtils.process_starTitle(cfg, curTitle)
	local LuaUIUtils = require("Utils.LuaUIUtils")
	local cT = LuaUIUtils.getStarTitleName(curTitle, true)

	return ValueDisplayUtils.process_type1(cfg, cT)
end

return ValueDisplayUtils
