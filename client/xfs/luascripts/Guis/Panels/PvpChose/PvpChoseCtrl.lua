-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpChose\\PvpChoseCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpChoseCtrl = Class.LightClass("PvpChoseCtrl", UICtrl)
local PvpModelComponent = require("Guis.Panels.PvpChose.Component.PvpModelComponent")
local PvpMatchResultComponent = require("Guis.Panels.PvpChose.Component.PvpMatchResultComponent")
local PvpChoseGamePadComponent = require("Guis.Panels.PvpChose.Component.PvpChoseGamePadComponent")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

PvpChoseCtrl.messages = {
	[MessageName.PVP_PET_SELECT] = {
		"petSelectChangeEvent",
		true
	},
	[MessageName.PVP_ENEMY_GET_READY] = {
		"enemyGetReadyEvent",
		true
	},
	[MessageName.PVP_BOTH_GET_READY] = {
		"bothGetReadyEvent",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PvpChoseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.pvpModelCmp = PvpModelComponent.new(self)
	self.matchResCmp = PvpMatchResultComponent.new(self, self.view.cutTo)
	self.gamePadCmp = PvpChoseGamePadComponent.new(self)
end

function PvpChoseCtrl:addListener()
	self.enemyMap = {}

	function self.view.list1.luaRenderItem(button, index, data)
		self:instantiatePetItem(button, data)

		function button.luaClick()
			self:clickPetItem(button, data)
		end

		function button.luaHover()
			self:refreshPetRestraint(data)
		end

		self.choseBtn[#self.choseBtn + 1] = button
	end

	function self.view.list2.luaRenderItem(button, index, data)
		self:instantiatePetItem(button, data)

		self.enemyMap[button] = data
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirm()
	end

	pg.game.pvp:reloadMatchType()
end

function PvpChoseCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PvpChoseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.choseBtn = {}

	self.model:clearData()

	self.data = self.model:initTeamInfos(info)

	self.view.component:TryChangePage("State", 1)
	self.view.player1:TryChangePage("State", 1)
	self.view.player2:TryChangePage("State", 1)
	ClientTextUtils.setText(self.view.name1, self.data.selfName)

	self.view.rankIcon1.url = self.data.selfScoreData.icon

	ClientTextUtils.setText(self.view.name2, self.data.otherName)

	self.view.rankIcon2.url = self.data.otherScoreData.icon

	self.matchResCmp:refreshView(self.data)
	self:startTimer(function()
		self:refreshView()
	end, 3)
	self:startTimer(function()
		self:tickCountDown()
	end, 0.03, true)
end

function PvpChoseCtrl:onShow()
	return
end

function PvpChoseCtrl:refreshView()
	self.view.component:TryChangePage("State", 0)
	self.view.list1:SetList(self.data.selfTeams)
	self.view.list2:SetList(self.data.otherTeams)
	self.gamePadCmp:modeChooseAreaSupplement(self.choseBtn)
end

function PvpChoseCtrl:tickCountDown()
	local remandSecond = self.data.endTime - Time.secondCache

	if remandSecond < 0 then
		return
	end

	ClientTextUtils.setText(self.view.readyCountDown, TimeUtils.timeToFormatString(remandSecond))
end

function PvpChoseCtrl:instantiatePetItem(item, data)
	local orc = item:GetComponent("ObjectReference")
	local iIcon = orc:GetRefValue("icon")
	local iName = orc:GetRefValue("name")
	local iLevel = orc:GetRefValue("level")
	local iCp = orc:GetRefValue("cp")

	iIcon.url = data.icon

	ClientTextUtils.setText(iName, data.name)
	ClientTextUtils.setText(iLevel, data.level or 0)
end

function PvpChoseCtrl:clickPetItem(item, data)
	if data.empty then
		return
	end

	if self.model.confirmTeam then
		return
	end

	local isFairMode = pg.game.pvp:isFairMode()
	local selectPos = self.model:checkSelected(isFairMode and data.templateId or data.id)

	if selectPos == 0 then
		local pos = self.model:checkHasPos()

		if pos > 0 then
			local arg = isFairMode and {
				isSelect = true,
				pos = pos,
				PVP1V1PetId = data.templateId
			} or {
				isSelect = true,
				pos = pos,
				PVP1V1PetId = data.id,
				templateId = data.templateId
			}

			pg.me:notifyPetSelectChange(arg, function(res)
				if not res then
					return
				end

				self.model:selectPet(pos, data)
				self:selectPet(false, true, pos, data, item)
				item:TryChangePage("State", 1)

				local orc = item:GetComponent("ObjectReference")
				local iOrder = orc:GetRefValue("order")

				ClientTextUtils.setText(iOrder, pos)
			end)
		end
	else
		local arg = isFairMode and {
			isSelect = false,
			pos = selectPos,
			PVP1V1PetId = data.templateId
		} or {
			isSelect = false,
			pos = selectPos,
			PVP1V1PetId = data.id,
			templateId = data.templateId
		}

		pg.me:notifyPetSelectChange(arg, function(res)
			if not res then
				return
			end

			self.model:deSelectPet(selectPos)
			self:deSelectPet(false, selectPos, item)
			item:TryChangePage("State", 0)
		end)
	end
end

function PvpChoseCtrl:selectPet(isEnemy, iconState, pos, data, item)
	self.pvpModelCmp:showModel(isEnemy, pos, data)

	if IsNil(item) then
		return
	end

	item:TryChangePage("console", 1)
end

function PvpChoseCtrl:deSelectPet(isEnemy, pos, item)
	self.pvpModelCmp:hideModel(isEnemy, pos)

	if IsNil(item) then
		return
	end

	item:TryChangePage("console", 0)
end

function PvpChoseCtrl:petSelectChangeEvent(args)
	if args.isSelect then
		self:selectPet(true, false, args.pos, args)
	else
		self:deSelectPet(true, args.pos)
	end
end

function PvpChoseCtrl:refreshPetRestraint(data)
	for btn, v in pairs(self.enemyMap) do
		local factor = 1

		for element, _ in pairs(data.elements) do
			factor = factor * Utils.getElementAgainstValue(element, v.elements)
		end

		if factor == 1 then
			btn:TryChangePage("Resist", 1)
		elseif factor < 1 then
			btn:TryChangePage("Resist", 2)
		else
			btn:TryChangePage("Resist", 0)
		end
	end
end

function PvpChoseCtrl:onBtnConfirm()
	if not self.model:checkCanReady() then
		pg.global.showBubbleMessage(2222)

		return
	end

	pg.me:playerGetReady(function(res)
		if not res then
			return
		end

		self.view.player1:TryChangePage("State", 2)

		self.model.confirmTeam = true

		LuaUIUtils.setUIViewVisible(self.view.btnConfirm, false)
	end)
end

function PvpChoseCtrl:enemyGetReadyEvent()
	self.view.player2:TryChangePage("State", 2)
end

function PvpChoseCtrl:bothGetReadyEvent(matchInfo)
	self.view.player1:TryChangePage("State", 2)
	self.view.player2:TryChangePage("State", 2)
	self.view.component:TryChangePage("State", 2)
	self.pvpModelCmp:startLoading(matchInfo)
end

function PvpChoseCtrl:onInputDeviceChanged(deviceType)
	self.gamePadCmp:onInputDeviceChanged(deviceType)
end

function PvpChoseCtrl:onHide()
	return
end

return PvpChoseCtrl
