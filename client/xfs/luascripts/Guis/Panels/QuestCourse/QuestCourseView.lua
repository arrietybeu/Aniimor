-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestCourse\\QuestCourseView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestCourseView = Class.LightClass("QuestCourseView", UIView)

function QuestCourseView:findObjects()
	return
end

function QuestCourseView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.courseUList = objectReference:GetRefValue("courseUList")
	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.root = objectReference:GetRefValue("root")
	self.courseFinTxt = objectReference:GetRefValue("courseFinTxt")
	self.courseTotalTxt = objectReference:GetRefValue("courseTotalTxt")
	self.courseDetailList = objectReference:GetRefValue("courseDetailList")
	self.rewardUList = objectReference:GetRefValue("rewardUList")
	self.beginnerNode = objectReference:GetRefValue("beginnerNode")
	self.mainCom = objectReference:GetRefValue("mainCom")
	self.titleTxt = objectReference:GetRefValue("titleTxt")
end

function QuestCourseView:initView()
	return
end

local courseGradeItemsComs = {}

function QuestCourseView:getCourseGradeItemComs(btn)
	if courseGradeItemsComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		courseGradeItemsComs[btn] = {}
		courseGradeItemsComs[btn].com = objectReference:GetRefValue("courseUComponent")
		courseGradeItemsComs[btn].courseTypeNameTxt = objectReference:GetRefValue("courseTypeNameTxt")
		courseGradeItemsComs[btn].courseFinTxt = objectReference:GetRefValue("courseFinTxt")
		courseGradeItemsComs[btn].courseTotalTxt = objectReference:GetRefValue("courseTotalTxt")
		courseGradeItemsComs[btn].courseProgressSlider = objectReference:GetRefValue("courseProgressSlider")
	end

	return courseGradeItemsComs[btn]
end

local courseItemsComs = {}

function QuestCourseView:getCourseItemComs(btn)
	if courseItemsComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		courseItemsComs[btn] = {}
		courseItemsComs[btn].btn = objectReference:GetRefValue("btn")
		courseItemsComs[btn].nameTxt = objectReference:GetRefValue("nameTxt")
		courseItemsComs[btn].bgImg = objectReference:GetRefValue("bgImg")
		courseItemsComs[btn].typeImg = objectReference:GetRefValue("typeImg")
		courseItemsComs[btn].rewardUList = objectReference:GetRefValue("rewardUList")

		local startBtn = objectReference:GetRefValue("startBtn")

		courseItemsComs[btn].startBtn = startBtn

		local startBtn_OR = startBtn.transform:GetComponent("ObjectReference")

		courseItemsComs[btn].startBtnTxt = startBtn_OR:GetRefValue("txtNameUText")
		courseItemsComs[btn].startBtnHotkey = startBtn_OR:GetRefValue("keyHotKeyContent")

		local claimBtn = objectReference:GetRefValue("claimBtn")

		courseItemsComs[btn].claimBtn = claimBtn

		local claimBtn_OR = claimBtn.transform:GetComponent("ObjectReference")

		courseItemsComs[btn].claimBtnTxt = claimBtn_OR:GetRefValue("txtNameUText")
	end

	return courseItemsComs[btn]
end

local courseDetailRewardItemsComs = {}

function QuestCourseView:getCourseDetailRewardItemComs(btn)
	if courseDetailRewardItemsComs[btn] == nil then
		courseDetailRewardItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		courseDetailRewardItemsComs[btn].rewardBtn = objectReference:GetRefValue("rewardBtn")
		courseDetailRewardItemsComs[btn].progress = objectReference:GetRefValue("progressUProgress")
		courseDetailRewardItemsComs[btn].textTitle = objectReference:GetRefValue("textTitle")
	end

	return courseDetailRewardItemsComs[btn]
end

function QuestCourseView:onDestroy()
	for k in next, courseGradeItemsComs do
		courseGradeItemsComs[k] = nil
	end

	for k in next, courseItemsComs do
		courseItemsComs[k] = nil
	end

	for k in next, courseDetailRewardItemsComs do
		courseDetailRewardItemsComs[k] = nil
	end
end

return QuestCourseView
