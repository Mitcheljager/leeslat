export default class expand_text {
  bind(): void {
    const switch_elements: HTMLButtonElement[] = Array.from(document.querySelectorAll("[data-action~='expand_text']"));

    switch_elements.forEach(element => {
      element.addEventListener("click", () => this.toggle(element));
    });
  }

  toggle(element: HTMLButtonElement): void {
    const target = element.getAttribute("aria-controls") as string;
    const targetElement = document.getElementById(target);

    if (!targetElement) return;

    targetElement.classList.toggle("expanded");
    const expanded = targetElement.classList.contains("expanded");

    element.ariaExpanded = expanded.toString();

    if (element.getAttribute("aria-remove-on-expand") === "true") element.remove();
    if (expanded && element.dataset.expandWith) element.innerText = element.dataset.expandWith;
    if (!expanded && element.dataset.collapseWith) element.innerText = element.dataset.collapseWith;
  }
}
