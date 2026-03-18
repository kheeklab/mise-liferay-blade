local http = require("http")
local file = require("file")
local log = require("log")

local JPM_RUN_URL = "https://raw.githubusercontent.com/liferay/liferay-blade-cli/master/cli/installers/biz.aQute.jpm.run-4.0.0-20201026.162724-24.jar"
local BLADE_URL_PREFIX = "https://repository-cdn.liferay.com/nexus/service/local/artifact/maven/content?r=liferay-public-releases&g=com.liferay.blade&a=com.liferay.blade.cli&v="

local function download(url, dest)
    local err = http.download_file({
        url = url
    }, dest)

    if err ~= nil then
        error("Download failed for " .. url .. ": " .. err)
    end
end

local function run_capture(cmd)
    local handle = io.popen(cmd .. " 2>&1")
    if not handle then
        error("Failed to run command: " .. cmd)
    end

    local output = handle:read("*a")
    local ok, _, code = handle:close()
    if ok ~= true then
        error("Command failed (exit " .. tostring(code) .. "): " .. cmd .. "\n" .. output)
    end

    return output
end

local function detect_jpm_bin_dir(init_output)
    for line in init_output:gmatch("[^\r\n]+") do
        local match = line:match("Bin%s*dir%s*:?%s*(%S+)")
        if match ~= nil then
            return match
        end
    end
    return nil
end

local function safe_get(ctx, key)
    local ok, value = pcall(function()
        return ctx[key]
    end)
    if ok then
        return value
    end
    return nil
end

local function is_valid_version(value)
    return value ~= nil and value ~= "" and value ~= "latest" and value ~= PLUGIN.version
end

local function detect_version(ctx)
    local sdk_info = safe_get(ctx, "sdkInfo")
    if type(sdk_info) == "table" then
        local blade_info = sdk_info["blade"]
        if type(blade_info) == "table" and is_valid_version(blade_info.version) then
            return blade_info.version
        end
        for _, info in pairs(sdk_info) do
            if type(info) == "table" and is_valid_version(info.version) then
                return info.version
            end
        end
    end

    local path_fields = {
        "rootPath",
        "installPath",
        "installDir",
        "runtimePath",
        "sdkPath",
    }
    for _, field in ipairs(path_fields) do
        local value = safe_get(ctx, field)
        if value ~= nil and value ~= "" then
            local tail = value:match("([^/\\]+)$")
            if is_valid_version(tail) then
                return tail
            end
        end
    end

    local ctx_version = safe_get(ctx, "version")
    if is_valid_version(ctx_version) then
        return ctx_version
    end
    local runtime_version = safe_get(ctx, "runtimeVersion")
    if is_valid_version(runtime_version) then
        return runtime_version
    end
    return nil
end

function PLUGIN:PostInstall(ctx)
    local root = safe_get(ctx, "rootPath")
    if root == nil or root == "" then
        root = safe_get(ctx, "installPath")
    end
    if root == nil or root == "" then
        error("Unable to determine install root for Blade CLI")
    end
    local jpm_jar = file.join_path(root, "jpm.run.jar")
    local blade_jar = file.join_path(root, "blade.jar")

    log.debug("Install root: " .. root)

    download(JPM_RUN_URL, jpm_jar)
    log.debug("Downloaded JPM bootstrap: " .. jpm_jar)

    local init_output = run_capture('java -jar "' .. jpm_jar .. '" -u init')
    local jpm_bin_dir = detect_jpm_bin_dir(init_output)
    if jpm_bin_dir == nil then
        error("Unable to determine JPM bin dir from output:\n" .. init_output)
    end
    log.debug("Detected JPM bin dir: " .. jpm_bin_dir)

    local version = detect_version(ctx)
    if version == nil then
        error("Unable to determine Blade CLI version for install")
    end

    local blade_url = BLADE_URL_PREFIX .. version
    log.debug("Blade download URL: " .. blade_url)
    download(blade_url, blade_jar)

    run_capture('"' .. jpm_bin_dir .. '/jpm" install -f "' .. blade_jar .. '"')
    log.info("Blade CLI installed into " .. jpm_bin_dir)

    os.remove(jpm_jar)
    os.remove(blade_jar)

    local ctx_path = safe_get(ctx, "path")
    if ctx_path ~= nil and ctx_path ~= "" then
        local marker = file.join_path(ctx_path, "jpm_bin_dir")
        local handle, err = io.open(marker, "w")
        if handle == nil then
            error("Failed to write " .. marker .. ": " .. tostring(err))
        end
        handle:write(jpm_bin_dir)
        handle:close()
    end
end
