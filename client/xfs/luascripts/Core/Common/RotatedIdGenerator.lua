-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\RotatedIdGenerator.lua

local class = require("Core.Framework.Class")
local RotatedIdGenerator = class.Class("RotatedIdGenerator")

function RotatedIdGenerator:ctor()
	self.id = 0
	self.maxId = 1048576
end

function RotatedIdGenerator:genID()
	self.id = self.id + 1

	if self.id == self.maxId then
		self.id = 1
	end

	return self.id
end

return RotatedIdGenerator
