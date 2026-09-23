-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\DeltaPositionOper.lua

local Class = require("Core.Framework.Class")
local EditorOperBase = require("GameApp.Home.HomeEdtorOper.EditorOperBase")
local DeltaPositionOper = Class.LiteClass("DeltaPositionOper", EditorOperBase)

function DeltaPositionOper:ctor(editor)
	DeltaPositionOper.super.ctor(self, editor)
end

function DeltaPositionOper:setOperTarget(operEntity)
	DeltaPositionOper.super.setOperTarget(self, operEntity)

	self.cachePosition = self.editor:getLocalPosition(self.operEntity:getPositionAgentPosition())
	self.targetPosition = self.cachePosition:Clone()
end

function DeltaPositionOper:recycle()
	DeltaPositionOper.super.recycle(self)

	self.cachePosition = nil
	self.targetPosition = nil
end

function DeltaPositionOper:doMoveDelta(deltaX, deltaY, deltaZ)
	self.targetPosition.x = self.cachePosition.x + deltaX
	self.targetPosition.y = self.cachePosition.y + deltaY
	self.targetPosition.z = self.cachePosition.z + deltaZ
	self.targetPosition = self.editor:clampLocalPosition(self.targetPosition)

	local worldPosition = self.editor:getWorldPosition(self.targetPosition)

	self.operEntity:setPosition(worldPosition)

	if self.operEntity.onEntityPositionChanged then
		self.operEntity:onEntityPositionChanged()
	end
end

function DeltaPositionOper:doOper()
	local worldPosition = self.editor:getWorldPosition(self.targetPosition)

	self.operEntity:setPosition(worldPosition)

	if self.operEntity.onEntityPositionChanged then
		self.operEntity:onEntityPositionChanged()
	end
end

function DeltaPositionOper:undoOper()
	local worldPosition = self.editor:getWorldPosition(self.cachePosition)

	self.operEntity:setPosition(worldPosition)

	if self.operEntity.onEntityPositionChanged then
		self.operEntity:onEntityPositionChanged()
	end
end

return DeltaPositionOper
