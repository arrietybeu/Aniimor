-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\VirtualPuppetContainer.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientUtils = require("Utils.ClientUtils")
local VirtualPuppetContainer = Class.LightClass("VirtualPuppetContainer", LevelItem)

function VirtualPuppetContainer:ctor(sandbox, spawnInfo, syncInfo)
	VirtualPuppetContainer.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function VirtualPuppetContainer:createEntity()
	self.entity = ClientUtils.createClientEntity("ClientVirtualPuppet", VirtualEntUtils.getNewVirtualEntityId(), {
		templateId = self.spawnInfo.templateId
	})

	return self.entity.eModel
end

function VirtualPuppetContainer:destroy()
	if self.entity then
		ClientUtils.safeDestroy(self.entity)
	end

	VirtualPuppetContainer.super.destroy(self)
end

return VirtualPuppetContainer
