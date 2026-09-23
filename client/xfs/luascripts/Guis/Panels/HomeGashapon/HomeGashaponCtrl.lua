-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeGashapon\\HomeGashaponCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local EventConst = require("Const.EventConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local CONSOLE_BAR_LISTENER_NAME = "HomeGashaponConsoleBar"
local CONSOLE_BAR_STATE_RULE = "HomeGashapon_Rule"
local CONSOLE_BAR_STATE_SELECT = "HomeGashapon_Select"
local NAV_GROUP_REWARD_LIST = "ListReward"
local NAV_GROUP_CURRENCY_LIST = "ListCurrency"
local HomeGashaponCtrl = Class.LightClass("HomeGashaponCtrl", UICtrl)

HomeGashaponCtrl.SHOWCASE_FOV = 48
HomeGashaponCtrl.SHOWCASE_VERTICAL_COVERAGE = 0.56
HomeGashaponCtrl.SHOWCASE_PITCH = 10
HomeGashaponCtrl.SHOWCASE_YAW = 0
HomeGashaponCtrl.SHOWCASE_HORIZONTAL_OFFSET_RATIO = 0
HomeGashaponCtrl.SHOWCASE_VERTICAL_OFFSET_RATIO = 0.02
HomeGashaponCtrl.SHOWCASE_BLEND_TIME = 0.8
HomeGashaponCtrl.DRAW_BUTTON_ANIM_DELAY = 0.8
HomeGashaponCtrl.DRAW_ANIM_FALLBACK_TIME = 15
HomeGashaponCtrl.PERIOD_RESET_DELAY_OFFSET = 1
HomeGashaponCtrl.DRAW_ANIM_REWARD_TIME = 7.5
HomeGashaponCtrl.messages = {
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_PETS_CHANGE] = {
		"onHomelandPetsChanged",
		true
	}
}

local function setText(target, text)
	if target then
		ClientTextUtils.setText(target, text)
	end
end

function HomeGashaponCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.ornamentId = nil
	self.isRequesting = false
	self.isDrawing = false
	self.isWaitingDrawButtonAnim = false
	self.drawButtonAnimTimer = nil
	self.drawAnimTimer = nil
	self.drawRewardVxAnimTimer = nil
	self.drawRewardVxTierId = nil
	self.isRewardVxDelayFinished = false
	self.isFurnitureDrawFinished = false
	self.isWaitingRewardPanelClose = false
	self.isRewardPanelClosed = false
	self.onRewardPanelClose = nil
	self.periodResetTimer = nil
	self.periodStart = nil
	self._drawUIHidden = false
	self._gashaponCtrlDestroyed = false
	self._focusEnabled = false
	self._showcaseActorsHidden = false
	self._hiddenHomePetIds = {}
	self.drawCount = 0
	self.drawLimit = 0
	self.nextCostCount = 0
end

function HomeGashaponCtrl:addListener()
	UICtrl.addListener(self)

	local view = self.view
	local closeButton = view.btnBackUButton
	local ruleButton = view.btnInfoUButton
	local drawButton = view.btnPlayUButton
	local rewardList = view.listRewardUList

	if closeButton then
		closeButton.luaClick = CallbackHandler(self, "onClickClose")
	end

	if ruleButton then
		ruleButton.luaClick = CallbackHandler(self, "onClickRule")
	end

	if drawButton then
		drawButton.luaClick = CallbackHandler(self, "onClickDraw")
	end

	if rewardList then
		rewardList.luaRenderItem = CallbackHandler(self, "renderRewardItem")
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaHotkeyActivationChangedListener(CONSOLE_BAR_LISTENER_NAME, function()
			self:refreshConsoleBarState()
		end)
	end
end

function HomeGashaponCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.ornamentId = info.ornamentId
	self.periodStart = nil

	self:syncPeriodState()
	self:schedulePeriodReset()
	self:focusFurniture()
	self:refreshStaticTexts()
	self:refreshAll()
	self:refreshConsoleBarState()
end

