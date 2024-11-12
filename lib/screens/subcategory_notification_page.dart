import 'package:flutter/material.dart';

class SubcategoryPage extends StatelessWidget {
  final String categoryName;
  final List<String> subcategories;

  // Constructor to receive categoryName and subcategories
  const SubcategoryPage({
    super.key,
    required this.categoryName,
    required this.subcategories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('$categoryName Subcategories'),
      ),
      body: subcategories.isEmpty
          ? const Center(child: Text('Enable Notification for this category'))
          : ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = subcategories[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(subcategory),
                    onTap: () {
                      // You can handle navigation here for further subcategory details if needed
                    },
                  ),
                );
              },
            ),
    );
  }
}
