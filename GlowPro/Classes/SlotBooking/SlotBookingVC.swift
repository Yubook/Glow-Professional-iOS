//
//  SlotBookingVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import FSCalendar

class SlotBookingVC: ParentViewController {
    @IBOutlet weak var calenderView : FSCalendar!
    @IBOutlet weak var calanderHegiht : NSLayoutConstraint!
    var arrSlots : [AvailableSlots] = []
    var arrDays : [String] = []
    var arrSelectedDates : [SelectedDates] = []
    var pararmComonDict : [String:Any] = [:]
    var selectDate : Date?
    var isFromHome = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTimeSlots()
        prepareUI()
    }
}

//MARK:- Others Methods
extension SlotBookingVC{
    func prepareUI(){
        arrDays.append(contentsOf: ["Morning Availability","Afternoon Availability","Evening Availability","Night Availability"])
        self.calenderView.scope = .week
        
        calenderView.locale = Locale.current
        calenderView.placeholderType = .none
        calenderView.scope = .week
        calenderView.scrollDirection = .vertical
        calenderView.clipsToBounds = true
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 80, right: 0)
    }
    
    
    func paramDictArray(selectedData: [AvailableSlots], selectedDate : [SelectedDates]) -> [String: Any]{
        var arrDict : [String:Any] = [:]
        for (idx,data) in selectedData.enumerated(){
            arrDict["time_id[" + "\(idx)" + "]"] = Int(data.id)!
        }
        if selectedDate.isEmpty{
            arrDict["date[" + "\(0)" + "]"] = getDate()
        }else{
            for (idx, data) in selectedDate.enumerated(){
                arrDict["date[" + "\(idx)" + "]"] = data.strDate
                arrDict["date[" + "\(idx + 1)" + "]"] = getDate()
            }
        }
        return arrDict
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton){
        let selectedTimes = arrSlots.filter{$0.isSelected}
        let selectedDates = arrSelectedDates.filter{$0.isSelected}
        let dict = paramDictArray(selectedData: selectedTimes, selectedDate: selectedDates)
        if !selectedTimes.isEmpty{
            self.addSlots(param: dict)
        }else{
            self.showError(msg: kSelectedTime)
        }
    }
}

//MARK:- FSCalander Delegate Methods
extension SlotBookingVC : FSCalendarDelegate,FSCalendarDataSource{
    func minimumDate(for calendar: FSCalendar) -> Date {
        return calendar.today ?? Date()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calanderHegiht.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selDate = getDate(dates: date)
        let objDate = SelectedDates(date: Date.dateFromAppServerFormatDeshFormat(from: selDate)!, str: selDate)
        objDate.isSelected.toggle()
        self.arrSelectedDates.append(objDate)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectedDt = Date.localDateNewString(from: date)
        if let selectedDate = Date.dateFromAppServerFormatDeshFormat(from: selectedDt){
            for (_,obj) in arrSelectedDates.enumerated(){
                if selectedDate == obj.dates || selectedDt == obj.strDate{
                    obj.isSelected = false
                }
            }
        }
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension SlotBookingVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrDays.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SlotBookingTblCell
        view.lblSection.text = arrDays[section]
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SlotBookingTblCell
        cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! SlotBookingTblCell
        cell.parentVC = self
        cell.strDays = arrDays[indexPath.section]
        cell.timesCollView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        cell.timesCollView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.widthRatio
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.widthRatio
    }
}

//MARK:- Get Times Web Call Methods
extension SlotBookingVC{
    func getTimeSlots(){
        showHud()
        KPWebCall.call.getTimes(param: [:]) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200, let arrDict = dict["result"] as? [NSDictionary]{
                weakSelf.hideHud()
                for dictData in arrDict{
                    var staticDict : [String:Any] = [:]
                    staticDict = dictData as! [String : Any]
                    staticDict["section"] = weakSelf.getDay(timeData: dictData["time"] as! String)
                    let objData = AvailableSlots(dict: staticDict as NSDictionary)
                    weakSelf.arrSlots.append(objData)
                }
                print(weakSelf.arrSlots.filter{$0.section == "Morning Availability"}.count)
                weakSelf.tableView.reloadData()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
    
    func getDay(timeData : String) -> String{
        var newTime = ""
        var times = timeData.prefix(2)
        if times.contains(":"){
            times.removeLast()
            newTime = String(times)
        }
        let strTime = Int(newTime == "" ? String(times) : newTime) ?? 0
        switch strTime {
        case 6..<12 :
            return "Morning Availability"
        case 12..<17 :
            return "Afternoon Availability"
        case 17..<22 :
            return "Evening Availability"
        default:
            return "Night Availability"
        }
    }
}

//MARK:- Add Selected Slots WebCall Methods
extension SlotBookingVC{
    func addSlots(param: [String:Any]){
        showHud()
        KPWebCall.call.addSlots(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.showSuccMsg(dict: dict) {
                    _user.isAvailblity = true
                    _appDelegator.saveContext()
                    _appDelegator.navigateUserToHome()
                }
                if weakSelf.isFromHome{
                    weakSelf.navigationController?.popViewController(animated: true)
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
    
    
    func getDate(dates: Date = Date()) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: dates)
    }
}
