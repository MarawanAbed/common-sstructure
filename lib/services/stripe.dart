

class StripeServices {
  // final ApiServices apiServices = ApiServices();
  //
  // Future<PaymentIntlEntity> createPaymentIntent(
  //     PaymentInputModel paymentInput) async {
  //   //call api to create payment intent
  //   //return payment intent objectb
  //   var response = await apiServices.post(
  //     contentType: Headers.formUrlEncodedContentType,
  //     body: paymentInput.toJson(),
  //     url: 'https://api.stripe.com/v1/payment_intents',
  //     token: ApiKeys.secretKey,
  //   );
  //   return PaymentIntlEntity.fromJson(response.data);
  // }
  //
  // Future<void> initPaymentSheet(
  //     {required String paymentSecret, required String customerEphemeralKeySecret,}) async {
  //   try {
  //     // 2. initialize the payment sheet
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         // Set to true for custom flow
  //         customFlow: false,
  //         customerEphemeralKeySecret:customerEphemeralKeySecret,
  //         customerId:'cus_P4BwqLExecXkBQ',
  //         // Main params
  //         merchantDisplayName: 'Marwan',
  //         paymentIntentClientSecret: paymentSecret,
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error initPaymentSheet ${e.toString()}');
  //   }
  // }
  //
  // Future displayPaymentSheet() async {
  //   return await Stripe.instance.presentPaymentSheet();
  // }
  //
  // //now i want to add all methods in one method
  // //so i will create a method called checkout
  // //and i will call all methods inside it
  // Future checkout({required PaymentInputModel paymentInput}) async {
  //   //1-create payment intent
  //   var paymentIntent = await createPaymentIntent(paymentInput);
  //   var customerEphemeralKeySecret = await createEphemeralKey(customerId: 'cus_P4BwqLExecXkBQ');
  //
  //   //2-init payment sheet
  //   await initPaymentSheet(paymentSecret: paymentIntent.clientSecret!,customerEphemeralKeySecret:customerEphemeralKeySecret.secret!);
  //   //3-display payment sheet
  //   await displayPaymentSheet();
  // }


  //create customer
  // Future<customerEntity> createCustomer(
  //     CustomerInput customerInput) async {
  //   var response = await apiServices.post(
  //     contentType: Headers.formUrlEncodedContentType,
  //     body: customerInput.toJson(),
  //     url: 'https://api.stripe.com/v1/customers',
  //     token: ApiKeys.secretKey,
  //   );
  //   return customerEntity.fromJson(response.data);
  // }
  //now you can summon it after sign up when you create account for user and save it in database
  //and you can summon it when user want to save card

  //create ephemeral key
  // Future<EphemeralKeyModelEntity> createEphemeralKey(
  //     {required String customerId}) async {
  //   var response = await apiServices.post(
  //     contentType: Headers.formUrlEncodedContentType,
  //     stripeVersion: '2023-10-16',
  //     body: {
  //       'customer': customerId,
  //     },
  //     url: 'https://api.stripe.com/v1/ephemeral_keys',
  //     token: ApiKeys.secretKey,
  //   );
  //   return EphemeralKeyModelEntity.fromJson(response.data);
  // }
}
