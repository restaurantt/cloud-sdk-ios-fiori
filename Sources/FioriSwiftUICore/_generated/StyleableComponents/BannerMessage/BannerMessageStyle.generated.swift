// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import SwiftUI

public protocol BannerMessageStyle: DynamicProperty {
    associatedtype Body: View

    func makeBody(_ configuration: BannerMessageConfiguration) -> Body
}

struct AnyBannerMessageStyle: BannerMessageStyle {
    let content: (BannerMessageConfiguration) -> any View

    init(@ViewBuilder _ content: @escaping (BannerMessageConfiguration) -> any View) {
        self.content = content
    }

    public func makeBody(_ configuration: BannerMessageConfiguration) -> some View {
        self.content(configuration).typeErased
    }
}

public struct BannerMessageConfiguration {
    public var componentIdentifier: String = "fiori_bannermessage_component"
    public let icon: Icon
    public let title: Title
    public let closeAction: CloseAction
    public let topDivider: TopDivider
    public let bannerTapAction: (() -> Void)?
    public let alignment: HorizontalAlignment
    public let hideSeparator: Bool
    public let messageType: BannerMultiMessageType
    public let showDetailLink: Bool

    public typealias Icon = ConfigurationViewWrapper
    public typealias Title = ConfigurationViewWrapper
    public typealias CloseAction = ConfigurationViewWrapper
    public typealias TopDivider = ConfigurationViewWrapper
}

extension BannerMessageConfiguration {
    func isDirectChild(_ componentIdentifier: String) -> Bool {
        componentIdentifier == self.componentIdentifier
    }
}

public struct BannerMessageFioriStyle: BannerMessageStyle {
    public func makeBody(_ configuration: BannerMessageConfiguration) -> some View {
        BannerMessage(configuration)
            .iconStyle(IconFioriStyle(bannerMessageConfiguration: configuration))
            .titleStyle(TitleFioriStyle(bannerMessageConfiguration: configuration))
            .closeActionStyle(CloseActionFioriStyle(bannerMessageConfiguration: configuration))
            .topDividerStyle(TopDividerFioriStyle(bannerMessageConfiguration: configuration))
    }
}
