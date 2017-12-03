# UW Food App

An application that lets students and faculties at the University of Washington view all the dining options on campus.

The current project is under development.

<!-- TOC -->

- [UW Food App](#uw-food-app)
  - [About The Project](#about-the-project)
    - [Our Inspiration](#our-inspiration)
    - [Why Developed It](#why-developed-it)
    - [Developers](#developers)
    - [INFO 449 Project Pitch Documents](#info-449-project-pitch-documents)
  - [Development](#development)
    - [Chat](#chat)
    - [Firebase Console](#firebase-console)
    - [Requirements](#requirements)
    - [Installation](#installation)
    - [Libraries We're Using](#libraries-were-using)
  - [Documentation](#documentation)
    - [Obtaining Place ID](#obtaining-place-id)
  - [Contact](#contact)
  - [License](#license)

<!-- /TOC -->

----

## About The Project

### Our Inspiration

We’re inspired by the simplicity and convenience provided by established mobile applications such as Yelp and OneBusAway (UW-owned). Yelp offers users the ability to look up restaurants near them, read reviews, provide ratings, and see information on each restaurant. On the other hand, OneBusAway makes it easy for users to check estimated bus wait times. It’s fast, reliable, and easy to use.

### Why Developed It

While OneBusAway allows us to find bus routes and wait times at each bus stop, we’re building a mobile application that allows us to search for restaurants, food items, prices, popular hours, and lots more. If you’re registered, you can also provide reviews for a restaurant.

### Developers

[Naruth Kongurai](http://www.naruthk.com), Demi Tu, and Thipok Cholsaipant.

### INFO 449 Project Pitch Documents

- Google Doc: [Pitch Deck](https://docs.google.com/presentation/d/1MVVqnKYfs7XXRjwEztFYqFT89grxo69O_V0npmqn-4U/edit#slide=id.g2891f1afb5_0_83)
- Google Slide: [Pitch Presentation](https://docs.google.com/document/d/1E4Wk3MKEe6RLPMeRxuAHHm1br9HlJo3zwEEgsLuBOeQ)

----

## Development

### Chat

- Slack: [uwfoodappproject.slack.com](uwfoodappproject.slack.com)

### Firebase Console

- Console  - [https://console.firebase.google.com/u/0/project/uwfoodapp/overview](https://console.firebase.google.com/u/0/project/uwfoodapp/overview)

### Requirements

You will need CocoaPods to be installed in your computer in order for the the mobile application to work. So if you don't have CocoaPods installed in your computer, run the following commands in Terminal:

```text
sudo gem install cocoapods
pod setup --verbose
```

Note: Running `pod setup --verbose` might take a long time. But you will only have to do it once only (unless we've updated any libraries).

### Installation

```text
git clone https://github.com/naruthk/mobile-uw-food-app.git
pod install
```

You must open **`UW Food App.xcworkspace`** in order to start developing the application. Instead, if you open the other file that contains the `.xcodeproj` extension, you might NOT be able to properly build and run the app.

### Libraries We're Using

With CocoaPods as the package dependency manager, we install these libraries:

- Alamofire
- ChameleonFramework
- Firebase
- Font-Awesome-Swift
- GoogleMaps
- GooglePlaces
- SwiftyJSON
- SwiftyDrop

For images,

- Freepik (Flaticon)
- Google (Flaticon)

----

## Documentation

### Obtaining Place ID

Google offers a way to retrieve the unique `PlaceID` for each restaurant on UW campus by using this website from the url - [https://developers.google.com/places/place-id](https://developers.google.com/places/place-id).

Each `PlaceID` has reference to lots of information, including a restaurant's ratings, hours, and website information. More information can be found here [https://developers.google.com/places/ios-api/reference/interface_g_m_s_place](https://developers.google.com/places/ios-api/reference/interface_g_m_s_place)

The `PlaceID` is what is stored as the value for the key `restaurantID`.

----

## Contact

Submit a pull request / send an email to [contact@naruthk.com](mailto:contact@naruthk.com) for any issues.

----

## License

2017 MIT License. UW Food App. Developed by [Naruth Kongurai](http://www.naruthk.com), Demi Tu, and Thipok Cholsaipant.