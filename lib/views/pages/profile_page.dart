import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:bearlysocial/constants/cloud_urls.dart';
import 'package:bearlysocial/constants/db_key.dart';
import 'package:bearlysocial/constants/design_tokens.dart';
import 'package:bearlysocial/constants/native_lang_name.dart';
import 'package:bearlysocial/constants/social_media_consts.dart';
import 'package:bearlysocial/constants/translation_key.dart';
import 'package:bearlysocial/constants/txt_sym.dart';
import 'package:bearlysocial/providers/statuses_pod.dart';
import 'package:bearlysocial/providers/foci_pod.dart';
import 'package:bearlysocial/providers/imgs_pod.dart';
import 'package:bearlysocial/providers/lists_pod.dart';
import 'package:bearlysocial/providers/schedule_pod.dart';
import 'package:bearlysocial/utils/cloud_util.dart';
import 'package:bearlysocial/utils/form_util.dart';
import 'package:bearlysocial/utils/local_db_util.dart';
import 'package:bearlysocial/utils/user_permission_util.dart';
import 'package:bearlysocial/views/buttons/splash_btn.dart';
import 'package:bearlysocial/views/form_elems/photo_display.dart';
import 'package:bearlysocial/views/form_elems/schedule.dart';
import 'package:bearlysocial/views/form_elems/selector.dart';
import 'package:bearlysocial/views/form_elems/social_media_links.dart';
import 'package:bearlysocial/views/form_elems/underlined_txt_field.dart';
import 'package:bearlysocial/views/screens/selfie_screen.dart';
import 'package:bearlysocial/views/texts/warning_message.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img_lib;

class ProfilePage extends ConsumerStatefulWidget {
  final ScrollController scroller;

