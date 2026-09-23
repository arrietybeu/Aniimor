-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\TopLogo\\TopLogoCapacityLimiter.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoCapacityLimiter = Class.LightClass("TopLogoCapacityLimiter")

function TopLogoCapacityLimiter:ctor(config)
	self.list = {}
	self.dict = {}
	self.maxProvider = config.maxProvider
	self.sortFunc = config.sortFunc
	self.filterFunc = config.filterFunc
	self.prepareSortData = config.prepareSortData
	self.visibleKey = UIConst.TOPLOGO_VISIBLE_KEY.CAPACITY_LIMIT
	self.cadenceSec = config.cadenceSec or 0.5
	self.dirty = false
	self.lastFlushTime = 0
	self.lastWasUnderCap = true
	self._needForceFlush = self.filterFunc ~= nil
end

function TopLogoCapacityLimiter:register(id, comp)
	if self.dict[id] then
		return
	end

	self.dict[id] = comp

	table.insert(self.list, comp)

	self.dirty = true
	self.lastWasUnderCap = false
end

function TopLogoCapacityLimiter:unregister(id)
	local comp = self.dict[id]

	if not comp then
		return
	end

	RemoveTableItem(self.list, comp)

	self.dict[id] = nil

	comp:setVisible(true, self.visibleKey)

	self.dirty = true
end

function TopLogoCapacityLimiter:flush(now)
	if #self.list == 0 then
		return
	end

	if not self.dirty and not self._needForceFlush then
		return
	end

	if now - self.lastFlushTime < self.cadenceSec then
		return
	end

	local effective

	if self.filterFunc then
		effective = {}

		for _, comp in ipairs(self.list) do
			if self.filterFunc(comp) then
				effective[#effective + 1] = comp
			else
				comp:setVisible(true, self.visibleKey)
			end
		end
	else
		effective = self.list
	end

	if #effective == 0 then
		self.lastWasUnderCap = true
		self.dirty = false
		self.lastFlushTime = now

		return
	end

	local max = self.maxProvider()

	if max >= #effective then
		if not self.lastWasUnderCap then
			for _, comp in ipairs(effective) do
				comp:setVisible(true, self.visibleKey)
			end

			self.lastWasUnderCap = true
		end

		self.dirty = false
		self.lastFlushTime = now

		return
	end

	if self.prepareSortData then
		self.prepareSortData(effective)
	end

	table.sort(effective, self.sortFunc)

	for idx, comp in ipairs(effective) do
		comp:setVisible(idx <= max, self.visibleKey)
	end

	self.lastWasUnderCap = false
	self.dirty = true
	self.lastFlushTime = now
end

function TopLogoCapacityLimiter:clear()
	for _, comp in ipairs(self.list) do
		comp:setVisible(true, self.visibleKey)
	end

	self.list = {}
	self.dict = {}
	self.dirty = false
	self.lastWasUnderCap = true
end

return TopLogoCapacityLimiter
