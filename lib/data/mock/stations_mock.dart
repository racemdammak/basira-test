import 'package:latlong2/latlong.dart';
import '../models/station.dart';

/// All stations in the SORETRAS network.
/// Station IDs must be unique and match the IDs used in [allBusLines].
const Map<String, Station> allStations = {
  // ════════════════════════════════════════════
  // LINE 1: Nassria → Bab Bhar
  // ════════════════════════════════════════════
  'nassria': Station(
    id: 'nassria',
    nameAr: 'النصرية',
    nameFr: 'Nassria',
    nameTun: 'النصرية',
    coordinates: LatLng(34.7520, 10.7630),
    lineNumbers: ['1', '10'],
  ),
  'jabri': Station(
    id: 'jabri',
    nameAr: 'الجبيري',
    nameFr: 'Jabri',
    nameTun: 'الجبيري',
    coordinates: LatLng(34.7505, 10.7615),
    lineNumbers: ['1'],
  ),
  'hached': Station(
    id: 'hached',
    nameAr: 'حشاد',
    nameFr: 'Hached',
    nameTun: 'حشاد',
    coordinates: LatLng(34.7480, 10.7580),
    lineNumbers: ['1', '6'],
  ),
  'place_15_novembre': Station(
    id: 'place_15_novembre',
    nameAr: 'ساحة 15 نوفمبر',
    nameFr: '15 Novembre',
    nameTun: '15 نوفمبر',
    coordinates: LatLng(34.7460, 10.7570),
    lineNumbers: ['1', '4'],
  ),
  'centre_ville': Station(
    id: 'centre_ville',
    nameAr: 'وسط المدينة',
    nameFr: 'Centre Ville',
    nameTun: 'وسط المدينة',
    coordinates: LatLng(34.7440, 10.7580),
    lineNumbers: ['1', '4', '10', '15'],
  ),
  'bab_jedid': Station(
    id: 'bab_jedid',
    nameAr: 'باب الجديد',
    nameFr: 'Bab Jedid',
    nameTun: 'باب الجديد',
    coordinates: LatLng(34.7425, 10.7585),
    lineNumbers: ['1'],
  ),
  'bab_bhar': Station(
    id: 'bab_bhar',
    nameAr: 'باب البحر',
    nameFr: 'Bab Bhar',
    nameTun: 'باب البحر',
    coordinates: LatLng(34.7404, 10.7594),
    lineNumbers: ['1'],
  ),

  // ════════════════════════════════════════════
  // LINE 2: Sfax Sud → Université
  // ════════════════════════════════════════════
  'sfax_sud': Station(
    id: 'sfax_sud',
    nameAr: 'صفاقس الجنوب',
    nameFr: 'Sfax Sud',
    nameTun: 'صفاقس الجنوب',
    coordinates: LatLng(34.7330, 10.7560),
    lineNumbers: ['2', '10'],
  ),
  'cite_el_izdihar': Station(
    id: 'cite_el_izdihar',
    nameAr: 'حي الازدهار',
    nameFr: 'Cité El Izdihar',
    nameTun: 'حي الازدهار',
    coordinates: LatLng(34.7320, 10.7530),
    lineNumbers: ['2'],
  ),
  'hopital_habib_bourguiba': Station(
    id: 'hopital_habib_bourguiba',
    nameAr: 'مستشفى الحبيب بورقيبة',
    nameFr: 'Hôpital Habib Bourguiba',
    nameTun: 'المستشفى',
    coordinates: LatLng(34.7350, 10.7540),
    lineNumbers: ['2', '4'],
  ),
  'moussa_ibn_noussair': Station(
    id: 'moussa_ibn_noussair',
    nameAr: 'موسى بن نصير',
    nameFr: 'Moussa Ibn Noussair',
    nameTun: 'موسى ابن نصير',
    coordinates: LatLng(34.7310, 10.7510),
    lineNumbers: ['2'],
  ),
  'hay_riadh': Station(
    id: 'hay_riadh',
    nameAr: 'حي الرياض',
    nameFr: 'Hay Riadh',
    nameTun: 'حي الرياض',
    coordinates: LatLng(34.7290, 10.7480),
    lineNumbers: ['2', '15'],
  ),
  'cite_el_amal': Station(
    id: 'cite_el_amal',
    nameAr: 'حي الأمل',
    nameFr: 'Cité El Amal',
    nameTun: 'حي الأمل',
    coordinates: LatLng(34.7275, 10.7460),
    lineNumbers: ['2'],
  ),
  'hopital_hedi_chaker': Station(
    id: 'hopital_hedi_chaker',
    nameAr: 'مستشفى الهادي شاكر',
    nameFr: 'Hôpital Hédi Chaker',
    nameTun: 'مستشفى الهادي شاكر',
    coordinates: LatLng(34.7370, 10.7430),
    lineNumbers: ['2', '15'],
  ),
  'universite': Station(
    id: 'universite',
    nameAr: 'جامعة صفاقس',
    nameFr: 'Université de Sfax',
    nameTun: 'الجامعة',
    coordinates: LatLng(34.7260, 10.7440),
    lineNumbers: ['2'],
  ),

  // ════════════════════════════════════════════
  // LINE 4: Aéroport → Médina
  // ════════════════════════════════════════════
  'aeroport': Station(
    id: 'aeroport',
    nameAr: 'المطار',
    nameFr: 'Aéroport',
    nameTun: 'المطار',
    coordinates: LatLng(34.7245, 10.6917),
    lineNumbers: ['4'],
  ),
  'cite_el_habib': Station(
    id: 'cite_el_habib',
    nameAr: 'حي الحبيب',
    nameFr: 'Cité El Habib',
    nameTun: 'حي الحبيب',
    coordinates: LatLng(34.7280, 10.7150),
    lineNumbers: ['4'],
  ),
  'route_tunis': Station(
    id: 'route_tunis',
    nameAr: 'طريق تونس',
    nameFr: 'Route Tunis',
    nameTun: 'طريق تونس',
    coordinates: LatLng(34.7480, 10.7500),
    lineNumbers: ['4', '6'],
  ),
  'medina': Station(
    id: 'medina',
    nameAr: 'المدينة العتيقة',
    nameFr: 'Médina',
    nameTun: 'المدينة',
    coordinates: LatLng(34.7410, 10.7610),
    lineNumbers: ['4'],
  ),

  // ════════════════════════════════════════════
  // LINE 6: Sakiet Ezzit → Gare Routière
  // ════════════════════════════════════════════
  'sakiet_ezzit': Station(
    id: 'sakiet_ezzit',
    nameAr: 'ساقية الزيت',
    nameFr: 'Sakiet Ezzit',
    nameTun: 'ساقية الزيت',
    coordinates: LatLng(34.7860, 10.7720),
    lineNumbers: ['6'],
  ),
  'cite_ali_baba': Station(
    id: 'cite_ali_baba',
    nameAr: 'حي علي بابا',
    nameFr: 'Cité Ali Baba',
    nameTun: 'حي علي بابا',
    coordinates: LatLng(34.7800, 10.7680),
    lineNumbers: ['6'],
  ),
  'sakiet_eddaier': Station(
    id: 'sakiet_eddaier',
    nameAr: 'ساقية الدائر',
    nameFr: 'Sakiet Eddaier',
    nameTun: 'ساقية الدائر',
    coordinates: LatLng(34.7750, 10.7650),
    lineNumbers: ['6'],
  ),
  'soukra': Station(
    id: 'soukra',
    nameAr: 'الصخيرة',
    nameFr: 'Soukra',
    nameTun: 'الصخيرة',
    coordinates: LatLng(34.7650, 10.7600),
    lineNumbers: ['6'],
  ),
  'el_firdaous': Station(
    id: 'el_firdaous',
    nameAr: 'الفردوس',
    nameFr: 'El Firdaous',
    nameTun: 'الفردوس',
    coordinates: LatLng(34.7570, 10.7560),
    lineNumbers: ['6'],
  ),
  'gare_routiere': Station(
    id: 'gare_routiere',
    nameAr: 'المحطة الطرقية',
    nameFr: 'Gare Routière',
    nameTun: 'المحطة',
    coordinates: LatLng(34.7450, 10.7530),
    lineNumbers: ['6'],
  ),

  // ════════════════════════════════════════════
  // LINE 10: Chihia → Nassria
  // ════════════════════════════════════════════
  'chihia': Station(
    id: 'chihia',
    nameAr: 'الشيحية',
    nameFr: 'Chihia',
    nameTun: 'الشيحية',
    coordinates: LatLng(34.7380, 10.7470),
    lineNumbers: ['10'],
  ),
  'cite_el_oumma': Station(
    id: 'cite_el_oumma',
    nameAr: 'حي الأمة',
    nameFr: 'Cité El Oumma',
    nameTun: 'حي الأمة',
    coordinates: LatLng(34.7390, 10.7490),
    lineNumbers: ['10'],
  ),
  'sfax_ville': Station(
    id: 'sfax_ville',
    nameAr: 'صفاقس المدينة',
    nameFr: 'Sfax Ville',
    nameTun: 'صفاقس المدينة',
    coordinates: LatLng(34.7430, 10.7560),
    lineNumbers: ['10'],
  ),
  // centre_ville and nassria already defined above

  // ════════════════════════════════════════════
  // LINE 15: Hay Ennour → Centre Ville
  // ════════════════════════════════════════════
  'hay_ennour': Station(
    id: 'hay_ennour',
    nameAr: 'حي النور',
    nameFr: 'Hay Ennour',
    nameTun: 'حي النور',
    coordinates: LatLng(34.7310, 10.7400),
    lineNumbers: ['15'],
  ),
  'cite_boudrak': Station(
    id: 'cite_boudrak',
    nameAr: 'حي بودراق',
    nameFr: 'Cité Boudrak',
    nameTun: 'حي بودراق',
    coordinates: LatLng(34.7330, 10.7410),
    lineNumbers: ['15'],
  ),
  'hay_wahat': Station(
    id: 'hay_wahat',
    nameAr: 'حي الواحات',
    nameFr: 'Hay Wahat',
    nameTun: 'حي الواحات',
    coordinates: LatLng(34.7370, 10.7450),
    lineNumbers: ['15'],
  ),
  'cite_ennour': Station(
    id: 'cite_ennour',
    nameAr: 'حي النور 2',
    nameFr: 'Cité Ennour',
    nameTun: 'حي النور 2',
    coordinates: LatLng(34.7340, 10.7420),
    lineNumbers: ['15'],
  ),
  'place_municipale': Station(
    id: 'place_municipale',
    nameAr: 'الساحة البلدية',
    nameFr: 'Place Municipale',
    nameTun: 'الساحة البلدية',
    coordinates: LatLng(34.7435, 10.7570),
    lineNumbers: ['15'],
  ),
  // centre_ville already defined above
};

List<Station> getAllStations() => allStations.values.toList();

Station? stationById(String id) => allStations[id];
