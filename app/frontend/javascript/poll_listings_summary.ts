export default class poll_listings_summary {
  static interval = 3000;
  static element: HTMLElement | null = null;

  run(): void {
    poll_listings_summary.element = document.querySelector("[data-action~='poll_listings_summary']");

    if (!poll_listings_summary.element) return;

    new Promise<void>((resolve, reject) => this.poll(resolve, reject));
  }

  private async poll(resolve: Function, reject: Function): Promise<void> {
    const url = poll_listings_summary.element!.dataset.url!;

    try {
      const response = await fetch(url);

      if (response?.status !== 200) throw new Error;

      const html_content = await response.text();

      poll_listings_summary.element!.innerHTML = html_content;
      this.update_notice_text();
    } catch {
      setTimeout(() => this.poll(resolve, reject), poll_listings_summary.interval);
    }
  }

  private update_notice_text(): void {
    const element: HTMLElement | null = document.querySelector("[data-role~='poll_listings_summary_notice']");

    if (!element) return;

    element.innerText = element.dataset.finalText!;
    element.classList.add("notice--success");
  }
}
