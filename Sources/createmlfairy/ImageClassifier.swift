//
//  TextClassifier.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import CreateML
import SwiftCLI

class ImageClassifier: Command {
    let name = "image-classifier"
    let shortDescription = "Create a machine learning model that has been trained to recognize images. When you give it an image, it responds with a label for that image."
	
	let inputDataDirectory = Parameter()
	
	let target = Key<String>("--target", description: "Column name from tabular dataset to be used as the target")
	let features = Key<String>("--features", description: "List of comma separated of column names from the tabular dataset to be used as the features.")
	
	let validation = Key<String>("--validation", description: "Path to validation dataset")
	let test = Key<String>("--test", description: "Path to test dataset")
	
	let iterations = Key<Int>("--maximum-iterations")
	let batchSize = Key<Int>("--batch-size")
	
	let output = Key<String>("--output", description: "Path to output CoreML file (.mlmodel)")
	let author = Key<String>("--model-author", description: "Used with --output, sets the 'Author name' in output model")
	let license = Key<String>("--model-license", description: "Used with --output, sets the 'License' in output model")
	let modelDescription = Key<String>("--model-description", description: "Used with --output, sets the 'Short Description' in output model")
	let modelVersion = Key<String>("--model-version", description: "Used with --output, sets the 'Version' in output model")
	
	func execute() throws {
		var options = MLImageClassifier.ModelParameters()
		if let validationDatasetDirectory = validation.value {
			options.validation = .dataSource(.labeledDirectories(at: URL(fileURLWithPath: validationDatasetDirectory)))
		}
		
		if let iterations = self.iterations.value {
			options.maxIterations = iterations
		}
		
		let trainingDataDirectory = try Assertions.assertInputDirectory(input: inputDataDirectory.value)
		let dataSource = MLImageClassifier.DataSource.labeledDirectories(at: trainingDataDirectory)
		let testDatasetPath = try Assertions.assertInputDirectory(input: test.value)
		let testDataSource: MLImageClassifier.DataSource = .labeledDirectories(at: testDatasetPath)
		
		let classifier = try MLImageClassifier(trainingData: dataSource, parameters: options)
		
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

extension MLImageClassifier: ModelWritable {
	
}
