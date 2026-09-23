-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityChooseBallPopup\\PetFertilityChooseBallPopupCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityChooseBallPopupCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local ItemSourceData = require("Data.item_source_data")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local ItemSelectionTipsUtils = require("Common.Utils.ItemSelectionTipsUtils")
local PetFertilityChooseBallPopupCtrl = Class.LightClass("PetFertilityChooseBallPopupCtrl", UICtrl)

PetFertilityChooseBallPopupCtrl.messages = {}

function PetFertilityChooseBallPopupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.eggItemId = info and info.eggItemId or 0
	self.currentItemId = info and info.currentItemId
	self.suggestItemId = info and info.suggestItemId
	self.sourceId = info and info.sourceId
	self.onConfirm = info and info.onConfirm
	self.onlyRecommend = info and info.onlyRecommend or false

	self.model:setup(self.eggItemId, self.currentItemId, self.suggestItemId, self.onlyRecommend)
	self:_setupClose()
	self:_setupList()
	self:_refreshSelectState()
	self:bindCloseButton(self.view.btnCancelUButton or self.view.btnCloseUButton)
	ClientTextUtils.setText(self.view.txtTltleUSDFText, pg.getGameString("CHOOSEBALL_SURE_USE_TITLE"))
end

function PetFertilityChooseBallPopupCtrl:addListener()
	return
end

function PetFertilityChooseBallPopupCtrl:onDestroy()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	UICtrl.onDestroy(self)
end

function PetFertilityChooseBallPopupCtrl:_setupClose()
	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:close()
		end
	end

	if self.view.btnCloseUButton2 then
		function self.view.btnCloseUButton2.luaClick()
			self:close()
		end
	end

	if self.view.btnCancelUButton then
		function self.view.btnCancelUButton.luaClick()
			self:close()
		end
	end
end

function PetFertilityChooseBallPopupCtrl:_setupList()
	if not self.view.listBallUList then
		return
	end

	local cubeList = self.model:getCubeList()

	self.isMultiItem = ItemSelectionTipsUtils.isMultiItem(#cubeList)

	if self.view.btnCloseUButton2 then
		self.view.btnCloseUButton2:RemoveLuaGamepadHotkey()

		if self.isMultiItem then
			self.view.btnCloseUButton2:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
				return true
			end)
			self.view.btnCloseUButton2:SetHotkeyConsoleBar("CONSOLE_BAR_SELECT_DESELECT", 1)
		end
	end

	function self.view.listBallUList.luaRenderItem(button, index, data)
		self:_renderBallItem(button, index, data)
	end

	self.view.listBallUList.luaSelectedChanged = nil

	function self.view.listBallUList.luaClick(button, data)
		if ItemSelectionTipsUtils.consumeLongPressClick(button) then
			return
		end

		if not data then
			return
		end

		if not self.isMultiItem then
			if ItemSelectionTipsUtils.isUsingGamepad() then
				return
			end

			button.isSelected = false

			ItemSelectionTipsUtils.showItemTips(button, data.itemId, data.count)

			return
		end

		self:_onSelect(data.itemId)
	end

	self.view.listBallUList:SetList(cubeList)
end

function PetFertilityChooseBallPopupCtrl:_renderBallItem(button, index, data)
	if not data then
		return
	end

	button.draggable = false

	LuaUIUtils.renderItem(button, {
		num = -1,
		id = data.itemId
	})

	button.gameObject.name = tostring(data.itemId)

	local objectReference = button:GetComponent("ObjectReference")

	if objectReference then
		local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")

		if NotNil(txtNumUBaseText) then
			LuaUIUtils.renderConsumeText(txtNumUBaseText, data.count or 0, 1, 1)
		end

		local recommendUContainer = objectReference:GetRefValue("recommendUContainer")

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
	end

	button.isSelected = self.isMultiItem and self.model:getSelectedItemId() == data.itemId

	ItemSelectionTipsUtils.bindLongPressTips(button, function()
		ItemSelectionTipsUtils.showItemTips(button, data.itemId, data.count)
	end)
end

function PetFertilityChooseBallPopupCtrl:_onSelect(itemId)
	local selectedItemId = ItemSelectionTipsUtils.toggleSelectedId(self.model:getSelectedItemId(), itemId)

	self.model:setSelectedItemId(selectedItemId)

	if self.view.listBallUList and self.view.listBallUList.RefreshList then
		self.view.listBallUList:RefreshList()
	end

	self:_refreshSelectState()
end

function PetFertilityChooseBallPopupCtrl:_refreshSelectState()
	self:_refreshDetails()
	self:_refreshTips()
	self:_refreshConfirmBtn()
end

function PetFertilityChooseBallPopupCtrl:_refreshDetails()
	if not self.view.txtDetailsUSDFText then
		return
	end

	ClientTextUtils.setText(self.view.txtDetailsUSDFText, "")
end

