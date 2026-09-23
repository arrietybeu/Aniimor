-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ItemNotifyManager.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ItemNotifyManager")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local ItemNotifyManager = Class.LightClass("ItemNotifyManager")

function ItemNotifyManager:ctor(owner)
	self.owner = owner
	self.running = false

	self:clear()
end

function ItemNotifyManager:clear()
	self.notifySource = ItemConst.ITEM_NOTIFY_SOURCE_NONE
	self.callback = nil
	self.notifyList = {}

	if self.delayExitTimer then
		self.owner:removeTimer(self.delayExitTimer)

		self.delayExitTimer = nil
	end
end

function ItemNotifyManager:runWithDelayExit(notifySource, delay, startNewIfRunning)
	delay = math.min(delay or 0, 5)

	if not self.owner then
		return
	end

	if self.delayExitTimer and not startNewIfRunning then
		return
	end

	self:run(notifySource)

	self.delayExitTimer = self.owner:addTimer(delay, function()
		self:exit()
	end)
end

function ItemNotifyManager:run(notifySource, callback)
	if self.running then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("run process %s failed: already in process %s", tostring(notifySource), tostring(self.notifySource), self.owner:repr())
		end

		self:clear()
	end

	self.running = true
	self.notifySource = notifySource or ItemConst.ITEM_NOTIFY_SOURCE_NONE
	self.callback = callback
end

function ItemNotifyManager:exit()
	if not self.running then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("exit process without running", self.owner:repr())
		end

		return
	end

	if next(self.notifyList) then
		if pg.component == "game" then
			if self.notifySource == ItemConst.ITEM_NOTIFY_SOURCE_CATCH_REPORT then
				self.owner:onItemNotifyCatchReport(self.notifyList)
			end

			self.owner:clientMsg("RPC_SC_OnNotifyItemsBatch", self.notifyList, self.notifySource)
		else
			self.owner:handleOnItemBatchNotifyEnd(self.notifyList)
		end
	end

	if self.callback then
		self.callback(self.notifyList)

		self.callback = nil
	end

	self.running = false

	self:clear()
end

function ItemNotifyManager:doItemNotify(idNumBoundDict, source, context)
	source = source or ItemConstSourceData.ITEM_SOURCE_COMMON
	context = context or {}

	if not self.running then
		if pg.component == "game" then
			self.owner:clientMsg("RPC_SC_OnNotifyItems", idNumBoundDict, source, context)
		else
			self.owner:handleOnItemBatchNotifyEnd({
				{
					idNumBoundDict,
					source,
					context
				}
			})
		end
	else
		lume.push(self.notifyList, {
			idNumBoundDict,
			source,
			context
		})
	end
end

return ItemNotifyManager
