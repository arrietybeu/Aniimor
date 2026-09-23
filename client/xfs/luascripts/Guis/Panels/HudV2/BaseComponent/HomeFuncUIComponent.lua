-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\HomeFuncUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeFuncUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local HomeFuncUIComponent = Class.LightClass("HomeFuncUIComponent", HudBaseComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local GlobalData = require("Core.Client.GlobalData")
local FlyFeedbackConst = require("Common.Const.FlyFeedbackConst")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local TimerManager = require("Core.Timer.TimerManager")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local HomelandWishStarData = require("Common.Homeland.HomelandWishStarData")
local HOMECAR_RED_DOT_REFRESH_INTERVAL = 5

HomeFuncUIComponent.messages = {
	[MessageName.ON_SYSTEM_FUNCTION_UNLOCKED] = {
		"onSystemFunctionUnlocked"
	},
	[MessageName.ON_SYSTEM_FUNCTION_LOCKED] = {
		"onSystemFunctionLocked"
	},
	[MessageName.ON_SYSTEM_FUNCTION_SHIELDED] = {
		"onSystemFunctionShielded"
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.HOMELAND_FOOD_INFO_REFRESH] = {
		"onHomelandManageRedDotChange",
		true
	},
	[MessageName.HOMELAND_PET_BOX_CAPACITY_CHANGED] = {
		"onHomelandManageRedDotChange",
		true
	},
	[MessageName.HOMELAND_WISH_STAR_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.HOMELAND_WISH_STAR_FLY_FEEDBACK] = {
		"playWishStarFly"
	},
	[MessageName.HOMELAND_ORNAMENT_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.HOMELAND_PETS_CHANGE] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.HOMELAND_PET_EVENT_STATE_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	}
}

function HomeFuncUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnHomeShopUButton = objectReference:GetRefValue("btnHomeShopUButton")
	self.btnHomePetUButton = objectReference:GetRefValue("btnPetManageUButton")
	self.txtNowPetUSDFText = objectReference:GetRefValue("txtNowPetUSDFText")
	self.btnHomeMakeUButton = objectReference:GetRefValue("btnHomeMakeUButton")
	self.btnPetManageUButton = objectReference:GetRefValue("btnPetManageUButton")
	self.btnHomeBuildUButton = objectReference:GetRefValue("btnHomeBuildUButton")
	self.btnHomeLogUButton = objectReference:GetRefValue("btnHomeLogUButton")
	self.btnWarehouseUButton = objectReference:GetRefValue("btnWarehouseUButton")
	self.homeLogHotKeyContent = objectReference:GetRefValue("homeLogHotKeyContent")
	self.homePetHotKeyContent = objectReference:GetRefValue("keyPetHotKeyContent")
	self.btnHomeManageUButton = objectReference:GetRefValue("btnHomeManageUButton")
	self.homeManageHotKeyContent = objectReference:GetRefValue("homeManageHotKeyContent")
	self.homeBuildHotKeyContent = objectReference:GetRefValue("homeBuildHotKeyContent")
	self.homeWarehouseHotKeyContent = objectReference:GetRefValue("homeWarehouseHotKeyContent")
	self.btnFurnitureStoreUButton = objectReference:GetRefValue("btnFurnitureStoreUButton")
	self.furnitureStoreHotKeyContent = objectReference:GetRefValue("furnitureStoreHotKeyContent")
	self.btnHomePokedexUButton = objectReference:GetRefValue("btnHomePokedexUButton")
	self.plantBookHotKeyContent = objectReference:GetRefValue("plantBookHotKeyContent")
	self.btnHomeMainUButton = objectReference:GetRefValue("btnHomeMainUButton")
	self.homeMainKeyHotKeyContent = objectReference:GetRefValue("homeMainKeyHotKeyContent")
	self.keyLHotKeyContent = objectReference:GetRefValue("keyLHotKeyContent")
	self.harvestFlyNodeUWidget = objectReference:GetRefValue("harvestFlyNodeUWidget")
	self.harvestCoinGeneral = objectReference:GetRefValue("harvestCoinGeneral")
