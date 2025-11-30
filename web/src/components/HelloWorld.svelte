<script lang="ts">
   import { jobList, currentJob } from '../store/stores';
  import { fetchNui } from '../utils/fetchNui';

  let selectedJob: number | null = null;


  function selectJob(index: number) {
    selectedJob = selectedJob === index ? null : index;
  }

async function signIn() {
  if (selectedJob === null) return;
  const jobName = $jobList[selectedJob].name;
  const response = await fetchNui('signInJob', jobName);
  if (response) {
    currentJob.set(jobName);
  }
}

function quitJob() {
  if (selectedJob === null) return;
  const jobName = $jobList[selectedJob].name;
  if (jobName === 'unemployed') return;
  const response = fetchNui('quitJob', jobName);
  if (response) {
    jobList.update(jobs => {
      const updated = [...jobs];
      updated.splice(selectedJob, 1);
      return updated;
    });
    selectedJob = null;
  }
}

function toggleDuty() {
  if (selectedJob === null) return;
  const jobName = $jobList[selectedJob].name;
  if (jobName === $currentJob) {
    fetchNui('toggleDuty', jobName);
  }
}
</script>

<div class="container">
  <div class="header">
    <div class="header-text">Multi Job</div>
  </div>

  <div class="content">
   {#each $jobList as jobData, index}
      <div class="job-card" class:selected={selectedJob === index}>
        <div class="job-info" on:click={() => selectJob(index)}>
          <div class="job-header">
            <h3 class="job-title">{jobData.label}</h3>
            <span class="pay-badge">${jobData.pay}/hr</span>
          </div>
          <p class="grade">{jobData.gradeLabel}</p>
        </div>

        {#if selectedJob === index}
          <div class="actions">
            {#if jobData.name !== $currentJob}
              <button class="btn sign-in" on:click={signIn}>
                Sign In
              </button>
            {/if}
            {#if jobData.name === $currentJob}
              <button class="btn clock-in" on:click={toggleDuty}>
                Toggle Duty
              </button>
            {/if}
              
            <button class="btn quit" on:click={quitJob}>
              Quit Job
            </button>
          </div>
        {/if}
      </div>
    {/each}
  </div>
</div>

<style>
  :root {
    --qb-red: #e63946;
    --qb-red-hover: #d62828;
    --qb-red-dark: #c1121f;
    --bg-main: #0d0d0d;
    --bg-container: #1a1a1a;
    --bg-container-active: #222222;
    --bg-container-hover: #1e1e1e;
    --header: #111111;
    --header-text: #ffffff;
    --container-border: #2a2a2a;
    --container-border-active: #e63946;
    --container-border-hover: #333333;
    --main-text: #e8e8e8;
    --secondary-text: #9a9a9a;
    --sign-in: #3b82f6;
    --clock-in: #10b981;
    --quit: #ef4444;
    --sign-in-hover: #2563eb;
    --clock-in-hover: #059669;
    --quit-hover: #dc2626;
  }
  
  .container {
    position: absolute;
    top: 50%;
    left: 80%;
    transform: translate(-50%, -50%);
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg-main);
    width: 22%;
    height: 52%;
    border-radius: 12px;
    color: var(--main-text);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
    border: 1px solid #1a1a1a;
  }

  .header {
    height: 60px;
    background: var(--header);
    display: flex;
    align-items: center;
    justify-content: center;
    border-bottom: 2px solid var(--qb-red);
    position: relative;
  }

  .header::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--qb-red), transparent);
  }

  .header-text {
    font-size: 28px;
    font-weight: 700;
    color: var(--header-text);
    letter-spacing: 1.5px;
    text-transform: uppercase;
  }

  .content {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    padding: 12px;
  }

  .content::-webkit-scrollbar {
    width: 6px;
  }

  .content::-webkit-scrollbar-track {
    background: var(--bg-main);
  }

  .content::-webkit-scrollbar-thumb {
    background: var(--qb-red);
    border-radius: 3px;
  }

  .content::-webkit-scrollbar-thumb:hover {
    background: var(--qb-red-hover);
  }

  .job-card {
    background: var(--bg-container);
    border-radius: 8px;
    margin-bottom: 10px;
    transition: all 0.2s ease;
    border: 1px solid var(--container-border);
    overflow: hidden;
  }

  .job-card:hover {
    border-color: var(--container-border-hover);
    transform: translateX(2px);
  }

  .job-card.selected {
    border-color: var(--container-border-active);
    background: var(--bg-container-active);
  }

  .job-info {
    padding: 18px 20px;
    cursor: pointer;
  }

  .job-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
  }

  .job-title {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--main-text);
  }

  .pay-badge {
    font-size: 12px;
    font-weight: 700;
    color: #10b981;
    background: rgba(16, 185, 129, 0.1);
    padding: 5px 12px;
    border-radius: 6px;
    border: 1px solid rgba(16, 185, 129, 0.2);
  }

  .grade {
    margin: 0;
    font-size: 13px;
    color: var(--secondary-text);
    font-weight: 400;
  }

  .actions {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
    padding: 0 20px 18px 20px;
  }

  .btn {
    padding: 10px 8px;
    border: none;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s ease;
    font-size: 12px;
    letter-spacing: 0.3px;
    text-transform: uppercase;
    border: 1px solid transparent;
  }

  .sign-in {
    background: var(--sign-in);
    color: white;
  }

  .sign-in:hover {
    background: var(--sign-in-hover);
    border-color: #3b82f6;
  }

  .clock-in {
    background: var(--clock-in);
    color: white;
  }

  .clock-in:hover {
    background: var(--clock-in-hover);
  }

  .quit {
    background: var(--quit);
    color: white;
  }

  .quit:hover {
    background: var(--quit-hover);
  }
</style>