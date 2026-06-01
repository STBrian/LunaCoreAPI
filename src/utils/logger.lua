---@class Logger
local logger = CoreAPI.Utils.Classic:extend()

function logger:new(idname, level)
    self._idname = idname
    self._level = level
end

local levels = {
    debug = 0,
    info = 1,
    warn = 2,
    error = 3
}

---Creates a new logger used to write to the log file.
---The idname will be appended at the start of your log messages
---@param idname string
---@param level string?
---@return Logger
function logger.newLogger(idname, level)
    if type(idname) == "string" then
        if level == nil or type(level) ~= "string" then
            level = "info"
        else
            level = string.lower(level)
        end
        if levels[level] == nil then
            level = "info"
        end
        return logger(idname, levels[level])
    else
        error("expected string for idname")
    end
end

function logger:message(msg)
    if self._level <= levels.info then
        local out = "[INFO] "
        out = out .. "(" .. self._idname .. ") " .. msg
        Core.Debug.log(out, true)
    end
end

function logger:info(msg)
    if self._level <= levels.info then
        local out = "[INFO] "
        out = out .. "(" .. self._idname .. ") " .. msg
        Core.Debug.log(out, false)
    end
end

function logger:debug(msg)
    if self._level <= levels.debug then
        local out = "[DEBUG] "
        out = out .. "(" .. self._idname .. ") " .. msg
        Core.Debug.log(out, false)
    end
end

function logger:warn(msg)
    if self._level <= levels.warn then
        local out = "[WARN] "
        out = out .. "(" .. self._idname .. ") " .. msg
        Core.Debug.log(out, false)
    end
end

function logger:error(msg)
    local out = "[ERROR] "
    out = out .. "(" .. self._idname .. ") " .. msg
    Core.Debug.log(out, false)
end

function logger:deprecated(msg)
    if self._level <= levels.warn then
        local out = "[WARN] "
        out = out .. "(" .. self._idname .. ") Deprecation: " .. msg
        Core.Debug.log(out, false)
    end
end

return logger