local playerJobs = {}
local Jobs = exports['qb-core']:GetSharedJobs()

local maxJobs = 5 -- Maximum number of jobs a player can have
local ignoreMax = {
    ABC1234k = true, -- Example CitizenID to ignore max job limit
} -- 

local refuseDuty = { -- Jobs that refuse duty toggling
    police = true,
    ambulance = true,
}

--- @param identifier number|string
--- @return string
local function verifyCitizenid(identifier)
    if type(identifier) == 'number' then
        local Player = exports['qb-core']:GetPlayer(identifier)
        identifier = Player.PlayerData.citizenid
    end
    return identifier
end

--- @param jobName string
--- @param jobRank number|string
--- @return table|nil
--- @description Returns job data table or nil if job/rank not found
local function returnJobData(jobName, jobRank)
    jobRank = tostring(jobRank)
    if Jobs[jobName] and Jobs[jobName].grades[jobRank] then
        return {
            label = Jobs[jobName].label,
            grade = jobRank,
            gradeLabel = Jobs[jobName].grades[jobRank] and Jobs[jobName].grades[jobRank].name or "Unknown",
            pay = Jobs[jobName].grades[jobRank] and Jobs[jobName].grades[jobRank].payment or 0,
            name = jobName
        }
    end
    print(Lang:t(string.format('Warning.not_found_in_jobs', {job = jobName, rank = jobRank})))
    return nil
end

--- @param job string
--- @param rank number|string
--- @return boolean
--- @description Verifies if job and rank exist in Jobs
local function verifyJobData(job, rank)
    if not Jobs[job] and Jobs[job].grades[tostring(rank)] then
        print(Lang:t(string.format('Warning.not_found_in_jobs', {job = job, rank = rank})))
        return false
    end
    return true
end

--- @param identifier string
--- @description Updates the database with the current jobs of the player
local function updataDatabase(identifier)
    local jobsToSave = {}
    for jobName, jobData in pairs(playerJobs[identifier]) do
        if jobName ~= 'unemployed' then
            if verifyJobData(jobName, jobData.grade) then
                jobsToSave[jobName] = jobData.grade
            end
        end
    end
    MySQL.update.await('UPDATE multijob SET jobs = ? WHERE citizenid = ?', {json.encode(jobsToSave), identifier})
    local Player = exports['qb-core']:GetPlayerByCitizenId(identifier)
    if Player and Player.PlayerData.source then
        TriggerClientEvent('qb-multijob:client:loadJobs', Player.PlayerData.source, playerJobs[identifier])
    end
end

--- @param identifier number|string
--- @description Initializes the cache for a player if not already initialized, loading data from database or creating a new entry
local function initCache(identifier)
    local citizenid = verifyCitizenid(identifier)
    if not playerJobs[citizenid] then
        playerJobs[citizenid] = {}

        local jobList = MySQL.query.await('SELECT * FROM multijob WHERE citizenid = ?', {citizenid})

        if jobList and jobList[1] then
            local jobs = json.decode(jobList[1].jobs)
            for jobName, jobGrade in pairs(jobs) do
                playerJobs[citizenid][jobName] = returnJobData(jobName, jobGrade)
            end
            playerJobs[citizenid]['unemployed'] = returnJobData('unemployed', 0)
        else
            local player = exports['qb-core']:GetPlayerByCitizenId(citizenid)
            local name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
            MySQL.insert.await('INSERT INTO multijob (citizenid, jobs, name) VALUES (?, ?, ?)', {citizenid, json.encode({}), name})
            playerJobs[citizenid]['unemployed'] = returnJobData('unemployed', 0)
        end
    end
end

--- @param identifier number|string
--- @return boolean
--- @description Checks if a player can add a new job based on maxJobs limit
local function canAddJob(identifier)
    if ignoreMax[identifier] then
        return true
    end

    identifier = verifyCitizenid(identifier)

    if not playerJobs[identifier] then
        initCache(identifier)
    end

    local jobCount = 0
    for k, v in pairs(playerJobs[identifier]) do
        jobCount = jobCount + 1
    end
    if jobCount >= maxJobs then
        return false
    else
        return true
    end
end

--- @param identifier number|string
--- @param jobName string
--- @param newRank number|string
--- @return boolean
--- @description Updates the rank of an existing job for a player
local function updateRank(identifier, jobName, newRank)
    identifier = verifyCitizenid(identifier)

    if not playerJobs[identifier] then
        initCache(identifier)
    end

    if not verifyJobData(jobName, newRank)  then
        return false
    end

    if not playerJobs[identifier][jobName] then
        print(Lang:t('Warning.failed_update', {identifier = identifier, job = jobName, rank = newRank}))
        return false
    end

    playerJobs[identifier][jobName] = returnJobData(jobName, newRank)
    updataDatabase(identifier)
    return true
