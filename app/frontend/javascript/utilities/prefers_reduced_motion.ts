export function prefers_reduced_motions(): boolean {
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}
