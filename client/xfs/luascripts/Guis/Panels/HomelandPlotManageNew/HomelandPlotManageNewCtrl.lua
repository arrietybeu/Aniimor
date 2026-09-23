-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlotManageNew\\HomelandPlotManageNewCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandPlotManageNewCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandPlotManageNewCtrl = Class.LightClass("HomelandPlotManageNewCtrl", UICtrl)
local PlotPanelComponent = require("Guis.Panels.HomelandPetManage.Component.PlotPanelComponent")
local PlotDetailComponent = require("Guis.Panels.HomelandPetManage.Component.PlotDetailComponent")
local PlotMultipleUpgradeComponent = require("Guis.Panels.HomelandPetManage.Component.PlotMultipleUpgradeComponent")
local PlotSpeedUpComponent = require("Guis.Panels.HomelandPetManage.Component.PlotSpeedUpComponent")
local FormulaTrackingUIComponent = require("Guis.Panels.HudV2.BaseComponent.FormulaTrackingUIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local CommonSwitch = require("Common.CommonSwitch")
local AudioConst = require("Const.AudioConst")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HomelandOperateData = require("Data.homeland_operate_data")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandFormulaData = require("Data.homeland_formula_data")

HomelandPlotManageNewCtrl.VIEWMODE_TYPE = {
	Ornamen = 3,
	SmallOrnamen = 2,
	Plot = 1
}
HomelandPlotManageNewCtrl.SMALL_ORNAMEN_SCALE = 0.6
HomelandPlotManageNewCtrl.GAMEPAD_PAN_STEP = 50
HomelandPlotManageNewCtrl.ENV_FACILITY_PAGE = {
	[Const.HOMELAND_FACILITY_TYPE.Electric] = 0,
	[Const.HOMELAND_FACILITY_TYPE.ElectricLink] = 0,
	[Const.HOMELAND_FACILITY_TYPE.HighTemperate] = 1,
	[Const.HOMELAND_FACILITY_TYPE.LowTemperate] = 2,
	[Const.HOMELAND_FACILITY_TYPE.Light] = 3
}
HomelandPlotManageNewCtrl.messages = {
	[MessageName.HOMELAND_ZONE_CONDITION_UNLOCK] = {
		"onZoneUnlock",
		true
	},
	[MessageName.HOMELAND_FORMULA_CHANGED] = {
		"onHomelandFormulaChanged",
		true
	},
	[MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED] = {
		"onDrawingUnlockChanged",
		true
	},
	[MessageName.HOMELAND_LEVEL_UP_SUCC] = {
		"onLevelUpSucc",
		true
	},
	[MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED] = {
		"onFacilityAllocateChanged",
		true
	},
	[MessageName.HOME_FORMULA_TRACKING_CHANGED] = {
		"onRefreshFormulaTracking",
		true
	},
	[MessageName.HOMELAND_ORNAMENT_CHANGED] = {
		"onOrnamentChanged",
		true
	}
}

function HomelandPlotManageNewCtrl:onCreate(info)
	info = info or {}
	self.areaId = info.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE
	self.selectLevel = nil
	self.selectOrnamen = nil
	self.plotList = nil
	self.ornamentTable = nil
	self.multipleMode = Const.HOMELAND_MULTIPLE_MODE.Normal
	self.canMultipleOrnamentTable = {}
	self.isMultipleOrnamentTable = {}
	self.canMultipleCount = 0
	self.multipleCount = 0
	self.viewMode = HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Plot

	self.view.scaleUWidget:SetActive(self.areaId == Const.HOMELAND_AREA_TYPE.PRODUCE)
	self.view.widget:TryChangePage("Type", self.areaId == Const.HOMELAND_AREA_TYPE.PRODUCE and 1 or 0)
	UICtrl.onCreate(self, info)
end

function HomelandPlotManageNewCtrl:addListener()
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMELAND_PLOT_BATCH_UPGRADE"))
	ClientTextUtils.setText(self.view.txtNameUSDFText2, pg.getGameString("HOMELAND_PLOT_AI_ALLOCATE"))
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMELAND_PLOT_FACILITY_MANAGE"))
	ClientTextUtils.setText(self.view.speedUpUSDFText, pg.getGameString("HOME_ACCELERATE_BATCH"))

	self.plotPanelManage = PlotPanelComponent.new(self, self.view.plotPanelUContainer)
	self.plotDetailManage = PlotDetailComponent.new(self, self.view.plotManageUContainer)
	self.plotMultipleUpgrade = PlotMultipleUpgradeComponent.new(self, self.view.batchUpgradeUContainer)
	self.plotSpeedUp = PlotSpeedUpComponent.new(self, self.view.plotSpeedUpUContainer)
	self.formulaTracking = FormulaTrackingUIComponent.new(self, self.view.formulaTrackTipsUContainer, {
		disableGamepadHotKey = true
	})

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	self.view.listCurrencyUList:SetList(self:getIconList())

	self.view.listPlotUList.rowCount = self.model.GRID_LINE_COUNT
	self.view.listPlotUList.colCount = self.model.GRID_COLUMN_COUNT

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnBatchUpgradeUButton.luaClick()
		if self.selectOrnamen ~= nil then
			return
		end

		self.view.plotManageUContainer:SetActive(false)
		self.view.quickActionsUWidget:SetActive(false)
		self:setSliderBtnActive(false)

		self.view.sliderFakeUSlider.interactable = false

		self.view.batchUpgradeUContainer:SetActive(true)
		self:refreshOrnamentGridMultipleMode(Const.HOMELAND_MULTIPLE_MODE.LevelUp)
		self.plotMultipleUpgrade:onEnterPage()
	end

	self.view.btnSpeedUpUButton:SetActive(true)

	function self.view.btnSpeedUpUButton.luaClick()
		if self.selectOrnamen ~= nil then
			return
		end

		self.view.plotManageUContainer:SetActive(false)
		self.view.quickActionsUWidget:SetActive(false)
		self:setSliderBtnActive(false)

		self.view.sliderFakeUSlider.interactable = false

		self.view.plotSpeedUpUContainer:SetActive(true)
		self:refreshOrnamentGridMultipleMode(Const.HOMELAND_MULTIPLE_MODE.SpeedUp)
		self.plotSpeedUp:onEnterPage()
	end

	function self.view.btnAllocationUButton.luaClick()
		if not pg.me or not pg.me.space or not pg.me.space.resetAllHomePetWork then
			return
		end

		pg.me.space:resetAllHomePetWork(function(code)
			if code ~= Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS then
				logger:error("RPC_CS_ResetAllHomePetWork failed code=%s", code)

				return
			end

			self:refreshOrnamentGrid()
			pg.global.showBubbleMessage(NoticeDef.HOME_AI_ALLOCATE_SUCCESS)
		end)
	end

	local produceAreaZoneCount = 0

	if self.areaId == Const.HOMELAND_AREA_TYPE.BUILD then
		local zoneUnlockData = HomeLandUtils.getHomelandZoneUnlockData()

		for _, zoneData in pairs(zoneUnlockData) do
			if zoneData.areaId == Const.HOMELAND_AREA_TYPE.PRODUCE then
				produceAreaZoneCount = produceAreaZoneCount + 1
			end
		end
	end

	function self.view.listPlotUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local uINodeHomeManagePlotItemUButton = objectReference:GetRefValue("uINodeHomeManagePlotItemUButton")
		local selectedState32UComponent = objectReference:GetRefValue("selectedState32UComponent")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtUnlockUSDFText = objectReference:GetRefValue("txtUnlockUSDFText")

		if data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlocked then
			uINodeHomeManagePlotItemUButton:TryChangePage("State", self.model.ENABLEUNLOCK_TYPE.CannotUnlock)
		end

		uINodeHomeManagePlotItemUButton:TryChangePage("State", data.enableUnlock)

		local instant = false

		if data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlockable then
			local haveCache = pg.global.prefsCacheUtils:getBool("HomeLandPlot_" .. data.level, false, ClientConst.CACHE_TYPE_FLAG.USER)

			if haveCache then
				instant = true
			end

			pg.global.prefsCacheUtils:setBool("HomeLandPlot_" .. data.level, true, ClientConst.CACHE_TYPE_FLAG.USER)

			if not instant then
				uINodeHomeManagePlotItemUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			end
		end

		local displayLevel = data.level - produceAreaZoneCount

		ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.concatByLanguage(pg.getGameString("HOMELAND_PLOT"), displayLevel))
		ClientTextUtils.setText(txtUnlockUSDFText, pg.getGameString("HOMELAND_PLOT_UNLOCKABLE"))

		button.interactable = data.enableUnlock ~= self.model.ENABLEUNLOCK_TYPE.CannotUnlock

		function button.luaDoubleClick()
			if self:canEnterPlotDetail() and data.enableUnlock == self.model.ENABLEUNLOCK_TYPE.Unlocked then
				self.view.listPlotUList:SelectItem(index)
				self:changeViewMode(self.VIEWMODE_TYPE.SmallOrnamen)
			end
		end
	end

	function self.view.listPlotUList.luaSelectedChanged(uList)
		if not uList or not uList.selectedItem then
			if self.view.plotPanelUContainer:CheckURLLoaded() then
				self.view.plotPanelUContainer.content:SetActive(false)
			end

			return
		end

		local selectItem = uList.selectedItem

		if self.selectLevel ~= selectItem.level then
			self.selectLevel = selectItem.level

			self.plotPanelManage:refreshPlotPanel(selectItem)
		end
	end

	function self.view.sliderFakeUSlider.luaValueChanged(value)
		local viewMode

		if value == 1 then
			viewMode = HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Ornamen
		elseif value == 0.5 then
			viewMode = HomelandPlotManageNewCtrl.VIEWMODE_TYPE.SmallOrnamen
		elseif value == 0 then
			viewMode = HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Plot
		end

		if viewMode then
			self:changeViewMode(viewMode)
		end
	end

	function self.view.btnAddUButton.luaClick()
		local selectedItem = self.view.listPlotUList.selectedItem

		if self.viewMode == HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Plot and selectedItem and selectedItem.enableUnlock == self.model.ENABLEUNLOCK_TYPE.CannotUnlock then
			return
		end

		local currentValue = self.view.sliderFakeUSlider.value

		if currentValue == 0 then
			self.view.sliderFakeUSlider.value = 0.5
		elseif currentValue == 0.5 then
			self.view.sliderFakeUSlider.value = 1
		end
	end

	function self.view.btnReduceUButton.luaClick()
		local currentValue = self.view.sliderFakeUSlider.value

		if currentValue == 1 then
			self.view.sliderFakeUSlider.value = 0.5
		elseif currentValue == 0.5 then
			self.view.sliderFakeUSlider.value = 0
		end
	end

	function self.view.viewCtrlSimpleViewCtrl.luaBeginDrag(screenPos)
		if not self:isOrnamenMode() then
			return
		end

		local transform = self.view.plotCellPoolUWidget.transform
		local localPosition = transform.localPosition

		self.plotCellPoolPositionX = localPosition.x
		self.plotCellPoolPositionY = localPosition.y
		self.curDragPosX = screenPos.x
		self.curDragPosY = screenPos.y
	end

	function self.view.viewCtrlSimpleViewCtrl.luaDragUpdate(screenPos)
		if not self:isOrnamenMode() then
			return
		end

		if self.curDragPosX and self.plotCellPoolPositionX then
			local currentScale = self:getCurrentScale()
			local diffX = 2700 * (screenPos.x - self.curDragPosX) / Screen.height / currentScale
			local diffY = 2700 * (screenPos.y - self.curDragPosY) / Screen.height / currentScale
			local posx, posy = self:_clampPlotCellPoolPos(self.plotCellPoolPositionX + diffX, self.plotCellPoolPositionY + diffY)

			self.view.plotCellPoolUWidget.transform:SetLocalPositionEx(posx, posy, 0)
		end
	end

	function self.view.viewCtrlSimpleViewCtrl.luaEndDrag(screenPos)
		if not self:isOrnamenMode() then
			return
		end

		self.curDragPosX = nil
		self.curDragPosY = nil
		self.plotCellPoolPositionX = nil
		self.plotCellPoolPositionY = nil
	end

	self:bindHotKeyPerform("Hud/InteractScroll", self.onPerformInteractScroll, self.view.viewCtrlSimpleViewCtrl.gameObject)
	self:bindHotKeyPerform("Raw/GamepadLeftTrigger", function()
		self:performScaleStep(1)
	end, self.view.viewCtrlSimpleViewCtrl.gameObject)
	self:bindHotKeyPerform("Raw/GamepadRightTrigger", function()
		self:performScaleStep(-1)
	end, self.view.viewCtrlSimpleViewCtrl.gameObject)
	self:_bindGamepadRightStickPan()
	self:createZoneBorder()

	if self:canEnterPlotDetail() then
		self:createOrnamentGrid()
	end

	local INTERACT_MODE_HOVER_ONLY = 1

	self.virtualMouseField = self.view.virtualMouseField

	if self.virtualMouseField then
		self.virtualMouseField:Init(pg.global.uiMgr.uiCamera, pg.global.uiMgr.uiRootCanvasRt, INTERACT_MODE_HOVER_ONLY)

		if pg.global.navMgr then
			pg.global.uiMgr:AddVirtualMouseField(self.virtualMouseField)
			pg.global.navMgr:AddLuaHotkeyActivationChangedListener("UI_HomelandPlotManageNew_FocusChanged", function()
				self:refreshVirtualMouseState()
			end)
		end

		self:refreshVirtualMouseState()
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("UI_HomelandPlotManageNew_ConsoleBarRefresh", function()
			self:refreshVirtualMouseState()
		end)
	end

	if self.view.btnOverViewUButton then
		if not CommonSwitch.HOMELAND_NEW_MAP then
			self.view.btnOverViewUButton:SetActive(false)
		else
			local btnText = self.view.btnOverViewUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

			ClientTextUtils.setText(btnText, pg.getGameString("HOME_AREA_OVERVIEW"))
			self.view.btnOverViewUButton:SetActive(true)

			function self.view.btnOverViewUButton.luaClick()
				self:onGoMainAreaPageBtnClick()
			end
		end
	end
