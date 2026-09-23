-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementTidyUp\\PetManagementTidyUpCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local PetManagementTidyUpCtrl = Class.LightClass("PetManagementTidyUpCtrl", UICtrl)

PetManagementTidyUpCtrl.messages = {}

function PetManagementTidyUpCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.boxId = info.boxId or 1
	self.sortId = nil
	self.isDescending = true
	self.view.btnCurrentUButton.interactable = false
	self.view.btnAllUButton.interactable = false

	self:setOptions()
end

function PetManagementTidyUpCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_MANAGEMENT_TIDY_UP)
end

function PetManagementTidyUpCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnCurrentUButton.luaClick()
		if self:hasExpiredBox(self.boxId) then
			pg.global.showBubbleMessageById(NoticeDef.INVALID_PET_BOX_CANT_TIDY_UP)

			return
		end

		if self:hasManualLockedBox(self.boxId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("ORGANIZE_LOCK_BOX"))

			return
		end

		self:tidyUp(self.boxId)
	end

	function self.view.btnAllUButton.luaClick()
		if self:hasExpiredBox(0) or self:hasManualLockedBox(0) then
			pg.global.showBubbleMessageById(NoticeDef.INVALID_PET_BOX_CANT_TIDY_UP)
		end

		self:tidyUp(0)
	end
end

function PetManagementTidyUpCtrl:setOptions()
	function self.view.sortOptionList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtTypeUText = objectReference:GetRefValue("txtTypeUText")
		local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")

		ClientTextUtils.setText(txtTypeUText, data.name)

		button.isSelected = false

		button:TryChangePage("button", 0)
		btnSwitchUButton:TryChangePage("Sort", self.isDescending and 0 or 1)

		function button.luaClick()
			if self.sortId == index then
				self.isDescending = not self.isDescending

				btnSwitchUButton:TryChangePage("Sort", self.isDescending and 0 or 1)
				self:checkBotButtonsStatus()

				return
			end

			self:deselectAllSortOptions()

			button.isSelected = true

			button:TryChangePage("button", 5)

			self.sortId = index

			btnSwitchUButton:TryChangePage("Sort", self.isDescending and 0 or 1)
			self:checkBotButtonsStatus()
		end
	end

	self.view.sortOptionList:SetList(self.model:getOptionsInfo())
end

function PetManagementTidyUpCtrl:deselectAllSortOptions()
	local btns = self.view.sortOptionList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i].isSelected = false

		btns[i]:TryChangePage("button", 0)
	end
end

function PetManagementTidyUpCtrl:checkBotButtonsStatus()
	if not self.sortId then
		self.view.btnCurrentUButton.interactable = false
		self.view.btnAllUButton.interactable = false

		return
	end

	self.view.btnCurrentUButton.interactable = true
	self.view.btnAllUButton.interactable = true
end

function PetManagementTidyUpCtrl:tidyUp(index)
	if not self.sortId then
		return
	end

	local desc = ""
	local type = self.model:getOptionsInfo()[self.sortId + 1].name
	local order = self.isDescending and pg.getGameString("DESCENDING") or pg.getGameString("ASCENDING")

	if index == 0 then
		desc = string.format(pg.getGameString("ORGANIZE_ALL_BOX"), type, order)
	else
		desc = string.format(pg.getGameString("ORGANIZE_BOX"), type, order, self.model:getBoxNameById(index))
	end

	local hintShowTs = pg.global.prefsCacheUtils:getInt("boxTidyUpHintHideFlagTs", 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if hintShowTs + 86400 <= Time.secondCache then
		pg.global.showConfirmMsgRaw(string.format(pg.getGameString("TIDY_UP_TITLE"), type, order), desc, function()
			pg.me:serverMsg("RPC_CS_PetBoxAutoAdjust", index, self.sortId, self.isDescending and 1 or 0)

			if self.hintHideFlag then
				pg.global.prefsCacheUtils:setInt("boxTidyUpHintHideFlagTs", Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
				pg.global.prefsCacheUtils:save()
			end

			self:closePanel()
		end, nil, function()
			return
		end, nil, nil, {
			hint = true,
			hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
			hintCb = function(isSelected)
				if isSelected then
					self.hintHideFlag = true
				else
					self.hintHideFlag = nil
				end
			end
		})
	else
		pg.me:serverMsg("RPC_CS_PetBoxAutoAdjust", index, self.sortId, self.isDescending and 1 or 0)
		self:closePanel()
	end
end

function PetManagementTidyUpCtrl:hasExpiredBox(boxIndex)
	local petBoxMap = pg.me.petBoxMap

	if boxIndex == 0 then
		for _, boxInfo in petBoxMap:items() do
			if boxInfo:isTempLocked() then
				return true
			end
		end

		return false
	else
		local boxInfo = petBoxMap[boxIndex]

		return boxInfo and boxInfo:isTempLocked()
	end
end

function PetManagementTidyUpCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.hintHideFlag = nil
end

function PetManagementTidyUpCtrl:hasManualLockedBox(boxIndex)
	local petBoxMap = pg.me.petBoxMap

	if boxIndex == 0 then
		for _, boxInfo in petBoxMap:items() do
			if boxInfo:isManualLocked() then
				return true
			end
		end

		return false
	else
		local boxInfo = petBoxMap[boxIndex]

		return boxInfo and boxInfo:isManualLocked()
	end
end

return PetManagementTidyUpCtrl
