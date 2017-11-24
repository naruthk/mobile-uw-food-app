# UW Food App

An application that lets students and faculties at the University of Washington view all the dining options on campus.

<!--

## Our Inspiration

We’re inspired by the simplicity and convenience provided by established mobile applications such as Yelp and OneBusAway (UW-owned). Yelp offers users the ability to look up restaurants near them, read reviews, provide ratings, and see information on each restaurant. On the other hand, OneBusAway makes it easy for users to check estimated bus wait times. It’s fast, reliable, and easy to use.

## Why Developed It?

While OneBusAway allows us to find bus routes and wait times at each bus stop, we’re building a mobile application that allows us to search for restaurants, food items, prices, popular hours, and lots more. If you’re registered, you can also provide reviews for a restaurant.

## Developers

We’re a team of three funny, talkative, and cheerful individuals: Naruth Kongurai, Demi Tu, and Thipok Cholsaipant.

---- -->

## Project Pitch Documents

- Google Doc: [Pitch Deck](https://docs.google.com/presentation/d/1MVVqnKYfs7XXRjwEztFYqFT89grxo69O_V0npmqn-4U/edit#slide=id.g2891f1afb5_0_83)
- Google Slide: [Pitch Presentation](https://docs.google.com/document/d/1E4Wk3MKEe6RLPMeRxuAHHm1br9HlJo3zwEEgsLuBOeQ)

### Chat

- Slack application: [uwfoodappproject.slack.com](uwfoodappproject.slack.com)

----

## Development

### Requirements

We will need CocoaPods installed in order for the UW Food App to work. So if you don't have CocoaPods installed in your computer, run the following commands in Terminal:

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

Now to start developing the app, open the file **`UW Food App.xcworkspace`**.

### Libraries We're Using

- Firebase (Authentication, Database) - [https://console.firebase.google.com/u/0/project/uwfoodapp/overview](https://console.firebase.google.com/u/0/project/uwfoodapp/overview)
- CocoaPods (Package Manager) - 1.3.1
- SwiftyJSON
- Alamofire

----

## Database Documentation

### JSON

#### Restaurants.JSON

`appData.restaurants` *json object* contains arrays of *key*, *value* pairs:

| Type | Type | Description |
| ---- | ---- | ------ |
|  id  |  Text `string` | The unique id of the restaurant. We use it to look up other values such as reviews and menus. |
| name | Text `string` | Name of the restaurant |
| description | Text `string` | Short / long description of the restaurant. Copied directly from the HFS website |
| locationName | Text `string` | Short name of the location |
| fullAddress | Text `string` | Full address (with city, state, and zip code) |
| mapCoordinates | Array `double` | Latitude and longitude data |
| category | Text `string` | Category of the restaurant |
| averageRating | Number `double` | Rating for this restaurant |
| hours | - | Operation hours from Monday until Sunday |
| popularHours | - | Popular hours from Monday until Sunday |
| contactInformation | - | Name, phone number, website, and email address |

```json
{
  "dataName": "restaurants",
  "modifiedDate": "11/21/17",
  "appData": {
    "restaurants": [
      {
        "restaurantID": "1",
        "name": "Dawg Bites",
        "description": "Dawg Bites, a smoothie bar located inside the Intramural Activities Building (IMA) on Montlake Boulevard, is a great place to get refreshed after a workout. Choose from a large selection of fresh grab-and-go salads and sandwiches, cold drinks, espresso, and of course, Freshëns blended fruit smoothies.",
        "locationName": "Intramural Activities Building (IMA)",
        "fullAddress": "Intramural Activities Building, Seattle, WA 98195",
        "mapCoordinates": [
          47.653491,
          -122.301684
        ],
        "category": "espresso",
        "averageRating": 0.0,
        "hours": {
          "mon": "7 am - 10 pm",
          "tues": "7 am - 10 pm",
          "wed": "7 am - 10 pm",
          "thurs": "7 am - 10 pm",
          "fri": "7 am - 10 pm",
          "sat": "9 am - 8 pm",
          "sun": "11 am - 7 pm"
        },
        "popularHours": {},
        "contactInformation": {
          "name": "Torin Munro",
          "phone": "206-221-4598",
          "website": "https://www.hfs.washington.edu/dining/Default.aspx?id=336",
          "email": "torinm@uw.edu"
        }
      }
    ]
  }
}
```

View actual `Restaurants.json` data file [here](data/Restaurants.json).

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
        "menus": [
          {
            "name": "Chocolate Latte",
            "price": 5.05,
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
            "rating": 4.5
          },
          {
            "reviewID": "143121534",
            "user": "556623424",
            "comment": "Delicious",
            "rating": 4.0
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