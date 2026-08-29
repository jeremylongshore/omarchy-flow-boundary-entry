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
/* Stryker disable next-line ConditionalExpression,StringLiteral: QML has no CommonJS module; Node does. */
if (typeof module !== "undefined") module.exports={MAX_EVENTS,MAX_STORED_BYTES,storedEvents,parse,appendEvent,pillText,tooltipText,kindHue,kindLabel}
