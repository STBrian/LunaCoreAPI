CoreAPI.Tools = {}

---@class ToolTier : cstruct
---@field MiningLevel number
---@field Durability number
---@field MiningEfficiency number
---@field DamageBonus number
---@field Enchantability number
local ToolTier = CoreAPI.Utils.CLike.CStruct.newStruct({
    {"int", "MiningLevel"},
    {"int", "Durability"},
    {"float", "MiningEfficiency"}, -- They really used a float for an int value 
    {"int", "DamageBonus"},
    {"int", "Enchantability"}
})

CoreAPI.Tools.ToolTier = ToolTier

local tiers = {}
---@type ToolTier
tiers.WOOD = ToolTier:newInstanceFromMemory(0x00b0e124)
---@type ToolTier
tiers.STONE = ToolTier:newInstanceFromMemory(0x00b0e138)
---@type ToolTier
tiers.IRON = ToolTier:newInstanceFromMemory(0x00b0e14c)
---@type ToolTier
tiers.DIAMOND = ToolTier:newInstanceFromMemory(0x00b0e160)
---@type ToolTier
tiers.GOLD = ToolTier:newInstanceFromMemory(0x00b0e174)

CoreAPI.Tools.Tiers = tiers