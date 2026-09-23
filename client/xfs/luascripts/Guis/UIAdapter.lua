-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\UIAdapter.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local HotKeyConst = require("Const.HotkeyConst")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local TInsert = table.insert
local logger = LoggerManager.getLogger("UIAdapter")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local SafeCallback = require("Core.Framework.SafeCallback")
local TimerManager = require("Core.Timer.TimerManager")
local AudioConst = require("Const.AudioConst")
local AccessControl = require("Core.Framework.AccessControl")
local SysConfigData = require("Data.sys_config_data")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local UIAdapter = Class.OldLightClass("UIAdapter", nil, true)

function UIAdapter:ctor()
	self.tag = "UIAdapter"
	self.msgMap = {}
	self.msg2ctrl2index = {}
	self.msgComponentMap = {}
	self.uiMgr = pg.global.uiMgr
	self.fixedBottomPanelList = {}
	self.normalPanelList = {}
	self.fixedTopPanelList = {}
	self.normalSecondPanelList = {}
	self.ui3DList = {}
	self.fullSceneState = false
	self.moduleToPanelId = {}
	self.orderList = {}
	self.ctrlDict = {}
	self.modelNotFoundSet = {}
	self.startOpenCallback = {}
	self.openFullScreenCallback = {}
	self.quitFullScreenCallback = {}
	self.textLinkPanelOpening = false
	self.uiHideConfig = self.uiHideConfig or {}
	self.restoreUITimer = {}
	self.visibleChangedUI = {}
	self.modelCtrlId = 0
	self.tipsUID = 4

	local metaTable = getmetatable(self)
	local oldIndexMap = metaTable.__index

	function metaTable.__index(t, key)
		if oldIndexMap then
			local v = oldIndexMap[key]

			if v ~= nil then
				return v
			end
		end

		local uid = self.moduleToPanelId[key]

		if uid then
			return self:__innerRequireCtrl(uid)
		end

		return nil
	end

	setmetatable(self, metaTable)

	self.tempWhiteListForVisible = {}
	self.waitLoadingUI = {}
	self.pendingDestroyUI = {}
	self.hideTipAreas = {}
	self.waitFullHideTipAreas = {}
	self.curUIOpenCount = 0
	self.lastCallUnloadUnusedFuncTime = 0
	self._uiSceneCameraTransitionCount = 0
	self.safeAreaMinHorizontalInset = -1
	self.safeAreaMinHorizontalInsetRefreshCount = 0
end

function UIAdapter:getSafeAreaMinHorizontalInsetConfig()
	return tonumber(SysConfigData.safe_area_mobile) or -1
end

function UIAdapter:checkSafeAreaMinHorizontalInsetEnabled(screenWidth, screenHeight)
	if not self.uiMgr:CheckIsMobileInteract() then
		return false
	end

	if not self.uiMgr:GetSafeAreaAdjustEnabled() then
		return false
	end

	if screenWidth <= 0 or screenHeight <= 0 then
		return false
	end

	if screenWidth <= screenHeight then
		return false
	end

	return screenWidth / screenHeight >= UIConst.SAFE_AREA_MIN_INSET_SCREEN_RATIO - UIConst.SAFE_AREA_MIN_INSET_SCREEN_RATIO_TOLERANCE
end

function UIAdapter:refreshSafeAreaMinHorizontalInset()
	local screen = CS.UnityEngine.Screen

	if CS.UnityEngine.Application.isEditor then
		screen = CS.UnityEngine.Device.Screen
	end

	local safeArea = screen.safeArea
	local screenWidth = screen.width
	local screenHeight = screen.height
	local screenOrientation = screen.orientation
	local configInset = self:getSafeAreaMinHorizontalInsetConfig()

	if configInset >= 0 and (screenWidth <= 0 or screenHeight <= 0 or screenWidth <= screenHeight) then
		return
	end

	local minInset = -1

	if configInset >= 0 and self:checkSafeAreaMinHorizontalInsetEnabled(screenWidth, screenHeight) then
		minInset = configInset
	end

	local screenStateChanged = self.lastSafeAreaScreenWidth ~= screenWidth or self.lastSafeAreaScreenHeight ~= screenHeight or self.lastSafeAreaX ~= safeArea.x or self.lastSafeAreaY ~= safeArea.y or self.lastSafeAreaWidth ~= safeArea.width or self.lastSafeAreaHeight ~= safeArea.height or self.lastSafeAreaOrientation ~= screenOrientation
	local forceRefresh = self.safeAreaMinHorizontalInsetRefreshCount > 0

	if self.safeAreaMinHorizontalInset == minInset and not screenStateChanged and not forceRefresh then
		return
	end

	if forceRefresh then
		self.safeAreaMinHorizontalInsetRefreshCount = self.safeAreaMinHorizontalInsetRefreshCount - 1
	end

	if screenStateChanged then
		self.safeAreaMinHorizontalInsetRefreshCount = math.max(self.safeAreaMinHorizontalInsetRefreshCount, UIConst.SAFE_AREA_MIN_INSET_SCREEN_CHANGE_REFRESH_COUNT)
	end

	self.safeAreaMinHorizontalInset = minInset
	self.lastSafeAreaScreenWidth = screenWidth
	self.lastSafeAreaScreenHeight = screenHeight
	self.lastSafeAreaX = safeArea.x
	self.lastSafeAreaY = safeArea.y
	self.lastSafeAreaWidth = safeArea.width
	self.lastSafeAreaHeight = safeArea.height
	self.lastSafeAreaOrientation = screenOrientation

	self.uiMgr:SetSafeAreaAdjustEnable(self.uiMgr:GetSafeAreaAdjustEnabled())

	if configInset < 0 then
		self:stopSafeAreaMinHorizontalInsetTimer()
	end
end

function UIAdapter:stopSafeAreaMinHorizontalInsetTimer()
	if self.safeAreaMinHorizontalInsetTimer then
		TimerManager.removeTimer(self.safeAreaMinHorizontalInsetTimer)

		self.safeAreaMinHorizontalInsetTimer = nil
	end
end

function UIAdapter:initSafeAreaMinHorizontalInset()
	self:stopSafeAreaMinHorizontalInsetTimer()

	self.safeAreaMinHorizontalInsetRefreshCount = UIConst.SAFE_AREA_MIN_INSET_STARTUP_REFRESH_COUNT

	self:refreshSafeAreaMinHorizontalInset()

	if self:getSafeAreaMinHorizontalInsetConfig() < 0 then
		return
	end

	self.safeAreaMinHorizontalInsetTimer = TimerManager.addRepeatTimer(UIConst.SAFE_AREA_MIN_INSET_CHECK_INTERVAL, function()
		self:refreshSafeAreaMinHorizontalInset()
	end)
end

function UIAdapter:init()
	self:initSafeAreaMinHorizontalInset()
	self:onInitAdapterPlatform()
	self:initConfigTable()

	UIConst.UI_CONFIGS[UIConst.UI_ID_HUD_V2].syncLoad = not pg.global.sdkManager:isDouyinCloudChannel()

	self:initModuleToPanelIdMap()
	self:refreshTextLinkHotkeyContext()
	self:registerOnInit()
	self:openPermanentPanels()
	self:initCustomRichText()
end

function UIAdapter:onInitAdapterPlatform()
	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self.__runPlatform = UIConst.PLATFORM.Mobile
	elseif pg.global.ui.uiMgr:CheckIsConsoleInteract() then
		self.__runPlatform = UIConst.PLATFORM.Console
	else
		self.__runPlatform = UIConst.PLATFORM.Standalone
	end
end

function UIAdapter:runPlatformByMobile()
	if ClientConfigInputPlatform == "Mobile" then
		return true
	end

	return self.__runPlatform == UIConst.PLATFORM.Mobile
end

function UIAdapter:runPlatformByConsole()
	if ClientConfigInputPlatform == "Console" then
		return true
	end

	return self.__runPlatform == UIConst.PLATFORM.Console
end

function UIAdapter:runPlatformByPC()
	if ClientConfigInputPlatform == "Standalone" then
		return true
	end

	return self.__runPlatform == UIConst.PLATFORM.Standalone
end

function UIAdapter:initConfigTable()
	local PanelConstData = require("Data.ui_panel_const_data")

	for id, v in pairs(PanelConstData) do
		local additionConfig = UIConst.UI_CONFIGS[id]
		local viewData = Utils.deepCopyTable(v)

		if additionConfig then
			for cKey, cValue in pairs(additionConfig) do
				viewData[cKey] = cValue
			end
		end

		UIConst.UI_CONFIGS[id] = viewData
	end

	package.loaded["Data.ui_panel_const_data"] = nil

	for id, uiConfig in pairs(UIConst.UI_CONFIGS) do
		if uiConfig.timeStop == 1 and not table.contains(UIConst.StopGameTimeUI, id) then
			table.insert(UIConst.StopGameTimeUI, id)
		end
	end
end

