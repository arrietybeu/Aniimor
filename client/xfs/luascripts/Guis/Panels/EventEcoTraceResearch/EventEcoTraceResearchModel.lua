-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventEcoTraceResearch\\EventEcoTraceResearchModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local Time = require("Core.Common.Time")
local PetData = require("Data.pet_data")
local EventEcoTraceResearchModel = Class.LightClass("EventEcoTraceResearchModel", UIModel)

function EventEcoTraceResearchModel:getChosedPetName()
	local chosedPetId = ClientActivityUtils.getEcoTracePetId()
	local petData = PetData[chosedPetId]

	return petData and petData.name or ""
end

return EventEcoTraceResearchModel
