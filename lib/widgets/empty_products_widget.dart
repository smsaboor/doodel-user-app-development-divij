import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../main.dart';

class ShimmeringCategoryProducts extends StatelessWidget {
  const ShimmeringCategoryProducts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 15),
      scrollDirection: Axis.vertical,
      children: [
        Column(
          children: <Widget>[
            SizedBox(height: devHeight * 0.0204),
            Container(
                width: devWidth,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: Container(
                      height: 25,
                      width: 150,
                      color: Colors.white,
                    ),
                  ),
                ])),
            const SizedBox(height: 30),
            ShimmeringProductsList(),
          ],
        ),
        Column(
          children: <Widget>[
            SizedBox(height: devHeight * 0.0204),
            Container(
                width: devWidth,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: Container(
                      height: 25,
                      width: 150,
                      color: Colors.white,
                    ),
                  ),
                ])),
            const SizedBox(height: 30),
            ShimmeringProductsList(),
          ],
        ),
      ],
    );
  }
}

class ShimmeringProductsList extends StatelessWidget {
  const ShimmeringProductsList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return ShimmeringProduct();
        },
      ),
    );
  }
}

class ShimmeringProduct extends StatelessWidget {
  const ShimmeringProduct({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15, left: 10),
      // width: devWidth * 0.2663,
      width: devHeight * 0.15,
      height: devHeight * 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              // width: devWidth * 0.2663,
              width: devHeight * 0.15,
              height: devHeight * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 10,
              width: 100,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 10,
              width: 100,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 10,
              width: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 15,
              width: 90,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 30,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 45,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmeringProductTilesList extends StatelessWidget {
  const ShimmeringProductTilesList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ShimmeringProductTile(),
        ShimmeringProductTile(),
        ShimmeringProductTile(),
        ShimmeringProductTile(),
        ShimmeringProductTile(),
        ShimmeringProductTile(),
        ShimmeringProductTile(),
      ],
    );
  }
}

class ShimmeringProductTile extends StatelessWidget {
  const ShimmeringProductTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: double.infinity,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        width: 200,
                        height: 10,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        width: 40,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                      child: Container(
                        height: 40,
                        width: 100,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Divider(height: 1),
        SizedBox(height: 5),
      ],
    );
  }
}
