-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\GroupBehaviorModule.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local GroupBehaviorModule = Class.LightClass("GroupBehaviorModule")

function GroupBehaviorModule:ctor()
	self.behaviourClass = {}
	self.behaviours = {}
	self.isInTick = false
	self.toRemoveBehaviours = {}
end

function GroupBehaviorModule:onTick()
	self.isInTick = true

	for behaviour, _ in pairs(self.behaviours) do
		behaviour:update()
	end

	self.isInTick = false

	for _, behaviour in ipairs(self.toRemoveBehaviours) do
		self:_innerDestroyBehaviour(behaviour)
	end

	table.clearArray(self.toRemoveBehaviours)
end

function GroupBehaviorModule:onDestroy()
	for behaviour, _ in pairs(self.behaviours) do
		behaviour:destroy()
	end
end

function GroupBehaviorModule:_getClassByType(type)
	local cls = self.behaviourClass[type]

	if cls == nil then
		local clsPath = "Common.AI.GroupBehavior." .. GroupBehaviourConst.BehaviourClassPath[type]

		cls = require(clsPath)
		self.behaviourClass[type] = cls
	end

	return cls
end

function GroupBehaviorModule:createBehaviour(behavName, ...)
	local behavType = GroupBehaviourConst.BehaviourType[behavName]

	behavType = behavType or GroupBehaviourConst.BehaviourType.Custom

	return self:_createBehaviourByType(behavType, behavName, ...)
end

function GroupBehaviorModule:_createBehaviourByType(behavType, behavName, ...)
	local cls = self:_getClassByType(behavType)
	local behaviour = cls.new(behavType, behavName)

	self.behaviours[behaviour] = true

	behaviour:init(...)

	return behaviour
end

function GroupBehaviorModule:destroyBehaviour(behaviour)
	if self.isInTick then
		self.toRemoveBehaviours[#self.toRemoveBehaviours + 1] = behaviour
	else
		self:_innerDestroyBehaviour(behaviour)
	end
end

function GroupBehaviorModule:_innerDestroyBehaviour(behaviour)
	if not behaviour then
		return
	end

	behaviour:destroy()

	self.behaviours[behaviour] = nil
end

return GroupBehaviorModule
