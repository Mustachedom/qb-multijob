

---@param identifier number|string Player ID or CitizenID
---@param job string Job name
---@param grade number Job grade
---@return boolean
function addJob(identifier, job, grade)
    grade = tonumber(grade) or 0
    local Player = QBCore.Functions.GetPlayer(identifier) or QBCore.Functions.GetPlayerByCitizenId(identifier)
    local citizenID = Player.PlayerData.citizenid

    verifyCache(citizenID)

    if not verifyJob(Player.PlayerData.source, job, tostring(grade)) then return false end

    if cachedSQL[citizenID][job] then
        cachedSQL[citizenID][job] = grade
    end

    local jobCount = 0
    for _ in pairs(cachedSQL[citizenID]) do
        jobCount = jobCount + 1
    end

    if jobCount >= MaxJobs and not tableContains(MaxJobImmune, citizenID) then
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('notify.overMax'), 'error')
        return false
    end

    cachedSQL[citizenID][job] = grade
    MySQL.update('UPDATE multijob SET jobs = ? WHERE citizenid = ?', {json.encode(cachedSQL[citizenID]), citizenID})
    Player.Functions.SetJob(job, grade)
    return true
end



function removeJob(identifier, job)
    local Player = QBCore.Functions.GetPlayer(identifier) or QBCore.Functions.GetPlayerByCitizenId(identifier)
    local citizenID = Player and Player.PlayerData.citizenid

    verifyCache(citizenID)
    if not verifyJob(Player.PlayerData.source, job) then return end

    if not cachedSQL[citizenID][job] then
        return false
    end

    if job == 'unemployed' then
        return false
    end

    cachedSQL[citizenID][job] = nil
    if Player.PlayerData.source then
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('notify.lost_job') .. QBCore.Shared.Jobs[job].label, 'error')
    end

    MySQL.update('UPDATE multijob SET jobs = ? WHERE citizenid = ?', {json.encode(cachedSQL[citizenID]), citizenID})
    if Player and Player.PlayerData.job.name == job then
        Player.Functions.SetJob('unemployed', 0)
    end
    return true, nil
end

function hasJob(identifier, job)
    local Player = QBCore.Functions.GetPlayer(identifier) or QBCore.Functions.GetPlayerByCitizenId(identifier)
    local citizenID = Player and Player.PlayerData.citizenid or identifier

    verifyCache(citizenID)
    if not verifyJob(Player.PlayerData.source or nil, job) then return false end
    return cachedSQL[citizenID][job] ~= nil
end

function getEmployees(jobName)
    local employees = {}
    local allEmployees = MySQL.query.await([[
        SELECT *
        FROM multijob
        WHERE JSON_CONTAINS_PATH(jobs, 'one', ?)
    ]], {
        '$.' .. jobName
    })

    for _, v in pairs(allEmployees) do
        local jobs = json.decode(v.jobs)
        if jobs and jobs[jobName] then
            local pTable = QBCore.Functions.GetPlayerByCitizenId(v.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(v.citizenid)
            local online 
            if pTable.PlayerData.source then
                online = true
            else
                online = false
            end
            table.insert(employees, {citizenID = v.citizenid, grade = jobs[jobName], name = v.player_name, online = online})
        end
    end
    return employees
end

function updateRank(identifier, job, grade)
    grade = tonumber(grade) or 0
    local Player = QBCore.Functions.GetPlayer(identifier) or QBCore.Functions.GetPlayerByCitizenId(identifier)
    local citizenID = Player.PlayerData.citizenid

    verifyCache(citizenID)

    if not verifyJob(Player.PlayerData.source, job, tostring(grade)) then return end

    if not cachedSQL[citizenID][job] then
        return false
    end

    cachedSQL[citizenID][job] = grade
    MySQL.update('UPDATE multijob SET jobs = ? WHERE citizenid = ?', {json.encode(cachedSQL[citizenID]), citizenID})
    if Player and Player.PlayerData.job.name == job then
        Player.Functions.SetJob(job, grade)
    end
    return true
end

exports('addJob', addJob)
exports('getEmployees', getEmployees)
exports('removeJob', removeJob)
exports('hasJob', hasJob)
exports('updateRank', updateRank)