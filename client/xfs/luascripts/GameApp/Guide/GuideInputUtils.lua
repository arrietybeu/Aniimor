-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Guide\\GuideInputUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local GuideInputUtils = {}

GuideInputUtils.NEXT_STEP_KEYBOARD_ACTION = "Common/Space"
GuideInputUtils.NEXT_STEP_GAMEPAD_ACTION = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth
GuideInputUtils.NEXT_STEP_KEYBOARD_INPUT = "<Keyboard>/space"
GuideInputUtils.NEXT_STEP_GAMEPAD_INPUT = "<Gamepad>/buttonSouth"
GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel
GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonEast
GuideInputUtils.GROUP_SKIP_GAMEPAD_HOLD_TIME = 0.55
GuideInputUtils.GROUP_SKIP_GAMEPAD_PROGRESS_START_TIME = 0.25

local function resetGroupSkipProgress(ctrl)
	if NotNil(ctrl.groupSkipKeyProgress) then
		ctrl.groupSkipKeyProgress:ProgressToValue(0, nil, 0)
	end
end

function GuideInputUtils.getNextStepActionPath()
	if pg.game.input:isUsingGamepad() then
		return GuideInputUtils.NEXT_STEP_GAMEPAD_ACTION
	end

	return GuideInputUtils.NEXT_STEP_KEYBOARD_ACTION
end

function GuideInputUtils.getNextStepInputPath()
	if pg.game.input:isUsingGamepad() then
		return GuideInputUtils.NEXT_STEP_GAMEPAD_INPUT
	end

	return GuideInputUtils.NEXT_STEP_KEYBOARD_INPUT
end

function GuideInputUtils.getGroupSkipActionPath()
	if pg.game.input:isUsingGamepad() then
		return GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION
	end

	return GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION
end

function GuideInputUtils.addNextStepBindings(ctrl, gameObject, bindingPrefix, priority, beforeHandled)
	local function addBinding(suffix, actionPath)
		local binding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, bindingPrefix .. suffix)

		binding.isVirtual = true
		binding.priority = priority
		binding.actionPath = actionPath

		function binding.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" and actionPath == GuideInputUtils.getNextStepActionPath() and ctrl:isNextStepEnabled() then
				if beforeHandled ~= nil then
					beforeHandled()
				end

				return false
			end

			return true
		end
	end

	addBinding("KeyboardBind", GuideInputUtils.NEXT_STEP_KEYBOARD_ACTION)
	addBinding("GamepadBind", GuideInputUtils.NEXT_STEP_GAMEPAD_ACTION)
end

function GuideInputUtils.addGamepadGroupSkipBinding(ctrl, gameObject, bindingName)
	local binding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, bindingName)

	binding.isVirtual = true
	binding.priority = 102
	binding.actionPath = GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION

	function binding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and pg.game.input:isUsingGamepad() and ctrl.groupSkipInputBlocked then
			GuideInputUtils.clearGroupSkipHoldTimer(ctrl)

			ctrl.groupSkipGamepadPressConsumed = true

			if ctrl.groupSkipEnabled then
				ctrl.groupSkipHoldTime = 0

				resetGroupSkipProgress(ctrl)

				ctrl.groupSkipHoldTimer = ctrl:startTimer(function()
					if not ctrl.groupSkipEnabled then
						GuideInputUtils.clearGroupSkipHoldTimer(ctrl)

						return
					end

					ctrl.groupSkipHoldTime = ctrl.groupSkipHoldTime + Time.unscaledDeltaTime

					if ctrl.groupSkipHoldTime > GuideInputUtils.GROUP_SKIP_GAMEPAD_PROGRESS_START_TIME and NotNil(ctrl.groupSkipKeyProgress) then
						local progress = (ctrl.groupSkipHoldTime - GuideInputUtils.GROUP_SKIP_GAMEPAD_PROGRESS_START_TIME) / (GuideInputUtils.GROUP_SKIP_GAMEPAD_HOLD_TIME - GuideInputUtils.GROUP_SKIP_GAMEPAD_PROGRESS_START_TIME)

						ctrl.groupSkipKeyProgress:ProgressToValue(math.min(math.max(progress, 0), 1), nil, 0)
					end

					if ctrl.groupSkipHoldTime >= GuideInputUtils.GROUP_SKIP_GAMEPAD_HOLD_TIME and ctrl.groupSkipEnabled then
						GuideInputUtils.clearGroupSkipHoldTimer(ctrl)
						GuideInputUtils.onGroupSkipClick(ctrl)
					end
				end, 0, true)
			end

			return false
		elseif inputInfo.phase == "Canceled" and ctrl.groupSkipGamepadPressConsumed then
			GuideInputUtils.clearGroupSkipHoldTimer(ctrl)

			ctrl.groupSkipGamepadPressConsumed = false

			return false
		end

		return true
	end
