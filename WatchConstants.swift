import Foundation
public struct DataKey {
    static let TopPrice = "TopPrice"
    static let TopRooms = "TopRooms"
    static let AmountMoney = "AmountMoney"
    static let TopOwners = "TopOwners"
    static let TopCategories = "TopCategories"
    static let TopBrands = "TopBrands"
    static let ImageData = "ImageData"
    static let MostExpensiveList = "MostExpensiveList"
    static let ItemCount = "ItemCount"
}
public struct Local{
    static let locale = Locale.current
    static let isMetric = locale.usesMetricSystem
    static let currencyCode  = locale.currencyCode
    static let currencySymbol = locale.currencySymbol
    static let languageCode = locale.languageCode
    static func currentLocaleForDate() -> String{
        return Local.languageCode!
    }
}
