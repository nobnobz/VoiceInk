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
        case .primary: return .white.opacity(1.0)
        case .secondary: return .white.opacity(0.90)
        case .muted: return .white.opacity(0.76)
        case .disabled: return .white.opacity(0.50)
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
        return .white.opacity(0.12)
    }

    static func contentShadow(usesLiquidGlass: Bool, colorScheme _: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .clear }
        return .black.opacity(0.92)
    }

    static func legibilityScrim(colorScheme _: ColorScheme, reduceTransparency: Bool, role: SurfaceRole) -> LinearGradient {
        if reduceTransparency {
            let opacity = role == .recorder ? 0.74 : 0.78
            return LinearGradient(
                colors: [
                    Color.black.opacity(opacity),
                    Color.black.opacity(opacity - 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        let topHighlight = role == .recorder ? 0.055 : 0.045
        let topShade = role == .recorder ? 0.075 : 0.18
        let bottomShade = role == .recorder ? 0.19 : 0.34
        return LinearGradient(
            colors: [
                Color.white.opacity(topHighlight),
                Color.black.opacity(topShade),
                Color.black.opacity(bottomShade)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func specularBloom(colorScheme _: ColorScheme, role: SurfaceRole) -> RadialGradient {
        let opacity: Double = role == .recorder ? 0.12 : 0.08
        return RadialGradient(
            colors: [
                Color.white.opacity(opacity),
                Color.white.opacity(0.02),
                Color.clear
            ],
            center: UnitPoint(x: 0.26, y: 0.10),
            startRadius: 0,
            endRadius: role == .recorder ? 130 : 190
        )
    }

    static func edgeHighlight(colorScheme _: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.70),
                Color.white.opacity(0.24),
                Color.white.opacity(0.05),
                Color.black.opacity(0.13)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func innerHighlight(colorScheme _: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.20),
                Color.white.opacity(0.045),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func outerShadow(colorScheme _: ColorScheme) -> Color {
        .black.opacity(0.24)
    }

    static func controlFill(isEnabled: Bool, isPressed: Bool, isHovering: Bool, colorScheme _: ColorScheme) -> Color {
        guard isHovering || isPressed else { return .clear }
        let baseOpacity = isPressed ? 0.20 : 0.12
        return Color.white.opacity(isEnabled ? baseOpacity : baseOpacity * 0.58)
    }

    static func controlStroke(isEnabled: Bool, colorScheme _: ColorScheme) -> Color {
        Color.white.opacity(isEnabled ? 0.20 : 0.12)
    }

    static func selectionFill(colorScheme _: ColorScheme) -> Color {
        Color.white.opacity(0.12)
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
                RecorderGlassStyle.legibilityScrim(
                    colorScheme: colorScheme,
                    reduceTransparency: reduceTransparency,
                    role: role
                )
            )
            shape.fill(
                RecorderGlassStyle.specularBloom(
                    colorScheme: colorScheme,
                    role: role
                )
            )
            shape.stroke(RecorderGlassStyle.innerHighlight(colorScheme: colorScheme), lineWidth: role == .recorder ? 0.8 : 0.9)
            shape.stroke(RecorderGlassStyle.edgeHighlight(colorScheme: colorScheme), lineWidth: role == .recorder ? 0.55 : 0.65)
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
                GlassEffectContainer(spacing: role == .recorder ? 18 : 28) {
                    Color.clear
                        .glassEffect(.clear, in: shape)
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

struct RecorderIconGlyph: View {
    let icon: String
    var fallbackSystemName: String
    var size: CGFloat = 13
    var weight: Font.Weight = .semibold
    var color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: weight))
            .symbolRenderingMode(.monochrome)
            .foregroundColor(color)
    }

    private var systemName: String {
        let trimmedIcon = icon.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-")
        let scalars = trimmedIcon.unicodeScalars
        guard !scalars.isEmpty, scalars.allSatisfy({ allowed.contains($0) }) else {
            return fallbackSystemName
        }
        return trimmedIcon
    }
}

// MARK: - Icon Toggle Button

struct RecorderToggleButton: View {
    let isEnabled: Bool
    let icon: String
    let fallbackIcon: String
    let disabled: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.recorderUsesLiquidGlass) private var usesLiquidGlassDesign
    @Environment(\.recorderUsesExternalGlass) private var usesExternalGlass
    @GestureState private var isPressed = false
    @State private var isHovering = false

    init(
        isEnabled: Bool,
        icon: String,
        fallbackIcon: String = "sparkles",
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.icon = icon
        self.fallbackIcon = fallbackIcon
        self.disabled = disabled
        self.action = action
    }

    private var isEmoji: Bool {
        !icon.contains(".") && !icon.contains("-") && icon.unicodeScalars.contains { !$0.isASCII }
    }

    var body: some View {
        Button(action: action) {
            Group {
                if usesLiquidGlassDesign {
                    RecorderIconGlyph(
                        icon: icon,
                        fallbackSystemName: fallbackIcon,
                        size: 12.5,
                        weight: .semibold,
                        color: iconColor
                    )
                } else if isEmoji {
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
                radius: usesLiquidGlassDesign ? 1.8 : 0,
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
                .glassEffect(.clear.interactive(), in: Circle())
                .overlay(
                    Circle()
                        .stroke(
                            RecorderGlassStyle.controlStroke(
                                isEnabled: isEnabled,
                                colorScheme: colorScheme
                            ),
                            lineWidth: isHovering || isPressed ? 0.45 : 0
                        )
                )
                .clipShape(Circle())
                .opacity(isHovering || isPressed ? (disabled ? 0.55 : 1) : 0.001)
        }
    }

    private var iconColor: Color {
        if disabled {
            if usesLiquidGlassDesign {
                return RecorderGlassStyle.mutedContent(
                    usesLiquidGlass: usesLiquidGlassDesign,
                    colorScheme: colorScheme
                )
            }

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
            icon: promptButtonIcon,
            fallbackIcon: "wand.and.sparkles",
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

    private var promptButtonIcon: String {
        if usesLiquidGlassDesign {
            return "wand.and.sparkles"
        }

        return enhancementService.activePrompt?.icon
            ?? enhancementService.allPrompts.first(where: { $0.id == PredefinedPrompts.defaultPromptId })?.icon
            ?? "checkmark.seal.fill"
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
            icon: powerButtonIcon,
            fallbackIcon: "bolt.fill",
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

    private var powerButtonIcon: String {
        if usesLiquidGlassDesign {
            return "bolt.fill"
        }

        return powerModeManager.enabledConfigurations.isEmpty
            ? "✨"
            : (powerModeManager.currentActiveConfiguration?.emoji ?? "✨")
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
                        radius: usesLiquidGlassDesign ? 1.8 : 0,
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
            radius: usesLiquidGlassDesign ? 1.8 : 0,
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
