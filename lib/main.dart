import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const FlutterFileManagerApp());
}

class FlutterFileManagerApp extends StatelessWidget {
  const FlutterFileManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Files',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0BCFF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const FileExplorerHomeScreen(),
    );
  }
}

enum FileCategory { images, videos, audio, documents, apps, archives, code, others }

class FileEntity {
  final String id;
  String name;
  final String path;
  final String? parentId;
  final bool isFolder;
  final FileCategory category;
  final int size; // in bytes
  DateTime updatedAt;
  bool isStarred;
  bool isSafeFolder;
  String content;

  FileEntity({
    required this.id,
    required this.name,
    required this.path,
    this.parentId,
    required this.isFolder,
    required this.category,
    required this.size,
    required this.updatedAt,
    this.isStarred = false,
    this.isSafeFolder = false,
    this.content = '',
  });

  String get formattedSize {
    if (isFolder) return 'Folder';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(updatedAt);
  }
}

class FileExplorerHomeScreen extends StatefulWidget {
  const FileExplorerHomeScreen({super.key});

  @override
  State<FileExplorerHomeScreen> createState() => _FileExplorerHomeScreenState();
}

class _FileExplorerHomeScreenState extends State<FileExplorerHomeScreen> {
  int _currentTabIndex = 1; // 0: Clean, 1: Browse, 2: Starred, 3: Safe
  String? _currentFolderId;
  FileCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isSearchOpen = false;
  bool _isSafeFolderUnlocked = false;
  final String _safePin = '1234';

  final List<String> _folderHistory = [];

  late List<FileEntity> _files;

  @override
  void initState() {
    super.initState();
    _initFiles();
  }