end

function HomelandPlotManageNewCtrl:isOrnamenMode(viewMode)
	viewMode = viewMode or self.viewMode

	return viewMode == self.VIEWMODE_TYPE.SmallOrnamen or viewMode == self.VIEWMODE_TYPE.Ornamen
end

function HomelandPlotManageNewCtrl:canEnterPlotDetail()
	return self.areaId == Const.HOMELAND_AREA_TYPE.PRODUCE
end

function HomelandPlotManageNewCtrl:getCurrentScale()
	if self.viewMode == self.VIEWMODE_TYPE.SmallOrnamen then
		return self.SMALL_ORNAMEN_SCALE
	end

	return 1
end

function HomelandPlotManageNewCtrl:getSliderValue(viewMode)
	viewMode = viewMode or self.viewMode

	if viewMode == self.VIEWMODE_TYPE.Ornamen then
		return 1
	elseif viewMode == self.VIEWMODE_TYPE.SmallOrnamen then
		return 0.5
	else
		return 0
	end
end

function HomelandPlotManageNewCtrl:applyViewScale()
	local scale = self:getCurrentScale()

	self.view.viewCtrlSimpleViewCtrl.transform:SetLocalScaleEx(scale, scale, 1)
end

function HomelandPlotManageNewCtrl:getIconList()
	local iconList = {}
	local itemIdSet = {}
	local zoneUnlockData = HomeLandUtils.getHomelandZoneUnlockData()

	for _, zoneData in pairs(zoneUnlockData) do
		if (zoneData.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE) == self.areaId then
			for _, costInfo in ipairs(zoneData.unlockCost or EMPTY_TABLE) do
				local itemId = costInfo[1]

				if itemId and not itemIdSet[itemId] then
					itemIdSet[itemId] = true

					table.insert(iconList, {
						itemId = itemId
					})
				end
			end
		end
	end

	if #iconList == 0 then
		table.insert(iconList, {
			itemId = HomelandConfigData.homeCurrencyId or 1010
		})
	end

	table.sort(iconList, function(a, b)
		return a.itemId < b.itemId
	end)

	return iconList
