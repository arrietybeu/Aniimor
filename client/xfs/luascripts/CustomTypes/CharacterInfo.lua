-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CharacterInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local CharacterInfo = class.LiteClass("CharacterInfo", CustomDict)

function CharacterInfo:isCharacterActive(id)
	return lume.find(self.characterList, id)
end

return CharacterInfo
