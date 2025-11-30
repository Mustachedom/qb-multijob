local Translations = {
    Warning = {
        not_found_in_jobs = "^1 [WARNING]: Job: %{job} Rank: %{rank} does not exist in qb-core/shared/jobs.lua",
        failed_update_no_Job = 'PLAYER: %{identifier} - Failed to update job %{job} to rank %{rank} Because Player Does Not Have The Job',
        failed_to_remove_no_Job = 'PLAYER: %{identifier} - Failed to remove job %{job} Because Player Does Not Have The Job',
    },
    Notify = {
        failedAdd_maxJobs = "Player: %{identifier} - Failed to add job %{job} rank %{rank} because they have reached the maximum number of jobs.",
        failed_update_alreadyHas = "Failed To Give Player: %{identifier} Job: %{job} Rank: %{rank} Because They Already Have The Job",
        signedIn = "You have signed in as %{job}",
        failedSignIn_noJob = "You do not have the job %{job} to sign in as it.",
        cantToggle = "You need to clock in at your workplace for %{job}",
        toggleDuty = "You Are Now %{status} Duty!",
        quitJob = "You have quit your job as %{job}",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
