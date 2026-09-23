-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetFeedComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetLevelData = require("Data.pet_level_data")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ItemConst = require("Common.Const.ItemConst")
local Utils = require("Common.Utils.Utils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("PetFeedComponent")
local PetFeedComponent = Class.LightClass("PetFeedComponent", UIComponent)
local Vector3 = Vector3
local Vector4 = Vector4
local UIUtils = UIUtils
local Quaternion = Quaternion
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetFeedComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.itemListUList = self.objectReference:GetRefValue("itemListUList")
	self.numSelectorUNumSelector = self.objectReference:GetRefValue("numSelectorUNumSelector")
	self.btnSelectUButton = self.objectReference:GetRefValue("btnSelectUButton")
	self.numUSDFText = self.objectReference:GetRefValue("numUSDFText")
	self.foodbarUComponent = self.objectReference:GetRefValue("foodbarUComponent")
	self._rectTransform = self.transform:GetComponent("RectTransform")
	self.petBallPreviewScene = pg.game.uiScene:getScene(UISceneConst.PET_BALL_PREVIEW_SCENE)
	self.sceneCamera = self.petBallPreviewScene.cameraTransform:GetComponent("Camera")
	self.itemListNeedAni = true
end

function PetFeedComponent:initView()
	function self.btnSelectUButton.luaClick()
		if self._curItemId and self._curItemCount > 0 then
			local expActionRemainExp = self.model:getTotalExpByExpActionList()
			local expCurTotal = self.model:getTotalExpByFeedItem(self._curItemId, self._curItemCount)
			local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
			local expMaxAdd = Utils.getPetExpMaxAdd(pg.me, petInfo.id)

			if expMaxAdd <= expActionRemainExp then
				pg.global.showConfirmMsgRaw(nil, pg.getGameString("PETBALL_FEED_CHECK"), function()
					self.model:setPetFood(self._curItemId, self._curItemCount, CallbackHandler(self, "onFeedRPCCallBack"))
				end)
			else
				self.model:setPetFood(self._curItemId, self._curItemCount, CallbackHandler(self, "onFeedRPCCallBack"))
			end
		end
	end

	function self.itemListUList.luaRenderItem(button, index, data)
		self:renderFoodItem(button, index, data)
	end

	function self.numSelectorUNumSelector.luaValueChanged(value)
		self:onItemNumChanged(value)
	end
end

function PetFeedComponent:tick()
	local petEntity = self.ctrl:getCurPreviewingPetEnt()

	if not petEntity or not self._petBallInfoView then
		return
	end

	if not self._modelOffSet then
		self._modelOffSet = self:getModelHeightOffSet()
	end

	local realPos = petEntity.eModel:GetBonePosition("Root_Fx")

	realPos.y = realPos.y + self._modelOffSet

	local screenPos = UIUtils.WorldToScreenPoint(realPos, self.sceneCamera)
	local uiPos = UIUtils.ScreenPointToUIPoint(self._rectTransform, screenPos)

	self._petBallInfoView.transform.position = uiPos
	self._petBallInfoView.transform.rotation = Quaternion.Euler(0, -30, 0)
end

function PetFeedComponent:refreshBallPetInfo()
	if not self._petBallInfoView then
		return
	end

	local objectReference = self._petBallInfoView.transform:GetComponent("ObjectReference")
	local sliderAddUSlider = objectReference:GetRefValue("sliderAddUSlider")
	local sliderNowUSlider = objectReference:GetRefValue("sliderNowUSlider")
	local imgPetUImage = objectReference:GetRefValue("imgPetUImage")
	local nameUSDFText = objectReference:GetRefValue("nameUSDFText")
	local maleUImage = objectReference:GetRefValue("maleUImage")
	local femaleUImage = objectReference:GetRefValue("femaleUImage")
	local numLvUSDFText = objectReference:GetRefValue("numLvUSDFText")
	local numCPUSDFText = objectReference:GetRefValue("numCPUSDFText")
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local baseLv, curExp = self:getExpActionTargetInfo()
	local maxExp = PetLevelData[baseLv + 1] ~= nil and PetLevelData[baseLv + 1].needExp or 0

	imgPetUImage.url = LuaUIUtils.getPetIcon(petInfo.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
	sliderNowUSlider.value = maxExp == 0 and 1 or curExp / maxExp
	sliderAddUSlider.value = 0

	ClientTextUtils.setText(nameUSDFText, pg.getLocalizationText(petInfo.name))
	ClientTextUtils.setText(numCPUSDFText, string.format("%s %s", pg.getGameString("CP"), petInfo.cp))
	ClientTextUtils.setText(numLvUSDFText, string.format("%s %s", pg.getGameString("LEVEL_TAG"), baseLv))
	maleUImage:SetActive(petInfo.gender == Const.GENDER_TYPE_MALE)
	femaleUImage:SetActive(petInfo.gender == Const.GENDER_TYPE_FEMALE)
end

function PetFeedComponent:refreshFoodItemList()
	self._foodItemList = self.model:getFoodItemsInfo()

	if not self._foodItemList then
		return
	end

	function self.itemListUList.luaFinishRender(_)
		return
	end

	function self.itemListUList.luaClick(button, data)
		self:onItemClick(button, data)
	end

	self.itemListUList:SetList(self._foodItemList)
	self.itemListUList:GoToIndex(0)
end

function PetFeedComponent:openPetFeedPanel()
	self.numSelectorUNumSelector.minValue = 0
	self.numSelectorUNumSelector.maxValue = 0
	self.numSelectorUNumSelector.value = 0
	self.btnSelectUButton.visualInteractable = false

	if self._curSelectItem then
		self._curSelectItem.isSelected = false
		self._curSelectItem = nil
	end

	self._curItemId = nil
	self._curItemCount = nil

	self.foodbarUComponent:TryChangePage("ItemSel", 0)

	local petEntity = self.ctrl:getCurPreviewingPetEnt()

	if petEntity then
		if self._petBallInfoView then
			self:refreshBallPetInfo()
		else
			self.view:addPrefabWithPathAsync(self.transform, AddressDataConst.PET_FERTILITY_BALLPETINFO, function(objInfo)
				if IsNil(objInfo.gameObject) then
					return
				end

				self._petBallInfoView = objInfo

				self:refreshBallPetInfo()
				LuaUIUtils.setUIViewVisible(objInfo, true)
			end)
		end
	end

	self.timer = self:startTimer(function()
		self:tick()
	end, 0, true)

	self:refreshFoodItemList()
end

function PetFeedComponent:renderFoodItem(button, index, data)
	self:setPropCard(button, index, data, 1)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local uIComPropCardAnimation = objectReference:GetRefValue("uIComPropCardAnimation")

	ClientTextUtils.setText(txtNameUText, tostring(data.count))

	function button.luaPress()
		if self._curSelectItem == button then
			return
		end

		if self._curSelectItem then
			self._curSelectItem.isSelected = false
		end

		button.isSelected = true
		self._curSelectItem = button
	end

	button.visualInteractable = data.count > 0
	button.draggable = false

	if self.itemListNeedAni then
		uIComPropCardAnimation:Play("UI_Prefab_Prop_Card_In")
	end
end

function PetFeedComponent:onItemNumChanged(value)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("PetFeedComponent-onItemNumChanged", value)
	end

	self._curItemCount = value
	self.btnSelectUButton.visualInteractable = self._curItemCount > 0

	self:refreshTimeCost()
	self:refreshAddExp()
end

function PetFeedComponent:setPropCard(button, idx, propData, showType)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
	local genIdTransform = objectReference:GetRefValue("genIdTransform")
	local stateNewULayoutBox = objectReference:GetRefValue("stateNewULayoutBox")
	local slotIndex = objectReference:GetRefValue("slotIndex")

	slotIndex.text = idx + 1

	button:TryChangePage("CardState", showType)

	if showType == UIConst.INVENTORY_CARD.CARD_EMPTY_IDX then
		return
	end

	if showType == UIConst.INVENTORY_CARD.CARD_IDX then
		button.gameObject.name = propData.itemId
		genIdTransform:GetChild(0).gameObject.name = propData.index
	end

	selectedULayoutBox.gameObject:SetActiveEx(false)
	btnDelUButton.gameObject:SetActiveEx(false)
	stateLockUWidget.gameObject:SetActiveEx(false)
	stateNewULayoutBox.gameObject:SetActiveEx(false)

	iconUImage.url = propData.icon

	button:TryChangePage("Quality", propData.quality)
	button:TryChangePage("CaptureMark", propData.isCaptureBind and 1 or 0)
end

function PetFeedComponent:onItemClick(button, data)
	if self._curItemId == data.itemId then
		return
	end

	self._curItemCount = data.count > 0 and 1 or 0
	self.numSelectorUNumSelector.minValue = 0
	self.numSelectorUNumSelector.maxValue = self.model:getAddItemMaxValue(data.itemId, data.count)
	self.numSelectorUNumSelector.value = self._curItemCount
	self.btnSelectUButton.visualInteractable = self._curItemCount > 0

	local success, curPage = self.foodbarUComponent:TryGetCurrentPage("ItemSel")
	local tarPage = self._curItemCount > 0 and 1 or 0

	self.foodbarUComponent:TryChangePage("ItemSel", tarPage)

	self._curItemId = data.itemId

	self:refreshTimeCost()
	self:refreshAddExp()

	local tipOpened = pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP)

	if tipOpened then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	if self._curItemCount == 0 then
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = data.itemId,
			num = data.count,
			targetRect = button
		})
	end
