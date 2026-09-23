-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditCircumstancesComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local AppearanceVariableData = require("Data.appearance_variable_data")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local EditCircumstancesComponent = Class.LightClass("EditCircumstancesComponent", UIComponent)

EditCircumstancesComponent.messages = {
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onStudioChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CONTENT_CHANGED] = {
		"onStudioContentChanged",
		true
	},
	[MessageName.ON_PROFILE_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onProfileStudioChanged",
		true
	}
}

function EditCircumstancesComponent:onCtor(info)
	self.isDestroyed = false
	self.playerInfo = info.playerInfo
	self.btnConfirm = info.btnConfirm
	self.getWayBottomText = info.getWayBottomText
	self.usingUWidget = info.usingUWidget
	self.btnConfirmText = self.btnConfirm:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.studioContentLoading = {}
	self.studioContentLoaded = {}

	function self.refreshPanelHandler(order)
		self.order = order

		self:refreshPanel()
	end

	function self.confirmHandler()
		self:onConfirmBtnClick()
	end
end

function EditCircumstancesComponent:initView()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnStudioUButton = self.objectReference:GetRefValue("btnStudioUButton")
	self.btnRehandlingUButton = self.objectReference:GetRefValue("btnRehandlingUButton")

	function self.listUList.luaRenderItem(button, index, data)
		self:renderStudioItem(button, data)
	end

	function self.btnStudioUButton.luaClick()
		self:onStudioBtnClick()
	end

	function self.btnRehandlingUButton.luaClick()
		self:onRehandlingBtnClick()
	end
end

function EditCircumstancesComponent:getStudioItems()
	local result = {}
	local studios = pg.me and pg.me:getAllStudios() or {}

	for studioUid, info in pairs(studios) do
		local content = pg.me:getCachedPhotographyStudioContent(studioUid)
		local coverVersion = type(content) == "table" and tonumber(content.coverVersion) or nil
		local name = info.name

		if not name or name == "" then
			name = pg.getGameString("PHOTO_STUDIO_DEFAULT_NAME")
		end

		result[#result + 1] = {
			studioUid = studioUid,
			name = name,
			isMine = tostring(info.masterUid) == tostring(pg.me.uid),
			slotId = info.slotId,
			coverImageId = PhotographyStudioUtils.genPhotographyStudioCoverImageId(studioUid),
			coverVersion = coverVersion
		}
	end

	table.sort(result, function(a, b)
		if a.isMine ~= b.isMine then
			return a.isMine
		end

		if a.isMine and a.slotId ~= b.slotId then
			return (a.slotId or math.huge) < (b.slotId or math.huge)
		end

		return tostring(a.studioUid) < tostring(b.studioUid)
	end)

	return result
end

function EditCircumstancesComponent:refreshPanel()
	if self.isDestroyed then
		return
	end

	local list = self:getStudioItems()

	for _, data in ipairs(list) do
		if data.coverVersion == nil and not self.studioContentLoaded[data.studioUid] then
			self:requestStudioContentForCover(data.studioUid)
		end
	end

	local selectedStudioUid = self:getEquippedStudioUid()
	local selectedIndex

	for index, data in ipairs(list) do
		if selectedStudioUid and tostring(data.studioUid) == selectedStudioUid then
			selectedIndex = index

			break
		end
	end

	if not selectedIndex and #list > 0 then
		selectedIndex = 1
	end

	self.selectedStudioUid = selectedIndex and list[selectedIndex].studioUid or nil

	self.listUList:SetList(list)

	if selectedIndex then
		self.listUList:GoToIndex(selectedIndex - 1)
	end

	self:refreshConfirmButtonState()
end

