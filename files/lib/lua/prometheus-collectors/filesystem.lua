local excludeMountPoints = {"/dev", "/proc", "/run/credentials", "/sys", "/var/lib/docker/",
                            "/var/lib/containers/storage/"}
local excludeFDTypes = {"autofs", "binfmt_misc", "bpf", "configfs", "debugfs", "devpts", "devtmpfs", "fusectl",
                        "hugetlbfs", "iso9660", "mqueue", "nsfs", "overlay", "proc", "procfs", "pstore", "rpc_pipefs",
                        "securityfs", "selinuxfs", "squashfs", "sysfs", "tracefs"}
local excludeFDTypesStart = {"cgroup2"}

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function has_starts_with (tab, val)
    for index, value in ipairs(tab) do
        if starts_with(val, value) then
            return true
        end
    end

    return false
end

local function has (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function scrape()
    local df = io.popen("df -PT")
    for s in df:read("*all"):gmatch("[^\r\n]+") do
        local df_itm = space_split(s)
        if df_itm[1] ~= "Filesystem" then
            if not has_starts_with(excludeMountPoints, df_itm[7]) and
                not has_starts_with(excludeFDTypesStart, df_itm[2]) and not has(excludeFDTypes, df_itm[2]) then
                local size_bytes = tonumber(df_itm[3]) * 1024
                local used_bytes = tonumber(df_itm[4]) * 1024
                local free_bytes = size_bytes - used_bytes
                local available_bytes = tonumber(df_itm[5]) * 1024

                local labels = {
                    device = df_itm[1],
                    fstype = df_itm[2],
                    mountpoint = df_itm[7],
                }

                metric("node_filesystem_size_bytes", "gauge", labels, size_bytes)
                metric("node_filesystem_free_bytes", "gauge", labels, free_bytes)
                metric("node_filesystem_avail_bytes", "gauge", labels, available_bytes)
            end
        end
    end
end

return {
    scrape = scrape
}
