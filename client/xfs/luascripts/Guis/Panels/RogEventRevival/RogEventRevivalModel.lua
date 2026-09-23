-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogEventRevival\\RogEventRevivalModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RogueConst = require("Const.RogueConst")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")
local RogueUtils = require("Utils.RogueUtils")
local RogEventRevivalModel = Class.LightClass("RogEventRevivalModel", UIModel)

function RogEventRevivalModel:getPetListRenderInfo()
	local ret = {}

	for i = 1, RogueConst.MAX_PET_COUNT do
		local info = pg.space.petInfos[i]

		if info then
			ret[i] = info
		else
			ret[i] = i == RogueConst.MAX_PET_COUNT and not RogueTalentUtils.func(pg.me, "rogueExtraSlot") and {
				gridIsLock = true
			} or {
				gridIsEmpty = true
			}
		end
	end

	table.sort(ret, RogueUtils.comparePetSortInfo)

	return ret
end

return RogEventRevivalModel
