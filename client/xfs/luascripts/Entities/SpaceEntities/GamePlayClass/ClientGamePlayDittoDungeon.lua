-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\GamePlayClass\\ClientGamePlayDittoDungeon.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientGamePlayEntity = require("Entities.SpaceEntities.GamePlayClass.ClientGamePlayEntity")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local EffectShaderViewComponent = CS.FunPlus.WorldX.Effect.EffectShaderViewComponent
local AirWallProgressDisengage = CS.FunPlus.WorldX.Physx.AirWallProgressDisengage
local SceneUtils = require("Common.Utils.SceneUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local SysConfigData = require("Data.sys_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local Vector3 = Vector3
local ClientGamePlayDittoDungeon = class.Class("ClientGamePlayDittoDungeon", ClientGamePlayEntity)

function ClientGamePlayDittoDungeon:init(dict)
	ClientGamePlayDittoDungeon.super.init(self, dict)

	self.failRadius = dict.failRadius
	self.entryPoiId = dict.entryPoiId
	self.entrySceneId = dict.entrySceneId
	self.centerPos = dict.center

	return true
end

function ClientGamePlayDittoDungeon:enterSpace(space)
	self.space = space
	self.sandbox = space:getSandbox(self.sandboxId)

	if self.sandbox then
		self.sandbox:addGameplay(self)
	end

	pg.me.inMorphling = true

	if pg.me.updateStateCache then
		pg.me:updateStateCache("MORPHLING_NO_ATTACK")
	end
end

function ClientGamePlayDittoDungeon:start()
	return
end

function ClientGamePlayDittoDungeon:onSandboxReady()
	if self.status == SandboxConst.DITTO_DUNGEON_STATE.START then
		self:refreshAreaEffect(true)
		self:setOuterPuppetVisible(false)
		self:refreshCollision(false)

		if self.endTime ~= 0 then
			local remainTime = self.endTime - Time.secondCache

			pg.global.ui.tips:showCountDown(remainTime, "Ditto")
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("MORPHLING_BEGIN_HINT"))
	end

	pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.DittoState, SandboxConst.DITTO_DUNGEON_RESULT.ACTIVE)
end

function ClientGamePlayDittoDungeon:on_status_changed(oldV, newV)
	if newV == SandboxConst.DITTO_DUNGEON_STATE.START then
		-- block empty
	else
		self:refreshAreaEffect(false)
		self:setOuterPuppetVisible(true)

		if self.endTime ~= 0 then
			pg.global.ui.tips:hideCountDown()
		end

		if newV == SandboxConst.DITTO_DUNGEON_STATE.SUCCESS then
			pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.DittoState, SandboxConst.DITTO_DUNGEON_RESULT.SUCCESS)
		elseif newV == SandboxConst.DITTO_DUNGEON_STATE.FAIL then
			local state = pg.global.prefsCacheUtils:getInt(pg.me.uid .. ClientConst.PrefKey.DittoState, 0)

			if state <= 1 then
				pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.DittoState, SandboxConst.DITTO_DUNGEON_RESULT.FAIL)
			end
		end

		self:toastPoiPopup(newV == SandboxConst.DITTO_DUNGEON_STATE.SUCCESS, pg.getGameString(newV == SandboxConst.DITTO_DUNGEON_STATE.SUCCESS and "SUCCEED" or "FAILED"), 3)
		self:refreshCollision(true)
		facade:SendMessageCommand(MessageName.MORPHLING_STATE_CHANGE, 1)

		self._exitTimer = self:addTimer(3, function()
			pg.global.ui:close(UIConst.UI_ID_Morphling)

			if newV == SandboxConst.DITTO_DUNGEON_STATE.SUCCESS then
				pg.global.ui.blackScreen:open({
					id = 166
				})

				self.blackScreenTimer = self:addTimer(1, function()
					ClientUtils.exitDungeon()
				end)
			else
				ClientUtils.exitDungeon()
			end
		end)
	end
end

function ClientGamePlayDittoDungeon:on_endTime_changed(oldV, newV)
	return
end

function ClientGamePlayDittoDungeon:setOuterPuppetVisible(visible)
	if not self.sandbox then
		return
	end

	local allPuppets = pg.ent("ClientPuppet")

	for _, puppet in pairs(allPuppets) do
		if not self.sandbox.entities[puppet.id] then
			puppet:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, visible, visible)
		end
	end
end

local AREA_EFFECT_RES_ID = "$Eff_BossArea_Common_30X30.prefab"

