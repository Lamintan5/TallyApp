import 'package:country_picker/country_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../../main.dart';

class TFormat{
  Country _country = CountryParser.parseCountryCode('US');
  String toCamelCase(String input) {
    List<String> words = input.split(RegExp(r'[\s_]+'));
    if (words.isEmpty) return input;

    String camelCaseString = words.first[0].toUpperCase() + words.first.substring(1).toLowerCase();
    for (int i = 1; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        camelCaseString += ' ' + word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    }

    return camelCaseString;
  }

  String getOrdinal(int floor) {
    if (floor % 100 >= 11 && floor % 100 <= 13) {
      return '${floor}th';
    }
    switch (floor % 10) {
      case 1:
        return '${floor}st';
      case 2:
        return '${floor}nd';
      case 3:
        return '${floor}rd';
      default:
        return '${floor}th';
    }
  }

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  double adjustHighestNumber(double number) {
    if (number >= 1 && number < 10) {
      return 10;
    } else if (number >= 10 && number < 100) {
      return 100;
    } else if (number >= 100 && number < 1000) {
      return 1000;
    } else if (number >= 1000 && number < 10000) {
      return 10000;
    } else if (number >= 10000 && number < 100000) {
      return 100000;
    } else if (number >= 100000 && number < 1000000) {
      return 1000000;
    } else if (number >= 1000000 && number < 10000000) {
      return 10000000;
    }
    return number;
  }

  String encryptText(String text, String id){
    final aesKey = encrypt.Key.fromUtf8(sha256.convert(utf8.encode(id)).toString().substring(0, 32));
    final iv = encrypt.IV.allZerosOfLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final encryptedText = encrypter.encrypt(text, iv: iv).base64;
    return encryptedText;
  }
  // Decryption
  String decryptField(String encryptedText, String eid) {
    final aesKey = encrypt.Key.fromUtf8(sha256.convert(utf8.encode(eid)).toString().substring(0, 32));
    final iv = encrypt.IV.allZerosOfLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    return encrypter.decrypt64(encryptedText, iv: iv);
  }

  String getCurrency() {
    return countryToCurrency[currentUser.country] ?? 'Unknown';
  }

  String? getCurrencyCode() {
    return countryToCurrencyCode[currentUser.country];
  }

