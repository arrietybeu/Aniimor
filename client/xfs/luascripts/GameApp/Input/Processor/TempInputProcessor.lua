-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\TempInputProcessor.lua

local CommonConst = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local ReloadScheduler = require("Core.Common.ReloadScheduler")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local logger = LoggerManager.getLogger("TempInputProcessor")
local GmToolUtils = require("Utils.GmToolUtils")
local TempInputProcessor = Class.LightClass("TempInputProcessor", BaseInputProcessor)

function TempInputProcessor:ctor(path)
	BaseInputProcessor.ctor(self, path)
end

function TempInputProcessor:onInit()
	BaseInputProcessor.onInit(self)

	self.actionMapKey = HotkeyConst.INPUT_MAP_ACTION_KEY.Temp

	if not TempInputProcessor._joyInstalled then -- [JOYSTICK] show virtual joystick on PC
		TempInputProcessor._joyInstalled = true
		local TM = require("Core.Timer.TimerManager")
		TM.addRepeatTimer(0.1, function()
			TempInputProcessor._joyTick = (TempInputProcessor._joyTick or 0) + 1
			if TempInputProcessor._joyTick == 50 then
				local ok, err = pcall(function()
					if pg.global.ui.mobileOperate then
						pg.global.ui.mobileOperate:open()
					else
						pg.global.ui:open(UIConst.UI_ID_HUD_MOBILE_OPERATE)
					end
				end)
				print("[JOYSTICK] open ok=" .. tostring(ok) .. " err=" .. tostring(err))
			end
		end)
	end
end

function TempInputProcessor:handleActionTriggered(inputInfo)
	if inputInfo.actionName == "OpenDebugPanel" then
		return self:handleOpenDebugPanelAction(inputInfo)
	elseif inputInfo.actionName == "BugReport" then
		return self:handleBugReportAction(inputInfo)
	elseif inputInfo.actionName == "SavePhotoParam" then
		return self:handleSavePhotoParamAction(inputInfo)
	elseif inputInfo.actionName == "OpenPV" then
		return self.handleOpenPVPanelAction(inputInfo)
	elseif inputInfo.actionName == "OpenDof" then
		return self.handleCameraDofAction(inputInfo)
	elseif inputInfo.actionName == "HiddenUI" then
		return self.handleHiddenUIAction(inputInfo)
	elseif inputInfo.actionName == "TeleportWithMouse" then
		return self:handleTeleportWithMouseAction(inputInfo)
	else
		return BaseInputProcessor.handleActionTriggered(self, inputInfo)
	end
end

function TempInputProcessor.checkHasGM()
	if pg.me then
		return Utils.enableClientUseGm(pg.me)
	else
		return false
	end
end

function TempInputProcessor:handleChangeEntityModelViewAction(inputInfo)
	return
end

function TempInputProcessor:handleTeleportWithMouseAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("@zq TempInputProcessor onInit")
		end

		if (UNITY_EDITOR or GmToolUtils.quickMoveEnabled) and pg.me ~= nil then
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_MAP) then
				pg.global.ui.map:debugQuickMove(UnityInput.mousePosition)
			else
				local pos = pg.me.eModel:TeleportWithMouse(CommonConst.COMPONENT_INDEX_MAIN_PLAYER)

				ClientUtils.teleportPos(pos)
			end
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleTeleportWithPositionAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		if (UNITY_EDITOR or GmToolUtils.quickMoveEnabled) and pg.me ~= nil then
			local pos = pg.me.eModel:TeleportWithPosition(CommonConst.COMPONENT_INDEX_MAIN_PLAYER)

			ClientUtils.teleportPos(pos)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:switchScenes(scene1, scene2)
	local sceneIds = {
		scene1,
		scene2
	}
	local index = 1

	if pg.me ~= nil then
		local currentSceneId = pg.me.sceneId

		for k, v in ipairs(sceneIds) do
			if v == currentSceneId then
				index = k % #sceneIds + 1

				pg.me:serverMsg("RPC_CS_TeleportScene", sceneIds[index])
			end
		end
	end
end

function TempInputProcessor:handleSwitchSceneAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if UNITY_EDITOR then
			self:switchScenes(251, 100)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSwitchTrainingSceneAction(inputInfo)
	if inputInfo.phase == "Performed" then
		self:switchScenes(259, 100)
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleExploreTutorialLevelAction(inputInfo)
	if inputInfo.phase == "Performed" then
		self:switchScenes(104, 100)
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleBattleTutorialLevel1Action(inputInfo)
	if inputInfo.phase == "Performed" then
		self:switchScenes(105, 100)
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSwitchGMAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			local flag = 0

			if pg.me.gmMode == 0 then
				flag = 1
			end

			if pg.me.doGmCmd == nil then
				if FREE_WALK and LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info("@fjs FREE_WALK mode: pg.me.doGmCmd == nil")
				end
			else
				pg.me:doGmCmd("setGmMode", flag)
			end
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleRefreshEntityAction(inputInfo)
	return
