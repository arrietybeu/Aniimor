-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\ParabolaThrowContext.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local InputCommand = require("GameApp.Input.InputCommand")
local EventConst = require("Const.EventConst")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local AddressDataConst = require("Const.AddressDataConst")
local ConflictTypes = require("Common.ConflictTypes")
local PlayableEventConst = require("Const.PlayableEventConst")
local NoticeDef = require("Common.NoticeDef")
local ParabolaThrowContext = Class.LightClass("ParabolaThrowContext", ThrowBallContext)

function ParabolaThrowContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)
end

function ParabolaThrowContext:enter()
	self.player.eModel.ThrowAnimType = self.ballData.animType
	self.player.eModel.AlwaysLookForward = true

	self:enableCatchMode(true, true)
	ThrowBallContext.enter(self)
	pg.global.ui.hudV2:switchAimVisible(false)
end

function ParabolaThrowContext:hold()
	self.player:addEModelComponent(CommonConst.COMPONENT_CATCH)
	self.player.eModel:LoadPointer(CommonConst.COMPONENT_CATCH, AddressDataConst.PARABOLA_POINTER, {
		boneName = self.ballData.bone,
		speed = self.ballData.maxV,
		offset = Vector3(unpack(self.ballData.offset))
	})

	if self.ballEnt then
		return false
	end

	if not ClientCaptureUtils.checkBallItem(self.itemId) then
		self:exitCatchMode()
		pg.global.showBubbleMessage(NoticeDef.ITEM_LACK_CANT_THROW)

		return false
	end

	self:_clear()
	self:createBall()
	self.eventEmitter:onceEventListener(PlayableEventConst.fireBall, function()
		self:fireBall()
	end)

	return true
end

function ParabolaThrowContext:throwEnd(breaked)
	self.player:switchContext()
end

function ParabolaThrowContext:exit()
	self.player:switchContext()

	return true
end

function ParabolaThrowContext:fireBall()
	if self.ballEnt then
		self.ballEnt:fire()
	end

	ThrowBallContext.fireBall(self)
	self.player.eModel:UnloadPointer(CommonConst.COMPONENT_CATCH)
end

function ParabolaThrowContext:_clear()
	self.eventEmitter:removeAllListeners(PlayableEventConst.holdBall)
	ThrowBallContext._clear(self)
end

function ParabolaThrowContext:destroy()
	self.player.eModel.AlwaysLookForward = false

	self.player.eModel:UnloadPointer(CommonConst.COMPONENT_CATCH)
	ThrowBallContext.destroy(self)
end

return ParabolaThrowContext