end

function HomeFuncUIComponent:initView()
	self:initButtonClickEvents()
	self:initHotKeyBindings()
	self:initRedDot()

	self.homeCarRedDotRefreshTimer = TimerManager.addRepeatTimer(HOMECAR_RED_DOT_REFRESH_INTERVAL, function()
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_FURNITURE_NEW)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_AREA_MANAGE)
	end)

	self:refreshHomeBtnState()
end

function HomeFuncUIComponent:initButtonClickEvents()
	function self.btnHomePetUButton.luaClick()
		if self.btnHomePetUButton.gameObject.activeInHierarchy then
			GlobalData.BILogger:customeLog("home_main_menu", {
				to_page = "pet"
			})

			if pg.game.home:checkEnableHomePet() then
				local currentAreaId = pg.game.home:getCurPlayerAreaId(pg.me:getPosition(), 10)

				pg.global.ui.homelandPetManageNew:open({
					areaId = currentAreaId
				})
			else
				pg.global.showBubbleMessage(NoticeDef.HOMELAND_MANAGEMENT_LOCK)
			end
		end
	end

	function self.btnHomeManageUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "manage"
		})
		pg.game.home:openManagePanelByArea()
	end

	function self.btnHomeBuildUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "build"
		})

		local areaId = pg.game.home:getNearestAreaId(pg.me:getPosition(), true)

		pg.global.ui.homelandEditor:open({
			areaId = areaId
		})
	end

	function self.btnHomeLogUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "home_log"
		})
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_PET_ACTION, {
			type = 1
		})
	end

	function self.btnWarehouseUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "warehouse"
		})
		pg.global.ui:open(UIConst.UI_ID_HOME_INVENTORY)
	end

	function self.btnFurnitureStoreUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "store"
		})
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE)
	end

	function self.btnHomePokedexUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "index"
		})
		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK)
	end

	function self.btnHomeMainUButton.luaClick()
		GlobalData.BILogger:customeLog("home_main_menu", {
			to_page = "homeland"
		})
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_MAIN_PAGE)
	end

	self.btnHomeShopUButton:SetActive(false)
	self.btnHomeMakeUButton:SetActive(false)
	self.btnHomeLogUButton:SetActive(false)
	self.btnFurnitureStoreUButton:SetActive(false)
	ClientTextUtils.setText(self.txtNowPetUSDFText, pg.getGameString("PET"))
end

function HomeFuncUIComponent:initHotKeyBindings()
	self.isHomeLTHeld = false

	if pg.game.input:isUsingGamepad() then
		self:initGamepadHotKeys()
	else
		self:initKeyboardHotKeys()
	end
end

