-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CustomMapMarkMap.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("CustomMapMarkMap")
local CustomMapMarkMap = class.LiteClass("CustomMapMarkMap", CustomDict)

function CustomMapMarkMap:_getNextGenId()
	self.genId = self.genId + 1

	if self.genId > 4294967295 then
		self.genId = 1
	end

	return self.genId
end

local function _checkPosition(pos)
	if pos == nil then
		return false
	end

	if math.abs((pos[1] or 0) - 0) < 1e-06 and math.abs((pos[2] or 0) - 0) < 1e-06 and math.abs((pos[3] or 0) - 0) < 1e-06 then
		return false
	end

	return true
end

function CustomMapMarkMap:addMark(sceneId, markIconIndex, pos, name)
	if not _checkPosition(pos) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("invalid position", inspect(pos))
		end

		return
	end

	self[sceneId] = self[sceneId] or {}
	self[sceneId][self:_getNextGenId()] = {
		markIconIndex = markIconIndex,
		pos = pos,
		name = name
	}
end

function CustomMapMarkMap:delMark(sceneId, genId)
	local sceneMarkMap = self[sceneId]

	if sceneMarkMap == nil or sceneMarkMap[genId] == nil then
		return
	end

	sceneMarkMap[genId] = nil
end

function CustomMapMarkMap:updateMark(sceneId, genId, updateDict)
	if updateDict.pos and not _checkPosition(updateDict.pos) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("invalid position", inspect(updateDict.pos))
		end

		return
	end

	local sceneMarkMap = self[sceneId]

	if sceneMarkMap == nil or sceneMarkMap[genId] == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("invalid mark", sceneId, genId)
		end

		return
	end

	local dict = sceneMarkMap[genId]

	if updateDict.markIconIndex then
		dict.markIconIndex = updateDict.markIconIndex
	end

	if updateDict.pos then
		dict.pos = updateDict.pos
	end

	if updateDict.name then
		dict.name = updateDict.name
	end
end

function CustomMapMarkMap:clearMarks(sceneId)
	self[sceneId] = nil
end

return CustomMapMarkMap
