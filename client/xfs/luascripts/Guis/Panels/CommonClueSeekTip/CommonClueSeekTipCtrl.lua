-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonClueSeekTip\\CommonClueSeekTipCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonClueSeekTipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemSourceData = require("Data.item_source_data")
local CommonClueSeekTipCtrl = Class.LightClass("CommonClueSeekTipCtrl", UICtrl)

CommonClueSeekTipCtrl.messages = {}

function CommonClueSeekTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonClueSeekTipCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.rootUPopupForm.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.rootUPopupForm.luaCloseAction()
		self:close()
	end
end

function CommonClueSeekTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CommonClueSeekTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.info = {}
	self.info.clueTb = ItemSourceData[tonumber(info.clueSeekID)]
	self.info.targetRect = info.targetRect
	self.info.autoHor = info.autoHor
	self.info.autoVer = info.autoVer
	self.info.useCustomLayout = info.useCustomLayout
	self.info.verAlign = info.verAlign
	self.info.horAlign = info.horAlign
	self.info.isModel = info.isModel
	self.info.petInfo = info.petInfo
	self.info.padding = info.padding
	self.info.customRefresh = info.customRefresh
	self.info.tooltipAnchor = info.tooltipAnchor

	if info.targetRect then
		local tran = info.targetRect.transform

		while tran do
			self.info.targetUWidget = tran:GetComponent("UWidget")

			if self.info.targetUWidget then
				break
			end

			tran = tran.parent
		end
	end
end

function CommonClueSeekTipCtrl:onShow()
	if self.info == nil then
		return
	end

	self:setIsModel(self.info.isModel or false)

	if self.info.customRefresh then
		self.info.customRefresh(self.view.rootUPopupForm)
	else
		self:refreshClueSeekInfo()
	end

	if self.info.useCustomLayout then
		local autoVer = self.info.autoVer or false
		local autoHor = self.info.autoHor or false

		self.view.rootUPopupForm:SetAutoVertical(autoVer, autoHor)

		if self.info.verAlign then
			self.view.rootUPopupForm:SetVerAlignment(self.info.verAlign)
		end

		if self.info.horAlign then
			self.view.rootUPopupForm:SetHorAlignment(self.info.horAlign)
		end
	end

	self.view.rootUPopupForm:SetPadding(self.info.padding or 0)

	if self.info.targetUWidget and self.info.targetUWidget.sortingOrder then
		local sortOrder = self.info.targetUWidget.sortingOrder + 1

		self.view.rootUPopupForm:SetHierarchy(1, sortOrder)
	end

	self.view.rootUPopupForm:OpenPopup(self.info.targetRect)

	if self.info.tooltipAnchor then
		LuaUIUtils.alignTooltipToAnchorLeftTop(self.view.rootUPopupForm, self.info.tooltipAnchor)
	end

	self.view.rootUPopupForm:SetSingleDisplay(self.info.singleDisplay or true)
	self.view.rootUPopupForm:SetAutoClose(self.info.autoClose or true)
end

function CommonClueSeekTipCtrl:refreshClueSeekInfo()
	local data = self.info.clueTb
	local hasIcon = not string.isNilOrEmpty(data.type1_icon)

	self.view.rootUPopupForm:TryChangePage("State", 0)
	LuaUIUtils.setUIViewVisible(self.view.collectiblesTagUContainer, false)

	local showToSeeBtn = data.param ~= nil

	LuaUIUtils.setUIViewVisible(self.view.titleUWidget, hasIcon or data.buttonTxt ~= nil)
	self.view.iconUWidget:SetActiveFastestAndMarkIgnoreLayout(hasIcon)
	LuaUIUtils.setUIViewVisible(self.view.iconUImage, hasIcon)

	if hasIcon then
		self.view.iconUImage.url = data.type1_icon
	end

	ClientTextUtils.setText(self.view.nameUBaseText, pg.getLocalizationText(data.buttonTxt))

	LuaUIUtils.customRichTextData.petInfo = self.info.petInfo

	local tips = pg.getLocalizationText(data.tips)

	LuaUIUtils.customRichTextData.petInfo = nil

	ClientTextUtils.setText(self.view.textUBaseText, tips)
	LuaUIUtils.setUIViewVisible(self.view.btnDetailUButton, showToSeeBtn)
end

return CommonClueSeekTipCtrl
