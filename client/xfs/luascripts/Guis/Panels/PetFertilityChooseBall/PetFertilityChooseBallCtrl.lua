-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityChooseBall\\PetFertilityChooseBallCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("PetFertilityChooseBallCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local UILib_TopTitleBackComp = require("Guis.Panels.UILibs.UILib_TopTitleBackComp")
local ItemData = require("Data.item_data")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local PetConfigData = require("Data.pet_config_data")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local rectTransformUtility = CS.UnityEngine.RectTransformUtility
local PetFertilityConst = require("Const.PetFertilityConst")
local PetFertilityChooseBallCtrl = Class.LightClass("PetFertilityChooseBallCtrl", UICtrl)

PetFertilityChooseBallCtrl.messages = {}
PetFertilityChooseBallCtrl.CONFIRM_CD = 1

function PetFertilityChooseBallCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.slotIndex = info and info.slotIndex
	self.onConfirm = info and info.onConfirm
	self.onCancel = info and info.onCancel
	self.eggItemId = info and info.eggItemId or 0
	self._confirmed = false
	self._closeForSourceJump = false
	self.lastConfirmTime = 0

	self.model:clearSelected()
	self:_autoSelectFirst()
	self:_setupTopBack()
	self:_setupList()
	self:_setupConfirmBtn()
	self:_refreshSelBall()
	self:bindCloseButton()
end

function PetFertilityChooseBallCtrl:_autoSelectFirst()
	local list = self.model:getAllValidCubeList(self.eggItemId)

	if list and list[1] then
		self.model:setSelectedItemId(list[1].itemId)
	end

	self:_systemOnSelectedCube(self.model:getSelectedItemId())
end

function PetFertilityChooseBallCtrl:onDestroy()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	self._tooltipItemId = nil

	if not self._confirmed and self.onCancel then
		local cb = self.onCancel

		self.onCancel = nil

		cb(self._closeForSourceJump == true)
	end

	if self.topBackComp then
		self.topBackComp:onDestroy()

		self.topBackComp = nil
	end

	self._choosedTime = nil

	UICtrl.onDestroy(self)
end

function PetFertilityChooseBallCtrl:closeForSourceJump()
	self._closeForSourceJump = true

	self:closeImmediately()
end

function PetFertilityChooseBallCtrl:addListener()
	return
end

function PetFertilityChooseBallCtrl:_setupTopBack()
	if not self.view.topBackUWidget then
		return
	end

	self.topBackComp = UILib_TopTitleBackComp.new(self.view.topBackUWidget, self)

	self.topBackComp:setTitle("PET_FERTILITY_TITLE")
	self.topBackComp:hideInfo()
	self.topBackComp:setOnBack(function()
		self:close()
	end)
end

function PetFertilityChooseBallCtrl:_setupList()
	if self.view.txtTitleUSDFText then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("PET_FERTILITY_CHOOSE_TIP"))
	end

	if not self.view.listBallUList then
		return
	end

	function self.view.listBallUList.luaRenderItem(button, index, data)
		self:_renderBallItem(button, index, data)
	end

	self:_refreshList()
end

function PetFertilityChooseBallCtrl:_refreshList()
	if not self.view.listBallUList then
		return
	end

	local list = self.model:getAllValidCubeList(self.eggItemId)

	self.view.listBallUList:SetList(list)
end

function PetFertilityChooseBallCtrl:_renderBallItem(button, index, data)
	if not data then
		return
	end

	button.draggable = false

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconBallUImage")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local recommendUContainer = objectReference:GetRefValue("recommendUContainer")

	if iconUImage and data.icon then
		iconUImage.url = data.icon
	end

	if txtNameUSDFText then
		local nameStr = pg.getLocalizationText(data.name)

		if pg.game.setting:getShowDebugId() then
			nameStr = nameStr .. "_" .. tostring(data.itemId)
		end

		ClientTextUtils.setText(txtNameUSDFText, nameStr)
	end

	if txtNumUSDFText then
		ClientTextUtils.setText(txtNumUSDFText, tostring(data.count or 0))
	end

	if NotNil(recommendUContainer) then
		if data.isRecommend then
			recommendUContainer.gameObject:SetActiveEx(true)

			if not recommendUContainer:CheckURLLoaded() then
				recommendUContainer:LoadDefaultUrlManually()
			end
		else
			recommendUContainer.gameObject:SetActiveEx(false)
		end
	end

	button:TryChangePage("Quality", data.quality or 0)

	button.interactable = true

	button:TryChangePage("Empty", data.isEnough and data.isAvailable and 0 or 1)

	local selectedId = self.model:getSelectedItemId()

	button.isSelected = selectedId == data.itemId
	button.enabledLongPress = true
	button.luaLongPress = nil

	local longPressFired = false

	function button.luaBeginLongPress()
		longPressFired = true

		self:_toggleItemTooltip(data, button)
	end

	function button.luaClick()
		if longPressFired then
			longPressFired = false

			return
		end

		if self._choosedTime and Time.millisecondCache - self._choosedTime < PetFertilityConst.WaitCubeSwitchEffectTime * 1000 then
			return
		end

		if self.model:getSelectedItemId() == data.itemId then
			return
		end

		self:_onSelectBall(button, data.itemId)

		self._choosedTime = Time.millisecondCache
	end
