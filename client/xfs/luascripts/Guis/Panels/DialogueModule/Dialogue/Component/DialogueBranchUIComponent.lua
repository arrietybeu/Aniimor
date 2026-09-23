-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\Dialogue\\Component\\DialogueBranchUIComponent.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local UIComponent = require("Guis.Helper.UIComponent")
local AddressDataConst = require("Const.AddressDataConst")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DialogueBranchUIComponent = Class.LightClass("DialogueBranchUIComponent", UIComponent)

function DialogueBranchUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.dialogueBranchList = self.objectReference:GetRefValue("dialogueBranchList")
	self.talkListUComponent = self.objectReference:GetRefValue("talkListUComponent")
end

function DialogueBranchUIComponent:initView()
	function self.dialogueBranchList.luaRenderItem(button, index, data)
		button.customData = data

		self:setupMultiDialogueBranchBtn(button, index, data)
	end

	self:show()
end

function DialogueBranchUIComponent:refreshDialogueBranchOption(optionList)
	local branchData = self:getCurrentDialogueBranchInfo(optionList)

	if #branchData <= 0 then
		self:setSelectData({})
		LuaUIUtils.setUIViewVisible(self.dialogueBranchList, false)
	end

	if #branchData >= 1 then
		pg.global.inputMgr:SetInputActionEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom, false, HotkeyConst.INPUT_BLOCK_FLAG.Dialogue)
	else
		pg.global.inputMgr:SetInputActionEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom, true, HotkeyConst.INPUT_BLOCK_FLAG.Dialogue)
	end

	if #branchData > 1 then
		self.talkListUComponent:TryChangePage("Scroll", 1)
	else
		self.talkListUComponent:TryChangePage("Scroll", 0)
	end

	self.selectedBtn = nil

	LuaUIUtils.setUIViewVisible(self.dialogueBranchList, true)
	self.dialogueBranchList:SetList(branchData)

	if not pg.global.ui:runPlatformByMobile() then
		self:trySelectDialogueOptionBtn()
	end
end

function DialogueBranchUIComponent:setSelectData(data)
	self.selectData = data

	if self.ctrl.onSelectItemChange then
		self.ctrl:onSelectItemChange()
	end
end

function DialogueBranchUIComponent:getCurInteractItem()
	return self.selectData
end

function DialogueBranchUIComponent:setBtnActionEnable(button)
	if self.selectedBtn and self.selectedBtn ~= button then
		self.selectedBtn.visualInteractable = not self.selectedBtn.customData.hasSelected
		self.selectedBtn.customData.keyBind.actionPath = ""
		self.selectedBtn.customData.keyBind.priority = 0
	end

	self.selectedBtn = button
	self.selectedBtn.visualInteractable = true
	self.selectedBtn.customData.keyBind.actionPath = self.selectedBtn.customData.actionPath
	self.selectedBtn.customData.keyBind.priority = 1000

	self:setSelectData(button.customData)
end

function DialogueBranchUIComponent:onMouseScroll(delta)
	local curIdx = self.dialogueOptionSelectedIndex
	local itemCount = self.dialogueOptionNum

	if not itemCount then
		return false
	end

	local nextIdx = curIdx

	if itemCount and itemCount > 0 and curIdx ~= nil then
		if delta > 0 then
			nextIdx = math.max(curIdx - 1, self.dialogueOptionBeginIndex)
		else
			nextIdx = math.min(curIdx + 1, self.dialogueOptionEndIndex)
		end

		if nextIdx ~= curIdx then
			self.dialogueBranchList:SelectItem(nextIdx)

			self.dialogueOptionSelectedIndex = nextIdx

			local flag, button = self.dialogueBranchList:TryGetChildAt(nextIdx)

			self:setBtnActionEnable(button)
		end
	elseif itemCount and itemCount > 0 then
		if delta > 0 then
			nextIdx = self.dialogueOptionEndIndex
		else
			nextIdx = self.dialogueOptionBeginIndex
		end

		self.dialogueBranchList:SelectItem(nextIdx)

		self.dialogueOptionSelectedIndex = nextIdx

		local flag, button = self.dialogueBranchList:TryGetChildAt(nextIdx)

		self:setBtnActionEnable(button)
	end

	return itemCount > 1
end

function DialogueBranchUIComponent:onGamepadSwitch()
	local curIdx = self.dialogueOptionSelectedIndex
	local itemCount = self.dialogueOptionNum
	local nextIdx = curIdx

	if itemCount and itemCount > 0 and curIdx ~= nil then
		nextIdx = (curIdx + 1) % itemCount

		if nextIdx ~= curIdx then
			self.dialogueBranchList:SelectItem(nextIdx)

			self.dialogueOptionSelectedIndex = nextIdx

			local flag, button = self.dialogueBranchList:TryGetChildAt(nextIdx)

			self:setBtnActionEnable(button)
		end
	elseif itemCount and itemCount > 0 then
		nextIdx = self.dialogueOptionBeginIndex

		self.dialogueBranchList:SelectItem(nextIdx)

		self.dialogueOptionSelectedIndex = nextIdx

		local flag, button = self.dialogueBranchList:TryGetChildAt(nextIdx)

		self:setBtnActionEnable(button)
	end

	return itemCount > 1
end

