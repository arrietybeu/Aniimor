-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\FirstTopupCardRenderer.lua

local logger = require("Core.Log.LoggerManager").getLogger("FirstTopupCardRenderer")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local HotkeyConst = require("Const.HotkeyConst")
local FirstTopupCardRenderer = Class.LightClass("FirstTopupCardRenderer")

FirstTopupCardRenderer.CardState = {
	LOCKED = 0,
	RECEIVED = 3,
	CAN_RECEIVE = 2,
	UNLOCKED = 1
}

function FirstTopupCardRenderer:ctor(rootUComponent, callbacks)
	self.rootUComponent = rootUComponent
	self.callbacks = callbacks or {}
	self.refs = {}

	self:_findAllObjects()
end

function FirstTopupCardRenderer:_findAllObjects()
	local objectReference = self.rootUComponent:GetComponent("ObjectReference")

	if not objectReference then
		logger:warn("ObjectReference not found in contentUComponent")

		return
	end

	local refs = self.refs

	refs.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	refs.tipsUSDFText = objectReference:GetRefValue("tipsUSDFText")
	refs.gotoUButton = objectReference:GetRefValue("gotoUButton")

	if refs.gotoUButton then
		local gotoObjectReference = refs.gotoUButton:GetComponent("ObjectReference")

		refs.gotoBtnUText = gotoObjectReference:GetRefValue("txtNameUText")
	end

	refs.card1 = {
		button = objectReference:GetRefValue("card1UButton"),
		titleText = objectReference:GetRefValue("card1TitleUSDFText"),
		rewardList = objectReference:GetRefValue("card1RewardUList"),
		tipsText = objectReference:GetRefValue("card1TipsUSDFText"),
		getButtonText = objectReference:GetRefValue("card1GetUSDFText"),
		num01USDFText = objectReference:GetRefValue("num01USDFText"),
		cardHotKeyContent = objectReference:GetRefValue("card1HotKeyContent")
	}
	refs.card2 = {
		button = objectReference:GetRefValue("card2UButton"),
		itemButton = objectReference:GetRefValue("card2ItemUButton"),
		itemText = objectReference:GetRefValue("card2ItemUSDFText"),
		tipsText = objectReference:GetRefValue("card2TipsUSDFText"),
		getButtonText = objectReference:GetRefValue("card2GetUSDFText"),
		num02USDFText = objectReference:GetRefValue("num02USDFText"),
		cardHotKeyContent = objectReference:GetRefValue("card2HotKeyContent"),
		itemNameBtnText = objectReference:GetRefValue("itemNameBtn2USDFText")
	}
	refs.card3 = {
		button = objectReference:GetRefValue("card3UButton"),
		itemButton = objectReference:GetRefValue("card3ItemUButton"),
		itemText = objectReference:GetRefValue("card3ItemUSDFText"),
		tipsText = objectReference:GetRefValue("card3TipsUSDFText"),
		getButtonText = objectReference:GetRefValue("card3GetUSDFText"),
		num03USDFText = objectReference:GetRefValue("num03USDFText"),
		cardHotKeyContent = objectReference:GetRefValue("card3HotKeyContent"),
		itemNameBtnText = objectReference:GetRefValue("itemNameBtn3USDFText")
	}
end

