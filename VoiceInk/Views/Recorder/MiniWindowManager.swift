import SwiftUI
import AppKit

@MainActor
class MiniWindowManager: ObservableObject {
    @Published var isVisible = false
    private var windowController: NSWindowController?
    private var panel: MiniRecorderPanel?
    private var contentSize = NSSize(width: 184, height: 40)

    private let makeView: (MiniWindowManager) -> AnyView

    init(engine: VoiceInkEngine, recorder: Recorder) {
        guard let enhancementService = engine.enhancementService else {
            preconditionFailure("VoiceInkEngine.enhancementService must be non-nil when creating MiniWindowManager")
        }
        self.makeView = { manager in
            let usesLiquidGlassDesign = UserDefaults.standard.bool(forKey: "UseLiquidGlassDesign")

            return AnyView(
                MiniRecorderView(
                    stateProvider: engine,
                    recorder: recorder,
                    usesLiquidGlassDesign: usesLiquidGlassDesign
                )
                    .environmentObject(manager)
                    .environmentObject(enhancementService)
            )
        }
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHideNotification),
            name: NSNotification.Name("HideMiniRecorder"),
            object: nil
        )
    }

    @objc private func handleHideNotification() {
        hide()
    }

    func show() {
        if isVisible { return }
        if panel == nil { initializeWindow() }
        isVisible = true
        panel?.show(contentSize: contentSize)
    }

    func hide() {
        guard isVisible else { return }
        isVisible = false
        panel?.orderOut(nil)
    }

    func destroyWindow() {
        isVisible = false
        deinitializeWindow()
    }

    private func initializeWindow() {
        deinitializeWindow()
        let metrics = MiniRecorderPanel.calculateWindowMetrics(contentSize: contentSize)
        let newPanel = MiniRecorderPanel(contentRect: metrics)
        let view = makeView(self)
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        newPanel.hasShadow = false
        newPanel.contentView = hostingController.view

        panel = newPanel
        windowController = NSWindowController(window: newPanel)
    }

    private func deinitializeWindow() {
        panel?.orderOut(nil)
        windowController?.close()
        windowController = nil
        panel = nil
    }

    func toggle() {
        isVisible ? hide() : show()
    }

    func updateContentMetrics(width: CGFloat, height: CGFloat, cornerRadius _: CGFloat) {
        let nextSize = NSSize(width: width, height: height)
        if contentSize != nextSize {
            contentSize = nextSize
            panel?.updateContentSize(nextSize)
        }
    }
}
