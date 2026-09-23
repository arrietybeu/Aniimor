-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Agent\\Blackboard.lua

local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local Lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Behaviac")
local table_clear = table.clear
local Blackboard = Class.LightClass("Blackboard")
local _M = Blackboard

_M.cacheTreeMem = {}

function _M:ctor(agent)
	self.m_agent = agent
	self.m_baseMemory = {}
	self.m_treeMemory = {}
end

function _M:init()
	return
end

function _M:release()
	local treeScope, _ = next(self.m_treeMemory)

	while treeScope do
		self:clearTreeMemory(treeScope)

		treeScope, _ = next(self.m_treeMemory)
	end

	table_clear(self.m_baseMemory)
	table_clear(self.m_treeMemory)
end

function _M.s_getNodeMem(treeMem, nodeScope)
	local memory = treeMem
	local nodeId = nodeScope:getId()

	if memory[nodeId] == nil then
		memory[nodeId] = {}
	end

	return memory[nodeId]
end

function _M.s_setTreeNode(treeMem, key, value, nodeScope)
	local nodeMem = _M.s_getNodeMem(treeMem, nodeScope)

	nodeMem[key] = value
end

function _M.s_getTreeNode(treeMem, key, nodeScope)
	local nodeMem = _M.s_getNodeMem(treeMem, nodeScope)

	return nodeMem[key]
end

function _M:getTreeMemory(treeScope)
	if self.m_treeMemory[treeScope] then
		return self.m_treeMemory[treeScope]
	end

	local cacheTreeMemList = _M.cacheTreeMem[treeScope.m_relativeTreePath]
	local newTreeMem

	if cacheTreeMemList and #cacheTreeMemList > 1 then
		newTreeMem = cacheTreeMemList[#cacheTreeMemList]
		cacheTreeMemList[#cacheTreeMemList] = nil
	else
		newTreeMem = {}
	end

	self.m_treeMemory[treeScope] = newTreeMem

	return newTreeMem
end

function _M:clearTreeMemory(treeScope)
	local treeMemoryMap = self.m_treeMemory[treeScope]

	if treeMemoryMap then
		self.m_treeMemory[treeScope] = nil

		for _, nodeMem in pairs(treeMemoryMap) do
			table_clear(nodeMem)
		end

		local relativeTreePath = treeScope.m_relativeTreePath

		if not relativeTreePath then
			return
		end

		if not _M.cacheTreeMem[treeScope.m_relativeTreePath] then
			_M.cacheTreeMem[treeScope.m_relativeTreePath] = {}
		end

		local cacheTreeMemList = _M.cacheTreeMem[treeScope.m_relativeTreePath]

		cacheTreeMemList[#cacheTreeMemList + 1] = treeMemoryMap
	end
end

function _M:getMemory(treeScope, nodeScope)
	local memory = self.m_baseMemory

	if treeScope then
		local treeMem = self:getTreeMemory(treeScope)

		memory = treeMem

		if nodeScope then
			local nodeMem = _M.s_getNodeMem(treeMem, nodeScope)

			memory = nodeMem
		end
	end

	return memory
end

function _M:set(key, value, treeScope, nodeScope)
	local mem = self:getMemory(treeScope, nodeScope)

	mem[key] = value
end

function _M:get(key, treeScope, nodeScope)
	local mem = self:getMemory(treeScope, nodeScope)

	return mem[key]
end

return _M
