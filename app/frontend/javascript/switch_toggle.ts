export default class switch_toggle {
  bind(): void {
    const switch_elements: HTMLButtonElement[] = Array.from(document.querySelectorAll("[data-action~='switch']"));

    switch_elements.forEach(element => {
      element.maybe_add_event_listener("click", () => this.toggle(element, !element.classList.contains("switch--active")));
    });
  }

  toggle(element: HTMLButtonElement, state: boolean): void {
    const indicator_element = element.querySelector("[data-role~='switch_indicator']");
    const transition_duration = parseFloat(window.getComputedStyle(indicator_element!).transitionDuration) * 1000;

    element.classList.add("switch--switching");
    element.classList.toggle("switch--active", state);

    setTimeout(() => {
      element.classList.remove("switch--switching");
    }, transition_duration);
  }
}
