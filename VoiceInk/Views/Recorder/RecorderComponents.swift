import SwiftUI

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
    static func primaryContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .white }
        return colorScheme == .dark ? .white.opacity(0.94) : .black.opacity(0.78)
    }

    static func secondaryContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .white.opacity(0.6) }
        return colorScheme == .dark ? .white.opacity(0.68) : .black.opacity(0.56)
    }

    static func disabledContent(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .white.opacity(0.3) }
        return colorScheme == .dark ? .white.opacity(0.34) : .black.opacity(0.30)
    }

    static func divider(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .white.opacity(0.15) }
        return colorScheme == .dark ? .white.opacity(0.14) : .black.opacity(0.10)
    }

    static func contentShadow(usesLiquidGlass: Bool, colorScheme: ColorScheme) -> Color {
        guard usesLiquidGlass else { return .clear }
        return colorScheme == .dark ? .black.opacity(0.35) : .white.opacity(0.60)
    }

    static func glassFill(colorScheme: ColorScheme, reduceTransparency: Bool) -> LinearGradient {
        if reduceTransparency {
            return LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.black.opacity(0.78), Color.black.opacity(0.70)]
                    : [Color.white.opacity(0.92), Color.white.opacity(0.84)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.10),
                    Color.black.opacity(0.24),
                    Color.black.opacity(0.40)
                ]
                : [
                    Color.white.opacity(0.54),
                    Color.white.opacity(0.34),
                    Color.black.opacity(0.08)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func glassSheen(colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.13),
                    Color.white.opacity(0.03),
                    Color.clear
                ]
                : [
                    Color.white.opacity(0.38),
                    Color.white.opacity(0.10),
                    Color.clear
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func glassStroke(colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.28),
                    Color.white.opacity(0.08),
                    Color.black.opacity(0.26)
                ]
                : [
                    Color.white.opacity(0.72),
                    Color.white.opacity(0.20),
                    Color.black.opacity(0.18)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct RecorderGlassLegibilityLayer<S: Shape>: View {
    let shape: S
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            shape.fill(
                RecorderGlassStyle.glassFill(
                    colorScheme: colorScheme,
                    reduceTransparency: reduceTransparency
                )
            )
            shape.fill(RecorderGlassStyle.glassSheen(colorScheme: colorScheme))
            shape.stroke(RecorderGlassStyle.glassStroke(colorScheme: colorScheme), lineWidth: 0.7)
        }
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
