import QtQuick

QtObject {
    // Core surfaces
    readonly property color bg: "{{ colors.background.default.hex }}"
    readonly property color surface: "{{ colors.surface.default.hex }}"
    readonly property color surfaceDim: "{{ colors.surface_dim.default.hex }}"
    readonly property color surfaceBright: "{{ colors.surface_bright.default.hex }}"

    readonly property color surfaceContainerLowest: "{{ colors.surface_container_lowest.default.hex }}"
    readonly property color surfaceContainerLow: "{{ colors.surface_container_low.default.hex }}"
    readonly property color surfaceContainer: "{{ colors.surface_container.default.hex }}"
    readonly property color surfaceContainerHigh: "{{ colors.surface_container_high.default.hex }}"
    readonly property color surfaceContainerHighest: "{{ colors.surface_container_highest.default.hex }}"

    // Text
    readonly property color fg: "{{ colors.on_surface.default.hex }}"
    readonly property color fgVariant: "{{ colors.on_surface_variant.default.hex }}"
    readonly property color muted: "{{ colors.outline.default.hex }}"
    readonly property color mutedStrong: "{{ colors.outline_variant.default.hex }}"

    // Accents
    readonly property color primary: "{{ colors.primary.default.hex }}"
    readonly property color primaryFg: "{{ colors.on_primary.default.hex }}"
    readonly property color primaryContainer: "{{ colors.primary_container.default.hex }}"
    readonly property color primaryContainerFg: "{{ colors.on_primary_container.default.hex }}"

    readonly property color secondary: "{{ colors.secondary.default.hex }}"
    readonly property color secondaryFg: "{{ colors.on_secondary.default.hex }}"

    readonly property color tertiary: "{{ colors.tertiary.default.hex }}"
    readonly property color tertiaryFg: "{{ colors.on_tertiary.default.hex }}"

    // Status colors
    readonly property color danger: "{{ colors.error.default.hex }}"
    readonly property color dangerFg: "{{ colors.on_error.default.hex }}"

    // Handy alpha variants
    readonly property color bgAlpha: "{{ colors.background.default.hex }}dd"
    readonly property color surfaceAlpha: "{{ colors.surface.default.hex }}dd"
    readonly property color primaryAlpha: "{{ colors.primary.default.hex }}aa"
    readonly property color borderSubtle: "{{ colors.outline_variant.default.hex }}66"
}
