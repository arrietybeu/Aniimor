-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoCarBoard.lua

local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local TimerManager = require("Core.Timer.TimerManager")
local TopLogoCarBoard = Class.LightClass("TopLogoCarBoard", TopLogoItem)

function TopLogoCarBoard:ctor(entity)
	TopLogoCarBoard.super.ctor(self, entity)

	self.resId = AddressDataConst.HOME_CAR_BOARD_TOPLOGO
end

function TopLogoCarBoard:destroy()
	self:stopRepeatTimer()
	TopLogoCarBoard.super.destroy(self)
end

function TopLogoCarBoard:onTopLogoDestroy()
	self:stopRepeatTimer()

	if self._likedTimer then
		self:killTimer(self._likedTimer)

		self._likedTimer = nil
	end

	self._pendingLiked = nil

	TopLogoCarBoard.super.onTopLogoDestroy(self)
end

function TopLogoCarBoard:findObjects()
	local objectReference = self.objectReference

	self.txtName = objectReference:GetRefValue("txtName")
	self.rootComponent = objectReference:GetComponent("UComponent")
	self.likedUComponent = objectReference:GetRefValue("likedUComponent")
	self.likeNum = objectReference:GetRefValue("likeNum")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
end

function TopLogoCarBoard:refreshTopLogoItemOnLoaded()
	self:refreshBoardInfo()
	self.rootComponent:TryChangePage("Liked", 0)

	if self._pendingLiked then
		self._pendingLiked = nil

		self:onLiked()
	end

	self:launchRepeatTimer()
end

function TopLogoCarBoard:stopRepeatTimer()
	if self.repeatTimer then
		TimerManager.removeTimer(self.repeatTimer)

		self.repeatTimer = nil
	end
end

function TopLogoCarBoard:launchRepeatTimer()
	self:stopRepeatTimer()

	self.repeatTimer = TimerManager.addRepeatTimer(0.5, function()
		self:refreshBoardInfo()
	end)
end

function TopLogoCarBoard:getTopLogoVisible()
	local valid = false
	local entity = self.entity

	if entity and entity.carGroup then
		local campCarEnt = entity.carGroup.campCarEnt

		if campCarEnt then
			valid = true
		end
	end

	if not valid then
		return false
	end

	return TopLogoCarBoard.super.getTopLogoVisible(self)
end

function TopLogoCarBoard:refreshBoardInfo()
	if not self.gameObject then
		return
	end

	local entity = self.entity

	if entity and entity.carGroup then
		local campCarEnt = entity.carGroup.campCarEnt

		if campCarEnt then
			local basicInfo = campCarEnt.basicInfo
			local likeCnt = campCarEnt.likeCnt
			local boardName = basicInfo.name
			local ownerUid = entity.playerUID or campCarEnt.ownerUid
			local _h = TopLogoCarBoard._platformHooks

			boardName = _h and _h.refreshBoardName and _h.refreshBoardName(self, ownerUid, boardName) or boardName

			ClientTextUtils.setText(self.txtName, boardName)
			ClientTextUtils.setText(self.likeNum, likeCnt)

			local itemsData = {}

			if entity:isSelfHomeCar() then
				itemsData = self:getHomeCampPetInfos() or {}
			end

			function self.listPetUList.luaRenderItem(button, index, data)
				button.draggable = false
				button.enabledTooltip = false

				local campPetInfo = data.campPetInfo

				campPetInfo.isShowCancel = data.isShowCancel

				LuaUIUtils.renderHomePetHead(button, campPetInfo, data.dispatchState, {
					closeAbility = true,
					isForbidToolTips = true
				})
			end

			self.listPetUList:SetList(itemsData)
		end
	end

	self:refreshTopLogoVisible()
end

function TopLogoCarBoard:onLiked()
	if not self.gameObject then
		self._pendingLiked = true

		return
	end

	if self._likedTimer then
		self:killTimer(self._likedTimer)

		self._likedTimer = nil
	end

	self._likedTimer = self:startTimer(function()
		self._likedTimer = nil

		if self.gameObject then
			self.rootComponent:TryChangePage("Liked", 0)
			self.rootComponent:TryChangePage("Liked", 1)
		end
	end, 0.8)
end

function TopLogoCarBoard:getHomeCampPetInfos()
	local entity = self.entity

	if entity and entity.carGroup then
		local campCarEnt = entity.carGroup.campCarEnt

		if campCarEnt then
			local itemsData = {}
			local petIds = campCarEnt and campCarEnt:getCampPetIds() or {}
			local dispatchState = campCarEnt:getCampPetDispatchState() or UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch
			local campPets = HomeCampUtils.getUICacheCampPetsList(petIds, campCarEnt)
			local campPetCnt = #campPets
			local isShowCancel = false

			for i = 1, campPetCnt do
				itemsData[#itemsData + 1] = {
					campPetInfo = campPets and campPets[i] or nil,
					dispatchState = dispatchState,
					isShowCancel = isShowCancel
				}
			end

			return itemsData
		end
	end
end

return TopLogoCarBoard
