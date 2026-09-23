-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MarkShare\\Helper\\MarkShareSystemEntityPoolHelper.lua

local Class = require("Core.Framework.Class")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local AddressDataConst = require("Const.AddressDataConst")
local GameObject = CS.UnityEngine.GameObject
local Object = CS.UnityEngine.Object
local preLoadCount = 10
local MarkShareSystemEntityPoolHelper = Class.LiteClass("MarkShareSystemEntityPoolHelper")

function MarkShareSystemEntityPoolHelper:ctor()
	return
end

function MarkShareSystemEntityPoolHelper:initPool()
	self.poolParent = GameObject("InfoStampGroup")
	self.poolLoaders = {}
	self.objectPool = {}
	self.pool = {}

	Object.DontDestroyOnLoad(self.poolParent)
	self:preloadItems()
end

function MarkShareSystemEntityPoolHelper:preloadItems()
	for i = 1, preLoadCount do
		local loader = ResLoader.new()

		loader:load(AddressDataConst.INFO_STAMP, function(gameObject)
			local info = {
				active = false,
				gameObject = gameObject,
				id = i
			}

			info.gameObject.name = string.format("pool_node_empty_%s", info.id)

			info.gameObject:SetActiveEx(info.active)
			info.gameObject.transform:SetParent(self.poolParent.transform)

			self.objectPool[#self.objectPool + 1] = info
			self.pool[info.id] = info
		end)

		self.poolLoaders[#self.poolLoaders + 1] = loader
	end
end

function MarkShareSystemEntityPoolHelper:isIdValid(id)
	return self.pool[id] ~= nil
end

function MarkShareSystemEntityPoolHelper:getFromPool(id)
	return self.pool[id]
end

function MarkShareSystemEntityPoolHelper:createFromPool(id, callback)
	if self:isIdValid(id) then
		local info = self:getFromPool(id)

		if callback then
			callback(info)
		end

		return
	end

	for oriId, info in pairs(self.objectPool) do
		if not info.active then
			info.active = true
			info.id = id
			info.gameObject.name = info.id

			info.gameObject:SetActiveEx(info.active)

			self.pool[oriId] = nil
			self.pool[info.id] = info

			if callback then
				callback(info)
			end

			return
		end
	end

	local loader = ResLoader.new()

	loader:load(AddressDataConst.INFO_STAMP, function(gameObject)
		local info = {
			active = true,
			gameObject = gameObject,
			id = id
		}

		info.gameObject.name = info.id

		info.gameObject:SetActiveEx(info.active)
		info.gameObject.transform:SetParent(self.poolParent.transform)

		self.objectPool[#self.objectPool + 1] = info
		self.pool[info.id] = info

		if callback then
			callback(info)
		end
	end)

	self.poolLoaders[#self.poolLoaders + 1] = loader
end

function MarkShareSystemEntityPoolHelper:recycleToPool(id, callback)
	if not self:isIdValid(id) then
		return
	end

	self.pool[id] = nil

	for _, info in pairs(self.objectPool) do
		if info.id == id then
			info.gameObject:SetActiveEx(false)

			info.gameObject.name = string.format("pool_node_empty_%s", info.id)
			info.active = false

			if callback then
				callback(info.gameObject)
			end

			return
		end
	end
end

function MarkShareSystemEntityPoolHelper:recycleAll()
	for id, _ in pairs(self.pool) do
		self:recycleToPool(id)
	end
end

function MarkShareSystemEntityPoolHelper:destroyPool()
	if self.poolLoaders then
		for _, loader in pairs(self.poolLoaders) do
			loader:destroy()
		end

		self.poolLoaders = nil
	end

	self.objectPool = nil
	self.pool = nil

	GameObject.Destroy(self.poolParent)

	self.poolParent = nil
end

return MarkShareSystemEntityPoolHelper
