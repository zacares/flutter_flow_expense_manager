import "package:app_settings/app_settings.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";

class TransactionTagsPreferencesPage extends StatefulWidget {
  const TransactionTagsPreferencesPage({super.key});

  @override
  State<TransactionTagsPreferencesPage> createState() =>
      _TransactionTagsPreferencesPageState();
}

class _TransactionTagsPreferencesPageState
    extends State<TransactionTagsPreferencesPage> {
  late final AppLifecycleListener _listener;

  late Future<PermissionStatus> _contactsPermissionGranted;

  @override
  void initState() {
    super.initState();

    _contactsPermissionGranted = Permission.contacts.status;

    _listener = AppLifecycleListener(
      onShow: () {
        _contactsPermissionGranted = Permission.contacts.status;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("preferences.transactions.geo".t(context))),
      body: SafeArea(
        child: FutureBuilder(
          future: _contactsPermissionGranted,
          builder: (context, snapshot) {
            final PermissionStatus? permissionData = snapshot.data;
            final bool hasPermission =
                permissionData != null && resolvePermission(permissionData);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  SwitchListTile(
                    title: Text(
                      "preferences.transactions.tags.contactTags.enableContacts"
                          .t(context),
                    ),
                    value: hasPermission,
                    onChanged: onChanged,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool resolvePermission(PermissionStatus permission) => switch (permission) {
    PermissionStatus.granted || PermissionStatus.limited => true,
    _ => false,
  };

  void updateEnableGeo(bool? newEnableGeo) async {
    if (newEnableGeo == null) return;

    await LocalPreferences().enableGeo.set(newEnableGeo);

    if (mounted) setState(() {});
  }

  void onChanged(bool? enable) {
    if (enable == null) return;

    if (enable) {
      tryRequestPermission();
    } else {
      AppSettings.openAppSettings();
    }
  }

  void tryRequestPermission() async {
    final PermissionStatus status = await Permission.contacts.request();

    if (!resolvePermission(status)) {
      if (mounted) {
        context.showErrorToast(
          error:
              "preferences.transactions.tags.enablePhoneContacts.permissionDenied"
                  .t(context),
        );
      }
    }

    _contactsPermissionGranted = Future.value(status);
    if (mounted) setState(() {});
  }
}