function HomeGashaponCtrl:onDestroy()
	self._gashaponCtrlDestroyed = true

	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener(CONSOLE_BAR_LISTENER_NAME)
	end

	if self.drawAnimTimer then
		self:killTimer(self.drawAnimTimer)

		self.drawAnimTimer = nil
	end

	if self.drawButtonAnimTimer then
		self:killTimer(self.drawButtonAnimTimer)

		self.drawButtonAnimTimer = nil
	end

	if self.drawRewardVxAnimTimer then
		self:killTimer(self.drawRewardVxAnimTimer)

		self.drawRewardVxAnimTimer = nil
	end

	self:clearRewardPanelCloseWait()

	if self.periodResetTimer then
		self:killTimer(self.periodResetTimer)

		self.periodResetTimer = nil
	end

	self.isDrawing = false
	self.isWaitingDrawButtonAnim = false
	self.drawRewardVxTierId = nil
	self.isRewardVxDelayFinished = false
	self.isFurnitureDrawFinished = false
	self.isWaitingRewardPanelClose = false
	self.isRewardPanelClosed = false

	self:resetFurnitureDraw()
	self:setDrawUIVisible(true)

	if self._focusEnabled and pg.game and pg.game.camera then
		pg.game.camera:enableFocusTarget(false)

		self._focusEnabled = false
	end

	if self._showcaseActorsHidden and pg.me then
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_GASHAPON, true)
		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_GASHAPON, true)

		for petId in pairs(self._hiddenHomePetIds) do
			local pet = pg.getEntity(petId)

			if pet then
				pet:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_GASHAPON, true)
			end
		end

		table.clear(self._hiddenHomePetIds)

		self._showcaseActorsHidden = false
	end

	UICtrl.onDestroy(self)
end

function HomeGashaponCtrl:refreshConsoleBarState()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local inRewardList = navMgr.CurrentFocusedGroupName == NAV_GROUP_REWARD_LIST
	local inCurrencyList = navMgr.CurrentFocusedGroupName == NAV_GROUP_CURRENCY_LIST
	local isVirtualMouseMode = navMgr.IsVirtualMouseMode

	navMgr:SetConsoleBarState(CONSOLE_BAR_STATE_RULE, not inRewardList and not inCurrencyList and not isVirtualMouseMode)
	navMgr:SetConsoleBarState(CONSOLE_BAR_STATE_SELECT, inRewardList or inCurrencyList)
	self:refreshRuleButtonVisibility(isVirtualMouseMode)
end

function HomeGashaponCtrl:refreshRuleButtonVisibility(isVirtualMouseMode)
	local hideRuleButton = pg.game.input:isUsingGamepad() and not isVirtualMouseMode

	self.view.btnInfoUButton.renderOpacity = hideRuleButton and 0.001 or 1
end

function HomeGashaponCtrl:refreshStaticTexts()
	setText(self.view.tMPUSDFText, pg.getGameString("HOME_GACHA_TIPS_TITLE"))
	setText(self.view.txtNameUSDFText, pg.getGameString("BATTLEPASS_RULE_TITLE"))
	setText(self.view.txtNumUSDFText, "")
	setText(self.view.niuDanUSDFText, pg.getGameString("HOME_GACHA"))
end

function HomeGashaponCtrl:refreshAll()
	self:refreshCurrency()
	self:refreshDrawState()
	self:refreshDisplayRewards()
end

function HomeGashaponCtrl:syncPeriodState()
	local periodStart = self.model:getCurrentPeriodStart()

	if self.periodStart == periodStart then
		return false
	end

	self.periodStart = periodStart
	self.drawCount = self.model:getDrawCount()
	self.drawLimit = self.model:getDrawLimit()
	self.nextCostCount = self.model:getCostCount(self.drawCount + 1)

	return true
end

function HomeGashaponCtrl:schedulePeriodReset()
	if self.periodResetTimer then
		self:killTimer(self.periodResetTimer)

		self.periodResetTimer = nil
	end

	local nextResetTime = self.model:getNextResetTime()

	if nextResetTime <= 0 then
		return
	end

	local delay = nextResetTime - Time.secondCache + HomeGashaponCtrl.PERIOD_RESET_DELAY_OFFSET

	self.periodResetTimer = self:startTimer(function()
		self.periodResetTimer = nil

		self:syncPeriodState()
		self:refreshDrawState()
		self:schedulePeriodReset()
	end, delay)
end

function HomeGashaponCtrl:refreshCurrency()
	local costItemId = self.model:getCostItemId()
	local iconCostItem = self.view.iconCostUImage

	if iconCostItem then
		iconCostItem.url = LuaUIUtils.getIconByItemId(costItemId)
	end

	if self.view.listCurrencyUList and costItemId > 0 then
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, {
			costItemId
		})
	end
end

