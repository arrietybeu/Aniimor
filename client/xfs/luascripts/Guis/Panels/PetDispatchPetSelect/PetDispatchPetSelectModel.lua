-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchPetSelect\\PetDispatchPetSelectModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetDispatchUtils = require("GameApp.PetDispatch.PetDispatchUtils")
local PetDispatchPetSelectModel = Class.LightClass("PetDispatchPetSelectModel", UIModel)

PetDispatchPetSelectModel.PAGE_SIZE = 15

function PetDispatchPetSelectModel:ctor()
	self.eventId = nil
	self.clueId = nil
	self.mode = "leader"
	self.slotIndex = nil
	self.excludePetIds = {}
	self.filter = nil
	self.pets = {}
	self.pageIndex = 1
	self.pageSize = PetDispatchPetSelectModel.PAGE_SIZE
	self.conditionsInfos = {}
	self.conditionTypeMap = {}
	self.conditionValueMap = {}
	self.followerSelections = {}
end

function PetDispatchPetSelectModel:refresh()
	local filter = self.filter or {}
	local pets = PetDispatchUtils.listSelectablePets(self.clueId, filter, self.mode)

	self.pets = {}

	for _, pet in ipairs(pets) do
		pet.petId = pet.id
		self.pets[#self.pets + 1] = pet
	end
end

function PetDispatchPetSelectModel:setPageSize(size)
	if type(size) == "number" and size >= 1 then
		self.pageSize = math.floor(size)
	else
		self.pageSize = PetDispatchPetSelectModel.PAGE_SIZE
	end
end

function PetDispatchPetSelectModel:getPageSize()
	return self.pageSize or PetDispatchPetSelectModel.PAGE_SIZE
end

function PetDispatchPetSelectModel:getTotalPages()
	return math.max(1, math.ceil(#(self.pets or {}) / self:getPageSize()))
end

function PetDispatchPetSelectModel:getPagedPets()
	local pets = self.pets or {}
	local pageSize = self:getPageSize()
	local startIdx = (self.pageIndex - 1) * pageSize + 1
	local endIdx = math.min(startIdx + pageSize - 1, #pets)
	local ret = {}

	for i = startIdx, endIdx do
		ret[#ret + 1] = pets[i]
	end

	return ret
end

return PetDispatchPetSelectModel