end

function PetFertilityChooseBallCtrl:_onSelectBall(curButton, itemId)
	local prev = self.model:getSelectedItemId()

	if prev == itemId then
		return
	end

	self.model:setSelectedItemId(itemId)

	if self.view.listBallUList and self.view.listBallUList.RefreshList then
		self.view.listBallUList:RefreshList()
	end

	self:_refreshSelBall()
	self:_refreshConfirmBtn()
	self:_systemOnSelectedCube(itemId)
end

function PetFertilityChooseBallCtrl:_refreshSelBall()
	local itemId = self.model:getSelectedItemId()
	local info = itemId and self.model:getCubeInfoById(itemId, self.eggItemId)

	if self.view.selBallUComponent then
		self.view.selBallUComponent.gameObject:SetActiveEx(info ~= nil)

		if info then
			self.view.selBallUComponent:TryChangePage("Quality", info.quality or 0)
		end
	end

	if self.view.txtBallNameUSDFText then
		ClientTextUtils.setText(self.view.txtBallNameUSDFText, info and info.name and pg.getLocalizationText(info.name) or "")
	end

	if self.view.txtDetailsUSDFText then
		local txtStr = info and info.fertityDesc and pg.getLocalizationText(info.fertityDesc) or ""

		ClientTextUtils.setText(self.view.txtDetailsUSDFText, txtStr)

		local isShowLine = txtStr and txtStr ~= ""

		if NotNil(self.view.ImgLineTs) and NotNil(self.view.ImgLineTs.gameObject) then
			self.view.ImgLineTs.gameObject:SetActiveEx(isShowLine)
		end
	end

	if self.view.imgSelBallIconUImage and info and info.icon then
		self.view.imgSelBallIconUImage.url = info.icon
	end

	local eggItemId = self.eggItemId or 0
	local itemCfg = ItemData[eggItemId]

	if not eggItemId or not itemCfg then
		if NotNil(self.view.txtBallName2USDFText) then
			self.view.txtBallName2USDFText:SetActive(false)
		end

		if NotNil(self.view.txtDetails2USDFText) then
			self.view.txtDetails2USDFText:SetActive(false)
		end

		if NotNil(self.view.eggPanelUComponent) then
			self.view.eggPanelUComponent:SetActive(false)
		end
	else
		if NotNil(self.view.txtBallName2USDFText) then
			ClientTextUtils.setText(self.view.txtBallName2USDFText, pg.getLocalizationText(itemCfg.itemName))
		end

		if NotNil(self.view.txtDetails2USDFText) then
			ClientTextUtils.setText(self.view.txtDetails2USDFText, pg.getLocalizationText(itemCfg.itemDes))
		end

		if NotNil(self.view.eggPanelUComponent) then
			self.view.eggPanelUComponent:SetActive(true)
			self.view.eggPanelUComponent:TryChangePage("Quality", itemCfg.quality or 0)
		end
	end
end

function PetFertilityChooseBallCtrl:_setupConfirmBtn()
	if not self.view.btnConfirmUButton then
		return
	end

	local objectReference = self.view.btnConfirmUButton:GetComponent("ObjectReference")

	if objectReference then
		local txtNameUText = objectReference:GetRefValue("txtNameUText")

		if txtNameUText then
			ClientTextUtils.setText(txtNameUText, pg.getGameString("ENSURE"))
		end
	end

	function self.view.btnConfirmUButton.luaClick()
		self:_onConfirm()
	end

	self:_refreshConfirmBtn()
end

