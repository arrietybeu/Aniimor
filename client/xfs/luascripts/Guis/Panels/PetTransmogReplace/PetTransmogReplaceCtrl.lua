-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogReplace\\PetTransmogReplaceCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogSchemeListComponent = require("Guis.Panels.PetTransmog.Component.PetTransmogSchemeListComponent")
local Const = require("Common.Const.Const")
local PetTransmogReplaceCtrl = Class.LightClass("PetTransmogReplaceCtrl", UICtrl)

PetTransmogReplaceCtrl.messages = {
	[MessageName.PET_TRANSMOG_SCHEME_LIST_CHANGED] = {
		"onSchemeListChanged",
		true
	},
	[MessageName.PET_TRANSMOG_SCHEME_APPLIED] = {
		"onSchemeApplied",
		true
	}
}

local DEFAULT_SCHEME_INDEX = Const.PetTransmogCustomDefultSchemeIndex
local REPLACE_MODE = PetTransmogUtils.REPLACE_MODE

function PetTransmogReplaceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.onReplacedCallback = info and info.onReplaced or nil
	self.imageKey = info and info.imageKey or nil
	self.needDestroyDownloadSprite = {}
	self.photoCache = {}
	self.itemPhotoTokens = {}

	self.model:setContext(info and info.petId or nil, info and info.mode or nil, info and info.newTempIndex or 0)
end

function PetTransmogReplaceCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnCancel then
		function self.view.btnCancel.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnConfirm then
		function self.view.btnConfirm.luaClick()
			self:onBtnConfirm()
		end
	end

	if self.view.customList then
		function self.view.customList.luaRenderItem(button, index, data)
			self:onRenderCustomItem(button, index, data)
		end
	end
end

function PetTransmogReplaceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info then
		self.onReplacedCallback = info.onReplaced or self.onReplacedCallback
		self.imageKey = info.imageKey or self.imageKey

		self.model:setContext(info.petId or self.model:getPetId(), info.mode or self.model:getMode(), info.newTempIndex or self.model:getNewTempIndex())
	end
end

function PetTransmogReplaceCtrl:onShow()
	self:applyInitialSelection()
	self:refreshList()
end

function PetTransmogReplaceCtrl:applyInitialSelection()
	if self.model:getSelected() then
		return
	end

	local fallback

	for _, scheme in ipairs(self.model:getCustomSchemes() or EMPTY_TABLE) do
		if scheme.index and scheme.index > DEFAULT_SCHEME_INDEX and scheme.exists then
			if scheme.isApplying then
				self.model:setSelected(scheme.index)

				return
			end

			fallback = fallback or scheme.index
		end
	end

	if fallback then
		self.model:setSelected(fallback)
	end
end

function PetTransmogReplaceCtrl:onDestroy()
	for _, sprite in ipairs(self.needDestroyDownloadSprite or EMPTY_TABLE) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	self.needDestroyDownloadSprite = nil
	self.photoCache = nil
	self.itemPhotoTokens = nil

	UICtrl.onDestroy(self)
end

function PetTransmogReplaceCtrl:refreshList()
	if not self.view.customList then
		return
	end

	local schemes = self.model:getCustomSchemes() or {}
	local list = {}

	for _, scheme in ipairs(schemes) do
		if scheme.index and scheme.index > DEFAULT_SCHEME_INDEX then
			list[#list + 1] = scheme
		end
	end

	self.view.customList:SetList(list)
end

function PetTransmogReplaceCtrl:buildPartList(scheme)
	local petId = self.model:getPetId()
	local holeIds = scheme and scheme.holeIds or nil
	local list = {}

	for i = 1, Const.PetTransmogSlotType.Max do
		local slotId = holeIds and holeIds[i] or nil
		local cfg = PetTransmogUtils.getSlotConfig(slotId)

		list[i] = {
			index = i,
			quality = cfg and cfg.quality or 0,
			unlocked = PetTransmogUtils.isHoleDisplayUnlocked(petId, i),
			name = PetTransmogUtils.getHoleName(petId, i)
		}
	end

	return list
end

function PetTransmogReplaceCtrl:onRenderCustomItem(button, _, data)
	if not data then
		return
	end

	local ref = button:GetComponent("ObjectReference")

	if not ref then
		return
	end

	local txtPlanName = ref:GetRefValue("txtPlanName")
	local listUList = ref:GetRefValue("listUList")

	button:TryChangePage("Quality", data.quality or 0)

	button.isSelected = data.index == self.model:getSelected()

	function button.luaClick()
		self:onCustomSelected(data)
	end

	if txtPlanName then
		ClientTextUtils.setText(txtPlanName, data.name or "")
	end

	if listUList then
		function listUList.luaRenderItem(partButton, _, partData)
			if not partData then
				return
			end

			local partRef = partButton:GetComponent("ObjectReference")

			if not partRef then
				return
			end

			local textPartUSDFText = partRef:GetRefValue("textPartUSDFText")

			if textPartUSDFText then
				ClientTextUtils.setText(textPartUSDFText, partData.name or "")
			end

			partButton:TryChangePage("Emtpy", partData.unlocked and 0 or 1)

			if partData.unlocked then
				partButton:TryChangePage("Quality", partData.quality or 0)
			end
		end

		listUList:SetList(self:buildPartList(data))
	end

	PetTransmogSchemeListComponent.refreshSchemeIcon(self, button, ref, data, true)
end

function PetTransmogReplaceCtrl:onCustomSelected(scheme)
	if not scheme or not scheme.index then
		return
	end

	self.model:setSelected(scheme.index)
end

function PetTransmogReplaceCtrl:onBtnConfirm()
	local petId = self.model:getPetId()
	local customIndex = self.model:getSelected()

	if not petId or not customIndex or customIndex <= DEFAULT_SCHEME_INDEX then
		return
	end

	local mode = self.model:getMode()
	local tempIndex

	if mode == REPLACE_MODE.SAVE_TEMP then
		tempIndex = self.model:getNewTempIndex()

		if not tempIndex or tempIndex <= 0 then
			return
		end
	elseif mode ~= REPLACE_MODE.APPLY_CURR then
		return
	end

	local imageKey = self.imageKey

	self:dismiss()

	if mode == REPLACE_MODE.SAVE_TEMP then
		pg.game.petTransmog:requestReplaceCustom(petId, tempIndex, customIndex, imageKey)
	else
		pg.game.petTransmog:requestreplaceAndUseCurrTransmogScheme(petId, customIndex, imageKey)
	end
end

function PetTransmogReplaceCtrl:onSchemeListChanged()
	if self.model:getMode() ~= REPLACE_MODE.SAVE_TEMP then
		return
	end

	if self.onReplacedCallback then
		self.onReplacedCallback()
	end

	self:dismiss()
end

function PetTransmogReplaceCtrl:onSchemeApplied()
	if self.onReplacedCallback then
		self.onReplacedCallback()
	end

	self:dismiss()
end

return PetTransmogReplaceCtrl
