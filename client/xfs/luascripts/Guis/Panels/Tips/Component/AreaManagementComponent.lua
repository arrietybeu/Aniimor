-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\AreaManagementComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local ToastRecycleController = require("Guis.Panels.Tips.ToastRecycleController")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AreaManagementComponent")
local AreaManagementComponent = Class.LightClass("AreaManagementComponent", UIComponent)

function AreaManagementComponent:onCtor(info)
	self.areas = {}
	self.areaList = {}
	self.recycleController = ToastRecycleController()
end

function AreaManagementComponent:findObjects()
	self.oc = self.view.objectReference
end

function AreaManagementComponent:initView()
	function self.startOpenFunc()
		self:onUIVisibleChanged()
	end

	function self.closeFunc()
		self:onClosePanel()
	end

	pg.global.ui:addQuitFullScreenCallback(self.closeFunc)
	pg.global.ui:addStartOpenCallback(self.startOpenFunc)

	self.tickTimer = self:startTimer(function()
		self:onUpdate()
	end, TipAreaConst.TICK_INTERVAL, true)
end

function AreaManagementComponent:refreshAreaUIHideState(areaType, area, hideAreas, forceHideTip, needFullScreenHide)
	local panelHide = forceHideTip or hideAreas[areaType] == true
	local fullScreenHide = needFullScreenHide and TipAreaConst.FULL_SCREEN_HIDE_AREA[areaType] == true

	if fullScreenHide then
		area:onAddHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen)
	end

	if panelHide then
		area:onAddHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_PanelHide)
	end

	if not panelHide then
		area:onRemoveHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_PanelHide)
	end

	if not fullScreenHide then
		area:onRemoveHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen)
	end

	if panelHide or fullScreenHide and not area.visible then
		area:onUIVisibleToHide()
	end
end

function AreaManagementComponent:onUIVisibleChanged(hideAreas, forceHideTip, needFullScreenHide)
	if hideAreas == nil then
		hideAreas, forceHideTip, needFullScreenHide = pg.global.ui:getHideTipAreas()
	end

	hideAreas = hideAreas or {}

	for areaType, area in pairs(self.areas) do
		self:refreshAreaUIHideState(areaType, area, hideAreas, forceHideTip, needFullScreenHide)
	end

	local waitingHideAreas = pg.global.ui:hasWaitingShowFullPanel()

	for areaType, area in pairs(self.areas) do
		if waitingHideAreas[areaType] then
			area:setWaitingShowState(true)
		else
			area:setWaitingShowState(false)
		end
	end
end

function AreaManagementComponent:onStartOpenLoadingUI(uid)
	local ret = pg.global.ui:getHideTipByUID(uid)
	local hideAreas = ret.tips or {}

	for areaType, area in pairs(self.areas) do
		self:refreshAreaUIHideState(areaType, area, hideAreas, ret.force, ret.fullScreen)
	end
end

function AreaManagementComponent:onUpdate()
	self.recycleController:update(Time.realSecondCache)

	if #self.areaList == 0 then
		return
	end

	for _, v in ipairs(self.areaList) do
		v:refreshRecycleRunState()
		v:update()
	end
end

function AreaManagementComponent:onClosePanel()
	for _, area in pairs(self.areas) do
		area:closePanel()
	end
end

function AreaManagementComponent:tryGetAreaWithType(areaType)
	local area = self.areas[areaType]

	if area then
		return area
	end

	local cData = TipAreaConst.AREAS_CONFIG[areaType]

	if cData == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [initAreaWithType] args areaType config is nil", areaType)
		end

		return nil
	end

	local model = require("Guis.Panels.Tips.Areas." .. areaType)
	local resKey = TipAreaConst.AREAS_CONFIG[areaType].resKey
	local params = {
		owner = self,
		type = areaType,
		oc = self.oc:GetRefValue(resKey),
		priority = cData.priority or 1
	}

	area = model.new(params)
	self.areas[areaType] = area

	local insertIndex = -1

	for i, v in ipairs(self.areaList) do
		if area.priority >= v.priority then
			insertIndex = i

			break
		end
	end

	if insertIndex < 0 then
		insertIndex = #self.areaList + 1
	end

	table.insert(self.areaList, insertIndex, area)
	self:onUIVisibleChanged()

	return area
end

function AreaManagementComponent:getAreaWithType(areaType)
	return self.areas[areaType]
end

function AreaManagementComponent:recycleAreaWithType(areaType)
	local area = self.areas[areaType]

	if area == nil then
		return
	end

	if area and area.destroy then
		area:destroy()
	end

	self.areas[areaType] = nil

	for i, v in ipairs(self.areaList) do
		if v.areaType == areaType then
			table.remove(self.areaList, i)

			break
		end
	end
end

function AreaManagementComponent:onDestroy()
	self.recycleController:destroy()

	if self.tickTimer then
		self:killTimer(self.tickTimer)
	end

	self.tickTimer = nil

	pg.global.ui:removeStartOpenCallback(self.startOpenFunc)
	pg.global.ui:removeQuitFullScreenCallback(self.closeFunc)

	for _, area in ipairs(self.areaList) do
		if area and area.destroy then
			area:destroy()
		end
	end

	table.clear(self.areas)
	table.clearArray(self.areaList)
	self:clearGMData()
	UIComponent.onDestroy(self)
end

