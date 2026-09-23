-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsPrepRoom\\Component\\GrabEggTeamSceneComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrabEggTeamSceneComponent = Class.LightClass("GrabEggTeamSceneComponent", UIComponent)

function GrabEggTeamSceneComponent:initView()
	self.uiScene = self.ctrl.uiScene
end

function GrabEggTeamSceneComponent:showPlayer()
	return
end

return GrabEggTeamSceneComponent
