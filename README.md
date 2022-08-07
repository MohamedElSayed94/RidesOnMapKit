# RidesOnMapKit

<h2>Prerequisite: </h2>
- add custom Location on xcode simulator (Simulator > Features > Location > Custom Location) to test user at near location (CLLocation(latitude: 52.501232, longitude: 13.44))

<h2>Main features in the App: </h2>

- Get user Location after asking for the location permission.
- make an API call to get all markers.
- Display them on Map.
- restrict Map to show near Scooters.
- draw a route from user location to nearest Scooter.
- Display bottom sheet with main Info of the scooter.
- manage the user to select another scooter instead of the nearest one.
- Different state of the view was handled from loading, getting data, displaying error, (empty state) handle No near Vehicle around.
- Handle different errors like (general error, missing network connections, unexpected API error and showing retry button).

<h2>Main features of the Project: </h2>

- Composition Over Inheritance principle is applied.
- UI of the project was build programmatically (No storyboards or Xib files).
- In this project MVVM pattern was followed using closures, and easey to be maintaned whether  using Combine or RXSwift.
- Build few Fastlane lanes to run tests and to see possible linting issues using swiftlint.
- Few unit tests were build, to test main logic in the project.
