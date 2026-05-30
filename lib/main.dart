import 'package:flutter/material.dart';
import 'package:diamond_gear/custom_expansion_tile.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

//Create cost variables
ValueNotifier<double> total = ValueNotifier(0);
double discount = 0;


//Track total quantity of items in order
int totalQuantity = 0;


//Create lists of products with their details
//Details include: product image, name, price, option type and options
//List<(Image, product name, product price, option type, options)>
final List<(Image, String, double, String, List<String>)> gloves = [
  (Image.asset("images/wilson-a2000-1810-12.75.png"), "Wilson A2000 1810 12.75\" Baseball Outfield Glove", 329.99, "Throwing Hand", ["Left", "Right"]),
  (Image.asset("images/rawlings-heart-of-the-hide-12.75.png"), "Rawlings Heart of the Hide 12.75\" Outfield Glove", 299.99, "Throwing Hand", ["Left", "Right"]),
];
final List<(Image, String, double, String, List<String>)> bats = [
  (Image.asset("images/rawlings-icon-bbcor.png"), "Rawlings Icon BBCOR (-3)", 499.99, "Length", ["32\"", "33\"", "34\""]),
  (Image.asset("images/easton-hype-fire-bbcor.png"), "Easton Hype Fire BBCOR (-3)", 449.99, "Length", ["31\"", "32\"", "33\"", "34\""])
];
final List<(Image, String, double, String, List<String>)> cleats = [
  (Image.asset("images/mizuno-ambition-3-metal.png"), "Mizuno Ambition 3 Metal Cleats", 89.99, "Size", ["9", "10", "11", "12"])
];


class ListItem extends StatefulWidget {
  //Creates an entry for each product
  //Includes a product image, the product name, price, options, and a quantity selector

  final Image image;
  final String productName;
  final double price;
  final String optionType;
  final List<String> options;
  const ListItem({super.key, required this.image, required this.productName, required this.price, required this.options, required this.optionType});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  String selectedOption = "";
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        visualDensity: VisualDensity(horizontal: -3, vertical: 1),

        //product image
        leading: widget.image,

        //product name
        title: Text(widget.productName),

        //product options
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3,),
            Text(
              widget.optionType,
              style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(255, 34, 34, 34)
              ),
            ),
            SizedBox(height: 3,),
            Wrap(
              spacing: 4,
              children: widget.options.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  showCheckmark: false,
                  selected: selectedOption == option,
                  selectedColor: Colors.lightBlue,
                  padding: EdgeInsets.all(0),
                  onSelected: (selected){
                    setState(() {
                      selectedOption = option;
                    });
                  },
                );
              }).toList(), 
            ),
          ]
        ),

        //price and quantity counter
        trailing: Column(
          children: [
            Text(
              "\$ ${widget.price.toString()}",
              style: TextStyle(
                fontSize: 12
              ),
            ),
            QuantityCounter(cost: widget.price),
          ]
        )
      )
    );
  }
}

class QuantityCounter extends StatefulWidget {
  //Create a widget that controls the quantity of an item
  //This widget has buttons to add or subtract from the quantity and displays
  //the current quantity of an item

  final double cost;
  const QuantityCounter({super.key, required this.cost});

  @override
  State<QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<QuantityCounter> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: () {
          setState(() {
            // prevent quantity from going negative
            if(quantity > 0) {
              quantity--;
              total.value -= widget.cost;
              totalQuantity--;
              (totalQuantity >= 3) ? discount = total.value * 0.1 : discount = 0;
            }
          });
        }, icon: Icon(Icons.remove)),
        Text("$quantity"),
        IconButton(onPressed: () {
          setState(() {
            quantity++;
            total.value += widget.cost;
            totalQuantity++;
            (totalQuantity >= 3) ? discount = total.value * 0.1 : discount = 0;
          });
        }, icon: Icon(Icons.add))
      ],
    );
  }
}

class ItemCategory extends StatefulWidget {
  //Creates a widget to group display each product
  //Utilizes a custom expansion tile to hide and show the products
  //in each category
  final String category;
  final List<(Image, String, double, String, List<String>)> products;
  const ItemCategory({super.key, required this.category, required this.products});

  @override
  State<ItemCategory> createState() => _ItemCategoryState();
}

class _ItemCategoryState extends State<ItemCategory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomExpansionTile(
          title: Text(widget.category),
          trailing: Text("${widget.products.length} Products"),
          showTrailingIcon: true,
          iconColor: Colors.blue,
          children: [
            generateListItems(widget.products)
          ],
        )
      ]
    );
  }
}

class PlaceOrderButton extends StatelessWidget {
  //Create an ElevatedButton that says "Place Order"
  //and displays a Order Confirmation message

  const PlaceOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            if(totalQuantity == 0) {
              return AlertDialog(
                title: Text("Empty Order"),
                content: Text("No items have been added. Order not placed."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Dismiss")
                  )
                ],
              );
            }
            
            return AlertDialog(
              title: Text("Order Confirmation"),
              content: Text("Your order has been confirmed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Dismiss")
                )
              ],
            );
          }
        );
      }, 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: Size.fromHeight(0),
        padding: EdgeInsets.all(20)
      ),
      child: Text("Place Order"),
    )
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diamond Gear',
      theme: ThemeData(
        colorScheme: .light(onPrimary: Colors.blue, surface: Color.fromARGB(255, 238, 238, 238)),
      ),
      home: const MyHomePage(title: 'Diamond Gear'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: GoogleFonts.contrailOne(color: Colors.white, fontSize: 30),),
        leading: Image.asset("images/home-plate-icon.png", color: Colors.white)
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: .start,

          //create each item category
          children: [
            ItemCategory(category: "Gloves", products: gloves),
            ItemCategory(category: "Bats", products: bats),
            ItemCategory(category: "Cleats", products: cleats),
          ],
        ),
      ),

      //Use bottomNavigationBar to include a PlaceOrderButton
      //and track the total price of the order
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            color: Colors.grey,
            blurRadius: 2.0,
            blurStyle: BlurStyle.outer
          )]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: total, 
              builder: (context, value, child) {
                return Column(
                  children: [
                    //Create discount if there are 3 or more items in the order
                    //(i.e. totalQuantity >= 3)
                    if (totalQuantity >= 3) 
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                        title: Text(
                          "10% Discount - 3+ Items",
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          "-\$ ${(discount).toStringAsFixed(2)}",
                        )
                      ),

                    //Display total cost of the items added
                    ListTile(
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      title: Text("Total"),
                      trailing: Text(
                        "\$ ${(value-discount).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 14),
                      )
                    ),
                    
                  ]
                );
              }
            ),
            
            //Place order button
            PlaceOrderButton()
          ],
        )
      ),
    );
  }
}

//Function to generate a ListItem for each product
Widget generateListItems(List<(Image, String, double, String, List<String>)> category) {
  List<ListItem> items = [];
  for (var item in category) {
    items.add(ListItem(image: item.$1, productName: item.$2, price: item.$3, optionType: item.$4, options: item.$5));
  }
  
  return Column(children: items);
}
