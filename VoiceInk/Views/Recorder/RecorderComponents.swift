import SwiftUI
import AppKit

// MARK: - Shared Popover State

enum ActivePopoverState {
    case none
    case enhancement
    case power
}

// MARK: - Recorder Visual Style

private struct RecorderUsesLiquidGlassKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var recorderUsesLiquidGlass: Bool {
        get { self[RecorderUsesLiquidGlassKey.self] }
        set { self[RecorderUsesLiquidGlassKey.self] = newValue }
    }
}

enum RecorderGlassStyle {
    enum ContentRole {
        case primary
        case secondary
        case muted
        case disabled
    }

    static func content(_ role: ContentRole, usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else {
            switch role {
            case .primary: return .white
            case .secondary: return .white.opacity(0.6)
            case .muted: return .white.opacity(0.44)
            case .disabled: return .white.opacity(0.3)
            }
        }

        switch (role, colorScheme) {
        case (.primary, .dark): return .white.opacity(0.97)
        case (.secondary, .dark): return .white.opacity(0.76)
        case (.muted, .dark): return .white.opacity(0.54)
        case (.disabled, .dark): return .white.opacity(0.34)
        case (.primary, _): return .black.opacity(0.86)
        case (.secondary, _): return .black.opacity(0.64)
        case (.muted, _): return .black.opacity(0.46)
        case (.disabled, _): return .black.opacity(0.30)
        }
    }

    static func primaryContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        content(.primary, usesLiquidGlass: usesLiquidGlass, colorScheme: colorScheme)
    }

    static func secondaryContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        content(.secondary, usesLiquidGlass: usesLiquidGlass, colorScheme: colorScheme)
    }

    static func mutedContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        content(.muted, usesLiquidGlass: usesLiquidGlass, colorScheme: colorScheme)
    }

    static func disabledContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        content(.disabled, usesLiquidGlass: usesLiquidGlass, colorScheme: colorScheme)
    }

    static func divider(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .white.opacity(0.15) }
        return colorScheme == .dark ? .white.opacity(0.12) : .black.opacity(0.075)
    }

    static func contentShadow(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .clear }
        return colorScheme == .dark ? .black.opacity(0.48) : .white.opacity(0.58)
    }

    static func glassBackground(colorScheme: ColorScheme, reduceTransparency: Bool) -> LinearGradient {
        if reduceTransparency {
            return LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black.opacity(0.82), Color.black.opacity(0.74)]
                    : [Color.white.opacity(0.94), Color.white.opacity(0.86)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.16),
                    Color.black.opacity(0.12),
                    Color.black.opacity(0.34)
                ]
                : [
                    Color.white.opacity(0.42),
                    Color.white.opacity(0.16),
                    Color.black.opacity(0.085)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func adaptiveScrim(colorScheme: ColorScheme, reduceTransparency: Bool) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.black.opacity(reduceTransparency ? 0.20 : 0.08),
                    Color.black.opacity(reduceTransparency ? 0.30 : 0.20),
                    Color.white.opacity(0.04)
                ]
                : [
                    Color.white.opacity(reduceTransparency ? 0.18 : 0.08),
                    Color.clear,
                    Color.black.opacity(reduceTransparency ? 0.10 : 0.07)
                ],
            startPoint: .top,
            endPoint: .bottomTrailing
        )
    }

    static func edgeHighlight(colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.38),
                    Color.white.opacity(0.11),
                    Color.black.opacity(0.36)
                ]
                : [
                    Color.white.opacity(0.78),
                    Color.white.opacity(0.22),
                    Color.black.opacity(0.24)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func innerHighlight(colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.20),
                    Color.white.opacity(0.04),
                    Color.clear
                ]
                : [
                    Color.white.opacity(0.38),
                    Color.white.opacity(0.08),
                    Color.clear
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func outerShadow(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.46) : .black.opacity(0.22)
    }

    static func controlFill(isEnabled: Bool, isPressed: Bool, isHovering: Bool, colorScheme: ColorScheme) -> LinearGradient {
        let activeBoost = isEnabled ? 1.0 : 0.55
        let pressBoost = isPressed ? 1.22 : (isHovering ? 1.10 : 1.0)
        return LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.14 * activeBoost * pressBoost),
                    Color.white.opacity(0.07 * activeBoost),
                    Color.black.opacity(0.18)
                ]
                : [
                    Color.white.opacity(0.46 * activeBoost * pressBoost),
                    Color.white.opacity(0.14 * activeBoost),
                    Color.black.opacity(0.06)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func controlStroke(isEnabled: Bool, colorScheme: ColorScheme) -> Color {
        let opacity = isEnabled ? 1.0 : 0.55
        return colorScheme == .dark
            ? Color.white.opacity(0.20 * opacity)
            : Color.black.opacity(0.12 * opacity)
    }

    static func selectionFill(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.055)
    }

    static func successContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .green }
        return colorScheme == .dark
            ? Color(red: 0.57, green: 0.95, blue: 0.70)
            : Color(red: 0.05, green: 0.45, blue: 0.24)
    }
}