function HomeGashaponCtrl:refreshDrawState()
	local canDraw = not self.isRequesting and not self.isDrawing and not self.isWaitingDrawButtonAnim
	local ownCount = ClientUtils.getItemCountById(self.model:getCostItemId(), true) or 0
	local costCountText = tostring(self.nextCostCount)

	if ownCount < self.nextCostCount then
		costCountText = "<color=#FF6969>" .. costCountText .. "</color>"
	end

	setText(self.view.txtCostUSDFText, costCountText)

	local remainingDrawCount = math.max(self.drawLimit - self.drawCount, 0)

	setText(self.view.txtTitleUSDFText, pg.getFormatText(pg.getGameString("HOME_GACHA_NUM"), remainingDrawCount, self.drawLimit))

	local drawButton = self.view.btnPlayUButton

	if drawButton then
		drawButton.interactable = canDraw
	end
end

function HomeGashaponCtrl:refreshDisplayRewards()
	local list = self.view.listRewardUList

	if list then
		list:SetList(self.model:getDisplayRewards())
	end
end

function HomeGashaponCtrl:onItemCountChanged(message)
	local costItemId = self.model:getCostItemId()
	local changedItemId = message and tonumber(message.itemId or message.genId) or nil

	if changedItemId and changedItemId ~= costItemId then
		return
	end

	self:refreshCurrency()
	self:refreshDrawState()
end

function HomeGashaponCtrl:renderRewardItem(button, index, data)
	LuaUIUtils.renderRewardItem(button, data)
end

function HomeGashaponCtrl:onClickDraw()
	if self.isRequesting or self.isDrawing or self.isWaitingDrawButtonAnim then
		return
	end

	if self:syncPeriodState() then
		self:refreshDrawState()
	end

	if not self:canDrawWithNotice() then
		return
	end

	self:playFurnitureStart()
	self:playRewardVx()
	self:startDrawRequestAfterButtonAnim()
end

function HomeGashaponCtrl:canDrawWithNotice()
	if self.drawLimit <= 0 then
		pg.global.showBubbleMessage(NoticeDef.ERROR_CHECK_COND_FAILED)

		return false
	end

	if self.drawCount >= self.drawLimit then
		pg.global.showBubbleMessage(NoticeDef.HOME_LOTTERY_LIMIT_REACHED)

		return false
	end

	local costItemId = self.model:getCostItemId()
	local ownCount = ClientUtils.getItemCountById(costItemId, true) or 0

	if ownCount < self.nextCostCount then
		pg.global.showBubbleMessage(NoticeDef.HOME_GACHA_COIN_LACK)

		return false
	end

	return true
end

function HomeGashaponCtrl:startDrawRequestAfterButtonAnim()
	self.isWaitingDrawButtonAnim = true

	self:scheduleDrawButtonAnimDelay()
	self:refreshDrawState()
end

function HomeGashaponCtrl:scheduleDrawButtonAnimDelay()
	if self.drawButtonAnimTimer then
		self:killTimer(self.drawButtonAnimTimer)
	end

	self.drawButtonAnimTimer = self:startTimer(function()
		self.drawButtonAnimTimer = nil

		self:onDrawButtonAnimFinished()
	end, HomeGashaponCtrl.DRAW_BUTTON_ANIM_DELAY)
end

function HomeGashaponCtrl:onDrawButtonAnimFinished()
	if self._gashaponCtrlDestroyed or not self.isWaitingDrawButtonAnim then
		return
	end

	if self.drawButtonAnimTimer then
		self:killTimer(self.drawButtonAnimTimer)

		self.drawButtonAnimTimer = nil
	end

	self.isWaitingDrawButtonAnim = false

	self:setDrawUIVisible(false)
	self:requestDraw()

	if self.isFurnitureDrawFinished then
		self:finishFurnitureDraw()
	end
end

function HomeGashaponCtrl:requestDraw()
	self.isRequesting = true

	self:refreshDrawState()
	pg.me:serverMsg("RPC_CS_HomeLotteryDraw", CallbackHandler(self, "onDrawResult"))
end

function HomeGashaponCtrl:onDrawResult(code, _tierId, _rewardConfigId, drawCount, drawLimit, costCount)
	if self._gashaponCtrlDestroyed then
		return
	end

	self.isRequesting = false
	self.drawCount = drawCount
	self.drawLimit = drawLimit
	self.nextCostCount = costCount

	self:refreshAll()

	if code ~= NoticeDef.SUCCESS then
		pg.global.showBubbleMessage(code)
		self:clearRewardPanelCloseWait()
		self:clearRewardVxState()
		self:resetFurnitureDraw()
		self:finishFurnitureDraw()

		return
	end

	self:waitRewardPanelClose()
	self:cacheRewardVxTierId(_tierId)
end

