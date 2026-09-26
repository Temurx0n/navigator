class AppLocalizations {
  static const Map<String, Map<String, String>> _values = {
    'uz': {
      'app_name': 'Navigator',
      'my_location': 'Mening joylashuvim',
      'distance': 'Masofa',
      'language': 'Til',
      'uzbek': 'O‘zbekcha',
      'russian': 'Ruscha',
      'english': 'Inglizcha',
      'online': 'Internet mavjud',
      'offline': 'Internet yo‘q',
    },
    'ru': {
      'app_name': 'Navigator',
      'my_location': 'Моё местоположение',
      'distance': 'Расстояние',
      'language': 'Язык',
      'uzbek': 'Узбекский',
      'russian': 'Русский',
      'english': 'Английский',
      'online': 'Интернет есть',
      'offline': 'Нет интернета',
    },
    'en': {
      'app_name': 'Navigator',
      'my_location': 'My location',
      'distance': 'Distance',
      'language': 'Language',
      'uzbek': 'Uzbek',
      'russian': 'Russian',
      'english': 'English',
      'online': 'Online',
      'offline': 'Offline',
    },
  };

  static String text(
      String key,
      String language,
      ) {
    return _values[language]?[key] ??
        _values['uz']?[key] ??
        key;
  }
}