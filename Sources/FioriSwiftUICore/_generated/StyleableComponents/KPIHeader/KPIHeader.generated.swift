// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import SwiftUI

/// `KPIHeader` is used to display KPIItem and KPIProgressItem.
///  The maximum number of items that can be displayed in the header is 4. If more than 4 items are provided, then only first 4 items are displayed and the rest will be ignored.
///  If the item is KPIProgressItem and the value of its property `chartSize` is `.small`, it will not be displayed, too.
/// ## Usage
/// ```swift
/// var data: [KPIHeaderItemModel] = [
///     KPIItem(kpiCaption: "small", items: [KPISubItemModelImpl(kPISubItemValue: .text("123"), kPISubItemType: .metric)], proposedViewSize: .small, alignment: .center),
///     KPIProgressItem(kpiCaption: "Downloading", data: .constant(KPIItemData.percent(0.65))),
///     KPIItem(kpiCaption: "Big caption and long text", items: [KPISubItemModelImpl(kPISubItemValue: .text("321"), kPISubItemType: .metric)], proposedViewSize: .large, alignment: .center),
///     KPIProgressItem(kpiCaption: "Completed", data: .constant(KPIItemData.percent(1.0)), chartSize: .small)]
/// KPIHeader(items: data, isItemOrderForced: false)
/// ```
public struct KPIHeader {
    let items: any View
    let bannerMessage: any View
    let isItemOrderForced: Bool
    let interItemSpacing: CGFloat?

    @Environment(\.kPIHeaderStyle) var style

    var componentIdentifier: String = KPIHeader.identifier

    fileprivate var _shouldApplyDefaultStyle = true

    public init(@ViewBuilder items: () -> any View = { EmptyView() },
                @ViewBuilder bannerMessage: () -> any View = { EmptyView() },
                isItemOrderForced: Bool = false,
                interItemSpacing: CGFloat? = nil,
                componentIdentifier: String? = KPIHeader.identifier)
    {
        self.items = items()
        self.bannerMessage = bannerMessage()
        self.isItemOrderForced = isItemOrderForced
        self.interItemSpacing = interItemSpacing
        self.componentIdentifier = componentIdentifier ?? KPIHeader.identifier
    }
}

public extension KPIHeader {
    static let identifier = "fiori_kpiheader_component"
}

public extension KPIHeader {
    init(items: [any KPIHeaderItemModel] = [],
         bannerMessage: BannerMessage? = nil,
         isItemOrderForced: Bool = false,
         interItemSpacing: CGFloat? = nil)
    {
        self.init(items: { KPIContainerStack(items) }, bannerMessage: { bannerMessage }, isItemOrderForced: isItemOrderForced, interItemSpacing: interItemSpacing)
    }
}

public extension KPIHeader {
    init(_ configuration: KPIHeaderConfiguration) {
        self.init(configuration, shouldApplyDefaultStyle: false)
    }

    internal init(_ configuration: KPIHeaderConfiguration, shouldApplyDefaultStyle: Bool) {
        self.items = configuration.items
        self.bannerMessage = configuration.bannerMessage
        self.isItemOrderForced = configuration.isItemOrderForced
        self.interItemSpacing = configuration.interItemSpacing
        self._shouldApplyDefaultStyle = shouldApplyDefaultStyle
        self.componentIdentifier = configuration.componentIdentifier
    }
}

extension KPIHeader: View {
    public var body: some View {
        if self._shouldApplyDefaultStyle {
            self.defaultStyle()
        } else {
            self.style.resolve(configuration: .init(componentIdentifier: self.componentIdentifier, items: .init(self.items), bannerMessage: .init(self.bannerMessage), isItemOrderForced: self.isItemOrderForced, interItemSpacing: self.interItemSpacing)).typeErased
                .transformEnvironment(\.kPIHeaderStyleStack) { stack in
                    if !stack.isEmpty {
                        stack.removeLast()
                    }
                }
        }
    }
}

private extension KPIHeader {
    func shouldApplyDefaultStyle(_ bool: Bool) -> some View {
        var s = self
        s._shouldApplyDefaultStyle = bool
        return s
    }

    func defaultStyle() -> some View {
        KPIHeader(.init(componentIdentifier: self.componentIdentifier, items: .init(self.items), bannerMessage: .init(self.bannerMessage), isItemOrderForced: self.isItemOrderForced, interItemSpacing: self.interItemSpacing))
            .shouldApplyDefaultStyle(false)
            .kPIHeaderStyle(KPIHeaderFioriStyle.ContentFioriStyle())
            .typeErased
    }
}
