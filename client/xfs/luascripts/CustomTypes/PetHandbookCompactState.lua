-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetHandbookCompactState.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetHandbookCompactState = class.LiteClass("PetHandbookCompactState", CustomDict)

function PetHandbookCompactState:init(dict)
	local discarded = false

	if type(dict) ~= "table" then
		dict = {}
		discarded = true
	end

	if dict.traitState ~= nil and type(dict.traitState) ~= "table" then
		dict.traitState = {}
		discarded = true
	end

	if dict.levelRewardState ~= nil and type(dict.levelRewardState) ~= "table" then
		dict.levelRewardState = {}
		discarded = true
	end

	local evolveState = dict.evolveState

	if evolveState ~= nil then
		if type(evolveState) ~= "table" then
			dict.evolveState = {}
			discarded = true
		else
			dict.evolveState = {
				routeState = type(evolveState.routeState) == "table" and evolveState.routeState or {},
				normalState = type(evolveState.normalState) == "table" and evolveState.normalState or {},
				itemState = type(evolveState.itemState) == "table" and evolveState.itemState or {}
			}
		end
	end

	PetHandbookCompactState.super.init(self, dict)
end

return PetHandbookCompactState
