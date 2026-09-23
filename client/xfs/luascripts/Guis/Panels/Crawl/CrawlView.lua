-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Crawl\\CrawlView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CrawlView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CrawlView = Class.LightClass("CrawlView", UIView)

function CrawlView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.mobileUContainer = objectReference:GetRefValue("mobileUContainer")
	self.pcUContainer = objectReference:GetRefValue("pcUContainer")
	self.crawlAimObjectReference = objectReference:GetRefValue("catchAimObjectReference")
end

function CrawlView:registerObjects()
	return
end

function CrawlView:initView()
	return
end

return CrawlView
