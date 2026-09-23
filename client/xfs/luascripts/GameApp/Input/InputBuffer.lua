-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\InputBuffer.lua

local Class = require("Core.Framework.Class")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local InputCommand = require("GameApp.Input.InputCommand")
local InputBuffer = Class.LightClass("InputBuffer")

function InputBuffer:ctor(ent)
	self.buffer = {}
	self.head = 1
	self.tail = 1
end

function InputBuffer:enqueue(command)
	if self:first() == command then
		return
	end

	if command == InputCommand.ThrowHold and self:first() ~= InputCommand.ThrowCancel then
		self:clear()
	end

	if command == InputCommand.MagnesisHold and self:first() ~= InputCommand.MagnesisCancel then
		self:clear()
	end

	if command == InputCommand.MagnesisCancel and self:first() == InputCommand.MagnesisRelease then
		return
	end

	self:_enqueue(command)
end

function InputBuffer:_enqueue(command)
	self.buffer[self.tail] = command
	self.tail = self.tail + 1
end

function InputBuffer:first()
	return self.buffer[self.head]
end

function InputBuffer:dequeue()
	self.buffer[self.head] = nil
	self.head = self.head + 1
end

function InputBuffer:dump()
	local str = ""

	for i = self.head, self.tail - 1 do
		str = str .. self.buffer[i] .. " "
	end

	return str
end

function InputBuffer:clear()
	self.buffer = {}
	self.head = 1
	self.tail = 1
end

return InputBuffer
