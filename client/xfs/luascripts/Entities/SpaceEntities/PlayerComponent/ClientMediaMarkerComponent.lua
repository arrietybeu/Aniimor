-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientMediaMarkerComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Const = require("Common.Const.Const")
local json = require("json")
local MessageName = require("Const.MessageName")
local ClientMediaMarkerComponent = class.Component("ClientMediaMarkerComponent")

function ClientMediaMarkerComponent:ctor()
	return
end

function ClientMediaMarkerComponent:init(avtDict)
	return true
end

function ClientMediaMarkerComponent:destroy()
	return
end

function ClientMediaMarkerComponent:onEnterSpaceInner()
	pg.game.markShare:refreshAroundInfoStamp()
end

function ClientMediaMarkerComponent:addMediaMarker(type, content)
	if type <= Const.MediaMarkerType._MinTextNum or type >= Const.MediaMarkerType._MaxTextNum then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("addMediaMarker type=%s error", type)
		end

		return
	end

	if content.pos == nil or #content.pos ~= 3 and #content.pos ~= 4 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("addMediaMarker content error, content=%s", content)
		end

		return
	end

	self:serverMsg("RPC_CS_AddMediaMarker", type, content)
end

function ClientMediaMarkerComponent:RPC_SC_AddMediaMarkerRet(markerId, type, jsonContent, encourageDays)
	local content = json.decode(jsonContent)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_AddMediaMarkerRet===: %s, %s, %s, %s", markerId, type, inspect(content), encourageDays)
	end

	facade:SendMessageCommand(MessageName.ON_ADD_INFO_STAMP_SUCCESS, {
		markerId = markerId,
		encourageDays = encourageDays
	})
	pg.game.audio:triggerEvent("SFX_UI_SendMessage")
end

function ClientMediaMarkerComponent:removeMediaMarker(markerId)
	self:serverMsg("RPC_CS_RemoveMediaMarker", markerId)
end

function ClientMediaMarkerComponent:setMediaMarkerView(setting)
	if type(setting) ~= "number" or setting < Const.MARKER_SETTINGS.DEFAULT or setting > Const.MARKER_SETTINGS.STRANGER_HIDE then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("setMediaMarkerView setting=%s error", setting)
		end

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_CS_SetMediaMarkerView setting=%s", setting)
	end

	self:serverMsg("RPC_CS_SetMediaMarkerView", setting)
end

function ClientMediaMarkerComponent:RPC_SC_RemoveMediaMarkerRet(markerId)
	facade:SendMessageCommand(MessageName.ON_DELETE_INFO_STAMP_SUCCESS, {
		markerId = markerId
	})
	pg.game.audio:triggerEvent("SFX_UI_DeleteMessages")
end

function ClientMediaMarkerComponent:likeMediaMarker(markerId, posIndex)
	self:serverMsg("RPC_CS_LikeMediaMarker", markerId, posIndex)
end

function ClientMediaMarkerComponent:likeSysMediaMarker(markerId, pos2)
	local infoStampGroup = pg.game.markShare.aroundMarkInfoStampGroup[markerId]

	if not infoStampGroup then
		return
	end

	if not infoStampGroup.posIndex then
		self:serverMsg("RPC_CS_LikeSysMediaMarker", markerId, pos2)
	else
		self:likeMediaMarker(markerId, infoStampGroup.posIndex)
	end
end

function ClientMediaMarkerComponent:RPC_SC_LikeMediaMarkerRet(markerId, likes, dislikes, encourageDays, isPermanent)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_LikeMediaMarkerRet===: %s, %s, %s, %s, %s", markerId, likes, dislikes, encourageDays, isPermanent)
	end

	facade:SendMessageCommand(MessageName.ON_INFO_STAMP_BE_LIKED, {
		markerId = markerId,
		likes = likes,
		encourageDays = encourageDays,
		isPermanent = isPermanent
	})
	pg.game.audio:triggerEvent("SFX_UI_Like")
end

function ClientMediaMarkerComponent:dislikeMediaMarker(markerId, posIndex)
	self:serverMsg("RPC_CS_DislikeMediaMarker", markerId, posIndex)
end

function ClientMediaMarkerComponent:dislikeSysMediaMarker(markerId, pos2)
	local infoStampGroup = pg.game.markShare.aroundMarkInfoStampGroup[markerId]

	if not infoStampGroup then
		return
	end

	if not infoStampGroup.posIndex then
		self:serverMsg("RPC_CS_DislikeSysMediaMarker", markerId, pos2)
	else
		self:dislikeMediaMarker(markerId, infoStampGroup.posIndex)
	end
end

function ClientMediaMarkerComponent:RPC_SC_DislikeMediaMarkerRet(markerId, likes, dislikes)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_DislikeMediaMarkerRet===: %s, %s, %s", markerId, likes, dislikes)
	end
end

function ClientMediaMarkerComponent:batchFindMediaMarker(markerIds)
	if #markerIds <= 0 then
		return
	end

	if #markerIds > 10 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("batchFindMediaMarker params len max 10")
		end

		return
	end

	if #markerIds == 1 then
		self:callService("MediaMarkerService", "findMarkerById", {
			markerIds[1]
		}, CallbackHandler(self, "findMarkerByIdCb", markerIds[1]), {
			hint = markerIds[1]
		})

		return
	end

	self:callService("MediaMarkerService", "batchFindMarker", {
		{},
		markerIds,
		{}
	}, CallbackHandler(self, "batchFindMediaMarkerCb"), {
		hint = markerIds[1]
	})
end

function ClientMediaMarkerComponent:batchFindMediaMarkerCb(retStatus, response)
	if not retStatus.status then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("batchFindMediaMarkerCb error, err=%s", retStatus.errmsg)
		end

		return
	end

	if response.ErrorCode ~= "OK" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("batchFindMediaMarkerCb response error, err=%s", response.ErrorCode)
		end

		return
	end

	facade:SendMessageCommand(MessageName.ON_REQUEST_SELF_MARK_INFO, {
		result = true,
		markers = response.Markers
	})
end

function ClientMediaMarkerComponent:findMarkerByIdCb(markerId, retStatus, response)
	if not retStatus.status then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("findMarkerByIdCb error, err=%s", retStatus.errmsg)
		end

		return
	end

	if response.ErrorCode ~= "OK" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("findMarkerByIdCb response error, err=%s", response.ErrorCode)
		end

		return
	end

	local markers = {
		[markerId] = response.Marker
	}

	facade:SendMessageCommand(MessageName.ON_REQUEST_SELF_MARK_INFO, {
		result = true,
		markers = markers
	})
end

return ClientMediaMarkerComponent
