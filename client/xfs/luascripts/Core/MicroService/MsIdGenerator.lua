-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\MsIdGenerator.lua

local class = require("Core.Framework.Class")
local MsIdGenerator = class.Class("MsIdGenerator")

function MsIdGenerator:ctor()
	self.id = 0
end

function MsIdGenerator:next()
	self.id = self.id + 1

	if self.id > 4294967295 then
		self.id = 1
	end

	return self.id
end

return MsIdGenerator
