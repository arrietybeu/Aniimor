-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\ResLoad\\ResLoader.lua

local Class = require("Core.Framework.Class")
local ResLoader = Class.LightClass("ResLoader")

function ResLoader:ctor(parent)
	self.obj = nil
	self.taskId = 0
	self.parent = parent
end

function ResLoader:load(resId, callback, noCache)
	self:clear()

	self.noCache = noCache or false
	self.taskId = pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(gameObj, userData)
		if self.position then
			gameObj.transform.position = self.position
		end

		if self.localPosition then
			gameObj.transform.localPosition = self.localPosition
		end

		if self.eulerAngles then
			gameObj.transform.localEulerAngles = self.eulerAngles
		end

		self.obj = gameObj

		if callback ~= nil then
			callback(gameObj)
		end
	end, 1, nil, self.parent)

	return self.taskId
end

function ResLoader:instantiateAsync(prefab, callback, position, rotation)
	self:clearInstantiate()
	pg.global.resMgr:ResInstantiateAsync(prefab, function(gameObj, userData)
		self.obj = gameObj

		if callback ~= nil then
			callback(gameObj)
		end
	end, position, rotation, self.parent)
end

function ResLoader:setParent(parent)
	self.parent = parent

	if self.obj then
		self.obj.transform:SetParent(self.parent)
	end
end

function ResLoader:setLocalPosition(localPosition)
	self.localPosition = localPosition

	if self.obj then
		self.obj.transform.localPosition = self.localPosition
	end
end

function ResLoader:setPosition(position)
	self.position = position

	if self.obj then
		self.obj.transform.position = self.position
	end
end

function ResLoader:setEulerAngles(eulerAngles)
	self.eulerAngles = eulerAngles

	if self.obj then
		self.obj.transform.eulerAngles = self.eulerAngles
	end
end

function ResLoader:setScale(scale)
	self.scale = scale

	if self.obj then
		self.obj.transform.localScale = self.scale
	end
end

function ResLoader:setActive(active)
	if self.obj then
		self.obj:SetActiveEx(active)
	end
end

function ResLoader:loaded()
	if self.obj then
		return true
	end

	return false
end

function ResLoader:clear()
	if not IsNil(self.obj) then
		pg.global.resMgr:RemoveInstanceToCache(self.obj, self.noCache or false)

		self.obj = nil
	else
		pg.global.resMgr:TryCancelGOLoadAsyncTask(self.taskId)
	end

	self.taskId = nil
end

function ResLoader:clearInstantiate()
	if not IsNil(self.obj) and self.obj.activeSelf then
		pg.global.resMgr:ResDestroyObject(self.obj)

		self.obj = nil
	end

	self.taskId = nil
end

function ResLoader:destroy()
	self:clear()

	self.parent = nil
	self.position = nil
end

return ResLoader
