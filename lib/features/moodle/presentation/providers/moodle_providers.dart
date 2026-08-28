import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/datasource/moodle_api_client.dart';
import '../../data/datasource/moodle_ical_client.dart';
import '../../data/models/moodle_models.dart';
import '../../data/repositories/moodle_repository_impl.dart';
import '../../data/repositories/moodle_ical_repository_impl.dart';
import '../../data/storage/moodle_credential_store.dart';
import '../../domain/repositories/moodle_ical_repository.dart';
import '../../domain/repositories/moodle_repository.dart';

final moodleCredentialStoreProvider = Provider<MoodleCredentialStore>((ref) {
  return MoodleCredentialStore();
});

final moodleCredentialsProvider = FutureProvider<MoodleCredentials?>((
  ref,
) async {
  return ref.watch(moodleCredentialStoreProvider).read();
});

final moodleRepositoryProvider =
    Provider.family<MoodleRepository, MoodleCredentials>((ref, credentials) {
      final client = MoodleApiClient(credentials);
      ref.onDispose(client.close);
      return MoodleRepositoryImpl(client);
    });

final moodleIcalRepositoryProvider = Provider<MoodleIcalRepository>((ref) {
  final client = MoodleIcalClient();
  final taskRepository = ref.watch(taskRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  ref.onDispose(client.close);
  return MoodleIcalRepositoryImpl(client, taskRepository, categoryRepository);
});
