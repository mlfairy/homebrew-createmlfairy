import Foundation
import CreateML

protocol ModelWritable {
	func write(toFile file: String, metadata: MLModelMetadata?) throws
}
