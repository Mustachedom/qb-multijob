local Translations = {
    menu = {
        mainHeader = 'Job Menu',
        jobDesc = ' Rank: {rankName} | Pay: ${pay}',
        currency = '$',
        optionHeader = 'Options for ',
        setJobHeader = 'Set as Job',
        setJobDesc = 'Set Current Job As',
        toggleDuty = 'Toggle Duty',
        toggleDutyDesc = 'Toggle Duty for',
        quit = 'Quit Job',
        quitDesc = 'Quit your job as',
        goback = 'Go Back',
        gobackDesc = 'Return To The Previous Page',
        unemployedDescription = 'Be Unemployed | $',
        closeMenu = 'Close Menu',
    },
    notify = {
        job_not_found = 'Job not found.',
        grade_not_found = 'Grade not found.',
        unemployed = 'You Are Now Unemployed',
        jobChange = 'You are now employed as at ',
        dont_have_job = 'You do not have this job.',
        cantQuitUnemployed = 'You cannot quit being unemployed.',
        error_quitting_job = 'An error occurred while trying to quit your job.',
        quit_job = 'You have quit your job as a ',
        cantToggle = 'You cannot toggle duty for this job.',
        toggleDuty = 'You are now ',
        overMax = 'You Already Have The Maximum Amount Of Jobs',
        lost_job = 'You have lost your job as a ',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
