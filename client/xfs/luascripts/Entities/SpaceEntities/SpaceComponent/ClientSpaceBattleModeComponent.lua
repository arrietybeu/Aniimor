-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceBattleModeComponent.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local ClientSpaceBattleModeComponent = Class.Component("ClientSpaceBattleModeComponent")

function ClientSpaceBattleModeComponent:on_supportPetMode_changed(oldv, newv)
	if pg.game.camera.playerCameraMode then
		pg.game.camera.playerCameraMode:resetCameraZoom(false)
	end
end

function ClientSpaceBattleModeComponent:on_battleMode_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.ON_SPACE_BATTLE_MODE_CHANGE, newv)
end

return ClientSpaceBattleModeComponent
