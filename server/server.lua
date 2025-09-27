
function verifyCache(citizenID)
    if not cachedSQL[citizenID] then
        local result = MySQL.query.await('SELECT * FROM multijob WHERE citizenid = ?', {citizenID})
        if result and result[1] then
            local jobList = json.decode(result[1].jobs)
            cachedSQL[citizenID] = jobList
        else
            MySQL.insert('INSERT INTO multijob (citizenid, jobs) VALUES (?, ?)', {citizenID, json.encode({})})
            cachedSQL[citizenID] = {}
        end
    end
end

function verifyJob(src, jobName, grade)
    if not QBCore.Shared.Jobs[jobName] then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.job_not_found'), 'error')
        return false
    end
    if not grade then grade = '0' end
    if not QBCore.Shared.Jobs[jobName].grades[tostring(grade)] then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.grade_not_found'), 'error')
        return false
    end
    return true
end

QBCore.Functions.CreateCallback('qb-multijob:server:getJobs', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenID = Player.PlayerData.citizenid

    if cachedSQL[citizenID] then
        cb(cachedSQL[citizenID])
        return
    end

    verifyCache(citizenID)
    cb(cachedSQL[citizenID])
end)

RegisterNetEvent('qb-multijob:server:setJob', function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenID = Player.PlayerData.citizenid
    local jobList = cachedSQL[citizenID]

    if not verifyJob(src, jobName) then return end

    if jobName == 'unemployed' then
        Player.Functions.SetJob('unemployed', 0)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.unemployed'), 'success')
        return
    end

    if jobList and jobList[jobName] then
        Player.Functions.SetJob(jobName, jobList[jobName])
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.jobChange') .. QBCore.Shared.Jobs[jobName].label, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.dont_have_job'), 'error')
    end
end)

RegisterNetEvent('qb-multijob:server:quitJob', function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenID = Player.PlayerData.citizenid
    local jobList = cachedSQL[citizenID]

    if not verifyJob(src, jobName) then return end

    if jobList and jobList[jobName] then
        if jobName == 'unemployed' then
            TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.cantQuitUnemployed'), 'error')
            return
        end
        if not removeJob(citizenID, jobName) then
            TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.error_quitting_job'), 'error')
            return
        end
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.quit_job') .. QBCore.Shared.Jobs[jobName].label, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.dont_have_job'), 'error')
    end
end)

function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

RegisterNetEvent('qb-multijob:server:toggleDuty', function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenID = Player.PlayerData.citizenid
    local jobList = cachedSQL[citizenID]

    if not verifyJob(src, jobName) then return end

    if jobList and jobList[jobName] then
        if tableContains(NoToggleDuty, jobName) then
            TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.cantToggle'), 'error')
            return
        end
        Player.Functions.SetJob(jobName, jobList[jobName])
        Player.PlayerData.job.onduty = not Player.PlayerData.job.onduty
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.toggleDuty') .. (Player.PlayerData.job.onduty and 'on duty' or 'off duty'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.dont_have_job'), 'error')
    end
end)