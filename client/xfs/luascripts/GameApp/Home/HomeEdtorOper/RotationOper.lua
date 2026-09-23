-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\RotationOper.lua

local Class = require("Core.Framework.Class")
local EditorOperBase = require("GameApp.Home.HomeEdtorOper.EditorOperBase")
local EntityRecorder = require("GameApp.Home.HomeEdtorOper.EntityRecorder")
local RotationOper = Class.LiteClass("RotationOper", EditorOperBase)

function RotationOper:ctor(editor)
	RotationOper.super.ctor(self, editor)

	self.undoRecorder = EntityRecorder.new(editor)
	self.redoRecorder = EntityRecorder.new(editor)
end

function RotationOper:recycle()
	RotationOper.super.recycle(self)
	self.undoRecorder:clear()
	self.redoRecorder:clear()

	self.cacheRotation = nil
	self.targetRotation = nil
end

function RotationOper:setOperTarget(operEntity)
	RotationOper.super.setOperTarget(self, operEntity)
	self.undoRecorder:record(self.operEntity)

	if not self.cacheRotation then
		local cached = self.editor:getCachedEulerAngles()

		if cached then
			self.cacheRotation = {
				x = cached.x,
				y = cached.y,
				z = cached.z
			}
		end
	end
end

function RotationOper:doRotate(rotation)
	self.targetRotation = self.targetRotation or {}
	self.targetRotation.x = rotation.x
	self.targetRotation.y = rotation.y
	self.targetRotation.z = rotation.z

	Vector3.enableCreateFromCache()

	local quaternion = Quaternion.Euler(rotation.x, rotation.y, rotation.z)
	local worldRotation = self.editor:getWorldRotation(quaternion)

	self.operEntity:setRotation(worldRotation)
	Vector3.disableCreateFromCache()
	self.editor:onEntityRotationChanged(self.operEntity, true)
	self.redoRecorder:record(self.operEntity)
end

function RotationOper:doOper()
	self.redoRecorder:restore(self.operEntity)
	self.editor:setCachedEulerAngles(self.targetRotation.x, self.targetRotation.y, self.targetRotation.z)
	self.editor:onEntityRotationChanged(self.operEntity)
end

function RotationOper:undoOper()
	self.undoRecorder:restore(self.operEntity)
	self.editor:setCachedEulerAngles(self.cacheRotation.x, self.cacheRotation.y, self.cacheRotation.z)
	self.editor:onEntityRotationChanged(self.operEntity)
end

return RotationOper
