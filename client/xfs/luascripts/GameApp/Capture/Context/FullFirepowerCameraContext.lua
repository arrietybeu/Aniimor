-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\FullFirepowerCameraContext.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local NoBallContext = require("GameApp.Capture.Context.NoBallContext")
local FullFirepowerCameraContext = Class.LightClass("FullFirepowerCameraContext", NoBallContext)

function FullFirepowerCameraContext:ctor(player)
	self.player = player
end

function FullFirepowerCameraContext:enter(fromContext)
	if self.player:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		self.player.eModel.AlwaysLookForward = true
	end

	self:enableCatchMode(true)
end

function FullFirepowerCameraContext:exit()
	return false
end

function FullFirepowerCameraContext:destroy()
	if self.player and self.player.eModel then
		self.player.eModel.AlwaysLookForward = false
	end

	self:enableCatchMode(false)

	self.player = nil
end

return FullFirepowerCameraContext
