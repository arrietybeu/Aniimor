-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\Component\\TradeMarketAppearanceDisplayComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarPreviewComponent = require("Guis.Panels.CashShop.Component.AvatarPreviewComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local AppearanceData = require("Data.appearance_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ItemData = require("Data.item_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local DEFAULT_PREVIEW_BACKGROUND = "$T_LVUIMall_BackGround_YueKa_CA.png"
local GENDER_FEMALE = 1
local GENDER_MALE = 2
local BODY_FEMALE = 11
local BODY_MALE = 21
local TradeMarketAppearanceDisplayComponent = Class.LightClass("TradeMarketAppearanceDisplayComponent", UIComponent)

function TradeMarketAppearanceDisplayComponent:findObjects()
	return
end

function TradeMarketAppearanceDisplayComponent:initView()
	self._entered = false
	self._ready = false
	self.avatarPreview = AvatarPreviewComponent.new(self.ctrl, self.transform, {
		sceneType = UISceneConst.CASH_SCENE
	})
end

function TradeMarketAppearanceDisplayComponent:bindObjectReference(objectReference)
	if not objectReference or self.objectReference == objectReference then
		return
	end

	self:_clearObjectListeners()

	self.objectReference = objectReference

	self:_findAppearanceObjects()
	self:_addObjectListeners()

	self._ready = true
end

function TradeMarketAppearanceDisplayComponent:_findAppearanceObjects()
	local objectReference = self.objectReference

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.txtDescNum = objectReference:GetRefValue("txtDescNum")
	self.txtDescType = objectReference:GetRefValue("txtDescType")
	self.txtName = objectReference:GetRefValue("txtName")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnTriangle = objectReference:GetRefValue("btnTriangle")
	self.fashionUImage = objectReference:GetRefValue("fashionUImage")
end

function TradeMarketAppearanceDisplayComponent:_addObjectListeners()
	self._btnTriangleState = 0

	function self.btnTriangle.luaClick()
		self._btnTriangleState = 1 - self._btnTriangleState

		self.rootUComponent:TryChangePage("BtnTriangle", self._btnTriangleState)
	end

	function self.listUList.luaRenderItem(button, index, data)
		self:_renderSuitAppearanceItem(button, index, data)
	end
end

function TradeMarketAppearanceDisplayComponent:_clearObjectListeners()
	if self.btnTriangle then
		self.btnTriangle.luaClick = nil
	end

	if self.listUList then
		self.listUList.luaRenderItem = nil
	end
end

function TradeMarketAppearanceDisplayComponent:setData(data)
	data = data or {}

	local itemId = data.itemId
	local isPetAppearance = data.isPetAppearance == true
	local dataChanged = self.itemId ~= itemId or self.isPetAppearance ~= isPetAppearance

	if dataChanged and self._entered then
		self:_clearAvatarPreview()
		self.avatarPreview:registerGesture()
	end

	self.itemId = itemId
	self.isPetAppearance = isPetAppearance

	if dataChanged then
		self._genderItemId = nil
	end

	self:_initializeGender(self.itemId)
end

function TradeMarketAppearanceDisplayComponent:onEnter(data)
	if data then
		self:setData(data)
	end

	if self._entered then
		self:refresh()

		return
	end

	self._entered = true

	self.avatarPreview:registerGesture()
	self:refresh()
end

function TradeMarketAppearanceDisplayComponent:onExit()
	if not self._entered then
		return
	end

	self._entered = false

	self:_clearAvatarPreview()
end

function TradeMarketAppearanceDisplayComponent:onDestroy()
	self._entered = false

	self:_clearObjectListeners()
	self:_clearAvatarPreview()

	self.avatarPreview = nil
	self.objectReference = nil
	self.rootUComponent = nil
	self.txtDescNum = nil
	self.txtDescType = nil
	self.txtName = nil
	self.listUList = nil
	self.btnTriangle = nil
	self.fashionUImage = nil

	UIComponent.onDestroy(self)
end

function TradeMarketAppearanceDisplayComponent:isReady()
	return self._ready == true
end

function TradeMarketAppearanceDisplayComponent:canSwitchGender()
	return self._canSwitchGender == true
end

function TradeMarketAppearanceDisplayComponent:isFemaleGender()
	return self.curGender == GENDER_FEMALE
end

function TradeMarketAppearanceDisplayComponent:switchGender()
	if not self:canSwitchGender() then
		return false
	end

	self.curGender = self.curGender == GENDER_FEMALE and GENDER_MALE or GENDER_FEMALE

	self:onGenderSwitched()

	return true
end

function TradeMarketAppearanceDisplayComponent:refresh()
	self:_initializeGender(self.itemId)

	if not self._ready or not self.itemId then
		return
	end

	self:refreshAppearanceInfo()
	self:refreshModelView()
end

function TradeMarketAppearanceDisplayComponent:_clearAvatarPreview()
	self._previewToken = (self._previewToken or 0) + 1

	local avatarPreview = self.avatarPreview

	if not avatarPreview then
		return
	end

	local avatarScene = avatarPreview.avatarScene

	if avatarScene then
		if self.isPetAppearance then
			avatarPreview:clearTradeMarketPetAccessoryPreview()
		else
			avatarPreview:clearPreviewState("all")
		end

		avatarPreview:hideAllEntities()

		local presetKeys = {
			avatarPreview.curPresetKey,
			avatarPreview.templatePresetKey
		}
		local removedKeys = {}

		for _, presetKey in pairs(presetKeys) do
			if presetKey and not removedKeys[presetKey] and avatarScene.getEntity and avatarScene:getEntity(presetKey) and avatarScene.removeEntity then
				removedKeys[presetKey] = true

				avatarScene:removeEntity(presetKey)
			end
		end

		avatarPreview.templatePresetKey = nil

		if avatarScene.syncLight then
			avatarScene:syncLight(false)
		elseif avatarScene.hideAllRoleLights then
			avatarScene:hideAllRoleLights()
		end

		if avatarScene.switchBackground then
			avatarScene:switchBackground(nil)
		end
	end

	avatarPreview:unRegisterGesture()
end

function TradeMarketAppearanceDisplayComponent:_getPreviewBackground(itemId)
	local suitData = AppearanceSuitData[itemId]

	if not suitData then
		local appearanceData = AppearanceData[itemId]

		suitData = appearanceData and appearanceData.suit and AppearanceSuitData[appearanceData.suit] or nil
	end

	local uiBack = suitData and suitData.uiBack

	return uiBack and uiBack ~= "" and uiBack or DEFAULT_PREVIEW_BACKGROUND
end

function TradeMarketAppearanceDisplayComponent:_getCurrentPreviewBody()
	return self.curGender == GENDER_MALE and BODY_MALE or BODY_FEMALE
end

function TradeMarketAppearanceDisplayComponent:_getAppearanceBodies(itemId)
	local appearanceConfig = AppearanceSuitData[itemId] or AvatarHairSuitData[itemId] or AppearanceData[itemId]

	return appearanceConfig and appearanceConfig.body
end

function TradeMarketAppearanceDisplayComponent:_getSupportedBodies(itemId)
	local supportedBodies = {}
	local firstBody

	for _, body in ipairs(self:_getAppearanceBodies(itemId) or {}) do
		if body == BODY_FEMALE or body == BODY_MALE then
			supportedBodies[body] = true
			firstBody = firstBody or body
		end
	end

	return supportedBodies, firstBody
end

function TradeMarketAppearanceDisplayComponent:_initializeGender(itemId)
	if not itemId or self._genderItemId == itemId then
		return
	end

	self._genderItemId = itemId

	local supportedBodies, firstBody = self:_getSupportedBodies(itemId)

	self._canSwitchGender = supportedBodies[BODY_FEMALE] == true and supportedBodies[BODY_MALE] == true

	local playerBody = self:_getPlayerBody()
	local initialBody = supportedBodies[playerBody] and playerBody or firstBody or playerBody or BODY_FEMALE

	self.curGender = initialBody == BODY_MALE and GENDER_MALE or GENDER_FEMALE
end

function TradeMarketAppearanceDisplayComponent:_getPlayerBody()
	local avatarPreview = self.avatarPreview
	local presetData = avatarPreview and pg.game.avatar:getAvatarPresetData(avatarPreview.curPresetKey)

	return presetData and presetData.body
end

function TradeMarketAppearanceDisplayComponent:_getTemplatePresetKey(body)
	local cfgKey = body == BODY_MALE and "template_preset_man" or "template_preset_woman"
	local cfg = ShopConstantData[cfgKey]
	local presetKey = cfg and tonumber(cfg.number)

	if presetKey and pg.game.avatar:getAvatarPresetData(presetKey) then
		return presetKey
	end

	local fallbackKey = body * 10000 + 1

	return pg.game.avatar:getAvatarPresetData(fallbackKey) and fallbackKey or nil
end

function TradeMarketAppearanceDisplayComponent:_getPreviewItemId(itemId, body)
	return ClientCashShopUtils.getGenderConvertedItemId(itemId, body) or itemId
end

function TradeMarketAppearanceDisplayComponent:refreshAppearanceInfo()
	local itemId = self.itemId

	if not itemId then
		return
	end

	local previewBody = self:_getCurrentPreviewBody()
	local previewItemId = self.isPetAppearance and itemId or self:_getPreviewItemId(itemId, previewBody)
	local suitData = AppearanceSuitData[previewItemId] or AvatarHairSuitData[previewItemId]
	local petAccessoryData = self.isPetAppearance and AppearanceJewelryPetData[previewItemId] or nil
	local fashion = 0

	if suitData then
		for _, appearanceId in ipairs(suitData.appearanceList or EMPTY_TABLE) do
			local appearanceData = AppearanceData[appearanceId]

			fashion = fashion + (appearanceData and appearanceData.fashion or 0)
		end
	elseif petAccessoryData then
		fashion = petAccessoryData.fashion or 0
	else
		local appearanceData = AppearanceData[previewItemId]

		fashion = appearanceData and appearanceData.fashion or 0
	end

	ClientTextUtils.setText(self.txtName, LuaUIUtils.getNameByItemId(previewItemId))
	ClientTextUtils.setText(self.txtDescType, pg.getGameString(suitData and "APPEARANCE_SUIT" or "APPEARANCE_ACCESSORY"))
	ClientTextUtils.setText(self.txtDescNum, fashion)
	self.fashionUImage.gameObject:SetActiveEx(fashion > 0)
	self.txtDescNum.gameObject:SetActiveEx(fashion > 0)

	local itemData = ItemData[previewItemId]

	self.rootUComponent:TryChangePage("Quality", itemData and itemData.quality or 0)
	self:_refreshSuitAppearanceList(itemId, previewItemId, previewBody, suitData)
end

function TradeMarketAppearanceDisplayComponent:_refreshSuitAppearanceList(itemId, previewItemId, previewBody, suitData)
	self._btnTriangleState = 0

	self.rootUComponent:TryChangePage("BtnTriangle", self._btnTriangleState)
	self.btnTriangle:SetActiveFastest(suitData ~= nil)

	if not suitData then
		self.listUList:SetList({})

		return
	end

	local list = ClientCashShopUtils.getSuitAppearanceItems(itemId, previewBody)

	if not list and AvatarHairSuitData[previewItemId] then
		list = {}

		for _, appearanceId in ipairs(AvatarHairSuitData[previewItemId].appearanceList or EMPTY_TABLE) do
			list[#list + 1] = {
				num = 1,
				id = appearanceId
			}
		end
	end

	self.listUList:SetList(list or {})
end

function TradeMarketAppearanceDisplayComponent:_renderSuitAppearanceItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	if itemIconUImage then
		itemIconUImage.url = LuaUIUtils.getIconByItemId(data.id)
	end

	if txtNumUText then
		ClientTextUtils.setText(txtNumUText, data.num or 1)
	end

	local itemData = ItemData[data.id]

	button:TryChangePage("Quality", itemData and itemData.quality or 0)

	function button.luaClick()
		LuaUIUtils.onRewardItemClick(button, data)
	end
end

function TradeMarketAppearanceDisplayComponent:refreshModelView()
	if not self._entered then
		return
	end

	local itemId = self.itemId

	if self.isPetAppearance then
		self:_showPetWithAccessory(itemId)
	else
		self:_showPlayerWithAppearance(itemId)
	end
end

function TradeMarketAppearanceDisplayComponent:_showPetWithAccessory(itemId)
	local avatarPreview = self.avatarPreview

	if not itemId or not avatarPreview or not avatarPreview.avatarScene then
		return
	end

	avatarPreview:clearTradeMarketPetAccessoryPreview()

	local petTemplateId = pgUtils.GetFirstPetTemplateIdByAccessoryId(itemId)

	if not petTemplateId or petTemplateId == 0 then
		avatarPreview:hideAllEntities()

		if avatarPreview.avatarScene.syncLight then
			avatarPreview.avatarScene:syncLight(false)
		end

		return
	end

	if not avatarPreview:showTradeMarketPetAccessoryPreview(petTemplateId, itemId) then
		avatarPreview:hideAllEntities()

		if avatarPreview.avatarScene.syncLight then
			avatarPreview.avatarScene:syncLight(false)
		end

		return
	end

	if avatarPreview.avatarScene.switchBackground then
		avatarPreview.avatarScene:switchBackground(DEFAULT_PREVIEW_BACKGROUND)
	end

	if avatarPreview.avatarScene.syncLight then
		avatarPreview.avatarScene:syncLight(true)
	end
end

function TradeMarketAppearanceDisplayComponent:_showPlayerWithAppearance(itemId)
	local avatarPreview = self.avatarPreview

	if not itemId or not avatarPreview or not avatarPreview.avatarScene then
		return
	end

	local avatarScene = avatarPreview.avatarScene
	local previewBody = self:_getCurrentPreviewBody()
	local previewItemId = self:_getPreviewItemId(itemId, previewBody)
	local suitData = AppearanceSuitData[previewItemId]
	local appearanceData = AppearanceData[previewItemId]

	if not suitData and appearanceData and appearanceData.suit then
		suitData = AppearanceSuitData[appearanceData.suit]
	end

	local shopAction = suitData and suitData.shopAction

	if not shopAction or shopAction == "" then
		local actionCfg = previewBody == BODY_MALE and ShopConstantData.default_action_man or ShopConstantData.default_action_woman

		shopAction = actionCfg and actionCfg.number
	end

	self._previewToken = (self._previewToken or 0) + 1

	local previewToken = self._previewToken

	avatarPreview:clearPreviewState("all")

	if previewBody == self:_getPlayerBody() then
		avatarPreview:showPlayerWithPreview(previewItemId, shopAction)
	else
		local presetKey = self:_getTemplatePresetKey(previewBody)

		if not presetKey then
			avatarPreview:hideAllEntities()

			if avatarScene.syncLight then
				avatarScene:syncLight(false)
			end

			return
		end

		avatarPreview:showTemplateAvatar(presetKey, shopAction, function()
			if not self._entered or previewToken ~= self._previewToken then
				return
			end

			avatarPreview:templateEquip(previewItemId)
		end)
	end

	if avatarScene.switchBackground then
		avatarScene:switchBackground(self:_getPreviewBackground(previewItemId))
	end

	if avatarScene.syncLight then
		avatarScene:syncLight(true)
	end
end

function TradeMarketAppearanceDisplayComponent:onGenderSwitched()
	local supportedBodies = self:_getSupportedBodies(self.itemId)

	if not supportedBodies[self:_getCurrentPreviewBody()] then
		return
	end

	self._previewToken = (self._previewToken or 0) + 1

	local avatarPreview = self.avatarPreview

	if avatarPreview and avatarPreview.avatarScene then
		avatarPreview:clearPreviewState("all")
		avatarPreview:hideAllEntities()
	end

	self:refreshAppearanceInfo()
	self:refreshModelView()
end

return TradeMarketAppearanceDisplayComponent
