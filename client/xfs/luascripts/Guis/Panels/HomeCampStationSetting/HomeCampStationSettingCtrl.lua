-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampStationSetting\\HomeCampStationSettingCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampStationSettingCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local HomeCampConst = require("Common.Const.HomeCampConst")
local TimerManager = require("Core.Timer.TimerManager")
local HomeCampStationSettingCtrl = Class.LightClass("HomeCampStationSettingCtrl", UICtrl)
local CONFIRM_LONG_PRESS_DURATION = 0.55
local CONFIRM_LONG_PRESS_TRIGGER = 0.25

HomeCampStationSettingCtrl.messages = {}

function HomeCampStationSettingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isPrivateStation = false
	self.isManager, self.isPrivate, self.permissions = self:getStationInfo()

	self:initSettingList()
end

function HomeCampStationSettingCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnClose2UButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmDissolveOrLeave()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderSettingInfo(button, index, data)
	end

	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("SETTING"))

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("HomeCampStationSetting", function()
			self:refreshConsoleBarState()
		end)
	end

	self:bindHotKeyPerform("Raw/GamepadStart", function()
		if self._currentInfoBtn then
			if self._currentInfoBtn.isTooltipOpen then
				self._currentInfoBtn:ClosePopup()
			else
				self._currentInfoBtn:OpenTooltip()
			end
		end
	end)
end

function HomeCampStationSettingCtrl:refreshConsoleBarState()
	local currentFocusedUContent = pg.global.navMgr.CurrentFocusedUContent
	local needInfo = false

	self._currentInfoBtn = nil

	if currentFocusedUContent and currentFocusedUContent.gameObject.name == "BtnSwitch" then
		local listButton = currentFocusedUContent.transform.parent:GetComponent("UButton")

		if self.firstListPass and listButton then
			local data = self.firstListPass:GetData(listButton)

			if data and data.tipsText ~= nil then
				needInfo = true

				local objRef = listButton:GetComponent("ObjectReference")

				self._currentInfoBtn = objRef and objRef:GetRefValue("btnInfoUButton") or nil
			end
		end
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeCampStationSetting_Info", needInfo)
end

function HomeCampStationSettingCtrl:onConfirmDissolveOrLeave()
	if self.isManager then
		pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOMECAR_DISBANDMENT_STATION_TIP"), function()
			self:onDissolveCamp()
		end)
	else
		pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOMECAR_LEAVE_STATION_TIP"), function()
			self:onLeaveCamp()
		end)
	end
end

function HomeCampStationSettingCtrl:onLeaveCamp()
	local campId = pg.me.curCampStaticId

	pg.me:changeCamp(campId, 0, function()
		self:close()

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_HOME_STATION_MANAGE) then
			pg.global.ui.homeStationManage:close()
		end
	end)
end

function HomeCampStationSettingCtrl:onDissolveCamp()
	pg.me:sendDissolvePrivateMessage(function()
		self:close()

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_HOME_STATION_MANAGE) then
			pg.global.ui.homeStationManage:close()
		end

		if pg.global.ui.homeCampMoveLoading then
			pg.global.ui.homeCampMoveLoading:open()
		end
	end)
end

function HomeCampStationSettingCtrl:getStationInfo()
	local staticId = pg.me.curCampStaticId

	if not staticId or staticId == 0 then
		return false
	end

	local campInfo = pg.me:getPlayerHomeCampInfo()
	local campLineInfo = campInfo.lineInfo or {}

	return campLineInfo.ownerUid == pg.me.uid, campLineInfo.isPrivate, campLineInfo.permissions
end

function HomeCampStationSettingCtrl:renderSettingInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	local settingList = data.settingList or {}

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

