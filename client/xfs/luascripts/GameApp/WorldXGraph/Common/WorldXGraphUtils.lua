-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\WorldXGraphUtils.lua

local WorldXGraphUtils = {}

local function readComponent(value, key, index)
	if value == nil then
		return 0
	end

	return value[key] or value[index] or 0
end

local function getCsValue(path)
	local cs = rawget(_G, "CS")

	if cs == nil then
		return nil
	end

	local ok, value = pcall(path, cs)

	if ok then
		return value
	end

	return nil
end

local function tryCall(callable, ...)
	if callable == nil then
		return nil
	end

	local ok, value = pcall(callable, ...)

	if ok then
		return value
	end

	return nil
end

function WorldXGraphUtils.ToVector3(value, defaultValue)
	if value == nil then
		return defaultValue
	end

	if type(value) ~= "table" then
		return value
	end

	local x = readComponent(value, "x", 1)
	local y = readComponent(value, "y", 2)
	local z = readComponent(value, "z", 3)
	local vector3 = rawget(_G, "Vector3")
	local result = vector3 and vector3.New and tryCall(vector3.New, x, y, z) or nil

	result = result or tryCall(vector3, x, y, z)

	if result ~= nil then
		return result
	end

	local csVector3 = getCsValue(function(cs)
		return cs.UnityEngine.Vector3
	end)

	result = csVector3 and csVector3.New and tryCall(csVector3.New, x, y, z) or nil
	result = result or tryCall(csVector3, x, y, z)

	return result or value
end

function WorldXGraphUtils.ToQuaternionFromEuler(euler, defaultValue)
	if euler == nil then
		return defaultValue
	end

	if type(euler) ~= "table" then
		return euler
	end

	local x = readComponent(euler, "x", 1)
	local y = readComponent(euler, "y", 2)
	local z = readComponent(euler, "z", 3)
	local quaternion = rawget(_G, "Quaternion")
	local result = quaternion and quaternion.Euler and tryCall(quaternion.Euler, x, y, z) or nil

	if result ~= nil then
		return result
	end

	local csQuaternion = getCsValue(function(cs)
		return cs.UnityEngine.Quaternion
	end)

	result = csQuaternion and csQuaternion.Euler and tryCall(csQuaternion.Euler, x, y, z) or nil

	return result or euler
end

function WorldXGraphUtils.ToCameraBlendFunction(value, defaultValue)
	if value == nil then
		return defaultValue
	end

	if type(value) ~= "string" then
		return value
	end

	local enumType = getCsValue(function(cs)
		return cs.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
	end)

	if enumType ~= nil and enumType[value] ~= nil then
		return enumType[value]
	end

	enumType = rawget(_G, "VirtualCameraBlendFunction")

	if enumType ~= nil and enumType[value] ~= nil then
		return enumType[value]
	end

	return defaultValue or value
end

function WorldXGraphUtils.GetAppFacade()
	return rawget(_G, "appFacade")
end

return WorldXGraphUtils
