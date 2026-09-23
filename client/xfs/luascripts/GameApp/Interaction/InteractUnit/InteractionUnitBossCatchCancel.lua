-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitBossCatchCancel.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local InteractData = require("Data.interact_data")
local lume = require("Core.Common.lume")
local ClientUtils = require("Utils.ClientUtils")
local castItemData = require("Data.cast_item_data")
local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractionUnitBossCatchCancel = Class.LightClass("InteractionUnitBossCatchCancel", InteractionUnitBase)

function InteractionUnitBossCatchCancel:ctor(info, interactId)
	InteractionUnitBossCatchCancel.super.ctor(self, info, interactId)
end

function InteractionUnitBossCatchCancel:interactive()
	local entity = self:getEntity()

	pg.me:cancelBossCapture(entity.actorId)
end

function InteractionUnitBossCatchCancel:canInteractive()
	local ent = self:getEntity()

	if not ent then
		return false
	end

	if not ent.needDoGroupReward then
		return false
	end

	local visible = ent.visible

	if visible == false then
		return false
	end

	if ent.checkCanInteract and not ent:checkCanInteract(self) then
		return false
	end

	if not self:checkInteractAngle() then
		return false
	end

	if not self:checkAirBlock() then
		return false
	end

	if not self:checkInteractBlock() then
		return false
	end

	if not self.interactData.showWhenCantAct and not self:checkConditionId() then
		return false
	end

	if not self:checkDistanceValid(ent) then
		return false
	end

	if pg.me:isInAir() or pg.me:CLIMB_ST() or pg.me:SWIM_ST() then
		return false
	end

	return true
end

return InteractionUnitBossCatchCancel