function UIAdapter:initCustomRichText()
	local LuaUIUtils = require("Utils.LuaUIUtils")

	function CS.FunPlus.WorldX.I18N.LocalizationText.getCustomRichTextData(strArray)
		return LuaUIUtils.getCustomRichTextData(strArray)
	end
end

function UIAdapter:refreshTextLinkHotkeyContext()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	if self.textLinkPanelOpening then
		navMgr:UpdateTextLinkHotkeyContext(nil, true, nil)

		return
	end

	local topUid = self:getTopFirstPanel()
	local topCtrl = topUid and self:tryGetCtrlByUid(topUid) or nil
	local uiConfig = topUid and UIConst.UI_CONFIGS[topUid] or nil
	local widget = topCtrl and topCtrl.view and topCtrl.view.widget or nil

	if not topUid or not topCtrl or not uiConfig or uiConfig.disableTextLinkHotkey or IsNil(widget) or IsNil(widget.transform) then
		navMgr:UpdateTextLinkHotkeyContext(nil, true, nil)

		return
	end

	local ownerUid = topUid
	local ownerCtrl = topCtrl

	navMgr:UpdateTextLinkHotkeyContext(widget.transform, false, function()
		self:onTextLinkHotkeyClick(ownerUid, ownerCtrl)
	end)
end

function UIAdapter:onTextLinkHotkeyClick(ownerUid, ownerCtrl)
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	if self.textLinkPanelOpening or self:getTopFirstPanel() ~= ownerUid or self:tryGetCtrlByUid(ownerUid) ~= ownerCtrl then
		navMgr:CompleteTextLinkHotkeyOpen()
		self:refreshTextLinkHotkeyContext()

		return
	end

	local snapshot = navMgr:TakeTextLinkHotkeySnapshot()
	local textList = {}

	if snapshot then
		for i = 0, snapshot.Length - 1 do
			local snapshotItem = snapshot[i]

			if snapshotItem then
				TInsert(textList, {
					text = snapshotItem:GetText(),
					snapshotItem = snapshotItem
				})
			end
		end
	end

	if #textList == 0 then
		navMgr:CompleteTextLinkHotkeyOpen()
		self:refreshTextLinkHotkeyContext()

		return
	end

	self.textLinkPanelOpening = true

	self:refreshTextLinkHotkeyContext()

	local openingFinished = false

	local function finishOpening()
		if openingFinished then
			return
		end

		openingFinished = true

		navMgr:CompleteTextLinkHotkeyOpen()

		self.textLinkPanelOpening = false

		self:refreshTextLinkHotkeyContext()
	end

	local ok = ClientUtils.tryWithLogError(function()
		local textLinkCtrl = self:__innerRequireCtrl(UIConst.UI_ID_TEXT_LINK)

		if not textLinkCtrl then
			error("Create TextLink ctrl failed")
		end

		textLinkCtrl:open({
			textList = textList
		}, nil, finishOpening)
	end)

	if not ok then
		finishOpening()
	end
end

function UIAdapter:enableVisibleWhitelistForDuration(uids)
	if self.tempWhiteListTimer then
		TimerManager.removeTimer(self.tempWhiteListTimer)

		self.tempWhiteListTimer = nil
	end

	for _, uid in pairs(uids) do
		self.tempWhiteListForVisible[uid] = true
	end

	self.tempWhiteListTimer = TimerManager.addTimer(3, function()
		self.tempWhiteListForVisible = {}
	end)
end

function UIAdapter:openPermanentPanels()
	for uid, config in pairs(UIConst.UI_CONFIGS) do
		if config.isPermanent then
			self:open(uid)
		end
	end
end

function UIAdapter:registerOnInit()
	for uid, config in pairs(UIConst.UI_CONFIGS) do
		if config.initRegister then
			self:register(uid)
		end
	end
end

function UIAdapter:initModuleToPanelIdMap()
	for id, cfg in pairs(UIConst.UI_CONFIGS) do
		if cfg.module then
			self.moduleToPanelId[cfg.module] = id
		end
	end
end

function UIAdapter:getPanelIdByModule(module)
	return self.moduleToPanelId[module]
end

function UIAdapter:__innerRequireCtrl(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid]

	if uiConfig then
		local ctrl = self.ctrlDict[uiConfig.module]

		ctrl = ctrl or self:register(uid)

		return ctrl
	end

	return nil
end

function UIAdapter:register(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid]

	if not uiConfig then
		return nil
	end

	if self.ctrlDict[uid] then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn(self.tag, "Duplicate uid ", uid)
		end

		return self.ctrlDict[uid]
	end

	local module = uiConfig.module
	local ctrlClz = self:genModuleClass(uid, module, "Ctrl")
	local ctrl = ctrlClz and ctrlClz.new() or nil

	if ctrl then
		ClientUtils.tryWithLogError(function()
			ctrl:initCtrl(uiConfig, uid, self)
		end)

		self.ctrlDict[module] = ctrl

		self:registerMessages(ctrl, false)
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(self.tag, "Create UI ctrl failed", uid, tostring(ctrlClz))
		end

		self.ctrlDict[module] = {}
	end

	return ctrl
end

function UIAdapter:changeUIScene(uid, res)
	local uiShopCfg = UIConst.UI_CONFIGS[uid]

	if not uiShopCfg then
		return
	end

	if self.ctrlDict[uiShopCfg.module] then
		self.ctrlDict[uiShopCfg.module]._uiSceneRes = res
	else
		uiShopCfg.uiSceneResId = res
	end
end

function UIAdapter:onMessage(index, body)
	local msgListInfo = self.msgMap[index] or {
		0,
		{}
	}

	if msgListInfo[1] > 0 then
		for _, ctrlInfo in ipairs(msgListInfo[2]) do
			if ctrlInfo[1] then
				local ctrl = ctrlInfo[2]
				local funcName = ctrl.messages[index][1]
				local fg = ctrl.messages[index][2]
				local isCmd = ctrl.messages[index][3] or false

				if ctrl.view and fg or not fg then
					local func = ctrl[funcName]

					if func then
						if isCmd then
							SafeCallback(func, ctrl, index, body)
						else
							SafeCallback(func, ctrl, body)
						end
					elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string.format("No func [%s] for msg [%s] ", funcName, index))
					end
				elseif LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn(string.format("No view [%s] with func[%s] for msg [%s]", ctrl.module, funcName, index))
				end
			end
		end
	end

	if self.msgComponentMap[index] then
		for component, _ in pairs(self.msgComponentMap[index]) do
			local funcName = component.messages[index][1]
			local func = component[funcName]

			if func then
				SafeCallback(func, component, body)
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error(string.format("No func [%s] for msg [%s] ", funcName, index))
			end
		end
	end
end

function UIAdapter:tryGetCtrlByUid(uid)
	if not uid then
		return nil
	end

	local uiConfig = UIConst.UI_CONFIGS[uid]

	if uiConfig then
		return self.ctrlDict[uiConfig.module]
	end

	return nil
end

function UIAdapter:getLastNormalFirstPanel()
	for i = #self.normalPanelList, 1, -1 do
		local uid = self.normalPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) then
			return uid
		end
	end

	return nil
end

function UIAdapter:getLastNormalSecondPanel()
	for i = #self.normalSecondPanelList, 1, -1 do
		local uid = self.normalSecondPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) then
			return uid
		end
	end

	return nil
end

function UIAdapter:getTopFirstPanel()
	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) then
			return uid
		end
	end

	for i = #self.normalSecondPanelList, 1, -1 do
		local uid = self.normalSecondPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) then
			return uid
		end
	end

	for i = #self.normalPanelList, 1, -1 do
		local uid = self.normalPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) then
			return uid
		end
	end

	for i = #self.fixedBottomPanelList, 1, -1 do
		local uid = self.fixedBottomPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) then
			return uid
		end
	end

	return false
end

function UIAdapter:checkShowCursor()
	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			return not self:checkUILockCursor(uid), self:checkUIShowVirtualMouseCursor(uid)
		end
	end

	for i = #self.normalSecondPanelList, 1, -1 do
		local uid = self.normalSecondPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			return not self:checkUILockCursor(uid), self:checkUIShowVirtualMouseCursor(uid)
		end
	end

	for i = #self.normalPanelList, 1, -1 do
		local uid = self.normalPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			return not self:checkUILockCursor(uid), self:checkUIShowVirtualMouseCursor(uid)
		end
	end

	for i = #self.fixedBottomPanelList, 1, -1 do
		local uid = self.fixedBottomPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			return not self:checkUILockCursor(uid), self:checkUIShowVirtualMouseCursor(uid)
		end
	end

	return false, false
end

function UIAdapter:checkPlayBGM()
	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			local bgm = self:getUIPlayBgm(uid)

			if bgm then
				return bgm
			end
		end
	end

	for i = #self.normalSecondPanelList, 1, -1 do
		local uid = self.normalSecondPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			local bgm = self:getUIPlayBgm(uid)

			if bgm then
				return bgm
			end
		end
	end

	for i = #self.normalPanelList, 1, -1 do
		local uid = self.normalPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			local bgm = self:getUIPlayBgm(uid)

			if bgm then
				return bgm
			end
		end
	end

	for i = #self.fixedBottomPanelList, 1, -1 do
		local uid = self.fixedBottomPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIVisible(uid) then
			local bgm = self:getUIPlayBgm(uid)

			if bgm then
				return bgm
			end
		end
	end

	return nil
