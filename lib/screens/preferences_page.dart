import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobify/bloc/category/category_bloc.dart';
import 'package:jobify/bloc/category/category_event.dart';
import 'package:jobify/bloc/category/category_state.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(FetchPreferencesEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is PreferencesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PreferencesLoaded) {
            final selectedCategories = state.selectedCategories;

            return ListView.builder(
              itemCount: selectedCategories.length,
              itemBuilder: (context, index) {
                final categoryName = selectedCategories.keys.elementAt(index);
                final subcategories = selectedCategories[categoryName]!;

                return Card(
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
                    children: subcategories.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Switch(
                          value: entry.value,
                          onChanged: (bool newValue) {
                            // Dispatch an event to update Firebase
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
                );
              },
            );
          } else if (state is CategoryError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Unexpected state.'));
        },
      ),
    );
  }
}
