-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\TeamGameplayComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local TeamGameplayComponent = Class.LightClass("TeamGameplayComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TeamPlayData = require("Data.team_play_data")
local ItemSourceData = require("Data.item_source_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")

function TeamGameplayComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.bgCloseUButton = self.objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.gameplayList = self.objectReference:GetRefValue("listUList")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
end

function TeamGameplayComponent:initView()
	self.selectedMessageText = ""

	function self.btnCloseUButton.luaClick()
		self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	end

	function self.bgCloseUButton.luaClick()
		self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	end

	function self.btnConfirmUButton.luaClick()
		LuaUIUtils.clueSeek(ItemSourceData[self.selectedTeamPlayData.sourceId], nil, self.selectedTeamPlayBtn)
	end

	self.confirmText = self.btnConfirmUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(self.confirmText, pg.getGameString("COMMON_CONFIRM"))

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.btnCloseUButton.luaClick()
	end

	function self.gameplayList.luaRenderItem(button, index, data)
		self:renderGameplayItem(button, index, data)
	end
end

function TeamGameplayComponent:renderGameplayItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local unlockTextUSDFText = objectReference:GetRefValue("unlockTextUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.teamplayName))
	ClientTextUtils.setText(txtNumUSDFText, pg.getLocalizationText(data.playnum))
	ClientTextUtils.setText(unlockTextUSDFText, pg.getLocalizationText(data.unlockCondition))

	bgUImage.url = data.res

	local isUnlock = not data.conditionId or ClientUtils.checkCondition(data.conditionId)

	button:TryChangePage("GamePlay", isUnlock and 0 or 1)

	function button.luaClick()
		pg.testBtn = button
		button.isSelected = true
		self.selectedTeamPlayBtn = button
		self.selectedTeamPlayData = data
		self.btnConfirmUButton.interactable = isUnlock
	end
end

function TeamGameplayComponent:refreshGameplayList()
	self.view.panelUComponent:TryChangePage("ShowPopup", 6)

	local gameplayData = {}

	for _, data in pairs(TeamPlayData) do
		table.insert(gameplayData, {
			teamplayName = data.teamplayName,
			playnum = data.playnum,
			unlockCondition = data.unlockCondition,
			sourceId = data.sourceId,
			res = data.res,
			conditionId = data.conditionId
		})
	end

	self.btnConfirmUButton.interactable = false

	self.gameplayList:SetList(gameplayData)
end

return TeamGameplayComponent
