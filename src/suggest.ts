// Name suggestions for the search and relationship-finder boxes. Replaces <datalist>, which many mobile browsers show
// badly or not at all (Firefox for Android ignores it; iOS only offers matches in the keyboard bar after typing).
// One shared list, placed under (or, near the bottom of the screen, above) whichever box has focus. Picking a name
// writes it into the box and fires `change`, the same event a datalist pick fires, so app.ts handles both alike.
const list = Object.assign(document.createElement("ul"), { id: "suggest", role: "listbox", hidden: true });
document.body.append(list);
let names: string[] = [];
let input: HTMLInputElement | null = null;
let active = -1;

/** The names to offer (the current saga's people). */
export function setSuggestions(all: string[]): void {
    names = all;
    if (input) render();
}

function render() {
    if (!input) return;
    const q = input.value.trim().toLowerCase();
    const hits = q ? names.filter((n) => n.toLowerCase().includes(q)) : names;
    active = -1;
    list.replaceChildren(
        ...hits.map((name, i) => {
            const li = Object.assign(document.createElement("li"), { textContent: name, id: `suggest-${i}` });
            li.setAttribute("role", "option");
            // Cancelling pointerdown keeps focus in the box, so its blur doesn't close the list mid-tap. The pick itself
            // waits for click: closing the list on pointerdown let the tap's click land on whatever was underneath.
            li.addEventListener("pointerdown", (e) => e.preventDefault());
            li.addEventListener("click", () => pick(name));
            return li;
        })
    );
    const exact = hits.length === 1 && hits[0].toLowerCase() === q;
    list.hidden = !hits.length || exact;
    input.setAttribute("aria-expanded", String(!list.hidden));
    if (!list.hidden) place();
}

function place() {
    const r = input!.getBoundingClientRect();
    const viewH = visualViewport?.height ?? innerHeight; // excludes the on-screen keyboard
    const below = viewH - r.bottom - 8;
    const above = r.top - 8;
    const up = below < 180 && above > below;
    Object.assign(list.style, {
        left: `${r.left}px`,
        width: `${r.width}px`,
        top: up ? "" : `${r.bottom + 2}px`,
        bottom: up ? `${innerHeight - r.top + 2}px` : "",
        maxHeight: `${Math.min(280, up ? above : below)}px`,
    });
}

function pick(name: string) {
    if (!input) return;
    input.value = name;
    close();
    input.dispatchEvent(new Event("change"));
}

function close() {
    list.hidden = true;
    input?.setAttribute("aria-expanded", "false");
}

function highlight(i: number) {
    list.children[active]?.removeAttribute("aria-selected");
    active = i;
    const li = list.children[i];
    li?.setAttribute("aria-selected", "true");
    li?.scrollIntoView({ block: "nearest" });
    if (li) input?.setAttribute("aria-activedescendant", li.id);
    else input?.removeAttribute("aria-activedescendant");
}

/** Offer suggestions on this box: on focus (the whole list) and while typing (names containing the text). */
export function attachSuggestions(box: HTMLInputElement): void {
    box.setAttribute("role", "combobox");
    box.setAttribute("aria-controls", "suggest");
    box.setAttribute("aria-autocomplete", "list");
    box.setAttribute("aria-expanded", "false");
    box.addEventListener("focus", () => ((input = box), render()));
    box.addEventListener("input", render);
    box.addEventListener("blur", () => (close(), (input = null)));
    box.addEventListener("keydown", (e) => {
        if (list.hidden) return;
        const n = list.children.length;
        if (e.key === "ArrowDown" || e.key === "ArrowUp") {
            e.preventDefault();
            highlight((active + (e.key === "ArrowDown" ? 1 : n - 1 + (active < 0 ? 1 : 0))) % n);
        } else if (e.key === "Enter" && active >= 0) {
            e.preventDefault();
            pick(list.children[active].textContent!);
        } else if (e.key === "Escape") {
            e.stopImmediatePropagation(); // first Escape closes the list; the next one is the box's own
            close();
        }
    });
}
addEventListener("resize", () => input && !list.hidden && place());
visualViewport?.addEventListener("resize", () => input && !list.hidden && place());
