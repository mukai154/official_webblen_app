import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/models/webblen_stream.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/streams/stream_block/stream_block_model.dart';

class StreamBlockWidget extends StatelessWidget {
  final WebblenStream stream;

  StreamBlockWidget({@required this.stream});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StreamBlockModel>.reactive(
      viewModelBuilder: () => StreamBlockModel(),
      builder: (context, model, child) => Container(
        height: 220,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: GestureDetector(
          onTap: () => model.navigateToEventDetails(),
          child: Row(
            children: [
              Container(
                width: 50,
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    CustomText(
                      text: stream.startDate
                          .substring(4, stream.startDate.length - 6),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      text: stream.startDate
                          .substring(0, stream.startDate.length - 9),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                        stream.imageURL,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.7),
                          Colors.black.withOpacity(.2),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.more_horiz, color: Colors.white),
                                onPressed: null,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomOverflowText(
                                text: stream.title,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  CustomText(
                                    text: stream.startTime,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  model.isHappeningNow
                                      ? Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          child: Center(
                                            child: CustomText(
                                              text: "Happening Now",
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              CustomText(
                                text: "Happening Now",
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              CustomText(
                                text: "${stream.city}, ${stream.province}",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
