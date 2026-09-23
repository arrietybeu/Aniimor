-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Attribute\\AttributeCalcUtils.lua

local AttributeCalcUtils = {}
local SMALL_NUMBER = math.smallNumber

function AttributeCalcUtils.calcPvcCurValue(v, p, fix, conv)
	return v * (1 + p) + fix + conv
end

function AttributeCalcUtils.calcMaxPvcCurValue(v, p, fix, conv)
	return v * (1 + p) + fix + conv
end

function AttributeCalcUtils.calcXpMaxCurValue(v, p, fix, conv, scale, forceSet)
	if forceSet > SMALL_NUMBER then
		return forceSet * (1 + scale)
	end

	return AttributeCalcUtils.calcPvcCurValue(v, p, fix, conv) * (1 + scale)
end

function AttributeCalcUtils.calcXpScaleMaxCurValue(v, p, fix, conv, scale, forceSet)
	if forceSet > SMALL_NUMBER then
		return forceSet
	end

	return AttributeCalcUtils.calcPvcCurValue(v, p, fix, conv) * (1 + scale)
end

function AttributeCalcUtils.calcLimitCurValue(cur, maxCur)
	return math.min(cur, maxCur)
end

function AttributeCalcUtils.calcConversionBaseValue(curValue, conversionValue, scale)
	return curValue - conversionValue * scale
end

function AttributeCalcUtils.calcConversionValue(curValue, conversionValue, scale, rate)
	return AttributeCalcUtils.calcConversionBaseValue(curValue, conversionValue, scale) * rate
end

return AttributeCalcUtils
