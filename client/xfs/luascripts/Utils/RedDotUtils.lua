-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RedDotUtils.lua

local RedDotConst = require("Const.RedDotConst")
local RedDotUtils = {}
local CSRedDotManager = CS.XGUI.RedDotMgr

function RedDotUtils.setRedDot(treePath, uWidget, isShow, defaultStyle, dotNum)
	if string.isNilOrEmpty(treePath) then
		return
	end

	if pg.global.scene:checkHideRedDot() then
		isShow = false
	end

	defaultStyle = defaultStyle or RedDotConst.RedDotStyle.NONE

	CSRedDotManager.LuaSetRedDot(treePath, uWidget, isShow, defaultStyle, dotNum or 0)
end

function RedDotUtils.checkHideRedDotHandle()
	return RedDotConst.RedDotStyle.NONE
end

function RedDotUtils.setPreViewRedDot(treePath, uWidget, func, func2)
	if string.isNilOrEmpty(treePath) or IsNil(uWidget) or func == nil then
		return
	end

	local function handle()
		if pg.global.scene:checkHideRedDot() then
			return RedDotConst.RedDotStyle.NONE
		end

		local success, result = pcall(func)

		if not success then
			return RedDotConst.RedDotStyle.NONE
		end

		return result
	end

	CSRedDotManager.LuaSetPreViewRedDot(treePath, uWidget, handle, func2)
end

function RedDotUtils.bindCurvedUI(treePath)
	CSRedDotManager.LuaBindCurvedUI(treePath)
end

function RedDotUtils.setCustomRedDotHandle(uWidget, func)
	if IsNil(uWidget) or func == nil then
		return
	end

	CSRedDotManager.LuaSetCustomRedDotHandle(uWidget, func)
end

function RedDotUtils.refreshRedDotState(treePath)
	if pg.global.scene:checkHideRedDot() then
		return
	end

	CSRedDotManager.CheckRefreshRedDotState(treePath)
end

function RedDotUtils.calculateRedDotPriority(styleList)
	if styleList == nil or #styleList == 0 then
		return RedDotConst.RedDotStyle.NONE
	end

	local style = RedDotConst.RedDotStyle.NONE
	local maxPriority = 0

	for _, v in ipairs(styleList) do
		local priority = RedDotConst.RedDotStylePriority[v] or 0

		if maxPriority < priority then
			maxPriority = priority
			style = v
		end
	end

	return style
end

return RedDotUtils
