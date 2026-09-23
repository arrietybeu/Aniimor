-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\InteractSignUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local InteractionSignUIBase = require("GameApp.InteractionSign.UIView.InteractionSignUIBase")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local bor = bit.bor
local lshift = bit.lshift
local InteractSignUIComponent = Class.LightClass("InteractSignUIComponent", HudBaseComponent)

InteractSignUIComponent.LOGIC_TICK_INTERVAL = 0.2
InteractSignUIComponent.BLOCK_CHECK_BUDGET_PER_FRAME = 2
InteractSignUIComponent.BLOCK_SCAN_BUDGET_PER_FRAME = 16
InteractSignUIComponent.messages = {
	[MessageName.UI_ADD_INTERACTION_SIGN] = {
		"onAddInteractionSign",
		true
	},
	[MessageName.UI_REMOVE_INTERACTION_SIGN] = {
		"onRemoveInteractionSign",
		true
	},
	[MessageName.UI_ON_VISIBLE_CHANGE] = {
		"onUIVisibleChanged",
		false
	},
	[MessageName.UPDATE_INTERACT_VIEW] = {
		"onInteractViewUpdated",
		true
	}
}

function InteractSignUIComponent:findObjects()
	return
end

function InteractSignUIComponent:initView()
	self.defaultUrlPath = "$UI_Node_Hud_Interaction_Sign.prefab"
	self.unitUIs = {}
	self.unitUIsList = {}
	self.unitUIsIndexMap = {}
	self.visibleUnitUIsList = {}
	self.visibleUnitUIsIndexMap = {}
	self.activeInteractFuncIds = {}
	self.frameContext = {
		activeInteractFuncIds = self.activeInteractFuncIds,
		entityCache = {},
		distanceCache = {},
		anchorCacheByGlobalId = {}
	}
	self.blockLayerMask = bor(lshift(1, ClientConst.LayerDefine.LAYER_GROUND), lshift(1, ClientConst.LayerDefine.LAYER_WALL), lshift(1, ClientConst.LayerDefine.LAYER_DEFAULT))
	self.blockCheckCursor = 0
	self.blockRayCount = 0
	self.lastFrameBlockRayCount = 0
	self.nextLogicTickTime = 0
	self.parentVisible = self.parentVisible ~= false
	self.componentShown = self.componentShown ~= false
	self.hasFullPanel = pg.global.ui:getModalPanelShowState()
	self.signSys = pg.game.interactionSignSystem
	self._onLateUpdate = CallbackHandler(self, "onLateUpdate")

	self:refreshActiveInteractFuncIds()

	for idx, unitGroup in pairs(self.signSys.signUnitList) do
		for cfgId, unit in pairs(unitGroup) do
			self:onAddSign({
				globalId = idx,
				cfgId = cfgId,
				unitData = unit
			})
		end
	end

	self:setUpdateSuspended(self:shouldSuspendUpdate())

	self.tickTimer = pg.game.camera:addLateUpdateTimer(self._onLateUpdate)
end

function InteractSignUIComponent:onDestroy()
	if self.tickTimer then
		pg.game.camera:removeLateUpdateTimer(self.tickTimer)

		self.tickTimer = nil
	end

	if self.unitUIsList then
		for _, unitView in pairs(self.unitUIsList) do
			unitView:onLeave()
		end
	end

	self.unitUIs = nil
	self.unitUIsList = nil
	self.unitUIsIndexMap = nil
	self.visibleUnitUIsList = nil
	self.visibleUnitUIsIndexMap = nil
	self.activeInteractFuncIds = nil
	self.frameContext = nil
	self.signSys = nil
	self._onLateUpdate = nil

	HudBaseComponent.onDestroy(self)
end

function InteractSignUIComponent:refreshFrameContext()
	local frameContext = self.frameContext

	frameContext.now = Time.realSecondCache
	frameContext.pawn = pg.pawn
	frameContext.signVisible = self.signSys and self.signSys:getSignVisible() == true
end

function InteractSignUIComponent:prepareActiveFrameContext(frameContext)
	frameContext.cameraSystem = pg.game.camera
	frameContext.worldCamera = pg.global.cameraMgr.worldCameraInst
	frameContext.blockLayerMask = self.blockLayerMask
end

function InteractSignUIComponent:resetFrameCaches(frameContext)
	table.clear(frameContext.entityCache)
	table.clear(frameContext.distanceCache)

	for _, anchorCache in pairs(frameContext.anchorCacheByGlobalId) do
		table.clear(anchorCache)
	end
end

function InteractSignUIComponent:shouldSuspendUpdate(frameContext)
	local signVisible = frameContext and frameContext.signVisible

	if signVisible == nil then
		signVisible = self.signSys and self.signSys:getSignVisible() == true
	end

	local pawn

	if frameContext then
		pawn = frameContext.pawn
	else
		pawn = pg.pawn
	end

	return self.hasFullPanel or not self.parentVisible or not self.componentShown or self.signSys == nil or not signVisible or pawn == nil
end