function EditCircumstancesComponent:renderStudioItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	local imgPhotoUImage = objectReference:GetRefValue("imgPhotoUImage")
	local adaptationBoxUXAdaptionRect = objectReference:GetRefValue("adaptationBoxUXAdaptionRect")

	ClientTextUtils.setText(textNameUBaseText, data.name or pg.getGameString("PHOTO_STUDIO_DEFAULT_NAME"))
	button:TryChangePage("Tag", 0)
	button:TryChangePage("State", self:isEquipped(data.studioUid) and 1 or 0)
	self:renderStudioCover(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect)

	button.isSelected = self.selectedStudioUid ~= nil and tostring(self.selectedStudioUid) == tostring(data.studioUid)

	function button.luaClick()
		self.selectedStudioUid = data.studioUid

		self:refreshConfirmButtonState()

		local infoPlayerCtrl = self.ctrl and self.ctrl.ctrl

		if infoPlayerCtrl and infoPlayerCtrl.applyPhotographyStudioPreview then
			infoPlayerCtrl:applyPhotographyStudioPreview(data.studioUid)
		end

		local buttons = self.listUList:GetAllButtons()

		for index = 0, buttons.Length - 1 do
			buttons[index].isSelected = false
		end

		button.isSelected = true
	end
end

function EditCircumstancesComponent:renderStudioCover(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect)
	local imageUrl = AppearanceVariableData.STUDIO_DEFAULT_IMAGE

	imgPhotoUImage:SetUrlWithCallback(imageUrl, function()
		self:updateCoverAdaptation(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect, imageUrl)
	end, nil, true)

	if data.coverVersion == nil and not self.studioContentLoaded[data.studioUid] then
		self:requestStudioContentForCover(data.studioUid)
	elseif data.coverVersion ~= nil then
		self:loadStudioCover(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect)
	end
end

function EditCircumstancesComponent:updateCoverAdaptation(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect, imageUrl)
	if self.isDestroyed or IsNil(button) or IsNil(imgPhotoUImage) or IsNil(adaptationBoxUXAdaptionRect) then
		return
	end

	if button.dataFromUList ~= data or imgPhotoUImage.url ~= imageUrl then
		return
	end

	local sprite = imgPhotoUImage.sprite

	if IsNil(sprite) or IsNil(sprite.texture) then
		return
	end

	local texture = sprite.texture

	adaptationBoxUXAdaptionRect.useCustomResolution = true
	adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

	adaptationBoxUXAdaptionRect:UpdateAdaptation()
end

function EditCircumstancesComponent:loadStudioCover(button, data, imgPhotoUImage, adaptationBoxUXAdaptionRect)
	local studioUid = data.studioUid
	local coverVersion = data.coverVersion

	PhotographyStudioUtils.loadPhotographyStudioCover(studioUid, coverVersion, function(sprite, success)
		if self.isDestroyed or not success or IsNil(button) or IsNil(imgPhotoUImage) or IsNil(adaptationBoxUXAdaptionRect) then
			return
		end

		local currentData = button.dataFromUList

		if currentData and tostring(currentData.studioUid) == tostring(studioUid) and currentData.coverVersion == coverVersion then
			if IsNil(sprite) or IsNil(sprite.texture) then
				return
			end

			imgPhotoUImage.url = nil
			imgPhotoUImage.sprite = sprite

			local texture = sprite.texture

			adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

			adaptationBoxUXAdaptionRect:UpdateAdaptation()
		end
	end)
end

function EditCircumstancesComponent:requestStudioContentForCover(studioUid)
	if self.studioContentLoading[studioUid] or self.studioContentLoaded[studioUid] then
		return
	end

	self.studioContentLoading[studioUid] = true

	pg.me:fetchStudioContent(studioUid, function(content, ok)
		self.studioContentLoading[studioUid] = nil

		if self.isDestroyed or not ok then
			return
		end

		self.studioContentLoaded[studioUid] = true

		self:refreshPanel()
	end)
end

function EditCircumstancesComponent:onDestroy()
	self.isDestroyed = true
end

