// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import SwiftUI
import Combine

public struct SignatureCaptureView<StartActionView: View, RestartActionView: View, CancelActionView: View, ClearActionView: View, SaveActionView: View> {
    @Environment(\.startActionModifier) private var startActionModifier
	@Environment(\.restartActionModifier) private var restartActionModifier
	@Environment(\.cancelActionModifier) private var cancelActionModifier
	@Environment(\.clearActionModifier) private var clearActionModifier
	@Environment(\.saveActionModifier) private var saveActionModifier

    let _title: String?
	let _mandatoryIndicator: String?
	let _startAction: StartActionView
	let _restartAction: RestartActionView
	let _cancelAction: CancelActionView
	let _clearAction: ClearActionView
	let _saveAction: SaveActionView
	let _signatureImage: UIImage?
	let _onSave: ((UIImage) -> Void)?
	let _onDelete: (() -> Void)?
	var drawingViewBackgroundColor = Color.preferredColor(.primaryBackground)
	@State var isReenterTapped = false
	var indicatorColor = Color.preferredColor(.primaryLabel)
	var hidesSignatureLine = false
	var hidesXmark = false
	@State var isEditing = false
	var isRequired = false
	var strokeWidth: CGFloat = 3.0
	var watermarkTextFont: UIFont = .preferredFont(forTextStyle: .caption1)
	@State var isSaved = false
	var addsTimestampInImage: Bool = false
	var appliesTintColorToImage = true
	var titleColor = Color.preferredColor(.primaryLabel)
	var xmarkColor = Color.preferredColor(.quaternaryLabel)
	let _drawingViewMinHeight: CGFloat = 256
	var signatureLineColor = Color.preferredColor(.quaternaryLabel)
	var indicatorFont = Font.fiori(forTextStyle: .subheadline).weight(.semibold)
	@State var fullSignatureImage: UIImage?
	var watermarkText: String?
	var watermarkTextAlignment: NSTextAlignment = .natural
	var cropsImage = false
	var titleFont = Font.fiori(forTextStyle: .subheadline).weight(.semibold)
	public private(set) var _heightDidChangePublisher = CurrentValueSubject<CGFloat, Never>(0)
	@State var currentDrawing = Drawing()
	@State var drawings = [Drawing]()
	var _drawingViewMaxHeight: CGFloat?
	var timestampFormatter: DateFormatter?
	var watermarkTextColor: Color = .preferredColor(.tertiaryLabel)
	var strokeColor = Color.preferredColor(.primaryLabel)

    private var isModelInit: Bool = false
	private var isTitleNil: Bool = false
	private var isMandatoryIndicatorNil: Bool = false
	private var isStartActionNil: Bool = false
	private var isRestartActionNil: Bool = false
	private var isCancelActionNil: Bool = false
	private var isClearActionNil: Bool = false
	private var isSaveActionNil: Bool = false
	private var isSignatureImageNil: Bool = false
	private var isOnSaveNil: Bool = false
	private var isOnDeleteNil: Bool = false

    public init(
        title: String? = nil,
		mandatoryIndicator: String? = "*",
		@ViewBuilder startAction: () -> StartActionView,
		@ViewBuilder restartAction: () -> RestartActionView,
		@ViewBuilder cancelAction: () -> CancelActionView,
		@ViewBuilder clearAction: () -> ClearActionView,
		@ViewBuilder saveAction: () -> SaveActionView,
		signatureImage: UIImage? = nil,
		onSave: ((UIImage) -> Void)? = nil,
		onDelete: (() -> Void)? = nil
        ) {
            self._title = title
			self._mandatoryIndicator = mandatoryIndicator
			self._startAction = startAction()
			self._restartAction = restartAction()
			self._cancelAction = cancelAction()
			self._clearAction = clearAction()
			self._saveAction = saveAction()
			self._signatureImage = signatureImage
			self._onSave = onSave
			self._onDelete = onDelete
    }

    @ViewBuilder var startAction: some View {
        if isModelInit {
            _startAction.modifier(startActionModifier.concat(Fiori.SignatureCaptureView.startAction).concat(Fiori.SignatureCaptureView.startActionCumulative))
        } else {
            _startAction.modifier(startActionModifier.concat(Fiori.SignatureCaptureView.startAction))
        }
    }
	@ViewBuilder var restartAction: some View {
        if isModelInit {
            _restartAction.modifier(restartActionModifier.concat(Fiori.SignatureCaptureView.restartAction).concat(Fiori.SignatureCaptureView.restartActionCumulative))
        } else {
            _restartAction.modifier(restartActionModifier.concat(Fiori.SignatureCaptureView.restartAction))
        }
    }
	@ViewBuilder var cancelAction: some View {
        if isModelInit {
            _cancelAction.modifier(cancelActionModifier.concat(Fiori.SignatureCaptureView.cancelAction).concat(Fiori.SignatureCaptureView.cancelActionCumulative))
        } else {
            _cancelAction.modifier(cancelActionModifier.concat(Fiori.SignatureCaptureView.cancelAction))
        }
    }
	@ViewBuilder var clearAction: some View {
        if isModelInit {
            _clearAction.modifier(clearActionModifier.concat(Fiori.SignatureCaptureView.clearAction).concat(Fiori.SignatureCaptureView.clearActionCumulative))
        } else {
            _clearAction.modifier(clearActionModifier.concat(Fiori.SignatureCaptureView.clearAction))
        }
    }
	@ViewBuilder var saveAction: some View {
        if isModelInit {
            _saveAction.modifier(saveActionModifier.concat(Fiori.SignatureCaptureView.saveAction).concat(Fiori.SignatureCaptureView.saveActionCumulative))
        } else {
            _saveAction.modifier(saveActionModifier.concat(Fiori.SignatureCaptureView.saveAction))
        }
    }
    
