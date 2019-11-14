//
//  main.swift
//  mlfairy
//
//  Copyright © 2019 MLFairy. All rights reserved.
//

import Foundation
import SwiftCLI

let VERSION = "0.1.0"
let cli = CLI(name: "createmlfairy", version: VERSION, description: "CreateMLFairy - A CLI for CreateML by MLFairy")

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

