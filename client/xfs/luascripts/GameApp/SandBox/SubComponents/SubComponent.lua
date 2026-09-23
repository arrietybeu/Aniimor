-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SubComponents\\SubComponent.lua

local Class = require("Core.Framework.Class")
local SubComponent = Class.LightClass("SubComponent")

function SubComponent:ctor(id, levelItem, info)
	self.id = id
	self.levelItem = levelItem
	self.info = info
end

function SubComponent:serverMsg(name, ...)
	self.levelItem:subCompServerMsg(self.id, name, ...)
end

return SubComponent