function InteractSignUIComponent:onVisibleChange(visible)
	self.parentVisible = visible

	self:setUpdateSuspended(self:shouldSuspendUpdate())
end

function InteractSignUIComponent:onShow()
	self.componentShown = true

	self:setUpdateSuspended(self:shouldSuspendUpdate())
end

function InteractSignUIComponent:onHide()
	self.componentShown = false

	self:setUpdateSuspended(true)
end

function InteractSignUIComponent:setUpdateSuspended(suspended)
	if self.updateSuspended == suspended then
		return
	end

	self.updateSuspended = suspended

	if suspended then
		self.lastFrameBlockRayCount = 0
	end

	if self.unitUIsList then
		for _, unitView in ipairs(self.unitUIsList) do
			unitView:onVisibleChange(not suspended)
		end
	end

	if not suspended then
		self.nextLogicTickTime = 0
	end
end

function InteractSignUIComponent:onLateUpdate()
	if self.frameContext == nil then
		return
	end

	if self.hasFullPanel or not self.parentVisible or not self.componentShown then
		self:setUpdateSuspended(true)

		return
	end

	self:refreshFrameContext()
	self:setUpdateSuspended(self:shouldSuspendUpdate(self.frameContext))

	if self.updateSuspended then
		return
	end

	local frameContext = self.frameContext

	self:prepareActiveFrameContext(frameContext)
	self:resetFrameCaches(frameContext)

	if frameContext.now >= self.nextLogicTickTime then
		self.nextLogicTickTime = frameContext.now + InteractSignUIComponent.LOGIC_TICK_INTERVAL

		self:onLogicTick(frameContext)
	end

	self:processBlockChecks(frameContext)
	self:onLayoutTick(frameContext)
end

function InteractSignUIComponent:onLogicTick(frameContext)
	for _, unitView in ipairs(self.unitUIsList) do
		local ent = self:getFrameEntity(frameContext, unitView.globalId)

		unitView:onLogicTick(frameContext, ent)
	end
end

function InteractSignUIComponent:onLayoutTick(frameContext)
	for index = #self.visibleUnitUIsList, 1, -1 do
		local unitView = self.visibleUnitUIsList[index]
		local ent = self:getFrameEntity(frameContext, unitView.globalId)

		unitView:onLayoutTick(frameContext, ent)
	end
end

function InteractSignUIComponent:processBlockChecks(frameContext)
	local unitCount = #self.unitUIsList

	if unitCount == 0 then
		self.blockCheckCursor = 0
		self.lastFrameBlockRayCount = 0

		return
	end

	local rayCount = 0
	local scannedCount = 0
	local scanBudget = math.min(unitCount, InteractSignUIComponent.BLOCK_SCAN_BUDGET_PER_FRAME)

	while rayCount < InteractSignUIComponent.BLOCK_CHECK_BUDGET_PER_FRAME and scannedCount < scanBudget do
		self.blockCheckCursor = self.blockCheckCursor % unitCount + 1

		local unitView = self.unitUIsList[self.blockCheckCursor]

		if unitView:tryRefreshCameraBlock(frameContext) then
			rayCount = rayCount + 1
		end

		scannedCount = scannedCount + 1
	end

	self.lastFrameBlockRayCount = rayCount
	self.blockRayCount = self.blockRayCount + rayCount
end

function InteractSignUIComponent:getPerformanceStats()
	return {
		activeViewCount = self.unitUIsList and #self.unitUIsList or 0,
		visibleViewCount = self.visibleUnitUIsList and #self.visibleUnitUIsList or 0,
		lastFrameBlockRayCount = self.lastFrameBlockRayCount or 0,
		blockRayCount = self.blockRayCount or 0
	}
end

function InteractSignUIComponent:getFrameEntity(frameContext, globalId)
	local ent = frameContext.entityCache[globalId]

	if ent == false then
		return nil
	end

	if ent == nil then
		ent = pg.getEntityByGlobalId(globalId)
		frameContext.entityCache[globalId] = ent or false
	end

	return ent
end

function InteractSignUIComponent:getFrameTargetPos(frameContext, unitData, ent)
	if ent == nil then
		return nil
	end

	local globalId = unitData.globalId
	local anchorCache = frameContext.anchorCacheByGlobalId[globalId]

	if anchorCache == nil then
		anchorCache = {}
		frameContext.anchorCacheByGlobalId[globalId] = anchorCache
	end

	local anchorKey = unitData.anchorCacheKey
	local targetPos = anchorCache[anchorKey]

	if targetPos == false then
		return nil
	end

	if targetPos == nil then
		targetPos = unitData:getTargetPos(ent)
		anchorCache[anchorKey] = targetPos or false
	end

	return targetPos
end

function InteractSignUIComponent:getFrameEntityDistance(frameContext, unitData, ent)
	local globalId = unitData.globalId
	local distance = frameContext.distanceCache[globalId]

	if distance == false then
		return nil
	end

	if distance == nil then
		distance = unitData:getDistanceWithPlayer(ent)
		frameContext.distanceCache[globalId] = distance or false
	end

	return distance
