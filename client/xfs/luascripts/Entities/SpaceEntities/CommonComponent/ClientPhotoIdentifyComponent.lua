-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPhotoIdentifyComponent.lua

local Class = require("Core.Framework.Class")
local PhotoIdentifyData = require("Data.photo_identify_data")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local FrontCondition = require("Data.front_condition_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientPhotoIdentifyComponent = Class.Component("ClientPhotoIdentifyComponent")

function ClientPhotoIdentifyComponent:start()
	self:initPhotoIdentify()
end

function ClientPhotoIdentifyComponent:destroy()
	if self.isEntityTagIdentify then
		self.isEntityTagIdentify = nil

		pg.me:removePhotoDistance(self.id)
	end
end

function ClientPhotoIdentifyComponent:initPhotoIdentify()
	local photoIdentifyIds = self:getConfigData().photoIdentifyIds

	if photoIdentifyIds and #photoIdentifyIds > 0 then
		local needIdentifyIds = {}
		local maxShowDistance = -1

		for idx, pId in ipairs(photoIdentifyIds) do
			if not ClientUtils.checkPhotoTraitIsUnlock(pId) then
				table.insert(needIdentifyIds, pId)

				local pInfo = PhotoIdentifyData[pId]

				self.isEntityTagIdentify = self:checkHasCondition(pInfo, "HAS_ENTITY_TAG")
				self.hasPetCondition = self:checkHasCondition(pInfo, "HAS_PET_BASE")

				if self.isEntityTagIdentify then
					pg.me:notifyPhotoDistance(self, 1)
				else
					local showDis = pInfo.showDistance[2]

					maxShowDistance = math.max(maxShowDistance, showDis)
				end
			end
		end

		self.photoShowDis = maxShowDistance
		self.photoIdentifyIds = needIdentifyIds
	end

	if not self.isEntityTagIdentify and self.photoShowDis and self.photoShowDis > 0 then
		self:addPhotoIdentifyTrigger()
	end
end

function ClientPhotoIdentifyComponent:checkHasCondition(pInfo, checkCondition)
	if pInfo.inspect ~= 2 then
		return false
	end

	if not pInfo.matchEntities or not pInfo.matchEntities[1] then
		return false
	end

	local conditions = pInfo.matchEntities[1][2]

	for _, conditionId in ipairs(conditions) do
		local conditionInfo = FrontCondition[conditionId]

		if conditionInfo and conditionInfo.condition then
			for _, info in ipairs(conditionInfo.condition) do
				local conditionType = info[1]

				if conditionType == checkCondition then
					return true
				end
			end
		end
	end

	return false
end

function ClientPhotoIdentifyComponent:onTriggerEnter(userData)
	if userData == ClientConst.TriggerType.PHOTO_IDENTIFY then
		pg.me:notifyPhotoDistance(self, self.photoShowDis)
	end
end

function ClientPhotoIdentifyComponent:onTriggerExit(userData)
	if userData == ClientConst.TriggerType.PHOTO_IDENTIFY then
		pg.me:removePhotoDistance(self.id)
	end
end

function ClientPhotoIdentifyComponent:addPhotoIdentifyTrigger()
	if not self.photoIdentifyTriggerId then
		self.photoIdentifyTriggerId = self.eModel:CreateSphereTrigger(ClientConst.TriggerType.PHOTO_IDENTIFY, self.photoShowDis + 1)
	end
end

function ClientPhotoIdentifyComponent:removePhotoIdentifyTrigger()
	if self.photoIdentifyTriggerId then
		self.eModel:DestroyTrigger(self.photoIdentifyTriggerId)

		self.photoIdentifyTriggerId = nil
	end
end

return ClientPhotoIdentifyComponent
