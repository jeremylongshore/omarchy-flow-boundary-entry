var MAX_EVENTS = 32
function parse(raw, nowMs) {
  var x; try { x = JSON.parse(String(raw)) } catch (e) { return [] }
  if (!x || !Array.isArray(x.events)) return []
  var out=[]
  for (var i=0;i<x.events.length && out.length<MAX_EVENTS;i++) { var e=x.events[i]||{}; if ((e.kind!=="arrive"&&e.kind!=="leave") || !isFinite(Number(e.at)) || Number(e.at)<=0) continue; var d=Math.max(0,Math.floor(Number(nowMs)/1000-Number(e.at))); out.push({kind:e.kind,age:d<60?"NOW":d<3600?Math.floor(d/60)+"M":Math.floor(d/3600)+"H"}) }
  return out
}
function pillText(rows) { return rows && rows.length ? (rows[rows.length-1].kind === "arrive" ? "FLOW" : "PAUSE") : "FLOW" }
function tooltipText(rows) { return rows && rows.length ? "Last boundary: " + rows[rows.length-1].kind : "Mark an intentional context boundary" }
function kindHue(kind) { return kind === "arrive" ? 0.43 : 0.075 }
function kindLabel(kind) { return kind === "arrive" ? "CONTEXT OPENED" : "CONTEXT CLOSED" }
if (typeof module !== "undefined") module.exports={MAX_EVENTS,parse,pillText,tooltipText,kindHue,kindLabel}
