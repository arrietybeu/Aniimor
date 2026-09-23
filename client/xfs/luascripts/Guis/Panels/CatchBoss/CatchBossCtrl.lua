-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchBoss\\CatchBossCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchBossCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local Const = require("Common.Const.Const")
local sysConfigData = require("Data.sys_config_data")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local CatchBossCtrl = Class.LightClass("CatchBossCtrl", UICtrl)

CatchBossCtrl.messages = {}

function CatchBossCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CatchBossCtrl:addListener()
	function self.view.btnUnsnapUButton.luaClick()
		self:onUnSnapClick()
	end
end

function CatchBossCtrl:onDestroy()
	UICtrl.onDestroy(self)
	pg.global.ui:show(UIConst.UI_ID_HUD_V2)
end

function CatchBossCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	pg.global.ui:hide(UIConst.UI_ID_HUD_V2)

	self.bossEntity = info.bossEntity

	self:refreshInfo()
end

function CatchBossCtrl:onShow()
	self.view:showSight(self.bossEntity.id)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossCatch, true)
end

function CatchBossCtrl:onHide()
	self.view:showSight(nil)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossCatch, false)
end

function CatchBossCtrl:refreshInfo()
	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderCatchBallItem(button, idx, data)
	end

	self.itemList = self.model:getBossCapturePropInfos(self.bossEntity)

	if #self.itemList < 6 then
		local startIdx = #self.itemList + 1
		local endIdx = 6

		for i = startIdx, endIdx do
			table.insert(self.itemList, {
				empty = true
			})
		end
	end

	self.view.listUList:SetList(self.itemList)

	local gender = 2

	if self.bossEntity.gender == Const.GENDER_TYPE_MALE then
		gender = 0
	elseif self.bossEntity.gender == Const.GENDER_TYPE_FEMALE then
		gender = 1
	end

	local pData = self.bossEntity:getConfigData()

	self.view.bossInfoUComponent:TryChangePage("Gender", gender)
	ClientTextUtils.setText(self.view.txtLvUBaseText, string.format("%s %s", pg.getGameString("LEVEL_TAG"), self.bossEntity.level))
	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getLocalizationText(pData.name))

	function self.view.listElementUList.luaRenderItem(button, idx, data)
		self:renderBossElementItem(button, idx, data)
	end

	local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

	self.view.listElementUList:SetList(elementNames)

	function self.view.listTagUList.luaRenderItem(button, idx, data)
		self:renderBossTagItem(button, idx, data)
	end

	local key, str
	local tagList = {}
	local hasRealTag = not Utils.tableIsEmptyOrNil(pData.eliteCatchPanelTag)
	local realTagInfo = hasRealTag and pData.eliteCatchPanelTag or sysConfigData.eliteCatchPanelTagDefault

	for i = 1, #realTagInfo do
		key = realTagInfo[i]
		str = hasRealTag and pg.getLocalizationText(key) or pg.getGameString(key)

		table.insert(tagList, {
			tag = str
		})
	end

	self.view.listTagUList:SetList(tagList)
end

function CatchBossCtrl:renderCatchBallItem(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootComponent = objectReference:GetRefValue("rootComponent")
	local iconBallUImage = objectReference:GetRefValue("iconBallUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local txtPercentUBaseText = objectReference:GetRefValue("txtPercentUBaseText")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local rootButton = objectReference:GetRefValue("rootButton")

	if data.empty then
		rootComponent:TryChangePage("Empty", 0)

		rootButton.luaClick = nil
	else
		rootComponent:TryChangePage("Empty", 1)

		iconBallUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

		ClientTextUtils.setText(txtNumUBaseText, data.count)
		ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))

		local finalProb = LuaUIUtils.formatCatchRate(data.prob)

		ClientTextUtils.setText(txtPercentUBaseText, finalProb .. "%")

		local ratePage = ClientCaptureUtils.getBossCatchPageByRate(data.prob)

		rootComponent:TryChangePage("SuccessRate", ratePage)

		function rootButton.luaClick()
			self:realSelectItem(idx + 1)
		end

		if idx == 0 and data.count <= 0 then
			rootButton.interactable = false
		else
			rootButton.interactable = true
		end
	end
end

function CatchBossCtrl:renderBossElementItem(button, idx, data)
	LuaUIUtils.setElementGrade(button, data.element, self.bossEntity.templateId, false)
end

function CatchBossCtrl:renderBossTagItem(button, idx, data)
	local txtTagName = button:Find("TxtTag"):GetComponent("UBaseText")

	ClientTextUtils.setText(txtTagName, data.tag)
end

function CatchBossCtrl:onUnSnapClick()
	pg.me:cancelBossCapture(self.bossEntity.actorId)
	self:dismiss()
end

function CatchBossCtrl:realSelectItem(itemIndex)
	if self.lastClickTime and Time.realSecondCache - self.lastClickTime <= 3 then
		return
	end

	self.lastClickTime = Time.realSecondCache
	itemIndex = math.clamp(itemIndex, 1, #self.itemList)

	local newCastItem = self.itemList[itemIndex]

	if not newCastItem or newCastItem.empty then
		return false
	end

	self.curSelectCastItem = newCastItem

	if pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end

	if pg.game.controller.onHandleThrow then
		pg.game.controller:onHandleThrow()
	end
end

function CatchBossCtrl:getCurSelectPropId()
	return self.curSelectCastItem.itemId
end

function CatchBossCtrl:onBackPackInfoChange()
	self.itemList = self.model:getBossCapturePropInfos(self.bossEntity)

	if #self.itemList < 6 then
		local startIdx = #self.itemList + 1
		local endIdx = 6

		for i = startIdx, endIdx do
			table.insert(self.itemList, {
				empty = true
			})
		end
	end

	self.view.listUList:SetList(self.itemList)
end

return CatchBossCtrl
