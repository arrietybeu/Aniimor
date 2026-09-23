-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PetJewelryOssCache.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TimerManager = require("Core.Timer.TimerManager")
local logger = LoggerManager.getLogger("PetJewelryOssCache")
local RESOURCE_TYPE = "pet_jewelry"
local STATE = {
	NONE = 0,
	READY = 2,
	LOADING = 1
}
local PetJewelryOssCache = {
	state = STATE.NONE,
	waiters = {}
}

local function getKey()
	return pg.me and tostring(pg.me.id) or nil
end

local function checkOwner()
	local self = PetJewelryOssCache

	if self.state ~= STATE.NONE and self.ownerKey ~= getKey() then
		self.state = STATE.NONE
		self.data = nil
		self.waiters = {}
		self.ownerKey = nil
		self.pendingRefreshPets = nil
	end
end

function PetJewelryOssCache.refreshPetModelNextFrame(petId)
	local self = PetJewelryOssCache

	if self.pendingRefreshPets == nil then
		local pendingPets = {}

		self.pendingRefreshPets = pendingPets

		TimerManager.addNextFrameCb(function()
			if self.pendingRefreshPets ~= pendingPets then
				return
			end

			self.pendingRefreshPets = nil

			if self.state ~= STATE.READY or self.ownerKey ~= getKey() then
				return
			end

			for id in pairs(pendingPets) do
				local petEntity = pg.getEntity(id)

				if petEntity and petEntity.reloadAccessory then
					petEntity:reloadAccessory()
				end
			end
		end)
	end

	self.pendingRefreshPets[tostring(petId)] = true
end

function PetJewelryOssCache._onLoaded(data)
	local self = PetJewelryOssCache

	self.data = data or {}
	self.state = STATE.READY

	for petId in pairs(self.data) do
		self.refreshPetModelNextFrame(petId)
	end

	local waiters = self.waiters

	self.waiters = {}

	for _, cb in ipairs(waiters) do
		local ok, err = pcall(cb)

		if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PetJewelryOssCache waiter callback error: ", tostring(err))
		end
	end
end

function PetJewelryOssCache.ensureLoaded(callback)
	local self = PetJewelryOssCache

	checkOwner()

	if self.state == STATE.READY then
		if callback then
			callback()
		end

		return
	end

	if callback then
		table.insert(self.waiters, callback)
	end

	if self.state == STATE.LOADING then
		return
	end

	local key = getKey()

	if not key then
		self._onLoaded({})

		return
	end

	self.state = STATE.LOADING
	self.ownerKey = key

	local ClientUtils = require("Utils.ClientUtils")

	ClientUtils.pullResource(RESOURCE_TYPE, key, function(_, body)
		if not body and LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("PetJewelryOssCache pullResource empty or failed, fallback to empty: ", key)
		end

		self._onLoaded(body or {})
	end)
end

function PetJewelryOssCache.isReady()
	checkOwner()

	return PetJewelryOssCache.state == STATE.READY
end

function PetJewelryOssCache.get(petId, accessoryId)
	local self = PetJewelryOssCache

	checkOwner()

	if self.state ~= STATE.READY or not self.data or petId == nil or accessoryId == nil then
		return nil
	end

	local petData = self.data[tostring(petId)]

	if not petData then
		return nil
	end

	return petData[tostring(accessoryId)]
end

function PetJewelryOssCache.getSavedTransform(petId, accessoryId, slotFallback)
	if petId == nil or accessoryId == nil then
		return nil
	end

	checkOwner()

	if PetJewelryOssCache.state == STATE.READY then
		return PetJewelryOssCache.get(petId, accessoryId)
	end

	return slotFallback
end

function PetJewelryOssCache.set(petId, accessoryId, transform)
	local self = PetJewelryOssCache

	if petId == nil or accessoryId == nil or transform == nil then
		return
	end

	self.data = self.data or {}

	local petKey = tostring(petId)

	self.data[petKey] = self.data[petKey] or {}
	self.data[petKey][tostring(accessoryId)] = transform

	self.refreshPetModelNextFrame(petId)
end

function PetJewelryOssCache.remove(petId, accessoryId)
	local self = PetJewelryOssCache

	checkOwner()

	if not self.data or petId == nil or accessoryId == nil then
		return
	end

	local petData = self.data[tostring(petId)]

	if petData then
		petData[tostring(accessoryId)] = nil

		self.refreshPetModelNextFrame(petId)
	end
end

function PetJewelryOssCache.upload(callback)
	local self = PetJewelryOssCache
	local key = getKey()

	if not key then
		if callback then
			callback(nil, false)
		end

		return
	end

	local ClientUtils = require("Utils.ClientUtils")

	ClientUtils.addResource(RESOURCE_TYPE, key, self.data or {}, function(k, success)
		if not success and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PetJewelryOssCache upload failed: ", k)
		end

		if callback then
			callback(k, success)
		end
	end)
end

function PetJewelryOssCache.reset()
	local self = PetJewelryOssCache

	self.state = STATE.NONE
	self.data = nil
	self.waiters = {}
	self.pendingRefreshPets = nil
end

return PetJewelryOssCache
