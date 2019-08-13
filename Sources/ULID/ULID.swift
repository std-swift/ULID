//
//  ULID.swift
//  ULID
//

import Base32
import Time

/// Universally Unique Lexicographically Sortable Identifier
public struct ULID {
	public static let zero = ULID(time: .distantPast, random: (0, 0, 0))
	
/*
	0                   1                   2                   3
	 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|                      32_bit_uint_time_high                    |
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|     16_bit_uint_time_low      |       16_bit_uint_random      |
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|                       32_bit_uint_random                      |
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|                       32_bit_uint_random                      |
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
*/
	public let rawTime: (high: UInt32, low: UInt16)
	public let random: (UInt16, UInt32, UInt32)
	
	public var time: Time {
		let milliseconds = (UInt64(self.rawTime.high) << 16) | UInt64(self.rawTime.low)
		return Time(seconds: Int(milliseconds / 1000),
		            nanoseconds: Int(milliseconds % 1000) * 1_000_000)
	}
	
	public init(rawTime: (high: UInt32, low: UInt16),
	            random: (UInt16, UInt32, UInt32)) {
		self.rawTime = rawTime
		self.random = random
	}
	
	public init(time: Time = Clock.realtime.now(),
	            random: @autoclosure () -> (UInt16, UInt32, UInt32)) {
		let milliseconds = time.view.milliseconds
		self.rawTime = (
			UInt32(truncatingIfNeeded: milliseconds >> 16),
			UInt16(truncatingIfNeeded: milliseconds)
		)
		self.random = random()
	}
	
	public init(time: Time = Clock.realtime.now(),
	            random: (Int) -> (UInt16, UInt32, UInt32)) {
		let milliseconds = time.view.milliseconds
		self.rawTime = (
			UInt32(truncatingIfNeeded: milliseconds >> 16),
			UInt16(truncatingIfNeeded: milliseconds)
		)
		self.random = random(milliseconds)
	}
	
	public init<T: RandomNumberGenerator>(time: Time = Clock.realtime.now(),
	                                      generator: inout T) {
		let milliseconds = time.view.milliseconds
		self.rawTime = (
			UInt32(truncatingIfNeeded: milliseconds >> 16),
			UInt16(truncatingIfNeeded: milliseconds)
		)
		self.random = (
			UInt16.random(in: .min ... .max, using: &generator),
			UInt32.random(in: .min ... .max, using: &generator),
			UInt32.random(in: .min ... .max, using: &generator)
		)
	}
	
	public init(time: Time = Clock.realtime.now()) {
		var generator = SystemRandomNumberGenerator()
		self.init(time: time, generator: &generator)
	}
}

extension ULID: Equatable {
	public static func == (lhs: ULID, rhs: ULID) -> Bool {
		return lhs.rawTime == rhs.rawTime && lhs.random == rhs.random
	}
}

extension ULID: Comparable {
	public static func < (lhs: ULID, rhs: ULID) -> Bool {
		return lhs.rawTime < rhs.rawTime ||
			(lhs.rawTime == rhs.rawTime && lhs.random < rhs.random)
	}
}

extension ULID: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.rawTime.high)
		hasher.combine(self.rawTime.low)
		hasher.combine(self.random.0)
		hasher.combine(self.random.1)
		hasher.combine(self.random.2)
	}
}

extension ULID: Codable {
	private enum Key: CodingKey {
		case timeHigh
		case timeLow
		case random0
		case random1
		case random2
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Key.self)
		try container.encode(self.rawTime.high, forKey: .timeHigh)
		try container.encode(self.rawTime.low,  forKey: .timeLow)
		try container.encode(self.random.0,  forKey: .random0)
		try container.encode(self.random.1,  forKey: .random1)
		try container.encode(self.random.2,  forKey: .random2)
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Key.self)
		self.rawTime = (
			try container.decode(UInt32.self, forKey: .timeHigh),
			try container.decode(UInt16.self, forKey: .timeLow)
		)
		self.random = (
			try container.decode(UInt16.self, forKey: .random0),
			try container.decode(UInt32.self, forKey: .random1),
			try container.decode(UInt32.self, forKey: .random2)
		)
	}
}

extension ULID: LosslessStringConvertible {
	public init?(_ description: String) {
		guard description.count == 26 else { return nil }
		var decoder = Base32Decoder()
		decoder.decode("000000") // Add alignment bytes
		decoder.decode(description)
		let bytes = decoder.finalize()
		
		// Ensure the time component is only 48 bits (these are alignment bytes)
		guard bytes[..<4].allSatisfy({ $0 == 0 }) else { return nil }
		
		self.rawTime = (
			Array(bytes[4..<8]).asBigEndian().first!,
			Array(bytes[8..<10]).asBigEndian().first!
		)
		self.random = (
			Array(bytes[10..<12]).asBigEndian().first!,
			Array(bytes[12..<16]).asBigEndian().first!,
			Array(bytes[16..<20]).asBigEndian().first!
		)
	}
	
	public var description: String {
		var encoder = Base32Encoder()
		encoder.encode([0,0,0,0]) // Align self.time to end on a boundary
		encoder.encode(self.rawTime.high.bigEndianBytes)
		encoder.encode(self.rawTime.low.bigEndianBytes)
		encoder.encode(self.random.0.bigEndianBytes)
		encoder.encode(self.random.1.bigEndianBytes)
		encoder.encode(self.random.2.bigEndianBytes)
		return String(encoder.finalize().dropFirst(6)) // Remove alignment bytes
	}
}