function ClientGamePlayDittoDungeon:refreshAreaEffect(enable)
	if not self.space then
		return
	end

	if enable then
		self.areaEffectTaskId = pg.global.resMgr:GetInstanceFromCacheByLua(AREA_EFFECT_RES_ID, function(obj, customData)
			self.areaEffectTaskId = nil
			self.areaEffectGo = obj

			local effectShaderView = EffectShaderViewComponent.GetOrAddComponent(self.areaEffectGo)

			effectShaderView:SetMaterialProperty("_VFXDistanceFadePluginModel_DistanceFadeEnable", 1)

			self.areaEffectGo.transform.position = self.centerPos

			local targetScale = self.failRadius / 30
			local rawScale = self.areaEffectGo.transform.localScale

			self.areaEffectGo.transform.localScale = Vector3(rawScale.x * targetScale, self.areaEffectGo.transform.localScale.y, rawScale.z * targetScale)

			self.areaEffectGo.transform:SetParent(pg.global.effectMgr.worldEffectRoot)

			local progressDisengage = AirWallProgressDisengage.GetOrAddComponent(self.areaEffectGo)

			AirWallProgressDisengage.AUTO_REDUCE_RATE = 0.1
			progressDisengage.selfActorId = pg.me.actorId
			progressDisengage.justClient = true
			progressDisengage.progressTime = 1
		end)
	else
		if self.areaEffectTaskId then
			pg.global.resMgr:TryCancelGOLoadAsyncTask(self.areaEffectTaskId)
		end

		if self.areaEffectGo then
			local scale = self.failRadius / 30
			local curScale = self.areaEffectGo.transform.localScale

			self.areaEffectGo.transform.localScale = Vector3(curScale.x / scale, self.areaEffectGo.transform.localScale.y, curScale.z / scale)

			pg.global.resMgr:RemoveInstanceToCache(self.areaEffectGo, true)
		end

		self.areaEffectTaskId = nil
		self.areaEffectGo = nil
	end
end

function ClientGamePlayDittoDungeon:refreshCollision(enable)
	if enable then
		if pg.pawn then
			pg.pawn:resetCollision()
		end

		local sandbox = self.sandbox

		if sandbox then
			for entId, ent in pairs(sandbox.entities) do
				if Utils.isPuppet(ent) and ent.resetCollision then
					ent:resetCollision()
				end
			end
		end
	else
		if pg.pawn then
			pg.pawn:setDittoCollision()
		end

		local sandbox = self.sandbox

		if sandbox then
			for entId, ent in pairs(sandbox.entities) do
				if Utils.isPuppet(ent) and ent.setDittoCollision then
					ent:setDittoCollision()
				end
			end
		end
	end
end

function ClientGamePlayDittoDungeon:onSwimmingDie()
	pg.global.ui.blackScreen:open({
		id = 167
	})
	pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.DittoState, SandboxConst.DITTO_DUNGEON_RESULT.DEAD)
	self:serverMsg("RPC_CS_ExitDittoDungeon", pg.me.id)
end

function ClientGamePlayDittoDungeon:onSandboxDisabled()
	self:refreshCollision(true)
	self:refreshAreaEffect(false)

	if self.endTime ~= 0 then
		pg.global.ui.tips:hideCountDown("Ditto")
	end

	if self._exitTimer then
		self:removeTimer(self._exitTimer)

		self._exitTimer = nil
	end
end

function ClientGamePlayDittoDungeon:destroy()
	pg.me.inMorphling = false

	if pg.me.updateStateCache then
		pg.me:updateStateCache("MORPHLING_NO_ATTACK")
	end

	self:refreshCollision(true)
	self:refreshAreaEffect(false)

	if self.endTime ~= 0 then
		pg.global.ui.tips:hideCountDown("Ditto")
	end

	if self._exitTimer then
		self:removeTimer(self._exitTimer)

		self._exitTimer = nil
	end

	pg.global.ui.blackScreen:closeScreen()
	ClientGamePlayDittoDungeon.super.destroy(self)
end

function ClientGamePlayDittoDungeon:getMarkConfigData()
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(self.entrySceneId or ClientConst.SCENE_MAIN_SINGLE_WORLD, self.id)
	local markConfig = sceneMarkPointData[self.entryPoiId] or {}

	return markConfig
end

function ClientGamePlayDittoDungeon:toastPoiPopup(isSuccess, subTitle, duration)
	LuaUIUtils.clearToastPoiPopup()

	local markConfig = self:getMarkConfigData()
	local POIIcon = markConfig.POIIcon
	local POIDesc = markConfig.POIDesc
	local POIMusic = markConfig.POIMusic
	local markConfigId = markConfig.markConfigId
	local POIShowType = {
		0,
		1
	}

	if markConfigId then
		POIShowType = (DefaultMapMarkData[markConfigId] or EMPTY_TABLE).POIShowType
		POIShowType = POIShowType or {
			0,
			1
		}
	end

	LuaUIUtils.toastPoiPopup(2, 10, self.id, POIShowType, POIIcon, POIDesc, subTitle, POIMusic, duration, {
		isSuccess = isSuccess
	}, SysConfigData.DITTO_SUCCESS_POI_DELAY)
end

return ClientGamePlayDittoDungeon
