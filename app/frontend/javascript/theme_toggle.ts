import switch_toggle from "./switch_toggle";
import { fallback_view_transition } from "./utilities/fallback_view_transition";
import { prefers_reduced_motions } from "./utilities/prefers_reduced_motion";

type Theme = "light" | "dark";

export default class theme_toggle {
  bind(): void {
    const toggle_button: HTMLButtonElement | null = document.querySelector("[data-action~='toggle_theme']");

    if (!toggle_button) return;

    const html_element =  document.querySelector("html") as HTMLHtmlElement;
    const theme = this.get_initial_theme(html_element);

    html_element.style.setProperty("color-scheme", theme);
    html_element.style.viewTransitionName = "changing-theme";

    this.set_position(html_element, toggle_button);
    this.set_cookie(theme);

    if (theme === "dark") new switch_toggle().toggle(toggle_button);

    toggle_button.addEventListener("click", () => {
      fallback_view_transition(() => {
        const currentTheme = html_element.style.getPropertyValue("color-scheme") as Theme;
        const theme = currentTheme === "light" ? "dark" : "light";

        this.set_position(html_element, toggle_button);
        html_element.style.setProperty("color-scheme", theme);

        this.set_cookie(theme);
      }, !prefers_reduced_motions());
    });
  }

  get_initial_theme(html_element: HTMLHtmlElement): Theme {
    const html_theme = html_element.style.getPropertyValue("color-scheme");
    const window_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";

    return (html_theme || window_theme) as Theme;
  }

  set_position(html_element: HTMLHtmlElement, toggle_button: HTMLButtonElement): void {
    const { width, height, left, top } = toggle_button.getBoundingClientRect();

    const x = (left + (width / 2)) / window.innerWidth * 100;
    const y = (top + (height / 2)) / window.innerHeight * 100;

    html_element.style.setProperty("--theme-toggle-position", `${x.toFixed(2)}% ${y.toFixed(2)}%`);
  }

  set_cookie(theme: Theme): void {
    document.cookie = `theme=${theme}; path=/; max-age=31536000`;
  }
}
