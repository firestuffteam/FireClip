import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(300, 500),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const FireClipApp());
}

class FireClipApp extends StatelessWidget {
  const FireClipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'FireClip',
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue,
        barBackgroundColor: CupertinoColors.systemGrey6,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.white,
          textStyle: TextStyle(
            color: CupertinoColors.white,
            fontSize: 16,
          ),
        ),
      ),
      home: const ClipboardManagerPage(),
    );
  }
}

class ClipboardItem {
  final String content;
  final DateTime timestamp;

  ClipboardItem({required this.content, required this.timestamp});
}

class ClipboardManagerPage extends StatefulWidget {
  const ClipboardManagerPage({super.key});

  @override
  _ClipboardManagerPageState createState() => _ClipboardManagerPageState();
}

class _ClipboardManagerPageState extends State<ClipboardManagerPage> {
  final List<ClipboardItem> _clipboardHistory = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Timer? _clipboardTimer;
  String? _lastClipboardContent;

  @override
  void initState() {
    super.initState();
    _startClipboardListener();
    
    // Show welcome modal after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeModal();
    });
  }

  void _showWelcomeModal() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Welcome to FireClip'),
        content: const Text(
          'FireClip is an open-source, simple clipboard manager designed to help you keep track of your clipboard history.\n\n'
          'Key Features:\n'
          '• Capture clipboard text automatically\n'
          '• Search through clipboard history\n'
          '• Copy and delete individual clipboard entries\n\n'
          'This app is completely open-source and privacy-focused.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Got It'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showAppInfoModal() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About FireClip'),
        content: const Text(
          'FireClip is an open-source clipboard manager.\n\n'
          'Version: 1.0.0\n'
          'License: MIT Open Source\n\n'
          'Developed as a simple, lightweight tool to help manage clipboard history.\n\n'
          'Features:\n'
          '• Automatic clipboard tracking\n'
          '• Search functionality\n'
          '• Easy copy and delete actions\n\n'
          'Privacy Note: All clipboard data is stored locally and never shared.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startClipboardListener() {
    _clipboardTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (data != null && data.text != null) {
          if (_lastClipboardContent != data.text) {
            _updateClipboardHistory(data.text!);
            _lastClipboardContent = data.text;
          }
        }
      } catch (e) {
        print('Clipboard access error: $e');
      }
    });
  }

  void _updateClipboardHistory(String text) {
    if (!mounted) return;

    setState(() {
      if (_clipboardHistory.isEmpty || 
          _clipboardHistory.first.content != text) {
        _clipboardHistory.insert(0, ClipboardItem(
          content: text, 
          timestamp: DateTime.now()
        ));
      } else {
        _clipboardHistory.first = ClipboardItem(
          content: text, 
          timestamp: DateTime.now()
        );
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    
    final displayText = text.length > 20 
      ? '${text.substring(0, 20)}...' 
      : text;

    showCupertinoDialog(
      context: context, 
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Copied'),
        content: Text('Copied: $displayText'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _deleteClipboardItem(int index) {
    setState(() {
      _clipboardHistory.removeAt(index);
    });
  }

  List<ClipboardItem> get _filteredClipboardHistory {
    return _clipboardHistory.where((item) => 
      item.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'FireClip',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.systemGrey6,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.info_circle, 
            color: CupertinoColors.systemBlue,
          ),
          onPressed: _showAppInfoModal,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.delete, 
            color: CupertinoColors.destructiveRed,
          ),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Clear History'),
                content: const Text('Are you sure you want to clear all clipboard history?'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Clear'),
                    onPressed: () {
                      setState(() {
                        _clipboardHistory.clear();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search clipboard history',
                style: const TextStyle(color: CupertinoColors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: _filteredClipboardHistory.isEmpty
                ? Center(
                    child: Text(
                      'No clipboard history',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : GestureDetector(
                    onVerticalDragUpdate: (details) {
                      _scrollController.jumpTo(
                        _scrollController.offset - details.delta.dy
                      );
                    },
                    child: CupertinoScrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredClipboardHistory.length,
                        itemBuilder: (context, index) {
                          final item = _filteredClipboardHistory[index];
                          return _ClipboardHistoryTile(
                            content: item.content,
                            timestamp: item.timestamp,
                            onCopy: () => _copyToClipboard(item.content),
                            onDelete: () => _deleteClipboardItem(
                              _clipboardHistory.indexOf(item)
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClipboardHistoryTile extends StatelessWidget {
  final String content;
  final DateTime timestamp;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _ClipboardHistoryTile({
    required this.content,
    required this.timestamp,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('MMM d, h:mm a').format(timestamp);

    final displayContent = content.length > 200 
      ? '${content.substring(0, 200)}...' 
      : content;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayContent,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 40,
                    child: const Icon(
                      CupertinoIcons.doc_on_clipboard, 
                      color: CupertinoColors.systemBlue,
                      size: 24,
                    ),
                    onPressed: onCopy,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 40,
                    child: const Icon(
                      CupertinoIcons.delete, 
                      color: CupertinoColors.destructiveRed,
                      size: 24,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}