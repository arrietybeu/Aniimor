-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionAreaBranchLine.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Const.Const")
local UIConst = require("Const.UIConst")
local InteractionAreaBranchLine = Class.LightClass("InteractionAreaBranchLine", InteractionUnitBase)

function InteractionAreaBranchLine:ctor(info, interactId)
	InteractionAreaBranchLine.super.ctor(self, info, interactId)
end

function InteractionAreaBranchLine:interactive()
	pg.global.ui:open(UIConst.UI_ID_BRANCH_LINE)
end

function InteractionAreaBranchLine:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BRANCH_LINE) then
		return false
	end

	return true
end

return InteractionAreaBranchLine