struct RecorderGlassLegibilityLayer<S: Shape>: View {
    let shape: S
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            shape.fill(
                RecorderGlassStyle.glassBackground(
                    colorScheme: colorScheme,
                    reduceTransparency: reduceTransparency
                )
            )
            shape.fill(
                RecorderGlassStyle.adaptiveScrim(
                    colorScheme: colorScheme,
                    reduceTransparency: reduceTransparency
                )
            )
            shape.stroke(RecorderGlassStyle.innerHighlight(colorScheme: colorScheme), lineWidth: 1.2)
            shape.stroke(RecorderGlassStyle.edgeHighlight(colorScheme: colorScheme), lineWidth: 0.75)
        }
        .clipShape(shape)
    }
}

struct RecorderLiquidGlassSurface<S: Shape>: View {
    let shape: S
    let material: NSVisualEffectView.Material

    init(shape: S, material: NSVisualEffectView.Material = .popover) {
        self.shape = shape
        self.material = material
    }

    var body: some View {
        ZStack {
            VisualEffectView(
                material: material,
                blendingMode: .behindWindow
            )
            .clipShape(shape)

            RecorderGlassLegibilityLayer(shape: shape)
        }
        .clipShape(shape)
        .compositingGroup()
    }
}

struct RecorderGlassDivider: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign

    var body: some View {
        Rectangle()
            .fill(
                RecorderGlassStyle.divider(
                    usesLiquidGlass: usesLiquidGlassDesign,
                    colorScheme: colorScheme
                )
            )
            .frame(height: 1)
    }
}

// MARK: - Icon Toggle Button

struct RecorderToggleButton: View {
    let isEnabled: Bool
    let icon: String
    let disabled: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @GestureState private var isPressed = false
    @State private var isHovering = false

    init(isEnabled: Bool, icon: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }

    private var isEmoji: Bool {
        !icon.contains(".") && !icon.contains("-") && icon.unicodeScalars.contains { !$0.isASCII }
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isEmoji {
                    Text(icon).font(.system(size: 14))
                } else {
                    Image(systemName: icon).font(.system(size: 13))
                }
            }
            .foregroundColor(iconColor)
            .frame(width: 22, height: 24)
            .background { buttonBackground }
            .shadow(
                color: RecorderGlassStyle.contentShadow(
                    usesLiquidGlass: usesLiquidGlassDesign,
                    colorScheme: colorScheme
                ),
                radius: usesLiquidGlassDesign ? 0.8 : 0,
                x: 0,
                y: 0.5
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
        )
        .onHover { isHovering = $0 }
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if usesLiquidGlassDesign {
            Circle()
                .fill(
                    RecorderGlassStyle.controlFill(
                        isEnabled: isEnabled,
                        isPressed: isPressed,
                        isHovering: isHovering,
                        colorScheme: colorScheme
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            RecorderGlassStyle.controlStroke(
                                isEnabled: isEnabled,
                                colorScheme: colorScheme
                            ),
                            lineWidth: 0.65
                        )
                )
                .opacity(disabled ? 0.48 : 1)
        }
    }

    private var iconColor: Color {
        if disabled {
            return RecorderGlassStyle.disabledContent(
                usesLiquidGlass: usesLiquidGlassDesign,
                colorScheme: colorScheme
            )
        }

        return isEnabled
            ? RecorderGlassStyle.primaryContent(
                usesLiquidGlass: usesLiquidGlassDesign,
                colorScheme: colorScheme
            )
            : RecorderGlassStyle.secondaryContent(
                usesLiquidGlass: usesLiquidGlassDesign,
                colorScheme: colorScheme
            )
    }
}

