import 'package:bearlysocial/constants/cloud_urls.dart';
import 'package:bearlysocial/constants/design_tokens.dart';
import 'package:bearlysocial/constants/http_methods.dart';
import 'package:bearlysocial/constants/translation_key.dart';
import 'package:bearlysocial/providers/txts_pod.dart';
import 'package:bearlysocial/utils/cloud_util.dart';
import 'package:bearlysocial/views/buttons/splash_btn.dart';
import 'package:bearlysocial/views/form_elems/underlined_txt_field.dart';
import 'package:bearlysocial/views/lines/progress_spinner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeroSection extends ConsumerStatefulWidget {
  const HeroSection({super.key});

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection> {
  bool _canInvokeCallback = true;

  final _emailAddrFocusNode = FocusNode();
  final _emailAddrController = TextEditingController();

  String? _emailAddrErrTxt;

  @override
  void initState() {
    super.initState();
    _emailAddrFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailAddrFocusNode.dispose();
    super.dispose();
  }

  void _requestOTP() async {
    final emailAddr = _emailAddrController.text;

    await CloudUtility.sendRequest(
      endpoint: DigitalOceanDropletURL.requestOTP,
      method: HTTPmethod.GET.name,
      body: {
        'email_address': emailAddr,
      },
      context: context,
      onSuccess: (_) {
        setState(() => _emailAddrErrTxt = null);
        ref.read(setAuthEmailAddr)(emailAddr);
      },
      onBadRequest: (response) {
        setState(() => _emailAddrErrTxt = response['message']);
      },
    );

    _canInvokeCallback = true;
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 80,
              child: Text(
                'Step in and explore!',
                maxLines: 4,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const Expanded(flex: 20, child: SizedBox()),
          ],
        ),
        const SizedBox(height: WhiteSpaceSize.veryLarge),
        UnderlinedTextField(
          enabled: ref.watch(authEmailAddr).isEmpty,
          label: TranslationKey.emailAddrLabel.name.tr(),
          controller: _emailAddrController,
          focusNode: _emailAddrFocusNode,
          errorText: _emailAddrErrTxt,
        ),
        const SizedBox(height: WhiteSpaceSize.large),
        SplashButton(
          width: double.infinity,
          verticalPadding: PaddingSize.small,
          borderRadius: BorderRadius.circular(CurvatureSize.large),
          callbackFunction: ref.watch(authEmailAddr).isEmpty
              ? _canInvokeCallback
                  ? () {
                      _canInvokeCallback = false;
                      _requestOTP();
                    }
                  : null
              : null,
          shadow: Shadow.medium,
          child: _canInvokeCallback
              ? Text(
                  'Continue',
                  style: Theme.of(context).textTheme.titleMedium,
                )
              : const ProgressSpinner(invertColor: true),
        ),
      ],
    );
  }
}
