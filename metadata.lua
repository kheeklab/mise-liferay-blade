-- metadata.lua
-- Plugin metadata and configuration
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#metadata-lua

PLUGIN = { -- luacheck: ignore
    -- Required: Tool name (lowercase, no spaces)
    name = "blade",

    -- Required: Plugin version (not the tool version)
    version = "1.0.0",

    -- Required: Brief description of the tool
    description = "Liferay Blade CLI",

    -- Required: Plugin author/maintainer
    author = "sida",

    -- Optional: Repository URL for plugin updates
    updateUrl = "https://github.com/kheeklab/mise-liferay-blade",

    -- Optional: Minimum mise runtime version required
    minRuntimeVersion = "0.2.0",
}
