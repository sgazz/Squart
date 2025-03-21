import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let viewModel: DrawingViewModel
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: UIColor(viewModel.selectedColor), width: viewModel.strokeWidth)
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        
        // Dodaj model poteze
        let modelStrokes = viewModel.modelStrokes
        for stroke in modelStrokes {
            canvasView.drawing.strokes.append(stroke)
        }
        
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        canvasView.tool = PKInkingTool(.pen, color: UIColor(viewModel.selectedColor), width: viewModel.strokeWidth)
        
        // Ažuriraj model poteze
        canvasView.drawing.strokes.removeAll()
        let modelStrokes = viewModel.modelStrokes
        for stroke in modelStrokes {
            canvasView.drawing.strokes.append(stroke)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
            // Implementirati ako je potrebno
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            // Implementirati ako je potrebno
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            // Implementirati ako je potrebno
        }
    }
} 