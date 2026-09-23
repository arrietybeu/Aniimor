-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\QteComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local logger = LoggerManager.getLogger("QteClip")
local QteComponent = Class.LightClass("QteComponent")

function QteComponent:ctor(actorId, componentData)
	self.actorId = actorId
	self.data = componentData or {}

	self:onCtor()
end

function QteComponent:start(id, context)
	self.id = id
	self.curTime = 0
	self.destroyed = false
	self.context = context or {}

	local resId = self:getPrefabResId()

	if resId then
		self:loadPrefab(resId)
	end

	self:onStart()
end

function QteComponent:update(deltaTime)
	self.curTime = self.curTime + deltaTime

	return false
end

function QteComponent:isFinish()
	return self.destroyed == true
end

function QteComponent:destroy()
	self.destroyed = true

	self:onDestroy()
	self:destroyPrefab()
end

function QteComponent:getPrefabResId()
	return self.data.prefabResID
end

function QteComponent:loadPrefab(resId)
	pg.global.ui.qte:instanceQtePrefab(self, resId)
end

function QteComponent:destroyPrefab()
	local resId = self:getPrefabResId()

	if self.gameObject and resId then
		pg.global.ui.qte:destroyQtePrefab(self.gameObject)
	end

	self.gameObject = nil
end

function QteComponent:prefabLoaded(gameObject)
	self.gameObject = gameObject

	self:initPrefabPosition()
	self:onPrefabLoaded()
end

function QteComponent:initPrefabPosition()
	if self.gameObject then
		local position = self.data.position or {
			0.5,
			0.5
		}

		UIUtils.SetAnchors(self.gameObject.transform, position[1], position[2], position[1], position[2])
	end
end

function QteComponent:getDebugName()
	return "qteComponent/" .. tostring(self.id)
end

function QteComponent:onCtor()
	return
end

function QteComponent:onStart()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk QteComponent onStart ", self:getDebugName())
	end
end

function QteComponent:onDestroy()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk QteComponent onDestroy ", self:getDebugName())
	end
end

function QteComponent:onUpdate(deltaTime)
	return
end

function QteComponent:onPrefabLoaded()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk qteClip onPrefabLoaded ", self:getDebugName())
	end
end

return QteComponent
