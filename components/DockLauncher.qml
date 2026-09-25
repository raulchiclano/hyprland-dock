import QtQuick
import Quickshell
import Quickshell.Io
import "DockStyle.js" as DockStyle

Item {
  id: root

  required property int slotSize
  required property int iconSize
  required property string position
  required property bool vertical

  width: vertical ? slotSize + 6 : slotSize
  height: vertical ? slotSize : slotSize + 6
  Accessible.role: Accessible.Button
  Accessible.name: "Aplicaciones"
  Accessible.onPressAction: root.activate()

  function activate() {
    if (!launchProcess.running) launchProcess.running = true
  }

  Process {
    id: launchProcess
    command: ["omarchy", "menu", "toggle", "apps"]
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) console.warn("Dock: could not open the Omarchy applications menu:", exitCode)
    }
  }

  Item {
    id: iconContainer
    x: root.vertical
      ? root.position === "left" ? 6 : root.width - root.iconSize - 6
      : (root.width - root.iconSize) / 2
    y: root.vertical
      ? (root.height - root.iconSize) / 2
      : root.position === "top" ? 6 : root.height - root.iconSize - 6
    width: root.iconSize
    height: root.iconSize
    // The Applications button keeps a fixed size on hover.

    Rectangle {
      anchors.fill: parent
      anchors.margins: -4
      radius: 14
      color: mouse.hovered ? Qt.rgba(1, 1, 1, 0.10) : "transparent"

      Behavior on color { ColorAnimation { duration: 100 } }
    }


    // Vector dots stay crisp at every icon size and need no icon-theme font.
    Grid {
      anchors.centerIn: parent
      columns: 3
      spacing: root.iconSize * 0.14
      Repeater {
        model: 9
        Rectangle {
          width: root.iconSize * 0.14
          height: width
          radius: width / 2
          color: mouse.hovered ? "#D4C6FF" : DockStyle.accent
          Behavior on color { ColorAnimation { duration: 100 } }
        }
      }
    }
  }

  PopupWindow {
    id: tooltip

    visible: mouse.hovered && !launchProcess.running
    implicitWidth: Math.min(420, Math.ceil(tooltipMetrics.advanceWidth) + 20,
      anchor.window ? anchor.window.screen.width - 24 : 420)
    implicitHeight: tooltipText.implicitHeight + 10
    TextMetrics {
      id: tooltipMetrics
      text: "Aplicaciones"
      font: tooltipText.font
    }
    color: "transparent"
    grabFocus: false
    anchor {
      window: root.QsWindow.window
      edges: Edges.Top | Edges.Left
      gravity: Edges.Bottom | Edges.Right
      adjustment: PopupAdjustment.Slide
      rect.width: 1
      rect.height: 1
      onAnchoring: {
        if (!tooltip.anchor.window) return
        var x = (root.width - tooltip.implicitWidth) / 2
        var y = root.position === "top" ? root.height + 8 : -tooltip.implicitHeight - 8
        if (root.position === "left" || root.position === "right") {
          x = root.position === "left" ? root.width + 8 : -tooltip.implicitWidth - 8
          y = (root.height - tooltip.implicitHeight) / 2
        }
        var point = tooltip.anchor.window.contentItem.mapFromItem(root, x, y)
        tooltip.anchor.rect.x = Math.round(point.x)
        tooltip.anchor.rect.y = Math.round(point.y)
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: 8
      color: DockStyle.panel
      border.width: 1
      border.color: DockStyle.border
      Text {
        id: tooltipText
        anchors.centerIn: parent
        width: parent.width - 18
        text: "Aplicaciones"
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: DockStyle.text
        font.family: DockStyle.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
      }
    }
  }

  HoverHandler {
    id: mouse
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: root.activate()
  }
}
