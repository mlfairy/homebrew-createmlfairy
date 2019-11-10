//
//  TabularRegressor.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import CreateML
import SwiftCLI

class TabularClassifier: Command {
	private static let LOGISTIC_REGRESSION = "logistic-regression"
	private static let RANDOM_FOREST = "random-forest"
	private static let BOOSTED_TREE = "boosted-tree"
	private static let DECISION_TREE = "decision-tree"
	private static let SUPPORT_VECTOR = "support-vector-machine"
	
    let name = "tabular-classifier"
    let shortDescription = "Create a machine learning model that has been trained for classification."
	
	let inputFilePath = Parameter()
	let classifier = Key<String>("--algorithm", description: "Algorithm used to train the model (\(RANDOM_FOREST), \(BOOSTED_TREE), \(DECISION_TREE), \(LOGISTIC_REGRESSION), \(SUPPORT_VECTOR)")
	let target = Key<String>("--target", description: "Column name from tabular dataset to be used as the target")
	let features = Key<String>("--features", description: "List of comma separated of column names from the tabular dataset to be used as the features. If no values are given, all columns (excluding the target column), will be used")
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
		guard let target = target.value else {
			throw MLFError(message: "No target given")
		}
		
		let algorithm = classifier.value ?? TabularClassifier.LOGISTIC_REGRESSION
		let features = self.features.value?.split(separator: ",").map {$0.trimmingCharacters(in: .whitespaces)}
		let dataTable = try Assertions.dataTable(from: inputFilePath.value, with: trainingDataTableOptions())
		
		let trainingDataset: MLDataTable
		let testDataset: MLDataTable
		if let testDatasetPath = test.value {
			testDataset = try Assertions.dataTable(from: testDatasetPath, with: testDataTableOptions())
			trainingDataset = dataTable
		} else {
			// TODO: Assert split is between 1-100
			let split = self.split.value ?? 80
			let seed = self.seed.value ?? 5
			let dataSplit = Double(split) / Double(100)
			
			let (evaluationTable, trainingTable) = dataTable.randomSplit(by: dataSplit, seed: seed)
			testDataset = evaluationTable
			trainingDataset = trainingTable
		}
		
		let classifier = try self.performTraining(
			using: algorithm,
			withTrainingData: trainingDataset,
			withTarget: target,
			withFeatures: features
		)
		
		stdout <<< "Performing evaluation..."
		
		let classifierEvaluation = try classifier.evaluation(on: testDataset)
		let evaluationError = classifierEvaluation.classificationError
		let evaluationAccuracy = (1.0 - evaluationError) * 100
		
		stdout <<< "Evaluation error \(evaluationError)\nEvaluation accuracy \(evaluationAccuracy)"
		