  void _initFiles() {
    _files = [
      FileEntity(
        id: 'dcim',
        name: 'DCIM',
        path: '/DCIM',
        isFolder: true,
        category: FileCategory.images,
        size: 154000000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        isStarred: true,
      ),
      FileEntity(
        id: 'downloads',
        name: 'Download',
        path: '/Download',
        isFolder: true,
        category: FileCategory.documents,
        size: 89000000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isStarred: true,
      ),
      FileEntity(
        id: 'documents',
        name: 'Documents',
        path: '/Documents',
        isFolder: true,
        category: FileCategory.documents,
        size: 32000000,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FileEntity(
        id: 'music',
        name: 'Music',
        path: '/Music',
        isFolder: true,
        category: FileCategory.audio,
        size: 45000000,
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FileEntity(
        id: 'flutter_proj',
        name: 'FlutterProjects',
        path: '/FlutterProjects',
        isFolder: true,
        category: FileCategory.code,
        size: 64000000,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isStarred: true,
      ),
      // Files inside DCIM
      FileEntity(
        id: 'img_1',
        name: 'IMG_20261002_094512.jpg',
        path: '/DCIM/IMG_20261002_094512.jpg',
        parentId: 'dcim',
        isFolder: false,
        category: FileCategory.images,
        size: 4850000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        isStarred: true,
      ),
      FileEntity(
        id: 'vid_1',
        name: 'VID_20261001_183022.mp4',
        path: '/DCIM/VID_20261001_183022.mp4',
        parentId: 'dcim',
        isFolder: false,
        category: FileCategory.videos,
        size: 24500000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      // Files inside Download
      FileEntity(
        id: 'pdf_notes',
        name: 'flutter_3.24_release_notes.pdf',
        path: '/Download/flutter_3.24_release_notes.pdf',
        parentId: 'downloads',
        isFolder: false,
        category: FileCategory.documents,
        size: 4200000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        isStarred: true,
        content: '# Flutter 3.24 Release Notes\n\n- Impeller Vulkan engine default on Android\n- Material 3 dynamic color tuning\n- WebAssembly (Wasm) production compiler',
      ),
      FileEntity(
        id: 'apk_1',
        name: 'material_theme_builder_v2.apk',
        path: '/Download/material_theme_builder_v2.apk',
        parentId: 'downloads',
        isFolder: false,
        category: FileCategory.apps,
        size: 28400000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      FileEntity(
        id: 'zip_1',
        name: 'assets_bundle.zip',
        path: '/Download/assets_bundle.zip',
        parentId: 'downloads',
        isFolder: false,
        category: FileCategory.archives,
        size: 14500000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      // Safe folder files
      FileEntity(
        id: 'safe_notes',
        name: 'recovery_seed_backup.txt',
        path: '/SafeFolder/recovery_seed_backup.txt',
        isFolder: false,
        category: FileCategory.documents,
        size: 104,
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        isSafeFolder: true,
        content: 'SECRET RECOVERY SEED (DO NOT SHARE):\nalpha harbor summit vintage velvet timber orbit horizon ripple quartz cascade zenith',
      ),
    ];
  }

  void _navigateToFolder(String? folderId) {
    setState(() {
      _selectedCategory = null;
      _folderHistory.add(_currentFolderId ?? '');
      _currentFolderId = folderId;
    });
  }

  void _navigateBack() {
    if (_selectedCategory != null) {
      setState(() => _selectedCategory = null);
      return;
    }
    if (_folderHistory.isNotEmpty) {
      setState(() {
        final prev = _folderHistory.removeLast();
        _currentFolderId = prev.isEmpty ? null : prev;
      });
    }
  }

  List<FileEntity> get _visibleFiles {
    List<FileEntity> list;
    if (_currentTabIndex == 2) {
      list = _files.where((f) => f.isStarred && !f.isSafeFolder).toList();
    } else if (_currentTabIndex == 3) {
      list = _isSafeFolderUnlocked ? _files.where((f) => f.isSafeFolder).toList() : [];
    } else if (_selectedCategory != null) {
      list = _files.where((f) => !f.isFolder && f.category == _selectedCategory && !f.isSafeFolder).toList();
    } else {
      list = _files.where((f) => f.parentId == _currentFolderId && !f.isSafeFolder).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((f) => f.name.toLowerCase().contains(q)).toList();
    }

    list.sort((a, b) {
      if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
      return a.name.compareTo(b.name);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBack = _folderHistory.isNotEmpty || _selectedCategory != null;

    return Scaffold(
      appBar: AppBar(
        leading: canBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF6750A4),
                  child: Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
        title: _isSearchOpen
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(
                _currentTabIndex == 0
                    ? 'Clean Storage'
                    : _currentTabIndex == 2
                        ? 'Starred Items'
                        : _currentTabIndex == 3
                            ? 'Safe Folder'
                            : _currentFolderId != null
                                ? _files.firstWhere((f) => f.id == _currentFolderId).name
                                : 'Flutter Files',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showAppInfoDialog(),
          ),
        ],
      ),
      body: _buildCurrentTabBody(theme),
      floatingActionButton: _currentTabIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showCreateDialog(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
            _selectedCategory = null;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.cleaning_services_outlined), selectedIcon: Icon(Icons.cleaning_services), label: 'Clean'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: 'Starred'),
          NavigationDestination(icon: Icon(Icons.lock_outline), selectedIcon: Icon(Icons.lock), label: 'Safe'),
        ],
      ),
    );
  }

  Widget _buildCurrentTabBody(ThemeData theme) {
    if (_currentTabIndex == 0) {
      return _buildCleanView(theme);
    }
    if (_currentTabIndex == 3 && !_isSafeFolderUnlocked) {
      return _buildSafeFolderLockView(theme);
    }

    final files = _visibleFiles;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_currentTabIndex == 1 && _currentFolderId == null && _selectedCategory == null && _searchQuery.isEmpty) ...[
          _buildStorageOverviewCard(theme),
          const SizedBox(height: 16),
          _buildCategoriesGrid(theme),
          const SizedBox(height: 20),
          const Text('Storage Folders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
        ],
        if (files.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('No files or folders found', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...files.map((file) => _buildFileTile(file, theme)),
      ],
    );
  }

  Widget _buildStorageOverviewCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Internal Storage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                const Text('24.2 GB / 128 GB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.19,
                minHeight: 10,
                backgroundColor: Colors.black12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(ThemeData theme) {
    final categories = [
      {'cat': FileCategory.images, 'name': 'Images', 'icon': Icons.image, 'color': Colors.redAccent},
      {'cat': FileCategory.videos, 'name': 'Videos', 'icon': Icons.videocam, 'color': Colors.amber},
      {'cat': FileCategory.audio, 'name': 'Audio', 'icon': Icons.music_note, 'color': Colors.purple},
      {'cat': FileCategory.documents, 'name': 'Documents', 'icon': Icons.description, 'color': Colors.blue},
      {'cat': FileCategory.apps, 'name': 'Apps', 'icon': Icons.android, 'color': Colors.green},
      {'cat': FileCategory.archives, 'name': 'Archives', 'icon': Icons.archive, 'color': Colors.orange},
      {'cat': FileCategory.code, 'name': 'Flutter & Code', 'icon': Icons.code, 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, idx) {
        final c = categories[idx];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() => _selectedCategory = c['cat'] as FileCategory);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: (c['color'] as Color).withOpacity(0.15),
                child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(c['name'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileTile(FileEntity file, ThemeData theme) {
    IconData icon;
    Color color;

    if (file.isFolder) {
      icon = Icons.folder;
      color = Colors.amber;
    } else {
      switch (file.category) {
        case FileCategory.images:
          icon = Icons.image;
          color = Colors.redAccent;
          break;
        case FileCategory.videos:
          icon = Icons.movie;
          color = Colors.amber;
          break;
        case FileCategory.audio:
          icon = Icons.music_note;
          color = Colors.purple;
          break;
        case FileCategory.apps:
          icon = Icons.android;
          color = Colors.green;
          break;
        case FileCategory.archives:
          icon = Icons.archive;
          color = Colors.orange;
          break;
        case FileCategory.code:
          icon = Icons.code;
          color = Colors.teal;
          break;
        case FileCategory.documents:
        default:
          icon = Icons.insert_drive_file;
          color = Colors.blue;
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${file.formattedSize} · ${file.formattedDate}', style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: Icon(file.isStarred ? Icons.star : Icons.star_border, color: file.isStarred ? Colors.amber : Colors.grey),
          onPressed: () {
            setState(() => file.isStarred = !file.isStarred);
          },
        ),
        onTap: () {
          if (file.isFolder) {
            _navigateToFolder(file.id);
          } else {
            _showFilePreview(file);
          }
        },
      ),
    );
  }

  Widget _buildCleanView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8DEF8),
              child: Icon(Icons.cleaning_services, size: 40, color: Color(0xFF6750A4)),
            ),
            const SizedBox(height: 20),
            const Text('Storage Cleaner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sweep temporary cache, junk files, and app logs.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Cleaned 142 MB of junk cache!')),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Clean 142 MB Junk'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeFolderLockView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFFFD8E4),
              child: Icon(Icons.lock, size: 40, color: Color(0xFFB3261E)),
            ),
            const SizedBox(height: 20),
            const Text('Safe Folder is Locked', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter 4-digit PIN to access encrypted files (Default: 1234)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showPinDialog(),
              icon: const Icon(Icons.key),
              label: const Text('Enter PIN'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog() {
    String entered = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Safe Folder PIN'),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter 4 digits (1234)'),
          onChanged: (val) => entered = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (entered == _safePin) {
                Navigator.pop(ctx);
                setState(() => _isSafeFolderUnlocked = true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN! Try 1234')),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder Name'),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.trim().isNotEmpty) {
                setState(() {
                  _files.insert(
                    0,
                    FileEntity(
                      id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
                      name: name.trim(),
                      path: '/$name',
                      parentId: _currentFolderId,
                      isFolder: true,
                      category: FileCategory.others,
                      size: 0,
                      updatedAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showFilePreview(FileEntity file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Size: ${file.formattedSize} · Path: ${file.path}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(height: 24),
            if (file.content.isNotEmpty) ...[
              const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                child: Text(file.content, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Simulated download: ${file.name}')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download File'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfoDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter Files',
      applicationVersion: '1.0.0',
      applicationIcon: const CircleAvatar(
        backgroundColor: Color(0xFF6750A4),
        child: Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: const [
        Text('Built with Flutter 3.24 & Material Design 3.'),
        SizedBox(height: 8),
        Text('Includes full virtual storage management, safe folder encryption, and storage cleaner.'),
      ],
    );
  }
}
