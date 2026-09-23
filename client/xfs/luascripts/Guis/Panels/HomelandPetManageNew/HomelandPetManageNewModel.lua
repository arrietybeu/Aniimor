-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManageNew\\HomelandPetManageNewModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandPetManageNewModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local HomelandPetManageNewModel = Class.LightClass("HomelandPetManageNewModel", UIModel)

function HomelandPetManageNewModel:ctor()
	self.HOME_TAG = "home"
	self.WORKPET_TAG = "workPet"
	self.NULLPET_TAG = "nullPet"
	self.HOME_SPLIT = "_"
end

function HomelandPetManageNewModel:getPetBoxCapacity()
	local space = pg.space

	return space and space.petBoxMap and space.petBoxMap:getSlotCount() or 0
end

function HomelandPetManageNewModel:redDot_GetPetBoxCapacityState()
	local player = pg.me

	if not player then
		return RedDotConst.RedDotStyle.NONE
	end

	local capacity = self:getPetBoxCapacity()
	local readCapacity = player:getRedDotRecord(Const.CLIENT_KEY.HOMELAND_PET_MANAGE_RED_DOT, RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY, 0)

	return readCapacity < capacity and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
end

function HomelandPetManageNewModel:redDot_RecordPetBoxCapacityRead()
	local player = pg.me
	local capacity = self:getPetBoxCapacity()

	if not player or capacity <= 0 then
		return
	end

	player:setRedDotRecord(Const.CLIENT_KEY.HOMELAND_PET_MANAGE_RED_DOT, RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY, capacity)
end

return HomelandPetManageNewModel
