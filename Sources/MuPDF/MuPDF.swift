// The Swift Programming Language
// https://docs.swift.org/swift-book

import CMuPDF
import CoreGraphics
import Foundation
import System

public class MuPDF {

  private let ctx: UnsafeMutablePointer<fz_context>!
  private var doc: UnsafeMutablePointer<fz_document>!
  private var ctm: fz_matrix!

  public init() throws {
    self.ctx = fz_new_context_imp(nil, nil, FZ_STORE_UNLIMITED, FZ_VERSION)
    if self.ctx == nil {
      throw MuPDFError.InitError(message: "Cannot init context")
    }
    fz_register_document_handlers(self.ctx)
  }

  public func openDoc(path: FilePath) throws {
    path.withCString {
      self.doc = fz_open_document(self.ctx, $0)
    }
    if self.doc == nil {
      throw MuPDFError.DocReadError(message: "Cannot read document \(path)")
    }
  }

  public var pageCount: UInt32 {
    UInt32(fz_count_pages(self.ctx, self.doc))
  }

  public func setPageTransform(scale_x: Float32, scale_y: Float32, rotate_by: Float32) {
    self.ctm = fz_scale(scale_x, scale_y)
    self.ctm = fz_pre_rotate(self.ctm, rotate_by)
  }

  public func getPagePixmap(page_number: Int32) throws -> CGImage {
    if page_number < 0 && page_number > self.pageCount {
      throw MuPDFError.InvalidPageNum(
        message: "Cannot read page \(page_number) from document with \(self.pageCount)")
    }
    let pixmap_ptr = fz_new_pixmap_from_page_number(
      self.ctx, self.doc, page_number, self.ctm, fz_device_rgb(self.ctx),
      0)
    if pixmap_ptr == nil {
      throw MuPDFError.PageRenderingError(message: "Cannot render page \(page_number)")
    }

    let pixmap = pixmap_ptr!.pointee

    let data = CFDataCreate(
      nil, pixmap.samples,
      Int(pixmap.w) * Int(pixmap.h) * Int(pixmap.n))

    let data_provider = CGDataProvider.init(
      data: data!)

    let image = CGImage(
      width: Int(pixmap.w), height: Int(pixmap.h), bitsPerComponent: 8,
      bitsPerPixel: Int(pixmap.n) * 8,
      bytesPerRow: Int(pixmap.stride),
      space: CGColorSpace.init(name: CGColorSpace.sRGB)!,
      bitmapInfo: CGBitmapInfo.byteOrderDefault,
      provider: data_provider!,
      decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
    if image == nil {
      throw MuPDFError.PageRenderingError(message: "Cannot create CGImage for page \(page_number)")
    }
    return image!
  }

  deinit {
    if self.doc != nil { fz_drop_document(self.ctx, self.doc) }
    fz_drop_context(self.ctx)
  }
}
