-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditBadgeBarComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EditBadgeBarComponent = Class.LightClass("EditBaseBarComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local PlayerBadgeData = require("Data.player_badge_data")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")

EditBadgeBarComponent.messages = {
	[MessageName.PLAYER_BADGE_SHOW_MAP_CHANGED] = {
		"onBadgeShowMapChanged"
	}
}

function EditBadgeBarComponent:onCtor(info)
	self.playerInfo = info.playerInfo
	self.badgeShowMap = self.playerInfo.badgeShowMap

	function self.refreshPanelHandler(order)
		self.order = order

		self:refreshBadgeBarPanel()
	end
end

function EditBadgeBarComponent:initView()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listUList = objectReference:GetRefValue("listUList")
	self.listEquipUList = objectReference:GetRefValue("listEquipUList")
	self.badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	self.textBadgeTimeUSDFText = objectReference:GetRefValue("textBadgeTimeUSDFText")
	self.textBadgeTitleUSDFText = objectReference:GetRefValue("textBadgeTitleUSDFText")
	self.textBadgeDescUSDFText = objectReference:GetRefValue("textBadgeDescUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.badgeBarUWidget = objectReference:GetRefValue("badgeBarUWidget")
	self.panelBadgeUWidget = objectReference:GetRefValue("panelBadgeUWidget")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.btnEmptyGoUButton = objectReference:GetRefValue("btnEmptyGoUButton")

	function self.listTabUList.luaRenderItem(button, index, data)
		local objRef = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objRef:GetRefValue("txtNameUSDFText")
		local name, _ = BadgeUtils.getMainTypeNameAndIconInPlayerUI(data.tabIndex)

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name))
	end

	function self.listTabUList.luaSelectedChanged(ulist, isSelected)
		if isSelected then
			local tabIndex = ulist.selectedItem.tabIndex

			self:refreshBadgeListByIndex(tabIndex)
		end
	end

	function self.listUList.luaRenderItem(button, index, data)
		self:renderBadgeItem(button, index, data)
		button:TryChangePage("State", self:isBadgeEquipped(data.badgeId) and 1 or 0)
	end

	function self.listUList.luaSelectedChanged(ulist, isSelected)
		if isSelected then
			self:refreshSelectedBadge(ulist.selectedItem.badgeId)
			self:refreshBadgeDetail(ulist.selectedItem)
		end
	end

	function self.listUList.luaFinishRender(ulist)
		self:selectBadgeItem(self.refreshSelectBadgeId or self.curSelectedEquipBadgeId)
	end

	function self.listEquipUList.luaRenderItem(button, index, data)
		if data.badgeId > 0 then
			button:TryChangePage("Badge", 0)
			self:renderBadgeItem(button, index, data)
		else
			button:TryChangePage("Badge", 1)
		end
	end

	function self.listEquipUList.luaSelectedChanged(ulist, isSelected)
		if isSelected then
			self.curSelectedEquipIndex = ulist.selectedIndex + 1
			self.nextSelectBadgeId = nil

			self:resetEquipBadgeData()

			self.curSelectedEquipBadgeId = self.badgeShowMap[self.curSelectedEquipIndex] or 0

			self:selectBadgeTab(self.curSelectedEquipBadgeId)
		end
	end
end

function EditBadgeBarComponent:refreshBadgeBarPanel(selectEquipIndex)
	local data = {}

	for k, v in pairs(BadgeUtils.BADGE_TYPE) do
		if BadgeUtils.checkBadgeTypeIsUnlock(v) then
			table.insert(data, {
				tabIndex = v
			})
		end
	end

	table.sort(data, function(a, b)
		return a.tabIndex < b.tabIndex
	end)

	self.badgeTabData = data
	self.badgeShowMap = self.playerInfo.badgeShowMap or pg.me.badgeShowMap or {}
	self.curSelectedEquipIndex = selectEquipIndex or self.curSelectedEquipIndex or 1
	self.curSelectedEquipBadgeId = self.badgeShowMap[self.curSelectedEquipIndex] or 0

	self.listTabUList:SetList(data)

	self.equipBadgeData = {}

	for i = 1, Const.BADGE_SHOW_COUNT do
		self.equipBadgeData[#self.equipBadgeData + 1] = {
			badgeId = self.badgeShowMap[i] or 0
		}
	end

	self.listEquipUList:SetList(self.equipBadgeData)

	if #self.equipBadgeData > 0 then
		self.listEquipUList:SelectItem(self.curSelectedEquipIndex - 1, false)
	end

	local objectReference = self.btnEmptyGoUButton:GetComponent("ObjectReference")
	local txtEmptyGoButtonUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtEmptyGoButtonUText, pg.getGameString("BADGE_EMPTY_GO_CHECK"))
	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("BADGE_EMPTY"))

	function self.btnEmptyGoUButton.luaClick()
		pg.global.ui.playerEnhance:open({
			defaultMode = 4,
			defaultTab = 1,
			badgeTabIndex = self.listTabUList.selectedItem.tabIndex
		})
	end

	local selectBadgeId = self.keepSelectedBadgeId or self.curSelectedEquipBadgeId

	self.keepSelectedBadgeId = nil

	self:selectBadgeTab(selectBadgeId)
