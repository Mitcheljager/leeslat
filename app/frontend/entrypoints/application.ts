import "@hotwired/turbo-rails";
import theme_toggle from "../javascript/theme_toggle";
import switch_toggle from "../javascript/switch_toggle";
import expand_text from "../javascript/expand_text";
import poll_listings_summary from "../javascript/poll_listings_summary";
import turbo_action_progress_bar from "../javascript/turbo_action_progress_bar";

document.addEventListener("turbo:load", () => {
  new theme_toggle().bind();
  new switch_toggle().bind();
  new expand_text().bind();
  new turbo_action_progress_bar().bind();

  new poll_listings_summary().run();
});
