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
  
  static func formatDateForAPI(_ date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(identifier: "UTC")
      return formatter.string(from: date)
  }
  
  
  static func isToday(_ date: Date) -> Bool{
    return Calendar.current.isDateInToday(date)
  }
  
  static func formatDateToDayMonth(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM"
    return dateFormatter.string(from: date)
  }
  
  static func Todate(from string: String) -> Date {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.date(from: string)!
  }
  
  
}
