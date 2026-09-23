-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Helper\\PropDetailUseAction.lua

local PropDetailComponent = require("Guis.Panels.Inventory.Component.PropDetailComponent")
local UIConst = require("Const.UIConst")
local PropDetailUseAction = {}
local activeOpenCounts = {}
local activeOpenCount = 0
local hudHidden = false

local function createComponentContext(context)
	local componentContext = {}

	for key, value in pairs(context or {}) do
		componentContext[key] = value
	end

	return setmetatable(componentContext, {
		__index = PropDetailComponent
	})
end

local function pack(...)
	return {
		n = select("#", ...),
		...
	}
end

local function createWhiteList()
	local whiteList = {
		[UIConst.UI_ID_COMMON_ITEM_TIP] = true
	}

	for uid in pairs(activeOpenCounts) do
		whiteList[uid] = true
	end

	return whiteList
end

local function refreshHiddenHud()
	local ui = pg.global.ui

	if activeOpenCount == 0 then
		if hudHidden then
			hudHidden = false

			ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.SpecialItem)
		end
	elseif hudHidden then
		ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.SpecialItem, createWhiteList())
	end
end

local function beginTrackedOpen(uid)
	activeOpenCount = activeOpenCount + 1
	activeOpenCounts[uid] = (activeOpenCounts[uid] or 0) + 1

	refreshHiddenHud()

	local closed = false

	local function closeTrackedOpen()
		if closed then
			return false
		end

		closed = true
		activeOpenCount = activeOpenCount - 1

		local uidOpenCount = activeOpenCounts[uid]

		if uidOpenCount == 1 then
			activeOpenCounts[uid] = nil
		else
			activeOpenCounts[uid] = uidOpenCount - 1
		end

		refreshHiddenHud()

		return true
	end

	local function finishTrackedOpen()
		if not closed and not hudHidden then
			hudHidden = true

			pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.SpecialItem, createWhiteList())
		end
	end

	return closeTrackedOpen, finishTrackedOpen
end

local function invokeTrackedOpen(uid, closeCallback, openCallback)
	local closeTrackedOpen, finishTrackedOpen = beginTrackedOpen(uid)

	local function wrappedCloseCallback(...)
		if not closeTrackedOpen() then
			return
		end

		if closeCallback then
			return closeCallback(...)
		end
	end

	local results = pack(pcall(openCallback, wrappedCloseCallback))

	if not results[1] then
		closeTrackedOpen()
		error(results[2], 0)
	end

	finishTrackedOpen()

	return unpack(results, 2, results.n)
end

local function executeWithHiddenHud(componentContext)
	local ui = pg.global.ui
	local ownAdapterOpen = rawget(ui, "open")
	local adapterOpen = ui.open
	local commonUseConfirm = ui.commonUseConfirm
	local ownCommonUseConfirmOpen = commonUseConfirm and rawget(commonUseConfirm, "open")
	local commonUseConfirmOpen = commonUseConfirm and commonUseConfirm.open

	function ui.open(adapter, uid, info, callback, closeCallback, sceneParams)
		return invokeTrackedOpen(uid, closeCallback, function(trackedCloseCallback)
			return adapterOpen(adapter, uid, info, callback, trackedCloseCallback, sceneParams)
		end)
	end

	if commonUseConfirmOpen then
		function commonUseConfirm.open(ctrl, info, callback, closeCallback, sceneParams, onSceneLoadedCallback, forceNoBlack)
			return invokeTrackedOpen(ctrl.uid, closeCallback, function(trackedCloseCallback)
				return commonUseConfirmOpen(ctrl, info, callback, trackedCloseCallback, sceneParams, onSceneLoadedCallback, forceNoBlack)
			end)
		end
	end

	local results = pack(pcall(PropDetailComponent.onClickUseBtn, componentContext))

	ui.open = ownAdapterOpen

	if commonUseConfirmOpen then
		commonUseConfirm.open = ownCommonUseConfirmOpen
	end

	if not results[1] then
		error(results[2], 0)
	end

	return unpack(results, 2, results.n)
end

function PropDetailUseAction.execute(propData, context, options)
	local componentContext = createComponentContext(context)

	componentContext.propData = propData

	if options and options.hideHudOnOpenUI then
		return executeWithHiddenHud(componentContext)
	end

	return PropDetailComponent.onClickUseBtn(componentContext)
end

return PropDetailUseAction
