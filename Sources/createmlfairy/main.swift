//
//  main.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import SwiftCLI

let cli = CLI(name: "createmlfairy", version: "1.0.0", description: "CreateMLFairy - A CLI for CreateML by MLFairy")

cli.commands = [
	ActivityClassifier(),
	ImageClassifier(),
//	ObjectDetector(),
	SoundClassifier(),
	TabularRegressor(),
	TabularClassifier(),
	TextClassifier(),
//	WordTagger()
]

cli.goAndExit()