end

function HomelandPlotManageNewCtrl:setSliderBtnActive(active)
	local btnActive = active or false

	if pg.game.input:isUsingGamepad() then
		btnActive = false
	end

	self.view.btnAddUButton:SetActive(btnActive)
	self.view.btnReduceUButton:SetActive(btnActive)
end

function HomelandPlotManageNewCtrl:_clampPlotCellPoolPos(x, y)
	local width = self.model.UNIT_LENGTH * self.model.ZONE_WIDTH * 4
	local height = self.model.UNIT_LENGTH * self.model.ZONE_HEIGHT * 4.25
	local posx = math.max(-width / 2, math.min(x, width / 2))
	local posy = math.max(-height / 2, math.min(y, height / 2))

	return posx, posy
end

function HomelandPlotManageNewCtrl:_stopGamepadPan()
	if self._plotPanTimer then
		self:killTimer(self._plotPanTimer)

		self._plotPanTimer = nil
	end

	self._plotPanDeltaX = nil
	self._plotPanDeltaY = nil
end

function HomelandPlotManageNewCtrl:_bindGamepadRightStickPan()
	local host = self.view.viewCtrlSimpleViewCtrl

	if not host or IsNil(host.gameObject) then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(host.gameObject, "plotPanGamepadBind")

	bind.actionPath = "Raw/GamepadRightStickMove"
	bind.isVirtual = true
	bind.priority = -1

	function bind.luaTrigger(inputInfo)
		local valueVec2 = inputInfo.valueVec2

		self._plotPanDeltaX = valueVec2.x * HomelandPlotManageNewCtrl.GAMEPAD_PAN_STEP
		self._plotPanDeltaY = valueVec2.y * HomelandPlotManageNewCtrl.GAMEPAD_PAN_STEP

		if inputInfo.phase == "Performed" then
			if not self:isOrnamenMode() or not self:isVirtualMouseEnabled() then
				self:_stopGamepadPan()

				return
			end

			if self._plotPanTimer == nil then
				self._plotPanTimer = self:startTimer(function()
					if not self:isOrnamenMode() or not self:isVirtualMouseEnabled() then
						self:_stopGamepadPan()

						return
					end

					local deltaX = self._plotPanDeltaX or 0
					local deltaY = self._plotPanDeltaY or 0

					if deltaX == 0 and deltaY == 0 then
						return
					end

					local currentScale = self:getCurrentScale()
					local transform = self.view.plotCellPoolUWidget.transform
					local cur = transform.localPosition
					local posx, posy = self:_clampPlotCellPoolPos(cur.x - deltaX / currentScale, cur.y - deltaY / currentScale)

					transform:SetLocalPositionEx(posx, posy, 0)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" then
			self:_stopGamepadPan()
		end
	end
end

function HomelandPlotManageNewCtrl:onPerformInteractScroll(inputInfo)
	if pg.game.input:isUsingGamepad() then
		return
	end

	self:performScaleStep(inputInfo.valueVec2.y > 0 and 1 or -1)

	return false
end

function HomelandPlotManageNewCtrl:performScaleStep(direction)
	if not self:canEnterPlotDetail() then
		return
	end

	if self.selectOrnamen ~= nil then
		return
	end

	if self.multipleMode ~= Const.HOMELAND_MULTIPLE_MODE.Normal then
		return
	end

	local selectedItem = self.view.listPlotUList.selectedItem

	if self.viewMode == HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Plot and selectedItem and selectedItem.enableUnlock == self.model.ENABLEUNLOCK_TYPE.CannotUnlock then
		return
	end

	local currentValue = self.view.sliderFakeUSlider.value

	if direction > 0 then
		if currentValue == 0 then
			self.view.sliderFakeUSlider.value = 0.5
		elseif currentValue == 0.5 then
			self.view.sliderFakeUSlider.value = 1
		end
	elseif currentValue == 1 then
		self.view.sliderFakeUSlider.value = 0.5
	elseif currentValue == 0.5 then
		self.view.sliderFakeUSlider.value = 0
	end

	if pg.game.input:isUsingGamepad() and self.virtualMouseField then
		self.virtualMouseField:CheckAndFireHover()
	end
end

HomelandPlotManageNewCtrl.VIRTUAL_MOUSE_YIELD_GROUPS = {
	ListPlotManage = true,
	ListCost = true
}

function HomelandPlotManageNewCtrl:_isFocusInYieldGroup()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return false
	end

	local focusedGroupName = navMgr.CurrentFocusedGroupName

	if IsNil(focusedGroupName) then
		return false
	end

	return HomelandPlotManageNewCtrl.VIRTUAL_MOUSE_YIELD_GROUPS[focusedGroupName] == true
end

function HomelandPlotManageNewCtrl:isVirtualMouseEnabled()
	if self:_isFocusInYieldGroup() then
		return false
	end

	if self.multipleMode ~= Const.HOMELAND_MULTIPLE_MODE.Normal then
		if pg.global.navMgr and pg.global.navMgr.CurrentFocusedGroupName == "ListCostSpeed" then
			return false
		end

		return true
	end

	if self.selectOrnamen ~= nil then
		return false
	end

	if pg.global.navMgr and pg.global.navMgr:IsInModalGroup() then
		return false
	end

	return true
end

function HomelandPlotManageNewCtrl:refreshVirtualMouseState()
	if self.virtualMouseField then
		local enabled = pg.game.input:isUsingGamepad() and self:isVirtualMouseEnabled()

		if enabled then
			self.virtualMouseField:Activate()
		else
			self.virtualMouseField:DeActivate()
		end
	end

	self:refreshConsoleBarState()
end

function HomelandPlotManageNewCtrl:refreshConsoleBarState()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	local inBatch = self.multipleMode ~= Const.HOMELAND_MULTIPLE_MODE.Normal
	local isNormal = inBatch or self.selectOrnamen == nil and (not pg.global.navMgr or not pg.global.navMgr:IsInModalGroup())

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSelect", isNormal)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canMove", isNormal)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canScale", isNormal and self.selectOrnamen == nil and self:canEnterPlotDetail())
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canCheck", false)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canRightStickMove", isNormal and self:isOrnamenMode())

	local canRemove, canReplace, canLock = false, false, false
	local navMgr = CS.XGUI.Navigation.NavManager.Instance
	local navItem = navMgr.CurrentFocusedUContent
	local data = navItem and navItem.dataFromUList

	if data and data.tIndex == 0 and data.petId then
		if data.currentWork then
			canRemove = true
			canLock = true
		else
			canReplace = true
		end
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canRemove", canRemove)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canReplace", canReplace)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canLock", false)
end

