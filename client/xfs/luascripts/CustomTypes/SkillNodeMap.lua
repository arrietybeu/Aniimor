-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\SkillNodeMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local SkillNodeMap = class.LiteClass("SkillNodeMap", CustomDict)

function SkillNodeMap:getSkillNodeLevel(nodeKey)
	return self[nodeKey] and self[nodeKey].lv or 0
end

return SkillNodeMap
