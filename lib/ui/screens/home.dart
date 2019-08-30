import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:zgadula/store/category.dart';
import 'package:zgadula/store/question.dart';
import 'package:zgadula/store/tutorial.dart';
import 'package:zgadula/ui/screens/category_list.dart';
import 'package:zgadula/ui/screens/category_favorites.dart';
import 'package:zgadula/ui/screens/settings.dart';
import '../shared/widgets.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.play_circle_filled)),
    Tab(icon: Icon(Icons.favorite)),
    Tab(icon: Icon(Icons.settings)),
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);

    if (!isTutorialWatched()) {
      // Cannot navigate instantly
      // https://github.com/flutter/flutter/issues/19330
      Future.delayed(Duration(milliseconds: 10)).then((_) {
        Navigator.pushNamed(
          context,
          '/tutorial',
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isTutorialWatched() {
    return TutorialModel.of(context).isWatched;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CategoryModel>(
      builder: (context, child, model) => ScopedModelDescendant<QuestionModel>(
        builder: (context, child, qModel) {
          if (model.isLoading || qModel.isLoading || !isTutorialWatched()) {
            return ScreenLoader();
          }

          return Scaffold(
            body: Scaffold(
              bottomNavigationBar: Container(
                color: primaryDarkColor,
                height: 45,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).buttonColor,
                    unselectedLabelColor: primaryLightColor,
                    indicatorColor: primaryDarkColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: tabs,
                  ),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CategoryListScreen(),
                  CategoryFavoritesScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
