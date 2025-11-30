<script lang="ts">
  import { useNuiEvent } from '../utils/useNuiEvent';
  import { fetchNui } from '../utils/fetchNui';
  import { onMount } from 'svelte';
  import { visibility, currentJob, jobList } from '../store/stores';

  let isVisible: boolean;

  visibility.subscribe((visible) => {
    isVisible = visible;
  });

  useNuiEvent<boolean>('openMultijob', (data) => {
    visibility.set(true);
    currentJob.set(data.currentJob);
    jobList.set(data.jobList);
  });

  onMount(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (isVisible && ['Escape'].includes(e.code)) {
        fetchNui('hideUI');
        visibility.set(false);
        currentJob.set(null);
        jobList.set(null);
      }
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
  });
</script>

<main>
  {#if isVisible}
    <slot />
  {/if}
</main>
