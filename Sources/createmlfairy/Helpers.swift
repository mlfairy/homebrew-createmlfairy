import Foundation
import CoreML
import CreateML

class Helpers {
	static func write(
		with writer: ModelWritable,
		output: String?,
		author: String?,
		description: String?,
		version: String?,
		license: String?
	) throws {
		if let output = output {
			if output.isEmpty {
				throw MLFError(message: "Output file is empty")
			}
			
			let metadata = MLModelMetadata(
				author: author ?? "",
				shortDescription: description ?? "",
				license: license,
				version: version ?? "",
				additional: nil
			)
			
			try writer.write(toFile: output, metadata: metadata)
		}
	}
}
