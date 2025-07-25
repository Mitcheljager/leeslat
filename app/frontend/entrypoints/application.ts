import "@hotwired/turbo-rails";
import theme_toggle from "../javascript/theme_toggle";
import switch_toggle from "../javascript/switch_toggle";
import expand_text from "../javascript/expand_text";
import poll_listings_summary from "../javascript/poll_listings_summary";

document.addEventListener("turbo:load", () => {
  new theme_toggle().bind();
  new switch_toggle().bind();
  new expand_text().bind();

  new poll_listings_summary().run();
});
