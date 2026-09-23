-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\BaseTipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = Class.LightClass("BaseTipArea")
local ClientUtils = require("Utils.ClientUtils")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BaseTipArea")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local RUN_STATE = TipAreaConst.ITEM_RUN_STATE
local ClearArray = table.clearArray
local ClearMap = table.clear
local CUTSCENE_FLAG = TipAreaConst.UITipAreaFlag.AreaFlag_Cutscene
local RECYCLE_INTERVAL = 60

function BaseTipArea:ctor(info)
	self.owner = info.owner
	self.areaType = info.type
	self.oc = info.oc
	self.priority = info.priority
	self.visible = true

	if NotNil(self.oc) then
		self.uWidget = self.oc.gameObject:GetComponent("UWidget")

		self.uWidget:SetActive(true)
	end

	self.dealtTime = 0
	self.lastUpdateTime = Time.realSecondCache
	self.items = {}
	self.itemDict = {}
	self.hideFlags = {}
	self.maxRunNum = TipAreaConst.AREAS_CONFIG[self.areaType].maxRunItemNum or 1
	self.curFrame = {}
	self.tmpFrame = {}
	self.preFrame = {}
	self.preCount = 0
	self.isWaitingOpenFullScreen = false
	self.__WaitRecycleTime = RECYCLE_INTERVAL
	self.__CanRecycle = true

	ClientUtils.tryWithLogError(function()
		self:onCtor(info)
		self:onInit()
	end)
end

function BaseTipArea:onCtor(info)
	return
end

function BaseTipArea:checkHasItem(itemKey)
	if string.isNilOrEmpty(itemKey) then
		return false
	end

	return self.itemDict[itemKey] ~= nil
end

function BaseTipArea:tryGetItem(itemKey)
	if string.isNilOrEmpty(itemKey) then
		return nil
	end

	local curType = self.areaType
	local item = self.itemDict[itemKey]

	if item then
		return item
	end

	local areaItems = TipAreaConst.AREA_ITEMS[curType]
	local cData = areaItems and areaItems[itemKey]

	if cData == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [BaseTipArea:tryGetItem] args itemKey config is nil", self.areaType, itemKey)
		end

		return nil
	end

	local modelPath = string.format("Guis.Panels.Tips.Items.%s.%sItem", curType, itemKey)

	if itemKey == "BossTitle" and UIConst.USE_BOSS_TITLE_V2 then
		modelPath = "Guis.Panels.Tips.Items.TopTipArea.BossTitleItemV2"
	end

	local model = require(modelPath)

	if not model then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UI [BaseTipArea:tryGetItem] no file [%s]", modelPath)
		end

		return nil
	end

	local initData = {
		view = self.owner.view,
		area = self,
		config = cData,
		itemKey = itemKey
	}

	if NotNil(self.oc) then
		initData.uWidget = self.oc:GetRefValue(cData.resKey)
	end

	item = model.new(initData)

	table.insert(self.items, item)

	self.itemDict[itemKey] = item

	if self:isCutsceneSuspended() then
		item:suspendTimeline()
	end

	self:refreshCustomAreaItemVisible(self:getCustomAreaShowFlags())
	table.sort(self.items, function(a, b)
		return a.priority > b.priority
	end)

	return item
end

function BaseTipArea:onInit()
	return
end

