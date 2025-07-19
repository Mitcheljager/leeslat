import { fallback_view_transition } from "./utilities/fallback_view_transition";
import { prefers_reduced_motions } from "./utilities/prefers_reduced_motion";

export default class theme_toggle {
  bind(): void {
    const toggleButton: HTMLButtonElement | null = document.querySelector("[data-action~='toggle_theme']")

    if (!toggleButton) return

    const htmlElement =  document.querySelector("html") as HTMLHtmlElement;
    const theme = htmlElement.style.getPropertyValue("color-scheme") as "light" | "dark";

    htmlElement.style.setProperty("color-scheme", theme);
    htmlElement.style.viewTransitionName = "changing-theme";

    this.set_position(htmlElement, toggleButton);

    toggleButton.addEventListener("click", () => {
      fallback_view_transition(() => {
        const theme = htmlElement.style.getPropertyValue("color-scheme");

        this.set_position(htmlElement, toggleButton);
        htmlElement.style.setProperty("color-scheme", theme === "light" ? "dark" : "light");

        document.cookie = `theme=${theme === "light" ? "dark" : "light"}; path=/; max-age=31536000`;
      }, !prefers_reduced_motions())
    })
  }

  set_position(htmlElement: HTMLHtmlElement, toggleButton: HTMLButtonElement) {
    const { width, height, left, top } = toggleButton.getBoundingClientRect();

    const x = (left + (width / 2)) / window.innerWidth * 100
    const y = (top + (height / 2)) / window.innerWidth * 100

    htmlElement.style.setProperty("--theme-toggle-position", `${x}% ${y}%`);
  }
}
