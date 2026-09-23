-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandOrnamentComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientHomeBaseOrnamentComponent = require("Entities.SpaceEntities.HomeBaseComponent.ClientHomeBaseOrnamentComponent")
local logger = LoggerManager.getLogger("ClientHomelandOrnamentComponent", "Sandbox", LoggerConst.ERROR)
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeObjectData = require("Data.home_object_data")
local HomeObjectPlaceData = require("Data.home_object_place_data")
local ClientOrnamentBuildAttachManager = require("Common.Homeland.ClientOrnamentBuildAttachManager")
local GlobalData = require("Core.Client.GlobalData")
local SCALE_INT_BASE = HomeLandUtils.ORNAMENT_SCALE_INT_BASE
local ADD_ORNAMENT_REQUEST_TIMEOUT = 5
local ClientHomelandOrnamentComponent = Class.Component("ClientHomelandOrnamentComponent", ClientHomeBaseOrnamentComponent)

function ClientHomelandOrnamentComponent:ctor()
	self.ornamentCountData = {}
	self.homeBlueprintBuildGroupIndexCache = {}
	self._isAddOrnamentRequesting = false
	self._addOrnamentTimeoutTimer = nil
	self.ornamentBuildAttachManager = ClientOrnamentBuildAttachManager.new(true)
end

function ClientHomelandOrnamentComponent:destroy()
	table.clear(self.homeBlueprintBuildGroupIndexCache)
	self.ornamentBuildAttachManager:destroy()
	self:destroyAllHomeEntities()
end

function ClientHomelandOrnamentComponent:postInit(dict)
	self.ornamentBuildAttachManager:init(self.ornament, self.ornamentExtraData)
	self:rebuildHomeBlueprintBuildGroupIndexCache()
	self:loadAllHomeEntities()
	self:refreshOrnamentCountData()
	self:initInteraction()
end

function ClientHomelandOrnamentComponent:loadAllHomeEntities()
	self:destroyAllHomeEntities()
	pg.game.home:createHomeEntities(self.ornament)
	pg.game.home:createLockZones(pg.space.unlockZone)
end

function ClientHomelandOrnamentComponent:destroyAllHomeEntities()
	pg.game.home:destroyHomeEntities()
	pg.game.home:destroyZones()
end

function ClientHomelandOrnamentComponent:initInteraction()
	return
end

function ClientHomelandOrnamentComponent:rebuildHomeBlueprintBuildGroupIndexCache()
	table.clear(self.homeBlueprintBuildGroupIndexCache)

	for groupIndex, groupInfo in ipairs(self.homeBlueprintGroupInfo or EMPTY_TABLE) do
		local ornamentIds = groupInfo and groupInfo.ornamentIds

		for _, ornamentId in ipairs(ornamentIds or EMPTY_TABLE) do
			self.homeBlueprintBuildGroupIndexCache[ornamentId] = groupIndex
		end
	end
end

function ClientHomelandOrnamentComponent:getHomeBlueprintBuildGroupByOrnamentId(ornamentId)
	local groupIndex = self.homeBlueprintBuildGroupIndexCache[ornamentId]

	if not groupIndex then
		return
	end

	local groupInfo = self.homeBlueprintGroupInfo and self.homeBlueprintGroupInfo[groupIndex]

	if not groupInfo or not groupInfo.ornamentIds then
		return
	end

	return groupIndex, groupInfo
end

function ClientHomelandOrnamentComponent:on_homeBlueprintGroupInfo_changed()
	self:rebuildHomeBlueprintBuildGroupIndexCache()
end

function ClientHomelandOrnamentComponent:onOrnamentDataChanged(key, ornamentInfo)
	pg.game.home:updateHomeEntity(key, ornamentInfo)
	self:refreshOrnamentCountData()
	facade:sendMsgToUI(MessageName.HOMELAND_ORNAMENT_CHANGED, {
		ornamentId = key
	})
	self:postComponentMethod("EVENT_onOrnamentChanged", key)
end

function ClientHomelandOrnamentComponent:onOrnamentDataAdded(k, ornamentInfo)
	pg.game.home:createHomeEntity(k, ornamentInfo)
	self:refreshOrnamentCountData()
	facade:sendMsgToUI(MessageName.HOMELAND_ORNAMENT_CHANGED, {
		ornamentId = k
	})
	self:postComponentMethod("EVENT_onOrnamentAdd", k)
end

