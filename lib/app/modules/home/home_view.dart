
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hanzì Journey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () { /* TODO: Navigate to profile */ },
          ),
        ],
      ),
      // Obx is a GetX widget that rebuilds its child when any of the Rx variables inside it change.
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.characters.length,
          itemBuilder: (context, index) {
            final character = controller.characters[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                leading: Text(
                  character.character,
                  style: const TextStyle(fontSize: 40, color: Colors.deepPurple),
                ),
                title: Text(character.word, style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text('${character.pinyin} - ${character.meaning}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => controller.startPractice(character),
              ),
            );
          },
        );
      }),
    );
  }
}
