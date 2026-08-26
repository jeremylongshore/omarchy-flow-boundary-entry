import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model
Panel {
 id: root; moduleName: "io.github.jeremylongshore.flow-boundary"; ipcTarget: "io.github.jeremylongshore.flow-boundary"; manageIpc: false
 property var anchorItem: null; property var hostWidget: null; property bool openedFromHotkey: false; readonly property var barIdentity: hostWidget || root
 readonly property string helperPath: Qt.resolvedUrl("bin/flow-boundary").toString().replace(/^file:\/\//, "")
 property var rows: []; property bool loaded: false; property double nowMs: Date.now(); readonly property bool isAlert: false
 readonly property string label: loaded ? Model.pillText(rows) : "FLOW"; readonly property string tooltip: loaded ? Model.tooltipText(rows) : "Reading local boundary ledger…"
 function open() { openedFromHotkey=false; root.controller.show(); root.refresh() } function openFromHotkey() { openedFromHotkey=true; root.controller.show(); root.refresh() } function close(){root.controller.hide()} function toggle(){if(root.opened)root.close();else root.openFromHotkey()} function switchPanel(d){return root.bar&&typeof root.bar.switchPanelFrom==="function"?root.bar.switchPanelFrom(root.barIdentity,d):false} function refresh(){nowMs=Date.now();if(!scan.running)scan.running=true} function mark(a){if(!act.running){act.command=[root.helperPath,a];act.running=true}}
 Process { id: scan; command:[root.helperPath,"--scan"]; stdout: StdioCollector { waitForEnd:true; onStreamFinished:{root.rows=Model.parse(text,root.nowMs);root.loaded=true} } }
 Process { id: act; command:[]; onExited:root.refresh() }
 Timer { interval:30000; running:true; repeat:true; triggeredOnStart:true; onTriggered:root.refresh() }
 IpcHandler { target:root.ipcTarget; function open():void{root.openFromHotkey()} function close():void{root.close()} function show():void{root.openFromHotkey()} function hide():void{root.close()} function toggle():void{root.toggle()} function refresh():void{if(root.hostWidget&&typeof root.hostWidget.broadcast==="function")root.hostWidget.broadcast("refresh");else root.refresh()} }
 KeyboardPanel { id:panel; anchorItem:root.anchorItem; owner:root.barIdentity; bar:root.bar; open:root.opened; centerOnBar:true; focusTarget:keys; contentWidth:panel.fittedContentWidth(Style.space(420)); contentHeight:panel.fittedContentHeight(content.implicitHeight)
  PanelKeyCatcher { id:keys; anchors.fill:parent; onCloseRequested:root.close(); onTabRequested:function(d){root.switchPanel(d)}
   Column { id:content; anchors.fill:parent; spacing:Style.space(10)
    PanelHero { title:root.rows.length?"YOUR LAST BOUNDARY":"MAKE A CLEAN BREAK"; meta:"A private local ledger for arriving and leaving context. No calendar access."; foreground:root.bar?root.bar.foreground:Color.foreground; fontFamily:root.bar?root.bar.fontFamily:Style.font.family }
    PanelSeparator { foreground:root.bar?root.bar.foreground:Color.foreground }
    Row { x:Style.space(16); width:parent.width-Style.space(32); spacing:Style.space(24)
     Text { text:"ARRIVE"; textFormat:Text.PlainText; width:Style.space(80); elide:Text.ElideRight; color:root.bar?root.bar.foreground:Color.foreground; font.family:root.bar?root.bar.fontFamily:Style.font.family; MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.mark("--arrive")} }
     Text { text:"LEAVE"; textFormat:Text.PlainText; width:Style.space(80); elide:Text.ElideRight; color:root.bar?root.bar.foreground:Color.foreground; font.family:root.bar?root.bar.fontFamily:Style.font.family; MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.mark("--leave")} }
    }
    Repeater { model:root.rows.slice(-8).reverse(); Item { required property var modelData; width:content.width; height:Style.space(24); Text { anchors.left:parent.left; anchors.leftMargin:Style.space(16); anchors.verticalCenter:parent.verticalCenter; text:modelData.kind.toUpperCase()+"  "+modelData.age; textFormat:Text.PlainText; width:parent.width-Style.space(32); elide:Text.ElideRight; color:root.bar?Qt.darker(root.bar.foreground,1.3):Color.muted; font.family:root.bar?root.bar.fontFamily:Style.font.family; font.pixelSize:Style.font.caption } } }
   }
  }
 }
}
