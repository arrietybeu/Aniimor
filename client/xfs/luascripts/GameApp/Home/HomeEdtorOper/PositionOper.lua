-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\PositionOper.lua

local Class = require("Core.Framework.Class")
local EditorOperBase = require("GameApp.Home.HomeEdtorOper.EditorOperBase")
local EntityRecorder = require("GameApp.Home.HomeEdtorOper.EntityRecorder")
local PositionOper = Class.LiteClass("PositionOper", EditorOperBase)

function PositionOper:ctor(editor)
	PositionOper.super.ctor(self, editor)

	self.undoRecorder = EntityRecorder.new(editor)
	self.redoRecorder = EntityRecorder.new(editor)
end

function PositionOper:recycle()
	PositionOper.super.recycle(self)
	self.undoRecorder:clear()
	self.redoRecorder:clear()

	self.targetPosition = nil
	self.gridAdsorptionOrigin = nil
end

function PositionOper:setOperTarget(operEntity)
	PositionOper.super.setOperTarget(self, operEntity)
	self.undoRecorder:record(self.operEntity)

	self.gridAdsorptionOrigin = nil

	if self.operEntity.useRelativeGridAdsorption and self.operEntity:useRelativeGridAdsorption() then
		local originPosition = self.editor:getLocalPosition(self.operEntity:getPosition())

		self.gridAdsorptionOrigin = originPosition:Clone()
	end
end

function PositionOper:doMove(targetPosition)
	local targetLocalPosition = self.editor:getLocalPosition(targetPosition)

	self.targetPosition = self.editor:clampLocalPosition(targetLocalPosition, self.gridAdsorptionOrigin)

	local worldPosition = self.editor:getWorldPosition(self.targetPosition)

	self.operEntity:setPosition(worldPosition)
	self.editor:onEntityPositionChanged(self.operEntity, true)
	self.redoRecorder:record(self.operEntity)
end

function PositionOper:doOper()
	self.redoRecorder:restore(self.operEntity)
	self.editor:onEntityPositionChanged(self.operEntity)
end

function PositionOper:undoOper()
	self.undoRecorder:restore(self.operEntity)
	self.editor:onEntityPositionChanged(self.operEntity)
end

return PositionOper
