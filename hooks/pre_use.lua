local metadata = require("lib.liferay_metadata")

function PLUGIN:PreUse(ctx)
    if ctx.version ~= "latest" then
        return {
            version = ctx.version,
        }
    end

    local data = metadata.get()
    if data.latest == nil then
        error("Failed to resolve latest Blade CLI version")
    end

    return {
        version = data.latest,
    }
end
