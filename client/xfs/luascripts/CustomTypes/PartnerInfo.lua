-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PartnerInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local class = require("Core.Framework.Class")
local PartnerInfo = class.LiteClass("PartnerInfo", CustomDict)

function PartnerInfo:refresh(entity)
	self.templateId = entity.templateId
	self.curHp = entity:getHp()
	self.maxHp = entity:getMaxHp()
	self.isAlive = entity:isAlive()
	self.shieldPoint = entity.shieldDataList:getCurPoint(entity)
end

function PartnerInfo:checkCanUseUltimateSkill()
	return self.maxSp == self.curSp
end

return PartnerInfo
