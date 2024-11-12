import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/auth/auth_bloc.dart';
import 'package:jobify/bloc/category/category_bloc.dart'; // Using CategoryBloc for notifications
import 'package:jobify/bloc/category/category_event.dart'; // Event for fetching true selected categories
import 'package:jobify/bloc/category/category_state.dart';
import 'package:jobify/screens/subcategory_notification_page.dart'; // State for displaying notifications

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch true selected categories (notifications) when the page is built
    context.read<CategoryBloc>().add(FetchTrueSelectedEvent());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dispatch LogoutEvent
              BlocProvider.of<AuthBloc>(context).authRepository.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrueSelectedLoaded) {
            final filteredCategories = state.filteredCategories;

            if (filteredCategories.isEmpty) {
              return const Center(child: Text("No categories available."));
            }

            return ListView.builder(
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final categoryName = filteredCategories.keys.elementAt(index);
                final subCategories = filteredCategories[categoryName]!;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(categoryName),
                    onTap: () {
                      // Pass both categoryName and its subcategories to the next page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubcategoryPage(
                            categoryName: categoryName,
                            subCategories: subCategories,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text("Something went wrong."));
        },
      ),
    );
  }
}