end

function InteractSignUIComponent:refreshActiveInteractFuncIds()
	if self.activeInteractFuncIds == nil then
		return
	end

	table.clear(self.activeInteractFuncIds)

	local interactSys = pg.game.interaction

	if interactSys == nil or interactSys.currentInteractList == nil then
		return
	end

	for _, unitRootNode in ipairs(interactSys.currentInteractList) do
		for _, unit in ipairs(unitRootNode.interactUnits) do
			if unit then
				local actionId = unit.actionPrototypeId

				if actionId then
					self.activeInteractFuncIds[actionId] = true
					self.activeInteractFuncIds[actionId % 100000] = true
				end

				if actionId == InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID and unit.funcMenuId then
					self.activeInteractFuncIds[unit.funcMenuId] = true
				end
			end
		end
	end
end

function InteractSignUIComponent:setUnitViewLayoutActive(unitView, active)
	local index = self.visibleUnitUIsIndexMap[unitView]

	if active then
		if index ~= nil then
			return
		end

		self.visibleUnitUIsList[#self.visibleUnitUIsList + 1] = unitView
		self.visibleUnitUIsIndexMap[unitView] = #self.visibleUnitUIsList

		return
	end

	if index == nil then
		return
	end

	local lastIndex = #self.visibleUnitUIsList
	local lastUnitView = self.visibleUnitUIsList[lastIndex]

	self.visibleUnitUIsList[index] = lastUnitView
	self.visibleUnitUIsList[lastIndex] = nil
	self.visibleUnitUIsIndexMap[unitView] = nil

	if lastUnitView ~= unitView then
		self.visibleUnitUIsIndexMap[lastUnitView] = index
	end
end

function InteractSignUIComponent:onUnitViewResourceReady(unitView)
	if self.unitUIsIndexMap[unitView] then
		self.nextLogicTickTime = 0
	end
end

function InteractSignUIComponent:onAddSign(info)
	local viewGroup = self.unitUIs[info.globalId]

	if viewGroup and viewGroup[info.cfgId] then
		return
	end

	local unitView = InteractionSignUIBase.new({
		defaultUrlPath = self.defaultUrlPath,
		root = self.transform,
		globalId = info.globalId,
		unitData = info.unitData,
		owner = self
	})

	if self.unitUIs[info.globalId] == nil then
		self.unitUIs[info.globalId] = {}
	end

	table.insert(self.unitUIsList, unitView)

	local index = #self.unitUIsList

	self.unitUIs[info.globalId][info.cfgId] = unitView
	self.unitUIsIndexMap[unitView] = index

	unitView:onVisibleChange(not self.updateSuspended)
	unitView:onEnter()

	self.nextLogicTickTime = 0
end

function InteractSignUIComponent:onRemoveSign(info)
	local viewGroup = self.unitUIs[info.globalId]

	if viewGroup then
		if info.cfgId == nil then
			for _, unitView in pairs(viewGroup) do
				self:_removeUnitUI(unitView)
			end

			self.unitUIs[info.globalId] = nil
			self.frameContext.anchorCacheByGlobalId[info.globalId] = nil
		else
			local unitView = viewGroup[info.cfgId]

			if unitView then
				self:_removeUnitUI(unitView)

				viewGroup[info.cfgId] = nil

				if next(viewGroup) == nil then
					self.unitUIs[info.globalId] = nil
					self.frameContext.anchorCacheByGlobalId[info.globalId] = nil
				end
			end
		end
	end
end

function InteractSignUIComponent:_removeUnitUI(unitView)
	local index = unitView and self.unitUIsIndexMap[unitView]

	if index == nil then
		return
	end

	if self.unitUIsList[index] ~= unitView then
		self.unitUIsIndexMap[unitView] = nil

		return
	end

	self:setUnitViewLayoutActive(unitView, false)
	unitView:onLeave()

	local lastIndex = #self.unitUIsList

	self.unitUIsList[index] = nil
	self.unitUIsIndexMap[unitView] = nil

	if lastIndex ~= index then
		local lastUnitUI = self.unitUIsList[lastIndex]

		self.unitUIsList[index] = lastUnitUI
		self.unitUIsList[lastIndex] = nil
		self.unitUIsIndexMap[lastUnitUI] = index
	end

	if self.blockCheckCursor > #self.unitUIsList then
		self.blockCheckCursor = 0
	end
end

function InteractSignUIComponent:onAddInteractionSign(unit)
	self:onAddSign(unit)
end

function InteractSignUIComponent:onRemoveInteractionSign(unit)
	self:onRemoveSign(unit)
end

function InteractSignUIComponent:onInteractViewUpdated()
	self:refreshActiveInteractFuncIds()

	self.nextLogicTickTime = 0
end

function InteractSignUIComponent:onUIVisibleChanged()
	local hasFullPanel = pg.global.ui:getModalPanelShowState()

	self.hasFullPanel = hasFullPanel

	self:setUpdateSuspended(self:shouldSuspendUpdate())
end

return InteractSignUIComponent
