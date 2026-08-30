import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/contribution_repository.dart';
import '../logic/schedule.dart';
import '../models/contri_folder.dart';
import '../models/payment_record.dart';
import '../theme/app_theme.dart';
import '../widgets/kontri_widgets.dart';
import '../widgets/pace_widgets.dart';
import '../widgets/proof_widgets.dart';
import 'pdf_preview_screen.dart';

/// Which participants the list is showing.
enum _Filter { all, behind, paid }

class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({
    super.key,
    required this.repository,
    required this.folder,
  });

  final ContributionRepository repository;
  final ContriFolder folder;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  FolderDetail? _detail;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await widget.repository.loadFolder(widget.folder);
    if (!mounted) return;
    setState(() => _detail = detail);
  }

  List<ParticipantView> get _visible {
    final all = _detail?.participants ?? const <ParticipantView>[];
    switch (_filter) {
      case _Filter.all:
        return all;
      case _Filter.behind:
        return all.where((p) => p.isBehind).toList();
      case _Filter.paid:
        return all.where((p) => p.isFullyPaid).toList();
    }
  }

  Future<void> _openParticipantSheet({ParticipantView? toEdit}) async {
    final detail = _detail;
    if (detail == null) return;

    // A new participant dilutes everyone's share, so preview against the
    // count that will exist once they are added.
    final share = toEdit != null
        ? toEdit.participant.amountExpected
        : ContributionRepository.splitAmount(
            detail.folder.budget,
            detail.participants.length + 1,
          );

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ParticipantSheet(
        repository: widget.repository,
        folder: detail.folder,
        toEdit: toEdit,
        previewShare: share,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _openPaymentSheet(ParticipantView view) async {
    final detail = _detail;
    if (detail == null) return;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
        repository: widget.repository,
        folder: detail.folder,
        view: view,
      ),
    );
    // Always reload: deleting a ledger entry changes the totals even when the
    // sheet is dismissed without confirming a new payment.
    await _load();
  }

  Future<void> _deleteParticipant(ParticipantView view) async {
    final detail = _detail;
    if (detail == null) return;
    await widget.repository.deleteParticipant(detail.folder, view.participant);
    await _load();
  }

  Future<void> _openExportSheet() async {
    final detail = _detail;
    if (detail == null) return;
    final includeProofs = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(detail: detail),
    );
    if (includeProofs == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfPreviewScreen(detail: detail, includeProofs: includeProofs),
      ),
    );
  }

  // ------------------------------------------------------------------- UI

  Widget _buildHeroCard(FolderDetail detail) {
    final folder = detail.folder;
    final pct = folder.budget > 0
        ? (detail.collected / folder.budget).clamp(0.0, 1.0)
        : 0.0;
    final daysLeft = folder.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;

    return GradientHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collected',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kCurrency.format(detail.collected),
                      style: KontriText.heroAmountSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Goal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kCurrency.format(folder.budget),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(KontriRadius.bar),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isOverdue
                      ? 'Deadline passed'
                      : '${DateFormat('MMM d').format(folder.effectiveStart)} – '
                            '${DateFormat('MMM d, yyyy').format(folder.deadline)}'
                            ' · $daysLeft d left',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (detail.arrears > 0.005) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(KontriRadius.chip),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${kCurrency.format(detail.arrears)} behind'
                      ' · ${detail.behindCount} '
                      '${detail.behindCount == 1 ? 'person' : 'people'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildFilterBar(FolderDetail detail) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KontriSpace.gutter,
        0,
        KontriSpace.gutter,
        12,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<_Filter>(
          groupValue: _filter,
          backgroundColor: scheme.surfaceContainerHighest,
          thumbColor: scheme.surface,
          children: {
            _Filter.all: _segment('All', detail.participants.length),
            _Filter.behind: _segment('Behind', detail.behindCount),
            _Filter.paid: _segment('Paid', detail.paidCount),
          },
          onValueChanged: (value) {
            if (value != null) setState(() => _filter = value);
          },
        ),
      ),
    );
  }

  Widget _segment(String label, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Text(
      '$label ($count)',
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  Widget _buildParticipantTile(ParticipantView view) {
    final scheme = Theme.of(context).colorScheme;
    final p = view.participant;
    final accent = colorForName(p.name);

    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: KontriColors.danger,
          borderRadius: BorderRadius.circular(KontriRadius.tile),
        ),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final result = await showCupertinoDialog<bool>(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Remove Participant'),
            content: Text(
              'Remove ${p.name} from this plan? '
              'Their payment records and proof images will be deleted.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onDismissed: (_) => _deleteParticipant(view),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(KontriRadius.tile),
          border: view.isBehind
              ? Border.all(
                  color: KontriColors.behind.withValues(alpha: 0.55),
                  width: 1.5,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(KontriRadius.tile),
          child: InkWell(
            borderRadius: BorderRadius.circular(KontriRadius.tile),
            onTap: () => _openPaymentSheet(view),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: accent.withValues(alpha: 0.2),
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KontriText.bodyStrong.copyWith(
                                  color: scheme.onSurface,
                                  decoration: view.isFullyPaid
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _openParticipantSheet(toEdit: view),
                              child: Icon(
                                CupertinoIcons.pencil_circle_fill,
                                size: 18,
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            if (view.proofCount > 0) ...[
                              const SizedBox(width: 8),
                              Icon(
                                CupertinoIcons.paperclip,
                                size: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${view.proofCount}',
                                style: KontriText.pill.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: view.progress,
                            minHeight: 4,
                            backgroundColor: scheme.onSurfaceVariant.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              view.isFullyPaid
                                  ? KontriColors.green
                                  : scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Paid: ${kCurrency.format(p.amountPaid)} / '
                                '${kCurrency.format(p.amountExpected)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KontriText.micro.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // The frequency badge now carries the number that
                            // makes the frequency meaningful.
                            StatPill(
                              label: view.cadence == Cadence.oneTime
                                  ? 'One-time'
                                  : '${formatCompact(view.perPeriodAmount)}'
                                        ' / ${view.cadence.shortUnit}',
                            ),
                          ],
                        ),
                        if (view.isBehind) ...[
                          const SizedBox(height: 6),
                          ArrearsBadge(
                            arrears: view.arrears,
                            missedPeriods: view.missedPeriods,
                            cadence: view.cadence,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (view.isFullyPaid)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        CupertinoIcons.checkmark_alt_circle_fill,
                        color: KontriColors.green,
                        size: 28,
                      ),
                    )
                  else
                    SizedBox(
                      height: 32,
                      width: 64,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          foregroundColor: scheme.primary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              KontriRadius.chip,
                            ),
                          ),
                        ),
                        onPressed: () => _openPaymentSheet(view),
                        child: const Text(
                          'Pay',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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
    final detail = _detail;
    final visible = _visible;

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
                leading: IconButton(
                  icon: Icon(CupertinoIcons.back, color: scheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.folder.title,
                  style: KontriText.cardTitle.copyWith(color: scheme.onSurface),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Export PDF report',
                    icon: Icon(
                      CupertinoIcons.square_arrow_up,
                      color: scheme.primary,
                    ),
                    onPressed: detail == null ? null : _openExportSheet,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (detail == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else ...[
                SliverToBoxAdapter(child: _buildHeroCard(detail)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KontriSpace.gutter,
                      28,
                      KontriSpace.gutter,
                      12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Participants',
                          style: KontriText.sectionTitle.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        if (detail.participants.isNotEmpty)
                          Text(
                            '${kCurrency.format(detail.participants.first.participant.amountExpected)} / head',
                            style: KontriText.captionStrong.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (detail.participants.isNotEmpty)
                  SliverToBoxAdapter(child: _buildFilterBar(detail)),
                if (detail.participants.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: CupertinoIcons.group,
                      title: 'No participants yet',
                      message:
                          'Tap the + button below to add people and auto-split the budget.',
                    ),
                  )
                else if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState(
                        icon: _filter == _Filter.behind
                            ? CupertinoIcons.checkmark_seal
                            : CupertinoIcons.person_2,
                        title: _filter == _Filter.behind
                            ? 'Nobody is behind'
                            : 'Nobody has fully paid yet',
                        message: _filter == _Filter.behind
                            ? 'Everyone is on track with their contributions.'
                            : 'Record a payment to see people here.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      KontriSpace.gutter,
                      0,
                      KontriSpace.gutter,
                      KontriSpace.fabClearance,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildParticipantTile(visible[index]),
                        childCount: visible.length,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openParticipantSheet(),
        child: const Icon(CupertinoIcons.person_add_solid),
      ),
    );
  }
}

// ---------------------------------------------------------------- sheets

/// Add/edit participant, with the live per-person pace panel.
class _ParticipantSheet extends StatefulWidget {
  const _ParticipantSheet({
    required this.repository,
    required this.folder,
    required this.previewShare,
    this.toEdit,
  });

  final ContributionRepository repository;
  final ContriFolder folder;
  final double previewShare;
  final ParticipantView? toEdit;

  @override
  State<_ParticipantSheet> createState() => _ParticipantSheetState();
}

class _ParticipantSheetState extends State<_ParticipantSheet> {
  late final TextEditingController _nameController;
  late Cadence _cadence;
  bool _saving = false;

  bool get _isEditing => widget.toEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.toEdit?.participant.name ?? '',
    );
    _cadence = widget.toEdit?.cadence ?? Cadence.weekly;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);

    final toEdit = widget.toEdit;
    if (toEdit != null) {
      await widget.repository.updateParticipant(
        toEdit.participant,
        name,
        _cadence,
      );
    } else {
      await widget.repository.addParticipant(widget.folder, name, _cadence);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return KontriSheet(
      title: _isEditing ? 'Edit Participant' : 'Add Participant',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KontriTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: CupertinoIcons.person,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Ambagan Frequency',
              style: KontriText.label.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<Cadence>(
                groupValue: _cadence,
                backgroundColor: scheme.surfaceContainerHighest,
                thumbColor: scheme.surface,
                children: {
                  for (final cadence in Cadence.values)
                    cadence: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        cadence.pickerLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                },
                onValueChanged: (value) {
                  if (value != null) setState(() => _cadence = value);
                },
              ),
            ),
            const SizedBox(height: 12),
            // The answer to "what does Weekly actually cost me?".
            ParticipantPacePanel(
              share: widget.previewShare,
              cadence: _cadence,
              start: widget.folder.effectiveStart,
              end: widget.folder.deadline,
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 8),
              Text(
                'Adding a participant re-splits the budget evenly across '
                'everyone in the plan.',
                style: KontriText.micro.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 20),
            KontriPrimaryButton(
              label: _isEditing ? 'Save Changes' : 'Add & Auto-Split',
              onPressed: _nameController.text.trim().isEmpty || _saving
                  ? null
                  : _save,
            ),
          ],
        ),
      ),
    );
  }
}

/// Record a payment, attach proof, and review the ledger.
class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({
    required this.repository,
    required this.folder,
    required this.view,
  });

  final ContributionRepository repository;
  final ContriFolder folder;
  final ParticipantView view;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _amountController = TextEditingController();
  late List<PaymentRecord> _payments;
  String? _proofFileName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _payments = List.of(widget.view.payments);
    final suggestion = widget.view.arrears > 0.005
        ? widget.view.arrears
        : widget.view.perPeriodAmount;
    if (suggestion > 0 && widget.view.remaining > 0) {
      _amountController.text = suggestion
          .clamp(0, widget.view.remaining)
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;

  Future<void> _confirm() async {
    if (_amount <= 0 || _saving) return;
    setState(() => _saving = true);
    await widget.repository.recordPayment(
      folder: widget.folder,
      p: widget.view.participant,
      amount: _amount,
      proofFileName: _proofFileName,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _attachProof() async {
    final fileName = await pickProof(context);
    if (fileName == null || !mounted) return;
    setState(() => _proofFileName = fileName);
  }

  Future<void> _deleteEntry(PaymentRecord record) async {
    await widget.repository.deletePayment(widget.view.participant, record);
    if (!mounted) return;
    setState(() {
      _payments = _payments.where((p) => p.id != record.id).toList();
    });
  }

  Future<void> _reset() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Reset payments?'),
        content: Text(
          'This clears every payment recorded for ${widget.view.participant.name}, '
          'including attached proof images.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.repository.resetPayment(widget.view.participant);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  /// One-tap amounts, so the common cases need no typing at all.
  Widget _quickFills() {
    final view = widget.view;
    final options = <({String label, double amount})>[
      if (view.cadence != Cadence.oneTime &&
          view.perPeriodAmount > 0 &&
          view.perPeriodAmount < view.remaining)
        (label: '1 ${view.cadence.unit}', amount: view.perPeriodAmount),
      if (view.arrears > 0.005 && view.arrears < view.remaining)
        (label: 'Catch up', amount: view.arrears),
      if (view.remaining > 0) (label: 'Full balance', amount: view.remaining),
    ];
    if (options.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ActionChip(
            backgroundColor: scheme.surfaceContainerHighest,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KontriRadius.chip),
            ),
            label: Text(
              '${option.label} · ${formatCompact(option.amount)}',
              style: KontriText.micro.copyWith(color: scheme.onSurface),
            ),
            onPressed: () => setState(() {
              _amountController.text = option.amount.toStringAsFixed(2);
            }),
          ),
      ],
    );
  }

  Widget _ledgerRow(PaymentRecord record) {
    final scheme = Theme.of(context).colorScheme;
    final hasProof = (record.proofFileName ?? '').isNotEmpty;

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: KontriColors.danger,
          borderRadius: BorderRadius.circular(KontriRadius.chip),
        ),
        child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 18),
      ),
      confirmDismiss: (_) async {
        final result = await showCupertinoDialog<bool>(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Delete entry?'),
            content: Text(
              '${kCurrency.format(record.amount)} will be removed from '
              "this participant's total.",
            ),
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
        return result ?? false;
      },
      onDismissed: (_) => _deleteEntry(record),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KontriRadius.chip),
          child: InkWell(
            borderRadius: BorderRadius.circular(KontriRadius.chip),
            onTap: hasProof
                ? () => openProof(
                    context,
                    fileName: record.proofFileName!,
                    title: widget.view.participant.name,
                    subtitle:
                        '${kCurrency.format(record.amount)} · ${DateFormat('MMM d, yyyy').format(record.paidAt)}',
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  if (hasProof)
                    Hero(
                      tag: 'proof-${record.proofFileName}',
                      child: ProofThumbnail(
                        fileName: record.proofFileName,
                        size: 36,
                      ),
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(KontriRadius.bar),
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark_alt,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kCurrency.format(record.amount),
                          style: KontriText.captionStrong.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat(
                            'MMM d, yyyy · h:mm a',
                          ).format(record.paidAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasProof)
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
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
    final view = widget.view;

    return KontriSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Record Payment for ${view.participant.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Remaining ${kCurrency.format(view.remaining)}'
                    '${view.cadence == Cadence.oneTime ? '' : ' · ${formatCompact(view.perPeriodAmount)} per ${view.cadence.unit}'}',
                    style: KontriText.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (view.isBehind) ...[
              const SizedBox(height: 10),
              ArrearsBadge(
                arrears: view.arrears,
                missedPeriods: view.missedPeriods,
                cadence: view.cadence,
              ),
            ],
            const SizedBox(height: 18),
            KontriTextField(
              controller: _amountController,
              label: 'Amount (₱)',
              icon: CupertinoIcons.money_dollar,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            _quickFills(),
            const SizedBox(height: 14),
            ProofAttachmentField(
              fileName: _proofFileName,
              onPick: _attachProof,
              onClear: () => setState(() => _proofFileName = null),
            ),
            const SizedBox(height: 18),
            KontriPrimaryButton(
              label: 'Confirm Payment',
              icon: CupertinoIcons.checkmark_alt,
              onPressed: _amount > 0 && !_saving ? _confirm : null,
            ),
            if (_payments.isNotEmpty) ...[
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    'Contribution history',
                    style: KontriText.label.copyWith(color: scheme.onSurface),
                  ),
                  const Spacer(),
                  Text(
                    'Swipe to delete',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final record in _payments) _ledgerRow(record),
                    ],
                  ),
                ),
              ),
            ],
            if (view.participant.amountPaid > 0) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: _reset,
                child: const Text(
                  'Reset all payments',
                  style: TextStyle(color: KontriColors.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Export options, shown before the PDF preview.
class _ExportSheet extends StatefulWidget {
  const _ExportSheet({required this.detail});

  final FolderDetail detail;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _includeProofs = false;

  int get _proofCount => widget.detail.participants.fold<int>(
    0,
    (sum, view) => sum + view.proofCount,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasProofs = _proofCount > 0;

    return KontriSheet(
      title: 'Export summary report',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(KontriRadius.field),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KontriRadius.chip),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text_fill,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.detail.folder.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KontriText.bodyStrong.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.detail.participants.length} participants · '
                        '$_proofCount ${_proofCount == 1 ? 'proof' : 'proofs'}',
                        style: KontriText.micro.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: hasProofs ? 1 : 0.5,
            child: SwitchListTile.adaptive(
              value: _includeProofs && hasProofs,
              onChanged: hasProofs
                  ? (value) => setState(() => _includeProofs = value)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                'Include proof images',
                style: KontriText.bodyStrong.copyWith(color: scheme.onSurface),
              ),
              subtitle: Text(
                hasProofs
                    ? 'Appends every attached receipt. Makes the file much larger.'
                    : 'No proof images have been attached yet.',
                style: KontriText.micro.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          KontriPrimaryButton(
            label: 'Preview & Share',
            icon: CupertinoIcons.eye,
            onPressed: () =>
                Navigator.pop(context, _includeProofs && hasProofs),
          ),
        ],
      ),
    );
  }
}
