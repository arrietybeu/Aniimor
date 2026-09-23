-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\StickerFeature.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local Utils = require("Common.Utils.Utils")
local EventConst = require("Const.EventConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EffectConst = require("Const.EffectConst")
local StickerFeature = Class.LiteClass("StickerFeature", iFeature)

function StickerFeature:ctor()
	StickerFeature.super.ctor(self)

	self.enable = false
end

function StickerFeature:init(master, data)
	StickerFeature.super.init(self, master, data)

	if not Utils.isPet(self.master) then
		return
	end

	local configData = self.master:getConfigData()

	self.featureConfig = configData.featureConfigData or {}

	local player = self.master:getMasterEntity()

	self.eventHandler = CallbackHandler(self, "refreshStickEnable")

	player.eventEmitter:addEventListener(EventConst.ON_FOR_RADIUS_CHANGE, self.eventHandler)
end

function StickerFeature:checkEnableFeature()
	return Utils.isPet(self.master) and self.master.isMainAuthority
end

function StickerFeature:onMasterModelLoaded()
	if not Utils.isPet(self.master) then
		return
	end

	if not self.master.eModel then
		return
	end

	self.master.eModel.modelView:EnsureRuntimeStickerForFeature()
end

function StickerFeature:bind(shell)
	self.shell = shell

	if not self:checkEnableFeature() then
		return
	end

	self:refreshStickEnable()

	if self.enable then
		for entId, v in pairs(self.stickEntities or EMPTY_TABLE) do
			self:stick(entId)
		end
	elseif #self.stickEntities > 0 then
		self:serverMsg("RPC_CS_ClearStick")
	end
end

function StickerFeature:enterStick(entId)
	if not self:checkEnableFeature() then
		return
	end

	local enterEnt = pg.getEntity(entId)

	if not enterEnt then
		return
	end

	if enterEnt.isDead and enterEnt:isDead() then
		return
	end

	if Utils.isPuppet(enterEnt) or Utils.isEnvObj(enterEnt) then
		self:serverMsg("RPC_CS_EnterStick", entId)
	end
end

function StickerFeature:exitStick(entId)
	self:serverMsg("RPC_CS_ExitStick", entId)
end

function StickerFeature:on_stickEntities_entry_added(entId, v)
	self:stick(entId)
end

function StickerFeature:on_stickEntities_entry_deleted(entId)
	self:unstick(entId)
end

function StickerFeature:stick(entId)
	if not self:checkEnableFeature() then
		return
	end

	local enterEnt = pg.getEntity(entId)

	if Utils.isPuppet(enterEnt) then
		enterEnt:beStick()
	end

	self.shell:Stick(entId)
end

function StickerFeature:unstick(entId)
	if not self:checkEnableFeature() then
		return
	end

	local enterEnt = pg.getEntity(entId)

	if Utils.isPuppet(enterEnt) then
		enterEnt:beUnstick()
	end

	self.shell:Unstick(entId)
end

function StickerFeature:refreshStickEnable()
	if not self:checkEnableFeature() then
		return
	end

	if not self.shell then
		return
	end

	local inFog = self.master.inFogArea
	local beControlled = self.master.beControlled

	self:setStickEnable(beControlled and inFog and self.master:FLY_ST())
end

function StickerFeature:setStickEnable(enable)
	if self.enable == enable then
		return
	end

	self.enable = enable

	self.shell:SetStickEnable(enable)

	self.master.eModel.isDisableWeightPush = enable

	if not enable then
		self:serverMsg("RPC_CS_ClearStick")
	end
end

function StickerFeature:playEffectAt(position)
	self.master:playEffect(EffectConst.EFF_PARMON_STICKON, {
		position = position
	})
end

function StickerFeature:destroy()
	local master = self.master

	if Utils.isPet(master) and master.eModel and master.eModel.modelView then
		master.eModel.modelView:RemoveRuntimeStickerForFeature()
	end

	if self:checkEnableFeature() then
		if master.eModel then
			master.eModel.isDisableWeightPush = false
		end

		local player = master:getMasterEntity()

		if player and player.eventEmitter then
			player.eventEmitter:removeEventListener(EventConst.ON_FOR_RADIUS_CHANGE, self.eventHandler)
		end
	end

	StickerFeature.super.destroy(self)

	self.shell = nil
end

return StickerFeature