function HomeGashaponCtrl:playRewardVx()
	if self.drawRewardVxAnimTimer then
		self:killTimer(self.drawRewardVxAnimTimer)
	end

	self.drawRewardVxTierId = nil
	self.isRewardVxDelayFinished = false
	self.drawRewardVxAnimTimer = self:startTimer(function()
		self.drawRewardVxAnimTimer = nil
		self.isRewardVxDelayFinished = true

		self:tryPlayRewardVx()
	end, HomeGashaponCtrl.DRAW_ANIM_REWARD_TIME)
end

function HomeGashaponCtrl:cacheRewardVxTierId(tierId)
	self.drawRewardVxTierId = tierId

	self:tryPlayRewardVx()
end

function HomeGashaponCtrl:tryPlayRewardVx()
	if not self.isRewardVxDelayFinished or not self.drawRewardVxTierId then
		return
	end

	local tierId = self.drawRewardVxTierId

	self:clearRewardVxState()

	if tierId == 1 then
		self:onRewardVxConfirmed()
	end
end

function HomeGashaponCtrl:clearRewardVxState()
	if self.drawRewardVxAnimTimer then
		self:killTimer(self.drawRewardVxAnimTimer)

		self.drawRewardVxAnimTimer = nil
	end

	self.drawRewardVxTierId = nil
	self.isRewardVxDelayFinished = false
end

function HomeGashaponCtrl:onRewardVxConfirmed()
	local targetEntity = self:getTargetEntity()

	if targetEntity and targetEntity.playHomeGashaponOpenBoxEffect then
		targetEntity:playHomeGashaponOpenBoxEffect()
	end
end

function HomeGashaponCtrl:playFurnitureStart()
	self.isDrawing = true
	self.isFurnitureDrawFinished = false

	self:refreshDrawState()

	local targetEntity = self:getTargetEntity()
	local animStarted = false

	if targetEntity and targetEntity.playHomeGashaponDraw then
		animStarted = targetEntity:playHomeGashaponDraw(CallbackHandler(self, "onFurnitureDrawFinished"))
	end

	if not animStarted then
		self.isFurnitureDrawFinished = true

		return
	end

	if self.drawAnimTimer then
		self:killTimer(self.drawAnimTimer)
	end

	self.drawAnimTimer = self:startTimer(function()
		self:onFurnitureDrawFinished()
	end, HomeGashaponCtrl.DRAW_ANIM_FALLBACK_TIME)
end

function HomeGashaponCtrl:resetFurnitureDraw()
	local targetEntity = self:getTargetEntity()

	if targetEntity and targetEntity.playHomeGashaponIdleAnim then
		targetEntity:playHomeGashaponIdleAnim()
	end
end

function HomeGashaponCtrl:onFurnitureDrawFinished()
	if self._gashaponCtrlDestroyed then
		return
	end

	self.isFurnitureDrawFinished = true

	if not self._drawUIHidden then
		return
	end

	self:finishFurnitureDraw()
end

function HomeGashaponCtrl:finishFurnitureDraw()
	if not self.isDrawing then
		return
	end

	if self.drawAnimTimer then
		self:killTimer(self.drawAnimTimer)

		self.drawAnimTimer = nil
	end

	if self.isWaitingRewardPanelClose and not self.isRewardPanelClosed then
		return
	end

	self:clearRewardPanelCloseWait()

	self.isDrawing = false
	self.isFurnitureDrawFinished = false

	self:refreshDrawState()
	self:setDrawUIVisible(true)
end

function HomeGashaponCtrl:waitRewardPanelClose()
	self:clearRewardPanelCloseWait()

	self.isWaitingRewardPanelClose = true
	self.isRewardPanelClosed = false

	function self.onRewardPanelClose()
		self:onRewardPanelClosed()
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self.onRewardPanelClose)
end

function HomeGashaponCtrl:onRewardPanelClosed()
	self.isRewardPanelClosed = true

	self:removeRewardPanelCloseListener()

	if self.isFurnitureDrawFinished and self._drawUIHidden then
		self:finishFurnitureDraw()
	end
end

function HomeGashaponCtrl:removeRewardPanelCloseListener()
	if self.onRewardPanelClose then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self.onRewardPanelClose)

		self.onRewardPanelClose = nil
	end
end

function HomeGashaponCtrl:clearRewardPanelCloseWait()
	self:removeRewardPanelCloseListener()

	self.isWaitingRewardPanelClose = false
	self.isRewardPanelClosed = false
end

