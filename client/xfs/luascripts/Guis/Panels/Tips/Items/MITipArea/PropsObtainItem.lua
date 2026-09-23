-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\MITipArea\\PropsObtainItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local HotkeyConst = require("Const.HotkeyConst")
local PropsObtainItem = Class.LightClass("PropsObtainItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function PropsObtainItem:onInit()
	self:setMaxLimit(1)
end

function PropsObtainItem:pushData(data)
	self:enqueue(data)
end

function PropsObtainItem:onUpdate()
	self:tryPopupItem()
end

function PropsObtainItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BP_OBTAIN) then
		self:closePanel(data)

		return
	end

	self:addRunItem(data)
	pg.global.ui:open(UIConst.UI_ID_COMMON_OBTAIN, data, nil, function()
		self:closePanel(data)
	end)
end

function PropsObtainItem:closePanel(data)
	self:removeItem(data)
end

return PropsObtainItem
