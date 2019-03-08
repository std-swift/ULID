// swift-tools-version:5.0
//
//  Package.swift
//  ULID
//

import PackageDescription

let package = Package(
	name: "ULID",
	platforms: [
		.macOS(.v10_12)
	],
	products: [
		.library(
			name: "ULID",
			targets: ["ULID"]),
	],
	dependencies: [
		.package(url: "https://github.com/std-swift/Base32.git",
		         from: "1.0.0"),
		.package(url: "https://github.com/std-swift/Time.git",
		         from: "1.0.0"),
	],
	targets: [
		.target(
			name: "ULID",
			dependencies: ["Base32", "Time"]),
		.testTarget(
			name: "ULIDTests",
			dependencies: ["ULID"]),
	]
)
