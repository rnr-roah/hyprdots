import QtQuick

QtObject {
    // Core surfaces
    readonly property color bg: "#101418"
    readonly property color surface: "#101418"
    readonly property color surfaceDim: "#101418"
    readonly property color surfaceBright: "#36393e"

    readonly property color surfaceContainerLowest: "#0b0e12"
    readonly property color surfaceContainerLow: "#191c20"
    readonly property color surfaceContainer: "#1d2024"
    readonly property color surfaceContainerHigh: "#272a2f"
    readonly property color surfaceContainerHighest: "#32353a"

    // Text
    readonly property color fg: "#e0e2e8"
    readonly property color fgVariant: "#c2c7cf"
    readonly property color muted: "#8c9199"
    readonly property color mutedStrong: "#42474e"

    // Accents
    readonly property color primary: "#9ecafc"
    readonly property color primaryFg: "#003256"
    readonly property color primaryContainer: "#144974"
    readonly property color primaryContainerFg: "#d0e4ff"

    readonly property color secondary: "#bac8db"
    readonly property color secondaryFg: "#243140"

    readonly property color tertiary: "#d5bee5"
    readonly property color tertiaryFg: "#3a2a48"

    // Status colors
    readonly property color danger: "#ffb4ab"
    readonly property color dangerFg: "#690005"

    // Handy alpha variants
    readonly property color bgAlpha: "#101418dd"
    readonly property color surfaceAlpha: "#101418dd"
    readonly property color primaryAlpha: "#9ecafcaa"
    readonly property color borderSubtle: "#42474e66"
}
