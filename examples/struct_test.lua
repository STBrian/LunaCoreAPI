---@class ToolTier : cstruct
---@field miningLevel number
---@field durability number
---@field unknown number
---@field damageBonus number
---@field enchantability number
local ToolTier = {}

local toolTierStruct = CoreAPI.Utils.CLike.CStruct.newStruct({
    {"int", "miningLevel"},
    {"int", "durability"},
    {"int", "unknown"},
    {"int", "damageBonus"},
    {"int", "enchantability"},
})

local tiers = {}
---@type ToolTier
tiers.WOOD = toolTierStruct:newInstanceFromMemory(0x00b0e124)
---@type ToolTier
tiers.STONE = toolTierStruct:newInstanceFromMemory(0x00b0e138)
---@type ToolTier
tiers.IRON = toolTierStruct:newInstanceFromMemory(0x00b0e14c)
---@type ToolTier
tiers.DIAMOND = toolTierStruct:newInstanceFromMemory(0x00b0e160)
---@type ToolTier
tiers.GOLD = toolTierStruct:newInstanceFromMemory(0x00b0e174)

Game.Gamepad.OnKeyPressed:Connect(function ()
    Core.Debug.message("Wood Tool Tier")
    Core.Debug.message("Mining level: "..tiers.WOOD.miningLevel)
    Core.Debug.message("Durability: "..tiers.WOOD.durability)

    Core.Debug.message("Stone Tool Tier")
    Core.Debug.message("Mining level: "..tiers.STONE.miningLevel)
    Core.Debug.message("Durability: "..tiers.STONE.durability)

    Core.Debug.message("Iron Tool Tier")
    Core.Debug.message("Mining level: "..tiers.IRON.miningLevel)
    Core.Debug.message("Durability: "..tiers.IRON.durability)
end)