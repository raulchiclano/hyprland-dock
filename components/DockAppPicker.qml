pragma ComponentBehavior: Bound

import QtQuick
import "DockStyle.js" as DockStyle
import Quickshell
import Quickshell.Widgets

PopupWindow {
  id: root

  required property Item anchorItem
  required property string position
  required property var pinned
  signal applicationSelected(string desktopId)

  readonly property var applications: DesktopEntries.applications.values || []
  readonly property var filteredApplications: filterApplications(searchInput.text)

  function open() {
    searchInput.text = ""
    visible = true
    Qt.callLater(() => searchInput.forceActiveFocus())
  }

  function matchScore(value, query) {
    var text = String(value || "").toLowerCase()
    var exactIndex = text.indexOf(query)
    if (exactIndex >= 0)
      return 1000 - exactIndex * 4 - text.length

    var queryIndex = 0
    var previousIndex = -2
    var score = 0
    for (var i = 0; i < text.length && queryIndex < query.length; ++i) {
      if (text[i] !== query[queryIndex]) continue
      score += i === previousIndex + 1 ? 8 : 2
      previousIndex = i
      ++queryIndex
    }
    return queryIndex === query.length ? score - text.length : -1
  }

  function filterApplications(rawQuery) {
    var query = String(rawQuery || "").trim().toLowerCase()
    var matches = []
    var modelRevision = applications.length

    for (var i = 0; i < applications.length; ++i) {
      var application = applications[i]
      if (!application || !application.id || application.noDisplay
          || pinned.indexOf(application.id) >= 0)
        continue

      var score = query
        ? Math.max(matchScore(application.name, query), matchScore(application.id, query))
        : 0
      if (score >= 0)
        matches.push({ application: application, score: score })
    }

    matches.sort((left, right) => right.score - left.score
      || String(left.application.name).localeCompare(String(right.application.name)))
    return matches.slice(0, 100).map(match => match.application)
  }

  function selectCurrent() {
    if (applicationList.currentIndex < 0 || applicationList.currentIndex >= filteredApplications.length)
      return
    var application = filteredApplications[applicationList.currentIndex]
    visible = false
    applicationSelected(application.id)
  }

  implicitWidth: 380
  implicitHeight: 420
  color: "transparent"
  grabFocus: true

  onFilteredApplicationsChanged: applicationList.currentIndex = filteredApplications.length ? 0 : -1

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

    Text {
      id: heading
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.topMargin: 16
      anchors.leftMargin: 16
      text: "Añadir al dock"
      color: DockStyle.text
      font.family: DockStyle.fontFamily
      font.pixelSize: 16
      font.weight: Font.DemiBold
    }

    Rectangle {
      id: searchField

      anchors {
        top: heading.bottom
        left: parent.left
        right: parent.right
        margins: 12
      }
      height: 42
      radius: 9
      color: DockStyle.field
      border.width: 1
      border.color: searchInput.activeFocus
        ? DockStyle.accent
        : DockStyle.border

      Text {
        anchors {
          verticalCenter: parent.verticalCenter
          left: parent.left
          leftMargin: 12
        }
        visible: !searchInput.text
        text: "Buscar aplicaciones…"
        color: DockStyle.muted
        font.family: DockStyle.fontFamily
        font.pixelSize: 14
      }

      TextInput {
        id: searchInput

        anchors {
          fill: parent
          leftMargin: 12
          rightMargin: 12
        }
        verticalAlignment: TextInput.AlignVCenter
        color: DockStyle.text
        selectionColor: DockStyle.selection
        selectedTextColor: DockStyle.text
        font.family: DockStyle.fontFamily
        font.pixelSize: 14
        clip: true

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Down) {
            applicationList.currentIndex = Math.min(applicationList.count - 1, applicationList.currentIndex + 1)
            applicationList.positionViewAtIndex(applicationList.currentIndex, ListView.Contain)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            applicationList.currentIndex = Math.max(0, applicationList.currentIndex - 1)
            applicationList.positionViewAtIndex(applicationList.currentIndex, ListView.Contain)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.selectCurrent()
            event.accepted = true
          } else if (event.key === Qt.Key_Escape) {
            root.visible = false
            event.accepted = true
          }
        }
      }
    }

    ListView {
      id: applicationList

      anchors {
        top: searchField.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: 8
        bottomMargin: 10
        leftMargin: 8
        rightMargin: 8
      }
      clip: true
      spacing: 2
      model: root.filteredApplications

      delegate: Rectangle {
        id: applicationRow

        required property var modelData
        required property int index

        width: applicationList.width
        height: 48
        radius: 9
        color: applicationList.currentIndex === index
          ? DockStyle.selection
          : "transparent"

        IconImage {
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
          }
          width: 30
          height: 30
          source: applicationRow.modelData.icon
            ? Quickshell.iconPath(applicationRow.modelData.icon, true)
            : Quickshell.iconPath("application-x-executable", true)
          // Avoid Qt icon pixmap loading on the background image thread.
          asynchronous: false
        }

        Column {
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: 52
            rightMargin: 10
          }

          Text {
            width: parent.width
            text: applicationRow.modelData.name || applicationRow.modelData.id
            color: DockStyle.text
            font.family: DockStyle.fontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
            elide: Text.ElideRight
          }
        }

        HoverHandler {
          id: rowHover
          cursorShape: Qt.PointingHandCursor
          onHoveredChanged: if (hovered) applicationList.currentIndex = applicationRow.index
        }

        TapHandler {
          onTapped: {
            applicationList.currentIndex = applicationRow.index
            root.selectCurrent()
          }
        }
      }

      Text {
        anchors.centerIn: parent
        visible: applicationList.count === 0
        text: "No hay aplicaciones disponibles"
        color: DockStyle.muted
        font.family: DockStyle.fontFamily
        font.pixelSize: 13
      }
    }
  }
}
