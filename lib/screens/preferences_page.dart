import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/category/category_bloc.dart';
import 'package:jobify/bloc/category/category_event.dart';
import 'package:jobify/bloc/category/category_state.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Ensure this import is correct

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch preferences when the page is built
    context.read<CategoryBloc>().add(FetchPreferencesEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          // Show loading indicator while data is being fetched
          if (state is PreferencesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // When preferences are successfully loaded
          else if (state is PreferencesLoaded) {
            final selectedCategories = state.selectedCategories;

            return ListView.builder(
              itemCount: selectedCategories.length,
              itemBuilder: (context, index) {
                final categoryName = selectedCategories.keys.elementAt(index);
                final subcategories = selectedCategories[categoryName]!;

                return Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(), // Drawer motion for sliding
                    children: [
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          // Dispatch DeleteCategoryEvent to remove category from Firestore
                          context.read<CategoryBloc>().add(DeleteCategoryEvent(
                                categoryName: categoryName,
                              ));
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ExpansionTile(
                      title: Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Loop through subcategories for each category
                      children: subcategories.entries.map((entry) {
                        return ListTile(
                          title: Text(entry.key),
                          trailing: Switch(
                            value: entry.value,
                            onChanged: (newValue) {
                              // Dispatch UpdatePreferenceEvent to update Firestore
                              context
                                  .read<CategoryBloc>()
                                  .add(UpdatePreferenceEvent(
                                    categoryName: categoryName,
                                    fieldName: entry.key,
                                    newValue: newValue,
                                  ));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }
          // Handle errors while fetching preferences
          else if (state is CategoryError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Working on'));
        },
      ),
      // Floating button to show unselected categories
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Fetch unselected categories by dispatching an event to the BLoC
          context.read<CategoryBloc>().add(FetchUnselectedCategoriesEvent());

          // Show the dialog or bottom sheet to display the unselected categories
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryError) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text(state.message),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  } else if (state is UnselectedCategoriesLoaded) {
                    final unselectedCategories = state.unselectedCategories;

                    // **New condition to check if no categories are left to add**
                    if (unselectedCategories.isEmpty) {
                      return AlertDialog(
                        title: const Text('More coming soon..'), // Title change
                        content: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                              'No more categories to add.'), // Message to indicate all categories are selected
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context
                                  .read<CategoryBloc>()
                                  .add(FetchPreferencesEvent());
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Close'),
                          ),
                        ],
                      );
                    } else {
                      return AlertDialog(
                        title: Text('Select Categories'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: unselectedCategories.map((entry) {
                              final categoryName = entry.key;

                              return ListTile(
                                title: Text(categoryName),
                                onTap: () {
                                  // Handle the category selection
                                  print('Category selected: $categoryName');

                                  // Add the selected category to user preferences
                                  Navigator.of(context).pop();
                                  context.read<CategoryBloc>().add(
                                        AddCategoryEvent(
                                          categoryName: categoryName,
                                        ),
                                      );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context
                                  .read<CategoryBloc>()
                                  .add(FetchPreferencesEvent());
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Close'),
                          ),
                        ],
                      );
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              );
            },
          );
        },
        elevation: 3,
        child: const Icon(Icons.add),
      ),
    );
  }
}
