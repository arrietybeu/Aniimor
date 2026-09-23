-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandLevelUpResult\\HomelandLevelUpResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandLevelUpResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandLevelUpResultCtrl = Class.LightClass("HomelandLevelUpResultCtrl", UICtrl)
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomelandFormulaData = require("Data.homeland_formula_data")
local UIConst = require("Const.UIConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")

HomelandLevelUpResultCtrl.messages = {}

function HomelandLevelUpResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.btnClose.luaClick()
		self:dismiss()
	end
end

function HomelandLevelUpResultCtrl:addListener()
	function self.view.listAttribute.luaRenderItem(button, index, data)
		self:onRenderAttrItem(button, index, data)
	end
end

function HomelandLevelUpResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomelandLevelUpResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local sData = info

	if sData.title then
		ClientTextUtils.setText(self.view.txtTitleUBaseText, sData.title)
	end

	self.view.listAttribute:SetList(sData.carryAttrs)
	ClientTextUtils.setText(self.view.txtLvNow, ClientTextUtils.formatShortLevel(sData.oldLv))
	ClientTextUtils.setText(self.view.txtLvAfter, ClientTextUtils.formatShortLevel(sData.newLv))
	pg.game.audio:playEvent("SFX_UI_PetEquipment_Breakthrough")
end

function HomelandLevelUpResultCtrl:onRenderAttrItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if data.tIndex == 0 then
		local txtName = objectReference:GetRefValue("txtTitleUSDFText")
		local txtNumNow = objectReference:GetRefValue("txtNumNowUSDFText")
		local txtNumAfter = objectReference:GetRefValue("txtNumAfterUSDFText")

		ClientTextUtils.setText(txtName, data.name)

		if data.tDesc and data.nDesc then
			ClientTextUtils.setText(txtNumNow, data.tDesc)
			ClientTextUtils.setText(txtNumAfter, data.nDesc)
		end
	elseif data.tIndex == 1 then
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		local listItemUList = objectReference:GetRefValue("listItemUList")

		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("HOMELAND_LEVEL_UNLOCKING_FORMULA"))

		if data.formulaList then
			function listItemUList.luaRenderItem(_button, _index, _data)
				LuaUIUtils.renderRewardItem(_button, _data)

				local objectReference = _button:GetComponent("ObjectReference")
				local imgMaskLockUWidget = objectReference:GetRefValue("imgMaskLockUWidget")

				if imgMaskLockUWidget then
					imgMaskLockUWidget:SetActive(_data.conditionLocked or _data.drawingLocked or false)
				end

				function _button.luaClick()
					local formulaData = HomelandFormulaData[_data.formulaId]
					local formulaInfo = ClientHomelandUtils.getHomeFormulaData(_data.formulaId)
					local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						padding = 20,
						id = _data.id,
						itemCount = ClientUtils.getHomelandItemCountById(_data.itemId),
						targetRect = self.view.listAttribute,
						formulaInfo = formulaInfo,
						conditionLockText = _data.conditionLocked and formulaData.unlockDesc,
						lockText = _data.drawingLocked and not _data.conditionLocked and ClientHomelandUtils.getDrawingUnlockText(false, false) or nil,
						sourceItemId = _data.drawingLocked and not _data.conditionLocked and formulaData.unlockByItemId or nil,
						sourceTitle = _data.drawingLocked and not _data.conditionLocked and ClientHomelandUtils.getDrawingSourceTitle(false) or nil,
						price = Utils.getHomeItemPrice(defaultOutputItem),
						extra = {
							closeFun = function()
								if not IsNil(listItemUList) then
									listItemUList:DeselectAll()
								end
							end
						}
					})
				end
			end

			listItemUList:SetList(data.formulaList)
		end
	elseif data.tIndex == 2 then
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

		ClientTextUtils.setText(txtTitleUSDFText, data.name)
	end
end

function HomelandLevelUpResultCtrl:onShow()
	return
end

function HomelandLevelUpResultCtrl:onHide()
	return
end

return HomelandLevelUpResultCtrl
