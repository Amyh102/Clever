import json
import requests

header = {"Content-Type": "application/json",
          "username": "giveitatry",
          "password": "Sh0wT!me"}

categories = {"Pets":"PetSmart Credit Card",
             "Grocery":"Whole Foods Credit Card",
             "Automotive":"BP Credit Card",
             "Electronics":"Best Buy Credit Card",
             "Gasoline":"Shell Credit Card",
             "Outdoor Living":"Bass Pro Shops Credit Card",
             "Jewelry":"Pandora Credit Card",
             "Bill Pay":" Credit Card",
             "Restaurants":"Olive Garden Credit Card",
             "Travel":"United Airlines Credit Card",
             "Clothing":"American Eagle Credit Card",
             "Baby":"Baby's R Us Credit Card",
             "Utilities":"Nest Credit Card",
             "Entertainment":"Cineplex Credit Card",
             "Books":"Chapters Credit Card",
             "Makeup":"Sephora Credit Card",
             "Sports":"Sport Chek Credit Card",
             "Insurance":"Local Insurance Provider Credit Card",
             }


def next_purchase(account_num):
    data = {"accountNum": account_num}
    req = requests.post("https://syf2020.syfwebservices.com/syf/nextMostLikelyPurchase", headers=header, data=json.dumps(data))
    next_purchase = req.json()
    categories = next_purchase["categories"]

    sorted_categories = sorted(categories, key=lambda category: category['probability'], reverse=True)
    most_probable = sorted_categories[0]

    return most_probable['categoryName']

def next_card(category):
    return categories[category]

if __name__ == '__main__':
    account_num = raw_input("Please enter your account number: ")
    account_num = int(account_num)

    while not 99999 < account_num < 105000:
        account_num = int(raw_input('Please enter your full account number:'))


    category = next_purchase(account_num)
    card = next_card(category)
    print "You may be interested in our {} cards".format(category)
    print "Consider applying for our",card, "cards"