end

function UIAdapter:getTopFirstModelPanel()
	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) and self:checkUIModel(uid) then
			return uid
		end
	end

	for i = #self.normalSecondPanelList, 1, -1 do
		local uid = self.normalSecondPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) and self:checkUIModel(uid) then
			return uid
		end
	end

	for i = #self.normalPanelList, 1, -1 do
		local uid = self.normalPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) and self:checkUIModel(uid) then
			return uid
		end
	end

	for i = #self.fixedBottomPanelList, 1, -1 do
		local uid = self.fixedBottomPanelList[i]

		if not self:checkUIIgnore(uid) and self:checkUIShow(uid) and self:checkUIModel(uid) then
			return uid
		end
	end

	return nil
end

function UIAdapter:containPanel(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}
	local uiType = uiConfig.uiType

	if uiType == UIConst.PANEL_LAYER then
		for _, value in ipairs(self.normalPanelList) do
			if value == uid then
				return true
			end
		end
	elseif uiType == UIConst.POPUP_LAYER then
		for _, value in ipairs(self.normalSecondPanelList) do
			if value == uid then
				return true
			end
		end
	elseif uiType == UIConst.SCENE_LAYER then
		for _, value in ipairs(self.fixedBottomPanelList) do
			if value == uid then
				return true
			end
		end
	elseif uiType == UIConst.INFOS_LAYER then
		for _, value in ipairs(self.fixedTopPanelList) do
			if value == uid then
				return true
			end
		end
	elseif uiType == UIConst.TYPE_3D then
		for _, value in ipairs(self.ui3DList) do
			if value == uid then
				return true
			end
		end
	end

	return false
end

function UIAdapter:openingUINumWithLayer(uiType)
	if uiType == UIConst.INFOS_LAYER then
		return #self.fixedTopPanelList
	end

	if uiType == UIConst.PANEL_LAYER then
		return #self.normalPanelList
	end

	if uiType == UIConst.POPUP_LAYER then
		return #self.normalSecondPanelList
	end

	if uiType == UIConst.SCENE_LAYER then
		return #self.fixedBottomPanelList
	end

	if uiType == UIConst.TYPE_3D then
		return #self.ui3DList
	end

	return 0
end

function UIAdapter:addNormalList(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid]
	local uiType = uiConfig.uiType
	local changed = self:removeNormalList(uid)

	if uiType == UIConst.PANEL_LAYER then
		self.normalPanelList[#self.normalPanelList + 1] = uid
		changed = true
	elseif uiType == UIConst.POPUP_LAYER then
		self.normalSecondPanelList[#self.normalSecondPanelList + 1] = uid
		changed = true
	end

	if changed then
		if uiType == UIConst.PANEL_LAYER then
			for i, ctrlUid in ipairs(self.normalPanelList) do
				local ctrl = self:tryGetCtrlByUid(ctrlUid)

				if ctrl then
					ctrl:setOrderWidget(i)
				end
			end
		elseif uiType == UIConst.POPUP_LAYER then
			for i, ctrlUid in ipairs(self.normalSecondPanelList) do
				local ctrl = self:tryGetCtrlByUid(ctrlUid)

				if ctrl then
					ctrl:setOrderWidget(i)
				end
			end
		end
	end

	return changed
end

function UIAdapter:removeNormalList(uid)
	local panelList = {}
	local targetPanelList
	local uiConfig = UIConst.UI_CONFIGS[uid]
	local uiType = uiConfig.uiType
	local changed = false

	if uiType == UIConst.PANEL_LAYER then
		targetPanelList = self.normalPanelList
	elseif uiType == UIConst.POPUP_LAYER then
		targetPanelList = self.normalSecondPanelList
	end

	for idx, value in ipairs(targetPanelList) do
		if value ~= uid then
			panelList[#panelList + 1] = value
		else
			changed = true
		end
	end

	if uiType == UIConst.PANEL_LAYER then
		self.normalPanelList = panelList
	elseif uiType == UIConst.POPUP_LAYER then
		self.normalSecondPanelList = panelList
	end

	if changed then
		if uiType == UIConst.PANEL_LAYER then
			for i, ctrlUid in ipairs(self.normalPanelList) do
				local ctrl = self:tryGetCtrlByUid(ctrlUid)

				if ctrl then
					ctrl:setOrderWidget(i)
				end
			end
		elseif uiType == UIConst.POPUP_LAYER then
			for i, ctrlUid in ipairs(self.normalSecondPanelList) do
				local ctrl = self:tryGetCtrlByUid(ctrlUid)

				if ctrl then
					ctrl:setOrderWidget(i)
				end
			end
		end
	end

	return changed
end

function UIAdapter:addFixedList(uid)
	if self:containPanel(uid) then
		return false
	end

	local uiConfig = UIConst.UI_CONFIGS[uid]
	local uiType = uiConfig.uiType
	local orderWidget = uiConfig.orderWidget or 0
	local targetPanelList

	if uiType == UIConst.SCENE_LAYER then
		targetPanelList = self.fixedBottomPanelList
	elseif uiType == UIConst.INFOS_LAYER then
		targetPanelList = self.fixedTopPanelList
	else
		return false
	end

	local insertIdx = #targetPanelList + 1

	for idx, value in ipairs(targetPanelList) do
		local targetWeight = UIConst.UI_CONFIGS[value].orderWidget or 0

		if orderWidget < targetWeight then
			insertIdx = idx

			break
		end
	end

	table.insert(targetPanelList, insertIdx, uid)

	return true
end

function UIAdapter:removeFixedList(uid)
	local targetPanelList
	local uiConfig = UIConst.UI_CONFIGS[uid]
	local uiType = uiConfig.uiType
	local changed = false

	if uiType == UIConst.SCENE_LAYER then
		targetPanelList = self.fixedBottomPanelList
	elseif uiType == UIConst.INFOS_LAYER then
		targetPanelList = self.fixedTopPanelList
	end

	local panelList = {}

	for idx, value in ipairs(targetPanelList) do
		if value ~= uid then
			panelList[#panelList + 1] = value
			changed = true
		end
	end

	if uiType == UIConst.SCENE_LAYER then
		self.fixedBottomPanelList = panelList
	elseif uiType == UIConst.INFOS_LAYER then
		self.fixedTopPanelList = panelList
	end

	return changed
end

function UIAdapter:add3DList(uid)
	if self:containPanel(uid) then
		return false
	end

	self.ui3DList[#self.ui3DList + 1] = uid

	return true
end

function UIAdapter:remove3DList(uid)
	local panelList = {}
	local changed = false

	for idx, value in pairs(self.ui3DList) do
		if value ~= uid then
			panelList[#panelList + 1] = value
			changed = true
		end
	end

	self.ui3DList = panelList

	return changed
end

function UIAdapter:getPanelDepth(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}
	local panelList = {}
	local uiType = uiConfig.uiType

	if uiType == UIConst.POPUP_LAYER then
		panelList = self.normalSecondPanelList
	elseif uiType == UIConst.PANEL_LAYER then
		panelList = self.normalPanelList
	elseif uiType == UIConst.INFOS_LAYER then
		panelList = self.fixedTopPanelList
	elseif uiType == UIConst.SCENE_LAYER then
		panelList = self.fixedBottomPanelList
	end

	local depth = 0

	for _, panelId in ipairs(panelList) do
		if panelId == uid then
			return depth
		end

		local ctrl = self:tryGetCtrlByUid(panelId)

		if ctrl.view then
			depth = depth + 1
		end
	end

	return 0
end

function UIAdapter:addPanel(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}
	local uiType = uiConfig.uiType or UIConst.PANEL_LAYER

	if uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER then
		return self:addNormalList(uid)
	elseif uiType == UIConst.SCENE_LAYER or uiType == UIConst.INFOS_LAYER then
		return self:addFixedList(uid)
	elseif uiType == UIConst.TYPE_3D then
		return self:add3DList(uid)
	end
end

function UIAdapter:removePanel(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}
	local uiType = uiConfig.uiType or UIConst.PANEL_LAYER

	if uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER then
		return self:removeNormalList(uid)
	elseif uiType == UIConst.SCENE_LAYER or uiType == UIConst.INFOS_LAYER then
		return self:removeFixedList(uid)
	elseif uiType == UIConst.TYPE_3D then
		return self:remove3DList(uid)
	end
end

function UIAdapter:markUIOpenState(uid, opened)
	if opened then
		self.waitLoadingUI[uid] = nil

		self:tryUnloadUnusedAssets(uid)
	else
		self.waitLoadingUI[uid] = true

		self:doStartOpenCallback()
	end
end

function UIAdapter:open(uid, info, cb, closeCb, sceneParams)
	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:open(info, cb, closeCb, sceneParams)
	end
end

function UIAdapter:openWithHide(uid)
	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:open()
		ctrl:hide()
	end
end

function UIAdapter:close(uid, force)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}

	if not force and uiConfig.isPermanent then
		return
	end

	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:close()
	end
end

function UIAdapter:closePanel(uid, force)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}

	if not force and uiConfig.isPermanent then
		return
	end

	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:closePanel()
	end
end

function UIAdapter:closeImmediately(uid, force)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}

	if not force and uiConfig.isPermanent then
		return
	end

	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:closeImmediately()
	end
end

function UIAdapter:show(uid)
	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:show()
	end
end

function UIAdapter:hide(uid)
	local ctrl = self:__innerRequireCtrl(uid)

	if ctrl then
		ctrl:hide()
	end
end

function UIAdapter:onUIAdd(uid, ctrl)
	if self:addPanel(uid) then
		facade:SendMessageCommand(MessageName.UI_ON_OPEN, uid)
		self:markModelWidgetChanged()
		self:refreshTextLinkHotkeyContext()

		return true
	end

	return false
end

function UIAdapter:onUIRemove(uid, ctrl)
	if self:removePanel(uid) then
		self:markModelWidgetChanged()
		facade:SendMessageCommand(MessageName.UI_ON_CLOSE, uid)
		self:tryFadeInHud()
		self:refreshTextLinkHotkeyContext()

		return true
	end

	return false
end

function UIAdapter:onUICreate(uid, ctrl)
	self:registerMessages(ctrl, true)
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:onUIOpen(uid, ctrl)
	self:adjustPanelDepth(uid)
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:tryFadeOutHud()
	if self.funcMenu:checkUIVisible() then
		local cameraMode = pg.game.camera.fixedWithTargetCameraMode.cameraMode
		local cameraView = cameraMode:GetCameraView()
		local dist = cameraView:GetArmLen()
		local speed = 7
		local time = 0.25
		local targetDist = speed * time
		local inter = dist + targetDist

		if inter > 0 then
			pg.game.camera:modifyFixedWithTargetDist(inter, time, CS.DG.Tweening.Ease.__CastFrom(6), true)
			self.funcMenu:playCloseManual()
		end
	end

	if self.hudV2:checkUIVisible() then
		self.fadeHudDirty = true

		self.tips:fadeOut()

		local playerCamera = pg.game.camera.playerCameraMode
		local dist = playerCamera:getBaseCameraDistance()
		local speed = 2
		local time = 0.6
		local targetDist = speed * time
		local inter = dist - targetDist

		if inter > 0 then
			self.fadeCameraDirty = true

			pg.game.camera.playerCameraMode:blendToDistance(inter, time, CS.DG.Tweening.Ease.__CastFrom(7))
		end
	end
end

function UIAdapter:tryFadeInHud()
	if self.hudV2:checkUIVisible() and self.fadeHudDirty then
		self.fadeHudDirty = false

		self.tips:fadeIn()

		if self.fadeCameraDirty then
			self.fadeCameraDirty = false

			pg.game.camera.playerCameraMode:blendOut(0.2)
		end
	end
end

function UIAdapter:tryFadeInHud_Camera()
	if self.hudV2:checkUIVisible() and self.fadeCameraDirty then
		self.fadeCameraDirty = false

		pg.game.camera.playerCameraMode:blendOut(0.2)
	end
end

function UIAdapter:blackFadeIn(duration, skipIfFading)
	if skipIfFading and self.blackChange.showingBlack then
		return
	end

	self.blackChange:blackChangeIn(duration)
end

function UIAdapter:blackFadeOut(duration, skipIfFading)
	if self._uiSceneBlackCount and self._uiSceneBlackCount > 0 and duration == 0 then
		return
	end

	if skipIfFading and self.blackChange.showingBlack then
		return
	end

	self.blackChange:blackChangeOut(duration)
end

function UIAdapter:showBlackBackground(owner, duration)
	return self.blackBg:showBackground(owner, duration)
end

function UIAdapter:hideBlackBackground(owner)
	self.blackBg:hideBackground(owner)
end

function UIAdapter:beginUISceneCameraTransition()
	self._uiSceneCameraTransitionCount = (self._uiSceneCameraTransitionCount or 0) + 1

	if self._uiSceneCameraTransitionCount == 1 and pg.game and pg.game.camera then
		pg.game.camera:setWorldCameraEnable(false, ClientConst.CameraDisableReason.UISceneTransition)
	end
end

function UIAdapter:endUISceneCameraTransition()
	if not self._uiSceneCameraTransitionCount or self._uiSceneCameraTransitionCount <= 0 then
		return
	end

	self._uiSceneCameraTransitionCount = self._uiSceneCameraTransitionCount - 1

	if self._uiSceneCameraTransitionCount == 0 and pg.game and pg.game.camera then
		pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.UISceneTransition)
	end
end

function UIAdapter:resetTeardownVisualState()
	self._uiSceneCameraTransitionCount = 0
	self._uiSceneBlackCount = 0

	if self.disableCameraTimer then
		TimerManager.delFrameCb(self.disableCameraTimer)

		self.disableCameraTimer = nil
	end

	self.enableCamera = true

	if pg.game and pg.game.camera then
		pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.UI)
		pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.UISceneTransition)
	end

	self.blackChange:blackChangeOut(0)
