// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:device_calendar/device_calendar.dart';

part 'main.g.dart';

// ==========================================
// 1. ISAR DATABASE MODELS
// ==========================================
@collection
class ContriFolder {
  Id id = Isar.autoIncrement;
  late String title;
  late double budget;
  late DateTime deadline;
}

@collection
class Participant {
  Id id = Isar.autoIncrement;
  late int folderId;
  late String name;
  late double amountExpected;
  late double amountPaid;
  late bool isPaid;
  DateTime? datePaid;
  List<String> paymentHistory = [];
  
  // NEW: Tracking variables for Missed Payments
  late DateTime createdAt;
  late String frequency; // 'One-time', 'Daily', 'Weekly', 'Monthly'
}

// ==========================================
// 2. MAIN APP INITIALIZATION
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Timezones for the Calendar Event
  tz.initializeTimeZones();

  // Initialize Isar Database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [ContriFolderSchema, ParticipantSchema],
    directory: dir.path,
  );

  runApp(KontriApp(isar: isar));
}

// ==========================================
// 3. SHARED HELPERS (currency, colors, dates)
// ==========================================
final NumberFormat kCurrency =
    NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

const List<Color> _avatarPalette = [
  Color(0xFFFF9500), // orange
  Color(0xFF34C759), // green
  Color(0xFF0A84FF), // blue
  Color(0xFFFF375F), // pink
  Color(0xFFAF52DE), // purple
  Color(0xFF5AC8FA), // light blue
  Color(0xFFFFCC00), // yellow
  Color(0xFF30D158), // mint green
];

Color _colorForName(String name) {
  if (name.isEmpty) return _avatarPalette.first;
  final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
  return _avatarPalette[sum % _avatarPalette.length];
}

// Opens an iOS-style wheel date picker inside a bottom sheet.
Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
  DateTime temp = initial;
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SizedBox(
        height: 320,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext, temp),
                    child: const Text('Done',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: DateTime.now(),
                onDateTimeChanged: (value) => temp = value,
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ==========================================
// 4. THEME (adapts to light / dark automatically)
// ==========================================
ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  const iosBlue = Color(0xFF0A84FF);
  const iosGreen = Color(0xFF34C759);
  const iosRed = Color(0xFFFF3B30);

  final Color pageBackground =
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  final Color surfaceBackground = isDark ? const Color(0xFF1C1C1E) : Colors.white;
  final Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
  final Color onSurfaceMuted =
      isDark ? const Color(0xFF98989D) : const Color(0xFF6D6D72);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: iosBlue,
    brightness: brightness,
  ).copyWith(
    primary: iosBlue,
    onPrimary: Colors.white,
    secondary: iosGreen,
    onSecondary: Colors.white,
    error: iosRed,
    onError: Colors.white,
    surface: surfaceBackground,
    onSurface: onSurfaceColor,
    surfaceContainerHighest:
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEFEFF4),
    onSurfaceVariant: onSurfaceMuted,
    outline: onSurfaceMuted.withOpacity(0.3),
    outlineVariant: onSurfaceMuted.withOpacity(0.15),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: pageBackground,
    // Uses the native iOS system font on iOS devices; falls back
    // gracefully to the platform default (e.g. Roboto) on Android.
    fontFamily: '.SF Pro Text',
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: pageBackground,
      foregroundColor: onSurfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: onSurfaceColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: onSurfaceMuted.withOpacity(0.15),
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: iosBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: onSurfaceMuted,
      textColor: onSurfaceColor,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
          bodyColor: onSurfaceColor,
          displayColor: onSurfaceColor,
        ),
  );
}

// ==========================================
// 5. APP ROOT
// ==========================================
class KontriApp extends StatefulWidget {
  final Isar isar;
  const KontriApp({super.key, required this.isar});

  // Allows the toggle button anywhere in the tree to flip the theme.
  // ignore: library_private_types_in_public_api
  static _KontriAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_KontriAppState>()!;

  @override
  State<KontriApp> createState() => _KontriAppState();
}

