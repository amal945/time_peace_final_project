import 'package:flutter/material.dart';

import '../../model/order_model.dart';
import '../../model/tracker_model.dart';

class OrderTrackerZen extends StatelessWidget {
  final List<TrackerData> trackerData;

  const OrderTrackerZen({Key? key, required this.trackerData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: trackerData.length,
      itemBuilder: (context, index) {
        final data = trackerData[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: Colors.green[400],
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(data.date),
                  SizedBox(height: 10),
                  ...data.trackerDetails.map((detail) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.title,
                              style: TextStyle(color: Colors.grey[100]),
                            ),
                            Text(
                              detail.datetime,
                              style: TextStyle(color: Colors.grey[100]),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrderTracking extends StatefulWidget {
  final Orders order;

  const OrderTracking({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  List<TrackerData> trackerDataList = [];

  @override
  void initState() {
    super.initState();
    _buildTrackerDataList(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Tracking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order.orderId}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Expanded(
              child: OrderTrackerZen(trackerData: trackerDataList),
            ),
          ],
        ),
      ),
    );
  }

  void _buildTrackerDataList(Orders order) {
    trackerDataList.clear();

    for (int i = 0; i < order.orderStatus.length; i++) {
      trackerDataList.add(
        TrackerData(
          title: order.orderStatus[i],
          date: order.statusTimes[i],
          trackerDetails: [
            TrackerDetails(
              title: order.orderStatus[i],
              datetime: order.statusTimes[i],
            ),
          ],
        ),
      );
    }
  }
}