function PetFertilityChooseBallCtrl:_refreshConfirmBtn()
	if not self.view.btnConfirmUButton then
		return
	end

	local itemId = self.model:getSelectedItemId()
	local info = itemId and self.model:getCubeInfoById(itemId, self.eggItemId)
	local enough = info and info.isEnough or false
	local isAvailable = info and info.isAvailable

	self.view.btnConfirmUButton.visualInteractable = enough and isAvailable

	self.view.btnConfirmUButton:TryChangePage("button", enough and isAvailable and 0 or 4)
	TimerManager.addNextFrameCb(function()
		local rayBox = self.view.btnConfirmUButton.transform:Find("RayBox")

		if NotNil(rayBox) and NotNil(rayBox.gameObject) then
			rayBox.gameObject:SetActiveEx(true)
		end
	end)

	if self.view.txtTipsUSDFText then
		if not isAvailable then
			ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("Pet_NewHatch_ChooseCube_NotAllow"))
		elseif not enough then
			ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("Pet_NewHatch_ChooseCube_Lack"))
		else
			ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("PET_FERTILITY_SURE_TIP"))
		end
	end
end

function PetFertilityChooseBallCtrl:_onConfirm()
	local itemId = self.model:getSelectedItemId()

	if not itemId then
		return
	end

	local info = self.model:getCubeInfoById(itemId, self.eggItemId)

	if not info or not info.isAvailable then
		pg.global.showBubbleMessage(NoticeDef.PET_NEW_HATCH_CUBE_UNAVAILABEL)

		return
	end

	local eggCfg = PetHatchEggData[self.eggItemId]
	local suggest = eggCfg and eggCfg.suggest
	local suggestItemId = suggest and suggest[1]

	if suggestItemId and not self.model:isCubeVisibleInChooseList(suggestItemId) then
		suggestItemId = nil
	end

	if not info.isEnough then
		if suggestItemId then
			local onlyRecommend = itemId == suggestItemId

			self:_openSuggestPopup(itemId, suggestItemId, suggest[2], onlyRecommend)
		else
			pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)
		end

		return
	end

	if self.lastConfirmTime and Time.realSecondCache - self.lastConfirmTime < PetFertilityChooseBallCtrl.CONFIRM_CD then
		return
	end

	self.lastConfirmTime = Time.realSecondCache

	if suggestItemId and suggestItemId ~= itemId then
		self:_openSuggestPopup(itemId, suggestItemId, suggest[2], false)

		return
	end

	self:_finalizeConfirm(itemId)
end

function PetFertilityChooseBallCtrl:_openSuggestPopup(currentItemId, suggestItemId, sourceId, onlyRecommend)
	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_POPUP_CHOOSE_BALL, {
		eggItemId = self.eggItemId,
		currentItemId = currentItemId,
		suggestItemId = suggestItemId,
		sourceId = sourceId,
		onlyRecommend = onlyRecommend,
		onConfirm = function(finalItemId)
			self:_finalizeConfirm(finalItemId)
		end
	})
end

function PetFertilityChooseBallCtrl:_finalizeConfirm(itemId)
	if not itemId then
		return
	end

	self._confirmed = true

	local cb = self.onConfirm

	self.onConfirm = nil

	if cb then
		cb(itemId)
	end

	self:close()
end

function PetFertilityChooseBallCtrl:onOpen(info)
	return
end

function PetFertilityChooseBallCtrl:onShow()
	return
end

function PetFertilityChooseBallCtrl:onHide()
	return
end

function PetFertilityChooseBallCtrl:onVisibleChange(visible)
	return
end

function PetFertilityChooseBallCtrl:_systemOnSelectedCube(itemId)
	if pg.game.soulEggEvolution then
		pg.game.soulEggEvolution:onSelectedCube(itemId)
	end
end

function PetFertilityChooseBallCtrl:_toggleItemTooltip(data, targetButton)
	local opened = pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP)

	if not opened then
		self._tooltipItemId = nil
	end

	local sameItem = opened and self._tooltipItemId == data.itemId

	if opened then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	if sameItem then
		self._tooltipItemId = nil

		return
	end

	self._tooltipItemId = data.itemId

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		autoHor = true,
		autoVer = false,
		sortingOrder = 30001,
		hierarchyMode = 0,
		checkTouchBegin = false,
		id = data.itemId,
		num = data.count or 0,
		targetRect = self.view.listBallUList,
		verAlign = CS.XGUI.EVerticalAlignment.Top,
		closeOnJumpToSource = function(sourceData)
			if not pg.game.soulEggEvolution or not pg.game.soulEggEvolution:beginChooseCubeSourceJump(sourceData) then
				self:closeForSourceJump()
			end
		end,
		validateTouch = function(pos)
			if not NotNil(targetButton) then
				return true
			end

			local rt = targetButton.rectTransform

			if not rt then
				return true
			end

			return not rectTransformUtility.RectangleContainsScreenPoint(rt, pos, CS.XGUI.UWidget.uiCamera)
		end
	})
end

return PetFertilityChooseBallCtrl
