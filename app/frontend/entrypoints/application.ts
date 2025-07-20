import "@hotwired/turbo-rails";
import theme_toggle from "../javascript/theme_toggle";
import switch_toggle from "../javascript/switch_toggle";

document.addEventListener("turbo:load", () => {
  new theme_toggle().bind();
  new switch_toggle().bind();
});
