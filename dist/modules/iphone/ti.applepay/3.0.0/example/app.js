/**
 *  Apple Pay SDK for Axway Titanium
 *  Conceptual archticture
 *  Version: 2.0.0
 *  Author: Hans Knoechel
 *  Last modified: 2017-11-18
 *
 *  References:
 *    - https://developer.apple.com/library/ios/documentation/PassKit/Reference/PKPaymentButton_Class/index.html
 *    - https://developer.apple.com/library/ios/documentation/PassKit/Reference/PKPaymentRequest_Ref/index.html
 *    - https://developer.apple.com/library/ios/documentation/PassKit/Reference/PKPaymentAuthorizationViewController_Ref/index.html
 */
var ApplePay = require("ti.applepay");

ApplePay.setupPaymentGateway({
    name: ApplePay.PAYMENT_GATEWAY_STRIPE, // OR: ApplePay.PAYMENT_GATEWAY_BRAINTREE
    apiKey: "<YOUR_STRIPE_OR_BRAINTREE_API_KEY>"
});

/**
 *  Apple Pay button
 */
var payButton = ApplePay.createPaymentButton({

    // You can check if passes are available using `ApplePay.isPassLibraryAvailable()`
    // and change the type to `PAYMENT_BUTTON_TYPE_SETUP` if no passes exist, yet
    type: ApplePay.PAYMENT_BUTTON_TYPE_BUY,
    style: ApplePay.PAYMENT_BUTTON_STYLE_WHITE_OUTLINE
});

// If the user can't make payments, you can check if a display the setup dialog by
// calling `ApplePay.openPaymentSetup();` instead
payButton.addEventListener("click", openPaymentDialog);

/**
 *  Check Apple Pay support
 */
Ti.API.info("Can make payments? " + ApplePay.canMakePayments());

/* 
 * You can also check certain conditions
 */
// ApplePay.canMakePayments({
//     networks: [ApplePay.PAYMENT_NETWORK_VISA, ApplePay.PAYMENT_NETWORK_MASTERCARD],
//     capabilities: ApplePay.MERCHANT_CAPABILITY_3DS | ApplePay.MERCHANT_CAPABILITY_CREDIT
// })

/**
 *  Summary Items
 */
var summaryItems = [];
var totalPrice = 0;

var company = "Best Buy";
var items = [{
    title: "Skateboard",
    price: 89.99
},{
    title: "BMX",
    price: 149.99
}];

for(var i = 0; i < items.length; i++) {
    summaryItems.push(ApplePay.createSummaryItem({
        itemType: ApplePay.PAYMENT_SUMMARY_ITEM_TYPE_FINAL,
        title: items[i].title,
        price: items[i].price
    }));

    totalPrice = totalPrice + items[i].price;
}

// The native Apple Pay API receives the total as a summary item that
// usually holds the company name and total price of the order.
var summary = ApplePay.createSummaryItem({
    itemType: ApplePay.PAYMENT_SUMMARY_ITEM_TYPE_FINAL,
    title: company,
    price: totalPrice
});

summaryItems.push(summary);

/**
 *  Shipping methods
 */

var shippingMethods = [];
var methods = [{
    identifier: "free_shipping",
    title: "Free Shipping",
    description: "3-5 working days",
    price: 0.0
},{
    identifier: "express_shipping",
    title: "Express Shipping",
    description: "1-2 working days",
    price: 10.0
}];

for(var k = 0; k < methods.length; k++) {
    shippingMethods.push(ApplePay.createShippingMethod(methods[k]));
}

/**
 *  Shipping / billing contact
 */

// Can be an object or Ti.Contacts.Person. Check your input data before (!)
var contact = {
    firstName: "John",
 //   middleName: "Dorian",
    lastName: "Doe",
 //   prefix: "Mr",
 //   suffix: "Jr",
    address: {
        street: "1 Infinite Loop",
        city: "Cupertino",
        zip: "95014",
        state: "California",
        country: "United States",
 //       ISOCountyCode: "USA"
    },
    email: "john@doe.com",
    phone: "+1 123 456-7890",
    supplementarySubLocality: "Nödike"
};

/**
 *  Payment request
 */
var paymentRequest = ApplePay.createPaymentRequest({
    merchantIdentifier: "merchant.de.hansknoechel.paydemo.stripe",
    merchantCapabilities: ApplePay.MERCHANT_CAPABILITY_3DS | ApplePay.MERCHANT_CAPABILITY_CREDIT | ApplePay.MERCHANT_CAPABILITY_DEBIT | ApplePay.MERCHANT_CAPABILITY_EMV,
    countryCode: "US",
    currencyCode: "USD",
    // billingContact: contact,
   // shippingContact: contact,
    supportedNetworks: [ApplePay.PAYMENT_NETWORK_VISA, ApplePay.PAYMENT_NETWORK_MASTERCARD],
    requiredShippingAddressFields: ApplePay.ADDRESS_FIELD_POSTAL_ADDRESS,
    requiredBillingAddressFields: ApplePay.ADDRESS_FIELD_POSTAL_ADDRESS,
    shippingType: ApplePay.SHIPPING_TYPE_DELIVERY,
    shippingMethods: shippingMethods,
    summaryItems: summaryItems,
    applicationData: {
        "userId": 1337
    }
});

/**
 *  Payment dialog
 */
var paymentDialog = ApplePay.createPaymentDialog({
    paymentRequest: paymentRequest
});

/**
 *  Payment events
 */
paymentDialog.addEventListener("didSelectPayment", didSelectPayment);
paymentDialog.addEventListener("didSelectShippingContact", didSelectShippingContact);
paymentDialog.addEventListener("didSelectShippingMethod", didSelectShippingMethod);
paymentDialog.addEventListener("willAuthorizePayment", willAuthorizePayment);
paymentDialog.addEventListener("didAuthorizePayment", didAuthorizePayment);
paymentDialog.addEventListener("close", willClose);

function didSelectPayment(e) {
    e.handler.complete(paymentRequest.getSummaryItems());
}

function didSelectShippingContact(e) {
    Ti.API.warn(e);
    e.handler.complete(ApplePay.PAYMENT_AUTHORIZATION_STATUS_SUCCESS, paymentRequest.getShippingMethods(), paymentRequest.getSummaryItems());
}

function didSelectShippingMethod(e) {

    /**
     * TODO:    (Demo) Update total price, insert item as penultimate element
     *          Update the summary items if certain shipping method is selected

                summaryItems.push(ApplePay.createSummaryItem({
                    itemType: ApplePay.PAYMENT_SUMMARY_ITEM_TYPE_FINAL,
                    title: "Extra Fee",
                    price: 13.37
                }));
                paymentRequest.setSummaryItems(summaryItems);
    */

    e.handler.complete(ApplePay.PAYMENT_AUTHORIZATION_STATUS_SUCCESS, paymentRequest.getSummaryItems());
}

function willAuthorizePayment() {

}

function didAuthorizePayment(e) {

    // Send the encrypted payment data to your backend and send the completion handler afterwards.
    Ti.API.info("Payment successfully authorized: " + e.success);
    e.handler.complete(ApplePay.PAYMENT_AUTHORIZATION_STATUS_SUCCESS);
}

function willClose(e) {

}

function openPaymentDialog(e) {
    if(e.buttonType == ApplePay.PAYMENT_BUTTON_TYPE_SETUP) {
        return; // Alert to setup Apple Pay. PKAddPaymentPassViewController is not supported, yet.
    }

    paymentDialog.show();
}

var window = Ti.UI.createWindow({backgroundColor: "white"});
window.add(payButton);
window.open();
