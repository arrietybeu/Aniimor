-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollectionDetail\\GrabEggsCollectionDetailModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsCollectionDetailModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsCollectionDetailModel = Class.LightClass("GrabEggsCollectionDetailModel", UIModel)

function GrabEggsCollectionDetailModel:init(ctrl)
	UIModel.init(self, ctrl)
end

return GrabEggsCollectionDetailModel
