-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomePetInteractComponent.lua

local Class = require("Core.Framework.Class")
local HomeEventTextData = require("Data.home_event_text_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local ClientHomePetInteractComponent = Class.Component("ClientHomePetInteractComponent")

function ClientHomePetInteractComponent:init(dict)
	return true
end

function ClientHomePetInteractComponent:requestHomePettingReward(playerEntity, petEntity)
	local petName = petEntity.customName or petEntity.petInfo and petEntity.petInfo.customName

	if string.isNilOrEmpty(petName) then
		petName = ClientTextUtils.getLocalizationText(petEntity:getConfigData().name)
	end

	playerEntity:serverMsg("RPC_CS_HomePettingReward", function(noticeId, wishStarCount)
		if noticeId ~= NoticeDef.SUCCESS then
			return
		end

		pg.global.showBubbleMessage(NoticeDef.TOUCH_PET_REWARD, petName)

		if wishStarCount > 0 then
			facade:sendMsgToUI(MessageName.HOMELAND_WISH_STAR_FLY_FEEDBACK, {
				collected = wishStarCount,
				sourceEntityId = petEntity:getGlobalId()
			})
		end
	end)
end

function ClientHomePetInteractComponent:finishHomePettingInteraction(playerEntity, petEntity, startSpace, revision, isComplete)
	HomeLandUtils.tryFinishHomePettingLeisure(playerEntity, petEntity, startSpace, revision)

	if not isComplete then
		return
	end

	self:requestHomePettingReward(playerEntity, petEntity)
end

function ClientHomePetInteractComponent:requestHomePettingInteraction()
	local playerEntity = pg.me
	local revision = HomeLandUtils.getHomePettingLeisureRevision(playerEntity, self)
	local interactGestureComponent = pg.game.social and pg.game.social.interactGestureComponent

	if not revision or not interactGestureComponent then
		return false
	end

	local startSpace = self.space
	local petEntityId = self.id

	return interactGestureComponent:requestTouchPetInteraction(playerEntity, self, function(isComplete)
		local petEntity = pg.getEntity(petEntityId)
		local currentPlayerEntity = pg.me

		if not petEntity or not currentPlayerEntity then
			return
		end

		petEntity:finishHomePettingInteraction(currentPlayerEntity, petEntity, startSpace, revision, isComplete)
	end)
end

function ClientHomePetInteractComponent:EVENT_InitInteractionList()
	self:initHomePetInteractListData()

	if #self.homePetInteractListData > 0 then
		self.interactionListData = self.interactionListData or {}

		for _, data in ipairs(self.homePetInteractListData) do
			self.interactionListData[#self.interactionListData + 1] = data
		end
	end
end

function ClientHomePetInteractComponent:initHomePetInteractListData()
	self.homePetInteractListData = {}

	local interactDist

	if self.getBeHoldDistance then
		interactDist = self:getBeHoldDistance()
	end

	if pg.space and Utils.isHomeland(pg.space.spaceType) and pg.me.space:isSelfHomeland(pg.me) then
		self.homePetInteractListData[#self.homePetInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_PET_SNUGGLE_ACTION_ID,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			overrideInteractDis = interactDist,
			canInteractiveFunc = function()
				return HomeLandUtils.getHomePettingLeisureRevision(pg.me, self) ~= nil and not pg.game.social.interactGestureComponent:checkInteractGesturePlaying()
			end,
			interactFunc = function()
				self:requestHomePettingInteraction()
			end
		}
		self.homePetInteractListData[#self.homePetInteractListData + 1] = {
			skipHomelandCheck = true,
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_FOOD_ACTION_ID,
			overrideInteractDis = interactDist,
			canInteractiveFunc = function(interactUnit)
				return self:checkDoHomePetFoodInteract()
			end,
			interactFunc = function(interactUnit)
				self:doHomePetFoodInteract(interactUnit)
			end
		}
	end
end

function ClientHomePetInteractComponent:checkDoHomePetFoodInteract()
	return pg.space and Utils.isHomeland(pg.space.spaceType) and not pg.space:checkHomePetHasFood()
end

function ClientHomePetInteractComponent:doHomePetFoodInteract(interactUnit)
	pg.global.ui.homelandPetManageNew:open({
		defaultTab = 1
	})
end

return ClientHomePetInteractComponent
