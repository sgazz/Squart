import SwiftUI

struct GameLayout {
    // Fiksne dimenzije okvira table
    static let fixedBoardSize: CGFloat = isPad ? 600 : 340
    
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func sidePanelWidth(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * 0.2
    }
    
    static func boardWidth(for geometry: GeometryProxy) -> CGFloat {
        fixedBoardSize
    }
    
    static var isInSplitView: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return windowScene.interfaceOrientation.isPortrait && 
                   window.frame.width < UIScreen.main.bounds.width
        }
        return false
    }
    
    static var isInSlideOver: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.frame.width < 400
        }
        return false
    }
    
    static func boardScaleFactor(for geometry: GeometryProxy, boardSize: Int) -> CGFloat {
        let availableWidth = geometry.size.width * 0.8
        let availableHeight = geometry.size.height - calculateVerticalPadding()
        
        let widthScale = availableWidth / fixedBoardSize
        let heightScale = availableHeight / fixedBoardSize
        
        // Uzimamo manji scale factor da tabla stane i po širini i po visini
        return min(widthScale, heightScale)
    }
    
    static func iPadScaleFactor(for geometry: GeometryProxy) -> CGFloat {
        if isInSlideOver {
            return 0.7
        } else if isInSplitView {
            return 0.8
        }
        return 1.0
    }
    
    // MARK: - Cell Size Calculation
    
    static func calculateCellSize(
        for geometry: GeometryProxy,
        boardSize: Int,
        isPortrait: Bool
    ) -> CGFloat {
        let cellSize = fixedBoardSize / CGFloat(boardSize)
        let minCellSize: CGFloat = isPad ? 24 : 20
        
        return max(cellSize, minCellSize)
    }
    
    private static func calculateVerticalPadding() -> CGFloat {
        if isPad {
            if isInSlideOver {
                return 160
            } else if isInSplitView {
                return 180
            } else {
                return 200
            }
        } else {
            return 140
        }
    }
} 