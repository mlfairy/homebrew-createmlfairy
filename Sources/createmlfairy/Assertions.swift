import Foundation
import CreateML

class Assertions {
	public static func dataTable(from pathString: String, with options: MLDataTable.ParsingOptions) throws -> MLDataTable {
		let path = try Assertions.assertInputFile(input: pathString)
		do {
			let dataTable = try MLDataTable(contentsOf: path, options: options)
			return dataTable
		} catch {
			throw MLFError(message: "Failed to read file or folder at \(pathString)", error: error)
		}
	}
	
	public static func assertInputFile(
		input: String?,
		withExtensions extensions: [String] = ["csv", "json"]
	) throws -> URL {
		guard let pathString = input else {
			throw MLFError(message: "No file given")
		}
		
		if pathString.isEmpty {
			throw MLFError(message: "No file name given")
		}
		
		if !FileManager.default.fileExists(atPath: pathString) {
			throw MLFError(message: "File not found '\(pathString)'")
		}
		
		let path = URL(fileURLWithPath: pathString, isDirectory: false)
		if !extensions.contains(path.pathExtension.lowercased()) {
			let supported = extensions.map{ "'.\($0)'" }.joined(separator: " or ")
			throw MLFError(message: "Unsupported file extension '\(path.pathExtension)'. Only \(supported) files supported")
		}
		
		return path
	}
	
	public static func assertInputDirectory(input: String?) throws -> URL {
		guard let pathString = input else {
			throw MLFError(message: "No file given")
		}
		
		if pathString.isEmpty {
			throw MLFError(message: "No file name given")
		}
		
		var isDirectory = ObjCBool(true)
		let exists = FileManager.default.fileExists(atPath: pathString, isDirectory: &isDirectory)
		
		if !exists || !isDirectory.boolValue {
			throw MLFError(message: "File not found '\(pathString)'")
		}
		
		let path = URL(fileURLWithPath: pathString, isDirectory: true)
		
		return path
	}
}
