//
//  FUIChartDataDirect.swift
//  Micro Charts
//
//  Created by Xu, Sheng on 2/5/20.
//  Copyright © 2020 sstadelman. All rights reserved.
//

import Foundation
import SwiftUI

/// Enum for available selection modes.
public enum ChartSelectionMode {

    /// Selects a single value in the currently selected series and category indices.
    case single

    /// Selects one value in each series for the selected category index(es).
    case all
}

/// Enum for default category selection.
public enum ChartCategorySelectionMode {
    
    /// No default selection mode is defined. Any set selection will be used.
    case index
    
    /// First category of the selected series and dimension will be used.
    case first
    
    /// Last category of the selected series and dimension will be used.
    case last
}


/// Selection state for points and rects in the chart.
enum ChartSelectionState {
    case normal
    case selected
    case highlighted
    case disabled
}

public class ChartModel: ObservableObject, Identifiable {

    ///
    public enum DimensionData<T> {
        case single(T)
        case array([T])
        
        var value: T? {
            switch self {
            case .single(let val):
                return val
            default:
                return nil
            }
        }
        
        var values: [T]? {
            switch self {
            case .array(let vals):
                return vals
            default:
                return nil
            }
        }
        
        var count: Int {
            switch self {
            case .array(let vals):
                return vals.count
            default:
                return 1
            }
        }
        
        var first: T? {
            switch self {
            case .array(let vals):
                return vals.first
            case .single(let val):
                return val
            }
        }
        
        subscript(index: Int) -> T {
            switch self {
            case .array(let vals):
                return vals[index]
                
            case .single(let val):
                return val
            }
        }
    }
    
    /// data
    @Published public var chartType: ChartType
    /// seires -> category -> dimension
    @Published public var data: [[DimensionData<Double>]]
    @Published public var titlesForCategory: [[String]]?
    @Published public var titlesForAxis: [String]?
    @Published public var labelsForDimension: [[DimensionData<String>]]?
    
    /// enable or disable user interaction
    @Published public var userInteractionEnabled: Bool = false
    
    ///
    @Published public var panChartToDataPointOnly = false
  
    /// seires attributes
    @Published public var seriesAttributes: ChartSeriesAttributes
    
    ///
    @Published public var colorsForCategory: [[Color]]?
    
    @Published public var numberOfGridlines: Int = 2
    
    /**
     Provides attributes for the category axis.

     - For stock, clustered column, line, and combo charts this is the X axis.
     - For bar charts this is the Y axis.
     */
    @Published public var categoryAxis: ChartCategoryAxis
    
    /**
     Provides attributes for the primary numeric axis.

     - For stock, clustered column, line, and combo charts this is the Y axis.
     - For bar charts this is the X axis.
     */
    @Published public var numericAxis: ChartNumericAxis
    
    /**
     Provides attributes for the secondary numeric axis.
     
     - For clustered line, area and combo charts this is the secondary Y axis.
     */
    @Published public var secondaryNumericAxis: ChartNumericAxis
    
    /**
     Indicates indexes of column series for combo chart.
     - Given indexes of series will be treated as column and the rest series will be treated as line.
     */
    @Published public var indexesOfColumnSeries: IndexSet?
    
    /**
     Indicates total indexes for waterfall chart.
     - Given indexes will treat the corresponding categories as totals.
     - The corresponding category values in the provided data should correspond to the total sum of the preceding values.
     - If the corresponding category value is nil in the provided data, the chart will complete the sum of the total value, which can be retrieved through `plotItem(atSeries:category:)`.
     */
    public var indexesOfTotalsCategories: IndexSet?
    
    /**
     Indicates secondary value axis series indexes for line based charts.
     - The secondary value index works with .line, .area and .combo charts only.
     - Given series indexes will assign the corresponding series to the secondary value axis.
     */
    public var indexesOfSecondaryValueAxis: IndexSet?
    
    /// selection state
    /**
     Determines which plot items should be selected for a category.
     - single : Selects a single value in the currently selected series and category indices.
     - all : Selects one value in each series for the selected category index(es).
     */
    @Published public var selectionMode: ChartSelectionMode = .single
    
