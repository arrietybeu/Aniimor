-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\MTipArea\\QuestChapterItem.lua

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
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local QuestChapterItem = Class.LightClass("QuestChapterItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function QuestChapterItem:onInit()
	self:setMaxLimit(1)
end

function QuestChapterItem:pushData(data)
	self:enqueue(data)
	self:checkTipState(data)
end

function QuestChapterItem:onUpdate()
	self:tryPopupItem()
end

function QuestChapterItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	pg.global.ui:open(UIConst.UI_ID_QUEST_CHAPTER, data, nil, function()
		if data.closeFuncOpenHud then
			data.closeFuncOpenHud()
		end

		self:removeItem(data)
		self:checkTipState()
	end)
	self:checkTipState()
end

function QuestChapterItem:checkTipState(data)
	if self:isWaitingOrRunning() then
		if data and data.type == 1 then
			pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.QUEST_CHAPTER, {
				[UIConst.UI_ID_QUEST_CHAPTER] = true,
				[UIConst.UI_ID_TIPS] = true
			})
			pg.global.ui.tips:hideAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_Quest, {
				TipAreaConst.AREAS.M
			})
		else
			pg.game:setModuleEnable(UIConst.UI_HIDE_MATE_KEY.QUSET_CHAPTER, ClientConst.ModuleKey.PetList, false)
		end
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.QUEST_CHAPTER)
		pg.global.ui.tips:showAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_Quest)
		pg.game:setModuleEnable(UIConst.UI_HIDE_MATE_KEY.QUSET_CHAPTER, ClientConst.ModuleKey.PetList, true)
	end
end

return QuestChapterItem
