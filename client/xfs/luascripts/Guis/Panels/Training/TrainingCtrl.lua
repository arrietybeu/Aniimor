-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Training\\TrainingCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local TrainingCtrl = Class.LightClass("TrainingCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local PuppetData = require("Data.puppet_data")
local ConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")

TrainingCtrl.PUPPET_TEMPLATE_ID = {
	11001100,
	11001200,
	11002100,
	11002300,
	11003100,
	11003200,
	11004100,
	11004300,
	11005100,
	11005300,
	11007100,
	11007200,
	11008100,
	11008300,
	11012200
}
TrainingCtrl.DEFAULT_PUPPET_ID = TrainingCtrl.PUPPET_TEMPLATE_ID[1]

function TrainingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.selectPetId = self.DEFAULT_PUPPET_ID

	self:generateDefaultPuppet()
end

function TrainingCtrl:onShow()
	UICtrl.onShow(self)
end

function TrainingCtrl:preProcessing()
	self.trainingPets = {}

	if ConfigData.TrainGroundPetList == nil then
		for _, v in pairs(self.PUPPET_TEMPLATE_ID) do
			local trainingPet = {}

			trainingPet.petId = v
			self.trainingPets[#self.trainingPets + 1] = trainingPet
		end
	else
		for _, v in pairs(ConfigData.TrainGroundPetList) do
			local trainingPet = {}

			trainingPet.petId = v
			self.trainingPets[#self.trainingPets + 1] = trainingPet
		end
	end
end

function TrainingCtrl:addListener()
	self:preProcessing()

	function self.view.exitBtn.luaClick()
		pg.me:tryTeleportToScene(3000, 0)
	end

	function self.view.resetBtn.luaClick()
		self:selectPet(self.DEFAULT_PUPPET_ID)
		self:generatePuppet()

		self.view.openAIState = true

		self.view.root:TryChangePage("ChoiceOpenBtn", 1)
		pg.me:serverMsg("RPC_CS_StumpPuppetSwitch", self.view.openAIState)
	end

	function self.view.petChoiceList.luaRenderItem(button, index, data)
		self:setTrainingPetInfo(button, index, data)
	end

	function self.view.petChoiceList.luaClick(button, data)
		self:selectPet(data.petId)
		self:generatePuppet()
	end

	self.view.petChoiceList:SetList(self.trainingPets)
	TimerManager.addTimer(0.1, function()
		self:selectPet(self.selectPetId)
	end)

	function self.view.openPuppetBtn.luaClick()
		self.view.root:TryChangePage("PuppetChoiceOpenBtn", 0)
		self:destroyPuppet()
	end

	function self.view.closePuppetBtn.luaClick()
		self.view.root:TryChangePage("PuppetChoiceOpenBtn", 1)
		self:generatePuppet()
	end
end

function TrainingCtrl:selectPet(petId)
	self.selectPetId = petId

	local buttons = self.view.petChoiceList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local button = buttons[i]

		button:TryChangePage("IsSelected", button.gameObject.name == tostring(petId) and 1 or 0)
	end
end

function TrainingCtrl:setTrainingPetInfo(button, index, data)
	button.gameObject.name = data.petId

	local objRef = button:GetComponent("ObjectReference")
	local petIcon = objRef:GetRefValue("petIcon")

	petIcon.url = LuaUIUtils.getPetIcon(PuppetData[data.petId].iconName, LuaUIUtils.PET_ICON)
end

function TrainingCtrl:generatePuppet()
	local me = pg.me
	local aiOn = self.view.openAIState
	local damageOff = true

	me:serverMsg("RPC_CS_TestCreateStumpPuppet", self.selectPetId, aiOn, damageOff)
end

function TrainingCtrl:generateDefaultPuppet()
	local me = pg.me
	local aiOn = true
	local damageOff = true

	me:serverMsg("RPC_CS_TestCreateStumpPuppet", self.DEFAULT_PUPPET_ID, aiOn, damageOff)
end

function TrainingCtrl:destroyPuppet()
	local me = pg.me

	me:serverMsg("RPC_CS_DestoryStumpPuppet")
end

return TrainingCtrl
