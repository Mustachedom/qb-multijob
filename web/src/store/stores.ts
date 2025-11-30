import { writable } from "svelte/store";

/** Returns boolean value of if the resource is visible or not */
export const visibility = writable(false);
export const jobList = writable<{ label: string; gradeLabel: string; pay: number; onduty: boolean, name: string }[] | null>(null);
export const currentJob = writable<string | null>(null);