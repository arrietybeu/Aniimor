-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditHeadBarComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EditHeadBarComponent = Class.LightClass("EditHeadBarComponent", UIComponent)
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")

function EditHeadBarComponent:onCtor(info)
	self.playerInfo = info.playerInfo
	self.btnConfirm = info.btnConfirm
	self.getWayBottomText = info.getWayBottomText
	self.usingUWidget = info.usingUWidget
	self.tabIndex = 1
	self.btnConfirmText = self.btnConfirm:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	function self.confirmHandler()
		self:onConfirmBtnClick()
	end

	function self.refreshPanelHandler(order)
		self.order = order

		self.btnTab1.luaClick()
		self:refreshEditHeadBarPanel()
	end
end

function EditHeadBarComponent:initView()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listHead = objectReference:GetRefValue("listHead")
	self.btnTab1 = objectReference:GetRefValue("btnTab1")
	self.btnTab2 = objectReference:GetRefValue("btnTab2")
	self.listFrame = objectReference:GetRefValue("listFrame")
	self.txtHeadIconName = objectReference:GetRefValue("txtHeadIconName")
	self.txtHeadIconDescription = objectReference:GetRefValue("txtHeadIconDescription")
	self.avatarUContainer = objectReference:GetRefValue("avatarUContainer")
	self.curSelectedIconId = self.playerInfo.headIcon
	self.curSelectedFrameId = self.playerInfo.headFrame

	function self.listHead.luaRenderItem(button, index, data)
		self:renderHeadListItem(button, index, data)
	end

	function self.listFrame.luaRenderItem(button, index, data)
		self:renderHeadFrameListItem(button, index, data)
	end

	function self.btnTab1.luaClick()
		self.uWidget:TryChangePage("Tab", 0)

		self.tabIndex = 1

		local headCfg = PlayerHeadIconData[self.playerInfo.headIcon]
		local headFrameCfg = PlayerHeadFrameData[self.playerInfo.headFrame]

		self.curSelectedIconId = self.playerInfo.headIcon
		self.curSelectedFrameId = self.playerInfo.headFrame

		self.listHead:RefreshList()
		self:selectHeadListItem(self.listHead, self.headDataList, self.playerInfo.headIcon)
		ClientTextUtils.setText(self.txtHeadIconName, pg.getLocalizationText(headCfg.name))
		ClientTextUtils.setText(self.txtHeadIconDescription, pg.getLocalizationText(headCfg.desc))
		self:renderCurAvatar(self.avatarUContainer.content)
		self:refreshConfirmButtonState(self.curSelectedIconId, true)
	end

	function self.btnTab2.luaClick()
		self.uWidget:TryChangePage("Tab", 1)

		self.tabIndex = 2

		local headCfg = PlayerHeadIconData[self.playerInfo.headIcon]
		local headFrameCfg = PlayerHeadFrameData[self.playerInfo.headFrame]

		self.curSelectedIconId = self.playerInfo.headIcon
		self.curSelectedFrameId = self.playerInfo.headFrame

		self.listFrame:RefreshList()
		self:selectHeadListItem(self.listFrame, self.frameDataList, self.playerInfo.headFrame)

		if headFrameCfg then
			ClientTextUtils.setText(self.txtHeadIconName, pg.getLocalizationText(headFrameCfg.name))
			ClientTextUtils.setText(self.txtHeadIconDescription, pg.getLocalizationText(headFrameCfg.desc))
		end

		self:renderCurAvatar(self.avatarUContainer.content)
		self:refreshConfirmButtonState(self.curSelectedFrameId, false)
	end

	self.avatarUContainer:LoadDefaultUrlManually(function(content)
		self:renderCurAvatar(content)
	end)
end

