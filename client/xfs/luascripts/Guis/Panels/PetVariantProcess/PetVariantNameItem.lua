-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetVariantProcess\\PetVariantNameItem.lua

local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RectTransformUtility = CS.UnityEngine.RectTransformUtility
local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3
local PetVariantNameItem = Class.LightClass("PetVariantNameItem")

function PetVariantNameItem:ctor(view, parent, camera, entity)
	self.view = view
	self.camera = camera
	self.entity = entity
	self.parentRectTransform = parent:GetComponent("RectTransform")

	self:_loadPrefab(parent)
end

function PetVariantNameItem:_loadPrefab(parent)
	self.loadTaskId = self.view:addPrefabWithPathAsync(parent, AddressDataConst.TOPLOGO_COMP_RES_COMBAT, function(item)
		self:_onPrefabLoaded(item)
	end)
end

function PetVariantNameItem:_onPrefabLoaded(item)
	self.loadTaskId = nil

	if self.destroyed or IsNil(item.gameObject) then
		return
	end

	self.gameObject = item.gameObject
	self.rectTransform = item.transform:GetComponent("RectTransform")

	self:_findObjects(item.transform)

	self.variantPageChangedCallback = CallbackHandler(self, "_refreshVariantPage")
	self.entity.petVariantNamePageChangedCallback = self.variantPageChangedCallback

	self:_initView()
	self:update()
end

function PetVariantNameItem:_findObjects(transform)
	local objectReference = transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.bloodBarUWidget = objectReference:GetRefValue("bloodBarUWidget")
	self.levelUWidget = objectReference:GetRefValue("levelUWidget")
	self.teamUWidget = objectReference:GetRefValue("teamUWidget")
	self.nameUText = objectReference:GetRefValue("nameUText")
	self.nameVariant1UBaseText = objectReference:GetRefValue("nameVariant1UBaseText")
	self.nameVariant2UBaseText = objectReference:GetRefValue("nameVariant2UBaseText")
	self.newLabelUImage = objectReference:GetRefValue("newLabelUImage")
	self.listElementUList = objectReference:GetRefValue("listElementUList")
	self.buffUList = objectReference:GetRefValue("buffUList")
	self.titleAddonUWidget = objectReference:GetRefValue("titleAddonUWidget")
	self.nameBarUWidget = objectReference:GetRefValue("nameBarUWidget")
	self.subTextUSDFText = objectReference:GetRefValue("subTextUSDFText")
	self.onlineIDUContainer = objectReference:GetRefValue("onlineIDUContainer")
	self.controlUWidget = objectReference:GetRefValue("controlUWidget")
	self.likabilityUWidget = objectReference:GetRefValue("likabilityUWidget")
end

function PetVariantNameItem:_initView()
	local name = self:_getDisplayName()

	ClientTextUtils.setText(self.nameUText, name)
	ClientTextUtils.setText(self.nameVariant1UBaseText, name)
	ClientTextUtils.setText(self.nameVariant2UBaseText, name)
	self.rootUComponent.gameObject:SetActiveEx(true)
	self.rootUComponent:TryChangePage("State", "Normal")
	self:_setObjectActive(self.nameBarUWidget, true)
	self:_setObjectActive(self.bloodBarUWidget, false)
	self:_setObjectActive(self.levelUWidget, false)
	self:_setObjectActive(self.teamUWidget, false)
	self:_setObjectActive(self.newLabelUImage, false)
	self:_setObjectActive(self.listElementUList, false)
	self:_setObjectActive(self.buffUList, false)
	self:_setObjectActive(self.titleAddonUWidget, false)
	self:_setObjectActive(self.subTextUSDFText, false)
	self:_setObjectActive(self.onlineIDUContainer, false)
	self:_setObjectActive(self.controlUWidget, false)
	self:_setObjectActive(self.likabilityUWidget, false)
	self:_refreshVariantPage(true)
	self:_setVisible(false)
end

function PetVariantNameItem:_getDisplayName()
	local customName = self.entity.petInfo.customName

	if not string.isNilOrEmpty(customName) then
		return customName
	end

	return pg.getLocalizationText(self.entity:getConfigData().name)
end

function PetVariantNameItem:_setObjectActive(target, active)
	target.gameObject:SetActiveEx(active)
end

function PetVariantNameItem:update()
	if not self.gameObject then
		return
	end

	local entity = self.entity
	local visible = entity.petVariantNameVisible == true and not entity.destroyed and entity.eModel ~= nil

	if not visible then
		self:_setVisible(false)

		return
	end

	self:_refreshPosition()
end

function PetVariantNameItem:_refreshVariantPage(force)
	local page = self.entity.petVariantNamePage

	if not force and self.currentPage == page then
		return
	end

	self.currentPage = page

	self.rootUComponent:TryChangePage("isChange", page)

	local isVariant = page == 1

	self:_setObjectActive(self.nameUText, not isVariant)
	self:_setObjectActive(self.nameVariant1UBaseText, isVariant)
	self:_setObjectActive(self.nameVariant2UBaseText, isVariant)
end

function PetVariantNameItem:_refreshPosition()
	local entity = self.entity
	local position = entity:getPosition()
	local height = self:_getTopLogoHeight()
	local worldPosition = Vector3(position.x, position.y + height, position.z)
	local screenPosition = self.camera:WorldToScreenPoint(worldPosition)

	if screenPosition.z <= 0 then
		self:_setVisible(false)

		return
	end

	local success, localPosition = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.parentRectTransform, Vector2(screenPosition.x, screenPosition.y), CS.XGUI.UWidget.uiCamera)

	if not success then
		self:_setVisible(false)

		return
	end

	self.rectTransform.anchoredPosition = localPosition

	self:_setVisible(true)
end

function PetVariantNameItem:_getTopLogoHeight()
	local entity = self.entity
	local configData = entity:getConfigData()
	local scale = entity.curModelScale or 1

	if configData.topLogoOffsetNoScale then
		return configData.topLogoOffsetNoScale
	end

	if configData.topLogoOffset then
		return configData.topLogoOffset * scale
	end

	local strategy = entity:getTopLogoFollowStrategy()

	if strategy == ClientConst.TopLogoFollowStrategy.Head then
		local success, headRadius = entity.eModel:TryGetHeadRadius(Const.COMPONENT_INDEX_MODEL)

		return (success and headRadius or 0) * scale + 0.15
	end

	local modelHeight = configData.modelHeight or entity:getHeight()

	return modelHeight * scale + 0.2
end

function PetVariantNameItem:_setVisible(visible)
	if self.visible == visible then
		return
	end

	self.visible = visible

	self.gameObject:SetActiveEx(visible)
end

function PetVariantNameItem:destroy()
	self.destroyed = true
	self.entity.petVariantNamePageChangedCallback = nil
	self.variantPageChangedCallback = nil

	if self.loadTaskId then
		self.view:cancelLoadTask(self.loadTaskId)

		self.loadTaskId = nil
	end

	if NotNil(self.gameObject) then
		self.view:destroyInstance(self.gameObject)

		self.gameObject = nil
	end

	self.entity = nil
	self.camera = nil
	self.view = nil
end

return PetVariantNameItem