end

function UIAdapter:beginUISceneBlack()
	self._uiSceneBlackCount = (self._uiSceneBlackCount or 0) + 1
end

function UIAdapter:endUISceneBlack(duration)
	self._uiSceneBlackCount = (self._uiSceneBlackCount or 0) - 1

	if self._uiSceneBlackCount < 0 then
		self._uiSceneBlackCount = 0
	end

	self.blackChange:blackChangeOut(duration)
end

function UIAdapter:onUIClose(uid, ctrl)
	self:unRegisterMessages(ctrl, true)
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:enableMainCamera(enabled)
	if self.enableCamera ~= enabled then
		self.enableCamera = enabled

		if enabled then
			pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.UI)

			if self.disableCameraTimer then
				TimerManager.delFrameCb(self.disableCameraTimer)

				self.disableCameraTimer = nil
			end
		else
			self.disableCameraTimer = TimerManager.addSpecificFrameCb(2, false, function()
				pg.game.camera:setWorldCameraEnable(false, ClientConst.CameraDisableReason.UI)

				self.disableCameraTimer = nil
			end)
		end
	end
end

function UIAdapter:onUIShow(uid, ctrl)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}
	local uiType = uiConfig.uiType or UIConst.PANEL_LAYER
	local forceHideOtherUI = uiConfig.forceHideOtherUI or false

	if uiType == UIConst.PANEL_LAYER or forceHideOtherUI then
		self:refreshBgmState()
		self:refreshUIVisible(uid, forceHideOtherUI)
	end

	self:checkResetInput(uid, ctrl)
	facade:SendMessageCommand(MessageName.UI_ON_SHOW, uid)
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:onUIHide(uid, ctrl)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}
	local uiType = uiConfig.uiType or UIConst.PANEL_LAYER
	local forceHideOtherUI = uiConfig.forceHideOtherUI or false

	if uiType == UIConst.PANEL_LAYER or forceHideOtherUI then
		self:refreshBgmState()
		self:refreshUIVisible(uid)
		self:tryFadeInHud()
	end

	facade:SendMessageCommand(MessageName.UI_ON_HIDE, uid)
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:onUIVisibleChange(uid, ctrl, visible)
	self.visibleChangedUI[uid] = visible

	self:markVisibleChangeDelayRefresh()
	self:markModelWidgetChanged()
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:markVisibleChangeDelayRefresh()
	if self.delayVisibleChangeRefreshTimer then
		return
	end

	self.delayVisibleChangeRefreshTimer = TimerManager.addNextFrameCb(function()
		for i, v in pairs(self.visibleChangedUI) do
			facade:SendMessageCommand(MessageName.UI_ON_VISIBLE_CHANGE, {
				uid = i,
				visible = v
			})
		end

		self:_visibleChangeDelayRefresh()
	end)
end

function UIAdapter:_visibleChangeDelayRefresh()
	self.delayVisibleChangeRefreshTimer = nil

	if not Utils.tableIsEmptyOrNil(self.visibleChangedUI) then
		self.visibleChangedUI = {}

		self:refreshLockCursor()
		self:refreshUIBgm()
		self:refreshFullScreenVisibleState()
	end
end

function UIAdapter:checkResetInput(uid, ctrl)
	if ctrl:getIsModel() and uid == self:getTopFirstModelPanel() then
		local excludeActions = ctrl:getExcludeResetInputActions()

		pg.game.input:resetAllActions(excludeActions)
	end
end

function UIAdapter:onIsModelChanged()
	self:markModelWidgetChanged()
	self:refreshLockCursor()
end

function UIAdapter:markModelWidgetChanged()
	self.refreshModelWidgetFlag = true
end

function UIAdapter:tryRefreshModelWidget()
	if self.refreshModelWidgetFlag then
		self.refreshModelWidgetFlag = false

		self:refreshModelWidget()
	end
