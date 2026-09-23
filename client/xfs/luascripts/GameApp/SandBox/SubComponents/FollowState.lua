-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SubComponents\\FollowState.lua

local Class = require("Core.Framework.Class")
local SubComponent = require("GameApp.Sandbox.SubComponents.SubComponent")
local FollowState = Class.LightClass("FollowState", SubComponent)

function FollowState:ctor(id, levelItem, info)
	FollowState.super.ctor(self, id, levelItem, info)
end

return FollowState
