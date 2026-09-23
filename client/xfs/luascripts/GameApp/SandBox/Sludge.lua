-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Sludge.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local LuaCSharpList = require("Utils.LuaCSharpList")
local CallbackHandler = require("Core.Common.CallbackHandler")
local bit_bnot = bit.bnot
local bit_lshift = bit.lshift
local math_floor = math.floor
local WORD_BITS = 32
local ALL_ONES = bit_bnot(0)
local Sludge = Class.LightClass("Sludge", LevelItem)

function Sludge:ctor(sandbox, spawnInfo, syncInfo)
	Sludge.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self._weatherChangeCallback = nil
	self._currentAreaWeatherCallback = nil
	self._isRainActive = nil
end

function Sludge:onInit()
	local majorConfig = self:getMajorConfig()

	self.isAutoRefresh = majorConfig.isAutoRefresh or false
	self.refreshInterval = majorConfig.refreshInterval or 30
	self.debuffId = majorConfig.debuffId or 90001
	self.gridWidth = majorConfig.gridWidth or 4
	self.gridHeight = majorConfig.gridHeight or 4
	self.majorCompId = self.spawnInfo.majorCompId

	local total = self.gridWidth * self.gridHeight

	self._cellTotal = total
	self._wordCount = math_floor((total + WORD_BITS - 1) / WORD_BITS)
	self._gridList = LuaCSharpList.newInt(self._wordCount, 0)

	self._gridList:setCount(self._wordCount)

	self._gridAccess = self._gridList:getCSharpAccess()
end

function Sludge:onSandboxReady()
	local comp = self:_getMajorComp()

	if comp then
		comp:BindGridBuffer(self._gridAccess, self.gridWidth, self.gridHeight)
	end

	if self.syncInfo then
		if self.syncInfo.gridPack then
			self:_applyFullToBitset(self.syncInfo.gridPack)
		else
			self:fillAll()
			self:onCellsChanged()
		end
	end

	self:_registerWeatherChangeCallback()
	self:_registerCurrentAreaWeatherCallback()

	local map = pg and pg.game and pg.game.map

	if map then
		self:_refreshRainState(map:getCurBlockAreaId())
	end
end

function Sludge:_getMajorComp()
	if not self.shell or not self.majorCompId then
		return nil
	end

	return self.shell:GetComponentById(self.majorCompId)
end

function Sludge:onWeatherChanged(oldValue, newValue, blockAreaId)
	local map = pg and pg.game and pg.game.map

	if not map or map:getCurBlockAreaId() ~= blockAreaId then
		return
	end

	self:_refreshRainState(blockAreaId)
end

function Sludge:onCurrentAreaWeatherRefresh(eventData)
	local map = pg and pg.game and pg.game.map

	if not map then
		return
	end

	self:_refreshRainState(map:getCurBlockAreaId())
end

function Sludge:_refreshRainState(blockAreaId)
	local space = self.sandbox and self.sandbox.space

	if not space or not blockAreaId or not space.getWeatherByAreaId then
		return
	end

	local weatherId = space:getWeatherByAreaId(blockAreaId)

	self:_setRainActive(weatherId == 2 or weatherId == 4 or weatherId == 12)
end

function Sludge:_setRainActive(isActive)
	if self._isRainActive == isActive then
		return
	end

	local comp = self:_getMajorComp()

	if not comp then
		return
	end

	comp:SetRainActive(isActive)

	self._isRainActive = isActive
end

function Sludge:_registerWeatherChangeCallback()
	if self._weatherChangeCallback then
		return
	end

	local space = self.sandbox and self.sandbox.space

	if not space or not space.addWeatherChangeCallback then
		return
	end

	self._weatherChangeCallback = CallbackHandler(self, "onWeatherChanged")

	space:addWeatherChangeCallback(self._weatherChangeCallback)
end

function Sludge:_unregisterWeatherChangeCallback()
	if not self._weatherChangeCallback then
		return
	end

	local space = self.sandbox and self.sandbox.space

	if space and space.removeWeatherChangeCallback then
		space:removeWeatherChangeCallback(self._weatherChangeCallback)
	end

	self._weatherChangeCallback = nil
end

function Sludge:_registerCurrentAreaWeatherCallback()
	if self._currentAreaWeatherCallback or not pg.me then
		return
	end

	self._currentAreaWeatherCallback = CallbackHandler(self, "onCurrentAreaWeatherRefresh")

	local eventName = pg.me.id .. SandboxConst.COMMON_EVENT.CURRENT_AREA_WEATHER_REFRESH

	facade:registerLuaEvent(eventName, self._currentAreaWeatherCallback)
end

function Sludge:_unregisterCurrentAreaWeatherCallback()
	if not self._currentAreaWeatherCallback then
		return
	end

	facade:unregisterLuaEvent(self._currentAreaWeatherCallback)

	self._currentAreaWeatherCallback = nil
end

function Sludge:reportEnterSludge(entityId)
	if self.sandbox.isMain then
		self:serverMsg("RPC_CS_EnterSludge", entityId)
	end
end

function Sludge:reportLeaveSludge(entityId)
	if self.sandbox.isMain then
		self:serverMsg("RPC_CS_LeaveSludge", entityId)
	end
end

function Sludge:RPC_SC_FillAll()
	self:fillAll()
	self:onCellsChanged()
end

function Sludge:onCellsChanged()
	if self.sandbox.isMain then
		self:serverMsg("RPC_CS_SyncGridInfo", self:_buildFullPacked())
	end
end

function Sludge:_buildFullPacked()
	local gridPack = {
		self.gridWidth,
		self.gridHeight,
		self._wordCount
	}

	for i = 1, self._wordCount do
		gridPack[3 + i] = self._gridList:rawGet(i) or 0
	end

	return gridPack
end

function Sludge:onLevelItemValueChange(key, oldValue, value)
	if key == "gridPack" and not self.sandbox.isMain then
		self:_applyFullToBitset(value)
	end
end

function Sludge:_applyFullToBitset(arr)
	if type(arr) ~= "table" then
		return
	end

	local w = arr[1]
	local h = arr[2]
	local wordCount = arr[3]

	if w ~= self.gridWidth or h ~= self.gridHeight then
		return
	end

	if wordCount ~= self._wordCount then
		return
	end

	for i = 1, wordCount do
		local word = arr[3 + i] or 0

		self._gridList:rawSet(i, word)
	end
end

function Sludge:fillAll()
	local total = self._cellTotal
	local wordCount = self._wordCount

	if wordCount <= 0 then
		return
	end

	for i = 1, wordCount - 1 do
		self._gridList:rawSet(i, ALL_ONES)
	end

	local lastBits = total - (wordCount - 1) * WORD_BITS

	if lastBits >= WORD_BITS then
		self._gridList:rawSet(wordCount, ALL_ONES)
	else
		local mask = bit_lshift(1, lastBits) - 1

		self._gridList:rawSet(wordCount, mask)
	end

	local comp = self:_getMajorComp()

	if comp then
		comp:FillAll()
	end
end

function Sludge:destroy()
	self:_unregisterCurrentAreaWeatherCallback()
	self:_unregisterWeatherChangeCallback()

	if self._gridList then
		self._gridList:destroyCSharpAccess()

		self._gridAccess = nil
		self._gridList = nil
	end

	Sludge.super.destroy(self)
end

return Sludge
