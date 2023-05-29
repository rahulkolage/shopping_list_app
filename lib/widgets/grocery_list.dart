import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';

// import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  // var _isLoading = true;
  // String? _error;

  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    // _loadItems();
    _loadedItems = _loadItems(); // will be set once
  }

  // void _loadItems() async {

// for using FutureBuilder
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'flutter-prep-b1690-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');

    // try { // commented as FutureBuilder has better way to handle errors with less code
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      // commented for using FutureBuilder
      // setState(() {
      //   _error = 'Failed to fetch data. Please try again later.';
      // });

      // for FutureBuilder
      throw Exception('Failed to fetch grocery, please try again.');
    }

    if (response.body == 'null') {
      // commented for using FutureBuilder
      // setState(() {
      //   _isLoading = false;
      // });
      // return;
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((categoryItem) =>
              categoryItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    // commented for using FutureBuilder
    // // assign converted loadeditems into _groceryItems
    // // remove final from _groceryItems, as we are assiging new value
    // setState(() {
    //   _groceryItems = loadedItems;
    //   _isLoading = false;
    // });

    return loadedItems;
    // } catch (error) {
    //   setState(() {
    //     _error = 'Somrthing went wrong. Please try again later.';
    //   });
    // }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });

    // commented as we are not getting data from pop from new item screen after adding
    // instead we get data using HTTP get call to Firebase
    // if (newItem == null) {
    //   return;
    // }

    // setState(() {
    //   _groceryItems.add(newItem);
    // });

    // commented to avoid unnecessary GET call
    // _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutter-prep-b1690-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // optional show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // commented for using FutureBuilder
    // Widget content = const Center(child: Text('No items added yet.'));

    // commented for using FutureBuilder
    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    // commented for using FutureBuilder
    // if (_groceryItems.isNotEmpty) {
    //   content = ListView.builder(
    //     // using actula grocery items instead dummy items
    //     itemCount: _groceryItems.length, // groceryItems
    //     itemBuilder: (ctx, index) => Dismissible(
    //       // this wants a key to uniquely identify every list item
    //       onDismissed: (direction) {
    //         _removeItem(_groceryItems[index]);
    //       },
    //       key: ValueKey(_groceryItems[index].id),
    //       child: ListTile(
    //         title: Text(_groceryItems[index].name), // groceryItems
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //           color: _groceryItems[index].category.color, //groceryItems
    //         ),
    //         trailing: Text(
    //           _groceryItems[index].quantity.toString(), // groceryItems
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // commented for using FutureBuilder
    // // error check
    // if (_error != null) {
    //   content = Center(child: Text(_error!));
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      // body: content,

      // using FutureBuilder widget
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items added yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              // this wants a key to uniquely identify every list item
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]);
              },
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                ),
              ),
            ),
          );
        },
      ),

      // // commented and moved this into " content " variable.
      // ListView.builder(
      //   // using actula grocery items instead dummy items
      //   itemCount: _groceryItems.length, // groceryItems
      //   itemBuilder: (ctx, index) => ListTile(
      //     title: Text(_groceryItems[index].name), // groceryItems
      //     leading: Container(
      //       width: 24,
      //       height: 24,
      //       color: _groceryItems[index].category.color, //groceryItems
      //     ),
      //     trailing: Text(
      //       _groceryItems[index].quantity.toString(), // groceryItems
      //     ),
      //   ),
      // ),
    );
  }
}
