# External API Integration - Implementation Documentation

## ✅ Requirement: "Datenabruf von einer externen Quelle"

This implementation demonstrates fetching data from an external API following Flutter best practices.

---

## 📋 What Was Implemented

### 1. **HTTP Package** (`pubspec.yaml`)
```yaml
http: ^1.1.0
```
- Standard Dart package for HTTP requests
- Enables GET/POST requests to external APIs

### 2. **Android Permissions** (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
- Required for network access on Android devices
- Allows the app to make HTTP requests

### 3. **Data Model with JSON Deserialization** (`lib/models/exchange_rate.dart`)
- `ExchangeRate` class representing the API response structure
- `fromJson()` factory constructor for **JSON deserialization**
- Custom data structure from JSON response
- Methods for data manipulation (convert, getRateFor)

### 4. **API Service Class** (`lib/services/exchange_rate_service.dart`)
- ✅ Uses `http` package for HTTP GET requests
- ✅ Returns `Future<ExchangeRate>` for async operations
- ✅ Proper error handling with try-catch
- ✅ **NOT called in build() method** - separate service layer
- ✅ Uses frankfurter.app - free currency API (no API key needed)

**Key Methods:**
- `fetchLatestRates()` - Gets current exchange rates
- `fetchRatesForCurrencies()` - Gets rates for specific currencies
- `fetchHistoricalRates()` - Gets historical data

### 5. **FutureBuilder Widget** (`lib/widgets/exchange_rate_widget.dart`)
- ✅ Uses `FutureBuilder` to display async data
- ✅ Future stored in `initState()`, **NOT in build()**
- ✅ Proper handling of 3 states:
  - **Loading**: Shows CircularProgressIndicator
  - **Error**: Shows error message with retry button
  - **Success**: Displays exchange rate data
- ✅ Refresh functionality to re-fetch data

### 6. **Integration** (`lib/screens/screens/settings/settings_screen.dart`)
- Exchange rate widget integrated into Settings screen
- Displays live currency exchange rates for EUR
- Shows USD, GBP, JPY, CHF rates

---

## 🔍 How It Works

1. **User opens Settings screen**
2. **Widget initializes** (`initState()`)
   - Calls `ExchangeRateService.fetchLatestRates()`
   - Stores Future in `_exchangeRateFuture` field
3. **HTTP Request** is made to `https://api.frankfurter.app/latest?from=EUR`
4. **API Response** (JSON) is received
5. **Deserialization**: JSON → `ExchangeRate` object
6. **FutureBuilder displays data**:
   - While loading: Shows spinner
   - On success: Shows currency rates
   - On error: Shows error with retry option
7. **User can refresh** by tapping refresh button

---

## 📊 Example API Response

```json
{
  "amount": 1.0,
  "base": "EUR",
  "date": "2026-01-06",
  "rates": {
    "USD": 1.0345,
    "GBP": 0.8456,
    "JPY": 162.45,
    "CHF": 0.9678
  }
}
```

---

## ✅ Best Practices Followed

| Requirement | Implementation |
|------------|----------------|
| HTTP requests library | ✅ `http` package |
| Async operations | ✅ `Future<ExchangeRate>` |
| JSON deserialization | ✅ `ExchangeRate.fromJson()` |
| Android permissions | ✅ INTERNET permission |
| FutureBuilder | ✅ Used for display |
| NOT in build() | ✅ API call in initState() |
| Error handling | ✅ Try-catch + error UI |
| Loading state | ✅ CircularProgressIndicator |

---

## 🧪 Testing

The API endpoint was tested and verified:
- **Endpoint**: https://api.frankfurter.app/latest?from=EUR
- **Method**: GET
- **Response**: 200 OK
- **Format**: JSON
- **API Documentation**: https://www.frankfurter.app/docs/

---

## 🎯 Where to Find It

1. Open the app
2. Navigate to **Settings** (Profile icon → Settings)
3. Scroll down to see **"Exchange Rates"** section
4. Data is fetched automatically from external API
5. Tap refresh icon to reload live data

---

## 📁 Files Created/Modified

### New Files:
- `lib/models/exchange_rate.dart` - Data model
- `lib/services/exchange_rate_service.dart` - API service
- `lib/widgets/exchange_rate_widget.dart` - UI widget with FutureBuilder

### Modified Files:
- `pubspec.yaml` - Added http package
- `android/app/src/main/AndroidManifest.xml` - Added INTERNET permission
- `lib/screens/screens/settings/settings_screen.dart` - Integrated widget

---

## 🎓 Educational Value

This implementation demonstrates:
1. Real-world API integration
2. Asynchronous programming in Flutter
3. JSON parsing and data modeling
4. Proper state management for async data
5. Error handling and user feedback
6. Clean architecture (separation of concerns)

---

**Status: ✅ COMPLETE**
All requirements for external data fetching are fulfilled!