function DialogueBranchUIComponent:getCurrentDialogueBranchInfo(optionList)
	local ret = {}

	self.allNotImportant = true
	self.showTime = pg.me:getGameTime()

	for idx, optionInfo in pairs(optionList) do
		local temp = {}

		temp.btnIcon = optionInfo.btnIcon or AddressDataConst.BRANCH_OPTION_ICON
		temp.btnTitle = optionInfo.optionText
		temp.dialogueId = optionInfo.dialogueId
		temp.id = optionInfo.id
		temp.nextDialogueId = optionInfo.nextDialogueId
		temp.index = #ret
		temp.hasSelected = optionInfo.hasSelected
		temp.callback = optionInfo.callback
		temp.important = optionInfo.important
		ret[#ret + 1] = temp

		if optionInfo.important then
			self.allNotImportant = false
		end
	end

	if self.allNotImportant then
		for _, temp in pairs(ret) do
			temp.actionPath = "Hud/InteractSouth"
		end
	else
		for _, temp in pairs(ret) do
			temp.actionPath = "Hud/Interact"
		end
	end

	return ret
end

function DialogueBranchUIComponent:setupMultiDialogueBranchBtn(button, idx, data, customInfo)
	local objectReference = button:GetComponent("ObjectReference")

	button.customData.keyBind = button:GetComponent("KeyBindingPro")

	local icon = objectReference:GetRefValue("iconUImage")
	local txtNameOneUSDFText = objectReference:GetRefValue("txtNameOneUSDFText")
	local txtNameTwoUSDFText = objectReference:GetRefValue("txtNameTwoUSDFText")

	txtNameOneUSDFText:SetActive(false)
	txtNameTwoUSDFText:SetActive(false)

	local iconUrl = data.btnIcon

	if iconUrl and iconUrl:match("^%$(.+)%.png$") then
		local iconName = iconUrl:match("^%$(.+)%.png$")

		iconUrl = string.format("%s[%s]", iconUrl, iconName)
	end

	icon:SetUrlWithCallback(iconUrl, function()
		local width = icon:GetSpriteSize()[1]

		if width >= 100 then
			button:TryChangePage("stage", 1)
		elseif width <= 36 then
			button:TryChangePage("stage", 0)
		else
			button:TryChangePage("stage", 2)
		end
	end)

	if data.btnIcon == nil then
		LuaUIUtils.setUIViewVisible(icon, false)
	else
		LuaUIUtils.setUIViewVisible(icon, true)
	end

	ClientTextUtils.setText(txtNameOneUSDFText, LuaUIUtils.getReplacedDialogueText(data.btnTitle))

	button.enabledVisualSelect = true
	button.visualInteractable = not data.hasSelected

	if txtNameOneUSDFText:IsTextOverflowing() then
		ClientTextUtils.setText(txtNameTwoUSDFText, LuaUIUtils.getReplacedDialogueText(data.btnTitle))
		txtNameTwoUSDFText:SetActive(true)
	else
		txtNameOneUSDFText:SetActive(true)
	end

	function button.luaHover()
		if not button.isSelected then
			self.dialogueBranchList:SelectItem(data.index)

			self.dialogueOptionSelectedIndex = data.index

			self:setBtnActionEnable(button)
		end
	end

	LuaUIUtils.setUIViewVisible(button, true)

	function button.luaClick()
		if self.showTime == nil or pg.me:getGameTime() - self.showTime < 0.5 then
			return false
		end

		pg.game.communication:addPlayerChoiceReviewLog(data.btnTitle, data.dialogueId)

		if data.callback then
			data.callback(data.id)

			return false
		else
			self.ctrl:onBranchOptionClick(data.nextDialogueId, data.index, customInfo)
		end

		return true
	end

	button.customData.keyBind.isVirtual = true

	function button.customData.keyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			button:OnClickSimulate()
		end
	end
end

function DialogueBranchUIComponent:trySelectDialogueOptionBtn()
	local isFirst = true
	local itemData = self.dialogueBranchList.itemData
	local firstBtn, firstIndex
	local nums = 0

	for i = 1, itemData.Count do
		local index = i - 1
		local flag, button = self.dialogueBranchList:TryGetChildAt(index)

		if flag and button then
			nums = nums + 1

			if isFirst then
				firstBtn = button
				firstIndex = index
				isFirst = false
			end
		end
	end

	self.dialogueOptionNum = nums

	if nums <= 0 then
		return
	end

	self.dialogueOptionBeginIndex = firstIndex
	self.dialogueOptionEndIndex = firstIndex + nums - 1
	self.dialogueOptionSelectedIndex = nil

	self.dialogueBranchList:SelectItem(firstIndex)

	self.dialogueOptionSelectedIndex = firstIndex

	self:setBtnActionEnable(firstBtn)
end

function DialogueBranchUIComponent:onInputDeviceChange()
	if self.selectedBtn then
		self:setBtnActionEnable(self.selectedBtn)
	end
end

function DialogueBranchUIComponent:clickSelectData(needImportant)
	if self.selectedBtn then
		local data = self.selectedBtn.customData

		if needImportant then
			if data and data.isImportant then
				self.selectedBtn.luaClick()
			else
				return true
			end
		else
			self.selectedBtn.luaClick()
		end
	else
		return true
	end
end

return DialogueBranchUIComponent
