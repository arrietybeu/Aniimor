-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\GrabEggSettlementScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local PlayableConst = require("Common.Const.PlayableConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local GrabEggSettlementScene = Class.LightClass("GrabEggSettlementScene", UISceneBase)

function GrabEggSettlementScene:onCtor()
	self.egg = nil
	self.pet = nil
	self.fallItems = {}
end

function GrabEggSettlementScene:onStart(param)
	self.objectReference = self.scene.transform:GetComponent("ObjectReference")

	pg.global.ui.grabEggSettlement:createModel()

	local pawnPos = pg.pawn:getPosition()

	self.scene.transform.position = Vector3.New(pawnPos.x, 500, pawnPos.y)

	EModelUtils.setAgentPositionAndRotation(pg.pawn, Vector3.New(pawnPos.x, 500, pawnPos.y), pg.pawn.rotRef)
	pg.pawn:SetKccEnable(false, Const.KccDisableReason.StaticSpawn)
end

function GrabEggSettlementScene:onDestroy()
	if self.egg then
		ClientUtils.safeDestroy(self.egg)
	end

	if self.pet then
		ClientUtils.safeDestroy(self.pet)
	end

	for k, v in pairs(self.fallItems) do
		ClientUtils.safeDestroy(v)
	end

	pg.pawn:SetKccEnable(true, Const.KccDisableReason.StaticSpawn)
end

function GrabEggSettlementScene:createPlayer(isWin)
	local entity = self:copyMainPlayer()

	entity.eModel:SetFacialStubEnabled(Const.COMPONENT_IDX_PLAYABLE, false)
	entity.eModel:SetTransformParent(self.scene.transform, false)
	entity.eModel:SetTransformLocalPosition(0.273, 0, 0.51)

	local localRotation = Quaternion.Euler(0, 23.3, 0)

	entity.eModel:SetTransformLocalRotation(localRotation.x, localRotation.y, localRotation.z, localRotation.w)
	entity.eModel:SetTransformLocalScale()

	if not isWin then
		entity:playAnimation(PlayableConst.Die)
	else
		entity:playAnimation(PlayableConst.Show_Dance02)
	end
end

function GrabEggSettlementScene:createEggInBag()
	if self.egg then
		return
	end

	local packSlot = pg.me:getItemFromBagSlotIndex(ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN, ItemConst.INV_TYPE_ROB_EGG)
	local itemId = packSlot and packSlot.id

	if not itemId then
		return
	end

	local entity = ClientUtils.createVirtualGrabEggEntity(itemId, Vector3(-0.525, 0, -0.067), 1, self.scene.transform, true)

	self.egg = entity
end

function GrabEggSettlementScene:createPlayerBecomeEgg()
	if self.egg then
		return
	end

	local entity = ClientUtils.createVirtualGrabEggEntity(nil, Vector3.zero, 1, self.scene.transform, true, true)

	self.egg = entity
end

function GrabEggSettlementScene:createPet()
	if self.pet then
		return
	end

	local entity = ClientVirtualEntityUtils.createPetVirtualEntityWithPetId(petId)

	EModelUtils.setAgentPosition(entity, Vector3(-0.2937003, -0.004999995, -0.9922301))

	local localRotation = Quaternion.Euler(0, 15.6, 0)

	entity.eModel:SetTransformLocalRotation(localRotation.x, localRotation.y, localRotation.z, localRotation.w)

	self.pet = entity
end

function GrabEggSettlementScene:createBagItem(itemId, pos)
	local entity = ClientUtils.createVirtualGrabEggEntity(itemId, pos, 1, self.scene.transform)

	self.fallItems[entity.id] = entity
end

return GrabEggSettlementScene