function HomelandPlotManageNewCtrl:refreshOrnamentInfoByOrnamentId(ornamentId)
	if not self.ornamentTable or not ornamentId then
		return
	end

	local oldOrnamentInfo = self.ornamentTable[ornamentId]
	local newOrnamentInfo = pg.me.space.ornament[ornamentId]

	if newOrnamentInfo and oldOrnamentInfo then
		oldOrnamentInfo.homeId = newOrnamentInfo.homeId

		local revertInfo = RevertHomeUpgradeData[newOrnamentInfo.homeId]
		local facilityLevel = revertInfo and revertInfo[2] or 1

		oldOrnamentInfo.level = facilityLevel

		self:refreshLevelRedDot(oldOrnamentInfo)
		self:refreshOrnamentGridSingle(oldOrnamentInfo)

		local ornamentPlot = oldOrnamentInfo.obj
		local objectReference = ornamentPlot:GetComponent("ObjectReference")
		local uINodeHomeManagePlotCellUButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")

		uINodeHomeManagePlotCellUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function HomelandPlotManageNewCtrl:createZoneBorder()
	local parent = self.view.borderUWidget.transform
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()

	for _, info in pairs(HomelandZoneUnlockConfigData) do
		if (info.areaId or 0) == self.areaId then
			local taskId = self.view:addPrefabWithPathAsync(parent, AddressDataConst.UI_HOME_PLOT_BORDER, function(obj)
				local borderPlot = obj.gameObject
				local pos = info.prefabPos

				borderPlot.transform.sizeDelta = Vector2(self.model.ZONE_WIDTH * self.model.UNIT_LENGTH, self.model.ZONE_HEIGHT * self.model.UNIT_LENGTH)

				borderPlot.transform:SetLocalPositionEx(pos[1] * self.model.UNIT_LENGTH, pos[2] * self.model.UNIT_LENGTH, 0)

				local objectReference = borderPlot:GetComponent("ObjectReference")
				local txtPlotNameUSDFText = objectReference:GetRefValue("txtPlotNameUSDFText")

				txtPlotNameUSDFText:SetActive(true)
				ClientTextUtils.setText(txtPlotNameUSDFText, pg.getLocalizationText(info.showName or info.name))
			end)
		end
	end
end

function HomelandPlotManageNewCtrl:createOrnamentGrid()
	self.ornamentTable = self.model:getOrnamentInfos(self.areaId)

	local parent = self.view.ornamentUWidget.transform

	for _, ornamentInfo in pairs(self.ornamentTable) do
		local taskId = self.view:addPrefabWithPathAsync(parent, AddressDataConst.UI_HOME_PLOT_CELL, function(obj)
			local ornamentPlot = obj.gameObject

			ornamentInfo.obj = ornamentPlot

			local width, length = self.model:getOrnamentSize(ornamentInfo.homeId, ornamentInfo.isRotate)

			ornamentPlot.transform.sizeDelta = Vector2(width * self.model.UNIT_LENGTH, length * self.model.UNIT_LENGTH)

			ornamentPlot.transform:SetLocalPositionEx(ornamentInfo.pos.x, ornamentInfo.pos.y, 0)

			local objectReference = ornamentPlot:GetComponent("ObjectReference")
			local txtUSDFText = objectReference:GetRefValue("txtUSDFText")
			local uINodeHomeManagePlotCellUButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")
			local imgBgRoundUWidget = objectReference:GetRefValue("imgBgRoundUWidget")

			ClientTextUtils.setText(txtUSDFText, pg.getGameString("LEVEL_LESS"))
			self:refreshLevelRedDot(ornamentInfo)

			local subType = 3

			if ornamentInfo.ornamentType == 101 then
				subType = 0
			elseif ornamentInfo.ornamentType == 102 or ornamentInfo.ornamentType == 103 then
				subType = 1
			elseif ornamentInfo.ornamentType == 104 then
				subType = 2
			end

			uINodeHomeManagePlotCellUButton:TryChangePage("PlotType", subType)

			local sizeType = 2

			if width >= 3 or length >= 3 then
				sizeType = 0
			elseif width >= 2 or length >= 2 then
				sizeType = 1
			end

			uINodeHomeManagePlotCellUButton:TryChangePage("ScaleGrade", sizeType)

			function uINodeHomeManagePlotCellUButton.luaClick()
				if self.multipleMode ~= Const.HOMELAND_MULTIPLE_MODE.Normal then
					self:changeMultipleSelect(ornamentInfo, imgBgRoundUWidget)
				else
					self:changeSelectornamen(ornamentInfo)
				end
			end

			self:refreshOrnamentElectricMode(ornamentInfo)
			self:refreshOrnamentGridSingle(ornamentInfo)
		end)
	end
end

function HomelandPlotManageNewCtrl:refreshLevelRedDot(ornamentInfo)
	local ornamentPlot = ornamentInfo.obj

	if not ornamentPlot then
		return
	end

	local objectReference = ornamentPlot:GetComponent("ObjectReference")
	local upHighUWidget = objectReference:GetRefValue("upHighUWidget")
	local canLevelUp = self.model:checkOrnamentCanLevelUp(ornamentInfo.homeId)

	upHighUWidget:SetActive(canLevelUp)
end

function HomelandPlotManageNewCtrl:refreshOrnamentGrid()
	if not self.ornamentTable then
		return
	end

	for _, ornamentInfo in pairs(self.ornamentTable) do
		self:refreshOrnamentGridSingle(ornamentInfo)
	end
end

function HomelandPlotManageNewCtrl:selectAllOrnamentGridMultiple(selectAll, isBtn)
	selectAll = selectAll or false
	self.multipleCount = 0

	if selectAll then
		for ornamentId, _ in pairs(self.canMultipleOrnamentTable) do
			local ornamentInfo = self.ornamentTable[ornamentId]

			if ornamentInfo then
				local ornamentPlot = ornamentInfo.obj
				local objectReference = ornamentPlot:GetComponent("ObjectReference")
				local imgBgRoundUWidget = objectReference:GetRefValue("imgBgRoundUWidget")

				imgBgRoundUWidget:SetActive(true)
			end

			self.isMultipleOrnamentTable[ornamentId] = true
			self.multipleCount = self.multipleCount + 1
		end
	else
		for ornamentId, _ in pairs(self.isMultipleOrnamentTable) do
			local ornamentInfo = self.ornamentTable[ornamentId]

			if ornamentInfo then
				local ornamentPlot = ornamentInfo.obj
				local objectReference = ornamentPlot:GetComponent("ObjectReference")
				local imgBgRoundUWidget = objectReference:GetRefValue("imgBgRoundUWidget")

				imgBgRoundUWidget:SetActive(false)
			end
		end

		table.clear(self.isMultipleOrnamentTable)
	end

	if self.plotDetailManage and self.plotDetailManage.plotDetailRecipe then
		local maxCount = self.canMultipleCount

		if isBtn then
			maxCount = nil
		end

		self.plotDetailManage.plotDetailRecipe:refreshMultipleNumText(self.multipleCount, maxCount)
	end

	if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.SpeedUp and self.plotSpeedUp then
		self.plotSpeedUp:setSelectedOrnaments(self.isMultipleOrnamentTable)
	end
