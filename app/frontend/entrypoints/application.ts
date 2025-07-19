import "@hotwired/turbo-rails";
import theme_toggle from "../javascript/theme_toggle";

document.addEventListener("turbo:load", () => {
  new theme_toggle().bind();
});