end

function GuideInputUtils.showGroupSkip(ctrl, logger, guideId, stepId)
	ctrl.groupSkipEnabled = true

	if logger ~= nil and LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[GuideGroupSkip] enabled", guideId, stepId)
	end

	ctrl.view.skipNode:SetUrlWithCallback("$UI_Node_Guide_Skip.prefab", function(content)
		if ctrl.view == nil then
			return
		end

		if not ctrl.groupSkipEnabled then
			ctrl.view.skipNode:DestroyContent()

			return
		end

		local objectReference = content.transform:GetComponent("ObjectReference")
		local btnSkip = objectReference:GetRefValue("btnSkip")
		local txtButtonSkip = objectReference:GetRefValue("txtButtonSkip")

		ctrl.groupSkipKeyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		ClientTextUtils.setText(txtButtonSkip, pg.getLocalizationText(pg.getGameString("SKIP_GROUP_GUIDE")))
		GuideInputUtils.refreshGroupSkipHotKeyContent(ctrl)
		LuaUIUtils.waitHotKeyContentObjectReference(ctrl, ctrl.groupSkipKeyHotKeyContent, function(keyObjectReference)
			if not ctrl.groupSkipEnabled then
				return
			end

			local progressContainer = keyObjectReference:GetRefValue("progressPressContainerUContainer")

			if not progressContainer then
				return
			end

			ctrl.groupSkipProgressContainer = progressContainer

			progressContainer:SetActive(pg.game.input:isUsingGamepad())
			progressContainer:LoadDefaultUrlManually(function()
				if not ctrl.groupSkipEnabled then
					return
				end

				ctrl.groupSkipKeyProgress = progressContainer.content

				resetGroupSkipProgress(ctrl)
			end)
		end)

		function btnSkip.luaClick()
			GuideInputUtils.onGroupSkipClick(ctrl)
		end
	end)
end

function GuideInputUtils.refreshGroupSkipHotKeyContent(ctrl)
	if NotNil(ctrl.groupSkipKeyHotKeyContent) then
		ctrl.groupSkipKeyHotKeyContent:SetHotKeyPaths(GuideInputUtils.getGroupSkipActionPath())
	end

	if NotNil(ctrl.groupSkipProgressContainer) then
		ctrl.groupSkipProgressContainer:SetActive(pg.game.input:isUsingGamepad())
	end
end

function GuideInputUtils.clearGroupSkipUI(ctrl)
	ctrl.groupSkipEnabled = false

	resetGroupSkipProgress(ctrl)

	ctrl.groupSkipKeyHotKeyContent = nil
	ctrl.groupSkipProgressContainer = nil
	ctrl.groupSkipKeyProgress = nil

	if ctrl.view ~= nil and NotNil(ctrl.view.skipNode) then
		ctrl.view.skipNode:DestroyContent()
	end
end

function GuideInputUtils.clearGroupSkipHoldTimer(ctrl)
	if ctrl.groupSkipHoldTimer then
		ctrl:killTimer(ctrl.groupSkipHoldTimer)

		ctrl.groupSkipHoldTimer = nil
	end

	ctrl.groupSkipHoldTime = 0

	resetGroupSkipProgress(ctrl)
end

function GuideInputUtils.onGroupSkipClick(ctrl)
	if not ctrl.groupSkipEnabled or ctrl.stepInfo == nil or ctrl.stepInfo.onSkipGroup == nil then
		return false
	end

	GuideInputUtils.clearGroupSkipHoldTimer(ctrl)

	ctrl.groupSkipEnabled = false

	ctrl.stepInfo.onSkipGroup()

	return true
end

return GuideInputUtils
