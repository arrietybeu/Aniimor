-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\EditorOperBase.lua

local Class = require("Core.Framework.Class")
local EditorOperBase = Class.LiteClass("EditorOperBase")

function EditorOperBase:ctor(editor)
	self.editor = editor
end

function EditorOperBase:recycle()
	self.operEntity = nil
end

function EditorOperBase:setOperTarget(operEntity)
	self.operEntity = operEntity
end

function EditorOperBase:doOper()
	return
end

function EditorOperBase:undoOper()
	return
end

return EditorOperBase
