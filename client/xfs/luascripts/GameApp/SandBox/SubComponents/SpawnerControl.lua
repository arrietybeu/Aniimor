-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SubComponents\\SpawnerControl.lua

local Class = require("Core.Framework.Class")
local SubComponent = require("GameApp.Sandbox.SubComponents.SubComponent")
local SpawnerControl = Class.LightClass("SpawnerControl", SubComponent)

function SpawnerControl:ctor(id, levelItem, info)
	SpawnerControl.super.ctor(self, id, levelItem, info)
end

function SpawnerControl:RPC_SC_SpawnerEntityCreate()
	local comp = self.levelItem.shell:GetComponentById(self.id)

	if comp and comp.OnSpawn then
		comp:OnSpawn()
	end
end

return SpawnerControl