    /**
     Default category selection mode for the chart. Defines how the initial selection is handled. Only valid values are selected.
     Used in combination with: `select(category:)`, `select(categoriesInRange:)`, `select(series:)`, `select(dimension:)`.
     If no series is selected through `select(series:)`, the first series will be used.
     For Scatter and Bubble charts, if no dimension is defined through `select(dimension:)`, the Y axis dimension will be used.
     - `MCDefaultCategorySelectionIndex` This is the default behavior, where the given selection will be considered as the initial selection.
     - `MCDefaultCategorySelectionFirst` The first category will be considered as the default selection.
     - `MCDefaultCategorySelectionLast` The last gategory will be considered as the default selection.
    */
    @Published public var defaultCategorySelectionMode: ChartCategorySelectionMode = .index
    
    /// When false a state is allowed in which no series is selected/active.
    @Published public var selectionRequired: Bool = false
    
    @Published public var selectedSeriesIndex: Int?
    @Published public var selectedCategoryIndexes: ClosedRange<Int>?
    @Published public var selectedDimensionIndex: ClosedRange<Int>?
    
    // scale is not allowed to be less than 1.0
    @Published public var scale: CGFloat = 1.0
    @Published public var startPos: Int = 0
    
    /// styles
    
    var ranges: [ClosedRange<Double>]?
    
    public let id = UUID()
    
    public init(chartType: ChartType,
                data: [[Double]],
                titlesForCategory: [[String]]? = nil,
                colorsForCategory: [[Color]]? = nil,
                titlesForAxis: [String]? = nil,
                labelsForDimension: [[String]]? = nil,
                selectedSeriesIndex: Int? = nil,
                userInteractionEnabled: Bool = false,
                seriesAttributes: ChartSeriesAttributes? = nil,
                categoryAxis: ChartCategoryAxis? = nil,
                numericAxis: ChartNumericAxis? = nil,
                secondaryNumericAxis: ChartNumericAxis? = nil) {
        self.chartType = chartType
        self.colorsForCategory = colorsForCategory
        self.titlesForAxis = titlesForAxis
        self.selectedSeriesIndex = selectedSeriesIndex
        self.userInteractionEnabled = userInteractionEnabled
        
        var intradayIndex: [Int] = []
        if chartType != .stock {
            self.titlesForCategory = titlesForCategory
        }
        else {
            if let titles = titlesForCategory {
                var modifiedTitlesForCategory: [[String]] = []
                for (i, category) in titles.enumerated() {
                    if let modifiedTitles = ChartModel.preprocessIntradayDataForStock(category) {
                        intradayIndex.append(i)
                        modifiedTitlesForCategory.append(modifiedTitles)
                    }
                    else {
                        modifiedTitlesForCategory.append(category)
                    }
                }
                
                self.titlesForCategory = modifiedTitlesForCategory
            }
        }
    
        var tmpData: [[DimensionData<Double>]] = []
        for (i, c) in data.enumerated() {
            var s: [DimensionData<Double>] = []
            for (j, d) in c.enumerated() {
                if intradayIndex.contains(i) && j == c.count - 1 {
                    continue
                }
                else {
                    s.append(DimensionData.single(d))
                }
            }
            tmpData.append(s)
        }
        self.data = tmpData
        
        if let labels = labelsForDimension {
            var tmpLabels: [[DimensionData<String>]] = []
            for c in labels {
                var s: [DimensionData<String>] = []
                for d in c {
                    s.append(DimensionData.single(d))
                }
                tmpLabels.append(s)
            }
            self.labelsForDimension = tmpLabels
        }
        
        if let numericAxis = numericAxis {
            self.numericAxis = numericAxis
        }
        else {
            self.numericAxis = ChartNumericAxis()
        }
        
        if let secondaryNumericAxis = secondaryNumericAxis {
            self.secondaryNumericAxis = secondaryNumericAxis
        }
        else {
            self.secondaryNumericAxis = ChartNumericAxis()
        }
        
        if let categoryAxis = categoryAxis {
            self.categoryAxis = categoryAxis
        }
        else {
            self.categoryAxis = ChartCategoryAxis()
        }
        
        if let seriesAttributes = seriesAttributes {
            self.seriesAttributes = seriesAttributes
        }
        else {
            self.seriesAttributes = ChartModel.initChartSeriesAttributes(chartType: chartType, seriesCount: data.count)
        }
        
        initialize()
    }
    
