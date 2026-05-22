import 'package:flutter/material.dart';
import 'package:coursework/components/module_model.dart';
import 'userCardsList.dart';
import 'package:coursework/components/module_list_title.dart';
import 'package:coursework/components/profile_header.dart';
// import 'package:coursework/services/auth_service.dart';
// import 'package:coursework/services/module_service.dart';
import 'package:coursework/services/profile_service.dart';

class PublicUserProfilePage extends StatelessWidget {
  final String targetUserId;
  final String targetUsername;

  PublicUserProfilePage({
    Key? key,
    required this.targetUserId,
    required this.targetUsername,
  }) : super(key: key);

  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Модули $targetUsername'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ProfileHeader(
              username: targetUsername,
              subtitle: 'Публичные модули пользователя',
              badge: FutureBuilder<int>(
                future: _profileService.countPublicModules(targetUserId),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$count публичных модулей'),
                  );
                },
              ),
              avatarSize: 90,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ModuleModel>>(
              stream: _profileService.watchPublicModules(targetUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }

                final modules = snapshot.data ?? [];

                if (modules.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Публичных модулей нет'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return ModuleListTile(
                      module: module,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserCardsList(
                              moduleId: module.id,
                              moduleName: module.name,
                              authorId: targetUserId,
                              isPublicStudy: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
}
