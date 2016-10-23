
import requests
header = {"Content-Type": "application/json",
         "username":'giveitatry',
         "password": 'Sh0wT!me'}

def next_card():
	account_num = raw_input("Please enter your account number: ")
	account_num = int(account_num)

	if 99999 < account_num < 105000:
		data = {"accountNum": account_num}
	else:
		account_num = raw_input('Please enter your full account number:')
		data = {"accountNum": account_num}

	a = requests.post("https://syf2020.syfwebservices.com/syf/nextMostLikelyPurchase", headers = header, json = data)

	next_purchase = a.json()
	next_purchase

	categories = next_purchase["categories"]


	sorted_categories = sorted(categories, key = lambda category: category['probability'], reverse = True)
	most_probable = sorted_categories[0]
	most_probable
	print "You may be interested in our", most_probable['categoryName'], "cards"


next_card()






