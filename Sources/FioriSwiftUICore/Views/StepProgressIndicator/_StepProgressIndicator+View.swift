import FioriThemeManager
import SwiftUI

extension Fiori {
    enum _StepProgressIndicator {
        typealias Title = EmptyModifier
        typealias TitleCumulative = EmptyModifier
        typealias Action = EmptyModifier
        typealias ActionCumulative = EmptyModifier
        typealias CancelAction = EmptyModifier
        typealias CancelActionCumulative = EmptyModifier
        static let title = Title()
        static let action = Action()
        static let cancelAction = CancelAction()
        static let titleCumulative = TitleCumulative()
        static let actionCumulative = ActionCumulative()
        static let cancelActionCumulative = CancelActionCumulative()
    }
}

extension _StepProgressIndicator: View {
    var stepsCount: Int {
        steps.count
    }
    
    var stepsSpacing: CGFloat {
        2
    }
    
    /// :nodoc:
    public var body: some View {
        switch axis {
        case .horizontal:
            VStack(spacing: 0) {
                self.stepsHeader
                self.stepsContainer
            }
        case .vertical:
            self.stepsContainer
        }
    }
    
    @ViewBuilder var stepsContainer: some View {
        switch axis {
        case .horizontal:
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    StepProgressIndicatorContainer(selection: _selection,
                                                   steps: steps)
                        .environment(\.stepFrames, $stepFrames)
                        .setOnChange(of: _selection.wrappedValue, action1: { newValue in
                            if let currentFrame = stepFrames[newValue],
                               !scrollBounds.contains(currentFrame)
                            {
                                withAnimation {
                                    proxy.scrollTo(newValue, anchor: .leading)
                                }
                            }
                        }) { _, newValue in
                            if let currentFrame = stepFrames[newValue],
                               !scrollBounds.contains(currentFrame)
                            {
                                withAnimation {
                                    proxy.scrollTo(newValue, anchor: .leading)
                                }
                            }
                        }
                }
            }
            .coordinateSpace(name: "SPICoordinateSpace")
            .frameReader(in: .local) { rect in
                scrollBounds = rect
            }
        case .vertical:
            ScrollViewReader { _ in
                ScrollView(.vertical, showsIndicators: false) {
                    StepProgressIndicatorContainer(selection: _selection,
                                                   steps: steps)
                }.padding(20)
            }
        }
    }
    
    @ViewBuilder var stepsHeader: some View {
        if isActionEmptyView, isTitleEmptyView {
            EmptyView()
        } else {
            HStack(alignment: .center) {
                title
                    .font(.fiori(forTextStyle: .headline, weight: .semibold))
                Spacer()
                action
                    .onSimultaneousTapGesture(perform: {
                        self.isPresented.toggle()
                    })
            }
            .frame(minHeight: 44)
            .sheet(isPresented: $isPresented) {
                self.verticalSteps
            }
        }
    }
    
    var verticalSteps: some View {
        var newSelf = self
        newSelf.axis = .vertical
        return NavigationView {
            newSelf.stepAxis(.vertical)
                .navigationTitle(NSLocalizedString("All Steps", comment: ""))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelAction.onSimultaneousTapGesture {
                            isPresented.toggle()
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
        }
    }
}

/// :nodoc:
public extension _StepProgressIndicator where Steps == _DefaultSteps, CancelActionView == _Action {
    /// Convenience initializer for default step progress indicator.
    /// - Parameters:
    ///   - selection: A binding string for selected step id.
    ///   - stepItems: An array of `StepItem` for default steps generation.
    ///   - title: Title for current step displayed on the top leading side of the step progress indicator.
    ///   - action: Action for steps displayed on the top trailing side of the step progress indicator. It will show vertical steps.
    init(selection: Binding<String>,
         stepItems: [StepItem],
         @ViewBuilder title: @escaping () -> Title,
         @ViewBuilder action: @escaping () -> ActionView)
    {
        self._selection = selection
        self.stepItems = stepItems
        self._title = title()
        self._action = action()
        self._cancelAction = _Action(model: _CancelActionDefault())
        
        self._steps = _DefaultSteps(stepItems: stepItems,
                                    selection: selection)
    }
    
    /// Convenience initializer for default step progress indicator.
    /// - Parameters:
    ///   - selection: A binding string for selected step id.
    ///   - stepItems: An array of `StepItem` for default steps generation.
    ///   - title: Title for current step displayed on the top leading side of the step progress indicator.
    init(selection: Binding<String>,
         stepItems: [StepItem],
         @ViewBuilder title: @escaping () -> Title) where ActionView == EmptyView
    {
        self.init(selection: selection,
                  stepItems: stepItems,
                  title: title,
                  action: { EmptyView() })
    }
    
    /// Convenience initializer for default step progress indicator.
    /// - Parameters:
    ///   - selection: A binding string for selected step id.
    ///   - stepItems: An array of `StepItem` for default steps generation.
    ///   - action: Action for steps displayed on the top trailing side of the step progress indicator. It will show vertical steps.
    init(selection: Binding<String>,
         stepItems: [StepItem],
         @ViewBuilder action: @escaping () -> ActionView) where Title == EmptyView
    {
        self.init(selection: selection,
                  stepItems: stepItems,
                  title: { EmptyView() },
                  action: action)
    }
    
    /// Convenience initializer for default step progress indicator.
    /// - Parameters:
    ///   - selection: A binding string for selected step id.
    ///   - stepItems: An array of `StepItem` for default steps generation.
    init(selection: Binding<String>,
         stepItems: [StepItem]) where Title == EmptyView, ActionView == EmptyView
    {
        self.init(selection: selection,
                  stepItems: stepItems,
                  title: { EmptyView() },
                  action: { EmptyView() })
    }
}
