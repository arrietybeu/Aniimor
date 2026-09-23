-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\BehaviorXUtils.lua

local BehaviorXConst = require("Common.Const.BehaviorXConst")
local BehaviorXUtils = {}

BehaviorXUtils.cacheConstTable = {}
BehaviorXUtils.cacheSubtreeLocalValueTable = {
	localValue = {}
}

function BehaviorXUtils.addCXXConstTable(key, value)
	BehaviorXUtils.cacheConstTable[key] = value

	return value
end

function BehaviorXUtils.existCXXConstTable(key)
	return BehaviorXUtils.cacheConstTable[key] ~= nil
end

function BehaviorXUtils.getCXXConstTable(key)
	return BehaviorXUtils.cacheConstTable[key]
end

function BehaviorXUtils.clearAllCXXConstTable()
	table.clear(BehaviorXUtils.cacheConstTable)
end

function BehaviorXUtils.getLuaAgentByActorId(actorId)
	local ent = pg.getEntityByActorId(actorId)

	return ent and ent.agent
end

function BehaviorXUtils.addCXXSubTreeLocalValue(treePathName, key, value)
	BehaviorXUtils.cacheSubtreeLocalValueTable.treePathName = treePathName
	BehaviorXUtils.cacheSubtreeLocalValueTable.localValue[key] = value
end

function BehaviorXUtils.getCXXSubTreeLocalValue(treePathName, key)
	if BehaviorXUtils.cacheSubtreeLocalValueTable.treePathName == treePathName then
		return BehaviorXUtils.cacheSubtreeLocalValueTable.localValue[key]
	end

	return nil
end

function BehaviorXUtils.clearAllCXXSubTreeLocalValue(treePathName)
	if BehaviorXUtils.cacheSubtreeLocalValueTable.treePathName == treePathName then
		table.clear(BehaviorXUtils.cacheSubtreeLocalValueTable.localValue)

		BehaviorXUtils.cacheSubtreeLocalValueTable.treePathName = nil

		return
	end
end

return BehaviorXUtils
