-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientInteractorPetEgg.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local ClientInteractorPetEgg = class.Class("ClientInteractorPetEgg", ClientInteractor)
local InteractorComponents = {}

class.AddComponents(ClientInteractorPetEgg, InteractorComponents)

function ClientInteractorPetEgg:start()
	ClientInteractorPetEgg.super.start(self)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientInteractorPetEgg start", self.id, self.itemId, self.itemGenId)
	end
end

function ClientInteractorPetEgg:destroy()
	ClientInteractorPetEgg.super.destroy(self)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientInteractorPetEgg destroy", self.id, self.itemId, self.itemGenId)
	end
end

return ClientInteractorPetEgg
