//
//  TabularRegressor.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import CreateML
import SwiftCLI

class TabularRegressor: Command {
	private static let LINEAR_REGRESSION = "linear-regression"
	private static let RANDOM_FOREST = "random-forest"
	private static let BOOSTED_TREE = "boosted-tree"
	private static let DECISION_TREE = "decision-tree"
	
    let name = "tabular-regressor"
    let shortDescription = "Create a machine learning model that has been trained for regression."
	
	let inputFilePath = Parameter()
	let regressor = Key<String>("--algorithm", description: "Algorithm used to train the model (\(RANDOM_FOREST), \(BOOSTED_TREE), \(DECISION_TREE), \(LINEAR_REGRESSION)")
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
		
		let algorithm = regressor.value ?? TabularRegressor.LINEAR_REGRESSION
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
		
		let regressor = try self.performTraining(
			using: algorithm,
			withTrainingData: trainingDataset,
			withTarget: target,
			withFeatures: features
		)
		
		try regressor.evaluate(on: testDataset)
		
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
			
			try regressor.write(toFile: output, metadata: metadata)
		}
	}
	
	private func performTraining(
		using algorithm: String,
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Regressor {
		// (random-forest, boosted-tree, decision-tree, linear-regression)
		switch algorithm.lowercased() {
		case TabularRegressor.LINEAR_REGRESSION:
			return try self.linearRegression(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularRegressor.BOOSTED_TREE:
			return try self.boostedTreeRegression(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularRegressor.DECISION_TREE:
			return try self.decisionTreeRegression(
				withTrainingData: trainingData,
				withTarget: target, withFeatures: features
			)
		case TabularRegressor.RANDOM_FOREST:
			return try self.randomForestRegression(
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
	
	private func linearRegression(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Regressor {
		// TODO: Build options from parameters
		let options = MLLinearRegressor.ModelParameters()
	
		do {
			let regressor = try MLLinearRegressor(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Regressor(regressor)
		} catch {
			throw MLFError(message: "Failed to train \(name) with regressor \(TabularRegressor.LINEAR_REGRESSION)", error: error)
		}
	}
	
	private func boostedTreeRegression(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Regressor {
		// TODO: Build options from parameters
		let options = MLBoostedTreeRegressor.ModelParameters()
	
		do {
			let regressor = try MLBoostedTreeRegressor(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Regressor(regressor)
		} catch {
			throw MLFError(message: "Failed to train \(name) with regressor \(TabularRegressor.BOOSTED_TREE)", error: error)
		}
	}
	
	private func decisionTreeRegression(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Regressor {
		// TODO: Build options from parameters
		let options = MLDecisionTreeRegressor.ModelParameters()
	
		do {
			let regressor = try MLDecisionTreeRegressor(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Regressor(regressor)
		} catch {
			throw MLFError(message: "Failed to train \(name) with regressor \(TabularRegressor.DECISION_TREE)", error: error)
		}
	}
	
	private func randomForestRegression(
		withTrainingData trainingData: MLDataTable,
		withTarget target: String,
		withFeatures features: [String]?
	) throws -> Regressor {
		// TODO: Build options from parameters
		let options = MLRandomForestRegressor.ModelParameters()

		do {
			let regressor = try MLRandomForestRegressor(
				trainingData: trainingData,
				targetColumn: target,
				featureColumns: features,
				parameters: options
			)
			return Regressor(regressor)
		} catch {
			throw MLFError(message: "Failed to train \(name) with regressor \(TabularRegressor.RANDOM_FOREST)", error: error)
		}
	}
}

private class Regressor: ModelWritable {
	private let linear: MLLinearRegressor?
	private let randomForest: MLRandomForestRegressor?
	private let boostedTree: MLBoostedTreeRegressor?
	private let decisionTree: MLDecisionTreeRegressor?
	
	init(_ linear: MLLinearRegressor) {
		self.linear = linear
		self.randomForest = nil
		self.boostedTree = nil
		self.decisionTree = nil
	}
	
	init(_ randomForest: MLRandomForestRegressor) {
		self.linear = nil
		self.randomForest = randomForest
		self.boostedTree = nil
		self.decisionTree = nil
	}
	
	init(_ boostedTree: MLBoostedTreeRegressor) {
		self.linear = nil
		self.randomForest = nil
		self.boostedTree = boostedTree
		self.decisionTree = nil
	}
	
	init(_ decisionTree: MLDecisionTreeRegressor) {
		self.linear = nil
		self.randomForest = nil
		self.boostedTree = nil
		self.decisionTree = decisionTree
	}
	
	@discardableResult
	public func evaluate(on dataset: MLDataTable) throws -> MLRegressorMetrics {
		if let regressor = self.linear {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.randomForest {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.boostedTree {
			return regressor.evaluation(on: dataset)
		} else if let regressor = self.decisionTree {
			return regressor.evaluation(on: dataset)
		} else {
			throw MLFError(message: "Unknown regressor")
		}
	}
	
	func write(toFile file: String, metadata: MLModelMetadata?) throws {
		if let regressor = self.linear {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.randomForest {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.boostedTree {
			try regressor.write(toFile: file, metadata: metadata)
		} else if let regressor = self.decisionTree {
			try regressor.write(toFile: file, metadata: metadata)
		} else {
			throw MLFError(message: "Unknown regressor")
		}
	}
}