function PetFertilityChooseBallPopupCtrl:_refreshTips()
	local isSuggest = self.model:isSuggestSelected()
	local info = self.model:getSelectedInfo()
	local enough = info and info.isEnough or false
	local hide = isSuggest and enough

	if self.view.tipsUWidget then
		self.view.tipsUWidget.gameObject:SetActiveEx(not hide)
	end

	if hide then
		return
	end

	if not self.view.txtTipsUSDFText then
		return
	end

	local tipStr

	if isSuggest then
		local name = info and info.name and pg.getLocalizationText(info.name) or ""

		tipStr = string.format(pg.getGameString("CHOOSEBALL_FORMAT_TIP_RECOMMEND_TOBUY"), name)
	else
		local eggCfg = PetHatchEggData[self.eggItemId]

		tipStr = eggCfg and eggCfg.desc and pg.getLocalizationText(eggCfg.desc) or ""
	end

	ClientTextUtils.setText(self.view.txtTipsUSDFText, tipStr)
end

function PetFertilityChooseBallPopupCtrl:_getSourceTargetUIId()
	local seekData = ItemSourceData and ItemSourceData[self.sourceId]
	local param = seekData and seekData.param

	if not Utils.isTable(param) or param[1] ~= "openUI" then
		return nil
	end

	local targetParam = param[2]

	if not Utils.isTable(targetParam) then
		return nil
	end

	return targetParam[1]
end

function PetFertilityChooseBallPopupCtrl:_closeChooseBallForSourceJump(seekData)
	self._isOpeningSourceAfterClose = false

	if self:checkUIOpen() then
		self:closeImmediately()
	end

	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL) then
		return
	end

	if pg.game.soulEggEvolution and pg.game.soulEggEvolution:beginChooseCubeSourceJump(seekData) then
		return
	end

	local chooseBallCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)

	if chooseBallCtrl and chooseBallCtrl.closeForSourceJump then
		chooseBallCtrl:closeForSourceJump()
	else
		pg.global.ui:closeImmediately(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)
	end
end

function PetFertilityChooseBallPopupCtrl:_openSourceAfterClosingChooseBall(seekData)
	if self._isOpeningSourceAfterClose then
		return
	end

	if not seekData then
		return
	end

	local targetUIId = self:_getSourceTargetUIId()
	local targetCfg = targetUIId and UIConst.UI_CONFIGS[targetUIId]

	if not targetCfg or not targetCfg.fullScreen then
		LuaUIUtils.clueSeek(seekData, nil, self.view.btnConfirmUButton, self.sourceId)

		return
	end

	if not LuaUIUtils.checkItemSourceCondition(seekData) then
		LuaUIUtils.clueSeek(seekData, nil, self.view.btnConfirmUButton, self.sourceId)

		return
	end

	self._isOpeningSourceAfterClose = true

	local sourceId = self.sourceId

	if self:checkUIOpen() then
		self:closeImmediately()
	end

	LuaUIUtils.clueSeek(seekData, function()
		self:_closeChooseBallForSourceJump(seekData)
	end, nil, sourceId)
end

function PetFertilityChooseBallPopupCtrl:_refreshConfirmBtn()
	if not self.view.btnConfirmUButton then
		return
	end

	local info = self.model:getSelectedInfo()
	local selectedId = self.model:getSelectedItemId()
	local isSuggest = self.model:isSuggestSelected()
	local enough = info and info.isEnough or false
	local needBuy = isSuggest and not enough

	if needBuy then
		if self.view.btnConfirmUSDFText then
			ClientTextUtils.setText(self.view.btnConfirmUSDFText, pg.getGameString("CHOOSEBALL_GOTO_BUY"))
		end

		local seekData = ItemSourceData and ItemSourceData[self.sourceId]

		self.view.btnConfirmUButton.luaClick = nil

		LuaUIUtils.setSourceSeekButton(self.view.btnConfirmUButton, self.sourceId, true)

		if seekData and self.view.btnConfirmUButton.luaClick then
			function self.view.btnConfirmUButton.luaClick()
				self:_openSourceAfterClosingChooseBall(seekData)
			end
		end

		if not self.view.btnConfirmUButton.luaClick then
			function self.view.btnConfirmUButton.luaClick()
				pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)
			end
		end
	else
		if self.view.btnConfirmUSDFText then
			ClientTextUtils.setText(self.view.btnConfirmUSDFText, pg.getGameString("CHOOSEBALL_SURE_USE"))
		end

		function self.view.btnConfirmUButton.luaClick()
			self:_onConfirmUse(selectedId)
		end
	end
end

function PetFertilityChooseBallPopupCtrl:_onConfirmUse(itemId)
	if not itemId then
		return
	end

	local info = self.model:getCubeInfoById(itemId)

	if not info or not info.isEnough then
		pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)

		return
	end

	local cb = self.onConfirm

	self.onConfirm = nil

	if cb then
		cb(itemId)
	end

	self:close()
end

function PetFertilityChooseBallPopupCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetFertilityChooseBallPopupCtrl:onShow()
	return
end

function PetFertilityChooseBallPopupCtrl:onHide()
	return
end

return PetFertilityChooseBallPopupCtrl