function HomeFuncUIComponent:initGamepadHotKeys()
	local btnPetManageUButton = self.btnPetManageUButton
	local btnHomeManageUButton = self.btnHomeManageUButton
	local btnHomeBuildUButton = self.btnHomeBuildUButton
	local btnWarehouseUButton = self.btnWarehouseUButton
	local btnHomeMainUButton = self.btnHomeMainUButton
	local petList = pg.global.ui.hudV2 and pg.global.ui.hudV2.RM and pg.global.ui.hudV2.RM.petList

	local function setupLTOnlyBind(bindName, btn)
		local kb = KeyBindingPro.GetOrAddKeyBindingByName(btn.gameObject, bindName)

		kb.isVirtual = true
		kb.actionPath = nil

		function kb.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				btn.luaClick()
			end

			return true
		end

		return kb
	end

	self.gamepadDPadLeftBinding = setupLTOnlyBind("Raw/GamepadDPadLeft", btnPetManageUButton)
	self.gamepadDPadUpBinding = setupLTOnlyBind("Raw/GamepadDPadUp", btnHomeManageUButton)
	self.gamepadDPadDownBinding = setupLTOnlyBind("Raw/GamepadDPadDown", btnHomeBuildUButton)
	self.gamepadDPadRightBinding = setupLTOnlyBind("Raw/GamepadDPadRight", btnWarehouseUButton)
	self.gamepadRightTriggerBinding = setupLTOnlyBind("Hud/GamepadHomelandRT", btnHomeMainUButton)

	self.homePetHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadLeft")
	self.homeManageHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadUp")
	self.homeBuildHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadDown")
	self.homeWarehouseHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadRight")
	self.homeMainKeyHotKeyContent:SetHotKeyPaths("Hud/GamepadHomelandRT")
	self.keyLHotKeyContent:SetHotKeyPaths("Hud/GamepadHomelandLT")
	self.keyLHotKeyContent.gameObject:SetActiveEx(true)
	self.homePetHotKeyContent.gameObject:SetActiveEx(false)
	self.homeManageHotKeyContent.gameObject:SetActiveEx(false)
	self.homeBuildHotKeyContent.gameObject:SetActiveEx(false)
	self.homeWarehouseHotKeyContent.gameObject:SetActiveEx(false)
	self.homeMainKeyHotKeyContent.gameObject:SetActiveEx(false)

	local homeLTBind = KeyBindingPro.GetOrAddKeyBindingByName(self.transform.gameObject, "homeLTBind")

	homeLTBind.isVirtual = true
	homeLTBind.actionPath = "Hud/GamepadHomelandLT"

	function homeLTBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.isHomeLTHeld = true

			self.homePetHotKeyContent.gameObject:SetActiveEx(true)
			self.homeManageHotKeyContent.gameObject:SetActiveEx(true)
			self.homeBuildHotKeyContent.gameObject:SetActiveEx(true)
			self.homeWarehouseHotKeyContent.gameObject:SetActiveEx(true)
			self.homeMainKeyHotKeyContent.gameObject:SetActiveEx(true)

			self.gamepadDPadLeftBinding.actionPath = "Raw/GamepadDPadLeft"
			self.gamepadDPadUpBinding.actionPath = "Raw/GamepadDPadUp"
			self.gamepadDPadDownBinding.actionPath = "Raw/GamepadDPadDown"
			self.gamepadDPadRightBinding.actionPath = "Raw/GamepadDPadRight"
			self.gamepadRightTriggerBinding.actionPath = "Hud/GamepadHomelandRT"

			if petList then
				petList:setBloodKeyHintVisible(false)
			end
		elseif inputInfo.phase == "Canceled" then
			self.isHomeLTHeld = false

			self.homePetHotKeyContent.gameObject:SetActiveEx(false)
			self.homeManageHotKeyContent.gameObject:SetActiveEx(false)
			self.homeBuildHotKeyContent.gameObject:SetActiveEx(false)
			self.homeWarehouseHotKeyContent.gameObject:SetActiveEx(false)
			self.homeMainKeyHotKeyContent.gameObject:SetActiveEx(false)

			self.gamepadDPadLeftBinding.actionPath = nil
			self.gamepadDPadUpBinding.actionPath = nil
			self.gamepadDPadDownBinding.actionPath = nil
			self.gamepadDPadRightBinding.actionPath = nil
			self.gamepadRightTriggerBinding.actionPath = nil

			if petList then
				petList:setBloodKeyHintVisible(true)
			end
		end
	end
end

