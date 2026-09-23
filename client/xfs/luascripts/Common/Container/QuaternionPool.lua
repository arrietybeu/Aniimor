-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\QuaternionPool.lua

local QuaternionPool = {}
local availableQuaternion = {}
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("QuaternionPool")
local _isInPool = 6

function QuaternionPool.getQuaternion(value)
	local retQuaternion

	if #availableQuaternion > 0 then
		retQuaternion = availableQuaternion[#availableQuaternion]
		availableQuaternion[#availableQuaternion] = nil
	else
		retQuaternion = Quaternion.New(0, 0, 0, 0)

		Quaternion.removeTempQuaterion(retQuaternion)
	end

	if value then
		Quaternion.Copy(retQuaternion, value)
	end

	rawset(retQuaternion, _isInPool, nil)

	return retQuaternion
end

function QuaternionPool.returnQuaternion(value)
	if not value then
		return
	end

	if rawget(value, _isInPool) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("QuaternionPool.returnQuaternion() Quaternion already in pool")
		end

		return
	end

	availableQuaternion[#availableQuaternion + 1] = value

	rawset(value, _isInPool, true)
end

return QuaternionPool
