import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  // app主入口，就这么多了，其实其他框架比如vue
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (create) => MyAppState(),
      child: MaterialApp(
        title: "my realization",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    } else{
      favorites.add(current);
    }
    notifyListeners();
  }
}
class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>_MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch(selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = PlaceHolderPage();
        break;
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    return LayoutBuilder(
        builder: (context,constraints){
        return Scaffold(
            body:Row(
              children: [
                SafeArea(
                    child:NavigationRail(
                      destinations: [
                        NavigationRailDestination(icon: Icon(Icons.home), label: Text("HOME")),
                        NavigationRailDestination(icon: Icon(Icons.favorite), label: Text("Favorite"))
                      ],
                      selectedIndex: selectedIndex,
                      extended: constraints.maxWidth >= 600,
                      onDestinationSelected: (value){
                        setState(() {
                          selectedIndex=value;
                        });
                      },
                    )
                ),
                Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ))
              ],
            )
        );
      });
    }

}


class PlaceHolderPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pairs = appState.favorites;

    if(pairs.isEmpty){
      return Center(
        child: Text("no favorites yet"),
      );
    }

    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("you have ${pairs.length} liked words:")
        ),
        for(var pair in pairs)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asCamelCase),
          )
      ],
    );
  }


}



class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
        elevation: 8.0,
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(pair.asCamelCase, style: style, semanticsLabel: "${pair.first} ${pair.second}",)
        )
    );
  }
}
