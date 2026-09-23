-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\VectorPool.lua

local VectorPool = {}
local availableVector = {
	[2] = {},
	[3] = {},
	[4] = {}
}
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("VectorPool")
local rawset = rawset
local rawget = rawget
local Vector2 = Vector2
local Vector3 = Vector3
local Vector4 = Vector4
local _isInPool = 6

function VectorPool.getVector(vectorType, value)
	vectorType = vectorType or 3

	local availableVectorTypePool = availableVector[vectorType]
	local retVector

	if availableVectorTypePool and #availableVectorTypePool > 0 then
		retVector = availableVectorTypePool[#availableVectorTypePool]
		availableVectorTypePool[#availableVectorTypePool] = nil
	elseif vectorType == 2 then
		retVector = Vector2.New()
	elseif vectorType == 3 then
		retVector = Vector3.New()

		Vector3.removeTempVector3(retVector)
	elseif vectorType == 4 then
		retVector = Vector4.New()
	end

	if value then
		retVector:Copy(value)
	end

	rawset(retVector, _isInPool, nil)

	return retVector
end

function VectorPool.returnVector(tmpVector)
	if not tmpVector then
		return
	end

	if rawget(tmpVector, _isInPool) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("VectorPool.returnVector() vector already in pool")
		end

		return
	end

	if tmpVector.class == "Vector2" then
		availableVector[2][#availableVector[2] + 1] = tmpVector
	elseif tmpVector.class == "Vector3" then
		availableVector[3][#availableVector[3] + 1] = tmpVector
	elseif tmpVector.class == "Vector4" then
		availableVector[4][#availableVector[4] + 1] = tmpVector
	end

	rawset(tmpVector, _isInPool, true)
end

return VectorPool
