-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\FocusFrameUIComponent.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local InputCommand = require("GameApp.Input.InputCommand")
local FocusFrameUIComponent = Class.LightClass("FocusFrameUIComponent", HudBaseComponent)

FocusFrameUIComponent.messages = {
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	}
}

function FocusFrameUIComponent:findObjects()
	return
end

function FocusFrameUIComponent:initView()
	LuaUIUtils.setUIViewVisible(self.transform.gameObject, false)
end

function FocusFrameUIComponent:onTeammateViewChange()
	LuaUIUtils.setUIViewVisible(self.transform.gameObject, pg.me.inTeammateView)
end

return FocusFrameUIComponent
