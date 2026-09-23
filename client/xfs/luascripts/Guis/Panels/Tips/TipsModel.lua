-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\TipsModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TipsModel = Class.LightClass("TipsModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")

TipsModel.TEXT_RES_ID = "UI_Prefab_Tips_GetTip_Text"
TipsModel.PET_SINGLE_RES = "UI_Node_Hud_Tip_NewGetPet"
TipsModel.PRE_LOAD_TEXT_COUNT = 3
TipsModel.TEXT_MAX_SHOW_COUNT = 2
TipsModel.BATTLE_TIP = 1
TipsModel.BUBBLE_TIP = 0
TipsModel.BUBBLE_ICON_BIG = 1
TipsModel.BUBBLE_ICON_NORMAL = 2
TipsModel.INTERVAL_POP_TEXT = 0.5
TipsModel.INTERVAL_POP_Pet = 0.2
TipsModel.PET_MULT_COUNT = SysConfigData.THRESHOLD_MULTICATCH_NOTIFICATION
TipsModel.PET_GOT_SINGLE_SHOW_COUNT = 3
TipsModel.PET_MULT_SHORT_MAX_COUNT = 10
TipsModel.PET_GOT_SHOW_MUL_SECONDS = 10
TipsModel.PET_GOT_SHOW_MUL_SECONDS_SHORT = 7
TipsModel.PET_GOT_SHOW_ALL_DURATION = 5
TipsModel.PRE_LOAD_PET_SINGLE_COUNT = 4
TipsModel.PET_GOT_SHOW_SECONDS = 7
TipsModel.PET_GOT_SHOW_SECONDS2 = 4
TipsModel.PET_DURATION_ADJUST_COUNT = TipsModel.PET_GOT_SINGLE_SHOW_COUNT + 1
TipsModel.PET_SINGLE_RARE = 0
TipsModel.PET_SINGLE_NORMAL = 1
TipsModel.TEXT_NORMAL_TIP = 0
TipsModel.TEXT_TIP = 1

function TipsModel:ctor()
	self.bossMechanismIconMap = {}
end

function TipsModel:getBossMechanismIconMap()
	return self.bossMechanismIconMap
end

function TipsModel:getBossMechanismIconData(actorId)
	return self.bossMechanismIconMap[actorId]
end

local function getOrCreate(self, actorId)
	local data = self.bossMechanismIconMap[actorId]

	if not data then
		local entity = pg.getEntityByActorId(actorId)

		data = {
			stage = false,
			pendingFlash = false,
			actorId = actorId,
			max = entity.bossMechanismIconMax or -1,
			cur = entity.bossMechanismIconProgress or -1
		}
		self.bossMechanismIconMap[actorId] = data
	end

	return data
end

function TipsModel:initBossMechanismIconClient(actorId, assetId, iconType, needFlash)
	local data = getOrCreate(self, actorId)

	data.assetId = assetId
	data.type = iconType

	if needFlash then
		data.pendingFlash = needFlash
	end
end

function TipsModel:syncBossMechanismIconMax(actorId, max)
	local data = getOrCreate(self, actorId)

	data.max = max
end

function TipsModel:syncBossMechanismIconProgress(actorId, progress)
	local data = getOrCreate(self, actorId)

	data.cur = progress
end

function TipsModel:removeBossMechanismIcon(actorId)
	self.bossMechanismIconMap[actorId] = nil
end

function TipsModel:setBossMechanismIconStage(actorId, stage)
	local data = self.bossMechanismIconMap[actorId]

	if not data then
		return
	end

	data.stage = stage
end

function TipsModel:setBossMechanismIconPendingFlash(actorId)
	local data = self.bossMechanismIconMap[actorId]

	if not data then
		return
	end

	data.pendingFlash = true
end

return TipsModel
