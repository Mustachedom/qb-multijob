
local function sort(t, key)
    table.sort(t, function(a, b)
        return a[key] > b[key]
    end)
end

local function generateMainPage(jobList)
    local menu = {}
    menu[#menu + 1] = {
        header = Lang:t('menu.mainHeader'),
        isMenuHeader = true,
        pay = 1000000000
    }
    for jobName, jobRank in pairs(jobList) do
        menu[#menu + 1] = {
            header = QBCore.Shared.Jobs[jobName].label,
            txt = QBCore.Shared.Jobs[jobName].grades[tostring(jobRank)].name .. ' | ' .. Lang:t('menu.currency') .. QBCore.Shared.Jobs[jobName].grades[tostring(jobRank)].payment,
            pay = QBCore.Shared.Jobs[jobName].grades[tostring(jobRank)].payment,
            action = function()
                local disabled = false
                if jobName ~= QBCore.Functions.GetPlayerData().job.name then
                    disabled = true
                end
                local options = {
                    {
                        header = Lang:t('menu.optionHeader') .. ' ' .. QBCore.Shared.Jobs[jobName].label,
                        isMenuHeader = true
                    },
                    {
                        header = Lang:t('menu.setJobHeader'),
                        txt = Lang:t('menu.setJobDesc') .. ' ' .. QBCore.Shared.Jobs[jobName].label,
                        disabled = not disabled,
                        action = function()
                            TriggerServerEvent('qb-multijob:server:setJob', jobName)
                            exports['qb-menu']:closeMenu()
                        end
                    },
                    {
                        header = Lang:t('menu.toggleDuty'),
                        txt = Lang:t('menu.toggleDutyDesc') .. ' ' .. QBCore.Shared.Jobs[jobName].label,
                        disabled = disabled,
                        action = function()
                            TriggerServerEvent('qb-multijob:server:toggleDuty', jobName)
                            exports['qb-menu']:closeMenu()
                        end
                    },
                    {
                        header = Lang:t('menu.quit'),
                        txt = Lang:t('menu.quitDesc') .. ' ' .. QBCore.Shared.Jobs[jobName].label,
                        action = function()
                            TriggerServerEvent('qb-multijob:server:quitJob', jobName)
                            exports['qb-menu']:closeMenu()
                        end
                    },
                    {
                        header = Lang:t('menu.goback'),
                        txt = Lang:t('menu.gobackDesc'),
                        action = function()
                            generateMainPage(jobList)
                        end
                    }
                }
                exports['qb-menu']:openMenu(options)
            end
        }
    end
    menu[#menu+1] = {
        header = QBCore.Shared.Jobs['unemployed'].label,
        txt = Lang:t('menu.unemployedDescription') .. QBCore.Shared.Jobs['unemployed'].grades[tostring(0)].payment,
        pay = QBCore.Shared.Jobs['unemployed'].grades[tostring(0)].payment,
        action = function()
            local options = {
                {
                    header = Lang:t('menu.optionHeader') .. ' ' .. QBCore.Shared.Jobs['unemployed'].label,
                    isMenuHeader = true
                },
                {
                    header = Lang:t('menu.setJobHeader'),
                    txt = Lang:t('menu.setJobDesc') .. ' ' .. QBCore.Shared.Jobs['unemployed'].label,
                    action = function()
                        TriggerServerEvent('qb-multijob:server:setJob', 'unemployed')
                        exports['qb-menu']:closeMenu()
                    end
                },
                {
                    header = Lang:t('menu.goback'),
                    txt = Lang:t('menu.gobackDesc'),
                    action = function()
                        generateMainPage(jobList)
                    end
                }
            }
            exports['qb-menu']:openMenu(options)
        end
    }
    menu[#menu + 1] = {
        header = Lang:t('menu.closeMenu'),
        pay = 0,
        action = function()
            exports['qb-menu']:closeMenu()
        end
    }
    sort(menu, 'pay')
    exports['qb-menu']:openMenu(menu)
end

RegisterCommand(Config.CommandName, function()
    local jobList = QBCore.Functions.TriggerCallback('qb-multijob:server:getJobs')
    generateMainPage(jobList)
end, false)

RegisterKeyMapping(Config.CommandName, 'Open Job Menu', 'keyboard', Config.KeyBoardKey)