// MARK: - Record Button

struct RecorderRecordButton: View {
    let isRecording: Bool
    let isProcessing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(buttonColor)
                    .frame(width: 25, height: 25)

                if isProcessing {
                    ProcessingIndicator(color: .white).frame(width: 16, height: 16)
                } else if isRecording {
                    RoundedRectangle(cornerRadius: 3).fill(Color.white).frame(width: 9, height: 9)
                } else {
                    Circle().fill(Color.white).frame(width: 9, height: 9)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isProcessing)
    }

    private var buttonColor: Color {
        if isProcessing { return Color(red: 0.4, green: 0.4, blue: 0.45) }
        if isRecording  { return .red }
        return Color(red: 0.3, green: 0.3, blue: 0.35)
    }
}

// MARK: - Processing Indicator

struct ProcessingIndicator: View {
    @State private var rotation: Double = 0
    let color: Color

    var body: some View {
        Circle()
            .trim(from: 0.1, to: 0.9)
            .stroke(color, lineWidth: 1.7)
            .frame(width: 14, height: 14)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Progress Dot Animation

struct ProgressAnimation: View {
    let color: Color
    let animationSpeed: Double

    private let dotCount = 5
    private let dotSize: CGFloat = 3
    private let dotSpacing: CGFloat = 2

    @State private var currentDot = 0
    @State private var timer: Timer?

    init(color: Color = .white, animationSpeed: Double = 0.3) {
        self.color = color
        self.animationSpeed = animationSpeed
    }

    var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<dotCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: dotSize / 2)
                    .fill(color.opacity(index <= currentDot ? 0.85 : 0.25))
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .onAppear { startAnimation() }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startAnimation() {
        timer?.invalidate()
        currentDot = 0
        timer = Timer.scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { _ in
            currentDot = (currentDot + 1) % (dotCount + 2)
            if currentDot > dotCount { currentDot = -1 }
        }
    }
}

// MARK: - Enhancement Prompt Button

struct RecorderPromptButton: View {
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @Binding var activePopover: ActivePopoverState
    let buttonSize: CGFloat
    let padding: EdgeInsets

    @State private var isHoveringButton: Bool = false
    @State private var isHoveringPopover: Bool = false
    @State private var dismissWorkItem: DispatchWorkItem?

    init(activePopover: Binding<ActivePopoverState>, buttonSize: CGFloat = 28, padding: EdgeInsets = EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 0)) {
        self._activePopover = activePopover
        self.buttonSize = buttonSize
        self.padding = padding
    }

    var body: some View {
        RecorderToggleButton(
            isEnabled: enhancementService.isEnhancementEnabled,
            icon: enhancementService.activePrompt?.icon ?? enhancementService.allPrompts.first(where: { $0.id == PredefinedPrompts.defaultPromptId })?.icon ?? "checkmark.seal.fill",
            disabled: false
        ) {
            if enhancementService.isEnhancementEnabled {
                activePopover = activePopover == .enhancement ? .none : .enhancement
            } else {
                enhancementService.isEnhancementEnabled = true
            }
        }
        .frame(width: buttonSize)
        .padding(padding)
        .onHover {
            isHoveringButton = $0
            syncPopoverVisibility()
        }
        .popover(isPresented: .constant(activePopover == .enhancement), arrowEdge: .bottom) {
            EnhancementPromptPopover()
                .environmentObject(enhancementService)
                .environment(\.colorScheme, colorScheme)
                .environment(\.recorderUsesLiquidGlass, usesLiquidGlassDesign)
                .onHover {
                    isHoveringPopover = $0
                    syncPopoverVisibility()
                }
        }
    }

    private func syncPopoverVisibility() {
        if isHoveringButton || isHoveringPopover {
            dismissWorkItem?.cancel()
            dismissWorkItem = nil
            activePopover = .enhancement
        } else {
            dismissWorkItem?.cancel()
            let work = DispatchWorkItem { [activePopoverBinding = $activePopover] in
                if activePopoverBinding.wrappedValue == .enhancement {
                    activePopoverBinding.wrappedValue = .none
                }
            }
            dismissWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
        }
    }
}

// MARK: - Power Mode Button

