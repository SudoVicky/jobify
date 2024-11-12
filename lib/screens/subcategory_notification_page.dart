import 'package:flutter/material.dart';
import 'package:jobify/screens/detailed_notification_page.dart';

class SubcategoryPage extends StatelessWidget {
  final String categoryName;
  final List<String> subCategories;

  // Constructor to receive categoryName and subcategories
  const SubcategoryPage({
    super.key,
    required this.categoryName,
    required this.subCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(categoryName),
      ),
      body: subCategories.isEmpty
          ? const Center(child: Text('Enable Notification for this category'))
          : ListView.builder(
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCategory = subCategories[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(subCategory),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedNotificationPage(
                            subCategory: subCategory,
                          ),
                        ),
                      );
                      // You can handle navigation here for further subcategory details if needed
                    },
                  ),
                );
              },
            ),
    );
  }
}
