export default class checkbox_list {
  static checkboxSelector: string = "[data-action~='toggle_checkbox_list']";

  bind(): void {
    const checkbox_elements: HTMLInputElement[] = this.get_checkbox_elements(document);

    checkbox_elements.forEach(element => {
      element.maybe_add_event_listener("change", () => this.toggle(element));
    });
  }

  // Toggle child checkboxes off if parent is toggled off.
  // Do nothing when toggled on.
  toggle(element: HTMLInputElement): void {
    if (element.checked) return;

    const list_element: HTMLElement | null = element.closest("[data-role='checkbox_list']");
    if (!list_element) return;

    const child_checkbox_elements: HTMLInputElement[] = this.get_checkbox_elements(list_element);

    child_checkbox_elements.forEach(element => element.checked = false);
  }

  private get_checkbox_elements(parent_element: HTMLElement | Document): HTMLInputElement[] {
    return Array.from(parent_element.querySelectorAll("[data-action~='toggle_checkbox_list']"));
  }
}
