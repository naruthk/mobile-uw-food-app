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

## Development

## Chat

[uwfoodappproject.slack.com](uwfoodappproject.slack.com)

## Project Files

- [Google Doc Pitch Deck](https://docs.google.com/presentation/d/1MVVqnKYfs7XXRjwEztFYqFT89grxo69O_V0npmqn-4U/edit#slide=id.g2891f1afb5_0_83)
- [Google Slide Pitch Deck](https://docs.google.com/document/d/1E4Wk3MKEe6RLPMeRxuAHHm1br9HlJo3zwEEgsLuBOeQ)

### Libraries

- Firebase (Authentication, Database)
- CocoaPods (Package Manager)

### JSON

#### Restaurants.JSON

```json
{
  "dataName": "restaurants",
  "modifiedDate": "11/21/17",
  "appData": {
    "restaurants": [
      {
        "id": 1,
        "name": "Dawg Bites",
        "locationName": "Intramural Activities Building (IMA)",
        "fullAddress": "Intramural Activities Building, Seattle, WA 98195",
        "mapCoordinates": [47.653491, -122.301684],
        "category": ["expresso"],
        "averageRating": 4.0,
        "hours": {
          "mon": "7 am - 10 pm",
          "tues": "7 am - 10 pm",
          "wed": "7 am - 10 pm",
          "thurs": "7 am - 10 pm",
          "fri": "7 am - 10 pm",
          "sat": "9 am - 8 pm",
          "sun": "11 am - 7 pm"
        },
        "popularHours": {
          "mon": "7 am - 10 pm",
          "tues": "7 am - 10 pm",
          "wed": "7 am - 10 pm",
          "thurs": "7 am - 10 pm",
          "fri": "7 am - 10 pm",
          "sat": "9 am - 8 pm",
          "sun": "11 am - 7 pm"
        },
        "contactInformation": {
          "name": "",
          "phone": "",
          "email": ""
        }
      }
    ]
  }
}
```

#### Menu.JSON

```json
{
  "dataName": "menus",
  "modifiedDate": "11/21/17",
  "appData": {
    "reviews": [
      {
        "restaurantID": 1,
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

#### Reviews.JSON

For development purposes, we will only be using mock-up data.

```json
{
  "dataName": "reviews",
  "modifiedDate": "11/21/17",
  "appData": {
    "reviews": [
      {
        "restaurantID": 1,
        "comments": [
          {
            "reviewID": 134543534,
            "user": 3405323424,
            "comment": "Great, fast place to grab some drinks!",
            "rating": 4.5
          },
          {
            "reviewID": 143121534,
            "user": 556623424,
            "comment": "Delicious",
            "rating": 4.0
          }
        ]
      }
    ]
  }
}
```