function HomeFuncUIComponent:initKeyboardHotKeys()
	local btnHomePetUButton = self.btnHomePetUButton
	local btnHomeManageUButton = self.btnHomeManageUButton
	local btnHomeBuildUButton = self.btnHomeBuildUButton
	local btnWarehouseUButton = self.btnWarehouseUButton
	local btnHomeMainUButton = self.btnHomeMainUButton
	local petList = pg.global.ui.hudV2 and pg.global.ui.hudV2.RM and pg.global.ui.hudV2.RM.petList

	if petList then
		petList:setBloodKeyHintVisible(true)
	end

	self:bindHotKeyPerform("Hud/HomelandPet", function()
		btnHomePetUButton.luaClick()
	end, btnHomePetUButton.gameObject, "Hud/HomelandPet")
	self:bindHotKeyPerform("Hud/HomelandManage", function()
		btnHomeManageUButton.luaClick()
	end, btnHomeManageUButton.gameObject, "Hud/HomelandManage")
	self.ctrl.ctrl:bindHotKeyPerform("Hud/HomelandBuild", function()
		btnHomeBuildUButton.luaClick()
	end, btnHomeBuildUButton.gameObject, "Hud/HomelandBuild")
	self.ctrl.ctrl:bindHotKeyPerform("Hud/HomelandStore", function()
		btnWarehouseUButton.luaClick()
	end, btnWarehouseUButton.gameObject, "Hud/HomelandStore")
	self.ctrl.ctrl:bindHotKeyPerform("Hud/HomelandMainPage", function()
		btnHomeMainUButton.luaClick()
	end, btnHomeMainUButton.gameObject, "Hud/HomelandMainPage")
	self.homePetHotKeyContent:SetHotKeyPaths("Hud/HomelandPet")
	self.homeBuildHotKeyContent:SetHotKeyPaths("Hud/HomelandBuild")
	self.homeWarehouseHotKeyContent:SetHotKeyPaths("Hud/HomelandStore")
	self.homeManageHotKeyContent:SetHotKeyPaths("Hud/HomelandManage")
	self.homeMainKeyHotKeyContent:SetHotKeyPaths("Hud/HomelandMainPage")
	self.keyLHotKeyContent.gameObject:SetActiveEx(false)
end

function HomeFuncUIComponent:initRedDot()
	HomeBookRedDotUtils.bindHud(self.btnHomePokedexUButton)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR, self.btnHomeMainUButton, function()
		return pg.global.ui.homeCarLevelUp.model:redDot_GetUpgradeState()
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOMELAND_FURNITURE_NEW, self.btnHomeBuildUButton, function()
		return ClientHomelandUtils.getFurnitureHudRedDotState()
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOMELAND_MANAGE, self.btnHomePetUButton, function()
		local foodIsWorking = pg.space.homeFoodSlotList:isWorking(pg.space)
		local hasPet = pg.space and HomeLandUtils.getPetCurCount(pg.space) > 0

		if not pg.game.home:checkEnableHomePet() then
			return RedDotConst.RedDotStyle.NONE
		elseif hasPet and not foodIsWorking then
			return RedDotConst.RedDotStyle.POINT
		end

		return pg.global.ui.homelandPetManageNew.model:redDot_GetPetBoxCapacityState()
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOMELAND_AREA_MANAGE, self.btnHomeManageUButton, function()
		local snapshot = HomelandWishStarData.getSnapshot(pg.space or pg.me.space)

		if snapshot.hasBottle and snapshot.isFull then
			return RedDotConst.RedDotStyle.POINT
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function HomeFuncUIComponent:onHomeBookDataChanged()
	HomeBookRedDotUtils.bindHud(self.btnHomePokedexUButton)
end

function HomeFuncUIComponent:refreshHomeBtnState()
	if self.btnHomePetUButton then
		self.btnHomePetUButton:TryChangePage("Locked", pg.game.home:checkEnableHomePet() and 0 or 1)
	end
end

function HomeFuncUIComponent:onSystemFunctionUnlocked(name)
	if name ~= Const.FUNCTION_NAME.HOMELAND_PET and name ~= Const.FUNCTION_NAME.HOMECAR_MANAGEMENT then
		return
	end

	self:refreshHomeBtnState()

	if name == Const.FUNCTION_NAME.HOMELAND_PET then
		self:onHomelandManageRedDotChange()
	end
end