function BaseTipArea:update()
	local now = Time.realSecondCache

	self.dealtTime = now - self.lastUpdateTime
	self.lastUpdateTime = now

	if not self.visible then
		return
	end

	if self.__CanRecycle and self.__WaitRecycleTime <= 0 then
		self.owner:recycleAreaWithType(self.areaType)

		return
	end

	if self.isWaitingOpenFullScreen then
		return
	end

	local nextRun = self.tmpFrame

	if #nextRun > 0 then
		ClearArray(nextRun)
	end

	for _, item in ipairs(self.items) do
		if item.__delayTime > 0 and not item:isTimelineSuspended() then
			local delta = self.dealtTime

			if item.__delayStartTime then
				delta = math.min(delta, now - item.__delayStartTime)
				item.__delayStartTime = nil
			end

			item.__delayTime = math.max(0, item.__delayTime - delta)
		end

		if item.__delayTime <= 0 then
			local state = item:checkRunState()

			if state ~= RUN_STATE.EMPTY and not item:isAreaHidden() then
				if #nextRun >= self.maxRunNum then
					local replaceIdx = -1

					for i = self.maxRunNum, 1, -1 do
						local itState = nextRun[i].run_state
						local fiState = nextRun[i].fix_state

						if itState < state and fiState <= item.fix_state then
							replaceIdx = i

							break
						end
					end

					if replaceIdx > 0 then
						table.remove(nextRun, replaceIdx)

						nextRun[#nextRun + 1] = item
					end
				else
					nextRun[#nextRun + 1] = item
				end
			end
		elseif item:isAreaHidden() then
			item:checkRunState()
		end
	end

	local curCount = #nextRun

	if self.__CanRecycle then
		if curCount <= 0 then
			self.__WaitRecycleTime = self.__WaitRecycleTime - self.dealtTime
		else
			self.__WaitRecycleTime = RECYCLE_INTERVAL
		end
	end

	if self.preCount <= 0 and curCount <= 0 then
		return
	end

	if self.preCount ~= curCount then
		self:onRunStateChanged(curCount > 0)
	end

	self.preCount = curCount

	ClearMap(self.curFrame)

	for _, v in ipairs(nextRun) do
		self.curFrame[v.itemKey] = v
	end

	for _, v in ipairs(self.items) do
		if self.curFrame[v.itemKey] then
			if self.preFrame[v.itemKey] == nil then
				self.preFrame[v.itemKey] = v

				v:start()
			end

			v:update()
		else
			if v:isRunning() then
				v:clearRunningList()
			end

			if self.preFrame[v.itemKey] then
				self.preFrame[v.itemKey] = nil

				v:finished()
			end
		end
	end
end

function BaseTipArea:onRunStateChanged(isRunning)
	return
end

function BaseTipArea:refreshAreaVisible()
	self:onRefreshAreaVisible()
end

function BaseTipArea:onRefreshAreaVisible()
	local customFlags = self:getCustomAreaShowFlags()
	local isVisible = #self.hideFlags == 0 or customFlags ~= nil

	if isVisible ~= self.visible then
		self.lastUpdateTime = Time.realSecondCache

		if NotNil(self.uWidget) then
			self.uWidget:SetActive(isVisible)
		end

		self:setAreaItemVisible(isVisible)

		self.visible = isVisible

		if self.visible then
			self:onShow()
		else
			self:onHide()
		end
	end

	self:refreshCustomAreaItemVisible(customFlags)
end

function BaseTipArea:getCustomAreaShowFlags()
	if #self.hideFlags == 0 then
		return nil
	end

	local areaConfig = TipAreaConst.AREAS_CONFIG[self.areaType]
	local customAreaShow = areaConfig and areaConfig.customAreaShow

	if customAreaShow == nil then
		return nil
	end

	local customFlags = {}

	for _, flag in ipairs(self.hideFlags) do
		if self:checkCustomAreaShowFlag(customAreaShow, flag) then
			customFlags[flag] = true
		else
			return nil
		end
	end

	return customFlags
end

function BaseTipArea:checkCustomAreaShowFlag(customAreaShow, flag)
	if customAreaShow == nil then
		return false
	end

	return customAreaShow[flag] == true or table.contains(customAreaShow, flag)
end

function BaseTipArea:refreshCustomAreaItemVisible(customFlags)
	local hasCustomFlags = customFlags ~= nil

	for _, item in ipairs(self.items) do
		if hasCustomFlags then
			local itemCustomAreaShow = item.rawData and item.rawData.customAreaShow
			local itemVisible = itemCustomAreaShow ~= nil

			if itemVisible then
				for flag in pairs(customFlags) do
					if not self:checkCustomAreaShowFlag(itemCustomAreaShow, flag) then
						itemVisible = false

						break
					end
				end
			end

			item:setAreaHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_CustomAreaShow, not itemVisible)
		else
			item:setAreaHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_CustomAreaShow, false)
		end
	end
end

function BaseTipArea:setWaitingShowState(hasWaitingShow)
	if self.isWaitingOpenFullScreen ~= hasWaitingShow then
		self.lastUpdateTime = Time.realSecondCache
	end

	self.isWaitingOpenFullScreen = hasWaitingShow
end

function BaseTipArea:setItemDelayTime(itemKey, delayTime)
	if string.isNilOrEmpty(itemKey) then
		return
	end

	local item = self:tryGetItem(itemKey)

	if item == nil then
		return
	end

	item:setDelayTime(delayTime)

	item.__delayStartTime = Time.realSecondCache
end

function BaseTipArea:setAreaItemVisible(visible)
	local flags = self.hideFlags

	for _, v in ipairs(self.items) do
		v:refreshRunState()

		if v:isRunning() then
			if visible then
				v:showArea(flags)
			else
				v:hideArea(flags)
			end
		end
	end
end