function ClientHomelandOrnamentComponent:onOrnamentDataDeleted(k)
	pg.game.home:destroyHomeEntityById(k)
	self:refreshOrnamentCountData()
	facade:sendMsgToUI(MessageName.HOMELAND_ORNAMENT_CHANGED, {
		ornamentId = k
	})
	self:postComponentMethod("EVENT_onOrnamentRemove", k)
end

function ClientHomelandOrnamentComponent:refreshOrnamentCountData()
	self.ornamentCountData = {}

	for ornamentId, ornamentInfo in pairs(self.ornament) do
		local homeId = ornamentInfo.homeId

		if homeId then
			self.ornamentCountData[homeId] = (self.ornamentCountData[homeId] or 0) + 1
		end
	end
end

function ClientHomelandOrnamentComponent:_startAddOrnamentLock()
	self._isAddOrnamentRequesting = true

	self:_clearAddOrnamentTimeout()

	self._addOrnamentTimeoutTimer = self:addTimer(ADD_ORNAMENT_REQUEST_TIMEOUT, function()
		self._addOrnamentTimeoutTimer = nil
		self._isAddOrnamentRequesting = false

		logger:error("AddOrnament request timeout, reset lock")
	end)
end

function ClientHomelandOrnamentComponent:_endAddOrnamentLock()
	self._isAddOrnamentRequesting = false

	self:_clearAddOrnamentTimeout()
end

function ClientHomelandOrnamentComponent:_clearAddOrnamentTimeout()
	if self._addOrnamentTimeoutTimer then
		self:removeTimer(self._addOrnamentTimeoutTimer)

		self._addOrnamentTimeoutTimer = nil
	end
end

function ClientHomelandOrnamentComponent:addOrnament(homeTemplateId, position, rotation, scale, buildExtraData, areaId)
	if self._isAddOrnamentRequesting then
		return
	end

	local ornamentInfo = HomeLandUtils.fillOrnamentTransform({
		homeId = homeTemplateId,
		areaId = areaId or 0
	}, position, rotation, scale or Vector3.one)

	self:_startAddOrnamentLock()

	buildExtraData = buildExtraData or {}

	pg.me:serverMsg("RPC_CS_AddOrnament", ornamentInfo, buildExtraData, CallbackHandler(self, "onAddOrnamentCallback"))
end

function ClientHomelandOrnamentComponent:onAddOrnamentCallback(code, ornamentId, homeId)
	self:_endAddOrnamentLock()
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.ADD)
end

function ClientHomelandOrnamentComponent:addOrnaments(ornamentsData, buildExtraData)
	if self._isAddOrnamentRequesting then
		return
	end

	local ornamentsInfo = {}

	for _, ornamentData in pairs(ornamentsData) do
		local ornamentInfo = HomeLandUtils.fillOrnamentTransform({
			homeId = ornamentData.homeTemplateId,
			clientOrnamentId = ornamentData.clientOrnamentId,
			areaId = ornamentData.areaId or 0
		}, ornamentData.position, ornamentData.rotation, ornamentData.scale or Vector3.one)

		table.insert(ornamentsInfo, ornamentInfo)
	end

	self:_startAddOrnamentLock()

	buildExtraData = buildExtraData or {}

	pg.me:serverMsg("RPC_CS_AddOrnaments", ornamentsInfo, buildExtraData, CallbackHandler(self, "onAddOrnamentsCallback"))
end

function ClientHomelandOrnamentComponent:onAddOrnamentsCallback(code, ornamentId, homeId)
	self:_endAddOrnamentLock()
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.ADD)
end

function ClientHomelandOrnamentComponent:removeOrnament(ornamentId)
	if not pg.me or not self.ornament[ornamentId] or not pg.me:checkHomelandRemoveOrnament(ornamentId, self.ornament[ornamentId]) then
		self:onRemoveOrnamentCallback({
			code = Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_NOT_EXIST
		})

		return
	end

	pg.me:serverMsg("RPC_CS_RemoveOrnament", ornamentId, CallbackHandler(self, "onRemoveOrnamentCallback"))
end

function ClientHomelandOrnamentComponent:onRemoveOrnamentCallback(code, ornamentId)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.REMOVE)
end

