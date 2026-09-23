-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitMimicry.lua

local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local InteractionUnitMimicry = Class.LightClass("InteractionUnitMimicry", InteractionUnitBase)

function InteractionUnitMimicry:interactive()
	local ent = self:getEntity()

	ent:serverMsg("RPC_CS_ChangeMimicryState", false)
end

return InteractionUnitMimicry
