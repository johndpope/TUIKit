//
//          File:   TUIScreen.swift
//    Created by:   African Swift

import Darwin

public struct TUIWindow {
  /// TTY Window Origin
  public private(set) var origin: TUIVec2
  
  /// Initialized size
  public private(set) var size: TUIWindowSize
  public var invalidate: Bool
  private var buffer: TUIView
  private var views = [TUIView]()
  private var backbuffer: TUIView
  
  /// Flat array of active buffer cell indexes
  internal var activeIndex: [(x: Int, y: Int, type: TUICharacter.Category)] {
    return self.buffer.activeIndex
  }
  
  /// Default initializer
  public init?()
  {
    guard let size = TUIWindow.ttysize(), let position = Ansi.Window.Report.position()
      else { return nil }

    self.origin = position
    self.size = size
    
    self.invalidate = true
    
    let viewParam = TUIView.Parameter(border: .none)
    self.buffer = TUIView(
      x: 0,
      y: 0,
      width: Int(size.pixel.width),
      height: Int(size.pixel.width),
      parameters: viewParam)
    
    self.backbuffer = self.buffer
  }
  
  private struct TTYSize  {
    private let rows: UInt16
    private let columns: UInt16
    private let width: UInt16
    private let height: UInt16
    
    func toTUIWindowSize() -> TUIWindowSize
    {
      return TUIWindowSize(columns: Int(self.columns), rows: Int(self.rows))
    }
  }
  
  /// Get Current Terminal Size
  /// TTY Window Size: IOCTL (TIOCGWINSZ)
  ///
  /// - returns: TUIWindowSize?
  public static func ttysize() -> TUIWindowSize?
  {
    guard let ttySize = UnsafeMutablePointer<Int32>(malloc(sizeof(TTYSize)))
      else { return nil }
    defer { free(ttySize) }
    Swift_ioctl(0, S_TIOCGWINSZ, ttySize)
    return UnsafeMutablePointer<TTYSize>(ttySize)[0].toTUIWindowSize()
  }
  
  
  
  public mutating func move(x: Int, y: Int)
  {
    Ansi.Window.move(x: x, y: y).stdout()
    self.origin = TUIVec2(x: x, y: y)
  }
}
