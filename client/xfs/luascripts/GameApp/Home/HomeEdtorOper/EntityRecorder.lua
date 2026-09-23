-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\EntityRecorder.lua

local Class = require("Core.Framework.Class")
local EntityRecorder = Class.LiteClass("EntityRecorder")

function EntityRecorder:ctor(editor)
	self.editor = editor
	self.cache = {
		position = Vector3.ForceNew(0, 0, 0),
		rotation = Quaternion.NewReadOnly(0, 0, 0, 1),
		scale = Vector3.ForceNew(1, 1, 1),
		buildExtraData = {}
	}
	self.hasRecord = false
	self.hasScale = false
end

function EntityRecorder:clear()
	self.hasRecord = false
	self.hasScale = false

	table.clear(self.cache.buildExtraData)
end

function EntityRecorder:record(entity)
	local position = entity:getPosition()

	self.cache.position:Copy(position)

	local rotation = entity:getRotation()

	self.cache.rotation:refreshReadOnly(rotation[1], rotation[2], rotation[3], rotation[4])

	self.hasScale = false

	if entity.getScale then
		local scale = entity:getScale()

		if scale then
			self.cache.scale:Copy(scale)

			self.hasScale = true
		end
	end

	table.clear(self.cache.buildExtraData)

	if self.editor.buildAttachManager then
		self.editor.buildAttachManager:recordEditorExtraData(self.cache.buildExtraData)
	end

	self.hasRecord = true
end

function EntityRecorder:restore(entity)
	if not self.hasRecord then
		return
	end

	entity:setPosition(self.cache.position)
	entity:setRotation(self.cache.rotation)

	if self.hasScale then
		entity:setScale(self.cache.scale)
	end

	if self.editor.buildAttachManager then
		self.editor.buildAttachManager:restoreEditorExtraData(self.cache.buildExtraData)
	end
end

return EntityRecorder
