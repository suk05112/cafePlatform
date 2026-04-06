import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';
import 'package:cafeplatform/Payment/payment_ui_tokens.dart';

/// Figma 1683:764 — 신용카드 / 간편결제 칩 선택 (PG 연동 전 UI)
class FigmaPaymentMethodSection extends StatefulWidget {
  const FigmaPaymentMethodSection({
    super.key,
    required this.onSelectionChanged,
    this.initialSelection = '카카오페이',
  });

  final ValueChanged<String> onSelectionChanged;
  final String initialSelection;

  @override
  State<FigmaPaymentMethodSection> createState() =>
      _FigmaPaymentMethodSectionState();
}

class _FigmaPaymentMethodSectionState extends State<FigmaPaymentMethodSection> {
  static const _cards = [
    'KB카드',
    '신한카드',
    '하나카드',
    '우리카드',
    '삼성카드',
    '롯데카드',
    '현대카드',
    '농협카드',
  ];
  static const _easy = ['카카오페이', '네이버페이', '페이코'];

  late String _selected;
  _PayCategory _category = _PayCategory.easy;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
    if (_easy.contains(_selected)) {
      _category = _PayCategory.easy;
    } else if (_cards.contains(_selected)) {
      _category = _PayCategory.card;
    } else {
      _category = _PayCategory.easy;
      _selected = _easy.first;
    }
  }

  void _pick(String label, _PayCategory cat) {
    setState(() {
      _selected = label;
      _category = cat;
    });
    widget.onSelectionChanged(label);
  }

  /// 한쪽만 펼침: 신용카드 선택 시 간편결제 칩 숨김, 반대도 동일.
  void _selectCategory(_PayCategory cat) {
    setState(() {
      _category = cat;
      if (cat == _PayCategory.card && !_cards.contains(_selected)) {
        _selected = _cards.first;
      } else if (cat == _PayCategory.easy && !_easy.contains(_selected)) {
        _selected = _easy.first;
      }
    });
    widget.onSelectionChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: '신용카드',
          selected: _category == _PayCategory.card,
          expanded: _category == _PayCategory.card,
          onTap: () => _selectCategory(_PayCategory.card),
        ),
        if (_category == _PayCategory.card) ...[
          const SizedBox(height: 10),
          _chipGrid(_cards, _PayCategory.card),
        ],
        const SizedBox(height: 20),
        _sectionHeader(
          title: '간편결제',
          selected: _category == _PayCategory.easy,
          expanded: _category == _PayCategory.easy,
          onTap: () => _selectCategory(_PayCategory.easy),
        ),
        if (_category == _PayCategory.easy) ...[
          const SizedBox(height: 10),
          _chipGrid(_easy, _PayCategory.easy),
        ],
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required bool selected,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 17,
            height: 17,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PaymentUiTokens.chipBorder),
              color: selected ? const Color(0xFFFF7700) : Colors.transparent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: title == '간편결제' ? 15 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.black54,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _chipGrid(List<String> labels, _PayCategory cat) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final maxW = constraints.maxWidth;
        final cellW = maxW > gap ? (maxW - gap) / 2 : maxW;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: labels.map((name) {
            return SizedBox(
              width: cellW,
              child: _chipCell(name, cat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _chipCell(String name, _PayCategory cat) {
    final isOn = _selected == name && _category == cat;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pick(name, cat),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isOn ? ColorAssset.mainColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOn ? ColorAssset.mainColor : PaymentUiTokens.chipBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isOn ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

enum _PayCategory { card, easy }
