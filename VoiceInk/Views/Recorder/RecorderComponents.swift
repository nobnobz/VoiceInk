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

private struct RecorderUsesExternalGlassKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var recorderUsesLiquidGlass: Bool {
        get { self[RecorderUsesLiquidGlassKey.self] }
        set { self[RecorderUsesLiquidGlassKey.self] = newValue }
    }

    var recorderUsesExternalGlass: Bool {
        get { self[RecorderUsesExternalGlassKey.self] }
        set { self[RecorderUsesExternalGlassKey.self] = newValue }
    }
}

enum RecorderGlassStyle {
    enum SurfaceRole {
        case recorder
        case popover
    }

    enum ContentRole {
        case primary
        case secondary
        case muted
        case disabled
    }

    static func content(_ role: ContentRole, usesLiquidGlass: Bool, colorScheme _: ColorScheme) -> Color {
        guard usesLiquidGlass else {
            switch role {
            case .primary: return .white
            case .secondary: return .white.opacity(0.6)
            case .muted: return .white.opacity(0.44)
            case .disabled: return .white.opacity(0.3)
            }
        }

        switch role {
        case .primary: return .white.opacity(0.99)
        case .secondary: return .white.opacity(0.86)
        case .muted: return .white.opacity(0.70)
        case .disabled: return .white.opacity(0.44)
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

    static func divider(usesLiquidGlass: Bool, colorScheme _: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .white.opacity(0.15) }
        return .white.opacity(0.14)
    }

    static func contentShadow(usesLiquidGlass: Bool, colorScheme _: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .clear }
        return .black.opacity(0.96)
    }

