//
//  TestView.swift
//  SpinNSip
//
//  Created by Aiden on 2025/6/5.
//

import SwiftUI

struct SpinningView: View {
    @State private var selectedCocktail: Cocktail?
    @State private var showDetail = false
    let selector = DrinkSelectorActor()
    
    @State private var rotation: Angle = .zero
    @State private var isSpinning = false
    @State private var selectedIndex: Int? = nil
    @State private var blink = false

    let segmentCount = 8
    let labels = ["🍎", "🍊", "🍋", "🍐", "🍇", "🍉", "🥝", "🍒"]
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan]

    var anglePerSegment: Double {
        360.0 / Double(segmentCount)
    }

    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<segmentCount, id: \.self) { i in
                    SegmentView(
                        index: i,
                        total: segmentCount,
                        color: colors[i % colors.count],
                        label: labels[i % labels.count],
                        isHighlighted: (i == selectedIndex && blink)
                    )
                }
                .rotationEffect(rotation)

                Triangle()
                    .fill(Color.black)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(180))
                    .offset(y: -170)
            }
            .frame(width: 300, height: 300)
            .onTapGesture {
                spinWheel()
            }

            if let selectedIndex = selectedIndex {
                Text("🎉 中獎：\(labels[selectedIndex]) (第 \(selectedIndex + 1) 塊)")
                    .font(.title3)
                    .bold()
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                if selectedIndex != nil && !isSpinning {
                    blink.toggle()
                } else {
                    blink = false
                }
            }
            Task {
                try? await selector.loadCocktails()
            }
        }
        .sheet(isPresented: $showDetail) {
            if let cocktail = selectedCocktail {
                CocktailDetailView(cocktail: cocktail)
            }
        }
    }

    func spinWheel() {
        guard !isSpinning else { return }

        isSpinning = true
        selectedIndex = nil

        let randomAngle = Double.random(in: 0..<360)
        let totalRotation = 5 * 360.0 + randomAngle

        withAnimation(.easeOut(duration: 3.0)) {
            rotation += Angle(degrees: totalRotation)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let totalDegrees = rotation.degrees.truncatingRemainder(dividingBy: 360)
            // 額外修正 90 度
            let corrected = normalizeAngle(360 - totalDegrees - 90)
            let index = Int(corrected / anglePerSegment) % segmentCount
            selectedIndex = index
            
            Task {
                if let drink = await selector.specificCocktail(index) {
                    selectedCocktail = drink
                    showDetail = true
                }
            }
            
            isSpinning = false
        }
    }
    
    // 修正度數為負數問題
    func normalizeAngle(_ angle: Double) -> Double {
        return angle >= 0 ? angle : angle + 360
    }
}

struct SegmentView: View {
    let index: Int
    let total: Int
    let color: Color
    let label: String
    let isHighlighted: Bool

    var anglePerSegment: Double {
        360.0 / Double(total)
    }

    var startAngle: Angle {
        Angle(degrees: Double(index) * anglePerSegment)
    }

    var endAngle: Angle {
        Angle(degrees: Double(index + 1) * anglePerSegment)
    }

    var body: some View {
        GeometryReader { geometry in
            let radius = geometry.size.width / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            Path { path in
                path.move(to: center)
                path.addArc(center: center,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false)
            }
            .fill(color)
            .opacity(isHighlighted ? 0.3 : 1.0)
            .overlay(
                Text(label)
                    .font(.system(size: 16))
                    .position(
                        x: center.x + CGFloat(cos((startAngle.radians + endAngle.radians)/2)) * radius * 0.65,
                        y: center.y + CGFloat(sin((startAngle.radians + endAngle.radians)/2)) * radius * 0.65
                    )
            )
            .shadow(color: isHighlighted ? .white : .clear, radius: isHighlighted ? 10 : 0)
            .animation(.easeInOut(duration: 0.5), value: isHighlighted)
        }
    }
}

#Preview {
    SpinningView()
}