function HomeGashaponCtrl:setDrawUIVisible(visible)
	local hidden = not visible

	if self._drawUIHidden == hidden then
		return
	end

	self._drawUIHidden = hidden

	LuaUIUtils.setUIVisible(self.view.windowUWidget, visible)
end

function HomeGashaponCtrl:checkCommonQuit()
	if self.isDrawing or self.isWaitingDrawButtonAnim then
		return false
	end

	return UICtrl.checkCommonQuit(self)
end

function HomeGashaponCtrl:onClickRule()
	pg.global.ui:open(UIConst.UI_ID_HOME_GASHAPON_RULE)
end

function HomeGashaponCtrl:getTargetEntity()
	if not self.ornamentId or not pg.game or not pg.game.home then
		return nil
	end

	return pg.game.home:getHomeEntity(self.ornamentId)
end

function HomeGashaponCtrl:focusFurniture()
	if not self.ornamentId or not pg.game or not pg.game.home or not pg.game.camera then
		return
	end

	local targetEntity = self:getTargetEntity()

	if not targetEntity or not targetEntity.eModel or not targetEntity.getPositionAgentPosition or not targetEntity.getRotation then
		return
	end

	local furnitureHeight = tonumber(targetEntity.eModel:GetMeshSize(Const.COMPONENT_IDX_ITEM, 1)) or 0

	if furnitureHeight <= 0 and targetEntity.getBoundHeight then
		furnitureHeight = tonumber(targetEntity:getBoundHeight()) or 0
	end

	if furnitureHeight <= 0 then
		return
	end

	local furniturePosition = targetEntity:getPositionAgentPosition()
	local furnitureForward = targetEntity:getRotation():Forward()

	furnitureForward.y = 0

	if Vector3.SqrMagnitude(furnitureForward) <= 0.0001 then
		return
	end

	furnitureForward:Normalize()

	local furnitureRight = targetEntity:getRotation() * Vector3.right

	furnitureRight.y = 0

	if Vector3.SqrMagnitude(furnitureRight) <= 0.0001 then
		return
	end

	furnitureRight:Normalize()

	local furnitureCenter = furniturePosition + Vector3.up * (furnitureHeight * 0.5)
	local halfFovRadian = math.rad(HomeGashaponCtrl.SHOWCASE_FOV * 0.5)
	local cameraDistance = furnitureHeight * 0.5 / (math.tan(halfFovRadian) * HomeGashaponCtrl.SHOWCASE_VERTICAL_COVERAGE)
	local pitchRadian = math.rad(HomeGashaponCtrl.SHOWCASE_PITCH)
	local yawRadian = math.rad(HomeGashaponCtrl.SHOWCASE_YAW)
	local cameraDirection = furnitureForward * math.cos(yawRadian) - furnitureRight * math.sin(yawRadian)
	local cameraPosition = furnitureCenter + cameraDirection * (cameraDistance * math.cos(pitchRadian)) + Vector3.up * (cameraDistance * math.sin(pitchRadian))
	local baseRotation = Quaternion.LookRotation(furnitureCenter - cameraPosition, Vector3.up)
	local cameraRight = baseRotation * Vector3.right
	local lookAtPosition = furnitureCenter + cameraRight * (cameraDistance * HomeGashaponCtrl.SHOWCASE_HORIZONTAL_OFFSET_RATIO) + Vector3.up * (cameraDistance * HomeGashaponCtrl.SHOWCASE_VERTICAL_OFFSET_RATIO)
	local cameraRotation = Quaternion.LookRotation(lookAtPosition - cameraPosition, Vector3.up)

	pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_GASHAPON, false)
	pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_GASHAPON, false)

	self._showcaseActorsHidden = true

	self:onHomelandPetsChanged()
	pg.game.camera:enableFocusTarget(true, {
		homeGashapon = targetEntity
	}, {
		position = cameraPosition,
		rotation = cameraRotation,
		fov = HomeGashaponCtrl.SHOWCASE_FOV,
		blendTime = HomeGashaponCtrl.SHOWCASE_BLEND_TIME
	})

	self._focusEnabled = true
end

function HomeGashaponCtrl:onHomelandPetsChanged()
	if not self._showcaseActorsHidden or not pg.space or not pg.space.pets then
		return
	end

	for petId in pairs(pg.space.pets) do
		local pet = pg.getEntity(petId)

		if pet then
			pet:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_GASHAPON, false)

			self._hiddenHomePetIds[petId] = true
		end
	end
end

function HomeGashaponCtrl:onClickClose()
	if self.isDrawing then
		return
	end

	self:close()
end

return HomeGashaponCtrl
