pragma ComponentBehavior: Bound

import QtQuick
import "DockStyle.js" as DockStyle

Item {
  id: root
  required property string status
  property bool vertical: false
  readonly property int dotCount: status === "multiple" ? 2
    : status === "local" || status === "remote" ? 1 : 0
  implicitWidth: vertical ? 4 : 14
  implicitHeight: vertical ? 14 : 4
  opacity: status === "remote" ? 0.4 : 1
  Behavior on opacity { NumberAnimation { duration: 120 } }

  Rectangle {
    anchors.centerIn: parent
    width: root.vertical ? 3 : 14
    height: root.vertical ? 14 : 3
    radius: 1.5
    color: "#D4C6FF"
    opacity: root.status === "active" ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
  }

  Repeater {
    model: root.dotCount
    Rectangle {
      required property int index
      width: 4
      height: 4
      radius: 2
      x: root.vertical ? 0 : (root.width - (root.dotCount * 7 - 3)) / 2 + index * 7
      y: root.vertical ? (root.height - (root.dotCount * 7 - 3)) / 2 + index * 7 : 0
      color: DockStyle.accent
    }
  }
}
