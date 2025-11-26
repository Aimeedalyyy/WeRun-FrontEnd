//
//  DateHelpers.swift
//  WeRun
//
//  Created by Aimee Daly on 25/11/2025.
//
import Foundation

class DateHelpers {
  //TODO: add date formatters for [2025-07-14T23:00:00+0000 -> July 14th] and [July 14th -> 2025-07-14T23:00:00+0000]
  
  static func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy"
    return dateFormatter.string(from: date)
  }
  
  
  static func isToday(_ date: Date) -> Bool{
    return Calendar.current.isDateInToday(date)
  }
  
  
}
