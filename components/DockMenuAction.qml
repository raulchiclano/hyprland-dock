import QtQuick
import "DockStyle.js" as DockStyle

Rectangle {
  id: root

  required property string text
  signal triggered()

  implicitWidth: 248
  implicitHeight: 38
  radius: 9
  color: hover.hovered && enabled ? DockStyle.selection : "transparent"
  opacity: enabled ? 1 : 0.55

  Text {
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 12
      right: parent.right
      rightMargin: 12
    }
    text: root.text
    color: DockStyle.text
    font.family: DockStyle.fontFamily
    font.pixelSize: 14
    font.weight: Font.DemiBold
    elide: Text.ElideRight
  }

  HoverHandler {
    id: hover
    enabled: root.enabled
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    enabled: root.enabled
    acceptedButtons: Qt.LeftButton
    onTapped: root.triggered()
  }
}
