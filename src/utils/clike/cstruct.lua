---@class cstruct
local cstruct = CoreAPI.Utils.Classic:extend()

local ctypes = {void=0, int=4, short=2, char=1, float=4, double=8, ["long long"]=8}

local readFunctions = {
    void=nil,
    int=Core.Memory.readS32,
    uint=Core.Memory.readU32,
    short=Core.Memory.readS16,
    ushort=Core.Memory.readU16,
    char=Core.Memory.readS8,
    uchar=Core.Memory.readU8,
    float=Core.Memory.readFloat,
    double=Core.Memory.readDouble,
    ["long long"]=nil
}

local function align(offset, size)
    return math.floor((offset + size - 1) / size) * size
end

---@class carray
local carray = CoreAPI.Utils.Classic:extend()

function carray:new(offset, dataType, size, isPointer, isUnsigned)
    self._offset = offset
    self._dataType = dataType
    self._size = size
    self._isPointer = isPointer
    self._isUnsigned = isUnsigned
end

function carray:_get_value(key)
    if key < 1 or key > self._size then
        return nil
    end

    local dataType = self._dataType
    if self._isUnsigned then
        dataType = "u"..dataType
    end
    local readFunc = readFunctions[dataType]
    local elementSize = ctypes[self._dataType]
    if self._isPointer then
        elementSize = 4
        dataType = dataType.."*"
        readFunc = readFunctions.uint
    end
    if self._dataType == "void" then
        if not self._isPointer then
            error("void not allowed without pointer modifier")
        end
    end
    if not readFunc then
        error("not implemented for "..dataType)
    end
    return readFunc(self._offset + elementSize * (key - 1))
end

local carray_mt = getmetatable(carray())
local carray_index = carray_mt.__index
carray_mt.__index = function (self, key)
    if type(key) == "number" then
        local _get_value = rawget(self, "_get_value")
        return _get_value(carray, key)
    end
    return carray_index[key]
end
carray_mt.__len = function (self)
    return self._size
end

--[[
example:
{
    {"unsigned int", "field1"},
    {"short", "field2"}
}
]]
function cstruct:new(def)
    local curOffset = 0
    self._fields = {}
    for _, value in ipairs(def) do
        value[1] = string.lower(value[1])
        local countMatch = 0
        local typeMatch = nil
        for dataType, _ in pairs(ctypes) do
            if string.match(value[1], dataType) then
                typeMatch = string.match(value[1], dataType)
                countMatch = countMatch + 1
            end
        end
        if countMatch > 1 then
            error("More than one type "..value[1])
        end
        if not typeMatch then
            error("Unexpected type "..value[1])
        end
        local unsignedMatch = nil
        if string.match(value[1], "unsigned") then
            unsignedMatch = string.match(value[1], "^ *(unsigned) *"..typeMatch)
            if not unsignedMatch then
                error("Unexpected type "..value[1])
            end
        end
        if unsignedMatch then
            if typeMatch == "float" or typeMatch == "double" then
                error("Unexpected type "..value[1])
            end
        end
        local arrayMatch
        if string.match(value[1], "%[.*%]") then
            arrayMatch = string.match(value[1], typeMatch.." *%*? *%[(%d+)%] *$")
            if not arrayMatch then
                error("Unexpected type "..value[1])
            end
        end
        local pointerMatch = nil
        if string.match(value[1], "%*.*%*") then
            error("max pointer level is only one")
        end
        if string.match(value[1], "%*") then
            pointerMatch = string.match(value[1], "(%*) *$")
            if not pointerMatch then
                pointerMatch = string.match(value[1], "(%*) *%[%d+%] *$")
                if not pointerMatch then
                    error("Unexpected type "..value[1])
                end
            end
        end
        if typeMatch == "void" and not pointerMatch then
            error("Type cannot be void "..value[1])
        end
        local size = 0
        local elementSize = 0
        if pointerMatch then
            elementSize = 4
        else
            elementSize = ctypes[typeMatch]
        end
        if arrayMatch then
            local arraySize = tonumber(arrayMatch, 10)
            if arraySize < 1 then
                error("arrays must have at least 1 element")
            end
            size = elementSize * arraySize
        else
            size = elementSize
        end
        local name = string.match(value[2], "^ *([%w]+) *$")
        if not name then
            error("Invalid name "..value[2])
        end
        if self._fields[name] ~= nil then
            error("Duplicated name "..value[2])
        end
        local offset = align(curOffset, elementSize)
        self._fields[name] = {
            offset = offset,
            size = size,
            elementSize = elementSize,
            dataType = typeMatch,
            isArray = arrayMatch ~= nil,
            isPointer = pointerMatch ~= nil,
            isUnsigned = unsignedMatch ~= nil
        }
        curOffset = offset + size
    end
    self._moffset = nil
    self._sizeof = curOffset
    self._allocated = false
end

---Creates a new cstruct definition
---@param def any
---@return cstruct
function cstruct.newStruct(def)
    return cstruct(def)
end

function cstruct:newInstance()
    local t = cstruct({})
    t._fields = self._fields
    t._sizeof = self._sizeof
    local moffset = Core.Memory.malloc(self._sizeof)
    if not moffset then
        error("Failed to allocate memory")
    end
    t._allocated = true
    t._moffset = moffset
    return t
end

function cstruct:newInstanceFromMemory(offset)
    local t = cstruct({})
    t._fields = self._fields
    t._sizeof = self._sizeof
    t._allocated = false
    t._moffset = offset
    return t
end

function cstruct:_check_instance()
    if self._moffset == nil then
        error("Not an instance")
    end
end

function cstruct:free()
    self:_check_instance()
    if self._allocated then
        Core.Memory.free(self._moffset)
        self._allocated = false
    end
end

function cstruct:getPointer()
    self:_check_instance()
end

function cstruct:_get_value(key)
    self:_check_instance()
    local value = self._fields[key]
    if value.isArray then
        return carray(self._moffset + value.offset, value.dataType, math.floor(value.size / value.elementSize), value.isPointer, value.isUnsigned)
    end

    local dataType = value.dataType
    if value.isUnsigned then
        dataType = "u"..dataType
    end
    local readFunc = readFunctions[dataType]
    if value.isPointer then
        dataType = dataType.."*"
        readFunc = readFunctions.uint
    end

    if not readFunc then
        error("not implemented for "..dataType)
    end
    return readFunc(self._moffset + value.offset)
end

local cstruct_mt = getmetatable(cstruct({}))
local cstruct_index = cstruct_mt.__index
cstruct_mt.__index = function (self, key)
    local _fields = rawget(self, "_fields")
    if _fields and _fields[key] ~= nil then
        --Core.Debug.log("fields", false)
        local _get_value = rawget(cstruct, "_get_value")
        return _get_value(self, key)
    end
    --Core.Debug.log("fallback", false)
    return cstruct_index[key]
end
cstruct_mt.__gc = function (self)
    if self._allocated then
        Core.Memory.free(self._moffset)
    end
end

return cstruct