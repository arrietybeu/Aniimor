-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarBoard.lua

local Class = require("Core.Framework.Class")
local ClientOwnClientNpc = require("Entities.ClientOwnClientNpc")
local TopLogoCarBoard = require("Guis.Panels.TopLogo.Node.TopLogoCarBoard")
local InteractionConst = require("Common.Const.InteractionConst")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local AddressDataConst = require("Const.AddressDataConst")
local EffectConst = require("Const.EffectConst")
local CommonSwitch = require("Common.CommonSwitch")
local ClientHomeCarBoard = Class.Class("ClientHomeCarBoard", ClientOwnClientNpc)

function ClientHomeCarBoard:init(dict)
	self.playerUID = dict.playerUID
	self.carGroup = pg.game.homeCar:getHomeCarGroup(self.playerUID)
	self.overrideTopLogoEnterDistance = 8

	ClientHomeCarBoard.super.init(self, dict)

	self.topLogoType = ClientConst.TopLogoType.HomeCarBoard

	return true
end

function ClientHomeCarBoard:start()
	ClientHomeCarBoard.super.start(self)
	self:refreshIndicatorEffect()
end

function ClientHomeCarBoard:isSelfHomeCar()
	return self.playerUID == pg.me.uid
end

function ClientHomeCarBoard:useNpcFirstLevelInteractIcon()
	return true
end

function ClientHomeCarBoard:onBasicInfoChanged(basicInfo)
	local topLogoItem = self:peekTopLogoItem()

	if topLogoItem then
		topLogoItem:refreshBoardInfo()
	end
end

function ClientHomeCarBoard:onLiked()
	local topLogoItem = self:ensureTopLogoItem("home_car_liked")

	if topLogoItem then
		self:showTopLogoEx(nil, "home_car_liked")

		if self.topLogoCreated then
			topLogoItem:onLiked()
		end
	end
end

function ClientHomeCarBoard:onLikeCntChanged()
	local topLogoItem = self:peekTopLogoItem()

	if topLogoItem then
		topLogoItem:refreshBoardInfo()
	end
end

function ClientHomeCarBoard:onPetInfoChanged()
	local topLogoItem = self:peekTopLogoItem()

	if topLogoItem then
		topLogoItem:refreshBoardInfo()
	end
end

function ClientHomeCarBoard:checkCarGroupValid()
	if not self.carGroup then
		return false
	end

	if self.carGroup:isVirtualCampCar() then
		return false
	end

	return true
end

function ClientHomeCarBoard:initInteraction()
	self.interactionListData = {}

	if self:isSelfHomeCar() then
		self.interactionListData[#self.interactionListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = Const.HOME_CAMP_VIEW_CAMP_BUFF,
			canInteractiveFunc = function()
				return true
			end,
			interactFunc = function()
				pg.global.ui:open(UIConst.UI_ID_HOME_CAR_BUFF_PANEL, {
					ownerUid = self.playerUID
				})
			end
		}
		self.interactionListData[#self.interactionListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = Const.HOME_CAMP_BUILD_INTERACT_ID,
			canInteractiveFunc = function()
				return self:canBuildCarCamp()
			end,
			interactFunc = function()
				self:doBuildCarCamp()
			end
		}

		if CommonSwitch.CAMP_MANAGER then
			self.interactionListData[#self.interactionListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = Const.HOME_CAMP_MANAGE_INTERACT_ID,
				canInteractiveFunc = function()
					return self:canManagerCarCamp()
				end,
				interactFunc = function()
					self:doManagerCarCamp()
				end
			}
		end
	else
		self.interactionListData[#self.interactionListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = Const.HOME_CAMP_LIKE_INTERACT_ID,
			canInteractiveFunc = function()
				return self:canHomeCampLike()
			end,
			interactFunc = function()
				self:doLikeHomeCamp()
			end
		}
		self.interactionListData[#self.interactionListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = Const.HOME_CAMP_VIEW_PLAYER_INTERACT_ID,
			canInteractiveFunc = function()
				return self:canDoViewPlayer()
			end,
			interactFunc = function()
				self:doViewPlayer()
			end
		}
	end

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientHomeCarBoard:canBuildCarCamp()
	return self:checkCarGroupValid()
end

function ClientHomeCarBoard:doBuildCarCamp()
	if self.carGroup then
		self.carGroup:startEdit()
	end
end

function ClientHomeCarBoard:canManagerCarCamp()
	if not pg.game.homeCar:checkEnableHomeCarManagement() then
		return false
	end

	return self:checkCarGroupValid()
end

function ClientHomeCarBoard:doManagerCarCamp()
	if not CommonSwitch.CAMP_MANAGER then
		return
	end

	if self.carGroup then
		pg.global.ui:open(UIConst.UI_ID_CAMP_MANAGER)
	end
end

function ClientHomeCarBoard:canHomeCampLike()
	return self:checkCarGroupValid()
end

function ClientHomeCarBoard:doLikeHomeCamp()
	pg.me:likeHomeCar(self.playerUID, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			self:onLiked()
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end
	end)
end

function ClientHomeCarBoard:canDoViewPlayer()
	return self:checkCarGroupValid()
end

function ClientHomeCarBoard:doViewPlayer()
	pg.me:queryPlayerInfo(self.playerUID, pg.game.chat.queryPlayerInfoType.ShowPlayerInfo, true, function(playerData)
		local param = {
			openType = ClientConst.PlayerInfoOpenType.Chat,
			playerId = self.playerUID,
			openSource = pg.game.chat.AddFriendSource.PlayerCard
		}

		LuaUIUtils.openInfoPlayerCard(param)
	end)
end

function ClientHomeCarBoard:refreshIndicatorEffect()
	if self:isSelfHomeCar() and not self.indicatorEffectId then
		self.indicatorEffectId = self:playEffectRaw(AddressDataConst.HOME_CAR_INDICATOR_EFFECT, {
			mountType = EffectConst.MountType.PositionAgent
		})
	end
end

return ClientHomeCarBoard