function EditHeadBarComponent:refreshEditHeadBarPanel()
	local headCfg = PlayerHeadIconData[self.playerInfo.headIcon]
	local headFrameCfg = PlayerHeadFrameData[self.playerInfo.headFrame]

	ClientTextUtils.setText(self.txtHeadIconName, pg.getLocalizationText(headCfg.name))
	ClientTextUtils.setText(self.txtHeadIconDescription, pg.getLocalizationText(headCfg.desc))

	self.headDataList = self.model:getHeadList()

	self.listHead:SetList(self.headDataList)

	self.frameDataList = self.model:getFrameList()

	self.listFrame:SetList(self.frameDataList)
	self:refreshConfirmButtonState(self.playerInfo.headIcon, true)

	self.curSelectedIconId = self.playerInfo.headIcon
	self.curSelectedFrameId = self.playerInfo.headFrame

	self:selectHeadListItem(self.listHead, self.headDataList, self.playerInfo.headIcon)
	self:renderCurAvatar(self.avatarUContainer.content)
end

function EditHeadBarComponent:selectHeadListItem(list, dataList, id)
	local selectIndex

	for i, data in ipairs(dataList or EMPTY_TABLE) do
		if data.id == id then
			selectIndex = i - 1

			break
		end
	end

	if selectIndex then
		list:SelectItem(selectIndex, false)
	end

	list:GoToIndex(selectIndex or 0)
end

function EditHeadBarComponent:renderCurAvatar(content)
	LuaUIUtils.renderPlayerAvatarImages(content, {
		avatarIconId = self.curSelectedIconId or self.playerInfo.headIcon,
		avatarFrameIconId = self.curSelectedFrameId or self.playerInfo.headFrame
	})
end

function EditHeadBarComponent:renderHeadListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local isLock = self.model:isHeadIconLock(data.id)
	local isEquip = data.id == self.playerInfo.headIcon

	if isEquip then
		self.curSelectedIconId = data.id

		button:TryChangePage("State", 2)
	else
		button:TryChangePage("State", isLock and 1 or 0)
	end

	button.isSelected = self.curSelectedIconId == data.id
	iconUImage.url = data.icon

	function button.luaClick()
		self.curSelectedIconId = data.id
		button.isSelected = true

		ClientTextUtils.setText(self.txtHeadIconName, pg.getLocalizationText(PlayerHeadIconData[data.id].name))
		ClientTextUtils.setText(self.txtHeadIconDescription, pg.getLocalizationText(PlayerHeadIconData[data.id].desc))

		if self.curSelectedIconId then
			self:refreshConfirmButtonState(data.id, true)
		end

		self:renderCurAvatar(self.avatarUContainer.content)
	end
end

function EditHeadBarComponent:renderHeadFrameListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local headFrameUContainer = objectReference:GetRefValue("headFramUContainer")
	local isLock = true
	local isEquip = false

	isLock = self.model:isHeadFrameLock(data.id)
	isEquip = data.id == self.playerInfo.headFrame

	if isEquip then
		button:TryChangePage("State", 2)
	else
		button:TryChangePage("State", isLock and 1 or 0)
	end

	button.isSelected = self.curSelectedFrameId == data.id

	local isDynamic = PlayerHeadFrameData[data.id].isDynamic == 1

	iconUImage:SetActive(not isDynamic)
	headFrameUContainer:SetActive(isDynamic)

	if isDynamic then
		headFrameUContainer:SetUrlWithCallback(data.icon)
	else
		headFrameUContainer:DestroyContent()

		iconUImage.url = data.icon
	end

	function button.luaClick()
		self.curSelectedFrameId = data.id
		button.isSelected = true

		ClientTextUtils.setText(self.txtHeadIconName, pg.getLocalizationText(PlayerHeadFrameData[data.id].name))
		ClientTextUtils.setText(self.txtHeadIconDescription, pg.getLocalizationText(PlayerHeadFrameData[data.id].desc))

		if self.curSelectedFrameId then
			self:refreshConfirmButtonState(data.id, false)
		end

		self:renderCurAvatar(self.avatarUContainer.content)
	end
end

