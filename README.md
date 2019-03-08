# ULID

[![](https://img.shields.io/badge/Swift-5.0-orange.svg)][1]
[![](https://img.shields.io/badge/os-macOS%20|%20Linux-lightgray.svg)][1]
[![](https://travis-ci.com/std-swift/ULID.svg?branch=master)][2]
[![](https://codecov.io/gh/std-swift/ULID/branch/master/graph/badge.svg)][3]
[![](https://codebeat.co/badges/c22ba76c-2a70-4bbb-9129-de3a041104c4)][4]

[1]: https://swift.org/download/#releases
[2]: https://travis-ci.com/std-swift/ULID
[3]: https://codecov.io/gh/std-swift/ULID
[4]: https://codebeat.co/projects/github-com-std-swift-ulid-master

[Universally Unique Lexicographically Sortable Identifier][5]

[5]: https://github.com/ulid/spec

## Importing

```Swift
import ULID
```

```Swift
platforms: [
	.macOS(.v10_12)
],
dependencies: [
	.package(url: "https://github.com/std-swift/ULID.git",
	         from: "1.0.0")
],
targets: [
	.target(
		name: "",
		dependencies: [
			"ULID"
		]),
]
```

## Using

### `ULID`

`ULID` conforms to `Equatable`, `Comparable`, `Hashable`, `Codable`, and `LosslessStringConvertible`

Initialize the raw data:

```Swift
init(rawTime: (high: UInt32, low: UInt16), random: (UInt16, UInt32, UInt32))
```

Initialize with a `Time` and data

```Swift
init(time: Time = Clock.realtime.now(), random: (Int) -> (UInt16, UInt32, UInt32))
init(time: Time = Clock.realtime.now(), random: @autoclosure () -> (UInt16, UInt32, UInt32))
```

Initialize with a `Time` and random data

```Swift
init(time: Time = Clock.realtime.now())
init<T: RandomNumberGenerator>(time: Time = Clock.realtime.now(), generator: inout T)
```

Get time and random data from a `ULID`

```Swift
ulid.time: Time
ulid.rawTime: (high: UInt32, low: UInt16)
ulid.random: (UInt16, UInt32, UInt32)
```
