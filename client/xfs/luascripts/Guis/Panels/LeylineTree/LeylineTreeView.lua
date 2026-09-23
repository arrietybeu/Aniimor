-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LeylineTree\\LeylineTreeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LeylineTreeLevelData = require("Data.leylinetree_level_data")
local AddressDataConst = require("Const.AddressDataConst")
local RedDotConst = require("Const.RedDotConst")
local LeylineTreeView = Class.LightClass("LeylineTreeView", UIView)

function LeylineTreeView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.point1UButton = self.objectReference:GetRefValue("point1UButton")
	self.point2UButton = self.objectReference:GetRefValue("point2UButton")
	self.point3UButton = self.objectReference:GetRefValue("point3UButton")
	self.point4UButton = self.objectReference:GetRefValue("point4UButton")
	self.point5UButton = self.objectReference:GetRefValue("point5UButton")
	self.point6UButton = self.objectReference:GetRefValue("point6UButton")
	self.point7UButton = self.objectReference:GetRefValue("point7UButton")
	self.point8UButton = self.objectReference:GetRefValue("point8UButton")
	self.point9UButton = self.objectReference:GetRefValue("point9UButton")
	self.point10UButton = self.objectReference:GetRefValue("point10UButton")
	self.point11UButton = self.objectReference:GetRefValue("point11UButton")
	self.point12UButton = self.objectReference:GetRefValue("point12UButton")
	self.point13UButton = self.objectReference:GetRefValue("point13UButton")
	self.point14UButton = self.objectReference:GetRefValue("point14UButton")
	self.point15UButton = self.objectReference:GetRefValue("point15UButton")
	self.point16UButton = self.objectReference:GetRefValue("point16UButton")
	self.point17UButton = self.objectReference:GetRefValue("point17UButton")
	self.point18UButton = self.objectReference:GetRefValue("point18UButton")
	self.point19UButton = self.objectReference:GetRefValue("point19UButton")
	self.point20UButton = self.objectReference:GetRefValue("point20UButton")
	self.point21UButton = self.objectReference:GetRefValue("point21UButton")
	self.point22UButton = self.objectReference:GetRefValue("point22UButton")
	self.point23UButton = self.objectReference:GetRefValue("point23UButton")
	self.point24UButton = self.objectReference:GetRefValue("point24UButton")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.btnRulesUButton = self.objectReference:GetRefValue("btnRulesUButton")
	self.txtNowUSDFText = self.objectReference:GetRefValue("txtNowUSDFText")
	self.txtAllUSDFText = self.objectReference:GetRefValue("txtAllUSDFText")
	self.progressAddUSlider = self.objectReference:GetRefValue("progressAddUSlider")
	self.progressNowUSlider = self.objectReference:GetRefValue("progressNowUSlider")
	self.btnInjectUButton = self.objectReference:GetRefValue("btnInjectUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.popupUComponent = self.objectReference:GetRefValue("popupUComponent")
	self.flowLineUWidget = self.objectReference:GetRefValue("flowLineUWidget")
	self.flowBoomTransform = self.objectReference:GetRefValue("flowBoomTransform")
	self.levelUpTransform = self.objectReference:GetRefValue("levelUpTransform")
	self.txtDisUSDFText = self.objectReference:GetRefValue("txtDisUSDFText")
	self.pointLUImage = self.objectReference:GetRefValue("pointLUImage")
	self.pointRUImage = self.objectReference:GetRefValue("pointRUImage")
	self.buffTransform = self.objectReference:GetRefValue("buffTransform")
	self.btnCultivateUButton = self.objectReference:GetRefValue("btnCultivateUButton")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.requiredCount = self.objectReference:GetRefValue("requiredCount")
	self.tipsUWidget = self.objectReference:GetRefValue("tipsUWidget")
	self.progressCountDown1 = self.objectReference:GetRefValue("progressCountDown1")
	self.progressCountDown2 = self.objectReference:GetRefValue("progressCountDown2")
	self.progressCountDown3 = self.objectReference:GetRefValue("progressCountDown3")
	self.btnWeatherUButton = self.objectReference:GetRefValue("btnWeatherUButton")
	self.disableButtonUButton = self.objectReference:GetRefValue("disableButtonUButton")
	self.weatherRequiredTip = self.objectReference:GetRefValue("weatherRequiredTip")
	self.flowDowmTransform = self.objectReference:GetRefValue("flowDowmTransform")
	self.vXLeylinesTreeNewBuffUpUWidget = self.objectReference:GetRefValue("vXLeylinesTreeNewBuffUpUWidget")
	self.flowBoomUWidget = self.objectReference:GetRefValue("flowBoomUWidget")
	self.flowDowmUWidget = self.objectReference:GetRefValue("flowDowmUWidget")
	self.vXLeylinesTreeClickLeafAnimation = self.objectReference:GetRefValue("vXLeylinesTreeClickLeafAnimation")
	self.loopLeafIconTransform = self.objectReference:GetRefValue("loopLeafIconTransform")
	self.txtTipsTransform = self.objectReference:GetRefValue("txtTipsTransform")
	self.btnCultivateIconUpUContainer = self.objectReference:GetRefValue("btnCultivateIconUpUContainer")
	self.freeTimeIconUpUContainer = self.objectReference:GetRefValue("freeTimeIconUpUContainer")
	self.pointGroup = {
		self.point1UButton,
		self.point2UButton,
		self.point3UButton,
		self.point4UButton,
		self.point5UButton,
		self.point6UButton,
		self.point7UButton,
		self.point8UButton,
		self.point9UButton,
		self.point10UButton,
		self.point11UButton,
		self.point12UButton,
		self.point13UButton,
		self.point14UButton,
		self.point15UButton,
		self.point16UButton,
		self.point17UButton,
		self.point18UButton,
		self.point19UButton,
		self.point20UButton,
		self.point21UButton,
		self.point22UButton,
		self.point23UButton,
		self.point24UButton
	}
end

function LeylineTreeView:initView()
	self.fragmentGroup = {}
	self.bigPointUnInjectAnim = {}

	for index, pointBtn in pairs(self.pointGroup) do
		self.fragmentGroup[index] = {}

		local objectReference = pointBtn:GetComponent("ObjectReference")
		local part1UComponent = objectReference:GetRefValue("part1UComponent")
		local part2UComponent = objectReference:GetRefValue("part2UComponent")
		local part3UComponent = objectReference:GetRefValue("part3UComponent")
		local part4UComponent = objectReference:GetRefValue("part4UComponent")
		local part5UComponent = objectReference:GetRefValue("part5UComponent")
		local part6UComponent = objectReference:GetRefValue("part6UComponent")
		local part7UComponent = objectReference:GetRefValue("part7UComponent")
		local part8UComponent = objectReference:GetRefValue("part8UComponent")
		local normalUWidget = objectReference:GetRefValue("normalUWidget")

		self.fragmentGroup[index] = {
			part1UComponent,
			part2UComponent,
			part3UComponent,
			part4UComponent,
			part5UComponent,
			part6UComponent,
			part7UComponent,
			part8UComponent
		}
		self.bigPointUnInjectAnim[index] = normalUWidget
	end

	self.flowGroup = {}

	local objectReference = self.flowLineUWidget:GetComponent("ObjectReference")
	local flow1UComponent = objectReference:GetRefValue("flow1UComponent")
	local flow2UComponent = objectReference:GetRefValue("flow2UComponent")
	local flow3UComponent = objectReference:GetRefValue("flow3UComponent")
	local flow4UComponent = objectReference:GetRefValue("flow4UComponent")
	local flow5UComponent = objectReference:GetRefValue("flow5UComponent")
	local flow6UComponent = objectReference:GetRefValue("flow6UComponent")
	local flow7UComponent = objectReference:GetRefValue("flow7UComponent")
	local flow8UComponent = objectReference:GetRefValue("flow8UComponent")
	local flow9UComponent = objectReference:GetRefValue("flow9UComponent")
	local flow10UComponent = objectReference:GetRefValue("flow10UComponent")
	local flow11UComponent = objectReference:GetRefValue("flow11UComponent")
	local flow12UComponent = objectReference:GetRefValue("flow12UComponent")
	local flow13UComponent = objectReference:GetRefValue("flow13UComponent")
	local flow14UComponent = objectReference:GetRefValue("flow14UComponent")
	local flow15UComponent = objectReference:GetRefValue("flow15UComponent")
	local flow16UComponent = objectReference:GetRefValue("flow16UComponent")
	local flow17UComponent = objectReference:GetRefValue("flow17UComponent")
	local flow18UComponent = objectReference:GetRefValue("flow18UComponent")
	local flow19UComponent = objectReference:GetRefValue("flow19UComponent")
	local flow20UComponent = objectReference:GetRefValue("flow20UComponent")
	local flow21UComponent = objectReference:GetRefValue("flow21UComponent")
	local flow22UComponent = objectReference:GetRefValue("flow22UComponent")
	local flow23UComponent = objectReference:GetRefValue("flow23UComponent")
	local flow24UComponent = objectReference:GetRefValue("flow24UComponent")

	self.flowGroup = {
		flow1UComponent,
		flow2UComponent,
		flow3UComponent,
		flow4UComponent,
		flow5UComponent,
		flow6UComponent,
		flow7UComponent,
		flow8UComponent,
		flow9UComponent,
		flow10UComponent,
		flow11UComponent,
		flow12UComponent,
		flow13UComponent,
		flow14UComponent,
		flow15UComponent,
		flow16UComponent,
		flow17UComponent,
		flow18UComponent,
		flow19UComponent,
		flow20UComponent,
		flow21UComponent,
		flow22UComponent,
		flow23UComponent,
		flow24UComponent
	}
end

function LeylineTreeView:generateBuffGroups(treeId)
	self.buffBtnGroup = {}
	self.buffSliderGroup = {}
	self.buffVxDown = {}
	self.buffVxPar = {}

	local leylineTreeLevelData = LeylineTreeLevelData[treeId]

	for level, v in ipairs(leylineTreeLevelData) do
		local child

		if v.isLargeBuff == 1 then
			child = self:addPrefabWithPathSync(self.buffTransform, AddressDataConst.LEYLINETREE_LARGE_BUFF_NODE)
		else
			child = self:addPrefabWithPathSync(self.buffTransform, AddressDataConst.LEYLINETREE_SMALL_BUFF_NODE)
		end

		if child then
			child.gameObject.transform.localPosition = Vector3.zero

			local slider = child.gameObject:GetComponent("USlider")
			local objRef = slider.transform:GetComponent("ObjectReference")
			local buffButton = objRef:GetRefValue("buffUButton")
			local path = string.format(RedDotConst.RedDotPath.LEYLINETREE_BUFF_ITEM, level)
			local show = v.isLargeBuff == 1 and pg.game.leylineTree:getLeylineTreeBuffRewardState(treeId, level) or false

			pg.global.setRedDot(path, buffButton, show, RedDotConst.RedDotStyle.REWARD)

			if objRef:GetRefValue("vXLeylinesTreeNewBuffDownRectTransform") then
				self.buffVxDown[level] = objRef:GetRefValue("vXLeylinesTreeNewBuffDownRectTransform")
			end

			if objRef:GetRefValue("parUWidget") then
				self.buffVxPar[level] = objRef:GetRefValue("parUWidget")
			end

			self.buffBtnGroup[level] = buffButton
			self.buffSliderGroup[level] = slider
		end
	end
end

return LeylineTreeView