function HomeFuncUIComponent:onSystemFunctionLocked(name)
	if name ~= Const.FUNCTION_NAME.HOMELAND_PET and name ~= Const.FUNCTION_NAME.HOMECAR_MANAGEMENT then
		return
	end

	self:refreshHomeBtnState()
end

function HomeFuncUIComponent:onSystemFunctionShielded(name)
	if name ~= Const.FUNCTION_NAME.HOMELAND_PET and name ~= Const.FUNCTION_NAME.HOMECAR_MANAGEMENT then
		return
	end

	self:refreshHomeBtnState()
end

function HomeFuncUIComponent:onHomelandManageRedDotChange()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_MANAGE)
end

function HomeFuncUIComponent:onHomelandWishStarChanged(info)
	if info and info.collected and info.collected > 0 then
		self:playWishStarFly(info)
	end

	if self.wishStarRedDotRefreshFrameId then
		return
	end

	self.wishStarRedDotRefreshFrameId = TimerManager.addNextFrameCb(function()
		self.wishStarRedDotRefreshFrameId = nil

		pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_AREA_MANAGE)
	end)
end

function HomeFuncUIComponent:playWishStarFly(info)
	local coinGeneral = self.harvestCoinGeneral
	local flyNode = self.harvestFlyNodeUWidget

	if not coinGeneral or IsNil(coinGeneral) or not flyNode or IsNil(flyNode) then
		return
	end

	coinGeneral.subParent = flyNode.transform

	function coinGeneral.luaGeneralCoin()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_GENERAL)
	end

	function coinGeneral.luaStartFly()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_START_FLY)
	end

	function coinGeneral.luaEndFly()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_END_FLY)
	end

	coinGeneral.coinIconUrl = LuaUIUtils.getIconByItemId(Const.HomeDecCoinItemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)
	coinGeneral.sourcePosition = self:getWishStarSourceWorldPos(info.sourceEntityId)
	coinGeneral.targetPosition = self:getWishStarCurrencyTargetWorldPos()

	local count = math.ceil(info.collected / FlyFeedbackConst.WISH_STAR.ICON_COUNT_RATIO)

	count = math.clamp(count, 1, FlyFeedbackConst.WISH_STAR.MAX_ICON_COUNT)

	coinGeneral:AppendCoin(count)
end

function HomeFuncUIComponent:getWishStarCurrencyTargetWorldPos()
	local globalUI = pg.global and pg.global.ui
	local hudV2 = globalUI and globalUI.hudV2
	local funcList = hudV2 and hudV2.RU and hudV2.RU.funcList
	local targetBtn = funcList and funcList.currencySlotMap and funcList.currencySlotMap[Const.HomeDecCoinItemId]

	if targetBtn and NotNil(targetBtn) and targetBtn.transform and NotNil(targetBtn.transform) then
		return targetBtn.transform.position
	end

	local anchor = FlyFeedbackConst.WISH_STAR.FALLBACK_TARGET_SCREEN_ANCHOR

	return self:getScreenAnchorToFlyWorldPos(anchor.x, anchor.y)
end

function HomeFuncUIComponent:getWishStarSourceWorldPos(sourceEntityId)
	local sourceEntity = sourceEntityId and pg.getEntityByGlobalId(sourceEntityId)
	local itemModel = sourceEntity and sourceEntity.eModel and sourceEntity.eModel.itemModel
	local worldCamera = pg.global.cameraMgr and pg.global.cameraMgr.worldCameraInst

	if itemModel and NotNil(itemModel) and worldCamera and NotNil(worldCamera) then
		local sourceScreenPos = worldCamera:WorldToScreenPoint(itemModel.transform.position)

		if sourceScreenPos.z > 0 then
			local flyTrans = self.harvestFlyNodeUWidget.transform
			local uiMgr = pg.global.uiMgr
			local uiCamera = uiMgr.orthographicCamera
			local screenPos = CS.UnityEngine.Vector2(sourceScreenPos.x, sourceScreenPos.y)
			local localPos = uiMgr:ScreenPointToLocalPoint(flyTrans, screenPos, uiCamera)

			return flyTrans:TransformPoint(localPos)
		end
	end

	local anchor = FlyFeedbackConst.WISH_STAR.FALLBACK_SOURCE_SCREEN_ANCHOR

	return self:getScreenAnchorToFlyWorldPos(anchor.x, anchor.y)