function EditHeadBarComponent:refreshConfirmButtonState(id, isHeadIcon)
	self.usingUWidget:SetActive(false)
	self.btnConfirm:SetActive(true)
	self.btnConfirm:TryChangePage("IconState", 0)

	if isHeadIcon then
		if self.model:isHeadIconLock(id) then
			if PlayerHeadIconData[id].item and ItemData[PlayerHeadIconData[id].item] and ItemData[PlayerHeadIconData[id].item].source and ItemSourceData[ItemData[PlayerHeadIconData[id].item].source[1]] and ItemSourceData[ItemData[PlayerHeadIconData[id].item].source[1]].param then
				ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GO_GET_ITEM"))
				self.btnConfirm:TryChangePage("IconState", 1)
				self.btnConfirm:TryChangePage("button", 0)

				self.btnConfirm.interactable = true

				self.getWayBottomText:SetActive(false)
			else
				ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("SKILL_LOCKED"))
				self.btnConfirm:TryChangePage("button", 4)

				self.btnConfirm.interactable = false

				self.getWayBottomText:SetActive(true)
				ClientTextUtils.setText(self.getWayBottomText, pg.getLocalizationText(PlayerHeadIconData[id].unlockavatar_txt))
			end
		elseif id == self.playerInfo.headIcon then
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))
			self.btnConfirm:TryChangePage("button", 4)

			self.btnConfirm.interactable = false

			self.getWayBottomText:SetActive(false)
			self.usingUWidget:SetActive(true)
			self.btnConfirm:SetActive(false)
		else
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))
			self.btnConfirm:TryChangePage("button", 0)

			self.btnConfirm.interactable = true

			self.getWayBottomText:SetActive(false)
		end
	elseif self.model:isHeadFrameLock(id) then
		if PlayerHeadFrameData[id].item and ItemData[PlayerHeadFrameData[id]] and ItemData[PlayerHeadFrameData[id]].source and ItemSourceData[PlayerHeadFrameData[id].item] and ItemSourceData[PlayerHeadFrameData[id].item].param then
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GO_GET_ITEM"))
			self.btnConfirm:TryChangePage("button", 0)

			self.btnConfirm.interactable = true

			self.getWayBottomText:SetActive(false)
		else
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("SKILL_LOCKED"))
			self.btnConfirm:TryChangePage("button", 4)

			self.btnConfirm.interactable = false

			self.getWayBottomText:SetActive(true)
			ClientTextUtils.setText(self.getWayBottomText, pg.getLocalizationText(PlayerHeadFrameData[id].unlockframe_txt))
		end
	elseif id == self.playerInfo.headFrame then
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))
		self.btnConfirm:TryChangePage("button", 4)

		self.btnConfirm.interactable = false

		self.getWayBottomText:SetActive(false)
		self.usingUWidget:SetActive(true)
		self.btnConfirm:SetActive(false)
	else
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))
		self.btnConfirm:TryChangePage("button", 0)

		self.btnConfirm.interactable = true

		self.getWayBottomText:SetActive(false)
	end
end

function EditHeadBarComponent:onPlayerIconChange()
	self.listHead:RefreshList()
	self.listFrame:RefreshList()
	self:refreshConfirmButtonState(self.tabIndex == 1 and self.playerInfo.headIcon or self.playerInfo.headFrame, self.tabIndex == 1)
end

function EditHeadBarComponent:onConfirmBtnClick()
	if self.tabIndex == 1 then
		local isLock = self.model:isHeadIconLock(self.curSelectedIconId)

		if not isLock then
			if self.curSelectedIconId and self.curSelectedIconId ~= pg.me.headIcon then
				pg.me:serverMsg("RPC_CS_SetHeadIcon", self.curSelectedIconId)
			end
		else
			local data = ItemSourceData[PlayerHeadIconData[self.curSelectedIconId].item]

			pg.me:doEventByData({
				data.param[1],
				data.param[2]
			})
		end
	else
		local isLock = self.model:isHeadFrameLock(self.curSelectedFrameId)

		if not isLock then
			if self.curSelectedFrameId and self.curSelectedFrameId ~= pg.me.headFrame then
				pg.me:serverMsg("RPC_CS_SetHeadFrame", self.curSelectedFrameId)
			end
		else
			local data = ItemSourceData[PlayerHeadFrameData[self.curSelectedFrameId].item]

			pg.me:doEventByData({
				data.param[1],
				data.param[2]
			})
		end
	end
end

return EditHeadBarComponent
