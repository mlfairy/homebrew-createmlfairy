//
//  TextClassifier.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import CreateML
import SwiftCLI

class TextClassifier: Command {
	private static let MAXIMUM_ENTROPY = "maximum-entropy"
	private static let CONDITIONAL_RANDOM_FIELD = "conditional-random-field"
	private static let TRANSFER_LEARNING = "transfer-learning"
	
	private static let DYNAMIC_EMBEDDED = "dynamic-embedding"
	private static let STATIC_EMBEDDED = "static-embedding"
	
    let name = "text-classifier"
    let shortDescription = "Create a machine learning model that has been trained to recognize text."
	
	let inputDataDirectory = Parameter()
	
	let algorithm = Key<String>("--algorithm", description: "Algorithm used to train the model (\(TRANSFER_LEARNING), \(MAXIMUM_ENTROPY), \(CONDITIONAL_RANDOM_FIELD))")
	let transferLearningOption = Key<String>("--feature-extractor", description: "Feature Extractor used if --algorithm is \(TRANSFER_LEARNING) (\(DYNAMIC_EMBEDDED) or \(STATIC_EMBEDDED))")
	
	let validation = Key<String>("--validation", description: "Path to validation dataset")
	let test = Key<String>("--test", description: "Path to test dataset")
	let split = Key<Int>("--train-test-split", description: "Percentage of data from training dataset that should be used for testing the model (0-100%)")
	let seed = Key<Int>("--train-test-seed", description: "Seed used for train-test-split")
	
	let output = Key<String>("--output", description: "Path to output CoreML file (.mlmodel)")
	let author = Key<String>("--model-author", description: "Used with --output, sets the 'Author name' in output model")
	let license = Key<String>("--model-license", description: "Used with --output, sets the 'License' in output model")
	let modelDescription = Key<String>("--model-description", description: "Used with --output, sets the 'Short Description' in output model")
	let modelVersion = Key<String>("--model-version", description: "Used with --output, sets the 'Version' in output model")
	
	func execute() throws {
		var options = MLTextClassifier.ModelParameters()
		
		let algorithm = self.algorithm.value ?? TextClassifier.TRANSFER_LEARNING
		let featureExtractor = self.transferLearningOption.value ?? TextClassifier.DYNAMIC_EMBEDDED
		if algorithm == TextClassifier.TRANSFER_LEARNING {
			if featureExtractor == TextClassifier.DYNAMIC_EMBEDDED {
				options.algorithm = .transferLearning(.dynamicEmbedding, revision: nil)
			} else if featureExtractor == TextClassifier.STATIC_EMBEDDED {
				options.algorithm = .transferLearning(.staticEmbedding, revision: nil)
			} else {
				throw MLFError(message: "Unknown feature extractor \(featureExtractor)")
			}
		} else if algorithm == TextClassifier.MAXIMUM_ENTROPY {
			options.algorithm = .maxEnt(revision: nil)
		} else if algorithm == TextClassifier.CONDITIONAL_RANDOM_FIELD {
			options.algorithm = .crf(revision: nil)
		} else {
			throw MLFError(message: "Unsupported algorithm \(algorithm)")
		}
		
		if let validationDatasetDirectory = validation.value {
			options.validation = .dataSource(.labeledDirectories(at: URL(fileURLWithPath: validationDatasetDirectory)))
		}
		
		let trainingDataDirectory = try Assertions.assertInputDirectory(input: inputDataDirectory.value)
		let dataSource = MLTextClassifier.DataSource.labeledDirectories(at: trainingDataDirectory)
		let testDatasetPath = try Assertions.assertInputDirectory(input: test.value)
		let testDataSource: MLTextClassifier.DataSource = .labeledDirectories(at: testDatasetPath)
		
		let classifier = try MLTextClassifier(trainingData: dataSource, parameters: options)
		
		stdout <<< "Performing evaluation..."
		let evaluationMetrics = classifier.evaluation(on: testDataSource)
		let trainingAccuracy = (1.0 - classifier.trainingMetrics.classificationError) * 100
		let validationAccuracy = (1.0 - classifier.validationMetrics.classificationError) * 100
		let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
		stdout <<< "Training accuracy \(trainingAccuracy)"
		stdout <<< "Validation accuracy \(validationAccuracy)"
		stdout <<< "Test accuracy \(evaluationAccuracy)"
		
		try Helpers.write(
			with: classifier,
			output: output.value,
			author: author.value,
			description: modelDescription.value,
			version: modelVersion.value,
			license: license.value
		)
	}
}

extension MLTextClassifier: ModelWritable {
	
}
