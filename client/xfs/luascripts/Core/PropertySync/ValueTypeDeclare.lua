-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\ValueTypeDeclare.lua

local class = require("Core.Framework.Class")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local PropertyDeclare = require("Core.PropertySync.PropertyDeclare")
local ValueTypeDeclare = class.Class("ValueTypeDeclare", PropertyDeclare)

function ValueTypeDeclare:ctor(valueType, intTypeKey)
	ValueTypeDeclare.super.ctor(self, nil, valueType, nil, "DummyAOI", "DummyPER", nil)
	assert(intTypeKey ~= nil)

	self.intTypeKey = intTypeKey

	if intTypeKey then
		self.keyType = "number"
	else
		self.keyType = "string"
	end

	self.isFixedDeclare = false
end

return ValueTypeDeclare
