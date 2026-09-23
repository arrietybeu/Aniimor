-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Math\\luaQuaternion.lua

local Vector3 = Vector3
local Quaternion = LuaQuaternion

Quaternion.class = "Quaternion"
Quaternion.className = "Quaternion"
Quaternion.banInspect = true

function Quaternion:__tostring()
	local x = self.x or "nil"
	local y = self.y or "nil"
	local z = self.z or "nil"
	local w = self.w or "nil"
	local eulerStr = ""

	if self.x and self.y and self.z and self.w then
		local eulerAngles = self:ToEulerAngles()

		eulerStr = string.format(" EulerAngles [%f, %f, %f]", eulerAngles.x, eulerAngles.y, eulerAngles.z)
	end

	local ret = string.format("Quaternion [%s, %s, %s, %s]", x, y, z, w)

	return ret .. eulerStr
end

setmetatable(Quaternion, Quaternion)

return Quaternion