end

function HomeFuncUIComponent:playHarvestFly(params)
	local coinGeneral = self.harvestCoinGeneral
	local flyNode = self.harvestFlyNodeUWidget
	local items = params and params.items

	if not coinGeneral or not flyNode or not items or #items == 0 then
		return
	end

	coinGeneral.subParent = flyNode.transform

	local sourcePos = self:getScreenAnchorToFlyWorldPos(0.5, 0.5)
	local targetPos = self:getHarvestTargetWorldPos(params.toBag)

	coinGeneral.sourcePosition = sourcePos
	coinGeneral.targetPosition = targetPos

	coinGeneral:StopCoin()

	local getIconByItemId = LuaUIUtils.getIconByItemId
	local iconType = LuaUIUtils.ITEM_ICON_TYPE.ICON_NORMAL
	local iconCountRatio = FlyFeedbackConst.HARVEST.ICON_COUNT_RATIO
	local maxIconCount = FlyFeedbackConst.HARVEST.MAX_ICON_COUNT

	for _, item in ipairs(items) do
		local count = item.count

		if count and count > 0 then
			coinGeneral.coinIconUrl = getIconByItemId(item.itemId, iconType)

			local iconCount = math.min(math.ceil(count / iconCountRatio), maxIconCount)

			coinGeneral:AppendCoin(iconCount)
		end
	end
end

function HomeFuncUIComponent:getHarvestTargetWorldPos(toBag)
	local targetBtn

	if not toBag then
		targetBtn = self.btnWarehouseUButton
	else
		targetBtn = self:getBagAnchorBtn()
	end

	if targetBtn and targetBtn.gameObject and targetBtn.gameObject.activeInHierarchy then
		return targetBtn.transform.position
	end

	local anchor = FlyFeedbackConst.HARVEST.FALLBACK_SCREEN_ANCHOR

	return self:getScreenAnchorToFlyWorldPos(anchor.x, anchor.y)
end

function HomeFuncUIComponent:getBagAnchorBtn()
	local hudV2 = pg.global.ui.hudV2
	local funcList = hudV2 and hudV2.RU and hudV2.RU.funcList

	return funcList and funcList.funcButton and funcList.funcButton[Const.FUNCTION_IDS.BAG]
end

function HomeFuncUIComponent:getScreenAnchorToFlyWorldPos(nx, ny)
	local flyTrans = self.harvestFlyNodeUWidget.transform
	local uiMgr = pg.global.uiMgr
	local uiCamera = uiMgr.orthographicCamera
	local screenPos = CS.UnityEngine.Vector2(CS.UnityEngine.Screen.width * nx, CS.UnityEngine.Screen.height * ny)
	local localPos = uiMgr:ScreenPointToLocalPoint(flyTrans, screenPos, uiCamera)

	return flyTrans:TransformPoint(localPos)
end

function HomeFuncUIComponent:onDestroy()
	if self.wishStarRedDotRefreshFrameId then
		TimerManager.delFrameCb(self.wishStarRedDotRefreshFrameId)

		self.wishStarRedDotRefreshFrameId = nil
	end

	if self.homeCarRedDotRefreshTimer then
		TimerManager.removeTimer(self.homeCarRedDotRefreshTimer)

		self.homeCarRedDotRefreshTimer = nil
	end

	if self.harvestCoinGeneral then
		self.harvestCoinGeneral:StopCoin()
	end

	HudBaseComponent.onDestroy(self)
end

function HomeFuncUIComponent:onInputDeviceChanged(deviceType)
	self:initHotKeyBindings()
end

return HomeFuncUIComponent
