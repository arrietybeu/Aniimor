-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitMarkShare.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local InteractionUnitMarkShare = Class.LightClass("InteractionUnitMarkShare", InteractionUnitBase)

function InteractionUnitMarkShare:ctor(info, interactId)
	InteractionUnitMarkShare.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.interactName = info.interactName
	self.isTip = info.isTip
end

function InteractionUnitMarkShare:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	return true
end

function InteractionUnitMarkShare:interactive()
	if self.interactFunc then
		self.interactFunc()
	end
end

function InteractionUnitMarkShare:getText(interactData)
	return string.format(pg.getGameString("INFO_STAMP_NAME_FORMAT"), self.interactName) or ""
end

return InteractionUnitMarkShare
