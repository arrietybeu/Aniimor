-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\EntityEditorHistory.lua

local Class = require("Core.Framework.Class")
local EntityEditorHistory = Class.LiteClass("EntityEditorHistory")
local MAX_RECORD = 30

function EntityEditorHistory:ctor(maxRecord)
	self.historyOper = {}
	self.operIndex = 0
	self.maxRecord = maxRecord or MAX_RECORD
end

function EntityEditorHistory:push(oper)
	for i = self.operIndex + 2, #self.historyOper do
		self.historyOper[i] = nil
	end

	self.historyOper[self.operIndex + 1] = oper
	self.operIndex = self.operIndex + 1

	if self.operIndex > self.maxRecord then
		self:adjustHistory()
	end
end

function EntityEditorHistory:undo()
	if not self:canUndo() then
		return
	end

	local oper = self.historyOper[self.operIndex]

	self.operIndex = self.operIndex - 1

	oper:undoOper()
end

function EntityEditorHistory:redo()
	if not self:canRedo() then
		return
	end

	self.operIndex = self.operIndex + 1

	local oper = self.historyOper[self.operIndex]

	oper:doOper()
end

function EntityEditorHistory:canUndo()
	return self.operIndex > 0
end

function EntityEditorHistory:canRedo()
	return self.operIndex < #self.historyOper
end

function EntityEditorHistory:adjustHistory()
	for i = 1, self.operIndex - 1 do
		self.historyOper[i] = self.historyOper[i + 1]
	end

	self.historyOper[self.operIndex] = nil
	self.operIndex = self.operIndex - 1
end

function EntityEditorHistory:undoAll()
	for i = self.operIndex, 1, -1 do
		self.historyOper[i]:undoOper()
	end

	self.operIndex = 0
end

function EntityEditorHistory:clearHistory()
	self.historyOper = {}
	self.operIndex = 0
end

return EntityEditorHistory
