-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\EnvElectricFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local EnvElectricFeature = Class.LiteClass("EnvElectricFeature", iFeature)

function EnvElectricFeature:ctor()
	EnvElectricFeature.super.ctor(self)
end

function EnvElectricFeature:init(master, data)
	EnvElectricFeature.super.init(self, master, data)
end

function EnvElectricFeature:destroy()
	EnvElectricFeature.super.destroy(self)
end

return EnvElectricFeature
