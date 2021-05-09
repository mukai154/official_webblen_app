import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LiveStreamGifterContainer extends StatelessWidget {
  final String? imgURL;
  final String? username;
  final double? amountGifted;

  LiveStreamGifterContainer({required this.imgURL, required this.username, required this.amountGifted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: imgURL!,
            imageBuilder: (context, imageProvider) => Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '@$username',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 15,
                width: 15,
                child: Image.asset(
                  'assets/images/webblen_coin.png',
                ),
              ),
              SizedBox(width: 4),
              Text(
                amountGifted!.toStringAsFixed(2),
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
