import QtQuick

QtObject {
    // Core surfaces
    readonly property color bg: "#171217"
    readonly property color surface: "#171217"
    readonly property color surfaceDim: "#171217"
    readonly property color surfaceBright: "#3d373d"

    readonly property color surfaceContainerLowest: "#110d11"
    readonly property color surfaceContainerLow: "#1f1a1f"
    readonly property color surfaceContainer: "#231e23"
    readonly property color surfaceContainerHigh: "#2e282d"
    readonly property color surfaceContainerHighest: "#393338"

    // Text
    readonly property color fg: "#eadfe7"
    readonly property color fgVariant: "#cfc3cd"
    readonly property color muted: "#988d97"
    readonly property color mutedStrong: "#4d444c"

    // Accents
    readonly property color primary: "#e9b5ee"
    readonly property color primaryFg: "#48214f"
    readonly property color primaryContainer: "#603767"
    readonly property color primaryContainerFg: "#fed6ff"

    readonly property color secondary: "#d7bfd5"
    readonly property color secondaryFg: "#3b2b3c"

    readonly property color tertiary: "#f5b8af"
    readonly property color tertiaryFg: "#4c2520"

    // Status colors
    readonly property color danger: "#ffb4ab"
    readonly property color dangerFg: "#690005"

    // Handy alpha variants
    readonly property color bgAlpha: "#171217dd"
    readonly property color surfaceAlpha: "#171217dd"
    readonly property color primaryAlpha: "#e9b5eeaa"
    readonly property color borderSubtle: "#4d444c66"
}