function BaseTipArea:onAddHideFlag(flag)
	flag = tostring(flag)

	if string.isNilOrEmpty(flag) then
		return
	end

	if table.contains(self.hideFlags, flag) then
		return
	end

	table.insert(self.hideFlags, flag)

	if flag == CUTSCENE_FLAG then
		self:_setItemsTimelineSuspend(true)
	end

	self:refreshAreaVisible()
end

function BaseTipArea:onRemoveHideFlag(flag)
	flag = tostring(flag)

	if string.isNilOrEmpty(flag) then
		return
	end

	local removed = false

	for i, v in ipairs(self.hideFlags) do
		if v == flag then
			table.remove(self.hideFlags, i)

			removed = true

			break
		end
	end

	if removed and flag == CUTSCENE_FLAG then
		self:_setItemsTimelineSuspend(false)
	end

	self:refreshAreaVisible()
end

function BaseTipArea:isCutsceneSuspended()
	return table.contains(self.hideFlags, CUTSCENE_FLAG)
end

function BaseTipArea:_setItemsTimelineSuspend(isSuspend)
	for _, item in ipairs(self.items) do
		if isSuspend then
			item:suspendTimeline()
		else
			item:resumeTimeline()
		end
	end
end

function BaseTipArea:clearItems(ignoreKeys)
	for key, item in pairs(self.itemDict) do
		if ignoreKeys == nil or ignoreKeys[key] == nil then
			item:clearAllData(true)
		end
	end
end

function BaseTipArea:clearRunItems()
	for _, item in pairs(self.itemDict) do
		item:clearRunningList()
	end

	self.preCount = 0

	table.clear(self.curFrame)
	table.clear(self.preFrame)
	self:onRunStateChanged(false)
end

function BaseTipArea:onUIVisibleToHide()
	for _, item in pairs(self.itemDict) do
		item:onUIVisibleToHide()
	end

	self.preCount = 0

	table.clear(self.curFrame)
	table.clear(self.preFrame)
	self:onRunStateChanged(false)
end

function BaseTipArea:pushData2Item(data)
	if string.isNilOrEmpty(data.itemKey) then
		return
	end

	local item = self:tryGetItem(data.itemKey)

	if item == nil then
		return
	end

	if UNITY_EDITOR and data.GMMode then
		item:GMPushData(data)
	end

	if data.overallDelayTime and data.overallDelayTime > 0 then
		item:setDelayTime(data.overallDelayTime)

		item.__delayStartTime = Time.realSecondCache
	end

	item:pushData(data)
end

function BaseTipArea:postPushData2Item(params)
	if string.isNilOrEmpty(params.itemKey) then
		return
	end

	local item = self:tryGetItem(params.itemKey)

	if item == nil then
		return
	end

	item:postPushData(params)
end

function BaseTipArea:hideItemById(itemKey, id)
	if string.isNilOrEmpty(itemKey) then
		return
	end

	local item = self:tryGetItem(itemKey)

	if item == nil then
		return
	end

	item:hideById(id)
end

function BaseTipArea:hideItem(itemKey)
	if string.isNilOrEmpty(itemKey) then
		return
	end

	local item = self:tryGetItem(itemKey)

	if item == nil then
		return
	end

	item:hide()
end

function BaseTipArea:refreshItem(itemKey, ...)
	if string.isNilOrEmpty(itemKey) then
		return
	end

	local item = self:tryGetItem(itemKey)

	if item == nil then
		return
	end

	item:refresh(...)
end

function BaseTipArea:onHide()
	return
end

function BaseTipArea:onShow()
	return
end

function BaseTipArea:closePanel()
	return
end

function BaseTipArea:onDestroy()
	return
end

function BaseTipArea:destroy()
	self:onDestroy()

	for _, item in pairs(self.items) do
		item:destroy()
	end

	self.items = nil
	self.owner = nil
end

function BaseTipArea:refreshRecycleRunState()
	if not self.recycleStateDirty then
		return
	end

	self.recycleStateDirty = false

	local count = 0

	for key, item in pairs(self.preFrame) do
		if item.__recycleStateDirty then
			item:checkRunState()
		end

		local finished = item.__recycleStateDirty and not item:hasRecycleRunningData() and not item:isRunning()

		item.__recycleStateDirty = nil

		if finished then
			self.preFrame[key] = nil
			self.curFrame[key] = nil

			item:finished()
		else
			count = count + 1
		end
	end

	if count == 0 and self.preCount > 0 then
		self.preCount = 0

		self:onRunStateChanged(false)
	end
end

return BaseTipArea
