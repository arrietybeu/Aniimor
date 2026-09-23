-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SlotMachine.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local PlayableConst = require("Common.Const.PlayableConst")
local SlotMachine = Class.LightClass("SlotMachine", LevelItem)

function SlotMachine:ctor(sandbox, spawnInfo, syncInfo)
	SlotMachine.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.scrollRate = 80
	self.oneImgSize = 400
	self.maxScrollCol = 3
	self.delayShowResultTime = 10
	self.showInterval = 1.5
	self.startDelayTime = 0.5
	self.parmonDelayTime = 0.5
	self.scrollImgs = {}
	self.result = {}
	self.lastResultIndex = {}
	self.cheerStartTime = 0.54
	self.applaudStartTime = 0.58
	self.prompts = {}
	self.slotMachineShowEventId = 1144
	self.slotMachineStartEventId = 1145
	self.slotMachineStopEventId1 = 1146
	self.slotMachineStopEventId2 = 1147
	self.slotMachineStopEventId3 = 1148
	self.slotMachineRewardEventId1 = 1149
	self.slotMachineRewardEventId2 = 1149
	self.slotMachineRewardEventId3 = 1149
	self.slotMachineFxEventId = 1150
	self.globalVariableId = 1037
end

function SlotMachine:destroy()
	SlotMachine.super.destroy(self)

	if pg.me.isPlayingSlotMachine then
		pg.game.camera:cancelBlendToFixed(1)

		pg.me.isPlayingSlotMachine = false

		if pg.me.updateStateCache then
			pg.me:updateStateCache("PLAY_SLOT_MACHINE_ST")
		end

		pg.game.audio:stopEvent("SFX_SceneObject_ARK_SlotMachine_Loop")
		pg.global.ui.interact:show()
	end

	for _, prompt in ipairs(self.prompts) do
		pg.global.resMgr:RemoveInstanceToCache(prompt)
	end

	if self.golden ~= nil then
		pg.global.resMgr:RemoveInstanceToCache(self.golden)
	end
end

function SlotMachine:onSandboxReady()
	self.slotMachineCom = self.shell.gameObject:GetComponent("SlotMachine")

	if self.slotMachineCom then
		self.scrollRate = self.slotMachineCom.scrollRate
		self.delayShowResultTime = self.slotMachineCom.delayShowResultTime
		self.showInterval = self.slotMachineCom.showInterval
		self.startDelayTime = self.slotMachineCom.startDelayTime
		self.npcBoyStaticId = self.slotMachineCom.npcBoyStaticId
		self.npcGirl1StaticId = self.slotMachineCom.npcGirl1StaticId
		self.npcGirl2StaticId = self.slotMachineCom.npcGirl2StaticId
		self.npcShellStaticId = self.slotMachineCom.npcShellStaticId
		self.npcCrabStaticId = self.slotMachineCom.npcCrabStaticId
		self.npcDogStaticId = self.slotMachineCom.npcDogStaticId
		self.npcParmon1StaticId = self.slotMachineCom.npcParmon1StaticId
		self.npcParmon2StaticId = self.slotMachineCom.npcParmon2StaticId
		self.npcParmon3StaticId = self.slotMachineCom.npcParmon3StaticId

		self:findNpcs()

		self.cheerLoopTime = self.slotMachineCom.cheerLoopTime
		self.applaudLoopTime = self.slotMachineCom.applaudLoopTime
	end

	self.fxRoot = self.shell.gameObject.transform:Find("Fx")
	self.camera = self.shell.gameObject.transform:Find("Camera")
	self.canvasRoot = self.shell.gameObject.transform:Find("Canvas")
	self.leftPanel = self.canvasRoot:Find("Left")
	self.midPanel = self.canvasRoot:Find("Mid")
	self.rightPanel = self.canvasRoot:Find("Right")
	self.leftImages = {}

	for i = 0, self.leftPanel.childCount - 1 do
		table.insert(self.leftImages, self.leftPanel:GetChild(i))
	end

	table.insert(self.scrollImgs, self.leftImages)

	self.midImages = {}

	for i = 0, self.midPanel.childCount - 1 do
		table.insert(self.midImages, self.midPanel:GetChild(i))
	end

	table.insert(self.scrollImgs, self.midImages)

	self.rightImages = {}

	for i = 0, self.rightPanel.childCount - 1 do
		table.insert(self.rightImages, self.rightPanel:GetChild(i))
	end

	table.insert(self.scrollImgs, self.rightImages)
end

