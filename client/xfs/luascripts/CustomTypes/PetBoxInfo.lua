-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBoxInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PetBoxInfo = class.LiteClass("PetBoxInfo", CustomDict)

function PetBoxInfo:isManualLocked()
	return self.locked
end

function PetBoxInfo:isTempLocked()
	return self.tempStatus == Const.BOX_TEMP_LOCKED
end

function PetBoxInfo:isLocked()
	return self.locked or self.tempStatus == Const.BOX_TEMP_LOCKED
end

function PetBoxInfo:addPet(index, petId)
	self[index] = petId
	self.count = self.count + 1
end

function PetBoxInfo:removePet(index)
	self[index] = nil
	self.count = self.count - 1
end

function PetBoxInfo:removeAll()
	for index, _ in self:items() do
		self[index] = nil
	end

	self.count = 0
end

return PetBoxInfo
