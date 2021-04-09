import 'package:workout_tracker/datasources/local/sembast_database/daos/quote_dao.dart';
import 'package:workout_tracker/datasources/remote/api_base_helper.dart';
import 'package:workout_tracker/datasources/remote/api_exception.dart';
import 'package:workout_tracker/models/quote.dart';

class QuoteRepository {
  static final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();
  static final QuoteDao _quoteDao = QuoteDao();
  static const String _url =
      "https://api.forismatic.com/api/1.0/?method=getQuote&lang=en&format=json";

  static Future<Quote> fetchQuote() async {
    Quote quote;
    try {
      quote = await _fetchQuoteFromServer();
      if (quote != null) {
        _quoteDao.insert(quote);
        return quote;
      } else {
        quote = await _fetchQuoteFromDb();
        return quote;
      }
    } on ApiException {
      quote = await _fetchQuoteFromDb();
      return quote;
    }
  }

  static Future<Quote> _fetchQuoteFromServer() async {
    var response = await _apiBaseHelper.get(_url);
    if (response is Map) {
      return Quote.fromJson(response);
    } else
      return null;
  }

  static Future<Quote> _fetchQuoteFromDb() async {
    return await _quoteDao.getRandom();
  }
}
