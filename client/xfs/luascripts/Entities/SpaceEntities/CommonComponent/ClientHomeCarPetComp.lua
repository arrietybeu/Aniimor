-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientHomeCarPetComp.lua

local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local ClientModelUtils = require("Utils.ClientModelUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local HomeCampUtils = require("Utils.HomeCampUtils")
local ClientHomeCarPetComp = Class.Component("ClientHomeCarPetComp")

function ClientHomeCarPetComp:EVENT_InitInteractionList()
	self:initHomeCarPetInteractionList()

	self.carPetInteraciontList = self.carPetInteraciontList or {}

	if #self.carPetInteraciontList > 0 then
		self.interactionListData = self.interactionListData or {}

		for _, data in ipairs(self.carPetInteraciontList) do
			self.interactionListData[#self.interactionListData + 1] = data
		end
	end
end

function ClientHomeCarPetComp:initHomeCarPetInteractionList()
	self.carPetInteraciontList = {}

	local protoData = {}

	protoData[#protoData + 1] = InteractionConst.INTERACT_HOME_CAR_PET_FINISH_DISPATCH

	for i, v in ipairs(protoData) do
		self.carPetInteraciontList[i] = {
			skipHomelandCheck = true,
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			actionPrototypeId = v,
			canInteractiveFunc = function()
				return self:isCanInteractiveCarPetFunc(v)
			end,
			interactFunc = function()
				self:doCarPetInteract(v)
			end
		}
	end
end

function ClientHomeCarPetComp:isCanInteractiveCarPetFunc(interactType)
	local dispatchState

	if interactType == InteractionConst.INTERACT_HOME_CAR_PET_FINISH_DISPATCH then
		local petId = self.id

		if petId then
			local carUid = pg.me and pg.me.uid
			local carEnt = HomeLandUtils.getCampCarEntity(carUid)

			dispatchState = HomeCampUtils.getPlayerCarPetsDispatchState(carEnt)
		end
	end

	return dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Finished
end

function ClientHomeCarPetComp:doCarPetInteract(interactType)
	if not self:isCanInteractiveCarPetFunc(interactType) then
		return
	end

	if interactType == InteractionConst.INTERACT_HOME_CAR_PET_FINISH_DISPATCH then
		local carUid = pg.me and pg.me.uid
		local carEnt = HomeLandUtils.getCampCarEntity(carUid)

		if carEnt then
			carEnt:finishDispatch()
		end
	end
end

return ClientHomeCarPetComp
