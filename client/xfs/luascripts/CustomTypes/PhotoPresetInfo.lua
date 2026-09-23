-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PhotoPresetInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local PhotoOfficialPresetData = require("Data.photo_official_preset_data")
local time2Str = TimeUtils.timeStampToUtcString
local PhotoPresetInfo = class.LiteClass("PhotoPresetInfo", CustomDict)

function PhotoPresetInfo:isLiked(presetId)
	return self.likedIdMap[presetId] ~= nil
end

function PhotoPresetInfo:dump()
	local res = {}
	local official = {}

	for id, _ in pairs(PhotoOfficialPresetData) do
		local presetId = Utils.genPhotoPresetUniqueId(true, id)

		official[#official + 1] = {
			presetId,
			self:isLiked(presetId)
		}
	end

	res.official = lume.sort(official, function(a, b)
		return a[1] < b[1]
	end)
	res.hot = {}

	local liked = {}

	for presetId, ts in pairs(self.likedIdMap) do
		liked[#liked + 1] = {
			presetId,
			time2Str(ts)
		}
	end

	res.liked = lume.sort(liked, function(a, b)
		return a[2] < b[2]
	end)

	local saved = {}

	for presetId, ts in pairs(self.savedIdMap) do
		saved[#saved + 1] = {
			presetId,
			time2Str(ts)
		}
	end

	res.saved = lume.sort(saved, function(a, b)
		return a[2] < b[2]
	end)

	return res
end

return PhotoPresetInfo
