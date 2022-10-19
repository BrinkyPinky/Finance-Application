//
//  outComeChartView.swift
//  financeapp
//
//  Created by Егор Шилов on 19.10.2022.
//

import SwiftUI
import SwiftUICharts

struct outComeChartView: View {
    let viewSize: CGSize
    var chartData: ChartData
    
    var body: some View {
        ZStack {
            Color.init(uiColor: UIColor.systemGroupedBackground)
            BarChartView(
                data: chartData,
                title: "Расходы",
                form: viewSize,
                dropShadow: false,
                valueSpecifier: "%.02f",
                animatedToBack: true
            )
        }
    }
}

struct outComeChartView_Previews: PreviewProvider {
    static var previews: some View {
        outComeChartView(viewSize: CGSize(width: 400, height: 200), chartData: ChartData(values: [
            ("1", 10),
            ("2", 10),
            ("3", 10),
            ("4", 24),
            ("5", 52),
            ("6", 41),
            ("7", 2)
        ]))
    }
}
