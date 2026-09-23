-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PhotoRecordInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local PhotoRecordInfo = class.LiteClass("PhotoRecordInfo", CustomDict)

function PhotoRecordInfo:record(player, photoId)
	self.photoId = photoId
	self.uploadTime = Time.secondCache
	self.uploadScene = player.space and player.space.sceneId or 0
	self.uploadPos = {
		player:getPosition():Get()
	}
end

return PhotoRecordInfo