end

function PetFeedComponent:refreshTimeCost()
	local totalSeconds = Utils.getExpActionCount(self._curItemId) * Utils.getExpActionTime(self._curItemId) * self._curItemCount

	ClientTextUtils.setText(self.numUSDFText, LuaUIUtils.getCountDownFormateText(totalSeconds, true))
end

function PetFeedComponent:refreshAddExp()
	if not self._petBallInfoView then
		return
	end

	local objectReference = self._petBallInfoView.transform:GetComponent("ObjectReference")
	local sliderAddUSlider = objectReference:GetRefValue("sliderAddUSlider")
	local sliderNowUSlider = objectReference:GetRefValue("sliderNowUSlider")
	local numLvUSDFText = objectReference:GetRefValue("numLvUSDFText")
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local baseLv, curExp = self:getExpActionTargetInfo()
	local expActionTotalExp = self.model:getTotalExpByExpActionList()
	local maxAddExp = Utils.getPetExpMaxAdd(pg.me, petInfo.id)

	if expActionTotalExp < maxAddExp and self._curItemId and self._curItemCount > 0 then
		local addExp = self.model:getTotalExpByFeedItem(self._curItemId, self._curItemCount)
		local targetLv = baseLv + 1
		local expTotal = curExp + addExp
		local maxExp = PetLevelData[targetLv] and PetLevelData[targetLv].needExp or 0
		local jumpLevel = false

		while maxExp ~= 0 and maxExp < expTotal and PetLevelData[targetLv + 1] ~= nil do
			jumpLevel = true
			targetLv = targetLv + 1
			expTotal = expTotal - maxExp
			maxExp = PetLevelData[targetLv].needExp
		end

		local tempStr = jumpLevel and "<color=#f960fe>%s %s</color>" or "%s %s"

		ClientTextUtils.setText(numLvUSDFText, string.format(tempStr, pg.getGameString("LEVEL_TAG"), jumpLevel and targetLv - 1 or baseLv))

		sliderNowUSlider.value = jumpLevel and 0 or maxExp == 0 and 1 or curExp / maxExp
		sliderAddUSlider.value = maxExp == 0 and 1 or expTotal / maxExp
	else
		local maxExp = PetLevelData[baseLv + 1] ~= nil and PetLevelData[baseLv + 1].needExp or 0

		sliderAddUSlider.value = 0
		sliderNowUSlider.value = maxExp == 0 and 1 or curExp / maxExp

		ClientTextUtils.setText(numLvUSDFText, string.format("%s %s", pg.getGameString("LEVEL_TAG"), baseLv))
	end
