-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\OSSPhotoRecordMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local OSSPhotoRecordMap = class.LiteClass("OSSPhotoRecordMap", CustomDict)

function OSSPhotoRecordMap:getInfo(key, upsert)
	if not self[key] and upsert and pg.component == "game" then
		self[key] = {}
	end

	return self[key]
end

return OSSPhotoRecordMap
