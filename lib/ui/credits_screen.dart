// ui/credits_screen.dart — renders the bundled CREDITS.md (the CC-BY
// attributions legally must ship visibly in-app; CREDITS.md is registered as
// a Flutter asset in pubspec.yaml). Lightweight markdown-ish rendering:
// headers by #-depth, list items, plain paragraphs. No new dependencies.
//
// Source paragraphs are hard-wrapped at ~76 cols, so lines are coalesced into
// logical blocks before rendering — one Text per paragraph/bullet, letting
// Flutter do the wrapping. (Desktop visual pass 2026-09-01: per-line Texts
// rendered ragged mid-sentence breaks.)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One logical block of the credits document.
class CreditsBlock {
  const CreditsBlock(this.kind, this.text, {this.depth = 0});
  final String kind; // 'header' | 'item' | 'para'
  final String text;
  final int depth; // header depth (# count)
}

/// Coalesces hard-wrapped markdown lines into logical blocks. Headers stand
/// alone; a "- " line starts a bullet; following indented/plain lines join
/// the open block; blank lines close it. Markdown noise (**, `) is stripped.
List<CreditsBlock> parseCreditsBlocks(String src) {
  final blocks = <CreditsBlock>[];
  String? kind;
  final buf = StringBuffer();
  void flush() {
    if (kind != null && buf.isNotEmpty) {
      blocks.add(CreditsBlock(kind!, _stripMd(buf.toString())));
    }
    kind = null;
    buf.clear();
  }

  for (final raw in src.split('\n')) {
    final line = raw.trimRight();
    if (line.isEmpty) {
      flush();
    } else if (line.startsWith('#')) {
      flush();
      final depth = line.indexOf(' ');
      blocks.add(CreditsBlock(
          'header', _stripMd(line.substring(depth + 1).trim()),
          depth: depth));
    } else if (line.startsWith('- ')) {
      flush();
      kind = 'item';
      buf.write(line.substring(2).trim());
    } else {
      kind ??= 'para';
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(line.trim());
    }
  }
  flush();
  return blocks;
}

/// Drop **bold** and `code` markers, keep the content.
String _stripMd(String s) => s.replaceAll('**', '').replaceAll('`', '');

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141420),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('CREDITS & LICENSES',
            style: TextStyle(
                fontFamily: 'Cinzel',
                color: Color(0xFFE8A33D),
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('CREDITS.md'),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE8A33D)));
          }
          final blocks = parseCreditsBlocks(snap.data!);
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: blocks.length,
            itemBuilder: (context, i) => _block(blocks[i]),
          );
        },
      ),
    );
  }

  Widget _block(CreditsBlock b) {
    if (b.kind == 'header') {
      return Padding(
        padding: EdgeInsets.only(top: b.depth <= 1 ? 4 : 14, bottom: 6),
        child: Text(b.text,
            style: TextStyle(
                fontFamily: 'Cinzel',
                fontWeight: FontWeight.bold,
                fontSize: b.depth <= 1 ? 20 : (b.depth == 2 ? 16 : 14),
                color: const Color(0xFFE8A33D))),
      );
    }
    final isItem = b.kind == 'item';
    return Padding(
      padding: EdgeInsets.only(left: isItem ? 12 : 0, bottom: isItem ? 4 : 8),
      child: Text(isItem ? '\u2022  ${b.text}' : b.text,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, height: 1.4)),
    );
  }
}
