import SwiftUI
import AppKit

@MainActor
class MiniWindowManager: ObservableObject {
    @Published var isVisible = false
    private var windowController: NSWindowController?
    private var panel: MiniRecorderPanel?
    private weak var glassView: NSGlassEffectView?
    private weak var depthView: PillGlassDepthView?
    private weak var edgeHighlightView: PillEdgeHighlightView?
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
                    usesLiquidGlassDesign: usesLiquidGlassDesign,
                    usesExternalGlass: usesLiquidGlassDesign
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
        let usesLiquidGlassDesign = UserDefaults.standard.bool(forKey: "UseLiquidGlassDesign")
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        newPanel.hasShadow = false
        if usesLiquidGlassDesign {
            newPanel.contentView = makeGlassHost(
                contentView: hostingController.view,
                cornerRadius: contentSize.height / 2
            )
        } else {
            newPanel.contentView = hostingController.view
        }

        panel = newPanel
        windowController = NSWindowController(window: newPanel)
    }

    private func deinitializeWindow() {
        panel?.orderOut(nil)
        windowController?.close()
        windowController = nil
        panel = nil
        glassView = nil
        depthView = nil
        edgeHighlightView = nil
    }

    func toggle() {
        isVisible ? hide() : show()
    }

    func updateContentMetrics(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        let nextSize = NSSize(width: width, height: height)
        if contentSize != nextSize {
            contentSize = nextSize
            panel?.updateContentSize(nextSize)
        }

        glassView?.cornerRadius = cornerRadius
        depthView?.cornerRadius = cornerRadius
        edgeHighlightView?.cornerRadius = cornerRadius
    }

    private func makeGlassHost(contentView: NSView, cornerRadius: CGFloat) -> NSView {
        let rootView = NSView()
        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.clear.cgColor
        rootView.layer?.masksToBounds = false
        rootView.layer?.shadowColor = NSColor.black.cgColor
        rootView.layer?.shadowOpacity = 0.26
        rootView.layer?.shadowRadius = 16
        rootView.layer?.shadowOffset = CGSize(width: 0, height: -7)

        let compositorAwakener = NSVisualEffectView()
        compositorAwakener.material = .underWindowBackground
        compositorAwakener.blendingMode = .behindWindow
        compositorAwakener.state = .active
        compositorAwakener.isEmphasized = false
        compositorAwakener.alphaValue = 0.01
        compositorAwakener.translatesAutoresizingMaskIntoConstraints = false
        compositorAwakener.wantsLayer = true
        compositorAwakener.layer?.cornerRadius = cornerRadius
        compositorAwakener.layer?.masksToBounds = true

        let glassView = NSGlassEffectView()
        glassView.style = .clear
        glassView.cornerRadius = cornerRadius
        glassView.tintColor = nil
        glassView.appearance = NSAppearance(named: .darkAqua)
        glassView.translatesAutoresizingMaskIntoConstraints = false

        let glassContentView = NSView()
        glassContentView.translatesAutoresizingMaskIntoConstraints = false
        glassContentView.wantsLayer = true
        glassContentView.layer?.backgroundColor = NSColor.clear.cgColor

        let depthView = PillGlassDepthView(cornerRadius: cornerRadius)
        depthView.translatesAutoresizingMaskIntoConstraints = false

        let edgeHighlightView = PillEdgeHighlightView(cornerRadius: cornerRadius)
        edgeHighlightView.translatesAutoresizingMaskIntoConstraints = false

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor

        rootView.addSubview(compositorAwakener)
        rootView.addSubview(glassView)
        rootView.addSubview(edgeHighlightView)
        glassView.contentView = glassContentView
        glassContentView.addSubview(depthView)
        glassContentView.addSubview(contentView)

        NSLayoutConstraint.activate([
            compositorAwakener.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            compositorAwakener.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            compositorAwakener.topAnchor.constraint(equalTo: rootView.topAnchor),
            compositorAwakener.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),

            glassView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            glassView.topAnchor.constraint(equalTo: rootView.topAnchor),
            glassView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),

            glassContentView.leadingAnchor.constraint(equalTo: glassView.leadingAnchor),
            glassContentView.trailingAnchor.constraint(equalTo: glassView.trailingAnchor),
            glassContentView.topAnchor.constraint(equalTo: glassView.topAnchor),
            glassContentView.bottomAnchor.constraint(equalTo: glassView.bottomAnchor),

            depthView.leadingAnchor.constraint(equalTo: glassContentView.leadingAnchor),
            depthView.trailingAnchor.constraint(equalTo: glassContentView.trailingAnchor),
            depthView.topAnchor.constraint(equalTo: glassContentView.topAnchor),
            depthView.bottomAnchor.constraint(equalTo: glassContentView.bottomAnchor),

            edgeHighlightView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            edgeHighlightView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            edgeHighlightView.topAnchor.constraint(equalTo: rootView.topAnchor),
            edgeHighlightView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: glassContentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: glassContentView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: glassContentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: glassContentView.bottomAnchor)
        ])

        self.glassView = glassView
        self.depthView = depthView
        self.edgeHighlightView = edgeHighlightView
        return rootView
    }
}

