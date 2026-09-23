-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerRename\\PlayerRenameModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PlayerRenameModel = Class.LightClass("PlayerRenameModel", UIModel)
local PlayerHeadIconData = require("Data.player_head_icon_data")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")

function PlayerRenameModel:getUserHeadIconList()
	local res = {}

	for i, v in ipairs(PlayerHeadIconData) do
		res[i] = {
			icon = v.res,
			id = i,
			selected = pg.me.headIcon == i
		}
	end

	table.sort(res, function(a, b)
		if a.selected ~= b.selected then
			return a.selected
		end
	end)

	return res
end

function PlayerRenameModel:redDot_CheckSaveDirty()
	if self.redDotDirty then
		pg.global.prefsCacheUtils:save()
	end
end

function PlayerRenameModel:redDot_GetPlayerIconListItemState(data)
	local record = pg.me:getRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.PLAYER_TREE_LIST .. data.icon, true)
	local showRedDot = record and not data.selected

	return showRedDot
end

function PlayerRenameModel:redDot_SetPlayerIconListItemState(data)
	self.redDotDirty = true

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PLAYER_ENHANCE_RED_DOT, RedDotConst.RedDotPath.PLAYER_TREE_LIST .. data.icon, false)
end

return PlayerRenameModel
