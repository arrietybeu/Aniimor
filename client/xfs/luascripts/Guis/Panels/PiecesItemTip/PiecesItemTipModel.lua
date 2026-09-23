-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PiecesItemTip\\PiecesItemTipModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PiecesItemTipModel = Class.LightClass("PiecesItemTipModel", UIModel)
local ItemData = require("Data.item_data")
local PiecesItemSpecialData = require("Data.pieces_item_special_data")

function PiecesItemTipModel:getPiecesItemState(itemId, openType)
	local state = 0
	local data = ItemData[itemId]

	if data then
		if data.showIPContent and data.showIPContent > 0 or openType and openType == 1 then
			state = 2
		else
			state = 1
		end
	elseif openType and openType == 1 then
		state = 2
	end

	return state
end

function PiecesItemTipModel:getEventPiecesInfo(piecesId)
	local piecesInfo = {}
	local piecesData = PiecesItemSpecialData[piecesId]

	if piecesData then
		piecesInfo.icon = piecesData.icon or ""
		piecesInfo.name = pg.getLocalizationText(piecesData.name or "")
		piecesInfo.funcRep = pg.getLocalizationText(piecesData.funcDesc or "")
		piecesInfo.itemDesc = pg.getLocalizationText(piecesData.content or "")
	end

	return piecesInfo
end

function PiecesItemTipModel:getPiecesInfo(itemData)
	local piecesInfo = {}
	local iData = ItemData[itemData.id]

	if not iData then
		return piecesInfo
	end

	if iData.showIPContent and iData.showIPContent > 0 then
		piecesInfo = self:getEventPiecesInfo(iData.showIPContent)
	end

	piecesInfo.id = itemData.id
	piecesInfo.num = itemData.num
	piecesInfo.icon = (not piecesInfo.icon or piecesInfo.icon == "") and itemData.icon or piecesInfo.icon
	piecesInfo.name = (not piecesInfo.name or piecesInfo.name == "") and itemData.itemName or piecesInfo.name
	piecesInfo.funcRep = (not piecesInfo.funcRep or piecesInfo.funcRep == "") and itemData.desc or piecesInfo.funcRep
	piecesInfo.itemDesc = (not piecesInfo.itemDesc or piecesInfo.itemDesc == "") and iData.itemDes or piecesInfo.itemDesc
	piecesInfo.quality = itemData.quality

	return piecesInfo
end

return PiecesItemTipModel
