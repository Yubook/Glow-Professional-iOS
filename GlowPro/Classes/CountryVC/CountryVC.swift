//
//  CountryVC.swift
//  GlowPro
//
//  Created by MutipzTechnology on 15/10/22.
//  Copyright © 2022 Devang Lakhani. All rights reserved.
//

import UIKit

class CountryVC: ParentViewController {
    var arrCountryList :[CountryList] = []
    var arrSearchList :[CountryList] = []
    var isFromSearch = false
    
    var completionCountrySelection : ((CountryList) -> ()) = {_ in}
    
    @IBOutlet weak var tfCountrySerach: UITextField!
    @IBOutlet weak var btnClearSearch: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnClearSearch.isHidden = true
        tfCountrySerach.addTarget(self, action: #selector(KPSearchLocationVC.searchTextDidChange), for: .editingChanged)
        self.getCountryList()
    }
}

//MARK: - Login Driver WebCall Methods
extension CountryVC {
    func getCountryList(){
        showHud()
        KPWebCall.call.getCountryList(param: [:]) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200, let resObj = dict["result"] as? [NSDictionary]{
                weakSelf.hideHud()
                for objCountry in resObj{
                    let objCountryData = CountryList(dict: objCountry)
                    weakSelf.arrCountryList.append(objCountryData)
                }
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK: - TableView Delegate & DataSource Methods
extension CountryVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFromSearch == true ? arrSearchList.count : arrCountryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CountryTableCell
        
        let objCountryData = isFromSearch == true ? arrSearchList[indexPath.row] : arrCountryList[indexPath.row]
        cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableCell", for: indexPath) as! CountryTableCell
        cell.selectionStyle = .none
        cell.prepareCell(countryObJ: objCountryData, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromSearch {
            self.completionCountrySelection(arrSearchList[indexPath.row])
        } else  {
            self.completionCountrySelection(arrCountryList[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true)
    }
}


extension CountryVC: UITextFieldDelegate {
    
    @IBAction func btnClearSearchTapped(_ sender: UIButton){
        tfCountrySerach.text = ""
        self.searchTextDidChange(textField: tfCountrySerach)
        self.view.endEditing(true)
        isFromSearch = false
    }
    
    @objc func searchTextDidChange(textField: UITextField) {
        if let strSearch = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            if strSearch != "" {
                isFromSearch = true
                arrSearchList = arrCountryList.filter { objCountryList in
                    return objCountryList.countryName.lowercased().contains(find: strSearch.lowercased())
                }
                self.btnClearSearch.isHidden = false
            } else  {
                self.btnClearSearch.isHidden = true
                isFromSearch = false
            }
            tableView.reloadData()
        }
    }

}
