//
//  StatusTextStyle.swift
//  Jukebox
//
//  Created by Florian Winkler on 02.08.23.
//

import Foundation
import SwiftUI

enum StatusTextStyle: String, CaseIterable {
    case titleWithArtist = "Icon, Title and Artist"
    case onlyTitle = "Icon and Title"
    case onlyIcon = "Only Icon"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