struct RecorderPowerModeButton: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @Binding var activePopover: ActivePopoverState
    let buttonSize: CGFloat
    let padding: EdgeInsets

    @State private var isHoveringButton: Bool = false
    @State private var isHoveringPopover: Bool = false
    @State private var dismissWorkItem: DispatchWorkItem?

    init(activePopover: Binding<ActivePopoverState>, buttonSize: CGFloat = 28, padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7)) {
        self._activePopover = activePopover
        self.buttonSize = buttonSize
        self.padding = padding
    }

    var body: some View {
        RecorderToggleButton(
            isEnabled: !powerModeManager.enabledConfigurations.isEmpty,
            icon: powerModeManager.enabledConfigurations.isEmpty ? "✨" : (powerModeManager.currentActiveConfiguration?.emoji ?? "✨"),
            disabled: powerModeManager.enabledConfigurations.isEmpty
        ) {
            activePopover = activePopover == .power ? .none : .power
        }
        .frame(width: buttonSize)
        .padding(padding)
        .onHover {
            isHoveringButton = $0
            syncPopoverVisibility()
        }
        .popover(isPresented: .constant(activePopover == .power), arrowEdge: .bottom) {
            PowerModePopover()
                .environment(\.colorScheme, colorScheme)
                .environment(\.recorderUsesLiquidGlass, usesLiquidGlassDesign)
                .onHover {
                    isHoveringPopover = $0
                    syncPopoverVisibility()
                }
        }
    }

    private func syncPopoverVisibility() {
        if isHoveringButton || isHoveringPopover {
            dismissWorkItem?.cancel()
            dismissWorkItem = nil
            activePopover = .power
        } else {
            dismissWorkItem?.cancel()
            let work = DispatchWorkItem { [activePopoverBinding = $activePopover] in
                if activePopoverBinding.wrappedValue == .power {
                    activePopoverBinding.wrappedValue = .none
                }
            }
            dismissWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
        }
    }
}

// MARK: - Live Transcript View

struct LiveTranscriptView: View {
    let text: String
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(
                        RecorderGlassStyle.primaryContent(
                            usesLiquidGlass: usesLiquidGlassDesign,
                            colorScheme: colorScheme
                        ).opacity(usesLiquidGlassDesign ? 0.88 : 0.8)
                    )
                    .shadow(
                        color: RecorderGlassStyle.contentShadow(
                            usesLiquidGlass: usesLiquidGlassDesign,
                            colorScheme: colorScheme
                        ),
                        radius: usesLiquidGlassDesign ? 0.8 : 0,
                        x: 0,
                        y: 0.5
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .id("bottom")
            }
            .frame(height: 56)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.18),
                        .init(color: .black, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onChange(of: text) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - Recorder Status Display

struct RecorderStatusDisplay: View {
    let currentState: RecordingState
    let audioMeter: AudioMeter
    let menuBarHeight: CGFloat?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign

    init(currentState: RecordingState, audioMeter: AudioMeter, menuBarHeight: CGFloat? = nil) {
        self.currentState = currentState
        self.audioMeter = audioMeter
        self.menuBarHeight = menuBarHeight
    }

    var body: some View {
        Group {
            if currentState == .enhancing {
                ProcessingStatusDisplay(mode: .enhancing, color: statusColor).transition(.opacity)
            } else if currentState == .transcribing {
                ProcessingStatusDisplay(mode: .transcribing, color: statusColor).transition(.opacity)
            } else if currentState == .recording {
                AudioVisualizer(audioMeter: audioMeter, color: statusColor, isActive: true)
                    .scaleEffect(y: menuBarHeight != nil ? min(1.0, (menuBarHeight! - 8) / 25) : 1.0, anchor: .center)
                    .transition(.opacity)
            } else {
                StaticVisualizer(color: statusColor)
                    .scaleEffect(y: menuBarHeight != nil ? min(1.0, (menuBarHeight! - 8) / 25) : 1.0, anchor: .center)
                    .transition(.opacity)
            }
        }
        .shadow(
            color: RecorderGlassStyle.contentShadow(
                usesLiquidGlass: usesLiquidGlassDesign,
                colorScheme: colorScheme
            ),
            radius: usesLiquidGlassDesign ? 0.9 : 0,
            x: 0,
            y: 0.5
        )
        .animation(.easeInOut(duration: 0.2), value: currentState)
    }

    private var statusColor: Color {
        RecorderGlassStyle.primaryContent(
            usesLiquidGlass: usesLiquidGlassDesign,
            colorScheme: colorScheme
        )
    }
}
