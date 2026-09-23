-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\EnvIceFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local EnvIceFeature = Class.LiteClass("EnvIceFeature", iFeature)

function EnvIceFeature:ctor()
	EnvIceFeature.super.ctor(self)
end

function EnvIceFeature:init(master, data)
	EnvIceFeature.super.init(self, master, data)
end

function EnvIceFeature:destroy()
	EnvIceFeature.super.destroy(self)
end

function EnvIceFeature:FM_SC_TestIceFeature(arg1, arg2, arg3)
	return
end

return EnvIceFeature
