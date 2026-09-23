-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\AttributeSnapshot.lua

local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local AttributeSnapshot = Class.LiteClass("AttributeSnapshot")

function AttributeSnapshot:ctor()
	self.attrs = {}
end

function AttributeSnapshot:init(owner)
	for i = 1, AttributeConst.GROUP_BASE_SINGLE_PROCESS_BEGIN - 1 do
		self.attrs[i] = owner.actorCombatAttribute:getAttribValue(i)
	end

	self.lvModifyCache = nil

	local ownerLvModifyCache = owner.actorCombatAttribute.lvModifyCache

	if ownerLvModifyCache then
		self.lvModifyCache = {}

		for level, cache in pairs(ownerLvModifyCache) do
			self.lvModifyCache[level] = {}

			for key, value in pairs(cache) do
				self.lvModifyCache[level][key] = value
			end
		end
	end
end

function AttributeSnapshot:getAttribValue(id)
	return self.attrs[id]
end

function AttributeSnapshot:getRawAttribValue(id)
	return self.attrs[id]
end

return AttributeSnapshot
