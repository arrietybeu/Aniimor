-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeDetail\\BadgeDetailCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeDetailCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local PlayerBadgeData = require("Data.player_badge_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local Utils = require("Common.Utils.Utils")
local BadgeDetailCtrl = Class.LightClass("BadgeDetailCtrl", UICtrl)
local SWITCH_ANIM = "VX_Ani_Node_Personal_Badge_Details_IconIn"

BadgeDetailCtrl.messages = {}

function BadgeDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BadgeDetailCtrl:addListener()
	function self.view.backGroundCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.abilityUList.luaRenderItem(button, index, data)
		BadgeUtils.renderEntry(button, index, data, false)
	end

	function self.view.conditionUList.luaRenderItem(button, index, data)
		self:_renderCondition(button, index, data)
	end

	function self.view.tabListUList.luaRenderItem(button, index, data)
		self:_renderTabItem(button, index, data)
	end

	function self.view.tabListUList.luaClick(button, data)
		if self.model.curIndex == data.index then
			return
		end

		self:onChangeLevel(data.index)
	end

	ClientTextUtils.setText(self.view.abilityTtileUSDFText, pg.getGameString("TITLE_PRIVILEGE"))
	ClientTextUtils.setText(self.view.conditionTtileUSDFText, pg.getGameString("TITLE_CONDITION"))
	ClientTextUtils.setText(self.view.lockedUSDFText, pg.getGameString("BADGE_IS_LOCK"))
	ClientTextUtils.setText(self.view.abilityInUseUSDFText, pg.getGameString("ABILITY_HAS_TAKE_EFFECT"))
end

function BadgeDetailCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.model.curIndex = nil
end

function BadgeDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.badgeGroupId = info.badgeGroupId
	self.badgeId = info.badgeId
	self.isOtherPlayer = info.playerId ~= nil and info.playerId ~= pg.me.uid

	self.view.tagUWidget:SetActiveFastest(self.isOtherPlayer ~= true)

	if self.badgeGroupId == nil then
		self.badgeGroupId = BadgeUtils.getGroupId(info.badgeId)
	end

	self.model:initData(self.badgeGroupId, self.badgeId, self.isOtherPlayer)
	self.view.btnLeftUButton:SetActive(false)
	self.view.btnRightUButton:SetActive(false)
	self.view.tabListUList:SetList(self.model.data)

	local playerName = LuaUIUtils.getMeDisplayName()

	if self.isOtherPlayer == true then
		playerName = LuaUIUtils.getPlayerDisplayName(info.playerId, info.playerName, true)
	end

	ClientTextUtils.setText(self.view.textIDUSDFText, playerName)
	self:refreshView(self.model.curIndex)
end

function BadgeDetailCtrl:onShow()
	return
end

function BadgeDetailCtrl:onHide()
	return
end

function BadgeDetailCtrl:onChangeLevel(nextLevel)
	self:refreshView(nextLevel)
end

function BadgeDetailCtrl:refreshView(newIndex)
	self.view.detailsAnimation:Stop()
	self.view.detailsAnimation:Play(SWITCH_ANIM)

	newIndex = math.clamp(newIndex, 1, self.model.maxIndex)
	self.model.curIndex = newIndex

	self.view.tabListUList:DeselectAll()
	self.view.tabListUList:SelectItem(newIndex - 1)

	local curData = self.model.data[newIndex]
	local cfgData = PlayerBadgeData[curData.badgeId]
	local isSecret = curData.badgeState == Const.BADGE_STATUS.Secret
	local isUnlock = curData.badgeState == Const.BADGE_STATUS.Complete

	self.view.badgeIconUImage.url = cfgData.icon

	if cfgData.quality == BadgeUtils.RainBowQuality and isUnlock then
		self.view.badgeIconUImage:SetMaterial(BadgeUtils.RainBowMatPath)
	else
		self.view.badgeIconUImage.material = ""
	end

	ClientTextUtils.setText(self.view.textNameUSDFText, pg.getLocalizationText(cfgData.name))
	ClientTextUtils.setText(self.view.descUSDFText, pg.getLocalizationText(cfgData.desc))
	self.view.rootView:TryChangePage("Mystical", isSecret and 1 or 0)
	self.view.rootView:TryChangePage("Lock", isUnlock and 0 or 1)

	if isUnlock then
		if self.isOtherPlayer ~= true then
			ClientTextUtils.setText(self.view.unlockDayUSDFText, curData.unlockTime)
			ClientTextUtils.setText(self.view.unlockStarUSDFText, string.format("Lv.%d", curData.unlockLevel))
			ClientTextUtils.setText(self.view.unlockTitleUSDFText, curData.unlockStarName)
		end

		self.view.progressUProgress:SetActiveFastest(false)
		self.view.rootView:TryChangePage("Quality", cfgData.quality)
	else
		self.view.rootView:TryChangePage("Quality", 0)
		ClientTextUtils.setText(self.view.unlockDayUSDFText, "")
		ClientTextUtils.setText(self.view.unlockStarUSDFText, pg.getGameString("LEARN_SKILL_TIPS"))
		ClientTextUtils.setText(self.view.unlockTitleUSDFText, "")

		if isSecret then
			self.view.badgeIconMysticalUImage.url = BadgeUtils.getBadgeSlotIcon(cfgData.group)

			ClientTextUtils.setText(self.view.textNameUSDFText, pg.getGameString("BADGE_SECRET_NAME"))
			ClientTextUtils.setText(self.view.descUSDFText, pg.getGameString("BADGE_SECRET_DESC"))
		end

		self.view.progressUProgress:SetActiveFastest(true)

		self.view.progressUProgress.maxValue = 1
		self.view.progressUProgress.value = curData.process
	end

	local entryData = self.model.getEntryData(cfgData)
	local entryIsEmpty = Utils.tableIsEmptyOrNil(entryData)

	if entryIsEmpty or isSecret then
		self.view.privilegTitleUWidget:SetActiveFastest(false)
		self.view.abilityUList:SetActiveFastest(false)
	else
		self.view.privilegTitleUWidget:SetActiveFastest(true)
		self.view.abilityUList:SetActiveFastest(true)
		self.view.abilityUList:SetList(entryData)
	end

	self.view.conditionUList:SetActive(true)

	if not isSecret then
		ClientTextUtils.setText(self.view.conditionTtileUSDFText, pg.getGameString("TITLE_CONDITION"))

		local conditionData = BadgeUtils.getConditionInfo(cfgData, self.isOtherPlayer)

		self.view.conditionUList:SetList(conditionData)
	else
		ClientTextUtils.setText(self.view.conditionTtileUSDFText, pg.getGameString("TITLE_CLUE"))

		if cfgData.clue then
			self.view.conditionUList:SetList({
				{
					tIndex = 0,
					clue = pg.getLocalizationText(cfgData.clue),
					source = cfgData.clueSource
				}
			})
		else
			self.view.conditionUList:SetList({})
		end
	end
end

function BadgeDetailCtrl:_renderCondition(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if data.clue then
			button:TryChangePage("ConditionState", 0)
			ClientTextUtils.setText(txtNameUSDFText, data.clue)
		else
			local isComplete = data.curNum >= data.needNum
			local desc = string.format("%s [%s/%s]", pg.getLocalizationText(data.desc), data.curNum, data.needNum)

			ClientTextUtils.setText(txtNameUSDFText, desc)
			button:TryChangePage("ConditionState", isComplete and 1 or 0)
		end

		button:TryChangePage("Click", data.source and 0 or 1)

		if data.source then
			function button.luaClick()
				LuaUIUtils.clueSeek(data.source, nil, button)
			end
		end
	elseif data.tIndex == 1 then
		local objectReference = button:GetComponent("ObjectReference")
		local listUList = objectReference:GetRefValue("listUList")

		listUList.luaRenderItem = BadgeDetailCtrl._renderOnePet

		listUList:SetList(data.collect)
	elseif data.tIndex == 2 then
		local objectReference = button:GetComponent("ObjectReference")
		local listUList = objectReference:GetRefValue("listUList")

		listUList.luaRenderItem = BadgeDetailCtrl._renderOneItem

		listUList:SetList(data.collect)
	end
end

function BadgeDetailCtrl._renderOnePet(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
	local icon = objectReference:GetRefValue("icon")
	local petInfoTip = objectReference:GetRefValue("petInfoTip")
	local petTextTip = objectReference:GetRefValue("petTextTip")

	button.draggable = false

	local stateIndex = 0

	if data.state == BadgeUtils.PET_STATE_IS_KNOWN then
		stateIndex = 1
	elseif data.state == BadgeUtils.PET_STATE_IS_EMPTY then
		stateIndex = 4
	end

	button:TryChangePage("state", stateIndex)

	icon.url = data.petIcon
end

function BadgeDetailCtrl._renderOneItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	itemIconUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

	ClientTextUtils.setText(txtNumUText, data.needNum)

	local itemConfig = ItemData[data.itemId]

	if itemConfig then
		local quality = itemConfig.quality or 0

		if data.type == 2 then
			quality = quality + 3
		end

		button:TryChangePage("Quality", quality)
	end

	local isGet = data.curNum >= data.needNum

	button:TryChangePage("State", isGet and 1 or 0)
end

function BadgeDetailCtrl:_renderTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = BadgeUtils.QUALITY_ICON[data.quality]
end

function BadgeDetailCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_PLAYER_ENHANCEMENT] = true
	whiteList[UIConst.UI_ID_MAP] = true
	whiteList[UIConst.UI_ID_SEASON_ACHIEVEMENT] = true

	return whiteList
end

return BadgeDetailCtrl
