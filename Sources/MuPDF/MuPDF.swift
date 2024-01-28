// The Swift Programming Language
// https://docs.swift.org/swift-book

import CMuPDF
import Foundation
import System

public enum MuPDFError : Error {
  case InitError(message: String)
  case DocReadError(message: String)
}

class PDF{
  
  private let ctx: UnsafeMutablePointer<fz_context>!;
  private var doc: UnsafeMutablePointer<fz_document>!;

  init() throws {
    self.ctx = fz_new_context_imp(nil,nil , FZ_STORE_UNLIMITED,FZ_VERSION );
      if (self.ctx == nil)
      {
        throw MuPDFError.InitError(message: "Cannot init context")
      }
  }

  @available(macOS 11, *)
  public func openDoc(path: FilePath) throws{
    path.withCString{
      self.doc = fz_open_document(self.ctx, $0)
    }
    if (self.doc == nil){
      throw MuPDFError.DocReadError(message: "Cannot read document \(path)")
    }
  }

  public var pageCount : UInt64 { 
    get {
      UInt64(fz_count_pages(self.ctx, self.doc))
    }
  }

  deinit{
    if (self.doc != nil) {fz_drop_document(self.ctx, self.doc)}
    fz_drop_context(self.ctx)
  }
}