end

function UIAdapter:refreshLockCursor()
	local showCursor = self:checkShowCursor()

	pg.game.input:setLockCursor(ClientConst.LockCursorKey.UI, not showCursor)
end

function UIAdapter:refreshUIBgm()
	local bgm = self:checkPlayBGM()

	pg.game.audio:playBgm(bgm, AudioConst.BgmPriority.UI)
end

function UIAdapter:refreshBgmState()
	local topUid = self:getLastNormalFirstPanel()
	local setAttenuation = false

	if topUid then
		local topFirstCtrl = self:tryGetCtrlByUid(topUid)

		if topFirstCtrl and not topFirstCtrl.uiConfig.fullScreenKeepBgm and not topFirstCtrl:checkSkipBgmAttenuation() then
			setAttenuation = true
		end
	end

	if setAttenuation then
		pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.BGM_VOLUME_STATE_ID_ATTENUATION, self:getClassType())
	else
		pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.BGM_VOLUME_STATE_ID_NORMAL, self:getClassType())
	end
end

function UIAdapter:adjustPanelDepth(uid)
	local uiConfig = UIConst.UI_CONFIGS[uid] or {}

	if uiConfig.uiType == UIConst.TYPE_3D then
		return
	end

	local ctrl = self.ctrlDict[uiConfig.module]

	if ctrl and ctrl.view then
		if uiConfig.uiType == UIConst.SCENE_LAYER then
			pg.global.uiMgr:RefreshFixedBottomUIDepth()
		elseif uiConfig.uiType == UIConst.INFOS_LAYER then
			pg.global.uiMgr:RefreshFixedTopUIDepth()
		elseif uiConfig.uiType == UIConst.PANEL_LAYER then
			pg.global.uiMgr:RefreshPanelUIDepth()
		elseif uiConfig.uiType == UIConst.POPUP_LAYER then
			pg.global.uiMgr:RefreshPopupUIDepth()
		end

		self:onUIDepthChange()
	end
end

function UIAdapter:onUIDepthChange()
	pg.game.input:onUIDepthChange()
	self:refreshTextLinkHotkeyContext()
end