end

function TempInputProcessor:handleDeleteAllEntityAction(inputInfo)
	return
end

function TempInputProcessor:handleTestAction(inputInfo)
	return
end

function TempInputProcessor:handleSwitchAvatarAction(inputInfo)
	if inputInfo.phase == "Performed" then
		local me = pg.me
		local templateIds = {
			5,
			3,
			4,
			3001,
			3002
		}
		local templateIdCount = #templateIds

		if me then
			for k, v in pairs(templateIds) do
				if v == me.templateId then
					local index = (k - 1 + 1) % templateIdCount

					me.templateId = templateIds[index + 1]

					break
				end
			end

			me:onConfigDataChange()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSwitchDrawSpeedLineAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			Switch.EnableDrawSpeedCurve = not Switch.EnableDrawSpeedCurve
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSummonMonster0Action(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:doGmCmd("createPuppet", 9999, 2)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSummonMonster1Action(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:doGmCmd("createPuppet", 10000, 2)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSummonMonster2Action(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:doGmCmd("createPuppet", 10001, 2)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleChangeWeapon1Action(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:ChangeWeaponByID("Claymore_01_None", 1)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleChangeWeapon2Action(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:ChangeWeaponByID("Claymore_01_Fire", 1)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleRefreshAllScriptsAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if UNITY_EDITOR then
			if pg.game.input:isUsingGamepad() then
				pg.global.inputMgr.gamepadDebug = not pg.global.inputMgr.gamepadDebug

				return
			end

			ClientUtils.reloadRecentFiles()
			pg.global.abilityMgr:clear()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleOpenDebugPanelAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_CONFIG) then
			pg.global.ui:close(UIConst.UI_ID_CONFIG)
			pg.global.ui:open(UIConst.UI_ID_CONFIG_TOPPING)
		else
			pg.global.ui:open(UIConst.UI_ID_CONFIG)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleBugReportAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_CONFIG_TOPPING) then
			pg.global.ui:close(UIConst.UI_ID_CONFIG_TOPPING)
		end

		pg.global.mobileCameraMgr:CaptureScreenDelaySaveCopy(function(sprite)
			table.insert(GmToolUtils.bugReportImageList, sprite)
			pg.global.ui:open(UIConst.UI_ID_CONFIG, {
				selectedIndex = GmToolUtils.FuncTabLabel.BugReport
			})
		end)
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleLoseConnectTestAction(inputInfo)
	if inputInfo.phase == "Performed" then
		pg.me:doGmCmd2("loseConnectTest", {
			5
		})
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleDelentrAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:doGmCmd("killEntInRange", 5, 0)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleMiddleViewAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.game.camera:middleView()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSlomoAction(inputInfo)
	return
end

function TempInputProcessor:handleToggleGameFullScreenAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.global.gameMgr:IsFullScreenWindow() then
			pg.global.gameMgr:SetBorderWindow()
		else
			pg.global.gameMgr:SetFullScreenWindow()
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleGamepadCaptureScreenAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if not pg.game.setting:getEnableGamepadDebugCapture() then
			return true
		end

		pgUtils.CaptureScreenShot()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleGamepadCaptureScreenActionCanceled(inputInfo)
	if inputInfo.phase == "Performed" then
		if not pg.game.setting:getEnableGamepadDebugCapture() then
			return true
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleQuickSwitchPetSkillGMAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.me ~= nil then
			pg.me:doGmCmd("quickSwitchCurPetSkill")
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor:handleSavePhotoParamAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
			pg.global.ui:open(UIConst.UI_ID_CONFIG, {
				selectedIndex = GmToolUtils.FuncTabLabel.Photo
			})
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor.handleOpenPVPanelAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_CONFIG_TOPPING) then
			pg.global.ui:close(UIConst.UI_ID_CONFIG_TOPPING)
		end

		pg.global.ui:open(UIConst.UI_ID_CONFIG, {
			selectedIndex = GmToolUtils.FuncTabLabel.PVHelper
		})
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor.handleCameraDofAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		GmToolUtils.GmDofState = not GmToolUtils.GmDofState
		GmToolUtils.GmDofObj = pg.game.camera:setDofEnable("GM", GmToolUtils.GmDofState)

		if GmToolUtils.GmDofState and GmToolUtils.GmDofObj ~= nil then
			pgUtils.SetDofPriority(GmToolUtils.GmDofObj, 10)
			CS.FunPlus.WorldX.Utils.Utils.EnableDofUpdate(GmToolUtils.GmDofObj)
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function TempInputProcessor.handleHiddenUIAction(inputInfo)
	if not self.checkHasGM() then
		return
	end

	if inputInfo.phase == "Performed" then
		local flag = CS.XGUI.UWidget.uiCamera.enabled

		if flag then
			CS.XGUI.UWidget.uiCamera.enabled = false

			facade:SendMessageCommand(MessageName.HIDDEN_UI)
		else
			CS.XGUI.UWidget.uiCamera.enabled = true
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

return TempInputProcessor
