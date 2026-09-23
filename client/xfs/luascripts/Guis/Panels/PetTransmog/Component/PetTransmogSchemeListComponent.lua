-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmog\\Component\\PetTransmogSchemeListComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogModel = require("Guis.Panels.PetTransmog.PetTransmogModel")
local Const = require("Common.Const.Const")
local CommonSwitch = require("Common.CommonSwitch")
local PetTransmogSchemeListComponent = Class.LightClass("PetTransmogSchemeListComponent", UIComponent)

local function refreshSchemeIcon(ctrl, button, ref, data, isCustom)
	local itemIcon = ref:GetRefValue("itemIcon")

	if not itemIcon then
		return
	end

	itemIcon.sprite = nil
	itemIcon.url = nil

	if not isCustom then
		itemIcon.url = data.pic

		return
	end

	if data.defaultPic then
		itemIcon.url = data.defaultPic
	end

	local tokens = ctrl.itemPhotoTokens

	if not tokens then
		return
	end

	local instanceId = button.gameObject:GetInstanceID()

	tokens[instanceId] = (tokens[instanceId] or 0) + 1

	local capturedToken = tokens[instanceId]

	if not data.photoId then
		return
	end

	local cached = ctrl.photoCache and ctrl.photoCache[data.photoId]

	if cached then
		itemIcon.sprite = cached

		return
	end

	ServiceUtils.kvServiceFind(data.photoId, function(status, response)
		if not ctrl.needDestroyDownloadSprite then
			return
		end

		if not ctrl.itemPhotoTokens then
			return
		end

		if ctrl.itemPhotoTokens[instanceId] ~= capturedToken then
			return
		end

		if not status.status or not response.value then
			return
		end

		local cachedAfter = ctrl.photoCache[data.photoId]

		if cachedAfter then
			itemIcon.sprite = cachedAfter

			return
		end

		ClientUtils.pullPicture(response.value, function(_, sprite)
			if not sprite then
				return
			end

			if not ctrl.needDestroyDownloadSprite or not ctrl.itemPhotoTokens then
				pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

				return
			end

			if ctrl.itemPhotoTokens[instanceId] ~= capturedToken then
				pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

				return
			end

			local cachedSprite = ctrl.photoCache[data.photoId]

			if cachedSprite then
				pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

				itemIcon.sprite = cachedSprite

				return
			end

			ctrl.photoCache[data.photoId] = sprite
			ctrl.needDestroyDownloadSprite[#ctrl.needDestroyDownloadSprite + 1] = sprite
			itemIcon.sprite = sprite
		end)
	end)
end

PetTransmogSchemeListComponent.refreshSchemeIcon = refreshSchemeIcon

function PetTransmogSchemeListComponent:initView()
	if self.view.btnComfilmPlan then
		function self.view.btnComfilmPlan.luaClick()
			self:onBtnComfilmPlan()
		end
	end

	if self.view.btnDelPlan then
		function self.view.btnDelPlan.luaClick()
			self:onBtnDelPlan()
		end
	end

	if self.view.schemeList then
		function self.view.schemeList.luaRenderItem(button, index, data)
			self:onRenderSchemeItem(button, index, data)
		end
	end

	if self.view.planStarList then
		function self.view.planStarList.luaRenderItem(button, index, data)
			self:onRenderPlanStarItem(button, data)
		end
	end
end

function PetTransmogSchemeListComponent:selectFirstScheme()
	local list = self.ctrl:getCurrentSchemes()
	local source = self.ctrl:getCurrentSource()

	if not list or not list[1] then
		self.model:setSelected(nil, nil)
	else
		local pickIndex = 1

		if source == PetTransmogModel.SCHEME_SOURCE.CUSTOM then
			for i, scheme in ipairs(list) do
				if scheme.isApplying then
					pickIndex = i

					break
				end
			end
		end

		self.model:setSelected(source, pickIndex)
	end

	self:refreshSchemeList()
	self:refreshPlanPartInfo()
	self.ctrl:previewTransmogScheme(PetTransmogUtils.toRawScheme(self.model:getSelectedScheme()))
end

function PetTransmogSchemeListComponent:refreshSchemeList()
	if not self.view.schemeList then
		return
	end

	self.view.schemeList:SetList(self.ctrl:getCurrentSchemes() or {})
end

function PetTransmogSchemeListComponent:refreshPlanPartInfo(overrideScheme)
	local scheme = overrideScheme or self.model:getSelectedScheme()

	if self.view.btnVideo then
		local showVideo = not overrideScheme and CommonSwitch.Pet_Transmog_Video and self.model:getCurrentTab() == PetTransmogModel.PLAN_TAB.PREVIEW and not string.isNilOrEmpty(PetTransmogUtils.getPreviewSchemeVideoPath(scheme))

		self.view.btnVideo:SetActive(showVideo)
	end

	if not self.view.planStarList then
		return
	end

	self.view.planStarList:SetList(self.ctrl:buildHoleData(scheme))

	if self.view.txtPlanNum then
		ClientTextUtils.setText(self.view.txtPlanNum, tostring(scheme and scheme.transmogValue or 0))
	end

	if overrideScheme then
		return
	end

	if self.view.planPanelUComponent then
		local state = 0

		if self.model:getCurrentTab() == PetTransmogModel.PLAN_TAB.PREVIEW then
			state = 2
		elseif scheme and scheme.isApplying then
			state = scheme.index == Const.PetTransmogCustomDefultSchemeIndex and 1 or 3
		end

		self.view.planPanelUComponent:TryChangePage("BtnState", state)
	end

	local isCustom = self.model:getCurrentTab() == PetTransmogModel.PLAN_TAB.CUSTOM
	local show = isCustom and scheme and not scheme.isApplying
	local showDel = show and scheme.index ~= Const.PetTransmogCustomDefultSchemeIndex

	if self.view.btnDelPlan then
		self.view.btnDelPlan:SetActive(showDel)
	end

	if self.view.btnComfilmPlan then
		self.view.btnComfilmPlan:SetActive(show)
	end
end

function PetTransmogSchemeListComponent:onRenderSchemeItem(button, index, data)
	local ref = button:GetComponent("ObjectReference")
	local txtRecommand = ref:GetRefValue("txtRecommand")
	local txtNow = ref:GetRefValue("txtNow")
	local txtUnlock = ref:GetRefValue("txtUnlock")
	local txtPlanName = ref:GetRefValue("txtPlanName")
	local imgRecommandImage = ref:GetRefValue("imgRecommandUImage")
	local imgNowImage = ref:GetRefValue("imgNowUImage")
	local imgUnlockImage = ref:GetRefValue("imgUnlockUImage")
	local uiIndex = index + 1

	button:TryChangePage("Quality", data.quality or 0)

	button.isSelected = uiIndex == self.model:getSelectedIndex()

	local isCustom = self.model:getCurrentTab() == PetTransmogModel.PLAN_TAB.CUSTOM
	local isLocked = isCustom and not data.exists

	button.interactable = not isLocked

	function button.luaClick()
		self:onSchemeSelected(uiIndex, data)
	end

	if txtPlanName then
		ClientTextUtils.setText(txtPlanName, data.name or "")
	end

	local showUnlock, showNow, showRecommand = false, false, false

	if isCustom then
		if not data.exists then
			showUnlock = true
		elseif data.isApplying then
			showNow = true
		elseif data.isRecommended then
			showRecommand = true
		end
	end

	button:TryChangePage("Empty", showUnlock and 1 or 0)

	if txtUnlock and imgUnlockImage then
		imgUnlockImage.gameObject:SetActiveEx(false)

		if showUnlock then
			ClientTextUtils.setText(txtUnlock, pg.getGameString("PETTRANSMOGRIFY_LOCKED"))
		end
	end

	if txtNow and imgNowImage then
		imgNowImage.gameObject:SetActiveEx(showNow)

		if showNow then
			ClientTextUtils.setText(txtNow, pg.getGameString("PETTRANSMOGRIFY_ACTIVE"))
		end
	end

	if txtRecommand and imgRecommandImage then
		imgRecommandImage.gameObject:SetActiveEx(false)

		if showRecommand then
			ClientTextUtils.setText(txtRecommand, pg.getGameString("PETTRANSMOGRIFY_RECOMMEND"))
		end
	end

	refreshSchemeIcon(self.ctrl, button, ref, data, isCustom)
end

function PetTransmogSchemeListComponent:onRenderPlanStarItem(button, data)
	if not data then
		return
	end

	local ref = button:GetComponent("ObjectReference")
	local txtPartName = ref:GetRefValue("txtPartName")
	local textQuality = ref:GetRefValue("textQuality")

	if txtPartName then
		ClientTextUtils.setText(txtPartName, pg.getLocalizationText(data.typename) or "")
	end

	button:TryChangePage("Quality", data.quality or 0)

	local unlocked = self.ctrl:getCurrentSource() == PetTransmogModel.SCHEME_SOURCE.PREVIEW or PetTransmogUtils.isHoleDisplayUnlocked(self.model:getPetId(), data.index)

	button:TryChangePage("Emtpy", unlocked and 0 or 1)

	if textQuality then
		local des = ""

		if unlocked then
			des = data.name and pg.getLocalizationText(data.name) or ""
		else
			des = pg.getGameString("PETTRANSMOGRIFY_PART_LOCK")
		end

		ClientTextUtils.setText(textQuality, des)
	end
end

function PetTransmogSchemeListComponent:onSchemeSelected(index, scheme)
	if not scheme or not index then
		return
	end

	local source = self.ctrl:getCurrentSource()

	if source == self.model:getSelectedSource() and index == self.model:getSelectedIndex() then
		return
	end

	if source == PetTransmogModel.SCHEME_SOURCE.CUSTOM and not scheme.exists then
		self:_updateItemSelected(index, false)

		return
	end

	local oldIndex = source == self.model:getSelectedSource() and self.model:getSelectedIndex() or nil

	self.model:setSelected(source, index)
	self:_updateItemSelected(oldIndex, false)
	self:_updateItemSelected(index, true)
	self:refreshPlanPartInfo()
	self.ctrl:previewTransmogScheme(PetTransmogUtils.toRawScheme(scheme))
end

function PetTransmogSchemeListComponent:_updateItemSelected(uiIndex, isSelected)
	if not uiIndex or not self.view.schemeList then
		return
	end

	local res, button = self.view.schemeList:TryGetChildAt(uiIndex - 1)

	if not res or not button then
		return
	end

	button.isSelected = isSelected
end

function PetTransmogSchemeListComponent:onBtnComfilmPlan()
	local petId = self.model:getPetId()
	local scheme = self.model:getSelectedScheme()

	if not petId or not scheme or not scheme.index then
		return
	end

	if self.model:getSelectedSource() ~= PetTransmogModel.SCHEME_SOURCE.CUSTOM then
		return
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_APPLY_SCHEME"), pg.getGameString("PETTRANSMOGRIFY_CONFIRM_REQUIRED"), function()
		self:doApplyCurrScheme(petId, scheme.index)
	end)
end

function PetTransmogSchemeListComponent:doApplyCurrScheme(petId, index)
	pg.game.petTransmog:requestUseCustom(petId, index)
end

function PetTransmogSchemeListComponent:onBtnDelPlan()
	local petId = self.model:getPetId()
	local scheme = self.model:getSelectedScheme()

	if not petId or not scheme or not scheme.index then
		return
	end

	if scheme.index <= Const.PetTransmogCustomDefultSchemeIndex then
		return
	end

	if self.model:getSelectedSource() ~= PetTransmogModel.SCHEME_SOURCE.CUSTOM then
		return
	end

	local schemeIndex = scheme.index
	local okText = pg.getGameString("PETTRANSMOGRIFY_DELETE_ENTER_OK")

	pg.global.ui:open(UIConst.UI_ID_COMMON_INPUT, {
		confirmBtnText = "COMMON_CONFIRM",
		title = "PETTRANSMOGRIFY_TIP",
		detail = "PETTRANSMOGRIFY_DELETE_CONFIRM",
		placeHolder = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_DELETE_ENTER"), okText),
		requireText = okText,
		confirmCb = function()
			pg.game.petTransmog:requestDelCustom(petId, schemeIndex)
		end
	})
end

return PetTransmogSchemeListComponent
