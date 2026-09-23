-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogEventRevival\\RogEventRevivalCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RogueUtils = require("Utils.RogueUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemConst = require("Common.Const.ItemConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local RogEventRevivalCtrl = Class.LightClass("RogEventRevivalCtrl", UICtrl)

function RogEventRevivalCtrl:onOpen(info)
	if not pg.me or not pg.me.space or not pg.me.space:isRogueEnv() then
		self:close()

		return
	end

	function self.view.btnClose.luaClick()
		self:close()
	end

	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.RogEvent, true)

	function self.view.btnReset.luaClick()
		if self.selectEntityId then
			pg.me:serverMsg("RPC_CS_StartRoguePetRevive", self.selectEntityId, function(ret)
				self:refreshShow()

				if ret then
					local index, selectItem = self:getSelectItem()

					if index and selectItem then
						self.view.listPet:SelectItem(index - 1)
						RogueUtils.playRevivalAnim(selectItem)
					end
				end
			end)
		end
	end

	self.selectEntityId = nil

	self:refreshShow()
end

function RogEventRevivalCtrl:refreshShow()
	self:refreshList()
	self:refreshRevivalInfo()
end

function RogEventRevivalCtrl:refreshList()
	function self.view.listPet.luaRenderItem(button, index, data)
		RogueUtils.renderPetCard(button, index, data)

		local notNeedNav = data.gridIsLock or data.gridIsEmpty

		button.navForceNonInteractable = notNeedNav
	end

	function self.view.listPet.luaClick(button, data)
		if self.selectEntityId == data.id then
			self.selectEntityId = nil
		else
			self.selectEntityId = data.id
		end

		self:refreshRevivalInfo()
	end

	self.showList = self.model:getPetListRenderInfo()

	self.view.listPet:SetList(self.showList)
end

function RogEventRevivalCtrl:refreshRevivalInfo()
	local hasSelect = self.selectEntityId ~= nil
	local isDead = false

	if hasSelect then
		local ent = pg.getEntity(self.selectEntityId)

		isDead = ent and ent:isDead() or false

		if isDead == false then
			local realtimeData = pg.me:getPetInfo(self.selectEntityId)

			if realtimeData and realtimeData.hpRatio <= 0 then
				isDead = true
			end
		end
	end

	self.view.rootComponent:TryChangePage("State", hasSelect and isDead and 0 or 1)

	local ownNum = ClientUtils.getItemCountById(ItemConst.ITEM_SPECIAL_ROGUE_COIN)
	local needNum = isDead and SysConfigData.ROGUE_REVIVE_COST or 0
	local enough = needNum <= ownNum
	local interactable = hasSelect and enough and isDead

	self.view.btnReset.interactable = interactable

	self.view.btnReset:TryChangePage("button", interactable and 0 or 4)
	RogueUtils.setMoneyText(self.view.txtMoney, needNum, ownNum)
end

function RogEventRevivalCtrl:getSelectItem()
	local petInfos = self.showList

	if petInfos and self.selectEntityId then
		for index, info in ipairs(petInfos) do
			if info.id == self.selectEntityId then
				local res, btn = self.view.listPet:TryGetChildAt(index - 1)

				if res then
					return index, btn
				end
			end
		end
	end
end

function RogEventRevivalCtrl:onDestroy()
	UICtrl.onDestroy(self)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.RogEvent, false)
end

return RogEventRevivalCtrl
