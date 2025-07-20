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

    this.set_clip_path_target(html_element, theme);
    this.set_cookie(theme);

    if (theme === "dark") new switch_toggle().toggle(toggle_button, true);

    toggle_button.addEventListener("click", () => {
      setTimeout(() => {
        fallback_view_transition(() => {
          const currentTheme = html_element.style.getPropertyValue("color-scheme") as Theme;
          const theme = currentTheme === "light" ? "dark" : "light";

          this.set_clip_path_target(html_element, theme);
          html_element.style.setProperty("color-scheme", theme);

          this.set_cookie(theme);
        }, !prefers_reduced_motions());
      }, window.ViewTransition ? 200 : 0);
    });
  }

  get_initial_theme(html_element: HTMLHtmlElement): Theme {
    const html_theme = html_element.style.getPropertyValue("color-scheme");
    const window_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";

    return (html_theme || window_theme) as Theme;
  }

  set_clip_path_target(html_element: HTMLHtmlElement, theme: Theme): void {
    const light = "0 0, 100% 0%, 100% 0, 0 0";
    const dark = "0 100%, 100% 100%, 100% 100%, 0 100%";

    html_element.style.setProperty("--theme-toggle-clip-path", theme === "dark" ? dark : light);
  }

  set_cookie(theme: Theme): void {
    document.cookie = `theme=${theme}; path=/; max-age=31536000`;
  }
}