class _KontriAppState extends State<KontriApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontri',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: DashboardScreen(isar: widget.isar),
    );
  }
}

// ==========================================
// 6. SMALL REUSABLE WIDGETS
// ==========================================
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _KontriTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _KontriTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: scheme.onSurface, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        hintText: label,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Aggregated per-folder numbers, derived from the participants table
// so the dashboard list doesn't need extra database round-trips.
class _FolderStats {
  final double collected;
  final int participantCount;
  final int paidCount;

  const _FolderStats({
    required this.collected,
    required this.participantCount,
    required this.paidCount,
  });
}

// ==========================================
// 7. DASHBOARD SCREEN (Folders)
// ==========================================
class DashboardScreen extends StatefulWidget {
  final Isar isar;
  const DashboardScreen({super.key, required this.isar});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ContriFolder> folders = [];
  Map<int, _FolderStats> folderStats = {};
  double totalCollectedAppWide = 0;
  double totalBudgetAppWide = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedFolders = await widget.isar.contriFolders.where().findAll();
    final allParticipants = await widget.isar.participants.where().findAll();

    double budget = 0;
    for (final folder in loadedFolders) {
      budget += folder.budget;
    }

    double collected = 0;
    final Map<int, _FolderStats> stats = {};
    for (final p in allParticipants) {
      collected += p.amountPaid;
      final existing = stats[p.folderId];
      if (existing == null) {
        stats[p.folderId] = _FolderStats(
          collected: p.amountPaid,
          participantCount: 1,
          paidCount: p.isPaid ? 1 : 0,
        );
      } else {
        stats[p.folderId] = _FolderStats(
          collected: existing.collected + p.amountPaid,
          participantCount: existing.participantCount + 1,
          paidCount: existing.paidCount + (p.isPaid ? 1 : 0),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      folders = loadedFolders;
      folderStats = stats;
      totalCollectedAppWide = collected;
      totalBudgetAppWide = budget;
    });
  }

  // 🗑️ DELETE FOLDER & ITS PARTICIPANTS
  Future<void> _deleteFolder(ContriFolder folder) async {
    await widget.isar.writeTxn(() async {
      // Delete all participants inside this folder first to prevent floating data
      await widget.isar.participants.filter().folderIdEqualTo(folder.id).deleteAll();
      // Then delete the folder itself
      await widget.isar.contriFolders.delete(folder.id);
    });
    _loadData();
  }

