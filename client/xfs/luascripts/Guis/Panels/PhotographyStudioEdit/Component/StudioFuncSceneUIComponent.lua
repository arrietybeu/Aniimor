-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioFuncSceneUIComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ItemData = require("Data.item_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local StudioFuncSceneUIComponent = Class.LightClass("StudioFuncSceneUIComponent", UIComponent)
local TIP_DURATION = 3

function StudioFuncSceneUIComponent:onCtor(info)
	self.avatarScene = self.ctrl:getAvatarScene()
	self.selectedBgId = self.avatarScene and self.avatarScene.bgId or nil
end

function StudioFuncSceneUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
end

function StudioFuncSceneUIComponent:initView()
	self.backgrounds = {}
	self.allBackgrounds = {}

	for bgId, bgData in pairs(AvatarUtils.getAllBackgroundData()) do
		self.allBackgrounds[#self.allBackgrounds + 1] = {
			id = bgId,
			name = ItemData[bgId] and ItemData[bgId].itemName,
			res = bgData.bgPrefab,
			icon = bgData.icon
		}
	end

	function self.listUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		iconUImage.url = data.icon

		ClientTextUtils.setText(txtNameUBaseText, data.name and pg.getLocalizationText(data.name) or "")

		local isUnlocked = data.isUnlocked
		local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Background, nil, data.id)

		pg.global.setRedDot(itemPath, button, PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.Background, data.id), RedDotConst.RedDotStyle.NEW)
		button:TryChangePage("Lock", isUnlocked and 0 or 1)
		button:TryChangePage("Tips", 0)

		button.skipInListSwitch = not isUnlocked
		button.isSelected = self.selectedBgId == data.id

		function button.luaClick()
			self:onClickBackground(button, data)
		end
	end
end

function StudioFuncSceneUIComponent:refreshUI()
	self.backgrounds = {}

	for _, data in ipairs(self.allBackgrounds) do
		if PhotographyAssetRedDotUtils.isAssetVisible(PhotographyAssetRedDotUtils.AssetType.Background, data.id) then
			self.backgrounds[#self.backgrounds + 1] = data
		end
	end

	PhotographyAssetRedDotUtils.sortUnlockedFirst(self.backgrounds, PhotographyAssetRedDotUtils.AssetType.Background)
	self.listUList:SetList(self.backgrounds)

	self.haveRefreshed = true
end

function StudioFuncSceneUIComponent:refreshAssetUnlockState()
	self:refreshUI()
end

function StudioFuncSceneUIComponent:onClickBackground(button, data)
	if not PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Background, data.id) then
		PhotographyStudioUtils.showLockedAssetTip(data.id, button)

		return
	end

	if not self.avatarScene then
		return
	end

	self.avatarScene:setBackground(data.res, data.id)
	self.avatarScene:applyPhotographyStudioBackgroundLight(data.id)

	self.selectedBgId = data.id

	PhotographyAssetRedDotUtils.markAssetViewed(PhotographyAssetRedDotUtils.AssetType.Background, data.id)
	pg.global.setRedDot(PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Background, nil, data.id), button, false, RedDotConst.RedDotStyle.NEW)
	self.ctrl:onPhotoAssetViewed(PhotographyAssetRedDotUtils.AssetType.Background)
	self.ctrl:recordHistoryStep("background_select")
	self:refreshButtonSelection(button)
	self:hideTip()
	button:TryChangePage("Tips", 1)

	self.tipButton = button
	self.tipBgId = data.id

	local tipBgId = data.id
	local timerId

	timerId = self:startTimer(function()
		if self.tipTimer ~= timerId then
			return
		end

		local currentData = button.dataFromUList

		if currentData and currentData.id == tipBgId then
			button:TryChangePage("Tips", 0)
		end

		self.tipButton = nil
		self.tipBgId = nil
		self.tipTimer = nil
	end, TIP_DURATION)
	self.tipTimer = timerId
end

function StudioFuncSceneUIComponent:refreshButtonSelection(selectedButton)
	local buttons = self.listUList:GetAllButtons()

	for index = 0, buttons.Length - 1 do
		buttons[index].isSelected = false
	end

	selectedButton.isSelected = true
end

function StudioFuncSceneUIComponent:hideTip()
	if self.tipButton then
		local currentData = self.tipButton.dataFromUList

		if currentData and currentData.id == self.tipBgId then
			self.tipButton:TryChangePage("Tips", 0)
		end

		self.tipButton = nil
		self.tipBgId = nil
	end

	if self.tipTimer then
		self:killTimer(self.tipTimer)

		self.tipTimer = nil
	end
end

function StudioFuncSceneUIComponent:saveToPreset(preset)
	preset.backgroundId = self.selectedBgId
end

function StudioFuncSceneUIComponent:applyPreset(preset)
	self.selectedBgId = tonumber(preset.backgroundId)

	if NotNil(self.listUList) and self.haveRefreshed then
		self.listUList:RefreshList()
	end
end

function StudioFuncSceneUIComponent:onDeselected()
	return
end

return StudioFuncSceneUIComponent
