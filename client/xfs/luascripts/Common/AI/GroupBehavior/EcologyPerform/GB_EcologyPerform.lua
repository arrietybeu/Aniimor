-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\EcologyPerform\\GB_EcologyPerform.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourBase = require("Common.AI.GroupBehavior.GroupBehaviourBase")
local GBT_CoolDown = require("Common.AI.GroupBehavior.Common.GBT_CoolDown")
local GBT_MakeGroup = require("Common.AI.GroupBehavior.Common.GBT_MakeGroup")
local GBT_MoveToResPoint = require("Common.AI.GroupBehavior.EcologyPerform.GBT_MoveToResPoint")
local GBT_CustomAnimation = require("Common.AI.GroupBehavior.EcologyPerform.GBT_CustomAnimation")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local TacheDefine = GroupBehaviourConst.TacheDefine
local GB_EcologyPerform = Class.LiteClass("GB_EcologyPerform", GroupBehaviourBase)

function GB_EcologyPerform:onInit()
	GroupBehaviourBase.onInit(self)
	self:addTache(TacheDefine.CoolDown, GBT_CoolDown.new(self, TacheDefine.CoolDown))
	self:addTache(TacheDefine.MakeGroup, GBT_MakeGroup.new(self, TacheDefine.MakeGroup))
	self:addTache(TacheDefine.MoveToResPoint, GBT_MoveToResPoint.new(self, TacheDefine.MoveToResPoint))
	self:addTache(TacheDefine.CustomAnimation, GBT_CustomAnimation.new(self, TacheDefine.CustomAnimation))
end

function GB_EcologyPerform:onStart()
	GroupBehaviourBase.onStart(self)
	self.fsm:start(TacheDefine.MakeGroup)
end

return GB_EcologyPerform
