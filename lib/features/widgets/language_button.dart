import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../map/bloc/map_bloc.dart';
import '../map/bloc/map_event.dart';
import '../map/bloc/map_state.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
      previous.language != current.language,
      builder: (context, state) {
        return FloatingActionButton(
          mini: true,
          heroTag: 'language_button',
          onPressed: () {
            _showLanguages(
              context,
              state.language,
            );
          },
          child: const Icon(Icons.language),
        );
      },
    );
  }

  void _showLanguages(
      BuildContext context,
      String currentLanguage,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _languageItem(
                  context,
                  'uz',
                  AppLocalizations.text(
                    'uzbek',
                    state.language,
                  ),
                  currentLanguage,
                ),
                _languageItem(
                  context,
                  'ru',
                  AppLocalizations.text(
                    'russian',
                    state.language,
                  ),
                  currentLanguage,
                ),
                _languageItem(
                  context,
                  'en',
                  AppLocalizations.text(
                    'english',
                    state.language,
                  ),
                  currentLanguage,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _languageItem(
      BuildContext context,
      String language,
      String title,
      String currentLanguage,
      ) {
    return ListTile(
      title: Text(title),
      trailing: language == currentLanguage
          ? const Icon(Icons.check)
          : null,
      onTap: () {
        context.read<MapBloc>().add(
          MapLanguageChanged(language),
        );

        Navigator.pop(context);
      },
    );
  }
}