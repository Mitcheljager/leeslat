export default class expand_text {
  bind(): void {
    const switch_elements: HTMLButtonElement[] = Array.from(document.querySelectorAll("[data-action~='expand_text']"));

    switch_elements.forEach(element => {
      element.maybe_add_event_listener("click", () => this.toggle(element));
    });
  }

  toggle(element: HTMLButtonElement): void {
    const target = element.getAttribute("aria-controls") as string;
    const target_element = document.getElementById(target);

    if (!target_element) return;

    target_element.classList.toggle("expanded");
    const expanded = target_element.classList.contains("expanded");

    element.ariaExpanded = expanded.toString();

    if (element.getAttribute("aria-remove-on-expand") === "true") element.remove();
    if (expanded && element.dataset.expandWith) element.innerText = element.dataset.expandWith;
    if (!expanded && element.dataset.collapseWith) element.innerText = element.dataset.collapseWith;
  }
}
