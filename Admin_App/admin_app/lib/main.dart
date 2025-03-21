import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeYou Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AddAffirmationScreen(),
    );
  }
}

class AddAffirmationScreen extends StatefulWidget {
  const AddAffirmationScreen({super.key});

  @override
  State<AddAffirmationScreen> createState() => _AddAffirmationScreenState();
}

class _AddAffirmationScreenState extends State<AddAffirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isLoading = false;
  String _responseMessage = '';
  bool _isSuccess = false;
  final List<String> _logs = [];

  // Define categories
  final List<String> _categories = [
    'Confidence',
    'General',
    'Abundance',
    'Love',
    'Success',
    'Gratitude',
  ];

  Future<void> _submitAffirmation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = '';
      _isSuccess = false;
    });

    try {
      // Make API call
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('https://beyou-api.onrender.com/affirmations/'));
      
      // Create request body
      request.body = json.encode({
        "text": _textController.text.trim(),
        "category": _selectedCategory,
      });
      
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      
      // Process response
      String responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response for logging
        Map<String, dynamic> responseData = json.decode(responseBody);
        String affirmationId = responseData['id'] ?? 'unknown';
        
        // Add log entry
        final timestamp = DateTime.now().toString().substring(0, 19);
        setState(() {
          _logs.add('[$timestamp] Added: "${_textController.text.substring(0, Math.min(30, _textController.text.length))}..." (ID: $affirmationId)');
          _isSuccess = true;
          _responseMessage = 'Affirmation successfully added!';
          _textController.clear();
        });
      } else {
        setState(() {
          _isSuccess = false;
          _responseMessage = 'Error: ${response.reasonPhrase}';
          
          // Add error log
          final timestamp = DateTime.now().toString().substring(0, 19);
          _logs.add('[$timestamp] Error: ${response.reasonPhrase}');
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _responseMessage = 'Error: $e';
        
        // Add error log
        final timestamp = DateTime.now().toString().substring(0, 19);
        _logs.add('[$timestamp] Exception: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeYou Admin'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if we're on a small screen (like a phone)
            final isSmallScreen = constraints.maxWidth < 600;
            
            if (isSmallScreen) {
              // Phone layout (vertical)
              return _buildPhoneLayout();
            } else {
              // Tablet/desktop layout (side by side)
              return _buildTabletLayout();
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildPhoneLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form section
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Affirmation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Affirmation Text',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the affirmation text',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter affirmation text';
                    }
                    if (value.length < 10) {
                      return 'Affirmation should be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitAffirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Submit Affirmation',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                if (_responseMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _responseMessage,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // Logs section
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text('No activity logs yet.'),
                  )
                : ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      // Display logs in reverse order (newest first)
                      final logEntry = _logs[_logs.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            logEntry,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _logs.clear();
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Logs'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form section (left side)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Affirmation',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Affirmation Text',
                      border: OutlineInputBorder(),
                      hintText: 'Enter the affirmation text',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter affirmation text';
                      }
                      if (value.length < 10) {
                        return 'Affirmation should be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitAffirmation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Submit Affirmation',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  if (_responseMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          _responseMessage,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Vertical divider
        const VerticalDivider(width: 1, thickness: 1),
        
        // Logs section (right side)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activities',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _logs.isEmpty
                      ? const Center(
                          child: Text('No activity logs yet.'),
                        )
                      : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            // Display logs in reverse order (newest first)
                            final logEntry = _logs[_logs.length - 1 - index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  logEntry,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Logs'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Added for Math.min
class Math {
  static int min(int a, int b) {
    return a < b ? a : b;
  }
}