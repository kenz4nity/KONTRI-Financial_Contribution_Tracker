import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/contribution_repository.dart';
import '../models/contri_folder.dart';
import '../theme/app_theme.dart';
import '../widgets/kontri_widgets.dart';
import '../widgets/pace_widgets.dart';
import 'folder_detail_screen.dart';

/// Root screen: every contribution plan, with app-wide totals.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.onToggleTheme,
  });

  final ContributionRepository repository;
  final VoidCallback onToggleTheme;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData _data = DashboardData.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.repository.loadDashboard();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _openPlanSheet({ContriFolder? folderToEdit}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanSheet(
        repository: widget.repository,
        folderToEdit: folderToEdit,
      ),
    );
    if (saved == true) await _load();
  }

  void _showFolderOptions(ContriFolder folder) {
    showCupertinoModalPopup(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: Text('Manage "${folder.title}"'),
        message: const Text('What would you like to do with this plan?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(popupContext);
              _openPlanSheet(folderToEdit: folder);
            },
            child: const Text('Edit Plan'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(popupContext);
              await _confirmDelete(folder);
            },
            child: const Text('Delete Plan'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(popupContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ContriFolder folder) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete Plan?'),
        content: Text('Are you sure you want to delete "${folder.title}"? '
            'All participants, payment records and proof images inside it '
            'will be permanently lost.'),
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
    if (confirmed != true) return;
    await widget.repository.deleteFolder(folder);
    await _load();
  }

  Future<void> _openFolder(ContriFolder folder) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderDetailScreen(
          repository: widget.repository,
          folder: folder,
        ),
      ),
    );
    await _load();
  }

  // ------------------------------------------------------------------- UI

  Widget _buildHeroCard() {
    final pct = _data.totalBudget > 0
        ? (_data.totalCollected / _data.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return GradientHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Collected',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(kCurrency.format(_data.totalCollected),
                        style: KontriText.heroAmount
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('of ${kCurrency.format(_data.totalBudget)} goal',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          // Arrears only appear when there are any, so a healthy dashboard
          // stays calm.
          if (_data.totalArrears > 0.005) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(KontriRadius.chip),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.exclamationmark_triangle_fill,
                      size: 13, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${kCurrency.format(_data.totalArrears)} behind across all plans',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderCard(ContriFolder folder) {
    final scheme = Theme.of(context).colorScheme;
    final stats = _data.summaries[folder.id] ?? FolderSummary.empty;
    final pct = folder.budget > 0
        ? (stats.collected / folder.budget).clamp(0.0, 1.0)
        : 0.0;
    final daysLeft = folder.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final deadlineColor = isOverdue
        ? KontriColors.danger
        : daysLeft <= 3
            ? KontriColors.warning
            : KontriColors.green;
    final accent = colorForName(folder.title);
    final isBehind = stats.arrears > 0.005;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(KontriRadius.card),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KontriRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(KontriRadius.card),
          onTap: () => _openFolder(folder),
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
                        color: accent.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(KontriRadius.field),
                      ),
                      child: Icon(CupertinoIcons.folder_fill,
                          color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(folder.title,
                              style: KontriText.cardTitle
                                  .copyWith(color: scheme.onSurface)),
                          const SizedBox(height: 2),
                          Text(
                            '${stats.participantCount} '
                            '${stats.participantCount == 1 ? 'person' : 'people'}'
                            ' · ${stats.paidCount} paid',
                            style: KontriText.caption
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.ellipsis,
                          color: scheme.onSurfaceVariant),
                      onPressed: () => _showFolderOptions(folder),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(KontriRadius.bar),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor:
                        scheme.onSurfaceVariant.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${kCurrency.format(stats.collected)} of '
                        '${kCurrency.format(folder.budget)}',
                        style: KontriText.captionStrong
                            .copyWith(color: scheme.onSurface),
                      ),
                    ),
                    Icon(CupertinoIcons.calendar,
                        size: 13, color: deadlineColor),
                    const SizedBox(width: 4),
                    Text(
                      isOverdue ? 'Overdue' : '$daysLeft d left',
                      style: KontriText.micro.copyWith(color: deadlineColor),
                    ),
                  ],
                ),
                if (isBehind) ...[
                  const SizedBox(height: 10),
                  StatPill(
                    icon: CupertinoIcons.exclamationmark_triangle_fill,
                    label: '${formatCompact(stats.arrears)} behind',
                    background: KontriColors.behind.withValues(alpha: 0.14),
                    foreground: KontriColors.behind,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 88,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                      start: KontriSpace.gutter, bottom: 16),
                  title: Text('Kontri',
                      style: KontriText.screenTitle
                          .copyWith(color: scheme.onSurface)),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: widget.onToggleTheme,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: scheme.surface, shape: BoxShape.circle),
                        child: Icon(
                          isDark
                              ? CupertinoIcons.sun_max_fill
                              : CupertinoIcons.moon_stars_fill,
                          color: scheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _buildHeroCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      KontriSpace.gutter, 28, KontriSpace.gutter, 12),
                  child: Text('Active Folders',
                      style: KontriText.sectionTitle
                          .copyWith(color: scheme.onSurface)),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (_data.folders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: CupertinoIcons.folder_fill,
                    title: 'No folders yet',
                    message:
                        "Tap 'New Plan' below to start collecting contributions.",
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(KontriSpace.gutter, 0,
                      KontriSpace.gutter, KontriSpace.fabClearance),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildFolderCard(_data.folders[index]),
                      childCount: _data.folders.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPlanSheet,
        icon: const Icon(CupertinoIcons.add),
        label: const Text('New Plan'),
      ),
    );
  }
}