end
exports('updateRank', updateRank)

--- @param identifier number|string
--- @param jobName string
--- @param jobRank number|string
--- @return boolean, string|nil
--- @description Adds a new job to a player if they haven't reached the maxJobs limit
local function addJob(identifier, jobName, jobRank)
    identifier = verifyCitizenid(identifier)

    if not playerJobs[identifier] then
        initCache(identifier)
    end

    if not canAddJob(identifier) then
        return false, Lang:t('Notify.failedAdd_maxJobs', {identifier = identifier, job = jobName, rank = jobRank})
    end

    if not verifyJobData(jobName, jobRank) then
        return false
    end

    if playerJobs[identifier][jobName] then
        return false, Lang:t('Warning.failed_update_alreadyHas', {identifier = identifier, job = jobName, rank = jobRank})
    end

    playerJobs[identifier][jobName] = returnJobData(jobName, jobRank)
    updataDatabase(identifier)
    return true
end
exports('addJob', addJob)

--- @param identifier number|string
--- @param jobName string
--- @return boolean
--- @description Removes a job from a player if they have it
local function removeJob(identifier, jobName)
    identifier = verifyCitizenid(identifier)

    if not playerJobs[identifier] then
        initCache(identifier)
    end

    if not playerJobs[identifier][jobName] then
        print(Lang:t('Warning.failed_to_remove_no_Job', {identifier = identifier, job = jobName}))
        return false
    end

    playerJobs[identifier][jobName] = nil
    updataDatabase(identifier)
    return true
end
exports('removeJob', removeJob)


--- @param identifier number|string
--- @param jobName string
--- @return boolean
--- @description Checks if a player has a specific job
local function hasJob(identifier, jobName)
    identifier = verifyCitizenid(identifier)

    if not playerJobs[identifier] then
        initCache(identifier)
    end

    if playerJobs[identifier][jobName] then
        return true
    else
        return false
    end
end
exports('hasJob', hasJob)

--local function getEmployees(jobName)
--    local employees = {}
--    local result = MySQL.query.await('SELECT * FROM multijob WHERE JSON_CONTAINS_PATH(jobs, "one", "$.' .. jobName .. '")', {})
--    for i = 1, #result do
--        local citizenid = result[i].citizenid
--        employees[#employees + 1] = {
--            citizenid = citizenid,
--            name = result[i].name,
--            jobData = playerJobs[citizenid][jobName]
--        }
--    end
--    return employees
--end

---@description Event is triggered on player loading to init their job data
RegisterNetEvent('qb-multijob:server:loadData', function()
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    if not playerJobs[citizenid] then
        initCache(citizenid)
    end
    TriggerClientEvent('qb-multijob:client:loadJobs', src, playerJobs[citizenid])
end)

---@param jobName string
---@description Event to set a player's current job if they have it
RegisterNetEvent('qb-multijob:server:setJob', function(jobName)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    if playerJobs[citizenid] and playerJobs[citizenid][jobName] then
        Player.Functions.SetJob(jobName, playerJobs[citizenid][jobName].grade)
        if refuseDuty[jobName] then
            Player.Functions.SetJobDuty(false)
        end
        TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.signedIn', {job = jobName}), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.failedSignIn_noJob', {job = jobName}), 'error')
    end
end)

---@param jobName string
---@description Event to toggle a player's duty status for a specific job
RegisterNetEvent('qb-multijob:server:toggleDuty', function(jobName)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    if refuseDuty[jobName] then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.cantToggle', {job = playerJobs[citizenid][jobName].label}), 'error')
        return
    end
    if playerJobs[citizenid] and playerJobs[citizenid][jobName] then
        if Player.PlayerData.job.name == jobName then
            Player.Functions.SetJobDuty(not Player.PlayerData.job.onduty)
            TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.toggleDuty', {status = not Player.PlayerData.job.onduty and "On" or "Off"}), 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.failedSignIn_noJob', {job = jobName}), 'error')
    end
end)

---@param jobName string
---@description Event To Remove Job When Player Quits
RegisterNetEvent('qb-multijob:server:quitJob', function(jobName)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    if playerJobs[citizenid] and playerJobs[citizenid][jobName] then
        if removeJob(citizenid, jobName) then
            if Player.PlayerData.job.name == jobName then
                Player.Functions.SetJob('unemployed', 0)
            end
            TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.quitJob', {job = jobName}), 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.failed_to_remove_no_Job', {identifier = citizenid, job = jobName}), 'error')
        end
        TriggerClientEvent('qb-multijob:client:loadJobs', src, playerJobs[citizenid])
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('Notify.failedSignIn_noJob', {job = jobName}), 'error')
    end
end)
