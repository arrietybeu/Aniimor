-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VotingFeature\\VotingFeatureCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local VotingFeatureCtrl = Class.LightClass("VotingFeatureCtrl", UICtrl)

function VotingFeatureCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function VotingFeatureCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function VotingFeatureCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function VotingFeatureCtrl:onShow()
	return
end

return VotingFeatureCtrl
