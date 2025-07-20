export default class switch_toggle {
  bind(): void {
    const switch_elements: HTMLButtonElement[] = Array.from(document.querySelectorAll("[data-action~='switch']"));

    switch_elements.forEach(element => {
      element.addEventListener("click", () => this.toggle(element));
    });
  }

  toggle(element: HTMLButtonElement): void {
    const indicator_element = element.querySelector("[data-role~='switch_indicator']");
    const transition_duration = parseFloat(window.getComputedStyle(indicator_element!).transitionDuration) * 1000;

    element.classList.add("switch--switching");
    element.classList.toggle("switch--active");

    setTimeout(() => {
      element.classList.remove("switch--switching");
    }, transition_duration);
  }
}
