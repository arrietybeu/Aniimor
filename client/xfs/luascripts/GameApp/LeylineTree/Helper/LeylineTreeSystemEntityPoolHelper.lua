-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\LeylineTree\\Helper\\LeylineTreeSystemEntityPoolHelper.lua

local Class = require("Core.Framework.Class")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local GameObject = CS.UnityEngine.GameObject
local Object = CS.UnityEngine.Object
local LeylineTreeSystemEntityPoolHelper = Class.LiteClass("LeylineTreeSystemEntityPoolHelper")

function LeylineTreeSystemEntityPoolHelper:ctor()
	return
end

function LeylineTreeSystemEntityPoolHelper:initPool()
	self.poolParent = GameObject("LeylineTreePlentyGroup")
	self.poolLoaders = {}
	self.objectPool = {}
	self.pool = {}

	Object.DontDestroyOnLoad(self.poolParent)
end

function LeylineTreeSystemEntityPoolHelper:isIdValid(id)
	return self.pool[id] ~= nil
end

function LeylineTreeSystemEntityPoolHelper:getFromPool(id)
	return self.pool[id]
end

function LeylineTreeSystemEntityPoolHelper:createFromPool(id, type, callback)
	if self:isIdValid(id) then
		local info = self:getFromPool(id)

		if callback then
			callback(info)
		end

		return
	end

	for oriId, info in pairs(self.objectPool) do
		if not info.active and info.type == type then
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
	local resType

	if type == Const.MAP_MARK_LeylineTree_Create then
		resType = AddressDataConst.LEYLINETREE_RING
	elseif type == Const.MAP_MARK_EcoTrace_Search then
		resType = AddressDataConst.ECO_TRACE_SEARCH_RING
	end

	if not resType then
		return
	end

	loader:load(resType, function(gameObject)
		local info = {
			active = true,
			gameObject = gameObject,
			id = id,
			type = type
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

function LeylineTreeSystemEntityPoolHelper:recycleToPool(id, callback)
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

function LeylineTreeSystemEntityPoolHelper:recycleAll()
	for id, _ in pairs(self.pool) do
		self:recycleToPool(id)
	end
end

function LeylineTreeSystemEntityPoolHelper:destroyPool()
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

return LeylineTreeSystemEntityPoolHelper
