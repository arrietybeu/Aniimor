-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientSummonedComponent.lua

local class = require("Core.Framework.Class")
local LxGeometry = require("Common.Ability.LxGeometry")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientSummonedComponent = class.Component("ClientSummonedComponent")

function ClientSummonedComponent:init(dict)
	self.summonHostActorId = dict.summonHostActorId

	return true
end

function ClientSummonedComponent:isSummonedEntity()
	return self.summonHostActorId and self.summonHostActorId ~= 0
end

function ClientSummonedComponent:getSummonHost()
	return pg.getEntityByActorId(self.summonHostActorId)
end

return ClientSummonedComponent
