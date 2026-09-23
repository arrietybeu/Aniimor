-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchPetReward\\PetResearchPetRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetResearchPetRewardModel = Class.LightClass("PetResearchPetRewardModel", UIModel)

function PetResearchPetRewardModel:setCurPetTemplateId(curPetTemplateId)
	self.curPetTemplateId = curPetTemplateId
end

return PetResearchPetRewardModel
