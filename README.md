# UW Food App

An application that lets students and faculties at the University of Washington view all the dining options on campus.

The current project is under development.

<!-- TOC -->

- [UW Food App](#uw-food-app)
  - [About The Project](#about-the-project)
    - [Our Inspiration](#our-inspiration)
    - [Why Developed It](#why-developed-it)
    - [Developers](#developers)
    - [Project Pitch Documents](#project-pitch-documents)
  - [Development](#development)
    - [Chat](#chat)
    - [Requirements](#requirements)
    - [Installation](#installation)
    - [Libraries We're Using](#libraries-were-using)
    - [Testing](#testing)
  - [Documentation](#documentation)
    - [JSON](#json)
      - [Restaurants.JSON](#restaurantsjson)
      - [Menu.JSON](#menujson)
      - [Reviews.JSON](#reviewsjson)
  - [License](#license)

<!-- /TOC -->

----

## About The Project

### Our Inspiration

We’re inspired by the simplicity and convenience provided by established mobile applications such as Yelp and OneBusAway (UW-owned). Yelp offers users the ability to look up restaurants near them, read reviews, provide ratings, and see information on each restaurant. On the other hand, OneBusAway makes it easy for users to check estimated bus wait times. It’s fast, reliable, and easy to use.

### Why Developed It

While OneBusAway allows us to find bus routes and wait times at each bus stop, we’re building a mobile application that allows us to search for restaurants, food items, prices, popular hours, and lots more. If you’re registered, you can also provide reviews for a restaurant.

### Developers

We’re a team of three funny, talkative, and cheerful individuals: [Naruth Kongurai](http://www.naruthk.com), Demi Tu, and Thipok Cholsaipant.

### Project Pitch Documents

- Google Doc: [Pitch Deck](https://docs.google.com/presentation/d/1MVVqnKYfs7XXRjwEztFYqFT89grxo69O_V0npmqn-4U/edit#slide=id.g2891f1afb5_0_83)
- Google Slide: [Pitch Presentation](https://docs.google.com/document/d/1E4Wk3MKEe6RLPMeRxuAHHm1br9HlJo3zwEEgsLuBOeQ)

----

## Development

### Chat

- Slack: [uwfoodappproject.slack.com](uwfoodappproject.slack.com)

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

- Firebase (Authentication, Database) - [https://console.firebase.google.com/u/0/project/uwfoodapp/overview](https://console.firebase.google.com/u/0/project/uwfoodapp/overview)
- CocoaPods (Package Manager) - 1.3.1
- SwiftyJSON
- Alamofire
- SwiftyDrop
- SVProgressHUD
- GoogleMaps
- GooglePlaces
- Font-Awesome-Swift

### Testing

Unit testings to be written at a later point.

----

## Documentation

### JSON

There are three JSON files that the app retrieves data from.

- Restaurants.JSON
- Menus.JSON
- Reviews.JSON

All files are currently hosted on my website: [http://naruthk.com/api/mobile-uw-food-app/data/Restaurants.json](http://naruthk.com/api/mobile-uw-food-app/data/Restaurants.json). Alternatively, they are available for viewing inside this Github repository's [data](/data) folder.

Eventually, we will need to migrate all of our data to Firebase, so that information can be retrieved and updated and can be reflected in the application immediately.

In every JSON file, there is a shared `restaurantID` for each restaurant, meaning that even though there are 3 seperate JSON files, we can still easily lookup basic information (such as contact information, description), menu, and reviews of a single restaurant by using the unique `restaurantID`.

When adding data to the JSON files, make sure that the `restaurantID` for each restaurant is the same in all 3 JSON files.

#### Restaurants.JSON

View actual `Restaurants.json` data file [here](data/Restaurants.json).

| Type | Type | Description |
| ---- | ---- | ------ |
|  id  |  Text `string` | The unique id of the restaurant. We use it to look up other values such as reviews and menus. |
| name | Text `string` | Name of the restaurant |
| description | Text `string` | Short / long description of the restaurant. Copied directly from the HFS website |
| locationName | Text `string` | Short name of the location |
| fullAddress | Text `string` | Full address (with city, state, and zip code) |
| mapCoordinates | Array `string` | Latitude and longitude data |
| category | Text `string` | Category of the restaurant |
| averageRating | Text `string` | Rating for this restaurant |
| hours | Dictionary `string:string` | Operation hours from Monday until Sunday |
| popularHours * | Dictionary `string:string` | Popular hours from Monday until Sunday |
| contactInformation | Dictionary `string:string` | Name, phone number, website, and email address |

Note: *`*` Popular hours are mocked data.*

----

#### Menu.JSON

```json
{
  "dataName": "menus",
  "modifiedDate": "11/21/17",
  "appData": {
    "menus": [
      {
        "restaurantID": "1",
        "food": [
          {
            "name": "Chocolate Latte",
            "price": "5.05",
            "foodCategory": "drinks"
          }
        ]
      }
    ]
  }
}
```

----

#### Reviews.JSON

For development purposes, we will only be using mock-up data.

```json
{
  "dataName": "reviews",
  "modifiedDate": "11/21/17",
  "appData": {
    "reviews": [
      {
        "restaurantID": "1",
        "comments": [
          {
            "reviewID": "134543534",
            "user": "3405323424",
            "comment": "Great, fast place to grab some drinks!",
            "rating": "4.5"
          },
          {
            "reviewID": "143121534",
            "user": "556623424",
            "comment": "Delicious",
            "rating": "4.0"
          }
        ]
      }
    ]
  }
}
```

----

## License

2017 MIT License