    static func nativeGlassDepth(colorScheme _: ColorScheme, role: SurfaceRole) -> LinearGradient {
        let topSheen: Double
        let midShade: Double
        let lowerShade: Double
        let rimShade: Double

        switch role {
        case .recorder:
            topSheen = 0.16
            midShade = 0.00
            lowerShade = 0.09
            rimShade = 0.21
        case .popover:
            topSheen = 0.12
            midShade = 0.05
            lowerShade = 0.18
            rimShade = 0.30
        }

        return LinearGradient(
            colors: [
                Color.white.opacity(topSheen),
                Color.black.opacity(midShade),
                Color.black.opacity(lowerShade),
                Color.black.opacity(rimShade)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func nativeGlassCaustic(colorScheme _: ColorScheme, role: SurfaceRole) -> RadialGradient {
        let opacity: Double = role == .recorder ? 0.20 : 0.14
        return RadialGradient(
            colors: [
                Color.white.opacity(opacity),
                Color.white.opacity(role == .recorder ? 0.045 : 0.035),
                Color.clear
            ],
            center: UnitPoint(x: 0.34, y: 0.20),
            startRadius: 0,
            endRadius: role == .recorder ? 118 : 170
        )
    }

    static func glassBackground(
        colorScheme _: ColorScheme,
        reduceTransparency: Bool,
        role: SurfaceRole
    ) -> LinearGradient {
        if reduceTransparency {
            let opacity = switch role {
            case .recorder: 0.78
            case .popover: 0.74
            }

            return LinearGradient(
                colors: [
                    Color.black.opacity(opacity),
                    Color.black.opacity(max(0.48, opacity - 0.08))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        let topSheen: Double
        let centerSheen: Double
        let lowerShade: Double
        let rimShade: Double

        switch role {
        case .recorder:
            topSheen = 0.040
            centerSheen = 0.000
            lowerShade = 0.060
            rimShade = 0.140
        case .popover:
            topSheen = 0.050
            centerSheen = 0.000
            lowerShade = 0.150
            rimShade = 0.260
        }

        return LinearGradient(
            colors: [
                Color.white.opacity(topSheen),
                Color.white.opacity(centerSheen),
                Color.black.opacity(lowerShade),
                Color.black.opacity(rimShade)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func adaptiveScrim(
        colorScheme _: ColorScheme,
        reduceTransparency: Bool,
        role: SurfaceRole
    ) -> LinearGradient {
        let topShade: Double
        let bottomShade: Double

        switch role {
        case .recorder:
            topShade = 0.020
            bottomShade = 0.150
        case .popover:
            topShade = 0.060
            bottomShade = 0.260
        }

        return LinearGradient(
            colors: [
                Color.black.opacity(reduceTransparency ? 0.18 : topShade),
                Color.clear,
                Color.black.opacity(reduceTransparency ? 0.24 : bottomShade)
            ],
            startPoint: .top,
            endPoint: .bottomTrailing
        )
    }

    static func edgeHighlight(colorScheme _: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.86),
                Color.white.opacity(0.34),
                Color.white.opacity(0.06),
                Color.black.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func innerHighlight(colorScheme _: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.24),
                Color.white.opacity(0.055),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func outerShadow(colorScheme _: ColorScheme) -> Color {
        .black.opacity(0.30)
    }

    static func controlFill(isEnabled: Bool, isPressed: Bool, isHovering: Bool, colorScheme _: ColorScheme) -> LinearGradient {
        let activeBoost = isEnabled ? 1.0 : 0.55
        let pressBoost = isPressed ? 1.22 : (isHovering ? 1.10 : 1.0)
        return LinearGradient(
            colors: [
                Color.white.opacity(0.28 * activeBoost * pressBoost),
                Color.white.opacity(0.055 * activeBoost),
                Color.black.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func controlStroke(isEnabled: Bool, colorScheme _: ColorScheme) -> Color {
        let opacity = isEnabled ? 1.0 : 0.55
        return Color.white.opacity(0.70 * opacity)
    }

    static func selectionFill(colorScheme _: ColorScheme) -> Color {
        Color.white.opacity(0.14)
    }

    static func successContent(usesLiquidGlass: Bool, colorScheme _: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .green }
        return Color(red: 0.58, green: 0.96, blue: 0.72)
    }
}

struct RecorderGlassLegibilityLayer<S: Shape>: View {
    let shape: S
    var role: RecorderGlassStyle.SurfaceRole = .recorder
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            shape.fill(
                RecorderGlassStyle.nativeGlassDepth(
                    colorScheme: colorScheme,
                    role: role
                )
            )
            shape.fill(
                RecorderGlassStyle.nativeGlassCaustic(
                    colorScheme: colorScheme,
                    role: role
                )
            )
            shape.fill(
                RecorderGlassStyle.glassBackground(
                    colorScheme: colorScheme,
                    reduceTransparency: reduceTransparency,
                    role: role
                )
            )
            shape.fill(
                RecorderGlassStyle.adaptiveScrim(
                    colorScheme: colorScheme,
                    reduceTransparency: reduceTransparency,
                    role: role
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
    var role: RecorderGlassStyle.SurfaceRole
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    init(shape: S, role: RecorderGlassStyle.SurfaceRole = .recorder) {
        self.shape = shape
        self.role = role
    }

    var body: some View {
        ZStack {
            if reduceTransparency {
                shape.fill(Color.black.opacity(0.74))
            } else {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    .clipShape(shape)
                    .opacity(role == .popover ? 0.30 : 0.12)

                GlassEffectContainer {
                    Color.clear
                        .glassEffect(.regular, in: shape)
                }
            }

            RecorderGlassLegibilityLayer(shape: shape, role: role)
        }
        .clipShape(shape)
        .compositingGroup()
    }
}

struct RecorderGlassDivider: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @Environment(\.recorderUsesExternalGlass) private var usesExternalGlass

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
    @Environment(\.recorderUsesExternalGlass) private var usesExternalGlass
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
                radius: usesLiquidGlassDesign ? 1.25 : 0,
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
            ZStack {
                GlassEffectContainer {
                    Color.clear
                        .glassEffect(.regular.interactive(), in: Circle())
                }

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
            }
            .clipShape(Circle())
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
                        radius: usesLiquidGlassDesign ? 1.35 : 0,
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
            radius: usesLiquidGlassDesign ? 1.35 : 0,
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
