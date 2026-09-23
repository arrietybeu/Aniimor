-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomePetRestSingleData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomePetRestSingleData = class.LiteClass("HomePetRestSingleData", CustomDict)

function HomePetRestSingleData:getRestPosition(space)
	if not space then
		return
	end

	local sceneId = space.sceneId
	local pos, rot = SceneUtils.getCommonBasicsPosition(sceneId, self.pos)

	return pos, rot
end

return HomePetRestSingleData
