-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChangeAvatar\\ChangeAvatarCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ChangeAvatarCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ChangeAvatarCtrl = Class.LightClass("ChangeAvatarCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")

ChangeAvatarCtrl.messages = {
	[MessageName.PLAYER_ICON_CHANGE] = {
		"refreshAvatarSelected",
		true
	},
	[MessageName.PLAYER_FRAME_CHANGE] = {
		"refreshAvatarSelected",
		true
	}
}

function ChangeAvatarCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.param = info

	self:initUI()
end

function ChangeAvatarCtrl:addListener()
	self:bindCommonCloseHotKey(function()
		self:close()
	end)

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnChangeUButton.luaClick()
		if self.param.changeAvatar then
			if self.curSelectedId and self.curSelectedId ~= pg.me.headIcon then
				pg.me:setRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarIcon .. pg.me.headIcon, false)
				pg.me:serverMsg("RPC_CS_SetHeadIcon", self.curSelectedId)
			end
		elseif self.curSelectedId and self.curSelectedId ~= pg.me.headFrame then
			pg.me:setRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarFrame .. pg.me.headFrame, false)
			pg.me:serverMsg("RPC_CS_SetHeadFrame", self.curSelectedId)
		end
	end
end

function ChangeAvatarCtrl:initUI()
	function self.view.avatarListUList.luaRenderItem(button, index, data)
		local isLock = true
		local isEquip = false

		if self.param.changeAvatar then
			isLock = self:isHeadIconLock(data.id)
			isEquip = data.id == pg.me.headIcon
		else
			isLock = self:isHeadFrameLock(data.id)
			isEquip = data.id == pg.me.headFrame
		end

		local data = {
			isLock = isLock,
			isEquip = isEquip,
			showAvatar = self.param.changeAvatar,
			showAvatarFrame = self.param.changeAvatarFrame,
			avatarIconId = self.param.changeAvatar and data.id or pg.me.headIcon,
			avatarFrameIconId = self.param.changeAvatarFrame and data.id or pg.me.headFrame,
			isAvatarList = self.param.changeAvatar,
			isAvatarFrameList = self.param.changeAvatarFrame,
			iconId = data.id
		}

		LuaUIUtils.renderPlayerAvatar(button, data)
	end

	function self.view.avatarListUList.luaClick(button, data)
		local headIconId = self.param.changeAvatar and data.id or pg.me.headIcon
		local headFrameId = self.param.changeAvatarFrame and data.id or pg.me.headFrame

		self.curSelectedId = data.id

		if self.param.changeAvatar then
			pg.me:setRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarIcon .. data.id, false)
			pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_PLAYER_AVATAR_ICON_LIST .. data.id, button, false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
		else
			pg.me:setRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarFrame .. data.id, false)
			pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_PLAYER_AVATAR_FRAME_LIST .. data.id, button, false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
		end

		self:refreshCurSelectedIconInfo(headIconId, headFrameId)
	end

	self.view.tltleUBaseText.text = self.param.changeAvatar and pg.getGameString("CHANGE_AVATAR_TITLE") or pg.getGameString("CHANGE_AVATAR_FRAME_TITLE")

	local headIconId = pg.me.headIcon or 1
	local headFrameId = pg.me.headFrame or 1

	self:refreshCurSelectedIconInfo(headIconId, headFrameId)
	self:refreshAvatarList()
end