end

function PetFeedComponent:onFeedRPCCallBack()
	self:onHidePetFeed()
	self.ctrl.petBallComponent:managementBackToPreviewPage()
	self.ctrl.petBallComponent:onPetFeedBack()
end

function PetFeedComponent:onHidePetFeed()
	if self.timer then
		self:killTimer(self.timer)
	end
end

function PetFeedComponent:getModelHeightOffSet()
	local petEntity = self.ctrl:getCurPreviewingPetEnt()

	if not petEntity then
		return
	end

	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local configData = PetData[petInfo.templateId or -1]
	local scaleX, _, _ = petEntity.eModel:GetTransformLocalScale()
	local configHeight = configData.topbarHeight and configData.topbarHeight * scaleX or nil
	local modelHeight = petEntity:getHeight() * scaleX

	return configHeight or modelHeight + 0.3
end

function PetFeedComponent:getExpActionTargetInfo()
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local expActionTotalExp = self.model:getTotalExpByExpActionList()
	local targetLv = petInfo.level
	local curExp = petInfo.exp
	local maxAddExp = Utils.getPetExpMaxAdd(pg.me, petInfo.id)
	local realAddExp = math.min(expActionTotalExp, maxAddExp)

	while true do
		local maxExp = PetLevelData[targetLv + 1] ~= nil and PetLevelData[targetLv + 1].needExp or nil

		if not maxExp then
			if PetLevelData[targetLv] ~= nil then
				curExp = PetLevelData[targetLv].needExp

				break
			end

			curExp = false

			if false then
				curExp = true
			end

			break
		end

		if realAddExp <= 0 then
			break
		end

		if maxExp <= curExp + realAddExp then
			realAddExp = realAddExp - (maxExp - curExp)
			curExp = 0
			targetLv = targetLv + 1
		else
			curExp = curExp + realAddExp
			realAddExp = 0
		end
	end

	return targetLv, curExp
end

function PetFeedComponent:onPetBallExpActionStatusChanged(info)
	return
end

function PetFeedComponent:onPetLevelChanged(info)
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local curPetId = petInfo.id

	if curPetId == info.petId then
		self:refreshBallPetInfo()
	end
end

function PetFeedComponent:onPetAddExp(info)
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local curPetId = petInfo.id

	if curPetId == info.petId then
		self:refreshBallPetInfo()
	end
end

return PetFeedComponent