function EditCircumstancesComponent:getEquippedStudioUid()
	local studioUid = pg.me and pg.me.profilePhotographyStudioUid or self.playerInfo.profilePhotographyStudioUid

	if studioUid == nil or tostring(studioUid) == "" then
		return PhotographyStudioUtils.getDefaultPhotographyStudioUid()
	end

	return tostring(studioUid)
end

function EditCircumstancesComponent:isUsingDefaultProfileStudioScene()
	local studioUid = pg.me and pg.me.profilePhotographyStudioUid or self.playerInfo.profilePhotographyStudioUid

	return studioUid == nil or tostring(studioUid) == ""
end

function EditCircumstancesComponent:isEquipped(studioUid)
	local equippedStudioUid = self:getEquippedStudioUid()

	return equippedStudioUid ~= nil and tostring(studioUid) == equippedStudioUid
end

function EditCircumstancesComponent:refreshConfirmButtonState()
	self.usingUWidget:SetActive(false)
	self.getWayBottomText:SetActive(false)
	self.btnConfirm:SetActive(true)
	self.btnConfirm:TryChangePage("IconState", 0)

	if not self.selectedStudioUid and self:isUsingDefaultProfileStudioScene() then
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))
		self.btnConfirm:TryChangePage("button", 4)

		self.btnConfirm.interactable = false

		self.usingUWidget:SetActive(true)
		self.btnConfirm:SetActive(false)
	elseif not self.selectedStudioUid then
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))
		self.btnConfirm:TryChangePage("button", 4)

		self.btnConfirm.interactable = false
	elseif self:isEquipped(self.selectedStudioUid) then
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))
		self.btnConfirm:TryChangePage("button", 4)

		self.btnConfirm.interactable = false

		self.usingUWidget:SetActive(true)
		self.btnConfirm:SetActive(false)
	else
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))
		self.btnConfirm:TryChangePage("button", 0)

		self.btnConfirm.interactable = true
	end
end

function EditCircumstancesComponent:onConfirmBtnClick()
	if not self.selectedStudioUid or self:isEquipped(self.selectedStudioUid) then
		return
	end

	local infoPlayerCtrl = self.ctrl and self.ctrl.ctrl

	if infoPlayerCtrl then
		infoPlayerCtrl:selectPhotographyStudioBackground(self.selectedStudioUid)
	end
end

function EditCircumstancesComponent:onStudioBtnClick()
	if not PhotographyStudioUtils.checkFunctionEnabled(true) then
		return
	end

	if not self.selectedStudioUid then
		return
	end

	self:prepareAppearanceOpen()
	pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, {
		enterPage = "photoStudioEdit",
		previewPhotographyStudio = true,
		photographyStudioUid = self.selectedStudioUid
	}, nil, function()
		self:startFrameTimer(self:getAppearanceCloseCallback(), 1)
	end)
end

function EditCircumstancesComponent:onRehandlingBtnClick()
	self:prepareAppearanceOpen()
	pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, {
		enterPage = "player",
		photographyStudioUid = self.selectedStudioUid
	}, nil, function()
		self:startFrameTimer(self:getAppearanceCloseCallback(), 1)
	end)
end

function EditCircumstancesComponent:prepareAppearanceOpen()
	local infoPlayerCtrl = self.ctrl and self.ctrl.ctrl

	if infoPlayerCtrl and infoPlayerCtrl.prepareAppearanceScene then
		infoPlayerCtrl:prepareAppearanceScene()
	end
end

function EditCircumstancesComponent:getAppearanceCloseCallback()
	local infoPlayerCtrl = self.ctrl and self.ctrl.ctrl

	return function()
		if infoPlayerCtrl and infoPlayerCtrl.restoreProfileAvatarScene then
			infoPlayerCtrl:restoreProfileAvatarScene()
		end
	end
end

function EditCircumstancesComponent:onStudioChanged()
	self:refreshPanel()
end

function EditCircumstancesComponent:onStudioContentChanged()
	self:refreshPanel()
end

function EditCircumstancesComponent:onProfileStudioChanged()
	self:refreshPanel()
end

return EditCircumstancesComponent