private final class PillGlassDepthView: NSView {
    var cornerRadius: CGFloat {
        didSet {
            needsLayout = true
        }
    }

    private let depthLayer = CAGradientLayer()
    private let causticLayer = CAGradientLayer()
    private let depthMask = CAShapeLayer()
    private let causticMask = CAShapeLayer()

    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        cornerRadius = 20
        super.init(coder: coder)
        setupLayers()
    }

    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        depthLayer.frame = bounds
        causticLayer.frame = bounds

        let pathBounds = bounds.insetBy(dx: 0.4, dy: 0.4)
        let radius = max(0, cornerRadius - 0.4)
        let path = CGPath(
            roundedRect: pathBounds,
            cornerWidth: radius,
            cornerHeight: radius,
            transform: nil
        )

        configure(mask: depthMask, with: path)
        configure(mask: causticMask, with: path)

        CATransaction.commit()
    }

    private func setupLayers() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = false

        depthLayer.startPoint = CGPoint(x: 0, y: 0)
        depthLayer.endPoint = CGPoint(x: 1, y: 1)
        depthLayer.locations = [0, 0.34, 0.72, 1]
        depthLayer.colors = [
            NSColor.white.withAlphaComponent(0.16).cgColor,
            NSColor.white.withAlphaComponent(0.02).cgColor,
            NSColor.black.withAlphaComponent(0.09).cgColor,
            NSColor.black.withAlphaComponent(0.21).cgColor
        ]

        causticLayer.type = .radial
        causticLayer.startPoint = CGPoint(x: 0.36, y: 0.20)
        causticLayer.endPoint = CGPoint(x: 0.92, y: 0.92)
        causticLayer.locations = [0, 0.42, 1]
        causticLayer.colors = [
            NSColor.white.withAlphaComponent(0.20).cgColor,
            NSColor.white.withAlphaComponent(0.045).cgColor,
            NSColor.white.withAlphaComponent(0).cgColor
        ]

        depthLayer.mask = depthMask
        causticLayer.mask = causticMask
        layer?.addSublayer(depthLayer)
        layer?.addSublayer(causticLayer)
    }

    private func configure(mask: CAShapeLayer, with path: CGPath) {
        mask.frame = bounds
        mask.path = path
        mask.fillColor = NSColor.white.cgColor
    }
}

private final class PillEdgeHighlightView: NSView {
    var cornerRadius: CGFloat {
        didSet {
            needsLayout = true
        }
    }

    private let topLeftHighlight = CAGradientLayer()
    private let bottomRightHighlight = CAGradientLayer()
    private let topLeftMask = CAShapeLayer()
    private let bottomRightMask = CAShapeLayer()

    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        cornerRadius = 20
        super.init(coder: coder)
        setupLayers()
    }

    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let layerBounds = bounds
        topLeftHighlight.frame = layerBounds
        bottomRightHighlight.frame = layerBounds

        let strokeInset: CGFloat = 0.35
        let pathBounds = layerBounds.insetBy(dx: strokeInset, dy: strokeInset)
        let radius = max(0, cornerRadius - strokeInset)
        let path = CGPath(
            roundedRect: pathBounds,
            cornerWidth: radius,
            cornerHeight: radius,
            transform: nil
        )

        configure(mask: topLeftMask, with: path)
        configure(mask: bottomRightMask, with: path)

        CATransaction.commit()
    }

    private func setupLayers() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = false

        configureTopLeftHighlight()
        configureBottomRightHighlight()

        topLeftHighlight.mask = topLeftMask
        bottomRightHighlight.mask = bottomRightMask

        layer?.addSublayer(topLeftHighlight)
        layer?.addSublayer(bottomRightHighlight)
    }

    private func configureTopLeftHighlight() {
        topLeftHighlight.startPoint = CGPoint(x: 0, y: 0)
        topLeftHighlight.endPoint = CGPoint(x: 1, y: 1)
        topLeftHighlight.locations = [0, 0.28, 0.58, 1]
        topLeftHighlight.colors = [
            NSColor.white.withAlphaComponent(0.82).cgColor,
            NSColor.white.withAlphaComponent(0.34).cgColor,
            NSColor.white.withAlphaComponent(0.06).cgColor,
            NSColor.white.withAlphaComponent(0).cgColor
        ]
    }

    private func configureBottomRightHighlight() {
        bottomRightHighlight.startPoint = CGPoint(x: 1, y: 1)
        bottomRightHighlight.endPoint = CGPoint(x: 0, y: 0)
        bottomRightHighlight.locations = [0, 0.26, 0.56, 1]
        bottomRightHighlight.colors = [
            NSColor.black.withAlphaComponent(0.22).cgColor,
            NSColor.black.withAlphaComponent(0.10).cgColor,
            NSColor.white.withAlphaComponent(0.025).cgColor,
            NSColor.black.withAlphaComponent(0).cgColor
        ]
    }

    private func configure(mask: CAShapeLayer, with path: CGPath) {
        mask.frame = bounds
        mask.path = path
        mask.fillColor = NSColor.clear.cgColor
        mask.strokeColor = NSColor.white.cgColor
        mask.lineWidth = 0.35
        mask.lineJoin = .round
        mask.lineCap = .round
    }
}