  // ⚙️ FOLDER OPTIONS MENU (Edit / Delete)
  void _showFolderOptions(ContriFolder folder) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Manage "${folder.title}"'),
        message: const Text('What would you like to do with this plan?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showManageFolderSheet(folderToEdit: folder);
            },
            child: const Text('Edit Plan'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              // Show confirmation dialog before deleting to prevent accidental clicks
              final confirm = await showCupertinoDialog<bool>(
                context: context,
                builder: (dialogContext) => CupertinoAlertDialog(
                  title: const Text('Delete Plan?'),
                  content: Text('Are you sure you want to delete "${folder.title}"? All participants and payment records inside it will be permanently lost.'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _deleteFolder(folder);
              }
            },
            child: const Text('Delete Plan'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // 📝 ADD OR EDIT FOLDER
  void _showManageFolderSheet({ContriFolder? folderToEdit}) {
    final isEditing = folderToEdit != null;
    final titleController = TextEditingController(text: folderToEdit?.title ?? '');
    final budgetController = TextEditingController(
      text: folderToEdit != null ? folderToEdit.budget.toStringAsFixed(0) : '',
    );
    DateTime selectedDeadline = folderToEdit?.deadline ?? DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final scheme = Theme.of(sheetContext).colorScheme;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Text(
                      isEditing ? 'Edit Plan' : 'New Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _KontriTextField(
                      controller: titleController,
                      label: 'Event / Folder Name',
                      icon: CupertinoIcons.textformat,
                    ),
                    const SizedBox(height: 12),
                    _KontriTextField(
                      controller: budgetController,
                      label: 'Target Budget (₱)',
                      icon: CupertinoIcons.money_dollar_circle,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await _pickDate(sheetContext, selectedDeadline);
                        if (picked != null) {
                          setSheetState(() => selectedDeadline = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.calendar, size: 18, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Text('Deadline', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15)),
                            const Spacer(),
                            Text(
                              DateFormat('MMM d, yyyy').format(selectedDeadline),
                              style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final budgetValue = double.tryParse(budgetController.text.trim());
                          if (title.isEmpty || budgetValue == null) return;

                          final folderToSave = folderToEdit ?? ContriFolder();
                          folderToSave.title = title;
                          folderToSave.budget = budgetValue;
                          folderToSave.deadline = selectedDeadline;

                          await widget.isar.writeTxn(() async {
                            await widget.isar.contriFolders.put(folderToSave);
                          });
                          
                          // 💡 AUTO-RECALCULATE if the budget was edited!
                          if (isEditing) {
                            final folderParticipants = await widget.isar.participants
                                .filter()
                                .folderIdEqualTo(folderToSave.id)
                                .findAll();
                            
                            if (folderParticipants.isNotEmpty) {
                              final newSplitAmount = budgetValue / folderParticipants.length;
                              await widget.isar.writeTxn(() async {
                                for (final p in folderParticipants) {
                                  p.amountExpected = newSplitAmount;
                                  // Update their paid status just in case the new expected amount is lower/higher
                                  p.isPaid = p.amountPaid >= p.amountExpected;
                                  await widget.isar.participants.put(p);
                                }
                              });
                            }
                          }

                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          _loadData();
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Create Plan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => KontriApp.of(context).toggleTheme(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_stars_fill,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final pct = totalBudgetAppWide > 0
        ? (totalCollectedAppWide / totalBudgetAppWide).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A84FF), Color(0xFF30D6C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A84FF).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Collected',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  kCurrency.format(totalCollectedAppWide),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${kCurrency.format(totalBudgetAppWide)} goal',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, ContriFolder folder) {
    final scheme = Theme.of(context).colorScheme;
    final stats = folderStats[folder.id] ??
        const _FolderStats(collected: 0, participantCount: 0, paidCount: 0);
    final pct = folder.budget > 0 ? (stats.collected / folder.budget).clamp(0.0, 1.0) : 0.0;
    final daysLeft = folder.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final deadlineColor = isOverdue
        ? const Color(0xFFFF3B30)
        : daysLeft <= 3
            ? const Color(0xFFFF9500)
            : const Color(0xFF34C759);
    final accent = _colorForName(folder.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FolderDetailScreen(isar: widget.isar, folder: folder),
              ),
            ).then((_) => _loadData());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(CupertinoIcons.folder_fill, color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folder.title,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: scheme.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stats.participantCount} ${stats.participantCount == 1 ? 'person' : 'people'} · ${stats.paidCount} paid',
                            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    // ⚙️ THE NEW MENU BUTTON
                    IconButton(
                      icon: Icon(CupertinoIcons.ellipsis, color: scheme.onSurfaceVariant),
                      onPressed: () => _showFolderOptions(folder),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: scheme.onSurfaceVariant.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${kCurrency.format(stats.collected)} of ${kCurrency.format(folder.budget)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(CupertinoIcons.calendar, size: 13, color: deadlineColor),
                        const SizedBox(width: 4),
                        Text(
                          isOverdue ? 'Overdue' : '$daysLeft d left',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: deadlineColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 88,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
                  title: Text(
                    'Kontri',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                actions: [_buildThemeToggle(context, isDark)],
              ),
              SliverToBoxAdapter(child: _buildHeroCard(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Text(
                    'Active Folders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              if (folders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: CupertinoIcons.folder_fill,
                    title: 'No folders yet',
                    message: "Tap 'New Plan' below to start collecting contributions.",
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildFolderCard(context, folders[index]),
                      childCount: folders.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showManageFolderSheet(),
        icon: const Icon(CupertinoIcons.add),
        label: const Text('New Plan'),
      ),
    );
  }
}

// ==========================================
// 8. FOLDER DETAIL SCREEN (Participants)
// ==========================================
class FolderDetailScreen extends StatefulWidget {
  final Isar isar;
  final ContriFolder folder;

  const FolderDetailScreen({super.key, required this.isar, required this.folder});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  List<Participant> participants = [];
  double totalCollected = 0;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final loaded =
        await widget.isar.participants.filter().folderIdEqualTo(widget.folder.id).findAll();
    double collected = 0;
    for (final p in loaded) {
      collected += p.amountPaid;
    }
    if (!mounted) return;
    setState(() {
      participants = loaded;
      totalCollected = collected;
    });
  }

  // 💡 AUTO-SPLIT LOGIC WITH FREQUENCY
  Future<void> _addParticipant(String name, String frequency) async {
    final newParticipant = Participant()
      ..folderId = widget.folder.id
      ..name = name
      ..amountExpected = 0
      ..amountPaid = 0
      ..isPaid = false
      ..createdAt = DateTime.now() // Record exactly when they joined
      ..frequency = frequency;

    final updated = [...participants, newParticipant];
    final splitAmount = widget.folder.budget / updated.length;

    await widget.isar.writeTxn(() async {
      for (final p in updated) {
        p.amountExpected = splitAmount;
        await widget.isar.participants.put(p);
      }
    });

    _loadParticipants();
  }

  // ✏️ EDIT PARTICIPANT LOGIC
  Future<void> _updateParticipantDetails(Participant p, String newName, String newFrequency) async {
    await widget.isar.writeTxn(() async {
      p.name = newName;
      p.frequency = newFrequency;
      await widget.isar.participants.put(p);
    });
    _loadParticipants();
  }

  Future<void> _deleteParticipant(Participant participant) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.participants.delete(participant.id);
    });

    final remaining = participants.where((p) => p.id != participant.id).toList();
    if (remaining.isNotEmpty) {
      final splitAmount = widget.folder.budget / remaining.length;
      await widget.isar.writeTxn(() async {
        for (final p in remaining) {
          p.amountExpected = splitAmount;
          await widget.isar.participants.put(p);
        }
      });
    }

    _loadParticipants();
  }

  Future<void> _resetPayment(Participant p) async {
    await widget.isar.writeTxn(() async {
      p.isPaid = false;
      p.amountPaid = 0;
      p.datePaid = null;
      p.paymentHistory = [];
      await widget.isar.participants.put(p);
    });
    _loadParticipants();
  }

  Future<void> _recordPartialPayment(Participant p, double amountAdded) async {
    final now = DateTime.now();
    final logEntry = '${DateFormat('MMM d, yyyy (h:mm a)').format(now)}: +₱${amountAdded.toStringAsFixed(0)}';

    await widget.isar.writeTxn(() async {
      p.amountPaid += amountAdded;
      p.isPaid = p.amountPaid >= p.amountExpected;
      p.datePaid = now; 
      p.paymentHistory = List.from(p.paymentHistory)..add(logEntry); 
      await widget.isar.participants.put(p);
    });

    try {
      final calendarPlugin = DeviceCalendarPlugin();
      var permissionsGranted = await calendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
        permissionsGranted = await calendarPlugin.requestPermissions();
      }

      if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
        final calendarsResult = await calendarPlugin.retrieveCalendars();
        final calendars = calendarsResult.data;

        if (calendars != null && calendars.isNotEmpty) {
          final writableCalendars = calendars.where((c) => c.isReadOnly == false).toList();
          if (writableCalendars.isNotEmpty) {
            final calendar = writableCalendars.first;
            final eventTime = tz.TZDateTime.now(tz.local);

            final event = Event(
              calendar.id,
              title: '✅ Kontri: ${p.name} paid ₱$amountAdded',
              description: 'Partial payment of ₱$amountAdded for ${widget.folder.title}. Total paid so far: ₱${p.amountPaid}',
              start: eventTime,
              end: eventTime.add(const Duration(hours: 1)),
            );
            await calendarPlugin.createOrUpdateEvent(event);
          }
        }
      }
    } catch (e) {}

    _loadParticipants();
  }

  // 🚨 MISSED PAYMENT CALCULATOR
  int _calculateMissedPayments(Participant p) {
    if (p.frequency == 'One-time' || p.isPaid) return 0;
    
    final now = DateTime.now();
    int periodsPassed = 0;

    if (p.frequency == 'Daily') {
      periodsPassed = now.difference(p.createdAt).inDays;
    } else if (p.frequency == 'Weekly') {
      periodsPassed = now.difference(p.createdAt).inDays ~/ 7;
    } else if (p.frequency == 'Monthly') {
      periodsPassed = (now.year - p.createdAt.year) * 12 + now.month - p.createdAt.month;
    }

    // If the periods passed is greater than the number of times they paid, they missed a payment!
    final missed = periodsPassed - p.paymentHistory.length;
    return missed > 0 ? missed : 0;
  }

  void _showPaymentSheet(Participant p) {
    final amountController = TextEditingController();
    final remaining = (p.amountExpected - p.amountPaid).clamp(0.0, double.infinity);
    if (remaining > 0) amountController.text = remaining.toStringAsFixed(0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: scheme.onSurfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(3)))),
                Text('Record Payment for ${p.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(height: 4),
                Text('Remaining Balance: ${kCurrency.format(remaining)}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
                const SizedBox(height: 20),
                _KontriTextField(controller: amountController, label: 'Amount (₱)', icon: CupertinoIcons.money_dollar, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                    onPressed: () {
                      final amount = double.tryParse(amountController.text.trim());
                      if (amount != null && amount > 0) {
                        _recordPartialPayment(p, amount);
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: const Text('Confirm Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                if (p.paymentHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Divider(color: scheme.onSurfaceVariant.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('Contribution History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: p.paymentHistory.reversed.map((log) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(CupertinoIcons.check_mark_circled_solid, size: 14, color: scheme.primary), const SizedBox(width: 8), Text(log, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant))]))).toList(),
                      ),
                    ),
                  ),
                ],
                if (p.amountPaid > 0) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: () { _resetPayment(p); Navigator.pop(sheetContext); }, child: const Text('Reset Payment to ₱0', style: TextStyle(color: Color(0xFFFF3B30)))),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  // 📝 BOTTOM SHEET FOR ADDING OR EDITING
  void _showManageParticipantSheet({Participant? participantToEdit}) {
    final nameController = TextEditingController(text: participantToEdit?.name ?? '');
    String selectedFreq = participantToEdit?.frequency ?? 'Weekly';
    final isEditing = participantToEdit != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final scheme = Theme.of(sheetContext).colorScheme;
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: scheme.onSurfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(3)))),
                    Text(isEditing ? 'Edit Participant' : 'Add Participant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                    const SizedBox(height: 20),
                    _KontriTextField(controller: nameController, label: 'Full Name', icon: CupertinoIcons.person),
                    const SizedBox(height: 20),
                    Text('Ambagan Frequency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: selectedFreq,
                        backgroundColor: scheme.surfaceContainerHighest,
                        thumbColor: scheme.surface,
                        children: const {
                          'One-time': Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('1-Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          'Daily': Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Daily', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          'Weekly': Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Weekly', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          'Monthly': Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Monthly', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                        },
                        onValueChanged: (value) {
                          if (value != null) setSheetState(() => selectedFreq = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;
                          
                          if (isEditing) {
                            _updateParticipantDetails(participantToEdit, name, selectedFreq);
                          } else {
                            _addParticipant(name, selectedFreq);
                          }
                          Navigator.pop(sheetContext);
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Add & Auto-Split', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final pct = widget.folder.budget > 0 ? (totalCollected / widget.folder.budget).clamp(0.0, 1.0) : 0.0;
    final daysLeft = widget.folder.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0A84FF), Color(0xFF30D6C8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: const Color(0xFF0A84FF).withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Collected', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(kCurrency.format(totalCollected), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Goal', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(kCurrency.format(widget.folder.budget), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))]),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: Colors.white.withOpacity(0.25), valueColor: const AlwaysStoppedAnimation(Colors.white))),
          const SizedBox(height: 14),
          Row(children: [Icon(CupertinoIcons.calendar, size: 14, color: Colors.white.withOpacity(0.85)), const SizedBox(width: 6), Text(isOverdue ? 'Deadline passed' : 'Due ${DateFormat('MMM d, yyyy').format(widget.folder.deadline)} · $daysLeft d left', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w600))]),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(BuildContext context, Participant p) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _colorForName(p.name);
    final isFullyPaid = p.amountPaid >= p.amountExpected;
    final progress = p.amountExpected > 0 ? (p.amountPaid / p.amountExpected).clamp(0.0, 1.0) : 0.0;
    
    // Check if they are behind on payments
    final missedPaymentsCount = _calculateMissedPayments(p);
    final isBehind = missedPaymentsCount > 0;

    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.only(right: 24), decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(18)), child: const Icon(CupertinoIcons.delete, color: Colors.white)),
      confirmDismiss: (direction) async {
        final result = await showCupertinoDialog<bool>(context: context, builder: (dialogContext) => CupertinoAlertDialog(title: const Text('Remove Participant'), content: Text('Remove ${p.name} from this plan?'), actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remove'))]));
        return result ?? false;
      },
      onDismissed: (direction) => _deleteParticipant(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: scheme.surface, 
          borderRadius: BorderRadius.circular(18),
          border: isBehind ? Border.all(color: const Color(0xFFFF3B30).withOpacity(0.5), width: 1.5) : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: isFullyPaid ? null : () => _showPaymentSheet(p),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: accent.withOpacity(0.2), child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?', style: TextStyle(color: accent, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: scheme.onSurface, decoration: isFullyPaid ? TextDecoration.lineThrough : null, decorationColor: scheme.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            // EDIT BUTTON
                            GestureDetector(
                              onTap: () => _showManageParticipantSheet(participantToEdit: p),
                              child: Icon(CupertinoIcons.pencil_circle_fill, size: 18, color: scheme.onSurfaceVariant.withOpacity(0.6)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: scheme.onSurfaceVariant.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(isFullyPaid ? const Color(0xFF34C759) : scheme.primary))),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Paid: ${kCurrency.format(p.amountPaid)} / ${kCurrency.format(p.amountExpected)}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                              child: Text(p.frequency, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                            ),
                          ],
                        ),
                        if (isBehind) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 12, color: Color(0xFFFF3B30)),
                              const SizedBox(width: 4),
                              Text('Missed $missedPaymentsCount ${p.frequency.toLowerCase()} payment(s)', style: const TextStyle(fontSize: 11, color: Color(0xFFFF3B30), fontWeight: FontWeight.w600)),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isFullyPaid)
                    const Padding(padding: EdgeInsets.only(right: 4), child: Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Color(0xFF34C759), size: 28))
                  else
                    SizedBox(height: 32, width: 64, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: scheme.primary.withOpacity(0.15), foregroundColor: scheme.primary, elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => _showPaymentSheet(p), child: const Text('Pay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadParticipants,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(pinned: true, backgroundColor: Theme.of(context).scaffoldBackgroundColor, surfaceTintColor: Colors.transparent, elevation: 0, leading: IconButton(icon: Icon(CupertinoIcons.back, color: scheme.onSurface), onPressed: () => Navigator.pop(context)), title: Text(widget.folder.title, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface))),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(child: _buildHeroCard(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Participants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      if (participants.isNotEmpty) Text('${kCurrency.format(participants.first.amountExpected)} / head', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              if (participants.isEmpty)
                const SliverFillRemaining(hasScrollBody: false, child: _EmptyState(icon: CupertinoIcons.group, title: 'No participants yet', message: 'Tap the + button below to add people and auto-split the budget.'))
              else
                SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 110), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildParticipantTile(context, participants[index]), childCount: participants.length))),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showManageParticipantSheet(),
        child: const Icon(CupertinoIcons.person_add_solid),
      ),
    );
  }
}