end

function HomelandPlotManageNewCtrl:refreshOrnamentGridMultipleMode(multipleMode, ornamentId, formulaId)
	if not self.ornamentTable then
		return
	end

	local ornamentTypeId1 = self.model:getOrnamentTypeId(ornamentId)
	local needLevel = self.model:getFormulaUnlockLevel(ornamentId, formulaId)

	if multipleMode == Const.HOMELAND_MULTIPLE_MODE.Formula and (not ornamentTypeId1 or not needLevel) then
		return
	end

	self.multipleMode = multipleMode or Const.HOMELAND_MULTIPLE_MODE.Normal
	self.multipleCount = 0
	self.canMultipleCount = 0

	table.clear(self.canMultipleOrnamentTable)
	table.clear(self.isMultipleOrnamentTable)

	for _, ornamentInfo in pairs(self.ornamentTable) do
		local ornamentPlot = ornamentInfo.obj
		local objectReference = ornamentPlot:GetComponent("ObjectReference")
		local uINodeHomeManagePlotCellUButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")
		local imgBgRoundUWidget = objectReference:GetRefValue("imgBgRoundUWidget")
		local isCheck = false

		if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.Formula then
			local ornamentTypeId2 = self.model:getOrnamentTypeId(ornamentInfo.ornamentId)

			if ornamentTypeId1 ~= ornamentTypeId2 then
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 1)
			elseif needLevel > ornamentInfo.level then
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 2)
			else
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 0)

				self.canMultipleOrnamentTable[ornamentInfo.ornamentId] = true
				self.canMultipleCount = self.canMultipleCount + 1
			end

			if ornamentId == ornamentInfo.ornamentId then
				isCheck = true
				self.isMultipleOrnamentTable[ornamentInfo.ornamentId] = true
				self.multipleCount = self.multipleCount + 1
			end
		elseif self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.LevelUp then
			local canLevelUp = self.model:checkOrnamentCanLevelUp(ornamentInfo.homeId)

			if canLevelUp then
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 0)

				self.canMultipleOrnamentTable[ornamentInfo.ornamentId] = true
				self.canMultipleCount = self.canMultipleCount + 1
			else
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 1)
			end
		elseif self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.SpeedUp then
			local accelerateInfo = ClientHomelandUtils.getProduceAccelerateInfo(ornamentInfo.ornamentId)

			if accelerateInfo then
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 0)

				self.canMultipleOrnamentTable[ornamentInfo.ornamentId] = true
				self.canMultipleCount = self.canMultipleCount + 1
			else
				uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 1)
			end
		else
			uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 0)
		end

		imgBgRoundUWidget:SetActive(isCheck)
	end

	if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.Formula and self.plotDetailManage and self.plotDetailManage.plotDetailRecipe then
		self.plotDetailManage.plotDetailRecipe:refreshMultipleNumText(self.multipleCount, self.canMultipleCount)
	end

	self:refreshVirtualMouseState()
end

function HomelandPlotManageNewCtrl:exitOrnamentGridMultipleMode()
	if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.Normal then
		return
	end

	table.clear(self.canMultipleOrnamentTable)
	table.clear(self.isMultipleOrnamentTable)

	for _, ornamentInfo in pairs(self.ornamentTable) do
		local ornamentPlot = ornamentInfo.obj

		if ornamentPlot then
			local objectReference = ornamentPlot:GetComponent("ObjectReference")
			local uINodeHomeManagePlotCellUButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")
			local imgBgRoundUWidget = objectReference:GetRefValue("imgBgRoundUWidget")

			uINodeHomeManagePlotCellUButton:TryChangePage("Disable", 0)
			imgBgRoundUWidget:SetActive(false)
		end
	end

	if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.LevelUp or self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.SpeedUp then
		self.view.quickActionsUWidget:SetActive(true)
		self:setSliderBtnActive(true)

		self.view.sliderFakeUSlider.interactable = self.selectOrnamen == nil
	end

	self.view.batchUpgradeUContainer:SetActive(false)
	self.view.plotSpeedUpUContainer:SetActive(false)

	self.multipleMode = Const.HOMELAND_MULTIPLE_MODE.Normal
	self.multipleCount = 0
	self.canMultipleCount = 0

	self:refreshVirtualMouseState()
end

function HomelandPlotManageNewCtrl:changeMultipleSelect(ornamentInfo, imgBgRoundUWidget)
	if self.canMultipleOrnamentTable[ornamentInfo.ornamentId] then
		local active = false

		if self.isMultipleOrnamentTable[ornamentInfo.ornamentId] then
			self.isMultipleOrnamentTable[ornamentInfo.ornamentId] = nil
			active = false
			self.multipleCount = self.multipleCount - 1
		else
			self.isMultipleOrnamentTable[ornamentInfo.ornamentId] = true
			active = true
			self.multipleCount = self.multipleCount + 1
		end

		imgBgRoundUWidget:SetActive(active)

		if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.Formula and self.plotDetailManage and self.plotDetailManage.plotDetailRecipe then
			self.plotDetailManage.plotDetailRecipe:refreshMultipleNumText(self.multipleCount, self.canMultipleCount)
		end

		if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.LevelUp and self.plotMultipleUpgrade then
			self.plotMultipleUpgrade:changeUpgradeInfoList(ornamentInfo.ornamentId, active)
		end

		if self.multipleMode == Const.HOMELAND_MULTIPLE_MODE.SpeedUp and self.plotSpeedUp then
			self.plotSpeedUp:setSelectedOrnaments(self.isMultipleOrnamentTable)
		end
	end
end

function HomelandPlotManageNewCtrl:refreshSpeedUpCandidates()
	if self.multipleMode ~= Const.HOMELAND_MULTIPLE_MODE.SpeedUp then
		return
	end

	self.canMultipleCount = 0
	self.multipleCount = 0

	table.clear(self.canMultipleOrnamentTable)

	for _, ornamentInfo in pairs(self.ornamentTable) do
		local ornamentId = ornamentInfo.ornamentId
		local accelerateInfo = ClientHomelandUtils.getProduceAccelerateInfo(ornamentId)
		local waitSignature = self.speedUpWaiting and self.speedUpWaiting[ornamentId]

		if waitSignature then
			local shouldClearWaiting = self:isSingleStageSpeedUp(ornamentId) or not accelerateInfo

			shouldClearWaiting = shouldClearWaiting or self:getSpeedUpWaitSignature(ornamentId) ~= waitSignature

			if shouldClearWaiting then
				self.speedUpWaiting[ornamentId] = nil
			else
				accelerateInfo = nil
			end
		end

		local objectReference = ornamentInfo.obj:GetComponent("ObjectReference")
		local cellButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")
		local selectedWidget = objectReference:GetRefValue("imgBgRoundUWidget")

		if accelerateInfo then
			self.canMultipleOrnamentTable[ornamentId] = true
			self.canMultipleCount = self.canMultipleCount + 1

			cellButton:TryChangePage("Disable", 0)
		else
			self.isMultipleOrnamentTable[ornamentId] = nil

			selectedWidget:SetActive(false)
			cellButton:TryChangePage("Disable", 1)
		end

		if self.isMultipleOrnamentTable[ornamentId] then
			self.multipleCount = self.multipleCount + 1
		end
	end

	self.plotSpeedUp:setSelectedOrnaments(self.isMultipleOrnamentTable)
