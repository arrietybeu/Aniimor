-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoShow\\PhotoShowCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PhotoShowCtrl = Class.LightClass("PhotoShowCtrl", UICtrl)
local GamePadNavigation = require("Utils.GamePadNavigation")
local PetData = require("Data.pet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")

PhotoShowCtrl.messages = {}

function PhotoShowCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.uiState = 0

	self:initUI()

	if info.photoTraitInfo then
		self:refreshPhotoShowInfo(info.photoTraitInfo)
	end
end

function PhotoShowCtrl:addListener()
	function self.view.bgBtnUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnScaleUButton.luaClick()
		self:close()
	end

	function self.view.btnHideUIUButton.luaClick()
		self.uiState = 1 - self.uiState

		self.view.rootUComponent:TryChangePage("HideUI", self.uiState)
	end

	function self.view.btnShareUButton.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
	end

	function self.view.btnSaveUButton.luaClick()
		pg.global.ui.photo.photoComponent:savePhoto()
	end
end

function PhotoShowCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PhotoShowCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PhotoShowCtrl:onShow()
	return
end

function PhotoShowCtrl:onHide()
	return
end

function PhotoShowCtrl:initUI()
	self.view.photoUImage.sprite = self.info.sprite

	ClientTextUtils.setText(self.view.timeUText, os.date("%Y/%m/%d  %H:%M"))
	self.view.titleUText:SetActive(false)
	self.view.detailUText:SetActive(false)
	self.view.frontUWidget:SetActive(false)
end

function PhotoShowCtrl:refreshPhotoShowInfo(info)
	self.view.titleUText:SetActive(true)
	self.view.detailUText:SetActive(true)
	self.view.frontUWidget:SetActive(true)
	ClientTextUtils.setText(self.view.titleUText, pg.getLocalizationText(info.name))
	ClientTextUtils.setText(self.view.detailUText, pg.getLocalizationText(info.detail))

	if info.iconUrl then
		self.view.iconUImage.url = info.iconUrl
	end
end

function PhotoShowCtrl:initGamepadPhotoShow()
	self.navigation = GamePadNavigation.new(self)
	self.navigation.AREAS = {
		PHOTO_SHOW = 1
	}
	self.navigation.PHOTO_SHOW = {
		index = 1
	}
	self.navigation.AREA_TABLES = {
		self.navigation.PHOTO_SHOW
	}

	local itemData = {}

	for i = 1, self.view.photoShowListShare.itemCount do
		table.insert(itemData, self.view.photoShowListShare.itemData[i - 1])
	end

	self.navigation:setListArea(self.navigation.PHOTO_SHOW, self.view.photoShowListShare, itemData, self.view.photoShowKeyListUList, nil, function(uList, curIndex)
		self.view.photoShowCloseBtn.luaClick()
	end, true)
end

function PhotoShowCtrl:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self:gamepadFocusPhotoShow()
	end
end

function PhotoShowCtrl:gamepadFocusPhotoShow()
	self.navigation:specificSet(self.navigation.AREAS.PHOTO_SHOW, 1, 1)
	self.navigation:reFocus()
	self:startTimer(function()
		local _, button = self.view.photoShowListShare:TryGetChildAt(0)

		if button then
			button:TryChangePage("button", 3)
		end
	end, 0.1)
end

return PhotoShowCtrl
