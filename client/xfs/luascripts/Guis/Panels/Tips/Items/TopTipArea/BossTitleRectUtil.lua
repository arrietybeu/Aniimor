-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossTitleRectUtil.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local RectUtil = {}
local DoTweenAnimMgr = DoTweenAnimMgr
local FX_RETRACT_EASE_SINEIN = CS.DG.Tweening.Ease.__CastFrom(2)

function RectUtil.applyRectByRatio(rect, allWidth, sizeY, topRatio, bottomRatio, posY)
	allWidth = allWidth or 0

	local displayWidth = allWidth * math.clamp(topRatio - bottomRatio, 0, 1)
	local posX = allWidth * math.clamp(topRatio, 0, 1)

	rect:SetSizeDeltaAndAnchoredPosEx(displayWidth, sizeY or 0, posX, posY)
end

function RectUtil.startRetractTween(target, id, fromRatio, toRatio, duration, delay, updateCb, completeCb)
	local tweenId = LuaUIUtils.TweenId(id)
	local targetGo = target.gameObject

	DoTweenAnimMgr.Kill(targetGo, tweenId, false)
	DoTweenAnimMgr.DoFloat(targetGo, fromRatio, toRatio, tweenId, duration, delay, FX_RETRACT_EASE_SINEIN, nil, updateCb, completeCb)
end

return RectUtil
