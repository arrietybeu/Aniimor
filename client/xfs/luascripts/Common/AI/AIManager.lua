-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\AIManager.lua

local Class = require("Core.Framework.Class")
local GroupBehaviorModule = require("Common.AI.GroupBehavior.GroupBehaviorModule")
local AITickModule = require("Common.AI.AITick.AITickModule2")
local ResPointModule = require("Common.AI.ResPoint.ResPointModule")
local AiConst = require("Common.Const.AiConst")
local BehaviorXConst = require("Common.Const.BehaviorXConst")
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local AIManager = Class.LiteClass("AIManager")

function AIManager:ctor(space)
	self.space = space
	self.groupBehaviorModule = GroupBehaviorModule.new()
	self.aiTickModule = AITickModule.new()
	self.resPointModule = ResPointModule.new()
end

function AIManager:init(createInfo)
	local sceneId = createInfo and createInfo.sceneId or 0

	self.resPointModule:init(self.space, sceneId)
end

function AIManager:tick(deltaTime)
	if AiConst.GLOBAL_OPEN_TICK then
		self.groupBehaviorModule:onTick()
		self.aiTickModule:onTick(deltaTime)
		self.resPointModule:onTick(deltaTime)
	end
end

function AIManager:destroy()
	self.space = nil

	if self.groupBehaviorModule then
		self.groupBehaviorModule:onDestroy()

		self.groupBehaviorModule = nil
	end

	if self.aiTickModule then
		self.aiTickModule:onDestroy()

		self.aiTickModule = nil
	end

	if self.resPointModule then
		self.resPointModule:onDestroy()

		self.resPointModule = nil
	end
end

function AIManager:createBehaviour(behavName, ...)
	return self.groupBehaviorModule:createBehaviour(behavName, ...)
end

function AIManager:destroyBehaviour(behaviour)
	self.groupBehaviorModule:destroyBehaviour(behaviour)
end

function AIManager:registerAgent(ent)
	self.aiTickModule:registerAgent(ent)
end

function AIManager:unregisterAgent(ent)
	self.aiTickModule:unregisterAgent(ent)
end

function AIManager:onChunkLoad(chunkKey)
	self.resPointModule:onChunkLoad(chunkKey)
end

function AIManager:onChunkUnload(chunkKey)
	self.resPointModule:onChunkUnload(chunkKey)
end

return AIManager
