-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushBattleDetailResult\\BossRushBattleDetailResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushBattleDetailResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local BossRushFunData = require("Data.bossrush_fun_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local AvatarRobotData = require("Data.avatar_robot_data")
local BossRushBattleDetailResultCtrl = Class.LightClass("BossRushBattleDetailResultCtrl", UICtrl)

BossRushBattleDetailResultCtrl.messages = {}

function BossRushBattleDetailResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.levelId = info.levelId
	self.finalFunData = info.finalFunData
	self.lastCountDown = info.lastCountDown

	self.view.countDownUCountDown:Play(self.lastCountDown)
end

function BossRushBattleDetailResultCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderList(button, idx, data)
	end

	function self.view.countDownUCountDown.luaFinished()
		self:close()
	end
end

function BossRushBattleDetailResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BossRushBattleDetailResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.finalFunData = info and info.finalFunData or self.finalFunData

	self.view.listUList:SetList(self.finalFunData or {})
end

function BossRushBattleDetailResultCtrl:renderList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")
	local textTopTitleUBaseText = objectReference:GetRefValue("textTopTitleUBaseText")
	local badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	local playerHeadUButton = objectReference:GetRefValue("playerHeadUButton")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local textLastStrikeUSDFText = objectReference:GetRefValue("textLastStrikeUSDFText")
	local iconUImage = playerHeadUButton:GetComponent("ObjectReference"):GetRefValue("iconUImage")

	ClientTextUtils.setText(textLastStrikeUSDFText, pg.getGameString("BOSS_RUSH_RESULT_TIP6"))

	local pIdNum = tonumber(data.pId)
	local recordInfo = BossRushUtils.startBattlePlayerRecord[data.pId] or BossRushUtils.startBattlePlayerRecord[tostring(data.pId)] or pIdNum and BossRushUtils.startBattlePlayerRecord[pIdNum] or {}
	local ent = pg.getEntity(data.pId)
	local playerSnapshot = data.playerSnapshot
	local playerName = playerSnapshot.playerName

	if data.isAi then
		local robotData = AvatarRobotData[playerSnapshot.botTemplateId]

		if robotData and robotData.name then
			playerName = pg.getLocalizationText(robotData.name)
		end
	end

	local _h = BossRushBattleDetailResultCtrl._platformHooks

	playerName = _h and _h.getMaskedPlayerName and _h.getMaskedPlayerName(self, data, recordInfo, ent, playerName) or playerName

	ClientTextUtils.setText(textUSDFText, playerName)

	local order = data.order or index + 1

	if order < 1 or order > 4 then
		order = index + 1
	end

	playerHeadUButton:TryChangePage("Teammate", order - 1)

	local cfg = BossRushFunData[data.type]

	ClientTextUtils.setText(textTopTitleUBaseText, cfg and pg.getLocalizationText(cfg.name) or "")
	button:TryChangePage("Color", cfg and cfg.color or 0)
	button:TryChangePage("LastStrike", data.isLastStrike and 0 or 1)

	badgeIconUImage.url = cfg and cfg.titleIcon or "$UI_Icon_BossMod_ResultCard_badge1.png"

	local petInfo = playerSnapshot.petInfo

	if petInfo then
		iconUImage.url = LuaUIUtils.getPetIcon(PetData[petInfo.templateId].iconName, LuaUIUtils.PET_ICON, petInfo.label)
	end

	function listUList.luaRenderItem(button, index, data)
		self:renderListInList(button, index, data)
	end

	listUList:SetList(data.statistic or {})
end

function BossRushBattleDetailResultCtrl:renderListInList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtValueUSDFText = objectReference:GetRefValue("txtValueUSDFText")

	button:TryChangePage("Icon", index)
	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("BOSS_RUSH_RESULT_TIP3_" .. index + 1))
	ClientTextUtils.setText(txtValueUSDFText, data.value or 0)
end

function BossRushBattleDetailResultCtrl:onShow()
	return
end

function BossRushBattleDetailResultCtrl:onHide()
	return
end

function BossRushBattleDetailResultCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return BossRushBattleDetailResultCtrl
