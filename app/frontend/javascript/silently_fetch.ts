export default class silently_fetch {
  run(): void {
    const elements: HTMLElement[] = Array.from(document.querySelectorAll("[data-action~='silently_fetch'][data-url]"));

    elements.forEach(element => fetch((element.dataset.url!)))
  }
}
