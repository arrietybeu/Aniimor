-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LiveStreaming\\LiveStreamingCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local LiveStreamingCtrl = Class.LightClass("LiveStreamingCtrl", UICtrl)
local logger = LoggerManager.getLogger("LiveStreamingCtrl")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PuppetData = require("Data.puppet_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local AddressDataConst = require("Const.AddressDataConst")
local SysConfigData = require("Data.sys_config_data")

function LiveStreamingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.heartEffectAniNames = {
		"VX_Ani_UI_Pb_LiveStreaming_Heart_In",
		"VX_Ani_UI_Pb_LiveStreaming_Heart_In02",
		"VX_Ani_UI_Pb_LiveStreaming_Heart_In03"
	}
	self.heartEffectPopAniNames = {
		"VX_Ani_3D_LiveStreaming_Pop_Heart_In01",
		"VX_Ani_3D_LiveStreaming_Pop_Heart_In02"
	}

	self:init(info)
end

function LiveStreamingCtrl:addListener()
	function self.view.chatListUList.luaRenderItem(button, _, data)
		self:onRenderEnterItem(button, data)
	end
end

function LiveStreamingCtrl:init(info)
	self.msgs = {}
	self.popMsgPool = {}
	self.heartEffectPool = {}
	self.likeCount = info and #info >= 9 and info[9] or 1

	self.view.likeTxt:SetNumber(self.likeCount)
	self.view.timerCountDown:Play(36000000)
	ClientTextUtils.setText(self.view.liveTitleTxt, pg.getGameString("LIVE_TITLE"))
	ClientTextUtils.setText(self.view.liveTitleMask, pg.getGameString("LIVE_TITLE_MASK"))
end

function LiveStreamingCtrl:onOpen(info)
	if info == nil then
		return
	end

	if IsNil(self.UIRoot) then
		if self.isLoadingRoot == true then
			table.insert(self.msgs, info)

			return
		end

		table.insert(self.msgs, info)

		self.isLoadingRoot = true

		pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.UI_3D_LIVE_STREAMING_ROOT, function(uiRoot, userData)
			if IsNil(uiRoot) then
				return
			end

			self.UIRoot = uiRoot
			self.isLoadingRoot = false
			uiRoot.transform.position = Vector3(0, 0, 0)

			local objectReference = uiRoot:GetComponent("ObjectReference")

			self.msgPanel = objectReference:GetRefValue("msgPanel")

			for i = 1, #self.msgs do
				local info = self.msgs[i]

				self:onAddNewMsg(info)
			end

			self.msgs = {}
		end)
	else
		self:onAddNewMsg(info)
	end
end

function LiveStreamingCtrl:onAddNewMsg(info)
	local dialogueId = #info > 0 and info[1] or nil

	if dialogueId == 0 or dialogueId == nil then
		self:clicklike(info)

		return
	end

	local baseLikeCount = info and #info >= 9 and info[9] or 0

	if baseLikeCount and baseLikeCount > 0 then
		self.likeCount = baseLikeCount

		self.view.likeTxt:SetNumber(self.likeCount)
	end

	if #self.popMsgPool > 0 then
		local itemObj = self.popMsgPool[1]

		LuaUIUtils.setUIViewVisible(itemObj, true)
		self:onRenderMsgItem(itemObj, info)
		table.remove(self.popMsgPool, 1)

		return
	end

	pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.UI_3D_LIVE_STREAMING_POP, function(itemObj, userData)
		if IsNil(itemObj) then
			return
		end

		itemObj.transform:SetParent(self.msgPanel)
		self:onRenderMsgItem(itemObj, info)
	end)
end

