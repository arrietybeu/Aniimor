-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformNameMaskRefreshHelper.lua

local EventConst = require("Common.Const.EventConst")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformNameMaskRefreshHelper = {}

function PlatformNameMaskRefreshHelper.getEventEmitter()
	return pg and pg.global and pg.global.eventEmitter or nil
end

function PlatformNameMaskRefreshHelper.getRootGameObject(ctrl)
	if type(ctrl) ~= "table" then
		return nil
	end

	if ctrl.gameObject then
		return ctrl.gameObject
	end

	local view = ctrl.view

	if type(view) ~= "table" then
		return nil
	end

	if view.gameObject then
		return view.gameObject
	end

	if view.widget and view.widget.gameObject then
		return view.widget.gameObject
	end

	if view.root and view.root.gameObject then
		return view.root.gameObject
	end

	return nil
end

function PlatformNameMaskRefreshHelper.isUnityObjectNil(value)
	return type(isUnityNil) == "function" and isUnityNil(value)
end

function PlatformNameMaskRefreshHelper.isCtrlAlive(ctrl)
	if type(ctrl) ~= "table" then
		return false
	end

	if ctrl._destroyed == true or ctrl.destroyed == true or ctrl.isDestroy == true then
		return false
	end

	if ctrl.view == nil then
		return false
	end

	local gameObject = PlatformNameMaskRefreshHelper.getRootGameObject(ctrl)

	if gameObject ~= nil then
		if PlatformNameMaskRefreshHelper.isUnityObjectNil(gameObject) then
			return false
		end

		if gameObject.activeInHierarchy == false or gameObject.activeSelf == false then
			return false
		end
	end

	return true
end

function PlatformNameMaskRefreshHelper.register(ctrl, refreshFunc)
	if type(ctrl) ~= "table" or type(refreshFunc) ~= "function" then
		return false
	end

	local emitter = PlatformNameMaskRefreshHelper.getEventEmitter()

	if not emitter or type(emitter.addEventListener) ~= "function" then
		return false
	end

	PlatformNameMaskRefreshHelper.unregister(ctrl)

	local function listener(payload)
		if not PlatformNameMaskRefreshHelper.isCtrlAlive(ctrl) then
			PlatformNameMaskRefreshHelper.unregister(ctrl)

			return
		end

		local ok, err = xpcall(refreshFunc, debug.traceback, ctrl, payload or {})

		if not ok and logger and type(logger.error) == "function" then
			logger:error("PlatformNameMaskRefreshHelper refresh failed: %s", tostring(err))
		end
	end

	ctrl._platformNameMaskRefreshListener = listener

	emitter:addEventListener(EventConst.PLATFORM_NAME_MASK_POLICY_REFRESHED, listener)
	emitter:addEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, listener)

	return true
end

function PlatformNameMaskRefreshHelper.unregister(ctrl)
	if type(ctrl) ~= "table" then
		return false
	end

	local listener = rawget(ctrl, "_platformNameMaskRefreshListener")

	if not listener then
		return false
	end

	local emitter = PlatformNameMaskRefreshHelper.getEventEmitter()

	if emitter and type(emitter.removeEventListener) == "function" then
		emitter:removeEventListener(EventConst.PLATFORM_NAME_MASK_POLICY_REFRESHED, listener)
		emitter:removeEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, listener)
	end

	rawset(ctrl, "_platformNameMaskRefreshListener", nil)

	return true
end

return PlatformNameMaskRefreshHelper
