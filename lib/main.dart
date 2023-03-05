import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_activity_sunday/recipeRepository.dart';
import 'package:lab_activity_sunday/recipe.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
         primarySwatch: Colors.red,
      ),
      home: const LoginPage(),
    );
  }
}

//login page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = "";

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const RecipePage()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _emailController.clear();
        _passwordController.clear();
      });

      _showDialog('Message', 'User created successfully');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  //show dialog box
  Future<void> _showDialog(String type, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login | Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              _errorMessage,
              style: const TextStyle(color: Color.fromARGB(255, 47, 18, 209)),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//add recipe

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  List<String> ingredients = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  final RecipeRepository _recipeRepository = RecipeRepository();
  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipeRepository.addRecipe(recipe);
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const RecipePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Recipe'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                    hintText: "Enter title"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                    hintText: "Enter description"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ingredients',
                    hintText: "Enter ingredients"),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    ingredients.add(_ingredientsController.text);
                    _ingredientsController.clear();
                  });
                },
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("Enterd Ingredient :  ${ingredients.toString()}"),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  _addRecipe(Recipe(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      ingredients: ingredients));
                },
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ));
  }
}

//display recipe

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  @override
  Widget build(BuildContext context) {
    final RecipeRepository recipeRepository = RecipeRepository();

    //delete function
    void _DeleteRecipe(String id) {
      setState(() {
        recipeRepository.deleteRecipe(id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: recipeRepository.getAllRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<Recipe>? recipes = snapshot.data;
                    return ListView.builder(
                      itemCount: recipes!.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(recipe.title.toString()),
                            subtitle: Text(recipe.description.toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OneRecipe(recipe),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility,
                                      color: Color.fromARGB(255, 223, 251, 40)),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateRecipe(recipe),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _DeleteRecipe(recipe.id.toString());
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecipePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//one recipe

class OneRecipe extends StatelessWidget {
  final Recipe? recipe;
  const OneRecipe(this.recipe, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("one recipe"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Title : ${recipe!.title.toString()}"),
            Text("Description : ${recipe!.description.toString()}"),
            Text("Ingredients : ${recipe!.ingredients.toString()}"),
          ],
        ),
      ),
    );
  }
}

//update recipe

class UpdateRecipe extends StatefulWidget {
  final Recipe? recipe;
  const UpdateRecipe(this.recipe, {super.key});

  @override
  State<UpdateRecipe> createState() => _UpdateRecipeState();
}

class _UpdateRecipeState extends State<UpdateRecipe> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final RecipeRepository recipeRepository = RecipeRepository();

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.recipe!.title.toString();
    _descriptionController.text = widget.recipe!.description.toString();

    void _updateRecipe(Recipe recipe) {
      setState(() {
        recipeRepository.updateRecipe(recipe);
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const RecipePage();
      }));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                  hintText: "Enter title"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                  hintText: "Enter description"),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Ingredients: ${widget.recipe!.ingredients}"),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                _updateRecipe(Recipe(
                    id: widget.recipe!.id,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    ingredients: widget.recipe!.ingredients));
              },
              child: const Text('Update Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
