//
//  SegmentedControl.swift
//  FioriSwiftUICore
//
//  Created by Ma, Xiao on 3/17/20.
//  Copyright © 2020 Ma, Xiao. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public struct SegmentedControl: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    
    public var titles: [String] {
        get {
            return model.titles
        }
        set {
            model.titles = newValue
        }
    }
    
    public var segmentAttributes: [ControlState: SegmentAttributes] {
        get {
            return model.segmentAttributes
        }
        set {
            model.segmentAttributes = newValue
        }
    }
    
    public var titleInsets: EdgeInsets {
        get {
            return model.titleInset
        }
        set {
            model.titleInset = newValue
        }
    }
    
    public var interItemSpacing: CGFloat {
        get {
            return model.interItemSpacing
        }
        set {
            model.interItemSpacing = newValue
        }
    }
    
    public var selectedIndex: Int? {
        get {
            return model.selectedIndex
        }
        set {
            guard self.isEnable else {
                return
            }
            if let value = newValue, (value < 0 || value >= self.titles.count) {
                return
            }
            model.selectedIndex = newValue
        }
    }
    
    public var isEnable: Bool {
        get {
            return model.isEnable
        }
        set {
            if !newValue {
                self.selectionDidChange(index: nil)
            }
            model.isEnable = newValue
        }
    }
    
    public var fixedSegmentWidth: Bool {
        get {
            return model.fixedSegmentWidth
        }
        set {
            model.fixedSegmentWidth = newValue
            fixedSize = newValue ? getFixedSize(for: self.titles) : nil
        }
    }
    
    public var fixedSize: CGSize? {
        get {
            return model.fixedSize
        }
        set {
            model.fixedSize = newValue
        }
    }
    
    public var contentInset: EdgeInsets {
        get {
            let leadingAndTrailing: CGFloat = horizontalSizeClass == .compact ? 16 : 48
            let defaultInset = EdgeInsets(top: 8, leading: leadingAndTrailing, bottom: 8, trailing: leadingAndTrailing)
            return model.contentInset ?? defaultInset
        }
        set {
            return model.contentInset = newValue
        }
    }
    
    lazy public private(set) var selectionDidChangePublisher: AnyPublisher<Int?, Never> = {
        self.model.$selectedIndex.eraseToAnyPublisher()
    }()
    
    @ObservedObject private var model: Model = Model()
        
    public init(segmentTitles: [String],
                interItemSpacing: CGFloat = 6,
                titleInsets: EdgeInsets = EdgeInsets.init(top: 8, leading: 8, bottom: 8, trailing: 8),
                selectedIndex: Int? = nil,
                contentInset: EdgeInsets? = nil) {
        
        self.model.segmentAttributes = [
            .normal: SegmentAttributes(fontColor: .gray, font: UIFont.preferredFont(forTextStyle: .subheadline), borderColor: .init(red: 0.2, green: 0.2, blue: 0.2)),
            .selected: SegmentAttributes(fontColor: .blue, font: UIFont.preferredFont(forTextStyle: .subheadline), borderColor: .blue),
            .disabled: SegmentAttributes(fontColor: .gray, font: UIFont.preferredFont(forTextStyle: .subheadline), borderColor: .init(red: 0.2, green: 0.2, blue: 0.2))
        ]
        
        self.titles             = segmentTitles
        self.titleInsets        = titleInsets
        self.interItemSpacing   = interItemSpacing
        self.model.isEnable     = true
        self.fixedSegmentWidth  = false
        self.selectedIndex      = selectedIndex
        
        if let _contentInset = contentInset {
            self.contentInset = _contentInset
        }
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: self.model.interItemSpacing) {
                ForEach(self.model.titles.indices, id: \.self) { index in
                    Segment(title: self.model.titles[index], isSelected: self.model.selectedIndex == index, isEnable: self.model.isEnable, segmentAttributes: self.model.segmentAttributes, titleInset: self.model.titleInset, fixedSize: self.fixedSize)
                        .onTapGesture {
                            if self.model.isEnable {
                                self.selectionDidChange(index: index)
                                print(self.getFixedSize(for: self.titles))
                            }
                    }
                }
            }
            .padding([.top, .bottom], 8)
            .padding(.leading, model.contentInset?.leading ?? (horizontalSizeClass == .compact ? 16 : 48))
            .padding(.trailing, model.contentInset?.trailing ?? (horizontalSizeClass == .compact ? 16 : 48))
        }
    }
    
    private func selectionDidChange(index: Int?) {
        if selectedIndex != index {
            self.model.selectedIndex = index
        }
    }
    
    private func getFixedSize(for titles: [String]) -> CGSize {
        var largestWidth: CGFloat = -1
        var largestHeight: CGFloat = -1
        
        let fonts = [segmentAttributes[.normal]?.font,
                     segmentAttributes[.disabled]?.font,
                     segmentAttributes[.selected]?.font]
        
        for font in fonts {
            if let _font = font {
                largestHeight = max(largestHeight, getSizeForString(titles[0], font: _font).height)
            }
        }
        
        for title in titles {
            let label = UILabel()
            label.text = title
            label.sizeToFit()
            largestWidth = max(label.frame.width, largestWidth)
        }
        
        return CGSize(width: largestWidth + titleInsets.leading + titleInsets.trailing,
                      height: largestHeight + titleInsets.top + titleInsets.bottom)
    }
    
    private func getSizeForString(_ string: String, font: UIFont) -> CGSize {
        return (string as NSString).size(withAttributes: [NSAttributedString.Key.font : font])
    }
}

extension SegmentedControl {
    struct Segment: View {
        
        let title: String
        
        var isSelected: Bool
        
        var isEnable: Bool
        
        var segmentAttributes: [ControlState: SegmentAttributes]
        
        var titleInset: EdgeInsets
        
        var fixedSize: CGSize?
        
        var body: some View {
            Text(title)
                .font(self.isSelected ? segmentAttributes[.selected]?.getFont(): segmentAttributes[.normal]?.getFont())
                .padding(titleInset)
                .foregroundColor(isEnable ? (self.isSelected ? segmentAttributes[.selected]?.fontColor : segmentAttributes[.normal]?.fontColor) : (segmentAttributes[.disabled]?.fontColor))
                .frame(width: self.fixedSize?.width, height: self.fixedSize?.height)
                .overlay(ButtonOverlayView(isSelected: self.isSelected, isEnable: self.isEnable, segmentAttributes: segmentAttributes))
        }
    }
    
    class Model: ObservableObject {
        @Published var titles: [String]!
        @Published var selectedIndex: Int?
        @Published var interItemSpacing: CGFloat!
        @Published var titleInset: EdgeInsets!
        @Published var segmentAttributes: [ControlState: SegmentAttributes]!
        @Published var contentInset: EdgeInsets?
        @Published var isEnable: Bool!
        @Published var fixedSegmentWidth: Bool!
        @Published var fixedSize: CGSize?
    }
}

struct DimensionSelector_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

