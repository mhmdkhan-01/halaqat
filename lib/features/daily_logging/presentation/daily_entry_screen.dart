import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class DailyEntryScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String initialSession;

  const DailyEntryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.initialSession,
  });

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isAlreadySubmitted = false;

  final Map<int, List<String>> quranParaSurahMap = {
    1: ["الفاتحة", "البقرة"],
    2: ["البقرة"],
    3: ["البقرة", "آل عمران"],
    4: ["آل عمران", "النساء"],
    5: ["النساء"],
    6: ["النساء", "المائدة"],
    7: ["المائدة", "الأنعام"],
    8: ["الأنعام", "الأعراف"],
    9: ["الأعراف", "الأنفال"],
    10: ["الأنفال", "التوبة"],
    11: ["التوبة", "يونس", "هود"],
    12: ["هود", "يوسف"],
    13: ["يوسف", "الرعد", "إبراهيم"],
    14: ["الحجر", "النحل"],
    15: ["الإسراء", "الكهف"],
    16: ["الكهف", "طه", "الأنبياء"],
    17: ["الأنبياء", "الحج"],
    18: ["المؤمنون", "النور", "الفرقان"],
    19: ["الفرقان", "الشعراء", "النمل"],
    20: ["النمل", "القصص", "العنكبوت"],
    21: ["العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب"],
    22: ["الأحزاب", "سبأ", "فاطر", "يس"],
    23: ["يس", "الصافات", "ص", "الزمر"],
    24: ["الزمر", "غافر", "فصلت"],
    25: ["فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية"],
    26: ["الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات"],
    27: ["الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد"],
    28: [
      "المجادلة",
      "الحشر",
      "الممتحنة",
      "الصف",
      "الجمعة",
      "المنافقون",
      "التغابن",
      "الطلاق",
      "التحريم",
    ],
    29: [
      "الملك",
      "القلم",
      "الحاقة",
      "المعارج",
      "نوح",
      "الجن",
      "المزمل",
      "المدثر",
      "القيامة",
      "الإنسان",
      "المرسلات",
    ],
    30: [
      "النبأ",
      "النازعات",
      "عبس",
      "التكوير",
      "الانفطار",
      "المطففين",
      "الانشقاق",
      "البروج",
      "الطارق",
      "الأعلى",
      "الغاشية",
      "الفجر",
      "البلد",
      "الشمس",
      "الليل",
      "الضحى",
      "الشرح",
      "التين",
      "العلق",
      "القدر",
      "البينة",
      "الزلزلة",
      "العاديات",
      "القارعة",
      "التكاثر",
      "العصر",
      "الهمزة",
      "الفيل",
      "قريش",
      "الماعون",
      "الكوثر",
      "الكافرون",
      "النصر",
      "المسد",
      "الإخلاص",
      "الفلق",
      "الناس",
    ],
  };

  List<String> remarks = ['Excellent', 'Excellent', 'Excellent'];

  final _paraController = TextEditingController();
  final _suraController = TextEditingController();
  final _linesController = TextEditingController();
  final _sabqiController = TextEditingController();
  final _manzilController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppDataProvider>();
      final todayStr = DateTime.now().toString().split(' ')[0];
      setState(() {
        isAlreadySubmitted = provider.isProgressLogSubmitted(
          todayStr,
          widget.studentId,
        );
      });
    });
  }

  @override
  void dispose() {
    _paraController.dispose();
    _suraController.dispose();
    _linesController.dispose();
    _sabqiController.dispose();
    _manzilController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName, style: const TextStyle(fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              if (context.locale == const Locale('en')) {
                context.setLocale(const Locale('ur'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAlreadySubmitted) _buildSubmittedBanner(),
                const SizedBox(height: 10),

                // Sabaq Section
                Text(
                  'sabaq'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paraController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'para_no'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSurahAutocomplete()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _linesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'lines_pages'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildRemarksSelector(0),
                const SizedBox(height: 20),

                // Sabqi Section
                Text(
                  'sabqi'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sabqiController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'sabqi_hint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                _buildRemarksSelector(1),
                const SizedBox(height: 20),

                // Manzil Section
                Text(
                  'manzil'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _manzilController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'manzil_hint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                _buildRemarksSelector(2),
                const SizedBox(height: 20),

                // General Remarks Section
                Text(
                  'remarks'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'remarks_hint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadySubmitted
                          ? Colors.grey.shade400
                          : const Color(0xFF0F9D58),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isAlreadySubmitted ? null : _submitForm,
                    child: Text(
                      isAlreadySubmitted
                          ? 'already_submitted'.tr()
                          : 'submit_log'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedBanner() {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.lock, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Record is already submitted.',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahAutocomplete() {
    return RawAutocomplete<String>(
      textEditingController: _suraController,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        final selectedPara = int.tryParse(_paraController.text.trim());
        if (selectedPara == null ||
            !quranParaSurahMap.containsKey(selectedPara)) {
          return const Iterable<String>.empty();
        }

        final availableSurahs = quranParaSurahMap[selectedPara]!;
        if (textEditingValue.text.isEmpty) return availableSurahs;

        return availableSurahs.where((String surah) {
          return surah.contains(textEditingValue.text.trim());
        });
      },
      onSelected: (String selection) {
        _suraController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'sura'.tr(),
              hintText: "اختر السورة",
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemarksSelector(int ind) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment<String>(
          value: 'Excellent',
          label: Text('excellent'.tr(), style: const TextStyle(fontSize: 12)),
          icon: const Icon(Icons.thumb_up_outlined),
        ),
        ButtonSegment<String>(
          value: 'Good',
          label: Text('good'.tr(), style: const TextStyle(fontSize: 12)),
          icon: const Icon(Icons.check_circle_outline),
        ),
        ButtonSegment<String>(
          value: 'Needs Practice',
          label: Text(
            'needs_practice'.tr(),
            style: const TextStyle(fontSize: 12),
          ),
          icon: const Icon(Icons.thumb_down_outlined),
        ),
      ],
      selected: {remarks[ind]},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          remarks[ind] = newSelection.first;
        });
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: remarks[ind] == 'Excellent'
            ? Colors.green[100]
            : remarks[ind] == 'Good'
            ? Colors.blue[100]
            : Colors.orange[100],
        selectedForegroundColor: remarks[ind] == 'Excellent'
            ? Colors.green[800]
            : remarks[ind] == 'Good'
            ? Colors.blue[800]
            : Colors.orange[800],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Submission"),
          content: const Text(
            "Are you sure you want to submit this progress log?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final provider = context.read<AppDataProvider>();
    final todayStr = DateTime.now().toString().split(' ')[0];

    await provider.addProgressLog(
      studentId: widget.studentId,
      studentName: widget.studentName,
      surah: _suraController.text.trim(),
      para: _paraController.text.trim(),
      lines: _linesController.text.trim(),
      sabqi: _sabqiController.text.trim(),
      manzil: _manzilController.text.trim(),
      remarksList: remarks,
      generalRemarks: _remarksController.text.trim(),
    );

    await provider.submitProgressLogForDate(todayStr, widget.studentId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress log saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
