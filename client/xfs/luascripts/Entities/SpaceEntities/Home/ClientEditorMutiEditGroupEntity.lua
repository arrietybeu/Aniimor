-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientEditorMutiEditGroupEntity.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local ClientEditorTemplateGroupEntity = require("Entities.SpaceEntities.Home.ClientEditorTemplateGroupEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientEditorMutiEditGroupEntity = Class.Class("ClientEditorMutiEditGroupEntity", ClientEditorTemplateGroupEntity)

function ClientEditorMutiEditGroupEntity:ctor(entityId)
	ClientEditorMutiEditGroupEntity.super.ctor(self, entityId)

	self.selectedEntityDict = {}
end

function ClientEditorMutiEditGroupEntity:destroy()
	table.clear(self.selectedEntityDict)
	ClientEditorMutiEditGroupEntity.super.destroy(self)
end

function ClientEditorMutiEditGroupEntity:useRelativeGridAdsorption()
	return true
end

function ClientEditorMutiEditGroupEntity:addExistChildEntity(targetEntity, isMainEntity)
	if self.selectedEntityDict[targetEntity.id] then
		return
	end

	local childEntity = self.editor:createTemplateObjectByTarget(targetEntity)

	self.selectedEntityDict[targetEntity.id] = childEntity

	self:addChildEntity(childEntity, nil, nil, isMainEntity)
end

function ClientEditorMutiEditGroupEntity:removeExitChildEntity(targetEntity)
	if not self.selectedEntityDict[targetEntity.id] then
		return
	end

	local childEntity = self.selectedEntityDict[targetEntity.id]

	self:removeChildEntity(childEntity)

	self.selectedEntityDict[targetEntity.id] = nil

	ClientUtils.safeDestroy(childEntity)
end

return ClientEditorMutiEditGroupEntity
