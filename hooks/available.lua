local metadata = require("lib.liferay_metadata")
local semver = require("semver")

function PLUGIN:Available(ctx)
    local _ = ctx
    local data = metadata.get()
    local result = {}

    for _, version in ipairs(data.versions) do
        local note = nil
        if data.latest == version then
            note = "Latest"
        elseif data.release == version then
            note = "Release"
        end

        table.insert(result, {
            version = version,
            note = note,
        })
    end

    table.sort(result, function(a, b)
        return semver.compare(a.version, b.version) > 0
    end)

    return result
end
