local function scrape()
  local wl_eth1_fd = io.popen("/usr/sbin/wl -i eth1 phy_tempsense 2>&1")
  local wl_eth2_fd = io.popen("/usr/sbin/wl -i eth2 phy_tempsense 2>&1")

  temp = string.sub(get_contents("/proc/dmu/temperature"), 19, -5)
  metric("node_dmu_temperature", "gauge", nil, tonumber(temp))
  
  wl_metric = metric("node_wl_tempsense", "gauge")

  local wl1_temp = space_split(wl_eth1_fd:read("*all"))
  if wl1_temp[2] ~= "Not" then
    local eth1_temp = tonumber(wl1_temp[1])
    eth1_temp = eth1_temp - 5
    wl_metric({ iface = "eth1" }, eth1_temp)
  end
  
  local wl2_temp = space_split(wl_eth2_fd:read("*all"))
  if wl2_temp[2] ~= "Not" then
    local eth2_temp = tonumber(wl2_temp[1])
    eth2_temp = eth2_temp - 5
    wl_metric({ iface = "eth2" }, eth2_temp)
  end

end

return { scrape = scrape }