end

function HomelandPlotManageNewCtrl:getSpeedUpWaitSignature(ornamentId)
	local facilityInfo = pg.me.space.facility[ornamentId]

	if not facilityInfo then
		return ""
	end

	local stateInfo = facilityInfo.facilityStateInfo or {}
	local outputCount = 0

	for _, itemNum in pairs(facilityInfo.outputMap or EMPTY_TABLE) do
		outputCount = outputCount + itemNum
	end

	local specialOutputCount = HomeLandUtils.sumSpecialOutput(facilityInfo)

	return table.concat({
		facilityInfo.formulaId or 0,
		facilityInfo.facilityState or 0,
		stateInfo.ptype or 0,
		stateInfo.totalValue or 0,
		stateInfo.curValue or 0,
		stateInfo.startTs or 0,
		outputCount,
		specialOutputCount
	}, ":")
end

function HomelandPlotManageNewCtrl:getSpeedUpWaitSignatures(ornamentIds)
	local signatures = {}

	for _, ornamentId in ipairs(ornamentIds) do
		signatures[ornamentId] = self:getSpeedUpWaitSignature(ornamentId)
	end

	return signatures
end

function HomelandPlotManageNewCtrl:isSingleStageSpeedUp(ornamentId)
	local facilityInfo = pg.me.space.facility[ornamentId]

	if not facilityInfo then
		return false
	end

	local formulaData = HomelandFormulaData[facilityInfo.formulaId]

	if not formulaData then
		return false
	end

	local preOperateList = formulaData.preOperateList or {}
	local postOperateList = formulaData.postOperateList or {}
	local stageCount = #preOperateList + #postOperateList
	local stageId = preOperateList[1] or postOperateList[1]

	return stageCount == 1 and formulaData.accelerateStageList == stageId
end

function HomelandPlotManageNewCtrl:onBatchSpeedUpResult(code, results, requestSignatures)
	if code == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.ERROR_PRODUCE_MATERIAL_NOT_ENOUGH then
		pg.global.showBubbleMessage(NoticeDef.ITEM_USE_OUT)
	end

	local successCount = 0

	if code == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS then
		self.speedUpWaiting = self.speedUpWaiting or {}

		for _, result in ipairs(results) do
			if result[2] == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS then
				local ornamentId = result[1]
				local requestSignature = requestSignatures[ornamentId]

				successCount = successCount + 1

				if self:isSingleStageSpeedUp(ornamentId) then
					self.speedUpWaiting[ornamentId] = nil
				elseif requestSignature and self:getSpeedUpWaitSignature(ornamentId) == requestSignature then
					self.speedUpWaiting[ornamentId] = requestSignature
				else
					self.speedUpWaiting[ornamentId] = nil
				end

				self.isMultipleOrnamentTable[ornamentId] = nil
			end
		end
	end

	if successCount > 0 then
		pg.global.showBubbleMessage(NoticeDef.HOMELAND_SPEED_SUCCESS)
	end

	self:refreshSpeedUpCandidates()
end

function HomelandPlotManageNewCtrl:refreshOrnamentElectricMode(ornamentInfo, useAnim)
	local ornamentPlot = ornamentInfo and ornamentInfo.obj

	if not ornamentPlot then
		return
	end

	local currentOrnamentInfo = pg.me.space.ornament[ornamentInfo.ornamentId]
	local electricMode = currentOrnamentInfo ~= nil and currentOrnamentInfo.electricMode == true
	local objectReference = ornamentPlot:GetComponent("ObjectReference")
	local electricTagUWidget = objectReference:GetRefValue("electricTagUWidget")
	local uINodeHomeManagePlotCellUButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")

	electricTagUWidget:SetActive(electricMode)

	if useAnim and electricMode then
		uINodeHomeManagePlotCellUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	ornamentInfo.electricMode = electricMode
end

function HomelandPlotManageNewCtrl:refreshOrnamentGridSingle(ornamentInfo)
	local ornamentPlot = ornamentInfo.obj

	if not ornamentPlot then
		return
	end

	local objectReference = ornamentPlot:GetComponent("ObjectReference")
	local iconPlotUImage = objectReference:GetRefValue("iconPlotUImage")
	local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
	local iconProductUImage = objectReference:GetRefValue("iconProductUImage")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local txtUSDFText = objectReference:GetRefValue("txtUSDFText")
	local uINodeHomeManagePlotCellUButton = objectReference:GetRefValue("uINodeHomeManagePlotCellUButton")
	local imgFrameBatchUWidget = objectReference:GetRefValue("imgFrameBatchUWidget")
	local imgBgRoundUWidget = objectReference:GetRefValue("imgBgRoundUWidget")
	local facilityInfo = pg.me.space.facility[ornamentInfo.ornamentId]
	local isElectricLink = Utils.getHomeFacilityType(ornamentInfo.homeId) == Const.HOMELAND_FACILITY_TYPE.ElectricLink
	local canUpgrade = self.model:canHomeObjectUpgrade(ornamentInfo.homeId)

	txtLvUSDFText:SetActive(not isElectricLink and canUpgrade)

	if self.viewMode == self.VIEWMODE_TYPE.SmallOrnamen then
		uINodeHomeManagePlotCellUButton:TryChangePage("MainState", 0)
		uINodeHomeManagePlotCellUButton:TryChangePage("Scale", 1)
		ClientTextUtils.setText(txtLvUSDFText, "Lv." .. ornamentInfo.level)

		iconPlotUImage.url = ornamentInfo.iconId
	elseif Utils.isHomeHatchBox(ornamentInfo.homeId) then
		uINodeHomeManagePlotCellUButton:TryChangePage("Scale", 0)

		local hatchBoxState = HomeLandUtils.getHatchBoxStatus(ornamentInfo.ornamentId)

		if hatchBoxState == Const.HOME_HATCHBOX_STATUS.HATCHING or hatchBoxState == Const.HOME_HATCHBOX_STATUS.HATCHED then
			uINodeHomeManagePlotCellUButton:TryChangePage("MainState", 1)

			local hatchBoxInfo = pg.me.space:getHatchBoxInfo(ornamentInfo.ornamentId)
			local hatchBoxRatio = HomeLandUtils.getHatchBoxProgressRatio(hatchBoxInfo)

			progressUProgress:SetActive(hatchBoxState == Const.HOME_HATCHBOX_STATUS.HATCHING)

			progressUProgress.maxValue = 1
			progressUProgress.value = hatchBoxRatio or 0

			progressUProgress:TryChangePage("State", 0)

			local hatchBoxData = HomeLandUtils.getHatchBoxItemInfo(ornamentInfo.ornamentId)

			iconProductUImage.url = hatchBoxData.itemIcon
		else
			uINodeHomeManagePlotCellUButton:TryChangePage("MainState", 0)
			ClientTextUtils.setText(txtLvUSDFText, "Lv." .. ornamentInfo.level)

			iconPlotUImage.url = ornamentInfo.iconId
		end
	elseif Utils.isHomeEnvFacility(ornamentInfo.homeId) then
		uINodeHomeManagePlotCellUButton:TryChangePage("Scale", 0)
		uINodeHomeManagePlotCellUButton:TryChangePage("MainState", 0)
		ClientTextUtils.setText(txtLvUSDFText, "Lv." .. ornamentInfo.level)

		iconPlotUImage.url = ornamentInfo.iconId
	elseif not facilityInfo or facilityInfo.facilityState == 0 then
		uINodeHomeManagePlotCellUButton:TryChangePage("Scale", 0)
		uINodeHomeManagePlotCellUButton:TryChangePage("MainState", 0)
		ClientTextUtils.setText(txtLvUSDFText, "Lv." .. ornamentInfo.level)

		iconPlotUImage.url = ornamentInfo.iconId
	else
		uINodeHomeManagePlotCellUButton:TryChangePage("Scale", 0)
		uINodeHomeManagePlotCellUButton:TryChangePage("MainState", 1)

		local operateInfo = HomelandOperateData[facilityInfo.facilityState]

		iconProductUImage.url = self.model:getOperateIcon(operateInfo, facilityInfo)

		local hasEntDoingOper = self.model:checkHasEntDoingOper(ornamentInfo.ornamentId)
		local statePaused = self.model:getStatePaused(facilityInfo, ornamentInfo.ornamentId)
		local workloadRate = Utils.getFacilityCurWorkRate(facilityInfo, ornamentInfo.homeId, ornamentInfo.ornamentId, statePaused)
		local workloadState = self.model:getProgressWorkloadState(hasEntDoingOper, workloadRate)

		progressUProgress:TryChangePage("State", workloadState)
		self:refreshFacilityProgress(facilityInfo, hasEntDoingOper, statePaused, progressUProgress)
	end