function SlotMachine:findNpcs()
	if not self.npcShell then
		self.npcShell = pg.me.space:getEntityByStaticId(self.npcShellStaticId)
	end

	if not self.npcCrab then
		self.npcCrab = pg.me.space:getEntityByStaticId(self.npcCrabStaticId)
	end

	if not self.npcDog then
		self.npcDog = pg.me.space:getEntityByStaticId(self.npcDogStaticId)
	end

	if not self.npcBoy then
		self.npcBoy = pg.me.space:getEntityByStaticId(self.npcBoyStaticId)
	end

	if not self.npcGirl1 then
		self.npcGirl1 = pg.me.space:getEntityByStaticId(self.npcGirl1StaticId)
	end

	if not self.npcGirl2 then
		self.npcGirl2 = pg.me.space:getEntityByStaticId(self.npcGirl2StaticId)
	end

	if not self.npcParmon1 then
		self.npcParmon1 = pg.me.space:getEntityByStaticId(self.npcParmon1StaticId)
	end

	if not self.npcParmon2 then
		self.npcParmon2 = pg.me.space:getEntityByStaticId(self.npcParmon2StaticId)
	end

	if not self.npcParmon3 then
		self.npcParmon3 = pg.me.space:getEntityByStaticId(self.npcParmon3StaticId)
	end
end

function SlotMachine:startPlay(npcFx)
	if self.playingTimer then
		return
	end

	pg.me:requestSetCustomVariable(self.globalVariableId, 1)

	pg.me.isPlayingSlotMachine = true

	if pg.me.updateStateCache then
		pg.me:updateStateCache("PLAY_SLOT_MACHINE_ST")
	end

	self.result = {}

	if npcFx then
		pg.game.audio:playEvent("SFX_SceneObject_ARK_SlotMachine_Coin")
		self.slotMachineCom:StartNpcFx(npcFx.actorId)

		self.npcFx = npcFx

		pg.game.audio:playEvent("SFX_SceneObject_ARK_SlotMachine_Pull")
		self:addTimer(5.8, function()
			self.slotMachineCom:PauseNpcFx()
		end)
	end

	local startDelayTime = self.startDelayTime

	self:addTimer(startDelayTime, function()
		pg.global.ui.interact:hide()
		pg.me:doEvent(self.slotMachineShowEventId)
		self:resetMachine()
		pg.game.camera:cameraBlendToFixed(self.camera.position, self.camera.rotation, self.slotMachineCom:GetPresetCameraFov(), 1, function()
			pg.me:doEvent(self.slotMachineStartEventId)

			self.playingTimer = self:addTimer(0.03, function()
				local isPlaying = false

				for i = 1, self.maxScrollCol do
					if not self.result[i] then
						local imgCount = #self.scrollImgs[i]

						for _, img in ipairs(self.scrollImgs[i]) do
							local newPosY = img.anchoredPosition.y + self.scrollRate

							if newPosY > self.oneImgSize * math.floor(imgCount / 2) then
								newPosY = newPosY - self.oneImgSize * imgCount
							end

							img.anchoredPosition = Vector2(img.anchoredPosition.x, newPosY)
						end

						isPlaying = true
					end
				end

				if not isPlaying then
					self:handleResult()
					self:removeTimer(self.playingTimer)

					self.playingTimer = nil
				end
			end, true)
		end)
	end)
end

function SlotMachine:setResult(result)
	local delayTime = self.delayShowResultTime

	for i, value in ipairs(result) do
		self:addTimer(delayTime, function()
			self.result[i] = value

			pg.me:doEvent(self["slotMachineStopEventId" .. i])

			for index, img in ipairs(self.scrollImgs[i]) do
				if tonumber(img.gameObject.name) == value then
					self.lastResultIndex[i] = index
					img.anchoredPosition = Vector2(img.anchoredPosition.x, 0)
				else
					img.gameObject:SetActiveEx(false)
				end
			end

			if self.prompts[i] == nil then
				pg.global.resMgr:GetInstanceFromCacheByLua("$Eff_Env_Build_Centre_Prompt_0" .. i .. ".prefab", function(obj, userData)
					self.prompts[i] = obj
				end, 1, nil, self.slotMachineCom.transform, true)
			else
				self.prompts[i]:SetActiveEx(true)
			end
		end)

		delayTime = delayTime + self.showInterval
	end
end

function SlotMachine:handleResult()
	pg.game.audio:stopEvent("SFX_SceneObject_ARK_SlotMachine_Loop")

	if self.result[1] and self.result[1] == self.result[2] and self.result[1] == self.result[3] then
		self.fxRoot.gameObject:SetActiveEx(true)
		pg.me:doEvent(self.slotMachineRewardEventId3)
		pg.me:doEvent(self.slotMachineFxEventId)
		self:addTimer(1, function()
			if self.golden == nil then
				pg.global.resMgr:GetInstanceFromCacheByLua("$Eff_Env_Build_Centre_golden.prefab", function(obj, userData)
					self.golden = obj
				end, 1, nil, self.slotMachineCom.transform, true)
			else
				self.golden:SetActiveEx(true)
			end
		end)
		self:addTimer(6, function()
			if self.golden then
				self.golden:SetActiveEx(false)
			end

			self:PlayFinish()
		end)
	elseif self.result[1] ~= self.result[2] and self.result[1] ~= self.result[3] and self.result[2] ~= self.result[3] then
		pg.me:doEvent(self.slotMachineRewardEventId1)
		self:addTimer(2, function()
			self:PlayFinish()
		end)
	else
		pg.me:doEvent(self.slotMachineRewardEventId2)
		self:addTimer(2, function()
			self:PlayFinish()
		end)
	end
