import switch_toggle from "./switch_toggle";
import { fallback_view_transition } from "./utilities/fallback_view_transition";
import { prefers_reduced_motions } from "./utilities/prefers_reduced_motion";

type Theme = "light" | "dark";

export default class theme_toggle {
  static theme: Theme;
  static html_element: HTMLHtmlElement;

  bind(): void {
    const toggle_button: HTMLButtonElement | null = document.querySelector("[data-action~='toggle_theme']");

    if (!toggle_button) return;

    theme_toggle.html_element = document.querySelector("html") as HTMLHtmlElement;
    theme_toggle.theme = this.get_initial_theme();

    theme_toggle.html_element.style.setProperty("color-scheme", theme_toggle.theme);
    theme_toggle.html_element.style.viewTransitionName = "changing-theme";

    this.set_clip_path_target();
    this.set_cookie();

    if (theme_toggle.theme === "dark") new switch_toggle().toggle(toggle_button, true);

    toggle_button.addEventListener("click", () => {
      setTimeout(() => {
        fallback_view_transition(() => {
          const currentTheme = theme_toggle.html_element.style.getPropertyValue("color-scheme") as Theme;
          theme_toggle.theme = currentTheme === "light" ? "dark" : "light";

          this.set_clip_path_target();
          theme_toggle.html_element.style.setProperty("color-scheme", theme_toggle.theme);

          this.set_cookie();
        }, !prefers_reduced_motions());
      }, window.ViewTransition ? 200 : 0);
    });
  }

  private get_initial_theme(): Theme {
    const html_theme = theme_toggle.html_element.style.getPropertyValue("color-scheme");
    const window_theme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";

    return (html_theme || window_theme) as Theme;
  }

  private set_clip_path_target(): void {
    const light = "0 0, 100% 0%, 100% 0, 0 0";
    const dark = "0 100%, 100% 100%, 100% 100%, 0 100%";

    theme_toggle.html_element.style.setProperty("--theme-toggle-clip-path", theme_toggle.theme === "dark" ? dark : light);
  }

  private set_cookie(): void {
    document.cookie = `theme=${theme_toggle.theme}; path=/; max-age=31536000`;
  }
}
