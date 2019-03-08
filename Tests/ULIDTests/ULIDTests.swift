//
//  ULIDTests.swift
//  ULIDTests
//

import XCTest
import ULID

final class ULIDTests: XCTestCase {
	func testTimeEncoding() {
		let zero = ULID.zero
		XCTAssertEqual(zero.description.prefix(10), "0000000000")
		
		let ulid1 = ULID(time: .init(seconds: 1547213173, nanoseconds: 513_000_000), random: (0, 0, 0))
		XCTAssertEqual(ulid1.description.prefix(10), "01D0YHEWR9")
		XCTAssertEqual(ulid1.time, .init(seconds: 1547213173, nanoseconds: 513_000_000))
		
		let ulid2 = ULID(time: .init(seconds: 1469918176, nanoseconds: 385_000_000), random: (0, 0, 0))
		XCTAssertEqual(ulid2.description.prefix(10), "01ARYZ6S41")
		XCTAssertEqual(ulid2.time, .init(seconds: 1469918176, nanoseconds: 385_000_000))
		
		let ulid3 = ULID(time: .init(seconds: 0001484581, nanoseconds: 420_000_000), random: (0, 0, 0))
		XCTAssertEqual(ulid3.description.prefix(10), "0001C7STHC")
		XCTAssertEqual(ulid3.time, .init(seconds: 0001484581, nanoseconds: 420_000_000))
	}
	
	func testRandomEncoding() {
		let zero = ULID.zero
		XCTAssertEqual(zero.description.suffix(16), "0000000000000000")
		
		let ulid1 = ULID(time: .distantPast, random: (0x1844, 0xA284EFC6, 0x3000000E))
		XCTAssertEqual(ulid1.description.suffix(16), "312A517FRRR0000E")
		XCTAssertEqual(ulid1.random.0, 0x1844)
		XCTAssertEqual(ulid1.random.1, 0xA284EFC6)
		XCTAssertEqual(ulid1.random.2, 0x3000000E)
	}
	
	func testFromString() {
		let string = "01D0YHEWR9" + "312A517FRRR0000E"
		let result = ULID(time: .init(seconds: 1547213173, nanoseconds: 513_000_000),
		                  random: (0x1844, 0xA284EFC6, 0x3000000E))
		let ulid = ULID(string)
		XCTAssertEqual(ulid, result)
		XCTAssertEqual(ulid?.time, .init(seconds: 1547213173, nanoseconds: 513_000_000))
		XCTAssertEqual(ulid?.random.0, 0x1844)
		XCTAssertEqual(ulid?.random.1, 0xA284EFC6)
		XCTAssertEqual(ulid?.random.2, 0x3000000E)
	}
	
	func testMaxULID() {
		let ulid1 = ULID(rawTime: (.max, .max), random: (.max, .max, .max))
		let ulid2 = ULID("7ZZZZZZZZZZZZZZZZZZZZZZZZZ")
		XCTAssertEqual(ulid1, ulid2)
		XCTAssertEqual(ulid1.description, "7ZZZZZZZZZZZZZZZZZZZZZZZZZ")
		XCTAssertEqual(ulid2?.time, .init(seconds: 281474976710, nanoseconds: 655_000_000))
		XCTAssertEqual(ulid2?.random.0, .max)
		XCTAssertEqual(ulid2?.random.1, .max)
		XCTAssertEqual(ulid2?.random.2, .max)
	}
}
