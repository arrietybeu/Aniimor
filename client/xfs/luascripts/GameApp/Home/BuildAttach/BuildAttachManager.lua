-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\BuildAttach\\BuildAttachManager.lua

local Class = require("Core.Framework.Class")
local BuildAttachManager = Class.LiteClass("BuildAttachManager")

function BuildAttachManager:ctor()
	self.enableAttach = true
end

function BuildAttachManager:init(buildExtraData)
	return
end

function BuildAttachManager:setEnableAttach(enableAttach)
	if self.enableAttach ~= enableAttach then
		self.enableAttach = enableAttach
	end
end

return BuildAttachManager
