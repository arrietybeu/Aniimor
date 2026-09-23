-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobileAddonBtnUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local MibileAddonBtnUIComponent = Class.LightClass("MibileAddonBtnUIComponent", HudBaseComponent)
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LevelData = require("Data.level_data")
local SandboxConst = require("Common.Const.SandboxConst")
local SysNoticeData = require("Data.sys_notice_data")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Const.EventConst")

MibileAddonBtnUIComponent.messages = {}

function MibileAddonBtnUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnPetExChangeUContainer = objectReference:GetRefValue("btnPetExChangeUContainer")
	self.skillAddonSpeicalUContainer = objectReference:GetRefValue("skillAddonSpeicalUContainer")
end

function MibileAddonBtnUIComponent:loadSkillAddonSpeical()
	return
end

function MibileAddonBtnUIComponent:addListeners()
	return
end

function MibileAddonBtnUIComponent:initView()
	if pg.space then
		local levelData = LevelData[pg.space.sceneId]

		self.isInMultiDungeon = levelData and levelData.playerNumMax > 1 and levelData.isTemple == 1

		if self.isInMultiDungeon then
			self.skillAddonSpeicalUContainer:LoadDefaultUrlManually(function(widget)
				self.skillAddonReference = self.skillAddonSpeicalUContainer.content:GetComponent("ObjectReference")
				self.txtNameUText = self.skillAddonReference:GetRefValue("txtNameUText")
				self.iconUImage = self.skillAddonReference:GetRefValue("iconUImage")
				self.btnNormalKeyBindingPro = self.skillAddonReference:GetRefValue("btnNormalKeyBindingPro")
				self.keyHotKeyContent = self.skillAddonReference:GetRefValue("keyHotKeyContent")
				self.specialUButton = self.skillAddonReference:GetRefValue("specialUButton")
				self.countDown = self.skillAddonReference:GetRefValue("countDown")

				self.skillAddonSpeicalUContainer.gameObject:SetActiveEx(true)
				ClientTextUtils.setText(self.txtNameUText, pg.getGameString("TEMPLE_SWITCH_VIEW"))

				self.iconUImage.url = "$UI_SkillIcon_People_Peep.png"

				self.keyHotKeyContent:SetHotKeyPaths("Raw/KeyNum5")

				function self.specialUButton.luaClick()
					self:switchTeammateView()
				end

				LuaUIUtils.bindFuncBtnHotKey(self.specialUButton.gameObject, "teammateView", "Raw/KeyNum5", function()
					self:switchTeammateView()
				end)
			end)
		end

		if pg.me and pg.me:isInTeam() then
			function self.onSetActionState(actionState)
				if pg.me.inTeammateView then
					for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
						if info.entityId ~= pg.me.id then
							local target = pg.getEntity(info.entityId)

							if target:isControllingPet() then
								local pet = target:getCurPetEntity()

								if pet then
									target = pet
								end
							end

							pg.game.camera:setTargetPlayer(target, 0)
						end
					end
				end
			end

			for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
				if info.entityId ~= pg.me.id then
					local other = pg.getEntity(info.entityId)

					if other ~= nil and other.eventEmitter ~= nil then
						self.hasAddStateEvent = true

						other.eventEmitter:addEventListener(EventConst.PLAYER_ACTION_STATE_CHANGED, self.onSetActionState)
					end

					break
				end
			end
		end
	end
end

function MibileAddonBtnUIComponent:switchTeammateView()
	if self.inTeammateView then
		if pg.me:isControllingPet() then
			local pet = pg.me:getCurPetEntity()

			pg.game.camera:setTargetPlayer(pet, 0)
		else
			pg.game.camera:setTargetPlayer(pg.me, 0)
		end

		self.inTeammateView = false
		pg.me.inTeammateView = false

		if self.teammateViewTarget then
			self.teammateViewTarget:setLodTickEnable(Const.LOD_TICK_KEY.TEAMMATEVIEW, false)
		end

		pg.global.ui:show(UIConst.UI_ID_TIPS)

		pg.me.inPeep = false

		if pg.pawn.updateStateCache then
			pg.pawn:updateStateCache("PEEP_ST")
		end

		if self.lastInFixedCamera then
			pg.game.camera:cameraBlendToFixed(self.lastCameraPos, self.lastCameraRotation, self.lastCameraFov, 0)

			self.lastInFixedCamera = false
		end

		facade:sendMsgToUI(MessageName.DUNGEON_TEAMMATEVIEW_CHANGE)
		facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.TEAMATE_VIEW_CHANGE, false)
	elseif pg.me:isInTeam() then
		local teammateInScene = false

		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local other = pg.getEntity(info.entityId)

				teammateInScene = other ~= nil
			end
		end

		if teammateInScene then
			if pg.me.disableTeammateView then
				return
			end

			for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
				if info.entityId ~= pg.me.id then
					local target = pg.getEntity(info.entityId)

					if target:isControllingPet() then
						local pet = target:getCurPetEntity()

						if pet then
							target = pet
						end
					end

					pg.game.camera:setTargetPlayer(target, 0)

					self.inTeammateView = true
					pg.me.inTeammateView = true

					target:setLodTickEnable(Const.LOD_TICK_KEY.TEAMMATEVIEW, true)

					self.teammateViewTarget = target
				end
			end

			pg.global.ui:hide(UIConst.UI_ID_TIPS)

			pg.me.inPeep = true

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("PEEP_ST")
			end

			if pg.game.camera.fixedCameraMode ~= nil then
				self.lastCameraPos = pg.game.camera.fixedCameraMode.lastPos
				self.lastCameraRotation = pg.game.camera.fixedCameraMode.lastRotation
				self.lastCameraFov = pg.game.camera.fixedCameraMode.lastFov

				pg.game.camera:cancelBlendToFixed(0, true)

				self.lastInFixedCamera = true
			end

			facade:sendMsgToUI(MessageName.DUNGEON_TEAMMATEVIEW_CHANGE)
			facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.TEAMATE_VIEW_CHANGE, true)
		else
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(SysNoticeData[NoticeDef.TEMPLE_SEE_TEAMMATE_FAILED].text))
		end
	end
end

function MibileAddonBtnUIComponent:onDestroy()
	if self.inTeammateView then
		self:switchTeammateView()
	end

	if pg.me and pg.me:isInTeam() and self.hasAddStateEvent then
		self.hasAddStateEvent = false

		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local other = pg.getEntity(info.entityId)

				if other ~= nil and other.eventEmitter ~= nil then
					other.eventEmitter:removeEventListener(EventConst.PLAYER_ACTION_STATE_CHANGED, self.onSetActionState)
				end

				break
			end
		end
	end

	HudBaseComponent.onDestroy(self)
end

function MibileAddonBtnUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MibileAddonBtnUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return MibileAddonBtnUIComponent
