-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\NpcInteract\\RandomDialogue.lua

local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local PetRandomTextData = require("Data.pet_random_text_data")
local InteractionConst = require("Common.Const.InteractionConst")
local DialogueConst = require("Const.DialogueConst")
local MessageName = require("Const.MessageName")
local lume = require("Core.Common.lume")
local RandomDialogue = {}

function RandomDialogue:buildRandomDialogueTextData()
	local ret

	if self.staticSceneEntityData then
		ret = {}

		if self.staticSceneEntityData.puppetDialogues then
			for _, dialogData in ipairs(self.staticSceneEntityData.puppetDialogues) do
				table.insert(ret, {
					weight = 1,
					text = dialogData.id
				})
			end
		end

		self.allowRandomDialogueHandlePetEthnicGroup = self.staticSceneEntityData.unknowDialogue

		if ToBool(self.staticSceneEntityData.isCancelDialogue) then
			return ToBool(ret) and ret or nil
		end
	end

	local prototypeId = Utils.getPuppetPetPrototypeId(self.templateId)
	local randomTextData = PetRandomTextData[prototypeId]

	if randomTextData then
		local petNature = self.nature or 0

		if ret == nil then
			ret = {}
		end

		for _, info in pairs(randomTextData) do
			if info.pet_nature == petNature and info.dialogue_id ~= nil then
				table.insert(ret, {
					weight = info.weight,
					text = info.dialogue_id
				})
			end
		end
	end

	return ToBool(ret) and ret or nil
end

function RandomDialogue:getWeightedRandomText()
	local weights = {}

	for index, info in ipairs(self.randomDialogueTextData) do
		if self.lastSelectedRandomDialogueTextIndex ~= index then
			weights[#weights + 1] = info.weight
		else
			weights[#weights + 1] = 0
		end
	end

	local index = lume.weightedchoice(weights) or 1

	self.lastSelectedRandomDialogueTextIndex = index

	return self.randomDialogueTextData[index].text, self.randomDialogueTextData[index].isDialogueGraph
end

function RandomDialogue:canInteract()
	if not ClientUtils.checkEntityCanBeInteracted(self) then
		return false
	end

	if not self.allowRandomDialogueHandlePetEthnicGroup and ClientUtils.checkTargetEntityDifferentEthnicGroupWithPawn(self) then
		return false
	end

	return true
end

function RandomDialogue:needRefreshOnPlayerSwitch()
	return self.randomDialogueTextData ~= nil and not self.allowRandomDialogueHandlePetEthnicGroup
end

function RandomDialogue:buildEntityDialogueGraphData()
	local ret

	if self.staticSceneEntityData and self.staticSceneEntityData.puppetSession then
		ret = {}

		for idx, data in ipairs(self.staticSceneEntityData.puppetSession) do
			table.insert(ret, {
				checkEntity = true,
				handlePetEthnicGroup = true,
				globalId = self:getGlobalId(),
				interactionType = InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION,
				actionPrototypeId = idx * 100000 + 1001,
				interactFunc = function()
					pg.global.ui.interact:hide()
					pg.game.dialogue:playDialogueGraph(data.id, function()
						pg.global.ui.interact:show()
					end, nil, {
						globalId = self.id,
						dialogueSrc = DialogueConst.SrcType.Interaction
					})
				end
			})
		end
	end

	return ret
end

function RandomDialogue:onEnterSpace()
	local pdata = self:getConfigData()
	local useRandomDialogText = pdata and ToBool(pdata.use_randomtxt) or false

	if useRandomDialogText then
		self.randomDialogueTextData = RandomDialogue.buildRandomDialogueTextData(self)

		if self.randomDialogueTextData ~= nil then
			self.lastSelectedRandomDialogueTextIndex = nil
		end
	end

	self.entityDialogueGraphData = RandomDialogue.buildEntityDialogueGraphData(self)
end

function RandomDialogue:onEnter()
	if self.entityDialogueGraphData then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self.entityDialogueGraphData)
	end

	if self.randomDialogueTextData ~= nil and RandomDialogue.canInteract(self) then
		self.curRandomDialogueTextData = {
			actionPrototypeId = 1001,
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_PUPPET_RANDOM_DIALOGUE,
			interactFunc = function()
				local dialogueId, isDialogueGraph = RandomDialogue.getWeightedRandomText(self)

				if isDialogueGraph then
					pg.global.ui.interact:hide()
					pg.game.dialogue:playDialogueGraph(dialogueId, function()
						pg.global.ui.interact:show()
					end, nil, {
						globalId = self.id,
						dialogueSrc = DialogueConst.SrcType.Interaction
					})
				else
					pg.game.communication:startNpcDialog(dialogueId, self.id, {
						disableTurn = true,
						disableCameraAnim = true,
						src = DialogueConst.SrcType.Interaction
					})
				end
			end,
			handlePetEthnicGroup = self.allowRandomDialogueHandlePetEthnicGroup
		}

		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self.curRandomDialogueTextData)
	elseif self.allowRandomDialogueHandlePetEthnicGroup and self.randomDialogueTextData == nil then
		self.curRandomDialogueTextData = {
			actionPrototypeId = 1001,
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_PUPPET_RANDOM_DIALOGUE,
			handlePetEthnicGroup = self.allowRandomDialogueHandlePetEthnicGroup
		}

		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self.curRandomDialogueTextData)
	end
end

function RandomDialogue:onLeave()
	if self.entityDialogueGraphData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self.entityDialogueGraphData)
	end

	if self.curRandomDialogueTextData ~= nil then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.curRandomDialogueTextData)

		self.curRandomDialogueTextData = nil
	end
end

function RandomDialogue:onEnterCombat()
	if self.curRandomDialogueTextData ~= nil then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.curRandomDialogueTextData)

		self.curRandomDialogueTextData = nil
	end
end

function RandomDialogue:contributeDist()
	if self.randomDialogueTextData or self.entityDialogueGraphData then
		return 2
	end

	return 0
end

return RandomDialogue
