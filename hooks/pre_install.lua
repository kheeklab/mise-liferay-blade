local metadata = require("lib.liferay_metadata")
local log = require("log")

local function resolve_version(version)
    if version == "latest" then
        local data = metadata.get()
        if data.latest == nil then
            error("Failed to resolve latest Blade CLI version")
        end
        return data.latest
    end
    return version
end

function PLUGIN:PreInstall(ctx)
    local version = resolve_version(ctx.version)
    local url = "https://repository-cdn.liferay.com/nexus/service/local/artifact/maven/content?r=liferay-public-releases&g=com.liferay.blade&a=com.liferay.blade.cli&v=" .. version

    log.info("Preparing Blade CLI " .. version)
    log.debug("Resolved Blade download URL: " .. url)

    return {
        version = version,
        url = url,
        note = "Installing Liferay Blade CLI " .. version,
    }
end