    public init(chartType: ChartType,
                data: [[[Double]]],
                titlesForCategory: [[String]]? = nil,
                colorsForCategory: [[Color]]? = nil,
                titlesForAxis: [String]? = nil,
                labelsForDimension: [[[String]]]? = nil,
                selectedSeriesIndex: Int? = nil,
                userInteractionEnabled: Bool = false,
                seriesAttributes: ChartSeriesAttributes? = nil,
                categoryAxis: ChartCategoryAxis? = nil,
                numericAxis: ChartNumericAxis? = nil,
                secondaryNumericAxis: ChartNumericAxis? = nil) {
        self.chartType = chartType
        self.colorsForCategory = colorsForCategory
        self.titlesForAxis = titlesForAxis
        self.selectedSeriesIndex = selectedSeriesIndex
        self.userInteractionEnabled = userInteractionEnabled
        
        var intradayIndex: [Int] = []
        if chartType != .stock {
            self.titlesForCategory = titlesForCategory
        }
        else {
            if let titles = titlesForCategory {
                var modifiedTitlesForCategory: [[String]] = []
                for (i, category) in titles.enumerated() {
                    if let modifiedTitles = ChartModel.preprocessIntradayDataForStock(category) {
                        intradayIndex.append(i)
                        modifiedTitlesForCategory.append(modifiedTitles)
                    }
                    else {
                        modifiedTitlesForCategory.append(category)
                    }
                }
                
                self.titlesForCategory = modifiedTitlesForCategory
            }
        }
        
        var tmpData: [[DimensionData<Double>]] = []
        for (i, c) in data.enumerated() {
            var s: [DimensionData<Double>] = []
            for (j, d) in c.enumerated() {
                if intradayIndex.contains(i) && j == c.count - 1 {
                    continue
                }
                else {
                    s.append(DimensionData.array(d))
                }
            }
            tmpData.append(s)
        }
        self.data = tmpData
        
        if let labels = labelsForDimension {
            var tmpLabels: [[DimensionData<String>]] = []
            for c in labels {
                var s: [DimensionData<String>] = []
                for d in c {
                    s.append(DimensionData.array(d))
                }
                tmpLabels.append(s)
            }
            self.labelsForDimension = tmpLabels
        }
        
        if let numericAxis = numericAxis {
            self.numericAxis = numericAxis
        }
        else {
            self.numericAxis = ChartNumericAxis()
        }
        
        if let secondaryNumericAxis = secondaryNumericAxis {
            self.secondaryNumericAxis = secondaryNumericAxis
        }
        else {
            self.secondaryNumericAxis = ChartNumericAxis()
        }
        
        if let categoryAxis = categoryAxis {
            self.categoryAxis = categoryAxis
        }
        else {
            self.categoryAxis = ChartCategoryAxis()
        }
        
        if let seriesAttributes = seriesAttributes {
            self.seriesAttributes = seriesAttributes
        }
        else {
            self.seriesAttributes = ChartModel.initChartSeriesAttributes(chartType: chartType, seriesCount: data.count)
        }
        
        initialize()
    }
    
    static func initChartSeriesAttributes(chartType: ChartType, seriesCount: Int) -> ChartSeriesAttributes {
        switch chartType {
        case .stock:
            let colors = [Palette.hexColor(for: .stockUpStroke), Palette.hexColor(for: .stockDownStroke), Palette.hexColor(for: .stockUpFill), Palette.hexColor(for: .stockDownFill), Palette.hexColor(for: .stockFillEndColor)]
            return ChartSeriesAttributes(colors: colors, lineWidth: 2, points: nil, firstLineCapDiameter: 0, lastLineCapDiameter: 0)
        default:
            let colors = [Palette.hexColor(for: .chart1), Palette.hexColor(for: .chart2)]
            let count = min(colors.count, max(1, seriesCount))
            return ChartSeriesAttributes(colors: Array(colors[0 ..< count]), lineWidth: 2, points: nil, firstLineCapDiameter: 0, lastLineCapDiameter: 0)
        }
    }
    
    func initialize() {
        // check if there is data
        if let _ = data.first?.first {
            self.ranges = []
            
            // go through series
            for i in 0 ..< data.count {
                let range: ClosedRange<Double> = {
                    var allValues: [Double] = []
                    
                    if let _ = data[i].first?.value {
                        allValues = data[i].map { $0.value! }
                    }
                    else if let _ = data[i].first?.values {
                        allValues = data[i].map({$0.values!.first!})
                    }
                                        
                    let min = allValues.min() ?? 0
                    let max = allValues.max() ?? 1
                    
                    var minVal = min
                    var maxVal = max
                    if self.chartType == .stock {
                        maxVal = max + (max - min) * 0.3
                        minVal = min - (max - min) * 0.3
                        
                        if minVal < 0 {
                            minVal = 0
                        }
                    }
                    
                    guard minVal != maxVal else { return 0...maxVal }
                    return minVal...maxVal
                }()
                self.ranges?.append(range)
            }
        }
    }
    
