import { Turbo } from "@hotwired/turbo-rails";

export default class form_filter {
  bind(): void {
    const form_elements: HTMLFormElement[] = Array.from(document.querySelectorAll("[data-action~='form_filter']"));

    form_elements.forEach(form => {
      this.bind_inputs(form);
      form.maybe_add_event_listener("submit", (event: SubmitEvent) => event.preventDefault());
    });
  }

  private bind_inputs(form: HTMLFormElement): void {
    const inputs: HTMLInputElement[] = Array.from(form.querySelectorAll("input, select"));

    inputs.forEach(input => input.maybe_add_event_listener("change", () => this.submit(form)));
  }

  private submit(form: HTMLFormElement): void {
    const form_data = new FormData(form);

    const params = Object.fromEntries(form_data);
    for (const key in params) {
      if (!params[key]) delete params[key];
    }

    const urlParams = new URLSearchParams(params as any);
    const url = `${form.action}?${urlParams.toString()}`;

    Turbo.visit(url, { frame: "form_filter_content" });
  }
}