function UIAdapter:checkUIOpen(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkUIOpen()
end

function UIAdapter:checkGameTimeStopActive(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkGameTimeStopActive()
end

function UIAdapter:collectGameTimeStopDebugInfo(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	if not ctrl then
		return nil
	end

	return ctrl:collectGameTimeStopDebugInfo()
end

function UIAdapter:checkUIVisible(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkUIVisible()
end

function UIAdapter:checkUIShow(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkUIShow()
end

function UIAdapter:checkUIIgnore(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkUIIgnore()
end

function UIAdapter:checkUILockCursor(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkUILockCursor()
end

function UIAdapter:checkUIShowVirtualMouseCursor(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:checkUIShowVirtualMouseCursor()
end

function UIAdapter:getUIPlayBgm(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl.uiConfig.bgm
end

function UIAdapter:checkUIModel(uid)
	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl and ctrl:getIsModel()
end

function UIAdapter:getFullScreenVisibleState()
	for i = #self.normalSecondPanelList, 1, -1 do
		local uid = self.normalSecondPanelList[i]

		if (UIConst.UI_CONFIGS[uid] or EMPTY_TABLE).fullScreen and self:checkUIVisible(uid) then
			return true, uid
		end
	end

	for i = #self.normalPanelList, 1, -1 do
		local uid = self.normalPanelList[i]

		if (UIConst.UI_CONFIGS[uid] or EMPTY_TABLE).fullScreen and self:checkUIVisible(uid) then
			return true, uid
		end
	end

	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]

		if (UIConst.UI_CONFIGS[uid] or EMPTY_TABLE).fullScreen and self:checkUIVisible(uid) then
			return true, uid
		end
	end

	return false
end

function UIAdapter:getModalPanelShowState(checkUID)
	for _, uid in ipairs(self.fixedTopPanelList) do
		local cfg = UIConst.UI_CONFIGS[uid]

		if cfg and (cfg.fullScreen or cfg.MutexDisplay) and self:checkUIShow(uid) then
			return true, uid
		end
	end

	for _, uid in ipairs(self.normalSecondPanelList) do
		local cfg = UIConst.UI_CONFIGS[uid]

		if cfg and (cfg.fullScreen or cfg.MutexDisplay) and self:checkUIShow(uid) then
			return true, uid
		end
	end

	for _, uid in ipairs(self.normalPanelList) do
		local topFirstCtrl = self:tryGetCtrlByUid(uid)
		local whiteList = topFirstCtrl:getWhiteList()

		if self:checkUIShow(uid) and (not checkUID or not whiteList[checkUID]) then
			return true, uid
		end
	end

	for _, uid in pairs(UIConst.TipMutBlackList) do
		if self:checkUIShow(uid) then
			return true, uid
		end
	end

	return false, nil
end

function UIAdapter:getHideTipAreas(ignoreUID)
	local hideTipAreas = ignoreUID and {} or self.hideTipAreas

	table.clear(hideTipAreas)

	local needFullScreenHide = false

	for _, uid in ipairs(self.normalSecondPanelList) do
		if uid ~= ignoreUID and self:checkUIVisible(uid) then
			local cfg = UIConst.UI_CONFIGS[uid]

			if cfg.forceHideTips == true then
				return TipAreaConst.FULL_SCREEN_HIDE_AREA, true, false
			end

			if cfg.fullScreen or cfg.MutexDisplay then
				needFullScreenHide = true
			end

			if cfg.hideTipAreas then
				for _, v in ipairs(cfg.hideTipAreas) do
					hideTipAreas[v] = true
				end
			end
		end
	end

	for _, uid in ipairs(self.normalPanelList) do
		if uid ~= ignoreUID and self:checkUIVisible(uid) then
			local cfg = UIConst.UI_CONFIGS[uid]

			if cfg.forceHideTips == true then
				return TipAreaConst.FULL_SCREEN_HIDE_AREA, true, false
			end

			if cfg.forceShowTips then
				if cfg.hideTipAreas then
					for _, v in ipairs(cfg.hideTipAreas) do
						hideTipAreas[v] = true
					end
				end
			else
				needFullScreenHide = true
			end
		end
	end

	for _, uid in ipairs(self.fixedTopPanelList) do
		if uid ~= ignoreUID and self:checkUIVisible(uid) then
			local cfg = UIConst.UI_CONFIGS[uid]

			if cfg.forceHideTips == true then
				return TipAreaConst.FULL_SCREEN_HIDE_AREA, true, false
			end

			if cfg.fullScreen or cfg.MutexDisplay then
				needFullScreenHide = true
			end

			if cfg.hideTipAreas then
				for _, v in ipairs(cfg.hideTipAreas) do
					hideTipAreas[v] = true
				end
			end
		end
	end

	for _, uid in ipairs(self.fixedBottomPanelList) do
		if uid ~= ignoreUID and self:checkUIVisible(uid) then
			local cfg = UIConst.UI_CONFIGS[uid]

			if cfg.hideTipAreas then
				for _, v in ipairs(cfg.hideTipAreas) do
					hideTipAreas[v] = true
				end
			end
		end
	end

	for uid, _ in pairs(self.pendingDestroyUI) do
		local cfg = UIConst.UI_CONFIGS[uid]

		if uid ~= ignoreUID and cfg then
			if cfg.forceHideTips == true then
				return TipAreaConst.FULL_SCREEN_HIDE_AREA, true, false
			end

			if cfg.hideTipAreas then
				for _, v in ipairs(cfg.hideTipAreas) do
					hideTipAreas[v] = true
				end
			end

			if not cfg.forceShowTips and (cfg.fullScreen or cfg.MutexDisplay) then
				needFullScreenHide = true
			end
		end
	end

	for _, uid in pairs(UIConst.TipMutBlackList) do
		if uid ~= ignoreUID and self:checkUIVisible(uid) then
			needFullScreenHide = true

			break
		end
	end

	return hideTipAreas, false, needFullScreenHide
end

function UIAdapter._mergeFullScreenHideAreas(hideTipAreas)
	for area, hide in pairs(TipAreaConst.FULL_SCREEN_HIDE_AREA) do
		if hide then
			hideTipAreas[area] = true
		end
	end
end

function UIAdapter:getHideTipByUID(uid)
	self.tempLoadingHideTips = self.tempLoadingHideTips or {}

	if self.tempLoadingHideTips[uid] then
		return self.tempLoadingHideTips[uid]
	end

	local ret = {}
	local needFullScreenHide = false
	local cfg = UIConst.UI_CONFIGS[uid]

	if cfg.forceHideTips == true then
		self.tempLoadingHideTips[uid] = {
			fullScreen = false,
			force = true,
			tips = TipAreaConst.FULL_SCREEN_HIDE_AREA
		}

		return self.tempLoadingHideTips[uid]
	end

	if cfg.fullScreen or cfg.MutexDisplay then
		needFullScreenHide = true
	end

	if cfg.hideTipAreas then
		for _, v in ipairs(cfg.hideTipAreas) do
			ret[v] = true
		end
	end

	self.tempLoadingHideTips[uid] = {
		force = false,
		tips = ret,
		fullScreen = needFullScreenHide
	}

	return self.tempLoadingHideTips[uid]
end

function UIAdapter:hasWaitingShowFullPanel()
	table.clear(self.waitFullHideTipAreas)

	local needFullScreenHide = false

	for uid, _ in pairs(self.waitLoadingUI) do
		local cfg = UIConst.UI_CONFIGS[uid]

		if cfg.fullScreen or cfg.MutexDisplay then
			needFullScreenHide = true
		end

		if cfg.hideTipAreas then
			for _, v in ipairs(cfg.hideTipAreas) do
				self.waitFullHideTipAreas[v] = true
			end
		end
	end

	if needFullScreenHide then
		UIAdapter._mergeFullScreenHideAreas(self.waitFullHideTipAreas)
	end

	return self.waitFullHideTipAreas
end

function UIAdapter:checkHasWaitingShowFullPanel()
	for uid, _ in pairs(self.waitLoadingUI) do
		local cfg = UIConst.UI_CONFIGS[uid]

		if not cfg.ignoreWaitHideTips and (cfg.fullScreen or cfg.MutexDisplay) then
			return true
		end
	end

	return false
end

function UIAdapter:markUIPendingDestroy(uid)
	if uid == nil then
		return
	end

	self.pendingDestroyUI[uid] = true
end

function UIAdapter:clearUIPendingDestroy(uid)
	if uid == nil or self.pendingDestroyUI[uid] == nil then
		return
	end

	self.pendingDestroyUI[uid] = nil

	if self:checkUIOpen(self.tipsUID) then
		self.tips:onUIVisibleChanged()
	end
end

function UIAdapter:checkHasPendingDestroyFullPanel()
	for uid, _ in pairs(self.pendingDestroyUI) do
		local cfg = UIConst.UI_CONFIGS[uid]

		if cfg and not cfg.forceShowTips and (cfg.forceHideTips or cfg.fullScreen or cfg.MutexDisplay) then
			return true
		end
	end

	return false
end

function UIAdapter:checkPanelVisible(uiId)
	for _, whiteList in pairs(self.uiHideConfig) do
		if not whiteList[uiId] then
			return false
		end
	end

	return true
end

function UIAdapter:refreshFullScreenVisibleState()
	local visibleState, fullscreenUID = self:getFullScreenVisibleState()

	if visibleState ~= self.fullSceneVisible then
		self.fullSceneVisible = visibleState

		if visibleState then
			self:onFullScreenVisible()
		else
			self:onFullScreenInvisible()
		end
	end

	if self.fullscreenUID ~= fullscreenUID then
		self.fullscreenUID = fullscreenUID

		self:onFullScreenUIDChanged()
	end

	self:refreshFullScreenAudioState(fullscreenUID)
end

function UIAdapter:isFullScreenVisible()
	return self.fullSceneVisible
end

function UIAdapter:addQuitFullScreenCallback(func)
	table.insert(self.quitFullScreenCallback, func)
end

function UIAdapter:removeQuitFullScreenCallback(func)
	local index = -1

	for i, v in ipairs(self.quitFullScreenCallback) do
		if v == func then
			index = i

			break
		end
	end

	if index < 0 then
		return
	end

	table.remove(self.quitFullScreenCallback, index)
end

function UIAdapter:doQuitFullScreenCallback()
	for _, func in ipairs(self.quitFullScreenCallback) do
		ClientUtils.tryWithLogError(func)
	end

	self.quitFullScreenCallback = {}
end

function UIAdapter:onFullScreenVisible()
	self:doOpenFullScreenCallback()
end

function UIAdapter:onFullScreenInvisible()
	self:doQuitFullScreenCallback()
end

function UIAdapter:onFullScreenUIDChanged()
	local enableMainCamera = true

	if self.fullscreenUID then
		local cfg = UIConst.UI_CONFIGS[self.fullscreenUID]

		if not cfg.enableMainCamera then
			enableMainCamera = false
		end
	end

	self:enableMainCamera(enableMainCamera)
end

function UIAdapter:refreshFullScreenAudioState(fullscreenUID)
	if fullscreenUID then
		local ctrl = self:tryGetCtrlByUid(fullscreenUID)

		if ctrl.uiConfig.fullScreen and not ctrl.uiConfig.fullScreenKeepAudio and not ctrl:checkSkipMenuAttenuation() then
			pg.game.audio:setAttenGroupState(AudioConst.AttenGroupStateReason.UI, true)
		else
			pg.game.audio:setAttenGroupState(AudioConst.AttenGroupStateReason.UI, false)
		end
	else
		pg.game.audio:setAttenGroupState(AudioConst.AttenGroupStateReason.UI, false)
	end
end

function UIAdapter:addOpenFullScreenCallback(func)
	table.insert(self.openFullScreenCallback, func)
end

function UIAdapter:removeOpenFullScreenCallback(func)
	local index = -1

	for i, v in ipairs(self.openFullScreenCallback) do
		if v == func then
			index = i

			break
		end
	end

	if index < 0 then
		return
	end

	table.remove(self.openFullScreenCallback, index)
end

function UIAdapter:doOpenFullScreenCallback()
	for _, func in ipairs(self.openFullScreenCallback) do
		ClientUtils.tryWithLogError(func)
	end
end

function UIAdapter:addStartOpenCallback(func)
	table.insert(self.startOpenCallback, func)
end

function UIAdapter:removeStartOpenCallback(func)
	local index = -1

	for i, v in ipairs(self.startOpenCallback) do
		if v == func then
			index = i

			break
		end
	end

	if index < 0 then
		return
	end

	table.remove(self.startOpenCallback, index)
end

function UIAdapter:doStartOpenCallback()
	for _, func in ipairs(self.startOpenCallback) do
		ClientUtils.tryWithLogError(func)
	end
end

function UIAdapter:getModulePath(uid, mName, typeKey)
	local prefix = UIConst.UI_MODULE_PREFIX_PARSER[uid] or UIConst.UI_PATH_PRE
	local upperName = mName:gsub("^%l", string.upper)

	return string.format("%s%s.%s%s", prefix, upperName, upperName, typeKey)
end

function UIAdapter:genModuleClass(uid, mName, typeKey)
	local path = self:getModulePath(uid, mName, typeKey)
	local module = require(path)

	if module then
		return module
	else
		return nil
	end
end

function UIAdapter:genModelClass(uid, mName)
	local path = self:getModulePath(uid, mName, "Model")

	if self.modelNotFoundSet[path] then
		return nil
	end

	local ok, ret = pcall(require, path)

	if ok then
		return ret
	end

	if string.find(tostring(ret), string.format("module '%s' not found", path), 1, true) then
		self.modelNotFoundSet[path] = true

		return nil
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(self.tag, "load model failed, module:", mName, "err:", ret)
	end

	return nil
end

function UIAdapter:registerComponentMessages(component)
	if not component then
		return
	end

	local messages = component.messages or {}

	for name, _ in pairs(messages) do
		local comps = self.msgComponentMap[name] or {}

		if comps[component] then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error(string.format("repeat register component: %s to msg: %s", component.className, name))
			end
		else
			comps[component] = true
		end

		self.msgComponentMap[name] = comps

		facade:RegisterUIComponentCommand(name)
	end
end

function UIAdapter:unRegisterComponentMessages(component)
	if not component then
		return
	end

	local messages = component.messages or {}

	for name, _ in pairs(messages) do
		local comps = self.msgComponentMap[name] or {}

		comps[component] = nil
		self.msgComponentMap[name] = comps

		if Utils.tableIsEmptyOrNil(comps) then
			facade:RemoveUIComponentCommand(name)
		end
	end
end

function UIAdapter:registerMessages(ctrl, isOpen)
	if ctrl == nil then
		return
	end

	if isOpen then
		ctrl.activeMessagesRegisted = true
	end

	local messages = ctrl.messages or {}

	for name, msgInfo in pairs(messages) do
		local _, needOpen = unpack(msgInfo)

		if needOpen == isOpen then
			local msgListInfo = self.msgMap[name] or {
				0,
				{}
			}
			local list = msgListInfo[2]
			local ctrlMap = self.msg2ctrl2index[name] or {}

			if ctrlMap[ctrl] == nil then
				ctrlMap[ctrl] = #list + 1
				list[#list + 1] = {
					true,
					ctrl
				}
				msgListInfo[1] = msgListInfo[1] + 1
			else
				local index = ctrlMap[ctrl]

				if list[index][1] == true then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string.format("repeat register ctrl: %s to msg: %s", ctrl.module, name))
					end
				else
					list[index][1] = true
					msgListInfo[1] = msgListInfo[1] + 1
				end
			end

			self.msg2ctrl2index[name] = ctrlMap
			msgListInfo[2] = list
			self.msgMap[name] = msgListInfo

			if msgListInfo[1] > 0 then
				facade:RegisterUICommand(name)
			end
		end
	end
end

function UIAdapter:clearAllRegisterMessages()
	for name, msgListInfo in pairs(self.msgMap) do
		msgListInfo[1] = 0
		msgListInfo[2] = {}
		self.msg2ctrl2index[name] = {}

		facade:RemoveUICommand(name)
	end
end

function UIAdapter:unRegisterMessages(ctrl, isOpen)
	if ctrl == nil then
		return
	end

	if isOpen then
		ctrl.activeMessagesRegisted = nil
	end

	local messages = ctrl.messages or {}

	for name, msgInfo in pairs(messages) do
		local _, needOpen = unpack(msgInfo)

		if needOpen == isOpen then
			local msgListInfo = self.msgMap[name] or {
				0,
				{}
			}
			local list = msgListInfo[2]
			local ctrlMap = self.msg2ctrl2index[name] or {}

			if ctrlMap[ctrl] == nil then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error(string.format("no register msg: %s from ctrl: %s, to unregister", name, ctrl.module))
				end
			else
				local index = ctrlMap[ctrl]

				if list[index] == nil then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string.format("no register msg: %s from ctrl: %s, to unregister, error ctrlMap have ctrl", name, ctrl.module))
					end
				elseif list[index][1] ~= false then
					list[index][1] = false
					msgListInfo[1] = msgListInfo[1] - 1
				end
			end

			if msgListInfo[1] <= 0 then
				facade:RemoveUICommand(name)
			end
		end
	end
end

function UIAdapter:hideAllUIByCustomKey(key, whiteList, maxTime)
	if self:checkHideKey(key) then
		local forbidNotifyTrigger = key == UIConst.UI_HIDE_KEY.ULTIMATE

		self:setHideAllUIConfig(key, whiteList, forbidNotifyTrigger)

		if maxTime and maxTime > 0 then
			if self.restoreUITimer[key] then
				TimerManager.removeTimer(self.restoreUITimer[key])
			end

			self.restoreUITimer[key] = TimerManager.addTimer(maxTime, function()
				self.restoreUITimer[key] = nil

				self:restoreAllUIByCustomKey(key)
			end)
		end

		facade:SendMessageCommand(MessageName.ON_HIDE_ALL_UI, {
			key = key
		})
	end
end

function UIAdapter:restoreAllUIByCustomKey(key)
	if self:checkHideKey(key) then
		if self.restoreUITimer[key] then
			TimerManager.removeTimer(self.restoreUITimer[key])

			self.restoreUITimer[key] = nil
		end

		self:removeHideAllUIConfig(key)
		facade:SendMessageCommand(MessageName.ON_RESTORE_ALL_UI, {
			key = key
		})
		self:tryFadeInHud_Camera()
	end
end

function UIAdapter:hideAllUI()
	self:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.CLIENT_UTILS, {})
end

function UIAdapter:gmSetAllUIOpacity(whiteList, opacity)
	for module, ctrl in pairs(self.ctrlDict) do
		local uid = self.moduleToPanelId[module]

		if not whiteList[uid] and ctrl and ctrl.view and ctrl.view.widget then
			ctrl.view.widget.renderOpacity = opacity
		end
	end
end

function UIAdapter:restoreAllUI()
	self:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CLIENT_UTILS)
end

function UIAdapter:setGauBlurScene(uid, active)
	self.blurConfig = self.blurConfig or {}

	if active then
		self.blurConfig[uid] = true
	else
		self.blurConfig[uid] = nil
	end

	local blurActive = not Utils.tableIsEmptyOrNil(self.blurConfig)

	pg.global.uiMgr:BlurSceneForBg(blurActive)
end

function UIAdapter:checkHideKey(key)
	if key == nil or key < 100000 or key > 999999 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("不符合要求的key值：" .. key)
		end

		return false
	end

	return true
end

function UIAdapter:isUISceneVisibleBypassUIHideKey(ctrl, keyId)
	local hideKeyConfig = UIConst.UI_HIDE_KEY_CONFIGS[keyId]

	if hideKeyConfig and hideKeyConfig.keepUIScene then
		return true
	end

	local uiSceneVisibleBypassUIHideKeys = ctrl.uiConfig.uiSceneVisibleBypassUIHideKeys or EMPTY_TABLE

	return uiSceneVisibleBypassUIHideKeys[keyId] == true
end

function UIAdapter:getAdapterVisibilityState(ctrl)
	local uid = ctrl.uid

	if self.uiHideConfig[UIConst.UI_HIDE_KEY.DIALOAGUE_GRAPH] and UIConst.DIALOGUE_UI_SET[uid] then
		return UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE
	end

	local hasUISceneBypassHideKey = false

	for keyId, whiteList in pairs(self.uiHideConfig) do
		if keyId ~= uid and not whiteList[uid] then
			if not self:isUISceneVisibleBypassUIHideKey(ctrl, keyId) then
				return UIConst.UI_ADAPTER_VISIBILITY_STATE.UI_HIDE_FORCE
			end

			hasUISceneBypassHideKey = true
		end
	end

	if hasUISceneBypassHideKey then
		return UIConst.UI_ADAPTER_VISIBILITY_STATE.UI_HIDE_KEEP_UI_SCENE
	end

	if uid == UIConst.UI_ID_BLACK_BG then
		return UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE
	end

	if Utils.tableIsEmptyOrNil(self.uiHideConfig) then
		local uiConfig = UIConst.UI_CONFIGS[uid] or {}

		if uiConfig.uiType ~= UIConst.INFOS_LAYER and uiConfig.uiType ~= UIConst.POPUP_LAYER then
			local topUid = self:getLastNormalFirstPanel()
			local topFirstCtrl = self:tryGetCtrlByUid(topUid)

			if topFirstCtrl then
				local whiteList = topFirstCtrl:getWhiteList()

				if uid ~= topUid and not whiteList[uid] then
					return UIConst.UI_ADAPTER_VISIBILITY_STATE.PANEL_COVERED
				end
			end
		end
	end

	return UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE
end

function UIAdapter:setHideAllUIConfig(keyId, whiteList, forbidNotifyTrigger)
	self.uiHideConfig[keyId] = whiteList or {}

	self:refreshUIVisible(nil, nil, forbidNotifyTrigger)
end

function UIAdapter:removeHideAllUIConfig(keyId)
	if self.uiHideConfig[keyId] then
		self.uiHideConfig[keyId] = nil

		self:refreshUIVisible()
	end
end

function UIAdapter:setUIHideConfig(keyId, uiId, inWhiteList)
	if self.uiHideConfig[keyId] then
		self.uiHideConfig[keyId][uiId] = inWhiteList

		self:refreshUIVisible()
	end
end

function UIAdapter:refreshUIVisible(excludeUID, forceHideUI, forbidNotifyTrigger)
	for module, ctrl in pairs(self.ctrlDict) do
		local uid = self.moduleToPanelId[module]

		if not self.tempWhiteListForVisible[uid] and ctrl and uid ~= excludeUID then
			ctrl:refreshUIVisible(forceHideUI, forbidNotifyTrigger)
		end
	end
end

function UIAdapter:refreshModelWidget()
	local modelCtrlId
	local layer = 0
	local orderWidget = 0

	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]
		local ctrl = self:tryGetCtrlByUid(uid)

		if ctrl and ctrl:checkUseModel() then
			modelCtrlId = uid
			layer = 3
			orderWidget = ctrl:getOrderWidget()

			break
		end
	end

	if not modelCtrlId then
		for i = #self.normalSecondPanelList, 1, -1 do
			local uid = self.normalSecondPanelList[i]
			local ctrl = self:tryGetCtrlByUid(uid)

			if ctrl and ctrl:checkUseModel() then
				modelCtrlId = uid
				layer = 2
				orderWidget = ctrl:getOrderWidget()

				break
			end
		end
	end

	if not modelCtrlId then
		for i = #self.normalPanelList, 1, -1 do
			local uid = self.normalPanelList[i]
			local ctrl = self:tryGetCtrlByUid(uid)

			if ctrl and ctrl:checkUseModel() then
				modelCtrlId = uid
				layer = 1
				orderWidget = ctrl:getOrderWidget()

				break
			end
		end
	end

	if not modelCtrlId then
		for i = #self.fixedBottomPanelList, 1, -1 do
			local uid = self.fixedBottomPanelList[i]
			local ctrl = self:tryGetCtrlByUid(uid)

			if ctrl and ctrl:checkUseModel() then
				modelCtrlId = uid
				layer = 0
				orderWidget = ctrl:getOrderWidget()

				break
			end
		end
	end

	modelCtrlId = modelCtrlId or 0

	if self.modelCtrlId ~= modelCtrlId then
		self.modelCtrlId = modelCtrlId
	end

	pg.global.uiMgr:SetModelWidgetInfo(modelCtrlId, layer, orderWidget)
	self:refreshGamepadModelWidget()
	pg.game.input:refreshCursorState()
end

function UIAdapter:refreshGamepadModelWidget()
	local gamepadModelCtrlId
	local layer = 0
	local orderWidget = 0

	for i = #self.fixedTopPanelList, 1, -1 do
		local uid = self.fixedTopPanelList[i]
		local ctrl = self:tryGetCtrlByUid(uid)

		if ctrl and ctrl:checkUseGamepadModel() then
			gamepadModelCtrlId = uid
			layer = 3
			orderWidget = ctrl:getOrderWidget()

			break
		end
	end

	if not gamepadModelCtrlId then
		for i = #self.normalSecondPanelList, 1, -1 do
			local uid = self.normalSecondPanelList[i]
			local ctrl = self:tryGetCtrlByUid(uid)

			if ctrl and ctrl:checkUseGamepadModel() then
				gamepadModelCtrlId = uid
				layer = 2
				orderWidget = ctrl:getOrderWidget()

				break
			end
		end
	end

	if not gamepadModelCtrlId then
		for i = #self.normalPanelList, 1, -1 do
			local uid = self.normalPanelList[i]
			local ctrl = self:tryGetCtrlByUid(uid)

			if ctrl and ctrl:checkUseGamepadModel() then
				gamepadModelCtrlId = uid
				layer = 1
				orderWidget = ctrl:getOrderWidget()

				break
			end
		end
	end

	if not gamepadModelCtrlId then
		for i = #self.fixedBottomPanelList, 1, -1 do
			local uid = self.fixedBottomPanelList[i]
			local ctrl = self:tryGetCtrlByUid(uid)

			if ctrl and ctrl:checkUseGamepadModel() then
				gamepadModelCtrlId = uid
				layer = 0
				orderWidget = ctrl:getOrderWidget()

				break
			end
		end
	end

	gamepadModelCtrlId = gamepadModelCtrlId or 0
	self.gamepadModelCtrlId = gamepadModelCtrlId

	pg.global.uiMgr:SetGamepadModelWidgetInfo(gamepadModelCtrlId, layer, orderWidget)
end

function UIAdapter:closeAllNormalPanel(whiteList)
	local panelList = {
		unpack(self.normalPanelList)
	}

	for idx, pId in pairs(panelList) do
		if not whiteList or whiteList[pId] ~= true then
			ClientUtils.tryWithLogErrorEx(self.close, self, pId)
		end
	end

	panelList = {
		unpack(self.normalSecondPanelList)
	}

	for idx, pId in pairs(panelList) do
		if not whiteList or whiteList[pId] ~= true then
			ClientUtils.tryWithLogErrorEx(self.close, self, pId)
		end
	end
end

function UIAdapter:closeAllFixedPanel(whiteList, force, loadingForce)
	local panelList = {
		unpack(self.fixedTopPanelList)
	}

	for idx, pId in pairs(panelList) do
		if (loadingForce or pId ~= UIConst.UI_ID_LOADING) and (not whiteList or whiteList[pId] ~= true) then
			ClientUtils.tryWithLogErrorEx(self.close, self, pId, force)
		end
	end

	panelList = {
		unpack(self.fixedBottomPanelList)
	}

	for idx, pId in pairs(panelList) do
		if (loadingForce or pId ~= UIConst.UI_ID_LOADING) and (not whiteList or whiteList[pId] ~= true) then
			ClientUtils.tryWithLogErrorEx(self.close, self, pId, force)
		end
	end
end

function UIAdapter:closeAllUIPanel(whiteList, force, loadingForce)
	whiteList = whiteList or UIConst.DEFAULT_CLOSE_WHITELIST
	self.hideMeMap = nil
	self.hideMeCount = nil

	self:closeAllNormalPanel(whiteList, force)
	self:closeAllFixedPanel(whiteList, force, loadingForce)
end

function UIAdapter:refreshRegisterMessages()
	self:clearAllRegisterMessages()

	for module, cfg in pairs(self.ctrlDict) do
		local ctrl = self.ctrlDict[module]

		self:registerMessages(ctrl, false)

		if ctrl.activeMessagesRegisted then
			self:registerMessages(ctrl, true)
		end
	end
end

function UIAdapter:addMessageName(name)
	return
end

function UIAdapter:addMessageNameCarefully(name)
	return
end

function UIAdapter:tipsHideAllAreasWithFlag(flag, ignoreAreas)
	for module, ctrl in pairs(self.ctrlDict) do
		local uid = self.moduleToPanelId[module]

		if uid == self.tipsUID and ctrl then
			ctrl:hideAllAreasWithFlag(flag, ignoreAreas)
		end
	end
end

function UIAdapter:tipsShowAllAreasWithFlag(flag)
	for module, ctrl in pairs(self.ctrlDict) do
		local uid = self.moduleToPanelId[module]

		if uid == self.tipsUID and ctrl then
			ctrl:showAllAreasWithFlag(flag)
		end
	end
end

function UIAdapter:levelHideAllUI(customKey, whiteList)
	local whiteListCp = {}

	for i, id in ipairs(whiteList or EMPTY_TABLE) do
		table.insert(whiteListCp, id)
	end

	for i, id in ipairs(UIConst.LEVEL_HIDE_UI_WHITE_LIST) do
		table.insert(whiteListCp, id)
	end

	customKey = customKey or "Default"
	self.levelHideConfig = self.levelHideConfig or {}
	self.levelHideConfig[customKey] = {
		whiteList = whiteListCp
	}

	self:refreshLevelHideUI()
end

function UIAdapter:levelRestoreAllUI(customKey)
	customKey = customKey or "Default"
	self.levelHideConfig = self.levelHideConfig or {}
	self.levelHideConfig[customKey] = nil

	self:refreshLevelHideUI()
end

function UIAdapter:refreshLevelHideUI()
	if Utils.tableIsEmptyOrNil(self.levelHideConfig) then
		self:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.LEVEL)
	else
		local whiteList = {}

		for key, hideConfig in pairs(self.levelHideConfig) do
			if hideConfig.whiteList then
				for _, uid in ipairs(hideConfig.whiteList) do
					whiteList[uid] = true
				end
			end
		end

		self:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.LEVEL, whiteList)
		pg.game.input:resetAllActions()
	end
end

function UIAdapter:onInputDeviceChanged(device)
	for _, uiCtrl in pairs(self.ctrlDict) do
		if uiCtrl:checkUIOpen() then
			uiCtrl:inputDeviceChanged(device)
		end
	end

	self:refreshGamepadModelWidget()
end

function UIAdapter:closePlatformSensitivePanels()
	for _, uiCtrl in pairs(self.ctrlDict) do
		if type(uiCtrl) == "table" and uiCtrl.checkUIOpen and uiCtrl.uiConfig and uiCtrl.uiConfig.platformSensitive and uiCtrl:checkUIOpen() then
			self:closeImmediately(uiCtrl.uid, true)
		end
	end
end

function UIAdapter:createEmptyTransformHandle(key, resId)
	local handle = self.uiMgr:CreateEmptyHandle(key, resId)

	return handle
end

function UIAdapter:destroyTransformHandle(handle)
	self.uiMgr:DestroyHandle(handle)
end

function UIAdapter:onLogin()
	self:open(UIConst.UI_ID_TOPLOGO)
end

function UIAdapter:tryUnloadUnusedAssets(uid)
	if UNITY_STANDALONE then
		return
	end

	local fullScreen = false
	local cf = UIConst.UI_CONFIGS[uid]

	if cf then
		fullScreen = cf.fullScreen
	end

	local count = 0.5

	if fullScreen then
		count = 2
	end

	local maxUIOpenCountCallClearMemory = 5

	self.curUIOpenCount = self.curUIOpenCount + count

	if fullScreen and maxUIOpenCountCallClearMemory <= self.curUIOpenCount then
		self:tryCallClearMemory()
	end
end

function UIAdapter:tryCallClearMemory()
	local curTime = Time.getTickSecond()

	if curTime - self.lastCallUnloadUnusedFuncTime >= ClientConst.UI_CALL_UNLOAD_UNUSED_FUNC_MIN_SECONDS_CD then
		self:clearMemory()
	end
end

function UIAdapter:clearMemory()
	self.lastCallUnloadUnusedFuncTime = Time.getTickSecond()
	self.curUIOpenCount = 0

	ClientUtils.gcImmediately()
end

function UIAdapter:checkFadeOutHudHolder(uid, exceptUid)
	if uid == exceptUid then
		return false
	end

	local cfg = UIConst.UI_CONFIGS[uid]

	if not cfg or not cfg.fullScreen then
		return false
	end

	if cfg.uiType ~= UIConst.PANEL_LAYER then
		return false
	end

	local ctrl = self:tryGetCtrlByUid(uid)

	return ctrl ~= nil and ctrl:checkFadeOutHud()
end

function UIAdapter:checkOtherFadeOutHudHolder(exceptUid)
	for uid in pairs(self.waitLoadingUI) do
		if self:checkFadeOutHudHolder(uid, exceptUid) then
			return true
		end
	end

	for _, uid in ipairs(self.normalPanelList) do
		if self:checkFadeOutHudHolder(uid, exceptUid) then
			return true
		end
	end

	return false
end

return UIAdapter
