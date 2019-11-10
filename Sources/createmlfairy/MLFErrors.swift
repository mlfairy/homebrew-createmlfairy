//
//  Errors.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import SwiftCLI

public struct MLFError: ProcessError {
	public let message: String?
    public let exitStatus: Int32
    public init(
		message: String,
		error: Error? = nil,
		exitStatus: Int32 = 1
	) {
		var output = "\nError: " + message + "\n"
		if let error = error {
			output += ": \(error)"
		}
		
		self.message = output
        self.exitStatus = exitStatus
    }
}
