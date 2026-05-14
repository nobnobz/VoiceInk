import SwiftUI
import AppKit

struct MiniRecorderView<S: RecorderStateProvider & ObservableObject>: View {
    @ObservedObject var stateProvider: S
    @ObservedObject var recorder: Recorder
    let usesLiquidGlassDesign: Bool
    let usesExternalGlass: Bool
    @EnvironmentObject var windowManager: MiniWindowManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("showLiveTextPreview") private var showLiveTextPreview = false

    @State private var activePopover: ActivePopoverState = .none

    init(
        stateProvider: S,
        recorder: Recorder,
        usesLiquidGlassDesign: Bool = true,
        usesExternalGlass: Bool = false
    ) {
        self.stateProvider = stateProvider
        self.recorder = recorder
        self.usesLiquidGlassDesign = usesLiquidGlassDesign
        self.usesExternalGlass = usesExternalGlass
    }

    // MARK: - Layout Constants

    private let controlBarHeight: CGFloat = 40
    private let compactWidth: CGFloat = 184
    private let expandedWidth: CGFloat = 300
    private let compactCornerRadius: CGFloat = 20
    private let expandedCornerRadius: CGFloat = 14

    private var pillWidth: CGFloat {
        hasLiveTranscript ? expandedWidth : compactWidth
    }

    private var pillHeight: CGFloat {
        controlBarHeight + (hasLiveTranscript ? 57 : 0)
    }

    private var pillCornerRadius: CGFloat {
        hasLiveTranscript ? expandedCornerRadius : compactCornerRadius
    }

    private var pillShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: pillCornerRadius, style: .continuous)
    }

    // true when live transcript is streaming in during recording
    private var hasLiveTranscript: Bool {
        showLiveTextPreview
            && stateProvider.recordingState == .recording
            && !stateProvider.partialTranscript.isEmpty
    }

    private var controlBar: some View {
        HStack(spacing: 0) {
            RecorderPromptButton(
                activePopover: $activePopover,
                buttonSize: 22,
                padding: EdgeInsets()
            )
            .padding(.leading, 12)

            Spacer(minLength: 0)

            RecorderStatusDisplay(
                currentState: stateProvider.recordingState,
                audioMeter: recorder.audioMeter
            )

            Spacer(minLength: 0)

            RecorderPowerModeButton(
                activePopover: $activePopover,
                buttonSize: 22,
                padding: EdgeInsets()
            )
            .padding(.trailing, 12)
        }
        .frame(height: controlBarHeight)
    }

    private var transcriptSection: some View {
        VStack(spacing: 0) {
            if hasLiveTranscript {
                LiveTranscriptView(text: stateProvider.partialTranscript)
                RecorderGlassDivider()
            }
        }
    }

    var body: some View {
        if windowManager.isVisible {
            pill
                .animation(.easeInOut(duration: 0.3), value: hasLiveTranscript)
                .onAppear(perform: syncWindowMetrics)
                .onChange(of: hasLiveTranscript) {
                    syncWindowMetrics()
                }
        }
    }

    private var pillContent: some View {
        VStack(spacing: 0) {
            transcriptSection
            controlBar
        }
        .frame(width: pillWidth, height: pillHeight)
        .environment(\.recorderUsesLiquidGlass, usesLiquidGlassDesign)
        .environment(\.recorderUsesExternalGlass, usesExternalGlass)
    }

    @ViewBuilder
    private var pill: some View {
        if usesLiquidGlassDesign {
            if usesExternalGlass {
                pillContent
            } else {
                pillContent
                    .background {
                        RecorderLiquidGlassSurface(shape: pillShape)
                    }
                    .clipShape(pillShape)
                    .shadow(
                        color: RecorderGlassStyle.outerShadow(colorScheme: colorScheme),
                        radius: hasLiveTranscript ? 24 : 18,
                        x: 0,
                        y: hasLiveTranscript ? 10 : 7
                    )
            }
        } else {
            pillContent
                .background(Color.black)
                .clipShape(pillShape)
        }
    }

    private func syncWindowMetrics() {
        windowManager.updateContentMetrics(
            width: pillWidth,
            height: pillHeight,
            cornerRadius: pillCornerRadius
        )
    }
}
