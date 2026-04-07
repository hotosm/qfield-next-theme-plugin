# QField Theme Toggle Plugin

QField app-wide plugin for toggling between two map themes.

To install the latest version in QField, choose to **Install plugin from URL** with the following:

`https://github.com/hotosm/qfield-toggle-theme-plugin/releases/latest/download/qfield-toggle-theme-plugin.zip`

## Rationale

- Initially, a user wanted a plugin to easily toggle base layers
  between OSM & Satellite.
- While it's possible to toggle layers & map themes easily in the sidebar,
  then wanted a simple one-click button in the UI to do this.
- Instead of developing a flaky baselayer switcher (as layers can vary so
  much per project), I decided to use the already existing Theme
  API for QField.
- Baselayers can be configured in Themes (Satellite & OpenStreetMap),
  then easily toggled using this new button.
