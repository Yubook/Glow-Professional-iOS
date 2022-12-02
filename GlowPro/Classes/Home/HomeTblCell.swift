//
//  HomeTblCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import Charts

class HomeTblCell: UITableViewCell {
    @IBOutlet weak var homeCollView : UICollectionView!
    @IBOutlet weak var lblSectionTitle : UILabel!
    @IBOutlet weak var lineGraphView : UIView!
    
    var lineChartView = CombinedChartView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//MARK:- Prepare Line Chart View
extension HomeTblCell{
    func prepareCell(data: EnumHome){
        switch data{
        case .revenueCell:
            self.prepareLineCharts()
        default: break
        }
    }
    
    func prepareLineCharts(){
        lineChartView.delegate = self
        lineChartView.frame = CGRect(x: 0 , y: 0, width: lineGraphView.frame.size.width, height: lineGraphView.frame.size.height)
        lineChartView.center = lineGraphView.center
        lineGraphView.addSubview(lineChartView)
        
        var entires  : [ChartDataEntry] = []
        
        for x in 0..<10{
            entires.append( ChartDataEntry(x: Double(x), y: Double(x)))
        }
        let set = LineChartDataSet(entries: entires)
        let data = LineChartData(dataSet: set)
        lineChartView.data = data
    }
}

//MARK:- ChartView Delegate Methods
extension HomeTblCell : ChartViewDelegate{
    
}

//MARK:- CollectionView Delegate & DataSource Methods
extension HomeTblCell : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : HomeCollCell
        
        cell = homeCollView.dequeueReusableCell(withReuseIdentifier: "gallaryCollCell", for: indexPath) as! HomeCollCell
        
        return cell
    }
}

//MARK:- CollectionView DelegateFlow Layout Methods
extension HomeTblCell : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collHeight = 90.widthRatio
        let collWidth = collHeight *  1.34
        
        return CGSize(width: collWidth, height: collHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }
}
