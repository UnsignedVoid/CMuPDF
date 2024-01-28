// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mupdf-swift",
    platforms: [
      .macOS(.v11)
    ],
        products: [
        .library(
            name: "MuPDF",
            targets: ["MuPDF"]
          ),
    ],
    targets: [
        .target(
          name: "MuPDF",
          dependencies: ["CMuPDF"],
          cSettings: [
            .unsafeFlags(["-I/opt/homebrew/include"])
          ]
        ),
        .systemLibrary(
          name: "CMuPDF",
          path: "Sources/cmupdf",
          pkgConfig: "cmupdf",
          providers: [
          .brew(["mupdf"])
        ])
    ]
)
