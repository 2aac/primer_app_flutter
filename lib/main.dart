import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier{
  var current = WordPair.random();

  var favoritos = <WordPair>[];
  
  void getSiguiente(){
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorito(){
    if (favoritos.contains(current)) {
      favoritos.remove(current);
    } else {
      favoritos.add(current);
    }
  notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch(selectedIndex) {
      case 0: page = GeneratorPage(); break;
      case 1: page = FavoritosPage(); break;
      default:
        throw UnimplementedError('No hay un widget para: $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home), 
                      label: Text('Inicio')),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), 
                      label: Text('Favoritos'))
                  ], 
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value){
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                )
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              )
            ],
          )
        );
      }
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair idea;
  const BigCard({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textStlye = tema.textTheme.displaySmall!.copyWith(
      color: tema.colorScheme.onPrimary
    );

    return Card(
      color: tema.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(idea.asPascalCase, 
          style: textStlye,
          semanticsLabel: "${idea.first} ${idea.second}",
          ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var idea = appState.current;
    IconData icon;
    if (appState.favoritos.contains(idea)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_outline;
    }
    
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(idea: appState.current),
            const SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => appState.toggleFavorito(), 
                  icon: Icon(icon),
                  label: const Text("Favorito")
                ),
                const SizedBox(width: 10,),
                ElevatedButton.icon(
                  onPressed: () => appState.getSiguiente(),
                  icon: const Icon(Icons.navigate_next),
                  label: const Text("Siguiente")
                ),
              ],
            ),
          ]
        ),
      );
  }
}

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState =context.watch<MyAppState>();
    if(appState.favoritos.isEmpty) {
      return Center(child: Text('Aun no hay favoritos'),);
    } else {
      return ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text('Sehan elegido ${appState.favoritos.length} favoritos'),
            ),
            for (var i in appState.favoritos)
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text(i.asPascalCase),
              )
        ],
      );
    }
  }
}