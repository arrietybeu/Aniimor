-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlayerEditorSetting\\HomelandPlayerEditorSettingCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandPlayerEditorSettingCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local HomelandConfigData = require("Data.homeland_config_data")
local Time = require("Core.Common.Time")
local HomelandPlayerEditorSettingCtrl = Class.LightClass("HomelandPlayerEditorSettingCtrl", UICtrl)

HomelandPlayerEditorSettingCtrl.messages = {}

local CLEAR_ALL_ORNAMENTS_CONFIRM_DELAY = 3

HomelandPlayerEditorSettingCtrl.FIRST_PASS_SETTINGS = {
	{
		tIndex = 1,
		defaultMode = true,
		titleKey = "HOMELAND_AUTO_ATTACH",
		mode = ClientConst.HomelandEditorSetting.AutoAttach
	},
	{
		tIndex = 0,
		useRotationList = true,
		titleKey = "HOMELAND_EDIT_ROTATION_ANGLE",
		mode = ClientConst.HomelandEditorSetting.RotationAngle
	},
	{
		tIndex = 1,
		titleKey = "HOMELAND_EDIT_THREE_AXIS_ROTATION",
		mode = ClientConst.HomelandEditorSetting.ThreeAxisRotation
	},
	{
		tIndex = 1,
		titleKey = "HOMELAND_EDIT_THREE_AXIS_SCALE",
		mode = ClientConst.HomelandEditorSetting.ThreeAxisScaling
	},
	{
		tIndex = 1,
		tipsModeKey = "ContinuousPurchaseHelpId",
		titleKey = "HOMELAND_EDIT_CONTINUOUS_PURCHASE",
		mode = ClientConst.HomelandEditorSetting.ContinuousPurchase
	},
	{
		tIndex = 1,
		titleKey = "HOMELAND_EDIT_QUICK_PLACEMENT",
		tipsModeKey = "QuickPlacementHelpId",
		defaultMode = true,
		mode = ClientConst.HomelandEditorSetting.QuickPlacement
	}
}
HomelandPlayerEditorSettingCtrl.SECOND_PASS_FILTERS = {
	{
		filterType = ClientConst.OrnamentFilterType.Heat
	},
	{
		filterType = ClientConst.OrnamentFilterType.Cool
	},
	{
		filterType = ClientConst.OrnamentFilterType.Electric
	},
	{
		filterType = ClientConst.OrnamentFilterType.Light
	}
}
HomelandPlayerEditorSettingCtrl.THIRD_PASS_FILTERS = {
	{
		tIndex = 2,
		clickFunc = "clearAllOrnaments",
		nameKey = "HOMELAND_COMPOSE_RESTORE_CURRENT_AREA"
	}
}

function HomelandPlayerEditorSettingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.editor = info.editor
	self.areaId = info.areaId or 0

	self:initSettingList()
end

function HomelandPlayerEditorSettingCtrl:addListener()
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("SETTING"))

	function self.view.listUList.luaRenderItem(button, index, data)
		if data.listMode == 1 then
			self:renderFirstPass(button, index, data)
		elseif data.listMode == 2 then
			self:renderSecondPass(button, index, data)
		elseif data.listMode == 3 then
			self:renderThirdPass(button, index, data)
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnClosePanalUButton.luaClick()
		self:close()
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("HomelandPlayerEditorSetting", function()
			self:refreshConsoleBarState()
		end)
	end

	self:bindHotKeyPerform("Raw/GamepadStart", function()
		if self._currentInfoBtn and self._currentInfoBtn.luaClick then
			self._currentInfoBtn.luaClick()
		end
	end)
end

