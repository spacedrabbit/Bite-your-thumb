//
//  EditBiteView.swift
//  BYT
//
//  Created by Louis Tur on 3/17/24.
//  Copyright © 2024 AccessLite. All rights reserved.
//

import SwiftUI

struct Bite: Identifiable {
	let id: String
	let name: String
	let url: String
	let components: [Nibble]
	
	init(operation: FoaasOperation) {
		self.id = operation.displayName
		self.name = operation.name
		self.url = operation.url
		self.components = []
	}
}

struct Nibble: Identifiable {
	let id: String
	
	let source: FoaasField?
	var text: String
	var isEditable: Bool { source != nil }
	
	var defaultValue: String {
		if let source {
			return source.defaultValue
		} else {
			return text
		}
	}

	init(source: FoaasField) {
		self.id = source.key
		self.source = source
		self.text = source.defaultValue
	}
	
	init(id: String, text: String) {
		self.id = id
		self.source = nil
		self.text = text
	}
}

struct EditBiteView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct EditBiteView_Previews: PreviewProvider {
    static var previews: some View {
        EditBiteView()
    }
}
