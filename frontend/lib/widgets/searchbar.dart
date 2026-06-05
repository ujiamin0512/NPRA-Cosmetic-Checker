import 'package:flutter/material.dart';

class NpraSearchBar extends StatefulWidget {
  const NpraSearchBar({super.key, this.onSearch});

  final ValueChanged<String>? onSearch;

  @override
  State<NpraSearchBar> createState() => _NpraSearchBarState();
}

class _NpraSearchBarState extends State<NpraSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _hasText = value.isNotEmpty;
    });
  }

  void _triggerSearch() {
    final String query = _controller.text.trim();
    if (query.isEmpty) return;
    widget.onSearch?.call(query);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      onSubmitted: (_) => _triggerSearch(),
      style: const TextStyle(
        color: Color(0xFF333752),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search for cosmetics',
        hintStyle: const TextStyle(
          color: Color(0xFF8A8DA4),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF8A8DA4),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_hasText)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF8A8DA4),
                ),
                onPressed: _clear,
              ),
          ],
        ),
        filled: true,
        fillColor: const Color(0xFFF1F4FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
  }
}
