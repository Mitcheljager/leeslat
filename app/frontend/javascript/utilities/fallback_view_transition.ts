export function fallback_view_transition(callback: Function, condition: boolean): void {
  if (!document.startViewTransition || !condition) {
    callback();
    return;
  }

  document.startViewTransition(() => {
    callback();
  });
}
