// Store all bound events in a WeakMap. Store elements with their ids. These ids are checked
// before assigning the event listener, not applying the listener if it's already present.
// A WeakMap is used so that elements are removed from the map when the element is removed.
// This whole thing exists to prevent Turbo from re-binding events on turbo:load for elements
// that already have the event attached to them.
const bindings = new WeakMap<Element, string[]>();

Element.prototype.maybe_add_event_listener = function(event, callback): void {
  const id = callback.toString();
  const bound_ids = bindings.get(this) || [];

  if (bound_ids?.includes(id)) return;

  this.addEventListener(event, callback);

  bound_ids.push(id);
  bindings.set(this, bound_ids);
};

interface Element {
  maybe_add_event_listener(event: string, callback: Function): void
}
