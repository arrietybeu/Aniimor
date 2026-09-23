-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SubComponents\\Retrospectable.lua

local Class = require("Core.Framework.Class")
local SubComponent = require("GameApp.Sandbox.SubComponents.SubComponent")
local Retrospectable = Class.LightClass("Retrospectable", SubComponent)

function Retrospectable:ctor(id, levelItem, info)
	Retrospectable.super.ctor(self, id, levelItem, info)
end

function Retrospectable:onRetrospectChanged(isAffected)
	if type(isAffected) ~= "boolean" then
		return
	end

	self:serverMsg("RPC_CS_SetAffected", isAffected)
end

return Retrospectable
