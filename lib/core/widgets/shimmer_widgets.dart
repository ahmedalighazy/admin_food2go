import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../core/utils/responsive_ui.dart';

class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Shimmer(
                duration: const Duration(seconds: 2),
                color: Colors.grey[300]!,
                child: Container(
                  height: ResponsiveUI.value(context, 80),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
                      topRight: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                child: Column(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        color: Colors.grey[300]!,
                        child: Container(
                          height: ResponsiveUI.value(context, 40),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TablesShimmer extends StatelessWidget {
  const TablesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUI.gridColumns(context),
        childAspectRatio: 1.2,
        crossAxisSpacing: ResponsiveUI.spacing(context, 16),
        mainAxisSpacing: ResponsiveUI.spacing(context, 16),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.grey[300]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
            ),
          ),
        );
      },
    );
  }
}

class OverviewShimmer extends StatelessWidget {
  const OverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      child: Column(
        children: [
          Row(
            children: List.generate(2, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? ResponsiveUI.spacing(context, 16) : 0),
                  child: Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.grey[300]!,
                    child: Container(
                      height: ResponsiveUI.value(context, 120),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          Row(
            children: List.generate(2, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? ResponsiveUI.spacing(context, 16) : 0),
                  child: Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.grey[300]!,
                    child: Container(
                      height: ResponsiveUI.value(context, 120),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 24)),
          Shimmer(
            duration: const Duration(seconds: 2),
            color: Colors.grey[300]!,
            child: Container(
              height: ResponsiveUI.value(context, 120),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}