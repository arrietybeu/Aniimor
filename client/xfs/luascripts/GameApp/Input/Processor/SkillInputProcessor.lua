-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\SkillInputProcessor.lua

local Time = require("Core.Common.Time")
local CombatContext = require("Common.Ability.CombatContext")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local TimerManager = require("Core.Timer.TimerManager")
local SkillInputProcessor = Class.LightClass("SkillInputProcessor", BaseInputProcessor)

function SkillInputProcessor:ctor(path)
	BaseInputProcessor.ctor(self, path)

	self.keyRecordMap = {}
	self.lockTargetTimer = nil
end

function SkillInputProcessor:onInit()
	BaseInputProcessor.onInit(self)

	self.actionMapKey = HotkeyConst.INPUT_MAP_ACTION_KEY.Skill
end

function SkillInputProcessor:handleLockTargetAction(inputInfo)
	if inputInfo.phase == "Performed" then
		self:handleLockTargetActionPerformed(inputInfo)
	elseif inputInfo.phase == "Canceled" then
		self:handleLockTargetActionCanceled(inputInfo)
	end
end

function SkillInputProcessor:handleLockTargetActionPerformed(inputInfo)
	local lockHelper = pg.game.controller.lockHelper

	if self.lockTargetTimer then
		TimerManager.removeTimer(self.lockTargetTimer)

		self.lockTargetTimer = nil
	end

	local lockComponent = pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.focus

	if not lockComponent then
		return
	end

	self.progressAnimLen = lockComponent.lockStrongUProgress.progressAnimLen

	if lockHelper.isUseHoldCancelLock then
		self.pressingProgress = 0

		if lockHelper.forceLockActorId ~= 0 then
			lockComponent.lockStrongUProgress.value = 0
			self.lockTargetTimer = TimerManager.addRepeatTimer(0, function()
				self.pressingProgress = self.pressingProgress + Time.deltaTime

				lockComponent.lockStrongUProgress:ProgressToValue(self.pressingProgress / self.progressAnimLen, nil)

				if lockHelper.isUseHoldCancelLock and self.pressingProgress > self.progressAnimLen then
					self.pressingProgress = 0

					pg.game.controller:unlockTarget()
					TimerManager.removeTimer(self.lockTargetTimer)

					self.lockTargetTimer = nil
				end
			end)
		else
			lockComponent.lockStrongUProgress.value = 0

			lockHelper:tryForceLockTarget()
		end
	elseif lockHelper.forceLockActorId ~= 0 then
		if lockHelper.isUseTabSwitchTarget then
			lockHelper:tryLockNextTarget()
		elseif not lockHelper.isUseHoldCancelLock then
			lockHelper:cancelLockTarget()
		end
	else
		lockHelper:tryForceLockTarget()
	end
end

function SkillInputProcessor:handleLockTargetActionCanceled(inputInfo)
	local lockHelper = pg.game.controller.lockHelper

	if self.lockTargetTimer then
		local lockComponent = pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.focus

		if lockComponent then
			lockComponent.lockStrongUProgress:ProgressToValue(0, nil)
		end

		TimerManager.removeTimer(self.lockTargetTimer)

		self.lockTargetTimer = nil

		if lockHelper.forceLockActorId ~= 0 then
			if lockHelper.isUseTabSwitchTarget then
				lockHelper:tryLockNextTarget()
			elseif not lockHelper.isUseHoldCancelLock then
				lockHelper:cancelLockTarget()
			end
		else
			lockHelper:tryForceLockTarget()
		end
	end
end

function SkillInputProcessor:handleGamepadSwitchLeftTargetAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.game.controller.lockHelper:onMouseScroll(1) then
			return
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end

	return true
end

function SkillInputProcessor:handleGamepadSwitchRightTargetAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.game.controller.lockHelper:onMouseScroll(-1) then
			return
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end

	return true
end

return SkillInputProcessor
