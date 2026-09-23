-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\BehaviorTreeFactory.lua

local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
local _M = {}
local common = require("Common.AI.Behaviac.Common")
local lib_loader = require("Common.AI.Behaviac.Parser.loader")
local Logging = common.d_log

_M.btCache = {}

function _M.preloadBehaviorTree(relativeTreePath)
	local NodeFactory = require("Common.AI.Behaviac.Parser.NodeFactory")
	local bt

	if _M.btCache[relativeTreePath] then
		bt = _M.btCache[relativeTreePath]
	else
		local treeData, fileType = lib_loader.load(relativeTreePath)

		if not treeData then
			Logging.error("[_M:preloadBehaviorTree()] load file(%s) failed!!!")

			return
		end

		local BehaviorTree = NodeFactory.BehaviorTree

		bt = BehaviorTree.new()

		bt:load(treeData, relativeTreePath)

		_M.btCache[relativeTreePath] = bt
	end

	return bt
end

function _M.clearCache(relativeTreePath)
	if relativeTreePath then
		_M.btCache[relativeTreePath] = false
	else
		_M.btCache = {}
	end
end

return _M
