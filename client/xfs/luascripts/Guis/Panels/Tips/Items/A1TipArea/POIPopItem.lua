-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\POIPopItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")
local POIPopItem = Class.LightClass("POIPopItem", BaseQueueItem)

function POIPopItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function POIPopItem:pushData(data)
	data.uniqueId = data.uniqueId or 0
	data.priority = data.priority or 0
	data.state = data.state or 0

	if self:checkCanPushStack(data) then
		self:enqueue(data)
	end
end

function POIPopItem:checkCanPushStack(data)
	if data.state == 1 then
		for _, v in ipairs(self.dataQueue) do
			if v.id == data.id and v.uniqueId == data.uniqueId and v.priority == data.priority then
				return false
			end
		end

		for _, v in ipairs(self.runList) do
			if v.id == data.id and v.uniqueId == data.uniqueId and v.priority == data.priority then
				return false
			end
		end

		local oldIndex = -1

		for i, v in ipairs(self.dataQueue) do
			if v.id == data.id and data.priority > v.priority then
				oldIndex = i

				break
			end
		end

		if oldIndex > 0 then
			table.remove(self.dataQueue, oldIndex)
		end
	end

	return true
end

function POIPopItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function POIPopItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.animeEnd = false
	data.endTime = Time.realSecondCache + (data.duration or 8)

	self:addRunItem(data)
	self:initUContainer(data)
end

function POIPopItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function POIPopItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if data.animeEnd == true or Time.realSecondCache > data.endTime then
		self:recycleToast(data)
	end
end

function POIPopItem:initUContainer(data)
	self.uContainer:DestroyContent()
	self.uContainer:SetUrlWithCallback(AddressDataConst.UI_TOAST_POIPop, self:guardRunCallback(data, function(content)
		if IsNil(content) or self.uContainer.content ~= content then
			return
		end

		self:renderItem(content, data)
	end))
end

function POIPopItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local root = objectReference:GetRefValue("root")
	local txtTitleExploreUSDFText = objectReference:GetRefValue("txtTitleExploreUSDFText")
	local iconTipsUImage = objectReference:GetRefValue("iconTipsUImage")
	local txtDiscriptUSDFText = objectReference:GetRefValue("txtDiscriptUSDFText")
	local iconTipsUImageHigh = objectReference:GetRefValue("iconTipsUImageHigh")
	local txtDiscriptUSDFTextHigh = objectReference:GetRefValue("txtDiscriptUSDFTextHigh")
	local iconTipsUImageLow = objectReference:GetRefValue("iconTipsUImageLow")
	local txtTitleDecryptUSDFText = objectReference:GetRefValue("txtTitleDecryptUSDFText")
	local txtDiscriptUSDFTextLow = objectReference:GetRefValue("txtDiscriptUSDFTextLow")
	local txtTitleDecryptFailUSDFText = objectReference:GetRefValue("txtTitleDecryptFailUSDFText")
	local txtTitleBattleUSDFText = objectReference:GetRefValue("txtTitleBattleUSDFText")
	local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local txtLevelUSDFTextHigh = objectReference:GetRefValue("txtLevelUSDFTextHigh")
	local listUListHigh = objectReference:GetRefValue("listUListHigh")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtCompleteUSDFText = objectReference:GetRefValue("txtCompleteUSDFText")
	local txtFailUSDFText = objectReference:GetRefValue("txtFailUSDFText")
	local txtCompleteUSDFText1 = objectReference:GetRefValue("txtCompleteUSDFText1")
	local txtFailUSDFText1 = objectReference:GetRefValue("txtFailUSDFText1")
	local iconAreaUImage = objectReference:GetRefValue("iconAreaUImage")
	local vXIconTipsUImage = objectReference:GetRefValue("vXIconTipsUImage")
	local vXIconAreaUImage = objectReference:GetRefValue("vXIconAreaUImage")
	local txtTitleExploreFailUSDFText = objectReference:GetRefValue("txtTitleExploreFailUSDFText")
	local txtTitleBattleFailUSDFText = objectReference:GetRefValue("txtTitleBattleFailUSDFText")
	local funcBtn = objectReference:GetRefValue("funcBtn")
	local areaTipsUComponent = objectReference:GetRefValue("areaTipsUComponent")
	local txtLevelUBaseText = objectReference:GetRefValue("txtLevelUBaseText")
	local txtWarningTipsUBaseText = objectReference:GetRefValue("txtWarningTipsUBaseText")
	local args = data.args
	local combine = {
		[0] = {
			[0] = {},
			{
				icon = iconTipsUImage,
				title = txtTitleExploreUSDFText,
				subTitle = txtDiscriptUSDFText,
				complete = txtCompleteUSDFText,
				fail = txtFailUSDFText,
				completeTitle = txtTitleExploreUSDFText,
				failTitle = txtTitleExploreFailUSDFText
			},
			{
				icon = iconTipsUImageHigh,
				title = txtTitleExploreUSDFText,
				subTitle = txtDiscriptUSDFTextHigh,
				complete = txtDiscriptUSDFTextHigh,
				fail = txtDiscriptUSDFTextHigh,
				completeTitle = txtTitleExploreUSDFText,
				failTitle = txtTitleExploreFailUSDFText
			}
		},
		{
			[0] = {
				icon = iconTipsUImageLow,
				title = txtTitleDecryptUSDFText,
				subTitle = txtDiscriptUSDFTextLow,
				complete = txtCompleteUSDFText1,
				fail = txtFailUSDFText1,
				completeTitle = txtTitleDecryptUSDFText,
				failTitle = txtTitleDecryptFailUSDFText
			},
			{
				icon = iconTipsUImage,
				title = txtTitleDecryptUSDFText,
				subTitle = txtDiscriptUSDFText,
				complete = txtCompleteUSDFText,
				fail = txtFailUSDFText,
				completeTitle = txtTitleDecryptUSDFText,
				failTitle = txtTitleDecryptFailUSDFText
			},
			{}
		},
		{
			[0] = {},
			{
				icon = iconTipsUImage,
				title = txtTitleBattleUSDFText,
				complete = txtCompleteUSDFText,
				fail = txtFailUSDFText,
				level = txtLevelUSDFText,
				elementList = listUList,
				completeTitle = txtTitleBattleUSDFText,
				failTitle = txtTitleBattleFailUSDFText
			},
			{
				icon = iconTipsUImageHigh,
				title = txtTitleBattleUSDFText,
				level = txtLevelUSDFTextHigh,
				elementList = listUListHigh,
				completeTitle = txtTitleBattleUSDFText,
				failTitle = txtTitleBattleFailUSDFText
			}
		}
	}

	if not combine[args.POIShowType[1]][args.POIShowType[2]] then
		return
	end

	root:TryChangePage("Type", args.POIShowType[1])
	root:TryChangePage("Grade", args.POIShowType[2])

	if args.POIShowType[1] == 2 then
		pg.game.audio:triggerEvent("SFX_UI_POI_CombatArea")
	else
		pg.game.audio:triggerEvent("SFX_UI_POI_EnterArea")
	end

	if args.POIShowType[2] == 0 then
		POIPopItem.playRootAnime(root, CS.XGUI.EInvokeTime.Custom4, data)
	elseif args.POIShowType[2] == 1 then
		POIPopItem.playRootAnime(root, CS.XGUI.EInvokeTime.Custom3, data)
	elseif args.POIShowType[2] == 2 then
		POIPopItem.playRootAnime(root, CS.XGUI.EInvokeTime.Custom2, data)
	end

	if args.isSuccess ~= nil then
		root:TryChangePage("State", args.isSuccess and 2 or 1)
		POIPopItem.playRootAnime(root, CS.XGUI.EInvokeTime.Custom3, data)
		pg.game.audio:stopEvent("SFX_UI_POI_CombatArea")
		pg.game.audio:stopEvent("SFX_UI_POI_EnterArea")

		if args.isSuccess then
			pg.game.audio:triggerEvent("SFX_UI_POI_MissionAccomplished")
		else
			pg.game.audio:triggerEvent("SFX_UI_POI_TaskFailed")
		end
	else
		root:TryChangePage("State", 0)
	end

	local fightType

	if args.sceneId and args.staticId then
		fightType = pg.game.map:isPOIPopupBelongsToFightType(args.sceneId, args.staticId)
	end

	for k, v in pairs(combine[args.POIShowType[1]][args.POIShowType[2]]) do
		if k == "icon" and args.POIIcon then
			v.url = args.POIIcon
			vXIconTipsUImage.url = args.POIIcon
			vXIconAreaUImage.url = args.POIIcon
		elseif k == "icon" and not args.POIIcon then
			v.url = nil
			vXIconTipsUImage.url = nil
			vXIconAreaUImage.url = nil
		end

		if k == "title" and args.title then
			if string.isNilOrEmpty(args.title) then
				args.title = " "
			end

			ClientTextUtils.setText(v, pg.getLocalizationText(args.title))
		end

		if k == "subTitle" and args.subTitle then
			if string.isNilOrEmpty(args.subTitle) then
				args.subTitle = " "
			end

			ClientTextUtils.setText(v, pg.getLocalizationText(args.subTitle))
		end

		if k == "complete" and args.completeText then
			if string.isNilOrEmpty(args.completeText) then
				args.completeText = " "
			end

			ClientTextUtils.setText(v, pg.getLocalizationText(args.completeText))
		end

		if k == "fail" and args.failText then
			if string.isNilOrEmpty(args.failText) then
				args.failText = " "
			end

			ClientTextUtils.setText(v, pg.getLocalizationText(args.failText))
		end

		if k == "completeTitle" and args.completeTitle then
			if string.isNilOrEmpty(args.completeTitle) then
				args.completeTitle = " "
			end

			ClientTextUtils.setText(v, pg.getLocalizationText(args.completeTitle))
		end

		if k == "failTitle" and args.failTitle then
			if string.isNilOrEmpty(args.failTitle) then
				args.failTitle = " "
			end

			ClientTextUtils.setText(v, pg.getLocalizationText(args.failTitle))
		end

		if k == "level" then
			local idInType = fightType[5]
			local entityId = fightType[4]

			LuaUIUtils.requestMapPuppetLevel(idInType, self:guardRunCallback(data, function(level)
				if entityId then
					pg.game.map.puppetStaticIdInitRecord[entityId] = level
				end

				ClientTextUtils.setText(v, string.format("Lv.%s", level or pg.getGameString("LEVEL_NOT_VALID")))

				local threatState = LuaUIUtils.getThreatLevelState(level)

				if threatState == "dangerous" then
					root:TryChangePage("BattleWarning", 1)
				elseif threatState == "veryDangerous" then
					root:TryChangePage("BattleWarning", 2)
				else
					root:TryChangePage("BattleWarning", 0)
				end
			end, item))
		end

		if k == "elementList" and fightType[3] then
			v.luaRenderItem = self:guardRunCallback(data, function(button, _, data1)
				LuaUIUtils.setElementButtonNew(button, data1.elementId)
			end, item)

			v:SetList(fightType[3])
		end
	end

	if args.POIMusic then
		pg.game.audio:playEvent(args.POIMusic)
	end

	if args.customFunc then
		funcBtn:SetActive(true)

		funcBtn.luaClick = self:guardRunCallback(data, function()
			args.customFunc.luaFunc()
		end, item)

		ClientTextUtils.setText(funcBtn:Find("TxtName"):GetComponent("USDFText"), args.customFunc.desc)

		local keyBind = funcBtn:GetComponent("KeyBindingPro")

		keyBind.actionPath = args.customFunc.actionPath
	else
		funcBtn:SetActive(false)
	end
end

function POIPopItem.playRootAnime(root, animeKey, data)
	root:InvokeCallbackWithCallback(animeKey, function()
		data.animeEnd = true
	end)
end

function POIPopItem:onSceneUnload()
	self:clearDataQueue()
	self:clearRunningList()
end

function POIPopItem:GMPushData(data)
	data.duration = 5
	data.args = {
		title = "测试",
		subTitle = "子Title",
		isSuccess = true,
		POIIcon = "$UI_Icon_POI_Decrypt_TimeLimited.png",
		POIShowType = {
			1,
			0
		}
	}
end

return POIPopItem
