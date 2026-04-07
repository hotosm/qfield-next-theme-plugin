import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import org.qfield
import org.qgis
import Theme

Item {
  id: plugin

  // ── Internal state ──
  property var mainWindow: iface.mainWindow()
  property var layerTree: iface.findItemByObjectName("layerTree")

  // ── Settings (global defaults) ──
  Settings {
    id: settings
    category: "themetoggle"
    property string themeA: "Satellite"
    property string themeB: "OpenStreetMap"
  }

  // ── Theme resolution: project variable → global setting → hardcoded ──
  function themeA() {
    var vars = ExpressionContextUtils.projectVariables(qgisProject)
    if (vars["theme_toggle_theme_a"])
      return vars["theme_toggle_theme_a"]
    return settings.themeA
  }

  function themeB() {
    var vars = ExpressionContextUtils.projectVariables(qgisProject)
    if (vars["theme_toggle_theme_b"])
      return vars["theme_toggle_theme_b"]
    return settings.themeB
  }

  // ── Auto-detect themes on project load ──
  function autoDetectThemes() {
    if (!layerTree)
      return

    // Respect existing project variables
    var vars = ExpressionContextUtils.projectVariables(qgisProject)
    if (vars["theme_toggle_theme_a"] && vars["theme_toggle_theme_b"])
      return

    var themes = layerTree.mapThemeCollection
    if (!themes)
      return

    var names = themes.mapThemes()
    if (names.length === 2) {
      projectInfo.saveVariable("theme_toggle_theme_a", names[0])
      projectInfo.saveVariable("theme_toggle_theme_b", names[1])
      mainWindow.displayToast(qsTr("Theme Toggle: auto-configured '%1' / '%2'").arg(names[0]).arg(names[1]))
    }
  }

  // ── Toggle logic ──
  function toggleTheme() {
    if (!layerTree) {
      mainWindow.displayToast(qsTr("Theme Toggle: layer tree not available"))
      return
    }

    var a = themeA()
    var b = themeB()
    var current = layerTree.mapTheme
    var next = (current === a) ? b : a
    layerTree.setMapTheme(next)
    mainWindow.displayToast(next)
  }

  // ── Toolbar button ──
  QfToolButton {
    id: toggleBtn
    round: true
    iconSource: Qt.resolvedUrl("basemap.svg")
    iconColor: "#4CAF50"
    bgcolor: "#FFFFFF"
    onClicked: plugin.toggleTheme()
  }

  Component.onCompleted: {
    iface.addItemToPluginsToolbar(toggleBtn)
    autoDetectThemes()
  }

  // ── Configure dialog (called by QField plugin manager) ──
  function configure() {
    configDialog.open()
  }

  QfDialog {
    id: configDialog
    parent: mainWindow.contentItem
    width: Math.min(mainWindow.width - 40, 320)
    x: (mainWindow.width - width) / 2
    y: (mainWindow.height - height) / 2
    title: qsTr("Theme Toggle Settings")

    property var availableThemes: []

    onAboutToShow: {
      // Populate available themes
      if (layerTree && layerTree.mapThemeCollection) {
        availableThemes = layerTree.mapThemeCollection.mapThemes()
      } else {
        availableThemes = []
      }

      // Set current selections
      var a = plugin.themeA()
      var b = plugin.themeB()
      comboA.currentIndex = Math.max(0, availableThemes.indexOf(a))
      comboB.currentIndex = Math.max(0, availableThemes.indexOf(b))
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 10
      spacing: 12

      Label {
        text: qsTr("Select which two map themes to toggle between.")
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font: Theme.defaultFont
        color: Theme.mainTextColor
      }

      Label {
        text: qsTr("Theme A")
        font: Theme.defaultFont
        color: Theme.mainTextColor
      }
      ComboBox {
        id: comboA
        Layout.fillWidth: true
        model: configDialog.availableThemes
        font: Theme.defaultFont
      }

      Label {
        text: qsTr("Theme B")
        font: Theme.defaultFont
        color: Theme.mainTextColor
      }
      ComboBox {
        id: comboB
        Layout.fillWidth: true
        model: configDialog.availableThemes
        font: Theme.defaultFont
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Item { Layout.fillWidth: true }

        QfButton {
          text: qsTr("Cancel")
          onClicked: configDialog.close()
        }

        QfButton {
          text: qsTr("Save")
          enabled: comboA.currentIndex !== comboB.currentIndex
          onClicked: {
            var a = configDialog.availableThemes[comboA.currentIndex]
            var b = configDialog.availableThemes[comboB.currentIndex]
            projectInfo.saveVariable("theme_toggle_theme_a", a)
            projectInfo.saveVariable("theme_toggle_theme_b", b)
            settings.themeA = a
            settings.themeB = b
            mainWindow.displayToast(qsTr("Theme Toggle: saved '%1' / '%2'").arg(a).arg(b))
            configDialog.close()
          }
        }
      }

      // Warning when fewer than 2 themes
      Label {
        visible: configDialog.availableThemes.length < 2
        text: qsTr("This project has fewer than 2 map themes. Create map themes in QGIS before using this plugin.")
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font: Theme.tipFont
        color: "#FF5722"
      }
    }
  }
}
