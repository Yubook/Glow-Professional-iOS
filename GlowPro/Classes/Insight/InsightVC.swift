//
//  InsightVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import Charts

class InsightVC: ParentViewController {
    @IBOutlet var btns : [UIButton]!
    @IBOutlet weak var barChartView : BarChartView!
    @IBOutlet weak var lblTotalRevenue : UILabel!
    
    var objInsight : Insight?
    var arrTotalRevenue : [PreviousBooking] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getTotalRevenue()
        getRevenueData(param: ["barber_id" : _user.id], completion : {
            self.prepareOneYearBarChart()
        })
    }
}

//MARK:- Others Methods
extension InsightVC{
    func prepareUI(){
        //lblTotalRevenue.text = "Revenue :- " + "£0"
        getNoDataCell()
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func setSelectedButtons(idx: Int){
        for btn in btns{
            btn.backgroundColor = btn.tag == idx ? #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1) : #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 0.8470588235)
        }
    }
    
    func getDataOnButtons(idx: Int){
        let driverId = _user.id
        if idx == 0{
            self.getRevenueData(param: ["barber_id" : driverId,"search" : "1Week"], completion: {
                self.prepareBarChart(idx: idx)
            })
        }else if idx == 1{
            self.getRevenueData(param: ["barber_id" : driverId, "search" : "1Month"], completion: {
                self.prepareBarChart(idx: idx)
            })
        }else if idx == 2{
            self.getRevenueData(param: ["barber_id" : driverId, "search" : "3Month"], completion: {
                self.prepareBarChart(idx: idx)
            })
        }else{
            self.getRevenueData(param: ["barber_id" : driverId, "search" : "6Month"], completion: {
                self.prepareBarChart(idx: idx)
            })
        }
    }
    
    @IBAction func btnMenuTapped(_ sender: UIButton){
        self.setSelectedButtons(idx: sender.tag)
        self.getDataOnButtons(idx: sender.tag)
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension InsightVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrTotalRevenue.isEmpty{
            return 1
        }
        return arrTotalRevenue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arrTotalRevenue.isEmpty{
            let cell : NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
            cell.setText(str: "No Data Available")
            return cell
        }
        let cell : InsightTblCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! InsightTblCell
        cell.prepareCell(data: arrTotalRevenue[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrTotalRevenue.isEmpty{
            return 100.widthRatio
        }
        return 55.widthRatio
    }
}


//MARK:- Get Insight Revenue Data WebCall Methods
extension InsightVC{
    func getRevenueData(param : [String : Any], completion: @escaping (() -> ())){
        showHud()
        KPWebCall.call.getRevenueData(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? NSDictionary{
               // weakSelf.showSuccMsg(dict: dict)
                let insightDict = Insight(dict: result)
                weakSelf.objInsight = insightDict
                completion()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}


//MARK:- Get Driver Revenue Details WebCall Methods
extension InsightVC{
    func getTotalRevenue(){
        showHud()
        KPWebCall.call.getDriverRevenue(param: ["barber_id" : _user.id]) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let res = dict["result"] as? NSDictionary{
                if let arrData = res["data"] as? [NSDictionary]{
                     for dictData in arrData{
                         let revenueDict = PreviousBooking(dict: dictData)
                         weakSelf.arrTotalRevenue.append(revenueDict)
                     }
                }
                weakSelf.tableView.reloadData()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}


//MARK:- Prepare Bar Charts
extension InsightVC{
    func prepareOneYearBarChart(){
        guard let objChartData = objInsight else {return}
        //Prepare Data
        let totalMonths = objChartData.arrYearOne.map{$0.strMonth}
        let totalRevenues = objChartData.arrYearOne.map{$0.revenue}
        let revenue = totalRevenues.map{Int($0)!}
        let total = revenue.reduce(0, +)
        lblTotalRevenue.text = "Apnt. booked :-" + "\(total)"
        let isRevenueZero = totalRevenues.allSatisfy{$0.isEmpty}
        self.barChartView.isHidden = isRevenueZero
        self.setBarCharts(dataPoints: totalMonths, values: totalRevenues, isOneMonthData: false,secDataPoint: nil)
    }
    
    func prepareBarChart(idx : Int){
        guard let objChartData = objInsight else {return}
        //MARK:- 1 Week BarChart
        if idx == 0{
            let totalDates = objChartData.arrWeekOne.map{$0.strDate}
            let totalRevenues = objChartData.arrWeekOne.map{$0.revenue}
            let isRevenueZero = totalRevenues.allSatisfy{$0.isEmpty}
            let revenue = totalRevenues.map{Int($0)!}
            let total = revenue.reduce(0, +)
            lblTotalRevenue.text = "Apnt. booked :-" + "\(total)"
            self.barChartView.isHidden = isRevenueZero
            
            self.setBarCharts(dataPoints: totalDates, values: totalRevenues, isOneMonthData: false,secDataPoint: nil)
            //MARK:- 1 Month BarChart
        } else if idx == 1{
            let totalStartWeek = objChartData.arrMonthOne.map{$0.strCombine}
            let totalEndWeek = objChartData.arrMonthOne.map{$0.strEndWeek}
            
            let totalRevenues = objChartData.arrMonthOne.map{$0.revenue}
            let isRevenueZero = totalRevenues.allSatisfy{$0.isEmpty}
            let revenue = totalRevenues.map{Int($0)!}
            let total = revenue.reduce(0, +)
            lblTotalRevenue.text = "Apnt. booked :-" + "\(total)"
            self.barChartView.isHidden = isRevenueZero
            self.setBarCharts(dataPoints: totalStartWeek, values: totalRevenues, isOneMonthData: true,secDataPoint: totalEndWeek)
            //MARK:- 3 Month BarChart
        }else if idx == 2{
            //Prepare Data
            let totalMonths = objChartData.arrMonthThree.map{$0.strMonth}
            let totalRevenues = objChartData.arrMonthThree.map{$0.revenue}
            let isRevenueZero = totalRevenues.allSatisfy{$0.isEmpty}
            let revenue = totalRevenues.map{Int($0)!}
            let total = revenue.reduce(0, +)
            lblTotalRevenue.text = "Apnt. booked :-" + "\(total)"
            self.barChartView.isHidden = isRevenueZero
            self.setBarCharts(dataPoints: totalMonths, values: totalRevenues, isOneMonthData: false,secDataPoint: nil)
            
            //MARK:- 6 Month BarChart
        }else if idx == 3{
            //Prepare Data
            let totalMonths = objChartData.arrMonthSix.map{$0.strMonth}
            let totalRevenues = objChartData.arrMonthSix.map{$0.revenue}
            let isRevenueZero = totalRevenues.allSatisfy{$0.isEmpty}
            let revenue = totalRevenues.map{Int($0)!}
            let total = revenue.reduce(0, +)
            lblTotalRevenue.text = "Apnt. booked :-" + "\(total)"
            self.barChartView.isHidden = isRevenueZero
            self.setBarCharts(dataPoints: totalMonths, values: totalRevenues, isOneMonthData: false,secDataPoint: nil)
        }
    }
}


//MARK:- BarCharts Methods
extension InsightVC{
    func setBarCharts(dataPoints : [String], values : [String], isOneMonthData : Bool, secDataPoint : [String]?){
        //No Data Setup
        barChartView.noDataTextColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        barChartView.noDataText = "Please Wait Chart is Loading"
        
        //Axis Setup
        let xAxis = barChartView.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.granularityEnabled = true
        if isOneMonthData, let secondArr = secDataPoint{
            xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints + ["-"] + secondArr)
        }
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        xAxis.labelWidth = 40.0
        barChartView.xAxis.granularity = 1
        barChartView.rightAxis.enabled = false
        
        
        let yaxis = barChartView.leftAxis
        yaxis.drawZeroLineEnabled = true
        yaxis.spaceTop = 0
        barChartView.rightAxis.enabled = false
        
        // Data Setup
        var revenueEntries : [BarChartDataEntry] = []
        for i in 0 ..< dataPoints.count{
            let data = BarChartDataEntry(x: Double(i) , y: Double(values[i]) ?? 0.0)
            revenueEntries.append(data)
        }
        
        if isOneMonthData{
            guard let secPoint = secDataPoint else {return}
            var revenueEntries : [BarChartDataEntry] = []
            for i in 0 ..< dataPoints.count{
                let data = BarChartDataEntry(x: Double(i) , y: Double(values[i]) ?? 0.0)
                revenueEntries.append(data)
            }
            
            for i in 0 ..< secPoint.count{
                let data = BarChartDataEntry(x: Double(i) , y: Double(values[i]) ?? 0.0)
                revenueEntries.append(data)
            }
        }
        
        let chartDataSet = BarChartDataSet(entries: revenueEntries, label: "Total Revenue")
        chartDataSet.colors = [#colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)]
        chartDataSet.drawValuesEnabled = false
        let chartData = BarChartData(dataSet: chartDataSet)
        
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        let startVal = 0
        
        chartData.barWidth = barWidth
        chartData.groupBars(fromX: Double(startVal), groupSpace: groupSpace, barSpace: barSpace)
        
        // chartData.barWidth = 5.0
        if isOneMonthData, let arrSec = secDataPoint{
            barChartView.xAxis.labelCount = arrSec.count
        }
        barChartView.xAxis.labelCount = dataPoints.count
        let data = BarChartData(dataSet: chartDataSet)
        chartDataSet.formLineWidth = CGFloat(barWidth)
        
        barChartView.legend.enabled = false
        barChartView.data = data
        barChartView.xAxis.labelTextColor = .black
        barChartView.dragEnabled = true
        barChartView.animate(xAxisDuration: 1.0)
        barChartView.notifyDataSetChanged()
    }
}
