-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\EntityTask.lua

local Class = require("Core.Framework.Class")
local EntityTask = Class.LiteClass("EntityTask")

function EntityTask:ctor(id, duration, func)
	self.id = id
	self.duration = duration
	self.func = func
end

return EntityTask