  const ProfilePage({
    super.key,
    required this.scroller,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _canResetChanges = true;
  bool _canApplyChanges = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _interestController = TextEditingController();
  final _langController = TextEditingController();

  final _instaHandleController = TextEditingController();
  final _facebookHandleController = TextEditingController();
  final _linkedinHandleController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();

  void _trackProfileChanges(List<TextEditingController> controllers) {
    for (var c in controllers) {
      // TODO: Improve the 'changes not saved' message handling here.
      c.addListener(() => ref.read(setProfileSaveStatus)(false));
    }
  }

  void _syncWithDatabase() async {
    ref.read(setLoadingPhotoStatus)(true);

    await Future.delayed(const Duration(
      milliseconds: AnimationDuration.medium,
    ));

    String photoBytes =
        LocalDatabaseUtility.retrieveTransaction(key: DatabaseKey.photo.name);

    if (photoBytes.isNotEmpty) {
      ref.read(setPhoto)(img_lib.decodeImage(base64Decode(photoBytes)));
    } else {
      ref.read(setPhoto)(null);
    }

    _firstNameController.text = LocalDatabaseUtility.retrieveTransaction(
      key: DatabaseKey.first_name.name,
    );
    _lastNameController.text = LocalDatabaseUtility.retrieveTransaction(
      key: DatabaseKey.last_name.name,
    );

    // ref.read(setInterests)(
    //   jsonDecode(LocalDatabaseUtility.retrieveTransaction(
    //     key: DatabaseKey.interests.name,
    //   )).cast<String>(),
    // );
    // ref.read(setLangs)(
    //   jsonDecode(LocalDatabaseUtility.retrieveTransaction(
    //     key: DatabaseKey.langs.name,
    //   )).cast<String>(),
    // );

    _interestController.text = TextSymbol.emptyString;
    _langController.text = TextSymbol.emptyString;

    _instaHandleController.text = LocalDatabaseUtility.retrieveTransaction(
      key: DatabaseKey.insta_handle.name,
    );
    _facebookHandleController.text = LocalDatabaseUtility.retrieveTransaction(
      key: DatabaseKey.fb_handle.name,
    );
    _linkedinHandleController.text = LocalDatabaseUtility.retrieveTransaction(
      key: DatabaseKey.linkedin_handle.name,
    );

    // ref.read(setSchedule)(SplayTreeMap.from(jsonDecode(
    //   LocalDatabaseUtility.retrieveTransaction(key: DatabaseKey.schedule.name),
    // )));

    ref.read(setLoadingPhotoStatus)(false);
    ref.read(setProfileSaveStatus)(true);

    _canResetChanges = true;
    _canApplyChanges = true;
  }

  final _allInterests = FormUtility.allInterests;

  void _addInterest() {
    if (_allInterests.containsKey(_interestController.text)) {
      if (ref.read(interests).length >= 4) ref.read(removeFirstInterest)();

      ref.read(addInterest)(_interestController.text);
      _interestController.text = TextSymbol.emptyString;

      ref.read(setProfileSaveStatus)(false);
    }
  }

  void _addLang() {
    if (NativeLanguageName.map.containsKey(_langController.text)) {
      if (ref.read(langs).length >= 4) ref.read(removeFirstLang)();

      ref.read(addLang)(_langController.text);
      _langController.text = TextSymbol.emptyString;

      ref.read(setProfileSaveStatus)(false);
    }
  }

  void _removeInterest(String entry) {
    ref.read(removeInterest)(entry);
    ref.read(setProfileSaveStatus)(false);
  }

  void _removeLang(String entry) {
    ref.read(removeLang)(entry);
    ref.read(setProfileSaveStatus)(false);
  }

  Future<CameraDescription?> _getFrontCamera() async {
    final bool cameraAllowed = await UserPermissionUtility.cameraPermission;

    if (cameraAllowed) {
      return (await availableCameras()).firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      return null;
    }
  }

  void _navToSelfieScreen() {
    _getFrontCamera().then((frontCamera) {
      if (frontCamera != null) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, p, q) => SelfieScreen(
              frontCamera: frontCamera,
              onCapture: (optionalPhoto) async {
                ref.read(setLoadingPhotoStatus)(true);
                await Future.delayed(const Duration(
                  milliseconds: AnimationDuration.medium,
                ));
                ref.read(setPhoto)(optionalPhoto);
                ref.read(setLoadingPhotoStatus)(false);
                ref.read(setProfileSaveStatus)(false);
              },
            ),
            transitionDuration: const Duration(
              seconds: AnimationDuration.instant,
            ),
          ),
        );
      }
    });
  }

  void _apply() {
    if (ref.read(photo) != null) {
      // CloudUtility.sendRequest(
      //   endpoint: DigitalOceanDropletAPI.updateProfile,
      //   method: HTTPmethod.,
      //   body: ,
      //   image: ,
      //   onSuccess: ,
      //   onBadRequest: ,
      // );
    }
  }

  @override
  void initState() {
    super.initState();

    _trackProfileChanges([
      _firstNameController,
      _lastNameController,
      _interestController,
      _langController,
      _instaHandleController,
      _facebookHandleController,
      _linkedinHandleController,
    ]);

    _firstNameFocusNode.addListener(() {
      ref.read(toggleFirstNameFocus)();
    });
    _lastNameFocusNode.addListener(() {
      ref.read(toggleLastNameFocus)();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithDatabase();
    });
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: widget.scroller,
        padding: const EdgeInsets.symmetric(horizontal: PaddingSize.medium),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: WarningMessage(),
            ),
            const SizedBox(height: WhiteSpaceSize.verySmall),
            const PhotoDisplay(),
            const SizedBox(height: WhiteSpaceSize.small),
            UnconstrainedBox(
              child: SplashButton(
                horizontalPadding: PaddingSize.small,
                verticalPadding: PaddingSize.verySmall,
                callbackFunction: _navToSelfieScreen,
                buttonColor: Theme.of(context).highlightColor,
                borderColor: Theme.of(context).focusColor,
                borderRadius: BorderRadius.circular(CurvatureSize.infinity),
                child: Text(
                  'Update Photo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).focusColor,
                      ),
                ),
              ),
            ),
            const SizedBox(height: WhiteSpaceSize.medium),
            UnderlinedTextField(
              label: 'First Name',
              controller: _firstNameController,
              focusNode: _firstNameFocusNode,
              focusPod: firstNameFocus,
            ),
            const SizedBox(height: WhiteSpaceSize.medium),
            UnderlinedTextField(
              label: 'Last Name',
              controller: _lastNameController,
              focusNode: _lastNameFocusNode,
              focusPod: lastNameFocus,
            ),
            const SizedBox(height: WhiteSpaceSize.large),
            Selector(
              hint: 'Interest(s)',
              menu: FormUtility.buildDropdownMenu(entries: _allInterests),
              controller: _interestController,
              entries: ref.watch(interests),
              addEntry: _addInterest,
              removeEntry: _removeInterest,
            ),
            const SizedBox(height: WhiteSpaceSize.large),
            Selector(
              hint: 'Language(s)',
              menu: FormUtility.buildDropdownMenu(
                entries: NativeLanguageName.map,
              ),
              controller: _langController,
              entries: ref.watch(langs),
              addEntry: _addLang,
              removeEntry: _removeLang,
            ),
            const SizedBox(height: WhiteSpaceSize.medium),
            SocialMediaLink(
              platform: SocialMedia.instagram,
              controller: _instaHandleController,
            ),
            const SizedBox(height: WhiteSpaceSize.medium),
            SocialMediaLink(
              platform: SocialMedia.facebook,
              controller: _facebookHandleController,
            ),
            const SizedBox(height: WhiteSpaceSize.medium),
            SocialMediaLink(
              platform: SocialMedia.linkedin,
              controller: _linkedinHandleController,
            ),
            const SizedBox(height: WhiteSpaceSize.large),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'When is your free time?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: WhiteSpaceSize.verySmall),
            const Schedule(),
            const SizedBox(height: WhiteSpaceSize.verySmall),
            Align(
              alignment: Alignment.centerLeft,
              child: UnconstrainedBox(
                child: SplashButton(
                  horizontalPadding: PaddingSize.small,
                  verticalPadding: PaddingSize.verySmall,
                  callbackFunction: () async {
                    List<DateTime>? dateTimeRange =
                        await FormUtility.appDateTimeRangePicker(
                      context: context,
                    );

                    ref.read(addTimeSlots)(dateTimeRange);
                  },
                  buttonColor: Theme.of(context).highlightColor,
                  borderColor: Theme.of(context).focusColor,
                  borderRadius: BorderRadius.circular(CurvatureSize.infinity),
                  child: Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).focusColor,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: WhiteSpaceSize.large),
            Padding(
              padding: const EdgeInsets.only(bottom: PaddingSize.medium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SplashButton(
                    horizontalPadding: PaddingSize.veryLarge,
                    verticalPadding: PaddingSize.small,
                    callbackFunction: _canResetChanges
                        ? () {
                            _canResetChanges = false;
                            _syncWithDatabase();
                          }
                        : null,
                    buttonColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(CurvatureSize.large),
                    child: Text(
                      TranslationKey.resetButton.name.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).focusColor,
                          ),
                    ),
                  ),
                  SplashButton(
                    horizontalPadding: PaddingSize.veryLarge,
                    verticalPadding: PaddingSize.small,
                    callbackFunction: _canApplyChanges
                        ? () {
                            _canApplyChanges = false;
                            _syncWithDatabase();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(CurvatureSize.large),
                    shadow: Shadow.medium,
                    child: Text(
                      TranslationKey.applyButton.name.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
