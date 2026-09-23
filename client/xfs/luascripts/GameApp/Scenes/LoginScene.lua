-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\LoginScene.lua

local UIConst = require("Const.UIConst")
local BaseScene = require("GameApp.Scenes.BaseScene")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local logger = LoggerManager.getLogger("LoginScene")
local EventConst = require("Const.EventConst")
local LoginScene = Class.LightClass("LoginScene", BaseScene)

function LoginScene:onStart()
	pg.global.eventEmitter:emit(EventConst.GAMEFLOW_CHANGE, "null", "EnterLogin", {})
	BaseScene.onStart(self)
	self:openLoginUI()

	if pg.game.audio then
		pg.game.audio:playBgm("BGM_Login", AudioConst.BgmPriority.Login)
	end
end

function LoginScene:onDestroy()
	pg.global.ui:close(UIConst.UI_ID_LOGIN)
	pg.global.ui:close(UIConst.UI_ID_CREATE_PLAYER_PANEL)
	pg.global.ui:close(UIConst.UI_ID_AVATAR_PREVIEW)
	pg.global.ui:close(UIConst.UI_ID_AVATAR_MAIN)
	pg.global.ui:close(UIConst.UI_ID_CREATE_ROLE_TIMELINE)
	pg.global.ui:close(UIConst.UI_ID_AVATAR)
	pg.game.uiScene:switchOutScene(UISceneConst.AVATAR_SCENE)
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Login)
end

function LoginScene:openLoginUI()
	local ok, err = xpcall(function()
		pg.global.ui:closeAllUIPanel({
			[UIConst.UI_ID_TIPS] = true,
			[UIConst.UI_ID_TOPLOGO] = true
		})
		pg.global.ui:openWithHide(UIConst.UI_ID_CREATE_ROLE_TIMELINE)
		pg.global.ui:open(UIConst.UI_ID_TIPS)
		pg.global.ui:open(UIConst.UI_ID_LOGIN, nil, function()
			if pg.game.input.hotKeyInited ~= true then
				pg.game.input:initHotkeys()
			end
		end)
	end, debug.traceback)

	if not ok then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("open login ui failed: %s", tostring(err))
		end

		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("STARTUP_LOGIN_UI_FAILED"), function()
			return
		end, true)
	end
end

function LoginScene:onReset(oldSceneId, newSceneId)
	self:openLoginUI()
end

return LoginScene
