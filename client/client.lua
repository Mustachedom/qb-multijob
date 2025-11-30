local jobList = {}

RegisterNetEvent('qb-multijob:client:loadJobs', function(jobs)
    jobList = {}
    for jobName, jobData in pairs(jobs) do
        jobList[#jobList + 1] = jobData
    end
    table.sort(jobList, function(a, b)
        if a.pay ~= b.pay then
            return a.pay > b.pay
        end
        return a.label > b.label
    end)
end)

local function openNui()
    local currentJob = exports['qb-core']:GetPlayerData().job
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMultijob',
        data = {
            jobList = jobList,
            currentJob = currentJob.name
        }
    })
end

RegisterCommand('multijob', function() openNui() end, false)

RegisterKeyMapping('multijob', 'Open MultiJob Menu', 'keyboard', 'J')

RegisterNuiCallback('hideUI', function(data, cb) SetNuiFocus(false, false) cb('ok') end)

RegisterNuiCallback('signInJob', function(data, cb) TriggerServerEvent('qb-multijob:server:setJob', data) cb(true) end)

RegisterNuiCallback('quitJob', function(data, cb) TriggerServerEvent('qb-multijob:server:quitJob', data) cb(true) end)

RegisterNuiCallback('toggleDuty', function(data, cb) TriggerServerEvent('qb-multijob:server:toggleDuty', data) cb('ok') end)


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qb-multijob:server:loadData')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if PlayerPedId() ~= 0 then
        TriggerServerEvent('qb-multijob:server:loadData')
    end
end)