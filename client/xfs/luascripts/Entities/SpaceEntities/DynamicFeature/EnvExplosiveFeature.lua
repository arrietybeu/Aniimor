-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\EnvExplosiveFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local EnvExplosiveFeature = Class.LiteClass("EnvExplosiveFeature", iFeature)

function EnvExplosiveFeature:ctor()
	EnvExplosiveFeature.super.ctor(self)
end

function EnvExplosiveFeature:init(master, data)
	EnvExplosiveFeature.super.init(self, master, data)
end

function EnvExplosiveFeature:destroy()
	EnvExplosiveFeature.super.destroy(self)
end

return EnvExplosiveFeature
