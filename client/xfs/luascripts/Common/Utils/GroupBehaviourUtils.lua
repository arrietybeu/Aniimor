-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\GroupBehaviourUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local logger = LoggerManager.getLogger("GroupBehaviour")
local GroupBehaviourUtils = {}

function GroupBehaviourUtils._getBehavBindInfo(behav)
	local bindInfo = ""

	if behav.bindResPoint then
		bindInfo = string.format("PointId:%d,%d", behav.bindResPoint.owner.actorId, behav.bindResPoint.pointId)
	elseif behav.bindEnt then
		bindInfo = string.format("ActorId:%d", behav.bindEnt.actorId)
	end

	return bindInfo
end

function GroupBehaviourUtils.LogWithBehav(behav, formatStr, ...)
	if GroupBehaviourConst.OpenLog then
		local bindInfo = GroupBehaviourUtils._getBehavBindInfo(behav)

		formatStr = string.format("[Behav][Type:%s][Name:%s][%s] %s", behav.className, tostring(behav.behaviourName), bindInfo, formatStr)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info(formatStr, ...)
		end
	end
end

function GroupBehaviourUtils.LogWithTache(tache, formatStr, ...)
	if GroupBehaviourConst.OpenLog then
		local bindInfo = GroupBehaviourUtils._getBehavBindInfo(tache.owner)

		formatStr = string.format("\t[Tache][Type:%s][ID:%d][%s] %s", tache.className, tache._stateEnum, bindInfo, formatStr)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info(formatStr, ...)
		end
	end
end

function GroupBehaviourUtils.LogError(...)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(...)
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(debug.traceback())
	end
end

return GroupBehaviourUtils
