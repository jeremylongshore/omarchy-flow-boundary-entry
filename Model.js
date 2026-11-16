var MAX_EVENTS = 32
var MAX_STORED_BYTES = 8192
function storedEvents(raw) {
  if (typeof raw !== "string" || raw.length > MAX_STORED_BYTES) return []
  var x; try { x = JSON.parse(raw) } catch (e) { return [] }
  if (!Array.isArray(x)) {
    if (!x || !Array.isArray(x.events)) return []
    x = x.events
  }
  var events = x
  var out = []
  for (var i = 0; i < Math.min(events.length, MAX_EVENTS); i++) {
    var event = events[i] || {}
    var at = Number(event.at)
    if ((event.kind !== "arrive" && event.kind !== "leave") || !isFinite(at) || at <= 0) continue
    out.push({kind:event.kind, at:Math.floor(at)})
  }
  return out
}
function parse(raw, nowMs) {
  var events = storedEvents(raw)
  var out=[]
  for (var i=0;i<events.length;i++) { var e=events[i]; var d=Math.max(0,Math.floor(Number(nowMs)/1000-e.at)); out.push({kind:e.kind,age:d<60?"NOW":d<3600?Math.floor(d/60)+"M":Math.floor(d/3600)+"H"}) }
  return out
}
function appendEvent(raw, kind, nowMs) {
  var events = storedEvents(raw)
  if (kind !== "arrive" && kind !== "leave") return JSON.stringify(events)
  var at = Math.floor(Number(nowMs) / 1000)
  if (!isFinite(at) || at <= 0) return JSON.stringify(events)
  events = events.slice(-(MAX_EVENTS - 1))
  events.push({kind:kind, at:at})
  return JSON.stringify(events)
}
function pillText(rows) { return rows && rows.length ? (rows[rows.length-1].kind === "arrive" ? "FLOW" : "PAUSE") : "FLOW" }
function tooltipText(rows) { return rows && rows.length ? "Last boundary: " + rows[rows.length-1].kind : "Mark an intentional context boundary" }
function kindHue(kind) { return kind === "arrive" ? 0.43 : 0.075 }
function kindLabel(kind) { return kind === "arrive" ? "CONTEXT OPENED" : "CONTEXT CLOSED" }
// Text and edges that are light on a dark surface vanish on a light one (1.3 to
// 1.8:1 on catppuccin-latte), so the panel picks the lightness for the surface
// it is drawn on. Exactly 0.5 counts as dark, and a missing reading stays dark.
function toneLightness(dark, light, surfaceLightness) { return Number(surfaceLightness) > 0.5 ? light : dark }
// Arrive is choice 0 and Leave is choice 1. Forward lands on Leave and back on
// Arrive. The two ends do not wrap, so a held key rests on a button instead of
// flipping it, and a zero step stays where it is.
function moveChoice(choice, step) { return step > 0 ? 1 : step < 0 ? 0 : choice === 1 ? 1 : 0 }
function choiceKind(choice) { return choice === 1 ? "leave" : "arrive" }
/* Stryker disable next-line ConditionalExpression,StringLiteral: QML has no CommonJS module; Node does. */
if (typeof module !== "undefined") module.exports={MAX_EVENTS,MAX_STORED_BYTES,storedEvents,parse,appendEvent,pillText,tooltipText,kindHue,kindLabel,toneLightness,moveChoice,choiceKind}
