import Foundation
import System

public enum MuPDFError: Error {
  case InitError(message: String)
  case DocReadError(message: String)
  case InvalidPageNum(message: String)
  case PageRenderingError(message: String)
}