/// Create/edit plan sheet, with the live contribution-pace preview.
class _PlanSheet extends StatefulWidget {
  const _PlanSheet({required this.repository, this.folderToEdit});

  final ContributionRepository repository;
  final ContriFolder? folderToEdit;

  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<_PlanSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _deadline;
  bool _saving = false;

  bool get _isEditing => widget.folderToEdit != null;

  @override
  void initState() {
    super.initState();
    final folder = widget.folderToEdit;
    _titleController = TextEditingController(text: folder?.title ?? '');
    _budgetController = TextEditingController(
      text: folder != null ? folder.budget.toStringAsFixed(0) : '',
    );
    _startDate = folder?.effectiveStart ?? DateTime.now();
    _deadline = folder?.deadline ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    // v1.0 leaked a controller per sheet presentation.
    _titleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  double get _budget =>
      double.tryParse(_budgetController.text.trim().replaceAll(',', '')) ?? 0;

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty && _budget > 0 && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    await widget.repository.saveFolder(
      existing: widget.folderToEdit,
      title: _titleController.text.trim(),
      budget: _budget,
      startDate: _startDate,
      deadline: _deadline,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return KontriSheet(
      title: _isEditing ? 'Edit Plan' : 'New Plan',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KontriTextField(
              controller: _titleController,
              label: 'Event / Folder Name',
              icon: CupertinoIcons.textformat,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            KontriTextField(
              controller: _budgetController,
              label: 'Target Budget (₱)',
              icon: CupertinoIcons.money_dollar_circle,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            KontriDateField(
              label: 'Starts',
              value: _startDate,
              icon: CupertinoIcons.play_circle,
              // No minimum: a plan already under way legitimately started in
              // the past, and v1.0's fixed floor made that impossible to pick.
              maximumDate: _deadline,
              onChanged: (picked) => setState(() {
                _startDate = picked;
                if (!_startDate.isBefore(_deadline)) {
                  _deadline = _startDate.add(const Duration(days: 30));
                }
              }),
            ),
            const SizedBox(height: 12),
            KontriDateField(
              label: 'Deadline',
              value: _deadline,
              minimumDate: _startDate,
              onChanged: (picked) => setState(() => _deadline = picked),
            ),
            const SizedBox(height: 16),
            PacePreviewCard(
              budget: _budget,
              start: _startDate,
              end: _deadline,
            ),
            const SizedBox(height: 20),
            KontriPrimaryButton(
              label: _isEditing ? 'Save Changes' : 'Create Plan',
              onPressed: _canSave ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
