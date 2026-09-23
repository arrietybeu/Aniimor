-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEdtorOper\\ExtendOper.lua

local Class = require("Core.Framework.Class")
local EditorOperBase = require("GameApp.Home.HomeEdtorOper.EditorOperBase")
local ExtendOper = Class.LiteClass("ExtendOper", EditorOperBase)

function ExtendOper:ctor(editor)
	ExtendOper.super.ctor(self, editor)
end

function ExtendOper:recycle()
	ExtendOper.super.recycle(self)

	self.cacheExtend = nil
	self.targetExtend = nil
end

function ExtendOper:setOperTarget(operEntity)
	ExtendOper.super.setOperTarget(self, operEntity)

	if not self.targetExtend then
		self.targetExtend = self.operEntity:getGroupExtend()
	end
end

function ExtendOper:setExtend(extend)
	if not self.cacheExtend then
		self.cacheExtend = self.operEntity:getGroupExtend()
	end

	self.targetExtend = extend

	self.operEntity:setGroupExtend(self.targetExtend)
	self.editor:onEntityGroupExtendChanged(self.operEntity, true)
end

function ExtendOper:doOper()
	self.operEntity:setGroupExtend(self.targetExtend)
	self.editor:onEntityGroupExtendChanged(self.operEntity)
end

function ExtendOper:undoOper()
	self.operEntity:setGroupExtend(self.cacheExtend)
	self.editor:onEntityGroupExtendChanged(self.operEntity)
end

return ExtendOper
