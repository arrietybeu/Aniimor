-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\LxGeometry.lua

local Class = require("Core.Framework.Class")
local Vector3 = Vector3
local LxGeometry = {}
local LxTrapezoid3D = Class.LiteClass("LxTrapezoid3D")

LxGeometry.LxTrapezoid3D = LxTrapezoid3D

function LxTrapezoid3D:ctor(center, rot, startRadius, endRadius, distance, heightUp, heightDown)
	self.center = center or Vector3.zero
	self.rot = rot or 0
	self.startRadius = startRadius or 0
	self.endRadius = endRadius or 0
	self.distance = distance or 0
	self.heightUp = heightUp or 0
	self.heightDown = heightDown or 0
end

local LxCircle3D = Class.LiteClass("LxCircle3D")

LxGeometry.LxCircle3D = LxCircle3D

function LxCircle3D:ctor(center, rot, radius, heightUp, heightDown)
	self.center = center or Vector3.zero
	self.rot = rot or 0
	self.radius = radius or 0
	self.heightUp = heightUp or 0
	self.heightDown = heightDown or 0
end

local LxSector3D = Class.LiteClass("LxSector3D")

LxGeometry.LxSector3D = LxSector3D

function LxSector3D:ctor(center, rot, radius, theta, heightUp, heightDown)
	self.center = center or Vector3.zero
	self.rot = rot or 0
	self.radius = radius or 0
	self.theta = theta or 0
	self.heightUp = heightUp or 0
	self.heightDown = heightDown or 0
end

local LxAnnularSector3D = Class.LiteClass("LxAnnularSector3D")

LxGeometry.LxAnnularSector3D = LxAnnularSector3D

function LxAnnularSector3D:ctor(center, rot, innerRadius, outerRadius, theta, heightUp, heightDown)
	self.center = center or Vector3.zero
	self.rot = rot or 0
	self.innerRadius = innerRadius or 0
	self.outerRadius = outerRadius or 0
	self.outerRadius = math.max(self.innerRadius + 0.2, self.outerRadius)
	self.theta = theta or 0
	self.heightUp = heightUp or 0
	self.heightDown = heightDown or 0
end

function LxAnnularSector3D:getArgs()
	return {
		self.innerRadius,
		self.outerRadius,
		self.theta,
		self.heightUp,
		self.heightDown
	}
end

local LxSphere = Class.LiteClass("LxShpere")

LxGeometry.LxSphere = LxSphere

function LxSphere:ctor(center, rot, radius)
	self.center = center or Vector3.zero
	self.rot = rot or 0
	self.radius = radius or 0
end

local LxBox = Class.LiteClass("LxBox")

LxGeometry.LxBox = LxBox

function LxBox:ctor(center, rot, extents)
	self.center = center or Vector3.zero
	self.rot = rot or 0
	self.extents = (extents or Vector3.zero) / 2
end

return LxGeometry
