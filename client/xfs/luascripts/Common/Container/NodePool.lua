-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\NodePool.lua

local Class = require("Core.Framework.Class")
local NodePool = Class.LightClass("NodePool")

function NodePool:ctor(maxCount)
	self.pool = {}
	self.maxCount = maxCount or 4096
end

function NodePool:get()
	local n = #self.pool

	if n > 0 then
		local node = self.pool[n]

		self.pool[n] = nil

		return node
	end

	return {}
end

function NodePool:release(node)
	if not node or #self.pool >= self.maxCount then
		return
	end

	node.value = nil
	node.prev = nil
	node.next = nil
	node._owner = nil
	self.pool[#self.pool + 1] = node
end

return NodePool
