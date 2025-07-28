import { Turbo } from "@hotwired/turbo-rails";

/**
 * data-turbo-action can be used to set the url when navigating with Turbo frames. It doesn't
 * actually show the progress bar when this happen. This class takes care of that by binding
 * events to form submissions and checking if the event was from a data-turbo-action element.
 * https://github.com/hotwired/turbo/issues/540#issuecomment-1783752175
 */
export default class turbo_action_progress_bar {
  bind(): void {
    const adapter = Turbo.navigator.delegate.adapter;

    document.addEventListener("turbo:before-fetch-request", (event) => {
      const target = event.target;

      if (!(target instanceof HTMLElement)) return;
      if (target.dataset.TurboAction !== undefined) return;

      adapter.formSubmissionStarted();
    }, true);

    document.addEventListener("turbo:before-fetch-response", () => {
      adapter.formSubmissionFinished();
    }, true);
  }
}
