-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopARK\\ShopARKModel.lua

local Class = require("Core.Framework.Class")
local ShopBaseModel = require("Guis.Panels.Shop.ShopBaseModel")
local ShopARKModel = Class.LightClass("ShopARKModel", ShopBaseModel)

function ShopARKModel:isLocateShopTagValid(shopTags, locateShopTag)
	return table.contains(shopTags, locateShopTag)
end

return ShopARKModel
