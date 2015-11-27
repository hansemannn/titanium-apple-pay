var ApplePay = require("ti.applepay");

/**
 *  Apple Pay button
 */
var payButton = ApplePay.createPaymentButton({
    type: ApplePay.PAYMENT_BUTTON_TYPE_BUY,
    style: ApplePay.PAYMENT_BUTTON_STYLE_WHITE_OUTLINE
});
payButton.addEventListener("click", openPaymentDialog);

/**
 *  Check Apple Pay support
 */
Ti.API.info("Can make payments? " + ApplePay.canMakePayments({
    networks: [ApplePay.PAYMENT_NETWORK_VISA, ApplePay.PAYMENT_NETWORK_MASTERCARD],
    capabilities: ApplePay.MERCHANT_CAPABILITY_3DS | ApplePay.MERCHANT_CAPABILITY_CREDIT
}));

/**
 *  Summary Item
 */
var item = ApplePay.createSummaryItem({
    itemType: ApplePay.PAYMENT_SUMMARY_ITEM_TYPE_FINAL,
    title: "Skateboard",
    price: 89.99
});

/**
 *  Payment request
 */
var paymentRequest = ApplePay.createPaymentRequest({
    merchantIdentifier: "merchant.de.hansknoechel.paydemo",
    merchantCapabilities: ApplePay.MERCHANT_CAPABILITY_3DS,
    countryCode: "DE",
    currencyCode: "EUR",
    supportedNetworks: [ApplePay.PAYMENT_NETWORK_VISA, ApplePay.PAYMENT_NETWORK_MASTERCARD],
    summaryItems: [item]
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
paymentDialog.addEventListener("willAuthorizePayment", didAuthorizePayment);
paymentDialog.addEventListener("didAuthorizePayment", willAuthorizePayment);
paymentDialog.addEventListener("didSelectPayment", didSelectPayment);
paymentDialog.addEventListener("didSelectShippingContact", didSelectShippingContact);
paymentDialog.addEventListener("didSelectShippingMethod", didSelectShippingMethod);
paymentDialog.addEventListener("didCancel", didCancel);

function willAuthorizePayment() {}
function didAuthorizePayment() {}
function didSelectPayment() {}
function didSelectShippingContact() {}
function didSelectShippingMethod() {}
function didCancel() {}

function openPaymentDialog(e) {
    if(e.buttonType == ApplePay.PAYMENT_BUTTON_TYPE_SETUP) {
        return; // Alert to setup Apple Pay
    }

    paymentDialog.show();
}

var window = Ti.UI.createWindow({backgroundColor: "white"});
window.add(payButton);
window.open();
