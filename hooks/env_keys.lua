local file = require("file")
local log = require("log")

local function read_trim(path)
    if not file.exists(path) then
        return nil
    end
    local content = file.read(path)
    if content == nil then
        return nil
    end
    return content:gsub("^%s+", ""):gsub("%s+$", "")
end

function PLUGIN:EnvKeys(ctx)
    local jpm_bin_dir = nil

    local ctx_path = nil
    local ok, value = pcall(function()
        return ctx.path
    end)
    if ok then
        ctx_path = value
    end

    if ctx_path ~= nil and ctx_path ~= "" then
        local marker = ctx_path .. "/jpm_bin_dir"
        jpm_bin_dir = read_trim(marker)
    end

    if jpm_bin_dir == nil or jpm_bin_dir == "" then
        local home = os.getenv("HOME") or ""
        if home ~= "" then
            local os_type = RUNTIME.osType or ""
            os_type = os_type:lower()
            if os_type == "darwin" then
                jpm_bin_dir = home .. "/Library/PackageManager/bin"
            else
                jpm_bin_dir = home .. "/jpm/bin"
            end
        end
    end

    if jpm_bin_dir == nil or jpm_bin_dir == "" then
        error("Unable to determine JPM bin directory for Blade CLI")
    end
    log.debug("Using JPM bin dir: " .. jpm_bin_dir)

    return {
        {
            key = "PATH",
            value = jpm_bin_dir,
        }
    }
end
