import UIKit
import XCPlayground
import Survata
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let g = dispatch_group_create()
func enter() { dispatch_group_enter(g) }
func leave() { dispatch_group_leave(g) }

enter()
let survey = Survey(option: SurveyOption(publisher: "survata-test"))
survey.create("survata-test") { status in
	if status == .Available {
		
	}
	leave()
}

dispatch_group_notify(g, dispatch_get_main_queue()) {
	XCPlaygroundPage.currentPage.finishExecution()
}
