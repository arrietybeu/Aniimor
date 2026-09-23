-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopPoster\\ShopPosterModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ShopPosterModel = Class.LightClass("ShopPosterModel", UIModel)

function ShopPosterModel:getGroupImgData(imgUrls)
	local t = {}

	for i = 1, #imgUrls do
		t[#t + 1] = {
			url = imgUrls[i]
		}
	end

	return t
end

function ShopPosterModel:getGroupBottomIndexData(count)
	local t = {}

	for i = 1, count do
		t[#t + 1] = {}
	end

	return t
end

return ShopPosterModel
