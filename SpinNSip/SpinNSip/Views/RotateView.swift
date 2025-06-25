//
//  RotateView.swift
//  SpinNSip
//
//  Created by Aiden on 2025/4/25.
//

import SwiftUI

struct RotateView: View {
    @State private var rotation: Angle = .zero
    @State private var isSpinning = false
    @State private var selectedIndex: Int? = nil
    @State private var highlight = false
    
    let segmentCount = 8
    let labels = ["🍎", "🍊", "🍋", "🍐", "🍇", "🍉", "🥝", "🍒"]
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan]
    
    var anglePerSegment: Double {
        360.0 / Double(segmentCount)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Background()
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2 - 20
                    
//                    context.translateBy(x: center.x, y: center.y)
//                    context.rotate(by: Angle(radians: rotation.radians))
//                    context.translateBy(x: -center.x, y: -center.y)
                    
                    let anglePerSegmentRadians = 2 * .pi / CGFloat(segmentCount)
                    
                    for i in 0..<segmentCount {
                        let startAngle = CGFloat(i) * anglePerSegmentRadians
                        let endAngle = startAngle + anglePerSegmentRadians
                        
                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: radius,
                                    startAngle: .radians(startAngle),
                                    endAngle: .radians(endAngle),
                                    clockwise: false)
                        
                        let isSelected = (i == selectedIndex)
                        let opacity = highlight && isSelected ? 0.0 : 1.0
                        let fillColor: Color = isSelected ? .white.opacity(opacity) : colors[i % colors.count]
                        context.fill(path, with: .color(fillColor))
                        
                        let midAngle = (startAngle + endAngle) / 2
                        let text = Text(labels[i % labels.count])
                            .font(.system(size: 20))
                            .foregroundColor(isSelected ? .black : .primary)
                        let resolved = context.resolve(text)
                        let textPoint = CGPoint(
                            x: center.x + cos(midAngle) * (radius * 0.65) - resolved.measure(in: size).width / 2,
                            y: center.y + sin(midAngle) * (radius * 0.65) - resolved.measure(in: size).height / 2
                        )
                        context.draw(resolved, at: textPoint)
                    }
                }
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .shadow(radius: 10)
                .rotationEffect(rotation)
                .onTapGesture {
                    spinWheel()
                }
                
                Triangle()
                    .fill(Color.black)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(180))
                    .offset(y: -170)
            }
            
            if let selectedIndex = selectedIndex {
                Text("🎉 中獎：\(labels[selectedIndex]) (第 \(selectedIndex + 1) 塊)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            // 啟動閃爍動畫
            withAnimation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                highlight.toggle()
            }
        }
    }
    
    func spinWheel() {
        guard !isSpinning else { return }
        
        isSpinning = true
        highlight = false
        selectedIndex = nil
        
        let randomAngle = Double.random(in: 0..<360)
        let fullRotations = 5 * 360.0
        let totalAngle = fullRotations + randomAngle
        
        withAnimation(.easeOut(duration: 3.0)) {
            rotation += Angle(degrees: totalAngle)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let degree = rotation.degrees.truncatingRemainder(dividingBy: 360)
            // 額外修正 90 度
            let correctedDegrees = normalizeAngle(360 - degree - 90)
            let index = Int(correctedDegrees / anglePerSegment) % segmentCount
            selectedIndex = index
            
            isSpinning = false
        }
    }
    
    // 修正度數為負數問題
    func normalizeAngle(_ angle: Double) -> Double {
        return angle >= 0 ? angle : angle + 360
    }

}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Background: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(AngularGradient(colors: [.teal, .pink, .teal], center: .center, angle: .degrees(isAnimating ? 360 : 0)))
            .frame(width: 300, height: 300)
            .blur(radius: 50)
            .onAppear() {
                withAnimation(Animation.linear(duration: 7).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct RotateView_Previews: PreviewProvider {
    static var previews: some View {
        RotateView()
    }
}
