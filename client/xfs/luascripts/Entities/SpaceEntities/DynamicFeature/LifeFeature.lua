-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\LifeFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local LifeFeature = Class.LiteClass("LifeFeature", iFeature)

function LifeFeature:ctor()
	LifeFeature.super.ctor(self)
end

function LifeFeature:init(master, data)
	LifeFeature.super.init(self, master, data)
end

function LifeFeature:destroy()
	LifeFeature.super.destroy(self)
end

function LifeFeature:on_lifeBoolTest_changed(oldv, newv)
	return
end

return LifeFeature
