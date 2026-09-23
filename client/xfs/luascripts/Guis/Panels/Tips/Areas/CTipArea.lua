-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\CTipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local JoyStickDragRelay = require("Guis.Helper.JoyStickDragRelay")
local CTipArea = Class.LightClass("CTipArea", BaseTipArea)
local RUN_STATE = TipAreaConst.ITEM_RUN_STATE
local SHARED_SLOT_LIMIT = 6

function CTipArea:onCtor(info)
	self.__CanRecycle = false
end

function CTipArea:findObjects()
	return
end

function CTipArea:onInit()
	if NotNil(self.oc) then
		self.joyStickDragListener = JoyStickDragRelay.attach(self.oc.gameObject)
	end
end

function CTipArea:onDestroy()
	JoyStickDragRelay.detach(self.joyStickDragListener)

	self.joyStickDragListener = nil
end

function CTipArea:onRunStateChanged(isRun)
	local topVisible = not isRun

	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.CF, TipAreaConst.UITipAreaFlag.AreaFlag_CShow, topVisible)
end

function CTipArea:_canShareQuickUseAndProps()
	local quickUse = self.itemDict.QuickUse
	local propObtain = self.itemDict.PropObtain

	if quickUse == nil or propObtain == nil then
		return false
	end

	if quickUse:checkRunState() == RUN_STATE.EMPTY or propObtain:checkRunState() == RUN_STATE.EMPTY then
		return false
	end

	for itemKey, item in pairs(self.itemDict) do
		if itemKey ~= "QuickUse" and itemKey ~= "PropObtain" and item:checkRunState() ~= RUN_STATE.EMPTY then
			return false
		end
	end

	return true
end

function CTipArea:_refreshSharedSlots(canShare)
	local propObtain = self.itemDict.PropObtain

	if propObtain == nil or propObtain.setSharedSlotLimit == nil then
		return
	end

	local quickUse = self.itemDict.QuickUse
	local quickUseBottom

	if canShare and quickUse and quickUse.getLastItemBottomWorldPosition then
		quickUseBottom = quickUse:getLastItemBottomWorldPosition()
	end

	propObtain:setQuickUseBottomWorldPosition(quickUseBottom)

	if not canShare then
		propObtain:setSharedSlotLimit(nil)

		return
	end

	local quickUseCount = quickUse and quickUse:getDisplayCount() or 0

	propObtain:setSharedSlotLimit(SHARED_SLOT_LIMIT - quickUseCount)
end

function CTipArea:update()
	local canShare = self:_canShareQuickUseAndProps()

	self.maxRunNum = canShare and 2 or 1

	self:_refreshSharedSlots(canShare)
	BaseTipArea.update(self)
end

return CTipArea
