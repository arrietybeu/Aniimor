-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FunMenuExit\\FunMenuExitModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("FunMenuExitModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local BossRushUtils = require("Utils.BossRushUtils")
local CommonSwitch = require("Common.CommonSwitch")
local FuncMenuData = require("Data.func_menu_data")
local FuncMenuCommonData = require("Data.func_menu_common_use_data")
local SceneData = require("Data.scene_data")
local FunMenuExitModel = Class.LightClass("FunMenuExitModel", UIModel)

function FunMenuExitModel:getCurConfigId()
	local configId = 1

	if pg.me.space and SceneData[pg.me.space.sceneId].funcListId then
		configId = SceneData[pg.me.space.sceneId].funcListId
	end

	return configId
end

function FunMenuExitModel:getCurFuncConfig()
	local configId = self:getCurConfigId()
	local funcCfg = FuncMenuData[configId]

	return funcCfg
end

function FunMenuExitModel:checkShowEscKeyCode()
	if self:isFastQuit() then
		return true
	end

	return false
end

function FunMenuExitModel:isFastQuit()
	local configId = self:getCurConfigId()
	local funcCfg = FuncMenuData[configId]

	if not funcCfg then
		return true
	end

	return pg.me:isInLeaderWorld() and not Utils.isScenePhoto() or funcCfg.mode == 3
end

function FunMenuExitModel:checkShowFunc()
	local configId = self:getCurConfigId()
	local funcCfg = FuncMenuData[configId]

	if pg.me and pg.me.isInRiftMode and pg.me:isInRiftMode() then
		return false, false
	end

	if not funcCfg then
		return true, false
	end

	local isCamp = pg.space and pg.space:isHomeCamp()

	if pg.me:isInLeaderWorld() and not Utils.isScenePhoto() and not isCamp or funcCfg.mode == 3 then
		return true, true
	end

	return funcCfg.mode == 1, funcCfg.mode == 2
end

function FunMenuExitModel:getExitDesc()
	local configId = self:getCurConfigId()
	local funcCfg = FuncMenuData[configId]

	if not funcCfg then
		return nil
	end

	return pg.getGameString(funcCfg.exitTxt) or nil
end

function FunMenuExitModel:getFuncListData()
	local funcCfg = self:getCurFuncConfig()

	if not funcCfg then
		return
	end

	local funcList = {}

	funcList[1] = {
		cfg = FuncMenuCommonData[4]
	}
	funcList[2] = {
		cfg = FuncMenuCommonData[13]
	}
	funcList[3] = {
		cfg = FuncMenuCommonData[5]
	}
	funcList[4] = {
		cfg = FuncMenuCommonData[14]
	}
	funcList[5] = {
		cfg = FuncMenuCommonData[9]
	}

	if funcCfg.showInformationButton == 1 then
		funcList[6] = {
			cfg = FuncMenuCommonData[10]
		}
	else
		funcList[6] = {
			cfg = FuncMenuCommonData[3]
		}
	end

	return funcList
end

function FunMenuExitModel:checkStopGameTime()
	if pg.me.space:isCatchRogue() then
		return true
	elseif pg.me.space:isBossRushEnv() then
		return not pg.me:isInTeam()
	elseif pg.me.space:isRogueEnv() then
		return true
	elseif pg.me.space:isNpcDuel() then
		return true
	elseif pg.me.space:isPVEDungeon() then
		return true
	elseif Utils.isSpaceFishingCaptureDungeon(pg.me.space.spaceType) then
		return true
	end

	return false
end

return FunMenuExitModel