function AreaManagementComponent:pushData2Area(data)
	if string.isNilOrEmpty(data.areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [pushData2Area] args data.areaType is nil", inspect(data))
		end

		return
	end

	local area = self:tryGetAreaWithType(data.areaType)

	if area == nil then
		return
	end

	area:pushData2Item(data)
end

function AreaManagementComponent:postPushData2Area(params)
	if string.isNilOrEmpty(params.areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [postPushData2Area] args data.areaType is nil", inspect(params))
		end

		return
	end

	local area = self:tryGetAreaWithType(params.areaType)

	if area == nil then
		return
	end

	area:postPushData2Item(params)
end

function AreaManagementComponent:hideAreaItemById(areaType, itemKey, id)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [hideAreaItemById] args areaType is %s", areaType)
		end

		return
	end

	local area = self:getAreaWithType(areaType)

	if area == nil then
		return
	end

	area:hideItemById(itemKey, id)
end

function AreaManagementComponent:hideAreaItem(areaType, itemKey)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [hideAreaItem] args areaType is %s", areaType)
		end

		return
	end

	local area = self:getAreaWithType(areaType)

	if area == nil then
		return
	end

	area:hideItem(itemKey)
end

function AreaManagementComponent:refreshAreaItem(areaType, itemKey, ...)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [refreshAreaItem] args areaType is %s", areaType)
		end

		return
	end

	local area = self:getAreaWithType(areaType)

	if area == nil then
		return
	end

	area:refreshItem(itemKey, ...)
end

function AreaManagementComponent:getAreaItem(areaType, itemKey)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [getAreaItem] args areaType is %s", areaType)
		end

		return nil
	end

	local area = self:tryGetAreaWithType(areaType)

	if area == nil then
		return nil
	end

	return area:tryGetItem(itemKey)
end

function AreaManagementComponent:hasAreaItem(areaType, itemKey)
	if string.isNilOrEmpty(areaType) then
		return false
	end

	local area = self.areas[areaType]

	if area == nil then
		return false
	end

	return area:checkHasItem(itemKey)
end

function AreaManagementComponent:hideAreaWithFlag(flag, ignoreAreas)
	for _, area in pairs(self.areas) do
		if ignoreAreas == nil or not table.contains(ignoreAreas, area.areaType) then
			area:onAddHideFlag(flag)
		end
	end
end

function AreaManagementComponent:showAreaWithFlag(flag)
	for _, area in pairs(self.areas) do
		area:onRemoveHideFlag(flag)
	end
end

function AreaManagementComponent:setAreaVisibleWithFlag(areaType, flag, visible)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [setAreaVisibleWithFlag] args areaType is %s", areaType)
		end

		return
	end

	local area = self:tryGetAreaWithType(areaType)

	if area == nil then
		return
	end

	if visible then
		area:onRemoveHideFlag(flag)
	else
		area:onAddHideFlag(flag)
	end
end

function AreaManagementComponent:setAreaItemDelayTime(areaType, itemKey, delayTime)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [setAreaItemDelayTime] args areaType is %s", areaType)
		end

		return
	end

	local area = self:tryGetAreaWithType(areaType)

	if area == nil then
		return
	end

	area:setItemDelayTime(itemKey, delayTime)
end

function AreaManagementComponent:clearAllTips()
	for _, v in pairs(self.areas) do
		v:clearItems()
	end
end

function AreaManagementComponent:clearAreaRunItems(areaType)
	if string.isNilOrEmpty(areaType) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [clearAreaRunItems] args areaType is %s", areaType)
		end

		return
	end

	local area = self:getAreaWithType(areaType)

	if area == nil then
		return
	end

	area:clearRunItems()
end

function AreaManagementComponent:onInputDeviceChanged(deviceType)
	for _, area in pairs(self.areas) do
		for _, item in pairs(area.items) do
			item:onInputDeviceChanged(deviceType)
		end
	end
end

function AreaManagementComponent:onSceneUnload()
	for _, area in pairs(self.areas) do
		for _, item in pairs(area.items) do
			item:onSceneUnload()
		end
	end
end

function AreaManagementComponent:parseGMTasks(dataList)
	if self.gmQueue == nil then
		self.gmQueue = {}
	end

	for _, v in ipairs(dataList) do
		v.gmReadyTime = Time.realSecondCache + (v.delay or 0)
		self.gmQueue[#self.gmQueue + 1] = v
	end

	if self.gmTimer then
		return
	end

	self.gmTimer = self:startTimer(function()
		for i = #self.gmQueue, 1, -1 do
			local item = self.gmQueue[i]

			if item.duration ~= nil and item.duration <= 0 then
				item.duration = nil
			end

			if Time.realSecondCache >= item.gmReadyTime then
				local cData = TipAreaConst.AREA_ITEMS[item.areaType] or {}
				local iData = cData[item.itemKey]

				if iData then
					local testData = iData.testParam or {}

					table.merge(item, testData)

					item.delay = nil
					item.gmReadyTime = nil
					item.GMMode = true

					self:pushData2Area(item)
				end

				table.remove(self.gmQueue, i)
			end
		end

		if #self.gmQueue <= 0 and self.gmTimer then
			self:killTimer(self.gmTimer)

			self.gmTimer = nil
		end
	end, 0.02, true)
end

function AreaManagementComponent:hideTips()
	self:clearGMData()
	self:clearAllTips()
end

function AreaManagementComponent:clearGMData()
	if self.gmTimer then
		self:killTimer(self.gmTimer)
	end

	self.gmTimer = nil
	self.gmQueue = nil
end

function AreaManagementComponent:setAreaItemVisibleWithFlag(areaType, itemKey, flag, visible)
	if string.isNilOrEmpty(areaType) or string.isNilOrEmpty(itemKey) then
		return
	end

	local area = self:tryGetAreaWithType(areaType)

	if area == nil then
		return
	end

	local item = area:tryGetItem(itemKey)

	if item == nil then
		return
	end

	item:setAreaHideFlag(flag, not visible)
end

return AreaManagementComponent
