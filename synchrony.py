import json
import requests

header = {"Content-Type": "application/json",
          "username": "giveitatry",
          "password": "Sh0wT!me"}

categories = {"Pets":"PetSmart Credit Card",
             "Grocery":"Whole Foods Credit Card",
             "Automotive":"BP Credit Card", # BP
             "Electronics":"Amazon Credit Card", # AMAZON
             "Gasoline":"Shell Credit Card",
             "Outdoor Living":"Bass Pro Shops Credit Card",
             "Jewelry":"Pandora Credit Card",
             "Bill Pay":" Credit Card",
             "Restaurants":"Olive Garden Credit Card",
             "Travel":"Cathay Pacific Credit Card", # CP
             "Clothing":"American Eagle Credit Card",
             "Baby":"Baby's R Us Credit Card", # TRU
             "Utilities":"Nest Credit Card",
             "Entertainment":"Cineplex Credit Card",
             "Books":"Chapters Credit Card",
             "Makeup":"Sephora Credit Card",
             "Sports":"Dicks Sporting Goods Credit Card", # DSG
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


def apply(card, info):
    data = {
        "apply": {
            "applyRequest": {
                "authCosApplicantData": {
                    "lastNameapp": "",
                    "firstNameapp": "",
                    "middleInitialapp": "",
                    "suffixapp": "",
                    "ssn1": "",
                    "birthDateapp": "",
                    "driverLicenseNumberapp": "",
                    "driverLicenseStateapp": "",
                    "signatureIndicatorapp": "",
                    "titleapp": "",
                    "occupationCodeapp": "",
                    "incomeAnnualapp": "",
                    "address": {
                        "address2app": "",
                        "stateapp": "",
                        "address1app": "",
                        "cityapp": "",
                        "zipCodeapp": ""
                    },
                    "membershipNumberapp": "",
                    "ssnOverrideapp": "",
                    "driverLicenseExpiryDateapp": ""
                },
                "spouseDetails": {
                    "spFirstName": "",
                    "spMiddleName": "",
                    "spLastName": "",
                    "address": {
                        "address2spd": "",
                        "statespd": "",
                        "address1spd": "",
                        "cityspd": "",
                        "zipCodespd": ""
                    }
                },
                "merchantData": {
                    "clientDepartment": "",
                    "iovationRequestType": "application",
                    "operator": "ECOM",
                    "clientData": "",
                    "merchantNumber": "0000000000010032",
                    "country": "US",
                    "deviceType": "T",
                    "originalProductCode": "010",
                    "rewardsCode": "",
                    "membershipNumber": "",
                    "primaryGroup": "000",
                    "empAccountCode": "Y",
                    "salesPerson": "213006748",
                    "clientDataShare": "",
                    "sendEmail": "",
                    "referalCode": "",
                    "register": "REGISTER",
                    "clientId": "TJX",
                    "referCode": "",
                    "comment": "",
                    "secondaryGroup": "000"
                },
                "primaryApplicant": {
                    "tempPassDays": "",
                    "longitude": "",
                    "cardIndSEDS": "",
                    "promoTrack": "",
                    "employerState": "",
                    "spCode": "",
                    "bankCardNumber": "",
                    "signatureIndicator": "",
                    "customerLoanTerm": "",
                    "passportIssuingCountry": "",
                    "swipeEdit": "",
                    "address": {
                        "address2": "",
                        "state": "IL",
                        "address1": "21 KING ARTHUR CT",
                        "city": "FANTASY ISLAND",
                        "zipCode": "60750"
                    },
                    "plateCode": "",
                    "ssn": "666010080",
                    "permanentResidentCard": "",
                    "passportNumber": "",
                    "cardIndVISA": "",
                    "cardIndAMEX": "",
                    "mobileStoreDistance": "",
                    "bankCardType": "",
                    "employerName": "",
                    "redemptionAmount": "",
                    "timeAtHome": "",
                    "latitude": "",
                    "applicationCountry": "",
                    "homePhone": "1234567891",
                    "requestedlineOfCredit": "",
                    "relativeInfo": "",
                    "memberNumber": "",
                    "employerPhone": "",
                    "imageDocID": "",
                    "secLastName": "",
                    "optOutFlag": "",
                    "eBillEnrollment": "",
                    "cardIndMC": "",
                    "birthDate": "19700605",
                    "promoCode": "",
                    "incomeAnnual": "12000000",
                    "companyPhone": "",
                    "maidenName": "",
                    "authCosCode": "",
                    "insuranceCode": "",
                    "onlineLetter": "",
                    "billingLastName": "",
                    "caCivicNumber": "",
                    "previousAddress": {
                        "address2prvad": "",
                        "stateprvad": "",
                        "address1prvad": "",
                        "cityprvad": "",
                        "zipCodeprvad": ""
                    },
                    "mobileDeviceType": "",
                    "lastName": "APPROVAL",
                    "billinngCycle": "",
                    "firstName": "JOE",
                    "ipAddress": "",
                    "purchaseAmount": "",
                    "extensionPhoneNumber": "",
                    "driverLicenseState": "",
                    "sourceCode": "",
                    "mothersBirthDate": "",
                    "driverLicenseExpiryDate": "",
                    "dlSsoId": "",
                    "memberSinceDate": "",
                    "email": "t@t.com",
                    "reissueDate": "",
                    "modelIndicator": "",
                    "billingFirstName": "",
                    "residenceCode": "",
                    "timeAtJob": "",
                    "vehicleOwn": "",
                    "relativePhone": "",
                    "creditLineRqd": "",
                    "contractNumber": "",
                    "passportBirthCity": "",
                    "employerZip": "",
                    "cardDeptStrInd": "",
                    "blackBoxId": "",
                    "title": "",
                    "bankAccountCode": "",
                    "regionalBusinessCode": "",
                    "occupationCode": "",
                    "employerAddress": "",
                    "driverLicenseNumber": "",
                    "applicationType": "",
                    "accoutInfo": "",
                    "mortgageOrRentPay": "",
                    "extensionOverride": "",
                    "employerCity": "",
                    "middleName": "",
                    "suffix": "",
                    "ssnOverride": "",
                    "currentEmployer": "",
                    "relativeCode": "",
                    "routingNumber": "",
                    "cellPhone": "",
                    "frnLangIndicator": "E",
                    "checkingAccountNumber": "",
                    "memberType": ""
                }
            }
        }
    }

    data['apply']['applyRequest']['primaryApplicant']['firstName'] = info['name'].split(' ')[0]
    data['apply']['applyRequest']['primaryApplicant']['address']['address1'] = info['address']['address1']
    data['apply']['applyRequest']['primaryApplicant']['address']['address2'] = info['address']['address2']
    data['apply']['applyRequest']['primaryApplicant']['address']['city'] = info['address']['city']
    data['apply']['applyRequest']['primaryApplicant']['address']['state'] = info['address']['state'][:2].upper()
    data['apply']['applyRequest']['primaryApplicant']['address']['zipCode'] = info['address']['zip']

    req = requests.post("https://syf2020.syfwebservices.com/syf/applyForCredit", headers=header, data=json.dumps(data))
    return req.json()


if __name__ == '__main__':
    account_num = raw_input("Please enter your account number: ")
    account_num = int(account_num)

    while not 99999 < account_num < 105000:
        account_num = int(raw_input('Please enter your full account number:'))


    category = next_purchase(account_num)
    card = next_card(category)
    print "You may be interested in our {} cards".format(category)
    print "Consider applying for our",card, "cards"
