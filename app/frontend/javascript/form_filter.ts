import { Turbo } from "@hotwired/turbo-rails";

export default class form_filter {
  bind(): void {
    const form_elements: HTMLFormElement[] = Array.from(document.querySelectorAll("[data-action~='form_filter']"));

    form_elements.forEach(form => {
      this.bind_inputs(form);
      form.maybe_add_event_listener("submit", (event: SubmitEvent) => {
        if (!this.is_submit_button_visible(form)) event.preventDefault();
      });
    });
  }

  private bind_inputs(form: HTMLFormElement): void {
    const inputs: HTMLInputElement[] = Array.from(form.querySelectorAll("input, select"));

    inputs.forEach(input => input.maybe_add_event_listener("change", () => this.submit(form)));
  }

  private submit(form: HTMLFormElement): void {
    if (this.is_submit_button_visible(form)) return;

    // Wait one frame so that checkboxes that are updated in bulk all have their state changed
    // before actually processing the form.
    requestAnimationFrame(() => {
      const form_data = new FormData(form);

      const params = this.form_data_to_params(form_data);

      const url_params = new URLSearchParams(params as any);
      const url = `${form.action}?${url_params.toString()}`;

      Turbo.visit(url, { frame: "form_filter_content" });
    })
  }

  // If the submit button is visible we forgo the whole auto submitting thing.
  // Instead the user is expected to submit the form themselves.
  private is_submit_button_visible(form: HTMLFormElement): boolean {
    const button: HTMLButtonElement | null = form.querySelector("[data-role='filter_submit']");

    if (!button) return false;
    return (window.getComputedStyle(button).display !== "none");
  }

  // Remove empty values and values that match min/max values of inputs.
  // The goal is to keep the URL as clean as possible, removing anything that
  // doesn't actually do anything.
  private form_data_to_params(form_data: FormData): [string, FormDataEntryValue][] {
    const params = form_data.entries();
    const cleaned_params: [string, FormDataEntryValue][] = [];

    for (const entry of params) {
      const [key, value] = entry;

      if (!value) continue;

      const matching_input = document.querySelector(`[name="${key}"]`) as HTMLInputElement;

      if (!matching_input) continue;

      if (matching_input.type === "number") {
        if (matching_input.min === value) continue;
        if (matching_input.max === value) continue;
      }

      cleaned_params.push(entry);
    }

    return cleaned_params;
  }
}
