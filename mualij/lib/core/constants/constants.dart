import 'package:flutter/material.dart';
import 'package:mualij/features/feed/feed_screen.dart';
import 'package:mualij/features/post/screens/add_post_screen.dart';

class Constants {
  static const logoPath = 'assets/images/logo.png';
  static const loginEmotePath = 'assets/images/loginEmote.jpg';
  static const googlePath = 'assets/images/google.png';
  static const loginLogo = 'assets/images/lgoinlogo.jpg';

  static const bannerDefault = 
      'https://raw.githubusercontent.com/mrZAIN-ALI/assetRepo/main/mualij/banner.jpg';
  // static const avatarDefault =
  //     'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';
  static const avatarDefault = 'https://raw.githubusercontent.com/mrZAIN-ALI/assetRepo/main/mualij/avatar.png';
  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
  ];

  static const IconData up =
      IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down =
      IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };

  
}
