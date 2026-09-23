-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenu\\Component\\FuncMenuGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local BaseGamePadComponent = require("Guis.GamePad.BaseGamePadComponent")
local FuncMenuGamePadComponent = Class.LightClass("FuncMenuGamePadComponent", BaseGamePadComponent)
local GamePadConst = require("Guis.GamePad.GamePadConst")

FuncMenuGamePadComponent.AREAS = {
	CHOICE_AREA = 1,
	FUNCTION_AREA = 2
}

function FuncMenuGamePadComponent:onRegisterListener()
	function self.uiView.listBtnUList.luaBindToList(uList)
		self:bind_ChoiceArea(uList)
	end

	function self.uiView.listBtnUList.luaBindToSlot(uBtn, index, data)
		return
	end
end

function FuncMenuGamePadComponent:onRegisterKeyEvent()
	self:addConsoleEvent({
		GamePadConst.FUNCTION_INDEX.X,
		GamePadConst.FUNCTION_INDEX.A,
		GamePadConst.FUNCTION_INDEX.LEFT_STICK
	})
end

function FuncMenuGamePadComponent:onBindStaticArea()
	return
end

function FuncMenuGamePadComponent:onBindDynamicArea()
	return
end

function FuncMenuGamePadComponent:bind_ChoiceArea(xBtnList)
	local area = self:addNewArea(self.AREAS.CHOICE_AREA)

	area:setMatchType(GamePadConst.MATCH_MODE.MATCH_DISTANCE)

	local btnList = xBtnList:GetAllButtons()

	if btnList.Length == 0 then
		return
	end

	local size = 0
	local lastX = 0
	local yStart = 0

	for i = 1, btnList.Length do
		local uBtn = btnList[i - 1]
		local data = uBtn.dataFromUList
		local x = math.floor(size / 3) + 1

		if lastX ~= x then
			lastX = x
			yStart = i
		end

		local y = i - yStart + 1
		local slot = area:addSlot(x, y)

		slot:bindUWidget(uBtn)
		slot:bindOpUIList(self.uiView.consoleKeyUList)
		slot:setPreFocus(function(x1, y1)
			return
		end)
		slot:setFocus(function(x1, y1)
			uBtn:DoHover()
		end)
		slot:setDisFocus(function(x1, y1)
			return
		end)
		slot:setFunc(GamePadConst.FUNCTION_INDEX.B, pg.getGameString("BACK_TO_PRE"), function(x1, y1)
			return
		end)
		slot:setFunc(GamePadConst.FUNCTION_INDEX.A, nil, function(x1, y1)
			slot:onClickSimulate()
		end)
		slot:setFunc(GamePadConst.FUNCTION_INDEX.START, nil, function(x1, y1)
			return
		end)

		size = size + data.size
	end

	self:focusImmediate(self.AREAS.CHOICE_AREA, 1, 1)
end

function FuncMenuGamePadComponent:startCountDown()
	if self.xKeyButton == nil then
		return
	end

	local countDown = self.xKeyButton:GetChild("CountDown"):GetComponent("UCountDown")

	function countDown.luaFinished()
		countDown:SetActive(false)
	end

	countDown:SetActive(true)
	countDown:Play(self.navigation.longPressDelay)
end

function FuncMenuGamePadComponent:endCountDown()
	if self.xKeyButton == nil then
		return
	end

	local countDown = self.xKeyButton:GetChild("CountDown"):GetComponent("UCountDown")

	countDown:SetActive(false)
end

function FuncMenuGamePadComponent:onDestroy()
	self.root = nil
	self.functionUList = nil
	self.choiceUList = nil
	self.navigation = nil
	self.disableLeftStickMove = true
	self.xKeyButton = nil
end

return FuncMenuGamePadComponent
