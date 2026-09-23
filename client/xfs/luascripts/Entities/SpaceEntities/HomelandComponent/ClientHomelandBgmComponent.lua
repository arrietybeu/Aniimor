-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandBgmComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local HomelandBgmData = require("Data.homeland_bgm_data")
local SceneData = require("Data.scene_data")
local ClientHomelandBgmComponent = Class.Component("ClientHomelandBgmComponent")

function ClientHomelandBgmComponent:start()
	self:applyHomelandBgm(self.bgmItemId or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT)
end

function ClientHomelandBgmComponent:destroy()
	if (pg.space == self or not pg.space or not pg.space:isHomeland()) and pg.game.audio:getBGMStackBgmStr(AudioConst.BgmPriority.HomelandMusicPlayer) then
		pg.game.audio:stopBgm(AudioConst.BgmPriority.HomelandMusicPlayer)
	end
end

function ClientHomelandBgmComponent:on_bgmItemId_changed(ov, nv)
	self:applyHomelandBgm(nv or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT)
end

function ClientHomelandBgmComponent:setHomelandBgm(bgmConfigId, callback)
	pg.me:serverMsg("RPC_CS_SetHomelandBgm", bgmConfigId, callback)
end

function ClientHomelandBgmComponent.getSceneDefaultBgmConfigId(sceneId)
	local sceneConfig = sceneId and SceneData[sceneId]
	local sceneBgmEvent = sceneConfig and sceneConfig.bgm

	if string.isNilOrEmpty(sceneBgmEvent) then
		return nil, sceneBgmEvent, 0
	end

	local matchedBgmConfigId
	local matchCount = 0

	for bgmConfigId, bgmConfig in pairs(HomelandBgmData) do
		if bgmConfig.bgmEvent == sceneBgmEvent then
			matchedBgmConfigId = bgmConfigId
			matchCount = matchCount + 1
		end
	end

	if matchCount == 1 then
		return matchedBgmConfigId, sceneBgmEvent, matchCount
	end

	return nil, sceneBgmEvent, matchCount
end

function ClientHomelandBgmComponent:getSelectedBgmItemId()
	return self.selectedBgmItemId or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
end

function ClientHomelandBgmComponent:getDefaultBgmConfigId()
	return self.defaultBgmConfigId
end

function ClientHomelandBgmComponent:applyHomelandBgm(bgmItemId)
	bgmItemId = tonumber(bgmItemId) or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT

	local defaultBgmConfigId, sceneDefaultBgmEvent, defaultBgmMatchCount = ClientHomelandBgmComponent.getSceneDefaultBgmConfigId(self.sceneId)

	self.defaultBgmConfigId = defaultBgmConfigId

	local isCustomBgm = bgmItemId ~= Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT and bgmItemId ~= defaultBgmConfigId
	local selectedBgmItemId = Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
	local bgmEvent

	if isCustomBgm then
		local bgmConfig = HomelandBgmData[bgmItemId]

		if bgmConfig and not string.isNilOrEmpty(bgmConfig.bgmEvent) then
			selectedBgmItemId = bgmItemId
			bgmEvent = bgmConfig.bgmEvent
		end
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		if not self.defaultBgmConfigId then
			if string.isNilOrEmpty(sceneDefaultBgmEvent) then
				self.logger:error("homeland scene is missing default BGM event, sceneId=%s", tostring(self.sceneId))
			else
				self.logger:error("homeland scene BGM must match exactly one homeland BGM config, sceneId=%s, bgmEvent=%s, matchCount=%s", tostring(self.sceneId), tostring(sceneDefaultBgmEvent), tostring(defaultBgmMatchCount))
			end
		end

		if isCustomBgm and not bgmEvent then
			self.logger:error("invalid homeland BGM config, bgmItemId=%s", tostring(bgmItemId))
		end
	end

	if pg.space == self then
		if bgmEvent then
			pg.game.audio:playBgm(bgmEvent, AudioConst.BgmPriority.HomelandMusicPlayer)
		elseif pg.game.audio:getBGMStackBgmStr(AudioConst.BgmPriority.HomelandMusicPlayer) then
			pg.game.audio:stopBgm(AudioConst.BgmPriority.HomelandMusicPlayer)
		end
	end

	self.selectedBgmItemId = selectedBgmItemId

	if pg.space == self then
		facade:sendMsgToUI(MessageName.HOMELAND_BGM_CHANGED, self.selectedBgmItemId)
	end
end

return ClientHomelandBgmComponent
