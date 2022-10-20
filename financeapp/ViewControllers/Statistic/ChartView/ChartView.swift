//
//  ChartView.swift
//  financeapp
//
//  Created by Егор Шилов on 20.10.2022.
//

import SwiftUI
import SwiftUICharts

struct ChartView: View {
    let size: CGSize
    let chartData: ChartData
    
    var body: some View {
        ZStack {
            Color.init(uiColor: UIColor.systemGroupedBackground)
            BarChartView(
                data: chartData,
                title: "Потрачено за 7 дней",
                form: size,
                dropShadow: false,
                valueSpecifier: "%.02f",
                animatedToBack: true
            )
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(
            size: CGSize(width: 350, height: 200),
            chartData: ChartData(values: [("qwr", 1),("qwr", 1),("qwr", 1),("qwr", 1),("qwr", 1),("qwr", 1),("qwr", 1)])
        )
    }
}
