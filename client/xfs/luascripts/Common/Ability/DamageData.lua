-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\DamageData.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local DamageData = Class.LiteClass("DamageData")

function DamageData:ctor()
	self.elementType = 0
	self.elementFactor = 1
	self.damageShowEnum = Const.DAMAGE_SHOW_ENUM_NORMAL
	self.rawDamage = 1
	self.shieldAbsorbDamage = nil
	self.damageFlag = 0
	self.finalDamage = 0
	self.srcType = 0
	self.attackResult = nil
	self.hitActorPartIdx = 0
	self.reduceShieldFactor = 0
end

return DamageData
