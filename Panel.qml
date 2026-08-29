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
    PanelHero { title:root.rows.length?"YOUR LAST BOUNDARY":"MAKE A CLEAN BREAK"; meta:"Private. Local. Enter with intent. Leave it clean."; foreground:root.bar?root.bar.foreground:Color.foreground; fontFamily:root.bar?root.bar.fontFamily:Style.font.family }
    PanelSeparator { foreground:root.bar?root.bar.foreground:Color.foreground }
    Row { x:Style.space(16); width:parent.width-Style.space(32); spacing:Style.space(10)
     Rectangle {
      width:(parent.width-parent.spacing)/2; height:Style.space(54); radius:Style.space(5)
      color:Qt.hsla(Model.kindHue("arrive"),0.48,0.50,0.13); border.color:Qt.hsla(Model.kindHue("arrive"),0.55,0.62,0.72)
      Accessible.role:Accessible.Button; Accessible.name:"Mark context arrival"
      Text { anchors.centerIn:parent; text:"ARRIVE  +"; textFormat:Text.PlainText; color:Qt.hsla(Model.kindHue("arrive"),0.58,0.68,1); font.family:root.bar?root.bar.fontFamily:Style.font.family; font.bold:true; font.letterSpacing:1 }
      MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.mark("--arrive")}
     }
     Rectangle {
      width:(parent.width-parent.spacing)/2; height:Style.space(54); radius:Style.space(5)
      color:Qt.hsla(Model.kindHue("leave"),0.48,0.50,0.13); border.color:Qt.hsla(Model.kindHue("leave"),0.55,0.62,0.72)
      Accessible.role:Accessible.Button; Accessible.name:"Mark context departure"
      Text { anchors.centerIn:parent; text:"LEAVE  -"; textFormat:Text.PlainText; color:Qt.hsla(Model.kindHue("leave"),0.58,0.68,1); font.family:root.bar?root.bar.fontFamily:Style.font.family; font.bold:true; font.letterSpacing:1 }
      MouseArea{anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.mark("--leave")}
     }
    }
    Repeater { model:root.rows.slice(-8).reverse(); Item { required property var modelData; width:content.width; height:Style.space(34); readonly property real eventHue:Model.kindHue(modelData.kind)
      Rectangle { anchors.fill:parent; anchors.leftMargin:Style.space(16); anchors.rightMargin:Style.space(16); radius:Style.space(4); color:Qt.hsla(parent.eventHue,0.42,0.50,0.07) }
      Rectangle { anchors.left:parent.left; anchors.leftMargin:Style.space(16); anchors.verticalCenter:parent.verticalCenter; width:Style.space(3); height:parent.height-Style.space(8); radius:width/2; color:Qt.hsla(parent.eventHue,0.56,0.66,1) }
      Text { anchors.left:parent.left; anchors.leftMargin:Style.space(28); anchors.verticalCenter:parent.verticalCenter; text:Model.kindLabel(modelData.kind); textFormat:Text.PlainText; width:parent.width-Style.space(130); elide:Text.ElideRight; color:Qt.hsla(parent.eventHue,0.50,0.72,1); font.family:root.bar?root.bar.fontFamily:Style.font.family; font.pixelSize:Style.font.caption; font.bold:true }
      Text { anchors.right:parent.right; anchors.rightMargin:Style.space(26); anchors.verticalCenter:parent.verticalCenter; text:modelData.age; textFormat:Text.PlainText; width:Style.space(64); horizontalAlignment:Text.AlignRight; elide:Text.ElideRight; color:root.bar?Qt.darker(root.bar.foreground,1.2):Color.muted; font.family:root.bar?root.bar.fontFamily:Style.font.family; font.pixelSize:Style.font.caption }
    } }
   }
  }
 }
}
