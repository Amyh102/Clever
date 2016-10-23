import json
import requests

header = {"Content-Type": "application/json",
          "username": "giveitatry",
          "password": "Sh0wT!me"}


def next_card(account_num):
    data = {"accountNum": account_num}
    req = requests.post("https://syf2020.syfwebservices.com/syf/nextMostLikelyPurchase", headers=header, data=json.dumps(data))
    next_purchase = req.json()
    categories = next_purchase["categories"]

    sorted_categories = sorted(categories, key=lambda category: category['probability'], reverse=True)
    most_probable = sorted_categories[0]

    return most_probable['categoryName']


if __name__ == '__main__':
    account_num = raw_input("Please enter your account number: ")
    account_num = int(account_num)

    while not 99999 < account_num < 105000:
        account_num = int(raw_input('Please enter your full account number:'))

    print "You may be interested in our {} cards".format(next_card(account_num))
