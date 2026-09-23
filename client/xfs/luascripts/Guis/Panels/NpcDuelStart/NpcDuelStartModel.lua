-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcDuelStart\\NpcDuelStartModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("NpcDuelStartModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local NpcDuelStartModel = Class.LightClass("NpcDuelStartModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")

NpcDuelStartModel.RENAME_FOR_GROUP = 0

function NpcDuelStartModel:getCurPetFormation()
	local petFormations = LuaUIUtils.getAllPetFormationsWithEmpty(true)

	return petFormations[pg.me.curPetFormationIndex] or {}
end

function NpcDuelStartModel:getGroupNameInfo(idx)
	return pg.global.ui.petManagement.model:getGroupNameInfo(idx)
end

function NpcDuelStartModel:getSelectGroupId()
	return pg.global.ui.petManagement.model:getSelectGroupId()
end

function NpcDuelStartModel:getGroupInfos()
	return pg.global.ui.petManagement.model:getGroupInfos()
end

function NpcDuelStartModel:getCpValue(id)
	return pg.global.ui.petManagement.model:getCpValue(id)
end

return NpcDuelStartModel
