-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\ScaleOper.lua

local Class = require("Core.Framework.Class")
local EditorOperBase = require("GameApp.Home.HomeEdtorOper.EditorOperBase")
local EntityRecorder = require("GameApp.Home.HomeEdtorOper.EntityRecorder")
local ScaleOper = Class.LiteClass("ScaleOper", EditorOperBase)

function ScaleOper:ctor(editor)
	ScaleOper.super.ctor(self, editor)

	self.undoRecorder = EntityRecorder.new(editor)
	self.redoRecorder = EntityRecorder.new(editor)
end

function ScaleOper:recycle()
	ScaleOper.super.recycle(self)
	self.undoRecorder:clear()
	self.redoRecorder:clear()

	self.cacheScale = nil
	self.targetScale = nil
end

function ScaleOper:setOperTarget(operEntity)
	ScaleOper.super.setOperTarget(self, operEntity)
	self.undoRecorder:record(self.operEntity)

	if not self.cacheScale then
		local cached = self.editor:getCachedScale()

		if cached then
			self.cacheScale = {
				x = cached.x,
				y = cached.y,
				z = cached.z
			}
		end
	end
end

function ScaleOper:doScale(scaleXYZ)
	self.targetScale = {
		x = scaleXYZ.x,
		y = scaleXYZ.y,
		z = scaleXYZ.z
	}

	self.operEntity:setScale(Vector3(scaleXYZ.x, scaleXYZ.y, scaleXYZ.z))
	self.editor:onEntityScaleChanged(self.operEntity, true)
	self.redoRecorder:record(self.operEntity)
end

function ScaleOper:doOper()
	self.redoRecorder:restore(self.operEntity)
	self.editor:onEntityScaleChanged(self.operEntity)
	self.editor:setCachedScale(self.targetScale.x, self.targetScale.y, self.targetScale.z)
end

function ScaleOper:undoOper()
	self.undoRecorder:restore(self.operEntity)
	self.editor:onEntityScaleChanged(self.operEntity)
	self.editor:setCachedScale(self.cacheScale.x, self.cacheScale.y, self.cacheScale.z)
end

return ScaleOper