function HomelandPlayerEditorSettingCtrl:refreshConsoleBarState()
	local currentFocusedUContent = pg.global.navMgr.CurrentFocusedUContent
	local needInfo = false
	local selectMode = 1

	self._currentInfoBtn = nil

	if currentFocusedUContent and currentFocusedUContent.gameObject.name == "BtnSwitch" then
		local listButton = currentFocusedUContent.transform.parent:GetComponent("UButton")

		if self.firstListPass and listButton then
			local data = self.firstListPass:GetData(listButton)

			if data and data.tipsMode ~= nil then
				needInfo = true

				local objRef = listButton:GetComponent("ObjectReference")

				self._currentInfoBtn = objRef and objRef:GetRefValue("btnInfoUButton") or nil
			end
		end
	elseif currentFocusedUContent and currentFocusedUContent.gameObject.name == "UI_Node_Filter_Facility(Clone)" then
		selectMode = 2
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeEditorSetting_Info", needInfo)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeEditorSetting_Switch", selectMode == 1)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeEditorSetting_Select", selectMode == 2)
end

function HomelandPlayerEditorSettingCtrl:renderFirstPass(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	local homeEditorRotationList = HomelandConfigData.homeEditorRotationList or {
		1,
		15,
		45,
		90
	}
	local rotationListInfo = {}

	for i, v in ipairs(homeEditorRotationList) do
		table.insert(rotationListInfo, {
			name = v .. "°"
		})
	end

	local settingList = {}

	for _, cfg in ipairs(self.FIRST_PASS_SETTINGS) do
		table.insert(settingList, {
			tIndex = cfg.tIndex,
			title = pg.getGameString(cfg.titleKey),
			mode = cfg.mode,
			defaultMode = cfg.defaultMode or false,
			tipsMode = cfg.tipsModeKey and HomelandConfigData[cfg.tipsModeKey] or nil,
			listInfo = cfg.useRotationList and rotationListInfo or nil
		})
	end

	self.firstListPass = listUList

	function listUList.luaRenderItem(_button, _index, _data)
		if _data.tIndex == 0 then
			self:renderSelectorInfo(_button, _index, _data)
		elseif _data.tIndex == 1 then
			self:renderSwitchButtonInfo(_button, _index, _data)
		end
	end

	listUList:SetList(settingList)
end

function HomelandPlayerEditorSettingCtrl:renderSecondPass(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	local settingList = {}

	for _, info in ipairs(self.SECOND_PASS_FILTERS) do
		table.insert(settingList, info)
	end

	function listUList.luaRenderItem(_button, _index, _data)
		self:rendererOrnamentFilterItem(_button, _index, _data)
	end

	listUList:SetList(settingList)
end

function HomelandPlayerEditorSettingCtrl:renderThirdPass(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	local settingList = {}

	for _, cfg in ipairs(self.THIRD_PASS_FILTERS) do
		table.insert(settingList, {
			tIndex = cfg.tIndex,
			name = pg.getGameString(cfg.nameKey),
			clickFunc = cfg.clickFunc
		})
	end

	function listUList.luaRenderItem(_button, _index, _data)
		if _data.tIndex == 2 then
			self:renderLongButtonInfo(_button, _index, _data)
		end
	end

	listUList:SetList(settingList)
end

function HomelandPlayerEditorSettingCtrl:rendererOrnamentFilterItem(button, index, data)
	button:TryChangePage("Type", data.filterType)

	button.isSelected = not pg.game.home:getHomeEditorOrnamentFilter(data.filterType)

	function button.luaClick()
		pg.game.home:setHomeEditorOrnamentFilter(data.filterType, not pg.game.home:getHomeEditorOrnamentFilter(data.filterType))

		button.isSelected = not pg.game.home:getHomeEditorOrnamentFilter(data.filterType)
	end
end

function HomelandPlayerEditorSettingCtrl:renderSelectorInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	local txtChoosNameUSDFText = objectReference:GetRefValue("txtChoosNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	function selectorUSelector.luaRenderPopup(popup, uList)
		function uList.luaRenderItem(_button, _index, _data)
			local objectReference = _button:GetComponent("ObjectReference")
			local txtUText = objectReference:GetRefValue("txtUText")

			ClientTextUtils.setText(txtUText, _data.name)

			function _button.luaClick()
				ClientTextUtils.setText(txtChoosNameUSDFText, _data.name)

				if data.mode == ClientConst.HomelandEditorSetting.RotationAngle then
					pg.game.home:setHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.RotationAngle, _index, self.editor)
				end

				selectorUSelector:ClosePopup()
			end
		end

		uList:SetList(data.listInfo)
	end

	selectorUSelector:SetOptions(data.listInfo)

	local selectIndex = HomelandConfigData.rotationAngleIndex or 0

	if data.mode == ClientConst.HomelandEditorSetting.RotationAngle then
		selectIndex = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.RotationAngle, selectIndex)
	end

	selectorUSelector.selectedIndex = math.max(0, math.min(selectIndex, #data.listInfo - 1))

	ClientTextUtils.setText(txtChoosNameUSDFText, data.listInfo[selectorUSelector.selectedIndex + 1].name)
end

function HomelandPlayerEditorSettingCtrl:renderSwitchButtonInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local txtButtonUSDFText = objectReference:GetRefValue("txtButtonUSDFText")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	local selectMode = pg.game.home:getHomeEditorPlayerSetting(data.mode, data.defaultMode or false)

	btnSwitchUButton.isSelected = selectMode

	ClientTextUtils.setText(txtButtonUSDFText, btnSwitchUButton.isSelected and pg.getGameString("ON") or pg.getGameString("OFF"))

	function btnSwitchUButton.luaClick()
		if data.mode == ClientConst.HomelandEditorSetting.ThreeAxisScaling then
			if btnSwitchUButton.isSelected and self:checkHasNonUniformScaleEntities() then
				self:showNonUniformScaleWarning(function()
					btnSwitchUButton.isSelected = false

					pg.game.home:setHomeEditorPlayerSetting(data.mode, false, self.editor)
					ClientTextUtils.setText(txtButtonUSDFText, btnSwitchUButton.isSelected and pg.getGameString("ON") or pg.getGameString("OFF"))
				end)

				return
			end

			btnSwitchUButton.isSelected = not btnSwitchUButton.isSelected

			pg.game.home:setHomeEditorPlayerSetting(data.mode, btnSwitchUButton.isSelected, self.editor)
		else
			btnSwitchUButton.isSelected = not btnSwitchUButton.isSelected

			pg.game.home:setHomeEditorPlayerSetting(data.mode, btnSwitchUButton.isSelected, self.editor)
		end

		ClientTextUtils.setText(txtButtonUSDFText, btnSwitchUButton.isSelected and pg.getGameString("ON") or pg.getGameString("OFF"))
	end

	btnInfoUButton:SetActive(data.tipsMode ~= nil)

	btnInfoUButton.enabledTooltip = false

	function btnInfoUButton.luaClick()
		if data.tipsMode then
			pg.global.ui.help:open({
				helpId = data.tipsMode
			})
		end
	end
end

function HomelandPlayerEditorSettingCtrl:renderLongButtonInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btn2ndUButton = objectReference:GetRefValue("btn2ndUButton")

	ClientTextUtils.setText(txtNameUSDFText, data.name)

	function btn2ndUButton.luaClick()
		if data.clickFunc then
			self[data.clickFunc](self)
		end
	end
end

function HomelandPlayerEditorSettingCtrl:clearAllOrnaments()
	local confirmCtrl = pg.global.ui.commonConfirm
	local confirmText = pg.getGameString("COMMON_CONFIRM")
	local unlockTime = Time.realtimeSinceStartup + CLEAR_ALL_ORNAMENTS_CONFIRM_DELAY

	local function resetConfirmButton()
		if confirmCtrl.tickTimer then
			confirmCtrl:killTimer(confirmCtrl.tickTimer)

			confirmCtrl.tickTimer = nil
		end

		if confirmCtrl.view then
			confirmCtrl.view.confirmBtn.interactable = true
		end
	end

	local function refreshConfirmButton()
		if not confirmCtrl.view then
			return
		end

		local remainSeconds = math.max(math.ceil(unlockTime - Time.realtimeSinceStartup), 0)

		confirmCtrl.view.confirmBtn.interactable = remainSeconds <= 0

		if remainSeconds > 0 then
			ClientTextUtils.setText(confirmCtrl.view.confirmBtnText, pg.getFormatText("{0}（{1}）", confirmText, remainSeconds))
		else
			ClientTextUtils.setText(confirmCtrl.view.confirmBtnText, confirmText)

			if confirmCtrl.tickTimer then
				confirmCtrl:killTimer(confirmCtrl.tickTimer)

				confirmCtrl.tickTimer = nil
			end
		end
	end

	confirmCtrl:open({
		tickInterval = 0.1,
		title = pg.getGameString("WARNING"),
		desc = pg.getGameString("HOMELAND_COMPOSE_RESTORE_CURRENT_AREA_CONFIRM"),
		okCb = function()
			pg.me:clearAllHomeOrnaments(self.areaId, function(isSucc)
				if isSucc then
					self:close()
					pg.global.ui.homelandPlacement:close()
					pg.global.ui.homelandMultiSelect:close()
					pg.global.ui.homelandEditor:close()
				end
			end)
		end,
		cancelCb = resetConfirmButton,
		extraInfo = {
			okBtnDesc = pg.getFormatText("{0}（{1}）", confirmText, CLEAR_ALL_ORNAMENTS_CONFIRM_DELAY),
			onSupersededCb = resetConfirmButton
		},
		tickFunc = refreshConfirmButton
	}, refreshConfirmButton)
end

function HomelandPlayerEditorSettingCtrl:checkHasNonUniformScaleEntities()
	local homeEntities = pg.game.home.homeEntities

	if not homeEntities then
		return false
	end

	local epsilon = 0.001

	for _, homeEntity in pairs(homeEntities) do
		if homeEntity.eModel and homeEntity.eModel:CheckPositionAgent() then
			local _scx, _scy, _scz = homeEntity.eModel:GetPositionAgentLocalScaleEx()

			if epsilon < math.abs(_scx - _scy) or epsilon < math.abs(_scx - _scz) or epsilon < math.abs(_scy - _scz) then
				return true
			end
		end
	end

	return false
end

function HomelandPlayerEditorSettingCtrl:showNonUniformScaleWarning(confirmCallback)
	ClientUtils.showConfirmRaw(pg.getGameString("NET_RECONNECT_TITLE"), pg.getGameString("HOMELAND_EDIT_SCALE_TIPS"), function()
		if confirmCallback then
			confirmCallback()
		end
	end, true)
end

function HomelandPlayerEditorSettingCtrl:onDestroy()
	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("HomelandPlayerEditorSetting")
	end

	UICtrl.onDestroy(self)

	self.firstListPass = nil
	self._currentInfoBtn = nil
	self.areaId = nil
end

function HomelandPlayerEditorSettingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.areaId = info.areaId or self.areaId or 0
end

function HomelandPlayerEditorSettingCtrl:initSettingList()
	local settingList = {
		{
			tIndex = 0,
			listMode = 1,
			title = pg.getGameString("HOMELAND_EDIT_PLACEMENT_SETTING")
		},
		{
			tIndex = 1,
			listMode = 2,
			title = pg.getGameString("HOMELAND_EDIT_RANGE_DISPLAY")
		},
		{
			tIndex = 0,
			listMode = 3,
			title = pg.getGameString("HOMELAND_COMPOSE_HOME_OPERATION")
		}
	}

	self.view.listUList:SetList(settingList)
end

function HomelandPlayerEditorSettingCtrl:onShow()
	return
end

function HomelandPlayerEditorSettingCtrl:onHide()
	return
end

function HomelandPlayerEditorSettingCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_HOMELAND_EDITOR_TOPLOGO] = true

	return whiteList
end

return HomelandPlayerEditorSettingCtrl
