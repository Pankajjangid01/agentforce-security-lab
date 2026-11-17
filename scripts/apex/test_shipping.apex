GetShippingQuoteApex.Request req = new GetShippingQuoteApex.Request();
req.postalCode = '110001';
req.weightKg = 2;
List<GetShippingQuoteApex.Result> out = GetShippingQuoteApex.getQuote(new List<GetShippingQuoteApex.Request>{ req });
System.debug('RESULT status=' + out[0].status + ' carrier=' + out[0].carrier + ' price=' + out[0].price + ' eta=' + out[0].etaDays);
