import SwiftUI

struct PowerModePopover: View {
    @ObservedObject var powerModeManager = PowerModeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @State private var selectedConfig: PowerModeConfig?

    private let popoverShape = RoundedRectangle(cornerRadius: 12, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Power Mode")
                .font(.headline)
                .foregroundColor(
                    RecorderGlassStyle.primaryContent(
                        usesLiquidGlass: usesLiquidGlassDesign,
                        colorScheme: colorScheme
                    )
                )
                .padding(.horizontal)
                .padding(.top, 8)

            RecorderGlassDivider()

            ScrollView {
                let enabledConfigs = powerModeManager.configurations.filter { $0.isEnabled }
                VStack(alignment: .leading, spacing: 4) {
                    if enabledConfigs.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(
                                    RecorderGlassStyle.secondaryContent(
                                        usesLiquidGlass: usesLiquidGlassDesign,
                                        colorScheme: colorScheme
                                    )
                                )
                                .font(.system(size: 16))
                            Text("No Power Modes Available")
                                .foregroundColor(
                                    RecorderGlassStyle.primaryContent(
                                        usesLiquidGlass: usesLiquidGlassDesign,
                                        colorScheme: colorScheme
                                    )
                                )
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else {
                        ForEach(enabledConfigs) { config in
                            PowerModeRow(
                                config: config,
                                isSelected: selectedConfig?.id == config.id,
                                action: {
                                    powerModeManager.setActiveConfiguration(config)
                                    selectedConfig = config
                                    applySelectedConfiguration()
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 180)
        .frame(maxHeight: 340)
        .padding(.vertical, 8)
        .background { popoverBackground }
        .clipShape(popoverShape)
        .environment(\.colorScheme, usesLiquidGlassDesign ? colorScheme : .dark)
        .onAppear {
            selectedConfig = powerModeManager.activeConfiguration
        }
        .onChange(of: powerModeManager.activeConfiguration) { newValue in
            selectedConfig = newValue
        }
    }

    private func applySelectedConfiguration() {
        Task {
            if let config = selectedConfig {
                await PowerModeSessionManager.shared.beginSession(with: config)
            }
        }
    }

    @ViewBuilder
    private var popoverBackground: some View {
        if usesLiquidGlassDesign {
            RecorderLiquidGlassSurface(shape: popoverShape, role: .popover)
        } else {
            Color.black
        }
    }
}

struct PowerModeRow: View {
    let config: PowerModeConfig
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(config.emoji)
                    .font(.system(size: 14))

                Text(config.name)
                    .foregroundColor(
                        RecorderGlassStyle.primaryContent(
                            usesLiquidGlass: usesLiquidGlassDesign,
                            colorScheme: colorScheme
                        )
                    )
                    .font(.system(size: 13))
                    .lineLimit(1)

                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(
                            RecorderGlassStyle.successContent(
                                usesLiquidGlass: usesLiquidGlassDesign,
                                colorScheme: colorScheme
                            )
                        )
                        .font(.system(size: 10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background { rowBackground }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .onHover { isHovering = $0 }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if usesLiquidGlassDesign {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected || isHovering ? RecorderGlassStyle.selectionFill(colorScheme: colorScheme) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(
                            isSelected
                                ? RecorderGlassStyle.controlStroke(isEnabled: true, colorScheme: colorScheme)
                                : Color.clear,
                            lineWidth: 0.6
                        )
                )
        } else {
            Color.white.opacity(isSelected ? 0.1 : 0)
        }
    }
}
