import QtQuick
import "DockStyle.js" as DockStyle
import Quickshell

PopupWindow {
  id: root

  required property Item anchorItem
  required property string position
  required property bool canClose
  required property bool autoHide
  signal openNewWindow()
  signal closeWindow()
  signal addApplication()
  signal removeFromDock()
  signal toggleAutoHide()

  function open() {
    visible = true
  }

  implicitWidth: 268
  implicitHeight: menuColumn.implicitHeight + 20
  color: "transparent"
  grabFocus: true

  anchor {
    window: root.anchorItem ? root.anchorItem.QsWindow.window : null
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: {
      if (!root.anchorItem || !root.anchor.window) return

      var x = root.anchorItem.width / 2 - root.implicitWidth / 2
      var y = root.anchorItem.height + 8
      if (root.position === "bottom")
        y = -root.implicitHeight - 8
      else if (root.position === "left") {
        x = root.anchorItem.width + 8
        y = root.anchorItem.height / 2 - root.implicitHeight / 2
      } else if (root.position === "right") {
        x = -root.implicitWidth - 8
        y = root.anchorItem.height / 2 - root.implicitHeight / 2
      }

      // The compositor slides the popup at screen edges; the dock is much smaller than the screen.
      var point = root.anchor.window.contentItem.mapFromItem(root.anchorItem, x, y)
      root.anchor.rect.x = Math.round(point.x)
      root.anchor.rect.y = Math.round(point.y)
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: DockStyle.radius
    color: DockStyle.panel
    border.width: 1
    border.color: DockStyle.border

    Column {
      id: menuColumn
      anchors.centerIn: parent
      width: parent.width - 20
      spacing: 2

      DockMenuAction {
        width: menuColumn.width
        text: "Añadir aplicación…"
        onTriggered: {
          root.visible = false
          root.addApplication()
        }
      }

      DockMenuAction {
        width: menuColumn.width
        text: "Desfijar del dock"
        onTriggered: {
          root.visible = false
          root.removeFromDock()
        }
      }

      DockMenuAction {
        width: menuColumn.width
        text: root.autoHide ? "Mantener siempre visible" : "Activar ocultación automática"
        onTriggered: {
          root.toggleAutoHide()
          root.visible = false
        }
      }

      Item {
        width: menuColumn.width
        height: 10

        Rectangle {
          anchors.centerIn: parent
          width: parent.width - 20
          height: 1
          color: DockStyle.separator
        }
      }

      DockMenuAction {
        width: menuColumn.width
        text: "Abrir aplicación"
        onTriggered: {
          root.visible = false
          root.openNewWindow()
        }
      }

      DockMenuAction {
        width: menuColumn.width
        text: "Cerrar ventana"
        enabled: root.canClose
        onTriggered: {
          root.visible = false
          root.closeWindow()
        }
      }
    }
  }
}