function HomeCampStationSettingCtrl:renderSelectorInfo(button, index, data)
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
				selectorUSelector:ClosePopup()
			end
		end

		uList:SetList(data.listInfo)
	end

	selectorUSelector:SetOptions(data.listInfo)

	local selectIndex = 0

	selectorUSelector.selectedIndex = math.max(0, math.min(selectIndex, #data.listInfo - 1))

	ClientTextUtils.setText(txtChoosNameUSDFText, data.listInfo[selectorUSelector.selectedIndex + 1].name)
end

function HomeCampStationSettingCtrl:renderSwitchButtonInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local txtButtonUSDFText = objectReference:GetRefValue("txtButtonUSDFText")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	local selectMode = bit.band(self.permissions or 0, data.mode) ~= 0

	btnSwitchUButton.isSelected = selectMode

	ClientTextUtils.setText(txtButtonUSDFText, btnSwitchUButton.isSelected and pg.getGameString("ON") or pg.getGameString("OFF"))

	function btnSwitchUButton.luaClick()
		if not self.isManager then
			return
		end

		local oldPerms = self.permissions or 0
		local newPerms

		if bit.band(oldPerms, data.mode) ~= 0 then
			newPerms = bit.band(oldPerms, bit.bnot(data.mode))
		else
			newPerms = bit.bor(oldPerms, data.mode)
		end

		pg.me:sendSetLinePermissionMessage(newPerms, function()
			self.permissions = newPerms
			btnSwitchUButton.isSelected = not btnSwitchUButton.isSelected

			ClientTextUtils.setText(txtButtonUSDFText, btnSwitchUButton.isSelected and pg.getGameString("ON") or pg.getGameString("OFF"))
		end)
	end

	btnSwitchUButton.interactable = self.isManager == true

	if data.tipsText then
		btnInfoUButton:SetActive(true)

		btnInfoUButton.enabledTooltip = true

		LuaUIUtils.bindCommonTipInfo(btnInfoUButton, data.tipsText)
	else
		btnInfoUButton:SetActive(false)

		btnInfoUButton.enabledTooltip = false
		btnInfoUButton.luaRenderTooltip = nil
	end
end

function HomeCampStationSettingCtrl:initSettingList()
	local settingList = {}
	local postStationPermissions = {}

	table.insert(postStationPermissions, {
		tIndex = 1,
		title = pg.getGameString("HOMECAR_ALLOW_MEMBER_INVITE"),
		mode = HomeCampConst.PERM_ALLOW_MEMBER_INVITE
	})
	table.insert(postStationPermissions, {
		tIndex = 1,
		title = pg.getGameString("HOMECAR_ALLOW_STRANGER_JOIN"),
		mode = HomeCampConst.PERM_ALLOW_RANDOM_JOIN,
		tipsText = pg.getGameString("HOMECAR_ALLOW_JOIN_TIPS")
	})
	table.insert(settingList, {
		tIndex = 0,
		title = pg.getGameString("HOMECAR_STATION_PERMISSION"),
		settingList = postStationPermissions
	})
	self.view.listUList:SetList(settingList)
	self.view.btnConfirmUButton:SetActive(self.isPrivate)

	if self.isManager then
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMECAR_DISBANDMENT_STATION"))
	else
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMECAR_LEAVE_STATION"))
	end
end

function HomeCampStationSettingCtrl:onDestroy()
	if self.focusFirstTimer then
		TimerManager.removeTimer(self.focusFirstTimer)

		self.focusFirstTimer = nil
	end

	self.firstListPass = nil

	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("HomeCampStationSetting")
	end

	UICtrl.onDestroy(self)
end

function HomeCampStationSettingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if self.focusFirstTimer then
		TimerManager.removeTimer(self.focusFirstTimer)

		self.focusFirstTimer = nil
	end

	self.focusFirstTimer = TimerManager.addNextFrameCb(function()
		self.focusFirstTimer = nil

		self:focusFirstSettingItem()
	end)
end

function HomeCampStationSettingCtrl:focusFirstSettingItem()
	local res, groupBtn = self.view.listUList:TryGetChildAt(0)

	if not res or not groupBtn or IsNil(groupBtn) then
		return
	end

	local groupRef = groupBtn:GetComponent("ObjectReference")

	if not groupRef then
		return
	end

	local innerList = groupRef:GetRefValue("listUList")

	if not innerList or IsNil(innerList) then
		return
	end

	local _res, firstItem = innerList:TryGetChildAt(0)

	if not _res or not firstItem or IsNil(firstItem) then
		return
	end

	local navManager = CS.XGUI.Navigation.NavManager.Instance

	if navManager and navManager.FocusItem then
		navManager:FocusItem(firstItem)
	end
end

function HomeCampStationSettingCtrl:onShow()
	return
end

function HomeCampStationSettingCtrl:onHide()
	return
end

return HomeCampStationSettingCtrl
