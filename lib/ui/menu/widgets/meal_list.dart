import 'package:flutter/material.dart';

import '../../../domain/model/Menu.dart';
import '../../meal_details/meal_details.dart';
import 'meal_item.dart';

class MealList extends StatefulWidget {
  const MealList({super.key, this.refreshMenuState, required this.menus});

  final Function()? refreshMenuState;
  final List<Menu>? menus;

  @override
  State<MealList> createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.menus?.length ?? 0,
        (menuIndex) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Menu Title
            Text(
              widget.menus?[menuIndex].name ?? "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),

            // List of Meals with Dividers
            Column(
              children: List.generate(
                widget.menus?[menuIndex].meals?.length ?? 0,
                (mealIndex) => Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MealDetails(
                                meal: widget
                                        .menus?[menuIndex].meals?[mealIndex],
                                    refreshMenuState: widget.refreshMenuState,
                                  )),
                        );
                      },
                      child: MealItem(
                        menus: widget.menus,
                        menuIndex: menuIndex,
                        mealIndex: mealIndex,
                      ),
                    ),
                    const Divider(),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