end

function SlotMachine:PlayFinish()
	pg.game.camera:cancelBlendToFixed(1)

	pg.me.isPlayingSlotMachine = false

	if pg.me.updateStateCache then
		pg.me:updateStateCache("PLAY_SLOT_MACHINE_ST")
	end

	pg.global.ui.interact:show()

	if self.npcFx then
		self.slotMachineCom:PlayNpcFx()
		self:addTimer(1, function()
			self.slotMachineCom:StopNpcFx()
			self.npcFx.eModel:SetActive(false)
			self.npcFx.eModel:SetActive(true)
		end)
	end

	for _, prompt in ipairs(self.prompts) do
		prompt:SetActiveEx(false)
	end

	pg.me:requestSlotReward(1)
	self:findNpcs()

	if self.result[1] and self.result[1] == self.result[2] and self.result[1] == self.result[3] then
		self.npcShell:playAnimation(PlayableConst.Behav_Happy)
		self.npcCrab:playAnimation(PlayableConst.Behav_Happy)
		self.npcDog:playAnimation(PlayableConst.Behav_Happy)
		self.npcParmon1:playAnimation(PlayableConst.EnvBehav_Clap)
		self:addTimer(self.parmonDelayTime, function()
			self.npcParmon2:playAnimation(PlayableConst.EnvBehav_Clap)
			self:addTimer(self.parmonDelayTime, function()
				self.npcParmon3:playAnimation(PlayableConst.EnvBehav_Clap)
			end)
		end)
		self.npcBoy:playAnimation(PlayableConst.Emotion_Cheer_Start, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		self.npcGirl1:playAnimation(PlayableConst.Emotion_Cheer_Start, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		self.npcGirl2:playAnimation(PlayableConst.Emotion_Cheer_Start, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		self:addTimer(self.cheerStartTime, function()
			self.npcBoy:playAnimation(PlayableConst.Emotion_Cheer_Loop, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl2:playAnimation(PlayableConst.Emotion_Cheer_Loop, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		end)
		self:addTimer(self.cheerStartTime + self.cheerLoopTime, function()
			self.npcBoy:playAnimation(PlayableConst.Emotion_Cheer_End, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl1:playAnimation(PlayableConst.Emotion_Cheer_End, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl2:playAnimation(PlayableConst.Emotion_Cheer_End, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		end)
	else
		self.npcShell:playAnimation(PlayableConst.Behav_Love)
		self.npcCrab:playAnimation(PlayableConst.Behav_Love)
		self.npcDog:playAnimation(PlayableConst.Behav_Love)
		self.npcBoy:playAnimation(PlayableConst.Emotion_Applaud_Start, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		self.npcGirl1:playAnimation(PlayableConst.Emotion_Applaud_Start, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		self.npcGirl2:playAnimation(PlayableConst.Emotion_Applaud_Start, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		self:addTimer(self.applaudStartTime, function()
			self.npcBoy:playAnimation(PlayableConst.Emotion_Applaud_Loop, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl1:playAnimation(PlayableConst.Emotion_Applaud_Loop, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl2:playAnimation(PlayableConst.Emotion_Applaud_Loop, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		end)
		self:addTimer(self.applaudStartTime + self.applaudLoopTime, function()
			self.npcBoy:playAnimation(PlayableConst.Emotion_Applaud_End, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl1:playAnimation(PlayableConst.Emotion_Applaud_End, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			self.npcGirl2:playAnimation(PlayableConst.Emotion_Applaud_End, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		end)
	end
end

function SlotMachine:resetMachine()
	self.fxRoot.gameObject:SetActiveEx(false)

	for scrollIndex, imgList in ipairs(self.scrollImgs) do
		local mid = math.ceil(#imgList / 2)

		for i, img in ipairs(imgList) do
			if self.lastResultIndex[1] ~= nil then
				img.anchoredPosition = Vector2(img.anchoredPosition.x, (i - self.lastResultIndex[scrollIndex]) * self.oneImgSize)
			else
				img.anchoredPosition = Vector2(img.anchoredPosition.x, (mid - i) * self.oneImgSize)
			end

			img.gameObject:SetActiveEx(true)
		end
	end
end

return SlotMachine