function FirstTopupCardRenderer:bindListeners(cardClickCallback, itemClickCallback)
	local refs = self.refs

	self.cardClickCallback = cardClickCallback

	if refs.card1.button then
		function refs.card1.button.luaClick()
			if cardClickCallback then
				cardClickCallback(1)
			end
		end

		if refs.card1.cardHotKeyContent then
			refs.card1.button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, refs.card1.cardHotKeyContent.gameObject)
			refs.card1.button:SetHotkeyActiveOnlyInCurrentItem(true)
		end
	end

	if refs.card2.button then
		function refs.card2.button.luaClick()
			if cardClickCallback then
				cardClickCallback(2)
			end
		end

		if refs.card2.cardHotKeyContent then
			refs.card2.button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, refs.card2.cardHotKeyContent.gameObject)
			refs.card2.button:SetHotkeyActiveOnlyInCurrentItem(true)
		end
	end

	if refs.card3.button then
		function refs.card3.button.luaClick()
			if cardClickCallback then
				cardClickCallback(3)
			end
		end

		if refs.card3.cardHotKeyContent then
			refs.card3.button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, refs.card3.cardHotKeyContent.gameObject)
			refs.card3.button:SetHotkeyActiveOnlyInCurrentItem(true)
		end
	end

	if refs.card1.rewardList then
		function refs.card1.rewardList.luaRenderItem(button, index, itemData)
			self:_renderCard1ListItem(button, itemData, itemClickCallback)
		end
	end

	if refs.gotoUButton then
		function refs.gotoUButton.luaClick()
			if self.callbacks.onGotoShop then
				self.callbacks.onGotoShop()
			end
		end
	end
end

function FirstTopupCardRenderer:setPageState(isInEventPanel, hasTopup)
	self.rootUComponent:TryChangePage("Btn", hasTopup and 0 or 1)
	self.rootUComponent:TryChangePage("Pop", isInEventPanel and 1 or 0)
end

function FirstTopupCardRenderer:refreshStaticTexts()
	local refs = self.refs

	if refs.titleUSDFText then
		ClientTextUtils.setText(refs.titleUSDFText, pg.getGameString("Firstopup_tips"))
	end

	if refs.card1.getButtonText then
		ClientTextUtils.setText(refs.card1.getButtonText, pg.getGameString("TOPUP_REWARD_CLAIM"))
	end

	if refs.card2.getButtonText then
		ClientTextUtils.setText(refs.card2.getButtonText, pg.getGameString("TOPUP_REWARD_CLAIM"))
	end

	if refs.card3.getButtonText then
		ClientTextUtils.setText(refs.card3.getButtonText, pg.getGameString("TOPUP_REWARD_CLAIM"))
	end

	if refs.gotoBtnUText then
		ClientTextUtils.setText(refs.gotoBtnUText, pg.getGameString("Firstopup_buttom"))
	end

	if refs.card1.titleText then
		ClientTextUtils.setText(refs.card1.titleText, pg.getGameString("Firstopup_reward_status4"))
	end

	if refs.card1.num01USDFText then
		ClientTextUtils.setText(refs.card1.num01USDFText, "01")
	end

	if refs.card2.num02USDFText then
		ClientTextUtils.setText(refs.card2.num02USDFText, "02")
	end

	if refs.card3.num03USDFText then
		ClientTextUtils.setText(refs.card3.num03USDFText, "03")
	end
end

function FirstTopupCardRenderer:_computeCardState(taskData, prevCardState)
	local taskState = taskData.taskState
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv
	local hasReceived = taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail

	if hasReceived then
		return self.CardState.RECEIVED
	elseif canReceive then
		return self.CardState.CAN_RECEIVE
	elseif prevCardState and prevCardState >= self.CardState.CAN_RECEIVE then
		return self.CardState.UNLOCKED
	else
		return self.CardState.LOCKED
	end
end

function FirstTopupCardRenderer:refreshCard1(taskData)
	local refs = self.refs.card1

	if not refs.button then
		return self.CardState.LOCKED
	end

	local state = self:_computeCardState(taskData, nil)
	local taskState = taskData.taskState
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv
	local hasReceived = taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail

	if refs.cardHotKeyContent then
		refs.button:SetHotkeyForceHidden(not canReceive)
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(taskData.taskAward, hasReceived, canReceive)

	for i, reward in ipairs(rewards) do
		reward.tIndex = i == 1 and 0 or (i == 2 or i == 3) and 1 or 2
	end

	if refs.rewardList then
		refs.rewardList:SetList(rewards)
	end

	local buttonState = hasReceived and 2 or canReceive and 1 or 0

	refs.button:TryChangePage("State", buttonState)

	if refs.tipsText then
		local tipsKey = hasReceived and "Firstopup_reward_status3" or "Firstopup_reward_status2"

		ClientTextUtils.setText(refs.tipsText, pg.getGameString(tipsKey))
	end

	return state
