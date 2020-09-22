import 'package:flutter/material.dart';
import '../lib/adjeminpay_flutter.dart';

// This page describes a very basic use of AdjeminPay
// to finalize an order on a cart screen

class ExampleScreen extends StatefulWidget {
  // The route name
  static const routeName = '/adjeminpay-example';

  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // To either display a loading spinner or the "Order Now" button
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // The basic configuration of AdjeminPay
    // You need to keep your apiKey and applicationId secret
    // You can store them in a constants.dart or env.dart file
    // They are required for all the operations with the package
    const Map adpConfig = {
      // Your apiKey
      'apiKey': "eyJpdiI6IkpNQ05tWmtGc0FVbWc1VFhFM",
      // Your applicationId
      'applicationId': "99f99e",
      // The notifyUrl is a url for your web backend if you use any
      // A post request with the {transactionId, status, message}
      // will be sent to this url when the payment is terminated (successful, failed, cancelled, or if an error occured)
      // This not required as the package allows you to excute a callback
      // on paymentTerminated
      'notifyUrl': "",
    };

    // This functions passes in data (your order/transaction data)
    // to the AdjeminPay() constructor, that will generate a payment gateway
    // where your user will enter their :
    // - name (it is recommended that
    //        you pass the name as an argument to AdjeminPay() to
    //        save your user the incovenience of having to type it in ),
    // - mobile money phone number
    // - or credit card information
    //
    // The payment gateway will then:
    // - notify your notifyUrl (if provided)
    //        with the transactionId, status and message
    // - return a Map containing transactionId, status and message
    //        for you to execute any callback or redirection accordingly

    void payWithAdjeminPay(dynamic orderData) async {
      // paymentResult will yield {transactionId, status, message }
      // once the payment gate is closed by the user
      // ! IMPORTANT : make sure to save the orderData in your database first
      // ! before calling this function
      Map<String, dynamic> paymentResult = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) =>
                // The AdjeminPay class
                AdjeminPay(
              // ! required apiKey
              apiKey: adpConfig['apiKey'],
              // ! required applicationId required
              applicationId: adpConfig['applicationId'],
              // ! required transactionId required
              // for you to follow the transaction
              //    or retrieve it later
              //    should be a string < 191 and unique for your application
              transactionId: "${orderData['transactionId']}",
              // notifyUrl for your web backend
              notifyUrl: "https://adjeminpay.net/v1/notifyUrl",
              // amount: int.parse("${orderData['totalAmount']}"),
              // ! required amount
              //    amount the user is going to pay
              //    should be an int
              amount: int.parse("${orderData['totalAmount']}"),
              // currency code
              // currently supported currency is XOF
              currency: "XOF",
              // ! required designation
              //   the name the user will see as what they're paying for

              designation: orderData['designation'],
              // designation: widget.element.title,
              // the name of your user
              payerName: orderData['clientName'],
            ),
          ));

      print(">>> ADJEMINPAY PAYMENT RESULTS <<<");
      print(paymentResult);
      // * Here you define your callbacks
      // Callback if the paymentResult is null
      //    the payment gate got closed without sending back any data
      if (paymentResult == null) {
        print("<<< Payment Gate Unexpectedly closed");
        return;
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Payment Status is ${paymentResult['status']}")));
      // Callback on payment successfully
      if (paymentResult['status'] == "SUCCESSFUL") {
        print("<<< AdjeminPay success");
        print(paymentResult);
        // redirect to or show another screen
        return;
      }
      // Callback on payment failed
      if (paymentResult['status'] == "FAILED") {
        print("<<< AdjeminPay failed");
        print(paymentResult);
        // the reason with be mentionned in the paymentResult['message']
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on payment cancelled
      if (paymentResult['status'] == "CANCELLED") {
        print("<<< AdjeminPay cancelled");
        print(paymentResult);
        // the reason with be mentionned in the paymentResult['message']
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on payment cancelled
      if (paymentResult['status'] == "EXPIRED") {
        print("<<< AdjeminPay expired");
        print(paymentResult);
        // The user took too long to approve or refuse payment
        print("Reason is : " + paymentResult['message']);
        // redirect to or show another screen
        return;
      }
      // Callback on initialisation error
      if (paymentResult['status'] == "ERROR_CONFIG") {
        print("<<< AdjeminPay Init error");
        // You didn't specify a required field
        // or your apiKey or applicationId are not valid
        print(paymentResult);
        return;
      }
      // Callback in case
      if (paymentResult['status'] == "ERROR") {
        print("<<< AdjeminPay Error");
        // You specified :
        // - a transactionId that has already been used
        // -
        print(paymentResult);
        return;
      }
      // Callback when AdjeminPay requests aren't completed
      if (paymentResult['status'] == "ERROR_HTTP") {
        return;
      }
    }

    // Map of a basic order data,
    // recommanded to use your Order/Cart class
    Map<String, dynamic> myOrder = {
      // ! required transactionId or orderId
      'transactionId': "UniqueTransactionId" + DateTime.now().toString(),
      // ! required total amount
      'totalAmount': 1000,
      // optional your orderItems data
      'items': [
        {
          'id': '1',
          'productId': 'prod1',
          'price': 100,
          'quantity': 1,
          'title': 'Product 1 title',
        },
        {
          'id': '2',
          'productId': 'prod9',
          'price': 300,
          'quantity': 3,
          'title': 'Product 9 title',
        },
      ],
      'currency': "XOF",
      'designation': "Order Title",
      'payerName': "ClientName",
    };

    // Basic Cart Screen for checkout from Academind by Maximilian Schwarzmüller
    // https://academind.com/

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${myOrder['totalAmount']?.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('ORDER NOW'),
                    onPressed: (myOrder['totalAmount'] == null ||
                            myOrder['totalAmount'] <= 0 ||
                            _isLoading)
                        ? null
                        : () {
                            // **** Payment Management Here
                            // you first store the Order's data in
                            // your database where you create a unique transaction Id
                            // for example :  await storeOrderData(myOrder);
                            // then you call the payment function
                            payWithAdjeminPay(myOrder);
                          },
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: myOrder['items'].length,
              itemBuilder: (ctx, i) => CartItem(
                myOrder['items'][i]['id'],
                myOrder['items'][i]['productId'],
                myOrder['items'][i]['price'],
                myOrder['items'][i]['quantity'],
                myOrder['items'][i]['title'],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final int price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text(
              'Do you want to remove the item from the cart?',
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        //
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}