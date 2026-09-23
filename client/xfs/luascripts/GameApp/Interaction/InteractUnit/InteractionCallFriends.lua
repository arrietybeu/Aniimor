-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionCallFriends.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Const.Const")
local InteractionCallFriends = Class.LightClass("InteractionCallFriends", InteractionUnitBase)

function InteractionCallFriends:ctor(info, interactId)
	InteractionCallFriends.super.ctor(self, info, interactId)

	self.owner = info.owner
end

function InteractionCallFriends:interactive()
	self.owner:playTrivialAnimation(PlayableConst.Behav_Happy)
	self.owner:playEffect("Eff_Common_Behav_CallForPals_2")
end

function InteractionCallFriends:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	return false
end

return InteractionCallFriends
