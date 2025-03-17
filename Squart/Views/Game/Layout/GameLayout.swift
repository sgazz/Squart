import SwiftUI

struct GameLayout {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func sidePanelWidth(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * (isInSplitView ? 0.2 : 0.15)
    }
    
    static func boardWidth(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * (isInSplitView ? 0.6 : 0.7)
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
        // Za iPhone
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch boardSize {
            case 5...7:
                return 1.0
            case 8...10:
                return 0.9
            case 11...13:
                return 0.8
            default:
                return 0.7
            }
        }
        
        // Za iPad
        return iPadScaleFactor(for: geometry)
    }
    
    static func iPadScaleFactor(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        // Različiti faktori za različite iPad modele
        switch screenWidth {
        case 1024: // iPad 9.7" i 10.2"
            return isInSplitView ? 0.8 : 1.0
        case 1112: // iPad Pro 10.5"
            return isInSplitView ? 0.85 : 1.1
        case 1180: // iPad Pro 11"
            return isInSplitView ? 0.9 : 1.2
        case 1366: // iPad Pro 12.9"
            return isInSplitView ? 0.95 : 1.3
        default:
            return 1.0
        }
    }
    
    // MARK: - Cell Size Calculation
    
    static func calculateCellSize(
        for geometry: GeometryProxy,
        boardSize: Int,
        isPortrait: Bool
    ) -> CGFloat {
        let horizontalPadding = calculateHorizontalPadding()
        let verticalPadding = calculateVerticalPadding()
        
        let availableWidth = geometry.size.width - (isPortrait ? horizontalPadding : geometry.size.width * (isInSplitView ? 0.5 : 0.4))
        let availableHeight = geometry.size.height - (isPortrait ? verticalPadding : 80)
        
        let maxCellsInRow = CGFloat(boardSize)
        let (maxCellSize, minCellSize) = calculateCellSizeLimits()
        
        let scaleFactor = iPadScaleFactor(for: geometry)
        let desiredCellSize = isPortrait ? 
            min(availableWidth / maxCellsInRow, maxCellSize) :
            min(min(availableHeight / maxCellsInRow, availableWidth / maxCellsInRow), maxCellSize)
        
        return max(desiredCellSize, minCellSize) * scaleFactor
    }
    
    private static func calculateHorizontalPadding() -> CGFloat {
        if isPad {
            if isInSlideOver {
                return 20
            } else if isInSplitView {
                return 40
            } else {
                return 60
            }
        } else {
            return 40
        }
    }
    
    private static func calculateVerticalPadding() -> CGFloat {
        if isPad {
            if isInSlideOver {
                return 160
            } else if isInSplitView {
                return 180
            } else {
                return 240
            }
        } else {
            return 200
        }
    }
    
    private static func calculateCellSizeLimits() -> (max: CGFloat, min: CGFloat) {
        if isPad {
            if isInSlideOver {
                return (45, 25)
            } else if isInSplitView {
                return (50, 30)
            } else {
                return (60, 35)
            }
        } else {
            return (50, 30)
        }
    }
} 