end

function HomelandPlotManageNewCtrl:refreshFacilityProgress(facilityInfo, hasEntDoingOper, statePaused, progress)
	if not facilityInfo then
		return
	end

	local facilityStateInfo = facilityInfo.facilityStateInfo
	local facilityState = facilityInfo.facilityState
	local operateInfo = HomelandOperateData[facilityInfo.facilityState]

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		if facilityStateInfo.curValue <= 0 and not hasEntDoingOper then
			progress:SetActive(false)
		else
			progress:SetActive(true)

			progress.maxValue = facilityStateInfo.totalValue
			progress.value = facilityStateInfo.curValue
		end
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		if facilityStateInfo.curValue <= 0 and statePaused then
			progress:SetActive(false)
		else
			progress:SetActive(true)
		end

		progress.maxValue = facilityStateInfo.totalValue

		local curValue = facilityStateInfo.curValue

		if facilityStateInfo.startTs ~= 0 then
			curValue = facilityStateInfo.curValue + (Time.getSecond() - facilityStateInfo.startTs)
		end

		local leftTs = math.max(facilityStateInfo.totalValue - curValue, 0)

		progress.value = math.min(curValue, facilityStateInfo.totalValue)
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		progress:SetActive(false)
	end
end

function HomelandPlotManageNewCtrl:setGridViewPos()
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local selectedItem = self.view.listPlotUList.selectedItem

	if not selectedItem or not selectedItem.level then
		return
	end

	local zoneInfo = HomelandZoneUnlockConfigData[selectedItem.level]

	if zoneInfo then
		self.view.plotCellPoolUWidget.transform:SetLocalPositionEx(zoneInfo.prefabPos[1] * -self.model.UNIT_LENGTH, zoneInfo.prefabPos[2] * -self.model.UNIT_LENGTH, 0)
	end
end

function HomelandPlotManageNewCtrl:clearSelectornamen()
	self.view.listPlotUList:DeselectAll()

	self.selectLevel = nil
end

function HomelandPlotManageNewCtrl:changeViewMode(viewMode, forceSelect)
	if viewMode ~= self.VIEWMODE_TYPE.Plot and not self:canEnterPlotDetail() then
		return
	end

	if not forceSelect and (self.viewMode == viewMode or self.selectOrnamen ~= nil or self.multipleMode ~= Const.HOMELAND_MULTIPLE_MODE.Normal) then
		return
	end

	local wasOrnamenMode = self:isOrnamenMode()

	self.viewMode = viewMode

	local isNowOrnamenMode = self:isOrnamenMode()

	self.view.listPlotUList:SetActive(not isNowOrnamenMode)
	self.view.plotCellPoolUWidget:SetActive(isNowOrnamenMode)
	self.view.quickActionsUWidget:SetActive(isNowOrnamenMode)

	self.view.sliderFakeUSlider.value = self:getSliderValue()

	if isNowOrnamenMode then
		self:applyViewScale()

		if not wasOrnamenMode then
			self:setGridViewPos()
			self:clearSelectornamen()
		end

		self:refreshOrnamentGrid()
	elseif self.viewMode == HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Plot then
		self:applyViewScale()
		self.view.listPlotUList:RefreshList()

		local posX = self.view.plotCellPoolUWidget.transform.localPosition.x / -self.model.UNIT_LENGTH
		local posY = self.view.plotCellPoolUWidget.transform.localPosition.y / -self.model.UNIT_LENGTH
		local zoneIndex = self.model:getZoneIndexByPos(posX, posY, self.areaId)
		local zoneInfo = self.plotList[zoneIndex + 1]

		if not zoneInfo or zoneInfo.enableUnlock == self.model.ENABLEUNLOCK_TYPE.CannotUnlock then
			zoneIndex = self.model:getDefaultZoneIndex(self.areaId)
		end

		if forceSelect then
			zoneIndex = forceSelect
		end

		if zoneIndex then
			self.view.listPlotUList:SelectItem(zoneIndex)
		end

		if wasOrnamenMode then
			self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end

	self:onRefreshFormulaTracking()
	self:refreshVirtualMouseState()
end

function HomelandPlotManageNewCtrl:onRefreshFormulaTracking()
	local isNowOrnamenMode = self:isOrnamenMode()
	local pinnedFormulaList = pg.me.pinnedFormulaList or {}
	local pinnedFormulaId = pinnedFormulaList[1]

	if isNowOrnamenMode and pinnedFormulaId then
		self.view.formulaTrackTipsUContainer:SetActive(true)
		self.formulaTracking:refreshPanel(pinnedFormulaId)
	else
		self.view.formulaTrackTipsUContainer:SetActive(false)
	end
end

function HomelandPlotManageNewCtrl:refreshEnvironmentRange(ornamentInfo)
	local rangeBtn = self.view.environmentRangeUButton

	if not ornamentInfo then
		rangeBtn:SetActive(false)

		return
	end

	local envInfo = self.model:getEnvFacilityInfo(ornamentInfo.homeId)

	if not envInfo then
		rangeBtn:SetActive(false)

		return
	end

	rangeBtn:SetActive(true)
	rangeBtn.transform:SetLocalPositionEx(ornamentInfo.pos.x, ornamentInfo.pos.y, 0)

	local envWidth = envInfo.envBounds[1]
	local envHeight = envInfo.envBounds[2]

	rangeBtn.transform.sizeDelta = Vector2(envWidth * self.model.UNIT_LENGTH, envHeight * self.model.UNIT_LENGTH)

	local page = self.ENV_FACILITY_PAGE[envInfo.facilityType] or 0

	rangeBtn:TryChangePage("FacilityType", page)
end