    // interpolate time strings in categoryTitles if it is intraday mode and return modified titles
    static func preprocessIntradayDataForStock(_ categoryTitles: [String]) -> [String]? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dataChanged = false
        
        let count = categoryTitles.count
        if count >= 3,
            let startTime = StockUtility.date(from: categoryTitles[0]),
            let secondTime = StockUtility.date(from: categoryTitles[1]),
            let timeBeforeEndTime = StockUtility.date(from: categoryTitles[count - 2]),
            let endTime = StockUtility.date(from: categoryTitles[count - 1]) {
            
            let startTimeInterval = secondTime.timeIntervalSince(startTime)
            var endTimeInterval = endTime.timeIntervalSince(timeBeforeEndTime)
            var j: Int = count - 1
            var insertedTime = timeBeforeEndTime
            var modifiedCategoryTitles = categoryTitles
            
            // indicates this is intraday
            while endTimeInterval > startTimeInterval {
                let time = insertedTime.advanced(by: startTimeInterval)
                let timeString = df.string(from: time)
                modifiedCategoryTitles.insert(timeString, at: j)
                j += 1
                insertedTime = time
                endTimeInterval -= startTimeInterval
                dataChanged = true
            }
            
            if dataChanged {
                return modifiedCategoryTitles
            }
        }
        
        return nil
    }
    
    func normalizedValue<T: BinaryFloatingPoint>(for value: T, seriesIndex: Int) -> T {
        if let range = ranges {
            return abs(T(value)) / T(range[seriesIndex].upperBound - range[seriesIndex].lowerBound)
        }
        else {
            return 0
        }
    }
    
    func normalizedValue<T: BinaryFloatingPoint>(for value: T) -> T {
        if let range = ranges {
            var minValue = range.first!.lowerBound
            var maxValue = range.first!.upperBound
            for i in range {
                minValue = min(minValue, i.lowerBound)
                maxValue = max(maxValue, i.upperBound)
            }
            
            return abs(value) / T(maxValue - minValue)
        }
        else {
            return T(0)
        }
    }
    
    public var currentSeriesIndex: Int {
        if let current = selectedSeriesIndex {
            return current
        }
        else {
            return 0
        }
    }
}


extension ChartModel {
    func colorAt(seriesIndex: Int, categoryIndex: Int) -> Color {
        guard let tmp = colorsForCategory, seriesIndex < tmp.count else {
            return Color.black
        }
            
        let colors = tmp[seriesIndex]
        if categoryIndex >= colors.count {
            return colors.last!
        }
        else {
            return colors[categoryIndex]
        }
    }
    
    func labelAt(seriesIndex: Int, categoryIndex: Int, dimensionIndex: Int) -> String? {
        guard let tmp = labelsForDimension, seriesIndex < tmp.count, categoryIndex < tmp[seriesIndex].count, dimensionIndex < tmp[seriesIndex][categoryIndex].count else {
            return nil
        }
        
        return tmp[seriesIndex][categoryIndex][dimensionIndex]
    }
    
    func titleAt(seriesIndex: Int, categoryIndex: Int) -> String? {
        guard let tmp = titlesForCategory, seriesIndex < tmp.count, categoryIndex < tmp[seriesIndex].count else {
            return nil
        }
        
        return tmp[seriesIndex][categoryIndex]
    }
    
    func dataItemsIn(seriesIndex: Int, dimensionIndex: Int = 0) -> [MicroChartDataItem] {
        var res: [MicroChartDataItem] = []
        
        guard seriesIndex < data.count, data[seriesIndex].count > 0 else {
            return res
        }
        
        for i in 0 ..< data[seriesIndex].count {
            if data[seriesIndex][i].count > dimensionIndex {
                let value = data[seriesIndex][i][dimensionIndex]
                
                let item = MicroChartDataItem(value: CGFloat(value),
                                              displayValue: labelAt(seriesIndex: seriesIndex, categoryIndex: i, dimensionIndex: dimensionIndex),
                                              label: titleAt(seriesIndex: seriesIndex, categoryIndex: i),
                                              color: colorAt(seriesIndex: seriesIndex, categoryIndex: i))
                res.append(item)
            }
        }
        
        return res
    }
}
