-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPerceptibilityComponent.lua

local class = require("Core.Framework.Class")
local IPerceptibilityComponent = class.Component("IPerceptibilityComponent")

function IPerceptibilityComponent:getPerceptibilityTarget()
	if self.ent.getMaxPerceptibility then
		local actorId, _ = self.ent:getMaxPerceptibility()

		return actorId
	end

	return 0
end

return IPerceptibilityComponent
