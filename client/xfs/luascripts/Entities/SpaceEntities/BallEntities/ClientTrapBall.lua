-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientTrapBall.lua

local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local SysConfigData = require("Data.sys_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local ClientMainAuthorityBall = require("Entities.SpaceEntities.BallEntities.ClientMainAuthorityBall")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientTrapBall = class.Class("ClientTrapBall", ClientMainAuthorityBall)

function ClientTrapBall:ctor(entityId)
	ClientTrapBall.super.ctor(self, entityId)

	self.actionPrototypeId = 1
end

function ClientTrapBall:onBallCreated()
	ClientTrapBall.super.onBallCreated(self)

	self.absorbedEIds = {}
	self.max_count = self.ballData.maxCount
end

function ClientTrapBall:getInteractionListData()
	return {
		{
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_PICK_UP,
			actionPrototypeId = self.actionPrototypeId,
			name = self:getConfigData().name or ""
		}
	}
end

function ClientTrapBall:onLuaHitEntity(hitEntityId)
	ClientTrapBall.super.onLuaHitEntity(self, hitEntityId)

	if self.catching then
		return
	end

	if not self.fired then
		return
	end

	if table.contains(self.absorbedEIds, hitEntityId) then
		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not CatchProbContext.clientGet(hitEntity).canCatch then
		self.eModel:OnHitEntity(hitEntity.eModel, false)

		return
	end

	if self.max_count > 0 then
		table.insert(self.absorbedEIds, hitEntity.id)

		self.max_count = self.max_count - 1

		self.eModel:OnHitEntity(hitEntity.eModel, true)
		hitEntity:trapped()
		self:doCaptureStart()
	end
end

function ClientTrapBall:onCaptureAnimEnd(puppetInfos)
	local entityIds = lume.imap(puppetInfos, "entId")
	local results = lume.imap(puppetInfos, "captureSuccess")

	self.catching = true

	local entities = {}

	for i, entityId in ipairs(entityIds) do
		local ent = pg.getEntity(entityId)

		table.insert(entities, ent)
	end

	self.entityIds = entityIds
	self.results = results

	self.eModel:CaptureResult(entityIds, results)
end

function ClientTrapBall:onLuaNoticeFinished()
	local entityIds = self.entityIds
	local results = self.results

	ClientTrapBall.super.onLuaNoticeFinished(self)

	if not entityIds then
		return
	end

	local successed = false

	for i, entityId in ipairs(entityIds) do
		local ent = pg.getEntity(entityId)

		if not results[i] then
			if ent then
				ent:cancelTrapped(self.master.actorId)
			end
		else
			successed = true
		end
	end

	if successed then
		self.master:postComponentMethod("OnPetProud")
	end

	self:doCaptureEnd()
end

function ClientTrapBall:fire(position, rotation)
	if self.fired then
		return
	end

	ClientTrapBall.super.fire(self)
	self.shell:PlaceTrap(position, rotation)
end

return ClientTrapBall
