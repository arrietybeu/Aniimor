-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\PhotoInputProcessor.lua

local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local PhotoInputProcessor = Class.LightClass("PhotoInputProcessor", BaseInputProcessor)

PhotoInputProcessor.moveXWeight = 0
PhotoInputProcessor.moveYWeight = 0
PhotoInputProcessor.moveZWeight = 0

function PhotoInputProcessor:onInit()
	BaseInputProcessor.onInit(self)
end

function PhotoInputProcessor:onEnableInputMap(mapName, enabled)
	if not enabled then
		self:reset()
	end
end

function PhotoInputProcessor:getActiveMoveCtrl()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		return pg.global.ui.photo
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT) then
		return pg.global.ui.PhotographyStudioEdit
	end

	return nil
end

function PhotoInputProcessor:isInputActive()
	return self:getActiveMoveCtrl() ~= nil
end

function PhotoInputProcessor:handleActionTriggered(inputInfo)
	local shouldBlockAction = pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) and pg.global.ui.photo.shouldBlockAction or false

	if shouldBlockAction then
		return true
	else
		return BaseInputProcessor.handleActionTriggered(self, inputInfo)
	end
end

function PhotoInputProcessor:reset()
	self.moveXWeight = 0
	self.moveYWeight = 0
	self.moveZWeight = 0

	self:handleMoveWeight()
end

function PhotoInputProcessor:handleScrollAction(inputInfo)
	local ctrl = self:getActiveMoveCtrl()

	if not ctrl then
		return true
	end

	if inputInfo.phase == "Performed" then
		local deltaZoom = inputInfo.valueVec2.y

		if deltaZoom == 0 then
			return
		end

		if ctrl.onLensScroll then
			ctrl:onLensScroll(deltaZoom > 0)
		elseif ctrl.view then
			if deltaZoom > 0 then
				ctrl.view.zoomAdd.luaClick()
			else
				ctrl.view.zoomDec.luaClick()
			end
		end
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleWAction(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveYWeight = self.moveYWeight + 1

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		self.moveYWeight = math.max(0, self.moveYWeight - 1)

		self:handleMoveWeight()
	end
end

function PhotoInputProcessor:handleW1Action(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveYWeight = math.max(0, self.moveYWeight - 1)

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleAAction(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveXWeight = self.moveXWeight - 1

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		self.moveXWeight = math.min(0, self.moveXWeight + 1)

		self:handleMoveWeight()
	end
end

function PhotoInputProcessor:handleA1Action(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveXWeight = math.min(0, self.moveXWeight + 1)

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleSAction(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveYWeight = self.moveYWeight - 1

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		self.moveYWeight = math.min(0, self.moveYWeight + 1)

		self:handleMoveWeight()
	end
end

function PhotoInputProcessor:handleS1Action(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveYWeight = math.min(0, self.moveYWeight + 1)

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleDAction(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveXWeight = self.moveXWeight + 1

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		self.moveXWeight = math.max(0, self.moveXWeight - 1)

		self:handleMoveWeight()
	end
end

function PhotoInputProcessor:handleD1Action(inputInfo)
	if not self:isInputActive() then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveXWeight = math.max(0, self.moveXWeight - 1)

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleQAction(inputInfo)
	local ctrl = self:getActiveMoveCtrl()

	if not ctrl then
		return true
	end

	if pg.game.input:isUsingGamepad() and not ctrl.isLeftShoulderPressed then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveZWeight = self.moveZWeight - 1

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		self.moveZWeight = math.min(0, self.moveZWeight + 1)

		self:handleMoveWeight()
	end
end

function PhotoInputProcessor:handleQ1Action(inputInfo)
	local ctrl = self:getActiveMoveCtrl()

	if not ctrl then
		return true
	end

	if pg.game.input:isUsingGamepad() and not ctrl.isLeftShoulderPressed then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveZWeight = math.min(0, self.moveZWeight + 1)

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleEAction(inputInfo)
	local ctrl = self:getActiveMoveCtrl()

	if not ctrl then
		return true
	end

	if pg.game.input:isUsingGamepad() and not ctrl.isLeftShoulderPressed then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveZWeight = self.moveZWeight + 1

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		self.moveZWeight = math.max(0, self.moveZWeight - 1)

		self:handleMoveWeight()
	end
end

function PhotoInputProcessor:handleE1Action(inputInfo)
	local ctrl = self:getActiveMoveCtrl()

	if not ctrl then
		return true
	end

	if pg.game.input:isUsingGamepad() and not ctrl.isLeftShoulderPressed then
		return true
	end

	if inputInfo.phase == "Performed" then
		self.moveZWeight = math.max(0, self.moveZWeight - 1)

		self:handleMoveWeight()
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function PhotoInputProcessor:handleMoveWeight()
	local ctrl = self:getActiveMoveCtrl()

	if not ctrl then
		return
	end

	ctrl.moveX = self.moveXWeight
	ctrl.moveY = self.moveYWeight
	ctrl.moveZ = self.moveZWeight
end

return PhotoInputProcessor
