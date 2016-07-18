## 1. Requirements

1. We assume that you already have a project in Xcode and that this project is opened in Xcode 7 or later.
2. The SDK supports iOS 8.0 and later.

## Installation
### CocoaPods

We recommend integrating Survata into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Survata', :git => 'git@github.com:Survata/survata-ios-public-sdk.git', :commit => '0cd312b' # Use latest commit
```

Then, run the following command:

```bash
$ pod install
```

And add `import Survata` to the top of the files using Survata

### Carthage

To intergrate Survata into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "survata/survata-ios-public-sdk" >= 1.0
```

And add `import Survata` to the top of the files using Survata


## Examples

Please check out [demo app](https://github.com/survata/survata-ios-demo-app) for a real-life demo.

Here is a brief demo to bind Survey to a button:

```swift
class ViewController: UIViewController {
    weak var surveyButton: UIButton!
    
	var survey: Survey!
	
    func checkSurvey() {
		let publisher = ....
		let option = SurveyOption(publisher: publisher)
		survey = Survey(option: option)
		survey.create { availability in
            if availability == .Available {
                surveyButton.hidden = false
            }
        }
    }

    // action for surveyButton
    func showSurvey() {
        survey.createSurveyWall { result in
            if result == .Completed {
                surveyButton.hidden = true
            }
        }
    }
}

```
#### IMPORTANT NOTE

There is a frequency cap on how many surveys we allow one day for a specific IP address. Thus while testing/developing, it might be frustrating to not see surveys appear after a couple of tries. You can bypass this in two ways. 

####1. FIRST WAY: Using "testing" property

There is a property called **testing** which is a boolean that can be set to true. Below is a snippet of the previous code above that includes the testing property. This will bring up real surveys (that might take very long to answer, so look at the second way), but your responses are not recorded.

```swift
    let option = SurveyOption(publisher: Settings.publisherId)
    option.testing = true
```

####2. SECOND WAY: Using a default survey with SurveyDebugOption, "preview" property & demo survey preview id 

There is another class called **SurveyDebugOption** (subclass of SurveyOption) in the SDK. It has a property called **preview** that allows you to set a default preview Id for a survey (thus, have a specific survey). We have a default short demo survey with just 3 questions at Survata that is perfect for testing that uses the preview id **5fd725139884422e9f1bb28f776c702d**. Here's some code as to show you how to integrate it: 

```swift
    let option = SurveyDebugOption(publisher: Settings.publisherId)
    option.preview = "5fd725139884422e9f1bb28f776c702d"
```
