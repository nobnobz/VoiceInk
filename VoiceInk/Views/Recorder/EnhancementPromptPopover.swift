import SwiftUI

// Enhancement Prompt Popover for recorder views
struct EnhancementPromptPopover: View {
    @EnvironmentObject var enhancementService: AIEnhancementService
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @State private var selectedPrompt: CustomPrompt?

    private let popoverShape = RoundedRectangle(cornerRadius: 12, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Enhancement Toggle at the top
            HStack(spacing: 8) {
                Toggle("AI Enhancement", isOn: $enhancementService.isEnhancementEnabled)
                    .foregroundColor(
                        RecorderGlassStyle.primaryContent(
                            usesLiquidGlass: usesLiquidGlassDesign,
                            colorScheme: colorScheme
                        )
                    )
                    .font(.headline)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)

            RecorderGlassDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    // Available Enhancement Prompts
                    ForEach(enhancementService.allPrompts) { prompt in
                        EnhancementPromptRow(
                            prompt: prompt,
                            isSelected: selectedPrompt?.id == prompt.id,
                            isDisabled: !enhancementService.isEnhancementEnabled,
                            action: {
                                // If enhancement is disabled, enable it first
                                if !enhancementService.isEnhancementEnabled {
                                    enhancementService.isEnhancementEnabled = true
                                }
                                enhancementService.setActivePrompt(prompt)
                                selectedPrompt = prompt
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 200)
        .frame(maxHeight: 340)
        .padding(.vertical, 8)
        .background { popoverBackground }
        .clipShape(popoverShape)
        .shadow(
            color: usesLiquidGlassDesign
                ? RecorderGlassStyle.outerShadow(colorScheme: colorScheme)
                : .clear,
            radius: 22,
            x: 0,
            y: 12
        )
        .environment(\.colorScheme, usesLiquidGlassDesign ? colorScheme : .dark)
        .onAppear {
            // Set the initially selected prompt
            selectedPrompt = enhancementService.activePrompt
        }
        .onChange(of: enhancementService.selectedPromptId) { oldValue, newValue in
            selectedPrompt = enhancementService.activePrompt
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

// Row view for each enhancement prompt in the popover
struct EnhancementPromptRow: View {
    let prompt: CustomPrompt
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Use the icon from the prompt
                Image(systemName: prompt.icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)

                Text(prompt.title)
                    .foregroundColor(titleColor)
                    .font(.system(size: 13))
                    .lineLimit(1)

                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(
                            isDisabled
                                ? RecorderGlassStyle.successContent(
                                    usesLiquidGlass: usesLiquidGlassDesign,
                                    colorScheme: colorScheme
                                ).opacity(0.55)
                                : RecorderGlassStyle.successContent(
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

    private var titleColor: Color {
        if isDisabled {
            return RecorderGlassStyle.disabledContent(
                usesLiquidGlass: usesLiquidGlassDesign,
                colorScheme: colorScheme
            )
        }

        return RecorderGlassStyle.primaryContent(
            usesLiquidGlass: usesLiquidGlassDesign,
            colorScheme: colorScheme
        )
    }

    private var iconColor: Color {
        if isDisabled {
            return RecorderGlassStyle.disabledContent(
                usesLiquidGlass: usesLiquidGlassDesign,
                colorScheme: colorScheme
            )
        }

        return RecorderGlassStyle.secondaryContent(
            usesLiquidGlass: usesLiquidGlassDesign,
            colorScheme: colorScheme
        )
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
