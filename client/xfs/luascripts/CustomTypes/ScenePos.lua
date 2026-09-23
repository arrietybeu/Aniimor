-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ScenePos.lua

local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local ScenePos = class.LiteClass("ScenePos", CustomList)

function ScenePos:updateByPosAndRot(pos, rot)
	for i = #self + 1, 4 do
		self:insert(i, 0)
	end

	self[1] = pos.x
	self[2] = pos.y
	self[3] = pos.z
	self[4] = rot:ToYaw()
end

function ScenePos:toPosAndRot()
	local pos = Vector3.New(self[1] or 0, self[2] or 0, self[3] or 0)
	local rot = Quaternion.Euler(0, self[4] or 0, 0)

	return pos, rot
end

return ScenePos