function HomelandPlotManageNewCtrl:changeSelectornamen(ornamentInfo)
	if self.selectOrnamen == ornamentInfo then
		return
	end

	self:exitOrnamentGridMultipleMode()
	self.view.plotManageUContainer:SetActive(ornamentInfo ~= nil)
	self.view.quickActionsUWidget:SetActive(ornamentInfo == nil)
	self:setSliderBtnActive(ornamentInfo == nil)

	self.view.sliderFakeUSlider.interactable = ornamentInfo == nil

	if ornamentInfo ~= nil and ornamentInfo.obj ~= nil then
		local ornamentPlot = ornamentInfo.obj
		local objectReference = ornamentPlot:GetComponent("ObjectReference")
		local imgFrameBatchUWidget = objectReference:GetRefValue("imgFrameBatchUWidget")

		imgFrameBatchUWidget:SetActive(true)
	end

	if self.selectOrnamen ~= nil and self.selectOrnamen.obj ~= nil then
		local ornamentPlot = self.selectOrnamen.obj
		local objectReference = ornamentPlot:GetComponent("ObjectReference")
		local imgFrameBatchUWidget = objectReference:GetRefValue("imgFrameBatchUWidget")

		imgFrameBatchUWidget:SetActive(false)
	end

	self.selectOrnamen = ornamentInfo

	if self.selectOrnamen ~= nil then
		self.plotDetailManage:refreshPlotDetailBox(ornamentInfo)
	end

	self:refreshEnvironmentRange(ornamentInfo)
	self:refreshVirtualMouseState()
end

function HomelandPlotManageNewCtrl:onZoneUnlock()
	pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_AREA_UNLOCK)
	self.view.listCurrencyUList:RefreshList()
	pg.global.showBubbleMessage(NoticeDef.HOME_BLOCK_UNLOCK_SUCCESS)

	self.plotList = self.model:getPlotList(self.areaId)

	self.view.listPlotUList:SetList(self.plotList)

	local index = self.model:getZoneIndexByLevel(self.selectLevel, self.areaId)

	self.view.listPlotUList:SelectItem(index)

	local res, button = self.view.listPlotUList:TryGetChildAt(index)

	if res then
		local objectReference = button:GetComponent("ObjectReference")
		local uINodeHomeManagePlotItemUButton = objectReference:GetRefValue("uINodeHomeManagePlotItemUButton")

		uINodeHomeManagePlotItemUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	self.plotPanelManage:refreshPlotPanel(self.view.listPlotUList.selectedItem)
end

function HomelandPlotManageNewCtrl:onHomelandFormulaChanged(ornamentId)
	if self.plotDetailManage then
		self.plotDetailManage:refreshPlotDetailInfo(ornamentId)
	end

	self:refreshSpeedUpCandidates()
end

function HomelandPlotManageNewCtrl:onDrawingUnlockChanged(data)
	if not data.formulaId or not self.plotDetailManage then
		return
	end

	local recipe = self.plotDetailManage.plotDetailRecipe

	if recipe and recipe.ornamentInfo then
		recipe:refreshPlotDetailRecipe(recipe.ornamentInfo, true)
	end
end

function HomelandPlotManageNewCtrl:onLevelUpSucc(info)
	self.view.listCurrencyUList:RefreshList()
	self:refreshOrnamentInfoByOrnamentId(info.ornamentId)

	if self.plotDetailManage then
		self.plotDetailManage:refreshPlotDetailInfo(info.ornamentId)
	end
end

function HomelandPlotManageNewCtrl:onFacilityAllocateChanged(ornamentId)
	if self.plotDetailManage then
		self.plotDetailManage:refreshPlotDetailInfo(ornamentId)
	end

	self:refreshSpeedUpCandidates()
end

function HomelandPlotManageNewCtrl:onOrnamentChanged(data)
	if not data or not self.ornamentTable then
		return
	end

	local ornamentInfo = self.ornamentTable[data.ornamentId]

	if not ornamentInfo then
		return
	end

	local currentOrnamentInfo = pg.me.space.ornament[data.ornamentId]
	local electricMode = currentOrnamentInfo ~= nil and currentOrnamentInfo.electricMode == true

	if ornamentInfo.electricMode == electricMode then
		return
	end

	self:refreshOrnamentElectricMode(ornamentInfo, true)

	if self.plotDetailManage then
		self.plotDetailManage:onElectricModeChanged(data.ornamentId)
	end
end

function HomelandPlotManageNewCtrl:updateOrnamentGrid()
	if self:isOrnamenMode() and self.ornamentTable then
		self:refreshOrnamentGrid()
		self:refreshSpeedUpCandidates()
	end
end

function HomelandPlotManageNewCtrl:onEnterPage()
	local playerPos = pg.game.home:getLocalPosition(self.areaId, pg.me:getPosition())
	local selectIndex = self.model:getZoneIndexByPos(playerPos.x, playerPos.z, self.areaId)

	self.plotList = self.model:getPlotList(self.areaId)

	self.view.listPlotUList:SetList(self.plotList)
	self:clearSelectornamen()

	self.multipleCount = 0
	self.canMultipleCount = 0
	self.canMultipleOrnamentTable = {}
	self.isMultipleOrnamentTable = {}

	self:changeSelectornamen(nil)
	self:changeViewMode(HomelandPlotManageNewCtrl.VIEWMODE_TYPE.Plot, selectIndex)

	if not self.ornamentRefreshTimer then
		self.ornamentRefreshTimer = self:startTimer(function()
			self:updateOrnamentGrid()
		end, 0.5, true)
	end

	self.view.plotManageUContainer:SetActive(false)
	self.view.batchUpgradeUContainer:SetActive(false)
	self.view.plotSpeedUpUContainer:SetActive(false)
	self.view.environmentRangeUButton:SetActive(false)

	local canEnterPlotDetail = self:canEnterPlotDetail()

	self.view.sliderFakeUSlider:SetActive(canEnterPlotDetail)
	self:setSliderBtnActive(canEnterPlotDetail)

	self.view.sliderFakeUSlider.interactable = canEnterPlotDetail

	self.view.viewCtrlSimpleViewCtrl.transform:SetLocalScaleEx(1, 1, 1)
	self:exitOrnamentGridMultipleMode()
end

function HomelandPlotManageNewCtrl:onGoMainAreaPageBtnClick()
	pg.global.ui.homelandAreaManage:open({
		isFromPlotManage = true,
		areaId = self.areaId
	}, function()
		self:close()
	end)
end

function HomelandPlotManageNewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:onEnterPage()
end

function HomelandPlotManageNewCtrl:onShow()
	return
end

function HomelandPlotManageNewCtrl:onHide()
	return
end

function HomelandPlotManageNewCtrl:close()
	if pg.global.ui.homelandAreaManage.view then
		pg.global.ui.homelandAreaManage.enterEventMark = true
	end

	UICtrl.close(self)
end

function HomelandPlotManageNewCtrl:onDestroy()
	self.selectLevel = nil
	self.multipleMode = Const.HOMELAND_MULTIPLE_MODE.Normal
	self.multipleCount = 0
	self.canMultipleCount = 0
	self.canMultipleOrnamentTable = {}
	self.isMultipleOrnamentTable = {}

	if self.ornamentRefreshTimer then
		self:killTimer(self.ornamentRefreshTimer)
	end

	self.ornamentRefreshTimer = nil

	self:_stopGamepadPan()

	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener("UI_HomelandPlotManageNew_FocusChanged")
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("UI_HomelandPlotManageNew_ConsoleBarRefresh")
	end

	pg.global.uiMgr:RemoveVirtualMouseField(self.virtualMouseField)

	self.virtualMouseField = nil

	UICtrl.onDestroy(self)
end

return HomelandPlotManageNewCtrl