  final Map<String, String> countryToCurrency = {
    "AD": "€", // Andorra
    "AE": "د.إ", // United Arab Emirates
    "AF": "؋", // Afghanistan
    "AG": "\$", // Antigua and Barbuda
    "AI": "\$", // Anguilla
    "AL": "L", // Albania
    "AM": "֏", // Armenia
    "AO": "Kz", // Angola
    "AR": "\$", // Argentina
    "AS": "\$", // American Samoa
    "AT": "€", // Austria
    "AU": "\$", // Australia
    "AW": "\$", // Aruba
    "AX": "€", // Åland Islands
    "AZ": "₼", // Azerbaijan
    "BA": "KM", // Bosnia and Herzegovina
    "BB": "\$", // Barbados
    "BD": "৳", // Bangladesh
    "BE": "€", // Belgium
    "BF": "CFA", // Burkina Faso
    "BG": "лв", // Bulgaria
    "BH": ".د.ب", // Bahrain
    "BI": "FBu", // Burundi
    "BJ": "CFA", // Benin
    "BL": "€", // Saint Barthélemy
    "BM": "\$", // Bermuda
    "BN": "\$", // Brunei
    "BO": "Bs.", // Bolivia
    "BQ": "€", // Bonaire, Sint Eustatius, and Saba
    "BR": "R\$", // Brazil
    "BS": "\$", // Bahamas
    "BT": "Nu.", // Bhutan
    "BV": "N/A", // Bouvet Island
    "BW": "P", // Botswana
    "BY": "Br", // Belarus
    "BZ": "BZ\$", // Belize
    "CA": "\$", // Canada
    "CC": "\$", // Cocos (Keeling) Islands
    "CD": "FC", // Democratic Republic of the Congo
    "CF": "CFA", // Central African Republic
    "CG": "CFA", // Republic of the Congo
    "CH": "CHF", // Switzerland
    "CI": "CFA", // Côte d'Ivoire
    "CK": "\$", // Cook Islands
    "CL": "\$", // Chile
    "CM": "CFA", // Cameroon
    "CN": "¥", // China
    "CO": "\$", // Colombia
    "CR": "₡", // Costa Rica
    "CU": "\$", // Cuba
    "CV": "\$", // Cape Verde
    "CW": "\$", // Curaçao
    "CX": "\$", // Christmas Island
    "CY": "€", // Cyprus
    "CZ": "Kč", // Czech Republic
    "DE": "€", // Germany
    "DJ": "Fdj", // Djibouti
    "DK": "kr", // Denmark
    "DM": "\$", // Dominica
    "DO": "\$", // Dominican Republic
    "DZ": "د.ج", // Algeria
    "EC": "\$", // Ecuador
    "EE": "€", // Estonia
    "EG": "E£", // Egypt
    "EH": "MAD", // Western Sahara
    "ER": "Nfk", // Eritrea
    "ES": "€", // Spain
    "ET": "Br", // Ethiopia
    "FI": "€", // Finland
    "FJ": "\$", // Fiji
    "FM": "\$", // Micronesia
    "FO": "kr", // Faroe Islands
    "FR": "€", // France
    "GA": "CFA", // Gabon
    "GB": "£", // United Kingdom
    "GD": "\$", // Grenada
    "GE": "₾", // Georgia
    "GF": "€", // French Guiana
    "GG": "£", // Guernsey
    "GH": "GH₵", // Ghana
    "GI": "£", // Gibraltar
    "GL": "kr", // Greenland
    "GM": "D", // Gambia
    "GN": "FG", // Guinea
    "GP": "€", // Guadeloupe
    "GQ": "E", // Equatorial Guinea
    "GR": "€", // Greece
    "GT": "Q", // Guatemala
    "GU": "\$", // Guam
    "GW": "CFA", // Guinea-Bissau
    "GY": "\$", // Guyana
    "HK": "\$", // Hong Kong
    "HM": "AUD", // Heard Island and McDonald Islands
    "HN": "L", // Honduras
    "HR": "kn", // Croatia
    "HT": "G", // Haiti
    "HU": "Ft", // Hungary
    "ID": "Rp", // Indonesia
    "IE": "€", // Ireland
    "IL": "₪", // Israel
    "IM": "£", // Isle of Man
    "IN": "₹", // India
    "IO": "\$", // British Indian Ocean Territory
    "IQ": "ع.د", // Iraq
    "IR": "﷼", // Iran
    "IS": "kr", // Iceland
    "IT": "€", // Italy
    "JE": "£", // Jersey
    "JM": "J\$", // Jamaica
    "JO": "JD", // Jordan
    "JP": "¥", // Japan
    "KE": "Ksh", // Kenya
    "KG": "с", // Kyrgyzstan
    "KH": "៛", // Cambodia
    "KI": "\$", // Kiribati
    "KM": "CF", // Comoros
    "KN": "\$", // Saint Kitts and Nevis
    "KP": "₩", // North Korea
    "KR": "₩", // South Korea
    "KW": "KD", // Kuwait
    "KY": "\$", // Cayman Islands
    "KZ": "₸", // Kazakhstan
    "LA": "₭", // Laos
    "LB": "ل.ل", // Lebanon
    "LC": "\$", // Saint Lucia
    "LI": "CHF", // Liechtenstein
    "LK": "රු", // Sri Lanka
    "LR": "\$", // Liberia
    "LS": "L", // Lesotho
    "LT": "€", // Lithuania
    "LU": "€", // Luxembourg
    "LV": "€", // Latvia
    "LY": "ل.د", // Libya
    "MA": "د.م.", // Morocco
    "MC": "€", // Monaco
    "MD": "MDL", // Moldova
    "ME": "€", // Montenegro
    "MF": "€", // Saint Martin
    "MG": "Ar", // Madagascar
    "MH": "\$", // Marshall Islands
    "MK": "ден", // North Macedonia
    "ML": "CFA", // Mali
    "MM": "K", // Myanmar
    "MN": "₮", // Mongolia
    "MO": "MOP\$", // Macau
    "MP": "\$", // Northern Mariana Islands
    "MQ": "€", // Martinique
    "MR": "UM", // Mauritania
    "MS": "\$", // Montserrat
    "MT": "€", // Malta
    "MU": "₨", // Mauritius
    "MV": "ރ.", // Maldives
    "MW": "MK", // Malawi
    "MX": "\$", // Mexico
    "MY": "RM", // Malaysia
    "MZ": "MT", // Mozambique
    "NA": "\$", // Namibia
    "NC": "XPF", // New Caledonia
    "NE": "CFA", // Niger
    "NF": "\$", // Norfolk Island
    "NG": "₦", // Nigeria
    "NI": "C\$", // Nicaragua
    "NL": "€", // Netherlands
    "NO": "kr", // Norway
    "NP": "₨", // Nepal
    "NR": "\$", // Nauru
    "NU": "\$", // Niue
    "NZ": "\$", // New Zealand
    "OM": "ر.ع.", // Oman
    "PA": "B/.", // Panama
    "PE": "S/.", // Peru
    "PF": "XPF", // French Polynesia
    "PG": "K", // Papua New Guinea
    "PH": "₱", // Philippines
    "PK": "₨", // Pakistan
    "PL": "zł", // Poland
    "PM": "€", // Saint Pierre and Miquelon
    "PN": "\$", // Pitcairn Islands
    "PR": "\$", // Puerto Rico
    "PS": "₪", // Palestine
    "PT": "€", // Portugal
    "PW": "\$", // Palau
    "PY": "₲", // Paraguay
    "QA": "ر.ق", // Qatar
    "RE": "€", // Réunion
    "RO": "lei", // Romania
    "RS": "дин", // Serbia
    "RU": "₽", // Russia
    "RW": "FRw", // Rwanda
    "SA": "ر.س", // Saudi Arabia
    "SB": "\$", // Solomon Islands
    "SC": "₨", // Seychelles
    "SD": "ج.س.", // Sudan
    "SE": "kr", // Sweden
    "SG": "\$", // Singapore
    "SH": "£", // Saint Helena
    "SI": "€", // Slovenia
    "SJ": "kr", // Svalbard and Jan Mayen
    "SK": "€", // Slovakia
    "SL": "Le", // Sierra Leone
    "SM": "€", // San Marino
    "SN": "CFA", // Senegal
    "SO": "Sh", // Somalia
    "SR": "\$", // Suriname
    "SS": "£", // South Sudan
    "ST": "Db", // São Tomé and Príncipe
    "SV": "\$", // El Salvador
    "SX": "\$", // Sint Maarten
    "SY": "ل.س", // Syria
    "SZ": "L", // Eswatini
    "TC": "\$", // Turks and Caicos Islands
    "TD": "CFA", // Chad
    "TF": "€", // French Southern Territories
    "TG": "CFA", // Togo
    "TH": "฿", // Thailand
    "TJ": "ЅМ", // Tajikistan
    "TK": "\$", // Tokelau
    "TL": "\$", // Timor-Leste
    "TM": "m", // Turkmenistan
    "TN": "د.ت", // Tunisia
    "TO": "T\$", // Tonga
    "TR": "₺", // Turkey
    "TT": "TT\$", // Trinidad and Tobago
    "TV": "\$", // Tuvalu
    "TW": "NT\$", // Taiwan
    "TZ": "TSh", // Tanzania
    "UA": "₴", // Ukraine
    "UG": "USh", // Uganda
    "UM": "\$", // United States Minor Outlying Islands
    "US": "\$", // United States
    "UY": "\$", // Uruguay
    "UZ": "so'm", // Uzbekistan
    "VA": "€", // Vatican City
    "VC": "\$", // Saint Vincent and the Grenadines
    "VE": "Bs.", // Venezuela
    "VG": "\$", // British Virgin Islands
    "VI": "\$", // U.S. Virgin Islands
    "VN": "₫", // Vietnam
    "VU": "Vt", // Vanuatu
    "WF": "XPF", // Wallis and Futuna
    "WS": "T", // Samoa
    "YE": "﷼", // Yemen
    "YT": "€", // Mayotte
    "ZA": "R", // South Africa
    "ZM": "ZK", // Zambia
    "ZW": "\$", // Zimbabwe
  };
  final Map<String, String> countryToCurrencyCode = {
    'AF': 'AFN', 'AL': 'ALL', 'DZ': 'DZD', 'AS': 'USD', 'AD': 'EUR',
    'AO': 'AOA', 'AI': 'XCD', 'AG': 'XCD', 'AR': 'ARS', 'AM': 'AMD',
    'AW': 'AWG', 'AU': 'AUD', 'AT': 'EUR', 'AZ': 'AZN', 'BS': 'BSD',
    'BH': 'BHD', 'BD': 'BDT', 'BB': 'BBD', 'BY': 'BYN', 'BE': 'EUR',
    'BZ': 'BZD', 'BJ': 'XOF', 'BM': 'BMD', 'BT': 'BTN', 'BO': 'BOB',
    'BA': 'BAM', 'BW': 'BWP', 'BR': 'BRL', 'BN': 'BND', 'BG': 'BGN',
    'BF': 'XOF', 'BI': 'BIF', 'CV': 'CVE', 'KH': 'KHR', 'CM': 'XAF',
    'CA': 'CAD', 'KY': 'KYD', 'CF': 'XAF', 'TD': 'XAF', 'CL': 'CLP',
    'CN': 'CNY', 'CO': 'COP', 'KM': 'KMF', 'CD': 'CDF', 'CG': 'XAF',
    'CR': 'CRC', 'HR': 'HRK', 'CU': 'CUP', 'CY': 'EUR', 'CZ': 'CZK',
    'DK': 'DKK', 'DJ': 'DJF', 'DM': 'XCD', 'DO': 'DOP', 'EC': 'USD',
    'EG': 'EGP', 'SV': 'USD', 'GQ': 'XAF', 'ER': 'ERN', 'EE': 'EUR',
    'SZ': 'SZL', 'ET': 'ETB', 'FJ': 'FJD', 'FI': 'EUR', 'FR': 'EUR',
    'GA': 'XAF', 'GM': 'GMD', 'GE': 'GEL', 'DE': 'EUR', 'GH': 'GHS',
    'GI': 'GIP', 'GR': 'EUR', 'GL': 'DKK', 'GD': 'XCD', 'GU': 'USD',
    'GT': 'GTQ', 'GN': 'GNF', 'GW': 'XOF', 'GY': 'GYD', 'HT': 'HTG',
    'HN': 'HNL', 'HK': 'HKD', 'HU': 'HUF', 'IS': 'ISK', 'IN': 'INR',
    'ID': 'IDR', 'IR': 'IRR', 'IQ': 'IQD', 'IE': 'EUR', 'IL': 'ILS',
    'IT': 'EUR', 'JM': 'JMD', 'JP': 'JPY', 'JO': 'JOD', 'KZ': 'KZT',
    'KE': 'KES', 'KI': 'AUD', 'KP': 'KPW', 'KR': 'KRW', 'KW': 'KWD',
    'KG': 'KGS', 'LA': 'LAK', 'LV': 'EUR', 'LB': 'LBP', 'LS': 'LSL',
    'LR': 'LRD', 'LY': 'LYD', 'LI': 'CHF', 'LT': 'EUR', 'LU': 'EUR',
    'MO': 'MOP', 'MK': 'MKD', 'MG': 'MGA', 'MW': 'MWK', 'MY': 'MYR',
    'MV': 'MVR', 'ML': 'XOF', 'MT': 'EUR', 'MH': 'USD', 'MR': 'MRU',
    'MU': 'MUR', 'MX': 'MXN', 'FM': 'USD', 'MD': 'MDL', 'MC': 'EUR',
    'MN': 'MNT', 'ME': 'EUR', 'MA': 'MAD', 'MZ': 'MZN', 'MM': 'MMK',
    'NA': 'NAD', 'NR': 'AUD', 'NP': 'NPR', 'NL': 'EUR', 'NC': 'XPF',
    'NZ': 'NZD', 'NI': 'NIO', 'NE': 'XOF', 'NG': 'NGN', 'NU': 'NZD',
    'NF': 'AUD', 'MP': 'USD', 'NO': 'NOK', 'OM': 'OMR', 'PK': 'PKR',
    'PW': 'USD', 'PA': 'PAB', 'PG': 'PGK', 'PY': 'PYG', 'PE': 'PEN',
    'PH': 'PHP', 'PL': 'PLN', 'PT': 'EUR', 'PR': 'USD', 'QA': 'QAR',
    'RO': 'RON', 'RU': 'RUB', 'RW': 'RWF', 'WS': 'WST', 'SM': 'EUR',
    'ST': 'STN', 'SA': 'SAR', 'SN': 'XOF', 'RS': 'RSD', 'SC': 'SCR',
    'SL': 'SLL', 'SG': 'SGD', 'SK': 'EUR', 'SI': 'EUR', 'SB': 'SBD',
    'SO': 'SOS', 'ZA': 'ZAR', 'SS': 'SSP', 'ES': 'EUR', 'LK': 'LKR',
    'SD': 'SDG', 'SR': 'SRD', 'SE': 'SEK', 'CH': 'CHF', 'SY': 'SYP',
    'TW': 'TWD', 'TJ': 'TJS', 'TZ': 'TZS', 'TH': 'THB', 'TL': 'USD',
    'TG': 'XOF', 'TO': 'TOP', 'TT': 'TTD', 'TN': 'TND', 'TR': 'TRY',
    'TM': 'TMT', 'TV': 'AUD', 'UG': 'UGX', 'UA': 'UAH', 'AE': 'AED',
    'GB': 'GBP', 'US': 'USD', 'UY': 'UYU', 'UZ': 'UZS', 'VU': 'VUV',
    'VE': 'VES', 'VN': 'VND', 'YE': 'YER', 'ZM': 'ZMW', 'ZW': 'ZWL'
  };
}