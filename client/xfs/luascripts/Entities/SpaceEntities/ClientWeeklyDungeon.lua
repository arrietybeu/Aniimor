-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientWeeklyDungeon.lua

local Class = require("Core.Framework.Class")
local ClientPveDungeon = require("Entities.SpaceEntities.ClientPveDungeon")
local ClientWeeklyDungeon = Class.Class("ClientWeeklyDungeon", ClientPveDungeon)

function ClientWeeklyDungeon:onResult(result)
	return
end

return ClientWeeklyDungeon