		if let output = output.value {
			if output.isEmpty {
				throw MLFError(message: "Output file is empty")
			}
			
			let metadata = MLModelMetadata(
				author: author.value ?? "",
				shortDescription: modelDescription.value ?? "",
				license: license.value ?? "",
				version: modelVersion.value ?? "",
				additional: nil
			)
			
			try classifier.write(toFile: output, metadata: metadata)
		}
    }
	
	private func performTraining(
		using algorithm: String,
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Classifier {
		switch algorithm.lowercased() {
		case TabularClassifier.LOGISTIC_REGRESSION:
			return try self.logisticClassifier(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularClassifier.BOOSTED_TREE:
			return try self.boostedTreeClassifier(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularClassifier.DECISION_TREE:
			return try self.decisionTreeClassifier(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularClassifier.RANDOM_FOREST:
			return try self.randomForestClassifier(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularClassifier.SUPPORT_VECTOR:
			return try self.supportVectorClassifier(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		default:
			throw MLFError(message: "Unknown regressor: \(algorithm)")
		}
	}
	
	private func trainingDataTableOptions() -> MLDataTable.ParsingOptions {
		// TODO Build options from input parameters
		let options = MLDataTable.ParsingOptions()
		return options
	}
	
	private func testDataTableOptions() -> MLDataTable.ParsingOptions {
		// TODO Build options from input parameters
		let options = MLDataTable.ParsingOptions()
		return options
	}
	
	private func validationDataTableOptions() -> MLDataTable.ParsingOptions {
		// TODO Build options from input parameters
		let options = MLDataTable.ParsingOptions()
		return options
	}
	
	private func logisticClassifier(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Classifier {
		// TODO: Build options from parameters
		let options = MLLogisticRegressionClassifier.ModelParameters()
	
		do {
			let classifier = try MLLogisticRegressionClassifier(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Classifier(classifier)
		} catch {
			throw MLFError(message: "Failed to train \(name) with classifier \(TabularClassifier.LOGISTIC_REGRESSION)", error: error)
		}
	}
	
	private func boostedTreeClassifier(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Classifier {
		// TODO: Build options from parameters
		let options = MLBoostedTreeClassifier.ModelParameters()
	
		do {
			let classifier = try MLBoostedTreeClassifier(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Classifier(classifier)
		} catch {
			throw MLFError(message: "Failed to train \(name) with classifier \(TabularClassifier.BOOSTED_TREE)", error: error)
		}
	}
	
	private func decisionTreeClassifier(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Classifier {
		// TODO: Build options from parameters
		let options = MLDecisionTreeClassifier.ModelParameters()
	
		do {
			let classifier = try MLDecisionTreeClassifier(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Classifier(classifier)
		} catch {
			throw MLFError(message: "Failed to train \(name) with classifier \(TabularClassifier.DECISION_TREE)", error: error)
		}
	}
	
	private func randomForestClassifier(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Classifier {
		// TODO: Build options from parameters
		let options = MLRandomForestClassifier.ModelParameters()
	
		do {
			let classifier = try MLRandomForestClassifier(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			
			return Classifier(classifier)
		} catch {
			throw MLFError(message: "Failed to train \(name) with classifier \(TabularClassifier.RANDOM_FOREST)", error: error)
		}
	}
	
	private func supportVectorClassifier(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Classifier {
		// TODO: Build options from parameters
		let options = MLSupportVectorClassifier.ModelParameters()
	
		do {
			let classifier = try MLSupportVectorClassifier(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			
			return Classifier(classifier)
		} catch {
			throw MLFError(message: "Failed to train \(name) with classifier \(TabularClassifier.SUPPORT_VECTOR)", error: error)
		}
	}
}

private class Classifier: ModelWritable {
	private let logistic: MLLogisticRegressionClassifier?
	private let randomForest: MLRandomForestClassifier?
	private let boostedTree: MLBoostedTreeClassifier?
	private let decisionTree: MLDecisionTreeClassifier?
	private let supportVector: MLSupportVectorClassifier?
	
	init(_ logistic: MLLogisticRegressionClassifier) {
		self.logistic = logistic
		self.randomForest = nil
		self.boostedTree = nil
		self.decisionTree = nil
		self.supportVector = nil
	}
	
	init(_ randomForest: MLRandomForestClassifier) {
		self.logistic = nil
		self.randomForest = randomForest
		self.boostedTree = nil
		self.decisionTree = nil
		self.supportVector = nil
	}
	
	init(_ boostedTree: MLBoostedTreeClassifier) {
		self.logistic = nil
		self.randomForest = nil
		self.boostedTree = boostedTree
		self.decisionTree = nil
		self.supportVector = nil
	}
	
	init(_ decisionTree: MLDecisionTreeClassifier) {
		self.logistic = nil
		self.randomForest = nil
		self.boostedTree = nil
		self.decisionTree = decisionTree
		self.supportVector = nil
	}
	
	init(_ supportVector: MLSupportVectorClassifier) {
		self.logistic = nil
		self.randomForest = nil
		self.boostedTree = nil
		self.decisionTree = nil
		self.supportVector = supportVector
	}
	
	@discardableResult
	public func evaluation(on dataset: MLDataTable) throws -> MLClassifierMetrics {
		if let regressor = self.logistic {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.randomForest {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.boostedTree {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.decisionTree {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.supportVector {
			return regressor.evaluation(on: dataset)
		} else {
			throw MLFError(message: "Unknown regressor")
		}
	}
	
	func write(toFile file: String, metadata: MLModelMetadata?) throws {
		if let regressor = self.logistic {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.randomForest {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.boostedTree {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.decisionTree {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.supportVector {
			try regressor.write(toFile: file, metadata: metadata)
		} else {
			throw MLFError(message: "Unknown regressor")
		}
	}
}
