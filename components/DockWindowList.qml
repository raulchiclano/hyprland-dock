pragma ComponentBehavior: Bound

import QtQuick
import "DockStyle.js" as DockStyle
import "WindowPolicy.js" as WindowPolicy

Item {
  id: root

  required property var selection
  required property string applicationName
  property real maximumHeight: 420
  readonly property var rows: WindowPolicy.windowRows(selection)
  signal backRequested()
  signal windowChosen(string address)
  implicitHeight: Math.min(maximumHeight, heading.height + (rows.length ? rows.reduce((sum, row) => sum + (row.header ? 32 : 72), 0) : 70))

  function choose(index) {
    var row = rows[index]
    if (row && !row.header) windowChosen(row.address)
  }

  function step(direction) {
    if (!rows.length) return
    var index = windows.currentIndex
    if (index < 0 && direction < 0) index = 0
    for (var count = 0; count < rows.length; ++count) {
      index = (index + direction + rows.length) % rows.length
      if (!rows[index].header) {
        windows.currentIndex = index
        windows.positionViewAtIndex(index, ListView.Contain)
        return index
      }
    }
    return -1
  }

  onRowsChanged: windows.currentIndex = -1
  onVisibleChanged: if (visible) windows.forceActiveFocus()

  Column {
    id: heading
    width: parent.width
    spacing: 8
    DockMenuAction {
      width: parent.width
      text: "‹  Volver"
      onTriggered: root.backRequested()
    }
    Text {
      width: parent.width - 24
      x: 12
      height: implicitHeight + 10
      text: root.applicationName
      textFormat: Text.PlainText
      color: DockStyle.text
      font.family: DockStyle.fontFamily
      font.pixelSize: 16
      font.weight: Font.DemiBold
      elide: Text.ElideRight
    }
  }

  ListView {
    id: windows
    anchors { top: heading.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
    clip: true
    model: root.rows
    currentIndex: -1
    boundsBehavior: Flickable.StopAtBounds
    keyNavigationEnabled: false
    Keys.enabled: root.visible
    Keys.onPressed: event => {
      if (event.key === Qt.Key_Down) root.step(1)
      else if (event.key === Qt.Key_Up) root.step(-1)
      else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.choose(currentIndex)
      else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) root.backRequested()
      else return
      event.accepted = true
    }

    delegate: Item {
      id: row
      required property var modelData
      required property int index
      width: ListView.view.width - 7
      height: modelData.header ? 32 : 72
      Text {
        visible: row.modelData.header
        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
        text: row.modelData.header ? row.modelData.title : ""
        color: DockStyle.muted
        font.family: DockStyle.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
      }
      Rectangle {
        visible: !row.modelData.header
        anchors.fill: parent
        anchors.bottomMargin: 3
        radius: 9
        color: hover.hovered || windows.currentIndex === row.index ? DockStyle.selection : "transparent"
        Rectangle {
          visible: row.modelData.active === true
          x: 10
          y: 20
          width: 5
          height: 5
          radius: 2.5
          color: DockStyle.accent
        }
        Column {
          x: 23
          y: 8
          width: parent.width - 35
          spacing: 4
          Text {
            width: parent.width
            text: row.modelData.header ? "" : row.modelData.title
            textFormat: Text.PlainText
            color: DockStyle.text
            font.family: DockStyle.fontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
          }
          Text {
            width: parent.width
            text: row.modelData.header ? "" : row.modelData.subtitle
            textFormat: Text.PlainText
            color: DockStyle.muted
            font.family: DockStyle.fontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
          }
        }
        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler {
          acceptedButtons: Qt.LeftButton
          onTapped: root.choose(row.index)
        }
      }
    }

    Text {
      visible: root.rows.length === 0
      anchors.centerIn: parent
      text: "No quedan ventanas abiertas."
      color: DockStyle.muted
      font.family: DockStyle.fontFamily
      font.pixelSize: 13
    }
  }

  Rectangle {
    visible: windows.contentHeight > windows.height
    anchors.right: parent.right
    width: 3
    radius: 1.5
    height: Math.max(24, windows.height * windows.height / Math.max(1, windows.contentHeight))
    y: heading.height + (windows.height - height)
      * Math.max(0, Math.min(1, windows.contentY / Math.max(1, windows.contentHeight - windows.height)))
    color: DockStyle.accent
    opacity: 0.55
  }
}
