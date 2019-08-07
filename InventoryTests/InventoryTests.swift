import XCTest
@testable import Inventory
class InventoryTests: XCTestCase {
    var inv : Inventory!
    override func setUp() {
        inv = Inventory()
    }
    override func tearDown() {
        inv = nil
    }
    func testExample() {
        let minmax = Global.minMax(array: [8, -6, 2, 109, 3, 71])!
        XCTAssertEqual(minmax.min, -6, "min is wrong")
        XCTAssertEqual(minmax.max, 109, "max is wrong")
    }
    func testNil() {
        let minmax = Global.minMax(array: [])
        XCTAssertNil(minmax)
    }
    func testPerformanceExample() {
        self.measure {
        }
    }
}
