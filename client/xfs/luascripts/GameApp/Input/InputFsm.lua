-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\InputFsm.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local InputCommand = require("GameApp.Input.InputCommand")
local InputFsm = Class.LightClass("InputFsm")
local Queue = require("Core.Framework.Queue")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("InputFsm")

function InputFsm:ctor(fsm)
	self.start = fsm.start
	self.rule = fsm.rules
	self.state = self.start
	self.commandQueue = Queue(100)
end

function InputFsm:addCommand(command)
	if self.commandQueue:getLast() == command then
		return
	end

	if self.commandQueue:isFull() then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("InputFsm queue full, force clear to recover", debug.traceback())
		end

		self:clear()
	end

	self.commandQueue:enQueue(command)
end

function InputFsm:read()
	if self.commandQueue:isEmpty() then
		self.state = self.start
	end

	while not self.commandQueue:isEmpty() do
		local command = self.commandQueue:deQueue()
		local newState = self.rule[self.state][command]

		if newState then
			self.state = newState
		else
			self.state = self.start

			local startNewState = self.rule[self.state][command]

			if startNewState then
				self.state = startNewState

				break
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("Error: Input Fsm 卡住了")
			end
		end
	end

	return self.state
end

function InputFsm:reset()
	self.state = self.start
end

function InputFsm:clear()
	self.state = self.start

	self.commandQueue:clear()
end

return InputFsm
