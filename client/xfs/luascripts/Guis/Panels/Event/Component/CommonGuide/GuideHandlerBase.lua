-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\GuideHandlerBase.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = Class.LightClass("GuideHandlerBase")

function GuideHandlerBase:ctor(comp)
	self.comp = comp
end

function GuideHandlerBase:getOwnedRefKeys()
	return {}
end

function GuideHandlerBase:getOwnedContainers()
	return {}
end

function GuideHandlerBase:onFindObjects(objectReference)
	return
end

function GuideHandlerBase:onRefresh()
	return
end

function GuideHandlerBase:onExit()
	return
end

function GuideHandlerBase:onMoneyChanged()
	return
end

function GuideHandlerBase:needBtn1()
	return true
end

function GuideHandlerBase:onButton1()
	return false
end

function GuideHandlerBase:onButton2()
	return false
end

function GuideHandlerBase:onDestroy()
	return
end

return GuideHandlerBase
