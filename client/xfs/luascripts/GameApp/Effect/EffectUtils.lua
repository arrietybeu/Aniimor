-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Effect\\EffectUtils.lua

local ItemEffectData = require("Data.item_effect_data")
local AbilityConst = require("Common.Const.AbilityConst")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local camp_data = require("Data.camp_data")
local PetData = require("Data.pet_data")
local LoggerManager = require("Core.Log.LoggerManager")
local Utils = require("Common.Utils.Utils")
local EffectConst = require("Const.EffectConst")
local EffectUtils = {}

function EffectUtils.playRedEyeEffect(entity)
	local effectKey = EffectConst.FIXED_EFFECT_KEYS.EFF_EVIL

	entity:stopEffect(effectKey)
	entity:playEffect(effectKey)
	entity.eModel.modelModelView:SendVisualEffectEvent(EffectConst.EFFECT_EVENT.EFF_EVIL_SMOKE)
end

return EffectUtils