end

function FirstTopupCardRenderer:refreshCard2Or3(taskData, cardIndex, prevCardState)
	local cardKey = "card" .. cardIndex
	local refs = self.refs[cardKey]

	if not refs or not refs.button then
		return self.CardState.LOCKED
	end

	local state = self:_computeCardState(taskData, prevCardState)
	local taskState = taskData.taskState
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv
	local hasReceived = taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail
	local rewards = LuaUIUtils.getRewardItemByDropId(taskData.taskAward, hasReceived, canReceive)

	refs.button:TryChangePage("State", state)

	if refs.tipsText then
		if hasReceived then
			ClientTextUtils.setText(refs.tipsText, pg.getGameString("Firstopup_reward_status3"))
		elseif not canReceive then
			ClientTextUtils.setText(refs.tipsText, pg.getGameString("Firstopup_reward_status1"))
		end
	end

	if rewards and #rewards > 0 and refs.itemButton then
		self:_renderRewardItem(refs.itemButton, refs.itemText, rewards[1])

		if refs.itemNameBtnText then
			ClientTextUtils.setText(refs.itemNameBtnText, LuaUIUtils.getNameByItemId(rewards[1].id) or "")
		end

		if canReceive then
			function refs.button.luaClick()
				if self.cardClickCallback then
					self.cardClickCallback(cardIndex)
				end
			end
		else
			function refs.itemButton.luaClick()
				if self.callbacks.onItemClick then
					self.callbacks.onItemClick(rewards[1], refs.itemButton)
				end
			end
		end

		if refs.cardHotKeyContent then
			refs.button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, refs.cardHotKeyContent.gameObject, function()
				if canReceive then
					if self.cardClickCallback then
						self.cardClickCallback(cardIndex)
					end
				elseif self.callbacks.onItemClick then
					self.callbacks.onItemClick(rewards[1], refs.itemButton)
				end

				return false
			end)
			refs.button:SetHotkeyActiveOnlyInCurrentItem(true)
			refs.button:SetHotkeyForceHidden(false)
		end
	end

	return state
end

function FirstTopupCardRenderer:_renderRewardItem(itemButton, itemText, rewardData)
	local objectReference = itemButton:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")

	if itemIconUImage then
		itemIconUImage.url = LuaUIUtils.getIconByItemId(rewardData.id)
	end

	if itemText then
		ClientTextUtils.setText(itemText, "x" .. tostring(rewardData.num))
	end
end

function FirstTopupCardRenderer:_renderCard1ListItem(button, itemData, clickCallback)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")

	if iconUImage then
		iconUImage.url = LuaUIUtils.getIconByItemId(itemData.id)
	end

	function button.luaClick()
		if clickCallback then
			clickCallback(itemData, button)
		end
	end
end

function FirstTopupCardRenderer:dispose()
	self.rootUComponent = nil
	self.refs = {}
	self.callbacks = {}
	self.cardClickCallback = nil
end

function FirstTopupCardRenderer:getCardButton(index)
	if not self.refs then
		return nil
	end

	local cardKey = "card" .. index
	local card = self.refs[cardKey]

	if not card then
		return nil
	end

	return card.button
end

function FirstTopupCardRenderer:refreshRewardRedDots(rewardTasks, getTreePath)
	for index = 1, 3 do
		local taskData = rewardTasks and rewardTasks[index]
		local button = self:getCardButton(index)
		local treePath = getTreePath and getTreePath(index)

		if button and treePath then
			local canReceive = taskData and taskData.taskState == ActivityConst.TaskState.Finihed_CanRecv

			pg.global.setRedDot(treePath, button, canReceive == true, RedDotConst.RedDotStyle.REWARD)
		end
	end
end

return FirstTopupCardRenderer
