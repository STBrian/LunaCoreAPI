---@class ToolTier : cstruct
---@field miningLevel number
---@field durability number
---@field miningEfficiency number
---@field damageBonus number
---@field enchantability number
local ToolTier = CoreAPI.Utils.CLike.CStruct.newStruct({
    {"int", "miningLevel"},
    {"int", "durability"},
    {"float", "miningEfficiency"}, -- They really used float for an int value 
    {"int", "damageBonus"},
    {"int", "enchantability"}
}, "ToolTier")

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

Game.Gamepad.OnKeyPressed:Connect(function ()
    Core.Debug.message("Gold Tier")
    Core.Debug.message("Mining level: "..tiers.IRON.miningEfficiency)

    Core.Debug.message("Wood Tool Tier")
    Core.Debug.message("Mining level: "..tiers.WOOD.miningEfficiency)

    Core.Debug.message("Stone Tool Tier")
    Core.Debug.message("Mining level: "..tiers.STONE.miningEfficiency)

    Core.Debug.message("Iron Tool Tier")
    Core.Debug.message("Mining level: "..tiers.IRON.miningEfficiency)

    Core.Debug.message("Iron Tool Tier")
    Core.Debug.message("Mining level: "..tiers.IRON.miningEfficiency)
end)