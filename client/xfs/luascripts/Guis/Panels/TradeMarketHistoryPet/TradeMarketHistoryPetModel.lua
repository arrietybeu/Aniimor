-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistoryPet\\TradeMarketHistoryPetModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryPetModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetData = require("Data.pet_data")
local TradeMarketHistoryPetModel = Class.LightClass("TradeMarketHistoryPetModel", UIModel)

function TradeMarketHistoryPetModel.getPetScaleAndOffset(petTemplateId)
	local petBaseData = PetData[petTemplateId] or {}
	local scale = petBaseData.scale or 1
	local offset = petBaseData.offset or Vector3.zero

	return scale, offset
end

return TradeMarketHistoryPetModel
