-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIFuncMenuUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local FunctionUnlockUIIdData = require("Data.function_unlock_ui")
local FuncToMenuIdData = require("Data.func_to_menu_id_data")
local NormalFuncToMenuIdData = require("Data.normal_func_to_menu_id_data")
local logger = LoggerManager.getLogger("LuaUIUtils")
local SceneData = require("Data.scene_data")
local FuncMenuData = require("Data.func_menu_data")
local FuncMenuListData = require("Data.func_menu_list_data")
local FuncMenuBottomListData = require("Data.func_menu_common_use_data")
local CommonSwitch = require("Common.CommonSwitch")
local SysNoticeData = require("Data.sys_notice_data")
local NoticeDef = require("Common.NoticeDef")
local SysConfigData = require("Data.sys_config_data")
local HudFuncData = require("Data.hud_func_button_data")
local UIConst = require("Const.UIConst")

return function(LuaUIUtils)
	function LuaUIUtils.getFuncMenuConfigId()
		local configId = 1

		if pg.me.space and SceneData[pg.me.space.sceneId].funcListId then
			configId = SceneData[pg.me.space.sceneId].funcListId
		end

		return configId
	end

	function LuaUIUtils.checkFuncIdInFuncMenu(id)
		return LuaUIUtils.checkFuncIdInFuncMenuMainPanel(id) or LuaUIUtils.checkFuncIdInFuncMenuRightList(id)
	end

	function LuaUIUtils.checkFuncIdInFuncMenuMainPanel(id)
		local funcMenuIds = FuncMenuData[LuaUIUtils.getFuncMenuConfigId()].defaultWidget or {}

		return table.contains(funcMenuIds, id)
	end

	function LuaUIUtils.checkFuncIdInFuncMenuRightList(id)
		local funcMenuIds = FuncMenuData[LuaUIUtils.getFuncMenuConfigId()].defaultFunction or {}

		return table.contains(funcMenuIds, id)
	end

	function LuaUIUtils.checkMarkShareFunc(funcData)
		local funcName = funcData["function"] or funcData.functionType

		if funcName == "markShare" and pg.space and SceneData[pg.space.sceneId] then
			return SceneData[pg.space.sceneId].markShare == 1
		end

		return true
	end

	function LuaUIUtils.checkFuncIdForbidden(id)
		local funcData = FuncMenuListData[id] or FuncMenuBottomListData[id]

		if funcData and funcData.stateDisable then
			local refRet = {}

			if not pg.me:checkStatus(funcData.stateDisable, nil, nil, nil, nil, refRet) then
				local msgData = SysNoticeData[NoticeDef.STATE_CONFLICT_MSG]
				local tip = pg.getLocalizationText(msgData.text, pg.getGameString("SC_" .. refRet.stat), pg.getGameString("SC_" .. funcData.stateDisable))

				return true, tip
			end
		end

		if funcData and not LuaUIUtils.checkMarkShareFunc(funcData) then
			return true, pg.getGameString("DISABLE_MARKSHARE")
		end

		if funcData and funcData.functionName then
			if pg.me:checkFunctionShielded(funcData.functionName) then
				return true
			end

			if not LuaUIUtils.checkFuncUnlockForREVIEW(funcData.functionName) then
				return true
			end
		end

		local forbiddenWidgetIds = FuncMenuData[LuaUIUtils.getFuncMenuConfigId()].defaultWidgetShield or {}
		local forbiddenFunctionIds = FuncMenuData[LuaUIUtils.getFuncMenuConfigId()].defaultFunctionShield or {}

		return table.contains(forbiddenWidgetIds, id) or table.contains(forbiddenFunctionIds, id)
	end

	function LuaUIUtils.checkIsQuitMode(funcId)
		local whitelist = {
			4,
			5,
			9,
			13,
			14,
			81,
			101
		}

		for _, v in ipairs(whitelist) do
			if v == funcId then
				return false
			end
		end

		local funcMode = FuncMenuData[LuaUIUtils.getFuncMenuConfigId()].mode

		return funcMode == 2
	end

	function LuaUIUtils.checkFuncCanOpen(id)
		return LuaUIUtils.checkFuncUnlock(id) and not LuaUIUtils.checkFuncForbidden(id)
	end

	function LuaUIUtils.checkUIFuncValid(uid)
		local funcName = FunctionUnlockUIIdData[uid]

		if funcName then
			if CommonSwitch[funcName] == false then
				pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))

				return false
			end

			local menuId = FuncToMenuIdData[funcName]

			if menuId and not LuaUIUtils.checkFuncCanOpen(menuId) then
				pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))

				return false
			end

			local normalId = NormalFuncToMenuIdData[funcName]

			if normalId and not LuaUIUtils.checkFuncCanOpen(normalId) then
				pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))

				return false
			end
		end

		return true
	end

	function LuaUIUtils.checkFuncForbidden(id)
		local whiteList = SysConfigData.WHITE_LIST_FUNCTION or {}

		for _, func in ipairs(whiteList) do
			if func[2] and func[2] == id then
				return false
			end
		end

		local isForbidden = LuaUIUtils.checkFuncIdForbidden(id)

		if LuaUIUtils.checkFuncIdInFuncMenu(id) and not LuaUIUtils.checkFuncIdInHudList(id) then
			isForbidden = isForbidden or not pg.global.ui.hudV2:checkCanOpenFuncMenu()
		end

		return isForbidden
	end

	function LuaUIUtils.checkFuncIdInHudList(id)
		local sceneId = pg.space and pg.space.sceneId or 0
		local hudButtonIds = HudFuncData[sceneId] and HudFuncData[sceneId].func or {}

		for _, value in ipairs(hudButtonIds) do
			if value[2] == id then
				return true
			end
		end

		return false
	end

	function LuaUIUtils.checkFuncUnlock(funcId)
		local funcName

		if FuncMenuListData[funcId] and FuncMenuListData[funcId].functionName then
			funcName = FuncMenuListData[funcId].functionName
		end

		if FuncMenuBottomListData[funcId] and FuncMenuBottomListData[funcId].functionName then
			funcName = FuncMenuBottomListData[funcId].functionName
		end

		if funcName == "CASHSHOP" and CommonSwitch.ShopMall_All ~= true then
			return false
		end

		if funcName and (not pg.me or not pg.me:checkFunctionUnlock(funcName) or CommonSwitch[funcName] == false) then
			return false
		end

		return true
	end

	function LuaUIUtils.getFuncName(funcId)
		local listData = FuncMenuListData[funcId]

		if listData and listData.name then
			return pg.getLocalizationText(listData.name)
		end
	end

	function LuaUIUtils.checkFuncUnlockForREVIEW(funcName)
		if CommonSwitch.IOS_REVIEW and UIConst.IOS_REVIEW_LOCK_FUNC[funcName] then
			return false
		end

		local _h = LuaUIUtils._platformHooks

		if _h and _h.checkPlatformFuncUnlock and _h.checkPlatformFuncUnlock(funcName) == false then
			return false
		end

		return true
	end

	function LuaUIUtils.getFuncActionPath(funcId)
		local funcCfg = FuncMenuListData[funcId] or FuncMenuBottomListData[funcId]

		if funcCfg then
			return funcCfg.actionPath
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("not find funcId in func_menu_list_data : " .. funcId)
			end

			return nil
		end

		return nil
	end

	function LuaUIUtils.checkFuncTemporaryDisable(id)
		if id == UIConst.UI_ID_SHOP_MAIN then
			local disable = not CommonSwitch.SHOP_OPEN

			if disable then
				pg.global.ui.tips:showTextTip(pg.getGameString("NOTIFY_SERVER_SWITCH"))
			end

			return disable
		end
	end
end
