local http = require("http")

local M = {}

local METADATA_URL = "https://repository-cdn.liferay.com/nexus/content/repositories/liferay-public-releases/com/liferay/blade/com.liferay.blade.cli/maven-metadata.xml"

local function fetch_metadata()
    local resp, err = http.get({
        url = METADATA_URL
    })

    if err ~= nil then
        error("Failed to fetch Blade CLI metadata: " .. err)
    end

    if resp.status_code ~= 200 then
        error("Blade CLI metadata request returned status " .. resp.status_code .. ": " .. resp.body)
    end

    return resp.body
end

local function parse_versions(xml)
    local versions = {}
    for version in xml:gmatch("<version>([^<]+)</version>") do
        table.insert(versions, version)
    end

    local latest = xml:match("<latest>([^<]+)</latest>")
    local release = xml:match("<release>([^<]+)</release>")

    return {
        versions = versions,
        latest = latest,
        release = release,
    }
end

function M.get()
    local xml = fetch_metadata()
    return parse_versions(xml)
end

return M
