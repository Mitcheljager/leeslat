export default class toggle_content {
  bind(): void {
    const elements: HTMLButtonElement[] = Array.from(document.querySelectorAll("[data-action~='toggle_content']"));

    elements.forEach(element => {
      element.maybe_add_event_listener("click", () => this.toggle(element));
    });
  }

  private toggle(element: HTMLButtonElement): void {
    const target: HTMLElement | null = document.querySelector(`[data-toggleable~='${element.dataset.target}']`);

    if (!target) return;

    this.set_label(element);

    const toggle_class: string | null = element.dataset.toggleClass || null;

    if (toggle_class) this.toggle_with_class(target, toggle_class);
    else this.toggle_with_display(target);
  }

  private toggle_with_class(target: HTMLElement, toggle_class: string): void {
    target.classList.toggle(toggle_class, !target.classList.contains(toggle_class));
  }

  private toggle_with_display(target: HTMLElement): void {
    const currently_visible = window.getComputedStyle(target).display !== "none";

    target.style.display = currently_visible ? "none" : "";
  }

  private set_label(element: HTMLButtonElement): void {
    if (!element.dataset.showsWith) return;
    if (!element.dataset.hidesWith) return;

    element.innerHTML = element.innerHTML === element.dataset.showsWith ? element.dataset.hidesWith : element.dataset.showsWith;
  }
}