	var isStartActionEmptyView: Bool {
        ((isModelInit && isStartActionNil) || StartActionView.self == EmptyView.self) ? true : false
    }

	var isRestartActionEmptyView: Bool {
        ((isModelInit && isRestartActionNil) || RestartActionView.self == EmptyView.self) ? true : false
    }

	var isCancelActionEmptyView: Bool {
        ((isModelInit && isCancelActionNil) || CancelActionView.self == EmptyView.self) ? true : false
    }

	var isClearActionEmptyView: Bool {
        ((isModelInit && isClearActionNil) || ClearActionView.self == EmptyView.self) ? true : false
    }

	var isSaveActionEmptyView: Bool {
        ((isModelInit && isSaveActionNil) || SaveActionView.self == EmptyView.self) ? true : false
    }
}

extension SignatureCaptureView where StartActionView == _ConditionalContent<_Action, EmptyView>,
		RestartActionView == _ConditionalContent<_Action, EmptyView>,
		CancelActionView == _ConditionalContent<_Action, EmptyView>,
		ClearActionView == _ConditionalContent<_Action, EmptyView>,
		SaveActionView == _ConditionalContent<_Action, EmptyView> {

    public init(model: SignatureCaptureViewModel) {
        self.init(title: model.title, mandatoryIndicator: model.mandatoryIndicator, startAction: model.startAction != nil ? _Action(model: model.startAction!) : nil, restartAction: model.restartAction != nil ? _Action(model: model.restartAction!) : nil, cancelAction: model.cancelAction != nil ? _Action(model: model.cancelAction!) : nil, clearAction: model.clearAction != nil ? _Action(model: model.clearAction!) : nil, saveAction: model.saveAction != nil ? _Action(model: model.saveAction!) : nil, signatureImage: model.signatureImage, onSave: model.onSave, onDelete: model.onDelete)
    }

    public init(title: String? = nil, mandatoryIndicator: String? = "*", startAction: _Action? = _Action(model: _TapToSignActionDefault()), restartAction: _Action? = _Action(model: _ReEnterSignatureActionDefault()), cancelAction: _Action? = _Action(model: _CancelActionDefault()), clearAction: _Action? = _Action(model: _ClearActionDefault()), saveAction: _Action? = _Action(model: _SaveActionDefault()), signatureImage: UIImage? = nil, onSave: ((UIImage) -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self._title = title
		self._mandatoryIndicator = mandatoryIndicator
		self._startAction = startAction != nil ? ViewBuilder.buildEither(first: startAction!) : ViewBuilder.buildEither(second: EmptyView())
		self._restartAction = restartAction != nil ? ViewBuilder.buildEither(first: restartAction!) : ViewBuilder.buildEither(second: EmptyView())
		self._cancelAction = cancelAction != nil ? ViewBuilder.buildEither(first: cancelAction!) : ViewBuilder.buildEither(second: EmptyView())
		self._clearAction = clearAction != nil ? ViewBuilder.buildEither(first: clearAction!) : ViewBuilder.buildEither(second: EmptyView())
		self._saveAction = saveAction != nil ? ViewBuilder.buildEither(first: saveAction!) : ViewBuilder.buildEither(second: EmptyView())
		self._signatureImage = signatureImage
		self._onSave = onSave
		self._onDelete = onDelete

		isModelInit = true
		isTitleNil = title == nil ? true : false
		isMandatoryIndicatorNil = mandatoryIndicator == nil ? true : false
		isStartActionNil = startAction == nil ? true : false
		isRestartActionNil = restartAction == nil ? true : false
		isCancelActionNil = cancelAction == nil ? true : false
		isClearActionNil = clearAction == nil ? true : false
		isSaveActionNil = saveAction == nil ? true : false
		isSignatureImageNil = signatureImage == nil ? true : false
		isOnSaveNil = onSave == nil ? true : false
		isOnDeleteNil = onDelete == nil ? true : false
    }
}