function ChangeAvatarCtrl:refreshCurSelectedIconInfo(headIconId, headFrameId)
	local curIsLock = false

	if self.param.changeAvatar then
		local headCfg = PlayerHeadIconData[headIconId]

		ClientTextUtils.setText(self.view.avatarNameUBaseText, pg.getLocalizationText(headCfg.name))
		ClientTextUtils.setText(self.view.avatarGetInfoUBaseText, pg.getLocalizationText(headCfg.unlockavatar_txt))

		curIsLock = self:isHeadIconLock(headIconId)
	else
		local headCfg = PlayerHeadFrameData[headFrameId]

		ClientTextUtils.setText(self.view.avatarNameUBaseText, pg.getLocalizationText(headCfg.name))
		ClientTextUtils.setText(self.view.avatarGetInfoUBaseText, pg.getLocalizationText(headCfg.unlockframe_txt))

		curIsLock = self:isHeadFrameLock(headFrameId)
	end

	local data = {
		isEquip = false,
		isLock = false,
		showAvatarFrame = true,
		showAvatar = true,
		avatarIconId = headIconId,
		avatarFrameIconId = headFrameId
	}

	LuaUIUtils.renderPlayerAvatar(self.view.btnAvatarUButton, data)
	self.view.btnGoToGetUButton:SetActive(curIsLock)

	if curIsLock then
		self:refreshItemSource()
	end

	self.view.btnChangeUButton:SetActive(not curIsLock)

	self.view.btnChangeUButton.interactable = self.param.changeAvatar and headIconId ~= pg.me.headIcon or headFrameId ~= pg.me.headFrame
end

function ChangeAvatarCtrl:refreshAvatarList()
	self.view.avatarListUList:SetList(self:getAvatarData())
end

function ChangeAvatarCtrl:refreshAvatarSelected()
	self.view.avatarListUList:RefreshList()
end

function ChangeAvatarCtrl:getAvatarData()
	local ret = {}
	local data = self.param.changeAvatar and PlayerHeadIconData or PlayerHeadFrameData
	local curUnlock = self.param.changeAvatar and pg.me.headIconDicts or pg.me.headFrameDicts
	local curUse = self.param.changeAvatar and pg.me.headIcon or pg.me.headFrame
	local alreadyInsert = {}

	if curUse and data[curUse] then
		table.insert(ret, {
			selected = true,
			id = curUse,
			icon = data[curUse].res
		})
		table.insert(alreadyInsert, curUse)
	end

	for index, value in pairs(curUnlock) do
		if value and index ~= curUse then
			table.insert(ret, {
				id = index,
				icon = data[index].res
			})
			table.insert(alreadyInsert, index)
		end
	end

	for id, value in ipairs(data) do
		if not table.contains(alreadyInsert, id) then
			table.insert(ret, {
				id = id,
				icon = value.res
			})
		end
	end

	return ret
end

function ChangeAvatarCtrl:refreshItemSource()
	self.view.btnGoToGetUButton.enabledTooltip = false

	function self.view.btnGoToGetUButton.luaClick()
		pg.global.ui.tips:showTextTip(pg.getGameString("NO_GET_CHANNEL"))
	end

	local data = self.param.changeAvatar and PlayerHeadIconData or PlayerHeadFrameData
	local cfg = data[self.curSelectedId]

	if cfg and cfg.item then
		local itemInfo = ItemData[cfg.item]

		if itemInfo and itemInfo.source then
			local sourceData = ItemSourceData[itemInfo.source[1]]

			if sourceData then
				LuaUIUtils.itemSourceTrigger(self.view.btnGoToGetUButton, sourceData)
			end
		end
	end
end

function ChangeAvatarCtrl:isHeadIconLock(id)
	return pg.me.headIconDicts[id] == nil or pg.me.headIconDicts[id] == false
end

function ChangeAvatarCtrl:isHeadFrameLock(id)
	return pg.me.headFrameDicts[id] == nil or pg.me.headFrameDicts[id] == false
end

function ChangeAvatarCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.param.changeAvatar then
		pg.me:setRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarIconNewCount, LuaUIUtils.getNewAvatarCount())
	elseif self.param.changeAvatarFrame then
		pg.me:setRedDotRecord(Const.CLIENT_KEY.AVATAR_ICON_RED_DOT, ClientConst.PrefKey.AvatarFrameNewCount, LuaUIUtils.getNewAvatarFrameCount())
	end
end

function ChangeAvatarCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ChangeAvatarCtrl:onShow()
	return
end

function ChangeAvatarCtrl:onHide()
	return
end

return ChangeAvatarCtrl