function LiveStreamingCtrl:onRenderMsgItem(itemObj, info)
	local dialogueId = #info > 0 and info[1] or nil

	if dialogueId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("dialogueId is nil!")
		end

		LuaUIUtils.setUIViewVisible(itemObj, false)
		table.insert(self.popMsgPool, itemObj)

		return
	end

	local dialogueConfig
	local dialogueData = NpcDialogueData[dialogueId]

	if dialogueData then
		dialogueConfig = dialogueData[1]
	end

	if dialogueConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("dialogue is nil! dialogueId is", dialogueId)
		end

		LuaUIUtils.setUIViewVisible(itemObj, false)
		table.insert(self.popMsgPool, itemObj)

		return
	end

	local isLeft = #info > 1 and info[2] or 0
	local objectReference = itemObj:GetComponent("ObjectReference")
	local leftTxt = objectReference:GetRefValue("leftTxt")
	local rightTxt = objectReference:GetRefValue("rightTxt")
	local chat = dialogueConfig.chat

	ClientTextUtils.setText(isLeft == 0 and leftTxt or rightTxt, pg.getLocalizationText(chat))

	local btn = itemObj:GetComponent("UButton")

	btn:TryChangePage("Pos", isLeft)

	local levelTxt = objectReference:GetRefValue("levelTxt")
	local level = #info > 2 and info[3] or 999

	ClientTextUtils.setText(levelTxt, level)

	local gender = #info > 3 and info[4] or 0

	btn:TryChangePage("Gender", gender)
	self:clicklike(info)

	local pos = #info > 5 and info[6] or Vector3(0, 0, 0)

	itemObj.transform.localPosition = pos

	local rot = #info > 6 and info[7] or Vector3(0, 0, 0)

	itemObj.transform.localEulerAngles = rot

	local enterLiveRoom = #info > 7 and info[8] or nil

	if enterLiveRoom == 1 then
		self.view.chatListUList:SetList({
			{
				dialogueConfig = dialogueConfig,
				level = level,
				gender = gender
			}
		})
		self:startScaleTimer(function()
			local itemCount = self.view.chatListUList.itemCount

			if itemCount > 0 then
				self.view.chatListUList:RemoveElement(itemCount - 1)
			end
		end, 5)
	end

	local scale = #info > 9 and info[10] or 1

	scale = scale == 0 and 1 or scale
	itemObj.transform.localScale = Vector3(0.001, 0.001, 0.001) * scale
	self.modelRoot = objectReference:GetRefValue("modelRoot")

	if self.modelRoot.childCount == 0 then
		pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.UI_3D_LIVE_STREAMING_MODEL, function(gameObj, userData)
			gameObj.transform:SetParent(self.modelRoot)

			gameObj.transform.localPosition = Vector3(0, -90, 0)
			gameObj.transform.localScale = Vector3(200, 200, 200)
			gameObj.transform.localEulerAngles = Vector3(0, 180, 0)
		end)
	end

	local panelAnim = objectReference:GetRefValue("panelAnim")

	UIUtils.PlayAnimation(panelAnim, "VX_Ani_3D_LiveStreaming_Pop_In")
	self:startScaleTimer(function()
		UIUtils.PlayAnimation(panelAnim, "VX_Ani_3D_LiveStreaming_Pop_Out", function()
			LuaUIUtils.setUIViewVisible(itemObj, false)
			table.insert(self.popMsgPool, itemObj)
		end)
	end, 5)
end

function LiveStreamingCtrl:clicklike(info)
	local like = #info > 4 and info[5] or 0

	if like >= 1 then
		self.view.likeTxt.StartNumber = self.likeCount
		self.view.likeTxt.EndNumber = self.likeCount + like

		self.view.likeTxt:StartDancing()

		self.likeCount = self.likeCount + like

		if self.view and self.view.rootUComponent then
			self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end
end

function LiveStreamingCtrl:getNpcHeadIconUrl(templateId)
	local pData = PuppetData[templateId]
	local iconUrl = pData and pData.iconName or nil

	iconUrl = iconUrl or LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON)

	return iconUrl
end

function LiveStreamingCtrl:playLikeEffect()
	if #self.heartEffectPool > 0 then
		self:playHeartAni(self.heartEffectPool[1])
		table.remove(self.heartEffectPool, 1)

		return
	end

	pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.UI_3D_LIVE_STREAMING_MODEL, function(itemObj, userData)
		if IsNil(itemObj) then
			return
		end

		itemObj.transform:SetParent(self.view.heartRoot)

		itemObj.transform.localPosition = Vector3(0, 0, 0)
		itemObj.transform.localScale = Vector3(1, 1, 1)

		self:playHeartAni(itemObj)
	end)
end

function LiveStreamingCtrl:playHeartAni(heartObj)
	UIUtils.PlayAnimation(self.view.likeBtnAni, "VX_Ani_Pb_LiveStreaming_Icon_Click")

	local anim = heartObj:GetComponent("Animation")
	local randomNum = math.random(1, 3)

	UIUtils.PlayAnimation(anim, self.heartEffectAniNames[randomNum], function()
		table.insert(self.heartEffectPool, heartObj)
	end)
end

function LiveStreamingCtrl:onRenderEnterItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local contentTxt = objectReference:GetRefValue("contentTxt")
	local enterLiveTip = pg.getGameString("ENTER_LIVE_TIPS")

	enterLiveTip = string.gsub(enterLiveTip, "{0}", pg.getLocalizationText(data.dialogueConfig.npcName))

	ClientTextUtils.setText(contentTxt, enterLiveTip)

	local levelTxt = objectReference:GetRefValue("levelTxt")

	ClientTextUtils.setText(levelTxt, data.level)
end

function LiveStreamingCtrl:onDestroy()
	pg.global.resMgr:ResDestroyObject(self.UIRoot)
end

function LiveStreamingCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return LiveStreamingCtrl
