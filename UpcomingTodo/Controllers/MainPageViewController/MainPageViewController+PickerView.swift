//
//  MainPageViewController+PickerView.swift
//  Todo
//
//  Created by turu on 2021/03/19.
//

import UIKit

extension MainPageViewController: UIPickerViewDelegate,
                                  UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("numberOfRowsInComponent] component=\(pickerDataList.count)")
        return self.pickerDataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("pickerView] titleForRow=\(row)")
        return self.pickerDataList[row].title ?? "None".localized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerView] didSelectRow=\(row)")
        self.pickerViewSelectedRow = row
    }
    
}
