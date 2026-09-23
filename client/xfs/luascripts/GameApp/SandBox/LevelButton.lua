-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\LevelButton.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local LevelButton = Class.LightClass("LevelButton", LevelItem)
local InteractionConst = require("Common.Const.InteractionConst")
local Time = require("Core.Common.Time")

function LevelButton:ctor(sandbox, spawnInfo, syncInfo)
	LevelButton.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local defaultValue = spawnInfo.defaultValue or {}

	self.interactPrototypeId = defaultValue.interactPrototypeId
	self.interactCD = defaultValue.interactCD
	self.interactRefId = defaultValue.interactRefId
end

function LevelButton:destroy()
	LevelButton.super.destroy(self)
end

function LevelButton:checkCanInteract(interactUnit)
	if not self.lastInteractTime then
		return true
	end

	return self.lastInteractTime + self.interactCD < Time.realSecondCache
end

function LevelButton:getInteractionListData(levelItemInteractSB, interactPartId)
	if not self.interactPrototypeId then
		return nil
	end

	local interactListData = {}
	local interactData = {
		interactPartId = interactPartId,
		actionPrototypeId = self.interactPrototypeId,
		globalId = self:getInteractGlobalId(interactPartId),
		interactFunc = function(interactUnit)
			self:onInteract(interactUnit)
			self:informServerInteract()
		end,
		canInteractiveFunc = function(interactUnit)
			local result = self:checkCanInteract(interactUnit)

			return result
		end
	}

	table.insert(interactListData, interactData)

	return interactListData
end

function LevelButton:onInteract(interactUnit)
	self.lastInteractTime = Time.realSecondCache

	self.shell:SendEventToFlowScript("OnButtonPress")
	self:serverMsg("RPC_CS_DoInteract", interactUnit.actionPrototypeId)
end

return LevelButton
