import "@hotwired/turbo-rails";
import "../javascript/maybe_add_event_listener";

import theme_toggle from "../javascript/theme_toggle";
import switch_toggle from "../javascript/switch_toggle";
import expand_text from "../javascript/expand_text";
import poll_listings_summary from "../javascript/poll_listings_summary";
import turbo_action_progress_bar from "../javascript/turbo_action_progress_bar";
import form_filter from "../javascript/form_filter";
import toggle_content from "../javascript/toggle_content";
import checkbox_list from "../javascript/checkbox_list";
import silently_fetch from "../javascript/silently_fetch";

// Events that are attached to the document are bound through here,
// otherwise they would be re-bound every time turbo:loads fires.
window.addEventListener("load", () => {
  new turbo_action_progress_bar().bind();
});

// Events that are per-element are bound here so that they are re-bound
// when the page changes.
document.addEventListener("turbo:load", () => {
  new theme_toggle().bind();
  new switch_toggle().bind();
  new expand_text().bind();
  new form_filter().bind();
  new toggle_content().bind();
  new checkbox_list().bind();

  new poll_listings_summary().run();
  new silently_fetch().run();
});
