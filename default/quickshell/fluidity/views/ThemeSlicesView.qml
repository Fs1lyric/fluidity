import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import "ImagePickerModel.js" as ImagePickerModel

// The theme switcher's card: Omarchy's image picker (shell/plugins/image-picker/ImagePicker.qml, MIT License,
// Copyright (c) David Heinemeier Hansson, see OMARCHY-LICENSE), ported with its layout, sizes, skewed slices,
// masks, borders, label, filter and keys unchanged. Only the plumbing differs: this is a pure view (no
// Quickshell types, so render/ can draw it off-screen) fed with rows from `fluidity-theme rows`.
//   rows       "path<TAB>thumbnail" lines; the file name of each path is the theme name
//   selected   path to highlight first (the current theme's row)
// Emits applied(themeName) on Enter / click on the selected slice, canceled() on Escape.
Item {
  id: root

  property string rows: ""
  property string selectedImage: ""
  property bool showLabels: true
  property bool filterable: true
  property bool opened: true
  property color dimColor: "#1e1e2e"
  property color foreground: "#cdd6f4"
  property color selectedBorder: "#cba6f7"
  property color unselectedBorder: Qt.rgba(Qt.color(foreground).r, Qt.color(foreground).g, Qt.color(foreground).b, 0.28)
  property real devicePixelRatio: 1

  signal applied(string name)
  signal canceled()

  property var imageArray: []
  property int selectedIndex: 0
  property string filterText: ""
  property bool layoutSettled: false

  property int expandedWidth: 768
  property int expandedHeight: 475
  property int sliceWidth: 108
  property int sliceHeight: 432
  property int sliceSpacing: -30
  property int skewOffset: 28
  property int bottomChromeHeight: showLabels ? (filterable ? 104 : 74) : (filterable ? 60 : 30)
  // Render only what fits on this display, plus one prefetch slice per side.
  readonly property int previewRadius: Math.max(1, Math.min(16, Math.ceil((width - expandedWidth) / (2 * (sliceWidth + sliceSpacing))) + 1))
  onPreviewRadiusChanged: updateVisibleItems()

  function alpha(c, a) { c = Qt.color(c); return Qt.rgba(c.r, c.g, c.b, a) }
  function fileUrl(path) { return path ? "file://" + String(path).split("/").map(encodeURIComponent).join("/") : "" }
  function editsFilter(event, text) {
    if (!text) return false
    if (event.modifiers & (Qt.AltModifier | Qt.MetaModifier)) return false
    if (event.key === Qt.Key_U) return event.modifiers === Qt.ControlModifier
    return event.key === Qt.Key_Backspace
  }
  function editedFilter(event, text) {
    if (event.key === Qt.Key_U) return ""
    if (event.modifiers & Qt.ControlModifier) return text.replace(/\s+$/, "").replace(/\S+$/, "")
    return text.slice(0, -1)
  }

  function load() {
    var images = ImagePickerModel.loadRows(rows)
    filterText = ""
    selectedIndex = ImagePickerModel.nextSelectedIndexForFilter(images, ImagePickerModel.indexForSelectedImage(images, selectedImage), "")
    imageArray = images
    layoutSettled = false
    revealTimer.restart()
    updateVisibleItems()
    Qt.callLater(function() { carousel.forceActiveFocus() })
  }
  onRowsChanged: load()
  onSelectedImageChanged: load()
  onOpenedChanged: if (opened) load()

  function currentPath() {
    if (imageArray.length === 0 || !itemMatches(selectedIndex)) return ""
    return imageArray[selectedIndex].filePath
  }
  function currentLabel() {
    var path = currentPath()
    if (!path) return filterText ? "No matches" : ""
    return ImagePickerModel.labelForPath(path)
  }
  function itemMatches(index) { return ImagePickerModel.itemMatches(imageArray, index, filterText) }
  function select(index, immediate) {
    if (imageArray.length === 0) return
    if (index < 0) index = 0
    else if (index >= imageArray.length) index = imageArray.length - 1
    if (!itemMatches(index)) return
    if (index === selectedIndex && immediate !== true) return
    selectedIndex = index
  }
  function selectAdjacent(direction) {
    var count = imageArray.length
    if (count === 0) return
    var index = selectedIndex
    for (var i = 0; i < count; i++) {
      index = (index + direction + count) % count
      if (itemMatches(index)) { select(index); return }
    }
  }
  function updateFilter(nextFilterText) {
    filterText = nextFilterText
    if (!itemMatches(selectedIndex)) {
      var first = ImagePickerModel.nextSelectedIndexForFilter(imageArray, selectedIndex, filterText)
      if (first >= 0) selectedIndex = first
    }
  }
  function applySelected() {
    var path = currentPath()
    if (path) root.applied(ImagePickerModel.nameForPath(path))
    else root.canceled()
  }

  readonly property var matchingImageIndices: ImagePickerModel.matchingIndices(imageArray, filterText)
  onMatchingImageIndicesChanged: updateVisibleItems()
  onSelectedIndexChanged: updateVisibleItems()
  function updateVisibleItems() {
    ImagePickerModel.syncWindow(visibleImages, ImagePickerModel.visibleWindow(matchingImageIndices, selectedIndex, previewRadius))
  }
  ListModel { id: visibleImages }

  // The card shows once the selected preview has decoded (or after 400 ms), so it lands in one frame.
  Timer { id: revealTimer; interval: 400; onTriggered: root.layoutSettled = true }

  Item {
    id: card
    visible: root.imageArray.length > 0
    opacity: root.layoutSettled ? 1 : 0
    width: Math.min(parent.width - 80, root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing) + 40)
    height: root.expandedHeight + 30 + root.bottomChromeHeight
    anchors.centerIn: parent

    MouseArea { anchors.fill: parent; enabled: root.layoutSettled; onClicked: {} }

    Item {
      id: carousel
      anchors.top: parent.top
      anchors.topMargin: 30
      anchors.bottom: parent.bottom
      anchors.bottomMargin: root.bottomChromeHeight
      anchors.horizontalCenter: parent.horizontalCenter
      width: root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing)
      clip: false
      focus: true

      readonly property real itemStep: root.sliceWidth + root.sliceSpacing
      readonly property real previewX: (width - root.expandedWidth) / 2

      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) {
        if (!root.layoutSettled) {
          if (event.key === Qt.Key_Escape) { root.canceled(); event.accepted = true }
          return
        }
        if (event.key === Qt.Key_Escape) {
          if (root.filterText) root.updateFilter("")
          else root.canceled()
          event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          root.applySelected()
          event.accepted = true
        } else if (root.filterable && root.editsFilter(event, root.filterText)) {
          root.updateFilter(root.editedFilter(event, root.filterText))
          event.accepted = true
        } else if (event.key === Qt.Key_Left || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab) {
          root.selectAdjacent(-1)
          event.accepted = true
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
          root.selectAdjacent(1)
          event.accepted = true
        } else if (root.filterable && event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127 && (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
          root.updateFilter(root.filterText + event.text)
          event.accepted = true
        }
      }

      Repeater {
        id: imageCards
        model: visibleImages

        delegate: Item {
          id: item
          required property int imageIndex
          required property int relativeIndex

          readonly property var imageData: root.imageArray[imageIndex]
          readonly property string thumbnailPath: imageData ? imageData.thumbnailPath : ""
          readonly property bool selected: imageIndex === root.selectedIndex
          onSelectedChanged: if (selected && (image.status === Image.Ready || image.status === Image.Error)) root.layoutSettled = true

          x: selected ? carousel.previewX : (relativeIndex < 0 ? carousel.previewX + relativeIndex * carousel.itemStep : carousel.previewX + root.expandedWidth + root.sliceSpacing + (relativeIndex - 1) * carousel.itemStep)
          width: selected ? root.expandedWidth : root.sliceWidth
          height: selected ? root.expandedHeight : root.sliceHeight
          y: selected ? 0 : (root.expandedHeight - root.sliceHeight) / 2
          z: selected ? 100 : 50 - Math.min(Math.abs(relativeIndex), 40)

          readonly property real skAbs: Math.abs(root.skewOffset)
          readonly property real topLeft: root.skewOffset >= 0 ? skAbs : 0
          readonly property real topRight: root.skewOffset >= 0 ? width : width - skAbs
          readonly property real bottomRight: root.skewOffset >= 0 ? width - skAbs : width
          readonly property real bottomLeft: root.skewOffset >= 0 ? 0 : skAbs

          Item {
            id: maskShape
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Shape {
              anchors.fill: parent
              antialiasing: true
              preferredRendererType: Shape.CurveRenderer
              ShapePath {
                fillColor: "white"
                strokeColor: "transparent"
                startX: item.topLeft; startY: 0
                PathLine { x: item.topRight; y: 0 }
                PathLine { x: item.bottomRight; y: item.height }
                PathLine { x: item.bottomLeft; y: item.height }
                PathLine { x: item.topLeft; y: 0 }
              }
            }
          }

          Item {
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            layer.effect: MultiEffect {
              maskEnabled: true
              maskSource: maskShape
              maskThresholdMin: 0.3
              maskSpreadAtMin: 0.3
            }

            Rectangle { anchors.fill: parent; color: root.dimColor }

            Image {
              id: image
              anchors.fill: parent
              source: item.thumbnailPath ? root.fileUrl(item.thumbnailPath) : ""
              sourceSize.width: Math.ceil(root.expandedWidth * root.devicePixelRatio)
              sourceSize.height: Math.ceil(root.expandedHeight * root.devicePixelRatio)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              cache: false
              smooth: true
              opacity: status === Image.Ready ? 1 : 0
              onStatusChanged: if (item.selected && (status === Image.Ready || status === Image.Error)) root.layoutSettled = true
            }

            Rectangle {
              anchors.fill: parent
              color: root.alpha(root.dimColor, item.selected ? 0 : 0.42)
            }
          }

          Shape {
            anchors.fill: parent
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
              fillColor: "transparent"
              strokeColor: item.selected ? root.selectedBorder : root.unselectedBorder
              strokeWidth: item.selected ? 3 : 1
              startX: item.topLeft; startY: 0
              PathLine { x: item.topRight; y: 0 }
              PathLine { x: item.bottomRight; y: item.height }
              PathLine { x: item.bottomLeft; y: item.height }
              PathLine { x: item.topLeft; y: 0 }
            }
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.layoutSettled
            cursorShape: Qt.PointingHandCursor
            onClicked: item.selected ? root.applySelected() : root.select(item.imageIndex)
          }
        }
      }
    }

    Text {
      id: selectedLabel
      textFormat: Text.PlainText
      visible: root.showLabels
      anchors.top: carousel.bottom
      anchors.topMargin: 16
      anchors.horizontalCenter: carousel.horizontalCenter
      width: root.expandedWidth
      text: root.currentLabel()
      color: root.foreground
      style: Text.Outline
      styleColor: root.alpha(root.dimColor, 0.7)
      font.family: "monospace"
      font.pixelSize: 24
      font.weight: Font.DemiBold
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
    }

    Text {
      textFormat: Text.PlainText
      visible: root.filterable && root.filterText
      anchors.top: selectedLabel.bottom
      anchors.topMargin: 8
      anchors.horizontalCenter: carousel.horizontalCenter
      width: root.expandedWidth
      text: root.filterText
      color: root.foreground
      opacity: 0.85
      style: Text.Outline
      styleColor: root.alpha(root.dimColor, 0.7)
      font.family: "monospace"
      font.pixelSize: 14
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
    }
  }
}
