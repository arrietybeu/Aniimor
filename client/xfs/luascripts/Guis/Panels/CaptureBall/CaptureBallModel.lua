-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CaptureBall\\CaptureBallModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local ItemData = require("Data.item_data")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local CaptureBallModel = Class.LightClass("CaptureBallModel", UIModel)

function CaptureBallModel:getCapturePropInfos()
	local propList = {}

	if pg.me then
		if ClientUtils.isInDouYinOfflineScene() then
			for _, info in ipairs(pg.me:getOfflineCaptureBalls()) do
				local itemId = info.itemId

				if itemId and ItemData[itemId] then
					propList[#propList + 1] = {
						itemId = itemId,
						icon = ItemData[itemId].icon,
						name = ItemData[itemId].itemName
					}
				end
			end
		elseif pg.me.isInFishingCapture and pg.me:isInFishingCapture() then
			return propList
		elseif Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			for idx, itemId in ipairs(pg.me.catchRogueInfo:getValidBallList(pg.me) or EMPTY_TABLE) do
				if itemId ~= 0 and ItemData[itemId] then
					local item_data = {
						itemId = itemId,
						icon = ItemData[itemId].icon,
						name = ItemData[itemId].itemName
					}
					local count = ClientUtils.getItemCountById(itemId)

					if count > 0 then
						propList[#propList + 1] = item_data
					end
				end
			end
		else
			for _, itemId in pairs(pg.me.invQuickSlotBall or EMPTY_TABLE) do
				if itemId ~= 0 and ItemData[itemId] and not ClientCaptureUtils.isPaidBall(itemId) then
					local item_data = {
						itemId = itemId,
						icon = ItemData[itemId].icon,
						name = ItemData[itemId].itemName
					}
					local count = ClientUtils.getItemCountById(itemId)

					if count > 0 then
						propList[#propList + 1] = item_data
					end
				end
			end
		end
	end

	return propList
end

function CaptureBallModel:getPaidCapturePropInfos()
	local propList = {}

	if not pg.me or ClientUtils.isInDouYinOfflineScene() or pg.me.isInFishingCapture and pg.me:isInFishingCapture() or Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		return propList
	end

	for _, itemId in ipairs(ClientCaptureUtils.getEquippedPaidBallItemIds()) do
		propList[#propList + 1] = {
			itemId = itemId,
			icon = ItemData[itemId].icon,
			name = ItemData[itemId].itemName
		}
	end

	return propList
end

return CaptureBallModel