function ClientHomelandOrnamentComponent:removeOrnaments(ornamentIds)
	if not pg.me or not ornamentIds then
		self:onRemoveOrnamentsCallback({
			code = Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_NOT_EXIST
		})

		return
	end

	for _, ornamentId in pairs(ornamentIds) do
		if not self.ornament[ornamentId] or not pg.me:checkHomelandRemoveOrnament(ornamentId, self.ornament[ornamentId]) then
			self:onRemoveOrnamentsCallback({
				code = Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_NOT_EXIST
			})

			return
		end
	end

	pg.me:serverMsg("RPC_CS_RemoveOrnaments", ornamentIds, CallbackHandler(self, "onRemoveOrnamentsCallback"))
end

function ClientHomelandOrnamentComponent:onRemoveOrnamentsCallback(code, ornamentId)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.REMOVE)
end

function ClientHomelandOrnamentComponent:updateOrnament(ornamentId, position, rotation, scale, buildExtraData)
	local ornamentInfo = HomeLandUtils.fillOrnamentTransform({}, position, rotation, scale)

	buildExtraData = buildExtraData or {}

	pg.me:serverMsg("RPC_CS_UpdateOrnament", ornamentId, ornamentInfo, buildExtraData, CallbackHandler(self, "onUpdateOrnamentCallback"))
end

function ClientHomelandOrnamentComponent:onUpdateOrnamentCallback(code, ornamentId)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.UPDATE)
end

function ClientHomelandOrnamentComponent:updateOrnaments(updateDict, buildExtraData)
	local ornamentUpdateInfo = {}

	for ornamentId, ornamentInfo in pairs(updateDict) do
		local updateInfo = HomeLandUtils.fillOrnamentTransform({}, ornamentInfo.position, ornamentInfo.rotation, ornamentInfo.scale)

		updateInfo.clientOrnamentId = ornamentInfo.clientOrnamentId
		ornamentUpdateInfo[ornamentId] = updateInfo
	end

	buildExtraData = buildExtraData or {}

	pg.me:serverMsg("RPC_CS_UpdateOrnaments", ornamentUpdateInfo, buildExtraData, CallbackHandler(self, "onUpdateOrnamentsCallback"))
end

function ClientHomelandOrnamentComponent:onUpdateOrnamentsCallback(code, ornamentId)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.UPDATE)
end

function ClientHomelandOrnamentComponent:liftOrnaments(liftDict)
	local liftInfo = {}

	for ornamentId, posY in pairs(liftDict) do
		liftInfo[ornamentId] = math.round(posY * 100)
	end

	pg.me:serverMsg("RPC_CS_LiftOrnaments", liftInfo, CallbackHandler(self, "onLiftOrnamentsCallback"))
end

function ClientHomelandOrnamentComponent:onLiftOrnamentsCallback(code, ornamentId)
	if code ~= Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS then
		pg.me:showOrnamentNotice(code)
	end
end

function ClientHomelandOrnamentComponent:upgradeOrnament(ornamentId, upgradeTemplateId, isInBatch, fromScene)
	pg.me:serverMsg("RPC_CS_UpgradeOrnament", ornamentId, upgradeTemplateId, CallbackHandler(self, "onUpgradeOrnamentCallback", upgradeTemplateId, isInBatch, fromScene))
end

function ClientHomelandOrnamentComponent:onUpgradeOrnamentCallback(upgradeTemplateId, isInBatch, fromScene, code, ornamentId)
	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	if not isSucc then
		pg.me:showOrnamentNotice(code)
	end

	if isSucc then
		facade:sendMsgToUI(MessageName.HOMELAND_LEVEL_UP_SUCC, {
			ornamentId = ornamentId
		})

		local _, toLevel = Utils.getHomeOrnamentCurLevelInfo(upgradeTemplateId)

		GlobalData.BILogger:customeLog("home_placement_level_up", {
			placement_id = tostring(upgradeTemplateId),
			to_level = toLevel or 0,
			is_in_batch = isInBatch and 1 or 0,
			from_scene = fromScene or "homeland"
		})
	end
end

function ClientHomelandOrnamentComponent:cleanTrash(ornamentId)
	pg.me:serverMsg("RPC_CS_CleanTrash", ornamentId, CallbackHandler(self, "onCleanTrashCallback"))
end

function ClientHomelandOrnamentComponent:onCleanTrashCallback(code, ornamentId)
	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	if not isSucc then
		pg.me:showOrnamentNotice(code)

		return
	end
end

function ClientHomelandOrnamentComponent:isTrashOrnament(ornamentId)
	local ornamentInfo = self.ornament[ornamentId]

	if not ornamentInfo then
		return false
	end

	local trashId = ornamentInfo.trashId

	if not trashId or trashId == 0 then
		return false
	end

	return true
end

return ClientHomelandOrnamentComponent
