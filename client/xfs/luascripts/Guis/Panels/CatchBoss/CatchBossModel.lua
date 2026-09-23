-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchBoss\\CatchBossModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchBossModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local Utils = require("Common.Utils.Utils")
local castItemData = require("Data.cast_item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local lume = require("Core.Common.lume")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local CatchBossModel = Class.LightClass("CatchBossModel", UIModel)
local BEST_BALL_ID = 110003

function CatchBossModel:getBossCapturePropInfos(bossEntity)
	local hasBestBall = ClientUtils.getItemCountById(BEST_BALL_ID) > 0
	local propList = {}
	local bContext = CatchProbContext.clientGet(bossEntity, BEST_BALL_ID)
	local bestBallInfo = {
		itemId = BEST_BALL_ID,
		icon = ItemData[BEST_BALL_ID].icon,
		name = ItemData[BEST_BALL_ID].itemName,
		count = ClientUtils.getItemCountById(BEST_BALL_ID),
		prob = bContext.finalProb
	}

	table.insert(propList, bestBallInfo)

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, ItemConst.INV_TYPE_BALL) or {}

	for _, packSlot in bag:items() do
		local item = LuaUIUtils.getItemClientInfoById(packSlot.id)
		local itemId = item.itemId

		if itemId ~= 0 and itemId ~= BEST_BALL_ID and ItemData[itemId] and ClientCaptureUtils.checkBallCanThrow(itemId) then
			local count = ClientUtils.getItemCountById(itemId)
			local context = CatchProbContext.clientGet(bossEntity, itemId)
			local item_data = {
				itemId = itemId,
				icon = ItemData[itemId].icon,
				name = ItemData[itemId].itemName,
				count = count,
				prob = context.finalProb
			}
			local castItemId = Utils.itemId2CastItemId(itemId)
			local ballData = castItemData[castItemId]

			if count > 0 and ballData and ballData.canQuickCaptureInHand then
				propList[#propList + 1] = item_data
			end
		end
	end

	propList = lume.sort(propList, function(a, b)
		return a.prob > b.prob
	end)

	return propList
end

return CatchBossModel
