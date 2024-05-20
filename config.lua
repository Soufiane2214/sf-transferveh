Config = Config or {}

Config.Command = 'transferveh'      -- command
Config.Payment = 'cash'             -- cash / bank
Config.EnableTransferSelf = false   -- enable only if you want test transfer vehicle with your self
Config.LimitPrice = {
    MinPrice = 1000,                -- Min price sell vehicle
    MaxPrice = 1000000              -- Max price sell vehicle
}