end

function EditBadgeBarComponent:resetEquipBadgeData()
	for i = 1, Const.BADGE_SHOW_COUNT do
		if self.equipBadgeData[i] then
			self.equipBadgeData[i].badgeId = self.badgeShowMap[i] or 0

			self.listEquipUList:RefreshElement(i - 1)
		end
	end
end

function EditBadgeBarComponent:refreshBadgeListByIndex(tabIndex, selectBadgeId)
	self.curBadgeTabIndex = tabIndex

	local data = self:getBadgeListByIndex(tabIndex)

	self.badgeBarUWidget:TryChangePage("Empty", #data > 0 and 0 or 1)

	self.badgeListData = data
	self.refreshSelectBadgeId = selectBadgeId or self.nextSelectBadgeId or self.curSelectedEquipBadgeId

	self.listUList:SetList(data)
	self:selectBadgeItem(self.refreshSelectBadgeId)
end

function EditBadgeBarComponent:getBadgeListByIndex(tabIndex)
	local data = {}

	for _, tabData in ipairs(BadgeUtils.getDataByTab(tabIndex)) do
		local bigBadgeData = self:getMaxCompleteBadgeData(tabData.bigBadgeGroupId)

		if bigBadgeData then
			table.insert(data, bigBadgeData)
		end

		for _, badgeData in ipairs(tabData.suite or EMPTY_TABLE) do
			local completeBadgeData = self:getMaxCompleteBadgeData(badgeData.badgeGroupId)

			if completeBadgeData then
				table.insert(data, completeBadgeData)
			end
		end
	end

	return data
end

function EditBadgeBarComponent:getMaxCompleteBadgeData(badgeGroupId)
	local ret

	for _, badgeData in ipairs(BadgeUtils.getAllBadgeByGroupId(badgeGroupId)) do
		if badgeData.badgeState == Const.BADGE_STATUS.Complete and PlayerBadgeData[badgeData.badgeId] then
			ret = badgeData
		end
	end

	return ret
end

function EditBadgeBarComponent:getFirstUnequippedBadgeData(tabIndex)
	for _, data in ipairs(self:getBadgeListByIndex(tabIndex)) do
		if not self:isBadgeEquipped(data.badgeId) then
			return data
		end
	end
end

function EditBadgeBarComponent:isBadgeEquipped(badgeId)
	if not badgeId or badgeId <= 0 then
		return false
	end

	for i = 1, Const.BADGE_SHOW_COUNT do
		if self.badgeShowMap[i] == badgeId then
			return true
		end
	end

	return false
end

function EditBadgeBarComponent:selectBadgeTab(badgeId)
	if not self.badgeTabData or #self.badgeTabData == 0 then
		self:refreshBadgeListByIndex(nil)

		return
	end

	local tabIndex = self.badgeTabData[1].tabIndex
	local selectBadgeId = badgeId

	if badgeId and badgeId > 0 then
		tabIndex = BadgeUtils.getTypeByBadgeId(badgeId)

		local completeBadgeData = self:getMaxCompleteBadgeData(PlayerBadgeData[badgeId] and PlayerBadgeData[badgeId].group)

		selectBadgeId = completeBadgeData and completeBadgeData.badgeId or badgeId
	else
		selectBadgeId = nil

		for _, data in ipairs(self.badgeTabData) do
			local badgeData = self:getFirstUnequippedBadgeData(data.tabIndex)

			if badgeData then
				tabIndex = data.tabIndex
				selectBadgeId = badgeData.badgeId

				break
			end
		end
	end

	for i, data in ipairs(self.badgeTabData) do
		if data.tabIndex == tabIndex then
			if self.listTabUList.selectedIndex == i - 1 then
				self:refreshBadgeListByIndex(tabIndex, selectBadgeId)
			else
				self.nextSelectBadgeId = selectBadgeId

				self.listTabUList:SelectItem(i - 1)
				self.listTabUList:GoToIndex(i - 1)
			end

			return
		end
	end

	self:refreshBadgeListByIndex(self.badgeTabData[1].tabIndex)
end

function EditBadgeBarComponent:selectBadgeItem(badgeId)
	if not self.badgeListData or #self.badgeListData == 0 then
		self.listUList:DeselectAll()
		self:refreshBtnState(0)
		self:refreshBadgeDetail()

		return
	end

	local selectIndex

	if badgeId and badgeId > 0 then
		for i, data in ipairs(self.badgeListData) do
			if data.badgeId == badgeId then
				selectIndex = i - 1

				break
			end
		end
	end

	if not selectIndex then
		for i, data in ipairs(self.badgeListData) do
			if (self.curSelectedEquipBadgeId or 0) > 0 or not self:isBadgeEquipped(data.badgeId) then
				selectIndex = i - 1

				break
			end
		end
	end

	selectIndex = selectIndex or 0

	self.listUList:SelectItem(selectIndex, false)
	self.listUList:GoToIndex(selectIndex)

	local data = self.badgeListData[selectIndex + 1]

	self:refreshSelectedBadge(data.badgeId)
	self:refreshBadgeDetail(data)
end

function EditBadgeBarComponent:refreshSelectedBadge(badgeId)
	self:refreshBtnState(badgeId)
end

function EditBadgeBarComponent:refreshBadgeDetail(data)
	if not data or not data.badgeId or data.badgeId <= 0 then
		self.panelBadgeUWidget:SetActive(false)

		return
	else
		self.panelBadgeUWidget:SetActive(true)
	end

	local cfgData = data and PlayerBadgeData[data.badgeId]
	local unlockTime = BadgeUtils.getBadgeUnlockInfo(data.badgeId)

	self.badgeIconUImage.url = cfgData and cfgData.icon or ""

	ClientTextUtils.setText(self.textBadgeTimeUSDFText, unlockTime or "")
	ClientTextUtils.setText(self.textBadgeTitleUSDFText, cfgData and pg.getLocalizationText(cfgData.name) or "")
	ClientTextUtils.setText(self.textBadgeDescUSDFText, cfgData and pg.getLocalizationText(cfgData.desc) or "")
end

function EditBadgeBarComponent:renderBadgeItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imageBadgeIconUImage = objectReference:GetRefValue("imageBadgeIconUImage")
	local cfgData = PlayerBadgeData[data.badgeId]

	imageBadgeIconUImage.url = cfgData.icon
end

function EditBadgeBarComponent:refreshBtnState(badgeId)
	local objectReference = self.btnConfirmUButton:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local canConfirm = badgeId ~= nil and badgeId > 0
	local curSelectedEquipBadgeId = self.curSelectedEquipBadgeId or 0
	local isUnload = canConfirm and badgeId == curSelectedEquipBadgeId
	local confirmTextKey = curSelectedEquipBadgeId == 0 and "BADGE_EQUIP" or isUnload and "BADGE_UNLOAD" or "BADGE_EXCHANGE"
	local text = pg.getGameString(confirmTextKey)

	ClientTextUtils.setText(txtNameUText, text)
	self.btnConfirmUButton:TryChangePage("button", canConfirm and 0 or 4)
	self.btnConfirmUButton:SetActive(canConfirm)

	self.btnConfirmUButton.interactable = canConfirm

	function self.btnConfirmUButton.luaClick()
		if canConfirm then
			self:setBadgeShow(isUnload and 0 or badgeId)
		end
	end
end

function EditBadgeBarComponent:setBadgeShow(badgeId)
	if not self.curSelectedEquipIndex then
		return
	end

	self.keepSelectedBadgeId = self.listUList.selectedItem and self.listUList.selectedItem.badgeId or badgeId

	pg.me:serverMsg("RPC_CS_SetBadgeShow", self:getBadgeShowMap(badgeId))
end

function EditBadgeBarComponent:getBadgeShowMap(badgeId)
	local badgeShowMap = {}
	local usedBadgeIds = {}
	local oldBadgeId = self.badgeShowMap[self.curSelectedEquipIndex] or 0

	for i = 1, Const.BADGE_SHOW_COUNT do
		local showBadgeId = self.badgeShowMap[i] or 0

		if i == self.curSelectedEquipIndex then
			showBadgeId = badgeId or 0
		elseif badgeId and badgeId > 0 and showBadgeId == badgeId then
			showBadgeId = oldBadgeId > 0 and oldBadgeId or 0
		end

		if showBadgeId and showBadgeId > 0 and not usedBadgeIds[showBadgeId] then
			badgeShowMap[i] = showBadgeId
			usedBadgeIds[showBadgeId] = true
		end
	end

	return badgeShowMap
end

function EditBadgeBarComponent:onBadgeShowMapChanged()
	self.playerInfo.badgeShowMap = pg.me.badgeShowMap or {}

	self:refreshBadgeBarPanel(self.curSelectedEquipIndex)
end

return EditBadgeBarComponent
