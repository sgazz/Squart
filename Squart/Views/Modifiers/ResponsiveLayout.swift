import SwiftUI

struct ResponsiveLayout: ViewModifier {
    let geometry: GeometryProxy
    let isPortrait: Bool
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var isSmallDevice: Bool {
        geometry.size.width < 375
    }
    
    private var isLargeDevice: Bool {
        geometry.size.width > 428
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleFactor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
    }
    
    private var scaleFactor: CGFloat {
        if isIPad {
            return isPortrait ? 1.2 : 1.0
        } else if isSmallDevice {
            return 0.9
        } else if isLargeDevice {
            return 1.1
        }
        return 1.0
    }
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return isPortrait ? 40 : 20
        }
        return 16
    }
    
    private var verticalPadding: CGFloat {
        if isIPad {
            return isPortrait ? 20 : 10
        }
        return 8
    }
}

extension View {
    func responsive(geometry: GeometryProxy, isPortrait: Bool) -> some View {
        modifier(ResponsiveLayout(geometry: geometry, isPortrait: isPortrait))
    }
} 